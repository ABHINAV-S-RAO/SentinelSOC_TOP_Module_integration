// =============================================================================
// basic_soc_top.sv
// Updated Top-Level SoC with Data OBI Exports, System Decoder & Security Regs
// =============================================================================

`include "obi/typedef.svh"
`include "obi/assign.svh"
`include "apb/typedef.svh"

module basic_soc_top (
  input  logic        clk_i,
  input  logic        rst_ni,

  // Hardware Security Verification Status
  input  logic        crypto_verified_i,

  // UART Interface
  output logic        uart_tx_o,
  input  logic        uart_rx_i,

  // DIFT Control
`ifdef DIFT
  input  logic        dift_en_i,
`endif

  // Instruction Fetch OBI Interface (Driven by Testbench Dummy Mem)
  output logic        instr_req_o,
  input  logic        instr_gnt_i,
  input  logic        instr_rvalid_i,
  output logic [31:0] instr_addr_o,
  input  logic [31:0] instr_rdata_i,
  input  logic [6:0]  instr_rdata_intg_i,
  input  logic        instr_err_i,

  // EXPORTED Data OBI Interface (To Testbench Memory/Scoreboard)
  output logic        data_req_o,
  input  logic        data_gnt_i,
  input  logic        data_rvalid_i,
  output logic [31:0] data_addr_o,
  output logic        data_we_o,
  output logic [3:0]  data_be_o,
  output logic [31:0] data_wdata_o,
  input  logic [31:0] data_rdata_i,
  input  logic        data_err_i
);

  localparam logic [31:0] BOOT_ADDR          = 32'h0000_0000;
  localparam logic [31:0] HART_ID            = 32'h0000_0000;
  localparam int unsigned DSRAM_SIZE_WORDS   = 1024;

  // Core Data OBI
  logic        core_data_req, core_data_gnt, core_data_rvalid;
  logic        core_data_we, core_data_err;
  logic [3:0]  core_data_be;
  logic [31:0] core_data_addr, core_data_wdata, core_data_rdata;
  logic [6:0]  core_data_wdata_intg, core_data_rdata_intg;

  // DIFT Intercepted Data OBI
  logic        dift_data_req, dift_data_gnt, dift_data_rvalid;
  logic        dift_data_we, dift_data_err;
  logic [3:0]  dift_data_be;
  logic [31:0] dift_data_addr, dift_data_wdata, dift_data_rdata;

  // Control Signals from Control Registers
  logic        boot_done;
  logic        isram_lock;

  // Address Decoder Subordinate Channels
  // Slot 0: TB External Data RAM
  // Slot 1: APB Peripherals (UART)
  // Slot 2: SOC Control Registers
  logic        apb_req, apb_gnt, apb_rvalid, apb_we, apb_err;
  logic [3:0]  apb_be;
  logic [31:0] apb_addr, apb_wdata, apb_rdata;

  logic        ctrl_req, ctrl_gnt, ctrl_rvalid, ctrl_we, ctrl_err;
  logic [3:0]  ctrl_be;
  logic [31:0] ctrl_addr, ctrl_wdata, ctrl_rdata;
  logic irq_dift, irq_uart;

  // ---------------------------------------------------------------------------
  // Core Instantiation (Ibex)
  // ---------------------------------------------------------------------------
`ifdef DIFT
  logic data_rdata_tag, data_wdata_tag, dift_exception;
