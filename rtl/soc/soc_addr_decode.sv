// Copyright 2025
// SoC Address Decoder
// Wraps obi_demux for data path (10 slaves: BootROM/ISRAM/DSRAM/CTRL/BUF/
// SHA/PLIC/APB/DBG/CLINT + 1 error responder) and fetch path (3 slaves: BootROM,
// ISRAM, DBG — DBG added for debug-ROM instruction fetch, see arbiter below)
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
//   Any time, dbg_mode_i=1         | BLOCKED    | allowed   | BLOCKED (see recovery) | (fetch gate independent of dbg)
//   dbg_mode_i=1 AND recovery_i=1  | BLOCKED    | allowed   | allowed until          | still gated by fw_verified_i
//     AND boot_done_i=0            |            |           | boot_done/isram_lock   |
//
// ISRAM writes are blocked by dbg_mode_i (not just post-boot) — a
// halted-core debug session must never be able to inject or modify
// firmware in ISRAM, even during the boot window before the bootloader's
// own write-lock is set. The ONE exception is JTAG recovery boot
// (recovery_i, see soc_recovery.sv): with a faulty bootrom the debugger
// loads a replacement image into ISRAM, allowed only while boot_done_i=0
// and ctrl_isram_lock_i=0. Execution of that image is still gated by
// fw_verified_i, so recovery cannot run unsigned code.
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
// BootROM execution (BOOTROM_XGATE=1, secure-boot SoCs): instruction fetches
// from the BootROM are served only while boot_done_i=0 and recovery_i=0, i.e.
// during a normal boot. After the handoff, and in recovery (debug mode
// included -- the debugger runs from the Debug Module's own ROM and never
// needs the BootROM), a BootROM fetch gets an error response: no bootrom
// code can be re-used as gadgets. Data reads are unaffected (see data decode).
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
  parameter logic [31:0] CLINT_BASE    = 32'h0200_0000,
  parameter logic [31:0] CLINT_MASK    = 32'hFFFF_0000, // 64KB

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
  parameter int unsigned NumMaxTrans   = 2,

  // 1 = SHA window (0x0005_0000) is backed by soc_secure_boot's VERIFY
  // registers; 0 = unimplemented, accesses get an error response.
  parameter bit          SHA_IMPL      = 1'b0,
  // 1 = PLIC / CLINT windows routed to their ports; 0 = error response
  parameter bit          PLIC_IMPL     = 1'b0,
  parameter bit          CLINT_IMPL    = 1'b0,
  // 1 = BootROM executable only during a normal boot (see header); 0 = always
  parameter bit          BOOTROM_XGATE = 1'b0
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

  // Core is executing in debug mode, i.e. every access on this cycle comes
  // from the debugger (debug ROM, abstract command or program buffer).
  // basic_soc_top wires ibex_top.debug_mode_o here. Tie 1'b0 in a SoC
  // without debug (fail-closed: no post-boot CSR reads at all).
  input  logic        dbg_mode_i,

  // JTAG recovery boot active (soc_recovery.sv). Only relaxes the debug
  // ISRAM-write block above; tie 1'b0 in SoCs without recovery.
  input  logic        recovery_i,

  //--------------------------------------------------------------------
  // Secure-boot verifier ISRAM read port (soc_secure_boot feeder).
  // Read-only, lowest priority (data > fetch > verifier). Tie ver_req_i
  // to 1'b0 in SoCs without soc_secure_boot.
  //--------------------------------------------------------------------
  input  logic        ver_req_i,
  input  logic [31:0] ver_addr_i,
  output logic        ver_gnt_o,
  output logic        ver_rvalid_o,
  output logic [31:0] ver_rdata_o,

  // ISRAM fetch permission for the CURRENT fetch address (Req 4). With
  // soc_secure_boot this is fetch_ok_o: verified signature, ISRAM unchanged
  // since, and instr_addr_i inside the signed code range. Legacy SoCs drive
  // a plain verified flag.
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
  // CLINT (mtime/mtimecmp/msip) — OBI subordinate, not privileged.
  // Tie the inputs off in SoCs without a CLINT (CLINT_IMPL=0).
  //--------------------------------------------------------------------
  output logic        clint_req_o,
  input  logic        clint_gnt_i,
  input  logic        clint_rvalid_i,
  output logic [31:0] clint_addr_o,
  output logic        clint_we_o,
  output logic [ 3:0] clint_be_o,
  output logic [31:0] clint_wdata_o,
  input  logic [31:0] clint_rdata_i,
  input  logic        clint_err_i,

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

  // Debug Target Interface (dm_top slave port). Shared by BOTH the data
  // demux (SEL_DBG — abstract data register / program-buffer-data
  // access) AND the fetch demux (FSEL_DBG — debug ROM / program-buffer
  // instruction fetch) via the arbiter below, mirroring the BootROM/
  // ISRAM arbiters. Both traffic types originate from the same halted
  // Ibex core executing the execution-based debug protocol, never from
  // a second independent master (no System Bus Access: the DM is built with
  // SbaEnable=0 in basic_soc_top).
  //
  // dbg_gnt_i / dbg_rvalid_i: CONFIRMED against dm_obi_top.sv — slave_gnt_o
  // is hardwired 1'b1 (always-ready) and slave_rvalid_o pulses one cycle
  // after any granted request. Since gnt is unconditionally high, this
  // matches the assumed "gnt=req, rvalid next cycle" model exactly.
  output logic        dbg_req_o,
  output logic [31:0] dbg_addr_o,
  output logic        dbg_we_o,
  output logic [ 3:0] dbg_be_o,
  output logic [31:0] dbg_wdata_o,
  input  logic        dbg_gnt_i,
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
    SEL_ERR     = 4'd9,
    SEL_CLINT   = 4'd10
    // If a new privileged slave is added (e.g. SEL_CRYPTO2), widen this
    // enum, bump DataNumMgrPorts below, and add a new manager-port slot.
  } data_sel_e;

  // --------------------------------------------------------------------------
  // Slave index encoding for fetch demux (3 slaves)
  // --------------------------------------------------------------------------
  // FSEL_DBG added: when the core enters debug mode (PC = DmHaltAddr,
  // e.g. 0x1A11_0800) it FETCHES instructions from dm_top's debug ROM /
  // program buffer via the normal instr_req_o path — this is not an
  // optional extra, the execution-based debug protocol requires it (see
  // soc_top.sv comments on dbg_mode / dm_top). Without this, a fetch to
  // the debug ROM range silently falls through to FSEL_BOOTROM instead.
  typedef enum logic [1:0] {
    FSEL_BOOTROM = 2'd0,
    FSEL_ISRAM   = 2'd1,
    FSEL_DBG     = 2'd2
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

  // writes: boot phase only, never from the debugger -- except that in JTAG
  // recovery the debugger may write the SHA window (VERIFY_CTRL.start), the
  // only way to verify a debugger-loaded image. That register can only start
  // a hardware-fed verification; it cannot influence the result.
  logic sha_hit;
  assign sha_hit       = ((data_addr_i & SHA_MASK) == SHA_BASE);
  assign priv_write_ok = ~boot_done_i & (~dbg_mode_i | (sha_hit & recovery_i));
  assign priv_read_ok  = ~boot_done_i | dbg_mode_i;     // reads: boot phase, or debug-halted
  assign priv_denied   = priv_hit & (data_we_i ? ~priv_write_ok : ~priv_read_ok);

  // --------------------------------------------------------------------------
  // Data path address decode → select signal
  // --------------------------------------------------------------------------
  data_sel_e data_sel;

  always_comb begin
    // BootROM: data READS allowed in the boot phase (strings/constants of the
    // boot code, .rodata of a C bootrom) or from the debugger; writes, and
    // reads by post-boot firmware, get an error.
    if      ((data_addr_i & BOOTROM_MASK) == BOOTROM_BASE) data_sel = (!data_we_i && (!boot_done_i || dbg_mode_i)) ? SEL_BOOTROM : SEL_ERR;
    else if ((data_addr_i & ISRAM_MASK)   == ISRAM_BASE)   data_sel = SEL_ISRAM;
    else if ((data_addr_i & DSRAM_MASK)   == DSRAM_BASE)   data_sel = SEL_DSRAM;
    else if (priv_denied)                                  data_sel = SEL_ERR; // Req 1-3
    else if ((data_addr_i & CTRL_MASK)    == CTRL_BASE)    data_sel = SEL_CTRL;
    else if ((data_addr_i & BUF_MASK)     == BUF_BASE)     data_sel = SEL_ERR; // BUF unimplemented
    else if ((data_addr_i & SHA_MASK)     == SHA_BASE)     data_sel = SHA_IMPL ? SEL_SHA : SEL_ERR;
    else if ((data_addr_i & PLIC_MASK)    == PLIC_BASE)    data_sel = PLIC_IMPL  ? SEL_PLIC  : SEL_ERR;
    else if ((data_addr_i & CLINT_MASK)   == CLINT_BASE)   data_sel = CLINT_IMPL ? SEL_CLINT : SEL_ERR;
    else if ((data_addr_i & DBG_MASK)     == DBG_BASE)     data_sel = SEL_DBG; // abstract data register access (dm_obi_top slave)
    else if ((data_addr_i & APB_MASK)     == APB_BASE)     data_sel = SEL_APB;
    else                                                    data_sel = SEL_ERR;
  end

  // --------------------------------------------------------------------------
  // Fetch path address decode → select signal
  // --------------------------------------------------------------------------
  fetch_sel_e fetch_sel;

  always_comb begin
    if      ((instr_addr_i & ISRAM_MASK) == ISRAM_BASE) fetch_sel = FSEL_ISRAM;
    else if ((instr_addr_i & DBG_MASK)   == DBG_BASE)   fetch_sel = FSEL_DBG;
    else                                                 fetch_sel = FSEL_BOOTROM;
  end

  // --------------------------------------------------------------------------
  // Data demux — 9 manager ports (8 slaves + 1 error responder)
  // --------------------------------------------------------------------------
  localparam int unsigned DataNumMgrPorts = 11; // SEL_BOOTROM..SEL_CLINT = indices 0..10

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
  // Fetch demux — 3 manager ports (BootROM, ISRAM, DBG)
  // --------------------------------------------------------------------------
  localparam int unsigned FetchNumMgrPorts = 3;

  soc_obi_req_t [FetchNumMgrPorts-1:0] fetch_mgr_req;
  soc_obi_rsp_t [FetchNumMgrPorts-1:0] fetch_mgr_rsp;

  obi_demux #(
    .ObiCfg      ( SocObiCfg        ),
    .obi_req_t   ( soc_obi_req_t    ),
    .obi_rsp_t   ( soc_obi_rsp_t    ),
    .NumMgrPorts ( FetchNumMgrPorts  ),
    .NumMaxTrans ( NumMaxTrans       ),
    .select_t    ( logic [1:0]       )
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
  //           data demux [SEL_BOOTROM] (read-only; decode above rejects writes)
  // Priority: data wins (a load stalls the pipeline; fetch just retries).
  // Responses are routed by the LATCHED owner of the accepted request, the
  // same scheme as the ISRAM / DBG arbiters.
  // --------------------------------------------------------------------------
  logic bootrom_data_active, bootrom_resp_is_data_q;
  logic bootrom_fetch_ok, bootrom_fetch_blocked_q;

  // BootROM execute gate (header): normal boot only.
  assign bootrom_fetch_ok = !BOOTROM_XGATE || (!boot_done_i && !recovery_i);

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni)                                bootrom_resp_is_data_q <= 1'b0;
    else if (bootrom_req_o && bootrom_gnt_i)    bootrom_resp_is_data_q <= bootrom_data_active;
  end

  // A refused fetch never reaches the ROM; it is answered with an error one
  // cycle after its grant (same scheme as the ISRAM fetch gate).
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) bootrom_fetch_blocked_q <= 1'b0;
    else         bootrom_fetch_blocked_q <= fetch_mgr_req[FSEL_BOOTROM].req &
                                            ~bootrom_data_active & ~bootrom_fetch_ok;
  end

  always_comb begin
    bootrom_data_active = data_mgr_req[SEL_BOOTROM].req;

    bootrom_we_o    = 1'b0;   // BootROM is always read-only
    bootrom_wdata_o = '0;
    bootrom_be_o    = 4'hF;
    if (bootrom_data_active) begin
      bootrom_req_o  = 1'b1;
      bootrom_addr_o = data_mgr_req[SEL_BOOTROM].a.addr;
    end else begin
      bootrom_req_o  = fetch_mgr_req[FSEL_BOOTROM].req & bootrom_fetch_ok;
      bootrom_addr_o = fetch_mgr_req[FSEL_BOOTROM].a.addr;
    end

    fetch_mgr_rsp[FSEL_BOOTROM]     = '0;
    fetch_mgr_rsp[FSEL_BOOTROM].gnt = bootrom_fetch_ok ? (bootrom_gnt_i & ~bootrom_data_active)
                                                       : (fetch_mgr_req[FSEL_BOOTROM].req & ~bootrom_data_active);
    data_mgr_rsp[SEL_BOOTROM]       = '0;
    data_mgr_rsp[SEL_BOOTROM].gnt   = bootrom_gnt_i &  bootrom_data_active;

    if (bootrom_resp_is_data_q) begin
      data_mgr_rsp[SEL_BOOTROM].rvalid  = bootrom_rvalid_i;
      data_mgr_rsp[SEL_BOOTROM].r.rdata = bootrom_rdata_i;
      data_mgr_rsp[SEL_BOOTROM].r.err   = bootrom_err_i;
    end else begin
      fetch_mgr_rsp[FSEL_BOOTROM].rvalid  = bootrom_rvalid_i;
      fetch_mgr_rsp[FSEL_BOOTROM].r.rdata = bootrom_rdata_i;
      fetch_mgr_rsp[FSEL_BOOTROM].r.err   = bootrom_err_i;
    end

    if (bootrom_fetch_blocked_q) begin
      fetch_mgr_rsp[FSEL_BOOTROM].rvalid  = 1'b1;
      fetch_mgr_rsp[FSEL_BOOTROM].r.rdata = 32'hDEAD_BEEF;
      fetch_mgr_rsp[FSEL_BOOTROM].r.err   = 1'b1;
    end
  end

  // --------------------------------------------------------------------------
