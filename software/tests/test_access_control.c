#include "soc.h"
#include "test_utils.h"

int main() {
    // 1. Verify BOOT_STATUS[0] == 0 at start
    ASSERT((CTRL_BOOT_STATUS & 1) == 0, 1);

    // 2. Verify isram_lock = 0
    ASSERT((CTRL_CTRL0 & 1) == 0, 2);

    // 3. Write ISRAM[0]
    REG32(ISRAM_BASE) = 0xA5A5A5A5;

    // 4. Read back
    ASSERT(REG32(ISRAM_BASE) == 0xA5A5A5A5, 3);

    uint32_t traps_before = exc_count;

    // 5. Set ISRAM lock
    CTRL_CTRL0 = 1;

    // 6. Attempt ISRAM write (should trap)
    REG32(ISRAM_BASE) = 0xDEADBEEF;

    // Wait a couple cycles for the trap to return
    wait_cycles(10);
    ASSERT(exc_count == traps_before + 1, 4);

    // 7. Verify ISRAM was not modified
    ASSERT(REG32(ISRAM_BASE) == 0xA5A5A5A5, 5);

    // 8. Set boot_done
    CTRL_CTRL1 = 1;
    
    // 9. Post-boot: privileged write to CTRL0 (should trap)
    traps_before = exc_count;
    CTRL_CTRL0 = 0xFFFFFFFF;
    wait_cycles(10);
    ASSERT(exc_count == traps_before + 1, 6);

    // 10. Post-boot: privileged read from CTRL0 (should trap)
    traps_before = exc_count;
    uint32_t val = CTRL_CTRL0;
    wait_cycles(10);
    ASSERT(exc_count == traps_before + 1, 7);

    // 11. Post-boot: privileged write to CRYPTO_CTRL (should trap)
    traps_before = exc_count;
    CRYPTO_CTRL = 1;
    wait_cycles(10);
    ASSERT(exc_count == traps_before + 1, 8);

    // Total exceptions should be 4
    // 1 from ISRAM write, 3 from post-boot priv accesses
    // Note: the test might have run with a non-zero exc_count from startup,
    // so we just tracked relative increments.

    return 0;
}
