-sv -timescale 1ns/1ps
+incdir+rtl/core/ibex_core/vendor/lowrisc_ip/dv/sv/dv_utils
+incdir+rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl
+incdir+rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim_generic/rtl
+incdir+/home/ibexcore/project/SentinelSOC_TOP_Module_integration/.bender/git/checkouts/common_cells-229df333cc9dff23/include
+incdir+/home/ibexcore/project/SentinelSOC_TOP_Module_integration/.bender/git/checkouts/apb-1b178314edfb6925/include
+incdir+/home/ibexcore/project/SentinelSOC_TOP_Module_integration/.bender/git/checkouts/obi-75858655e8b256db/include

# Bender deps
-f verif/bender_files.f

# OBI wrappers (DIFT)
rtl/obi_wrapper/dift_obi/dift_tag_sram_shim.sv
rtl/obi_wrapper/dift_obi/dift_obi_ctrl.sv

# TB LAST
verif/tb/dift_obi_ctrl_tb.sv