// ISRAM — arbiter between fetch demux [FSEL_ISRAM] and data demux [SEL_ISRAM]
// Priority: data wins (writes must not be blocked; fetch stalls are acceptable)
// Write port gated by ctrl_isram_lock_i
// Fetch port gated by fw_verified_i (Req 4)
// --------------------------------------------------------------------------
logic isram_data_active, isram_fetch_active, isram_ver_active;
logic isram_fetch_blocked_q;

// Owner of the in-flight transaction when it came from the verifier port.
logic isram_resp_is_ver_q;

// NEW: remembers which port's request is the one currently in flight,
// so the response (which arrives after req has already dropped) gets
// routed back to the correct port instead of being silently dropped.
logic isram_resp_is_data_q;

// Debug-session ISRAM write block, relaxed only for JTAG recovery boot.
logic isram_dbg_wr_block;
assign isram_dbg_wr_block = dbg_mode_i & ~(recovery_i & ~boot_done_i);

// Write-denied status of the in-flight data transaction. OBI err belongs to
// the response phase, so it must be latched like the owner -- driving it only
// in the request cycle meant a denied write was silently dropped with err=0.
logic isram_wr_denied, isram_wr_denied_q;
assign isram_wr_denied = data_mgr_req[SEL_ISRAM].a.we &
                         (ctrl_isram_lock_i | isram_dbg_wr_block);

