`ifndef SOC_ENV_SV
`define SOC_ENV_SV

import uvm_pkg::*;
`include "uvm_macros.svh"

class soc_env extends uvm_env;
  `uvm_component_utils(soc_env)

  obi_monitor       instr_mon;
  obi_monitor       data_mon;
  dift_tag_monitor  dift_mon;
  sw_status_monitor sw_mon;
  soc_scoreboard    scb;
  soc_cov           cov;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Differentiate virtual interface lookup names for instruction vs data monitors
    uvm_config_db#(string)::set(this, "instr_mon", "vif_name", "instr_obi_vif");
    uvm_config_db#(string)::set(this, "data_mon",  "vif_name", "data_obi_vif");

    instr_mon = obi_monitor::type_id::create("instr_mon", this);
    data_mon  = obi_monitor::type_id::create("data_mon", this);
    dift_mon  = dift_tag_monitor::type_id::create("dift_mon", this);
    sw_mon    = sw_status_monitor::type_id::create("sw_mon", this);
    scb       = soc_scoreboard::type_id::create("scb", this);
    cov       = soc_cov::type_id::create("cov", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    // Bind analysis ports to scoreboard, SW completion monitor, and coverage collector
    data_mon.ap.connect(scb.data_obi_imp);
    dift_mon.ap.connect(scb.dift_tag_imp);
    data_mon.ap.connect(sw_mon.analysis_export);
    data_mon.ap.connect(cov.analysis_export);
  endfunction
endclass

`endif