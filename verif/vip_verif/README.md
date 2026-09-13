# Sentinel SoC VIP Verification (NoCore) Environment

Welcome to the VIP-driven verification sandbox! 
This environment is specifically designed to perform **"SoC - NoCore"** verification. In this environment, the real Ibex CPU is forcefully bypassed. Instead, a UVM OBI Master Agent acts as the CPU, directly driving transactions into the OBI crossbar.

This allows us to verify **integration issues** (address decoding, crossbar routing, interrupt bridging) and test the APB peripherals in isolation without relying on C-firmware.

## How it works
1. When compiled with `+define+NO_CORE`, `sentinel_soc_vip_uvm_top.sv` disables the Ibex CPU's `fetch_enable_i` and forces the inputs of the OBI crossbar (`core_data_req`, `core_data_we`, etc.) to be driven by our `obi_if`.
2. The `obi_cpu_agent` generates raw read/write sequences (emulating CPU loads/stores).
3. The traffic hits the APB peripherals (UART, SPI).
4. External mBits AVIPs (Advanced Verification IPs) sitting on the outside of the SoC passively sniff the physical pins (like `uart_tx_o`) and score the transactions.

## How to Run

To run a test in this environment, you must use the VIP-specific compilation file and define `NO_CORE`:

```bash
xrun -f verif/vip_verif/sentinel_soc_vip_files.f \
     +define+NO_CORE \
     +UVM_TESTNAME=sentinel_soc_vip_base_test \
     -uvm -access +rw
```

## Memory Map for Peripherals

When writing UVM sequences for the `obi_cpu_agent`, use the following base addresses to target the peripherals:

| Peripheral | Base Address  | Description / Notes |
|------------|--------------|---------------------|
| **UART**   | `0x1050_0000`| APB UART. TXDATA is at offset `0x00`. RXDATA at `0x04`. |
| **SPI**    | `0x1050_1000`| APB SPI Master. STATUS at offset `0x00`. CLKDIV at `0x04`. |
| **GPIO**   | `0x1050_2000`| APB GPIO. Direction at offset `0x00`. Output at `0x04`. |
| **TIMER**  | `0x1050_3000`| APB Timer (Note: Currently disabled in RTL). |

## Available Tests / Sequences

1. `soc_reg_seq` (Address Decoding Test)
   - **Goal:** Emulate the CPU issuing back-to-back writes and reads to different APB peripherals (e.g., UART then SPI).
   - **Signoff:** Proves that the `soc_addr_decode` crossbar accurately routes packets based on the memory map and returns `rvalid` correctly.

2. `soc_uart_traffic_seq` (Integration Test)
   - **Goal:** Emulate the CPU blasting a 16-byte payload into the UART `TXDATA` register.
   - **Signoff:** Proves that the APB-to-UART translation is flawless, as verified by the external mBits `uart_avip` sniffing the physical pins.

3. `soc_spi_traffic_seq` (Integration Test)
   - **Goal:** Emulate the CPU programming the SPI controller and transmitting a block of data.
   - **Signoff:** Verifies the SPI IP works in Master mode and that the mBits `spi_avip` (acting as Slave on the outside) receives the exact bytes sent by the CPU agent.

4. `soc_qspi_flash_seq` (Integration Test)
   - **Goal:** Emulate the CPU initiating a memory-mapped fetch or raw block transfer over QSPI.
   - **Signoff:** Verifies that our SoC correctly drives the QSPI Master pins and that the `qspi_flash_bfm` successfully processes the command and returns dummy flash data.

5. `soc_gpio_toggle_seq` (Integration Test)
   - **Goal:** Write alternating bit patterns (`0xAAAA`, `0x5555`) to the GPIO Output register.
   - **Signoff:** The UVM Monitor attached to the `gpio_if` asserts that the physical `gpio_io` wires immediately reflect the register writes.

6. `soc_jtag_debug_seq` (Integration Test)
   - **Goal:** Use the external mBits `jtag_avip` to inject OpenOCD-style JTAG DTM (Debug Transport Module) packets into the SoC.
   - **Signoff:** Verifies that the internal RISC-V Debug Module correctly interprets the JTAG pulses and asserts `debug_req` to the Ibex CPU.

7. `soc_timer_irq_seq` (Integration Test)
   - **Goal:** Emulate the CPU writing a countdown value to the APB Timer register, and waiting for it to reach zero.
   - **Signoff:** The UVM Monitor attached to `timer_irq_if` detects the `irq_timer` line asserting exactly when the countdown finishes.
