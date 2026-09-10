`ifndef SOC_BASE_TEST_SV
`define SOC_BASE_TEST_SV

import uvm_pkg::*;
`include "uvm_macros.svh"

class soc_base_test extends uvm_test;
  `uvm_component_utils(soc_base_test)

  soc_env env;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = soc_env::type_id::create("env", this);
  endfunction

  task run_phase(uvm_phase phase);
    // Safety watchdog timeout (10 ms) in case software gets stuck in an infinite loop
    uvm_top.set_timeout(10ms, 0);
  endtask
endclass

`endif