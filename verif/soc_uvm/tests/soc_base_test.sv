`include "uvm_macros.svh"
import uvm_pkg::*;
import soc_uvm_pkg::*;

class soc_base_test extends uvm_test;
  `uvm_component_utils(soc_base_test)

  soc_env env;

  function new(string name = "soc_base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // Instantiates your soc_env, which builds the monitors and scoreboard
    env = soc_env::type_id::create("env", this);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info(get_type_name(), "Simulation started. Firmware running...", UVM_LOW)

    // Option A: Explicit run window (useful while tuning monitors)
    #100us;

    // Option B: Wait for sw_status_monitor completion event (Ideal)
    // wait (env.sw_stat_mon.test_passed == 1'b1);

    `uvm_info(get_type_name(), "Dropping objection to finish test.", UVM_LOW)
    phase.drop_objection(this);
  endtask
endclass