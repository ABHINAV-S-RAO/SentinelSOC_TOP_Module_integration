`timescale 1ns/1ps

// =============================================================================
// sentinel_soc_vip_uvm_top -- VIP "NoCore" testbench for final_soc_top
// (the tape-out SoC). The Ibex core is switched off and a UVM OBI CPU agent
// drives the core's data bus; the UART/SPI/JTAG AVIPs, the QSPI flash BFM,
// the GPIO VIP and the timer IRQ interface watch/drive the chip pins.
//
// Build with +define+NO_CORE (see Makefile). The boot watchdog is disabled in
// this mode: with no core running, nothing ever finishes booting, and the
// watchdog would otherwise drop the chip into JTAG recovery mid-test.
// =============================================================================
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
    // Start out of reset, then pulse reset low->high so any block waiting
    // on @(negedge reset)/@(posedge reset) -- e.g. UartRxMonitorBfm's
    // WaitForReset() -- actually observes a real falling edge.
    rst_ni = 1;
    #20;
    rst_ni = 0;
    #100;
    rst_ni = 1;
  end

  // ---------------------------------------------------------------------------
  // Interfaces
  // ---------------------------------------------------------------------------
  sentinel_soc_if vif(clk_i, rst_ni);

  // UART AVIP
  UartIf u_uart_if(clk_i, rst_ni);
  UartTxAgentBfm u_uart_tx_bfm(u_uart_if);
  UartRxAgentBfm u_uart_rx_bfm(u_uart_if);

  // SPI AVIP (on the general-purpose SPI master, spi2)
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

  // JTAG clock (25 MHz, period 40 ns)
  logic jtag_tck;
  initial begin
    jtag_tck = 0;
    forever #20 jtag_tck = ~jtag_tck;
  end

  // JTAG AVIP
  JtagIf u_jtag_if(jtag_tck, rst_ni);
  JtagControllerDeviceAgentBfm u_jtag_ctrl_bfm(u_jtag_if);
  JtagTargetDeviceMonitorBfm   u_jtag_target_mon_bfm (
    .clk   (u_jtag_if.clk),
    .reset (u_jtag_if.reset),
    .Tdo   (u_jtag_if.Tdo),
    .Tms   (u_jtag_if.Tms),
    .Tdi   (u_jtag_if.Tdi),
    .Trst  (u_jtag_if.Trst)
  );

  // CPU agent
  obi_if u_obi_if(clk_i, rst_ni);

  // GPIO VIP
  gpio_if u_gpio_if(clk_i, rst_ni);

  // Timer IRQ
  timer_irq_if u_timer_if(clk_i, rst_ni);

  // ---------------------------------------------------------------------------
  // DUT pins
  // ---------------------------------------------------------------------------
  logic        dut_uart_tx;

  // QSPI flash controller (0x1050_0000)
  logic        qspi_clk;
  logic [3:0]  qspi_csn;
  logic [1:0]  qspi_mode;
  logic [3:0]  qspi_sdo;
  logic        qspi_sdi0, qspi_sdi1, qspi_sdi2, qspi_sdi3;

  // General-purpose SPI master (0x1050_2000)
  logic [3:0]  spi2_csn;

  // GPIO pads: the chip has split in/out/dir, the GPIO VIP has one shared
  // bus. The chip drives a pin only where its direction bit is 1 (output).
  logic [31:0] gpio_out, gpio_dir;
  genvar gi;
  generate
    for (gi = 0; gi < 32; gi++) begin : gen_gpio_pad
      assign u_gpio_if.gpio_pins[gi] = gpio_dir[gi] ? gpio_out[gi] : 1'bz;
    end
  endgenerate

  // Memories outside the chip (SRAM macro ports)
  logic        bootrom_req, bootrom_gnt, bootrom_rvalid, bootrom_we, bootrom_err;
  logic [3:0]  bootrom_be;
  logic [31:0] bootrom_addr, bootrom_wdata, bootrom_rdata;
  logic        isram_req, isram_gnt, isram_rvalid, isram_we, isram_err;
  logic [3:0]  isram_be;
  logic [31:0] isram_addr, isram_wdata, isram_rdata;
  logic        data_req, data_gnt, data_rvalid, data_we, data_err;
  logic [3:0]  data_be;
  logic [31:0] data_addr, data_wdata, data_rdata;

  // JTAG pin conditioning (IEEE 1149.1 pull-ups): keeps 'X' from the VIP's
  // padding bits out of the DUT TAP state machine.
  wire dut_jtag_tms    = ($isunknown(u_jtag_if.Tms))  ? 1'b1 : u_jtag_if.Tms;
  wire dut_jtag_tdi    = ($isunknown(u_jtag_if.Tdi))  ? 1'b0 : u_jtag_if.Tdi;
  wire dut_jtag_trst_n = ($isunknown(u_jtag_if.Trst)) ? 1'b1 : u_jtag_if.Trst;

  // ---------------------------------------------------------------------------
  // DUT: the tape-out SoC
  // ---------------------------------------------------------------------------
  final_soc_top #(
`ifdef NO_CORE
    .BOOT_WDT_CYCLES   ( 0 ),               // no core -> no boot -> no watchdog
