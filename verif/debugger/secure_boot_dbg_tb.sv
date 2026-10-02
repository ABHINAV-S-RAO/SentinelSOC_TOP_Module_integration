// =============================================================================
// secure_boot_dbg_tb.sv -- riscv-dbg + Ibex(DIFT) + JTAG recovery + hardware secure boot
//
// Drives basic_soc_top's external JTAG pins (jtag_if BFM) and self-checks:
//   Part A  generic debug-spec behaviour (DTM, DM, halt/resume, abstract
//           register/CSR access, program buffer, single-step, errors, ndmreset,
//           dmactive, hartsel, autoexec, SBA)
//   Part B  DIFT <-> debugger interaction, one scenario per SoC boot:
//     S1 tainted GPRs, no checks      -> tag tracking across debug ops
//     S2 tainted t1, full TCR policy  -> TCR/TPR lockout, reads, progbuf faults
//     S5 DIFT has no off switch       -> core dift_en tied on inside the SoC
//     S3 tainted s0, full policy      -> can the hart still be halted?
//     S4 tainted FLAGS tag alias      -> can the hart still be halted/resumed?
//     S6 X tag on FLAGS alias         -> uninitialised tag RAM (sim only)
//   Part D  SoC debug access policy (dbg_mode from ibex debug_mode_o):
//     D-TAG  debugger stores into DSRAM are tagged untrusted
//     D-PRIV debugger cannot write SoC CSRs / ISRAM, can read them
//   Part C  no SBA: not advertised, forced SBA pokes are ignored
//   Part E  JTAG recovery boot + hardware-fed Ed25519 secure boot
//           (soc_secure_boot; power-on resets, faulty bootrom):
//     R-STRAP  strap -> halted before first insn; the BootROM is not
//              executable in recovery; TCR/TPR stay locked; the debugger
//              loads the signed image (verif/debugger/images, TEST-ONLY key in
//              OTP); it does not run unverified; a tampered copy is rejected;
//              ISRAM locks when the verification starts; the engine is
//              one-shot per reset; the signed copy verifies; only ENTRY may be
//              entered (header / entry+4 fault); resuming at ENTRY makes the
//              HARDWARE set boot_done; afterwards the debugger can no longer
//              write ISRAM / VERIFY / CTRL
//     R-WDT    faulty bootrom: boot watchdog forces recovery; the ISRAM lock
//              blocks swap-after-verify; ndmreset clears lock + boot_done,
//              keeps ISRAM and recovery; retry verifies and runs
//     R-NORMAL good bootrom, no strap -> real secure boot, hardware boot_done,
//              no recovery; BootROM not executable after the handoff; ndmreset
//              clears boot_done and the boot runs again
//   Part F  hardware boot handoff vs. a buggy bootrom (strap = 0):
//     F-CTRL1  bootrom writes CTRL1 (old boot_done_set) and hangs -> ignored,
//              watchdog -> recovery (the bug that used to brick the chip)
//     F-SKIPV  bootrom jumps to ENTRY without verifying -> fetch refused,
//              no boot_done, watchdog -> recovery
//     F-JOFF   bootrom verifies, then jumps to ENTRY+8 -> single entry
//              refuses it, no boot_done, watchdog -> recovery
//     F-ISRW   bootrom writes ISRAM after VERIFY start -> bus error (lock),
//              image intact, boots normally
//     F-TAMPER tampered image, good bootrom -> rejected, watchdog -> recovery
//
// Result classes:
//   [FAIL]     debug functionality broken / RTL feature not behaving as coded
//   [FINDING]  DIFT integrity or availability issue caused by debug (design
//              review item -- the debugger "works", DIFT semantics break)
//   [OBS]      observed DIFT-specific behaviour, reported for the record
//
// Every boot is a real secure boot. A small bootrom is assembled here and
// backdoor-loaded into the bootrom model: it starts the hardware verification,
// waits for it and jumps to ENTRY (hardware then sets boot_done). Switches in
// DSRAM make it misbehave on purpose (Part F). The DIFT test firmware is a
// signed ISRAM image (verif/debugger/images/dift_fw_signed.mem) that is
// backdoor-copied into ISRAM before each boot, standing in for the flash copy.
// Scenario config (TPR/TCR and secret values) is backdoor-written into DSRAM,
// and taint is injected by writing the SoC's shadow tag RAM (u_dut.tag_mem)
// before an ndmreset boot; the firmware's loads then propagate that taint
// into GPR tags (TPR EN_SOURCE).
// =============================================================================
`timescale 1ns/1ps

`define CORE  u_dut.u_ibex_top.u_ibex_core
`define CTRL  `CORE.id_stage_i.controller_i
`define TAGRF `CORE.tag_register_file_i.rf_reg
`define GPR   u_dut.u_ibex_top.gen_regfile_ff.register_file_i.rf_reg
`define CSRS  `CORE.cs_registers_i

module secure_boot_dbg_tb;
  import dm::*;

`ifndef DIFT
  initial $fatal(1, "secure_boot_dbg_tb must be compiled with +define+DIFT");
