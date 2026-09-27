-64bit -sv -timescale 1ns/1ps -access +rwc -coverage functional -covoverwrite -top dift_dbg_tb
+define+DIFT

// Include dirs
+incdir+rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl
+incdir+rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim_generic/rtl
+incdir+rtl/core/ibex_core/vendor/lowrisc_ip/dv/sv/dv_utils
+incdir+/home/ibexcore/project/SentinelSOC_TOP_Module_integration/.bender/git/checkouts/common_cells-229df333cc9dff23/include
+incdir+/home/ibexcore/project/SentinelSOC_TOP_Module_integration/.bender/git/checkouts/apb-1b178314edfb6925/include
+incdir+/home/ibexcore/project/SentinelSOC_TOP_Module_integration/.bender/git/checkouts/obi-75858655e8b256db/include
+incdir+rtl/obi_wrapper
+incdir+verif/debugger
+incdir+verif/debugger/interface

// RTL
-f verif/bender_files.f

// OBI -- vendored sources (NOT the bender obi src/ -- those use obi_pkg which needs the include)
rtl/obi_wrapper/obi_intf.sv
rtl/obi_wrapper/obi_demux.sv
rtl/obi_wrapper/obi_mux.sv

// LowRISC primitives
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim_generic/rtl/prim_ram_1p_pkg.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl/prim_secded_pkg.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim_generic/rtl/prim_buf.sv

// Ibex Core
rtl/core/ibex_core/rtl/ibex_pkg.sv
rtl/core/ibex_core/rtl/ibex_tracer_pkg.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim_generic/rtl/prim_clock_gating.sv

// DIFT
rtl/core/dift/ibex_dift_logic.sv
rtl/core/dift/ibex_dift_mem.sv
rtl/core/dift/ibex_dift_tmu.sv
rtl/core/dift/ibex_register_file_latch_tag.sv

-f rtl/core/ibex_core/rtl/ibex_core.f
rtl/core/ibex_core/rtl/ibex_top.sv

// DIFT OBI
rtl/obi_wrapper/dift_obi/dift_obi_ctrl.sv
rtl/obi_wrapper/dift_obi/dift_tag_sram_shim.sv

// APB Peripherals
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

// PLIC
rtl/Interrupts/plic/plic_regmap.sv
rtl/Interrupts/plic/rv_plic_gateway.sv
rtl/Interrupts/plic/rv_plic_target.sv
rtl/Interrupts/plic/plic_top.sv

// Crypto
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

// SoC memories
rtl/soc/soc_bootrom.sv
rtl/soc/soc_sram.sv

// riscv-dbg
rtl/riscv-dbg/src/dm_pkg.sv
rtl/riscv-dbg/src/dm_mem.sv
rtl/riscv-dbg/debug_rom/debug_rom.sv
rtl/riscv-dbg/src/dm_csrs.sv
rtl/riscv-dbg/src/dm_sba.sv
rtl/riscv-dbg/src/dm_obi_top.sv
rtl/riscv-dbg/src/dm_top.sv
rtl/riscv-dbg/src/dmi_cdc.sv
rtl/riscv-dbg/src/dmi_jtag_tap.sv
rtl/riscv-dbg/src/dmi_jtag.sv
rtl/riscv-dbg/src/dmi_intf.sv

// SoC top
rtl/soc/soc_addr_decode.sv
rtl/soc/soc_ctrl_regs.sv
rtl/soc/soc_buffer.sv
rtl/soc/soc_recovery.sv
rtl/soc/basic_soc_top.sv

// Testbench
verif/debugger/interface/jtag_if.sv
verif/debugger/bootrom_model.sv
verif/debugger/isram_model.sv
verif/debugger/dsram_model.sv
verif/debugger/qspi_flash_model.sv
verif/debugger/dift_dbg_tb.sv