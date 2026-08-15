// =============================================================================
// tb_dift_debug_integration.sv  —  Vivado / xsim  (Revision 4)
//
// Matches soc_top_dift architecture:
//   • ibex_top used as CPU (lockstep/ECC/scan ports tied off)
//   • dift_obi_ctrl sits between ibex_top and soc_addr_decode on both buses
//   • Tag shadow RAM is in soc_top under `ifdef DIFT (not inside ibex_dift_mem)
//   • LSU DIFT ports inside ibex_top→ibex_core:
//       data_rdata_tag_i, lsu_rdata_tag_o, lsu_tag_err_o,
//       data_wdata_tag_o, lsu_wdata_tag_i, tcr_load_check_i
//   • dift_exception_o is NOT a top-level port of soc_top_dift.
//     ibex_core fires dift_exception_o → dift_obi_ctrl passes it through
//     as irq_dift (internal) → PLIC irq_sources[7].
//     Tests that previously probed the external port now probe dut.irq_dift.
//   • No tag_ram_* ports on soc_top (tag RAM is internal, `ifdef DIFT)
//   • All memory access via CPU LSU (SBA disabled)
//
// TEST PLAN  (41 tests, 7 categories)
// ────────────────────────────────────
//  A  Reset / power-on sanity                            5 tests
//  B  JTAG TAP structural correctness                    5 tests
//  C  Debug entry / exit                                 7 tests
//  D  DIFT policy protection (TPR/TCR via debug)         7 tests
//  E  Debug-injected data tainted via dift_obi_ctrl      6 tests
//  F  load_from_dm_mem boundary correctness              5 tests
//  G  Edge cases                                         6 tests
//                                                Total: 41 tests
//
// HIERARCHY PROBES  — adjust paths if your wrapper hierarchy differs:
//   soc_top
//     └─ u_ibex_top           (ibex_top wrapping ibex_core with DIFT)
//         └─ u_ibex_core
//             ├─ cs_registers_i
//             └─ load_store_unit_i
// =============================================================================
// =============================================================================
module tb_dift_debug_integration;

// ─── Parameters ──────────────────────────────────────────────────────────────

localparam int    IR_LEN       = 5;
localparam logic  [IR_LEN-1:0]
    IR_BYPASS    = 5'h1f,
    IR_IDCODE    = 5'h01,
    IR_DTMCSR    = 5'h10,
    IR_DMIACCESS = 5'h11;

localparam int    ABITS        = 7;
localparam int    DMI_DR_LEN   = ABITS + 34;   // 41 bits

localparam logic [6:0]
    DM_DMCONTROL  = 7'h10,
    DM_DMSTATUS   = 7'h11,
    DM_ABSTRACTCS = 7'h16,
    DM_COMMAND    = 7'h17,
    DM_PROGBUF0   = 7'h20,
    DM_PROGBUF1   = 7'h21,
    DM_DATA0      = 7'h04;

localparam logic [11:0]
    CSR_TPR       = 12'hBC0,
    CSR_TCR       = 12'hBC1;

// SoC address map (match soc_addr_decode)
localparam logic [31:0]
    DSRAM_BASE    = 32'h0002_0000,
    DM_BASE       = 32'h1A11_0000,
    DM_LIMIT      = 32'h1A12_0000,     // DM_BASE + 64KB
    DM_DATAADDR   = DM_BASE + 32'h380; // dm::DataAddr

localparam int TCK_HALF = 4;   // sys-clock half-periods per TCK half (100 MHz → 12.5 MHz TCK)

// ─── DUT I/O ─────────────────────────────────────────────────────────────────

logic        clk_i, rst_ni;
logic        qspi_csn_o, qspi_clk_o;
wire  [ 3:0] qspi_io_io;
logic        spi_csn_o, spi_clk_o, spi_mosi_o, spi_miso_i;
logic        uart_tx_o, uart_rx_i;
wire  [31:0] gpio_io;
logic        jtag_tck_i, jtag_tms_i, jtag_tdi_i, jtag_tdo_o, jtag_trst_ni;
// dift_exception_o is no longer a top-level port. The signal is internal:
// ibex_core.dift_exception_o -> dift_obi_ctrl -> irq_dift -> PLIC.
// Probed directly as dut.irq_dift in tests A1, C7, D7, G6.

