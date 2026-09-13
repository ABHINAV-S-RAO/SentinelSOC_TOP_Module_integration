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
  UartTxAgentBfm u_uart_tx_bfm(u_uart_if);
  UartRxAgentBfm u_uart_rx_bfm(u_uart_if);
  
  // CPU Agent Interface
  obi_if u_obi_if(clk_i, rst_ni);
  
  // GPIO Interface
  gpio_if u_gpio_if(clk_i, rst_ni);
  
  // Timer IRQ Interface
  timer_irq_if u_timer_if(clk_i, rst_ni);

  logic qspi_sdi0, qspi_sdi1, qspi_sdi2, qspi_sdi3;
  
  // QSPI BFM Instantiation
  qspi_flash_bfm u_qspi_bfm (
    .spi_clk (vif.qspi_clk),
    .spi_csn0(vif.qspi_csn),
    .spi_mode(2'b00),
    .spi_sdo0(vif.qspi_io[0]),
    .spi_sdo1(vif.qspi_io[1]),
    .spi_sdo2(vif.qspi_io[2]),
    .spi_sdo3(vif.qspi_io[3]),
    .spi_sdi0(qspi_sdi0),
    .spi_sdi1(qspi_sdi1),
    .spi_sdi2(qspi_sdi2),
    .spi_sdi3(qspi_sdi3)
  );

  // ---------------------------------------------------------------------------
  // DUT Instantiation
  // ---------------------------------------------------------------------------
  logic dut_uart_tx;

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
    .uart_tx_o          ( dut_uart_tx ), // DUT TX goes to VIP RX
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
`ifdef NO_CORE
  initial begin
    // Force Ibex fetch disable so it doesn't do anything
    force u_dut.u_ibex_top.fetch_enable_i = 4'b1010;
    
    // Fully silence Ibex's instruction bus
    force u_dut.core_instr_req = 1'b0;
  end

  // Continuously force OBI signals from our obi_if into the crossbar/dift_obi_ctrl.
  // In SystemVerilog, force inside an initial block with a variable on the RHS evaluates once.
  // BUT if the RHS is a single net (wire), the simulator sets up continuous tracking!
  wire        tb_req   = u_obi_if.req;
  wire        tb_we    = u_obi_if.we;
  wire [31:0] tb_addr  = u_obi_if.addr;
  wire [31:0] tb_wdata = u_obi_if.wdata;
  wire [ 3:0] tb_be    = u_obi_if.be;

  initial begin
    // Force Ibex fetch disable so it doesn't do anything
    force u_dut.u_ibex_top.fetch_enable_i = 4'b1010;
    
    // Fully silence Ibex's instruction bus
    force u_dut.core_instr_req = 1'b0;

    // Force data bus to track testbench wires continuously
    force u_dut.core_data_req   = tb_req;
    force u_dut.core_data_we    = tb_we;
    force u_dut.core_data_addr  = tb_addr;
    force u_dut.core_data_wdata = tb_wdata;
    force u_dut.core_data_be    = tb_be;
  end

  // Assign monitor signals back to obi_if
  assign u_obi_if.gnt    = u_dut.core_data_gnt;
  assign u_obi_if.rvalid = u_dut.core_data_rvalid;
  assign u_obi_if.rdata  = u_dut.core_data_rdata;
  assign u_obi_if.err    = u_dut.core_data_err;

  // DEBUG MONITOR
  always @(posedge clk_i) begin
    // Only print when there's an active request or a valid response to avoid flooding the terminal
    if (u_obi_if.req || u_dut.apb_bridge_req || u_dut.core_data_rvalid || u_dut.apb_bridge_rvalid) begin
      $display("[HW_TRACE] %0t: u_obi_req=%b core_req=%b gnt=%b rvalid=%b | apb_req=%b apb_gnt=%b apb_rvalid=%b | pready=%b psel_uart=%b", 
        $time, 
        u_obi_if.req, u_dut.core_data_req, u_dut.core_data_gnt, u_dut.core_data_rvalid,
        u_dut.apb_bridge_req, u_dut.apb_bridge_gnt, u_dut.apb_bridge_rvalid,
        u_dut.apb_rsp.pready, u_dut.psel_uart
      );
    end
  end
`endif

  // ---------------------------------------------------------------------------
  // UART VIP Multiple-Driver Workaround
  // ---------------------------------------------------------------------------
  // UartRxDriverBfm actively drives rx to 1. To prevent a multiple-driver 
  // collision with the DUT's tx output, we force the rx line instead.
  initial begin
    force u_uart_if.rx = dut_uart_tx;
  end

  // ---------------------------------------------------------------------------
  // UVM Initialization
  // ---------------------------------------------------------------------------
  initial begin
    uvm_config_db#(virtual sentinel_soc_if)::set(null, "*", "vif", vif);
    uvm_config_db#(virtual UartIf)::set(null, "*", "vif_uart", u_uart_if);
    uvm_config_db#(virtual obi_if)::set(null, "*", "vif_obi", u_obi_if);
    uvm_config_db#(virtual gpio_if)::set(null, "*", "vif_gpio", u_gpio_if);
    uvm_config_db#(virtual timer_irq_if)::set(null, "*", "vif_timer", u_timer_if);
    
    run_test();
  end

  // ---------------------------------------------------------------------------
  // Waveform Dumping
  // ---------------------------------------------------------------------------
  initial begin
    $shm_open("waves_vip.shm");
    $shm_probe("ACMT");
  end

endmodule
