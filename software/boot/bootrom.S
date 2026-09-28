# =============================================================================
# software/boot/bootrom.S -- SentinelSoC secure-boot ROM (RV32I, 0x0000_0000)
#
# Power-on flow:
#   1. stack + UART (8N1, sim-fast divisor), banner
#   2. read the signed image header from external SPI flash (QSPI ctrl, CS0):
#        flash+0x00  sha_len (big-endian) = 16 + code_words
#        flash+0x04  R[32] S[32]            (Ed25519 signature)
#        flash+0x44  code[code_words*4]     (signed message, entry point)
#   3. copy the whole image (1 + sha_len words) byte-exact into ISRAM
#   4. lock ISRAM (CTRL0.isram_lock)
#   5. VERIFY_CTRL.start -> hardware reads ISRAM and checks the signature
#      against the OTP public key (soc_secure_boot); poll VERIFY_STATUS
#   6. verified: read VERIFY ENTRY, set boot_done, jump to the image entry.
#      not verified / bad header: print why and halt (JTAG recovery then
#      takes over via the boot watchdog).
#
# Assembles with software/tools/rvasm.py or riscv32-unknown-elf-gcc
# (-march=rv32i -nostdlib -Ttext=0). No stack use, no C runtime.
# =============================================================================

    .equ UART_BASE,    0x10503000
    .equ UART_THR,     0x00
    .equ UART_DLL,     0x00
    .equ UART_DLM,     0x04
    .equ UART_LCR,     0x0C
    .equ UART_LSR,     0x14
    .equ UART_DIV,     15            # bit time = DIV+1 clk cycles (sim-fast)

    .equ QSPI_BASE,    0x10500000
    .equ SPI_STATUS,   0x00          # W: [0] rd [1] wr [11:8] cs; R: [0] idle, [20:16] rx words
    .equ SPI_CLKDIV,   0x04
    .equ SPI_CMD,      0x08
    .equ SPI_ADDR,     0x0C
    .equ SPI_LEN,      0x10          # [5:0] cmd bits [13:8] addr bits [31:16] data bits
    .equ SPI_DUMMY,    0x14
    .equ SPI_RXFIFO,   0x20
    .equ FLASH_READ,   0x03000000    # SPI NOR READ (0x03), MSB-aligned
    .equ SPI_LEN_CA,   0x1808        # 8-bit cmd, 24-bit address
    .equ SPI_GO_RD,    0x101         # rd + CS0
    .equ CHUNK_WORDS,  8             # <= RX FIFO depth (10)

    .equ ISRAM_BASE,   0x00010000
    .equ ISRAM_WORDS,  2048          # 8 KB
    .equ CTRL_BASE,    0x00030000    # +0 CTRL0 (isram_lock) +C CTRL1 (boot_done_set)
    .equ VERIFY_BASE,  0x00050000    # +0 CTRL +4 STATUS +8 CODE_WORDS +C ENTRY
    .equ STACK_TOP,    0x00021000
    .equ FLASH_IMAGE,  0x000000      # image offset in flash

    .text
# -----------------------------------------------------------------------------
# 0x000-0x07C: trap vectors (mtvec resets to boot_addr, vectored) -> trap
# -----------------------------------------------------------------------------
vectors:
    .rept 32
    j   trap
    .endr

# -----------------------------------------------------------------------------
# 0x080: reset entry
# -----------------------------------------------------------------------------
    .org 0x80
_start:
    li   sp, STACK_TOP
    li   s0, UART_BASE
    li   s1, QSPI_BASE
    li   s4, 0x0000FF00             # byte-swap masks
    li   s5, 0x00FF0000

    # UART: 8N1, divisor UART_DIV
    li   t0, 0x83
    sw   t0, UART_LCR(s0)           # DLAB=1
    li   t0, UART_DIV
    sw   t0, UART_DLL(s0)
    sw   zero, UART_DLM(s0)
    li   t0, 0x03
    sw   t0, UART_LCR(s0)           # DLAB=0, 8 data bits
    la   a0, msg_banner
    jal  ra, puts

    # QSPI: fastest SPI clock
    sw   zero, SPI_CLKDIV(s1)

    # --- header word: sha_len ------------------------------------------------
    li   a0, FLASH_IMAGE
    li   a1, 1
    li   a2, ISRAM_BASE
    jal  ra, flash_read
    li   t1, ISRAM_BASE
    lw   t1, 0(t1)
    jal  ra, bswap_t1               # t1 = sha_len
    mv   s2, t1
    li   t0, 17
    bltu s2, t0, bad_image          # need >= 1 code word
    li   t0, ISRAM_WORDS
    bgeu s2, t0, bad_image          # 1 + sha_len words must fit ISRAM

    # --- rest of the image: sha_len words ------------------------------------
    li   a0, FLASH_IMAGE + 4
    mv   a1, s2
    li   a2, ISRAM_BASE + 4
    jal  ra, flash_read
    la   a0, msg_loaded
    jal  ra, puts

    # --- lock ISRAM, then verify ---------------------------------------------
    li   t0, CTRL_BASE
    li   t1, 1
    sw   t1, 0(t0)                  # CTRL0.isram_lock
    li   s3, VERIFY_BASE
    sw   t1, 0(s3)                  # VERIFY_CTRL.start
