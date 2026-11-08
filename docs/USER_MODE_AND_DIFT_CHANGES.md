# SentinelSoC: User-Mode Firmware and DIFT Debugger Fixes

| | |
|---|---|
| Date | 2026-10-25 |
| Branch | `boot_handoff` (uncommitted local changes) |
| Builds on | `docs/SOC_MODES_AND_SECURITY.md` (boot handoff, already committed) |
| Status | RTL, firmware, testbenches and signed images updated. **`full_soc_tb` passes in all three modes** (Verilator, locally). The debugger TBs are to be run on Xcelium. |

---

## 1. Summary

| # | Change | Kind | Files |
|---|---|---|---|
| U1 | Firmware runs in **User mode** after a Machine-mode startup that writes the DIFT policy once | Firmware (no RTL change needed) | `software/app/app_demo.S`, `verif/debugger/images/gen_signed_image.py` |
| F1 | **D06a closed:** values the debugger writes into registers are tagged untrusted | RTL | `rtl/soc/basic_soc_top.sv` |
| F2 | **D08 closed:** `s0`/`a0` keep their taint across halt/resume | RTL | `rtl/core/ibex_core/rtl/ibex_core.sv` |
| F3 | **D03 reclassified:** "by design", no RTL change | Testbenches only | both debugger TBs |
| F4 | **Peripheral input is tainted again:** loads from the APB peripheral window return tag 1 (restores the original DIFT top's rule) | RTL | `rtl/soc/basic_soc_top.sv` |
| T | Testbenches updated to check all of the above | Verification | `full_soc_tb.sv`, `secure_boot_dbg_tb.sv`, `dift_dbg_tb.sv` |
| D | Documentation updated | Docs | this file, `SOC_MODES_AND_SECURITY.md`, `debug_secure_boot_integration.md` |

The policy architecture (which TCR bits exist and what they check) is **unchanged**.

---

## 2. U1: User-mode firmware

### 2.1 The model

```
 hardware handoff (first verified fetch at ENTRY, boot_done = 1)
        │
        ▼
 MACHINE MODE: firmware startup code (runs once)
   1. mtvec = vector table          (it resets to the BootROM, which can't run any more)
   2. clear DSRAM                   (nothing from a previous boot / recovery is trusted)
   3. park the machine timer        (mtimecmp = all ones)
   4. TPR, TCR  <- DIFT policy      (the ONE and ONLY write)
   5. mie = MTIE | MEIE             (interrupt enables)
   6. mstatus.MPP = U, mepc = app, mret
        │
        ▼
 USER MODE: the application
   - TCR/TPR, mtvec, mie, mstatus, ... are illegal instructions
   - interrupts and exceptions trap to Machine mode (trap handler), mret returns to User
```

This is what your partner described: the policy is written once, then the code runs in User mode, and the only mode switches after that are traps.

### 2.2 Why no RTL change was needed

Everything required is already in Ibex:

| Need | Ibex behaviour |
|---|---|
| User-mode code cannot write TCR/TPR | They are Machine-only CSRs (`0x7C2`/`0x7C3`, bits [9:8] = `11`). From U-mode any access is an illegal instruction (`illegal_csr_priv`, `ibex_cs_registers.sv`). |
| Interrupts work while in User mode | Machine-level interrupts are always enabled in U-mode, gated only by `mie` (`irq_enabled = MIE \| (priv == U)`, `ibex_controller.sv:483`). Firmware keeps `mstatus.MIE` = 0, so Machine-mode code is never interrupted. |
| `wfi` in the idle loop | Legal in U-mode while `mstatus.TW` = 0 (its reset value) |
| User mode can reach memory and peripherals | No PMP (`PMPEnable = 0`), so U-mode has the same memory access as M-mode, and the SoC address decoder never looked at privilege |
| Trap returns to the right mode | A trap from U saves `mstatus.MPP` = U; the handler's `mret` returns to U |

### 2.3 `software/app/app_demo.S`

- **Startup (Machine mode):** steps 1–6 above.
  - DIFT policy for the demo: `TPR = 0x0000_AAAA` (every class ORs source tags; loads propagate memory tags).
  - `TCR = 0x0000_0003` (trap on a tainted PC or a tainted jump target register).
  - Bit 6 is deliberately left off; see section 5.1. Tainted UART data is never used as a jump target, so the policy never fires during the demo.
- **The application (User mode):**
  - UART hello.
  - **A peripheral-taint check:** the app loads a UART register, stores it to `DSRAM[4]`, and stores a constant to `DSRAM[5]`. Hardware must tag the first 1 and the second 0 (F4).
  - **A User-mode check:** it writes `DSRAM[3] = 1`, then executes `csrw tcr, zero`. That must trap (illegal instruction, `mcause` 2). The handler sees `DSRAM[3] == 1`, sets it to 2 and skips the instruction. The app checks `DSRAM[3] == 2` and prints `[APP] running in User mode: TCR write trapped`.
  - Then SPI2, the CLINT timer interrupt and the PLIC interrupt as before.
  - The old `csrs mie` / `csrsi mstatus` lines were removed from the app; they would now be illegal. The interrupt enables moved into the startup code.
- **Trap handler (Machine mode):** timer and external interrupts as before, plus the one expected illegal instruction. Anything else writes `0xDEAD0000 | mcause` and stops.

### 2.4 Debugger TB firmware (`gen_signed_image.py` → `dift_fw_signed.mem`)

The signed test firmware used by `secure_boot_dbg_tb` follows the same model:
- **Machine-mode startup:** `mtvec`, then TPR, the four scenario loads, then TCR (the only policy write).
- **Then the drop to User mode:** `mstatus.MPP` = U, `mepc` = `0x0001_01D0`, `mret`.
- **The heartbeat loop runs in User mode:** `0x101D0`, `0x101D4`, `0x101D8`.
- **The trap handler moved** to `0x101DC`.
- **The image is now 126 words** (was 119).

### 2.5 What this does and doesn't protect

| Threat | Before | After U1 |
|---|---|---|
| Exploited **application** code rewrites TCR/TPR (disables DIFT) | Possible | **Blocked:** illegal instruction |
| Exploited **trap handler** (Machine mode) rewrites TCR/TPR | Possible | Still possible. Keep handlers small. |
| Debugger halts, sets `dcsr.prv = M` and `dpc` to the startup's own `csrw tcr`, resumes | Possible | Still possible (debug lifecycle topic, L7) |
| Application touches peripherals, CLINT, PLIC | Allowed | Still allowed (no PMP; by design) |

---

## 3. F1: D06a, debugger-written registers are tagged untrusted

### 3.1 The problem
Every value the debugger writes into a register reaches the core the same way: the abstract command (or program buffer) loads it from the debug module's data registers `data0`/`data1` at `0x1A11_0380`–`0x1A11_0387`. The debug module isn't DSRAM, so that load returned tag 0, and the debugger could launder any value into the firmware as trusted.

### 3.2 The fix (`rtl/soc/basic_soc_top.sv`, tag RAM read path)

```systemverilog
// Debugger data is untrusted (finding D06a)
localparam logic [31:0] DBG_DATA_ADDR = DBG_BASE_ADDR + 32'(dm::DataAddr);      // 0x1A11_0380
localparam logic [31:0] DBG_DATA_END  = DBG_DATA_ADDR + 4 * 32'(dm::DataCount); // 0x1A11_0388
assign tag_in_dbgdata = core_debug_mode &&
                        ({tag_addr, 2'b00} >= DBG_DATA_ADDR) && ({tag_addr, 2'b00} < DBG_DATA_END);
...
tag_rd_dbgdata_q <= tag_in_dbgdata;                    // registered with the request
...
assign tag_rdata = tag_rd_dbgdata_q  ? 1'b1 :          // debugger data: tainted
                   tag_rd_in_dsram_q ? tag_mem[tag_rd_addr_q] : 1'b0;
```

- **Same rule as DSRAM:** in debug mode, the data window reads as a tainted memory word. The destination register gets tag 1 through the normal load-propagation rule (TPR bit 15, "loads propagate the memory tag"). This is exactly how a tainted DSRAM word behaves, and it pairs with the existing rule that debugger **stores** into DSRAM are tagged 1.
- **Pre-boot (bootrom, recovery):** TCR/TPR are 0, so the tag has no effect, as you noted.
- **`a0` follows too:** riscv-dbg writes `a0` through `dscratch1`, and the taint reaches it via F2.

### 3.3 Consequence to know about
Under a firmware policy that checks **load/store addresses** (TCR bit 6), an address the debugger writes into a register is now tainted. A program-buffer memory access through that register therefore traps (`cmderr` = 3).

- In recovery and pre-boot, TCR = 0, so loading ISRAM is unaffected.
- After boot, with an address-checking policy, the debugger can still halt the firmware and read and write registers. It can't use its own pointers for memory access. That's DIFT working as intended: debugger data is untrusted.

### 3.4 Open question: peripherals
Your note said "the same way we do peripherals post boot". In the current RTL, **loads from peripherals (APB, CLINT, PLIC) return tag 0**; only DSRAM has tags. If peripheral input (UART RX, SPI RX, GPIO) is meant to be tainted after boot, that's a separate change: one more address window in the same tag read path, gated by `boot_done`. **Not done here**, tell me if you want it.

---

## 4. F2: D08, `s0`/`a0` keep their taint across halt/resume

### 4.1 The problem
The debug ROM uses `s0` and `a0` as scratch registers:
- On every debug entry it parks them in `dscratch0`/`dscratch1` (`csrw dscratch0, s0`).
- Before running a command, and on resume, it restores them (`csrr s0, dscratch0`).

CSRs held only the value, so a single halt/resume cleared the taint of both registers.

### 4.2 The fix (`rtl/core/ibex_core/rtl/ibex_core.sv`, DIFT section, item 6)

```systemverilog
assign csr_is_dscratch0 = csr_access && (csr_addr == CSR_DSCRATCH0);
assign csr_is_dscratch1 = csr_access && (csr_addr == CSR_DSCRATCH1);

always_ff @(posedge clk_i or negedge rst_ni)
  if (!rst_ni) {dscratch0_tag_q, dscratch1_tag_q} <= '0;
  else if (csr_op_en && !illegal_csr_insn_id && csr_op != CSR_OP_READ) begin
    // csrw replaces the value; csrs/csrc merge into it, so keep any old taint
    if (csr_is_dscratch0) dscratch0_tag_q <= (csr_op == CSR_OP_WRITE) ? alu_op_a_tag_ex
                                                                      : dscratch0_tag_q | alu_op_a_tag_ex;
    if (csr_is_dscratch1) dscratch1_tag_q <= ...same...;
  end

// a dscratch read returns the stored tag as the destination tag
assign regfile_wdata_tag_dbg = csr_is_dscratch0 ? dscratch0_tag_q :
                               csr_is_dscratch1 ? dscratch1_tag_q : regfile_wdata_tag;
// writeback stage now takes regfile_wdata_tag_dbg instead of regfile_wdata_tag
```

- **A write to a scratch CSR** stores the tag of its source operand. That's the resolved operand-A tag, with forwarding, the same tag the ALU uses.
- **A read of a scratch CSR** returns the stored tag.
- **Coverage:** every debug ROM path (entry, command, exception, resume) and every abstract command saves and restores `s0`/`a0` only through these two CSRs, so all of them now carry the taint.
- **Only the debug ROM is affected:** the scratch CSRs are accessible only in debug mode, so normal firmware never sees a difference.

---

## 5. F4: peripheral input is tainted again

### What was wrong
The original DIFT top ([`soc_top.sv:561`](../rtl/soc/soc_top.sv)) labels every load from outside DSRAM as tainted:
`tag_rdata = is_data_sram_q ? tag_mem[...] : 1'b1;`

That rule was never carried into `basic_soc_top`, the SoC we build and tape out:
- **At first**, non-DSRAM loads read a random DSRAM word's tag (aliasing).
- **After the DSRAM-only fix** (`441ba4e`), they read 0.

So UART/SPI/GPIO input was being treated as **trusted**. No test covered it.

### The fix (`rtl/soc/basic_soc_top.sv`, tag read path)
```systemverilog
// every load from the APB peripheral window (UART, QSPI, SPI2, timer, GPIO;
// 0x1000_0000-0x1FFF_FFFF minus the debug module 0x1A11_xxxx) returns tag 1
assign tag_in_periph = (({tag_addr, 2'b00} & 32'hF000_0000) == 32'h1000_0000) &&
                       (({tag_addr, 2'b00} & 32'hFFFF_0000) != DBG_BASE_ADDR);
...
assign tag_rdata = tag_rd_dbgdata_q  ? 1'b1 :                  // debugger data (F1)
                   tag_rd_periph_q   ? 1'b1 :                  // peripheral input (F4)
                   tag_rd_in_dsram_q ? tag_mem[tag_rd_addr_q] : 1'b0;
```
- **Unconditional on purpose.** The label only records where the data came from. TPR decides whether it propagates into the register (bits 15/14, load mode bits 5:4). TCR decides whether it traps. With TPR = 0 (reset and bootrom) a load leaves register tags untouched, so pre-boot behaviour is unchanged.
- **How it reaches DSRAM:** peripheral load (tag 1), then the register (tag 1 if TPR propagates loads), then a store writes the register's tag into the DSRAM tag RAM. All peripheral data passes through the CPU (there's no DMA), so this covers every path.
- **What stays clean:** ISRAM (signed code and constants), BootROM, CTRL, VERIFY, CLINT, PLIC and the debug module, except its data registers (F1).
- **Checked by `full_soc_tb`:** the UART word in DSRAM has tag 1, the constant next to it tag 0, and no DIFT violation fires.

