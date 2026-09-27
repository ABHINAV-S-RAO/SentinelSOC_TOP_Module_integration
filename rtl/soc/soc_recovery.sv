// =============================================================================
// soc_recovery.sv -- JTAG recovery-boot controller
//
// Fallback when the bootrom is faulty (buggy, corrupted, hangs). Recovery is
// entered by either trigger, and then stays set until power-on reset:
//   1. boot_mode_i strap sampled high right after power-on reset, or
//   2. boot watchdog: boot_done_i still 0 after BOOT_WDT_CYCLES cycles of the
//      core running (paused while the core is in debug mode, so an ordinary
//      debug session during boot never trips it). BOOT_WDT_CYCLES=0 disables it.
//
// In recovery, halt_req_o (OR'ed into Ibex debug_req_i) holds the hart in
// debug mode before it retires a single bootrom instruction -- Ibex samples
// debug_req in FIRST_FETCH. It releases once the core has entered debug mode
// and re-arms on every system reset (incl. ndmreset), so the debugger can
// reset and retry without the bootrom ever running.
//
// While recovery_o=1 the address decoder lets the halted core (debugger) write
// ISRAM until boot_done/isram_lock (soc_addr_decode.sv). The loaded image
// still only executes once fw_verified_i is set by the signature checker.
// =============================================================================
module soc_recovery #(
  parameter int unsigned BOOT_WDT_CYCLES = 32'd1_000_000
) (
  input  logic clk_i,
  input  logic por_rst_ni,         // power-on reset only: recovery flag survives ndmreset
  input  logic sys_rst_ni,         // system reset incl. ndmreset: re-arms halt, restarts watchdog
  input  logic boot_mode_i,        // strap, 1 = recovery boot (static during/after reset)
  input  logic boot_done_i,        // from soc_ctrl_regs
  input  logic core_debug_mode_i,  // from ibex_top.debug_mode_o
  output logic recovery_o,
  output logic halt_req_o,
  output logic wdt_expired_o
);

  // ---------------------------------------------------------------------------
  // Recovery flag (power-on reset domain)
  // ---------------------------------------------------------------------------
  logic strap_sampled_q, recovery_q, recovery_d1_q;
  logic wdt_expired;

  always_ff @(posedge clk_i or negedge por_rst_ni) begin
    if (!por_rst_ni) begin
      strap_sampled_q <= 1'b0;
      recovery_q      <= 1'b0;
      recovery_d1_q   <= 1'b0;
    end else begin
      // The strap is sampled once, in the first cycle after power-on reset,
      // so toggling the pin later cannot halt a running system.
      if (!strap_sampled_q) begin
        strap_sampled_q <= 1'b1;
        if (boot_mode_i) recovery_q <= 1'b1;
      end
      if (wdt_expired) recovery_q <= 1'b1;
      recovery_d1_q <= recovery_q;
    end
  end

  // ---------------------------------------------------------------------------
  // Boot watchdog (system reset domain: restarts after every ndmreset)
  // ---------------------------------------------------------------------------
  logic [31:0] wdt_q;

  always_ff @(posedge clk_i or negedge sys_rst_ni) begin
    if (!sys_rst_ni) begin
      wdt_q <= '0;
    end else if (!boot_done_i && !recovery_q && !core_debug_mode_i && !wdt_expired) begin
      wdt_q <= wdt_q + 32'd1;
    end
  end

  assign wdt_expired = (BOOT_WDT_CYCLES != 0) && (wdt_q >= BOOT_WDT_CYCLES);

  // ---------------------------------------------------------------------------
  // Halt request
  // ---------------------------------------------------------------------------
  logic halt_q;

  always_ff @(posedge clk_i or negedge sys_rst_ni) begin
    if (!sys_rst_ni) begin
      halt_q <= 1'b1;                                   // re-armed by every reset
    end else if (core_debug_mode_i) begin
      halt_q <= 1'b0;                                   // halted: debugger has control
    end else if (recovery_q && !recovery_d1_q) begin
      halt_q <= 1'b1;                                   // watchdog fired mid-run
    end
  end

  assign recovery_o    = recovery_q;
  assign halt_req_o    = recovery_q & halt_q;
  assign wdt_expired_o = wdt_expired;

endmodule : soc_recovery
