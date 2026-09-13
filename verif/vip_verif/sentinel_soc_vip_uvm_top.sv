`timescale 1ns/1ps

module sentinel_soc_vip_uvm_top;
  import uvm_pkg::*;
  import sentinel_soc_vip_uvm_pkg::*;

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
  initial vif.dift_en = 1'b1;

  // AVIP Interfaces
  UartIf u_uart_if(clk_i, rst_ni);
  
  // CPU Agent Interface
  obi_if u_obi_if(clk_i, rst_ni);
  
  // GPIO Interface
  gpio_if u_gpio_if(clk_i, rst_ni);
  
  // Timer IRQ Interface
  timer_irq_if u_timer_if(clk_i, rst_ni);

  // QSPI BFM Instantiation
  qspi_flash_bfm u_qspi_bfm (
    .clk_i(vif.qspi_clk),
    .rst_ni(rst_ni),
    .csn_i(vif.qspi_csn),
    .data_io(vif.qspi_io)
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
    .uart_tx_o          ( u_uart_if.rx ), // DUT TX goes to VIP RX
    .uart_rx_i          ( u_uart_if.tx ), // VIP TX goes to DUT RX

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
  initial begin
    $display("[VIP-TB] Loading default firmware: software/bootrom.hex");
    $readmemh("software/bootrom.hex", u_dut.u_bootrom.mem);
  end

  // ---------------------------------------------------------------------------
  // NoCore Bypassing (CPU Agent Injection)
  // ---------------------------------------------------------------------------
  initial begin
`ifdef NO_CORE
    // Force Ibex fetch disable so it doesn't do anything
    force u_dut.u_ibex_top.fetch_enable_i = 1'b0;
    
    // Force OBI signals from our obi_if into the crossbar/dift_obi_ctrl
    force u_dut.core_data_req   = u_obi_if.req;
    force u_dut.core_data_we    = u_obi_if.we;
    force u_dut.core_data_addr  = u_obi_if.addr;
    force u_dut.core_data_wdata = u_obi_if.wdata;
    force u_dut.core_data_be    = u_obi_if.be;
    
    // Assign monitor signals back to obi_if
    assign u_obi_if.gnt    = u_dut.core_data_gnt;
    assign u_obi_if.rvalid = u_dut.core_data_rvalid;
    assign u_obi_if.rdata  = u_dut.core_data_rdata;
`endif
  end

  // ---------------------------------------------------------------------------
  // UVM Initialization
  // ---------------------------------------------------------------------------
  initial begin
    uvm_config_db#(virtual sentinel_soc_if)::set(null, "uvm_test_top.*", "vif", vif);
    uvm_config_db#(virtual UartIf)::set(null, "uvm_test_top.*", "vif_uart", u_uart_if);
    uvm_config_db#(virtual obi_if)::set(null, "uvm_test_top.*", "vif_obi", u_obi_if);
    uvm_config_db#(virtual gpio_if)::set(null, "uvm_test_top.*", "vif_gpio", u_gpio_if);
    uvm_config_db#(virtual timer_irq_if)::set(null, "uvm_test_top.*", "vif_timer", u_timer_if);
    
    run_test("sentinel_soc_vip_base_test");
  end

  // ---------------------------------------------------------------------------
  // Waveform Dumping
  // ---------------------------------------------------------------------------
  initial begin
    $shm_open("waves_vip.shm");
    $shm_probe("ACMT");
  end

endmodule
