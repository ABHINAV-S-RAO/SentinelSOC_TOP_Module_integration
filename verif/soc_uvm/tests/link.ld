/*
 * Ibex resets to BOOT_ADDR + 0x80 unconditionally (fixed in ibex_if_stage.sv,
 * not configurable). BOOT_ADDR = 0x0000_0000 here (basic_soc_top.sv
 * localparam), so .text must start at 0x80 or the core's first fetch lands
 * on whatever happens to precede it.
 *
 * BOOTROM is fetch-only in soc_addr_decode.sv (no SEL_BOOTROM on the data
 * arbiter, only FSEL_BOOTROM on fetch) -- .rodata/.data must NOT be placed
 * here or data-side loads/stores stall forever with no gnt.
 */
MEMORY
{
  BOOTROM (rx)  : ORIGIN = 0x00000080, LENGTH = 0xFF80   /* 64KB, minus 0x80 reset vector offset */
  ISRAM   (rwx) : ORIGIN = 0x00010000, LENGTH = 0x10000   /* 64KB, matches soc_addr_decode ISRAM region */
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
  } > ISRAM

  .data : {
    *(.data*)
  } > ISRAM

  /DISCARD/ : {
    *(.riscv.attributes)
    *(.comment)
  }
}