# =============================================================================
# software/app/app_demo.S -- first signed firmware for the full-SoC flow
#
# Linked at the ISRAM entry 0x0001_0044 (image = 17-word header + this code),
# with a 256-byte aligned vector table (Ibex mtvec is vectored-only),
# signed with software/tools/sign_image.py and booted by software/boot/bootrom.S.
#
# Privilege model (docs/USER_MODE_AND_DIFT_CHANGES.md):
#   Startup code runs in MACHINE mode, exactly once:
#     mtvec -> clear DSRAM -> park the machine timer -> DIFT policy (TPR, TCR:
#     written ONCE, here) -> interrupt enables (mie) -> mret into USER mode.
#   The application runs in USER mode. TCR/TPR (and every other machine CSR)
#   are out of its reach: a write is an illegal instruction. The only switches
#   back to Machine mode are traps -- interrupts and exceptions -- and the trap
#   handler returns to User mode with mret.
#
# The User-mode application exercises, in order, printing progress over UART:
#   1. UART output from verified code
#   2. proof of User mode: csrw tcr, zero must trap (illegal instruction,
#      mcause 2); the handler skips it once and records it in DSRAM[3]
#   2b. peripheral input is tainted: a UART register value stored to DSRAM
#      carries DIFT tag 1, a constant stored next to it tag 0
#   3. SPI #2 (APB 0x1050_2000): transmit one byte 0xA5 on CS0
#   4. CLINT machine-timer interrupt  (mtimecmp -> irq_timer -> mcause 7)
#   5. PLIC external interrupt from the APB timer compare (source 5 -> mcause 11,
#      claim/complete)
#   6. writes TEST_PASS (0xB007B007) to DSRAM[0] and idles
# Any unexpected trap writes 0xDEAD0000|mcause to DSRAM[0] and halts.
# =============================================================================

    .equ UART_BASE,    0x10503000
    .equ UART_LSR,     0x14
    .equ SPI2_BASE,    0x10502000
    .equ TIMER_BASE,   0x10501000      # timer0: +0 TIMER +4 CTRL +8 CMP
    .equ CLINT_MTIMECMP_LO, 0x02004000
    .equ CLINT_MTIMECMP_HI, 0x02004004
    .equ CLINT_MTIME_LO,    0x0200BFF8
    .equ PLIC_PRIO5,   0x0C000014
    .equ PLIC_IE0,     0x0C002000
    .equ PLIC_THRESH0, 0x0C200000
    .equ PLIC_CC0,     0x0C200004
    .equ IRQ_TIMER,    5

    # DSRAM byte offsets: [0] result  [4] mtimer count  [8] last PLIC id
    #   [12] U-mode check  [16] UART data (tainted)  [20] constant (clean)
    .equ DSRAM_BASE,   0x00020000
    .equ STACK_TOP,    0x00021000
    .equ TEST_PASS,    0xB007B007
    .equ TEST_FAIL,    0xDEAD0000

    # DIFT policy, written once by the Machine-mode startup code.
    #   TPR: every instruction class ORs its source tags into the result,
    #        loads propagate the memory tag (bit 15).
    #   TCR: trap if the PC is tainted (bit 0) or if a jump target register
    #        is tainted (bit 1). Bit 6 (LOADSTORE_CHECK_DA) is NOT set: in this
    #        RTL it also makes the load-store unit trap on every load that
    #        returns a tainted word -- i.e. on every peripheral read, since
    #        peripheral input is tainted (docs/USER_MODE_AND_DIFT_CHANGES.md).
    .equ DIFT_TPR,     0x0000AAAA
    .equ DIFT_TCR,     0x00000003

    # mstatus.MPP (bits 12:11) and the machine interrupt enables
    .equ MSTATUS_MPP,  0x1800
    .equ MIE_MTIE_MEIE, 0x880

    .text
_start:
    j    main

# Ibex implements only VECTORED mtvec with a 256-byte aligned base
# (mtvec[7:0] are fixed): exceptions go to base+0, interrupt n to base+4*n.
# Every entry jumps to the common handler, which decodes mcause.
    .align 8
vector_table:
    .rept 32
    j    trap_handler
    .endr