// ─── DUT ─────────────────────────────────────────────────────────────────────

soc_top dut (
    .clk_i           ( clk_i           ),
    .rst_ni          ( rst_ni          ),
    .qspi_csn_o      ( qspi_csn_o      ),
    .qspi_clk_o      ( qspi_clk_o      ),
    .qspi_io_io      ( qspi_io_io      ),
    .spi_csn_o       ( spi_csn_o       ),
    .spi_clk_o       ( spi_clk_o       ),
    .spi_mosi_o      ( spi_mosi_o      ),
    .spi_miso_i      ( spi_miso_i      ),
    .uart_tx_o       ( uart_tx_o       ),
    .uart_rx_i       ( uart_rx_i       ),
    .gpio_io         ( gpio_io         ),
    .jtag_tck_i      ( jtag_tck_i      ),
    .jtag_tms_i      ( jtag_tms_i      ),
    .jtag_tdi_i      ( jtag_tdi_i      ),
    .jtag_tdo_o      ( jtag_tdo_o      ),
    .jtag_trst_ni    ( jtag_trst_ni    )
    // dift_exception_o removed — signal is internal (irq_dift → PLIC)
);

// ─── Clock ───────────────────────────────────────────────────────────────────

initial clk_i = 0;
always  #5 clk_i = ~clk_i;

// ─── Counters ────────────────────────────────────────────────────────────────

int pass_count = 0;
int fail_count = 0;

// ─── Hierarchy aliases — adjust if your wrapper names differ ─────────────────
`define CHECK_EQ(label, got, expected) \
    if ((got) !== (expected)) begin \
        $error("[FAIL] %s: got=%0h expected=%0h", label, got, expected); \
        fail_count++; \
    end else begin \
        $display("[PASS] %s", label); \
        pass_count++; \
    end

`define CHECK_TRUE(label, cond) \
    if (!(cond)) begin \
        $error("[FAIL] %s", label); \
        fail_count++; \
    end else begin \
        $display("[PASS] %s", label); \
        pass_count++; \
    end

`define CHECK_NE(label, got, bad) \
    if ((got) === (bad)) begin \
        $error("[FAIL] %s: got=%0h (should differ from %0h)", label, got, bad); \
        fail_count++; \
    end else begin \
        $display("[PASS] %s", label); \
        pass_count++; \
    end
// ibex_core internal signals
// ibex_top is the DUT-level instance; ibex_core lives one level inside it.
`define CORE  dut.u_ibex_top.u_ibex_core

// CSR registers
`define CSR   `CORE.cs_registers_i

// LSU ports (DIFT side)
`define LSU   `CORE.load_store_unit_i

// dm_halted in soc_top
`define DM_HALTED  dut.dm_halted

// Probes
logic [31:0] probe_tpr;
logic [31:0] probe_tcr;
logic        probe_debug_mode;
logic        probe_dm_halted;
logic        probe_lsu_tag_err;
logic        probe_data_rdata_tag;    // tag returning to core
logic        probe_load_from_dm;      // combinational bounds check
logic [31:0] probe_data_addr;         // data_addr seen by the memory subsystem

assign probe_tpr            = `CSR.tpr_q;
assign probe_tcr            = `CSR.tcr_q;
assign probe_debug_mode     = `CSR.debug_mode_i;
assign probe_dm_halted      = `DM_HALTED;
assign probe_lsu_tag_err    = `LSU.lsu_tag_err_o;
assign probe_data_rdata_tag = dut.tag_rdata;   
assign probe_load_from_dm   = !dut.is_data_sram;
assign probe_data_addr      = dut.data_addr;

// =============================================================================
//  JTAG BFM
// =============================================================================

task automatic jtag_init();
    jtag_tck_i   = 0; jtag_tms_i = 1;
    jtag_tdi_i   = 0; jtag_trst_ni = 0;
    repeat(6) @(posedge clk_i);
    jtag_trst_ni = 1;
    @(posedge clk_i);
endtask

