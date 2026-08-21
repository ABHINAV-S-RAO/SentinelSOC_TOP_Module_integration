// =============================================================================
// soc_basic_files.f
// Compilation filelist for exhaustive basic SoC testing
// =============================================================================

// Base filelist that correctly includes the Prim libraries, DIFT, and Ibex Core (WITHOUT UVM)
// (Must be executed from the project root)
-f verif/files.f

// OBI and APB Includes
+incdir+rtl/obi_wrapper
+incdir+rtl/peripheral/apb_uart

// OBI to APB Bridge
rtl/obi_wrapper/obi_to_apb.sv

// Basic SoC Top
rtl/soc/basic_soc_top.sv

// Exhaustive Testbench
verif/soc_verif/basic_soc_tb.sv