`endif
    .SECURE_BOOT       ( 1'b1 ),
    .CRYPTO_CLK_DIV    ( 2 ),
    .HAS_GPIO          ( 1'b1 )
  ) u_dut (
    .clk_i             ( clk_i ),
    .rst_ni            ( rst_ni ),
    .crypto_verified_i ( 1'b0 ),            // unused with SECURE_BOOT=1
    .boot_mode_i       ( 1'b0 ),            // normal boot strap

    // UART
    .uart_tx_o         ( dut_uart_tx ),     // DUT TX -> VIP RX
    .uart_rx_i         ( u_uart_if.tx ),    // VIP TX -> DUT RX

    // Memories
    .bootrom_req_o     ( bootrom_req    ),
    .bootrom_gnt_i     ( bootrom_gnt    ),
    .bootrom_rvalid_i  ( bootrom_rvalid ),
    .bootrom_addr_o    ( bootrom_addr   ),
    .bootrom_we_o      ( bootrom_we     ),
    .bootrom_be_o      ( bootrom_be     ),
    .bootrom_wdata_o   ( bootrom_wdata  ),
    .bootrom_rdata_i   ( bootrom_rdata  ),
    .bootrom_err_i     ( bootrom_err    ),
    .isram_req_o       ( isram_req      ),
    .isram_gnt_i       ( isram_gnt      ),
    .isram_rvalid_i    ( isram_rvalid   ),
    .isram_addr_o      ( isram_addr     ),
    .isram_we_o        ( isram_we       ),
    .isram_be_o        ( isram_be       ),
    .isram_wdata_o     ( isram_wdata    ),
    .isram_rdata_i     ( isram_rdata    ),
    .isram_err_i       ( isram_err      ),

    // QSPI -> flash BFM
    .spi_clk_o         ( qspi_clk ),
    .spi_csn_o         ( qspi_csn ),
    .spi_mode_o        ( qspi_mode ),
    .spi_sdo_o         ( qspi_sdo ),
    .spi_sdi_i         ( {qspi_sdi3, qspi_sdi2, qspi_sdi1, qspi_sdi0} ),

    // SPI2 -> SPI AVIP (single lane, chip select 0)
    .spi2_clk_o        ( u_spi_if.sclk ),
    .spi2_csn_o        ( spi2_csn ),
    .spi2_sdo_o        ( u_spi_if.mosi0 ),
    .spi2_sdi_i        ( u_spi_if.miso0 ),

    // GPIO
    .gpio_in_i         ( u_gpio_if.gpio_pins ),
    .gpio_out_o        ( gpio_out ),
    .gpio_dir_o        ( gpio_dir ),

    // DSRAM
    .data_req_o        ( data_req    ),
    .data_gnt_i        ( data_gnt    ),
    .data_rvalid_i     ( data_rvalid ),
    .data_addr_o       ( data_addr   ),
    .data_we_o         ( data_we     ),
    .data_be_o         ( data_be     ),
    .data_wdata_o      ( data_wdata  ),
    .data_rdata_i      ( data_rdata  ),
    .data_err_i        ( data_err    ),

    // JTAG
    .jtag_tck_i        ( jtag_tck ),
    .jtag_tms_i        ( dut_jtag_tms ),
    .jtag_trst_ni      ( dut_jtag_trst_n ),
    .jtag_tdi_i        ( dut_jtag_tdi ),
    .jtag_tdo_o        ( u_jtag_if.Tdo )
  );

  assign u_spi_if.cs[0] = spi2_csn[0];

  // ---------------------------------------------------------------------------
  // External memory models (same models as full_soc_tb)
  // ---------------------------------------------------------------------------
  bootrom_model #(.DEPTH(16384), .HEX_FILE("")) u_bootrom (
    .clk_i(clk_i), .rst_ni(rst_ni), .req_i(bootrom_req), .gnt_o(bootrom_gnt),
    .rvalid_o(bootrom_rvalid), .addr_i(bootrom_addr), .we_i(bootrom_we),
    .be_i(bootrom_be), .wdata_i(bootrom_wdata), .rdata_o(bootrom_rdata), .err_o(bootrom_err));

  isram_model #(.DEPTH(65536), .HEX_FILE("")) u_isram (
    .clk_i(clk_i), .rst_ni(rst_ni), .req_i(isram_req), .gnt_o(isram_gnt),
    .rvalid_o(isram_rvalid), .addr_i(isram_addr), .we_i(isram_we),
    .be_i(isram_be), .wdata_i(isram_wdata), .rdata_o(isram_rdata), .err_o(isram_err));

  dsram_model #(.DEPTH(16384), .HEX_FILE("")) u_dsram (
    .clk_i(clk_i), .rst_ni(rst_ni), .req_i(data_req), .gnt_o(data_gnt),
    .rvalid_o(data_rvalid), .addr_i(data_addr), .we_i(data_we),
    .be_i(data_be), .wdata_i(data_wdata), .rdata_o(data_rdata), .err_o(data_err));

  // ---------------------------------------------------------------------------
  // QSPI flash BFM on the boot-flash pins
  // ---------------------------------------------------------------------------
  qspi_flash_bfm u_qspi_bfm (
    .spi_clk  ( qspi_clk ),
    .spi_csn0 ( qspi_csn[0] ),
    .spi_mode ( qspi_mode ),
    .spi_sdo0 ( qspi_sdo[0] ),
    .spi_sdo1 ( qspi_sdo[1] ),
    .spi_sdo2 ( qspi_sdo[2] ),
    .spi_sdo3 ( qspi_sdo[3] ),
    .spi_sdi0 ( qspi_sdi0 ),
    .spi_sdi1 ( qspi_sdi1 ),
    .spi_sdi2 ( qspi_sdi2 ),
    .spi_sdi3 ( qspi_sdi3 )
  );

  // ---------------------------------------------------------------------------
  // NoCore: switch Ibex off, drive its data bus from the UVM CPU agent
  // ---------------------------------------------------------------------------
`ifdef NO_CORE
  // A force with a single net on the right-hand side tracks it continuously.
  wire        tb_req   = u_obi_if.req;
  wire        tb_we    = u_obi_if.we;
  wire [31:0] tb_addr  = u_obi_if.addr;
  wire [31:0] tb_wdata = u_obi_if.wdata;
  wire [ 3:0] tb_be    = u_obi_if.be;

  initial begin
    $assertoff(0, sentinel_soc_vip_uvm_top.u_dut.u_ibex_top);

    // Ibex never fetches, and its instruction bus stays silent
    force u_dut.u_ibex_top.fetch_enable_i = 4'b1010;   // IbexMuBiOff
    force u_dut.instr_req_int = 1'b0;

    // Data bus follows the CPU agent
    force u_dut.core_data_req   = tb_req;
    force u_dut.core_data_we    = tb_we;
    force u_dut.core_data_addr  = tb_addr;
    force u_dut.core_data_wdata = tb_wdata;
    force u_dut.core_data_be    = tb_be;
  end

  assign u_obi_if.gnt    = u_dut.core_data_gnt;
  assign u_obi_if.rvalid = u_dut.core_data_rvalid;
  assign u_obi_if.rdata  = u_dut.core_data_rdata;
  assign u_obi_if.err    = u_dut.core_data_err;

