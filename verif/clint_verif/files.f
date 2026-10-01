// =============================================================================
// verif/clint_verif/files.f
// Compilation filelist for the CLINT standalone/SoC-level verification bench.
//
// Usage (Xcelium from workspace root):
//   xrun -f verif/clint_verif/files.f -top tb_clint_top -access +rwc \
//        +TEST=all -timescale 1ns/1ps
//
// To run a single phase:
//   xrun ... +TEST=phase3
// =============================================================================

// ---------------------------------------------------------------------------
// Include directories
// ---------------------------------------------------------------------------
+incdir+rtl/core/ibex_core/vendor/lowrisc_ip/dv/sv/dv_utils
+incdir+rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl
+incdir+rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim_generic/rtl
+incdir+.bender/git/checkouts/common_cells-229df333cc9dff23/include
+incdir+.bender/git/checkouts/apb-1b178314edfb6925/include
+incdir+.bender/git/checkouts/obi-75858655e8b256db/include
+incdir+verif/clint_verif

// ---------------------------------------------------------------------------
// Bender-managed library dependencies (OBI, APB, common_cells, etc.)
// ---------------------------------------------------------------------------
-f verif/bender_files.f

// ---------------------------------------------------------------------------
// Ibex core
// ---------------------------------------------------------------------------
rtl/core/ibex_core/rtl/ibex_pkg.sv
rtl/core/ibex_core/rtl/ibex_tracer_pkg.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim_generic/rtl/prim_clock_gating.sv

-f rtl/core/ibex_core/rtl/ibex_core.f

// ---------------------------------------------------------------------------
// DIFT modules (always compiled; sentinel_soc_top uses `ifdef DIFT guards)
// ---------------------------------------------------------------------------
rtl/core/dift/ibex_dift_logic.sv
rtl/core/dift/ibex_dift_mem.sv
rtl/core/dift/ibex_dift_tmu.sv
rtl/core/dift/ibex_register_file_latch_tag.sv

// ---------------------------------------------------------------------------
// Peripherals (needed by sentinel_soc_top)
// ---------------------------------------------------------------------------
rtl/peripheral/apb_uart/io_generic_fifo.sv
rtl/peripheral/apb_uart/uart_rx.sv
rtl/peripheral/apb_uart/uart_tx.sv
rtl/peripheral/apb_uart/uart_interrupt.sv
rtl/peripheral/apb_uart/apb_uart.sv
rtl/peripheral/apb_uart/apb_uart_sv.sv

rtl/peripheral/apb_spi_master/apb_spi_master.sv
rtl/peripheral/apb_timer/apb_timer.sv
rtl/peripheral/apb_gpio/apb_gpio.sv

// ---------------------------------------------------------------------------
// Interrupt controllers
// ---------------------------------------------------------------------------
rtl/Interrupts/plic/plic_regmap.sv
rtl/Interrupts/plic/rv_plic_gateway.sv
rtl/Interrupts/plic/rv_plic_target.sv
rtl/Interrupts/plic/plic_top.sv

// CLINT — the DUT block
rtl/Interrupts/clint.sv

// ---------------------------------------------------------------------------
// Crypto / OTP (needed by sentinel_soc_top)
// ---------------------------------------------------------------------------
rtl/crypto/ed25519/ED25519/ED25519.srcs/sources_1/new/SHA/sha512_pkg.sv
rtl/crypto/ed25519/ED25519/ED25519.srcs/sources_1/new/ALU/pseudo_mersenne.sv
rtl/crypto/ed25519/ED25519/ED25519.srcs/sources_1/new/ALU/multiplier.sv
rtl/crypto/ed25519/ED25519/ED25519.srcs/sources_1/new/ALU/alu.sv
rtl/crypto/ed25519/ED25519/ED25519.srcs/sources_1/new/ALU/alu_top.sv
rtl/crypto/ed25519/ED25519/ED25519.srcs/sources_1/new/SHA/sha512_msg_sched.sv
rtl/crypto/ed25519/ED25519/ED25519.srcs/sources_1/new/SHA/sha512_padder.sv
rtl/crypto/ed25519/ED25519/ED25519.srcs/sources_1/new/SHA/sha512_round.sv
rtl/crypto/ed25519/ED25519/ED25519.srcs/sources_1/new/SHA/sha512_top.sv
rtl/crypto/ed25519/ED25519/ED25519.srcs/sources_1/new/bram.sv
rtl/crypto/ed25519/ED25519/ED25519.srcs/sources_1/new/reg_file.sv
rtl/crypto/ed25519/ED25519/ED25519.srcs/sources_1/new/micro_seq.sv
rtl/crypto/ed25519/ED25519/ED25519.srcs/sources_1/new/master_fsm.sv
rtl/crypto/ed25519/ED25519/ED25519.srcs/sources_1/new/top_ed25519.sv
rtl/crypto/ed25519/ED25519/ED25519.srcs/sources_1/new/top_most.sv
rtl/crypto/ed25519/sha_ed25519_obi_wrapper.sv

// ---------------------------------------------------------------------------
// RISC-V debug module (dm_pkg.sv MUST come first — all others import dm::)
// ---------------------------------------------------------------------------
rtl/riscv-dbg/src/dm_pkg.sv
rtl/riscv-dbg/src/dm_mem.sv
rtl/riscv-dbg/src/dm_csrs.sv
rtl/riscv-dbg/src/dm_sba.sv
rtl/riscv-dbg/src/dm_obi_top.sv
rtl/riscv-dbg/src/dm_top.sv
rtl/riscv-dbg/src/dmi_cdc.sv
rtl/riscv-dbg/src/dmi_jtag_tap.sv
rtl/riscv-dbg/src/dmi_jtag.sv
rtl/riscv-dbg/src/dmi_intf.sv

// ---------------------------------------------------------------------------
// SoC glue
// ---------------------------------------------------------------------------
rtl/soc/soc_bootrom.sv
rtl/soc/soc_sram.sv
rtl/soc/soc_addr_decode.sv
rtl/soc/soc_ctrl_regs.sv
rtl/soc/soc_buffer.sv

// DUT — sentinel SoC top (with CLINT instantiated)
rtl/soc/sentinel_soc_top.sv

// ---------------------------------------------------------------------------
// CLINT verification bench
// ---------------------------------------------------------------------------
+incdir+verif/clint_verif
verif/clint_verif/clint_if.sv
verif/clint_verif/clint_tb_pkg.sv
verif/clint_verif/tb_clint_top.sv
