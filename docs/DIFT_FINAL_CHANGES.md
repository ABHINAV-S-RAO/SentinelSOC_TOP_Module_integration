# SentinelSoC DIFT: Final Behaviour and Every Change

| | |
|---|---|
| Date | 2026-11-08 |
| Branch | Done on `boot_handoff`, merged into `main` (Xcelium regression passed) |
| Scope | DIFT in the core (`ibex_core` + `rtl/core/dift/`) and in the SoC (`final_soc_top`) |
| Related docs | `USER_MODE_AND_DIFT_CHANGES.md` (User mode, F1–F4), `SOC_MODES_AND_SECURITY.md` (boot handoff, modes), `debug_secure_boot_integration.md` (debugger findings D01–D13) |

This document is the single reference for how DIFT behaves now, and for every DIFT change made on this branch. Section 2 is the final behaviour. Section 3 lists the changes made earlier (already committed). Section 4 covers the check-wiring fix made in this round.

---

## 1. Overview in one picture

```
                 LABEL                       PROPAGATE (TPR)               CHECK (TCR)
  where a tag comes from          how tags move through instructions     when a tag traps

  DSRAM word ......... tag RAM     ALU / shift / logic / compare:          PC, jump, branch, ALU: EX
  APB peripheral ..... 1           MODE(src1 tag, src2 tag)                load address  (bit 21): EX
  debugger data0/1 ... 1           load:  MODE(addr tag & en14,            store address (bit 6) : EX
     (debug mode)                         data tag & en15)                 store data    (bit 7) : EX
  everything else .... 0           store: MODE(data tag & en15,            loaded data   (bit 7) : response
     (ISRAM, ROM, CLINT,                  addr tag & en16)                 load dest     (bit 8) : response
      PLIC, CTRL, ...)             dscratch0/1 keep s0/a0 tags
```

- **Label:** the SoC decides where untrusted data comes from.
- **Propagate:** the TPR decides how a tag moves through each instruction.
- **Check:** the TCR decides which uses of a tainted value trap.

Writing 0 to both TCR and TPR (their reset value) turns every check and every propagation off. There's no hardware off-switch (D12).

---

## 2. Final behaviour

### 2.1 Labels (where tags come from), in `rtl/soc/final_soc_top.sv`

| Load from | Tag | Notes |
|---|---|---|
| DSRAM `0x0002_0000`–`0x0002_FFFF` | the stored tag (tag RAM, 1 bit per word) | Stores write the tag the core computes (section 2.3) |
| APB peripheral window `0x1000_0000`–`0x1FFF_FFFF`, except the debug module | **1** | UART, QSPI, SPI2, timer, GPIO. All outside input is untrusted (F4) |
| Debug module data window `data0`/`data1`, `0x1A11_0380`–`0x1A11_0387`, **in debug mode** | **1** | Anything the debugger writes into a register is untrusted (D06a) |
| Everything else: ISRAM, BootROM, CTRL, VERIFY, CLINT, PLIC, rest of the debug module | 0 | Signed code and internal registers are trusted |

- **Loads only.** Store responses never carry a label. That's the "loads only" fix that cured the S2 failures.
- **A label is applied unconditionally**, but it does nothing on its own. Whether it reaches a register is up to the TPR, and whether it traps is up to the TCR.
- **Debugger stores into DSRAM** over the system bus are tagged 1.

### 2.2 Policy registers

| CSR | Address | Access |
|---|---|---|
| TCR (checks) | `0x7C2` | Machine mode only. User mode: illegal instruction. Debug mode: reads 0, writes dropped, the access reports an exception |
| TPR (propagation) | `0x7C3` | same |

The firmware writes both **once** in its Machine-mode startup, then drops to User mode (U1). After that, nothing running in User mode can change the policy.

### 2.3 TPR: propagation

