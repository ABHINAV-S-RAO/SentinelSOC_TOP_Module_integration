# software/Makefile - Build SentinelSOC BootROM firmware
# Usage: make        (builds all hex files)
#        make clean  (remove build artifacts)

CROSS ?= $(shell which riscv64-unknown-elf-gcc >/dev/null 2>&1 && echo riscv64-unknown-elf || \
                 (which riscv32-unknown-elf-gcc >/dev/null 2>&1 && echo riscv32-unknown-elf) || \
                 echo riscv64-unknown-elf)
CC       = $(CROSS)-gcc
OBJCOPY  = $(CROSS)-objcopy
OBJDUMP  = $(CROSS)-objdump

ARCH_FLAGS = -march=rv32imc -mabi=ilp32

CFLAGS  = $(ARCH_FLAGS) -nostdlib -nostartfiles -static -I. -O2
LDFLAGS = -T crt0.ld

TESTS = tests/test_integrated_soc \
        tests/test_spiflash_boot \
        tests/test_trap_robustness \
        tests/test_soc_stress \
        tests/test_rv32imc_isa \
        tests/test_memory_exhaustive \
        tests/test_plic_priority_arbitration \
        tests/test_benchmark_dhrystone \
        tests/test_uart_boot \
        tests/test_crypto_accelerator \
        tests/test_plic_interrupts \
        tests/test_access_control \
        tests/test_dift_integration \
        tests/test_soc_buffer_stream

all: $(addsuffix .hex, $(TESTS)) $(addsuffix .dump, $(TESTS)) bootrom.hex

# Original bootrom.S
bootrom.elf: bootrom.S bootrom.ld
	$(CC) $(ARCH_FLAGS) -nostdlib -nostartfiles -static -T bootrom.ld -o bootrom.elf bootrom.S

# C tests
%.elf: %.c crt0.S crt0.ld soc.h test_utils.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ crt0.S $<

%.hex: %.elf
	$(OBJCOPY) -O binary $< $*.bin
	python3 bin2hex.py $*.bin $@

%.dump: %.elf
	$(OBJDUMP) -d -M no-aliases $< > $@

clean:
	rm -f bootrom.elf bootrom.bin bootrom.hex bootrom.dump
	rm -f tests/*.elf tests/*.bin tests/*.hex tests/*.dump

.PHONY: all clean
