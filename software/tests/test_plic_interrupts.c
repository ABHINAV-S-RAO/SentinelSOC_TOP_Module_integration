#include "soc.h"
#include "test_utils.h"

volatile uint32_t claimed_irq = 0;

void irq_handler() {
    // Claim interrupt from PLIC
    uint32_t id = PLIC_CC0;
    
    // Complete interrupt
    PLIC_CC0 = id;

    // Record the latest ID
    claimed_irq = id;
}

int main() {
    // 1. Set priorities
    PLIC_PRIO(IRQ_UART) = 3; // Highest
    PLIC_PRIO(IRQ_GPIO) = 2; // Medium
    PLIC_PRIO(IRQ_SPI)  = 1; // Lowest

    // 2. Enable IRQ sources for Target 0
    PLIC_IE0 = (1 << IRQ_UART) | (1 << IRQ_GPIO) | (1 << IRQ_SPI);

    // 3. Set threshold to 0 (accept any priority > 0)
    PLIC_THRESHOLD0 = 0;

    // 4. Enable global interrupts in Ibex
    // MSTATUS.MIE = bit 3, MIE.MEIE = bit 11
    __asm__ volatile ("csrs mie, %0" :: "r"(1 << 11));
    __asm__ volatile ("csrs mstatus, %0" :: "r"(1 << 3));

    // 5. Trigger UART IRQ (source 1)
    UART_LCR = 0x03; 
    UART_IER = UART_IER_THRE; // enable THRE interrupt
    UART_THR = 0xAA; // this will drain quickly and raise THRE

    int timeout = 10000;
    while(claimed_irq != IRQ_UART) {
        timeout--;
        ASSERT(timeout > 0, 1);
    }
    
    // Clear the IRQ so it doesn't fire again
    UART_IER = 0;

    // 6. Trigger GPIO IRQ (source 4)
    // Writing to PADOUT with PADDIR=1 toggles the output and triggers the GPIO irq
    GPIO_PADDIR = 0xFFFFFFFF;
    claimed_irq = 0; // reset
    GPIO_PADOUT = 0xA5A5A5A5;

    timeout = 10000;
    while(claimed_irq != IRQ_GPIO) {
        timeout--;
        ASSERT(timeout > 0, 2);
    }

    return 0;
}
