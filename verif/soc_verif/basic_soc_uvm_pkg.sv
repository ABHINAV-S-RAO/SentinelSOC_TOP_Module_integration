`ifndef BASIC_SOC_UVM_PKG_SV
`define BASIC_SOC_UVM_PKG_SV

package basic_soc_uvm_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // ---------------------------------------------------------------------------
  // Sequence Item
  // ---------------------------------------------------------------------------
  class basic_soc_seq_item extends uvm_sequence_item;
    rand logic [31:0] addr;
    rand logic [31:0] data;
    rand bit          is_write; // 0 for fetch/read, 1 for write

    `uvm_object_utils_begin(basic_soc_seq_item)
      `uvm_field_int(addr, UVM_ALL_ON)
      `uvm_field_int(data, UVM_ALL_ON)
      `uvm_field_int(is_write, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "basic_soc_seq_item");
      super.new(name);
    endfunction
  endclass

  // ---------------------------------------------------------------------------
  // Sequence
  // ---------------------------------------------------------------------------
  class basic_soc_sequence extends uvm_sequence #(basic_soc_seq_item);
    `uvm_object_utils(basic_soc_sequence)

    function new(string name = "basic_soc_sequence");
      super.new(name);
    endfunction

    task body();
      // In this basic sequence, we don't necessarily drive stimulus into the core
      // since the core fetches instructions automatically. We could use this
      // sequence to configure the dummy memory or send interrupts.
      // For now, it's just a placeholder as the driver operates as a responder.
      `uvm_info("SEQ", "Sequence started.", UVM_LOW)
      #50000; // Let simulation run
      `uvm_info("SEQ", "Sequence finished.", UVM_LOW)
    endtask
  endclass

  // ---------------------------------------------------------------------------
  // Sequencer
  // ---------------------------------------------------------------------------
  class basic_soc_sequencer extends uvm_sequencer #(basic_soc_seq_item);
    `uvm_component_utils(basic_soc_sequencer)

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
  endclass

  // ---------------------------------------------------------------------------
  // Driver
  // ---------------------------------------------------------------------------
  class basic_soc_driver extends uvm_driver #(basic_soc_seq_item);
    `uvm_component_utils(basic_soc_driver)
    
    virtual basic_soc_if vif;

    logic [31:0] instructions [0:4] = '{
      32'h10000537, // 0x00: lui a0, 0x10000       -> a0 = 0x10000000 (APB Base)
      32'h04100593, // 0x04: addi a1, zero, 0x41   -> a1 = 0x41 ('A')
      32'h00b52023, // 0x08: sw a1, 0(a0)          -> Write 'A' to UART TX
      32'h00052603, // 0x0C: lw a2, 0(a0)          -> Read from UART RX
      32'h0000006f  // 0x10: j .                   -> Infinite loop
    };

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(!uvm_config_db#(virtual basic_soc_if)::get(this, "", "vif", vif))
        `uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
    endfunction

    task run_phase(uvm_phase phase);
      vif.instr_gnt_i    <= 0;
      vif.instr_rvalid_i <= 0;
      vif.instr_rdata_i  <= 0;
      vif.instr_err_i    <= 0;
      vif.instr_rdata_intg_i <= '0;

      wait(vif.rst_ni == 1'b1);
      
      forever begin
        @(posedge vif.clk_i);
        
        // Pipelined OBI memory response logic
        vif.instr_gnt_i <= vif.instr_req_o;
        vif.instr_rvalid_i <= vif.instr_gnt_i;
        
        if (vif.instr_gnt_i) begin
          case (vif.instr_addr_o)
            32'h80: vif.instr_rdata_i <= instructions[0];
            32'h84: vif.instr_rdata_i <= instructions[1];
            32'h88: vif.instr_rdata_i <= instructions[2];
            32'h8C: vif.instr_rdata_i <= instructions[3];
            default: vif.instr_rdata_i <= instructions[4]; // loop
          endcase
        end
        
        // Setup UART RX pin default state
        vif.uart_rx_i <= 1'b1;
      end
    endtask
  endclass

  // ---------------------------------------------------------------------------
  // Monitor
  // ---------------------------------------------------------------------------
  class basic_soc_monitor extends uvm_monitor;
    `uvm_component_utils(basic_soc_monitor)
    
    virtual basic_soc_if vif;
    uvm_analysis_port #(basic_soc_seq_item) ap;

    function new(string name, uvm_component parent);
      super.new(name, parent);
      ap = new("ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(!uvm_config_db#(virtual basic_soc_if)::get(this, "", "vif", vif))
        `uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
    endfunction

    task run_phase(uvm_phase phase);
      basic_soc_seq_item item;
      wait(vif.rst_ni == 1'b1);
      
      forever begin
        @(posedge vif.clk_i);
        
        // Monitor Instruction Fetches
        if (vif.instr_req_o && vif.instr_gnt_i) begin
          item = basic_soc_seq_item::type_id::create("item");
          item.addr = vif.instr_addr_o;
          item.is_write = 0;
          `uvm_info("MON", $sformatf("Observed Fetch at Addr: 0x%0h", item.addr), UVM_HIGH)
          // We could write to AP, but let's just log it
        end
        
        // Monitor UART TX
        if (vif.uart_tx_o == 1'b0) begin
          // Start bit detected, we could decode UART here, but for simplicity
          // let's just log it. A full UART monitor would sample at baud rate.
        end
      end
    endtask
  endclass

  // ---------------------------------------------------------------------------
  // Agent
  // ---------------------------------------------------------------------------
  class basic_soc_agent extends uvm_agent;
    `uvm_component_utils(basic_soc_agent)

    basic_soc_driver    driver;
    basic_soc_sequencer sequencer;
    basic_soc_monitor   monitor;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      monitor = basic_soc_monitor::type_id::create("monitor", this);
      if(get_is_active() == UVM_ACTIVE) begin
        driver    = basic_soc_driver::type_id::create("driver", this);
        sequencer = basic_soc_sequencer::type_id::create("sequencer", this);
      end
    endfunction

    function void connect_phase(uvm_phase phase);
      if(get_is_active() == UVM_ACTIVE) begin
        driver.seq_item_port.connect(sequencer.seq_item_export);
      end
    endfunction
  endclass

  // ---------------------------------------------------------------------------
  // Scoreboard
  // ---------------------------------------------------------------------------
  class basic_soc_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(basic_soc_scoreboard)
    
    uvm_analysis_imp #(basic_soc_seq_item, basic_soc_scoreboard) ap_imp;

    function new(string name, uvm_component parent);
      super.new(name, parent);
      ap_imp = new("ap_imp", this);
    endfunction

    function void write(basic_soc_seq_item item);
      `uvm_info("SCB", $sformatf("Scoreboard received item: Addr=0x%0h Data=0x%0h Write=%0d", item.addr, item.data, item.is_write), UVM_LOW)
    endfunction
  endclass

  // ---------------------------------------------------------------------------
  // Environment
  // ---------------------------------------------------------------------------
  class basic_soc_env extends uvm_env;
    `uvm_component_utils(basic_soc_env)

    basic_soc_agent      agent;
    basic_soc_scoreboard scb;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      agent = basic_soc_agent::type_id::create("agent", this);
      scb   = basic_soc_scoreboard::type_id::create("scb", this);
    endfunction

    function void connect_phase(uvm_phase phase);
      agent.monitor.ap.connect(scb.ap_imp);
    endfunction
  endclass

  // ---------------------------------------------------------------------------
  // Test
  // ---------------------------------------------------------------------------
  class basic_soc_test extends uvm_test;
    `uvm_component_utils(basic_soc_test)

    basic_soc_env env;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      env = basic_soc_env::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);
      basic_soc_sequence seq;
      
      phase.raise_objection(this);
      `uvm_info("TEST", "Starting Test", UVM_LOW)
      
      seq = basic_soc_sequence::type_id::create("seq");
      seq.start(env.agent.sequencer);
      
      `uvm_info("TEST", "Ending Test", UVM_LOW)
      phase.drop_objection(this);
    endtask
  endclass

endpackage

`endif
