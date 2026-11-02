#include "soc.h"
#include "test_utils.h"

// Track claimed interrupts
volatile uint32_t claimed_irq = 0;
volatile uint32_t last_claimed_id = 0;

void irq_handler(void) {
    uint32_t id = PLIC_CC0;
    last_claimed_id = id;
    claimed_irq |= (1 << id);
    PLIC_CC0 = id; // Complete interrupt
}

int main(void) {
    uint32_t traps_before;

    // =========================================================================
    // Phase 1: Memory Subsystem Integrity (ISRAM & DSRAM)
    // =========================================================================
    // 1. Walking-1s on ISRAM
    for (int i = 0; i < 32; i++) {
        REG32(ISRAM_BASE + i * 4) = (1U << i);
    }
    for (int i = 0; i < 32; i++) {
        ASSERT(REG32(ISRAM_BASE + i * 4) == (1U << i), 0x1000 | i);
    }

    // 2. DSRAM word, halfword, and byte accesses (at offset 0x100 to avoid DSRAM[0])
    volatile uint8_t *dsram_b = (volatile uint8_t *)(DSRAM_BASE + 0x100);
    dsram_b[0] = 0x12;
    dsram_b[1] = 0x34;
    dsram_b[2] = 0x56;
    dsram_b[3] = 0x78;
    ASSERT(REG32(DSRAM_BASE + 0x100) == 0x78563412, 0x1020);

    // =========================================================================
    // Phase 2: Access Control & ISRAM Lock
    // =========================================================================
    ASSERT((CTRL_BOOT_STATUS & 1) == 0, 0x2001);
    ASSERT((CTRL_CTRL0 & 1) == 0, 0x2002);

    traps_before = exc_count;
    CTRL_CTRL0 = 1; // Lock ISRAM
    ASSERT((CTRL_STATUS0 & (1 << CTRL_STATUS0_ISRAM_LOCKED_BIT)) != 0, 0x2003);

    // Attempt locked ISRAM write -> should trap (store access fault)
    REG32(ISRAM_BASE) = 0xDEADBEEF;
    wait_cycles(10);
    ASSERT(exc_count == traps_before + 1, 0x2004);
    ASSERT(REG32(ISRAM_BASE) == 1U, 0x2005); // Data intact

    // =========================================================================
    // Phase 3: Hardware Crypto Accelerator & OTP Verification
    // =========================================================================
    CRYPTO_CTRL = (1 << CRYPTO_CTRL_SOFTRST_BIT);
    for (int i = 0; i < 8; i++) {
        CRYPTO_R_IN = 0x11111111 * (i + 1);
        CRYPTO_S_IN = 0x22222222 * (i + 1);
    }
    CRYPTO_MSG_LEN = 17;
    CRYPTO_CTRL = (1 << CRYPTO_CTRL_START_BIT);

    int timeout = 10000;
    while (!(CRYPTO_STATUS & (1 << CRYPTO_STATUS_READY_BIT))) {
        timeout--;
        ASSERT(timeout > 0, 0x3001);
    }
    CRYPTO_DATA_IN = 0xCAFEBABE;

    timeout = 300000;
    while (!(CRYPTO_STATUS & (1 << CRYPTO_STATUS_DONE_BIT))) {
        timeout--;
        ASSERT(timeout > 0, 0x3002);
    }
    ASSERT((CRYPTO_STATUS & (1 << CRYPTO_STATUS_VALID_BIT)) != 0, 0x3003);

    // =========================================================================
    // Phase 4: PLIC Setup & Global Interrupt Enable
    // =========================================================================
    PLIC_PRIO(IRQ_UART)  = 3;
    PLIC_PRIO(IRQ_GPIO)  = 2;
    PLIC_PRIO(IRQ_TIMER) = 1;

    PLIC_IE0 = (1 << IRQ_UART) | (1 << IRQ_GPIO) | (1 << IRQ_TIMER);
    PLIC_THRESHOLD0 = 0;

    __asm__ volatile ("csrs mie, %0" :: "r"(1 << 11)); // MEIE
    __asm__ volatile ("csrs mstatus, %0" :: "r"(1 << 3)); // MIE

    // =========================================================================
    // Phase 5: APB Dual Timer Service & Interrupt Verification
    // =========================================================================
    TIMER0_VAL  = 0;
    TIMER0_CMP  = 100;
    TIMER0_CTRL = TIMER_CTRL_ENABLE;

    timeout = 15000;
    while (!(claimed_irq & (1 << IRQ_TIMER))) {
        timeout--;
        ASSERT(timeout > 0, 0x5001);
    }
    TIMER0_CTRL = 0; // Disable timer

    // =========================================================================
    // Phase 6: APB GPIO Walking Pins & Interrupt
    // =========================================================================
    GPIO_PADDIR = 0xFFFFFFFF;
    GPIO_PADOUT = 0x55555555;
    wait_cycles(5);
    GPIO_PADOUT = 0xAAAAAAAA;

    timeout = 10000;
    while (!(claimed_irq & (1 << IRQ_GPIO))) {
        timeout--;
        ASSERT(timeout > 0, 0x6001);
    }

    // =========================================================================
    // Phase 7: APB UART 16550 String Transmission
    // =========================================================================
    UART_LCR = UART_LCR_DLAB;
    UART_DLL = 0x1B;
    UART_DLM = 0x00;
    UART_LCR = 0x03; // 8N1

    const char *msg = "[SentinelSOC] FULL INTEGRATED TEST PASS!\r\n";
    for (int i = 0; msg[i] != '\0'; i++) {
        UART_THR = msg[i];
        timeout = 10000;
        while (!(UART_LSR & UART_LSR_THRE)) {
            timeout--;
            ASSERT(timeout > 0, 0x7001);
        }
    }
    timeout = 10000;
    while (!(UART_LSR & UART_LSR_TEMT)) {
        timeout--;
        ASSERT(timeout > 0, 0x7002);
    }

    // =========================================================================
    // Phase 8: APB QSPI Register Path Verification
    // =========================================================================
    QSPI_CLKDIV = 0x04;
    ASSERT((QSPI_CLKDIV & 0xFF) == 0x04, 0x8001);
    QSPI_SPICMD = 0xA5;
    ASSERT((QSPI_SPICMD & 0xFF) == 0xA5, 0x8002);

    // =========================================================================
    // Phase 9: DIFT Register Programming
    // =========================================================================
    __asm__ volatile ("csrw 0x7C3, %0" :: "r"(0xFFFFFFFF)); // TPR
    __asm__ volatile ("csrw 0x7C2, %0" :: "r"(0x80));       // TCR
    uint32_t tcr_val;
    __asm__ volatile ("csrr %0, 0x7C2" : "=r"(tcr_val));
    ASSERT((tcr_val & 0xFF) == 0x80, 0x9001);

    // =========================================================================
    // Phase 10: Synchronous Trap Robustness
    // =========================================================================
    traps_before = exc_count;
    // 1. Intentional illegal instruction
    __asm__ volatile (".word 0x00000000");
    wait_cycles(10);
    ASSERT(exc_count == traps_before + 1, 0xA001);

    // 2. Intentional unmapped read (SEL_ERR)
    traps_before = exc_count;
    volatile uint32_t *unmapped = (volatile uint32_t *)0xDEAD0000;
    volatile uint32_t dummy = *unmapped;
    (void)dummy;
    wait_cycles(10);
    ASSERT(exc_count == traps_before + 1, 0xA002);

    // =========================================================================
    // Phase 11: Boot Finalization & Post-Boot Security Seal
    // =========================================================================
    CTRL_CTRL1 = 1; // boot_done_set
    ASSERT((CTRL_BOOT_STATUS & 1) != 0, 0xB001);

    // Privileged access post-boot should trap
    traps_before = exc_count;
    CTRL_CTRL0 = 0x12345678;
    wait_cycles(10);
    ASSERT(exc_count == traps_before + 1, 0xB002);

    return 0; // Success -> writes TEST_PASS (0xB007B007)
}
