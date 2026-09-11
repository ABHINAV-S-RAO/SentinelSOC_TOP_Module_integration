// =============================================================================
// sentinel_soc_if.sv
// Top-level interface for the Sentinel SoC
// =============================================================================

interface sentinel_soc_if (input logic clk, input logic rst_n);
  
  // QSPI — external flash
  logic       qspi_csn;
  logic       qspi_clk;
  wire  [3:0] qspi_io;

  // SPI
  logic       spi_csn;
  logic       spi_clk;
  logic       spi_mosi;
  logic       spi_miso;

  // UART
  logic       uart_tx;
  logic       uart_rx;

  // GPIO
  wire [31:0] gpio;

  // JTAG
  logic       jtag_tck;
  logic       jtag_tms;
  logic       jtag_tdi;
  logic       jtag_tdo;
  logic       jtag_trst_n;

  // DIFT Hardware Enable
  logic       dift_en;

  // ---------------------------------------------------------------------------
  // Simple UART TX Monitor (Prints firmware output to console)
  // ---------------------------------------------------------------------------
  // Assuming 115200 baud at 50MHz clk -> ~434 clks per bit
  logic [7:0] rx_byte;
  integer bit_period = 434;

  initial begin
    forever begin
      @(negedge uart_tx); // start bit
      repeat (bit_period + bit_period/2) @(posedge clk); // 1.5 bit periods
      for (int i=0; i<8; i++) begin
        rx_byte[i] = uart_tx;
        repeat (bit_period) @(posedge clk);
      end
      $write("%c", rx_byte);
      // Wait for stop bit
      repeat (bit_period) @(posedge clk);
    end
  end

endinterface
