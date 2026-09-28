`include "obi/typedef.svh"
`include "obi/assign.svh"
`include "apb/typedef.svh"
 
module basic_soc_top #(
  // Boot watchdog for JTAG recovery (soc_recovery.sv): cycles of core
  // execution without boot_done before recovery is forced. 0 = disabled.
  parameter int unsigned BOOT_WDT_CYCLES = 32'd1_000_000,  // 10 ms @ 100 MHz

  // 1 = hardware-fed Ed25519 secure boot (soc_secure_boot): ISRAM executes
  //     only the signature-verified code range. crypto_verified_i is unused.
  // 0 = legacy: ISRAM fetch gated directly by the crypto_verified_i pin
  //     (for testbenches that predate secure boot).
  parameter bit          SECURE_BOOT     = 1'b1,
  parameter int unsigned CRYPTO_CLK_DIV  = 2,               // crypto clock = clk_i / N

  // 1 = PULP apb_gpio instantiated (rtl/peripheral/apb_gpio must be in the
  // filelist). 0 = GPIO window returns an APB error, gpio_*_o driven 0.
  parameter bit          HAS_GPIO        = 1'b0
) (
  input  logic        clk_i,
  input  logic        rst_ni,
 
  // Legacy verification pin, used only when SECURE_BOOT=0
  input  logic        crypto_verified_i,

  // Boot-mode strap: 1 = JTAG recovery boot (hart held halted, bootrom
  // never executes). Sampled once after power-on reset.
  input  logic        boot_mode_i,
 
  // UART Interface
  output logic        uart_tx_o,
  input  logic        uart_rx_i,
 
  // DIFT Control
`ifdef DIFT
  input  logic        dift_en_i,
