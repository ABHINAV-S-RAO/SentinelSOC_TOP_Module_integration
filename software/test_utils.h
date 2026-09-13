#ifndef TEST_UTILS_H
#define TEST_UTILS_H

#include "soc.h"

// Write PASS signature to DSRAM[0] and halt
static inline void PASS() {
    REG32(DSRAM_BASE) = TEST_PASS;
    while(1) { __asm__ volatile ("wfi"); }
}

// Write FAIL signature + code to DSRAM[0] and halt
static inline void FAIL(uint16_t code) {
    REG32(DSRAM_BASE) = TEST_FAIL | code;
    while(1) { __asm__ volatile ("wfi"); }
}

// Assert macro
#define ASSERT(cond, code) do { if (!(cond)) FAIL(code); } while (0)

// Wait loop (spin delay)
static inline void wait_cycles(uint32_t cycles) {
    for (volatile uint32_t i = 0; i < cycles; i++) {}
}

// Global IRQ counter (updated by handler)
extern volatile uint32_t irq_count;
extern volatile uint32_t exc_count;

#endif // TEST_UTILS_H
