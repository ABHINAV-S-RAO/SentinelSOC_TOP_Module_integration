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
    phase.raise_objection(this);
    // Safety watchdog timeout (10 ms) in case software gets stuck in an infinite loop
    uvm_top.set_timeout(10ms, 0);
    `uvm_info(get_type_name(), "Simulation started. Firmware running...", UVM_LOW)

    // Run for 100 us to let firmware execute and monitors collect data
    #100us;

    `uvm_info(get_type_name(), "Dropping objection to finish test.", UVM_LOW)
    phase.drop_objection(this);
  endtask
endclass

`endif