| Bits | Field | Meaning |
|---|---|---|
| 1:0 | JUMP mode | `jal`/`jalr` result tag |
| 3:2 | BRANCH mode | branches |
| 5:4 | LOAD/STORE mode | loads and stores (rule below) |
| 7:6 | INTEGER mode | `add`, `sub`, `addi`, M extension |
| 9:8 | SHIFT mode | |
| 11:10 | LOGICAL mode | |
| 13:12 | COMPARISON mode | |
| 14 | EN_SOURCE_ADDR | loads: the **address** register's tag counts |
| 15 | EN_SOURCE | loads: the **memory word's** tag counts. Stores: the **data** register's tag counts |
| 16 | EN_DEST_ADDR | stores: the **address** register's tag counts |

Modes: `00` OLD, `01` AND, `10` OR, `11` CLEAR.

**ALU classes:** result tag = MODE(source 1 tag, source 2 tag). An immediate has tag 0. OLD and CLEAR both give 0 for ALU results.

**Loads:** register tag = MODE(address tag & bit 14, memory tag & bit 15).
- OLD leaves the register's old tag in place.
- The address tag is now captured **when the load is issued** (change C1).

**Stores:** memory tag = MODE(data tag & bit 15, address tag & bit 16). Change C4. Here the data tag is the data register's tag ORed with the tag of the instruction's PC.

| Mode | Stored tag |
|---|---|
| OLD | the data tag, unmasked (a store never drops taint) |
| AND | both enabled inputs tainted |
| OR | either enabled input tainted |
| CLEAR | 0 |

**Debug scratch registers:** `dscratch0`/`dscratch1` keep a tag bit, so `s0`/`a0` keep their taint when the debug ROM saves and restores them (D08).

### 2.4 TCR: checks (final)

| Bit | Name | Checks | When | Trap |
|---|---|---|---|---|
| 0 | EXECUTE_PC | the PC of the instruction is tainted | EX | illegal instruction (`mcause` 2) |
| 1 / 2 / 3 | JUMP S1 / S2 / D | jump source 1 / source 2 / result | EX | `mcause` 2 |
| 4 / 5 | BRANCH S1 / S2 | branch operands | EX | `mcause` 2 |
| **6** | LOADSTORE_CHECK_DA | **store** through a tainted address register | EX, **before the bus** | `mcause` 2; the store never happens |
| **7** | LOADSTORE_CHECK_S | **store** of tainted data, *and* a **load** that returns a tainted word | store: EX, before the bus. Load: on the response | store: `mcause` 2, store never happens. Load: load access fault (`mcause` 5), value not written to the register |
| **8** | LOADSTORE_CHECK_D | the tag the **load's destination** would get (after TPR) is tainted | on the response | load access fault (`mcause` 5), value not written |
| 9–11 | INTEGER S1 / S2 / D | | EX | `mcause` 2 |
| 12, 18, 13 | SHIFT S1 / S2 / D | | EX | `mcause` 2 |
| 14, 19, 15 | LOGICAL S1 / S2 / D | | EX | `mcause` 2 |
| 16, 20, 17 | COMPARISON S1 / S2 / D | | EX | `mcause` 2 |
| **21** | LOADSTORE_CHECK_SA | **load** through a tainted address register | EX, **before the bus** | `mcause` 2; the load never happens |

Bit 6 now means only "store address", bit 21 only "load address", and bit 8 no longer applies to stores (a store has no destination register). LUI/AUIPC still use bits 6/7/8 as source 1, source 2 and destination, as before.

**Policies used in the testbenches:**

| Where | TPR | TCR | Meaning |
|---|---|---|---|
| `app_demo.S` (`full_soc_tb`) | `0x0000_AAAA` | `0x0000_0003` | OR everywhere, loads take the memory tag. Trap on a tainted PC or jump target |
| Debugger TBs, `TCR_FULL` | `0x0000_AAAA` | `0x0001_56F2` | adds branch, store address/data, integer, logical and comparison checks |

Now that bit 6 no longer fires on every peripheral read, `app_demo.S` can safely add **bit 6** (store through a tainted pointer) and **bit 21** (load through a tainted pointer). That's `TCR = 0x0020_0043`. It hasn't been switched yet: it needs the firmware images rebuilt and re-signed. Bit 7 would trap on the first UART read, because it checks loaded data too, so it doesn't belong in the demo policy.