`endif
 
  // BootROM OBI Interface (real backing memory, testbench-preloaded with
  // the loader code; read-only in practice -- soc_addr_decode already
  // errors data writes to this region, we/be/wdata ports exist only
  // because soc_addr_decode's arbiter needs them structurally)
  output logic        bootrom_req_o,
  input  logic        bootrom_gnt_i,
  input  logic        bootrom_rvalid_i,
  output logic [31:0] bootrom_addr_o,
  output logic        bootrom_we_o,
  output logic [3:0]  bootrom_be_o,
  output logic [31:0] bootrom_wdata_o,
  input  logic [31:0] bootrom_rdata_i,
  input  logic         bootrom_err_i,
 
  // ISRAM OBI Interface (real backing memory, testbench-preloaded as scratch;
  // both fetch and data-writable -- this is where the loader copies the
  // flash image to before jumping)
  output logic        isram_req_o,
  input  logic        isram_gnt_i,
  input  logic        isram_rvalid_i,
  output logic [31:0] isram_addr_o,
  output logic        isram_we_o,
  output logic [3:0]  isram_be_o,
  output logic [31:0] isram_wdata_o,
  input  logic [31:0] isram_rdata_i,
  input  logic        isram_err_i,
 
  // QSPI flash controller (APB 0x1050_0000) -- external boot flash
  output logic        spi_clk_o,
  output logic [3:0]  spi_csn_o,
  output logic [1:0]  spi_mode_o,      // 00 standard, 01 quad-tx, 10 quad-rx
  output logic [3:0]  spi_sdo_o,
  input  logic [3:0]  spi_sdi_i,

  // General-purpose SPI master (APB 0x1050_2000), single-lane
  output logic        spi2_clk_o,
  output logic [3:0]  spi2_csn_o,
  output logic        spi2_sdo_o,
  input  logic        spi2_sdi_i,

  // GPIO (APB 0x1060_0000); pads are split in/out/dir, tristate is off-chip
  input  logic [31:0] gpio_in_i,
  output logic [31:0] gpio_out_o,
  output logic [31:0] gpio_dir_o,
 
  // EXPORTED Data OBI Interface (To Testbench Memory/Scoreboard)
  output logic        data_req_o,
  input  logic        data_gnt_i,
  input  logic        data_rvalid_i,
  output logic [31:0] data_addr_o,
  output logic        data_we_o,
  output logic [3:0]  data_be_o,
  output logic [31:0] data_wdata_o,
  input  logic [31:0] data_rdata_i,
  input  logic        data_err_i,

  // JTAG DTM (riscv-dbg)
  input  logic        jtag_tck_i,
  input  logic        jtag_tms_i,
  input  logic        jtag_trst_ni,
  input  logic        jtag_tdi_i,
  output logic        jtag_tdo_o
);
 
  localparam logic [31:0] BOOT_ADDR          = 32'h0000_0000;
  localparam logic [31:0] HART_ID            = 32'h0000_0000;
  localparam int unsigned DSRAM_SIZE_WORDS   = 1024;        // 4 KB (DIFT tag RAM size)
  localparam int unsigned ISRAM_SIZE_WORDS   = 2048;        // 8 KB
  localparam logic [31:0] ISRAM_MASK         = ~(32'(ISRAM_SIZE_WORDS) * 4 - 1);
 
  // Core Instruction OBI (now internal-only -- routes through soc_addr_decode)
  logic        instr_req_int, instr_gnt_int, instr_rvalid_int, instr_err_int;
  logic [31:0] instr_addr_int, instr_rdata_int;
 
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
  logic        apb_req, apb_gnt, apb_rvalid, apb_we, apb_err;
  logic [3:0]  apb_be;
  logic [31:0] apb_addr, apb_wdata, apb_rdata;
 
  logic        ctrl_req, ctrl_gnt, ctrl_rvalid, ctrl_we, ctrl_err;
  logic [3:0]  ctrl_be;
  logic [31:0] ctrl_addr, ctrl_wdata, ctrl_rdata;
  logic irq_dift, irq_uart;

  // Interrupts: peripherals -> PLIC -> irq_external; CLINT -> timer/software
  logic irq_spi2, irq_qspi, irq_gpio, irq_timer_periph;
  logic irq_external, irq_mtimer, irq_msoft;

  // ---------------------------------------------------------------------------
  // RISC-V Debug (riscv-dbg): reset split + slave-port signals
  // ---------------------------------------------------------------------------
  // ndmreset resets core/peripherals/DIFT but NOT the debug module itself,
  // so a debugger-triggered reset never kills its own JTAG/DMI connection.
  logic ndmreset;
  logic sys_rst_n;
  assign sys_rst_n = rst_ni & ~ndmreset;

  logic        dbg_req, dbg_we, dbg_gnt, dbg_rvalid;
  logic [31:0] dbg_addr, dbg_wdata, dbg_rdata;
  logic [3:0]  dbg_be;
  logic        dbg_req_core, dmactive;

  // Core debug-mode status (ibex_top.debug_mode_o). Drives the decoder's
  // debug access policy and tags debugger stores into DSRAM as untrusted.
  logic        core_debug_mode;

  // JTAG recovery boot
  logic        recovery, recovery_halt_req, recovery_by_wdt;

  // Must match soc_addr_decode's DBG_BASE param exactly
  localparam logic [31:0] DBG_BASE_ADDR = 32'h1A11_0000;

  // dataaccess=1: abstract data register is memory-mapped at
  // DmBaseAddress + dm::DataAddr (0x1A110380), reached over the data OBI
  // channel -- routed to SEL_DBG in soc_addr_decode.
  localparam dm::hartinfo_t DBG_HARTINFO = '{
    zero1      : '0,
    nscratch   : 4'd2,
    zero0      : '0,
    dataaccess : 1'b1,
    datasize   : dm::DataCount,
    dataaddr   : dm::DataAddr
  };
  dm::hartinfo_t [0:0] hartinfo_arr;
  assign hartinfo_arr[0] = DBG_HARTINFO;

  dm::dmi_req_t  dmi_req;
  dm::dmi_resp_t dmi_resp;
  logic dmi_req_valid, dmi_req_ready, dmi_resp_valid, dmi_resp_ready, dmi_rst_n;
 
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
    .rst_ni               ( sys_rst_n ),
    .test_en_i            ( 1'b0 ),
    .ram_cfg_icache_tag_i ( '0 ),
    .ram_cfg_icache_data_i( '0 ),
    .ram_cfg_rsp_icache_tag_o(),
    .ram_cfg_rsp_icache_data_o(),
    .hart_id_i            ( HART_ID ),
    .boot_addr_i          ( BOOT_ADDR ),
 
    .instr_req_o          ( instr_req_int ),
    .instr_gnt_i          ( instr_gnt_int ),
    .instr_rvalid_i       ( instr_rvalid_int ),
    .instr_addr_o         ( instr_addr_int ),
    .instr_rdata_i        ( instr_rdata_int ),
    .instr_rdata_intg_i   ( 7'h0 ),          // integrity checking disabled (SecureIbex=0)
    .instr_err_i          ( instr_err_int ),
 
    .data_req_o           ( core_data_req ),
    .data_gnt_i            ( core_data_gnt ),
    .data_rvalid_i        ( core_data_rvalid ),
    .data_we_o            ( core_data_we ),
    .data_be_o            ( core_data_be ),
    .data_addr_o          ( core_data_addr ),
    .data_wdata_o         ( core_data_wdata ),
    .data_wdata_intg_o    ( core_data_wdata_intg ),
    .data_rdata_i         ( core_data_rdata ),
    .data_rdata_intg_i    ( '0 ),
    .data_err_i           ( core_data_err ),
 
    .irq_software_i       ( irq_msoft ),      // CLINT msip
    .irq_timer_i          ( irq_mtimer ),     // CLINT mtimecmp
    .irq_external_i       ( irq_external ),   // PLIC target 0
    .irq_fast_i           ( 15'h0 ),
    .irq_nm_i             ( irq_dift ),
 
    .scramble_key_valid_i ( 1'b0 ),
    .scramble_key_i       ( '0 ),
    .scramble_nonce_i     ( '0 ),
    .scramble_req_o       ( ),
 
    .debug_req_i          ( dbg_req_core | recovery_halt_req ),
    .debug_mode_o         ( core_debug_mode ),
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
    .rst_ni             ( sys_rst_n ),
 
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
 
  // Tag RAM indexing: tag_addr is ALREADY a word address (shim drops
  // addr[1:0]), so index with tag_addr[TAG_AW-1:0] = byte addr[TAG_AW+1:2].
  // (Was tag_addr[TAG_AW+1:2] -- a double shift giving one tag per 4 words.)
`ifdef DIFT
  localparam int unsigned TAG_AW = $clog2(DSRAM_SIZE_WORDS);
  // Must match soc_addr_decode's DSRAM_BASE/DSRAM_MASK (4 KB = DSRAM_SIZE_WORDS)
  localparam logic [31:0] DSRAM_BASE_ADDR = 32'h0002_0000;
  logic tag_mem [DSRAM_SIZE_WORDS];
  logic [TAG_AW-1:0] tag_rd_addr_q;
  logic              tag_in_dsram, tag_rd_in_dsram_q;

  // Only DSRAM is tagged. Every other data address (debug module, ISRAM,
  // peripherals) used to alias onto DSRAM tags through addr[11:2]; those
  // accesses now read tag 0 and never write the tag RAM.
  assign tag_in_dsram = (tag_addr[29:TAG_AW] == DSRAM_BASE_ADDR[31:TAG_AW+2]);

  always_ff @(posedge clk_i or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
      tag_rd_addr_q     <= '0;
      tag_rd_in_dsram_q <= 1'b0;
    end else if (tag_req) begin
      tag_rd_addr_q     <= tag_addr[TAG_AW-1:0];
      tag_rd_in_dsram_q <= tag_in_dsram;
    end
  end

  // Reset on power-on reset only: DSRAM contents survive ndmreset, so their
  // tags must too. Stores executed in debug mode (debugger program buffer /
  // memory writes) are always tagged untrusted.
  // Plain `always` (not always_ff) so verification can backdoor-inject taint
  // into tag_mem (verif/debugger/dift_dbg_tb.sv); always_ff forbids any
  // other writer. Synthesizes identically.
  always @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      for (int i = 0; i < DSRAM_SIZE_WORDS; i++) tag_mem[i] <= 1'b0;
    end else if (tag_req && tag_we && tag_in_dsram) begin
      tag_mem[tag_addr[TAG_AW-1:0]] <= tag_wdata | core_debug_mode;
    end
  end
  assign tag_rdata = tag_rd_in_dsram_q ? tag_mem[tag_rd_addr_q] : 1'b0;
`else
  assign tag_rdata = 1'b0;
`endif
 
  // ---------------------------------------------------------------------------
  // Address Decoding: Route Instruction Fetch (BootROM/ISRAM), DIFT-OBI'd
  // Data (DSRAM/CTRL/APB/etc.)
  // ---------------------------------------------------------------------------
  // ---------------------------------------------------------------------------
  // Secure boot: ISRAM verifier port, SHA-window registers, fetch gate
  // ---------------------------------------------------------------------------
  logic        ver_req, ver_gnt, ver_rvalid;
  logic [31:0] ver_addr, ver_rdata;
  logic        sha_req, sha_we, sha_gnt, sha_rvalid, sha_err;
  logic [3:0]  sha_be;
  logic [31:0] sha_addr, sha_wdata, sha_rdata;
  logic        fw_fetch_ok, fw_verified;

  if (SECURE_BOOT) begin : g_secure_boot
    soc_secure_boot #(
      .CRYPTO_CLK_DIV ( CRYPTO_CLK_DIV ),
      .ISRAM_BASE     ( 32'h0001_0000  ),   // must match soc_addr_decode ISRAM_BASE
      .ISRAM_WORDS    ( ISRAM_SIZE_WORDS )  // must match ISRAM_MASK
    ) u_secure_boot (
      .clk_i         ( clk_i           ),
      .rst_ni        ( sys_rst_n       ),
      .req_i         ( sha_req         ),
      .we_i          ( sha_we          ),
      .be_i          ( sha_be          ),
      .addr_i        ( sha_addr        ),
      .wdata_i       ( sha_wdata       ),
      .gnt_o         ( sha_gnt         ),
      .rvalid_o      ( sha_rvalid      ),
      .rdata_o       ( sha_rdata       ),
      .err_o         ( sha_err         ),
      .ver_req_o     ( ver_req         ),
      .ver_addr_o    ( ver_addr        ),
      .ver_gnt_i     ( ver_gnt         ),
      .ver_rvalid_i  ( ver_rvalid      ),
      .ver_rdata_i   ( ver_rdata       ),
      .isram_write_i ( isram_req_o & isram_we_o & isram_gnt_i ),
      .fetch_addr_i  ( instr_addr_int  ),
      .fetch_ok_o    ( fw_fetch_ok     ),
      .verified_o    ( fw_verified     )
    );
  end else begin : g_legacy_verify
    assign ver_req     = 1'b0;
    assign ver_addr    = '0;
    assign sha_gnt     = 1'b0;
    assign sha_rvalid  = 1'b0;
    assign sha_rdata   = '0;
    assign sha_err     = 1'b0;
    assign fw_fetch_ok = crypto_verified_i;
    assign fw_verified = crypto_verified_i;
  end

  // PLIC (OBI -> reg bus) and CLINT slave signals
  logic        plic_req, plic_we, plic_gnt, plic_rvalid, plic_err;
  logic [3:0]  plic_be;
  logic [31:0] plic_addr, plic_wdata, plic_rdata;
  logic        clint_req, clint_we, clint_gnt, clint_rvalid, clint_err;
  logic [3:0]  clint_be;
  logic [31:0] clint_addr, clint_wdata, clint_rdata;

  soc_addr_decode #(
    .ISRAM_MASK          ( ISRAM_MASK  ),
    .SHA_IMPL            ( SECURE_BOOT ),
    .PLIC_IMPL           ( 1'b1        ),
    .CLINT_IMPL          ( 1'b1        )
  ) u_soc_addr_decode (
    .clk_i               ( clk_i ),
    .rst_ni              ( sys_rst_n ),
 
    // Access-control signals
    .boot_done_i         ( boot_done ),
    .fw_verified_i       ( fw_fetch_ok ),
    .dbg_mode_i          ( core_debug_mode ),
    .recovery_i          ( recovery ),
    .ctrl_isram_lock_i   ( isram_lock ),
 
    // Ibex Instruction Fetch Channel -- now LIVE (was tied off pre-restructure)
    .instr_req_i         ( instr_req_int ),
    .instr_gnt_o         ( instr_gnt_int ),
    .instr_rvalid_o      ( instr_rvalid_int ),
    .instr_addr_i        ( instr_addr_int ),
    .instr_rdata_o       ( instr_rdata_int ),
    .instr_err_o         ( instr_err_int ),
 
    // Ibex Data Channel (From DIFT Controller)
    .data_req_i          ( dift_data_req ),
    .data_we_i           ( dift_data_we ),
    .data_be_i           ( dift_data_be ),
    .data_addr_i         ( dift_data_addr ),
    .data_wdata_i        ( dift_data_wdata ),
    .data_gnt_o          ( dift_data_gnt ),
    .data_rvalid_o       ( dift_data_rvalid ),
    .data_rdata_o        ( dift_data_rdata ),
    .data_err_o          ( dift_data_err ),
 
    // DSRAM Channel -> Exported to Testbench Memory
    .dsram_req_o         ( data_req_o ),
    .dsram_we_o          ( data_we_o ),
    .dsram_be_o          ( data_be_o ),
    .dsram_addr_o        ( data_addr_o ),
    .dsram_wdata_o       ( data_wdata_o ),
    .dsram_gnt_i         ( data_gnt_i ),
    .dsram_rvalid_i      ( data_rvalid_i ),
    .dsram_rdata_i       ( data_rdata_i ),
    .dsram_err_i         ( data_err_i ),
 
    // BootROM Channel -> Exported to Testbench Memory (was tied off)
    .bootrom_req_o       ( bootrom_req_o ),
    .bootrom_gnt_i       ( bootrom_gnt_i ),
    .bootrom_rvalid_i    ( bootrom_rvalid_i ),
    .bootrom_addr_o      ( bootrom_addr_o ),
    .bootrom_we_o        ( bootrom_we_o ),
    .bootrom_be_o        ( bootrom_be_o ),
    .bootrom_wdata_o     ( bootrom_wdata_o ),
    .bootrom_rdata_i     ( bootrom_rdata_i ),
    .bootrom_err_i       ( bootrom_err_i ),
 
    // ISRAM Channel -> Exported to Testbench Memory (was tied off)
    .isram_req_o         ( isram_req_o ),
    .isram_gnt_i         ( isram_gnt_i ),
    .isram_rvalid_i      ( isram_rvalid_i ),
    .isram_addr_o        ( isram_addr_o ),
    .isram_we_o          ( isram_we_o ),
    .isram_be_o          ( isram_be_o ),
    .isram_wdata_o       ( isram_wdata_o ),
    .isram_rdata_i       ( isram_rdata_i ),
    .isram_err_i         ( isram_err_i ),
 
    // APB Peripherals (UART + QSPI)
    .apb_req_o           ( apb_req ),
    .apb_we_o            ( apb_we ),
    .apb_be_o            ( apb_be ),
    .apb_addr_o          ( apb_addr ),
    .apb_wdata_o         ( apb_wdata ),
    .apb_gnt_i           ( apb_gnt ),
    .apb_rvalid_i        ( apb_rvalid ),
    .apb_rdata_i         ( apb_rdata ),
    .apb_err_i           ( apb_err ),
 
    // SOC Control Registers
    .ctrl_req_o          ( ctrl_req ),
    .ctrl_we_o           ( ctrl_we ),
    .ctrl_be_o           ( ctrl_be ),
    .ctrl_addr_o         ( ctrl_addr ),
    .ctrl_wdata_o        ( ctrl_wdata ),
    .ctrl_gnt_i          ( ctrl_gnt ),
    .ctrl_rvalid_i       ( ctrl_rvalid ),
    .ctrl_rdata_i        ( ctrl_rdata ),
    .ctrl_err_i          ( ctrl_err ),
 
    // Buffer CSR (on hold this phase -- left tied off)
    .buf_req_o           ( ),
    .buf_gnt_i           ( 1'b0 ),
    .buf_rvalid_i        ( 1'b0 ),
    .buf_addr_o          ( ),
    .buf_we_o            ( ),
    .buf_be_o            ( ),
    .buf_wdata_o         ( ),
    .buf_rdata_i         ( 32'h0 ),
    .buf_err_i           ( 1'b0 ),
 
    // SHA window: soc_secure_boot VERIFY registers (SECURE_BOOT=1)
    .sha_req_o           ( sha_req    ),
    .sha_gnt_i           ( sha_gnt    ),
    .sha_rvalid_i        ( sha_rvalid ),
    .sha_addr_o          ( sha_addr   ),
    .sha_we_o            ( sha_we     ),
    .sha_be_o            ( sha_be     ),
    .sha_wdata_o         ( sha_wdata  ),
    .sha_rdata_i         ( sha_rdata  ),
    .sha_err_i           ( sha_err    ),

    // Secure-boot verifier ISRAM read port
    .ver_req_i           ( ver_req    ),
    .ver_addr_i          ( ver_addr   ),
    .ver_gnt_o           ( ver_gnt    ),
    .ver_rvalid_o        ( ver_rvalid ),
    .ver_rdata_o         ( ver_rdata  ),
 
    // PLIC Interrupt Controller (deferred to next phase -- left tied off)
    .plic_req_o          ( plic_req    ),
    .plic_gnt_i          ( plic_gnt    ),
    .plic_rvalid_i       ( plic_rvalid ),
    .plic_addr_o         ( plic_addr   ),
    .plic_we_o           ( plic_we     ),
    .plic_be_o           ( plic_be     ),
    .plic_wdata_o        ( plic_wdata  ),
    .plic_rdata_i        ( plic_rdata  ),
    .plic_err_i          ( plic_err    ),

    .clint_req_o         ( clint_req    ),
    .clint_gnt_i         ( clint_gnt    ),
    .clint_rvalid_i      ( clint_rvalid ),
    .clint_addr_o        ( clint_addr   ),
    .clint_we_o          ( clint_we     ),
    .clint_be_o          ( clint_be     ),
    .clint_wdata_o       ( clint_wdata  ),
    .clint_rdata_i       ( clint_rdata  ),
    .clint_err_i         ( clint_err    ),
 
    // Debug Subordinate -- wired to dm_obi_top's OBI slave port below
    .dbg_req_o           ( dbg_req    ),
    .dbg_addr_o          ( dbg_addr   ),
    .dbg_we_o            ( dbg_we     ),
    .dbg_be_o            ( dbg_be     ),
    .dbg_wdata_o         ( dbg_wdata  ),
    .dbg_gnt_i           ( dbg_gnt    ),
    .dbg_rvalid_i        ( dbg_rvalid ),
    .dbg_rdata_i         ( dbg_rdata  )
  );

  // ---------------------------------------------------------------------------
  // JTAG recovery boot (strap or boot watchdog -> hold hart halted for the
  // debugger, allow it to load ISRAM; execution still needs fw_verified)
  // ---------------------------------------------------------------------------
  soc_recovery #(
    .BOOT_WDT_CYCLES ( BOOT_WDT_CYCLES )
  ) u_soc_recovery (
    .clk_i             ( clk_i             ),
    .por_rst_ni        ( rst_ni            ),
    .sys_rst_ni        ( sys_rst_n         ),
    .boot_mode_i       ( boot_mode_i       ),
    .boot_done_i       ( boot_done         ),
    .core_debug_mode_i ( core_debug_mode   ),
    .recovery_o        ( recovery          ),
    .halt_req_o        ( recovery_halt_req ),
    .recovery_wdt_o    ( recovery_by_wdt   )
  );

  // ---------------------------------------------------------------------------
  // RISC-V Debug Module (OBI-wrapped) + JTAG DTM
  // ---------------------------------------------------------------------------
  dm_obi_top #(
    .IdWidth       ( 1             ),
    .NrHarts       ( 1             ),
    .BusWidth      ( 32            ),
    .DmBaseAddress ( DBG_BASE_ADDR ),
    .SbaEnable     ( 1'b0          )    // execution-based debug only, no SBA
  ) u_dm_obi_top (
    .clk_i              ( clk_i          ),
    .rst_ni             ( rst_ni         ),   // raw POR reset, NOT sys_rst_n
    .testmode_i         ( 1'b0           ),
    .ndmreset_o         ( ndmreset       ),
    .dmactive_o         ( dmactive       ),
    .debug_req_o        ( dbg_req_core   ),
    .unavailable_i      ( 1'b0           ),
    .hartinfo_i         ( hartinfo_arr   ),

    .slave_req_i        ( dbg_req        ),
    .slave_gnt_o        ( dbg_gnt        ),
    .slave_we_i         ( dbg_we         ),
    .slave_addr_i       ( dbg_addr       ),
    .slave_be_i         ( dbg_be         ),
    .slave_wdata_i      ( dbg_wdata      ),
    .slave_aid_i        ( 1'b0           ),
    .slave_rvalid_o     ( dbg_rvalid     ),
    .slave_rdata_o      ( dbg_rdata      ),
    .slave_rid_o        (                ),

    // No System Bus Access: SbaEnable=0 makes the DM report no SBA support
    // (sbcs.sbasize=0) and ignore SBA triggers, so debuggers only use
    // abstract commands + program buffer executed by the core, i.e. every
    // debugger memory access goes through soc_addr_decode's access policy.
    // The master port is tied off and can never be requested.
    .master_req_o       (                ),
    .master_addr_o      (                ),
    .master_we_o        (                ),
    .master_wdata_o     (                ),
    .master_be_o        (                ),
    .master_gnt_i       ( 1'b0           ),
    .master_rvalid_i    ( 1'b0           ),
    .master_err_i       ( 1'b0           ),
    .master_other_err_i ( 1'b0           ),
    .master_rdata_i     ( '0             ),

    .dmi_rst_ni         ( dmi_rst_n      ),
    .dmi_req_valid_i    ( dmi_req_valid  ),
    .dmi_req_ready_o    ( dmi_req_ready  ),
    .dmi_req_i          ( dmi_req        ),
    .dmi_resp_valid_o   ( dmi_resp_valid ),
    .dmi_resp_ready_i   ( dmi_resp_ready ),
    .dmi_resp_o         ( dmi_resp       )
  );

  dmi_jtag #(
    .IdcodeValue ( 32'h0000_0DB3 )   // placeholder -- swap for a project-specific IDCODE if you have one
  ) u_dmi_jtag (
    .clk_i             ( clk_i         ),
    .rst_ni            ( rst_ni        ),   // raw POR reset, NOT sys_rst_n
    .testmode_i        ( 1'b0          ),
    .dmi_rst_no        ( dmi_rst_n     ),
    .dmi_req_o         ( dmi_req       ),
    .dmi_req_valid_o   ( dmi_req_valid ),
    .dmi_req_ready_i   ( dmi_req_ready ),
    .dmi_resp_i        ( dmi_resp      ),
    .dmi_resp_ready_o  ( dmi_resp_ready),
    .dmi_resp_valid_i  ( dmi_resp_valid),
    .tck_i             ( jtag_tck_i    ),
    .tms_i             ( jtag_tms_i    ),
    .trst_ni           ( jtag_trst_ni  ),
    .td_i              ( jtag_tdi_i    ),
    .td_o              ( jtag_tdo_o    ),
    .tdo_oe_o          (               )   // no tri-state pad model needed in sim
  );
 
  // ---------------------------------------------------------------------------
  // SOC Control Registers
  // ---------------------------------------------------------------------------
  soc_ctrl_regs u_soc_ctrl_regs (
    .clk_i               ( clk_i ),
    .rst_ni              ( sys_rst_n ),
    .req_i               ( ctrl_req ),
    .we_i                ( ctrl_we ),
    .be_i                ( ctrl_be ),
    .addr_i              ( ctrl_addr ),
    .wdata_i             ( ctrl_wdata ),
    .gnt_o               ( ctrl_gnt ),
    .rvalid_o            ( ctrl_rvalid ),
    .rdata_o             ( ctrl_rdata ),
    .err_o               ( ctrl_err ),
    .crypto_verified_i   ( fw_verified ),
    .recovery_i          ( recovery ),
    .recovery_wdt_i      ( recovery_by_wdt ),
    .boot_done_o         ( boot_done ),
    .isram_lock_o        ( isram_lock )
  );
 
  // ---------------------------------------------------------------------------
  // OBI to APB Bridge + APB peripherals (UART, QSPI, SPI, timer, GPIO)
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
    .rst_ni     ( sys_rst_n ),
    .obi_req_i  ( apb_obi_req ),
    .obi_rsp_o  ( apb_obi_rsp ),
    .apb_req_o  ( apb_req_struct ),
    .apb_rsp_i  ( apb_rsp_struct )
  );
 
  // ---------------------------------------------------------------------------
  // APB peripheral map (matches software/soc.h). Each slave gets PSEL only
  // inside its 4 KB window; responses are muxed (never multi-driven).
  // An APB address outside every window gets PSLVERR (bus error).
  // ---------------------------------------------------------------------------
  localparam logic [31:0] APB_QSPI_BASE  = 32'h1050_0000;
  localparam logic [31:0] APB_TIMER_BASE = 32'h1050_1000;
  localparam logic [31:0] APB_SPI_BASE   = 32'h1050_2000;
  localparam logic [31:0] APB_UART_BASE  = 32'h1050_3000;
  localparam logic [31:0] APB_GPIO_BASE  = 32'h1060_0000;

  logic psel_qspi, psel_timer, psel_spi2, psel_uart, psel_gpio;
  assign psel_qspi  = apb_req_struct.psel && (apb_req_struct.paddr[31:12] == APB_QSPI_BASE[31:12]);
  assign psel_timer = apb_req_struct.psel && (apb_req_struct.paddr[31:12] == APB_TIMER_BASE[31:12]);
  assign psel_spi2  = apb_req_struct.psel && (apb_req_struct.paddr[31:12] == APB_SPI_BASE[31:12]);
  assign psel_uart  = apb_req_struct.psel && (apb_req_struct.paddr[31:12] == APB_UART_BASE[31:12]);
  assign psel_gpio  = apb_req_struct.psel && (apb_req_struct.paddr[31:12] == APB_GPIO_BASE[31:12]);

  logic [31:0] uart_prdata,  qspi_prdata,  spi2_prdata,  timer_prdata,  gpio_prdata;
  logic        uart_pready,  qspi_pready,  spi2_pready,  timer_pready,  gpio_pready;
  logic        uart_pslverr, qspi_pslverr, spi2_pslverr, timer_pslverr, gpio_pslverr;

  always_comb begin
    apb_rsp_struct.prdata  = 32'h0;
    apb_rsp_struct.pready  = 1'b1;
    apb_rsp_struct.pslverr = 1'b1;                  // unmapped APB address
    unique case (1'b1)
      psel_uart:  begin apb_rsp_struct.prdata = uart_prdata;  apb_rsp_struct.pready = uart_pready;  apb_rsp_struct.pslverr = uart_pslverr;  end
      psel_qspi:  begin apb_rsp_struct.prdata = qspi_prdata;  apb_rsp_struct.pready = qspi_pready;  apb_rsp_struct.pslverr = qspi_pslverr;  end
      psel_spi2:  begin apb_rsp_struct.prdata = spi2_prdata;  apb_rsp_struct.pready = spi2_pready;  apb_rsp_struct.pslverr = spi2_pslverr;  end
      psel_timer: begin apb_rsp_struct.prdata = timer_prdata; apb_rsp_struct.pready = timer_pready; apb_rsp_struct.pslverr = timer_pslverr; end
      psel_gpio:  begin apb_rsp_struct.prdata = gpio_prdata;  apb_rsp_struct.pready = gpio_pready;  apb_rsp_struct.pslverr = gpio_pslverr;  end
      default: ;
    endcase
    // PREADY only has meaning in the ACCESS phase. The PULP slaves tie it to
    // 1, and obi_to_apb (EnableSameCycleRsp=0) tracks the transfer as
    // "psel & ~pready" -- a ready seen in SETUP ends the transfer before
    // ACCESS, so rvalid never comes and the core stalls. Gate with PENABLE.
    apb_rsp_struct.pready &= apb_req_struct.penable;
  end

  // UART (16550-style). apb_uart_sv decodes its register index from
  // PADDR[2:0] (byte-spaced), but Ibex only issues word-aligned addresses,
  // so the index is taken from paddr[4:2]: register n lives at +4*n,
  // matching software/soc.h (THR +0x00, LCR +0x0C, LSR +0x14).
  apb_uart_sv #(
    .APB_ADDR_WIDTH ( 12 )
  ) u_apb_uart (
    .CLK            ( clk_i ),
    .RSTN           ( sys_rst_n ),
    .PADDR          ( {2'b00, apb_req_struct.paddr[11:2]} ),
    .PWDATA         ( apb_req_struct.pwdata ),
    .PWRITE         ( apb_req_struct.pwrite ),
    .PSEL           ( psel_uart ),
    .PENABLE        ( apb_req_struct.penable ),
    .PRDATA         ( uart_prdata ),
    .PREADY         ( uart_pready ),
    .PSLVERR        ( uart_pslverr ),
    .rx_i           ( uart_rx_i ),
    .tx_o           ( uart_tx_o ),
    .event_o        ( irq_uart )
  );

  // QSPI flash controller
  logic [1:0] qspi_events;
  assign irq_qspi = qspi_events[0];

  apb_spi_master u_apb_qspi (
    .HCLK     ( clk_i ),
    .HRESETn  ( sys_rst_n ),
    .PADDR    ( apb_req_struct.paddr[11:0] ),
    .PWDATA   ( apb_req_struct.pwdata ),
    .PWRITE   ( apb_req_struct.pwrite ),
    .PSEL     ( psel_qspi ),
    .PENABLE  ( apb_req_struct.penable ),
    .PRDATA   ( qspi_prdata ),
    .PREADY   ( qspi_pready ),
    .PSLVERR  ( qspi_pslverr ),
    .events_o ( qspi_events ),
    .spi_clk  ( spi_clk_o ),
    .spi_csn0 ( spi_csn_o[0] ),
    .spi_csn1 ( spi_csn_o[1] ),
    .spi_csn2 ( spi_csn_o[2] ),
    .spi_csn3 ( spi_csn_o[3] ),
    .spi_mode ( spi_mode_o ),
    .spi_sdo0 ( spi_sdo_o[0] ),
    .spi_sdo1 ( spi_sdo_o[1] ),
    .spi_sdo2 ( spi_sdo_o[2] ),
    .spi_sdo3 ( spi_sdo_o[3] ),
    .spi_sdi0 ( spi_sdi_i[0] ),
    .spi_sdi1 ( spi_sdi_i[1] ),
    .spi_sdi2 ( spi_sdi_i[2] ),
    .spi_sdi3 ( spi_sdi_i[3] )
  );

  // General-purpose SPI master (single lane). In standard mode
  // apb_spi_master transmits on sdo0 and RECEIVES on sdi1 (QSPI IO0/IO1).
  logic [1:0] spi2_events;
  assign irq_spi2 = spi2_events[0];

  apb_spi_master u_apb_spi (
    .HCLK     ( clk_i ),
    .HRESETn  ( sys_rst_n ),
    .PADDR    ( apb_req_struct.paddr[11:0] ),
    .PWDATA   ( apb_req_struct.pwdata ),
    .PWRITE   ( apb_req_struct.pwrite ),
    .PSEL     ( psel_spi2 ),
    .PENABLE  ( apb_req_struct.penable ),
    .PRDATA   ( spi2_prdata ),
    .PREADY   ( spi2_pready ),
    .PSLVERR  ( spi2_pslverr ),
    .events_o ( spi2_events ),
    .spi_clk  ( spi2_clk_o ),
    .spi_csn0 ( spi2_csn_o[0] ),
    .spi_csn1 ( spi2_csn_o[1] ),
    .spi_csn2 ( spi2_csn_o[2] ),
    .spi_csn3 ( spi2_csn_o[3] ),
    .spi_mode ( ),
    .spi_sdo0 ( spi2_sdo_o ),
    .spi_sdo1 ( ),
    .spi_sdo2 ( ),
    .spi_sdo3 ( ),
    .spi_sdi0 ( 1'b0 ),
    .spi_sdi1 ( spi2_sdi_i ),       // standard-mode RX samples sdi1 (MISO = IO1)
    .spi_sdi2 ( 1'b0 ),
    .spi_sdi3 ( 1'b0 )
  );

  // Timer (PULP apb_timer, 2 timers: overflow + compare irq each)
  logic [3:0] timer_irqs;
  assign irq_timer_periph = |timer_irqs;

  apb_timer #(
    .APB_ADDR_WIDTH ( 12 ),
    .TIMER_CNT      ( 2  )
  ) u_apb_timer (
    .HCLK     ( clk_i ),
    .HRESETn  ( sys_rst_n ),
    .PADDR    ( apb_req_struct.paddr[11:0] ),
    .PWDATA   ( apb_req_struct.pwdata ),
    .PWRITE   ( apb_req_struct.pwrite ),
    .PSEL     ( psel_timer ),
    .PENABLE  ( apb_req_struct.penable ),
    .PRDATA   ( timer_prdata ),
    .PREADY   ( timer_pready ),
    .PSLVERR  ( timer_pslverr ),
    .irq_o    ( timer_irqs )
  );

  // GPIO (PULP apb_gpio)
  if (HAS_GPIO) begin : g_gpio
    apb_gpio #(
      .APB_ADDR_WIDTH ( 12 ),
      .PAD_NUM        ( 32 )
    ) u_apb_gpio (
      .HCLK            ( clk_i ),
      .HRESETn         ( sys_rst_n ),
      .dft_cg_enable_i ( 1'b0 ),
      .PADDR           ( apb_req_struct.paddr[11:0] ),
      .PWDATA          ( apb_req_struct.pwdata ),
      .PWRITE          ( apb_req_struct.pwrite ),
      .PSEL            ( psel_gpio ),
      .PENABLE         ( apb_req_struct.penable ),
      .PRDATA          ( gpio_prdata ),
      .PREADY          ( gpio_pready ),
      .PSLVERR         ( gpio_pslverr ),
      .gpio_in         ( gpio_in_i ),
      .gpio_in_sync    ( ),
      .gpio_out        ( gpio_out_o ),
      .gpio_dir        ( gpio_dir_o ),
      .gpio_padcfg     ( ),
      .interrupt       ( irq_gpio )
    );
  end else begin : g_no_gpio
    assign gpio_prdata  = 32'h0;
    assign gpio_pready  = 1'b1;
    assign gpio_pslverr = 1'b1;
    assign gpio_out_o   = '0;
    assign gpio_dir_o   = '0;
    assign irq_gpio     = 1'b0;
    logic unused_gpio_in;
    assign unused_gpio_in = ^gpio_in_i;
  end

  // ---------------------------------------------------------------------------
  // PLIC (0x0C00_0000): OBI -> reg-bus adapter, same as the verified
  // verif/tb/ibex_plic_soc_tb.sv. The regmap is combinational on the request
  // cycle, so read data / error are captured there and returned with rvalid.
  // Source IDs match software/soc.h (IRQ_UART=1 ... IRQ_DIFT=8).
  // ---------------------------------------------------------------------------
  typedef struct packed {
    logic        valid;
    logic        write;
    logic [31:0] addr;
    logic [31:0] wdata;
    logic [ 3:0] wstrb;
  } plic_reg_req_t;

  typedef struct packed {
    logic        ready;
    logic        error;
    logic [31:0] rdata;
  } plic_reg_rsp_t;

  plic_reg_req_t plic_reg_req;
  plic_reg_rsp_t plic_reg_rsp;

  assign plic_gnt           = plic_req;
  assign plic_reg_req.valid = plic_req;
  assign plic_reg_req.write = plic_we;
  assign plic_reg_req.addr  = plic_addr;
  assign plic_reg_req.wdata = plic_wdata;
  assign plic_reg_req.wstrb = plic_be;

  always_ff @(posedge clk_i or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
      plic_rvalid <= 1'b0;
      plic_rdata  <= '0;
      plic_err    <= 1'b0;
    end else begin
      plic_rvalid <= plic_req & plic_gnt;
      if (plic_req & plic_gnt) begin
        plic_rdata <= plic_reg_rsp.rdata;
        plic_err   <= plic_reg_rsp.error;
      end
    end
  end

  logic [0:0] plic_eip;
  assign irq_external = plic_eip[0];

  plic_top #(
    .N_SOURCE  ( 12             ),
    .N_TARGET  ( 1              ),
    .MAX_PRIO  ( 3              ),
    .reg_req_t ( plic_reg_req_t ),
    .reg_rsp_t ( plic_reg_rsp_t )
  ) u_plic (
    .clk_i         ( clk_i        ),
    .rst_ni        ( sys_rst_n    ),
    .req_i         ( plic_reg_req ),
    .resp_o        ( plic_reg_rsp ),
    .le_i          ( 12'h0        ),   // all level-triggered
    //                  12..9  8         7 (SHA)  6 (BUF)  5                 4         3         2         1
    .irq_sources_i ( {4'h0, irq_dift, 1'b0,    1'b0,    irq_timer_periph, irq_gpio, irq_qspi, irq_spi2, irq_uart} ),
    .eip_targets_o ( plic_eip     )
  );

  // ---------------------------------------------------------------------------
  // CLINT (0x0200_0000): mtime / mtimecmp -> irq_timer, msip -> irq_software
  // ---------------------------------------------------------------------------
  clint_obi u_clint (
    .clk_i    ( clk_i        ),
    .rst_ni   ( sys_rst_n    ),
    .req_i    ( clint_req    ),
    .gnt_o    ( clint_gnt    ),
    .rvalid_o ( clint_rvalid ),
    .addr_i   ( clint_addr   ),
    .we_i     ( clint_we     ),
    .be_i     ( clint_be     ),
    .wdata_i  ( clint_wdata  ),
    .rdata_o  ( clint_rdata  ),
    .err_o    ( clint_err    ),
    .msip_o   ( irq_msoft    ),
    .mtip_o   ( irq_mtimer   )
  );

endmodule
 
