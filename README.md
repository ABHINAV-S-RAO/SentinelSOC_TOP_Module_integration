# SentinelSoC

A secure RISC-V microcontroller SoC built around the **Ibex** core. It is aimed at a **TSMC 28 nm** tape-out.

It has three security features:

- **DIFT (Dynamic Information Flow Tracking).** Every register and every data word carries a tag bit. Hardware checks stop tainted data from being used as a jump target, a load/store address or an instruction.
- **Hardware secure boot.** Firmware is copied from external QSPI flash into on-chip ISRAM. An on-chip **SHA-512 + Ed25519** engine checks its signature against an OTP public key. The CPU may only run the image once that check passes.
- **JTAG recovery.** If the flash is empty or corrupt, a debugger can load a signed image over JTAG and boot it. The image goes through **the same signature check**, so the debugger cannot bypass secure boot.

<p align="center">
  <img width="615" height="493" alt="image" src="https://github.com/user-attachments/assets/f762f350-c4e0-42fe-96f6-de41acc133c9" />

</p>

---

## What's inside

| Block | Details |
|---|---|
| CPU | Ibex, RV32IM software (the Ibex C decoder is still present), M/U modes, PMP, DIFT tag pipeline |
| Debug | PULP `riscv-dbg` (JTAG TAP → DMI → debug module), execution-based, 8-entry program buffer |
| Secure boot | `soc_secure_boot`: SHA-512 + Ed25519 verifier, ISRAM lock, single fixed entry point, hardware `boot_done` |
| Recovery | `soc_recovery`: `boot_mode` strap or boot watchdog → core halts in debug, ready for a JTAG load |
| Memory | 4 KB BootROM, 8 KB ISRAM (instructions), 4 KB DSRAM (data), DIFT tag RAM |
| Interrupts | PLIC (UART, SPI, QSPI, GPIO, timer, DIFT sources) + CLINT (mtime/mtimecmp, msip); DIFT violation → NMI |
| Peripherals (APB) | QSPI flash controller, SPI master, UART, timer, GPIO |
| Interconnect | OBI crossbar/demux → OBI-to-APB bridge; unmapped accesses get a bus error |

**Top module:** [`rtl/soc/final_soc_top.sv`](rtl/soc/final_soc_top.sv)

## Memory map

| Address | Region |
|---|---|
| `0x0000_0000` | BootROM (4 KB, read-only) |
| `0x0001_0000` | ISRAM (8 KB). Firmware entry is fixed at `0x0001_0044` |
| `0x0002_0000` | DSRAM (4 KB) |
| `0x0003_0000` | SoC control registers |
| `0x0005_0000` | Secure-boot VERIFY registers |
| `0x0200_0000` | CLINT |
| `0x0C00_0000` | PLIC |
| `0x1050_0000` | QSPI · `0x1050_1000` Timer · `0x1050_2000` SPI · `0x1050_3000` UART |
| `0x1060_0000` | GPIO |
| `0x1A11_0000` | Debug module |

Every other address returns a bus error. Nothing hangs.

## Boot flow

```
Power-on reset
   │
   ├─ boot_mode = normal ──► BootROM copies the image from QSPI flash into ISRAM
   │                          └─► VERIFY start (ISRAM locks) ──► SHA-512 + Ed25519 check
   │                                 ├─ pass ──► jump to 0x0001_0044 ──► boot_done = 1 ──► firmware
   │                                 └─ fail ──► stays in the BootROM; the watchdog fires
   │
   └─ boot_mode = recovery, or watchdog timeout
          └─► core halts in debug mode ──► JTAG loads the image into ISRAM
                 └─► VERIFY start ──► same hardware check ──► resume at 0x0001_0044
```

- The CPU can only enter the firmware at **one address** (the entry point), and only **after verification passes**.
- Once VERIFY starts, ISRAM is locked. Nobody can change the image while it is being checked, or afterwards, including the debugger.

## Repository layout

