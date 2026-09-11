class soc_qspi_test extends soc_base_test;
  `uvm_component_utils(soc_qspi_test)

  function new(string name = "soc_qspi_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("QSPI_TEST", "Starting Core-Driven QSPI Functional Coverage Test", UVM_LOW)
    
    // Allow core to run through qspi_test firmware loop
    #500us;
    
    `uvm_info("QSPI_TEST", "QSPI Test Execution Completed", UVM_LOW)
    phase.drop_objection(this);
  endtask
endclass