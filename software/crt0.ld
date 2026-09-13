/* crt0.ld - Linker script for SentinelSOC BootROM C firmware
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
        *(.srodata .srodata.*)
    } > ROM

    .data : {
        . = ALIGN(4);
        *(.data .data.*)
        *(.sdata .sdata.*)
    } > DSRAM

    .bss : {
        . = ALIGN(4);
        _sbss = .;
        *(.bss .bss.*)
        *(.sbss .sbss.*)
        *(COMMON)
        _ebss = .;
    } > DSRAM

    /DISCARD/ : {
        *(.comment)
        *(.note*)
    }
}
