void main(void);

// Bare-metal entry point
void __attribute__((section(".text.entry"))) _start(void) {
    __asm__ volatile (
        "la sp, 0x0001FFFF\n"  // Set stack pointer to top of RAM
        "call main\n"          // Call C main function
        "1: wfi\n"             // Sleep if main returns
        "j 1b\n"
    );
}

#define QSPI_BASE       0x10001000 // APB QSPI Base Address
#define REG_CTRL        *(volatile unsigned int*)(QSPI_BASE + 0x00)
#define REG_STATUS      *(volatile unsigned int*)(QSPI_BASE + 0x04)
#define REG_TXDATA      *(volatile unsigned int*)(QSPI_BASE + 0x08)
#define REG_RXDATA      *(volatile unsigned int*)(QSPI_BASE + 0x0C)
#define REG_CLKDIV      *(volatile unsigned int*)(QSPI_BASE + 0x10)

void main(void) {
    // 1. Clock Prescaler Sweep
    for (int div = 1; div <= 8; div <<= 1) {
        REG_CLKDIV = div;
    }

    // 2. Standard Single-SPI (1-1-1) Read Flash ID (Opcode 0x9F)
    REG_CTRL = 0x00000001; 
    REG_TXDATA = 0x9F;     
    while (REG_STATUS & 0x01); 

    // 3. Quad-SPI (1-4-4) Fast Read Sweep (Opcode 0xEB)
    REG_CTRL = 0x00000004; 
    REG_TXDATA = 0xEB;
    REG_TXDATA = 0x000000; 
    
    // 4. FIFO Stress
    for (int i = 0; i < 16; i++) {
        REG_TXDATA = 0xA5A5A5A5;
    }

    *(volatile unsigned int*)(0x00030000) = 0x1; // Signal test completion
}