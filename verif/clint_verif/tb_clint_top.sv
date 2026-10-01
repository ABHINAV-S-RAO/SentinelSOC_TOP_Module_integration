// =============================================================================
// tb_clint_top.sv
// CLINT Verification Top-Level Testbench
//
// DUT: sentinel_soc_top (full SoC instantiation)
//
// The CLINT (Core Local INTerrupt controller) inside sentinel_soc_top is
// accessed via the SoC's OBI memory map.  This bench drives the CLINT's
// OBI slave port indirectly — through a bypass interface wired alongside
// the SoC's internal clint_* wires — to keep the testbench self-contained
// without modifying sentinel_soc_top's external port list.
//
// Register map tested (CLINT base = 0x0200_0000, offsets per clint_obi.sv):
//   0x0200_0000  msip        (1-bit, RW)
//   0x0200_4000  mtimecmp_lo (32-bit, RW)
//   0x0200_4004  mtimecmp_hi (32-bit, RW)
//   0x020B_FF8   mtime_lo    (32-bit, RW) — note 16-bit offset 0xBFF8
//   0x020B_FFC   mtime_hi    (32-bit, RW) — note 16-bit offset 0xBFFC
//
// Test phases:
//   Phase 0 — plumbing / reset sanity
//   Phase 1 — MSIP register read/write + msip_o output check
//   Phase 2 — mtime free-running increment observation
//   Phase 3 — mtimecmp write + mtip_o assertion when mtime >= mtimecmp
//   Phase 4 — mtimecmp update clears mtip_o (re-arms timer)
//   Phase 5 — mtime direct write (preset counter)
//   Phase 6 — boundary: mtimecmp == mtime (mtip_o must assert, >= is strict)
//   Phase 7 — unmapped address → err_o asserted, no side-effects
// =============================================================================

import clint_tb_pkg::*;

