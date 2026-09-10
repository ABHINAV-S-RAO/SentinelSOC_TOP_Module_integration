// =============================================================================
// Compiler & Simulation Options
// =============================================================================
-64bit -uvm -sv -timescale 1ns/1ps -access +rwc
+define+DIFT

// =============================================================================
// Include Directories (RTL + Vendor + UVM)
// =============================================================================
+incdir+rtl/core/ibex_core/vendor/lowrisc_ip/dv/sv/dv_utils
+incdir+rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl
+incdir+rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim_generic/rtl
+incdir+.bender/git/checkouts/common_cells-229df333cc9dff23/include
+incdir+.bender/git/checkouts/apb-1b178314edfb6925/include
+incdir+.bender/git/checkouts/obi-75858655e8b256db/include

+incdir+verif/soc_uvm
+incdir+verif/soc_uvm/interface
+incdir+verif/soc_uvm/monitor
+incdir+verif/soc_uvm/scoreboard
+incdir+verif/soc_uvm/sequence_item

// =============================================================================
// Vendor & Core RTL Dependencies
// =============================================================================
-f verif/bender_files.f
.bender/git/checkouts/obi-75858655e8b256db/src/obi_demux.sv
.bender/git/checkouts/obi-75858655e8b256db/src/obi_mux.sv
// LowRISC primitive packages (MUST be compiled first)
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim_generic/rtl/prim_ram_1p_pkg.sv

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

// APB Peripherals & Interrupts
rtl/peripheral/apb_uart/io_generic_fifo.sv
rtl/peripheral/apb_uart/uart_rx.sv
rtl/peripheral/apb_uart/uart_tx.sv
rtl/peripheral/apb_uart/uart_interrupt.sv
rtl/peripheral/apb_uart/apb_uart.sv

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

// RISC-V Debug Module & JTAG DTM
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
rtl/soc/soc_addr_decode.sv
rtl/soc/soc_ctrl_regs.sv
rtl/soc/soc_buffer.sv
rtl/soc/basic_soc_top.sv

// =============================================================================
// UVM Testbench Infrastructure
// =============================================================================
verif/soc_uvm/interface/obi_if.sv
verif/soc_uvm/interface/dift_tag_if.sv
verif/soc_uvm/soc_uvm_pkg.sv
verif/soc_uvm/soc_tb_top.sv
