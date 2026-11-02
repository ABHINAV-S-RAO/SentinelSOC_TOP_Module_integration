#include "soc.h"
#include "test_utils.h"

// Exhaustive PLIC Priority & Preemption Test

volatile uint32_t claim_sequence[4];
volatile int claim_idx = 0;

void irq_handler(void) {
    uint32_t id = PLIC_CC0;
    if (claim_idx < 4) {
        claim_sequence[claim_idx++] = id;
    }
    PLIC_CC0 = id; // Complete
}

int main(void) {
    // -------------------------------------------------------------------------
    // Phase 1: Priority Arbitration Order
    // Assign different priorities to UART (IRQ 1 = prio 1), GPIO (IRQ 4 = prio 3)
    // -------------------------------------------------------------------------
    PLIC_PRIO(IRQ_UART) = 1; // Lowest active
    PLIC_PRIO(IRQ_GPIO) = 3; // Highest active

    PLIC_IE0 = (1 << IRQ_UART) | (1 << IRQ_GPIO);
    PLIC_THRESHOLD0 = 0; // Accept all > 0

    // Set up both peripherals to assert simultaneously
    GPIO_PADDIR = 0xFFFFFFFF;
    UART_LCR = 0x03;
    UART_IER = UART_IER_THRE;

    // Clear record
    claim_idx = 0;

    // Enable CPU interrupts
    __asm__ volatile ("csrs mie, %0" :: "r"(1 << 11)); // MEIE
    __asm__ volatile ("csrs mstatus, %0" :: "r"(1 << 3)); // MIE

    // Trigger GPIO
    GPIO_PADOUT = 0x55555555;
    // Trigger UART
    UART_THR = 0x55;

    // Wait for both to be claimed
    int timeout = 10000;
    while (claim_idx < 2) {
        timeout--;
        ASSERT(timeout > 0, 0x1001);
    }

    // Since GPIO has priority 3 and UART has priority 1, GPIO must be claimed first!
    ASSERT(claim_sequence[0] == IRQ_GPIO, 0x1002);
    ASSERT(claim_sequence[1] == IRQ_UART, 0x1003);

    // Disable UART interrupt
    UART_IER = 0;

    // -------------------------------------------------------------------------
    // Phase 2: Threshold Filtering
    // Set threshold = 2. UART has priority 1 -> should NOT trigger interrupt!
    // -------------------------------------------------------------------------
    PLIC_THRESHOLD0 = 2; // Only priority > 2 (i.e. prio 3) is accepted

    claim_idx = 0;
    claim_sequence[0] = 0;

    UART_IER = UART_IER_THRE; // Re-enable UART interrupt
    UART_THR = 0xAA;

    wait_cycles(200); // Give plenty of time
    // Should NOT have triggered because priority 1 <= threshold 2
    ASSERT(claim_idx == 0, 0x2001);

    // Now trigger GPIO (priority 3 > threshold 2) -> should immediately trigger!
    GPIO_PADOUT = 0xAAAAAAAA;
    timeout = 10000;
    while (claim_idx == 0) {
        timeout--;
        ASSERT(timeout > 0, 0x2002);
    }
    ASSERT(claim_sequence[0] == IRQ_GPIO, 0x2003);

    // Cleanup
    UART_IER = 0;
    PLIC_IE0 = 0;

    return 0; // Success
}