`endif

  ibex_top #(
    .PMPEnable        ( 1'b0 ),
    .PMPGranularity   ( 0 ),
    .PMPNumRegions    ( 4 ),
    .MHPMCounterNum   ( 0 ),
    .MHPMCounterWidth ( 40 ),
    .RV32E            ( 1'b0 ),
    .RV32M            ( ibex_pkg::RV32MFast ),
    .RV32B            ( ibex_pkg::RV32BNone ),
    .RegFile          ( ibex_pkg::RegFileFF ),
    .BranchTargetALU  ( 1'b0 ),
    .WritebackStage   ( 1'b1 ),
    .ICache           ( 1'b0 ),
    .BranchPredictor  ( 1'b0 ),
    .DbgTriggerEn     ( 1'b0 ),
    .SecureIbex       ( 1'b0 )
  ) u_ibex_top (
    .clk_i                ( clk_i ),
    .rst_ni               ( rst_ni ),
    .test_en_i            ( 1'b0 ),
    .ram_cfg_icache_tag_i ( '0 ),
    .ram_cfg_icache_data_i( '0 ),
    .ram_cfg_rsp_icache_tag_o(),
    .ram_cfg_rsp_icache_data_o(),
    .hart_id_i            ( HART_ID ),
    .boot_addr_i          ( BOOT_ADDR ),

    .instr_req_o          ( instr_req_o ),
    .instr_gnt_i          ( instr_gnt_i ),
    .instr_rvalid_i       ( instr_rvalid_i ),
    .instr_addr_o         ( instr_addr_o ),
    .instr_rdata_i        ( instr_rdata_i ),
    .instr_rdata_intg_i   ( instr_rdata_intg_i ),
    .instr_err_i          ( instr_err_i ),

    .data_req_o           ( core_data_req ),
    .data_gnt_i           ( core_data_gnt ),
    .data_rvalid_i        ( core_data_rvalid ),
    .data_we_o            ( core_data_we ),
    .data_be_o            ( core_data_be ),
    .data_addr_o          ( core_data_addr ),
    .data_wdata_o         ( core_data_wdata ),
    .data_wdata_intg_o    ( core_data_wdata_intg ),
    .data_rdata_i         ( core_data_rdata ),
    .data_rdata_intg_i    ( '0 ),
    .data_err_i           ( core_data_err ),

    .irq_software_i       ( 1'b0 ),
    .irq_timer_i          ( 1'b0 ),
    .irq_external_i       ( irq_uart ),
    .irq_fast_i           ( 15'h0 ),
    .irq_nm_i             ( irq_dift ),

    .scramble_key_valid_i ( 1'b0 ),
    .scramble_key_i       ( '0 ),
    .scramble_nonce_i     ( '0 ),
    .scramble_req_o       ( ),

    .debug_req_i          ( 1'b0 ),
    .crash_dump_o         ( ),
    .double_fault_seen_o  ( ),
    .fetch_enable_i       ( ibex_pkg::IbexMuBiOn ),
    .alert_minor_o        ( ),
    .alert_major_internal_o(),
    .alert_major_bus_o    ( ),
    .core_sleep_o         ( ),
    .scan_rst_ni          ( 1'b1 ),

    .lockstep_cmp_en_o       (),
    .data_req_shadow_o       (),
    .data_we_shadow_o        (),
    .data_be_shadow_o        (),
    .data_addr_shadow_o      (),
    .data_wdata_shadow_o     (),
    .data_wdata_intg_shadow_o(),
    .instr_req_shadow_o      (),
    .instr_addr_shadow_o     ()

`ifdef DIFT
  ,
    .data_rdata_tag_i     ( data_rdata_tag ),
    .data_wdata_tag_o     ( data_wdata_tag ),
    .dift_exception_o     ( dift_exception ),
    .dift_en_i            ( dift_en_i )
`endif
  );

  // ---------------------------------------------------------------------------
  // DIFT OBI Interceptor
  // ---------------------------------------------------------------------------
  logic tag_req, tag_we;
  logic [29:0] tag_addr;
  logic tag_wdata, tag_rdata;

  dift_obi_ctrl u_dift_obi_ctrl (
    .clk_i              ( clk_i ),
    .rst_ni             ( rst_ni ),

    .core_data_req_i    ( core_data_req ),
    .core_data_addr_i   ( core_data_addr ),
    .core_data_we_i     ( core_data_we ),
    .core_data_be_i     ( core_data_be ),
    .core_data_wdata_i  ( core_data_wdata ),
    .core_data_gnt_o    ( core_data_gnt ),
    .core_data_rvalid_o ( core_data_rvalid ),
    .core_data_rdata_o  ( core_data_rdata ),
    .core_data_err_o    ( core_data_err ),

    .data_obi_req_o     ( dift_data_req ),
    .data_obi_addr_o    ( dift_data_addr ),
    .data_obi_we_o      ( dift_data_we ),
    .data_obi_be_o      ( dift_data_be ),
    .data_obi_wdata_o   ( dift_data_wdata ),
    .data_obi_gnt_i     ( dift_data_gnt ),
    .data_obi_rvalid_i  ( dift_data_rvalid ),
    .data_obi_rdata_i   ( dift_data_rdata ),
    .data_obi_err_i     ( dift_data_err ),

    .tag_req_o          ( tag_req ),
    .tag_we_o           ( tag_we ),
    .tag_addr_o         ( tag_addr ),
    .tag_wdata_o        ( tag_wdata ),
    .tag_rdata_i        ( tag_rdata ),
    .tag_gnt_i          ( 1'b1 ),

`ifdef DIFT
    .core_data_wdata_tag_i ( data_wdata_tag ),
    .core_data_rdata_tag_o ( data_rdata_tag ),
    .dift_exception_i      ( dift_exception ),
    .dift_en_i             ( dift_en_i ),