task automatic jtag_clk(input logic tms, input logic tdi, output logic tdo);
    jtag_tms_i = tms; jtag_tdi_i = tdi;
    repeat(TCK_HALF) @(posedge clk_i);
    jtag_tck_i = 1;
    repeat(TCK_HALF) @(posedge clk_i);
    tdo = jtag_tdo_o;
    jtag_tck_i = 0;
endtask

task automatic jtag_goto_rti();
    logic d;
    repeat(5) jtag_clk(1'b1, 1'b0, d);
    jtag_clk(1'b0, 1'b0, d);
endtask

task automatic jtag_shift_ir(input logic [IR_LEN-1:0] ir);
    logic d;
    jtag_clk(1'b1, 1'b0, d);  // SelectDR
    jtag_clk(1'b1, 1'b0, d);  // SelectIR
    jtag_clk(1'b0, 1'b0, d);  // CaptureIR
    jtag_clk(1'b0, 1'b0, d);  // ShiftIR
    for (int i = 0; i < IR_LEN-1; i++) jtag_clk(1'b0, ir[i], d);
    jtag_clk(1'b1, ir[IR_LEN-1], d);  // Exit1IR
    jtag_clk(1'b1, 1'b0, d);  // UpdateIR
    jtag_clk(1'b0, 1'b0, d);  // RTI
endtask

task automatic jtag_shift_dmi(
    input  logic [ABITS-1:0] addr,
    input  logic [31:0]      din,
    input  logic [1:0]       op,
    output logic [31:0]      dout,
    output logic [1:0]       resp
);
    logic [DMI_DR_LEN-1:0] sr_in = {addr, din, op};
    logic [DMI_DR_LEN-1:0] sr_out = '0;
    logic d;

    jtag_clk(1'b1, 1'b0, d);  // SelectDR
    jtag_clk(1'b0, 1'b0, d);  // CaptureDR
    jtag_clk(1'b0, 1'b0, d);  // ShiftDR
    for (int i = 0; i < DMI_DR_LEN-1; i++) jtag_clk(1'b0, sr_in[i], sr_out[i]);
    jtag_clk(1'b1, sr_in[DMI_DR_LEN-1], sr_out[DMI_DR_LEN-1]);  // Exit1DR
    jtag_clk(1'b1, 1'b0, d);  // UpdateDR
    jtag_clk(1'b0, 1'b0, d);  // RTI

    dout = sr_out[33:2];
    resp = sr_out[1:0];
endtask

// =============================================================================
//  DMI / DM helpers
// =============================================================================

task automatic dmi_write(input logic [6:0] addr, input logic [31:0] data);
    logic [31:0] rd; logic [1:0] rs;
    jtag_shift_ir(IR_DMIACCESS);
    jtag_shift_dmi(addr, data, 2'h2, rd, rs);
    jtag_shift_dmi(7'h0, 32'h0, 2'h0, rd, rs);  // NOP flush
    repeat(8) @(posedge clk_i);
endtask

task automatic dmi_read(input logic [6:0] addr, output logic [31:0] rdata);
    logic [1:0] rs;
    jtag_shift_ir(IR_DMIACCESS);
    jtag_shift_dmi(addr, 32'h0, 2'h1, rdata, rs);  // initiate read
    jtag_shift_dmi(7'h0, 32'h0, 2'h0, rdata, rs);  // NOP captures result
    repeat(8) @(posedge clk_i);
endtask

task automatic dm_activate();
    dmi_write(DM_DMCONTROL, 32'h0000_0001);
    repeat(4) @(posedge clk_i);
endtask

task automatic dm_halt_hart0();
    logic [31:0] st;
    dmi_write(DM_DMCONTROL, 32'h8000_0001);
    repeat(500) begin
        @(posedge clk_i);
        dmi_read(DM_DMSTATUS, st);
        if (st[9]) break;
    end
    if (!probe_dm_halted)
        $display("WARNING: dm_halt_hart0 timed out");
endtask

task automatic dm_resume_hart0();
    logic [31:0] st;
    dmi_write(DM_DMCONTROL, 32'h4000_0001);
    repeat(200) begin
        @(posedge clk_i);
        dmi_read(DM_DMSTATUS, st);
        if (st[17]) break;
    end
    dmi_write(DM_DMCONTROL, 32'h0000_0001);
    repeat(20) @(posedge clk_i);
endtask

task automatic dm_wait_abscmd();
    logic [31:0] cs;
    repeat(300) begin
        @(posedge clk_i);
        dmi_read(DM_ABSTRACTCS, cs);
        if (!cs[12]) return;
    end
    $display("WARNING: dm_wait_abscmd timed out");
endtask

// Write GPR via abstract Access Register command
// regno = 0x1000 | gpr  (standard RISC-V debug spec encoding)
task automatic dm_write_gpr(input logic [4:0] gpr, input logic [31:0] val);
    logic [31:0] cmd;
    dmi_write(DM_DATA0, val);
    cmd = 32'h0000_0000
        | (3'h2 << 20)                           // aarsize = 32-bit
        | (1'b1 << 17)                           // transfer = 1
        | (1'b1 << 16)                           // write = 1
        | (16'h1000 | {11'h0, gpr});             // regno
    dmi_write(DM_COMMAND, cmd);
    dm_wait_abscmd();
endtask

task automatic dm_read_gpr(input logic [4:0] gpr, output logic [31:0] val);
    logic [31:0] cmd;
    cmd = 32'h0000_0000
        | (3'h2 << 20)
        | (1'b1 << 17)
        | (1'b0 << 16)                           // write = 0 → read
        | (16'h1000 | {11'h0, gpr});
    dmi_write(DM_COMMAND, cmd);
    dm_wait_abscmd();
    dmi_read(DM_DATA0, val);
endtask

task automatic dm_exec_progbuf();
    dmi_write(DM_COMMAND, 32'h0004_0000);  // postexec=1, transfer=0
    dm_wait_abscmd();
endtask

// csrrw x0, csr_addr, x1  (writes x1 into CSR, discards old)
task automatic dm_csrw_via_progbuf(input logic [11:0] csr_addr, input logic [31:0] val);
    logic [31:0] csrrw = {csr_addr, 5'd1, 3'b001, 5'd0, 7'b111_0011};
    logic [31:0] ebrk  = 32'h0010_0073;
    dm_write_gpr(5'd1, val);
    dmi_write(DM_PROGBUF0, csrrw);
    dmi_write(DM_PROGBUF1, ebrk);
    dm_exec_progbuf();
endtask

// csrrs x1, csr_addr, x0  (reads CSR into x1)
task automatic dm_csrr_via_progbuf(input logic [11:0] csr_addr, output logic [31:0] val);
    logic [31:0] csrrs = {csr_addr, 5'd0, 3'b010, 5'd1, 7'b111_0011};
    logic [31:0] ebrk  = 32'h0010_0073;
    dmi_write(DM_PROGBUF0, csrrs);
    dmi_write(DM_PROGBUF1, ebrk);
    dm_exec_progbuf();
    dm_read_gpr(5'd1, val);
endtask

// ─── Utilities ────────────────────────────────────────────────────────────────

task automatic hard_reset();
    rst_ni = 0;
    jtag_init();
    repeat(12) @(posedge clk_i);
    rst_ni = 1;
    repeat(12) @(posedge clk_i);
endtask

task automatic wait_cyc(input int n);
    repeat(n) @(posedge clk_i);
endtask

task automatic read_idcode(output logic [31:0] id);
    logic d;
    jtag_clk(1'b1, 1'b0, d);  // SelectDR
    jtag_clk(1'b0, 1'b0, d);  // CaptureDR
    jtag_clk(1'b0, 1'b0, d);  // ShiftDR
    for (int i = 0; i < 31; i++) jtag_clk(1'b0, 1'b0, id[i]);
    jtag_clk(1'b1, 1'b0, id[31]);
    jtag_clk(1'b1, 1'b0, d);  // UpdateDR
    jtag_clk(1'b0, 1'b0, d);  // RTI
endtask

// =============================================================================
//  MAIN TEST BODY
// =============================================================================

initial begin : tb_main
    spi_miso_i = 0;
    uart_rx_i  = 1;

    hard_reset();
    $display("\n=== RESET COMPLETE ===\n");

    // =========================================================================
    // CAT A — Reset / power-on sanity
    // =========================================================================
    $display("─── CAT A: Reset / power-on sanity ─────────────────────────────");

    // A1: dift_exception_o deasserted
    wait_cyc(3);
    `CHECK_EQ("A1 irq_dift=0 at reset", dut.irq_dift, 1'b0)

    // A2: TPR has no X
    `CHECK_NE("A2 TPR not X at reset", probe_tpr, 32'hx)

    // A3: TCR has no X
    `CHECK_NE("A3 TCR not X at reset", probe_tcr, 32'hx)

    // A4: Not in debug mode
    `CHECK_EQ("A4 debug_mode_i=0 at reset", probe_debug_mode, 1'b0)

    // A5: lsu_tag_err_o is 0 at reset (no spurious violation)
    `CHECK_EQ("A5 lsu_tag_err_o=0 at reset", probe_lsu_tag_err, 1'b0)

    // =========================================================================
    // CAT B — JTAG TAP structural correctness
    // =========================================================================
    $display("\n─── CAT B: JTAG TAP structural ──────────────────────────────────");

    jtag_goto_rti();

    // B1: IDCODE LSB = 1 (IEEE 1149.1 §10.4.1: bit 0 of IDCODE always 1)
    begin
        logic [31:0] idcode;
        jtag_shift_ir(IR_IDCODE);
        read_idcode(idcode);
        `CHECK_EQ("B1 IDCODE[0]=1 (mandatory per IEEE 1149.1)", idcode[0], 1'b1)
    end

    // B2: IDCODE is non-zero
    begin
        logic [31:0] idcode;
        jtag_shift_ir(IR_IDCODE);
        read_idcode(idcode);
        `CHECK_NE("B2 IDCODE != 0", idcode, 32'h0)
    end

    // B3: DTMCSR.version = 1 (RISC-V Debug Spec 0.13)
    begin
        logic [31:0] dtmcsr;
        logic d;
        jtag_shift_ir(IR_DTMCSR);
        jtag_clk(1'b1,1'b0,d); jtag_clk(1'b0,1'b0,d); jtag_clk(1'b0,1'b0,d);
        for (int i=0;i<31;i++) jtag_clk(1'b0,1'b0,dtmcsr[i]);
        jtag_clk(1'b1,1'b0,dtmcsr[31]);
        jtag_clk(1'b1,1'b0,d); jtag_clk(1'b0,1'b0,d);
        `CHECK_EQ("B3 DTMCSR.version=1 (debug spec 0.13)", dtmcsr[3:0], 4'h1)
    end

    // B4: DTMCSR.abits = 7
    begin
        logic [31:0] dtmcsr;
        logic d;
        jtag_shift_ir(IR_DTMCSR);
        jtag_clk(1'b1,1'b0,d); jtag_clk(1'b0,1'b0,d); jtag_clk(1'b0,1'b0,d);
        for (int i=0;i<31;i++) jtag_clk(1'b0,1'b0,dtmcsr[i]);
        jtag_clk(1'b1,1'b0,dtmcsr[31]);
        jtag_clk(1'b1,1'b0,d); jtag_clk(1'b0,1'b0,d);
        `CHECK_EQ("B4 DTMCSR.abits=7", dtmcsr[9:4], 6'd7)
    end

    // B5: BYPASS — TDI shifted in appears on TDO after one clock
    begin
        logic d, tdo_out;
        jtag_shift_ir(IR_BYPASS);
        jtag_clk(1'b1,1'b0,d); jtag_clk(1'b0,1'b0,d); jtag_clk(1'b0,1'b0,d);
        jtag_clk(1'b1, 1'b1, tdo_out);   // shift in 1 → should get 0 (bypass reg reset to 0), next:
        jtag_clk(1'b0, 1'b0, tdo_out);   // now 1 (the 1 we shifted in) exits
        jtag_clk(1'b1,1'b0,d); jtag_clk(1'b0,1'b0,d);
        // BYPASS has 1 extra clock delay: value shifted in on previous edge exits here
        `CHECK_EQ("B5 BYPASS delays TDI by 1 TCK", tdo_out, 1'b1)
    end

    // =========================================================================
    // CAT C — Debug entry / exit
    // =========================================================================
    $display("\n─── CAT C: Debug entry / exit ───────────────────────────────────");

    // C1: Activate DM (dmactive=1)
    dm_activate();
    wait_cyc(10);
    begin
        logic [31:0] st;
        dmi_read(DM_DMSTATUS, st);
        `CHECK_EQ("C1 dmstatus.version=2 (RISC-V DM v0.13)", st[3:0], 4'h2)
    end

    // C2: Halt hart0
    dm_halt_hart0();
    wait_cyc(20);
    `CHECK_EQ("C2 dm_halted asserted", probe_dm_halted, 1'b1)

    // C3: Core sees debug_mode_i=1 while halted
    `CHECK_EQ("C3 debug_mode_i=1 inside cs_registers", probe_debug_mode, 1'b1)

    // C4: dmstatus.anyhalted=1
    begin
        logic [31:0] st;
        dmi_read(DM_DMSTATUS, st);
        `CHECK_EQ("C4 dmstatus.anyhalted=1", st[9], 1'b1)
    end

    // C5: dmstatus.allhalted=1
    begin
        logic [31:0] st;
        dmi_read(DM_DMSTATUS, st);
        `CHECK_EQ("C5 dmstatus.allhalted=1", st[8], 1'b1)
    end

    // C6: Resume
    dm_resume_hart0();
    wait_cyc(20);
    `CHECK_EQ("C6 dm_halted cleared after resume", probe_dm_halted, 1'b0)
    `CHECK_EQ("C6b debug_mode_i=0 after resume", probe_debug_mode, 1'b0)

    // C7: No DIFT exception from plain halt/resume
    `CHECK_EQ("C7 no DIFT exception from debug entry/exit", dut.irq_dift, 1'b0)

    // =========================================================================
    // CAT D — DIFT policy protection: TPR/TCR cannot be modified via debug
    // =========================================================================
    $display("\n─── CAT D: DIFT policy protection (TPR/TCR) ─────────────────────");

    begin : cat_d
        logic [31:0] tpr_snap, tcr_snap, rd;

        tpr_snap = probe_tpr;
        tcr_snap = probe_tcr;

        dm_halt_hart0();
        wait_cyc(10);

        // D1: Attempt CSRW TPR = 0 (disable all taint propagation)
        dm_csrw_via_progbuf(CSR_TPR, 32'h0);
        wait_cyc(10);
        `CHECK_EQ("D1 TPR write 0 from debug mode dropped", probe_tpr, tpr_snap)

        // D2: Attempt CSRW TCR = 0 (disable all checks)
        dm_csrw_via_progbuf(CSR_TCR, 32'h0);
        wait_cyc(10);
        `CHECK_EQ("D2 TCR write 0 from debug mode dropped", probe_tcr, tcr_snap)

        // D3: Attempt CSRW TPR = 0xFFFF_FFFF
        dm_csrw_via_progbuf(CSR_TPR, 32'hFFFF_FFFF);
        wait_cyc(10);
        `CHECK_EQ("D3 TPR write 0xFFFFFFFF from debug dropped", probe_tpr, tpr_snap)

        // D4: CSRR TPR via progbuf must return 0 (real value hidden)
        dm_csrr_via_progbuf(CSR_TPR, rd);
        `CHECK_EQ("D4 TPR CSRR via debug returns 0 (policy hidden)", rd, 32'h0)

        // D5: CSRR TCR via progbuf must return 0
        dm_csrr_via_progbuf(CSR_TCR, rd);
        `CHECK_EQ("D5 TCR CSRR via debug returns 0 (policy hidden)", rd, 32'h0)

        // D6: Resume and re-verify
        dm_resume_hart0();
        wait_cyc(10);
        `CHECK_EQ("D6 TPR intact after debug session", probe_tpr, tpr_snap)
        `CHECK_EQ("D6b TCR intact after debug session", probe_tcr, tcr_snap)

        // D7: No DIFT exception during D tests
        `CHECK_EQ("D7 no DIFT exception during policy probe", dut.irq_dift, 1'b0)
    end

    // =========================================================================
    // CAT E — Debug-injected data tainted via dift_obi_ctrl + tag shadow RAM
    // =========================================================================
    // Abstract command "write GPR x10":
    //   DM puts 0xDEADBEEF into data0 (at DM_BASE+0x380 = 0x1A110380)
    //   DM inserts LW x10, 0(xN) into abstract command area
    //   Core executes that load → data_addr in soc_top hits DM window
    //   soc_top tag shadow RAM: is_data_sram=0 → tag_rdata forced to 1 (tainted)
    //   dift_obi_ctrl returns tag=1 → ibex_core LSU sees tainted rdata_tag
    //   LSU: lsu_rdata_tag_o=1 → register file writes tag=1 to x10
    //   Any subsequent TCR-gated use of x10 will see a tainted tag
    // =========================================================================
    $display("\n─── CAT E: Debug-injected data tainted via dift_obi_ctrl ─────────");

    // E1: Halt
    dm_halt_hart0();
    wait_cyc(10);
    `CHECK_EQ("E1 halted before E tests", probe_dm_halted, 1'b1)

    // E2: Inject into x10
    dm_write_gpr(5'd10, 32'hDEAD_BEEF);
    wait_cyc(20);

    // E3: Readback — value must be present
    begin
        logic [31:0] v;
        dm_read_gpr(5'd10, v);
        `CHECK_EQ("E3 injected value readable from x10", v, 32'hDEAD_BEEF)
    end

    // E4: data_addr seen by soc_top during the abstract-cmd load must have
    //     been outside the DSRAM window (is_data_sram=0), making tag_rdata=1.
    //     Since dm_write_gpr already returned (abstract cmd complete),
    //     we verify by forcing data_addr and checking is_data_sram combinationally.
    begin
        force dut.data_addr = DM_DATAADDR;
        #1;
        `CHECK_EQ("E4 is_data_sram=0 (tainted) for DM DataAddr (combinational)",
                   probe_load_from_dm, 1'b1)
        release dut.data_addr;
    end

    // E5: tag_rdata must be 1 when is_data_sram_q=0 (outside DSRAM → tainted)
    begin
        // Force is_data_sram_q=0 to simulate a non-DSRAM (e.g. DM) address
        force dut.is_data_sram_q = 1'b0;
        #1;
        `CHECK_EQ("E5 tag_rdata=1 (tainted) for DM window address",
                   probe_data_rdata_tag, 1'b1)
        release dut.is_data_sram_q;
    end

    // E6: tag_rdata must come from shadow RAM when is_data_sram_q=1 (DSRAM address)
    //     Force is_data_sram_q=1 — word 0 of shadow RAM was never tainted → expect 0
    begin
        force dut.is_data_sram_q = 1'b1;
        #1;
        // Word 0 of shadow RAM was never written tainted — should be 0
        `CHECK_EQ("E6 tag_rdata=0 for clean DSRAM address (no forced taint)",
                   probe_data_rdata_tag, 1'b0)
        release dut.is_data_sram_q;
    end

    dm_resume_hart0();
    wait_cyc(10);

    // =========================================================================
    // CAT F — load_from_dm_mem boundary correctness
    // =========================================================================
    $display("\n─── CAT F: load_from_dm_mem boundary correctness ────────────────");

    // All tests use force on data_addr_i to isolate the combinational boundary.

    // F1: Exactly DM_BASE → inside
    force dut.data_addr = DM_BASE;
    #1;
    `CHECK_EQ("F1 load_from_dm_mem=1 at DM_BASE", probe_load_from_dm, 1'b1)

    // F2: DM_BASE + 0x380 (DataAddr) → inside
    force dut.data_addr = DM_DATAADDR;
    #1;
    `CHECK_EQ("F2 load_from_dm_mem=1 at DM_DATAADDR", probe_load_from_dm, 1'b1)

    // F3: DM_LIMIT - 4 (last word) → inside
    force dut.data_addr = DM_LIMIT - 32'h4;
    #1;
    `CHECK_EQ("F3 load_from_dm_mem=1 at DM last word", probe_load_from_dm, 1'b1)

    // F4: Exactly DM_LIMIT → outside (exclusive upper bound)
    force dut.data_addr = DM_LIMIT;
    #1;
    `CHECK_EQ("F4 load_from_dm_mem=0 at DM_LIMIT (exclusive)", probe_load_from_dm, 1'b0)

    // F5: DSRAM base → outside
    force dut.data_addr = DSRAM_BASE;
    #1;
    `CHECK_EQ("F5 load_from_dm_mem=0 for DSRAM address", probe_load_from_dm, 1'b0)

    release dut.data_addr;

    // =========================================================================
    // CAT G — Edge cases
    // =========================================================================
    $display("\n─── CAT G: Edge cases ───────────────────────────────────────────");

    // G1: debug_disable gating — cannot halt when gated
    dm_activate();
    force dut.debug_disable = 1'b1;
    dmi_write(DM_DMCONTROL, 32'h8000_0001);
    wait_cyc(100);
    `CHECK_EQ("G1 debug_disable prevents core halt", probe_dm_halted, 1'b0)
    release dut.debug_disable;
    dmi_write(DM_DMCONTROL, 32'h0000_0001);
    wait_cyc(20);

    // G2: TestLogicReset (5× TMS=1) resets DTM; DM still responsive after
    begin
        logic [31:0] st; logic d;
        repeat(5) jtag_clk(1'b1, 1'b0, d);
        jtag_clk(1'b0, 1'b0, d);
        wait_cyc(20);
        dm_activate();
        dmi_read(DM_DMSTATUS, st);
        `CHECK_EQ("G2 DM responsive after TestLogicReset", st[3:0], 4'h2)
    end

    // G3: Non-implemented DM register reads as 0
    begin
        logic [31:0] v;
        dm_halt_hart0();
        dmi_read(7'h1d, v);    // nextdm — not in this DM
        `CHECK_EQ("G3 non-implemented DM reg = 0", v, 32'h0)
        dm_resume_hart0();
    end

    // G4: TPR/TCR survive a full halt/resume cycle (D7 regression check)
    begin
        logic [31:0] tpr_b = probe_tpr, tcr_b = probe_tcr;
        dm_halt_hart0();
        wait_cyc(5);
        dm_resume_hart0();
        wait_cyc(5);
        `CHECK_EQ("G4 TPR unchanged across halt/resume", probe_tpr, tpr_b)
        `CHECK_EQ("G4b TCR unchanged across halt/resume", probe_tcr, tcr_b)
    end

    // G5: lsu_tag_err_o=0 when data_rvalid_i=0 (even if tainted tag present)
    //     Force rvalid low and tainted tag into lsu — error must not fire
    begin
        force `LSU.data_rvalid_i  = 1'b0;
        force `LSU.lsu_rdata_tag_o = 1'b1;
        #1;
        `CHECK_EQ("G5 lsu_tag_err_o=0 when data_rvalid_i=0", probe_lsu_tag_err, 1'b0)
        release `LSU.data_rvalid_i;
        release `LSU.lsu_rdata_tag_o;
    end

    // G6: No spurious DIFT exception after all tests
    wait_cyc(5);
    `CHECK_EQ("G6 no spurious DIFT exception at end of suite", dut.irq_dift, 1'b0)

    // =========================================================================
    // REPORT
    // =========================================================================
    $display("\n╔═════════════════════════════════════╗");
    $display("║  TEST COMPLETE                      ║");
    $display("║  PASS : %3d                          ║", pass_count);
    $display("║  FAIL : %3d                          ║", fail_count);
    $display("╚═════════════════════════════════════╝\n");
    if (fail_count == 0) $display("ALL TESTS PASSED ✓");
    else                 $display("FAILURES — see FAIL lines above");

    $finish;
end

// ─── Watchdog ────────────────────────────────────────────────────────────────
initial begin
    #10_000_000;
    $display("WATCHDOG: simulation limit exceeded");
    $finish;
end

// ─── VCD dump ────────────────────────────────────────────────────────────────
initial begin
    $dumpfile("tb_dift_debug.vcd");
    $dumpvars(0, tb_dift_debug_integration);
end

endmodule
