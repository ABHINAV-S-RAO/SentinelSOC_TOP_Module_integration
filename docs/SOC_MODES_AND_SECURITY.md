# SentinelSoC — Boot, Modes and Access Control: Final Spec

| | |
|---|---|
| Status | **Locked.** This is the reference for the RTL and testbench changes. |
| Branch | Implement on a new branch off `full_soc` |
| Date | 2026-10-02 |
| Scope | `SECURE_BOOT=1` builds (`basic_soc_top` with `soc_secure_boot`). `SECURE_BOOT=0` builds and the older `soc_top.sv` keep today's behaviour. |

---

## 1. Decisions at a glance

| # | Topic | Decision |
|---|---|---|
| D1 | **`boot_done`** | **Set by hardware** the first time a fetch of the firmware entry instruction is accepted from verified ISRAM. Sticky until system reset. **Software can no longer set it.** |
| D2 | Firmware entry | **Single entry:** before `boot_done`, the only ISRAM address the fetch gate accepts is ENTRY |
| D3 | Boot watchdog | Stops on the hardware `boot_done` (follows from D1). Default **2,000,000 cycles** |
| D4 | ISRAM write lock | **ISRAM locks the moment VERIFY start is accepted,** until system reset |
| D5 | BootROM execution | BootROM code can run **only during normal boot**: not after `boot_done`, and never in recovery |
| D6 | `dift_en_i` pin | **Removed.** DIFT is always on inside the chip. |
| D7 | Firmware privilege | Firmware runs in **Machine mode**. The bootrom hands over with a plain jump (no `mret`, no User mode). |
| D8 | DIFT policy (TCR/TPR) | **Set by the firmware itself,** in M-mode. No signed policy, no lock. The debugger (normal or recovery) can never write them. |
| D9 | PMP | Stays off |
| D10 | Debug after boot | Allowed, with today's write restrictions |
| D11 | Strap pin | Kept: the manual way into recovery |
| D12 | Bootrom | Stays a placeholder (`software/boot/bootrom.S`), tested in simulation. Only change: drop its CTRL1 write. |

---

## 2. Modes

A **mode** is the set of hardware conditions that decides what is allowed right now. It controls:

- memory access;
- which CSRs and special instructions are legal;
- where instructions come from;
- what happens on a trap;
- whether interrupts and the watchdog run;
- how DIFT tags data.

There are two independent layers.

### 2.1 CPU mode (inside Ibex)

| | **Machine (M)** | **Debug (D)** |
|---|---|---|
| Who runs here | Bootrom and all firmware | The JTAG debugger (debug ROM + program buffer) |
| CSRs | All, including TCR/TPR | All **except TCR/TPR** (reads 0, writes dropped) |
| Interrupts | Taken if enabled | Ignored |
| Exceptions go to | `mtvec` handler | One fixed entry in the debug ROM (`0x1A11_0810`). `mepc`/`mcause` are not touched; the debugger sees "exception" (`cmderr = 3`). |
| Instructions from | Wherever the PC points | Debug ROM in the Debug Module |
| DIFT | Normal tag tracking | Every store to DSRAM is tagged 1 (untrusted) |
| Boot watchdog | Counts until `boot_done` | Paused |

User mode exists in Ibex but is not used (D7). Without PMP (D9), it would not restrict memory anyway.

### 2.2 SoC flags (our hardware)

| Flag | Meaning | Set by | Cleared by |
|---|---|---|---|
| `boot_done` | Boot is over; privileged windows closed | **Hardware**, on the first verified fetch at ENTRY (D1) | System reset (POR or ndmreset) |
| `recovery` | Chip is in JTAG recovery | Strap at POR, or watchdog expiry | **POR only** |
| ISRAM lock | ISRAM is read-only | Bootrom writes CTRL0, **or VERIFY start accepted (D4)** | System reset |
| `verified` | ISRAM holds a correctly signed image, unchanged since checked | Hardware verifier only | Any ISRAM write, a new start, system reset |

- **Power-on reset (POR)** resets everything.
- **System reset** is POR **or** ndmreset, triggered from the debugger. It resets the core, peripherals, `boot_done`, the ISRAM lock, `verified` and the verifier, **but not** the recovery flag.

