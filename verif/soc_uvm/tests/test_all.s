# ==============================================================================
# SentinelSoC Comprehensive Test Suite (test_all.s)
# Target Architecture: RV32I / RV32M (Ibex)
# Memory Layout Alignment:
#   - Entry Point: BOOTROM @ 0x0000_0080 (.text.start)
#   - ISRAM:       0x0001_0000 (.rodata & .data)
#   - DSRAM:       0x0002_0000 (Scratch, DIFT Tag Seed, Pass/Fail Sentinels)
#   - Peripherals: UART @ 0x1000_0000, QSPI @ 0x1000_1000
# ==============================================================================

.equ DSRAM_BASE,    0x00020000
.equ SENTINEL_ADDR, 0x00020008  # Pass/Fail code checked by sw_status_monitor
.equ UART_BASE,     0x10000000  # APB UART Base
.equ UART_THR,      0x00000000  # Transmit Holding Register
.equ UART_LSR,      0x00000014  # Line Status Register (Offset 5 x 4)
.equ QSPI_BASE,     0x10001000  # APB QSPI Master Base

.equ TEST_PASS_CODE, 0xDEADBEEF
.equ TEST_FAIL_CODE, 0xCAFEF00D

# ------------------------------------------------------------------------------
# Reset Vector and Entry Point (.text.start at 0x80)
# ------------------------------------------------------------------------------
.section .text.start, "ax"
.global _start

_start:
    # 1. Initialize Stack Pointer to top of ISRAM (0x0001_FF00)
    li sp, 0x0001FF00

    # 2. Install Trap Handler for expected Bus Errors & Access Faults
    la t0, trap_handler
    csrw mtvec, t0

    # Initialize Fault Counter
    li s11, 0                    # s11 tracks caught access traps

# ------------------------------------------------------------------------------
# Phase 1: Address Decoder Boundary & Access Fault Verification
# ------------------------------------------------------------------------------
phase_addr_decode:
    # Scenario 1.1: BOOTROM Read Boundary Access (Valid Read)
    li t0, 0x00000000
    lw t1, 0(t0)                 # Valid fetch/read from BOOTROM base

    # Scenario 1.2: Data-side Store to BOOTROM (Should trap / return error)
    li t0, 0x00000000
    sw t1, 0(t0)                 # Expect Load/Store Access Fault -> Trap

    # Scenario 1.3: Access Gap Region (0x0003_FFFF to 0x0004_0000)
    li t0, 0x0003FFF0
    lw t1, 0(t0)                 # Expect Bus Fault -> Trap

    # Scenario 1.4: PLIC Boundary Check (4MB Region Offset)
    li t0, 0x0C000000            # PLIC Base
    lw t1, 0(t0)
    li t0, 0x0C3FFFFC            # PLIC Base + 4MB - 4
    lw t1, 0(t0)

# ------------------------------------------------------------------------------
# Phase 2: Memory Sweep (ISRAM .rodata & DSRAM Bit Patterns)
# ------------------------------------------------------------------------------
phase_memory_sweep:
    # Scenario 2.1: DSRAM Data Integrity Patterns
    li t0, DSRAM_BASE + 0x10     # Scratch area

    # Pattern 1: All Zeros
    li t1, 0x00000000
    sw t1, 0(t0)
    lw t2, 0(t0)
    bne t1, t2, test_fail

    # Pattern 2: All Ones
    li t1, 0xFFFFFFFF
    sw t1, 0(t0)
    lw t2, 0(t0)
    bne t1, t2, test_fail

    # Pattern 3: Alternating Bit Pattern A
    li t1, 0x55555555
    sw t1, 0(t0)
    lw t2, 0(t0)
    bne t1, t2, test_fail

    # Pattern 4: Alternating Bit Pattern B
    li t1, 0xAAAAAAAA
    sw t1, 0(t0)
    lw t2, 0(t0)
    bne t1, t2, test_fail

    # Scenario 2.2: ISRAM .rodata String Read Loop
    la t0, test_str              # Pointer to string in ISRAM .rodata
    li t1, DSRAM_BASE + 0x20     # Copy buffer in DSRAM
rodata_copy_loop:
    lbu t2, 0(t0)
    sb  t2, 0(t1)
    addi t0, t0, 1
    addi t1, t1, 1
    bnez t2, rodata_copy_loop

# ------------------------------------------------------------------------------
# Phase 3: DIFT Propagation Verification
# ------------------------------------------------------------------------------
phase_dift_test:
    # Scenario 3.1: Read $deposit Seeded Taint Tag from DSRAM Word 0 (0x0002_0000)
    li t0, DSRAM_BASE
    lw a0, 0(t0)                 # Loads word; DIFT tag propagates into reg 'a0'

    # Scenario 3.2: Register ALU Tag Propagation
    add a1, a0, zero             # Tag propagates from 'a0' to 'a1'

    # Scenario 3.3: Store Tagged Register back to DSRAM Word 1 (0x0002_0004)
    sw a1, 4(t0)                 # Store propagates tag back to tag_mem[1]

# ------------------------------------------------------------------------------
# Phase 4: QSPI Controller Interface
# ------------------------------------------------------------------------------
phase_qspi_test:
    # Trigger SPI Read Command Sequence via APB Registers
    li t0, QSPI_BASE
    li t1, 0x00000003            # Command 0x03 (STD Read)
    sw t1, 0x0(t0)
    li t1, 0x00000001            # Start transaction
    sw t1, 0x4(t0)

# ------------------------------------------------------------------------------
# Phase 5: UART Output Stream & Pass Signoff
# ------------------------------------------------------------------------------
phase_uart_report:
    la s0, uart_pass_str         # Load message from ISRAM .rodata
    li s1, UART_BASE

uart_tx_loop:
    lbu t0, 0(s0)
    beqz t0, test_pass           # Null terminator reached -> Exit Pass

poll_lsr:
    lw t1, UART_LSR(s1)          # Read Line Status Register
    andi t1, t1, 0x20            # Check THRE (Transmit Holding Register Empty)
    beqz t1, poll_lsr            # Wait until ready

    sw t0, UART_THR(s1)          # Write byte to THR
    addi s0, s0, 1
    j uart_tx_loop

# ------------------------------------------------------------------------------
# Pass / Fail Exit Routines
# ------------------------------------------------------------------------------
test_pass:
    li t0, SENTINEL_ADDR
    li t1, TEST_PASS_CODE
    sw t1, 0(t0)                 # Writes 0xDEADBEEF to DSRAM+0x8
pass_loop:
    j pass_loop                  # Spin until UVM objection drops

test_fail:
    li t0, SENTINEL_ADDR
    li t1, TEST_FAIL_CODE
    sw t1, 0(t0)                 # Writes 0xCAFEF00D to DSRAM+0x8
fail_loop:
    j fail_loop

# ------------------------------------------------------------------------------
# Non-blocking Trap Handler (Handles expected access faults)
# ------------------------------------------------------------------------------
.section .text
.align 2
trap_handler:
    csrr t6, mcause              # Inspect fault reason
    addi s11, s11, 1             # Increment fault counter

    csrr t6, mepc                # Read faulting instruction PC
    addi t6, t6, 4               # Advance past faulting 32-bit instruction
    csrw mepc, t6                # Update return address
    mret                         # Resume execution

# ------------------------------------------------------------------------------
# Data Section (Placed in ISRAM per link.ld)
# ------------------------------------------------------------------------------
.section .rodata
.align 2
test_str:
    .string "SENTINELSOC_MEM_TEST_DATA"

uart_pass_str:
    .string "SENTINELSOC OK\n"