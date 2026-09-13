#include "soc.h"
#include "test_utils.h"

#define CSR_TCR 0x7C2
#define CSR_TPR 0x7C3

#define CSR_WRITE(csr, val) __asm__ volatile ("csrw " #csr ", %0" :: "rK"(val))
#define CSR_READ(csr, val)  __asm__ volatile ("csrr %0, " #csr : "=r"(val))

// TCR Bits based on ibex_dift_tmu.sv
#define JUMP_CHECK_S1      0
#define JUMP_CHECK_S2      1
#define JUMP_CHECK_D       2
#define BRANCH_CHECK_S1    3
#define BRANCH_CHECK_S2    4
#define LOADSTORE_CHECK_DA 5
#define LOADSTORE_CHECK_S  6
#define LOADSTORE_CHECK_D  7

int main() {
    // 1. Program TPR (Taint Policy Register) to propagate taint on everything
    // Just writing 0xFFFFFFFF sets all policy bits to 1 (max propagation)
    CSR_WRITE(CSR_TPR, 0xFFFFFFFF);

    // 2. Program TCR (Taint Control Register) to trigger violation on Load/Store destination
    // Bit 7 is LOADSTORE_CHECK_D
    CSR_WRITE(CSR_TCR, (1 << LOADSTORE_CHECK_D));

    // 3. Taint a memory location (in simulation this would normally be done via TMU propagation
    // or by loading from a peripheral that generates tags).
    // For the sake of test_dift_integration, if DIFT_EN=1, the processor will 
    // actively use the shadow pipeline. If DIFT_EN=0, it bypasses.
    
    // Perform standard operations that might trigger DIFT if fully seeded.
    for (int i = 0; i < 16; i++) {
        REG32(DSRAM_BASE + i * 4) = 0x11111111 * i;
    }

    uint32_t sum = 0;
    for (int i = 0; i < 16; i++) {
        sum += REG32(DSRAM_BASE + i * 4);
    }

    // 4. Peripheral interaction
    GPIO_PADDIR = 0xFFFFFFFF;
    GPIO_PADOUT = sum;

    // 5. In a real DIFT violation, irq_dift (PLIC source 8) would fire, causing an exception.
    // If DIFT_EN=1, we might see exc_count/irq_count increase if we successfully tainted data.
    // If DIFT_EN=0, they must remain 0.
    // We will just verify the processor didn't lock up and the CSR writes succeeded.
    
    uint32_t tcr_val;
    CSR_READ(CSR_TCR, tcr_val);
    ASSERT(tcr_val == (1 << LOADSTORE_CHECK_D), 1);

    return 0;
}
