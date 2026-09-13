package sentinel_soc_vip_uvm_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // Import AVIP Packages
  import UartGlobalPkg::*;
  import UartTxPkg::*;
  import UartRxPkg::*;
  import UartEnvPkg::*;
  
  import obi_cpu_agent_pkg::*;

  // -------------------------------------------------------------------------
  // APB Register Sequence
  // -------------------------------------------------------------------------
  class soc_reg_seq extends uvm_sequence #(obi_seq_item);
    `uvm_object_utils(soc_reg_seq)
    function new(string name = "soc_reg_seq"); super.new(name); endfunction
    
    task body();
      obi_seq_item item = obi_seq_item::type_id::create("item");
      
      // Test 1: UART TX register write
      `uvm_info("SEQ", "Testing UART Address Decoding (Write)", UVM_LOW)
      start_item(item);
      item.addr = 32'h1050_0000; // UART Base
      item.data = 32'h0000_0055; // Write 'U' (0x55)
      item.we = 1;
      item.be = 4'hF;
      finish_item(item);

      // Test 2: SPI Status register read
      `uvm_info("SEQ", "Testing SPI Address Decoding (Read)", UVM_LOW)
      start_item(item);
      item.addr = 32'h1050_1004; // SPI Register Offset 0x04
      item.we = 0;
      item.be = 4'hF;
      finish_item(item);
      `uvm_info("SEQ", $sformatf("Read SPI Status: %0h", item.data), UVM_LOW)
    endtask
  endclass

  // -------------------------------------------------------------------------
  // Base Test
  // -------------------------------------------------------------------------
  class sentinel_soc_vip_base_test extends uvm_test;
    `uvm_component_utils(sentinel_soc_vip_base_test)

    UartEnvConfig uart_cfg;
    UartEnv       uart_env;
    virtual UartIf vif_uart;
    
    // CPU Agent (NoCore)
    obi_agent     cpu_agent;
    virtual obi_if vif_obi;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      
      // Get Interfaces
      if (!uvm_config_db#(virtual UartIf)::get(this, "", "vif_uart", vif_uart)) begin
        `uvm_fatal("VIP_TEST", "Could not get vif_uart from config DB")
      end
      if (!uvm_config_db#(virtual obi_if)::get(this, "", "vif_obi", vif_obi)) begin
        `uvm_fatal("VIP_TEST", "Could not get vif_obi from config DB")
      end

      // Setup Config
      uart_cfg = UartEnvConfig::type_id::create("uart_cfg");
      uart_cfg.has_tx_agent = 1;
      uart_cfg.has_rx_agent = 1;
      
      uvm_config_db#(UartEnvConfig)::set(this, "*", "UartEnvConfig", uart_cfg);

      // Create Envs/Agents
      uart_env = UartEnv::type_id::create("uart_env", this);
      cpu_agent = obi_agent::type_id::create("cpu_agent", this);
      
      // Pass OBI interface to CPU agent
      uvm_config_db#(virtual obi_if)::set(this, "cpu_agent.driver", "vif", vif_obi);
    endfunction

    task run_phase(uvm_phase phase);
      soc_reg_seq seq;
      phase.raise_objection(this);
      
      `uvm_info("VIP_TEST", "Running SoC with CPU Agent and UART AVIP...", UVM_LOW)
      
      // Wait for reset to finish
      #150; 
      
      // Execute the Register Decoding Sequence
      seq = soc_reg_seq::type_id::create("seq");
      seq.start(cpu_agent.sequencer);
      
      #5000;
      phase.drop_objection(this);
    endtask
  endclass

endpackage
