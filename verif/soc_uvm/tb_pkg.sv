package tb_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class soc_base_test extends uvm_test;
    `uvm_component_utils(soc_base_test)

    function new(string name = "soc_base_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      `uvm_info("BASE_TEST", "SoC simulation started. Running test execution...", UVM_LOW)
      
      // Allow clock cycles for instruction fetches
      #100_000; 
      
      `uvm_info("BASE_TEST", "Test completed successfully.", UVM_LOW)
      phase.drop_objection(this);
    endtask
  endclass
endpackage