### 2.3 The five states

| # | State | CPU | SoC |
|---|---|---|---|
| ① | Bootrom running | M | `boot_done` = 0 |
| ② | Debugger halts the chip during boot | D | `boot_done` = 0 |
| ③ | Recovery session | D | recovery = 1, `boot_done` = 0 |
| ④ | Firmware running | M | `boot_done` = 1 |
| ⑤ | Debugger halts the running firmware | D | `boot_done` = 1 |

```
                         POWER-ON RESET
                               │
               strap = 1 ──────┴────── strap = 0
                   │                       │
                   ▼                       ▼
            ③ RECOVERY   ◀── watchdog ── ① BOOTROM (M)
          (core held halted)   expires      │ copy image, lock, verify,
                   │                        │ jump to ENTRY
   debugger loads ISRAM,                    │
   VERIFY start (ISRAM locks),              │
   dpc = ENTRY, resume                      │
                   │                        │
                   └──────────┬─────────────┘
                              ▼
           first verified fetch at ENTRY  →  HARDWARE sets boot_done = 1
                              │              (watchdog stops)
                              ▼
                       ④ FIRMWARE (M)  ◀──resume──┐
                              │                    │
                              └──JTAG halt──▶ ⑤ DEBUG AFTER BOOT

   ndmreset : boot_done / lock / verified cleared → ① again (or ③ if recovery = 1)
   POR      : the only way out of recovery
```

---

## 3. Who can do what (after the changes)

✓ = allowed, ✗ = bus error / access fault. **(new)** = changed by this spec.

| Region | ① Bootrom | ② Debug in boot | ③ Recovery | ④ Firmware | ⑤ Debug after boot |
|---|---|---|---|---|---|
| **BootROM** `0x0000_0000` read | ✓ | ✓ | ✓ | ✗ | ✓ |
| **BootROM** execute | ✓ | ✓ | ✗ **(new)** | ✗ **(new)** | ✗ on resume **(new)** |
| **ISRAM** `0x0001_0000` read | ✓ | ✓ | ✓ | ✓ | ✓ |
| **ISRAM** write | ✓ until lock / VERIFY start **(new)** | ✗ | ✓ until VERIFY start **(new)** | ✗ | ✗ |
| **ISRAM** execute | ENTRY only, if verified **(new)** | — | ENTRY only, if verified **(new)** | Whole signed range, if verified | — |
| **DSRAM** `0x0002_0000` | R/W | R/W (tagged) | R/W (tagged) | R/W | R/W (tagged) |
| **DSRAM** execute | ✗ always | | | | |
| **CTRL** `0x0003_0000` | R/W, **CTRL1 ignored (new)** | R | R | ✗ | R |
| **VERIFY** `0x0005_0000` | R/W | R | R + W (start) | ✗ | R |
| **CLINT, PLIC, UART, QSPI, SPI2, timer, GPIO** | R/W | R/W | R/W | R/W | R/W |
| **TCR/TPR** (DIFT CSRs) | R/W | ✗ | ✗ | R/W | ✗ |

---

## 4. DIFT policy (TCR `0x7C2`, TPR `0x7C3`)

| Who | Read | Write |
|---|---|---|
| Firmware (M-mode, normal execution) | ✓ | ✓ any time |
| Bootrom (M-mode) | ✓ | ✓ technically, but it contains no such instruction |
| Debugger, normal debug | ✗ (reads 0) | ✗ (dropped) |
| Debugger, **recovery** | ✗ (reads 0) | ✗ (dropped). Recovery does **not** relax this. |

- **Reset values:** both registers reset to 0 (no checks, no propagation) on POR and on ndmreset.
- **Who chooses the policy:** the firmware sets it in its startup code. In recovery, the debugger influences the policy only by choosing which signed firmware to load.
- **Taint labels are always kept:** DSRAM tags are always recorded, and debugger writes are always tagged 1. Data planted earlier is still marked untrusted when the firmware turns checks on.

```asm
    la   t0, vector_table          # firmware startup (M-mode)
    csrw mtvec, t0
    li   t0, TCR_POLICY            # what to CHECK   (bit map: ibex_pkg.sv "TCR")
    csrw 0x7C2, t0
    li   t0, TPR_POLICY            # how taint SPREADS (bit map: ibex_pkg.sv "TPR")
    csrw 0x7C3, t0
```