`endif

    .dift_exception_o   ( irq_dift ),
    .core_instr_req_i   ( 1'b0 ),
    .core_instr_addr_i  ( '0 ),
    .instr_obi_gnt_i    ( 1'b0 ),
    .instr_obi_rvalid_i ( 1'b0 ),
    .instr_obi_rdata_i  ( '0 ),
    .instr_obi_rid_i    ( '0 ),
    .instr_obi_err_i    ( 1'b0 ),
    .data_obi_rid_i     ( '0 ),
    .core_instr_gnt_o   ( ),
    .core_instr_rvalid_o( ),
    .core_instr_rdata_o ( ),
    .core_instr_err_o   ( ),
    .instr_obi_req_o    ( ),
    .instr_obi_addr_o   ( ),
    .instr_obi_we_o     ( ),
    .instr_obi_be_o     ( ),
    .instr_obi_wdata_o  ( ),
    .instr_obi_aid_o    ( ),
    .data_obi_aid_o     ( )
  );

  // Corrected Tag RAM Indexing (Word-aligned index [TAG_AW+1:2])
`ifdef DIFT
  localparam int unsigned TAG_AW = $clog2(DSRAM_SIZE_WORDS);
  logic tag_mem [DSRAM_SIZE_WORDS];
  logic [TAG_AW-1:0] tag_rd_addr_q;

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      tag_rd_addr_q <= '0;
    end else if (tag_req) begin
      tag_rd_addr_q <= tag_addr[TAG_AW+1:2];
    end
  end

  always_ff @(posedge clk_i) begin
    if (tag_req && tag_we)
      tag_mem[tag_addr[TAG_AW+1:2]] <= tag_wdata;
  end
  assign tag_rdata = tag_mem[tag_rd_addr_q];
