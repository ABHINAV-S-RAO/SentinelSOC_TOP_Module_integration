#include <stdint.h>

// SoC Memory Map (from soc_addr_decode.sv)
#define DSRAM_TOP  0x00021000 // 0x00020000 + 4KB
#define QSPI_BASE  0x10500000
#define UART_BASE  0x10503000

// QSPI Registers (Assuming standard apb_spi_master offsets)
#define QSPI_STATUS REG32(QSPI_BASE + 0x00)
#define QSPI_CMD    REG32(QSPI_BASE + 0x04)
#define QSPI_TX     REG32(QSPI_BASE + 0x08)
#define QSPI_RX     REG32(QSPI_BASE + 0x0C)

#define UART_TX     REG32(UART_BASE + 0x00)

#define REG32(addr) (*((volatile uint32_t *)(addr)))

// -----------------------------------------------------------------------------
// Bare-Metal Startup (Replaces boot_start.s)
// -----------------------------------------------------------------------------
void main(void);

// This forces the compiler to put this exact assembly at the very top of the ROM
__attribute__((naked, section(".text.init"))) void _start(void) {
    __asm__ volatile (
        "li sp, %0\n" // Load Stack Pointer to the top of DSRAM
        "j main\n"    // Jump to C code
        : : "i" (DSRAM_TOP)
    );
}

// -----------------------------------------------------------------------------
// C Logic
// -----------------------------------------------------------------------------
void uart_print(const char *str) {
    while (*str) {
        UART_TX = *str++;
    }
}

void main(void) {
    uart_print("\n--- Sentinel BootROM Secure Boot Sequence ---\n");
    uart_print("Initializing QSPI...\n");

    // 1. Write 'Read JEDEC ID' (0x9F) to QSPI TX register
    QSPI_TX = 0x9F;

    // 2. Trigger transaction (Modify offset/bits based on exact SPI IP specs)
    // QSPI_CMD = 0x... 
    
    // 3. Read back the response
    uint32_t flash_id = QSPI_RX;

    if (flash_id == 0xEF4016) {
        uart_print("SUCCESS: Flash JEDEC ID verified via OBI-APB Bridge.\n");
    } else {
        uart_print("ERROR: Flash ID Mismatch.\n");
    }

    // Halt core
    while(1) {
        __asm__ volatile ("wfi"); 
    }
}