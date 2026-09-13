// crt0.S - C Runtime Startup for SentinelSOC
.section .vectors, "ax"
.global _start
_start:
    j   reset_handler   // 0x00: reset vector
.org 0x4
    j   trap_handler    // 0x04: all traps (direct mode)

.section .text
.global reset_handler
reset_handler:
    // Setup mtvec = 0 (direct mode, vector table at 0x0)
    csrwi mtvec, 0

    // Set stack pointer to top of DSRAM
    li   sp, 0x00021000

    // Zero .bss section
    la   a0, _sbss
    la   a1, _ebss
    bge  a0, a1, end_clear_bss
clear_bss:
    sw   zero, 0(a0)
    addi a0, a0, 4
    blt  a0, a1, clear_bss
end_clear_bss:

    // Call main
    call main

    // Main returned - write success if return 0, else fail
    beqz a0, success
    // Write fail + return code
    li   t0, 0x00020000
    li   t1, 0xDEAD0000
    or   t1, t1, a0
    sw   t1, 0(t0)
    j    halt

success:
    li   t0, 0x00020000
    li   t1, 0xB007B007
    sw   t1, 0(t0)

halt:
    wfi
    j    halt

// ---------------------------------------------------------------------------
// Unified Trap Handler
// ---------------------------------------------------------------------------
.global trap_handler
trap_handler:
    // Save registers
    addi sp, sp, -64
    sw   ra,  0(sp)
    sw   t0,  4(sp)
    sw   t1,  8(sp)
    sw   t2, 12(sp)
    sw   a0, 16(sp)
    sw   a1, 20(sp)
    sw   a2, 24(sp)
    sw   a3, 28(sp)
    sw   a4, 32(sp)
    sw   a5, 36(sp)
    sw   a6, 40(sp)
    sw   a7, 44(sp)

    // Check if interrupt or exception
    csrr t0, mcause
    bltz t0, is_interrupt

is_exception:
    la   t1, exc_count
    lw   t2, 0(t1)
    addi t2, t2, 1
    sw   t2, 0(t1)

    // Advance mepc past faulting instruction
    csrr t2, mepc
    lh   t1, 0(t2)
    andi t1, t1, 3
    li   t0, 3
    beq  t1, t0, 1f
    addi t2, t2, 2
    j    2f
1:  addi t2, t2, 4
2:  csrw mepc, t2
    j    restore_and_ret

is_interrupt:
    la   t1, irq_count
    lw   t2, 0(t1)
    addi t2, t2, 1
    sw   t2, 0(t1)
    
    // Call user irq_handler (C function if defined)
    // We assume the user program implements void irq_handler(void)
    call irq_handler

restore_and_ret:
    // Restore registers
    lw   ra,  0(sp)
    lw   t0,  4(sp)
    lw   t1,  8(sp)
    lw   t2, 12(sp)
    lw   a0, 16(sp)
    lw   a1, 20(sp)
    lw   a2, 24(sp)
    lw   a3, 28(sp)
    lw   a4, 32(sp)
    lw   a5, 36(sp)
    lw   a6, 40(sp)
    lw   a7, 44(sp)
    addi sp, sp, 64
    mret

// Global counters
.section .data
.align 2
.global exc_count
exc_count: .word 0

.global irq_count
irq_count: .word 0

// Weak default irq_handler in case user doesn't provide one
.weak irq_handler
irq_handler:
    ret
