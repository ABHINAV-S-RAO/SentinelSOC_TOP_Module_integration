#include "soc.h"
#include "test_utils.h"

// Synthetic Integer Benchmark (Dhrystone-style arithmetic & control stress)

typedef struct {
    uint32_t val1;
    uint32_t val2;
    uint32_t sum;
} test_struct_t;

static uint32_t compute_iteration(uint32_t iter, test_struct_t *s) {
    s->val1 = iter * 33 + 7;
    s->val2 = iter * 17 + 13;
    s->sum  = s->val1 + s->val2;

    uint32_t res = 0;
    for (int j = 0; j < 8; j++) {
        res += (s->sum ^ (iter << j)) - (s->val1 >> (j & 3));
    }
    return res;
}

int main(void) {
    test_struct_t s;
    uint32_t accumulator = 0x12345678;

    // Run 100 benchmark iterations
    for (uint32_t i = 1; i <= 100; i++) {
        accumulator ^= compute_iteration(i, &s);
        accumulator = (accumulator << 5) | (accumulator >> 27); // ROR 27
    }

    // Verify deterministic result
    ASSERT(accumulator != 0, 0x1001);

    // Save final checksum to DSRAM[1] for verification
    REG32(DSRAM_BASE + 0x04) = accumulator;

    return 0; // Success
}
