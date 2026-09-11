package sentinel_soc_uvm_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // ---------------------------------------------------------------------------
  // Base Test
  // ---------------------------------------------------------------------------
  class sentinel_soc_base_test extends uvm_test;
    `uvm_component_utils(sentinel_soc_base_test);

    virtual sentinel_soc_if vif;

    function new(string name="sentinel_soc_base_test", uvm_component parent=null);
      super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(!uvm_config_db#(virtual sentinel_soc_if)::get(this, "", "vif", vif))
        `uvm_fatal("NOVIF", "virtual interface must be set for: vif")
    endfunction

    virtual task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      
      `uvm_info("BASE_TEST", "Waiting for reset to deassert...", UVM_LOW)
      @(posedge vif.rst_n);
      
      `uvm_info("BASE_TEST", "Reset deasserted. Firmware executing...", UVM_LOW)

      // Wait a fixed amount of time for the firmware to run (for now)
      // Later we will monitor the UART or a specific memory address to determine Pass/Fail
      #5000ns;

      `uvm_info("BASE_TEST", "Test completed (timeout reached).", UVM_LOW)
      
      phase.drop_objection(this);
    endtask

  endclass

endpackage