**Accepted risk (D8):** two things can rewrite the policy:

- code that takes over the firmware at runtime;
- a debugger that halts the firmware and resumes it at its own `csrw` instruction with a chosen value.

---

## 5. Boot flows with the hardware `boot_done`

### 5.1 Normal boot

1. Reset. The core fetches the bootrom at `0x80`.
2. The bootrom copies the signed image from SPI flash into ISRAM.
3. The bootrom writes CTRL0 (lock), then VERIFY start. The lock is also forced by hardware (D4).
4. The hardware verifier reads ISRAM, runs SHA-512 + Ed25519, and sets `verified`.
5. The bootrom reads VERIFY ENTRY and jumps (`jr`) to ENTRY = `0x0001_0044`.
6. **The fetch at ENTRY is accepted, so hardware sets `boot_done` = 1.** The watchdog stops.
7. The firmware runs: it sets `mtvec`, then the DIFT policy, then interrupts, and so on.

### 5.2 Recovery

1. Strap at POR, or watchdog expiry. Recovery = 1 and the core is held halted.
2. The debugger does an ndmreset (clean start). Recovery stays 1, the core is halted again, `boot_done` = 0.
3. The debugger loads the image into ISRAM through the program buffer.
4. The debugger writes VERIFY start (program-buffer `sw`). **ISRAM locks.**
5. The debugger polls VERIFY_STATUS until `done`, and checks `verified`.
6. The debugger writes `dpc` = ENTRY and resumes. The core leaves debug mode.
7. **The fetch at ENTRY is accepted, so the same hardware sets `boot_done` = 1.**

There is no separate recovery mechanism.

| Recovery edge case | Result |
|---|---|
| Resume at an ISRAM address other than ENTRY | Refused (single entry). The core takes a fetch fault; the debugger halts it and fixes `dpc`. |
| Verification failed, resume at ENTRY anyway | Fetch refused, `boot_done` stays 0. ndmreset and retry. |
| Retry after a failed attempt | ndmreset clears the lock and the verifier. ISRAM keeps its contents, so the debugger patches the image and presses start again. Unlimited retries. |
| Debugger halts the firmware later | `boot_done` stays 1. Normal state-⑤ rules apply. |

---

## 6. Changes to implement

All new behaviour is enabled only when `SECURE_BOOT=1`. Legacy builds are unchanged.

### R1 — Hardware `boot_done` + single entry (D1, D2)

> **Implementation note:** debug mode is *not* part of the trigger, and the BootROM gate (R5) is closed in recovery even in debug mode. Ibex issues the fetch at `dpc` in the same cycle it executes `dret`, while `debug_mode` still reads 1. A debug-mode exception would therefore miss the recovery resume at ENTRY (R1), and would let exactly one BootROM instruction run at a debugger-chosen address (R5). In debug mode the core only executes the Debug Module's own ROM, so neither rule takes anything away from the debugger. · `soc_secure_boot.sv`, `basic_soc_top.sv`

**Current:** `boot_done` comes from a software write to CTRL1. The fetch gate accepts any address in the signed range.

```systemverilog
// soc_secure_boot.sv
assign fetch_ok_o = verified_q && (fetch_addr_i >= ENTRY) && (fetch_addr_i < code_end);
```

**New:**

```systemverilog
// soc_secure_boot.sv -- owns ENTRY, so it owns the handoff
input  logic fetch_accept_i,   // instruction fetch req & gnt this cycle
output logic fw_entered_o,     // = hardware boot_done

logic entered_q;               // system-reset domain (rst_ni = sys_rst_n)
always_ff @(posedge clk_i or negedge rst_ni) begin
  if (!rst_ni)
    entered_q <= 1'b0;
  else if (fetch_accept_i && fetch_ok_o && (fetch_addr_i == ENTRY))
    entered_q <= 1'b1;         // sticky: only a system reset clears it
end
assign fw_entered_o = entered_q;

// Single entry: before the handoff only ENTRY; afterwards the signed range.
assign fetch_ok_o = verified_q &&
                    (entered_q ? ((fetch_addr_i >= ENTRY) && (fetch_addr_i < code_end))
                               :  (fetch_addr_i == ENTRY));
```