`endif

  // ---------------------------------------------------------------------------
  // Clock / reset / JTAG
  // ---------------------------------------------------------------------------
  localparam time CLK_PERIOD = 10ns;

  logic clk_i, rst_ni;
  initial clk_i = 1'b0;
  always #(CLK_PERIOD/2) clk_i = ~clk_i;

  initial begin
    rst_ni = 1'b1;
    #1 rst_ni = 1'b0;          // a real edge: Verilator has no time-0 negedge
    repeat (10) @(posedge clk_i);
    rst_ni = 1'b1;
  end

  jtag_if u_jtag();
  initial u_jtag.tck_half_period = CLK_PERIOD * 3;

  wire jtag_tck    = u_jtag.tck;
  wire jtag_tms    = u_jtag.tms;
  wire jtag_trst_n = u_jtag.trst_n;
  wire jtag_tdi    = u_jtag.tdi;
  wire jtag_tdo_dut;
  assign u_jtag.tdo = jtag_tdo_dut;

  logic boot_mode = 1'b0;   // recovery strap

  // Boot watchdog: must cover one hardware verification (~0.42M cycles, the
  // real boot flow runs before every scenario), kept short so R-WDT / Part F
  // run quickly. The SoC default (2M) is checked by full_soc_tb +BIGIMAGE.
  localparam int unsigned WDT_CYCLES = 600_000;

  // ---------------------------------------------------------------------------
  // DUT + memory models
  // ---------------------------------------------------------------------------
  logic        bootrom_req, bootrom_gnt, bootrom_rvalid, bootrom_we, bootrom_err;
  logic [3:0]  bootrom_be;
  logic [31:0] bootrom_addr, bootrom_wdata, bootrom_rdata;
  logic        isram_req, isram_gnt, isram_rvalid, isram_we, isram_err;
  logic [3:0]  isram_be;
  logic [31:0] isram_addr, isram_wdata, isram_rdata;
  logic        data_req, data_gnt, data_rvalid, data_we, data_err;
  logic [3:0]  data_be;
  logic [31:0] data_addr, data_wdata, data_rdata;
  logic        uart_tx, spi_clk;
  logic [3:0]  spi_csn, spi_sdo;
  logic [1:0]  spi_mode;

  basic_soc_top #(
    .BOOT_WDT_CYCLES   ( WDT_CYCLES     )
  ) u_dut (
    .clk_i             ( clk_i          ),
    .rst_ni            ( rst_ni         ),
    .crypto_verified_i ( 1'b0           ),   // legacy pin, unused with SECURE_BOOT=1
    .boot_mode_i       ( boot_mode      ),
    .uart_tx_o         ( uart_tx        ),
    .uart_rx_i         ( 1'b1           ),
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
    .data_req_o        ( data_req       ),
    .data_gnt_i        ( data_gnt       ),
    .data_rvalid_i     ( data_rvalid    ),
    .data_addr_o       ( data_addr      ),
    .data_we_o         ( data_we        ),
    .data_be_o         ( data_be        ),
    .data_wdata_o      ( data_wdata     ),
    .data_rdata_i      ( data_rdata     ),
    .data_err_i        ( data_err       ),
    .spi_clk_o         ( spi_clk        ),
    .spi_csn_o         ( spi_csn        ),
    .spi_mode_o        ( spi_mode       ),
    .spi_sdo_o         ( spi_sdo        ),
    .spi_sdi_i         ( 4'h0           ),
    .spi2_clk_o        (                ),   // general-purpose SPI unused here
    .spi2_csn_o        (                ),
    .spi2_sdo_o        (                ),
    .spi2_sdi_i        ( 1'b0           ),
    .gpio_in_i         ( 32'h0          ),   // GPIO unused here
    .gpio_out_o        (                ),
    .gpio_dir_o        (                ),
    .jtag_tck_i        ( jtag_tck       ),
    .jtag_tms_i        ( jtag_tms       ),
    .jtag_trst_ni      ( jtag_trst_n    ),
    .jtag_tdi_i        ( jtag_tdi       ),
    .jtag_tdo_o        ( jtag_tdo_dut   )
  );

  bootrom_model #(.DEPTH(16384), .HEX_FILE("")) u_bootrom (
    .clk_i(clk_i), .rst_ni(rst_ni), .req_i(bootrom_req), .gnt_o(bootrom_gnt),
    .rvalid_o(bootrom_rvalid), .addr_i(bootrom_addr), .we_i(bootrom_we),
    .be_i(bootrom_be), .wdata_i(bootrom_wdata), .rdata_o(bootrom_rdata),
    .err_o(bootrom_err));

  isram_model #(.DEPTH(65536), .HEX_FILE("")) u_isram (
    .clk_i(clk_i), .rst_ni(rst_ni), .req_i(isram_req), .gnt_o(isram_gnt),
    .rvalid_o(isram_rvalid), .addr_i(isram_addr), .we_i(isram_we),
    .be_i(isram_be), .wdata_i(isram_wdata), .rdata_o(isram_rdata),
    .err_o(isram_err));

  dsram_model #(.DEPTH(16384), .HEX_FILE("")) u_dsram (
    .clk_i(clk_i), .rst_ni(rst_ni), .req_i(data_req), .gnt_o(data_gnt),
    .rvalid_o(data_rvalid), .addr_i(data_addr), .we_i(data_we),
    .be_i(data_be), .wdata_i(data_wdata), .rdata_o(data_rdata),
    .err_o(data_err));

  // ---------------------------------------------------------------------------
  // Constants
  // ---------------------------------------------------------------------------
  // GPR numbers
  localparam int T0 = 5, T1 = 6, T2 = 7, S0 = 8, S1 = 9, A0 = 10, A1 = 11,
                 T3 = 28, T4 = 29, T5 = 30;

  // DSRAM (0x0002_0000) word layout used by the firmware
  localparam int W_TPR = 4, W_TCR = 5, W_BD = 6, W_S0 = 8, W_A0 = 9, W_T1 = 10,
                 W_S1 = 11, W_HB = 12, W_MCAUSE = 13, W_TRAPCNT = 14, W_MARK = 15,
                 W_DBGWR = 16;
  // TB bootrom switches (W_BD = hand over to the firmware; 0 = spin in ROM)
  localparam int W_ROM_CTRL1 = 17,   // write CTRL1 (old boot_done_set) first
                 W_ROM_SKIPV = 18,   // jump to ENTRY without verifying
                 W_ROM_ISRW  = 19,   // write ISRAM after VERIFY start
                 W_ROM_JOFF  = 20;   // byte offset added to ENTRY for the jump

  // SoC map
  localparam logic [31:0] ISRAM_BASE = 32'h0001_0000, DSRAM_BASE = 32'h0002_0000,
                          CTRL_BASE  = 32'h0003_0000;
  localparam int ISRAM_IDX0 = (ISRAM_BASE >> 2) % 65536;   // isram_model index of 0x1_0000
  localparam logic [31:0] MARK_OK = 32'h600D_B007;          // written by the recovery image
  localparam logic [31:0] SB_BASE = 32'h0005_0000;          // soc_secure_boot VERIFY registers
  localparam logic [31:0] ENTRY   = ISRAM_BASE + 32'h44;    // first signed code word
  localparam int          IMG_WORDS = 25;                   // header(17) + code(8)
  localparam int          FW_WORDS  = 119;                  // DIFT test firmware image
  localparam logic [31:0] ROM_FAIL  = 32'hFFFF_FFFF;        // W_MARK: bootrom saw "not verified"

  localparam logic [31:0] SEC_S0 = 32'h5EC0_0008, SEC_A0 = 32'h5EC0_000A,
                          SEC_T1 = 32'h5EC0_0006, VAL_S1 = 32'hC1EA_0009;

  // Firmware heartbeat loop in ISRAM (gen_signed_image.py, dift_fw_signed.mem)
  localparam logic [31:0] PC_LOOP0 = 32'h0001_01B4, PC_LOOP1 = 32'h0001_01B8,
                          PC_LOOP2 = 32'h0001_01BC;
  // TB bootrom spin loop (W_BD = 0)
  localparam logic [31:0] ROM_LOOP0 = 32'h0000_00E8, ROM_LOOP2 = 32'h0000_00F0;

  // Shadow tag RAM is indexed by addr[11:2] for EVERY data address, so DM
  // accesses alias onto DSRAM word tags:
  localparam int TAG_HALTED = 12'h100 >> 2;  // 0x1A110100 -> DSRAM 0x20100
  localparam int TAG_DATA0  = 12'h380 >> 2;  // 0x1A110380 -> DSRAM 0x20380
  localparam int TAG_FLAGS  = 12'h400 >> 2;  // 0x1A110400 -> DSRAM 0x20400

  // TPR: every ALU class = OR propagation, loads propagate memory tag
  localparam logic [31:0] TPR_OR   = 32'h0000_AAAA;
  // TCR: checks on jump s1, branch s1/s2, ld/st addr+src, int s1/s2,
  //      shift s1, logical s1, compare s1
  localparam logic [31:0] TCR_FULL = 32'h0001_56F2;
  localparam logic [31:0] TCR_NONE = 32'h0;

  localparam logic [11:0] CSR_MEPC_I = 12'h341, CSR_MCAUSE_I = 12'h342;
  localparam logic [15:0] CSR_DCSR = 16'h07B0, CSR_DPC = 16'h07B1,
                          CSR_MSCRATCH = 16'h0340, CSR_TCR = 16'h07C2,
                          CSR_TPR = 16'h07C3, CSR_BOGUS = 16'h07FF;

  // ---------------------------------------------------------------------------
  // Tiny RV32I encoder (firmware + program buffer)
  // ---------------------------------------------------------------------------
  function automatic logic [31:0] enc_i(int imm, int rs1, int f3, int rd, logic [6:0] op);
    logic [11:0] im = imm;
    return {im, 5'(rs1), 3'(f3), 5'(rd), op};
  endfunction
  function automatic logic [31:0] enc_s(int imm, int rs2, int rs1, int f3);
    logic [11:0] im = imm;
    return {im[11:5], 5'(rs2), 5'(rs1), 3'(f3), im[4:0], 7'h23};
  endfunction
  function automatic logic [31:0] addi(int rd, int rs1, int imm); return enc_i(imm, rs1, 0, rd, 7'h13); endfunction
  function automatic logic [31:0] lw  (int rd, int rs1, int imm); return enc_i(imm, rs1, 2, rd, 7'h03); endfunction
  function automatic logic [31:0] sw  (int rs2, int rs1, int imm); return enc_s(imm, rs2, rs1, 2);     endfunction
  function automatic logic [31:0] csrw(int csr, int rs1);         return enc_i(csr, rs1, 1, 0, 7'h73);  endfunction
  function automatic logic [31:0] csrr(int rd, int csr);          return enc_i(csr, 0, 2, rd, 7'h73);   endfunction
  function automatic logic [31:0] lui (int rd, int imm20);
    logic [19:0] im = imm20;
    return {im, 5'(rd), 7'h37};
  endfunction
  function automatic logic [31:0] jal (int rd, int off);
    logic [20:0] o = off;
    return {o[20], o[10:1], o[11], o[19:12], 5'(rd), 7'h6F};
  endfunction
  function automatic logic [31:0] beq (int rs1, int rs2, int off);
    logic [12:0] o = off;
    return {o[12], o[10:5], 5'(rs2), 5'(rs1), 3'b000, o[4:1], o[11], 7'h63};
  endfunction
  function automatic logic [31:0] bne (int rs1, int rs2, int off);
    logic [12:0] o = off;
    return {o[12], o[10:5], 5'(rs2), 5'(rs1), 3'b001, o[4:1], o[11], 7'h63};
  endfunction
  function automatic logic [31:0] andi(int rd, int rs1, int imm); return enc_i(imm, rs1, 7, rd, 7'h13); endfunction
  function automatic logic [31:0] jalr(int rd, int rs1, int imm); return enc_i(imm, rs1, 0, rd, 7'h67); endfunction
  function automatic logic [31:0] add (int rd, int rs1, int rs2);
    return {7'h00, 5'(rs2), 5'(rs1), 3'b000, 5'(rd), 7'h33};
  endfunction
  localparam logic [31:0] MRET    = 32'h3020_0073;
  localparam logic [31:0] EBREAK  = 32'h0010_0073;
  localparam logic [31:0] ILLEGAL = 32'h0000_0000;

  task automatic fw_put(int addr, logic [31:0] insn);
    u_bootrom.mem[addr >> 2] = insn;
  endtask

  // TB bootrom (boot_addr=0 -> reset PC 0x80, trap vectors at 0x00..0x7C).
  // A minimal secure-boot ROM: the signed image is already in ISRAM (backdoor,
  // standing in for the flash copy). It starts the hardware verification,
  // waits, and jumps to ENTRY -- the jump is the handoff, hardware sets
  // boot_done. DSRAM switches inject bootrom bugs (Part F).
  localparam int A2 = 12, A3 = 13, A4 = 14, A5 = 15, T6 = 31;
  task automatic rom_load();
    for (int i = 0; i < 32; i++) fw_put(4*i, jal(0, 32'h100 - 4*i));
    fw_put(32'h80, lui (T0, 32'h20));            // t0 = DSRAM
    fw_put(32'h84, lw  (T2, T0, 4*W_ROM_CTRL1));
    fw_put(32'h88, beq (T2, 0, 12));
    fw_put(32'h8C, lui (T3, 32'h30));            // CTRL base
    fw_put(32'h90, sw  (T2, T3, 32'hC));         // BUG: CTRL1 (old boot_done_set)
    fw_put(32'h94, lw  (T2, T0, 4*W_BD));        // hand over at all?
    fw_put(32'h98, beq (T2, 0, 32'hE4 - 32'h98));
    fw_put(32'h9C, lui (T4, 32'h50));            // VERIFY base
    fw_put(32'hA0, lw  (T2, T0, 4*W_ROM_SKIPV));
    fw_put(32'hA4, bne (T2, 0, 32'hD4 - 32'hA4));// BUG: skip the verification
    fw_put(32'hA8, addi(T5, 0, 1));
    fw_put(32'hAC, sw  (T5, T4, 0));             // VERIFY_CTRL.start (ISRAM locks)
    fw_put(32'hB0, lw  (T2, T0, 4*W_ROM_ISRW));
    fw_put(32'hB4, beq (T2, 0, 12));
    fw_put(32'hB8, lui (T3, 32'h10));            // ISRAM base
    fw_put(32'hBC, sw  (T2, T3, 0));             // BUG: write ISRAM after start
    fw_put(32'hC0, lw  (T5, T4, 4));             // poll VERIFY_STATUS
    fw_put(32'hC4, andi(T6, T5, 2));             //   done?
    fw_put(32'hC8, beq (T6, 0, -8));
    fw_put(32'hCC, andi(T6, T5, 8));             //   verified?
    fw_put(32'hD0, beq (T6, 0, 32'hF4 - 32'hD0));
    fw_put(32'hD4, lw  (T6, T4, 32'hC));         // ENTRY
    fw_put(32'hD8, lw  (T2, T0, 4*W_ROM_JOFF));
    fw_put(32'hDC, add (T6, T6, T2));            // BUG if non-zero: wrong entry
    fw_put(32'hE0, jalr(0, T6, 0));              // handoff
    fw_put(32'hE4, addi(A1, 0, 0));              // spin (boot phase): heartbeat
    fw_put(32'hE8, addi(A1, A1, 1));
    fw_put(32'hEC, sw  (A1, T0, 4*W_HB));
    fw_put(32'hF0, jal (0, -8));
    fw_put(32'hF4, addi(T6, 0, -1));             // not verified: mark, park
    fw_put(32'hF8, sw  (T6, T0, 4*W_MARK));
    fw_put(32'hFC, jal (0, 0));
    // Trap handler: record mcause, count; a store fault (7) is skipped (F-ISRW),
    // anything else parks. Uses a2..a5 only (t-regs are live in the ROM flow).
    fw_put(32'h100, lui (A2, 32'h20));
    fw_put(32'h104, csrr(A3, CSR_MCAUSE_I));
    fw_put(32'h108, sw  (A3, A2, 4*W_MCAUSE));
    fw_put(32'h10C, lw  (A4, A2, 4*W_TRAPCNT));
    fw_put(32'h110, addi(A4, A4, 1));
    fw_put(32'h114, sw  (A4, A2, 4*W_TRAPCNT));
    fw_put(32'h118, addi(A5, 0, 7));
    fw_put(32'h11C, bne (A3, A5, 20));
    fw_put(32'h120, csrr(A5, CSR_MEPC_I));
    fw_put(32'h124, addi(A5, A5, 4));
    fw_put(32'h128, csrw(CSR_MEPC_I, A5));
    fw_put(32'h12C, MRET);
    fw_put(32'h130, jal (0, 0));
  endtask

  // Signed DIFT test firmware image (gen_signed_image.py)
  logic [31:0] fimg [FW_WORDS];
  initial $readmemh("verif/debugger/images/dift_fw_signed.mem", fimg);

  // Backdoor copy of the signed firmware into ISRAM (stands in for the
  // bootrom's flash copy). tamper = flip one bit of the signed code.
  task automatic isram_load_fw(bit tamper = 1'b0);
    foreach (fimg[i]) u_isram.mem[ISRAM_IDX0 + i] = fimg[i];
    if (tamper) u_isram.mem[ISRAM_IDX0 + 40] ^= 32'h0000_0100;
  endtask

  // TB bootrom switches
  task automatic rom_cfg(bit handoff, bit ctrl1 = 1'b0, bit skipv = 1'b0,
                         bit isrw = 1'b0, int joff = 0);
    u_dsram.mem[W_BD]        = handoff;
    u_dsram.mem[W_ROM_CTRL1] = ctrl1;
    u_dsram.mem[W_ROM_SKIPV] = skipv;
    u_dsram.mem[W_ROM_ISRW]  = isrw;
    u_dsram.mem[W_ROM_JOFF]  = joff;
  endtask

  initial begin
    #2;          // after the models' own initial blocks
    rom_load();
  end

  // ---------------------------------------------------------------------------
  // Scoreboard
  // ---------------------------------------------------------------------------
  int    errors, findings, checks;
  string finding_log[$];
  string scen = "INIT";

  task automatic pass(string msg);
    checks++;
    $display("[%0t] [PASS]    %s: %s", $time, scen, msg);
  endtask
  task automatic fail(string msg);
    checks++; errors++;
    $display("[%0t] [FAIL]    %s: %s", $time, scen, msg);
  endtask
  task automatic check(bit cond, string msg);
    if (cond) pass(msg); else fail(msg);
  endtask
  task automatic finding(string id, string msg);
    checks++; findings++;
    finding_log.push_back($sformatf("%s (%s): %s", id, scen, msg));
    $display("[%0t] [FINDING] %s %s: %s", $time, id, scen, msg);
  endtask
  task automatic obs(string msg);
    $display("[%0t] [OBS]     %s: %s", $time, scen, msg);
  endtask

  // ---------------------------------------------------------------------------
  // Monitors (reset per scenario / per test via mon_clear)
  // ---------------------------------------------------------------------------
  int mon_rom_exc;       // exceptions taken while in debug mode
  int mon_dift_dbg;      // DIFT exception pulses while in debug mode
  int mon_dift_run;      // DIFT exception pulses while running
  int mon_nmi;           // NMI entries
  int mon_exc_run;       // exceptions taken outside debug mode
  int mon_print;         // cap on DIFT event prints
  int mon_rom_fetch;     // BootROM fetches that reached the ROM after handoff / in recovery
  int mon_bd_rise;       // boot_done 0 -> 1 transitions
  int mon_entry_fetch;   // accepted (gate-approved) fetches at ENTRY
  bit mon_bd_early;      // boot_done rose without an ENTRY fetch in the cycle before
  logic nmi_q, bd_q, entry_acc_q;

  task automatic mon_clear();
    mon_rom_exc = 0; mon_dift_dbg = 0; mon_dift_run = 0; mon_nmi = 0; mon_print = 0;
    mon_exc_run = 0; mon_rom_fetch = 0; mon_bd_rise = 0; mon_entry_fetch = 0; mon_bd_early = 0;
  endtask

  // Boot-handoff monitors: boot_done may only rise in the cycle after an
  // accepted fetch at ENTRY; no BootROM fetch may reach the ROM once the
  // BootROM is not executable (after the handoff, or in recovery).
  always @(posedge clk_i) begin
    if (u_dut.boot_done === 1'b1 && bd_q === 1'b0) begin
      mon_bd_rise++;
      if (entry_acc_q !== 1'b1) mon_bd_early = 1;
    end
    // accepted = granted AND allowed by the fetch gate (a refused fetch is
    // granted too, then answered with an error)
    entry_acc_q <= u_dut.instr_req_int && u_dut.instr_gnt_int && u_dut.fw_fetch_ok &&
                   u_dut.instr_addr_int == ENTRY;
    if (u_dut.instr_req_int && u_dut.instr_gnt_int && u_dut.fw_fetch_ok && u_dut.instr_addr_int == ENTRY)
      mon_entry_fetch++;
    bd_q <= u_dut.boot_done;
    if ((u_dut.boot_done === 1'b1 || u_dut.recovery === 1'b1) &&
        bootrom_req && !u_dut.u_soc_addr_decode.bootrom_data_active)
      mon_rom_fetch++;
  end

  always @(posedge clk_i) begin
    // Debug-mode exception actually taken (controller redirects to
    // DmExceptionAddr). Counting fetches of the ROM's _exception address
    // would also count harmless sequential prefetches past 'j entry_loop'.
    if (`CTRL.pc_set_o && `CTRL.pc_mux_o == ibex_pkg::PC_EXC &&
        `CTRL.exc_pc_mux_o == ibex_pkg::EXC_PC_DBG_EXC)
      mon_rom_exc++;
    if (`CTRL.pc_set_o && `CTRL.pc_mux_o == ibex_pkg::PC_EXC &&
        `CTRL.exc_pc_mux_o == ibex_pkg::EXC_PC_EXC)
      mon_exc_run++;
    if (u_dut.irq_dift === 1'b1 || `CORE.ex_exception === 1'b1 || `CORE.pc_exception === 1'b1) begin
      if (`CTRL.debug_mode_q) mon_dift_dbg++; else mon_dift_run++;
      if (mon_print < 12) begin
        mon_print++;
        $display("[%0t]   DIFT-EVT dbg_mode=%0b pc_id=%08h ex=%0b pc=%0b ld=%0b lsu=%0b irq_nm=%0b",
                 $time, `CTRL.debug_mode_q, `CORE.pc_id, `CORE.ex_exception,
                 `CORE.pc_exception, `CORE.load_exception, `CORE.lsu_tag_err, u_dut.irq_dift);
      end
    end
    // Tainted load data returning to the core, and the tag-RF write it causes
    if (mon_print < 12 && u_dut.core_data_rvalid && u_dut.data_rdata_tag === 1'b1) begin
      mon_print++;
      $display("[%0t]   LOAD-TAG tag_idx=%0d shim->core=1 lsu_tag=%b rf_we_tag=%b rf_wdata_tag=%b waddr=x%0d",
               $time, u_dut.tag_rd_addr_q, `CORE.lsu_rdata_tag, `CORE.rf_we_tag_wb,
               `CORE.rf_wdata_tag_wb, `CORE.rf_waddr_wb);
    end
    nmi_q <= `CTRL.nmi_mode_q;
    if (`CTRL.nmi_mode_q === 1'b1 && nmi_q !== 1'b1) mon_nmi++;
  end

  // ---------------------------------------------------------------------------
  // DMI helpers
  // ---------------------------------------------------------------------------
  task automatic dm_w(dm_csr_e a, logic [31:0] d);
    u_jtag.dmi_write(7'(a), d);
  endtask
  task automatic dm_r(dm_csr_e a, output logic [31:0] d);
    u_jtag.dmi_read(7'(a), d);
  endtask

  function automatic logic [31:0] cmd_reg(logic [15:0] regno, bit write, bit transfer,
                                          bit postexec, logic [2:0] size = 3'd2);
    return {8'h00, 1'b0, size, 1'b0, postexec, transfer, write, regno};
  endfunction
  function automatic logic [15:0] gpr(int n); return 16'h1000 + 16'(n); endfunction

  // Poll abstractcs.busy; return cmderr and clear it (W1C) if non-zero.
  task automatic abs_wait(output logic [2:0] err, input int max_polls = 100);
    logic [31:0] acs;
    int n = 0;
    do begin
      dm_r(AbstractCS, acs);
      n++;
    end while (acs[12] && n < max_polls);
    err = acs[10:8];
    if (acs[12]) begin
      err = 3'h7;  // report "stuck busy" as Other
      obs($sformatf("abstractcs still busy after %0d polls (abstractcs=%08h)", n, acs));
    end
    if (acs[10:8] != 0) dm_w(AbstractCS, 32'h0000_0700);
  endtask

  task automatic abs_cmd(logic [31:0] cmd, output logic [2:0] err);
    dm_w(Command, cmd);
    abs_wait(err);
  endtask

  task automatic reg_read(logic [15:0] regno, output logic [31:0] d, output logic [2:0] err);
    dm_w(Data0, 32'hDEAD_0000);  // sentinel: detect whether data0 was written
    abs_cmd(cmd_reg(regno, 0, 1, 0), err);
    dm_r(Data0, d);
  endtask

  task automatic reg_write(logic [15:0] regno, logic [31:0] d, output logic [2:0] err);
    dm_w(Data0, d);
    abs_cmd(cmd_reg(regno, 1, 1, 0), err);
  endtask

  task automatic progbuf_run(logic [31:0] i0, logic [31:0] i1, output logic [2:0] err);
    dm_w(ProgBuf0, i0);
    dm_w(ProgBuf1, i1);
    abs_cmd(cmd_reg(16'h0, 0, 0, 1), err);  // postexec only
  endtask

  task automatic dmstatus(output logic [31:0] s);
    dm_r(DMStatus, s);
  endtask

  task automatic halt(output bit ok, input int max_polls = 60);
    logic [31:0] s;
    int n = 0;
    dm_w(DMControl, 32'h8000_0001);
    do begin
      dmstatus(s);
      n++;
    end while (!s[9] && n < max_polls);
    ok = s[9];
    dm_w(DMControl, 32'h0000_0001);  // drop haltreq
  endtask

  task automatic resume(output bit ok, input int max_polls = 60);
    logic [31:0] s;
    int n = 0;
    dm_w(DMControl, 32'h4000_0001);
    do begin
      dmstatus(s);
      n++;
    end while (!s[17] && n < max_polls);  // allresumeack
    ok = s[17];
    dm_w(DMControl, 32'h0000_0001);
  endtask

  // Wait until the firmware heartbeat advances by n (running core).
  task automatic heartbeat(output bit ok, input int n = 3, input int max_cycles = 4000);
    logic [31:0] start = u_dsram.mem[W_HB];
    int c = 0;
    while (u_dsram.mem[W_HB] - start < n && c < max_cycles) begin
      @(posedge clk_i);
      c++;
    end
    ok = (u_dsram.mem[W_HB] - start >= n);
  endtask

  function automatic logic [31:0] next_pc(logic [31:0] pc);
    return (pc == PC_LOOP2) ? PC_LOOP0 : pc + 4;
  endfunction

  // ---------------------------------------------------------------------------
  // Scenario boot: hold core in ndmreset, program config + taint, release.
  // taint = {s1, t1, a0, s0} -> tag_mem[11,10,9,8]
  // ---------------------------------------------------------------------------
  // handoff=1: the TB bootrom verifies the signed firmware and jumps to it
  // (real secure boot, hardware boot_done). handoff=0: it spins in the ROM,
  // i.e. the SoC stays in the boot phase (boot_done=0).
  task automatic boot(string name, logic [31:0] tpr, logic [31:0] tcr,
                      logic [3:0] taint, bit en, output bit ok,
                      input bit handoff = 1'b1);
    scen = name;
    $display("\n==================== %s ====================", name);
    $display("  TPR=%08h TCR=%08h taint{s1,t1,a0,s0}=%04b handoff=%0b", tpr, tcr, taint, handoff);
    dm_w(DMControl, 32'h0000_0003);  // dmactive + ndmreset: core held in reset
    isram_load_fw();                 // "flash copy" of the signed firmware
    rom_cfg(handoff);
    u_dsram.mem[W_MARK]    = 0;
    u_dsram.mem[W_TPR]     = tpr;
    u_dsram.mem[W_TCR]     = tcr;
    u_dsram.mem[W_S0]      = SEC_S0;
    u_dsram.mem[W_A0]      = SEC_A0;
    u_dsram.mem[W_T1]      = SEC_T1;
    u_dsram.mem[W_S1]      = VAL_S1;
    u_dsram.mem[W_HB]      = 0;
    u_dsram.mem[W_MCAUSE]  = 0;
    u_dsram.mem[W_TRAPCNT] = 0;
    for (int i = 0; i < 1024; i++) u_dut.tag_mem[i] = 1'b0;
    u_dut.tag_mem[W_S0] = taint[0];
    u_dut.tag_mem[W_A0] = taint[1];
    u_dut.tag_mem[W_T1] = taint[2];
    u_dut.tag_mem[W_S1] = taint[3];
    dm_w(DMControl, 32'h1000_0001);  // release ndmreset, ackhavereset
    dm_w(AbstractCS, 32'h0000_0700); // clear any stale cmderr
    mon_clear();
    heartbeat(ok, 3, 1_500_000);     // includes one hardware verification
    if (!ok) begin
      fail("firmware did not start after ndmreset (no heartbeat)");
      return;
    end
    check(u_dut.boot_done === handoff,
          $sformatf("boot_done=%0b after %s", u_dut.boot_done,
                    handoff ? "secure boot + hardware handoff" : "boot phase (bootrom spinning)"));
    if (!handoff) return;
    check(mon_bd_rise == 1 && !mon_bd_early && mon_entry_fetch >= 1,
          "hardware set boot_done exactly at the first verified fetch at ENTRY");
    // Sanity: DIFT propagated the injected taint into GPR tags
    begin
      logic [3:0] exp = (en && tpr[15]) ? taint : 4'b0;
      logic [3:0] got = {`TAGRF[S1], `TAGRF[T1], `TAGRF[A0], `TAGRF[S0]};
      check(got === exp, $sformatf("boot GPR tags {s1,t1,a0,s0}=%04b (expected %04b)", got, exp));
      check(`CSRS.tcr_q === tcr && `CSRS.tpr_q === tpr,
            $sformatf("firmware programmed TCR=%08h TPR=%08h", `CSRS.tcr_q, `CSRS.tpr_q));
    end
  endtask

  // ---------------------------------------------------------------------------
  // Power-on reset (whole SoC incl. DM/DTM), optional strap / faulty bootrom
  // ---------------------------------------------------------------------------
  // faulty_rom: every bootrom word is an illegal instruction. Otherwise the
  // TB bootrom with the given switches; load_fw copies the signed firmware
  // into ISRAM first (tamper: with one bit flipped).
  task automatic por(string name, bit strap, bit faulty_rom, bit load_fw = 1'b0,
                     bit handoff = 1'b1, bit ctrl1 = 1'b0, bit skipv = 1'b0,
                     bit isrw = 1'b0, int joff = 0, bit tamper = 1'b0);
    scen = name;
    $display("\n==================== %s ====================", name);
    $display("  power-on reset: boot_mode strap=%0b bootrom=%s", strap,
             faulty_rom ? "FAULTY (all illegal)" :
             $sformatf("TB rom handoff=%0b ctrl1=%0b skipv=%0b isrw=%0b joff=%0d fw=%s",
                       handoff, ctrl1, skipv, isrw, joff, !load_fw ? "(ISRAM as is)" : tamper ? "TAMPERED" : "signed"));
    rst_ni = 1'b0;
    boot_mode = strap;
    if (faulty_rom) for (int a = 0; a < 32'h200; a += 4) fw_put(a, ILLEGAL);
    else            rom_load();
    if (load_fw) isram_load_fw(tamper);
    rom_cfg(handoff, ctrl1, skipv, isrw, joff);
    u_dsram.mem[W_TPR]  = TPR_OR;
    u_dsram.mem[W_TCR]  = TCR_NONE;
    u_dsram.mem[W_MARK] = 0;
    u_dsram.mem[W_HB]   = 0;
    u_dsram.mem[W_MCAUSE]  = 0;
    u_dsram.mem[W_TRAPCNT] = 0;
    repeat (10) @(posedge clk_i);
    mon_clear();
    rst_ni = 1'b1;
    u_jtag.tap_reset();
    dm_w(DMControl, 32'h0000_0001);
  endtask

  task automatic wait_halted(output bit ok, input int max_polls = 60);
    logic [31:0] s;
    int n = 0;
    do begin
      dmstatus(s);
      n++;
    end while (!s[9] && n < max_polls);
    ok = s[9];
  endtask

  // Wait (cycle-accurate, no JTAG traffic) for the boot watchdog to force
  // recovery, then for the core to be halted.
  task automatic wait_recovery(output bit ok, input int max_cycles = WDT_CYCLES + 1_600_000);
    int c = 0;
    while (u_dut.recovery !== 1'b1 && c < max_cycles) begin @(posedge clk_i); c++; end
    obs($sformatf("recovery after %0d cycles (watchdog %0d)", c, WDT_CYCLES));
    wait_halted(ok);
    ok = ok && (u_dut.recovery === 1'b1);
  endtask

  // Read a SoC word through the program buffer (t3 = address, result in s1)
  task automatic dbg_lw(logic [31:0] addr, output logic [31:0] v, output logic [2:0] e);
    logic [2:0] e2;
    reg_write(gpr(T3), addr, e2);
    progbuf_run(lw(S1, T3, 0), EBREAK, e);
    v = `GPR[S1];
  endtask

  // Signed recovery image (verif/debugger/images/gen_signed_image.py): header
  // [sha_len, R, S] + code that marks DSRAM word W_MARK and heartbeats. The
  // matching TEST-ONLY public key is forced into the OTP model (a real part
  // has it fused at manufacturing).
  `define SB u_dut.g_secure_boot.u_secure_boot
  logic [31:0]  rimg [IMG_WORDS];
  logic [31:0]  otp_key_w [8];
  logic [255:0] otp_key;
  initial begin
    $readmemh("verif/debugger/images/recovery_signed.mem", rimg);
    $readmemh("verif/debugger/images/otp_pubkey.mem", otp_key_w);
    foreach (otp_key_w[i]) otp_key[32*i +: 32] = otp_key_w[i];
`ifdef VERILATOR
    #2 `SB.u_otp.otp_mem = otp_key;   // (no force on always_ff variables in this simulator)
`else
    force `SB.u_otp.otp_mem = otp_key;
`endif
  end

  // Write one ISRAM word through the debugger (allowed only in recovery)
  task automatic isram_poke(int idx, logic [31:0] val, output logic [2:0] e);
    logic [2:0] e2;
    reg_write(gpr(T3), ISRAM_BASE + 4*idx, e2);
    reg_write(gpr(S1), val, e2);
    progbuf_run(sw(S1, T3, 0), EBREAK, e);
  endtask

  // Debugger starts a hardware verification (VERIFY_CTRL.start) and, once
  // the engine finishes, reads VERIFY_STATUS back the way software would.
  task automatic sb_verify(output logic [31:0] st, output logic [2:0] e);
    logic [2:0] e2;
    int c = 0;
    reg_write(gpr(T3), SB_BASE, e2);
    reg_write(gpr(S1), 32'h1, e2);
    progbuf_run(sw(S1, T3, 0), EBREAK, e);
    while (`SB.state_q != 0 && c < 1_500_000) begin @(posedge clk_i); c++; end
    progbuf_run(lw(S1, T3, 32'h4), EBREAK, e2);
    st = `GPR[S1];
    obs($sformatf("verification took %0d cycles, VERIFY_STATUS=%05b (err verified valid done busy)", c, st[4:0]));
  endtask

  // Load rimg into ISRAM through the debugger (execution-based, as OpenOCD
  // does without SBA): t3 = address; per word: write s1 + postexec
  // "sw s1,0(t3); addi t3,t3,4; ebreak". Returns number of failed words.
  task automatic load_image(output int nerr);
    logic [2:0] e;
    nerr = 0;
    reg_write(gpr(T3), ISRAM_BASE, e);
    dm_w(ProgBuf0, sw  (S1, T3, 0));
    dm_w(ProgBuf1, addi(T3, T3, 4));
    dm_w(ProgBuf2, EBREAK);
    foreach (rimg[i]) begin
      dm_w(Data0, rimg[i]);
      abs_cmd(cmd_reg(gpr(S1), 1, 1, 1), e);
      if (e != 0) nerr++;
    end
  endtask

  function automatic bit image_in_isram();
    foreach (rimg[i]) if (u_isram.mem[ISRAM_IDX0 + i] !== rimg[i]) return 0;
    return 1;
  endfunction

  // ---------------------------------------------------------------------------
  // Main sequence
  // ---------------------------------------------------------------------------
  logic [31:0] r, r2, dpc0, dpc1, dcsr, pat;
  logic [31:0] pats [4];
  int          npoll;
  logic [2:0]  err;
  bit          ok, ok2;

  initial begin
    $timeformat(-9, 0, " ns", 10);
    errors = 0; findings = 0; checks = 0;
    u_jtag.tck = 1'b0; u_jtag.tms = 1'b1; u_jtag.tdi = 1'b0; u_jtag.trst_n = 1'b0;
    wait (rst_ni === 1'b1);
    repeat (5) @(posedge clk_i);

    // =========================================================================
    // PART A -- generic debug behaviour (DIFT on, no taint, no checks)
    // =========================================================================
    scen = "A-DTM";
    u_jtag.tap_reset();
    u_jtag.read_idcode(r);
    check(r == 32'h0000_0DB3, $sformatf("IDCODE=%08h", r));
    u_jtag.read_dtmcs(r);
    check(r[3:0] == 4'd1 && r[9:4] == 6'd7, $sformatf("DTMCS version=%0d abits=%0d", r[3:0], r[9:4]));

    dm_w(DMControl, 32'h0000_0001);
    dm_r(DMControl, r);
    check(r[0], $sformatf("dmactive reads back 1 (dmcontrol=%08h)", r));
    dmstatus(r);
    check(r[3:0] == 4'd2 && r[7], $sformatf("dmstatus version=2 authenticated=1 (dmstatus=%08h)", r));
    dm_r(Hartinfo, r);
    check(r[23:20] == 4'd2 && r[16] && r[15:12] == 4'd2 && r[11:0] == 12'h380,
          $sformatf("hartinfo nscratch=2 dataaccess=1 datasize=2 dataaddr=380 (%08h)", r));
    dm_r(AbstractCS, r);
    check(r[28:24] == 5'd8 && r[3:0] == 4'd2,
          $sformatf("abstractcs progbufsize=8 datacount=2 (%08h)", r));

    boot("A-BASE", TPR_OR, TCR_NONE, 4'b0000, 1'b1, ok);
    dmstatus(r);
    check(r[11] && !r[9], $sformatf("allrunning, not halted (dmstatus=%08h)", r));
    check(r[19], $sformatf("allhavereset set after ndmreset (dmstatus=%08h)", r));

    // --- halt ----------------------------------------------------------------
    halt(ok);
    check(ok, "haltreq -> allhalted");
    r = u_dsram.mem[W_HB];
    repeat (200) @(posedge clk_i);
    check(u_dsram.mem[W_HB] == r, "heartbeat frozen while halted");
    reg_read(CSR_DCSR, dcsr, err);
    check(err == 0 && dcsr[8:6] == dm::CauseRequest && dcsr[1:0] == 2'b11,
          $sformatf("dcsr cause=haltreq prv=M (dcsr=%08h err=%0d)", dcsr, err));
    reg_read(CSR_DPC, dpc0, err);
    check(err == 0 && dpc0 inside {PC_LOOP0, PC_LOOP1, PC_LOOP2},
          $sformatf("dpc inside firmware loop (dpc=%08h)", dpc0));

    // haltreq while already halted is harmless
    halt(ok);
    reg_read(gpr(S1), r, err);
    check(ok && err == 0 && r == VAL_S1, $sformatf("re-halt while halted; s1 still readable (%08h)", r));

    // --- GPR access ----------------------------------------------------------
    pats = '{32'h0, 32'hFFFF_FFFF, 32'hA5A5_5A5A, 32'h8000_0001};
    foreach (pats[i]) begin
      pat = pats[i];
      reg_write(gpr(S1), pat, err);
      reg_read(gpr(S1), r, err);
      check(err == 0 && r == pat && `GPR[S1] == pat,
            $sformatf("s1 write/read %08h (dmi=%08h rf=%08h)", pat, r, `GPR[S1]));
    end
    reg_write(gpr(0), 32'h1234_5678, err);
    reg_read(gpr(0), r, err);
    check(r == 0, $sformatf("x0 stays zero after debugger write (%08h)", r));
    // s0/a0 are the ROM's scratch regs: DM routes them through dscratch0/1
    reg_write(gpr(S0), 32'h0DD5_0008, err);
    reg_write(gpr(A0), 32'h0DD5_000A, err);
    reg_read(gpr(S0), r, err);
    reg_read(gpr(A0), r2, err);
    check(r == 32'h0DD5_0008 && r2 == 32'h0DD5_000A,
          $sformatf("s0/a0 (dscratch-backed) write/read (s0=%08h a0=%08h)", r, r2));
    // restore s1 for later checks
    reg_write(gpr(S1), VAL_S1, err);

    // --- CSR access ----------------------------------------------------------
    reg_write(CSR_MSCRATCH, 32'hC0FF_EE00, err);
    reg_read(CSR_MSCRATCH, r, err);
    check(err == 0 && r == 32'hC0FF_EE00, $sformatf("mscratch write/read (%08h)", r));
    reg_read(CSR_BOGUS, r, err);
    check(err == 3'd3, $sformatf("read of unimplemented CSR 0x7FF -> cmderr=exception (err=%0d)", err));

    // --- unsupported / malformed commands -------------------------------------
    abs_cmd(cmd_reg(gpr(S1), 0, 1, 0, 3'd3), err);
    check(err == 3'd2, $sformatf("aarsize=64 on RV32 -> cmderr=notsupported (err=%0d)", err));
    abs_cmd(32'h0100_0000, err);  // cmdtype=1 (quick access)
    check(err == 3'd2, $sformatf("quick-access command -> cmderr=notsupported (err=%0d)", err));
    abs_cmd(cmd_reg(gpr(S1), 0, 0, 0), err);  // transfer=0, postexec=0
    // Spec: a no-op. riscv-dbg's dm_mem leaves abstract_cmd[0] = illegal()
    // for this case, so it reports cmderr=exception (harmless, OpenOCD never
    // issues it). Record rather than fail.
    obs($sformatf("no-op access-register command -> cmderr=%0d (riscv-dbg returns 3; spec says 0)", err));

    // --- program buffer ---------------------------------------------------------
    progbuf_run(addi(S1, S1, 1), EBREAK, err);
    reg_read(gpr(S1), r, err);
    check(r == VAL_S1 + 1, $sformatf("progbuf addi s1,s1,1 executed (s1=%08h)", r));
    reg_write(gpr(S1), VAL_S1, err);
    progbuf_run(ILLEGAL, EBREAK, err);
    check(err == 3'd3, $sformatf("illegal insn in progbuf -> cmderr=exception (err=%0d)", err));
    dmstatus(r);
    reg_read(CSR_DPC, dpc1, err);
    check(r[9] && dpc1 == dpc0, $sformatf("hart still halted, dpc unchanged after progbuf fault (dpc=%08h)", dpc1));
    // transfer + postexec: write s1 then run progbuf on it
    dm_w(Data0, 32'h0000_0100);
    dm_w(ProgBuf0, addi(S1, S1, 2));
    dm_w(ProgBuf1, EBREAK);
    abs_cmd(cmd_reg(gpr(S1), 1, 1, 1), err);
    reg_read(gpr(S1), r, err);
    check(r == 32'h102, $sformatf("transfer+postexec (s1=%08h, expect 102)", r));

    // --- autoexecdata -----------------------------------------------------------
    reg_write(gpr(S1), 32'h1111_1111, err);   // last command = write s1
    dm_w(AbstractAuto, 32'h0000_0001);        // autoexec on data0
    dm_w(Data0, 32'h2222_2222);               // re-executes the write
    abs_wait(err);
    dm_w(AbstractAuto, 32'h0);
    check(`GPR[S1] == 32'h2222_2222, $sformatf("autoexecdata re-ran write (s1=%08h)", `GPR[S1]));
    reg_write(gpr(S1), VAL_S1, err);

    // --- single step --------------------------------------------------------------
    reg_read(CSR_DPC, dpc0, err);
    reg_read(CSR_DCSR, dcsr, err);
    reg_write(CSR_DCSR, dcsr | 32'h4, err);   // step=1
    resume(ok);
    npoll = 0;
    do begin dmstatus(r); npoll++; end while (!r[9] && npoll < 60);
    reg_read(CSR_DPC, dpc1, err);
    reg_read(CSR_DCSR, dcsr, err);
    check(r[9] && dpc1 == next_pc(dpc0) && dcsr[8:6] == dm::CauseSingleStep,
          $sformatf("single-step %08h -> %08h (expect %08h), cause=%0d",
                    dpc0, dpc1, next_pc(dpc0), dcsr[8:6]));
    reg_write(CSR_DCSR, dcsr & ~32'h4, err);  // step=0

    // --- resume -----------------------------------------------------------------
    resume(ok);
    check(ok, "resumereq -> allresumeack");
    heartbeat(ok);
    dmstatus(r);
    check(ok && r[11], $sformatf("hart running after resume (dmstatus=%08h)", r));
    check(`GPR[S0] == 32'h0DD5_0008 && `GPR[A0] == 32'h0DD5_000A,
          "debugger-written s0/a0 restored into GPRs on resume");

    // --- command while running ------------------------------------------------------
    reg_read(gpr(S1), r, err);
    check(err == 3'd4, $sformatf("abstract command while running -> cmderr=haltresume (err=%0d)", err));

    // --- hartsel of nonexistent hart -------------------------------------------------
    // hartsel is WARL: debuggers discover HARTSELLEN by writing all ones and
    // reading back. NrHarts=1 -> HARTSELLEN=0 -> must read back 0.
    dm_w(DMControl, 32'h03FF_FFC1);           // hartsello/hi = all ones
    dm_r(DMControl, r);
    check(r[25:6] == 20'h0, $sformatf("hartsel WARL reads back 0 for 1 hart (dmcontrol=%08h)", r));
    dmstatus(r);
    check(!r[15] && !r[14], $sformatf("hart 0 selected, not nonexistent (dmstatus=%08h)", r));
    dm_w(DMControl, 32'h0000_0001);

    // --- dmactive toggle (DM reset) ------------------------------------------------
    dm_w(DMControl, 32'h0000_0000);
    dm_r(DMControl, r);
    check(r == 0, $sformatf("dmactive=0 resets dmcontrol (%08h)", r));
    dm_w(DMControl, 32'h0000_0001);
    halt(ok);
    check(ok, "DM usable again after dmactive toggle (halt ok)");
    resume(ok);

    // =========================================================================
    // PART B -- DIFT interaction scenarios
    // =========================================================================

    // -------------------------------------------------------------------------
    // S1: s0, a0, t1 tainted; no checks -> pure tag bookkeeping
    // -------------------------------------------------------------------------
    boot("S1-TAGS", TPR_OR, TCR_NONE, 4'b0111, 1'b1, ok);
    u_dut.tag_mem[TAG_HALTED] = 1'b1;   // taint DSRAM word 0x20100
    halt(ok);
    check(ok, "halt with tainted s0/a0/t1 and no checks");
    if (u_dut.tag_mem[TAG_HALTED] !== 1'b1)
      finding("D07a", $sformatf("debug-ROM HALTED store (0x1A110100) rewrote shadow tag of DSRAM 0x20100: 1 -> %b (tag RAM aliases by addr[11:2])",
                                u_dut.tag_mem[TAG_HALTED]));
    else pass("HALTED store did not disturb DSRAM tag alias");

    u_dut.tag_mem[TAG_DATA0] = 1'b0;
    reg_read(gpr(T1), r, err);
    check(err == 0 && r == SEC_T1, $sformatf("tainted t1 readable with checks off (%08h)", r));
    if (u_dut.tag_mem[TAG_DATA0] === 1'b1)
      finding("D07b", "abstract read of tainted t1 copied its taint into tag_mem[0xE0] = shadow tag of DSRAM 0x20380 (data0 aliases a real DSRAM word)");
    check(`TAGRF[T1] === 1'b1, "t1 tag preserved by an abstract read");

    u_dut.tag_mem[TAG_DATA0] = 1'b0;
    reg_write(gpr(T1), 32'h0000_1234, err);
    check(err == 0 && `GPR[T1] == 32'h1234, "debugger write of t1 lands in the RF");
    if (`TAGRF[T1] !== 1'b1)
      finding("D06a", $sformatf("debugger write to tainted t1 CLEARED its tag (now %b): the value is loaded from DM data0 (untagged, reads tag 0), so debugger-written registers are clean -- open decision: tag them untrusted",
                                `TAGRF[T1]));
    u_dut.tag_mem[TAG_DATA0] = 1'b1;
    reg_write(gpr(S1), 32'h0000_5678, err);
    if (`TAGRF[S1] === 1'b1)
      finding("D06b", "debugger write to clean s1 TAINTED it because tag_mem[0xE0] (DSRAM 0x20380) happened to be tainted -- tag of debugger-written data is an alias artefact");
    else obs($sformatf("s1 tag after debugger write with tag_mem[0xE0]=1: %b", `TAGRF[S1]));
    reg_write(gpr(S1), VAL_S1, err);

    resume(ok);
    check(ok, "resume with tainted state");
    heartbeat(ok);
    check(ok, "firmware continues after resume");
    if (`TAGRF[S0] !== 1'b1)
      finding("D08a", $sformatf("s0 lost its taint across halt/resume (tag=%b): debug ROM uses s0 as scratch (add/lbu) and restores the VALUE from dscratch0, which has no tag",
                                `TAGRF[S0]));
    else pass("s0 taint survives halt/resume");
    if (`TAGRF[A0] !== 1'b1)
      finding("D08b", $sformatf("a0 lost its taint across halt/resume (tag=%b): debug ROM recomputes a0 (auipc/srli/slli) and restores the VALUE from dscratch1 only",
                                `TAGRF[A0]));
    else pass("a0 taint survives halt/resume");
    check(`GPR[S0] == SEC_S0 && `GPR[A0] == SEC_A0, "s0/a0 values restored correctly");

    // -------------------------------------------------------------------------
    // S2: t1 tainted, full TCR policy
    // -------------------------------------------------------------------------
    boot("S2-POLICY", TPR_OR, TCR_FULL, 4'b0100, 1'b1, ok);
    halt(ok);
    check(ok, "halt with DIFT policy armed (no taint on ROM path)");

    // TCR/TPR lockout in debug mode (deliberate RTL change in cs_registers)
    reg_read(CSR_TCR, r, err);
    check(err == 3'd3 && r != TCR_FULL, $sformatf("abstract read TCR -> cmderr=exception, value hidden (err=%0d data0=%08h)", err, r));
    reg_read(CSR_TPR, r, err);
    check(err == 3'd3 && r != TPR_OR, $sformatf("abstract read TPR -> cmderr=exception, value hidden (err=%0d data0=%08h)", err, r));
    reg_write(CSR_TCR, 32'h0, err);
    check(err == 3'd3 && `CSRS.tcr_q == TCR_FULL, $sformatf("abstract write TCR=0 rejected (err=%0d tcr=%08h)", err, `CSRS.tcr_q));
    reg_write(CSR_TPR, 32'h0, err);
    check(err == 3'd3 && `CSRS.tpr_q == TPR_OR, $sformatf("abstract write TPR=0 rejected (err=%0d tpr=%08h)", err, `CSRS.tpr_q));
    progbuf_run(csrw(CSR_TCR, 0), EBREAK, err);
    check(err == 3'd3 && `CSRS.tcr_q == TCR_FULL, $sformatf("progbuf csrw TCR,x0 rejected (err=%0d tcr=%08h)", err, `CSRS.tcr_q));

    // Clean register under policy
    reg_read(gpr(S1), r, err);
    check(err == 0 && r == VAL_S1, $sformatf("clean s1 readable under policy (%08h err=%0d)", r, err));

    // Tainted register under policy
    mon_clear();
    reg_read(gpr(T1), r, err);
    obs($sformatf("abstract READ of tainted t1 under store-source check: cmderr=%0d data0=%08h (%s), DIFT events in debug=%0d",
                  err, r, (r == SEC_T1) ? "SECRET VISIBLE" : "not leaked", mon_dift_dbg));
    if (r == SEC_T1)
      finding("D03", $sformatf("tainted t1 reached DM data0 and was read out over JTAG (cmderr=%0d): the DIFT store check fires only on the store RESPONSE, after the tainted word is already written", err));
    mon_clear();
    reg_write(gpr(T1), 32'h0000_7777, err);
    obs($sformatf("abstract WRITE of tainted t1: cmderr=%0d rf=%08h tag=%b", err, `GPR[T1], `TAGRF[T1]));

    // Restore t1 taint for the progbuf test (write does not propagate taint)
    boot("S2-POLICY", TPR_OR, TCR_FULL, 4'b0100, 1'b1, ok);
    halt(ok);
    mon_clear();
    progbuf_run(addi(S1, T1, 0), EBREAK, err);  // integer op with tainted source
    obs($sformatf("progbuf 'addi s1,t1,0' (tainted src, INTEGER_CHECK_S1): cmderr=%0d s1=%08h DIFT-events dbg=%0d",
                  err, `GPR[S1], mon_dift_dbg));
    check(err == 3'd3, "DIFT violation inside program buffer reported as cmderr=exception");
    check(`GPR[S1] == VAL_S1, "violating progbuf instruction did not retire");
    dmstatus(r);
    reg_read(gpr(S1), r2, err);
    check(r[9] && err == 0 && r2 == VAL_S1, "hart still halted and DM usable after DIFT fault");

    mon_clear();
    resume(ok);
    heartbeat(ok, 3, 2000);
    check(ok, "firmware runs after resume following a debug-mode DIFT fault");
    if (mon_nmi != 0 || u_dsram.mem[W_TRAPCNT] != 0)
      finding("D09", $sformatf("DIFT violation raised in debug mode fired later as NMI/trap in firmware (nmi=%0d traps=%0d mcause=%08h)",
                               mon_nmi, u_dsram.mem[W_TRAPCNT], u_dsram.mem[W_MCAUSE]));
    else pass("no deferred DIFT NMI/trap leaks into firmware after resume");

    // -------------------------------------------------------------------------
    // S5: DIFT has no off switch -- the dift_en_i pin was removed from the
    // SoC (anyone with the board could have tied it low); the core input is
    // tied on inside basic_soc_top.
    // -------------------------------------------------------------------------
    scen = "S5-NO-OFF-SWITCH";
    check(`CORE.dift_en_i === 1'b1, "core DIFT enable tied on inside the SoC (no external dift_en_i pin)");

    // -------------------------------------------------------------------------
    // S3: tainted s0 + full policy -> the debug ROM itself computes on s0
    // -------------------------------------------------------------------------
    boot("S3-TAINTED-S0", TPR_OR, TCR_FULL, 4'b0001, 1'b1, ok);
    mon_clear();
    halt(ok, 40);
    obs($sformatf("halt: allhalted=%0b, debug-ROM exception entries=%0d, DIFT events dbg=%0d",
                  ok, mon_rom_exc, mon_dift_dbg));
    if (ok) begin
      reg_read(gpr(S1), r, err);
      obs($sformatf("abstract read of clean s1 while halted: cmderr=%0d data0=%08h", err, r));
      resume(ok2, 40);
      obs($sformatf("resume: allresumeack=%0b", ok2));
    end
    if (!ok || mon_rom_exc != 0)
      finding("D10", $sformatf("tainted s0 + TCR policy breaks debug entry: debug ROM (add s0,s0,a0 / andi / bnez on s0) faults, hart livelocks in ROM exception loop (allhalted=%0b, rom exceptions=%0d)",
                               ok, mon_rom_exc));
    dm_w(DMControl, 32'h0000_0001);

    // -------------------------------------------------------------------------
    // S4: DM FLAGS register tag alias (DSRAM 0x20400) tainted
    // -------------------------------------------------------------------------
    boot("S4-FLAGS-ALIAS", TPR_OR, TCR_FULL, 4'b0000, 1'b1, ok);
    u_dut.tag_mem[TAG_FLAGS] = 1'b1;
    mon_clear();
    halt(ok, 40);
    obs($sformatf("halt: allhalted=%0b, debug-ROM exception entries=%0d, DIFT events dbg=%0d",
                  ok, mon_rom_exc, mon_dift_dbg));
    if (ok) begin
      reg_read(gpr(S1), r, err);
      obs($sformatf("abstract read of clean s1: cmderr=%0d data0=%08h", err, r));
      resume(ok2, 40);
      obs($sformatf("resume: allresumeack=%0b", ok2));
    end
    if (!ok || mon_rom_exc != 0)
      finding("D11", $sformatf("an unrelated tainted DSRAM word (0x20400) aliases the DM FLAGS tag: ROM 'lbu s0,FLAGS' loads taint, ROM branch/logic checks fault -> debugger denial of service (allhalted=%0b, rom exceptions=%0d)",
                               ok, mon_rom_exc));
    dm_w(DMControl, 32'h0000_0001);

    // -------------------------------------------------------------------------
    // S6: uninitialised (X) tag on the FLAGS alias -- tag_mem has no reset
    // -------------------------------------------------------------------------
    boot("S6-X-TAG", TPR_OR, TCR_FULL, 4'b0000, 1'b1, ok);
    u_dut.tag_mem[TAG_FLAGS] = 1'bx;
    mon_clear();
    halt(ok, 40);
    if (ok) resume(ok2, 40);
    if (!ok || !ok2 || mon_rom_exc != 0)
      finding("D13", $sformatf("unreset shadow tag RAM (X) on a DM alias breaks debug entry/exit in simulation (allhalted=%0b resumeack=%0b rom exceptions=%0d); on silicon this is a random 0/1 = S4 at power-up",
                               ok, ok2, mon_rom_exc));
    else pass("X tag on FLAGS alias tolerated");
    dm_w(DMControl, 32'h0000_0001);

    // =========================================================================
    // PART D -- SoC debug access policy
    // =========================================================================

    // D-TAG: debugger stores into DSRAM are tagged untrusted
    boot("D-TAG", TPR_OR, TCR_NONE, 4'b0000, 1'b1, ok);
    check(u_dut.tag_mem[W_HB] === 1'b0, "firmware (non-debug) store into DSRAM is clean");
    halt(ok);
    reg_write(gpr(T3), DSRAM_BASE + 4*W_DBGWR, err);
    reg_write(gpr(S1), 32'h0BAD_DA7A, err);
    check(`TAGRF[S1] === 1'b0, "(info) debugger-written GPR is clean: register tags are not debugger-tainted");
    progbuf_run(sw(S1, T3, 0), EBREAK, err);
    check(err == 0 && u_dsram.mem[W_DBGWR] == 32'h0BAD_DA7A,
          $sformatf("debugger store into DSRAM lands (err=%0d mem=%08h)", err, u_dsram.mem[W_DBGWR]));
    check(u_dut.tag_mem[W_DBGWR] === 1'b1, "debugger store into DSRAM tagged UNTRUSTED (tag=1)");
    resume(ok);
    heartbeat(ok);
    check(ok && u_dut.tag_mem[W_HB] === 1'b0, "firmware stores after resume are clean again");

    // D-PRIV: boot phase (boot_done=0, bootrom spinning), halted core must not
    // write SoC CSRs or ISRAM
    boot("D-PRIV", TPR_OR, TCR_NONE, 4'b0000, 1'b1, ok, 1'b0);
    halt(ok);
    check(ok, "halt during boot phase (boot_done=0)");
    // The BootROM stays executable for the debugger during a normal boot
    reg_read(CSR_DPC, dpc0, err);
    reg_read(CSR_DCSR, dcsr, err);
    reg_write(CSR_DCSR, dcsr | 32'h4, err);   // step=1
    resume(ok);
    npoll = 0;
    do begin dmstatus(r); npoll++; end while (!r[9] && npoll < 60);
    reg_read(CSR_DPC, dpc1, err);
    reg_read(CSR_DCSR, dcsr, err);
    check(r[9] && dpc0 inside {[ROM_LOOP0:ROM_LOOP2]} && dpc1 == ((dpc0 == ROM_LOOP2) ? ROM_LOOP0 : dpc0 + 4),
          $sformatf("single-step inside the bootrom during boot: %08h -> %08h (BootROM executable in boot phase)", dpc0, dpc1));
    reg_write(CSR_DCSR, dcsr & ~32'h4, err);
    reg_write(gpr(T3), CTRL_BASE, err);
    reg_write(gpr(S1), 32'h1, err);
    progbuf_run(sw(S1, T3, 32'h0), EBREAK, err);          // CTRL0.isram_lock
    check(err == 3'd3 && u_dut.isram_lock == 1'b0,
          $sformatf("debugger write to CTRL0 (isram_lock) denied (err=%0d lock=%0b)", err, u_dut.isram_lock));
    progbuf_run(sw(S1, T3, 32'hC), EBREAK, err);          // CTRL1.boot_done_set
    check(err == 3'd3 && u_dut.boot_done == 1'b0,
          $sformatf("debugger write to CTRL1 (boot_done) denied (err=%0d boot_done=%0b)", err, u_dut.boot_done));
    reg_write(CSR_TCR, 32'h0, err);
    check(err == 3'd3, $sformatf("debugger write of TCR denied in boot phase (err=%0d)", err));
    reg_write(gpr(S1), 32'hFFFF_FFFF, err);
    progbuf_run(lw(S1, T3, 32'h8), EBREAK, err);          // BOOT_STATUS read
    check(err == 0 && `GPR[S1] == 32'h0,
          $sformatf("debugger read of BOOT_STATUS allowed (err=%0d val=%08h)", err, `GPR[S1]));
    r = u_isram.mem[ISRAM_IDX0];
    reg_write(gpr(T3), ISRAM_BASE, err);
    reg_write(gpr(S1), 32'h1234_5678, err);
    progbuf_run(sw(S1, T3, 0), EBREAK, err);
    check(err == 3'd3 && u_isram.mem[ISRAM_IDX0] === r,
          $sformatf("debugger write to ISRAM denied outside recovery (err=%0d isram[0]=%08h)", err, u_isram.mem[ISRAM_IDX0]));
    progbuf_run(lw(S1, T3, 0), EBREAK, err);
    check(err == 0 && `GPR[S1] === r, $sformatf("debugger read of ISRAM allowed (err=%0d)", err));
    reg_write(gpr(T3), SB_BASE, err);
    reg_write(gpr(S1), 32'h1, err);
    progbuf_run(sw(S1, T3, 0), EBREAK, err);
    check(err == 3'd3 && `SB.state_q == 0,
          $sformatf("debugger cannot start verification outside recovery (err=%0d)", err));
    repeat (WDT_CYCLES + 1000) @(posedge clk_i);
    check(u_dut.recovery === 1'b0, "boot watchdog paused while halted in boot phase (no false recovery)");
    resume(ok);

    // =========================================================================
    // PART C -- no System Bus Access (DM built with SbaEnable=0)
    // =========================================================================
    boot("C-SBA", TPR_OR, TCR_NONE, 4'b0000, 1'b1, ok);
    dm_r(SBCS, r);
    check(r[11:5] == 0 && r[4:0] == 0,
          $sformatf("sbcs advertises no SBA: sbasize=0, sbaccess*=0 (sbcs=%08h)", r));
    // A debugger that ignores sbcs and pokes SBA anyway must not wedge anything
    dm_w(SBCS, 32'h0014_0000);          // sbreadonaddr, sbaccess=32-bit
    dm_w(SBAddress0, 32'h0002_0000);
    dm_w(SBData0, 32'h1234_5678);
    dm_r(SBCS, r);
    check(!r[21] && !u_dut.u_dm_obi_top.master_req_o,
          $sformatf("forced SBA access ignored: sbbusy=0, no bus request (sbcs=%08h)", r));
    halt(ok);
    reg_read(gpr(S1), r, err);
    check(ok && err == 0 && r == VAL_S1, "execution-based debug still works after SBA poke");
    resume(ok);

    // =========================================================================
    // PART E -- JTAG recovery boot
    // =========================================================================

    // R-STRAP: faulty bootrom, strap set
    por("R-STRAP", 1'b1, 1'b1);
    wait_halted(ok);
    check(ok && u_dut.recovery === 1'b1, $sformatf("strap -> recovery, hart halted (allhalted=%0b)", ok));
    check(mon_exc_run == 0, $sformatf("no bootrom instruction executed (exceptions=%0d)", mon_exc_run));
    reg_read(CSR_DPC, r, err);
    check(err == 0 && r == 32'h80, $sformatf("halted at the reset vector before executing it (dpc=%08h)", r));
    check(mon_rom_fetch == 0, $sformatf("no BootROM fetch reached the ROM in recovery (%0d)", mon_rom_fetch));

    // TCR/TPR cannot be configured by the recovery debugger
    reg_write(CSR_TCR, 32'hFFFF_FFFF, err);
    check(err == 3'd3 && `CSRS.tcr_q == 32'h0, $sformatf("recovery: abstract write TCR rejected (err=%0d tcr=%08h)", err, `CSRS.tcr_q));
    reg_write(gpr(S1), 32'hFFFF_FFFF, err);
    progbuf_run(csrw(CSR_TPR, S1), EBREAK, err);
    check(err == 3'd3 && `CSRS.tpr_q == 32'h0, $sformatf("recovery: progbuf csrw TPR rejected (err=%0d tpr=%08h)", err, `CSRS.tpr_q));

    // The BootROM is not executable in recovery (no gadgets): resuming into it
    // faults; no fetch reaches the ROM; the core stays haltable.
    mon_clear();
    resume(ok);
    repeat (500) @(posedge clk_i);
    check(mon_exc_run != 0 && mon_rom_fetch == 0 && u_dut.boot_done === 1'b0,
          $sformatf("recovery: resume into the BootROM faults, nothing fetched from the ROM (exceptions=%0d rom fetches=%0d)",
                    mon_exc_run, mon_rom_fetch));
    halt(ok);
    check(ok, "core haltable after the refused BootROM fetches");

    load_image(npoll);
    check(npoll == 0 && image_in_isram(), $sformatf("debugger loaded recovery image into ISRAM (failed words=%0d)", npoll));
    reg_write(gpr(T3), CTRL_BASE, err);
    progbuf_run(sw(S1, T3, 32'hC), EBREAK, err);
    check(err == 3'd3 && u_dut.boot_done == 1'b0, "CSR writes stay blocked in recovery");
    progbuf_run(lw(S1, T3, 32'h4), EBREAK, err);           // STATUS0
    check(err == 0 && `GPR[S1][3:1] == 3'b010,
          $sformatf("STATUS0 recovery_mode=1 recovery_wdt=0 isram_locked=0 (STATUS0=%08h)", `GPR[S1]));

    // Unverified image must not run
    reg_write(CSR_DPC, ENTRY, err);
    mon_clear();
    resume(ok);
    repeat (2000) @(posedge clk_i);
    check(u_dsram.mem[W_MARK] != MARK_OK && mon_exc_run != 0,
          $sformatf("UNVERIFIED image does not execute: fetch faults (exceptions=%0d mark=%08h)", mon_exc_run, u_dsram.mem[W_MARK]));
    halt(ok);
    check(ok, "core still haltable after refused ISRAM fetch (no bus wedge)");

    // Tampered copy (one code bit flipped) is rejected
    isram_poke(20, rimg[20] ^ 32'h1, err);
    check(err == 0, "debugger can modify ISRAM in recovery");
    sb_verify(r, err);
    check(err == 0 && r[1] && !r[2] && !r[3] && !r[4],
          $sformatf("TAMPERED image: signature rejected (VERIFY_STATUS=%05b)", r[4:0]));
    // ISRAM locked once a verification was started
    isram_poke(20, 32'h0BAD_C0DE, err);
    check(err == 3'd3 && u_isram.mem[ISRAM_IDX0 + 20] == (rimg[20] ^ 32'h1),
          $sformatf("ISRAM write after VERIFY start refused, image unchanged (err=%0d)", err));
    dbg_lw(CTRL_BASE + 4, r2, err);
    check(r2[1], $sformatf("STATUS0.isram_locked=1 after VERIFY start (STATUS0=%08h)", r2));
    reg_write(CSR_DPC, ENTRY, err);
    mon_clear();
    resume(ok);
    repeat (2000) @(posedge clk_i);
    check(u_dsram.mem[W_MARK] != MARK_OK && mon_exc_run != 0, "tampered image does not execute");
    halt(ok);

    // The engine is one-shot per reset
    reg_write(gpr(T3), SB_BASE, err);
    reg_write(gpr(S1), 32'h1, err);
    progbuf_run(sw(S1, T3, 0), EBREAK, err);
    progbuf_run(lw(S1, T3, 32'h4), EBREAK, err);
    check(`GPR[S1][4] && !`GPR[S1][3],
          $sformatf("second verification without reset -> VERIFY_STATUS.error (%05b)", `GPR[S1][4:0]));

    // ndmreset in recovery re-halts before the bootrom runs again
    mon_clear();
    dm_w(DMControl, 32'h0000_0003);
    dm_w(DMControl, 32'h1000_0001);
    wait_halted(ok);
    reg_read(CSR_DPC, r, err);
    check(ok && r == 32'h80 && mon_exc_run == 0,
          $sformatf("ndmreset in recovery -> halted at reset vector again (dpc=%08h exc=%0d)", r, mon_exc_run));
    check(u_dut.recovery === 1'b1 && u_dut.isram_lock === 1'b0 && u_dut.boot_done === 1'b0,
          "ndmreset keeps recovery, clears the ISRAM lock (retry possible)");

    // Restore the signed copy: verifies
    isram_poke(20, rimg[20], err);
    check(image_in_isram(), "signed image restored in ISRAM");
    sb_verify(r, err);
    check(err == 0 && r[1] && r[2] && r[3] && !r[4],
          $sformatf("SIGNED image verified: valid + verified (VERIFY_STATUS=%05b)", r[4:0]));
    reg_write(gpr(T3), SB_BASE, err);
    progbuf_run(lw(S1, T3, 32'hC), EBREAK, err);
    check(`GPR[S1] == ENTRY, $sformatf("VERIFY ENTRY register = %08h", `GPR[S1]));
    reg_write(gpr(T3), CTRL_BASE, err);
    progbuf_run(lw(S1, T3, 32'h4), EBREAK, err);           // STATUS0
    check(`GPR[S1][0], $sformatf("STATUS0.crypto_verified follows the hardware verdict (STATUS0=%08h)", `GPR[S1]));

    // Only the signed code range executes: jumping to the header faults
    reg_write(CSR_DPC, ISRAM_BASE, err);
    mon_clear();
    resume(ok);
    repeat (2000) @(posedge clk_i);
    check(u_dsram.mem[W_MARK] != MARK_OK && mon_exc_run != 0 && u_dut.boot_done === 1'b0,
          "image header (outside the verified code range) does not execute, no boot_done");
    halt(ok);

    // Single entry: a verified image cannot be entered anywhere but ENTRY
    reg_write(CSR_DPC, ENTRY + 4, err);
    mon_clear();
    resume(ok);
    repeat (2000) @(posedge clk_i);
    check(u_dsram.mem[W_MARK] != MARK_OK && mon_exc_run != 0 && u_dut.boot_done === 1'b0 &&
          `SB.verified_q === 1'b1,
          $sformatf("resume at ENTRY+4 refused although verified (exceptions=%0d boot_done=%0b)", mon_exc_run, u_dut.boot_done));
    halt(ok);
    check(ok, "core haltable after the refused mid-image entry");

    // Verified image runs from its entry point: the resume is the handoff
    reg_write(CSR_DPC, ENTRY, err);
    mon_clear();
    resume(ok);
    heartbeat(ok);
    check(ok && u_dsram.mem[W_MARK] == MARK_OK,
          $sformatf("VERIFIED recovery image runs from ISRAM entry (mark=%08h)", u_dsram.mem[W_MARK]));
    check(u_dut.boot_done === 1'b1 && mon_bd_rise == 1 && !mon_bd_early,
          "recovery: HARDWARE set boot_done at the resume fetch at ENTRY (no software involved)");
    check(u_dut.recovery === 1'b1, "recovery flag stays set until power-on reset");

    // After the handoff the debugger loses the recovery rights
    halt(ok);
    isram_poke(21, 32'h0BAD_C0DE, err);
    check(err == 3'd3 && u_isram.mem[ISRAM_IDX0 + 21] == rimg[21],
          $sformatf("after handoff: debugger ISRAM write refused (err=%0d)", err));
    reg_write(gpr(T3), SB_BASE, err);
    reg_write(gpr(S1), 32'h1, err);
    progbuf_run(sw(S1, T3, 0), EBREAK, err);
    check(err == 3'd3, $sformatf("after handoff: debugger VERIFY write refused (err=%0d)", err));
    reg_write(gpr(T3), CTRL_BASE, err);
    progbuf_run(sw(S1, T3, 0), EBREAK, err);
    check(err == 3'd3, $sformatf("after handoff: debugger CTRL write refused (err=%0d)", err));
    resume(ok);
    heartbeat(ok);
    check(ok, "recovered firmware keeps running after the debug session");

    // R-WDT: faulty bootrom, no strap -> watchdog forces recovery
    por("R-WDT", 1'b0, 1'b1);
    check(u_dut.recovery === 1'b0, "no recovery right after POR without strap");
    wait_recovery(ok);
    check(ok && u_dut.recovery === 1'b1 && mon_exc_run != 0,
          $sformatf("boot watchdog -> recovery + halt after faulty bootrom ran (allhalted=%0b exceptions=%0d)", ok, mon_exc_run));
    check(image_in_isram(), "ISRAM image survived power-on reset (model)");
    reg_write(gpr(T3), CTRL_BASE, err);
    progbuf_run(lw(S1, T3, 32'h4), EBREAK, err);           // STATUS0
    check(err == 0 && `GPR[S1][3:2] == 2'b11,
          $sformatf("STATUS0 recovery_mode=1 recovery_wdt=1 (STATUS0=%08h)", `GPR[S1]));

    sb_verify(r, err);
    check(r[3], $sformatf("signed image verified after watchdog recovery (VERIFY_STATUS=%05b)", r[4:0]));

    // Swap-after-verify is now blocked by the lock: the write never lands,
    // the verdict stands
    isram_poke(20, 32'h0BAD_C0DE, err);
    reg_write(gpr(T3), SB_BASE, err);
    progbuf_run(lw(S1, T3, 32'h4), EBREAK, r2);
    check(err == 3'd3 && image_in_isram() && `GPR[S1][3],
          $sformatf("swap-after-verify refused by the ISRAM lock, verdict stands (err=%0d VERIFY_STATUS=%05b)", err, `GPR[S1][4:0]));

    // Reset + re-verify -> runs (retry path: ndmreset clears the lock and
    // boot_done, keeps ISRAM and recovery)
    dm_w(DMControl, 32'h0000_0003);
    dm_w(DMControl, 32'h1000_0001);
    wait_halted(ok);
    check(ok && u_dut.recovery === 1'b1 && u_dut.isram_lock === 1'b0 && u_dut.boot_done === 1'b0 && image_in_isram(),
          "ndmreset: halted again, recovery kept, lock + boot_done cleared, ISRAM kept");
    isram_poke(20, rimg[20], err);
    check(err == 0, "ISRAM writable again for the retry");
    u_dsram.mem[W_MARK] = 0;
    sb_verify(r, err);
    reg_write(CSR_DPC, ENTRY, err);
    mon_clear();
    resume(ok);
    heartbeat(ok);
    check(r[3] && ok && u_dsram.mem[W_MARK] == MARK_OK && u_dut.boot_done === 1'b1,
          "re-verified image runs after reset, hardware boot_done");

    // R-NORMAL: good bootrom, no strap -> never enters recovery
    por("R-NORMAL", 1'b0, 1'b0, 1'b1);
    heartbeat(ok, 3, 1_500_000);
    repeat (WDT_CYCLES + 1000) @(posedge clk_i);
    check(ok && u_dut.boot_done === 1'b1 && u_dut.recovery === 1'b0 && !`CTRL.debug_mode_q,
          "good bootrom: secure boot, hardware boot_done, no recovery, hart running");
    check(mon_bd_rise == 1 && !mon_bd_early && mon_rom_fetch == 0,
          $sformatf("boot_done rose once, at the ENTRY fetch; no BootROM fetch after it (%0d)", mon_rom_fetch));
    halt(ok);
    reg_write(gpr(T3), CTRL_BASE, err);
    progbuf_run(lw(S1, T3, 32'h4), EBREAK, err);           // STATUS0 (debug read allowed post-boot)
    check(err == 0 && `GPR[S1][3:1] == 3'b001,
          $sformatf("STATUS0 recovery bits clear, ISRAM locked on normal boot (STATUS0=%08h)", `GPR[S1]));
    progbuf_run(lw(S1, T3, 32'h8), EBREAK, err);           // BOOT_STATUS
    check(err == 0 && `GPR[S1] == 32'h1, $sformatf("BOOT_STATUS reads the hardware boot_done (%08h)", `GPR[S1]));

    // After the handoff the BootROM is not executable, even via the debugger
    reg_write(CSR_DPC, 32'h80, err);
    mon_clear();
    resume(ok);
    repeat (500) @(posedge clk_i);
    check(u_dsram.mem[W_TRAPCNT] == 1 && u_dsram.mem[W_MCAUSE] == 32'h1 && mon_rom_fetch == 0,
          $sformatf("resume into the BootROM after boot -> instruction access fault in the firmware's handler (mcause=%0d traps=%0d rom fetches=%0d)",
                    u_dsram.mem[W_MCAUSE], u_dsram.mem[W_TRAPCNT], mon_rom_fetch));
    halt(ok);

    // ndmreset after boot: boot_done back to 0, the full boot runs again
    dm_w(DMControl, 32'h0000_0003);
    repeat (5) @(posedge clk_i);
    check(u_dut.boot_done === 1'b0 && u_dut.isram_lock === 1'b0, "ndmreset clears boot_done and the ISRAM lock");
    u_dsram.mem[W_HB] = 0;
    u_dsram.mem[W_TRAPCNT] = 0;
    mon_clear();
    dm_w(DMControl, 32'h1000_0001);
    heartbeat(ok, 3, 1_500_000);
    check(ok && u_dut.boot_done === 1'b1 && mon_bd_rise == 1 && !mon_bd_early && u_dut.recovery === 1'b0,
          "after ndmreset the bootrom verifies and hands over again (hardware boot_done)");

    // =========================================================================
    // PART F -- hardware boot handoff vs. a buggy bootrom (strap = 0)
    // =========================================================================

    // F-CTRL1: the old boot_done_set write is ignored; the bootrom hangs.
    // Before: boot_done=1 stopped the watchdog -> stuck forever. Now: recovery.
    por("F-CTRL1", 1'b0, 1'b0, 1'b1, 1'b0, 1'b1);
    heartbeat(ok, 3, 20000);
    check(ok && u_dut.boot_done === 1'b0,
          $sformatf("bootrom wrote CTRL1 (boot_done_set): ignored, boot_done=%0b", u_dut.boot_done));
    wait_recovery(ok);
    check(ok && u_dut.recovery_by_wdt === 1'b1 && mon_bd_rise == 0,
          "hanging bootrom -> boot watchdog -> recovery, core halted (the L1 brick is gone)");
    check(mon_nmi == 0, $sformatf("clean halt when the watchdog cuts the running bootrom (exceptions before halt=%0d)", mon_exc_run));
    obs($sformatf("F-CTRL1: refused BootROM fetches between recovery and halt -> %0d exception(s)", mon_exc_run));

    // F-SKIPV: bootrom jumps to ENTRY without verifying
    por("F-SKIPV", 1'b0, 1'b0, 1'b1, 1'b1, 1'b0, 1'b1);
    wait_recovery(ok);
    check(ok && mon_bd_rise == 0 && mon_entry_fetch == 0 && u_dsram.mem[W_MCAUSE] == 32'h1,
          $sformatf("unverified jump to ENTRY refused (mcause=%0d), no boot_done, watchdog -> recovery",
                    u_dsram.mem[W_MCAUSE]));

    // F-JOFF: verified, but the bootrom jumps to ENTRY+8
    por("F-JOFF", 1'b0, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 8);
    wait_recovery(ok);
    check(ok && `SB.verified_q === 1'b1 && mon_bd_rise == 0 && u_dsram.mem[W_MCAUSE] == 32'h1,
          $sformatf("verified image entered at ENTRY+8 refused (single entry), no boot_done, watchdog -> recovery (verified=%0b)",
                    `SB.verified_q));

    // F-ISRW: bootrom writes ISRAM after VERIFY start
    por("F-ISRW", 1'b0, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 1'b1);
    heartbeat(ok, 3, 1_500_000);
    check(u_dsram.mem[W_MCAUSE] == 32'h7 && u_dsram.mem[W_TRAPCNT] == 1 && u_isram.mem[ISRAM_IDX0] == fimg[0],
          $sformatf("ISRAM write after VERIFY start -> store access fault, image intact (mcause=%0d)", u_dsram.mem[W_MCAUSE]));
    check(ok && u_dut.boot_done === 1'b1 && u_dut.recovery === 1'b0,
          "verification unaffected, firmware boots (hardware boot_done)");

    // F-TAMPER: good bootrom, tampered image
    por("F-TAMPER", 1'b0, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 0, 1'b1);
    wait_recovery(ok);
    check(ok && u_dsram.mem[W_MARK] == ROM_FAIL && mon_bd_rise == 0 && mon_entry_fetch == 0 && u_dut.recovery_by_wdt === 1'b1,
          "tampered image rejected by the hardware, bootrom never hands over, watchdog -> recovery");

    // =========================================================================
    // Summary
    // =========================================================================
    $display("\n=====================================================================");
    $display(" checks=%0d  FAIL=%0d  DIFT-FINDINGS=%0d", checks, errors, findings);
    foreach (finding_log[i]) $display("  - %s", finding_log[i]);
    if (errors == 0) $display(" [secure_boot_dbg_tb] TEST PASSED -- debug spec + DIFT + JTAG recovery + hardware Ed25519 secure boot + hardware boot handoff%s",
                              findings ? " -- review DIFT findings above" : "");
    else             $display(" [secure_boot_dbg_tb] TEST FAILED -- %0d functional error(s)", errors);
    $display("=====================================================================");
    $finish;
  end

  initial begin
    #400ms;   // each Ed25519 verification is ~4 ms at CRYPTO_CLK_DIV=2
    $display("[FAIL] Global watchdog timeout in scenario %s", scen);
    $finish;
  end

endmodule : secure_boot_dbg_tb
