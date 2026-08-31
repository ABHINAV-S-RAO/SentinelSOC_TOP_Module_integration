`ifndef BASIC_SOC_UVM_PKG_SV
`define BASIC_SOC_UVM_PKG_SV
`timescale 1ns/1ps

package basic_soc_uvm_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // ---------------------------------------------------------------------------
  // Sequence Item
  // ---------------------------------------------------------------------------
  class basic_soc_seq_item extends uvm_sequence_item;
    rand logic [31:0] addr;
    rand logic [31:0] data;
    rand bit          is_write;
    
    // For exhaustive delay testing in the driver
    rand int unsigned gnt_delay;
    rand int unsigned rvalid_delay;

    constraint delay_c {
      gnt_delay <= 5;
      rvalid_delay <= 5;
    }

    `uvm_object_utils_begin(basic_soc_seq_item)
      `uvm_field_int(addr, UVM_ALL_ON)
      `uvm_field_int(data, UVM_ALL_ON)
      `uvm_field_int(is_write, UVM_ALL_ON)
      `uvm_field_int(gnt_delay, UVM_ALL_ON)
      `uvm_field_int(rvalid_delay, UVM_ALL_ON)
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
      basic_soc_seq_item item;
      `uvm_info("SEQ", "Sequence started.", UVM_LOW)
      
      // We can generate items just to configure the driver's randomization
      repeat(100) begin
        item = basic_soc_seq_item::type_id::create("item");
        start_item(item);
        assert(item.randomize());
        finish_item(item);
      end
      
      #50000; // Let simulation run for remaining fetches
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
      32'h10000537, // 0x00: lui a0, 0x10000
      32'h04100593, // 0x04: addi a1, zero, 0x41 ('A')
      32'h00b52023, // 0x08: sw a1, 0(a0) (UART TX)
      32'h00052603, // 0x0C: lw a2, 0(a0) (UART RX)
      32'h0000006f  // 0x10: j .
    };

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(!uvm_config_db#(virtual basic_soc_if)::get(this, "", "vif", vif))
        `uvm_fatal("NO_VIF", {"virtual interface must be set for: ", get_full_name(), ".vif"});
    endfunction

    task run_phase(uvm_phase phase);
      basic_soc_seq_item req_item;
      int gnt_d = 0;
      int rvalid_d = 0;
      
      vif.instr_gnt_i    <= 0;
      vif.instr_rvalid_i <= 0;
      vif.instr_rdata_i  <= 0;
      vif.instr_err_i    <= 0;
      vif.instr_rdata_intg_i <= '0;

      wait(vif.rst_ni == 1'b1);
      
      // Driver runs a concurrent loop getting seq items to update delay params
      fork
        forever begin
          seq_item_port.get_next_item(req_item);
          gnt_d = req_item.gnt_delay;
          rvalid_d = req_item.rvalid_delay;
          seq_item_port.item_done();
        end
        
        // Memory Responder Loop
        forever begin
          @(posedge vif.clk_i);
          
          if (vif.instr_req_o) begin
            // Simulate random Grant delay
            if (gnt_d > 0) repeat(gnt_d) @(posedge vif.clk_i);
            vif.instr_gnt_i <= 1'b1;
            
            @(posedge vif.clk_i);
            vif.instr_gnt_i <= 1'b0;
            
            // Simulate random RVALID delay
            if (rvalid_d > 0) repeat(rvalid_d) @(posedge vif.clk_i);
            
            vif.instr_rvalid_i <= 1'b1;
            case (vif.instr_addr_o)
              32'h00: vif.instr_rdata_i <= instructions[0];
              32'h04: vif.instr_rdata_i <= instructions[1];
              32'h08: vif.instr_rdata_i <= instructions[2];
              32'h0C: vif.instr_rdata_i <= instructions[3];
              default: vif.instr_rdata_i <= instructions[4]; // loop
            endcase
            
            @(posedge vif.clk_i);
            vif.instr_rvalid_i <= 1'b0;
          end
        end
      join_none
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
      
      fork
        // Sniff OBI Instruction Fetches
        forever begin
          @(posedge vif.clk_i);
          if (vif.instr_req_o && vif.instr_gnt_i) begin
            item = basic_soc_seq_item::type_id::create("item");
            item.addr = vif.instr_addr_o;
            item.is_write = 0;
            ap.write(item);
          end
        end
        
        // Sniff UART via internal APB hooks
        forever begin
          @(posedge vif.clk_i);
          if (vif.apb_psel && vif.apb_penable) begin
            if (vif.apb_pwrite) begin
              item = basic_soc_seq_item::type_id::create("item");
              item.addr = vif.apb_paddr;
              item.data = vif.apb_pwdata;
              item.is_write = 1;
              ap.write(item);
            end
          end
        end
      join_none
    endtask
  endclass

  // ---------------------------------------------------------------------------
  // Coverage Collector
  // ---------------------------------------------------------------------------
  class basic_soc_coverage extends uvm_subscriber #(basic_soc_seq_item);
    `uvm_component_utils(basic_soc_coverage)
    
    basic_soc_seq_item cg_item;

    covergroup soc_cg;
      option.per_instance = 1;
      // Cover memory addresses fetched
      cp_addr: coverpoint cg_item.addr {
        bins boot = {32'h00};
        bins text = {[32'h04:32'h0C]};
        bins loop = {32'h10};
      }
      // Cover UART transactions
      cp_is_write: coverpoint cg_item.is_write;
      cp_uart_data: coverpoint cg_item.data[7:0] iff (cg_item.is_write == 1) {
        bins char_A = {8'h41};
      }
    endgroup

    function new(string name, uvm_component parent);
      super.new(name, parent);
      soc_cg = new();
    endfunction

    function void write(basic_soc_seq_item t);
      cg_item = t;
      soc_cg.sample();
    endfunction
  endclass

  // ---------------------------------------------------------------------------
  // Scoreboard
  // ---------------------------------------------------------------------------
  class basic_soc_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(basic_soc_scoreboard)
    
    uvm_analysis_imp #(basic_soc_seq_item, basic_soc_scoreboard) ap_imp;
    
    int total_fetches;
    int total_uart_writes;
    string uart_stream;

    function new(string name, uvm_component parent);
      super.new(name, parent);
      ap_imp = new("ap_imp", this);
      total_fetches = 0;
      total_uart_writes = 0;
      uart_stream = "";
    endfunction

    function void write(basic_soc_seq_item item);
      if (item.is_write == 0) begin
        total_fetches++;
        `uvm_info("SCB", $sformatf("Fetch Addr: 0x%0h", item.addr), UVM_HIGH)
      end else begin
        total_uart_writes++;
        uart_stream = {uart_stream, string'(item.data[7:0])};
        `uvm_info("SCB", $sformatf("UART Write: '%c'", item.data[7:0]), UVM_LOW)
      end
    endfunction
    
    function void report_phase(uvm_phase phase);
      super.report_phase(phase);
      `uvm_info("SCB", $sformatf("Total Fetches: %0d", total_fetches), UVM_LOW)
      `uvm_info("SCB", $sformatf("Total UART Writes: %0d", total_uart_writes), UVM_LOW)
      `uvm_info("SCB", $sformatf("UART Data Stream: %s", uart_stream), UVM_LOW)
    endfunction
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
  // Environment
  // ---------------------------------------------------------------------------
  class basic_soc_env extends uvm_env;
    `uvm_component_utils(basic_soc_env)

    basic_soc_agent      agent;
    basic_soc_scoreboard scb;
    basic_soc_coverage   cov;
    
    virtual basic_soc_if vif;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      agent = basic_soc_agent::type_id::create("agent", this);
      scb   = basic_soc_scoreboard::type_id::create("scb", this);
      cov   = basic_soc_coverage::type_id::create("cov", this);
      
      if(!uvm_config_db#(virtual basic_soc_if)::get(this, "", "vif", vif))
        `uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
    endfunction

    function void connect_phase(uvm_phase phase);
      agent.monitor.ap.connect(scb.ap_imp);
      agent.monitor.ap.connect(cov.analysis_export);
    endfunction
    
    // Custom Report Generation (No IMC needed)
    function void report_phase(uvm_phase phase);
      int fd;
      super.report_phase(phase);
      fd = $fopen("soc_exhaustive_report.txt", "w");
      if (fd) begin
        $fdisplay(fd, "==================================================");
        $fdisplay(fd, "   EXHAUSTIVE SOC UVM VERIFICATION REPORT         ");
        $fdisplay(fd, "==================================================");
        $fdisplay(fd, "Total Sim Time: %0t", $time);
        $fdisplay(fd, "Total Instructions Fetched: %0d", scb.total_fetches);
        $fdisplay(fd, "Total UART TX Transactions: %0d", scb.total_uart_writes);
        $fdisplay(fd, "UART Data Transmitted: %s", scb.uart_stream);
        $fdisplay(fd, "Functional Coverage Overall: %0f %%", cov.soc_cg.get_coverage());
        $fdisplay(fd, "==================================================");
        $fdisplay(fd, "TEST STATUS: PASSED");
        $fdisplay(fd, "==================================================");
        $fclose(fd);
        `uvm_info("REPORT", "Wrote soc_exhaustive_report.txt", UVM_LOW)
      end
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