verify_wait:
    lw   t1, 4(s3)
    andi t2, t1, 2                  # done
    beqz t2, verify_wait
    andi t2, t1, 8                  # verified
    beqz t2, verify_fail

    la   a0, msg_verified
    jal  ra, puts
    la   a0, msg_jump               # print BEFORE boot_done: after it, ROM data
    jal  ra, puts                   # reads (these strings) are refused
    lw   s6, 12(s3)                 # ENTRY (read before boot_done hides the window)
    li   t0, CTRL_BASE
    li   t1, 1
    sw   t1, 12(t0)                 # CTRL1.boot_done_set -- no ROM data reads past here
    jr   s6

bad_image:
    la   a0, msg_bad_image
    jal  ra, puts
    j    halt
verify_fail:
    la   a0, msg_verify_fail
    jal  ra, puts
    j    halt
trap:
    csrr t0, mcause                 # load access fault: after boot_done the ROM strings
    li   t1, 5                      # are unreadable, so printing would fault again ->
    beq  t0, t1, halt               # halt silently instead of looping
    la   a0, msg_trap
    jal  ra, puts
halt:
    wfi
    j    halt

# -----------------------------------------------------------------------------
# flash_read: copy a1 words from flash byte address a0 to memory at a2,
# converting each SPI word (first byte in [31:24]) to a little-endian memory
# word so the destination is byte-exact. Clobbers a0-a2, t0-t6.
# -----------------------------------------------------------------------------
flash_read:
    mv   t6, ra
fr_chunk:
    beqz a1, fr_done
    li   t0, CHUNK_WORDS
    bgeu a1, t0, fr_go
    mv   t0, a1                     # last, partial chunk
fr_go:
    li   t1, FLASH_READ
    sw   t1, SPI_CMD(s1)
    slli t1, a0, 8                  # 24-bit address, MSB-aligned
    sw   t1, SPI_ADDR(s1)
    slli t2, t0, 21                 # data bits (words*32) << 16
    li   t3, SPI_LEN_CA
    or   t2, t2, t3
    sw   t2, SPI_LEN(s1)
    sw   zero, SPI_DUMMY(s1)
    li   t1, SPI_GO_RD
    sw   t1, SPI_STATUS(s1)
fr_wait_rx:                         # wait until the whole chunk is in the RX FIFO
    lw   t1, SPI_STATUS(s1)
    srli t1, t1, 16
    andi t1, t1, 0x1F
    bltu t1, t0, fr_wait_rx
fr_pop:
    lw   t1, SPI_RXFIFO(s1)
    jal  ra, bswap_t1
    sw   t1, 0(a2)
    addi a2, a2, 4
    addi a0, a0, 4
    addi a1, a1, -1
    addi t0, t0, -1
    bnez t0, fr_pop
fr_wait_idle:                       # transfer fully finished before the next one
    lw   t1, SPI_STATUS(s1)
    andi t1, t1, 1
    beqz t1, fr_wait_idle
    j    fr_chunk
fr_done:
    mv   ra, t6
    ret

# bswap_t1: t1 = byte-swapped t1 (uses t4, t5; masks in s4/s5)
bswap_t1:
    srli t4, t1, 24
    slli t5, t1, 24
    or   t4, t4, t5
    srli t5, t1, 8
    and  t5, t5, s4
    or   t4, t4, t5
    slli t5, t1, 8
    and  t5, t5, s5
    or   t1, t4, t5
    ret

# puts: print NUL-terminated string at a0 (clobbers a0, t0, t1)
puts:
    lbu  t1, 0(a0)
    beqz t1, puts_done
puts_wait:
    lw   t0, UART_LSR(s0)
    andi t0, t0, 0x20               # THRE: TX FIFO empty
    beqz t0, puts_wait
    sw   t1, UART_THR(s0)
    addi a0, a0, 1
    j    puts
puts_done:
    ret

# -----------------------------------------------------------------------------
msg_banner:      .asciz "\r\n[BOOT] SentinelSoC secure boot ROM\r\n"
msg_loaded:      .asciz "[BOOT] image copied from SPI flash to ISRAM\r\n"
msg_verified:    .asciz "[BOOT] Ed25519 signature VERIFIED\r\n"
msg_jump:        .asciz "[BOOT] setting boot_done, jumping to firmware\r\n"
msg_bad_image:   .asciz "[BOOT] ERROR: bad image header\r\n"
msg_verify_fail: .asciz "[BOOT] ERROR: signature verification FAILED\r\n"
msg_trap:        .asciz "[BOOT] ERROR: unexpected trap\r\n"
    .align 2
