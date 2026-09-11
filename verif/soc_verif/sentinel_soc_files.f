+incdir+rtl/core/ibex_core/vendor/lowrisc_ip/dv/sv/dv_utils
+incdir+rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl
+incdir+rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim_generic/rtl
+incdir+.bender/git/checkouts/common_cells-229df333cc9dff23/include
+incdir+.bender/git/checkouts/apb-1b178314edfb6925/include
+incdir+.bender/git/checkouts/obi-75858655e8b256db/include

# Bender deps
-f verif/bender_files.f

rtl/core/ibex_core/rtl/ibex_pkg.sv
rtl/core/ibex_core/rtl/ibex_tracer_pkg.sv

# -------------------------------------------------------
# lowRISC prim packages (must come before ibex_core.f)
# These are packages (not modules), so -y cannot auto-find them.
# Add ALL prim packages upfront to avoid any missing pkg errors.
# -------------------------------------------------------
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim_generic/rtl/prim_pkg.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim_generic/rtl/prim_ram_1p_pkg.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim_generic/rtl/prim_ram_2p_pkg.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim_generic/rtl/prim_rom_pkg.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl/prim_alert_pkg.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl/prim_cipher_pkg.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl/prim_count_pkg.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl/prim_esc_pkg.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl/prim_mubi_pkg.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl/prim_pad_wrapper_pkg.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl/prim_secded_pkg.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl/prim_subreg_pkg.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl/prim_util_pkg.sv

# -y lets elaborator auto-resolve prim_buf, prim_flop, prim_ram_1p etc.
-y rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl
-y rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim_generic/rtl
+libext+.sv+.svh

# Explicit module needed for clock gating (generic implementation)
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim_generic/rtl/prim_clock_gating.sv

# DIFT modules
rtl/core/dift/ibex_dift_logic.sv
rtl/core/dift/ibex_dift_mem.sv
rtl/core/dift/ibex_dift_tmu.sv
rtl/core/dift/ibex_register_file_latch_tag.sv

# ibex core compile order
-f rtl/core/ibex_core/rtl/ibex_core.f

# ibex top-level (wraps ibex_core, uses prim_buf, prim_flop, prim_ram_1p_scr etc.)
rtl/core/ibex_core/rtl/ibex_top.sv
rtl/core/ibex_core/rtl/ibex_top_tracing.sv

# DIFT OBI Wrapper
rtl/obi_wrapper/dift_obi/dift_obi_pkg.sv
rtl/obi_wrapper/dift_obi/dift_obi_ctrl.sv
rtl/obi_wrapper/dift_obi/dift_tag_sram_shim.sv

rtl/peripheral/apb_uart/io_generic_fifo.sv
rtl/peripheral/apb_uart/uart_rx.sv
rtl/peripheral/apb_uart/uart_tx.sv
rtl/peripheral/apb_uart/uart_interrupt.sv
rtl/peripheral/apb_uart/apb_uart.sv
#rtl/peripheral/apb_uart/apb_uart_sv.sv

# GPIO (NEW)
rtl/peripheral/apb_gpio/rtl/apb_gpio.sv

# QSPI
rtl/peripheral/apb_spi_master/apb_spi_master.sv
rtl/peripheral/apb_spi_master/spi_master_apb_if.sv
rtl/peripheral/apb_spi_master/spi_master_clkgen.sv
rtl/peripheral/apb_spi_master/spi_master_controller.sv
rtl/peripheral/apb_spi_master/spi_master_fifo.sv
rtl/peripheral/apb_spi_master/spi_master_rx.sv
rtl/peripheral/apb_spi_master/spi_master_tx.sv

rtl/Interrupts/plic/plic_regmap.sv
rtl/Interrupts/plic/rv_plic_gateway.sv
rtl/Interrupts/plic/rv_plic_target.sv
rtl/Interrupts/plic/plic_top.sv

rtl/crypto/ed25519/ED25519/ED25519.srcs/sources_1/new/SHA/sha512_pkg.sv
rtl/crypto/ed25519/ED25519/ED25519.srcs/sources_1/new/ALU/pseudo_mersenne.sv
rtl/crypto/ed25519/ED25519/ED25519.srcs/sources_1/new/ALU/multiplier.sv
rtl/crypto/ed25519/ED25519/ED25519.srcs/sources_1/new/ALU/alu.sv
rtl/crypto/ed25519/ED25519/ED25519.srcs/sources_1/new/ALU/alu_top.sv
rtl/crypto/ed25519/ED25519/ED25519.srcs/sources_1/new/SHA/sha512_msg_sched.sv
rtl/crypto/ed25519/ED25519/ED25519.srcs/sources_1/new/SHA/sha512_padder.sv
rtl/crypto/ed25519/ED25519/ED25519.srcs/sources_1/new/SHA/sha512_round.sv
rtl/crypto/ed25519/ED25519/ED25519.srcs/sources_1/new/SHA/sha512_top.sv

rtl/crypto/ed25519/ED25519/ED25519.srcs/sources_1/new/reg_file.sv
rtl/crypto/ed25519/ED25519/ED25519.srcs/sources_1/new/micro_seq.sv
rtl/crypto/ed25519/ED25519/ED25519.srcs/sources_1/new/master_fsm.sv
rtl/crypto/ed25519/ED25519/ED25519.srcs/sources_1/new/top_ed25519.sv
rtl/crypto/top_most.sv

rtl/soc/soc_bootrom.sv
rtl/soc/soc_sram.sv
rtl/crypto/otp.sv

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

rtl/soc/soc_addr_decode.sv
rtl/soc/soc_ctrl_regs.sv
rtl/soc/soc_buffer.sv

# Sentinel SoC Top
rtl/soc/sentinel_soc_top.sv

# Sentinel SoC UVM Testbench
verif/soc_verif/sentinel_soc_if.sv
verif/soc_verif/sentinel_soc_uvm_pkg.sv
verif/soc_verif/sentinel_soc_uvm_top.sv
