`timescale 1ns/1ps

module soc_tb;

  // 1. Clock and Reset Generation
  logic clk_i = 0;
  logic rst_ni = 0;

  always #10 clk_i = ~clk_i; // 50 MHz clock

  initial begin
    #100 rst_ni = 1; // Release reset after 100ns
    #500000;         // Failsafe timeout
    $display("TIMEOUT: Simulation ran too long without finishing.");
    $finish;
  end

  // 2. Physical Board Traces
  logic       uart_tx;
  logic       uart_rx = 1'b1; // Tie UART RX high (idle)

  logic       board_qspi_csn;
  logic       board_qspi_clk;
  wire  [3:0] board_qspi_io;

  // 3. Instantiate the Full Silicon Chip
  soc_top u_soc (
    .clk_i      ( clk_i ),
    .rst_ni     ( rst_ni ),
    
    // UART
    .uart_tx_o  ( uart_tx ),
    .uart_rx_i  ( uart_rx ),
    
    // QSPI
    .qspi_csn_o ( board_qspi_csn ),
    .qspi_clk_o ( board_qspi_clk ),
    .qspi_io_io ( board_qspi_io ),
    
    // Security / Debug Tie-offs
    .dift_en_i  ( 1'b0 ) // Disable dynamic information flow tracking for this test
    // Note: If you have jtag_* pins exposed at the top level, tie them to 0 here as well.
  );

  // 4. Instantiate the External Dummy Flash
  flash #(
    .MEM_SIZE_BYTES( 1024 * 1024 )
  ) u_dummy_flash (
    .csn_i ( board_qspi_csn ),
    .sck_i ( board_qspi_clk ),
    .io_io ( board_qspi_io )
  );

endmodule