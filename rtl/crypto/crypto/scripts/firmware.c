// firmware.c — arbitrary payload; top_most never executes it, only hashes it.
typedef unsigned int uint32_t;
volatile uint32_t *const GPIO_OUT = (uint32_t *)0x40000000;

static uint32_t fib(uint32_t n) {
    uint32_t a = 0, b = 1;
    for (uint32_t i = 0; i < n; i++) { uint32_t t = a + b; a = b; b = t; }
    return a;
}
static void delay(volatile uint32_t c) { while (c--) {} }

void _start(void) {
    uint32_t x = 0;
    while (1) { x = fib(x % 20); *GPIO_OUT = x; delay(1000); }
}