# ============================================================
# Genus synthesis script
# DIFT-instrumented Ibex core (SentinelSOC)
# Sky130 FD SC HD
#
# Assumes you launch genus from the REPO ROOT (the same directory
# files_dift_synth.f's relative paths are written against), e.g.:
#   cd <repo-root>
#   genus -files genus/synth.tcl
# If you actually run from inside genus/, change FILELIST below to
# "../files_dift_synth.f" or use an absolute path instead.
# ============================================================

# -----------------------------
# Design configuration
# -----------------------------

set TOP ibex_top

# NOTE: reused from the PipelinedCPU project's synth.tcl -- point this
# at wherever the sky130 PDK actually lives for THIS project/machine.
set LIB "/home/ibexcore/project/test/skywater-pdk/libraries/sky130_fd_sc_hd/latest/timing/sky130_fd_sc_hd__tt_025C_1v80.lib"

# Synthesis-only filelist -- see files_dift_synth.f. Relative to
# original files.f, this drops:
#   - the TB (verif/tb/ibex_core_tb.sv) -- not synthesizable
#   - the dv_utils incdir -- verification-only (DPI/UVM) headers
#   - -f verif/bender_files.f -- turned out to be an Xcelium/irun
#     OPTIONS file (-64bit -uvm -timescale ... -access +rwc), not an
#     RTL filelist. Feeding it to read_hdl corrupted the parse and
#     cascaded into unrelated errors in tc_sram.sv etc. If ibex_top
#     genuinely needs OBI/APB/common_cells RTL that lived behind that
#     -f, add the actual RTL files/filelist here explicitly instead.
# Genus's -f parser also doesn't support "#" comments inside the
# filelist itself (it tokenizes comment words as filenames), so
# files_dift_synth.f is kept comment-free -- notes live here instead.
# Resolved relative to THIS script's own location, so it works no
# matter what directory you're in when you launch genus, and no
# matter what the containing folder is named (genus/, synth/, etc).
set SCRIPT_DIR [file dirname [file normalize [info script]]]
set FILELIST "$SCRIPT_DIR/files_dift_synth.f"

# -----------------------------
# Library setup
# -----------------------------

set_db init_lib_search_path [file dirname $LIB]
set_db library [file tail $LIB]

# -----------------------------
# Read RTL via filelist
# -----------------------------
# read_hdl -f consumes the filelist directly -- it understands -sv,
# +incdir+, nested -f, and comment lines the same way Xcelium does,
# so files_dift_synth.f can be passed straight through.

read_hdl -language sv -f $FILELIST

# -----------------------------
# Elaborate
# -----------------------------

elaborate $TOP

# -----------------------------
# Basic design checks
# -----------------------------

check_design -unresolved

# -----------------------------
# Generic synthesis
# -----------------------------
# NOTE: clock/reset port names assumed as clk_i / rst_ni, following
# lowRISC/Ibex naming convention. Rename below if this project's
# ibex_top uses something else.
# NOTE: 1.7ns (from the reference script) was PipelinedCPU's target --
# it has no bearing on Ibex's achievable frequency. Placeholder period
# below is 10ns (100MHz); tighten/loosen once you know the real target.

create_clock -name clk_i -period 10.0 [get_ports clk_i]
syn_generic

# -----------------------------
# Technology mapping
# -----------------------------

syn_map

# -----------------------------
# Optimization
# -----------------------------

syn_opt

# -----------------------------
# Reports
# -----------------------------

report_area > area.rpt
report_timing > timing.rpt

# -----------------------------
# Write synthesized netlist
# -----------------------------

write_hdl > synth_out/ibex_top_synth.v

puts "============================================"
puts " Synthesis completed successfully"
puts " Top module : $TOP"
puts " Library    : $LIB"
puts "============================================"