# -----------------------------------------------------------------------------
# Machine-mode startup (runs once, right after the hardware handoff)
# -----------------------------------------------------------------------------
main:
    # mtvec FIRST -- it resets to the BootROM, which is no longer executable
    # after the handoff -- then clear the DSRAM data area so nothing left by a
    # recovery session (or a previous boot) is trusted. Clearing with clean
    # registers also clears the DIFT tags of every word.
    la   t0, vector_table
    ori  t0, t0, 1                    # MODE=vectored (Ibex ignores/forces it anyway)
    csrw mtvec, t0
    li   t0, DSRAM_BASE
    li   t1, STACK_TOP
clear_dsram:
    sw   zero, 0(t0)
    addi t0, t0, 4
    bltu t0, t1, clear_dsram
    li   sp, STACK_TOP

    # Park the machine timer (mtimecmp = all ones) before enabling its
    # interrupt: M-level interrupts are always taken while in User mode.
    li   t0, CLINT_MTIMECMP_HI
    li   t1, -1
    sw   t1, 0(t0)
    li   t0, CLINT_MTIMECMP_LO
    sw   t1, 0(t0)

    # DIFT policy: the one and only write (Machine mode only)
    li   t0, DIFT_TPR
    csrw tpr, t0
    li   t0, DIFT_TCR
    csrw tcr, t0

    # Interrupt enables. mstatus.MIE stays 0: Machine mode itself is never
    # interrupted; in User mode M-level interrupts are always enabled.
    li   t0, MIE_MTIE_MEIE
    csrw mie, t0

    # Drop to User mode: mstatus.MPP = U (00), mepc = user_main, mret
    li   t0, MSTATUS_MPP
    csrc mstatus, t0
    la   t0, user_main
    csrw mepc, t0
    mret

# -----------------------------------------------------------------------------
# User-mode application
# -----------------------------------------------------------------------------
user_main:
    li   s0, UART_BASE
    li   s1, DSRAM_BASE
    la   a0, msg_hello
    jal  ra, puts

    # ---- 1. User mode really is User mode -------------------------------------
    li   t0, 1
    sw   t0, 12(s1)                   # DSRAM[3] = 1: one illegal trap expected
    csrw tcr, zero                    # Machine-only CSR: traps, the handler skips it
    lw   t1, 12(s1)
    li   t2, 2
    bne  t1, t2, fail_code            # trap not seen -> not in User mode
    la   a0, msg_umode
    jal  ra, puts

    # ---- 1b. Peripheral input is tainted ----------------------------------------
    # Loads from the APB peripheral window return DIFT tag 1; with this TPR
    # (loads OR in the memory tag) the register is tainted and the store
    # carries the taint into DSRAM. A constant stored next to it stays clean.
    lw   t1, UART_LSR(s0)             # data from a peripheral -> tag 1
    sw   t1, 16(s1)                   # DSRAM[4] inherits the taint
    li   t1, 0x5A
    sw   t1, 20(s1)                   # DSRAM[5] clean
    la   a0, msg_taint
    jal  ra, puts

    # ---- 2. SPI #2: send 0xA5 --------------------------------------------------
    li   t0, SPI2_BASE
    sw   zero, 0x04(t0)               # CLKDIV
    sw   zero, 0x10(t0)               # clear LEN first
    li   t1, 0x00080000               # 8 data bits, no cmd/addr
    sw   t1, 0x10(t0)
    li   t1, 0xA5000000               # MSB-first from bit 31
    sw   t1, 0x18(t0)                 # TXFIFO
    li   t1, 0x102                    # wr + CS0
    sw   t1, 0x00(t0)
spi_wait:
    lw   t1, 0x00(t0)
    srli t2, t1, 24
    andi t2, t2, 0x1F                 # TX FIFO elements
    bnez t2, spi_wait
    andi t1, t1, 1                    # idle
    beqz t1, spi_wait
    la   a0, msg_spi
    jal  ra, puts

    # ---- 3. CLINT machine timer (MTIE already enabled by the startup code) ----
    li   t0, CLINT_MTIME_LO
    lw   t1, 0(t0)
    addi t1, t1, 500
    li   t0, CLINT_MTIMECMP_LO
    sw   t1, 0(t0)                    # HI is still all ones: not armed yet
    li   t0, CLINT_MTIMECMP_HI
    sw   zero, 0(t0)                  # armed (mtime < 2^32 this early in simulation)
