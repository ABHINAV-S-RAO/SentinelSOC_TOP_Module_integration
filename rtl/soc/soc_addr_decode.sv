// Copyright 2025
// SoC Address Decoder
// Wraps obi_demux for data path (8 slaves) and fetch path (2 slaves: BootROM, ISRAM)
// Uses ObiDefaultConfig: 32-bit addr/data, 1-bit ID, no integrity, no optional fields
//
// =============================================================================
// ACCESS-CONTROL MODEL (Req 1-4)
// =============================================================================
// Privileged CSR ranges: Control Registers (CTRL), Buffer CSR (BUF),
// SHA/ED25519 CSR (SHA). These hold verification-critical state and must
// not be reachable by firmware once the boot phase is over.
//
//   Phase                          | CSR writes | CSR reads | ISRAM writes         | ISRAM fetch
//   -----------------------------------------------------------------------------------------------
//   Boot phase (boot_done_i=0)     | allowed    | allowed   | allowed (unless dbg)  | n/a (BootROM)
//   Post-boot, normal execution    | BLOCKED    | BLOCKED   | BLOCKED (lock is set) | BLOCKED until fw_verified_i
//   Any time, dbg_mode_i=1         | BLOCKED    | allowed   | BLOCKED (unconditional)| (fetch gate independent of dbg)
//
// ISRAM writes are blocked by dbg_mode_i UNCONDITIONALLY (not just
// post-boot) — a halted-core debug session must never be able to inject
// or modify firmware in ISRAM, even during the boot window before the
// bootloader's own write-lock is set.
//
// Denied CSR accesses are redirected to SEL_ERR (reuses the existing
// unmapped-address error responder — DEAD_BEEF + err=1). This keeps the
// gating logic in one place (see priv_hit / priv_denied below) instead of
// duplicating checks in every per-slave always_comb block.
//
// To add another privileged block in future (e.g. a second crypto CSR
// range), add a BASE/MASK parameter pair and OR its hit condition into
// priv_hit — no other change needed.
//
// NOTE ISRAM_write lock (ctrl_isram_lock_i) is a SEPARATE, orthogonal
// mechanism: it gates *firmware writes into ISRAM* (bootloader sets it
// once done copying firmware in). It is unrelated to the CSR privilege
// gating above.
// =============================================================================

`include "obi/typedef.svh"
`include "obi/assign.svh"

