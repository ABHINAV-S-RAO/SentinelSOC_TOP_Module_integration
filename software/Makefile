# Sentinel SoC Bare-Metal Makefile
TOOLCHAIN_PREFIX = riscv64-unknown-elf-
CC = $(TOOLCHAIN_PREFIX)gcc
OBJCOPY = $(TOOLCHAIN_PREFIX)objcopy

# RV32IMC for Ibex, ILP32 ABI, optimized for size, bare-metal flags
CFLAGS = -march=rv32imc -mabi=ilp32 -Os -nostartfiles -nostdlib -ffreestanding

# Base addresses mapped from soc_addr_decode.sv
BOOTROM_BASE = 0x00000000
ISRAM_BASE   = 0x00010000

all: bootrom.hex

# Compile BootROM (starts at 0x00000000)
bootrom.elf: bootrom.c
	$(CC) $(CFLAGS) -Wl,-Ttext=$(BOOTROM_BASE) bootrom.c -o bootrom.elf

bootrom.hex: bootrom.elf
	$(OBJCOPY) -O verilog bootrom.elf bootrom.hex

clean:
	rm -f *.elf *.hex *.bin