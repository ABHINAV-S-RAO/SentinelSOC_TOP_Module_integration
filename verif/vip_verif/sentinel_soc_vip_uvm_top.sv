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

  SpiInterface  u_spi_if(clk_i, rst_ni);
  SpiMasterMonitorBFM u_spi_master_monitor_bfm (.pclk(u_spi_if.pclk),
                                               .areset(u_spi_if.areset),
                                               .sclk(u_spi_if.sclk),
                                               .cs(u_spi_if.cs),
                                               .mosi0(u_spi_if.mosi0),
                                               .mosi1(u_spi_if.mosi1),
                                               .mosi2(u_spi_if.mosi2),
                                               .mosi3(u_spi_if.mosi3),
                                               .miso0(u_spi_if.miso0),
                                               .miso1(u_spi_if.miso1),
                                               .miso2(u_spi_if.miso2),
                                               .miso3(u_spi_if.miso3));

  SpiSlaveAgentBFM  u_spi_slave_agent_bfm  (.spiInterface(u_spi_if));
  JtagIf u_jtag_if(clk_i, rst_ni);

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

    // UART
    .uart_tx_o          ( dut_uart_tx ), // DUT TX goes to VIP RX
    .uart_rx_i          ( u_uart_if.tx ), // VIP TX goes to DUT RX

    // GPIO
    .gpio_io            ( u_gpio_if.gpio_pins ),

    // SPI
    .spi_csn_o          ( u_spi_if.cs[0] ),
    .spi_clk_o          ( u_spi_if.sclk ),
    .spi_mosi_o         ( u_spi_if.mosi0 ),
    .spi_miso_i         ( u_spi_if.miso0),

    // JTAG
    .jtag_tck_i         ( clk_i ),
    .jtag_tms_i         ( u_jtag_if.Tms ),
    .jtag_tdi_i         ( u_jtag_if.Tdi ),
    .jtag_tdo_o         ( u_jtag_if.Tdo ),
    .jtag_trst_ni       ( u_jtag_if.Trst)

`ifdef DIFT
    ,
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
      // $display("[HW_TRACE] %0t: core_req=%b sbr_req=%b sbr_port_req=%b mgr_req7=%b | sel=%d inflight=%b | demux_gnt=%b apb_req=%b",
      //   $time,
      //   u_dut.core_data_req, u_dut.u_addr_decode.data_req_s.req, u_dut.u_addr_decode.u_data_demux.sbr_port_req_i.req, u_dut.u_addr_decode.u_data_demux.mgr_ports_req_o[7].req,
      //   u_dut.u_addr_decode.data_sel, u_dut.u_addr_decode.u_data_demux.in_flight,
      //   u_dut.u_addr_decode.u_data_demux.sbr_port_gnt, u_dut.apb_bridge_req
      // );
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
    uvm_config_db#(virtual SpiInterface)::set(null, "*", "vif_spi", u_spi_if);
    uvm_config_db#(virtual JtagIf)::set(null, "*", "vif_jtag", u_jtag_if);
    uvm_config_db#(virtual SpiMasterMonitorBFM)::set(null,"*", "SpiMasterMonitorBFM", u_spi_master_monitor_bfm);

    run_test();
  end

  // ---------------------------------------------------------------------------
  // Waveform Dumping
  // ---------------------------------------------------------------------------
  initial begin
    $dumpfile("waves_vip.vcd");
    $dumpvars(0, sentinel_soc_vip_uvm_top);
  end

`ifdef NO_CORE
  initial $assertoff(0, u_dut.u_ibex_top);
`endif
endmodule