`else
  assign tag_rdata = 1'b0;
`endif

  // ---------------------------------------------------------------------------
  // Address Decoding: Route DIFT OBI to External RAM, APB Bridge, & SOC Regs
  // ---------------------------------------------------------------------------
  soc_addr_decode u_soc_addr_decode (
    .clk_i               ( clk_i ),
    .rst_ni              ( rst_ni ),
    .boot_done_i         ( boot_done ),
    .fw_verified_i       ( crypto_verified_i ),
    .dbg_mode_i          ( 1'b0 ),
    .ctrl_isram_lock_i   ( isram_lock ),

    // Data Master Input (From DIFT Controller)
    .data_req_i          ( dift_data_req ),
    .data_we_i           ( dift_data_we ),
    .data_be_i           ( dift_data_be ),
    .data_addr_i         ( dift_data_addr ),
    .data_wdata_i        ( dift_data_wdata ),
    .data_gnt_o          ( dift_data_gnt ),
    .data_rvalid_o       ( dift_data_rvalid ),
    .data_rdata_o        ( dift_data_rdata ),
    .data_err_o          ( dift_data_err ),

    // Subordinate 0: External RAM (Exported to Testbench)
    .ram_req_o           ( data_req_o ),
    .ram_we_o            ( data_we_o ),
    .ram_be_o            ( data_be_o ),
    .ram_addr_o          ( data_addr_o ),
    .ram_wdata_o         ( data_wdata_o ),
    .ram_gnt_i           ( data_gnt_i ),
    .ram_rvalid_i        ( data_rvalid_i ),
    .ram_rdata_i         ( data_rdata_i ),
    .ram_err_i           ( data_err_i ),

    // Subordinate 1: APB Peripherals (UART)
    .apb_req_o           ( apb_req ),
    .apb_we_o            ( apb_we ),
    .apb_be_o            ( apb_be ),
    .apb_addr_o          ( apb_addr ),
    .apb_wdata_o         ( apb_wdata ),
    .apb_gnt_i           ( apb_gnt ),
    .apb_rvalid_i        ( apb_rvalid ),
    .apb_rdata_i         ( apb_rdata ),
    .apb_err_i           ( apb_err ),

    // Subordinate 2: SOC Control Registers
    .ctrl_req_o          ( ctrl_req ),
    .ctrl_we_o           ( ctrl_we ),
    .ctrl_be_o           ( ctrl_be ),
    .ctrl_addr_o         ( ctrl_addr ),
    .ctrl_wdata_o        ( ctrl_wdata ),
    .ctrl_gnt_i          ( ctrl_gnt ),
    .ctrl_rvalid_i       ( ctrl_rvalid ),
    .ctrl_rdata_i        ( ctrl_rdata ),
    .ctrl_err_i          ( ctrl_err )
  );

  // ---------------------------------------------------------------------------
  // SOC Control Registers
  // ---------------------------------------------------------------------------
  soc_ctrl_regs u_soc_ctrl_regs (
    .clk_i               ( clk_i ),
    .rst_ni              ( rst_ni ),
    .req_i               ( ctrl_req ),
    .we_i                ( ctrl_we ),
    .be_i                ( ctrl_be ),
    .addr_i              ( ctrl_addr ),
    .wdata_i             ( ctrl_wdata ),
    .gnt_o               ( ctrl_gnt ),
    .rvalid_o            ( ctrl_rvalid ),
    .rdata_o             ( ctrl_rdata ),
    .err_o               ( ctrl_err ),
    .crypto_verified_i   ( crypto_verified_i ),
    .boot_done_o         ( boot_done ),
    .isram_lock_o        ( isram_lock )
  );

  // ---------------------------------------------------------------------------
  // OBI to APB Bridge & UART
  // ---------------------------------------------------------------------------
  `OBI_TYPEDEF_DEFAULT_ALL(obi_apb, obi_pkg::ObiDefaultConfig)
  typedef logic [31:0] apb_addr_t;
  typedef logic [31:0] apb_data_t;
  typedef logic [ 3:0] apb_strb_t;
  `APB_TYPEDEF_ALL(apb, apb_addr_t, apb_data_t, apb_strb_t)

  obi_apb_req_t  apb_obi_req;
  obi_apb_rsp_t  apb_obi_rsp;
  apb_req_t      apb_req_struct;
  apb_resp_t     apb_rsp_struct;

  assign apb_obi_req.req     = apb_req;
  assign apb_obi_req.a.we    = apb_we;
  assign apb_obi_req.a.be    = apb_be;
  assign apb_obi_req.a.addr  = apb_addr;
  assign apb_obi_req.a.wdata = apb_wdata;
  assign apb_obi_req.a.aid   = '0;
  assign apb_obi_req.a.a_optional = '0;

  assign apb_gnt            = apb_obi_rsp.gnt;
  assign apb_rvalid         = apb_obi_rsp.rvalid;
  assign apb_rdata          = apb_obi_rsp.r.rdata;
  assign apb_err            = apb_obi_rsp.r.err;

  obi_to_apb #(
    .ObiCfg     ( obi_pkg::ObiDefaultConfig ),
    .obi_req_t  ( obi_apb_req_t ),
    .obi_rsp_t  ( obi_apb_rsp_t ),
    .apb_req_t  ( apb_req_t ),
    .apb_rsp_t  ( apb_resp_t )
  ) u_obi_to_apb (
    .clk_i      ( clk_i ),
    .rst_ni     ( rst_ni ),
    .obi_req_i  ( apb_obi_req ),
    .obi_rsp_o  ( apb_obi_rsp ),
    .apb_req_o  ( apb_req_struct ),
    .apb_rsp_i  ( apb_rsp_struct )
  );

  logic psel_uart;
  assign psel_uart = (apb_req_struct.paddr[31:12] == 20'h10000);

  apb_uart_sv #(
    .APB_ADDR_WIDTH ( 12 )
  ) u_apb_uart (
    .CLK            ( clk_i ),
    .RSTN           ( rst_ni ),
    .PADDR          ( apb_req_struct.paddr[11:0] ),
    .PWDATA         ( apb_req_struct.pwdata ),
    .PWRITE         ( apb_req_struct.pwrite ),
    .PSEL           ( psel_uart ),
    .PENABLE        ( apb_req_struct.penable ),
    .PRDATA         ( apb_rsp_struct.prdata ),
    .PREADY         ( apb_rsp_struct.pready ),
    .PSLVERR        ( apb_rsp_struct.pslverr ),
    .rx_i           ( uart_rx_i ),
    .tx_o           ( uart_tx_o ),
    .event_o        ( irq_uart )
  );

endmodule