```systemverilog
// basic_soc_top.sv
.fetch_accept_i ( instr_req_int & instr_gnt_int ),
.fw_entered_o   ( boot_done_hw ),
```

### R2 — CTRL1 can no longer set `boot_done` (D1) · `soc_ctrl_regs.sv`

**Current:**

```systemverilog
CTRL1_OFFSET: if (be_i[0] && wdata_i[0]) boot_done_q <= 1'b1;
assign boot_done_o = boot_done_q;
```

**New:**

```systemverilog
parameter bit HW_BOOT_DONE = 1'b0,     // basic_soc_top passes SECURE_BOOT
input  logic  boot_done_hw_i,

CTRL1_OFFSET: if (!HW_BOOT_DONE && be_i[0] && wdata_i[0]) boot_done_q <= 1'b1;  // ignored in HW mode
assign boot_done_o = HW_BOOT_DONE ? boot_done_hw_i : boot_done_q;
// BOOT_STATUS readback returns boot_done_o
```

`software/boot/bootrom.S`: delete the CTRL1 write before `jr s6`. In HW mode it would be ignored anyway. The bootrom still prints and reads ENTRY before the jump.

### R3 — Watchdog (D3) · `soc_recovery.sv`, `basic_soc_top.sv`

The counter logic is unchanged: it already stops on `boot_done`, which is now the hardware event. Only the default changes:

```systemverilog
parameter int unsigned BOOT_WDT_CYCLES = 32'd2_000_000,  // 20 ms @ 100 MHz, see section 9
```

### R4 — ISRAM locks on VERIFY start (D4) · `soc_secure_boot.sv`, `basic_soc_top.sv`, `soc_ctrl_regs.sv`

**Current:** `.ctrl_isram_lock_i ( isram_lock )`, the software CTRL0 bit only.

**New:**

```systemverilog
// soc_secure_boot.sv
logic started_q;
always_ff @(posedge clk_i or negedge rst_ni) begin
  if (!rst_ni)                           started_q <= 1'b0;
  else if (state_q == S_IDLE && start_w) started_q <= 1'b1;
end
assign verify_started_o = started_q;

// basic_soc_top.sv
.ctrl_isram_lock_i ( isram_lock | verify_started ),
// soc_ctrl_regs STATUS0[1] (isram_locked) reports the same effective lock
```

Writes after VERIFY start get a bus error. The existing "dirty → not verified" and "any write clears verified" logic stays as a second layer.

### R5 — BootROM executable only during normal boot (D5) · `soc_addr_decode.sv`

**Current:** BootROM fetches are never gated.

**New** (new parameter `BOOTROM_XGATE`, set to `SECURE_BOOT` by `basic_soc_top`):

```systemverilog
logic bootrom_fetch_ok, bootrom_fetch_blocked_q;
assign bootrom_fetch_ok = !BOOTROM_XGATE || (!boot_done_i && !recovery_i);

always_ff @(posedge clk_i or negedge rst_ni)
  if (!rst_ni) bootrom_fetch_blocked_q <= 1'b0;
  else         bootrom_fetch_blocked_q <= fetch_mgr_req[FSEL_BOOTROM].req &
                                          ~bootrom_data_active & ~bootrom_fetch_ok;

// BootROM arbiter: a refused fetch never reaches the ROM and is answered
// with an error one cycle later (same pattern as the ISRAM fetch gate).
if (!bootrom_data_active && !bootrom_fetch_ok) begin
  bootrom_req_o                   = 1'b0;
  fetch_mgr_rsp[FSEL_BOOTROM].gnt = fetch_mgr_req[FSEL_BOOTROM].req;
end
if (bootrom_fetch_blocked_q) begin
  fetch_mgr_rsp[FSEL_BOOTROM].rvalid  = 1'b1;
  fetch_mgr_rsp[FSEL_BOOTROM].r.rdata = 32'hDEAD_BEEF;
  fetch_mgr_rsp[FSEL_BOOTROM].r.err   = 1'b1;
end
```

