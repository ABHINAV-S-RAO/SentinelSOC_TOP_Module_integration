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

rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim_generic/rtl/prim_clock_gating.sv

# DIFT modules
rtl/core/dift/ibex_dift_logic.sv
rtl/core/dift/ibex_dift_mem.sv
rtl/core/dift/ibex_dift_tmu.sv
rtl/core/dift/ibex_register_file_latch_tag.sv

# ibex native compile order
-f rtl/core/ibex_core/rtl/ibex_core.f

rtl/peripheral/apb_uart/io_generic_fifo.sv
rtl/peripheral/apb_uart/uart_rx.sv
rtl/peripheral/apb_uart/uart_tx.sv
rtl/peripheral/apb_uart/uart_interrupt.sv
rtl/peripheral/apb_uart/apb_uart.sv
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

rtl/soc/soc_bootrom.sv
rtl/soc/soc_sram.sv

# --- NEW: riscv-dbg debug module + JTAG DTM ---
# Confirmed real paths from `tree -L 4`: rtl/riscv-dbg/src/*.sv
# Confirmed via grep that riscv-dbg is NOT already pulled in through
# verif/bender_files.f -- so it must be listed explicitly here.
# dm_pkg.sv MUST come first (every other file below imports dm::).
# dmi_bscane_tap.sv / dmi_test.sv intentionally excluded -- soc_top drives
# dmi_jtag directly off real JTAG pins, not the Xilinx BSCANE2 wrapper.
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

# NOTE: dmi_jtag_tap.sv instantiates tc_clk_inverter/tc_clk_mux2
# (common_cells tech_cells_generic). Since riscv-dbg's own Bender.yml
# likely declares tech_cells_generic as ITS dependency, and riscv-dbg
# itself isn't being pulled in via Bender here, that dependency won't be
# auto-resolved either. If compile fails on these two modules, add
# tech_cells_generic's tc_clk_inverter.sv/tc_clk_mux2.sv explicitly, right
# before this block.

rtl/soc/soc_addr_decode.sv
rtl/soc/soc_ctrl_regs.sv
rtl/soc/soc_buffer.sv

# --- REMOVED for this run ---
# verif/uart_verif/stubs/dbg_uart_test_stub.sv
# Matches the old "JTAG debug stub -- TODO: instantiate riscv_dbg" comment
# that used to sit in soc_top.sv. Now that soc_top.sv instantiates the real
# dmi_jtag/dm_top, check what this stub actually defines -- if it declares
# modules with the same names, compiling it alongside the real RTL will
# throw duplicate-module-definition errors in Xcelium. Run:
#   grep -n "^module" verif/uart_verif/stubs/dbg_uart_test_stub.sv
# to confirm before re-enabling this line.

rtl/soc/soc_top.sv

# --- NEW: debug-module regression testbench (replaces tb_top.sv for this run) ---
+incdir+verif/debugger
verif/debugger/jtag_if.sv
verif/debugger/tb_dm_ibex_top.sv

# --- REMOVED for this run ---
# +incdir+verif/uart_verif/files
# verif/uart_verif/files/tb_top.sv
# Your existing top-level bench -- not needed since we elaborate
# -top tb_dm_ibex_top instead. Leaving it compiled alongside is harmless
# (xrun only elaborates whichever -top you pass) but it's dead weight here;
# commented out to keep this run's compile scoped to the debug regression.
