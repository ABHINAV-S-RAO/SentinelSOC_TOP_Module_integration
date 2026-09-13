#include "soc.h"
#include "test_utils.h"

int main() {
    // 1. Soft-reset crypto core via BUF_CTRL (bit 0) and ACCEL_CTRL (direct softrst bit? no, buf_ctrl has softrst)
    BUF_CTRL = 1; // soft_reset
    wait_cycles(10);
    BUF_CTRL = 0; // release

    // 2. Configure BUF_BLK_SIZE = 16 words
    BUF_BLK_SIZE = 16;

    // 3. Configure BUF_MSG_LEN = 17 (16 word header + 1 payload)
    BUF_MSG_LEN = 17;

    // 4. Configure BUF_ACCEL_CTRL (first_block = bit 0, last_block = bit 1)
    // We'll send one block only, so it is both first and last
    BUF_ACCEL_CTRL = 3;

    // 5. Assert BUF_CTRL stream_enable (bit 1)
    BUF_CTRL = 2;

    // 6. Write 16 words sequentially to DATA_FIFO
    for (int i = 0; i < 16; i++) {
        REG32(BUF_DATA_FIFO) = 0x55555555 + i;
    }

    // 7. Poll BUF_STATUS for done (bit 3)
    int timeout = 300000;
    while (!(BUF_STATUS & 8)) { // done is bit 3 (1<<3 = 8)
        timeout--;
        ASSERT(timeout > 0, 1);
    }

    // 8. Test passed
    return 0;
}
