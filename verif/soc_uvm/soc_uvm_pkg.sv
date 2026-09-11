`ifndef SOC_UVM_PKG_SV
`define SOC_UVM_PKG_SV

package soc_uvm_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  `include "obi_seq_item.sv"
  `include "dift_tag_seq_item.sv"
  `include "obi_monitor.sv"
  `include "dift_tag_monitor.sv"
  `include "sw_status_monitor.sv"
  `include "addr_decode_monitor.sv"
  `include "apb_peripheral_monitor.sv"
  `include "qspi_protocol_monitor.sv"
  `include "soc_scoreboard.sv"
  `include "soc_cov.sv"
  `include "soc_env.sv"
  `include "soc_base_test.sv"
endpackage

`endif