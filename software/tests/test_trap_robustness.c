#include "soc.h"
#include "test_utils.h"

volatile uint32_t timer_irq_count = 0;

void irq_handler(void) {
    uint32_t id = PLIC_CC0;
    if (id == IRQ_TIMER) {
        timer_irq_count++;
        // Reset timer counter so it re-triggers periodically
        TIMER0_VAL = 0;
    }
    PLIC_CC0 = id;
}

int main(void) {
    uint32_t traps_before;

    // 1. Configure Timer interrupts to continuously fire under load
    PLIC_PRIO(IRQ_TIMER) = 1;
    PLIC_IE0 = (1 << IRQ_TIMER);
    PLIC_THRESHOLD0 = 0;

    __asm__ volatile ("csrs mie, %0" :: "r"(1 << 11)); // MEIE
    __asm__ volatile ("csrs mstatus, %0" :: "r"(1 << 3)); // MIE

    TIMER0_VAL  = 0;
    TIMER0_CMP  = 150; // fast periodic compare
    TIMER0_CTRL = TIMER_CTRL_ENABLE;

    // 2. Loop through multiple trap conditions while interrupts are active
    for (int iter = 0; iter < 10; iter++) {
        // Trap 1: Illegal instruction
        traps_before = exc_count;
        __asm__ volatile (".word 0x00000000");
        wait_cycles(5);
        ASSERT(exc_count == traps_before + 1, 0x100 | iter);

        // Trap 2: Load access fault on BootROM data port (0x00000000)
        traps_before = exc_count;
        volatile uint32_t *rom_ptr = (volatile uint32_t *)0x00000004;
        volatile uint32_t d1 = *rom_ptr;
        (void)d1;
        wait_cycles(5);
        ASSERT(exc_count == traps_before + 1, 0x200 | iter);

        // Trap 3: Load access fault on unmapped address
        traps_before = exc_count;
        volatile uint32_t *unmapped = (volatile uint32_t *)(0x50000000 + iter * 0x1000);
        volatile uint32_t d2 = *unmapped;
        (void)d2;
        wait_cycles(5);
        ASSERT(exc_count == traps_before + 1, 0x300 | iter);
    }

    // 3. Verify that timer interrupts were being successfully received and serviced
    ASSERT(timer_irq_count > 0, 0x900);

    // Stop timer
    TIMER0_CTRL = 0;

    return 0; // Success
}
