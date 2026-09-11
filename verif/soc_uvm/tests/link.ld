/*
 * Ibex resets to BOOT_ADDR + 0x80 unconditionally (fixed in ibex_if_stage.sv,
 * not configurable). BOOT_ADDR = 0x0000_0000 here (basic_soc_top.sv
 * localparam), so .text must start at 0x80 or the core's first fetch lands
 * on whatever happens to precede it.
 */
MEMORY
{
  BOOTROM (rx) : ORIGIN = 0x00000000, LENGTH = 0x10000   /* 64KB, matches soc_addr_decode BOOTROM region */
}

SECTIONS
{
  . = 0x80;
  .text : {
    *(.text.start)
    *(.text*)
  } > BOOTROM

  .rodata : {
    *(.rodata*)
  } > BOOTROM

  .data : {
    *(.data*)
  } > BOOTROM

  /DISCARD/ : {
    *(.riscv.attributes)
    *(.comment)
  }
}
