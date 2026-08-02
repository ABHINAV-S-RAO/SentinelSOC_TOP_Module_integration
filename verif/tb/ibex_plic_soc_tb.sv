// =============================================================================
// ibex_plic_soc_tb.sv
// Ibex + soc_addr_decode + PLIC integration bench (real SoC routing path).
// CTRL/BUF/SHA/APB/DBG tied to error-responder defaults — not under test here.
// Requires -define DIFT — this core build does not support a no-DIFT config.
// =============================================================================
`timescale 1ns/1ps

module ibex_plic_soc_tb;
  import ibex_pkg::*;

  localparam CLK_PERIOD = 10;
  logic clk, rst_n;
  initial clk = 0;
  always #(CLK_PERIOD/2) clk = ~clk;

  localparam logic [31:0] BOOT_ADDR   = 32'h0000_0000; // matches BOOTROM_BASE
  localparam logic [31:0] ISRAM_BASE  = 32'h0001_0000; // matches soc_addr_decode default
  localparam int          HANDLER_IDX = 256;
  localparam logic [31:0] MTVEC_VAL   = BOOT_ADDR + (HANDLER_IDX * 4);
  localparam logic [31:0] PLIC_CC     = 32'h0C20_0004;
  localparam logic [31:0] PLIC_PRIO1  = 32'h0C00_0004;
  localparam logic [31:0] PLIC_IE     = 32'h0C00_2000;
  localparam logic [31:0] PLIC_THRESH = 32'h0C20_0000;

  // ---- ibex <-> decoder flat signals ----
  logic        instr_req, instr_gnt, instr_rvalid;
  logic [31:0] instr_addr, instr_rdata;
  logic        instr_err;
  logic        data_req, data_gnt, data_rvalid, data_we;
  logic [3:0]  data_be;
  logic [31:0] data_addr, data_wdata, data_rdata;
  logic        data_err;

  logic        dummy_instr_id, dummy_instr_wb;
  logic [4:0]  rf_raddr_a, rf_raddr_b, rf_waddr_wb;
  logic        rf_we_wb;
  logic [31:0] rf_wdata_wb_ecc, rf_rdata_a_ecc, rf_rdata_b_ecc;

  logic [IC_NUM_WAYS-1:0]  ic_tag_req, ic_data_req;
  logic                    ic_tag_write, ic_data_write;
  logic [IC_INDEX_W-1:0]   ic_tag_addr, ic_data_addr;
  logic [IC_TAG_SIZE-1:0]  ic_tag_wdata;
  logic [IC_LINE_SIZE-1:0] ic_data_wdata;

  logic        irq_software, irq_timer, irq_external, irq_nm;
  logic [14:0] irq_fast;
  logic        irq_pending, debug_req, double_fault;
  crash_dump_t crash_dump;
  logic        alert_minor, alert_major_int, alert_major_bus;
  ibex_mubi_t  core_busy;

  // DIFT tag ports — tied off / observed, not under test in this harness
  logic data_wdata_tag;   // confirm actual width against ibex_core.sv:184 if not 7 bits
  logic data_rdata_tag;
  logic       dift_exception;

  assign data_rdata_tag = '0;   // no incoming taint on this harness's memory model

  assign irq_software = 1'b0;
  assign irq_timer    = 1'b0;
  assign irq_nm       = 1'b0;
  assign irq_fast     = 15'b0;
  assign debug_req    = 1'b0;

  // ---- decoder <-> slave flat signals ----
  logic bootrom_req, bootrom_gnt, bootrom_rvalid;
  logic [31:0] bootrom_addr, bootrom_rdata;
  logic bootrom_err;

  logic isram_req, isram_gnt, isram_rvalid, isram_we;
  logic [3:0] isram_be;
  logic [31:0] isram_addr, isram_wdata, isram_rdata;
  logic isram_err;

  logic plic_req, plic_gnt, plic_rvalid, plic_we;
  logic [3:0] plic_be;
  logic [31:0] plic_addr, plic_wdata, plic_rdata;
  logic plic_err;

  // ---- ibex_core ----
  ibex_core #(
    .PMPEnable(1'b0), .MHPMCounterNum(0), .RV32M(RV32MFast), .RV32B(RV32BNone),
    .WritebackStage(1'b0), .BranchTargetALU(1'b0), .ICache(1'b0),
    .BranchPredictor(1'b0), .DbgTriggerEn(1'b0), .SecureIbex(1'b0),
    .DummyInstructions(1'b0), .RegFileECC(1'b0), .MemECC(1'b0), .ResetAll(1'b0)
  ) dut (
    .clk_i(clk), .rst_ni(rst_n),
    .hart_id_i(32'h0), .boot_addr_i(BOOT_ADDR),

    .instr_req_o(instr_req), .instr_gnt_i(instr_gnt),
    .instr_rvalid_i(instr_rvalid), .instr_addr_o(instr_addr),
    .instr_rdata_i(instr_rdata), .instr_err_i(instr_err),

    .data_req_o(data_req), .data_gnt_i(data_gnt),
    .data_rvalid_i(data_rvalid), .data_we_o(data_we), .data_be_o(data_be),
    .data_addr_o(data_addr), .data_wdata_o(data_wdata),
    .data_rdata_i(data_rdata), .data_err_i(data_err),
    .data_wdata_tag_o(data_wdata_tag),
    .data_rdata_tag_i(data_rdata_tag),
    .dift_exception_o(dift_exception),

    .dummy_instr_id_o(dummy_instr_id), .dummy_instr_wb_o(dummy_instr_wb),
    .rf_raddr_a_o(rf_raddr_a), .rf_raddr_b_o(rf_raddr_b),
    .rf_waddr_wb_o(rf_waddr_wb), .rf_we_wb_o(rf_we_wb),
    .rf_wdata_wb_ecc_o(rf_wdata_wb_ecc),
    .rf_rdata_a_ecc_i(rf_rdata_a_ecc), .rf_rdata_b_ecc_i(rf_rdata_b_ecc),

    .ic_tag_req_o(ic_tag_req), .ic_tag_write_o(ic_tag_write),
    .ic_tag_addr_o(ic_tag_addr), .ic_tag_wdata_o(ic_tag_wdata),
    .ic_tag_rdata_i('{default:'0}),
    .ic_data_req_o(ic_data_req), .ic_data_write_o(ic_data_write),
    .ic_data_addr_o(ic_data_addr), .ic_data_wdata_o(ic_data_wdata),
    .ic_data_rdata_i('{default:'0}),
    .ic_scr_key_valid_i(1'b1), .ic_scr_key_req_o(),

    .irq_software_i(irq_software), .irq_timer_i(irq_timer),
    .irq_external_i(irq_external), .irq_fast_i(irq_fast), .irq_nm_i(irq_nm),
    .irq_pending_o(irq_pending),

    .debug_req_i(debug_req), .crash_dump_o(crash_dump),
    .double_fault_seen_o(double_fault),

    .fetch_enable_i(IbexMuBiOn), .alert_minor_o(alert_minor),
    .alert_major_internal_o(alert_major_int), .alert_major_bus_o(alert_major_bus),
    .core_busy_o(core_busy)
  );

  // ---- register file ----
  logic [31:0] reg_file [0:31];
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) for (int i = 0; i < 32; i++) reg_file[i] <= 32'h0;
    else if (rf_we_wb && rf_waddr_wb != 5'd0) reg_file[rf_waddr_wb] <= rf_wdata_wb_ecc;
  end
  assign rf_rdata_a_ecc = reg_file[rf_raddr_a];
  assign rf_rdata_b_ecc = reg_file[rf_raddr_b];

  // ---- real SoC address decode ----
  soc_addr_decode u_addr_decode (
    .clk_i(clk), .rst_ni(rst_n),

    .instr_req_i(instr_req), .instr_gnt_o(instr_gnt),
    .instr_rvalid_o(instr_rvalid), .instr_addr_i(instr_addr),
    .instr_rdata_o(instr_rdata), .instr_err_o(instr_err),

    .data_req_i(data_req), .data_gnt_o(data_gnt),
    .data_rvalid_o(data_rvalid), .data_we_i(data_we), .data_be_i(data_be),
    .data_addr_i(data_addr), .data_wdata_i(data_wdata),
    .data_rdata_o(data_rdata), .data_err_o(data_err),

    .bootrom_req_o(bootrom_req), .bootrom_gnt_i(bootrom_gnt),
    .bootrom_rvalid_i(bootrom_rvalid), .bootrom_addr_o(bootrom_addr),
    .bootrom_we_o(), .bootrom_be_o(), .bootrom_wdata_o(),
    .bootrom_rdata_i(bootrom_rdata), .bootrom_err_i(bootrom_err),

    .isram_req_o(isram_req), .isram_gnt_i(isram_gnt),
    .isram_rvalid_i(isram_rvalid), .isram_addr_o(isram_addr),
    .isram_we_o(isram_we), .isram_be_o(isram_be),
    .isram_wdata_o(isram_wdata), .isram_rdata_i(isram_rdata),
    .isram_err_i(isram_err),
    .ctrl_isram_lock_i(1'b0),

    .boot_done_i(1'b1), .dbg_mode_i(1'b0), .fw_verified_i(1'b1),

    .dsram_req_o(), .dsram_gnt_i(1'b0), .dsram_rvalid_i(1'b0),
    .dsram_addr_o(), .dsram_we_o(), .dsram_be_o(), .dsram_wdata_o(),
    .dsram_rdata_i(32'h0), .dsram_err_i(1'b1),

    .ctrl_req_o(), .ctrl_gnt_i(1'b0), .ctrl_rvalid_i(1'b0),
    .ctrl_addr_o(), .ctrl_we_o(), .ctrl_be_o(), .ctrl_wdata_o(),
    .ctrl_rdata_i(32'h0), .ctrl_err_i(1'b1),

    .buf_req_o(), .buf_gnt_i(1'b0), .buf_rvalid_i(1'b0),
    .buf_addr_o(), .buf_we_o(), .buf_be_o(), .buf_wdata_o(),
    .buf_rdata_i(32'h0), .buf_err_i(1'b1),

    .sha_req_o(), .sha_gnt_i(1'b0), .sha_rvalid_i(1'b0),
    .sha_addr_o(), .sha_we_o(), .sha_be_o(), .sha_wdata_o(),
    .sha_rdata_i(32'h0), .sha_err_i(1'b1),

    .plic_req_o(plic_req), .plic_gnt_i(plic_gnt),
    .plic_rvalid_i(plic_rvalid), .plic_addr_o(plic_addr),
    .plic_we_o(plic_we), .plic_be_o(plic_be), .plic_wdata_o(plic_wdata),
    .plic_rdata_i(plic_rdata), .plic_err_i(plic_err),

    .apb_req_o(), .apb_gnt_i(1'b0), .apb_rvalid_i(1'b0),
    .apb_addr_o(), .apb_we_o(), .apb_be_o(), .apb_wdata_o(),
    .apb_rdata_i(32'h0), .apb_err_i(1'b1),

    .dbg_req_o(), .dbg_addr_o(), .dbg_we_o(), .dbg_be_o(), .dbg_wdata_o(),
    .dbg_gnt_i(1'b0), .dbg_rvalid_i(1'b0), .dbg_rdata_i(32'h0)
  );

  // ---- BootROM (test program preloaded before reset via hierarchical write) ----
  soc_bootrom #(.NumWords(1024)) u_bootrom (
    .clk_i(clk), .rst_ni(rst_n),
    .req_i(bootrom_req), .addr_i(bootrom_addr),
    .rdata_o(bootrom_rdata), .rvalid_o(bootrom_rvalid),
    .gnt_o(bootrom_gnt), .err_o(bootrom_err)
  );

  // ---- ISRAM (used for claim-id scratch check) ----
  soc_sram #(.NumWords(1024)) u_isram (
    .clk_i(clk), .rst_ni(rst_n),
    .req_i(isram_req), .we_i(isram_we), .be_i(isram_be),
    .addr_i(isram_addr), .wdata_i(isram_wdata),
    .rdata_o(isram_rdata), .rvalid_o(isram_rvalid),
    .gnt_o(isram_gnt), .err_o(isram_err)
  );

  // ---- PLIC + reg-bus adapter (verbatim pattern from soc_top.sv) ----
  typedef struct packed {
    logic        valid;
    logic        write;
    logic [31:0] addr;
    logic [31:0] wdata;
    logic [3:0]  wstrb;
  } plic_reg_req_t;
  typedef struct packed {
    logic        ready;
    logic        error;
    logic [31:0] rdata;
  } plic_reg_rsp_t;

  logic [11:0] irq_src;
  logic [0:0]  eip_targets;
  plic_reg_req_t plic_reg_req;
  plic_reg_rsp_t plic_reg_rsp;

  assign plic_gnt           = plic_req;
  assign plic_reg_req.valid = plic_req;
  assign plic_reg_req.write = plic_we;
  assign plic_reg_req.addr  = plic_addr;
  assign plic_reg_req.wdata = plic_wdata;
  assign plic_reg_req.wstrb = plic_be;

  always_ff @(posedge clk or negedge rst_n)
    if (!rst_n) plic_rvalid <= 1'b0;
    else        plic_rvalid <= plic_req & plic_gnt;

  assign plic_rdata = plic_reg_rsp.rdata;
  assign plic_err   = plic_reg_rsp.error;

  plic_top #(
    .N_SOURCE(12), .N_TARGET(1), .MAX_PRIO(3),
    .reg_req_t(plic_reg_req_t), .reg_rsp_t(plic_reg_rsp_t)
  ) u_plic (
    .clk_i(clk), .rst_ni(rst_n),
    .req_i(plic_reg_req), .resp_o(plic_reg_rsp),
    .le_i(12'h0),
    .irq_sources_i(irq_src),
    .eip_targets_o(eip_targets)
  );
  assign irq_external = eip_targets[0];

  // ---- instruction encoder helpers ----
  function automatic logic [31:0] f_itype(input logic [11:0] imm, input logic [4:0] rs1, rd,
    input logic [2:0] funct3, input logic [6:0] opcode);
    return {imm, rs1, funct3, rd, opcode};
  endfunction
  function automatic logic [31:0] f_stype(input logic [11:0] imm, input logic [4:0] rs2, rs1,
    input logic [2:0] funct3);
    return {imm[11:5], rs2, rs1, funct3, imm[4:0], 7'h23};
  endfunction
  function automatic logic [31:0] f_utype(input logic [19:0] imm20, input logic [4:0] rd,
    input logic [6:0] opcode);
    return {imm20, rd, opcode};
  endfunction
  function automatic logic [31:0] f_csrrw(input logic [11:0] csr, input logic [4:0] rs1, rd);
    return {csr, rs1, 3'b001, rd, 7'h73};
  endfunction
  function automatic logic [31:0] f_csrrs(input logic [11:0] csr, input logic [4:0] rs1, rd);
    return {csr, rs1, 3'b010, rd, 7'h73};
  endfunction
  function automatic logic [31:0] f_addi(input logic [4:0] rd, rs1, input logic [11:0] imm);
    return f_itype(imm, rs1, rd, 3'b000, 7'h13);
  endfunction
  function automatic logic [31:0] f_lui(input logic [4:0] rd, input logic [19:0] imm);
    return f_utype(imm, rd, 7'h37);
  endfunction
  function automatic logic [31:0] f_lw(input logic [4:0] rd, rs1, input logic [11:0] imm);
    return f_itype(imm, rs1, rd, 3'b010, 7'h03);
  endfunction
  function automatic logic [31:0] f_sw(input logic [4:0] rs2, rs1, input logic [11:0] imm);
    return f_stype(imm, rs2, rs1, 3'b010);
  endfunction
  function automatic logic [31:0] f_beq(input logic [4:0] rs1, rs2, input logic [12:0] imm);
    return {imm[12], imm[10:5], rs2, rs1, 3'b000, imm[4:1], imm[11], 7'h63};
  endfunction

  localparam logic [31:0] MRET = 32'h3020_0073;
  localparam logic [11:0] CSRA_MTVEC   = 12'h305;
  localparam logic [11:0] CSRA_MSTATUS = 12'h300;
  localparam logic [11:0] CSRA_MIE     = 12'h304;

  int pc_wr;
  task automatic emit(input logic [31:0] insn);
    u_bootrom.mem[pc_wr++] = insn;
  endtask

  task automatic load_imm32(input logic [4:0] rd, input logic [31:0] val);
    logic [31:0] hi; logic [11:0] lo;
    lo = val[11:0];
    hi = val[31:12] + (val[11] ? 20'h1 : 20'h0);
    if (hi != 20'h0) emit(f_lui(rd, hi));
    else              emit(f_addi(rd, 5'd0, 12'h0));
    if (lo != 12'h0)  emit(f_addi(rd, rd, lo));
    else              emit(f_addi(rd, rd, 12'h0));
  endtask

  // ---- ISR: claim, store claimed id into ISRAM[0], complete, mret ----
  task automatic write_handler();
    automatic int h = HANDLER_IDX;
    pc_wr = h;
    load_imm32(5'd30, PLIC_CC);
    emit(f_lw(5'd31, 5'd30, 12'h0));          // claim
    load_imm32(5'd29, ISRAM_BASE);
    emit(f_sw(5'd31, 5'd29, 12'h0));          // record claimed id
    emit(f_sw(5'd31, 5'd30, 12'h0));          // complete
    emit(MRET);
    for (int i = pc_wr; i < HANDLER_IDX + 64; i++) u_bootrom.mem[i] = 32'h0000_0013; // NOP
  endtask

  // ---- reset ----
  task automatic do_reset();
    rst_n = 0;
    for (int i = 0; i < 32; i++) reg_file[i] = 32'h0;
    irq_src = 12'h0;
    repeat(3) @(posedge clk);
    rst_n = 1;
    @(posedge clk);
  endtask

  int pass_count, fail_count;
  task automatic pass_t(input string msg); $display("[PASS] %s", msg); pass_count++; endtask
  task automatic fail_t(input string msg); $display("[FAIL] %s", msg); fail_count++; endtask

  logic [31:0] mcause_at_trap_q;
  logic        trap_seen_q;    
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      mcause_at_trap_q <= 32'h0;
      trap_seen_q      <= 1'b0;
    end else if (!trap_seen_q && dut.pc_id >= HANDLER_IDX*4 && dut.pc_id < (HANDLER_IDX+64)*4) begin
      mcause_at_trap_q <= dut.cs_registers_i.csr_mcause_i;
      trap_seen_q      <= 1'b1;
    end
  end

  // =========================================================================
  // Test: source 1 fires -> trap -> ISR claims/records/completes -> mret ->
  // main loop resumes and keeps counting (proves clean return, not a hang).
  // =========================================================================
  task automatic plic_irq_test();
    logic [12:0] back_off;
    int loop_word;

    pc_wr = 0;

    load_imm32(5'd28, MTVEC_VAL);
    emit(f_csrrw(CSRA_MTVEC, 5'd28, 5'd0));

    load_imm32(5'd29, 32'h8);              // mstatus.MIE
    emit(f_csrrs(CSRA_MSTATUS, 5'd29, 5'd0));

    load_imm32(5'd29, 32'h800);            // mie.MEIE
    emit(f_csrrs(CSRA_MIE, 5'd29, 5'd0));

    load_imm32(5'd10, PLIC_PRIO1);
    load_imm32(5'd11, 32'd2);
    emit(f_sw(5'd11, 5'd10, 12'h0));

    load_imm32(5'd10, PLIC_IE);
    load_imm32(5'd11, 32'h2);
    emit(f_sw(5'd11, 5'd10, 12'h0));

    load_imm32(5'd10, PLIC_THRESH);
    emit(f_sw(5'd0, 5'd10, 12'h0));

    // main loop: x16 counts iterations forever
    loop_word = pc_wr;
    emit(f_addi(5'd16, 5'd16, 12'h001));
    back_off = -13'sd4;
    emit(f_beq(5'd0, 5'd0, back_off));

    write_handler();
    do_reset();

    fork
      begin
        repeat(80) @(posedge clk);
        irq_src[0] = 1'b1;   // physical wire 0 = register ID 1
      end
      begin
        repeat(500) @(posedge clk);
      end
    join
    
    if (u_isram.mem[0] == 32'd1)
      pass_t("PLIC SoC-routed IRQ: correct source claimed via real addr decode");
    else
      fail_t($sformatf("PLIC SoC-routed IRQ: ISRAM[0]=%0d (expected claimed id 1)",
                        u_isram.mem[0]));

    if (reg_file[16] > 32'd5)
      pass_t("Core resumed normal execution after mret (loop counter advancing)");
    else
      fail_t($sformatf("Core did not resume cleanly: x16=%0d", reg_file[16]));

    if (mcause_at_trap_q == 32'h8000_000B)
      pass_t("mcause correctly reflects machine external interrupt on trap entry");
    else
      fail_t($sformatf("mcause incorrect at trap entry: got 0x%h, expected 0x8000000B",mcause_at_trap_q));
  endtask

  initial begin
    pass_count = 0; fail_count = 0;
    for (int i = 0; i < 1024; i++) u_bootrom.mem[i] = 32'h0000_0013; // NOP fill
    plic_irq_test();
    $display("PLIC SoC INTEGRATION: %0d PASS / %0d FAIL", pass_count, fail_count);
    $finish;
  end

  initial begin
    #200_000;
    $display("[TIMEOUT] possible hang");
    $finish;
  end

 
  // debug trace — remove once confirmed working
  always @(posedge clk) begin
    if (rst_n)
        $display("[DBG] t=%0t pc=%h instr=%h mcause=%h irq_ext=%b plic_req=%b plic_addr=%h plic_we=%b dift_exc=%b data_req=%b data_gnt=%b data_rvalid=%b data_addr=%h data_we=%b isram_req=%b isram_gnt=%b isram_rvalid=%b lsu_resp_valid=%b lsu_req=%b lsu_req_done=%b id_in_ready=%b ex_valid=%b instr_valid_id=%b",
          $time, dut.pc_id, dut.instr_rdata_id, dut.cs_registers_i.csr_mcause_i, irq_external,
          plic_req, plic_addr, plic_we, dift_exception,
          data_req, data_gnt, data_rvalid, data_addr, data_we,
          isram_req, isram_gnt, isram_rvalid, dut.lsu_resp_valid, dut.lsu_req, dut.lsu_req_done, dut.id_in_ready, dut.ex_valid, dut.instr_valid_id);
  end

endmodule