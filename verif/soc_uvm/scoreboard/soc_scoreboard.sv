`ifndef SOC_SCOREBOARD_SV
`define SOC_SCOREBOARD_SV

// Replaces the transaction-counting stub. Each test_all.s variant loads a
// matching expected-value config into this scoreboard via config_db before
// run_phase (see soc_env.sv / individual uvm_test classes). This scoreboard
// does not generate stimulus — firmware does. It only judges what firmware
// produced against what the test author said it should produce.
//
// Four independent checks, each with its own pass/fail, so a QSPI bug and
// a DIFT bug in the same run don't hide behind each other:
//   1. QSPI read data vs. flash contents (via qspi_flash_bfm.peek_byte)
//   2. UART TX byte stream vs. expected string
//   3. DIFT tag transitions vs. expected propagation table
//   4. addr_decode violations, aggregated from addr_decode_monitor
//
// Existing sentinel-code pass/fail at DSRAM_BASE+0x8 (TEST_PASS_CODE /
// TEST_FAIL_CODE) still drives UVM objection drop in sw_status_monitor.sv
// as before — that's unchanged and still the "did firmware think it
// passed" signal. This scoreboard is the independent "did it actually
// happen correctly" signal, and both should agree at end of test.

class dift_expect;
  bit [4:0]  rf_addr;
  bit        expected_tag;
  bit        expect_exception;
endclass

class soc_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(soc_scoreboard)

  uvm_analysis_imp_qspi   #(qspi_txn,          soc_scoreboard) qspi_export;
  uvm_analysis_imp_apb    #(apb_txn,           soc_scoreboard) apb_export;
  uvm_analysis_imp_addr   #(addr_decode_event, soc_scoreboard) addr_export;
  uvm_analysis_imp_dift   #(dift_event,        soc_scoreboard) dift_export;

  // pulled in via config_db, set per-test
  byte           expected_flash_image[];        // full expected flash content, or empty = skip
  byte           expected_uart_stream[$];        // expected TX bytes in order
  dift_expect    expected_dift[$];               // expected tag events in order

  byte           observed_uart_stream[$];
  int            dift_idx;
  int            addr_decode_violations;
  int            qspi_mismatches;
  int            uart_mismatches;
  int            dift_mismatches;

  qspi_flash_bfm bfm_h;  // hierarchical handle set via config_db for peek_byte()

  function new(string name, uvm_component parent);
    super.new(name, parent);
    qspi_export = new("qspi_export", this);
    apb_export  = new("apb_export", this);
    addr_export = new("addr_export", this);
    dift_export = new("dift_export", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    void'(uvm_config_db#(byte[])::get(this, "", "expected_flash_image", expected_flash_image));
    // expected_uart_stream / expected_dift pushed by the test class directly
    // via a handle grab, since queues of class objects don't marshal well
    // through config_db by value.
    if (!uvm_config_db#(qspi_flash_bfm)::get(this, "", "bfm_h", bfm_h))
      `uvm_warning("SCB", "no flash BFM handle — QSPI data-integrity checks disabled")
  endfunction

  // --- QSPI: cross-check monitor-decoded read data against flash contents
  function void write_qspi(qspi_txn t);
    if (t.mode == 2'b10 || t.cmd inside {8'h03, 8'h0B, 8'h6B, 8'hEB}) begin // read-family opcodes; TODO confirm actual opcode map
      if (bfm_h != null) begin
        foreach (t.data[i]) begin
          byte unsigned expected = bfm_h.peek_byte(t.addr + i);
          if (t.data[i] !== expected) begin
            qspi_mismatches++;
            `uvm_error("SCB_QSPI", $sformatf("addr=0x%08h byte[%0d]: got 0x%02h expected 0x%02h",
                                              t.addr, i, t.data[i], expected))
          end
        end
      end
    end
  endfunction

  // --- APB: currently pass-through logging; extend per-peripheral as needed
  function void write_apb(apb_txn t);
    if (t.pslverr)
      `uvm_info("SCB_APB", $sformatf("%0s: PSLVERR at addr=0x%08h", t.periph, t.paddr), UVM_MEDIUM)
    if (t.periph == "UART" && t.write && t.paddr[2:0] == 3'h0) // THR offset per session notes
      observed_uart_stream.push_back(t.pdata[7:0]);
  endfunction

  // --- addr decode: just aggregate, monitor already flags via uvm_error
  function void write_addr(addr_decode_event e);
    if (e.onehot_violation || e.region_mismatch) addr_decode_violations++;
  endfunction

  // --- DIFT: walk expected queue in order, tolerate exception events
  // interrupting the normal sequence (an exception ends the propagation
  // chain early by design)
  function void write_dift(dift_event e);
    if (dift_idx >= expected_dift.size()) return;
    if (e.exception) begin
      if (!expected_dift[dift_idx].expect_exception) begin
        dift_mismatches++;
        `uvm_error("SCB_DIFT", $sformatf("unexpected exception at pc=0x%08h (event #%0d)",
                                          e.exception_pc, dift_idx))
      end
      dift_idx++;
      return;
    end
    if (e.rf_addr != expected_dift[dift_idx].rf_addr ||
        e.tag_in  != expected_dift[dift_idx].expected_tag) begin
      dift_mismatches++;
      `uvm_error("SCB_DIFT", $sformatf("event #%0d: rf_addr=%0d tag=%0b, expected rf_addr=%0d tag=%0b",
                 dift_idx, e.rf_addr, e.tag_in,
                 expected_dift[dift_idx].rf_addr, expected_dift[dift_idx].expected_tag))
    end
    dift_idx++;
  endfunction

  function void check_phase(uvm_phase phase);
    super.check_phase(phase);
    if (observed_uart_stream.size() != expected_uart_stream.size()) begin
      uart_mismatches++;
      `uvm_error("SCB_UART", $sformatf("length mismatch: got %0d bytes, expected %0d",
                 observed_uart_stream.size(), expected_uart_stream.size()))
    end else begin
      foreach (observed_uart_stream[i])
        if (observed_uart_stream[i] != expected_uart_stream[i]) begin
          uart_mismatches++;
          `uvm_error("SCB_UART", $sformatf("byte[%0d]: got 0x%02h expected 0x%02h",
                     i, observed_uart_stream[i], expected_uart_stream[i]))
        end
    end
    if (dift_idx < expected_dift.size())
      `uvm_error("SCB_DIFT", $sformatf("only %0d/%0d expected DIFT events observed",
                 dift_idx, expected_dift.size()))

    `uvm_info("SCB_SUMMARY", $sformatf(
      "qspi_mismatches=%0d uart_mismatches=%0d dift_mismatches=%0d addr_decode_violations=%0d",
      qspi_mismatches, uart_mismatches, dift_mismatches, addr_decode_violations), UVM_LOW)
  endfunction

endclass

`endif