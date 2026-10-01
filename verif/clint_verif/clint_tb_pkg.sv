// =============================================================================
// clint_tb_pkg.sv
// Non-UVM, class-based CLINT testbench package.
//
// Style matches plic_tb_pkg.sv: plain SV classes, virtual interface handles,
// no uvm_pkg dependency.
//
// CLINT register map (standard RISC-V CLINT, base address 0x0200_0000):
//   Offset 0x0000 : msip      (RW, 1-bit, machine software interrupt pending)
//   Offset 0x4000 : mtimecmp_lo (RW, lower 32 bits of mtimecmp)
//   Offset 0x4004 : mtimecmp_hi (RW, upper 32 bits of mtimecmp)
//   Offset 0xBFF8 : mtime_lo    (RW, lower 32 bits of mtime)
//   Offset 0xBFFC : mtime_hi    (RW, upper 32 bits of mtime)
//
// For the block-level bench (tb_clint_top) the driver talks DIRECTLY to the
// clint_obi OBI slave port, bypassing the full SoC memory map.
// For the SoC-level bench the same driver is reused against the address-
// decoded OBI bus at the full CLINT_BASE addresses.
// =============================================================================

package clint_tb_pkg;

  // ---------------------------------------------------------------------------
  // Address offsets (relative to the base supplied to the driver task)
  // ---------------------------------------------------------------------------
  localparam logic [31:0] CLINT_MSIP         = 32'h0000_0000;
  localparam logic [31:0] CLINT_MTIMECMP_LO  = 32'h0000_4000;
  localparam logic [31:0] CLINT_MTIMECMP_HI  = 32'h0000_4004;
  localparam logic [31:0] CLINT_MTIME_LO     = 32'h0000_BFF8;
  localparam logic [31:0] CLINT_MTIME_HI     = 32'h0000_BFFC;

  // SoC-level absolute base of CLINT (used by tb_clint_soc_top only)
  localparam logic [31:0] CLINT_BASE         = 32'h0200_0000;

  // ===========================================================================
  // clint_obi_driver
  // Drives the clint_obi OBI slave port via a virtual clint_if handle.
  // All transactions are blocking (one-at-a-time) — matching the simple
  // always-ready (gnt=1) nature of clint_obi.
  // ===========================================================================
  class clint_obi_driver;
    virtual clint_if.drv vif;
    int unsigned timeout_cycles = 100;

    function new(virtual clint_if.drv vif);
      this.vif = vif;
    endfunction

    // -------------------------------------------------------------------------
    // idle : de-assert req, leave bus quiet
    // -------------------------------------------------------------------------
    task automatic idle();
      vif.drv_cb.req   <= 1'b0;
      vif.drv_cb.addr  <= '0;
      vif.drv_cb.we    <= 1'b0;
      vif.drv_cb.be    <= '0;
      vif.drv_cb.wdata <= '0;
    endtask

    // -------------------------------------------------------------------------
    // write : blocking OBI write.  gnt is always 1 from clint_obi so this
    // completes in one clock after req is asserted.
    // -------------------------------------------------------------------------
    task automatic write(
      input logic [31:0] addr,
      input logic [31:0] data,
      input logic [ 3:0] be = 4'hF
    );
      int unsigned n = 0;
      @(vif.drv_cb);
      vif.drv_cb.req   <= 1'b1;
      vif.drv_cb.addr  <= addr;
      vif.drv_cb.we    <= 1'b1;
      vif.drv_cb.be    <= be;
      vif.drv_cb.wdata <= data;
      // Wait for gnt (should be immediate — clint_obi ties gnt=1)
      do begin
        @(vif.drv_cb);
        n++;
        if (n > timeout_cycles)
          $error("[clint_obi_driver] WRITE timeout addr=0x%08h", addr);
      end while (!vif.drv_cb.gnt && n <= timeout_cycles);
      // De-assert after gnt
      vif.drv_cb.req <= 1'b0;
      vif.drv_cb.we  <= 1'b0;
      // Wait for rvalid (one cycle later)
      do begin
        @(vif.drv_cb);
      end while (!vif.drv_cb.rvalid);
      if (vif.drv_cb.err)
        $error("[clint_obi_driver] WRITE bus error addr=0x%08h", addr);
    endtask

    // -------------------------------------------------------------------------
    // read : blocking OBI read. Returns rdata by ref.
    // -------------------------------------------------------------------------
    task automatic read(
      input  logic [31:0] addr,
      output logic [31:0] data
    );
      int unsigned n = 0;
      @(vif.drv_cb);
      vif.drv_cb.req  <= 1'b1;
      vif.drv_cb.addr <= addr;
      vif.drv_cb.we   <= 1'b0;
      vif.drv_cb.be   <= 4'hF;
      do begin
        @(vif.drv_cb);
        n++;
        if (n > timeout_cycles)
          $error("[clint_obi_driver] READ timeout addr=0x%08h", addr);
      end while (!vif.drv_cb.gnt && n <= timeout_cycles);
      vif.drv_cb.req <= 1'b0;
      // Wait for rvalid and capture data
      do begin
        @(vif.drv_cb);
      end while (!vif.drv_cb.rvalid);
      if (vif.drv_cb.err)
        $error("[clint_obi_driver] READ bus error addr=0x%08h", addr);
      data = vif.drv_cb.rdata;
    endtask

    // -------------------------------------------------------------------------
    // Convenience wrappers
    // -------------------------------------------------------------------------
    task automatic write_msip(logic msip_val);
      write(CLINT_MSIP, {31'h0, msip_val});
    endtask

    task automatic read_msip(output logic msip_val);
      logic [31:0] rd;
      read(CLINT_MSIP, rd);
      msip_val = rd[0];
    endtask

    task automatic write_mtimecmp(input logic [63:0] cmp);
      // Write hi first to prevent spurious interrupt during split write
      write(CLINT_MTIMECMP_HI, cmp[63:32]);
      write(CLINT_MTIMECMP_LO, cmp[31:0]);
    endtask

    task automatic read_mtimecmp(output logic [63:0] cmp);
      logic [31:0] lo, hi;
      read(CLINT_MTIMECMP_LO, lo);
      read(CLINT_MTIMECMP_HI, hi);
      cmp = {hi, lo};
    endtask

    task automatic write_mtime(input logic [63:0] val);
      write(CLINT_MTIME_LO, val[31:0]);
      write(CLINT_MTIME_HI, val[63:32]);
    endtask

    task automatic read_mtime(output logic [63:0] val);
      logic [31:0] lo, hi;
      read(CLINT_MTIME_LO, lo);
      read(CLINT_MTIME_HI, hi);
      val = {hi, lo};
    endtask
  endclass

  // ===========================================================================
  // clint_model
  // Software reference model tracking msip / mtimecmp / mtime state and
  // predicting the expected msip_o / mtip_o outputs.
  //
  // mtime increment: one per clock cycle (matches clint_obi RTL).
  // ===========================================================================
  class clint_model;
    bit          msip_q;
    logic [63:0] mtimecmp_q;
    logic [63:0] mtime_q;

    function new();
      msip_q     = 1'b0;
      mtimecmp_q = 64'hFFFF_FFFF_FFFF_FFFF;
      mtime_q    = 64'h0;
    endfunction

    // Called once per clock cycle to advance mtime
    function automatic void tick();
      mtime_q = mtime_q + 64'h1;
    endfunction

    function automatic void set_msip(bit v);
      msip_q = v;
    endfunction

    function automatic void set_mtimecmp(logic [63:0] cmp);
      mtimecmp_q = cmp;
    endfunction

    function automatic void set_mtime(logic [63:0] val);
      mtime_q = val;
    endfunction

    function automatic bit expected_msip();
      return msip_q;
    endfunction

    function automatic bit expected_mtip();
      return (mtime_q >= mtimecmp_q);
    endfunction
  endclass

  // ===========================================================================
  // clint_scoreboard
  // Compares DUT observations against clint_model predictions.
  // ===========================================================================
  class clint_scoreboard;
    clint_model  model;
    int unsigned pass_count = 0;
    int unsigned fail_count = 0;

    function new(clint_model model);
      this.model = model;
    endfunction

    function automatic void check(string tag, logic actual, logic expected);
      if (actual === expected) begin
        pass_count++;
        $display("[SCB][PASS] %-45s actual=%0b expected=%0b", tag, actual, expected);
      end else begin
        fail_count++;
        $error("[SCB][FAIL] %-45s actual=%0b expected=%0b", tag, actual, expected);
      end
    endfunction

    function automatic void check32(string tag, logic [31:0] actual, logic [31:0] expected);
      if (actual === expected) begin
        pass_count++;
        $display("[SCB][PASS] %-45s actual=0x%08h expected=0x%08h", tag, actual, expected);
      end else begin
        fail_count++;
        $error("[SCB][FAIL] %-45s actual=0x%08h expected=0x%08h", tag, actual, expected);
      end
    endfunction

    function automatic void check64(string tag, logic [63:0] actual, logic [63:0] expected);
      if (actual === expected) begin
        pass_count++;
        $display("[SCB][PASS] %-45s actual=0x%016h expected=0x%016h", tag, actual, expected);
      end else begin
        fail_count++;
        $error("[SCB][FAIL] %-45s actual=0x%016h expected=0x%016h", tag, actual, expected);
      end
    endfunction

    function automatic void report();
      $display("=================================================");
      $display("CLINT scoreboard: %0d PASS / %0d FAIL", pass_count, fail_count);
      $display("=================================================");
      if (fail_count > 0) $fatal(1, "CLINT verification FAILED");
    endfunction
  endclass

endpackage : clint_tb_pkg
