// =============================================================================
// bootrom.S - SentinelSOC Boot ROM Firmware
// Target: Ibex RV32IMC, base address 0x0000_0000
//
// Memory Map:
//   0x0000_0000  BootROM  4KB  (fetch-only; data reads -> SEL_ERR trap)
//   0x0001_0000  ISRAM    4KB
//   0x0002_0000  DSRAM    4KB
//   0x0003_0000  CTRL     4KB  (privileged, boot phase only)
//     +0x00  CTRL0       [0]=isram_lock (write-once sticky)
//     +0x04  STATUS0     [0]=crypto_verified [1]=isram_locked
//     +0x08  BOOT_STATUS [0]=boot_done
//     +0x0C  CTRL1       [0]=boot_done_set (self-clearing)
//   0x1050_0000  APB QSPI
//   0x1050_2000  APB SPI
//   0x1050_3000  APB UART
//   0x1060_0000  APB GPIO
// Edge cases exercised:
//  1. DSRAM round-trip (A5A5/5A5A pattern)
//  2. BOOT_STATUS == 0 at power-on
//  3. BootROM data read  -> SEL_ERR trap (data path to BootROM blocked)
//  4. Unmapped address   -> SEL_ERR trap
//  5. ISRAM write walking-1s before lock
//  6. ISRAM read-back verify
//  7. ISRAM lock via CTRL0[0]
//  8. STATUS0[1]=1 (locked readback)
//  9. Lock sticky: write 0, verify still 1
// 10. Locked ISRAM write  -> blocked (trap)
// 11. Locked ISRAM verify: old data intact
// 12. STATUS0[0] crypto_verified (0 in sim, informational)
// 13. Set boot_done via CTRL1
// 14. BOOT_STATUS readback == 1
// 15. Post-boot priv write  -> denied (trap)
// 16. Post-boot priv read   -> denied (trap)
// 17. UART APB TX smoke write
// 18. GPIO APB DIR+OUT smoke write
// 19. Write PASS_SIG/FAIL_SIG to DSRAM[0] for testbench
// =============================================================================

.section .vectors, "ax"
.global _start
_start:
    j   boot_main       // 0x00: reset vector
.org 0x4
    j   exc_handler     // 0x04: all traps (direct mode)

.section .text
.global boot_main
boot_main:
    // Setup mtvec = 0 (direct mode, vector table at 0x0)
    csrwi mtvec, 0

    // Stack: top of DSRAM
    li   sp, 0x00021000

    // ---------------------------------------------------------------
    // 1. DSRAM round-trip
    // ---------------------------------------------------------------
    li   t0, 0x00020000
    li   t1, 0xA5A5A5A5
    sw   t1, 4(t0)
    lw   t2, 4(t0)
    bne  t2, t1, fail

    li   t1, 0x5A5A5A5A
    sw   t1, 8(t0)
    lw   t2, 8(t0)
    bne  t2, t1, fail

    // ---------------------------------------------------------------
    // 2. BOOT_STATUS == 0 at power-on
    // ---------------------------------------------------------------
    li   t0, 0x00030000
    lw   t1, 0x08(t0)
    bnez t1, fail

    // ---------------------------------------------------------------
    // 3. BootROM data read -> SEL_ERR trap (data path blocked)
    // ---------------------------------------------------------------
    la   t4, exc_count
    lw   t1, 0(t4)
    li   t2, 0x00000004
    lw   zero, 0(t2)
    lw   t3, 0(t4)
    addi t1, t1, 1
    bne  t3, t1, fail

    // ---------------------------------------------------------------
    // 4. Unmapped address -> SEL_ERR trap
    // ---------------------------------------------------------------
    lw   t1, 0(t4)
    li   t2, 0xDEAD0000
    lw   zero, 0(t2)
    lw   t3, 0(t4)
    addi t1, t1, 1
    bne  t3, t1, fail

    // ---------------------------------------------------------------
    // 5. ISRAM write: walking 1s pattern (32 words)
    // ---------------------------------------------------------------
    li   t0, 0x00010000
    li   t1, 1
    li   t3, 32
1:  sw   t1, 0(t0)
    sll  t1, t1, 1
    addi t0, t0, 4
    addi t3, t3, -1
    bnez t3, 1b

    // ---------------------------------------------------------------
    // 6. ISRAM read-back verify
    // ---------------------------------------------------------------
    li   t0, 0x00010000
    li   t1, 1
    li   t3, 32
