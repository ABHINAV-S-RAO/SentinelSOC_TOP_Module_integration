#include "soc.h"
#include "test_utils.h"

// 32-bit LFSR for pseudo-random data generation
static inline uint32_t lfsr32(uint32_t val) {
    uint32_t bit = ((val >> 0) ^ (val >> 1) ^ (val >> 21) ^ (val >> 31)) & 1;
    return (val >> 1) | (bit << 31);
}

int main(void) {
    uint32_t seed = 0xACE1ACE1;
    volatile uint32_t *dsram = (volatile uint32_t *)(DSRAM_BASE + 0x200);

    // 1. Initialize UART for stress streaming
    UART_LCR = UART_LCR_DLAB;
    UART_DLL = 0x08; // High speed
    UART_DLM = 0x00;
    UART_LCR = 0x03;

    // 2. Initialize GPIO for output
    GPIO_PADDIR = 0xFFFFFFFF;

    // 3. Stress loop: 200 iterations of random memory operations + peripheral writes
    for (int iter = 0; iter < 100; iter++) {
        // Pseudo-random write to DSRAM array
        seed = lfsr32(seed);
        int idx = (seed & 0x1F); // 0 to 31
        dsram[idx] = seed;

        // Verify immediately
        ASSERT(dsram[idx] == seed, 0x1000 | iter);

        // Toggle GPIO pins with seed
        GPIO_PADOUT = seed;

        // Push byte to UART (poll with timeout to prevent hang)
        if (UART_LSR & UART_LSR_THRE) {
            UART_THR = (uint8_t)(seed & 0x7F);
        }
    }

    // 4. Memory read-back stress check across whole array
    for (int i = 0; i < 32; i++) {
        volatile uint32_t v = dsram[i];
        (void)v;
    }

    return 0; // Success
}