module tb_clint_top;

  timeunit 1ns;
  timeprecision 1ps;

  localparam time CLK_PERIOD = 10ns; // 100 MHz

  // ---------------------------------------------------------------------------
  // Clock & reset
  // ---------------------------------------------------------------------------
  logic clk_i;
  logic rst_ni;

  initial  clk_i = 1'b0;
  always #(CLK_PERIOD/2) clk_i = ~clk_i;

  initial begin
    rst_ni = 1'b0;
    repeat (8) @(posedge clk_i);
    @(negedge clk_i);
    rst_ni = 1'b1;
  end

  // ---------------------------------------------------------------------------
  // CLINT OBI interface — drives the clint_obi slave port directly inside
  // the SoC.  sentinel_soc_top does not expose an external CLINT port, so
  // we wire a parallel interface to the internal net names via a bind or
  // by driving the DUT's CLINT wires directly from the TB using the
  // force/release mechanism (acceptable for block-level directed tests).
  //
  // In this bench the clint_if is wired to the DUT's internal clint_* nets
  // using hierarchical references so the SoC top port list is untouched.
  // ---------------------------------------------------------------------------
  clint_if u_clint_if (.clk_i(clk_i), .rst_ni(rst_ni));

  // ---------------------------------------------------------------------------
  // DUT — full SoC top
  // Tie off all external IO not exercised by the CLINT bench
  // ---------------------------------------------------------------------------

  // QSPI (bidir) — tied to weak pull-up via 'z' (no external flash needed)
  logic       qspi_csn_o;
  logic       qspi_clk_o;
  wire  [3:0] qspi_io_io = 4'bzzzz;

  // SPI
  logic spi_csn_o;
  logic spi_clk_o;
  logic spi_mosi_o;
  logic spi_miso_i;
  assign spi_miso_i = 1'b1;

  // UART
  logic uart_tx_o;
  logic uart_rx_i;
  assign uart_rx_i = 1'b1; // idle

  // GPIO (bidir)
  wire [31:0] gpio_io = {32{1'bz}};

  // JTAG — unused, tie to safe values
  logic jtag_tck_i   = 1'b0;
  logic jtag_tms_i   = 1'b1; // BYPASS
  logic jtag_tdi_i   = 1'b0;
  logic jtag_tdo_o;
  logic jtag_trst_ni = 1'b0; // assert JTAG reset

  sentinel_soc_top u_dut (
    .clk_i       (clk_i),
    .rst_ni      (rst_ni),

    .qspi_csn_o  (qspi_csn_o),
    .qspi_clk_o  (qspi_clk_o),
    .qspi_io_io  (qspi_io_io),

    .spi_csn_o   (spi_csn_o),
    .spi_clk_o   (spi_clk_o),
    .spi_mosi_o  (spi_mosi_o),
    .spi_miso_i  (spi_miso_i),

    .uart_tx_o   (uart_tx_o),
    .uart_rx_i   (uart_rx_i),

    .gpio_io     (gpio_io),

    .jtag_tck_i  (jtag_tck_i),
    .jtag_tms_i  (jtag_tms_i),
    .jtag_tdi_i  (jtag_tdi_i),
    .jtag_tdo_o  (jtag_tdo_o),
    .jtag_trst_ni(jtag_trst_ni)
  );

  // ---------------------------------------------------------------------------
  // Wire the clint_if directly to the clint_obi DUT slave port inside the SoC.
  // The CLINT is now properly integrated into soc_addr_decode (SEL_CLINT slot),
  // so normal SoC data-bus traffic at 0x0200_xxxx reaches u_clint via the
  // demux.  For this block-level bench we still drive u_clint's OBI port
  // directly via hierarchical references so the bench is self-contained and
  // does not depend on Ibex/bootrom being live.  The soc_addr_decode CLINT
  // output wires (u_dut.clint_req, etc.) feed directly into u_clint.req_i,
  // so the hierarchical assigns below are consistent with the RTL wiring.
  // ---------------------------------------------------------------------------

  // Observe DUT outputs
  logic msip_o;
  logic mtip_o;
  assign msip_o = u_dut.u_clint.msip_o;
  assign mtip_o = u_dut.u_clint.mtip_o;

  // Force-drive the CLINT OBI inputs via the interface so the TB controls
  // the CLINT directly without going through the full address decoder +
  // Ibex pipeline.  This is valid for a dedicated CLINT block-level bench.
  always @(*) begin
    force u_dut.u_clint.req_i   = u_clint_if.req;
    force u_dut.u_clint.addr_i  = u_clint_if.addr;
    force u_dut.u_clint.we_i    = u_clint_if.we;
    force u_dut.u_clint.be_i    = u_clint_if.be;
    force u_dut.u_clint.wdata_i = u_clint_if.wdata;
  end

  initial begin
    // Hold Ibex core in reset to prevent it from fetching X instructions
    // from uninitialized memory and failing assertions in this CLINT bench.
    force u_dut.u_ibex_top.rst_ni = 1'b0;
  end


  assign u_clint_if.gnt    = u_dut.u_clint.gnt_o;
  assign u_clint_if.rvalid = u_dut.u_clint.rvalid_o;
  assign u_clint_if.rdata  = u_dut.u_clint.rdata_o;
  assign u_clint_if.err    = u_dut.u_clint.err_o;

  // ---------------------------------------------------------------------------
  // Testbench environment objects
  // ---------------------------------------------------------------------------
  clint_obi_driver drv;
  clint_model      mdl;
  clint_scoreboard scb;

  initial begin
    drv = new(u_clint_if.drv);
    mdl = new();
    scb = new(mdl);
  end

  // ---------------------------------------------------------------------------
  // Phase helper — wait N clocks after reset
  // ---------------------------------------------------------------------------
  task automatic wait_clks(int unsigned n);
    repeat (n) @(posedge clk_i);
  endtask

  // ===========================================================================
  // Phase 0 — plumbing / reset sanity
  // After reset: msip=0, mtimecmp=MAX, mtime=0 → mtip must be 0
  // ===========================================================================
  task automatic phase0_reset_sanity();
    logic [31:0] rd;
    $display("\n===== PHASE 0: reset sanity =====");

    wait_clks(2);

    // msip register should read 0
    drv.read(CLINT_MSIP, rd);
    scb.check32("phase0.msip_reg_reset_value", rd, 32'h0);
    scb.check("phase0.msip_o_low_on_reset",    msip_o, 1'b0);

    // mtime_lo should read a small non-zero value (has been running since rst_ni)
    // We just check that mtip is not asserted (mtimecmp is MAX)
    scb.check("phase0.mtip_o_low_on_reset", mtip_o, 1'b0);

    // mtimecmp reset value = 0xFFFFFFFFFFFFFFFF
    drv.read(CLINT_MTIMECMP_LO, rd);
    scb.check32("phase0.mtimecmp_lo_reset", rd, 32'hFFFF_FFFF);
    drv.read(CLINT_MTIMECMP_HI, rd);
    scb.check32("phase0.mtimecmp_hi_reset", rd, 32'hFFFF_FFFF);
  endtask

  // ===========================================================================
  // Phase 1 — MSIP register read/write + msip_o output
  // ===========================================================================
  task automatic phase1_msip();
    logic [31:0] rd;
    $display("\n===== PHASE 1: MSIP register =====");

    // Write 1 → msip
    drv.write_msip(1'b1);
    mdl.set_msip(1'b1);
    wait_clks(1);

    drv.read_msip(rd[0]);
    scb.check32("phase1.msip_reg_reads_1",  {31'h0, rd[0]}, 32'h1);
    scb.check("phase1.msip_o_asserted",     msip_o, mdl.expected_msip());

    // Write 0 → clear msip
    drv.write_msip(1'b0);
    mdl.set_msip(1'b0);
    wait_clks(1);

    drv.read_msip(rd[0]);
    scb.check32("phase1.msip_reg_reads_0",  {31'h0, rd[0]}, 32'h0);
    scb.check("phase1.msip_o_deasserted",   msip_o, mdl.expected_msip());

    // Write upper bits — only bit 0 should be stored (RW1C / RW mask)
    drv.write(CLINT_MSIP, 32'hDEAD_BEEF);
    wait_clks(1);
    drv.read(CLINT_MSIP, rd);
    scb.check32("phase1.msip_upper_bits_masked", rd, 32'h0000_0001);

    // Clean up
    drv.write_msip(1'b0);
    mdl.set_msip(1'b0);
    wait_clks(2);
  endtask

  // ===========================================================================
  // Phase 2 — mtime free-running increment
  // ===========================================================================
  task automatic phase2_mtime_increment();
    logic [31:0] rd_lo_a, rd_lo_b;
    $display("\n===== PHASE 2: mtime free-running increment =====");

    drv.read(CLINT_MTIME_LO, rd_lo_a);
    wait_clks(10);
    drv.read(CLINT_MTIME_LO, rd_lo_b);

    // rd_lo_b must be strictly greater than rd_lo_a (timer advanced)
    if (rd_lo_b > rd_lo_a) begin
      scb.pass_count++;
      $display("[SCB][PASS] phase2.mtime_is_incrementing  a=0x%08h b=0x%08h", rd_lo_a, rd_lo_b);
    end else begin
      scb.fail_count++;
      $error("[SCB][FAIL] phase2.mtime_is_incrementing  mtime did NOT advance: a=0x%08h b=0x%08h",
             rd_lo_a, rd_lo_b);
    end
  endtask

  // ===========================================================================
  // Phase 3 — mtimecmp write + mtip_o assertion
  // Write mtime to a known value, then set mtimecmp just above it;
  // then let mtime run up to / past mtimecmp and confirm mtip_o asserts.
  // ===========================================================================
  task automatic phase3_mtip_assertion();
    logic [63:0] t0;
    logic [31:0] rd;
    $display("\n===== PHASE 3: mtip_o assertion =====");

    // Preset mtime to a known value (stop jitter from phase 2 mtime reads)
    drv.write_mtime(64'h0000_0000_0000_0100);
    mdl.set_mtime(64'h0000_0000_0000_0100);
    wait_clks(1);

    // Set mtimecmp = mtime + 20 (asserts after ~20 cycles)
    drv.write_mtimecmp(64'h0000_0000_0000_0114); // 0x100 + 20 = 0x114
    mdl.set_mtimecmp(64'h0000_0000_0000_0114);
    scb.check("phase3.mtip_not_yet", mtip_o, 1'b0);

    // Wait long enough for mtime to reach mtimecmp
    wait_clks(30);

    // mtip_o should now be asserted
    scb.check("phase3.mtip_asserted_when_mtime_ge_cmp", mtip_o, 1'b1);

    // msip_o must remain unaffected
    scb.check("phase3.msip_unaffected", msip_o, 1'b0);
  endtask

  // ===========================================================================
  // Phase 4 — re-arm timer: write mtimecmp far ahead, mtip_o should clear
  // ===========================================================================
  task automatic phase4_mtip_rearm();
    $display("\n===== PHASE 4: mtip_o re-arm (clear) =====");

    // mtip should still be asserted from phase 3
    scb.check("phase4.mtip_still_asserted_entry", mtip_o, 1'b1);

    // Write mtimecmp = 0xFFFF_FFFF_FFFF_FFFF (effectively infinity)
    drv.write_mtimecmp(64'hFFFF_FFFF_FFFF_FFFF);
    mdl.set_mtimecmp(64'hFFFF_FFFF_FFFF_FFFF);
    wait_clks(2);

    // mtip_o must deassert
    scb.check("phase4.mtip_cleared_after_rearm", mtip_o, 1'b0);
  endtask

  // ===========================================================================
  // Phase 5 — direct mtime write (preset counter)
  // Verify the write path works and the counter resumes incrementing from
  // the written value.
  // ===========================================================================
  task automatic phase5_mtime_write();
    logic [63:0] mtime_read;
    logic [63:0] mtime_expected_min;
    $display("\n===== PHASE 5: mtime direct write =====");

    // Write mtime to a specific value
    drv.write_mtime(64'h0000_0000_CAFE_0000);
    mdl.set_mtime(64'h0000_0000_CAFE_0000);
    wait_clks(1);

    drv.read_mtime(mtime_read);
    mtime_expected_min = 64'h0000_0000_CAFE_0000;

    // Must be >= written value (counter may have advanced by a few cycles)
    if (mtime_read >= mtime_expected_min && mtime_read < 64'h0000_0000_CAFE_0020) begin
      scb.pass_count++;
      $display("[SCB][PASS] phase5.mtime_write_then_read  read=0x%016h", mtime_read);
    end else begin
      scb.fail_count++;
      $error("[SCB][FAIL] phase5.mtime_write_then_read  read=0x%016h out of expected range", mtime_read);
    end
  endtask

  // ===========================================================================
  // Phase 6 — boundary: mtimecmp == mtime (>= is non-strict, mtip asserts)
  // ===========================================================================
  task automatic phase6_boundary_equal();
    logic [31:0] rd;
    $display("\n===== PHASE 6: boundary mtime == mtimecmp =====");

    // Freeze mtime by writing a large value and immediately setting mtimecmp == that value
    // Use a large value so the counter doesn't overflow to 0 in the test window
    drv.write_mtime(64'h0000_0000_0000_F000);
    wait_clks(1); // let the write settle

    // Read back mtime_lo to get the current value (may have advanced 1 cycle)
    drv.read(CLINT_MTIME_LO, rd);
    // Set mtimecmp_lo == current mtime_lo and mtimecmp_hi = 0
    drv.write(CLINT_MTIMECMP_HI, 32'h0000_0000);
    drv.write(CLINT_MTIMECMP_LO, rd); // mtime_lo at the time of this write
    mdl.set_mtimecmp({32'h0, rd});

    wait_clks(2); // allow comparison logic to settle

    // mtip_o MUST be asserted (mtime >= mtimecmp, using >= semantics)
    scb.check("phase6.mtip_at_boundary_equal", mtip_o, 1'b1);

    // Re-arm for subsequent phases
    drv.write_mtimecmp(64'hFFFF_FFFF_FFFF_FFFF);
    mdl.set_mtimecmp(64'hFFFF_FFFF_FFFF_FFFF);
    wait_clks(2);
    scb.check("phase6.mtip_cleared_after_rearm", mtip_o, 1'b0);
  endtask

  // ===========================================================================
  // Phase 7 — unmapped address → err_o asserted, no state change
  // ===========================================================================
  task automatic phase7_unmapped_addr();
    logic [31:0] msip_before, msip_after;
    $display("\n===== PHASE 7: unmapped address error =====");

    drv.read(CLINT_MSIP, msip_before);

    // Access an unmapped offset (0x0001 is not a valid CLINT register)
    @(u_clint_if.drv_cb);
    u_clint_if.drv_cb.req  <= 1'b1;
    u_clint_if.drv_cb.addr <= CLINT_BASE + 32'h0000_0001; // byte 1 — unmapped
    u_clint_if.drv_cb.we   <= 1'b0;
    u_clint_if.drv_cb.be   <= 4'hF;
    @(u_clint_if.drv_cb);
    u_clint_if.drv_cb.req  <= 1'b0;
    // Wait for rvalid
    @(u_clint_if.drv_cb);
    scb.check("phase7.err_on_unmapped_read", u_clint_if.err, 1'b1);

    // Also try an unmapped write
    @(u_clint_if.drv_cb);
    u_clint_if.drv_cb.req   <= 1'b1;
    u_clint_if.drv_cb.addr  <= CLINT_BASE + 32'h0001_0000; // mid-gap — unmapped
    u_clint_if.drv_cb.we    <= 1'b1;
    u_clint_if.drv_cb.be    <= 4'hF;
    u_clint_if.drv_cb.wdata <= 32'hDEAD_BEEF;
    @(u_clint_if.drv_cb);
    u_clint_if.drv_cb.req <= 1'b0;
    u_clint_if.drv_cb.we  <= 1'b0;
    @(u_clint_if.drv_cb);
    scb.check("phase7.err_on_unmapped_write", u_clint_if.err, 1'b1);

    // msip register should be unmodified
    drv.read(CLINT_MSIP, msip_after);
    scb.check32("phase7.msip_unmodified_after_unmapped_write", msip_after, msip_before);
  endtask

  // ===========================================================================
  // Top-level test sequencer
  // ===========================================================================
  string test_name;

  initial begin
    // Initialise interface to idle state
    u_clint_if.req   = 1'b0;
    u_clint_if.addr  = '0;
    u_clint_if.we    = 1'b0;
    u_clint_if.be    = '0;
    u_clint_if.wdata = '0;

    // Wait for reset de-assertion
    wait (rst_ni === 1'b1);
    repeat (5) @(posedge clk_i);

    if (!$value$plusargs("TEST=%s", test_name)) test_name = "all";

    case (test_name)
      "phase0": phase0_reset_sanity();
      "phase1": phase1_msip();
      "phase2": phase2_mtime_increment();
      "phase3": phase3_mtip_assertion();
      "phase4": begin
        phase3_mtip_assertion();
        phase4_mtip_rearm();
      end
      "phase5": phase5_mtime_write();
      "phase6": phase6_boundary_equal();
      "phase7": phase7_unmapped_addr();
      "all": begin
        phase0_reset_sanity();
        phase1_msip();
        phase2_mtime_increment();
        phase3_mtip_assertion();
        phase4_mtip_rearm();
        phase5_mtime_write();
        phase6_boundary_equal();
        phase7_unmapped_addr();
      end
      default: $fatal(1, "Unknown +TEST=%s", test_name);
    endcase

    repeat (5) @(posedge clk_i);
    scb.report();
    $display("CLINT TEST DONE: %s", test_name);
    $finish;
  end

  // ---------------------------------------------------------------------------
  // Global simulation timeout
  // ---------------------------------------------------------------------------
  initial begin
    #5_000_000;
    $fatal(1, "Global timeout — a test phase hung");
  end

endmodule : tb_clint_top
