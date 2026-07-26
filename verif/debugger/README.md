# riscv-dbg + Ibex debug-module regression (JTAG-driven, self-checking)

## What this is
A real JTAG bit-bang testbench that drives `soc_top`'s external
`jtag_tck_i/tms_i/tdi_i/tdo_o/trst_ni` pins exactly like OpenOCD would, goes
through `dmi_jtag_tap` -> `dmi_jtag` -> `dm_top`, and self-checks the results
against `dm_pkg`'s actual register semantics. No DPI, no force/deposit into
the DM or Ibex internals -- this exercises the whole external debug interface
end-to-end, on plain Ibex (no DIFT).

Files:
- `jtag_if.sv` -- reusable JTAG BFM (TAP FSM walk, IR/DR shift, DMI
  read/write/reset with busy-retry). Portable: no dependency on `dm::`
  package, all constants mirrored locally.
- `tb_dm_ibex_top.sv` -- instantiates `soc_top`, clk/rst gen, and runs 13
  directed test groups (T1-T13) plus a 20-round randomized GPR stress loop,
  with a running PASS/FAIL scoreboard and a global watchdog.
- `filelist_debug_tb.f`, `run_xrun.sh` -- Xcelium glue.

## Coverage (T1-T13)
1. TAP IDCODE sanity
2. DTMCS sanity (abits=7, version=1 -- checked against your literal RTL)
3. `dmihardreset` actually reaches `dm_top` via `dmi_rst_n` (not just the
   DTM shift register) -- this directly checks the reset-wiring fix noted
   in your `soc_top.sv` comments
4. Post-activation DMSTATUS sanity pre-halt
5. Halt request -> allhalted/anyhalted/anyrunning transitions
6. GPR write/read-back via abstract command (x10, x1, x0-reads-zero)
7. CSR write/read-back via abstract command (dscratch0)
8. Program buffer execution (`addi x10,x10,1; ebreak`), confirms the
   postexec'd command completes cleanly and the hart re-halts on ebreak
9. Single-step via `dcsr.step`, confirms `dpc` advances exactly one
   instruction and the hart re-halts
10. Resume-to-free-run, confirms DMSTATUS flips back correctly
11. `ndmreset` pulse via DMCONTROL, confirms the hart is still controllable
    afterward
12. Randomized GPR write/read-back stress, 20 rounds, register index and
    pattern both randomized
13. `cmderr` fault injection (bogus regno) + write-1-to-clear, then confirms
    the DM is still fully functional afterward

## Before you run it
1. **Filelist**: `files.f` is your actual project filelist with the debug
   RTL and the new testbench inserted, and a couple of stale/conflicting
   pieces commented out (with the reasoning inline). Diff it against your
   original `files.f` to see exactly what moved. Two things need your
   confirmation, both flagged in comments in the file itself:
   - whether `verif/uart_verif/stubs/dbg_uart_test_stub.sv` defines
     anything that collides with the real `dm_top`/`dmi_jtag` now that
     they're wired into `soc_top.sv` for real (left out of the filelist
     for this run, pending that check)
   - whether `tc_clk_inverter`/`tc_clk_mux2` (used inside
     `dmi_jtag_tap.sv`) are actually reachable via your `bender_files.f`,
     or need `tech_cells_generic` added as an explicit dependency
   - `rtl/debug/` is where I assumed you'd drop the 12 `dm_*.sv`/`dmi_*.sv`
     files and `verif/debug_verif/` for the 2 new testbench files --
     adjust paths in `files.f` if you place them elsewhere.
2. **TCK rate**: `jtag_if.tck_half_period` defaults to 20ns (25MHz TCK)
   against a 100MHz `clk_i`. If your `dmi_cdc` needs a different ratio,
   override this before the first JTAG task call, e.g.
   `initial u_jtag.tck_half_period = 40ns;` in the tb.
3. **Bootrom contents**: `soc_top` has no memory-init port, so whatever your
   bootrom elaborates with (X's, zeros) is what the core executes at reset.
   Every test here works regardless -- debug halt/GPR/CSR/progbuf access
   doesn't care what the core is doing -- except T10's "confirm anyrunning"
   check, which only asserts the *status bit*, not correct program
   behavior. If you want a clean free-run demo on top of this, backdoor
   `$readmemh`/`force` a tight loop into your actual bootrom memory array
   right after reset (I didn't have that module's source to wire this in
   directly).

## Extending this
Straightforward next additions, same pattern as T1-T13:
- **haltreq via `hartsel`** once you go multi-hart (currently NrHarts=1 so
  `hasel`/`hartsel` aren't exercised)
- **`autoexec`** (AbstractAuto) to test triggering progbuf automatically on
  Data0 write instead of an explicit Command write
- **Illegal-instruction-during-progbuf** -> confirms `cmderr =
  CmdErrorException` and `dm_top`'s exception vector (`DmExceptionAddr`,
  the bug you already fixed to point at `0x810` instead of `0x808`) is
  actually taken -- this would be a strong regression test for that exact
  fix
- **Back-to-back DMI ops without the NOP-scan wait**, to stress the
  DTM_BUSY/dmireset retry path in `jtag_if.dmi_write/dmi_read` under load
- **SBA-disabled negative test**: confirm `sbcs` accesses reflect
  SBA being tied off (since your SoC deliberately disables it), rather
  than silently doing nothing