module soc_addr_decode #(
  // Memory map parameters — override at SoC top level if needed
  parameter logic [31:0] BOOTROM_BASE  = 32'h0000_0000,
  parameter logic [31:0] BOOTROM_MASK  = 32'hFFFF_F000, // 4KB
  parameter logic [31:0] ISRAM_BASE    = 32'h0001_0000,
  parameter logic [31:0] ISRAM_MASK    = 32'hFFFF_F000, // 4KB
  parameter logic [31:0] DSRAM_BASE    = 32'h0002_0000,
  parameter logic [31:0] DSRAM_MASK    = 32'hFFFF_F000, // 4KB
  parameter logic [31:0] CTRL_BASE     = 32'h0003_0000,
  parameter logic [31:0] CTRL_MASK     = 32'hFFFF_F000, // 4KB
  parameter logic [31:0] BUF_BASE      = 32'h0004_0000,
  parameter logic [31:0] BUF_MASK      = 32'hFFFF_F000, // 4KB
  parameter logic [31:0] SHA_BASE      = 32'h0005_0000,
  parameter logic [31:0] SHA_MASK      = 32'hFFFF_F000, // 4KB
  parameter logic [31:0] PLIC_BASE = 32'h0C00_0000,
  parameter logic [31:0] PLIC_MASK = 32'hFFC0_0000, // 4MB 	

  // ---------------------------------------------------------------------
  // PLACEHOLDER — reserve address space for future privileged blocks.
  // Uncomment, add to priv_hit below, and wire into a new SEL_/port pair
  // when a second crypto CSR block (or similar) is added.
  // ---------------------------------------------------------------------
  // parameter logic [31:0] CRYPTO2_BASE = 32'h0006_0000,
  // parameter logic [31:0] CRYPTO2_MASK = 32'hFFFF_F000, // 4KB

  parameter logic [31:0] DBG_BASE      = 32'h1A11_0000,
  parameter logic [31:0] DBG_MASK      = 32'hFFFF_0000,
  parameter logic [31:0] APB_BASE      = 32'h1000_0000,
  parameter logic [31:0] APB_MASK      = 32'hF000_0000, // 256MB

  // Max outstanding transactions through the demux
  parameter int unsigned NumMaxTrans   = 2
) (
  input  logic clk_i,
  input  logic rst_ni,

  //--------------------------------------------------------------------
  // Ibex instruction fetch interface (flat, matches ibex_top ports)
  //--------------------------------------------------------------------
  input  logic        instr_req_i,
  output logic        instr_gnt_o,
  output logic        instr_rvalid_o,
  input  logic [31:0] instr_addr_i,
  output logic [31:0] instr_rdata_o,
  output logic        instr_err_o,

  //--------------------------------------------------------------------
  // Ibex data interface (flat, matches ibex_top ports)
  //--------------------------------------------------------------------
  input  logic        data_req_i,
  output logic        data_gnt_o,
  output logic        data_rvalid_o,
  input  logic        data_we_i,
  input  logic [ 3:0] data_be_i,
  input  logic [31:0] data_addr_i,
  input  logic [31:0] data_wdata_i,
  output logic [31:0] data_rdata_o,
  output logic        data_err_o,

  //--------------------------------------------------------------------
  // BootROM — OBI subordinate (read-only, shared by fetch + data)
  //--------------------------------------------------------------------
  output logic        bootrom_req_o,
  input  logic        bootrom_gnt_i,
  input  logic        bootrom_rvalid_i,
  output logic [31:0] bootrom_addr_o,
  output logic        bootrom_we_o,
  output logic [ 3:0] bootrom_be_o,
  output logic [31:0] bootrom_wdata_o,
  input  logic [31:0] bootrom_rdata_i,
  input  logic        bootrom_err_i,

  //--------------------------------------------------------------------
  // ISRAM — OBI subordinate (dual path: fetch read + data write/read)
  // Write port gated by ctrl_isram_lock_i (orthogonal to priv gating)
  // Fetch port gated by fw_verified_i (Req 4)
  //--------------------------------------------------------------------
  output logic        isram_req_o,
  input  logic        isram_gnt_i,
  input  logic        isram_rvalid_i,
  output logic [31:0] isram_addr_o,
  output logic        isram_we_o,
  output logic [ 3:0] isram_be_o,
  output logic [31:0] isram_wdata_o,
  input  logic [31:0] isram_rdata_i,
  input  logic        isram_err_i,

  // ISRAM write lock from Control Registers block
  input  logic        ctrl_isram_lock_i,

  //--------------------------------------------------------------------
  // Access-control inputs (Req 1-4)
  //--------------------------------------------------------------------
  // Set once bootloader has finished and written BOOT_STATUS.boot_done
  // in soc_ctrl_regs. Before this: full CSR RW access (boot phase).
  input  logic        boot_done_i,

  // Direct wire from Ibex core debug_mode (core halted under active debug
  // session). TODO: ibex_top does not currently expose this as a port —
  // add `output logic debug_mode_o` to ibex_top, wired from
  // u_ibex_core's internal debug_mode_q (in cs_registers), and connect
  // here. Until that exists, tie to 1'b0 (fail-closed: no post-boot CSR
  // reads at all) rather than 1'b1.
  input  logic        dbg_mode_i,

  // Firmware signature-verified status — direct wire from SHA+ED25519
  // (same source soc_ctrl_regs.crypto_verified_i uses). Gates instruction
  // fetch from ISRAM (Req 4).
  input  logic        fw_verified_i,

  //--------------------------------------------------------------------
  // DSRAM — OBI subordinate
  //--------------------------------------------------------------------
  output logic        dsram_req_o,
  input  logic        dsram_gnt_i,
  input  logic        dsram_rvalid_i,
  output logic [31:0] dsram_addr_o,
  output logic        dsram_we_o,
  output logic [ 3:0] dsram_be_o,
  output logic [31:0] dsram_wdata_o,
  input  logic [31:0] dsram_rdata_i,
  input  logic        dsram_err_i,

  //--------------------------------------------------------------------
  // Control Registers — OBI subordinate (PRIVILEGED — see gating above)
  //--------------------------------------------------------------------
  output logic        ctrl_req_o,
  input  logic        ctrl_gnt_i,
  input  logic        ctrl_rvalid_i,
  output logic [31:0] ctrl_addr_o,
  output logic        ctrl_we_o,
  output logic [ 3:0] ctrl_be_o,
  output logic [31:0] ctrl_wdata_o,
  input  logic [31:0] ctrl_rdata_i,
  input  logic        ctrl_err_i,

  //--------------------------------------------------------------------
  // Buffer CSR — OBI subordinate (PRIVILEGED — see gating above)
  //--------------------------------------------------------------------
  output logic        buf_req_o,
  input  logic        buf_gnt_i,
  input  logic        buf_rvalid_i,
  output logic [31:0] buf_addr_o,
  output logic        buf_we_o,
  output logic [ 3:0] buf_be_o,
  output logic [31:0] buf_wdata_o,
  input  logic [31:0] buf_rdata_i,
  input  logic        buf_err_i,

  //--------------------------------------------------------------------
  // SHA + ED25519 CSR — OBI subordinate (PRIVILEGED — see gating above)
  //--------------------------------------------------------------------
  output logic        sha_req_o,
  input  logic        sha_gnt_i,
  input  logic        sha_rvalid_i,
  output logic [31:0] sha_addr_o,
  output logic        sha_we_o,
  output logic [ 3:0] sha_be_o,
  output logic [31:0] sha_wdata_o,
  input  logic [31:0] sha_rdata_i,
  input  logic        sha_err_i,
  
  //interrupt plic 
  output logic        plic_req_o,
  input  logic        plic_gnt_i,
  input  logic        plic_rvalid_i,
  output logic [31:0] plic_addr_o,
  output logic        plic_we_o,
  output logic [ 3:0] plic_be_o,
  output logic [31:0] plic_wdata_o,
  input  logic [31:0] plic_rdata_i,
  input  logic        plic_err_i,

  //--------------------------------------------------------------------
  // OBI-to-APB Bridge — OBI subordinate
  //--------------------------------------------------------------------
  output logic        apb_req_o,
  input  logic        apb_gnt_i,
  input  logic        apb_rvalid_i,
  output logic [31:0] apb_addr_o,
  output logic        apb_we_o,
  output logic [ 3:0] apb_be_o,
  output logic [31:0] apb_wdata_o,
  input  logic [31:0] apb_rdata_i,
  input  logic        apb_err_i,

  // Debug Target Interface (dm_top slave port — separate JTAG-side access,
  // NOT gated by the priv model above; out of scope for this pass)
  output logic        dbg_req_o,
  output logic [31:0] dbg_addr_o,
  output logic        dbg_we_o,
  output logic [ 3:0] dbg_be_o,
  output logic [31:0] dbg_wdata_o,
  input  logic        dbg_rvalid_i,
  input  logic [31:0] dbg_rdata_i
);

  // --------------------------------------------------------------------------
  // OBI type definitions — using ObiDefaultConfig (32b addr/data, 1b ID,
  // no integrity, no optional fields)
  // --------------------------------------------------------------------------
  localparam obi_pkg::obi_cfg_t SocObiCfg = obi_pkg::ObiDefaultConfig;

  `OBI_TYPEDEF_DEFAULT_ALL(soc_obi, SocObiCfg)

  // --------------------------------------------------------------------------
  // Slave index encoding for data demux (8 slaves)
  // --------------------------------------------------------------------------
  typedef enum logic [3:0] {
    SEL_BOOTROM = 4'd0,
    SEL_ISRAM   = 4'd1,
    SEL_DSRAM   = 4'd2,
    SEL_CTRL    = 4'd3,
    SEL_BUF     = 4'd4,
    SEL_SHA     = 4'd5,
    SEL_PLIC	= 4'd6,
    SEL_APB     = 4'd7,
    SEL_DBG     = 4'd8,
    SEL_ERR     = 4'd9
    // If a new privileged slave is added (e.g. SEL_CRYPTO2), widen this
    // enum, bump DataNumMgrPorts below, and add a new manager-port slot.
  } data_sel_e;

  // --------------------------------------------------------------------------
  // Slave index encoding for fetch demux (2 slaves)
  // --------------------------------------------------------------------------
  typedef enum logic [0:0] {
    FSEL_BOOTROM = 1'd0,
    FSEL_ISRAM   = 1'd1
  } fetch_sel_e;

  // --------------------------------------------------------------------------
  // Pack Ibex flat data signals into OBI request struct
  // --------------------------------------------------------------------------
  soc_obi_req_t data_req_s;
  soc_obi_rsp_t data_rsp_s;

  always_comb begin
    data_req_s        = '0;
    data_req_s.req    = data_req_i;
    data_req_s.a.addr  = data_addr_i;
    data_req_s.a.we    = data_we_i;
    data_req_s.a.be    = data_be_i;
    data_req_s.a.wdata = data_wdata_i;
    data_req_s.a.aid   = '0;
  end

  assign data_gnt_o    = data_rsp_s.gnt;
  assign data_rvalid_o = data_rsp_s.rvalid;
  assign data_rdata_o  = data_rsp_s.r.rdata;
  assign data_err_o    = data_rsp_s.r.err;

  // --------------------------------------------------------------------------
  // Pack Ibex flat instruction signals into OBI request struct
  // --------------------------------------------------------------------------
  soc_obi_req_t fetch_req_s;
  soc_obi_rsp_t fetch_rsp_s;

  always_comb begin
    fetch_req_s        = '0;
    fetch_req_s.req    = instr_req_i;
    fetch_req_s.a.addr  = instr_addr_i;
    fetch_req_s.a.we    = 1'b0;  // fetch is always a read
    fetch_req_s.a.be    = 4'hF;
    fetch_req_s.a.wdata = '0;
    fetch_req_s.a.aid   = '0;
  end

  assign instr_gnt_o    = fetch_rsp_s.gnt;
  assign instr_rvalid_o = fetch_rsp_s.rvalid;
  assign instr_rdata_o  = fetch_rsp_s.r.rdata;
  assign instr_err_o    = fetch_rsp_s.r.err;

  // --------------------------------------------------------------------------
  // Privileged CSR access gating (Req 1-3)
  // --------------------------------------------------------------------------
  logic priv_hit;
  logic priv_write_ok, priv_read_ok, priv_denied;

  always_comb begin
    priv_hit = ((data_addr_i & CTRL_MASK) == CTRL_BASE) ||
               ((data_addr_i & BUF_MASK)  == BUF_BASE)  ||
               ((data_addr_i & SHA_MASK)  == SHA_BASE);
               // OR in additional privileged ranges here, e.g.:
               // || ((data_addr_i & CRYPTO2_MASK) == CRYPTO2_BASE)
  end

  assign priv_write_ok = ~boot_done_i;                 // writes: boot phase only, ever
  assign priv_read_ok  = ~boot_done_i | dbg_mode_i;     // reads: boot phase, or debug-halted
  assign priv_denied   = priv_hit & (data_we_i ? ~priv_write_ok : ~priv_read_ok);

  // --------------------------------------------------------------------------
  // Data path address decode → select signal
  // --------------------------------------------------------------------------
  data_sel_e data_sel;

  always_comb begin
    if      ((data_addr_i & BOOTROM_MASK) == BOOTROM_BASE) data_sel = SEL_BOOTROM;
    else if ((data_addr_i & ISRAM_MASK)   == ISRAM_BASE)   data_sel = SEL_ISRAM;
    else if ((data_addr_i & DSRAM_MASK)   == DSRAM_BASE)   data_sel = SEL_DSRAM;
    else if (priv_denied)                                  data_sel = SEL_ERR; // Req 1-3
    else if ((data_addr_i & CTRL_MASK)    == CTRL_BASE)    data_sel = SEL_CTRL;
    else if ((data_addr_i & BUF_MASK)     == BUF_BASE)     data_sel = SEL_BUF;
    else if ((data_addr_i & SHA_MASK)     == SHA_BASE)     data_sel = SEL_SHA;
    else if ((data_addr_i & PLIC_MASK) == PLIC_BASE) data_sel = SEL_PLIC;
    else if ((data_addr_i & DBG_MASK)     == DBG_BASE)     data_sel = SEL_DBG;
    else if ((data_addr_i & APB_MASK)     == APB_BASE)     data_sel = SEL_APB;
    else                                                    data_sel = SEL_ERR;
  end

  // --------------------------------------------------------------------------
  // Fetch path address decode → select signal
  // --------------------------------------------------------------------------
  fetch_sel_e fetch_sel;

  always_comb begin
    if ((instr_addr_i & ISRAM_MASK) == ISRAM_BASE) fetch_sel = FSEL_ISRAM;
    else                                            fetch_sel = FSEL_BOOTROM;
  end

  // --------------------------------------------------------------------------
  // Data demux — 9 manager ports (8 slaves + 1 error responder)
  // --------------------------------------------------------------------------
  localparam int unsigned DataNumMgrPorts = 10; // SEL_BOOTROM..SEL_ERR = indices 0..8

  soc_obi_req_t [DataNumMgrPorts-1:0] data_mgr_req;
  soc_obi_rsp_t [DataNumMgrPorts-1:0] data_mgr_rsp;

  obi_demux #(
    .ObiCfg      ( SocObiCfg       ),
    .obi_req_t   ( soc_obi_req_t   ),
    .obi_rsp_t   ( soc_obi_rsp_t   ),
    .NumMgrPorts ( DataNumMgrPorts  ),
    .NumMaxTrans ( NumMaxTrans      ),
    .select_t    ( logic [3:0]      )
  ) u_data_demux (
    .clk_i,
    .rst_ni,
    .sbr_port_select_i ( data_sel     ),
    .sbr_port_req_i    ( data_req_s   ),
    .sbr_port_rsp_o    ( data_rsp_s   ),
    .mgr_ports_req_o   ( data_mgr_req ),
    .mgr_ports_rsp_i   ( data_mgr_rsp )
  );

  // --------------------------------------------------------------------------
  // Fetch demux — 2 manager ports (BootROM, ISRAM)
  // --------------------------------------------------------------------------
  localparam int unsigned FetchNumMgrPorts = 2;

  soc_obi_req_t [FetchNumMgrPorts-1:0] fetch_mgr_req;
  soc_obi_rsp_t [FetchNumMgrPorts-1:0] fetch_mgr_rsp;

  obi_demux #(
    .ObiCfg      ( SocObiCfg        ),
    .obi_req_t   ( soc_obi_req_t    ),
    .obi_rsp_t   ( soc_obi_rsp_t    ),
    .NumMgrPorts ( FetchNumMgrPorts  ),
    .NumMaxTrans ( NumMaxTrans       ),
    .select_t    ( logic [0:0]       )
  ) u_fetch_demux (
    .clk_i,
    .rst_ni,
    .sbr_port_select_i ( fetch_sel      ),
    .sbr_port_req_i    ( fetch_req_s    ),
    .sbr_port_rsp_o    ( fetch_rsp_s    ),
    .mgr_ports_req_o   ( fetch_mgr_req  ),
    .mgr_ports_rsp_i   ( fetch_mgr_rsp  )
  );

  // --------------------------------------------------------------------------
  // BootROM — arbiter between fetch demux [FSEL_BOOTROM] and
  //           data demux [SEL_BOOTROM]
  // Simple priority: fetch wins over data (instruction fetch is latency-critical)
  // --------------------------------------------------------------------------
  always_comb begin
    // Default: fetch port drives BootROM
    bootrom_req_o   = fetch_mgr_req[FSEL_BOOTROM].req;
    bootrom_addr_o  = fetch_mgr_req[FSEL_BOOTROM].a.addr;
    bootrom_we_o    = 1'b0; // BootROM is always read-only
    bootrom_be_o    = fetch_mgr_req[FSEL_BOOTROM].a.be;
    bootrom_wdata_o = '0;

    fetch_mgr_rsp[FSEL_BOOTROM].gnt    = bootrom_gnt_i;
    fetch_mgr_rsp[FSEL_BOOTROM].rvalid = bootrom_rvalid_i;
    fetch_mgr_rsp[FSEL_BOOTROM].r      = '0;
    fetch_mgr_rsp[FSEL_BOOTROM].r.rdata = bootrom_rdata_i;
    fetch_mgr_rsp[FSEL_BOOTROM].r.err   = bootrom_err_i;

    // Data port to BootROM: stall (not implemented yet)
    data_mgr_rsp[SEL_BOOTROM].gnt    = 1'b0;
    data_mgr_rsp[SEL_BOOTROM].rvalid = 1'b0;
    data_mgr_rsp[SEL_BOOTROM].r      = '0;
    data_mgr_rsp[SEL_BOOTROM].r.err  = 1'b1; // error: data access to BootROM not supported
  end

  // --------------------------------------------------------------------------
  // ISRAM — arbiter between fetch demux [FSEL_ISRAM] and data demux [SEL_ISRAM]
  // Priority: data wins (writes must not be blocked; fetch stalls are acceptable)
  // Write port gated by ctrl_isram_lock_i
  // Fetch port gated by fw_verified_i (Req 4) — until firmware signature
  // is verified, instruction fetch from ISRAM returns a bus error even
  // though the words are physically present in the array. This is a
  // hardware backstop: even if bootloader software has a bug and jumps
  // to ISRAM early, the core cannot actually execute what's there.
  // --------------------------------------------------------------------------
  logic isram_data_active, isram_fetch_active;
  logic isram_fetch_blocked_q; // registered so blocked-fetch rvalid timing
                                // matches the normal 1-cycle SRAM latency

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) isram_fetch_blocked_q <= 1'b0;
    else         isram_fetch_blocked_q <= isram_fetch_active & ~fw_verified_i;
  end

  always_comb begin
    isram_data_active  = data_mgr_req[SEL_ISRAM].req;
    isram_fetch_active = fetch_mgr_req[FSEL_ISRAM].req & ~isram_data_active;

    // Default outputs
    isram_req_o   = 1'b0;
    isram_addr_o  = '0;
    isram_we_o    = 1'b0;
    isram_be_o    = '0;
    isram_wdata_o = '0;

    // Data response defaults
    data_mgr_rsp[SEL_ISRAM].gnt    = 1'b0;
    data_mgr_rsp[SEL_ISRAM].rvalid = 1'b0;
    data_mgr_rsp[SEL_ISRAM].r      = '0;

    // Fetch response defaults
    fetch_mgr_rsp[FSEL_ISRAM].gnt    = 1'b0;
    fetch_mgr_rsp[FSEL_ISRAM].rvalid = 1'b0;
    fetch_mgr_rsp[FSEL_ISRAM].r      = '0;

    if (isram_data_active) begin
      // Data port drives ISRAM — apply write lock
      isram_req_o   = 1'b1;
      isram_addr_o  = data_mgr_req[SEL_ISRAM].a.addr;
      // Gate write: blocked if (a) bootloader has set the sticky write
      // lock, OR (b) the core is currently halted in debug mode. (b) is
      // unconditional — it applies even during boot phase, before the
      // lock bit is set, so a debugger-driven store (via an abstract
      // command or program-buffer execution on the halted core) can
      // never inject/modify ISRAM contents, ever.
      isram_we_o    = data_mgr_req[SEL_ISRAM].a.we
                       & ~ctrl_isram_lock_i
                       & ~dbg_mode_i;
      isram_be_o    = data_mgr_req[SEL_ISRAM].a.be;
      isram_wdata_o = data_mgr_req[SEL_ISRAM].a.wdata;

      data_mgr_rsp[SEL_ISRAM].gnt              = isram_gnt_i;
      data_mgr_rsp[SEL_ISRAM].rvalid           = isram_rvalid_i;
      data_mgr_rsp[SEL_ISRAM].r.rdata          = isram_rdata_i;
      // If write was attempted while locked or while in debug mode, error
      data_mgr_rsp[SEL_ISRAM].r.err            =
        isram_err_i | (data_mgr_req[SEL_ISRAM].a.we
                        & (ctrl_isram_lock_i | dbg_mode_i));

    end else if (isram_fetch_active) begin
      if (fw_verified_i) begin
        // Firmware verified — fetch from ISRAM proceeds normally.
        isram_req_o   = 1'b1;
        isram_addr_o  = fetch_mgr_req[FSEL_ISRAM].a.addr;
        isram_we_o    = 1'b0;
        isram_be_o    = 4'hF;
        isram_wdata_o = '0;

        fetch_mgr_rsp[FSEL_ISRAM].gnt    = isram_gnt_i;
        fetch_mgr_rsp[FSEL_ISRAM].rvalid = isram_rvalid_i;
        fetch_mgr_rsp[FSEL_ISRAM].r.rdata = isram_rdata_i;
        fetch_mgr_rsp[FSEL_ISRAM].r.err   = isram_err_i;
      end else begin
        // Firmware not yet verified — block fetch entirely. Do not even
        // issue the request to the physical SRAM; return a bus error to
        // Ibex with the same 1-cycle latency as a normal access.
        fetch_mgr_rsp[FSEL_ISRAM].gnt     = 1'b1;
        fetch_mgr_rsp[FSEL_ISRAM].rvalid  = isram_fetch_blocked_q;
        fetch_mgr_rsp[FSEL_ISRAM].r.rdata = 32'hDEAD_BEEF;
        fetch_mgr_rsp[FSEL_ISRAM].r.err   = 1'b1;
      end
    end
  end

  // --------------------------------------------------------------------------
  // DSRAM — data demux only, no fetch access
  // --------------------------------------------------------------------------
  assign dsram_req_o   = data_mgr_req[SEL_DSRAM].req;
  assign dsram_addr_o  = data_mgr_req[SEL_DSRAM].a.addr;
  assign dsram_we_o    = data_mgr_req[SEL_DSRAM].a.we;
  assign dsram_be_o    = data_mgr_req[SEL_DSRAM].a.be;
  assign dsram_wdata_o = data_mgr_req[SEL_DSRAM].a.wdata;

  always_comb begin
    data_mgr_rsp[SEL_DSRAM]        = '0;
    data_mgr_rsp[SEL_DSRAM].gnt    = dsram_gnt_i;
    data_mgr_rsp[SEL_DSRAM].rvalid = dsram_rvalid_i;
    data_mgr_rsp[SEL_DSRAM].r.rdata = dsram_rdata_i;
    data_mgr_rsp[SEL_DSRAM].r.err   = dsram_err_i;
  end

  // --------------------------------------------------------------------------
  // Control Registers (PRIVILEGED)
  // --------------------------------------------------------------------------
  assign ctrl_req_o   = data_mgr_req[SEL_CTRL].req;
  assign ctrl_addr_o  = data_mgr_req[SEL_CTRL].a.addr;
  assign ctrl_we_o    = data_mgr_req[SEL_CTRL].a.we;
  assign ctrl_be_o    = data_mgr_req[SEL_CTRL].a.be;
  assign ctrl_wdata_o = data_mgr_req[SEL_CTRL].a.wdata;

  always_comb begin
    data_mgr_rsp[SEL_CTRL]         = '0;
    data_mgr_rsp[SEL_CTRL].gnt     = ctrl_gnt_i;
    data_mgr_rsp[SEL_CTRL].rvalid  = ctrl_rvalid_i;
    data_mgr_rsp[SEL_CTRL].r.rdata = ctrl_rdata_i;
    data_mgr_rsp[SEL_CTRL].r.err   = ctrl_err_i;
  end

  // --------------------------------------------------------------------------
  // Buffer CSR (PRIVILEGED)
  // --------------------------------------------------------------------------
  assign buf_req_o   = data_mgr_req[SEL_BUF].req;
  assign buf_addr_o  = data_mgr_req[SEL_BUF].a.addr;
  assign buf_we_o    = data_mgr_req[SEL_BUF].a.we;
  assign buf_be_o    = data_mgr_req[SEL_BUF].a.be;
  assign buf_wdata_o = data_mgr_req[SEL_BUF].a.wdata;

  always_comb begin
    data_mgr_rsp[SEL_BUF]         = '0;
    data_mgr_rsp[SEL_BUF].gnt     = buf_gnt_i;
    data_mgr_rsp[SEL_BUF].rvalid  = buf_rvalid_i;
    data_mgr_rsp[SEL_BUF].r.rdata = buf_rdata_i;
    data_mgr_rsp[SEL_BUF].r.err   = buf_err_i;
  end

  // --------------------------------------------------------------------------
  // SHA + ED25519 CSR (PRIVILEGED)
  // --------------------------------------------------------------------------
  assign sha_req_o   = data_mgr_req[SEL_SHA].req;
  assign sha_addr_o  = data_mgr_req[SEL_SHA].a.addr;
  assign sha_we_o    = data_mgr_req[SEL_SHA].a.we;
  assign sha_be_o    = data_mgr_req[SEL_SHA].a.be;
  assign sha_wdata_o = data_mgr_req[SEL_SHA].a.wdata;

  always_comb begin
    data_mgr_rsp[SEL_SHA]         = '0;
    data_mgr_rsp[SEL_SHA].gnt     = sha_gnt_i;
    data_mgr_rsp[SEL_SHA].rvalid  = sha_rvalid_i;
    data_mgr_rsp[SEL_SHA].r.rdata = sha_rdata_i;
    data_mgr_rsp[SEL_SHA].r.err   = sha_err_i;
  end

  // --------------------------------------------------------------------------
  // APB Bridge
  // --------------------------------------------------------------------------
  assign apb_req_o   = data_mgr_req[SEL_APB].req;
  assign apb_addr_o  = data_mgr_req[SEL_APB].a.addr;
  assign apb_we_o    = data_mgr_req[SEL_APB].a.we;
  assign apb_be_o    = data_mgr_req[SEL_APB].a.be;
  assign apb_wdata_o = data_mgr_req[SEL_APB].a.wdata;

  always_comb begin
    data_mgr_rsp[SEL_APB]         = '0;
    data_mgr_rsp[SEL_APB].gnt     = apb_gnt_i;
    data_mgr_rsp[SEL_APB].rvalid  = apb_rvalid_i;
    data_mgr_rsp[SEL_APB].r.rdata = apb_rdata_i;
    data_mgr_rsp[SEL_APB].r.err   = apb_err_i;
  end

  // --------------------------------------------------------------------------
  // Debug Module slave port — data demux only
  // --------------------------------------------------------------------------
  assign dbg_req_o   = data_mgr_req[SEL_DBG].req;
  assign dbg_addr_o  = data_mgr_req[SEL_DBG].a.addr;
  assign dbg_we_o    = data_mgr_req[SEL_DBG].a.we;
  assign dbg_be_o    = data_mgr_req[SEL_DBG].a.be;
  assign dbg_wdata_o = data_mgr_req[SEL_DBG].a.wdata;

  // dm_top grants immediately (no backpressure on slave port)
  always_comb begin
    data_mgr_rsp[SEL_DBG]          = '0;
    data_mgr_rsp[SEL_DBG].gnt      = data_mgr_req[SEL_DBG].req; // always grant
    data_mgr_rsp[SEL_DBG].rvalid   = dbg_rvalid_i;
    data_mgr_rsp[SEL_DBG].r.rdata  = dbg_rdata_i;
    data_mgr_rsp[SEL_DBG].r.err    = 1'b0;
  end

  // --------------------------------------------------------------------------
  // Error responder — unmapped address OR denied privileged access (Req 1-3)
  // Returns gnt immediately, rvalid next cycle, err=1, rdata=DEAD_BEEF
  // --------------------------------------------------------------------------
  logic err_rvalid_q;

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      err_rvalid_q <= 1'b0;
    end else begin
      err_rvalid_q <= data_mgr_req[SEL_ERR].req &
                      data_mgr_rsp[SEL_ERR].gnt;
    end
  end

  always_comb begin
    data_mgr_rsp[SEL_ERR]         = '0;
    data_mgr_rsp[SEL_ERR].gnt     = data_mgr_req[SEL_ERR].req;
    data_mgr_rsp[SEL_ERR].rvalid  = err_rvalid_q;
    data_mgr_rsp[SEL_ERR].r.rdata = 32'hDEAD_BEEF;
    data_mgr_rsp[SEL_ERR].r.err   = 1'b1;
  end

endmodule