mtimer_wait:
    lw   t1, 4(s1)
    beqz t1, mtimer_wait
    la   a0, msg_mtimer
    jal  ra, puts

    # ---- 4. PLIC external interrupt from the APB timer (MEIE already on) ------
    li   t0, PLIC_PRIO5
    li   t1, 1
    sw   t1, 0(t0)
    li   t0, PLIC_IE0
    li   t1, 1 << IRQ_TIMER
    sw   t1, 0(t0)
    li   t0, PLIC_THRESH0
    sw   zero, 0(t0)
    li   t0, TIMER_BASE
    sw   zero, 0(t0)                  # TIMER = 0
    li   t1, 200
    sw   t1, 8(t0)                    # CMP
    li   t1, 1
    sw   t1, 4(t0)                    # CTRL.enable, no prescaler
plic_wait:
    lw   t1, 8(s1)
    beqz t1, plic_wait
    li   t2, IRQ_TIMER
    bne  t1, t2, fail_code            # claimed the wrong source
    la   a0, msg_plic
    jal  ra, puts

    # ---- done ------------------------------------------------------------------
    li   t0, TEST_PASS
    sw   t0, 0(s1)
    la   a0, msg_pass
    jal  ra, puts
idle:
    wfi                               # legal in User mode (mstatus.TW = 0)
    j    idle

fail_code:
    li   t0, TEST_FAIL
    or   t0, t0, t1
    sw   t0, 0(s1)
    la   a0, msg_fail
    jal  ra, puts
    j    idle

# -----------------------------------------------------------------------------
# Trap handler (Machine mode): machine timer and PLIC external interrupts, the
# one expected illegal instruction from the User-mode check; anything else
# fails. mret returns to the interrupted mode (User).
# -----------------------------------------------------------------------------
    .align 2
trap_handler:
    addi sp, sp, -16
    sw   t0, 0(sp)
    sw   t1, 4(sp)
    sw   t2, 8(sp)
    sw   s1, 12(sp)
    li   s1, DSRAM_BASE
    csrr t0, mcause
    bgez t0, trap_exception
    andi t0, t0, 0x3F
    li   t1, 7
    beq  t0, t1, irq_mtimer
    li   t1, 11
    beq  t0, t1, irq_external
    j    trap_fatal
irq_mtimer:
    li   t0, CLINT_MTIMECMP_HI
    li   t1, -1
    sw   t1, 0(t0)                    # push mtimecmp out of reach -> mtip clears
    lw   t1, 4(s1)
    addi t1, t1, 1
    sw   t1, 4(s1)
    j    trap_return
irq_external:
    li   t0, TIMER_BASE
    sw   zero, 4(t0)                  # stop the APB timer
    li   t0, PLIC_CC0
    lw   t1, 0(t0)                    # claim
    sw   t1, 8(s1)
    sw   t1, 0(t0)                    # complete
trap_return:
    lw   t0, 0(sp)
    lw   t1, 4(sp)
    lw   t2, 8(sp)
    lw   s1, 12(sp)
    addi sp, sp, 16
    mret
trap_exception:
    # The User-mode check expects exactly one illegal instruction (mcause 2)
    # while DSRAM[3] == 1: record it (DSRAM[3] = 2) and skip the instruction.
    csrr t1, mcause
    li   t0, 2
    bne  t1, t0, trap_fatal
    lw   t0, 12(s1)
    li   t2, 1
    bne  t0, t2, trap_fatal
    li   t0, 2
    sw   t0, 12(s1)
    csrr t0, mepc
    addi t0, t0, 4
    csrw mepc, t0
    j    trap_return
trap_fatal:
    csrr t1, mcause
    li   t0, TEST_FAIL
    or   t0, t0, t1
    sw   t0, 0(s1)
    j    idle

# puts: print NUL-terminated string at a0 (clobbers a0, t0, t1)
puts:
    lbu  t1, 0(a0)
    beqz t1, puts_done
puts_wait:
    lw   t0, UART_LSR(s0)
    andi t0, t0, 0x20
    beqz t0, puts_wait
    sw   t1, 0(s0)
    addi a0, a0, 1
    j    puts
puts_done:
    ret

msg_hello:  .asciz "[APP] hello from verified firmware in ISRAM\r\n"
msg_umode:  .asciz "[APP] running in User mode: TCR write trapped\r\n"
msg_taint:  .asciz "[APP] UART data stored to DSRAM (tainted by hardware)\r\n"
msg_spi:    .asciz "[APP] SPI2 byte sent\r\n"
msg_mtimer: .asciz "[APP] CLINT timer interrupt OK\r\n"
msg_plic:   .asciz "[APP] PLIC external interrupt OK (APB timer, source 5)\r\n"
msg_pass:   .asciz "[APP] PASS\r\n"
msg_fail:   .asciz "[APP] FAIL\r\n"
    .align 2
