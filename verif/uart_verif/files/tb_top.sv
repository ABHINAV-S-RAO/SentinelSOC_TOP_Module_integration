// =============================================================================
// tb_top.sv
// Top-level simulation module for SentinelSoC UART UVM testbench.
//
// Instantiates:
//   - soc_top DUT
//   - uart_if  (physical UART pins)
//   - soc_top_if (clock/reset/IRQ observation interface)
//   - UVM kickoff via run_test()
//
// Clock: 50 MHz (20 ns period)
// Reset: active-low, released after 20 cycles
// =============================================================================

`timescale 1ns/1ps

// ── SoC probe interface ──────────────────────────────────────────────────────
// Gives UVM tests access to clock, reset, and key internal signals
// without modifying soc_top.
interface soc_top_if (
  input logic clk,
  input logic rst_n
);
  // Driven by TB
  logic rst_n_drive;

  // Observed from DUT (hierarchical refs resolved in tb_top)
  logic irq_uart;
  logic irq_external;
  logic uart_tx;

  // Allow test to drive reset
  assign rst_n = rst_n_drive;

  clocking cb @(posedge clk);
    default input #1step output #1;
    input  irq_uart;
    input  irq_external;
    input  uart_tx;
    output rst_n_drive;
  endclocking

endinterface : soc_top_if


// ── Testbench top ────────────────────────────────────────────────────────────
module tb_top;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // UVM component files — include order matters
  `include "uart_seq_item.sv"
  `include "uart_if.sv"
  `include "uart_driver.sv"
  `include "uart_monitor.sv"
  `include "uart_scoreboard.sv"
  `include "uart_agent.sv"
  `include "uart_sequences.sv"
  `include "uart_env.sv"
  `include "uart_tests.sv"

  // ── Clock generation ───────────────────────────────────────────────────────
  localparam real CLK_PERIOD = 20.0; // 50 MHz

  logic clk;
  logic rst_n;

  initial clk = 1'b0;
  always  #(CLK_PERIOD/2) clk = ~clk;

  // ── DUT I/O ───────────────────────────────────────────────────────────────
  logic       qspi_csn, qspi_clk;
  wire  [3:0] qspi_io;
  logic       spi_csn, spi_clk, spi_mosi, spi_miso;
  logic       uart_tx, uart_rx;
  wire [31:0] gpio_io;
  logic       jtag_tck, jtag_tms, jtag_tdi, jtag_tdo, jtag_trst_n;

  // Tie unused inouts
  assign qspi_io  = 4'bZZZZ;
  assign gpio_io  = 32'hZZZZ_ZZZZ;
  assign spi_miso = 1'b0;
  assign jtag_tck    = 1'b0;
  assign jtag_tms    = 1'b0;
  assign jtag_tdi    = 1'b0;
  assign jtag_trst_n = 1'b1;

  // ── DUT ───────────────────────────────────────────────────────────────────
  soc_top u_dut (
    .clk_i        ( clk         ),
    .rst_ni       ( rst_n       ),
    .qspi_csn_o   ( qspi_csn   ),
    .qspi_clk_o   ( qspi_clk   ),
    .qspi_io_io   ( qspi_io    ),
    .spi_csn_o    ( spi_csn    ),
    .spi_clk_o    ( spi_clk    ),
    .spi_mosi_o   ( spi_mosi   ),
    .spi_miso_i   ( spi_miso   ),
    .uart_tx_o    ( uart_tx    ),
    .uart_rx_i    ( uart_rx    ),
    .gpio_io      ( gpio_io    ),
    .jtag_tck_i   ( jtag_tck   ),
    .jtag_tms_i   ( jtag_tms   ),
    .jtag_tdi_i   ( jtag_tdi   ),
    .jtag_tdo_o   ( jtag_tdo   ),
    .jtag_trst_ni ( jtag_trst_n)
  );

  // ── Interfaces ────────────────────────────────────────────────────────────
  uart_if    uart_if_inst  (.clk(clk));
  soc_top_if soc_if_inst   (.clk(clk), .rst_n(rst_n));

  // Connect UART interface to DUT pins
  assign uart_rx                = uart_if_inst.rx;
  assign uart_if_inst.tx        = uart_tx;

  // Connect SoC interface probes to DUT internal signals
  // (hierarchical references — adjust path if module names differ)
  assign soc_if_inst.irq_uart     = u_dut.irq_uart;
  assign soc_if_inst.irq_external = u_dut.irq_external;
  assign soc_if_inst.uart_tx      = uart_tx;

  // Reset driven through soc_if
  assign rst_n = soc_if_inst.rst_n_drive;

  // ── UVM config DB population ──────────────────────────────────────────────
  initial begin
    uvm_config_db #(virtual uart_if)::set(null, "uvm_test_top.*",
                                          "uart_vif", uart_if_inst);
    uvm_config_db #(virtual soc_top_if)::set(null, "uvm_test_top.*",
                                             "soc_vif", soc_if_inst);

    // Default reset — held until test applies it
    soc_if_inst.rst_n_drive = 1'b0;
    uart_if_inst.rx         = 1'b1; // idle

    // Start UVM — test name passed via +UVM_TESTNAME=<test>
    // Examples:
    //   xsim +UVM_TESTNAME=uart_banner_test
    //   xsim +UVM_TESTNAME=uart_echo_test
    //   xsim +UVM_TESTNAME=uart_irq_test
    //   xsim +UVM_TESTNAME=uart_stress_test
    //   xsim +UVM_TESTNAME=uart_full_test
    run_test();
  end

  // ── Watchdog ──────────────────────────────────────────────────────────────
  initial begin
    #50_000_000; // 50 ms at 50 MHz = 2.5 million cycles, covers all tests
    `uvm_fatal("WATCHDOG", "Simulation timeout!")
  end

  // ── Waveform dump (optional) ──────────────────────────────────────────────
  initial begin
    if ($test$plusargs("WAVES")) begin
      $dumpfile("uart_tb.vcd");
      $dumpvars(0, tb_top);
    end
  end

endmodule : tb_top
