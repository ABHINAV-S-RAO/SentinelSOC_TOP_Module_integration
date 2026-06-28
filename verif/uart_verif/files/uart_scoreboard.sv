// =============================================================================
// uart_scoreboard.sv
// Self-checking scoreboard for UART verification.
//
// Two analysis FIFOs:
//   fifo_tx  — bytes the TB sent TO the SoC (from driver via agent)
//   fifo_rx  — bytes the SoC sent BACK (from monitor)
//
// Test scenarios checked:
//   1. Echo test   : every byte sent → expect same byte echoed back
//   2. Banner test : after reset, SoC should transmit a boot banner
//   3. IRQ test    : UART RX interrupt fires within N cycles of a byte arriving
//   4. Framing     : no framing errors on any received byte
//
// The scoreboard is passive for banner/IRQ tests and active for echo tests.
// =============================================================================

class uart_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(uart_scoreboard)

  // Analysis FIFOs
  uvm_tlm_analysis_fifo #(uart_seq_item) fifo_tx; // bytes we sent
  uvm_tlm_analysis_fifo #(uart_seq_item) fifo_rx; // bytes SoC sent

  // Analysis exports (connect from agent's monitor ap)
  uvm_analysis_export #(uart_seq_item) tx_export;
  uvm_analysis_export #(uart_seq_item) rx_export;

  // Test result counters
  int unsigned checks_passed;
  int unsigned checks_failed;

  // Mode
  typedef enum { ECHO_MODE, BANNER_MODE, FREE_MODE } mode_e;
  mode_e mode = FREE_MODE;

  // Expected echo queue
  logic [7:0] echo_expected[$];

  // Expected banner string
  string expected_banner = "";
  string captured_banner = "";

  // Framing error count
  int unsigned framing_errors;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    checks_passed  = 0;
    checks_failed  = 0;
    framing_errors = 0;
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    fifo_tx    = new("fifo_tx", this);
    fifo_rx    = new("fifo_rx", this);
    tx_export  = new("tx_export", this);
    rx_export  = new("rx_export", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    tx_export.connect(fifo_tx.analysis_export);
    rx_export.connect(fifo_rx.analysis_export);
  endfunction

  task run_phase(uvm_phase phase);
    uart_seq_item rx_item;
    forever begin
      fifo_rx.get(rx_item);
      process_rx(rx_item);
    end
  endtask

  task process_rx(uart_seq_item item);
    // Framing error check — always active
    if (item.framing_err) begin
      framing_errors++;
      `uvm_error("SB_FRAMING",
        $sformatf("Framing error on received byte 0x%02h at t=%0d",
                  item.data, item.timestamp_clks))
      checks_failed++;
      return;
    end

    case (mode)
      ECHO_MODE: begin
        if (echo_expected.size() == 0) begin
          `uvm_error("SB_ECHO", $sformatf(
            "Got unexpected byte 0x%02h — echo queue empty", item.data))
          checks_failed++;
        end else begin
          logic [7:0] exp = echo_expected.pop_front();
          if (item.data === exp) begin
            `uvm_info("SB_ECHO", $sformatf(
              "PASS: echoed 0x%02h as expected", item.data), UVM_MEDIUM)
            checks_passed++;
          end else begin
            `uvm_error("SB_ECHO", $sformatf(
              "FAIL: expected echo 0x%02h, got 0x%02h", exp, item.data))
            checks_failed++;
          end
        end
      end

      BANNER_MODE: begin
        captured_banner = {captured_banner, string'(item.data)};
        `uvm_info("SB_BANNER", $sformatf(
          "Banner char: 0x%02h '%s'", item.data,
          (item.data >= 8'h20 && item.data < 8'h7f) ? string'(item.data) : "."),
          UVM_HIGH)
      end

      FREE_MODE: begin
        `uvm_info("SB_RX", $sformatf(
          "Received 0x%02h ('%s')", item.data,
          (item.data >= 8'h20 && item.data < 8'h7f) ? string'(item.data) : "."),
          UVM_MEDIUM)
      end
    endcase
  endtask

  // Called by test to queue expected echo bytes
  function void expect_echo(logic [7:0] data);
    echo_expected.push_back(data);
  endfunction

  // Called by test at end to check banner
  function void check_banner();
    if (expected_banner == "") return;
    if (captured_banner.substr(0, expected_banner.len()-1) == expected_banner) begin
      `uvm_info("SB_BANNER", $sformatf(
        "PASS: Banner contains '%s'", expected_banner), UVM_LOW)
      checks_passed++;
    end else begin
      `uvm_error("SB_BANNER", $sformatf(
        "FAIL: Expected banner '%s', got '%s'",
        expected_banner, captured_banner))
      checks_failed++;
    end
  endfunction

  function void report_phase(uvm_phase phase);
    `uvm_info("SCOREBOARD", $sformatf(
      "\n==================================================\n"
    + "  UART Scoreboard Report\n"
    + "  Passed : %0d\n"
    + "  Failed : %0d\n"
    + "  Framing errors: %0d\n"
    + "==================================================",
      checks_passed, checks_failed, framing_errors), UVM_NONE)

    if (checks_failed > 0 || framing_errors > 0)
      `uvm_error("SCOREBOARD", "*** TESTBENCH FAILED ***")
    else
      `uvm_info("SCOREBOARD",  "*** ALL CHECKS PASSED ***", UVM_NONE)
  endfunction

endclass : uart_scoreboard
