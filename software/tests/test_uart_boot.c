#include "soc.h"
#include "test_utils.h"

int main() {
    // 1. Set LCR: DLAB=1, program DLL=0x1B (baud=115200 at 50MHz)
    UART_LCR = UART_LCR_DLAB;
    UART_DLL = 0x1B;
    UART_DLM = 0x00;

    // 2. Set LCR: 8N1 (DLAB=0, bits=0b11)
    UART_LCR = 0x03;

    // 3. Enable THRE interrupt in IER
    UART_IER = UART_IER_THRE;

    // 4. Write string to THR; after each, poll LSR[5] (TX FIFO empty)
    const char *msg = "Hello Sentinel!\n";
    for (int i = 0; msg[i] != '\0'; i++) {
        UART_THR = msg[i];
        
        // Spin until THRE is set
        int timeout = 10000;
        while (!(UART_LSR & UART_LSR_THRE)) {
            timeout--;
            ASSERT(timeout > 0, 1);
        }
    }

    // 5. Read LSR[6]: verify TX shift register drained
    int timeout = 10000;
    while (!(UART_LSR & UART_LSR_TEMT)) {
        timeout--;
        ASSERT(timeout > 0, 2);
    }

    // 6. Verify APB routing: read IIR, expect no spurious IRQ pending other than THRE
    // IIR bit 0 = 1 means no interrupt pending.
    // However, since we enabled THRE, and the FIFO is empty, THRE interrupt might be pending!
    // IIR for THRE is 0b0010 (bit 0=0, bit 1=1).
    uint32_t iir = UART_IIR;
    ASSERT((iir & 0x0F) == 0x02 || (iir & 0x01) == 1, 3); 

    // Done
    return 0;
}
