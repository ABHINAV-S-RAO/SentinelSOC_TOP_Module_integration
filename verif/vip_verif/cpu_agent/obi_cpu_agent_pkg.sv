package obi_cpu_agent_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // Basic sequence item for OBI
  class obi_seq_item extends uvm_sequence_item;
    rand logic [31:0] addr;
    rand logic [31:0] data;
    rand logic        we;
    rand logic [3:0]  be;
    
    `uvm_object_utils_begin(obi_seq_item)
      `uvm_field_int(addr, UVM_ALL_ON)
      `uvm_field_int(data, UVM_ALL_ON)
      `uvm_field_int(we, UVM_ALL_ON)
      `uvm_field_int(be, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "obi_seq_item");
      super.new(name);
    endfunction
  endclass

  // Basic driver
  class obi_driver extends uvm_driver #(obi_seq_item);
    `uvm_component_utils(obi_driver)
    virtual obi_if vif;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(virtual obi_if)::get(this, "", "vif", vif))
        `uvm_fatal("NO_VIF", "obi_if not found")
    endfunction

    task run_phase(uvm_phase phase);
      vif.req   <= 0;
      vif.we    <= 0;
      vif.addr  <= 0;
      vif.wdata <= 0;
      vif.be    <= 0;
      @(posedge vif.rst_ni);
      `uvm_info("OBI_DRV", "Out of reset, waiting for items...", UVM_LOW)
      
      forever begin
        seq_item_port.get_next_item(req);
        `uvm_info("OBI_DRV", $sformatf("Driving req to addr 0x%0h", req.addr), UVM_LOW)
        
        // Drive at posedge using NBA to prevent delta-cycle races with RTL
        @(posedge vif.clk_i);
        vif.req   <= 1;
        vif.we    <= req.we;
        vif.addr  <= req.addr;
        vif.wdata <= req.data;
        vif.be    <= req.be;
        
        // Wait for gnt
        `uvm_info("OBI_DRV", "Waiting for gnt==1", UVM_LOW)
        do begin
          @(posedge vif.clk_i);
          #1ps; // Wait for combinational logic to settle before sampling
        end while (vif.gnt !== 1'b1);
        `uvm_info("OBI_DRV", "Got gnt==1, dropping req and waiting for rvalid==1", UVM_LOW)
        
        // Drop req at posedge using NBA
        vif.req <= 0;

        // Keep waiting for rvalid (check immediately since it could be 1 in same cycle)
        while (vif.rvalid !== 1'b1) begin
          @(posedge vif.clk_i);
          #1ps; // Wait for combinational logic to settle before sampling
        end
        `uvm_info("OBI_DRV", "Got rvalid==1, finishing item", UVM_LOW)
        if (!req.we) begin
          req.data = vif.rdata;
        end
        
        seq_item_port.item_done();
      end
    endtask
  endclass

  // Sequencer
  class obi_sequencer extends uvm_sequencer #(obi_seq_item);
    `uvm_component_utils(obi_sequencer)
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
  endclass

  // Agent
  class obi_agent extends uvm_agent;
    `uvm_component_utils(obi_agent)
    obi_driver driver;
    obi_sequencer sequencer;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      driver = obi_driver::type_id::create("driver", this);
      sequencer = obi_sequencer::type_id::create("sequencer", this);
    endfunction

    function void connect_phase(uvm_phase phase);
      driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction
  endclass
endpackage
