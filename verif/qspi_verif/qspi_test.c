#define QSPI_BASE       0x10001000 // APB QSPI Base Address
#define REG_CTRL        *(volatile unsigned int*)(QSPI_BASE + 0x00)
#define REG_STATUS      *(volatile unsigned int*)(QSPI_BASE + 0x04)
#define REG_TXDATA      *(volatile unsigned int*)(QSPI_BASE + 0x08)
#define REG_RXDATA      *(volatile unsigned int*)(QSPI_BASE + 0x0C)
#define REG_CLKDIV      *(volatile unsigned int*)(QSPI_BASE + 0x10)

void main() {
    // 1. Clock Prescaler Sweep (Div 2, 4, 8, 16)
    for (int div = 1; div <= 8; div <<= 1) {
        REG_CLKDIV = div;
    }

    // 2. Standard Single-SPI (1-1-1) Read Flash ID (Opcode 0x9F)
    REG_CTRL = 0x00000001; // Enable SPI, Single Mode
    REG_TXDATA = 0x9F;     // READ_ID command
    while (REG_STATUS & 0x01); // Wait for done

    // 3. Quad-SPI (1-4-4) Fast Read Sweep (Opcode 0xEB)
    REG_CTRL = 0x00000004; // Enable Quad Mode (4-bit IO)
    REG_TXDATA = 0xEB;
    REG_TXDATA = 0x000000; // 24-bit dummy address
    
    // 4. FIFO Stress: Fill TX FIFO to trigger Full & Overflow flags
    for (int i = 0; i < 16; i++) {
        REG_TXDATA = 0xA5A5A5A5;
    }

    // End of Test marker for TB
    *(volatile unsigned int*)(0x00030000) = 0x1; // Write to SYS_CTRL done reg
}