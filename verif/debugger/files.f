// =============================================================================
// Compiler & Simulation Options
// =============================================================================
// CHANGED: -uvm dropped (no UVM classes used by this TB)
// CHANGED: -top soc_tb_top -> -top dbg_tb_top (new non-UVM debugger top,
//          see "Debugger Testbench" section below -- NOT YET WRITTEN)
-64bit -sv -timescale 1ns/1ps -access +rwc -coverage functional -covoverwrite -top dbg_tb_top
+define+DIFT

// =============================================================================
// Include Directories (RTL + Vendor)
// =============================================================================
// REMOVED: dv_utils incdir (UVM/DV-utility macros only, unused without UVM)
// REMOVED: verif/soc_uvm, interface/monitor/scoreboard/sequence_item incdirs
// KEPT: prim/prim_generic/common_cells/apb/obi -- still needed, these back
//       plain typedef/assign macros used inside the DUT RTL itself, not UVM
+incdir+rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl
+incdir+rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim_generic/rtl
+incdir+.bender/git/checkouts/common_cells-229df333cc9dff23/include
+incdir+.bender/git/checkouts/apb-1b178314edfb6925/include
+incdir+.bender/git/checkouts/obi-75858655e8b256db/include

// NEW: debugger TB's own include path (JTAG interface, mem models, top)
+incdir+verif/debugger
+incdir+verif/debugger/interface

// =============================================================================
// Vendor & Core RTL Dependencies
// =============================================================================
// UNCHANGED FROM HERE THROUGH basic_soc_top.sv -- basic_soc_top instantiates
// APB/QSPI/PLIC/crypto/riscv-dbg directly, none of this can be dropped
// without breaking elaboration even though the *test* only exercises
// core+DIFT+riscv-dbg. All riscv-dbg files were already present and
// correctly ordered (dm_pkg.sv first, since everything else uses `dm::`
// types) -- confirmed, no changes needed in this block.
-f verif/bender_files.f
.bender/git/checkouts/obi-75858655e8b256db/src/obi_intf.sv
.bender/git/checkouts/obi-75858655e8b256db/src/obi_demux.sv
.bender/git/checkouts/obi-75858655e8b256db/src/obi_mux.sv
// LowRISC primitive packages (MUST be compiled first)
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim_generic/rtl/prim_ram_1p_pkg.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl/prim_secded_pkg.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim_generic/rtl/prim_buf.sv

// Ibex Core files
rtl/core/ibex_core/rtl/ibex_pkg.sv
rtl/core/ibex_core/rtl/ibex_tracer_pkg.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim_generic/rtl/prim_clock_gating.sv

// DIFT Subsystem
rtl/core/dift/ibex_dift_logic.sv
rtl/core/dift/ibex_dift_mem.sv
rtl/core/dift/ibex_dift_tmu.sv
rtl/core/dift/ibex_register_file_latch_tag.sv

// Ibex Core Native Manifest
-f rtl/core/ibex_core/rtl/ibex_core.f
// Ibex Core Top
rtl/core/ibex_core/rtl/ibex_top.sv

// DIFT OBI Controller
rtl/obi_wrapper/dift_obi/dift_obi_ctrl.sv
rtl/obi_wrapper/dift_obi/dift_tag_sram_shim.sv

// APB Peripherals & Interrupts
rtl/peripheral/apb_uart/io_generic_fifo.sv
rtl/peripheral/apb_uart/uart_rx.sv
rtl/peripheral/apb_uart/uart_tx.sv
rtl/peripheral/apb_uart/uart_interrupt.sv
rtl/peripheral/apb_uart/apb_uart.sv

rtl/peripheral/apb_spi_master/spi_master_fifo.sv
rtl/peripheral/apb_spi_master/spi_master_clkgen.sv
rtl/peripheral/apb_spi_master/spi_master_tx.sv
rtl/peripheral/apb_spi_master/spi_master_rx.sv
rtl/peripheral/apb_spi_master/spi_master_apb_if.sv
rtl/peripheral/apb_spi_master/spi_master_controller.sv
rtl/peripheral/apb_spi_master/apb_spi_master.sv

rtl/Interrupts/plic/plic_regmap.sv
rtl/Interrupts/plic/rv_plic_gateway.sv
rtl/Interrupts/plic/rv_plic_target.sv
rtl/Interrupts/plic/plic_top.sv

// Crypto Subsystem (SHA-512 & ED25519)
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

// SoC Memories & Peripherals
rtl/soc/soc_bootrom.sv
rtl/soc/soc_sram.sv

// RISC-V Debug Module & JTAG DTM -- all present, order unchanged/confirmed OK
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

// SoC Interconnect & Control
// basic_soc_top.sv here is the MODIFIED version (JTAG ports, dm_obi_top +
// dmi_jtag instances, reset split, SEL_DBG fix in soc_addr_decode.sv)
rtl/soc/soc_addr_decode.sv
rtl/soc/soc_ctrl_regs.sv
rtl/soc/soc_buffer.sv
rtl/soc/basic_soc_top.sv

// =============================================================================
// Debugger Testbench (non-UVM)
// =============================================================================
// REMOVED (UVM): verif/soc_uvm/interface/{obi_if,dift_tag_if,addr_decode_if,
//   apb_if,qspi_if}.sv, qspi_flash_bfm.sv, soc_uvm_pkg.sv, soc_tb_top.sv
//
// NEW -- none of these exist yet, this is the next deliverable:
//   verif/debugger/interface/jtag_if.sv   -- drives tck/tms/trst_n/tdi,
//                                             samples tdo; DMI-level tasks
//                                             (dmi_write/dmi_read) built on
//                                             top of the raw JTAG bit-bang
//   verif/debugger/bootrom_model.sv       -- simple req/gnt/rvalid memory
//                                             model, preloaded from a hex
//                                             file, replaces UVM scoreboard
//                                             memory for bootrom_*_o/i
//   verif/debugger/isram_model.sv         -- same, for isram_*_o/i
//   verif/debugger/dsram_model.sv         -- same, for data_*_o/i (DSRAM)
//   verif/debugger/qspi_flash_model.sv    -- plain (non-UVM) flash BFM,
//                                             replaces qspi_flash_bfm.sv
//   verif/debugger/dbg_tb_top.sv          -- top: instantiates
//                                             basic_soc_top + jtag_if +
//                                             the memory models above,
//                                             drives clk_i/rst_ni
//
// Once written, uncomment:
// verif/debugger/interface/jtag_if.sv
// verif/debugger/bootrom_model.sv
// verif/debugger/isram_model.sv
// verif/debugger/dsram_model.sv
// verif/debugger/qspi_flash_model.sv
// verif/debugger/dbg_tb_top.sv