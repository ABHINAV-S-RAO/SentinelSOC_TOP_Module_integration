-sv
+incdir+rtl/core/ibex_core/vendor/lowrisc_ip/dv/sv/dv_utils
+incdir+rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl
+incdir+rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim_generic/rtl
+incdir+/home/ibexcore/project/SentinelSOC_TOP_Module_integration/.bender/git/checkouts/common_cells-229df333cc9dff23/include
+incdir+/home/ibexcore/project/SentinelSOC_TOP_Module_integration/.bender/git/checkouts/apb-1b178314edfb6925/include
+incdir+/home/ibexcore/project/SentinelSOC_TOP_Module_integration/.bender/git/checkouts/obi-75858655e8b256db/include

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

# TB LAST
verif/tb/ibex_core_tb.sv