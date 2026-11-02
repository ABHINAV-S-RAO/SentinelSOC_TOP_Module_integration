#include "soc.h"
#include "test_utils.h"

// External SPI flash boot test:
// 1. Ibex starts execution in BootROM.
// 2. Configures QSPI controller for external flash read.
// 3. Emulates reading bootloader/firmware payload from SPI flash into ISRAM (0x00010000).
// 4. Locks ISRAM to protect loaded code.
// 5. Jumps to and executes payload in ISRAM.
// 6. ISRAM payload writes PASS signature.

typedef void (*fn_ptr_t)(void);

int main(void) {
    // 1. Initialize QSPI master
    QSPI_CLKDIV = 0x02;
    QSPI_SPICMD = 0x03; // Standard Read command (03h)
    QSPI_SPIADR = 0x00001000; // Flash address offset
    // 8-bit cmd, 24-bit addr, 32-bit data transfer
    QSPI_SPILEN = (8 << 0) | (24 << 8) | (32 << 16);

    // 2. Load execution payload into ISRAM (simulating secondary bootloader load)
    // We write a simple function into ISRAM:
    //   li a0, 0
    //   ret
    // In RV32:
    //   li a0, 0 -> addi a0, zero, 0 -> 0x00000513
    //   ret      -> jalr zero, 0(ra) -> 0x00008067
    volatile uint32_t *isram_code = (volatile uint32_t *)ISRAM_BASE;
    isram_code[0] = 0x00000513; // addi a0, zero, 0
    isram_code[1] = 0x00008067; // ret

    // Verify ISRAM written successfully
    ASSERT(isram_code[0] == 0x00000513, 1);
    ASSERT(isram_code[1] == 0x00008067, 2);

    // 3. Lock ISRAM (write-once sticky)
    CTRL_CTRL0 = 1;
    ASSERT((CTRL_STATUS0 & (1 << CTRL_STATUS0_ISRAM_LOCKED_BIT)) != 0, 3);

    // 4. Verify ISRAM write is now blocked (ROM remap mode)
    uint32_t traps_before = exc_count;
    isram_code[0] = 0xDEADBEEF;
    wait_cycles(10);
    ASSERT(exc_count == traps_before + 1, 4);
    ASSERT(isram_code[0] == 0x00000513, 5); // Unchanged

    // 5. Jump and execute payload from ISRAM
    fn_ptr_t isram_func = (fn_ptr_t)ISRAM_BASE;
    isram_func();

    // 6. Seal boot
    CTRL_CTRL1 = 1;
    ASSERT((CTRL_BOOT_STATUS & 1) != 0, 6);

    return 0; // Success
}
