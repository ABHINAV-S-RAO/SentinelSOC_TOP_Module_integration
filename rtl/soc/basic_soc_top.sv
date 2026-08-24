// =============================================================================
// basic_soc_top.sv
// Simplified Top-level SoC for UART/DIFT exhaustive testing.
// Exposes the Instruction OBI interface to the Testbench (Dummy Memory).
// =============================================================================

`include "obi/typedef.svh"
`include "obi/assign.svh"
`include "apb/typedef.svh"

module basic_soc_top (
  input  logic clk_i,
  input  logic rst_ni,

  // UART Interface
  output logic uart_tx_o,
  input  logic uart_rx_i,

  // DIFT Interface
`ifdef DIFT
  input  logic dift_en_i,
`endif

  // Instruction Fetch OBI Interface (Driven by Testbench Dummy Mem)
  output logic        instr_req_o,
  input  logic        instr_gnt_i,
  input  logic        instr_rvalid_i,
  output logic [31:0] instr_addr_o,
  input  logic [31:0] instr_rdata_i,
  input  logic [6:0]  instr_rdata_intg_i,
  input  logic        instr_err_i
);

  localparam logic [31:0] BOOT_ADDR  = 32'h0000_0000;
  localparam logic [31:0] HART_ID    = 32'h0000_0000;
  localparam int unsigned DSRAM_SIZE_WORDS = 1024;

  // ---------------------------------------------------------------------------
  // Internal Signals
  // ---------------------------------------------------------------------------
  // Core Data OBI
  logic        core_data_req;
  logic        core_data_gnt;
  logic        core_data_rvalid;
  logic        core_data_we;
  logic [3:0]  core_data_be;
  logic [31:0] core_data_addr;
  logic [31:0] core_data_wdata;
  logic [6:0]  core_data_wdata_intg;
  logic [31:0] core_data_rdata;
  logic [6:0]  core_data_rdata_intg;
  logic        core_data_err;

  // DIFT Intercepted Data OBI
  logic        dift_data_req;
  logic        dift_data_gnt;
  logic        dift_data_rvalid;
  logic        dift_data_we;
  logic [3:0]  dift_data_be;
  logic [31:0] dift_data_addr;
  logic [31:0] dift_data_wdata;
  logic [31:0] dift_data_rdata;
  logic        dift_data_err;

  // Struct instances for OBI to APB
  `OBI_TYPEDEF_DEFAULT_ALL(obi_apb, obi_pkg::ObiDefaultConfig)
  typedef logic [31:0] apb_addr_t;
  typedef logic [31:0] apb_data_t;
  typedef logic [ 3:0] apb_strb_t;
  `APB_TYPEDEF_ALL(apb, apb_addr_t, apb_data_t, apb_strb_t)

  obi_apb_req_t  apb_obi_req;
  obi_apb_rsp_t  apb_obi_rsp;
  apb_req_t      apb_req;
  apb_resp_t     apb_rsp;

  // Assign DIFT intercepted signals to OBI Struct
  assign apb_obi_req.req     = dift_data_req;
  assign apb_obi_req.a.we    = dift_data_we;
  assign apb_obi_req.a.be    = dift_data_be;
  assign apb_obi_req.a.addr  = dift_data_addr;
  assign apb_obi_req.a.wdata = dift_data_wdata;
  assign dift_data_gnt       = apb_obi_rsp.gnt;
  assign dift_data_rvalid    = apb_obi_rsp.rvalid;
  assign dift_data_rdata     = apb_obi_rsp.r.rdata;
  assign dift_data_err       = apb_obi_rsp.r.err;

  // Tie off unused OBI struct fields
  assign apb_obi_req.a.aid        = '0;
  assign apb_obi_req.a.a_optional = '0;

  // Interrupts
  logic irq_software_i = 1'b0;
  logic irq_timer_i    = 1'b0;
  logic irq_external_i;
  logic irq_nm_i;
  logic irq_dift;
  logic irq_uart;

  // Route UART interrupt to external interrupt
  assign irq_external_i = irq_uart;
  
  // Route DIFT exception to NMI
  assign irq_nm_i       = irq_dift;
  
  // Default values for unimplemented features
  assign core_data_rdata_intg = '0;

  // ---------------------------------------------------------------------------
  // Core Instantiation
  // ---------------------------------------------------------------------------
`ifdef DIFT
  logic data_rdata_tag;
  logic data_wdata_tag;
  logic dift_exception;
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

    // Instruction Interface -> Top Level Pins
    .instr_req_o          ( instr_req_o ),
    .instr_gnt_i          ( instr_gnt_i ),
    .instr_rvalid_i       ( instr_rvalid_i ),
    .instr_addr_o         ( instr_addr_o ),
    .instr_rdata_i        ( instr_rdata_i ),
    .instr_rdata_intg_i   ( instr_rdata_intg_i ),
    .instr_err_i          ( instr_err_i ),

    // Data Interface -> DIFT Intercept
    .data_req_o           ( core_data_req ),
    .data_gnt_i           ( core_data_gnt ),
    .data_rvalid_i        ( core_data_rvalid ),
    .data_we_o            ( core_data_we ),
    .data_be_o            ( core_data_be ),
    .data_addr_o          ( core_data_addr ),
    .data_wdata_o         ( core_data_wdata ),
    .data_wdata_intg_o    ( core_data_wdata_intg ),
    .data_rdata_i         ( core_data_rdata ),
    .data_rdata_intg_i    ( core_data_rdata_intg ),
    .data_err_i           ( core_data_err ),

    .irq_software_i       ( irq_software_i ),
    .irq_timer_i          ( irq_timer_i ),
    .irq_external_i       ( irq_external_i ),
    .irq_fast_i           ( 15'h0 ),
    .irq_nm_i             ( irq_nm_i ),

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

    // Data port from core
    .core_data_req_i    ( core_data_req ),
    .core_data_addr_i   ( core_data_addr ),
    .core_data_we_i     ( core_data_we ),
    .core_data_be_i     ( core_data_be ),
    .core_data_wdata_i  ( core_data_wdata ),
    .core_data_gnt_o    ( core_data_gnt ),
    .core_data_rvalid_o ( core_data_rvalid ),
    .core_data_rdata_o  ( core_data_rdata ),
    .core_data_err_o    ( core_data_err ),

    // Data port to memory/peripherals
    .data_obi_req_o     ( dift_data_req ),
    .data_obi_addr_o    ( dift_data_addr ),
    .data_obi_we_o      ( dift_data_we ),
    .data_obi_be_o      ( dift_data_be ),
    .data_obi_wdata_o   ( dift_data_wdata ),
    .data_obi_gnt_i     ( dift_data_gnt ),
    .data_obi_rvalid_i  ( dift_data_rvalid ),
    .data_obi_rdata_i   ( dift_data_rdata ),
    .data_obi_err_i     ( dift_data_err ),

    // Shadow tag RAM interface
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
    
    // Unused Instruction / Identifier Ports
    .core_instr_req_i   ( 1'b0 ),
    .core_instr_addr_i  ( '0 ),
    .instr_obi_gnt_i    ( 1'b0 ),
    .instr_obi_rvalid_i ( 1'b0 ),
    .instr_obi_rdata_i  ( '0 ),
    .instr_obi_rid_i    ( '0 ),
    .instr_obi_err_i    ( 1'b0 ),
    .data_obi_rid_i     ( '0 ),
    
    // Explicitly disconnected outputs
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

  // Minimal Shadow SRAM (Tag memory)
`ifdef DIFT
  localparam int unsigned TAG_AW = $clog2(DSRAM_SIZE_WORDS);
  logic tag_mem [DSRAM_SIZE_WORDS];
  logic [TAG_AW-1:0] tag_rd_addr_q;

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      tag_rd_addr_q <= '0;
    end else if (tag_req) begin
      tag_rd_addr_q <= tag_addr[TAG_AW-1:0];
    end
  end

  always_ff @(posedge clk_i) begin
    if (tag_req && tag_we)
      tag_mem[tag_addr[TAG_AW-1:0]] <= tag_wdata;
  end
  assign tag_rdata = tag_mem[tag_rd_addr_q];
`else
  assign tag_rdata = 1'b0;
`endif

  // ---------------------------------------------------------------------------
  // OBI to APB Bridge
  // ---------------------------------------------------------------------------
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
    .apb_req_o  ( apb_req ),
    .apb_rsp_i  ( apb_rsp )
  );

  // ---------------------------------------------------------------------------
  // APB UART 
  // ---------------------------------------------------------------------------
  logic psel_uart;
  // Route to UART if APB request is in range (e.g. 0x1000_0000 -> 0x1000_0FFF)
  assign psel_uart = (apb_req.paddr[31:12] == 20'h10000); 

  apb_uart_sv #(
    .APB_ADDR_WIDTH ( 12 )
  ) u_apb_uart (
    .CLK            ( clk_i ),
    .RSTN           ( rst_ni ),
    .PADDR          ( apb_req.paddr[11:0] ),
    .PWDATA         ( apb_req.pwdata ),
    .PWRITE         ( apb_req.pwrite ),
    .PSEL           ( psel_uart ),
    .PENABLE        ( apb_req.penable ),
    .PRDATA         ( apb_rsp.prdata ),
    .PREADY         ( apb_rsp.pready ),
    .PSLVERR        ( apb_rsp.pslverr ),
    .rx_i           ( uart_rx_i ),
    .tx_o           ( uart_tx_o ),
    .event_o        ( irq_uart )
  );

endmodule