`ifdef DEBUG_BUS_TRACE
  always @(posedge clk_i) begin
    if (u_obi_if.req || u_dut.core_data_rvalid || u_dut.dift_data_req || u_dut.dift_data_rvalid ||
        u_dut.apb_req || u_dut.apb_rvalid || u_dut.apb_req_struct.psel)
      $display("[HW_TRACE] %0t: rst=%b sys_rst=%b | core req=%b we=%b addr=%08h gnt=%b rv=%b err=%b | dift req=%b gnt=%b rv=%b | apbport req=%b gnt=%b rv=%b | psel=%b pen=%b paddr=%08h pready=%b pslverr=%b",
        $time, rst_ni, u_dut.sys_rst_n,
        u_dut.core_data_req, u_dut.core_data_we, u_dut.core_data_addr,
        u_dut.core_data_gnt, u_dut.core_data_rvalid, u_dut.core_data_err,
        u_dut.dift_data_req, u_dut.dift_data_gnt, u_dut.dift_data_rvalid,
        u_dut.apb_req, u_dut.apb_gnt, u_dut.apb_rvalid,
        u_dut.apb_req_struct.psel, u_dut.apb_req_struct.penable, u_dut.apb_req_struct.paddr,
        u_dut.apb_rsp_struct.pready, u_dut.apb_rsp_struct.pslverr);
  end
`endif
`endif

  // ---------------------------------------------------------------------------
  // UART RX: UartRxDriverBfm drives rx to 1. To avoid two drivers on that
  // line, force it to the DUT's TX instead.
  // ---------------------------------------------------------------------------
  initial begin
    force u_uart_if.rx = dut_uart_tx;
  end

  // ---------------------------------------------------------------------------
  // Timer IRQ
  // ---------------------------------------------------------------------------
  assign u_timer_if.irq_timer     = u_dut.irq_timer_periph;
  assign u_timer_if.irq_timer_raw = u_dut.timer_irqs;

  // ---------------------------------------------------------------------------
  // UVM
  // ---------------------------------------------------------------------------
  initial begin
    uvm_config_db#(virtual sentinel_soc_if)::set(null, "*", "vif", vif);
    uvm_config_db#(virtual UartIf)::set(null, "*", "vif_uart", u_uart_if);
    uvm_config_db#(virtual obi_if)::set(null, "*", "vif_obi", u_obi_if);
    uvm_config_db#(virtual gpio_if)::set(null, "*", "vif_gpio", u_gpio_if);
    uvm_config_db#(virtual timer_irq_if)::set(null, "*", "vif_timer", u_timer_if);
    uvm_config_db#(virtual SpiInterface)::set(null, "*", "vif_spi", u_spi_if);
    uvm_config_db#(virtual SpiMasterMonitorBFM)::set(null, "*", "SpiMasterMonitorBFM", u_spi_master_monitor_bfm);
    uvm_config_db#(virtual JtagIf)::set(null, "*", "vif_jtag", u_jtag_if);
    uvm_config_db#(virtual JtagTargetDeviceMonitorBfm)::set(null, "*", "jtagTargetDeviceMonitorBfm", u_jtag_target_mon_bfm);

    run_test();
  end

  // ---------------------------------------------------------------------------
  // Waveforms
  // ---------------------------------------------------------------------------
  initial begin
    $shm_open("waves_vip.shm");
    $shm_probe(sentinel_soc_vip_uvm_top, "AS");
  end

endmodule