Firmware rules that follow from this:

- **Set `mtvec` as the very first thing.** `mtvec` resets to the BootROM, so an earlier trap would now fault in a loop. `app_demo.S` already does this.
- **Clear the DSRAM data area at startup.** This removes anything a recovery session left behind.

### R6 — Remove `dift_en_i` (D6) · `basic_soc_top.sv`, testbenches

Remove the port and drive the Ibex input with a constant `1'b1`. Remove `.dift_en_i(1'b1)` from `full_soc_tb`, `secure_boot_dbg_tb` and `dift_dbg_tb`. `soc_top.sv` has its own port and is not touched.

---

## 7. Every user of `boot_done`, and what changes

The **source** of `boot_done` changes. **Every consumer keeps exactly the same logic.**

| Where | What it does with `boot_done` | After the change |
|---|---|---|
| `soc_addr_decode` — privileged windows | CTRL/VERIFY writable only while 0; readable while 0 or by the debugger | Same logic. Closes at the jump to ENTRY instead of a few instructions earlier. |
| `soc_addr_decode` — BootROM data reads | Allowed while 0 or by the debugger | Same. The bootrom prints and reads ENTRY before the jump, as today. |
| `soc_addr_decode` — debugger ISRAM writes | Allowed only in recovery while 0 | Same. Additionally ended by the R4 lock. |
| `soc_addr_decode` — BootROM execute (R5) | n/a today | New consumer |
| `soc_recovery` — watchdog | Counts while 0 | Same logic. Now stopped by a hardware event. |
| `soc_ctrl_regs` — BOOT_STATUS readback | Returns the bit | Returns the hardware bit |
| `soc_top.sv`, `sentinel_soc_top.sv` (older tops, `verif/files.f`, UVM) | Use `soc_ctrl_regs` + `soc_addr_decode` | **Unchanged.** The new parameters default to legacy behaviour. |

---

## 8. ISRAM has one port

There is **one physical ISRAM port** (`isram_req_o` …; `isram_model` in the TB). Three requesters share it through a fixed-priority arbiter in `soc_addr_decode`:

