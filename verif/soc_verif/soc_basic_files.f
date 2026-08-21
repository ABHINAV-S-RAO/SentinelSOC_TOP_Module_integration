// =============================================================================
// soc_basic_files.f
// Compilation filelist for exhaustive basic SoC testing
// =============================================================================

// Include the entire core Ibex filelist (includes DIFT files we added)
-f ../../rtl/core/ibex_core/dv/uvm/core_ibex/ibex_dv.f

// Include Paths for APB and OBI types
+incdir+../../rtl/obi_wrapper
+incdir+../../rtl/peripheral/apb_uart

// OBI to APB Bridge
../../rtl/obi_wrapper/obi_to_apb.sv

// APB UART Submodule
../../rtl/peripheral/apb_uart/apb_uart_sv.sv

// Basic SoC Top
../../rtl/soc/basic_soc_top.sv

// Exhaustive Testbench
basic_soc_tb.sv
