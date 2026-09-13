#include "soc.h"
#include "test_utils.h"

int main() {
    // 1. Soft-reset crypto core
    CRYPTO_CTRL = (1 << CRYPTO_CTRL_SOFTRST_BIT);

    // 2. Write 8 words to R_IN (known test vector)
    for (int i = 0; i < 8; i++) {
        CRYPTO_R_IN = 0x11111111 * i;
    }

    // 3. Write 8 words to S_IN
    for (int i = 0; i < 8; i++) {
        CRYPTO_S_IN = 0x22222222 * i;
    }

    // 4. Write MSG_LEN = 17 (16-word header + 1-word payload)
    CRYPTO_MSG_LEN = 17;

    // 5. Write CTRL[0]=1 (start)
    CRYPTO_CTRL = (1 << CRYPTO_CTRL_START_BIT);

    // 6. Poll STATUS[1] (ready_for_word), write 1 word to DATA_IN
    int timeout = 10000;
    while (!(CRYPTO_STATUS & (1 << CRYPTO_STATUS_READY_BIT))) {
        timeout--;
        ASSERT(timeout > 0, 1);
    }
    CRYPTO_DATA_IN = 0xCAFEBABE;

    // 7. Poll STATUS[2] (done) and STATUS[3] (sig_valid)
    timeout = 300000; // crypto takes ~200k cycles
    while (!(CRYPTO_STATUS & (1 << CRYPTO_STATUS_DONE_BIT))) {
        timeout--;
        ASSERT(timeout > 0, 2);
    }

    // 8. With OTP backdoor programmed, assert sig_valid
    ASSERT((CRYPTO_STATUS & (1 << CRYPTO_STATUS_VALID_BIT)) != 0, 3);

    return 0;
}