1. **CPU data** (loads/stores, including the debugger's program buffer). Highest priority.
2. **CPU instruction fetch** (only when the fetch gate allows it).
3. **Hardware verifier** (read-only). Lowest priority.

Each response is routed to the requester that owns it.

| Question | Answer |
|---|---|
| Does the verifier get starved? | No, in practice. During verification the bootrom polls VERIFY and fetches from the BootROM, and in recovery the core is halted. The verifier only waits when someone hammers ISRAM. |
| Effect of R4 | Writes are refused after start, so the image cannot change under the verifier. Reads by the CPU are still allowed. |
| Firmware linking rule | ISRAM is read-only after the lock, so `.data`, `.bss` and the stack must live in **DSRAM**. ISRAM holds code and read-only constants only, and firmware can never modify itself. |

---

## 9. Watchdog value

Sized from the **largest image that fits** (8 KB ISRAM = 2048 words):

| Step | Cycles (100 MHz) | Basis |
|---|---|---|
| Copy 2048 words from SPI flash | ≈ 250k | 8-word SPI chunks plus the bootrom's per-word loop (≈ 120 cycles/word) |
| Hash 2048 words (SHA-512 at clk/2) | ≈ 35k | 64 blocks plus the per-word feed |
| Ed25519 | ≈ 400k | Fixed cost, independent of image size (from `full_soc_tb`) |
| Bootrom setup + prints (sim-fast UART) | ≈ 30k | ~165 characters |
| **Worst case** | **≈ 0.7M** | |
| **Chosen value (≈ 3× margin)** | **2,000,000 = 20 ms** | |

- These are estimates. A full-size (8 KB) image test confirms them (section 11).
- **Re-derive** the value if the clock changes or the bootrom prints at a real baud rate. At 115200 baud, the prints alone are ≈ 1.4M cycles.
- The watchdog stays paused while the core is in debug mode. The debugger TBs keep their small values (20k) on purpose.

---

## 10. Things to watch (could break later)

| # | Risk | Handling |
|---|---|---|
| W1 | **`secure_boot_dbg_tb` runs its test firmware from the BootROM** (`fw_load()` at `0x80`, heartbeat loop, CTRL1 write via the `set_boot_done` knob). With R1/R2/R5, CTRL1 is ignored and BootROM code cannot run after boot. | Rework that TB: build its DIFT test firmware as a signed ISRAM image (`gen_signed_image.py`) and boot it through the real flow. Watchdog tests trigger by "bootrom never jumps" instead of "firmware doesn't set `boot_done`". |
| W2 | `dift_dbg_tb` uses the same BootROM-hosted firmware | Unaffected: it is `SECURE_BOOT=0`, legacy mode. Only `.dift_en_i` is removed. |
| W3 | Ibex fetches the next instruction (ENTRY+4) right after ENTRY. `boot_done` must already be 1 by then, or the single-entry rule refuses it. | `boot_done` is registered on the clock edge that accepts ENTRY, so the next request sees it. **Confirm in simulation.** |
| W4 | A trap before the firmware sets `mtvec` now loops (R5) | Firmware rule: `mtvec` first (section 6, R5) |
| W5 | Watchdog-triggered recovery cuts off the bootrom mid-run. With R5, its next fetches are refused while the halt request lands. | Confirm the core enters debug mode cleanly, with no trap loop first |
| W6 | ENTRY (`0x0001_0044`) is defined in several places: `soc_secure_boot` (`ENTRY`), `sign_image.py`, the app link address, TB localparams | Keep one value. Any change must touch all of them. |
| W7 | A refused fetch now also happens on a resume at the wrong address in recovery | The debugger sees a fault and re-halts. Document it in the recovery procedure. |
| W8 | The decoder input `fw_verified_i` actually carries `fetch_ok` (verified + address check) | Naming only; consider renaming to `fw_fetch_ok_i` |
| W9 | Validly signed but broken firmware boots every time | Not fixable by the watchdog. The strap is the way back in (D11). |
| W10 | The `dift_en_i` removal and the new ports change `basic_soc_top`'s interface | Update all three TB instantiations. The older tops are not affected. |

---

## 11. Test plan

**Existing tests that must still pass:**

| Test | Required result |
|---|---|
| `dift_dbg_tb` | All checks unchanged (legacy mode) |
| `full_soc_tb` | Normal boot reaches `[APP] PASS`; `+TAMPER` never executes the firmware |
| `secure_boot_dbg_tb` | Passes after the W1 rework |

**New checks:**

| ID | Check |
|---|---|
| T1 | Normal boot: `boot_done` rises in the cycle the fetch at ENTRY is accepted, and not earlier |
| T2 | Writing CTRL1 has no effect (bootrom, or firmware before the jump) |
| T3 | Bad or tampered image: `boot_done` never rises, the watchdog fires, and the chip enters recovery (`STATUS0[2]` = 1, `[3]` = 1) |
| T4 | Recovery: resume at ENTRY sets `boot_done`; resume at ENTRY+4 faults and leaves `boot_done` = 0 |
| T5 | After VERIFY start, a debugger ISRAM write gets a bus error and ISRAM is unchanged |
| T6 | After boot, a jump into the BootROM faults (`mcause` 1). In recovery, a resume into the BootROM faults. |
| T7 | A full 8 KB image boots in under 2,000,000 cycles |
| T8 | TCR/TPR: written by firmware ✓; written by the debugger in normal debug and in recovery ✗ |
| T9 | ndmreset after boot: `boot_done` → 0. In recovery the core is halted again and ISRAM keeps its contents. |

---

## 12. Implementation order

1. Create a branch off `full_soc`.
2. **R6** (remove `dift_en_i`): an interface-only change. Re-run all three TBs.
3. **R1 + R2 + R3** (hardware `boot_done`, CTRL1 ignored, watchdog value) together with the `bootrom.S` edit. Then `full_soc_tb` + T1, T2, T3, T7.
4. **R4** (lock on VERIFY start), plus T5.
5. **R5** (BootROM execute gate), plus T6 and the W3/W5 checks.
6. **W1:** rework `secure_boot_dbg_tb` (signed ISRAM test firmware), plus T4, T8, T9.
7. Final regression of all three TBs.