```
rtl/
  soc/            final_soc_top, address decode, BootROM, SRAMs, control regs, secure boot, recovery
  core/           Ibex core with DIFT (ibex_core/, dift/)
  crypto/         SHA-512 and Ed25519 engines, OTP
  riscv-dbg/      JTAG debug module (PULP)
  Interrupts/     PLIC and CLINT
  peripheral/     APB UART, SPI master, timer, GPIO (submodule)
  obi_wrapper/    OBI bus fabric, OBI↔APB bridges, DIFT bus wrapper
software/
  boot/bootrom.S  BootROM source
  app/            demo firmware
  tools/          rvasm.py (assembler), sign_image.py (image signer)
verif/
  soc/            full-chip testbench (real Ibex, real BootROM, flash model)
  debugger/       JTAG + secure-boot and JTAG + DIFT testbenches
  vip_verif/      UVM environment (no-core mode) with UART/SPI/JTAG VIPs
  dift_verif/     DIFT unit tests
  secure_boot/    secure-boot block testbench
  vip/            UART and JTAG AVIP submodules
synth/            synthesis scripts
docs/             design notes (modes and security, DIFT, debug + secure boot)
```

## Getting started

```sh
git clone <repo-url> && cd SentinelSOC_TOP_Module_integration
git submodule update --init --recursive
bender update
bender script flist -t rtl > verif/bender_files.f
```

Build the simulation images: BootROM, signed firmware and test public key. No RISC-V toolchain is needed.

```sh
bash software/build_sim_images.sh
```

## Running the tests

The sign-off simulator is **Cadence Xcelium**. Run every command from the repo root.

| Testbench | Command | What it checks |
|---|---|---|
| Full chip | `xrun -f verif/soc/files_full_soc.f` | Real boot from flash, signature check, firmware run, DIFT, peripherals |
| Full chip, tampered image | `xrun -f verif/soc/files_full_soc.f +TAMPER` | A corrupted image must not boot |
| Full chip, largest image | `xrun -f verif/soc/files_full_soc.f +BIGIMAGE` | An 8 KB image boots within the watchdog limit |
| JTAG + secure boot | `xrun -f verif/debugger/files_secure_boot_dbg.f` | Recovery, ISRAM lock, entry point, debugger attacks (~190 checks) |
| JTAG + DIFT | `xrun -f verif/debugger/files_dift_dbg.f` | Debugger vs. DIFT policy and tags (126 checks) |
| DIFT core unit | `xrun -f verif/dift_verif/files_dift.f` | Tag propagation and checks (97 checks) |
| DIFT bus wrapper | `xrun -f verif/dift_verif/files_dift_obi.f` | Tag RAM and bus-side checks |

**UVM / VIP tests (no-core mode).** Run these from `verif/vip_verif/`:

```sh
make test_memmap   # every address range + error responses
make test_irq      # PLIC sources, masking, priority, CLINT
make test_uart     # UART AVIP
make test_spi      # SPI AVIP
make test_jtag     # JTAG AVIP
make test_qspi     # QSPI flash BFM
make test_gpio
make test_timer
```

## Status

**Done and passing on Xcelium:**

- full-chip secure boot (good image, tampered image, largest image);
- JTAG recovery;
- DIFT end to end;
- memory map decode;
- interrupt paths;
- UART, SPI and JTAG VIP tests.

**Still open before sign-off:**

- reset synchronizer and pad ring;
- clock source (PLL);
- debug-port lock for production parts;
- flash programming over JTAG;
- random/stress tests;
- a C software test suite;
- full-chip synthesis and timing for TSMC 28 nm.

## Documentation

- [Modes and security model](docs/SOC_MODES_AND_SECURITY.md)
- [Debug + secure boot integration](docs/debug_secure_boot_integration.md)
- [User mode and DIFT changes](docs/USER_MODE_AND_DIFT_CHANGES.md)
- [DIFT final changes](docs/DIFT_FINAL_CHANGES.md)
- [Crypto engines](rtl/crypto/README.md) · [Debugger testbenches](verif/debugger/README.md)