always_ff @(posedge clk_i or negedge rst_ni) begin
  if (!rst_ni) isram_fetch_blocked_q <= 1'b0;
  else         isram_fetch_blocked_q <= isram_fetch_active & ~fw_verified_i;
end

always_ff @(posedge clk_i or negedge rst_ni) begin
  if (!rst_ni) begin
    isram_resp_is_data_q <= 1'b0;
    isram_resp_is_ver_q  <= 1'b0;
    isram_wr_denied_q    <= 1'b0;
  end else if (isram_req_o && isram_gnt_i) begin
    // A transaction was just accepted this cycle — latch which port it
    // came from so the eventual isram_rvalid_i pulse routes correctly.
    isram_resp_is_data_q <= isram_data_active;
    isram_resp_is_ver_q  <= isram_ver_active;
    isram_wr_denied_q    <= isram_data_active & isram_wr_denied;
  end
end

always_comb begin
  isram_data_active  = data_mgr_req[SEL_ISRAM].req;
  isram_fetch_active = fetch_mgr_req[FSEL_ISRAM].req & ~isram_data_active;
  isram_ver_active   = ver_req_i & ~isram_data_active & ~fetch_mgr_req[FSEL_ISRAM].req;

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

  // Verifier response defaults
  ver_gnt_o    = 1'b0;
  ver_rvalid_o = 1'b0;
  ver_rdata_o  = '0;

  if (isram_data_active) begin
    // Data port drives ISRAM — apply write lock
    isram_req_o   = 1'b1;
    isram_addr_o  = data_mgr_req[SEL_ISRAM].a.addr;
    isram_we_o    = data_mgr_req[SEL_ISRAM].a.we & ~isram_wr_denied;
    isram_be_o    = data_mgr_req[SEL_ISRAM].a.be;
    isram_wdata_o = data_mgr_req[SEL_ISRAM].a.wdata;

    data_mgr_rsp[SEL_ISRAM].gnt = isram_gnt_i;
  end else if (isram_fetch_active) begin
    if (fw_verified_i) begin
      isram_req_o   = 1'b1;
      isram_addr_o  = fetch_mgr_req[FSEL_ISRAM].a.addr;
      isram_we_o    = 1'b0;
      isram_be_o    = 4'hF;
      isram_wdata_o = '0;

      fetch_mgr_rsp[FSEL_ISRAM].gnt = isram_gnt_i;
    end else begin
      fetch_mgr_rsp[FSEL_ISRAM].gnt     = 1'b1;
      fetch_mgr_rsp[FSEL_ISRAM].rvalid  = isram_fetch_blocked_q;
      fetch_mgr_rsp[FSEL_ISRAM].r.rdata = 32'hDEAD_BEEF;
      fetch_mgr_rsp[FSEL_ISRAM].r.err   = 1'b1;
    end
  end else if (isram_ver_active) begin
    // Secure-boot verifier: read-only
    isram_req_o   = 1'b1;
    isram_addr_o  = ver_addr_i;
    isram_we_o    = 1'b0;
    isram_be_o    = 4'hF;
    isram_wdata_o = '0;
    ver_gnt_o     = isram_gnt_i;
  end

  // NEW: route the response using the LATCHED owner, not live req state.
  // This fires regardless of what isram_data_active/isram_fetch_active
  // happen to be on the response cycle.
  if (isram_resp_is_data_q) begin
    data_mgr_rsp[SEL_ISRAM].rvalid  = isram_rvalid_i;
    data_mgr_rsp[SEL_ISRAM].r.rdata = isram_rdata_i;
    data_mgr_rsp[SEL_ISRAM].r.err   = isram_err_i | isram_wr_denied_q;
  end else if (isram_resp_is_ver_q) begin
    ver_rvalid_o = isram_rvalid_i;
    ver_rdata_o  = isram_rdata_i;
  end else begin
    fetch_mgr_rsp[FSEL_ISRAM].rvalid  = isram_rvalid_i;
    fetch_mgr_rsp[FSEL_ISRAM].r.rdata = isram_rdata_i;
    fetch_mgr_rsp[FSEL_ISRAM].r.err   = isram_err_i;
  end

  // A fetch refused by the fw_verified_i gate never reaches the ISRAM, so its
  // response comes from here (one cycle after the gnt above). This must come
  // after the routing block: previously the routing block overwrote it with
  // isram_rvalid_i=0, so a blocked fetch never completed and wedged the core
  // (and the fetch demux) instead of raising an instruction access fault.
  if (isram_fetch_blocked_q) begin
    fetch_mgr_rsp[FSEL_ISRAM].rvalid  = 1'b1;
    fetch_mgr_rsp[FSEL_ISRAM].r.rdata = 32'hDEAD_BEEF;
    fetch_mgr_rsp[FSEL_ISRAM].r.err   = 1'b1;
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
  // PLIC — data demux only, simple passthrough (not privileged: interrupt
  // controller config isn't verification-critical state, no gating needed)
  // NOTE: ports/decode case existed already but the response wiring was
  // missing — plic_req_o/data_mgr_rsp[SEL_PLIC] were undriven. Added here.
  // --------------------------------------------------------------------------
  assign plic_req_o   = data_mgr_req[SEL_PLIC].req;
  assign plic_addr_o  = data_mgr_req[SEL_PLIC].a.addr;
  assign plic_we_o    = data_mgr_req[SEL_PLIC].a.we;
  assign plic_be_o    = data_mgr_req[SEL_PLIC].a.be;
  assign plic_wdata_o = data_mgr_req[SEL_PLIC].a.wdata;

  always_comb begin
    data_mgr_rsp[SEL_PLIC]         = '0;
    data_mgr_rsp[SEL_PLIC].gnt     = plic_gnt_i;
    data_mgr_rsp[SEL_PLIC].rvalid  = plic_rvalid_i;
    data_mgr_rsp[SEL_PLIC].r.rdata = plic_rdata_i;
    data_mgr_rsp[SEL_PLIC].r.err   = plic_err_i;
  end

  // --------------------------------------------------------------------------
  // CLINT — data demux only, simple passthrough (not privileged)
  // --------------------------------------------------------------------------
  assign clint_req_o   = data_mgr_req[SEL_CLINT].req;
  assign clint_addr_o  = data_mgr_req[SEL_CLINT].a.addr;
  assign clint_we_o    = data_mgr_req[SEL_CLINT].a.we;
  assign clint_be_o    = data_mgr_req[SEL_CLINT].a.be;
  assign clint_wdata_o = data_mgr_req[SEL_CLINT].a.wdata;

  always_comb begin
    data_mgr_rsp[SEL_CLINT]         = '0;
    data_mgr_rsp[SEL_CLINT].gnt     = clint_gnt_i;
    data_mgr_rsp[SEL_CLINT].rvalid  = clint_rvalid_i;
    data_mgr_rsp[SEL_CLINT].r.rdata = clint_rdata_i;
    data_mgr_rsp[SEL_CLINT].r.err   = clint_err_i;
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
  // Debug Module slave port — arbiter between data demux [SEL_DBG]
  // (abstract data register access) and fetch demux [FSEL_DBG] (debug
  // ROM / program buffer instruction fetch). Priority: data wins, same
  // convention as the ISRAM arbiter — mid-transaction data-register
  // accesses shouldn't be preempted by the next instruction fetch.
  // NOT gated by boot_done_i/dbg_mode_i/fw_verified_i: this path is only
  // ever reachable when the core is already halted in debug mode by
  // construction (that's what dm_mem is for), so the priv model doesn't
  // apply here.
  // --------------------------------------------------------------------------
  logic dbg_data_active, dbg_fetch_active;

  // Same fix as the ISRAM arbiter: remember which port owns the in-flight
  // transaction, so the rvalid pulse (which arrives after the manager has
  // already dropped req) is routed back instead of silently dropped. Without
  // this, Ibex's prefetch buffer loses debug-ROM fetch responses after a
  // pipeline flush and wedges waiting for rvalid.
  logic dbg_resp_is_data_q;

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      dbg_resp_is_data_q <= 1'b0;
    end else if (dbg_req_o && dbg_gnt_i) begin
      dbg_resp_is_data_q <= dbg_data_active;
    end
  end

  always_comb begin
    dbg_data_active  = data_mgr_req[SEL_DBG].req;
    dbg_fetch_active = fetch_mgr_req[FSEL_DBG].req & ~dbg_data_active;

    dbg_req_o   = 1'b0;
    dbg_addr_o  = '0;
    dbg_we_o    = 1'b0;
    dbg_be_o    = '0;
    dbg_wdata_o = '0;

    data_mgr_rsp[SEL_DBG]   = '0;
    fetch_mgr_rsp[FSEL_DBG] = '0;

    if (dbg_data_active) begin
      dbg_req_o   = 1'b1;
      dbg_addr_o  = data_mgr_req[SEL_DBG].a.addr;
      dbg_we_o    = data_mgr_req[SEL_DBG].a.we;
      dbg_be_o    = data_mgr_req[SEL_DBG].a.be;
      dbg_wdata_o = data_mgr_req[SEL_DBG].a.wdata;

      data_mgr_rsp[SEL_DBG].gnt     = dbg_gnt_i;

    end else if (dbg_fetch_active) begin
      dbg_req_o   = 1'b1;
      dbg_addr_o  = fetch_mgr_req[FSEL_DBG].a.addr;
      dbg_we_o    = 1'b0;
      dbg_be_o    = 4'hF;
      dbg_wdata_o = '0;

      fetch_mgr_rsp[FSEL_DBG].gnt     = dbg_gnt_i;
    end

    // Route the response using the LATCHED owner, not live req state.
    if (dbg_resp_is_data_q) begin
      data_mgr_rsp[SEL_DBG].rvalid  = dbg_rvalid_i;
      data_mgr_rsp[SEL_DBG].r.rdata = dbg_rdata_i;
    end else begin
      fetch_mgr_rsp[FSEL_DBG].rvalid  = dbg_rvalid_i;
      fetch_mgr_rsp[FSEL_DBG].r.rdata = dbg_rdata_i;
    end
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
