-sv
+incdir+rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl
+incdir+rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim_generic/rtl
+incdir+.bender/git/checkouts/common_cells-229df333cc9dff23/include
+incdir+.bender/git/checkouts/apb-1b178314edfb6925/include
+incdir+.bender/git/checkouts/obi-75858655e8b256db/include

# NOTE: dv_utils incdir dropped from the original files.f -- that's a
# verification-only (DPI/UVM) include path and has no business in a
# synthesis run. Put it back if elaboration complains about a missing
# header that turns out to live there.

# NOTE: bender_files.f is UNVERIFIED for synthesis. I don't have its
# contents, so I can't tell whether it's pure RTL (OBI/APB/common_cells
# glue that ibex_top actually instantiates) or pulls in sim-only stuff
# (interfaces, clocking blocks, DPI-C). Left in because ibex_top may
# need bus-adapter RTL from it -- but if syn_generic/check_design
# throws non-synthesizable-construct errors, this line is the first
# suspect. Comment it out and re-run if ibex_top doesn't actually
# depend on it.
-f verif/bender_files.f

rtl/core/ibex_core/rtl/ibex_pkg.sv
rtl/core/ibex_core/rtl/ibex_tracer_pkg.sv

rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim_generic/rtl/prim_clock_gating.sv

# DIFT modules
rtl/core/dift/ibex_dift_logic.sv
rtl/core/dift/ibex_dift_mem.sv
rtl/core/dift/ibex_dift_tmu.sv
rtl/core/dift/ibex_register_file_latch_tag.sv

# ibex native compile order (this should include ibex_top.sv and ibex_core.sv)
-f rtl/core/ibex_core/rtl/ibex_core.f

# TB intentionally EXCLUDED for synthesis -- verif/tb/ibex_core_tb.sv