---

## 3. Earlier DIFT changes (already committed on this branch)

| # | Change | Where | Why |
|---|---|---|---|
| E1 | **DSRAM-only tags** (`441ba4e`): only DSRAM addresses index the tag RAM | `final_soc_top.sv` | Before, any address aliased into the tag RAM, so a peripheral or debug-module load read a random DSRAM word's tag |
| E2 | **TCR/TPR locked in debug mode**: reads return 0, writes dropped, access reports an exception | `ibex_cs_registers.sv` | A debugger can't read or disable the policy (D-findings, S2) |
| E3 | **TCR/TPR are Machine-only**, and the firmware runs in **User mode** after writing them once (U1) | `app_demo.S`, `gen_signed_image.py` | Exploited application code can't switch DIFT off |
| E4 | **`dift_en_i` pin removed** (D12): DIFT enable tied on inside the SoC | `final_soc_top.sv` | Anyone holding the board could have tied the pin low |
| E5 | **D06a**: debugger `data0/1` loads in debug mode return tag 1 (F1) | `final_soc_top.sv` | The debugger could launder values into firmware as trusted |
| E6 | **D08**: tag bits for `dscratch0/1`; reading them returns the stored tag (F2) | `ibex_core.sv` | One halt/resume cleared the taint of `s0`/`a0` |
| E7 | **Peripheral input tainted again**: APB window loads return tag 1 (F4) | `final_soc_top.sv` | UART/SPI/GPIO input was being treated as trusted |
| E8 | **Labels on loads only** (`0fcf026`) | `final_soc_top.sv` | The D06a label also hit store responses and tripped the old bit-6 response check (S2 failures) |
| E9 | **D03 reclassified as by design**, later resolved by C3 (section 4) | TBs | |

Details and code for E3, E5–E7 are in `USER_MODE_AND_DIFT_CHANGES.md`.

---

## 4. This round: the check-wiring fix

Two decisions taken: **bit 7 is made to work on stores**, and **the store tag follows the TPR enable bits** (rule in section 2.3).

### C1. The load address tag comes from the load's own base register
**Problem:** load propagation (TPR bit 14) read the address tag from the register file's read port **at the time the load data came back**. In the SoC (Ibex with the writeback stage), the next instruction is already in decode by then. So the tag came from **the next instruction's** register, not the load's base register.

**Fix:** `load_addr_tag_q` captures the base register's tag (with forwarding) when the load is issued. It's skipped on the second half of a misaligned load, whose address doesn't come from a register. Ibex has at most one data access outstanding, so one register is enough.
- `rtl/core/ibex_core/rtl/ibex_core.sv`

### C2. The load address check (bit 21) runs before the bus access
**Problem:** bit 21 was checked in `riscv_load_check` at writeback, using the same wrong register as C1. Its result also only drove the core's `dift_exception_o` output. In `final_soc_top` that output reaches the core only as a one-cycle pulse on the non-maskable interrupt line (core → `dift_obi_ctrl` → `irq_dift` → `irq_nm_i`), not as a trap on the offending load, so the load itself was never stopped.

**Fix:** the check decoder (`ibex_dift_tmu`) now has a load case: source 1 = bit 21. `ibex_dift_logic` evaluates it for loads in EX. The violation is a normal DIFT exception (`mcause` 2), and the load is never sent to the bus.
- `rtl/core/dift/ibex_dift_tmu.sv`, `rtl/core/dift/ibex_dift_logic.sv`

### C3. Bit 6 = store address only; bit 7 now works on stores
**Problems:**
- Bit 6 was also wired into the LSU as "the word that came back is tainted". That fired on **every peripheral read** (the UART crash, finding 5.1), and on store responses.
- Bit 7 checked operand B of the store. For a store, operand B is the immediate offset, whose tag is always 0, so the store-data check could never fire.