2:  lw   t2, 0(t0)
    bne  t2, t1, fail
    sll  t1, t1, 1
    addi t0, t0, 4
    addi t3, t3, -1
    bnez t3, 2b

    // ---------------------------------------------------------------
    // 7. Lock ISRAM: CTRL0[0]=1
    // ---------------------------------------------------------------
    li   t0, 0x00030000
    li   t1, 1
    sw   t1, 0x00(t0)

    // 8. STATUS0[1]=1 readback
    lw   t2, 0x04(t0)
    andi t2, t2, 2
    li   t3, 2
    bne  t2, t3, fail

    // 9. Lock is sticky: write 0, verify still 1
    sw   zero, 0x00(t0)
    lw   t2, 0x00(t0)
    andi t2, t2, 1
    beqz t2, fail

    // ---------------------------------------------------------------
    // 10. Locked ISRAM write -> trap (err response from addr_decode)
    // ---------------------------------------------------------------
    la   t4, exc_count
    lw   t1, 0(t4)
    li   t0, 0x00010000
    li   t5, 0xDEADBEEF
    sw   t5, 0(t0)
    lw   t3, 0(t4)
    addi t1, t1, 1
    bne  t3, t1, fail

    // 11. Old data still intact: ISRAM[0] == 1
    lw   t2, 0(t0)
    li   t3, 1
    bne  t2, t3, fail

    // ---------------------------------------------------------------
    // 12. crypto_verified (STATUS0[0]) -- informational, store to DSRAM
    // ---------------------------------------------------------------
    li   t0, 0x00030000
    lw   t1, 0x04(t0)
    andi t1, t1, 1
    li   t2, 0x00020000
    sw   t1, 12(t2)             // DSRAM[3]

    // ---------------------------------------------------------------
    // 13. Set boot_done via CTRL1[0]
    // ---------------------------------------------------------------
    li   t0, 0x00030000
    li   t1, 1
    sw   t1, 0x0C(t0)

    // 14. BOOT_STATUS readback == 1
    lw   t2, 0x08(t0)
    andi t2, t2, 1
    beqz t2, fail

    // ---------------------------------------------------------------
    // 15. Post-boot priv write -> denied (trap)
    // ---------------------------------------------------------------
    la   t4, exc_count
    lw   t1, 0(t4)
    li   t0, 0x00030000
    li   t5, 0xFFFFFFFF
    sw   t5, 0x00(t0)
    lw   t3, 0(t4)
    addi t1, t1, 1
    bne  t3, t1, fail

    // ---------------------------------------------------------------
    // 16. Post-boot priv read -> denied (trap)
    // ---------------------------------------------------------------
    lw   t1, 0(t4)
    lw   zero, 0x00(t0)
    lw   t3, 0(t4)
    addi t1, t1, 1
    bne  t3, t1, fail

    // ---------------------------------------------------------------
    // 17. UART APB TX smoke: write 0x55 to UART[0]
    // ---------------------------------------------------------------
    li   t0, 0x10503000
    li   t1, 0x55
    sw   t1, 0(t0)

    // ---------------------------------------------------------------
    // 18. GPIO APB smoke: PADDIR=0xFFFF PADOUT=0xA5A5A5A5
    // ---------------------------------------------------------------
    li   t0, 0x10600000
    li   t1, 0xFFFFFFFF
    sw   t1, 0(t0)
    li   t1, 0xA5A5A5A5
    sw   t1, 4(t0)

    // ---------------------------------------------------------------
    // 19. Write PASS signature to DSRAM[0]
    // ---------------------------------------------------------------
pass:
    li   t0, 0x00020000
    li   t1, 0xB007B007
    sw   t1, 0(t0)
    j    halt

fail:
    li   t0, 0x00020000
    li   t1, 0xDEADDEAD
    sw   t1, 0(t0)
halt:
    j    halt

// ---------------------------------------------------------------------------
// Exception handler: increment exc_count, skip faulting instruction, mret
// ---------------------------------------------------------------------------
exc_handler:
    addi sp, sp, -16
    sw   t0,  0(sp)
    sw   t1,  4(sp)
    sw   t2,  8(sp)
    sw   t3, 12(sp)

    la   t0, exc_count
    lw   t1, 0(t0)
    addi t1, t1, 1
    sw   t1, 0(t0)

    // Advance mepc: 2 bytes for compressed (opcode[1:0]!=11), else 4
    csrr t2, mepc
    lh   t3, 0(t2)
    andi t3, t3, 3
    li   t0, 3
    beq  t3, t0, 3f
    addi t2, t2, 2
    j    4f
3:  addi t2, t2, 4
4:  csrw mepc, t2

    lw   t0,  0(sp)
    lw   t1,  4(sp)
    lw   t2,  8(sp)
    lw   t3, 12(sp)
    addi sp, sp, 16
    mret

.section .data
.align 2
exc_count:
    .word 0
