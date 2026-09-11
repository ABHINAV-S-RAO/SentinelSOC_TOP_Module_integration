`timescale 1ns/1ps

module sentinel_soc_uvm_top;
  import uvm_pkg::*;
  import sentinel_soc_uvm_pkg::*;

  // ---------------------------------------------------------------------------
  // Clock & Reset
  // ---------------------------------------------------------------------------
  logic clk_i;
  logic rst_ni;

  initial begin
    clk_i = 0;
    forever #10 clk_i = ~clk_i; // 50 MHz
  end

  initial begin
    rst_ni = 0;
    #100;
    rst_ni = 1;
  end

  // ---------------------------------------------------------------------------
  // Interface Instantiation
  // ---------------------------------------------------------------------------
  sentinel_soc_if vif(clk_i, rst_ni);

  // Enable DIFT
  initial vif.dift_en = 1'b1;

  // ---------------------------------------------------------------------------
  // DUT Instantiation
  // ---------------------------------------------------------------------------
  sentinel_soc_top u_dut (
    .clk_i              ( vif.clk ),
    .rst_ni             ( vif.rst_n ),

    // QSPI
    .qspi_csn_o         ( vif.qspi_csn ),
    .qspi_clk_o         ( vif.qspi_clk ),
    .qspi_io_io         ( vif.qspi_io ),

    // SPI
    .spi_csn_o          ( vif.spi_csn ),
    .spi_clk_o          ( vif.spi_clk ),
    .spi_mosi_o         ( vif.spi_mosi ),
    .spi_miso_i         ( vif.spi_miso ),

    // UART
    .uart_tx_o          ( vif.uart_tx ),
    .uart_rx_i          ( vif.uart_rx ),

    // GPIO
    .gpio_io            ( vif.gpio ),

    // JTAG
    .jtag_tck_i         ( vif.jtag_tck ),
    .jtag_tms_i         ( vif.jtag_tms ),
    .jtag_tdi_i         ( vif.jtag_tdi ),
    .jtag_tdo_o         ( vif.jtag_tdo ),
    .jtag_trst_ni       ( vif.jtag_trst_n ),

`ifdef DIFT
    .dift_en_i          ( vif.dift_en )
`endif
  );

  // Load Firmware
  initial begin
    // Make sure we have compiled bootrom.hex in the software directory
    $display("[UVM_TOP] Loading firmware into BootROM...");
    $readmemh("software/bootrom.hex", u_dut.u_bootrom.mem);
  end

  // ---------------------------------------------------------------------------
  // UVM Initialization
  // ---------------------------------------------------------------------------
  initial begin
    uvm_config_db#(virtual sentinel_soc_if)::set(null, "uvm_test_top.*", "vif", vif);
    uvm_config_db#(virtual sentinel_soc_if)::set(null, "uvm_test_top.env", "vif", vif); 
    run_test("sentinel_soc_base_test");
  end

  // ---------------------------------------------------------------------------
  // Waveform Dumping
  // ---------------------------------------------------------------------------
  initial begin
    $shm_open("waves.shm");
    $shm_probe("ACMT");
  end

endmodule
