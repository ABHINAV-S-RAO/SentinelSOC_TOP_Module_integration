# =============================================================================
# software/app/app_demo.S -- first signed firmware for the full-SoC flow
#
# Linked at the ISRAM entry 0x0001_0044 (image = 17-word header + this code),
# with a 256-byte aligned vector table (Ibex mtvec is vectored-only),
# signed with software/tools/sign_image.py and booted by software/boot/bootrom.S.
# Exercises, in order, printing progress over UART:
#   1. UART output from verified code
#   2. SPI #2 (APB 0x1050_2000): transmit one byte 0xA5 on CS0
#   3. CLINT machine-timer interrupt  (mtimecmp -> irq_timer -> mcause 7)
#   4. PLIC external interrupt from the APB timer compare (source 5 -> mcause 11,
#      claim/complete)
#   5. writes TEST_PASS (0xB007B007) to DSRAM[0] and idles
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

    .equ DSRAM_BASE,   0x00020000      # [0] result  [4] mtimer count  [8] last PLIC id
    .equ STACK_TOP,    0x00021000
    .equ TEST_PASS,    0xB007B007
    .equ TEST_FAIL,    0xDEAD0000

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

main:
    li   sp, STACK_TOP
    li   s0, UART_BASE
    li   s1, DSRAM_BASE
    sw   zero, 0(s1)
    sw   zero, 4(s1)
    sw   zero, 8(s1)
    la   t0, vector_table
    ori  t0, t0, 1                    # MODE=vectored (Ibex ignores/forces it anyway)
    csrw mtvec, t0
    la   a0, msg_hello
    jal  ra, puts

    # ---- 1. SPI #2: send 0xA5 --------------------------------------------------
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

    # ---- 2. CLINT machine timer -----------------------------------------------
    li   t0, CLINT_MTIME_LO
    lw   t1, 0(t0)
    addi t1, t1, 500
    li   t0, CLINT_MTIMECMP_LO
    sw   t1, 0(t0)
    li   t0, CLINT_MTIMECMP_HI
    sw   zero, 0(t0)                  # mtime < 2^32 this early in simulation
    li   t0, 0x80
    csrs mie, t0                      # MTIE
    csrsi mstatus, 8                  # MIE
mtimer_wait:
    lw   t1, 4(s1)
    beqz t1, mtimer_wait
    la   a0, msg_mtimer
    jal  ra, puts

    # ---- 3. PLIC external interrupt from the APB timer ------------------------
    li   t0, PLIC_PRIO5
    li   t1, 1
    sw   t1, 0(t0)
    li   t0, PLIC_IE0
    li   t1, 1 << IRQ_TIMER
    sw   t1, 0(t0)
    li   t0, PLIC_THRESH0
    sw   zero, 0(t0)
    li   t0, 0x800
    csrs mie, t0                      # MEIE
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
    wfi
    j    idle

fail_code:
    li   t0, TEST_FAIL
    or   t0, t0, t1
    sw   t0, 0(s1)
    la   a0, msg_fail
    jal  ra, puts
    j    idle

# -----------------------------------------------------------------------------
# Trap handler: machine timer and PLIC external interrupts; anything else fails
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
    j    trap_exception
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
    csrr t1, mcause
    li   t0, TEST_FAIL
    or   t0, t0, t1
    li   s1, DSRAM_BASE
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
msg_spi:    .asciz "[APP] SPI2 byte sent\r\n"
msg_mtimer: .asciz "[APP] CLINT timer interrupt OK\r\n"
msg_plic:   .asciz "[APP] PLIC external interrupt OK (APB timer, source 5)\r\n"
msg_pass:   .asciz "[APP] PASS\r\n"
msg_fail:   .asciz "[APP] FAIL\r\n"
    .align 2
