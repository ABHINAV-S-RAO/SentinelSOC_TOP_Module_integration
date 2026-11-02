#include "soc.h"
#include "test_utils.h"

// Exhaustive Memory Subsystem Test:
// Covers Walking-1s, Walking-0s, Checkerboard, Address-as-Data, and Byte-lane Enables.

int main(void) {
    // We test a 64-word window in DSRAM (from offset 0x400 to 0x500 to keep stack safe)
    volatile uint32_t *dsram = (volatile uint32_t *)(DSRAM_BASE + 0x400);
    const int NUM_WORDS = 64;

    // -------------------------------------------------------------------------
    // 1. Walking-1s Test across 32 bits
    // -------------------------------------------------------------------------
    for (int b = 0; b < 32; b++) {
        uint32_t pattern = (1U << b);
        for (int i = 0; i < NUM_WORDS; i++) {
            dsram[i] = pattern;
        }
        for (int i = 0; i < NUM_WORDS; i++) {
            ASSERT(dsram[i] == pattern, 0x1000 | b);
        }
    }

    // -------------------------------------------------------------------------
    // 2. Walking-0s Test across 32 bits
    // -------------------------------------------------------------------------
    for (int b = 0; b < 32; b++) {
        uint32_t pattern = ~(1U << b);
        for (int i = 0; i < NUM_WORDS; i++) {
            dsram[i] = pattern;
        }
        for (int i = 0; i < NUM_WORDS; i++) {
            ASSERT(dsram[i] == pattern, 0x2000 | b);
        }
    }

    // -------------------------------------------------------------------------
    // 3. Checkerboard Patterns (0xAAAAAAAA and 0x55555555)
    // -------------------------------------------------------------------------
    for (int i = 0; i < NUM_WORDS; i++) {
        dsram[i] = (i & 1) ? 0xAAAAAAAA : 0x55555555;
    }
    for (int i = 0; i < NUM_WORDS; i++) {
        uint32_t expected = (i & 1) ? 0xAAAAAAAA : 0x55555555;
        ASSERT(dsram[i] == expected, 0x3000 | i);
    }

    // Inverted Checkerboard
    for (int i = 0; i < NUM_WORDS; i++) {
        dsram[i] = (i & 1) ? 0x55555555 : 0xAAAAAAAA;
    }
    for (int i = 0; i < NUM_WORDS; i++) {
        uint32_t expected = (i & 1) ? 0x55555555 : 0xAAAAAAAA;
        ASSERT(dsram[i] == expected, 0x3100 | i);
    }

    // -------------------------------------------------------------------------
    // 4. Address-as-Data (Verifies address decoding & unaliased memory space)
    // -------------------------------------------------------------------------
    for (int i = 0; i < NUM_WORDS; i++) {
        dsram[i] = (uint32_t)&dsram[i];
    }
    for (int i = 0; i < NUM_WORDS; i++) {
        ASSERT(dsram[i] == (uint32_t)&dsram[i], 0x4000 | i);
    }

    // -------------------------------------------------------------------------
    // 5. Byte & Halfword Write-Enable / Strobe Testing
    // -------------------------------------------------------------------------
    volatile uint8_t *b_ptr = (volatile uint8_t *)dsram;
    dsram[0] = 0x00000000;

    // Write individual bytes (tests be=4'b0001, 4'b0010, 4'b0100, 4'b1000)
    b_ptr[0] = 0xDE;
    ASSERT(dsram[0] == 0x000000DE, 0x5001);
    b_ptr[1] = 0xAD;
    ASSERT(dsram[0] == 0x0000ADDE, 0x5002);
    b_ptr[2] = 0xBE;
    ASSERT(dsram[0] == 0x00BEADDE, 0x5003);
    b_ptr[3] = 0xEF;
    ASSERT(dsram[0] == 0xEFBEADDE, 0x5004);

    // Halfword writes (tests be=4'b0011, 4'b1100)
    volatile uint16_t *h_ptr = (volatile uint16_t *)dsram;
    h_ptr[0] = 0x1234;
    ASSERT(dsram[0] == 0xEFBE1234, 0x5005);
    h_ptr[1] = 0x5678;
    ASSERT(dsram[0] == 0x56781234, 0x5006);

    return 0; // Success
}
