.section .text.start
.global _start

# ---------------------------------------------------------------------------
# Address map (confirmed this session against soc_ctrl_regs.sv /
# soc_addr_decode.sv / basic_soc_top.sv -- not guessed):
#   CTRL_BASE   = 0x0003_0000
#     BOOT_STATUS_OFFSET = +0x008 (read,  bit0 = boot_done_q)
#     CTRL1_OFFSET       = +0x00C (write, bit0 = boot_done_set, always reads 0)
#   DSRAM_BASE  = 0x0002_0000  (word-addressed, ordinary RAM -- sw/lw)
#   UART_BASE   = 0x1000_0000  (BYTE-addressed register file, register_adr =
#                 PADDR[2:0] -- registers sit at consecutive byte offsets
#                 0x0..0x7, NOT word-aligned slots. lw at offset 0x5 would be
#                 a misaligned word access and likely trap -- lb/sb only.)
#       THR = +0x0   LSR = +0x5 (bit5 = THRE, tx-ready)
#
# No trap handler is installed and mtvec is left at its reset value. Every
# access below is either word-aligned (CTRL/DSRAM) or the intentionally
# byte-granular UART access -- if anything here IS misaligned or otherwise
# illegal, expect the same infinite illegal-instruction-at-PC-0 loop from
# the no-firmware run, not a clean failure. That symptom means re-check an
# address/width here, not a new RTL bug.
# ---------------------------------------------------------------------------

_start:
    # Set boot_done first. soc_addr_decode takes boot_done_i as an
    # access-control input and its exact gating scope on DSRAM/ISRAM
    # reads+writes isn't confirmed -- setting this before anything else
    # removes it as a variable if something below fails.
    li      t0, 0x00030000        # CTRL_BASE
    li      t1, 1
    sw      t1, 0x00C(t0)         # CTRL1_OFFSET: boot_done_set

    # --- Core sanity: basic ALU ops, no memory dependency ---
    li      t0, 5
    li      t1, 7
    add     t2, t0, t1             # t2 = 12
    sub     t3, t1, t0             # t3 = 2  (result unused, but visible on a wave dump)

    # --- DSRAM bus/decode read-write test ---
    li      s0, 0x00020000         # DSRAM_BASE
    li      s1, 0xDEADBEEF
    sw      s1, 0(s0)
    lw      s2, 0(s0)
    bne     s1, s2, dsram_fail

    li      s1, 0xCAFEF00D
    sw      s1, 4(s0)
    lw      s2, 4(s0)
    bne     s1, s2, dsram_fail
    j       dsram_pass

dsram_fail:
    li      s3, 0x0BADC0DE         # DSRAM test failed
    j       write_sentinel

dsram_pass:
    li      s3, 0x600DC0DE         # DSRAM test passed, proceed to UART

    # --- UART TX ---
    # First real exercise of the OBI->APB bridge's single-byte-strobe path
    # (obi_to_apb / apb peripheral bus) -- not validated by anything run
    # this session before now. If bytes come out garbled/missing on the
    # wave dump or a real UART monitor, suspect that path specifically,
    # not this firmware.
    li      s4, 0x10000000         # UART_BASE
    la      s5, msg

uart_loop:
    lb      s6, 0(s5)
    beqz    s6, uart_done

wait_thre:
    lb      s7, 0x5(s4)            # LSR
    andi    s7, s7, 0x20           # bit5 = THRE
    beqz    s7, wait_thre

    sb      s6, 0x0(s4)            # THR
    addi    s5, s5, 1
    j       uart_loop

uart_done:

write_sentinel:
    sw      s3, 8(s0)              # DSRAM_BASE+0x8 -- test-result sentinel.
                                    # 0x600DC0DE = DSRAM+UART path reached,
                                    # 0x0BADC0DE = DSRAM readback mismatch.
                                    # Check this word from the TB/waveform
                                    # after the run.

halt:
    j       halt                   # spin forever -- intentional, not a hang

.section .rodata
msg:
    .string "SENTINELSOC OK\n"