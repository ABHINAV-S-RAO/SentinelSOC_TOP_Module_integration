+define+DIFT
+incdir+rtl/core/ibex_core/vendor/lowrisc_ip/dv/sv/dv_utils
+incdir+rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl
+incdir+rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim_generic/rtl
+incdir+.bender/git/checkouts/common_cells-229df333cc9dff23/include
+incdir+.bender/git/checkouts/apb-1b178314edfb6925/include
+incdir+.bender/git/checkouts/obi-75858655e8b256db/include

# Bender deps
-f verif/bender_files.f
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl/prim_secded_pkg.sv
rtl/core/ibex_core/rtl/ibex_pkg.sv
rtl/core/ibex_core/rtl/ibex_tracer_pkg.sv

rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim_generic/rtl/prim_clock_gating.sv

# DIFT modules
# NOTE: left in place, unchanged, since this filelist compiles them
# regardless of whether soc_top instantiates the DIFT variant of the core.
# They cost nothing at compile time and this is otherwise your known-good
# ibex-dift-verif list. If ibex_core.f pulls in a DIFT-specific ibex_core
# wrapper (rather than plain vendor ibex_core), and that wrapper isn't the
# one soc_top.sv is written against, that's the one thing worth confirming
# separately from this filelist -- it's an RTL-selection question, not a
# filelist-ordering one.
rtl/core/dift/ibex_dift_logic.sv
rtl/core/dift/ibex_dift_mem.sv
rtl/core/dift/ibex_dift_tmu.sv
rtl/core/dift/ibex_register_file_latch_tag.sv

rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim_generic/rtl/prim_ram_1p_pkg.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim_generic/rtl/prim_buf.sv
# ibex native compile order
-f rtl/core/ibex_core/rtl/ibex_core.f
rtl/core/ibex_core/rtl/ibex_icache.sv
rtl/core/ibex_core/rtl/ibex_top.sv


rtl/peripheral/apb_uart/io_generic_fifo.sv
rtl/peripheral/apb_uart/uart_rx.sv
rtl/peripheral/apb_uart/uart_tx.sv
rtl/peripheral/apb_uart/uart_interrupt.sv
# DUPLICATE of apb_uart_sv.sv, same module name, not instantiated anywhere -- rtl/peripheral/apb_uart/apb_uart.sv
rtl/peripheral/apb_uart/apb_uart_sv.sv

rtl/Interrupts/plic/plic_regmap.sv
rtl/Interrupts/plic/rv_plic_gateway.sv
rtl/Interrupts/plic/rv_plic_target.sv
rtl/Interrupts/plic/plic_top.sv

# --- REMOVED for this run: standalone PLIC bench (-top tb_plic_top) ---
# Harmless to leave compiled since we pass an explicit -top, but it's dead
# weight for a debug-only regression -- commented out to shrink compile time.
# +incdir+verif/plic_verif
# verif/plic_verif/plic_reg_if.sv
# verif/plic_verif/plic_irq_if.sv
# verif/plic_verif/plic_tb_pkg.sv
# verif/plic_verif/tb_plic_top.sv

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


rtl/crypto/top_most.sv
rtl/crypto/otp.sv
rtl/soc/soc_bootrom.sv
rtl/soc/soc_sram.sv

# --- NEW: riscv-dbg debug module + JTAG DTM ---
# dm_pkg.sv MUST compile before every other dm_*/dmi_* file below (they all
# `import dm::*` or reference dm:: types directly) and before soc_top.sv
# (which references dm::DataCount / dm::DataAddr in its hartinfo_i hookup).
# Paths below assume you drop the 12 files I gave you into rtl/riscv-dbg/src/ --
# adjust the directory to wherever you actually place them.
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
# dmi_bscane_tap.sv / dmi_test.sv NOT needed here -- soc_top drives
# dmi_jtag directly off real JTAG pins, not the Xilinx BSCANE2 wrapper.
# Leave them out unless something else in your repo instantiates them.

# NOTE on dependencies inside dmi_jtag_tap.sv: it instantiates
# tc_clk_inverter / tc_clk_mux2 (common_cells tech_cells_generic). Confirm
# these are actually pulled in by verif/bender_files.f above -- if your
# bender manifest doesn't list `tech_cells_generic` as a dependency (only
# `common_cells` proper), compilation will fail on these two modules and
# you'll need to add that package explicitly.

rtl/obi_wrapper/dift_obi/dift_obi_pkg.sv
rtl/obi_wrapper/dift_obi/dift_tag_sram_shim.sv
rtl/obi_wrapper/dift_obi/dift_obi_ctrl.sv

.bender/git/checkouts/obi-75858655e8b256db/src/obi_demux.sv
rtl/soc/soc_addr_decode.sv
rtl/soc/soc_ctrl_regs.sv
rtl/soc/soc_buffer.sv

# --- REMOVED for this run ---
# verif/uart_verif/stubs/dbg_uart_test_stub.sv
# This was almost certainly the placeholder that stood in for the real
# debug module before dm_top/dmi_jtag existed (matches the "JTAG debug
# stub -- TODO: instantiate riscv_dbg" comment that used to sit in
# soc_top.sv). Now that soc_top.sv instantiates the real dmi_jtag/dm_top,
# check what this stub actually defines -- if it declares modules with the
# same names (or a fake dm_top/dmi_jtag), compiling it alongside the real
# RTL will throw duplicate-module-definition errors in Xcelium. Safest to
# leave it out of this filelist entirely unless you confirm it's unrelated.

rtl/soc/soc_top.sv

# --- NEW: debug-module regression testbench (replaces tb_top.sv for this run) ---
+incdir+verif/debugger
verif/debugger/jtag_if.sv
verif/debugger/tb_dift_debug_integration.sv

# --- REMOVED for this run ---
# +incdir+verif/uart_verif/files
# verif/uart_verif/files/tb_top.sv
# Your existing top-level bench -- not needed since we elaborate
# -top tb_dm_ibex_top instead. Leaving it compiled alongside is harmless
# (xrun only elaborates whichever -top you pass) but it's dead weight here;
# commented out to keep this run's compile scoped to the debug regression.
