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
    forever #10 clk_i = ~clk_i; // 50 MHz (20ns period)
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

  // Enable DIFT by default
  initial vif.dift_en = 1'b1;

  // ---------------------------------------------------------------------------
  // QSPI BFM Model Instantiation
  // ---------------------------------------------------------------------------
  logic qspi_sdi0, qspi_sdi1, qspi_sdi2, qspi_sdi3;
  assign vif.qspi_io[0] = (!vif.qspi_csn && (u_qspi_bfm.phase == u_qspi_bfm.PH_DATA)) ? qspi_sdi0 : 1'bz;

  qspi_flash_bfm u_qspi_bfm (
    .spi_clk  ( vif.qspi_clk ),
    .spi_csn0 ( vif.qspi_csn ),
    .spi_mode ( 2'b00 ),
    .spi_sdo0 ( vif.qspi_io[0] ),
    .spi_sdo1 ( vif.qspi_io[1] ),
    .spi_sdo2 ( vif.qspi_io[2] ),
    .spi_sdo3 ( vif.qspi_io[3] ),
    .spi_sdi0 ( qspi_sdi0 ),
    .spi_sdi1 ( qspi_sdi1 ),
    .spi_sdi2 ( qspi_sdi2 ),
    .spi_sdi3 ( qspi_sdi3 )
  );

  // ---------------------------------------------------------------------------
  // Deadlock & Protocol Monitor
  // ---------------------------------------------------------------------------
  soc_deadlock_monitor u_deadlock_mon (
    .clk   ( vif.clk ),
    .rst_n ( vif.rst_n )
  );

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

  // ---------------------------------------------------------------------------
  // Load Firmware
  // ---------------------------------------------------------------------------
  string firmware_file;
  initial begin
    if ($value$plusargs("FIRMWARE=%s", firmware_file)) begin
      $display("[TB] Loading firmware from: %s", firmware_file);
      $readmemh(firmware_file, u_dut.u_bootrom.mem);
    end else begin
      $display("[TB] Loading default firmware: software/bootrom.hex");
      $readmemh("software/bootrom.hex", u_dut.u_bootrom.mem);
    end

    // Backdoor OTP Programming for crypto_accelerator verification
    // 256-bit dummy key loaded into OTP array
    u_dut.u_otp.otp_mem = 256'hDEADBEEF_CAFEBABE_B007B007_12345678_87654321_09876543_AAAABBBB_CCCCDDDD;
  end

  // ---------------------------------------------------------------------------
  // Interface Configuration
  // ---------------------------------------------------------------------------
  int dift_en_arg;
  initial begin
    if (!$value$plusargs("DIFT_EN=%d", dift_en_arg)) begin
      dift_en_arg = 1; // Default DIFT ON
    end
    vif.dift_en = dift_en_arg[0];
  end

  // ---------------------------------------------------------------------------
  // UVM Initialization
  // ---------------------------------------------------------------------------
  initial begin
    uvm_config_db#(virtual sentinel_soc_if)::set(null, "*", "vif", vif);
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
