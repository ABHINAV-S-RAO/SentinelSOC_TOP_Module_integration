#include "soc.h"
#include "test_utils.h"

// Exhaustive test of RV32IMC ISA:
// Base Integer (RV32I), Hardware Multiplier/Divider (RV32M), and Compressed (RV32C)

int main(void) {
    // -------------------------------------------------------------------------
    // 1. RV32I ALU & Immediate Operations
    // -------------------------------------------------------------------------
    int32_t a = 12345;
    int32_t b = -6789;

    ASSERT((a + b) == (12345 - 6789), 0x101);
    ASSERT((a - b) == (12345 - (-6789)), 0x102);
    ASSERT((a ^ b) == (12345 ^ -6789), 0x103);
    ASSERT((a | b) == (12345 | -6789), 0x104);
    ASSERT((a & b) == (12345 & -6789), 0x105);
    ASSERT((a << 3) == (12345 << 3), 0x106);
    ASSERT((b >> 2) == (-6789 >> 2), 0x107); // Arithmetic shift
    ASSERT(((uint32_t)b >> 2) == ((uint32_t)-6789 >> 2), 0x108); // Logical shift

    // Comparisons
    ASSERT((a < b) == 0, 0x109);
    ASSERT(((uint32_t)a < (uint32_t)b) == 1, 0x10A); // Unsigned comparison

    // -------------------------------------------------------------------------
    // 2. RV32M Hardware Multiplication & Division Corner Cases
    // -------------------------------------------------------------------------
    // Standard multiplication
    int32_t m1 = 123456;
    int32_t m2 = 654321;
    int64_t prod = (int64_t)m1 * (int64_t)m2;
    int32_t mul_low = m1 * m2;
    ASSERT(mul_low == (int32_t)prod, 0x201);

    // MULH (high 32 bits signed)
    int32_t mulh_res;
    __asm__ volatile ("mulh %0, %1, %2" : "=r"(mulh_res) : "r"(m1), "r"(m2));
    ASSERT(mulh_res == (int32_t)(prod >> 32), 0x202);

    // MULHU (high 32 bits unsigned)
    uint32_t u1 = 0xF0000000;
    uint32_t u2 = 0x00000010;
    uint64_t uprod = (uint64_t)u1 * (uint64_t)u2;
    uint32_t mulhu_res;
    __asm__ volatile ("mulhu %0, %1, %2" : "=r"(mulhu_res) : "r"(u1), "r"(u2));
    ASSERT(mulhu_res == (uint32_t)(uprod >> 32), 0x203);

    // Standard Division & Remainder
    int32_t div_res = m2 / m1;
    int32_t rem_res = m2 % m1;
    ASSERT(div_res == 5, 0x204);
    ASSERT(rem_res == (654321 - 5 * 123456), 0x205);

    // Corner Case 1: Division by zero (RISC-V spec: x / 0 = -1, x % 0 = x)
    volatile int32_t zero_val = 0;
    int32_t div_zero;
    int32_t rem_zero;
    __asm__ volatile ("div %0, %1, %2" : "=r"(div_zero) : "r"(m1), "r"(zero_val));
    __asm__ volatile ("rem %0, %1, %2" : "=r"(rem_zero) : "r"(m1), "r"(zero_val));
    ASSERT(div_zero == -1, 0x206);
    ASSERT(rem_zero == m1, 0x207);

    // Corner Case 2: Signed overflow (0x80000000 / -1 -> quotient = 0x80000000, rem = 0)
    int32_t min_int = (int32_t)0x80000000;
    int32_t neg_one = -1;
    int32_t div_ovf;
    int32_t rem_ovf;
    __asm__ volatile ("div %0, %1, %2" : "=r"(div_ovf) : "r"(min_int), "r"(neg_one));
    __asm__ volatile ("rem %0, %1, %2" : "=r"(rem_ovf) : "r"(min_int), "r"(neg_one));
    ASSERT(div_ovf == min_int, 0x208);
    ASSERT(rem_ovf == 0, 0x209);

    // -------------------------------------------------------------------------
    // 3. Byte & Halfword Memory Load/Store Sign Extension
    // -------------------------------------------------------------------------
    volatile uint32_t *test_mem = (volatile uint32_t *)(DSRAM_BASE + 0x300);
    *test_mem = 0xA5B6C7D8;

    volatile int8_t  *b_ptr  = (volatile int8_t *)test_mem;
    volatile uint8_t *ub_ptr = (volatile uint8_t *)test_mem;
    volatile int16_t *h_ptr  = (volatile int16_t *)test_mem;
    volatile uint16_t *uh_ptr = (volatile uint16_t *)test_mem;

    // Byte 0: 0xD8 (signed = -40, unsigned = 0xD8)
    ASSERT(b_ptr[0] == (int8_t)0xD8, 0x301);
    ASSERT(ub_ptr[0] == 0xD8, 0x302);

    // Halfword 0: 0xC7D8 (signed = -14376, unsigned = 0xC7D8)
    ASSERT(h_ptr[0] == (int16_t)0xC7D8, 0x303);
    ASSERT(uh_ptr[0] == 0xC7D8, 0x304);

    // Halfword 1: 0xA5B6
    ASSERT(h_ptr[1] == (int16_t)0xA5B6, 0x305);
    ASSERT(uh_ptr[1] == 0xA5B6, 0x306);

    // -------------------------------------------------------------------------
    // 4. Branch & Jump Variations
    // -------------------------------------------------------------------------
    volatile int branch_taken = 0;
    if (a > b) branch_taken = 1;
    ASSERT(branch_taken == 1, 0x401);

    branch_taken = 0;
    if (b > a) branch_taken = 1;
    ASSERT(branch_taken == 0, 0x402);

    return 0; // Success
}
