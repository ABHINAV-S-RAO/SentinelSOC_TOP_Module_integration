// tb_plic_top.sv
// Standalone PLIC verification top. Phase 8 (DIFT-tainted interrupt path)
// is NOT included here — it needs the core-level ibex_core_tb harness
// (claim -> ISR -> complete with a tainted destination register), not a
// PLIC-only bench. See note at bottom of file.
//
// ADAPT before compiling:
//   - plic_top port names/types (req_i/rsp_o vs discrete signals,
//     irq_src_i vs irq_i, output irq_o vs irq_external_o, id/msip ports)
//   - reg_req_t / reg_rsp_t package import (whatever soc_top.sv uses)
//   - MAX_PRIO(3) matches the fix already applied in soc_top.sv

import plic_tb_pkg::*;

module tb_plic_top;

  timeunit 1ns;
  timeprecision 1ps;

  localparam time CLK_PERIOD = 10ns;

  logic clk_i;
  logic rst_ni;

  plic_irq_if #(.N_SOURCE(N_SOURCE)) u_irq_if (.clk_i(clk_i));
  logic                irq_external;
  logic [31:0]         irq_id_unused;

  // ---- clock / reset ----
  initial clk_i = 0;
  always #(CLK_PERIOD/2) clk_i = ~clk_i;

  initial begin
    rst_ni = 0;
    u_irq_if.irq_src = '0;
    repeat (5) @(posedge clk_i);
    rst_ni = 1;
  end

  plic_reg_if u_if (.clk_i(clk_i), .rst_ni(rst_ni));

  // Local struct types matching the reg bus plic_top is generic over
  typedef struct packed {
    logic        valid;
    logic        write;
    logic [31:0] addr;
    logic [31:0] wdata;
    logic [3:0]  wstrb;
  } plic_reg_req_t;

  typedef struct packed {
    logic        ready;
    logic [31:0] rdata;
    logic        error;
  } plic_reg_rsp_t;

  plic_reg_req_t plic_req;
  plic_reg_rsp_t plic_rsp;
  logic [0:0]    eip_targets; // N_TARGET=1

  assign plic_req.valid = u_if.valid;
  assign plic_req.write = u_if.write;
  assign plic_req.addr  = u_if.addr;
  assign plic_req.wdata = u_if.wdata;
  assign plic_req.wstrb = u_if.wstrb;

  assign u_if.ready = plic_rsp.ready;
  assign u_if.rdata = plic_rsp.rdata;
  assign u_if.error = plic_rsp.error;

  assign irq_external = eip_targets[0];

  // ---- DUT ----
  plic_top #(
    .N_SOURCE  (N_SOURCE),
    .N_TARGET  (1),
    .MAX_PRIO  (3),
    .reg_req_t (plic_reg_req_t),
    .reg_rsp_t (plic_reg_rsp_t)
  ) u_dut (
    .clk_i,
    .rst_ni,
    .req_i          (plic_req),
    .resp_o         (plic_rsp),
    .le_i           ('0),               // all sources level-triggered
    .irq_sources_i  (u_irq_if.irq_src),
    .eip_targets_o  (eip_targets)
  );

  // ---- debug instrumentation, remove after root-causing ----
  always @(posedge clk_i) begin
    if (rst_ni)
      $display("[DBG] t=%0t irq_src=%b  gw.ip=%b  u_dut.ip=%b  claim=%b  ia=%b",
                $time, u_irq_if.irq_src,
                u_dut.i_rv_plic_gateway.ip,
                u_dut.ip,
                u_dut.i_rv_plic_gateway.claim,
                u_dut.i_rv_plic_gateway.ia);
  end

  // ---- TB env ----
  plic_reg_driver   reg_drv;
  irq_source_driver src_drv;
  plic_model        model;
  plic_scoreboard   scb;

  initial begin
    reg_drv = new(u_if.drv);
    src_drv = new(u_irq_if.drv);
    model   = new();
    scb     = new(model);
  end

  // ---------------------------------------------------------------------
  // Helper: assert a source and let its IP bit settle, updating model
  // ---------------------------------------------------------------------
  task automatic drive_source(int unsigned id, bit level);
    if (level) src_drv.assert_src(id);
    else       src_drv.deassert_src(id);
    model.set_src_level(id, level);
    @(posedge clk_i);
  endtask
  // ---------------------------------------------------------------------
  // Phase 0: plumbing sanity
  // ---------------------------------------------------------------------
  task automatic phase0_plumbing();
    logic [31:0] rd;
    $display("\n===== PHASE 0: plumbing =====");
    reg_drv.write_priority(1, 32'h3);
    model.set_priority(1, 32'h3);
    reg_drv.read_priority(1, rd);
    scb.check32("phase0.priority0_readback", rd, 32'h3);
  endtask

  // ---------------------------------------------------------------------
  // Phase 1: register sanity sweep
  // ---------------------------------------------------------------------
  task automatic phase1_reg_sweep();
    logic [31:0] rd;
    $display("\n===== PHASE 1: register sweep =====");
    for (int unsigned i = 0; i < N_SOURCE; i++) begin
      logic [31:0] val = i[1:0]; // 2-bit field per plic_regs
      reg_drv.write_priority(i, val);
      model.set_priority(i, val);
      reg_drv.read_priority(i, rd);
      scb.check32($sformatf("phase1.priority[%0d]", i), rd, val);
    end

    reg_drv.write_threshold(32'h1);
    model.set_threshold(32'h1);
    reg_drv.read_threshold(rd);
    scb.check32("phase1.threshold", rd, 32'h1);

    reg_drv.write_ie(32'hFFF);
    model.set_ie(32'hFFE);
    reg_drv.read_ie(rd);
    scb.check32("phase1.ie", rd, 32'hFFE);

    // reset threshold/ie for subsequent phases
    reg_drv.write_threshold(32'h0);
    model.set_threshold(32'h0);
    reg_drv.write_ie(32'h0);
    model.set_ie(32'h0);
  endtask

  // ---------------------------------------------------------------------
  // Phase 2: basic ip observation, IE=0 -> irq_external stays low
  // ---------------------------------------------------------------------
  task automatic phase2_ip_observation();
    logic [31:0] rd;
    $display("\n===== PHASE 2: IP observation (IE=0) =====");
    reg_drv.write_ie(32'h0);
    model.set_ie(32'h0);

    drive_source(1, 1); // irq_uart
    @(posedge clk_i);

    reg_drv.read_ip(rd);
    scb.check32("phase2.ip_bit1_set", rd, model.expected_ip());
    scb.check("phase2.irq_external_low", irq_external, 1'b0);

    drive_source(1, 0);
  endtask

  // ---------------------------------------------------------------------
  // Phase 3: enable + threshold gating
  // ---------------------------------------------------------------------
  task automatic phase3_enable_threshold();
    logic [31:0] rd;
    int unsigned wid; logic [2:0] wprio; bit found;
    $display("\n===== PHASE 3: enable + threshold gating =====");

    reg_drv.write_priority(2, 32'h2); model.set_priority(2, 32'h2); // irq_spi, prio 2
    reg_drv.write_ie(32'h1 << 2);     model.set_ie(32'h1 << 2);
    reg_drv.write_threshold(32'h2);   model.set_threshold(32'h2);  // strict >, so blocked at ==

    drive_source(2, 1);
    @(posedge clk_i);
    found = model.compute_expected(wid, wprio);
    scb.check("phase3.blocked_at_threshold_eq", irq_external, found);

    reg_drv.write_threshold(32'h1);   model.set_threshold(32'h1);  // now priority(2) > threshold(1)
    @(posedge clk_i);
    found = model.compute_expected(wid, wprio);
    scb.check("phase3.asserted_above_threshold", irq_external, found);
// ---- debug instrumentation, remove after root-causing ----
    drive_source(2, 0);
    reg_drv.write_threshold(32'h0); model.set_threshold(32'h0);
    reg_drv.write_ie(32'h0);        model.set_ie(32'h0);
  endtask

  // ---------------------------------------------------------------------
  // Phase 4: claim/complete handshake
  // ---------------------------------------------------------------------
  task automatic phase4_claim_complete();
    logic [31:0] cc_id, rd;
    $display("\n===== PHASE 4: claim/complete =====");

    reg_drv.write_priority(1, 32'h2); model.set_priority(1, 32'h2);
    reg_drv.write_ie(32'h1 << 1);     model.set_ie(32'h1 << 1);
    reg_drv.write_threshold(32'h0);   model.set_threshold(32'h0);

    drive_source(1, 1); // level held asserted throughout
    @(posedge clk_i);

    reg_drv.claim(cc_id);
    model.do_claim(1);
    scb.check32("phase4.claimed_id", cc_id, 32'd1);

    reg_drv.read_ip(rd);
    scb.check32("phase4.ip_clear_after_claim", rd, model.expected_ip());
    scb.check("phase4.irq_external_low_after_claim", irq_external, 1'b0);

    reg_drv.complete(cc_id);
    model.do_complete(1, 1'b1); // physical line still held -> re-pends
    @(posedge clk_i);

    reg_drv.read_ip(rd);
    scb.check32("phase4.ip_reset_after_complete_still_held", rd, model.expected_ip());

    drive_source(1, 0);
    reg_drv.write_ie(32'h0); model.set_ie(32'h0);
  endtask

  // ---------------------------------------------------------------------
  // Phase 5: multi-source arbitration (priority order + tie-break lowest ID)
  // ---------------------------------------------------------------------
  task automatic phase5_arbitration();
    logic [31:0] cc_id;
    int unsigned wid; logic [2:0] wprio;
    $display("\n===== PHASE 5: multi-source arbitration =====");

    reg_drv.write_priority(3, 32'h2); model.set_priority(3, 32'h2); // irq_qspi
    reg_drv.write_priority(5, 32'h2); model.set_priority(5, 32'h2); // irq_timer_periph, tie with 3
    reg_drv.write_priority(6, 32'h1); model.set_priority(6, 32'h1); // irq_buf, lower prio
    reg_drv.write_ie(32'b0110_1000);  model.set_ie(32'b0110_1000); // sources 3,5,6
    reg_drv.write_threshold(32'h0);   model.set_threshold(32'h0);

    drive_source(3, 1);
    drive_source(5, 1);
    drive_source(6, 1);
    @(posedge clk_i);

    void'(model.compute_expected(wid, wprio));
    reg_drv.claim(cc_id);
    model.do_claim(wid);
    scb.check32("phase5.winner_is_lowest_id_at_tied_max_prio", cc_id, wid);

    reg_drv.complete(cc_id);
    model.do_complete(wid, 1'b1);
    @(posedge clk_i);

    void'(model.compute_expected(wid, wprio));
    reg_drv.claim(cc_id);
    model.do_claim(wid);
    scb.check32("phase5.next_winner", cc_id, wid);

    reg_drv.complete(cc_id);
    model.do_complete(wid, 1'b1);
    drive_source(3, 0); drive_source(5, 0); drive_source(6, 0);
    reg_drv.write_ie(32'h0); model.set_ie(32'h0);
  endtask

  // ---------------------------------------------------------------------
  // Phase 6: dynamic reconfiguration under load
  // ---------------------------------------------------------------------
  task automatic phase6_dynamic_reconfig();
    int unsigned wid; logic [2:0] wprio; bit found;
    $display("\n===== PHASE 6: dynamic reconfiguration =====");

    reg_drv.write_priority(4, 32'h1); model.set_priority(4, 32'h1); // irq_gpio
    reg_drv.write_ie(32'h1 << 4);     model.set_ie(32'h1 << 4);
    reg_drv.write_threshold(32'h1);   model.set_threshold(32'h1); // blocked, prio(4)==threshold

    drive_source(4, 1);
    @(posedge clk_i);
    found = model.compute_expected(wid, wprio);
    scb.check("phase6.blocked_before_reconfig", irq_external, found);

    // raise priority mid-flight while source still asserted
    reg_drv.write_priority(4, 32'h3); model.set_priority(4, 32'h3);
    @(posedge clk_i);
    found = model.compute_expected(wid, wprio);
    scb.check("phase6.asserted_after_priority_raise", irq_external, found);

    // lower threshold mid-flight instead
    reg_drv.write_priority(4, 32'h1); model.set_priority(4, 32'h1);
    reg_drv.write_threshold(32'h0);   model.set_threshold(32'h0);
    @(posedge clk_i);
    found = model.compute_expected(wid, wprio);
    scb.check("phase6.asserted_after_threshold_drop", irq_external, found);

    drive_source(4, 0);
    reg_drv.write_ie(32'h0); model.set_ie(32'h0);
    reg_drv.write_threshold(32'h0); model.set_threshold(32'h0);
  endtask

  // ---------------------------------------------------------------------
  // Phase 7: priority-0 edge case (must never assert, even at THRESHOLD=0,
  // due to strict `>` comparison)
  // ---------------------------------------------------------------------
  task automatic phase7_priority_zero();
    logic [31:0] rd;
    $display("\n===== PHASE 7: priority-0 edge case =====");

    reg_drv.write_priority(7, 32'h0); model.set_priority(7, 32'h0); // irq_sha
    reg_drv.write_ie(32'h1 << 7);     model.set_ie(32'h1 << 7);
    reg_drv.write_threshold(32'h0);   model.set_threshold(32'h0);

    drive_source(7, 1);
    @(posedge clk_i);

    reg_drv.read_ip(rd);
    scb.check("phase7.ip_bit_set_despite_prio0", rd[7], 1'b1);
    scb.check("phase7.irq_external_never_asserts", irq_external, 1'b0);

    drive_source(7, 0);
    reg_drv.write_ie(32'h0); model.set_ie(32'h0);
  endtask

  // ---------------------------------------------------------------------
  // Sequencer
  // ---------------------------------------------------------------------
  string test_name;

  initial begin
    if (!$value$plusargs("TEST=%s", test_name)) test_name = "all";

    reg_drv.reset();
    wait (rst_ni === 1'b1);
    repeat (3) @(posedge clk_i);

    case (test_name)
      "phase0": phase0_plumbing();
      "phase1": phase1_reg_sweep();
      "phase2": phase2_ip_observation();
      "phase3": phase3_enable_threshold();
      "phase4": phase4_claim_complete();
      "phase5": phase5_arbitration();
      "phase6": phase6_dynamic_reconfig();
      "phase7": phase7_priority_zero();
      "all": begin
        phase0_plumbing();
        phase1_reg_sweep();
        phase2_ip_observation();
        phase3_enable_threshold();
        phase4_claim_complete();
        phase5_arbitration();
        phase6_dynamic_reconfig();
        phase7_priority_zero();
      end
      default: $fatal(1, "Unknown +TEST=%s", test_name);
    endcase

    scb.report();
    $display("PLIC TEST DONE: %s", test_name);
    $finish;
  end

  // Safety timeout
  initial begin
    #100000;
    $fatal(1, "Global timeout — a phase hung (likely missing ready/rvalid)");
  end

  // ---------------------------------------------------------------------
  // NOTE on Phase 8 (DIFT-tainted interrupt path):
  // This is a core+SoC-level scenario (claim -> ISR -> complete with a
  // tainted destination register), not something a PLIC-only bench can
  // exercise meaningfully. Once phases 0-7 pass here, phase 8 should be
  // added to ibex_core_tb.sv (or soc_top tb) reusing this plic_reg_driver
  // against the OBI-to-reg shim's memory-mapped view, with the DIFT tag
  // RF deposited on the ISR's destination register before claim.
  // ---------------------------------------------------------------------

endmodule