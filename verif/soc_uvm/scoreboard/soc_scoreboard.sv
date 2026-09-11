`ifndef SOC_SCOREBOARD_SV
`define SOC_SCOREBOARD_SV

// Declare specialized analysis implementation suffixes for multiple imp ports
`uvm_analysis_imp_decl(_qspi)
`uvm_analysis_imp_decl(_apb)
`uvm_analysis_imp_decl(_addr)
`uvm_analysis_imp_decl(_dift)

typedef byte byte_arr_t[];

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

  function automatic void build_phase(uvm_phase phase);
    super.build_phase(phase);
    void'(uvm_config_db#(byte_arr_t)::get(this, "", "expected_flash_image", expected_flash_image));
    if (!uvm_config_db#(qspi_flash_bfm)::get(this, "", "bfm_h", bfm_h))
      `uvm_warning("SCB", "no flash BFM handle - QSPI data-integrity checks disabled")
  endfunction

  // --- QSPI: cross-check monitor-decoded read data against flash contents
  function automatic void write_qspi(qspi_txn t);
    byte unsigned expected;
    if (t.mode == 2'b10 || t.cmd inside {8'h03, 8'h0B, 8'h6B, 8'hEB}) begin
      if (bfm_h != null) begin
        foreach (t.data[i]) begin
          expected = bfm_h.peek_byte(t.addr + i);
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
  function automatic void write_apb(apb_txn t);
    if (t.pslverr)
      `uvm_info("SCB_APB", $sformatf("%0s: PSLVERR at addr=0x%08h", t.periph, t.paddr), UVM_MEDIUM)
    if (t.periph == "UART" && t.write && t.paddr[2:0] == 3'h0)
      observed_uart_stream.push_back(t.pdata[7:0]);
  endfunction

  // --- addr decode: aggregate violations
  function automatic void write_addr(addr_decode_event e);
    if (e.onehot_violation || e.region_mismatch) addr_decode_violations++;
  endfunction

  // --- DIFT: walk expected queue in order
  function automatic void write_dift(dift_event e);
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

  function automatic void check_phase(uvm_phase phase);
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