### 5.1 Finding for the DIFT team: TCR bit 6 also checks loaded data
`LOADSTORE_CHECK_DA` (TCR bit 6) is named "check load/store address", but it's wired to **two** checks:

| Where | What it checks |
|---|---|
| Decode (`ibex_dift_tmu.sv`, store opcodes → `source_1`) | the **address register's** tag: matches the name |
| Load-store unit (`ibex_load_store_unit.sv:557`): `lsu_tag_err = data_rvalid && loaded_tag && TCR[6]` | the tag of the **word coming back from memory**. That's every response: loads of tainted data, and stores whose target word is tainted. |

**Consequence:** with peripheral input tainted, a firmware that sets bit 6 traps (load access fault, `mcause` 5) on its **first peripheral read**. The first test run did exactly that, on the UART status poll in `puts`. That's why the demo uses `TCR = 0x03`.

No RTL change was made (the policy architecture stays as it is). To decide: should the LSU check move to its own bit (e.g. bit 7 `LOADSTORE_CHECK_S`), or be dropped, so that bit 6 means only "tainted address"?

---

## 6. F3: D03, by design

The test shows that a tainted register can be stored (here into the debugger's `data0`) without an exception. **That matches the existing policy architecture:** tainted store **data** isn't blocked; only a tainted **address** raises an exception. No RTL change. Both debugger TBs now print it as `[OBS] D03 (by design)` instead of a finding.

D12 was already closed when the `dift_en_i` pin was removed.

---

## 7. How to run (all you need to do)

The signed images were **already regenerated locally** and are part of the changes. If you edit the firmware again, regenerate them on your laptop (Python `cryptography` is needed for the Ed25519 signature), from the repo root:

```
bash software/build_sim_images.sh
python3 verif/debugger/images/gen_signed_image.py
```

| Output | Changes? |
|---|---|
| `verif/soc/images/app.flash.hex`, `app.sym` | yes (User-mode `app_demo.S`) |
| `verif/soc/images/app_max.flash.hex` | yes |
| `verif/soc/images/bootrom.hex`, `bootrom.sym` | no (bootrom unchanged) |
| `verif/debugger/images/dift_fw_signed.mem` | yes (User-mode TB firmware, 126 words) |
| `verif/debugger/images/recovery_signed.mem`, `otp_pubkey.mem` | no (byte-identical) |

The image build also rewrites the tracked build outputs under `build/sw/`. Commit them or not, as you prefer.

Then on the Cadence server (type the lines exactly; no `#` comments in csh):

```
xrun -f verif/soc/files_full_soc.f
xrun -f verif/soc/files_full_soc.f +TAMPER
xrun -f verif/soc/files_full_soc.f +BIGIMAGE
xrun -f verif/debugger/files_secure_boot_dbg.f
xrun -f verif/debugger/files_dift_dbg.f
```

### Expected results

| Run | Expect |
|---|---|
| `full_soc_tb` | `TEST PASSED` (verified locally); new checks: drop to User mode after the handoff, policy written before the switch, TCR write from U trapped, TCR/TPR never change in U, app ends in User mode, UART data in DSRAM tainted / constant clean, no DIFT violation |
| `full_soc_tb +TAMPER` | `TEST PASSED (+TAMPER)` (verified locally, unchanged behaviour) |
| `full_soc_tb +BIGIMAGE` | `TEST PASSED (+BIGIMAGE)` (verified locally), handoff at ~661k cycles (33% of the watchdog), plus all the User-mode checks |
| `secure_boot_dbg_tb` | `FAIL=0`, **`DIFT-FINDINGS=0`**; D06a/D08 are now PASS checks; every boot checks the firmware dropped to User mode; dcsr shows `prv=U` when halted |
| `dift_dbg_tb` (legacy, firmware still in Machine mode in the BootROM) | `FAIL=0`, **`DIFT-FINDINGS=0`** |

### What was verified locally
- **Image scripts:** both ran cleanly, and the images are regenerated.
- **RTL:** compiles, including the D08 block, the D06a/F4 tag paths and the User-mode firmware.
- **`full_soc_tb`:** passes in the normal, `+TAMPER` and `+BIGIMAGE` modes (Verilator).
- **Not run locally:** `secure_boot_dbg_tb` and `dift_dbg_tb`, which exercise the D06a/D08 RTL with the debugger. If they fail, send the `[FAIL]` lines.

---

## 8. Every file touched

| File | Change |
|---|---|
| `rtl/soc/basic_soc_top.sv` | F1: DM data-window loads in debug mode return tag 1. F4: APB peripheral loads return tag 1 |
| `rtl/core/ibex_core/rtl/ibex_core.sv` | F2: tag bits for `dscratch0/1`; writeback takes the dscratch tag on a dscratch read |
| `software/app/app_demo.S` | U1: Machine-mode startup (policy once, `mie`, `mret`), User-mode app, User-mode check, handler skips the one expected illegal instruction. F4: peripheral-taint check (UART word vs constant in DSRAM). TCR = `0x03` |
| `verif/soc/images/*`, `verif/debugger/images/dift_fw_signed.mem` | Regenerated signed images (the bootrom, recovery image and public key are unchanged) |
| `verif/debugger/images/gen_signed_image.py` | U1: TB firmware drops to User mode (new loop/trap addresses, 126 words) |
| `verif/soc/full_soc_tb.sv` | Privilege and DIFT monitors; 7 new checks (User mode, policy-once, TCR trap, no change in U, ends in U, peripheral taint, no DIFT violation) |
| `verif/debugger/secure_boot_dbg_tb.sv` | New firmware size and loop addresses; `prv=U` in dcsr; User-mode check per boot; D06a/D08 → checks; D03 → `[OBS]`; D-TAG expects tagged registers |
| `verif/debugger/dift_dbg_tb.sv` | D06a/D08 → checks; D03 → `[OBS]`; D-TAG expects tagged registers |
| `docs/SOC_MODES_AND_SECURITY.md` | D7/D8 updated, User-mode column in the mode table, TCR/TPR access rows, remaining risks |
| `docs/debug_secure_boot_integration.md` | Findings status table (D06a/D08 closed, D03 by design, D12 closed) |
| `docs/USER_MODE_AND_DIFT_CHANGES.md` | This file |
