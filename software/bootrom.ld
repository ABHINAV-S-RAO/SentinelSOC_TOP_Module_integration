/* bootrom.ld - Linker script for SentinelSOC BootROM firmware
 * BootROM: 0x0000_0000, 4KB (1024 x 32-bit words)
 * DSRAM:   0x0002_0000, 4KB (for stack + data section)
 */
OUTPUT_ARCH(riscv)
ENTRY(_start)

MEMORY {
    ROM  (rx)  : ORIGIN = 0x00000000, LENGTH = 4K
    DSRAM (rw) : ORIGIN = 0x00020000, LENGTH = 4K
}

SECTIONS {
    .vectors 0x00000000 : {
        *(.vectors)
    } > ROM

    .text : {
        *(.text .text.*)
    } > ROM

    .rodata : {
        *(.rodata .rodata.*)
    } > ROM

    .data : {
        exc_count = .;
        *(.data .data.*)
    } > DSRAM

    .bss : {
        *(.bss .bss.*)
        *(COMMON)
    } > DSRAM

    /DISCARD/ : {
        *(.comment)
        *(.note*)
    }
}