**Fix:**
- The LSU check on bit 6 is removed. Bit 6 is only the EX check on the store's address register.
- For stores, the decode stage puts the **store-data tag** on operand B, so bit 7 checks the data being stored. A store writes no register, so this tag feeds only the check.
- Every load/store that fails an EX check is kept off the bus: `lsu_req` is gated with the DIFT exception in `ibex_id_stage.sv`. With the writeback stage (the SoC configuration), Ibex already did this, because an instruction with an ID/EX exception doesn't execute. The gate makes the core-only TB configuration behave the same.
- **Effect on D03:** under a policy with bit 7, a debugger abstract read of a tainted register (which is a store into the debug module's `data0`) is now **refused**: `cmderr` = exception, and the secret isn't copied. Without bit 7 it still completes. That's the policy's choice.
- Files: `ibex_dift_tmu.sv`, `ibex_id_stage.sv`, `ibex_load_store_unit.sv`

### C4. Store tag rule implemented (P1)
**Problem:** the TPR store-enable bits did nothing. Every store wrote "data register tag OR PC tag" to the tag RAM. The decoder `riscv_enable_tag` computed the enables, but its outputs weren't connected.

**Fix:** the decode stage computes the stored tag as MODE(data tag & bit 15, address tag & bit 16), as in section 2.3.
- `rtl/core/ibex_core/rtl/ibex_id_stage.sv`
- **For the current policies nothing changes:** TPR `0xAAAA` has OR, bit 15 = 1 and bit 16 = 0, so stored tag = data tag, exactly as before.

### C5. Loaded-data checks (bits 7 / 8) now actually trap
**Problem:** `riscv_load_check` drove only `dift_exception_o`, the NMI pulse (see C2), so bits 7 and 8 on loads never trapped the offending load in the SoC.

**Fix:**
- `riscv_load_check` now checks the loaded word's tag (bit 7) and the propagated destination tag (bit 8) on the raw load response.
- Its result goes into the LSU as `load_tag_viol_i`. The LSU raises it like a bus error, which gives a precise **load access fault** (`mcause` 5) for that load, and the tainted value isn't written to the register.
- Files: `ibex_dift_tmu.sv`, `ibex_core.sv`, `ibex_load_store_unit.sv`

**Interface change:** the LSU port `tcr_load_check_i` is replaced by `load_tag_viol_i`. The module `riscv_load_check` lost its `rs1_i_tag` port and gained `regfile_dest_en` and `resp_valid_i`. Nothing outside `ibex_core` instantiates either.

### Testbench changes in this round

| TB | Change |
|---|---|
| `verif/tb/ibex_core_tb.sv` | **G1–G5 and N1** now check that the exception fired **on the instruction under test**, not just that some DIFT exception happened, and that the blocked load/store didn't happen. **G3 and N1** arm the TCR only right before the store (bit 7 also checks the earlier load). **New tests:** G5 (bit 7 on a load), G6 (bit 6 doesn't fire on a tainted word read through a clean pointer: the UART case), G7 (bit 21 doesn't check stores). **O3/O4** were wrong (under AND mode the pointer could never become tainted): the pointer is now tainted under OR, then TPR switches to AND. **P1–P9** cover the store tag rule in every mode and enable combination; the old P1 expectation contradicted the agreed rule, and P2 checked nothing. Total 97 tests (was 87) |
| `verif/debugger/dift_dbg_tb.sv`, `secure_boot_dbg_tb.sv` | **D03** is now a check: under `TCR_FULL` (bit 7 on), the abstract read of tainted `t1` must be refused and the secret must not appear in `data0` |

---

## 5. How to run on Xcelium

Nothing needs regenerating: no firmware or images changed in this round. On the server:

```
xrun -f verif/dift_verif/files_dift.f
xrun -f verif/dift_verif/files_dift_obi.f
xrun -f verif/soc/files_full_soc.f
xrun -f verif/soc/files_full_soc.f +TAMPER
xrun -f verif/soc/files_full_soc.f +BIGIMAGE
xrun -f verif/debugger/files_dift_dbg.f
xrun -f verif/debugger/files_secure_boot_dbg.f -l sb.log > /dev/null
grep -E "\*(E|F|SE),|\[FAIL\]|\[FINDING\]|checks=|TEST " sb.log
```

Use the same `xrun` options you used before for each TB. The lines above only show the filelists.

| TB | Expect |
|---|---|
| `ibex_core_tb` | 97 / 97 PASS |
| `dift_obi_ctrl_tb` | 9 PASS (unchanged) |
| `full_soc_tb` (all three modes) | `TEST PASSED`; the demo policy doesn't use bits 6/7/8/21 |
| `dift_dbg_tb` | `FAIL=0`, `DIFT-FINDINGS=0`; checks = 126 (was 125, plus D03) |
| `secure_boot_dbg_tb` | `FAIL=0`, `DIFT-FINDINGS=0`; checks = 189 (was 188, plus D03) |

---

## 6. Still open (DIFT)

| Item | Note |
|---|---|
| `app_demo.S` policy | It can add bits 6 and 21 (`TCR = 0x0020_0043`) now that bit 6 no longer fires on peripheral reads. Needs an image rebuild and re-sign |
| DIFT trap cause | EX-stage violations report **illegal instruction** (`mcause` 2, `mtval` = PC), and loaded-data violations report **load access fault** (`mcause` 5). A trap handler can't tell a DIFT trap from a real illegal instruction or bus error. A custom cause code (e.g. 24) would fix that; it's a small controller change |
| `dift_exception_o` → NMI | The core output **is** connected: core → `dift_obi_ctrl` → `irq_dift` → Ibex `irq_nm_i` (non-maskable interrupt). So a violation in normal running raises the trap **and** a one-cycle NMI pulse. `secure_boot_dbg_tb` checks that a violation in debug mode never comes back later as an NMI (D09), but no test fires a violation while the firmware runs normally, so what the core does with the trap plus the NMI pulse is **untested**. Decide whether the NMI is wanted (an alarm), and add a full-SoC test either way |
| Bit 7 on loads vs stores | One bit controls both "load of a tainted word" and "store of tainted data". With peripheral input tainted, enabling it traps the first UART read. Splitting it would need a new TCR bit; we kept the existing bit map |
| APB timer | Timer reads are labelled tainted like the other peripherals. It could be excluded if firmware needs clean timer values |
| Trap handler in Machine mode | Can still rewrite TCR/TPR. Keep it small (see `USER_MODE_AND_DIFT_CHANGES.md` 2.5) |

---

## 7. Every file touched in this round

| File | Change |
|---|---|
| `rtl/core/dift/ibex_dift_tmu.sv` | Load case (bit 21), separate store case (bits 6/7, no dest check). `riscv_load_check` rewritten: bits 7/8 on the load response |
| `rtl/core/dift/ibex_dift_logic.sv` | Loads: address check in EX |
| `rtl/core/ibex_core/rtl/ibex_id_stage.sv` | Store-data tag on operand B for stores; store tag rule; `lsu_req` gated by a DIFT exception |
| `rtl/core/ibex_core/rtl/ibex_core.sv` | `load_addr_tag_q`; load propagation and load check use it; load check wired to the LSU; `dift_exception_o` terms |
| `rtl/core/ibex_core/rtl/ibex_load_store_unit.sv` | Bit-6 response check removed; `load_tag_viol_i` → load access fault on loads only |
| `verif/tb/ibex_core_tb.sv` | G/N/O/P groups as described in section 4 |
| `verif/debugger/dift_dbg_tb.sv`, `verif/debugger/secure_boot_dbg_tb.sv` | D03 is a check |
| `docs/DIFT_FINAL_CHANGES.md` | This file |
| `docs/USER_MODE_AND_DIFT_CHANGES.md`, `docs/debug_secure_boot_integration.md` | Pointers: finding 5.1 and D03 are resolved here |
