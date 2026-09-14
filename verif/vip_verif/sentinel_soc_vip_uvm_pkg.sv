package sentinel_soc_vip_uvm_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // Import AVIP Packages
  import UartGlobalPkg::*;
  import UartTxPkg::*;
  import UartRxPkg::*;
  import UartEnvPkg::*;

  import SpiGlobalsPkg::*;
  import SpiMasterPkg::*;
  import SpiSlavePkg::*;
  import SpiEnvPkg::*;

  import JtagGlobalPkg::*;
  import JtagControllerDevicePkg::*;
  import JtagTargetDevicePkg::*;
  import JtagEnvPkg::*;

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
      item.addr = 32'h1050_3000; // Correct UART Base
      item.data = 32'h0000_0055; // Write 'U' (0x55)
      item.we = 1;
      item.be = 4'hF;
      finish_item(item);

      // Test 2: SPI Status register read
      `uvm_info("SEQ", "Testing SPI Address Decoding (Read)", UVM_LOW)
      start_item(item);
      item.addr = 32'h1050_2004; // Correct SPI Register Offset 0x04
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
      uart_cfg.uartTxAgentConfig = UartTxAgentConfig::type_id::create("uartTxAgentConfig");
      uart_cfg.uartRxAgentConfig = UartRxAgentConfig::type_id::create("uartRxAgentConfig");
      uart_cfg.uartTxAgentConfig.is_active = UVM_PASSIVE;
      uart_cfg.uartRxAgentConfig.is_active = UVM_PASSIVE;
      uart_cfg.hasScoreboard = 1;
      
      uvm_config_db#(UartEnvConfig)::set(this, "*", "uartEnvConfig", uart_cfg);
      uvm_config_db#(UartTxAgentConfig)::set(this, "*", "uartTxAgentConfig", uart_cfg.uartTxAgentConfig);
      uvm_config_db#(UartRxAgentConfig)::set(this, "*", "uartRxAgentConfig", uart_cfg.uartRxAgentConfig);

      uvm_config_db#(virtual UartIf)::set(this, "uart_env", "vif", vif_uart);
      uvm_config_db#(virtual UartIf)::set(this, "uart_env.*", "vif", vif_uart);

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

  // -------------------------------------------------------------------------
  // UART VIP Integration Test (Traffic Test)
  // -------------------------------------------------------------------------
  
  // Sequence that blasts data using the CPU agent, meant to be caught by the UART VIP
  class soc_uart_traffic_seq extends uvm_sequence #(obi_seq_item);
    `uvm_object_utils(soc_uart_traffic_seq)
    function new(string name = "soc_uart_traffic_seq"); super.new(name); endfunction
    
    task body();
      obi_seq_item item = obi_seq_item::type_id::create("item");
      string payload = "Hello mBits VIP!";
      
      `uvm_info("SEQ", "Blasting payload into UART TX Register...", UVM_LOW)
      
      foreach(payload[i]) begin
        start_item(item);
        item.addr = 32'h1050_3000; // Correct UART TXDATA Base
        item.data = {24'h0, payload[i]}; // Write 1 byte
        item.we = 1;
        item.be = 4'h1; // Byte enable
        finish_item(item);
      end
      
      `uvm_info("SEQ", "Payload sent to APB!", UVM_LOW)
    endtask
  endclass

  class sentinel_soc_vip_uart_test extends sentinel_soc_vip_base_test;
    `uvm_component_utils(sentinel_soc_vip_uart_test)
    
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
    
    task run_phase(uvm_phase phase);
      soc_uart_traffic_seq seq;
      phase.raise_objection(this);
      
      `uvm_info("UART_TEST", "Running SoC UART Traffic Test...", UVM_LOW)
      
      #150; 
      
      // Execute the traffic sequence on the CPU agent
      // The UART AVIP (instantiated in the base_test) is passively monitoring the 
      // physical tx/rx pins on the outside of the SoC and will automatically 
      // capture and score this traffic!
      seq = soc_uart_traffic_seq::type_id::create("seq");
      seq.start(cpu_agent.sequencer);
      
      // Wait for UART RTL to shift out all the bits
      #50000;
      
      phase.drop_objection(this);
    endtask
  endclass

  // -------------------------------------------------------------------------
  // SPI VIP Integration Test
  // -------------------------------------------------------------------------
  class soc_spi_traffic_seq extends uvm_sequence #(obi_seq_item);
    `uvm_object_utils(soc_spi_traffic_seq)
    function new(string name = "soc_spi_traffic_seq"); super.new(name); endfunction
    task body();
      obi_seq_item item = obi_seq_item::type_id::create("item");
      `uvm_info("SEQ", "Configuring SPI...", UVM_LOW)
      start_item(item);
      item.addr = 32'h1050_2004; // SPI CLKDIV
      item.data = 32'h0000_0008; 
      item.we = 1; item.be = 4'hF;
      finish_item(item);
    endtask
  endclass

  class sentinel_soc_vip_spi_test extends sentinel_soc_vip_base_test;
    `uvm_component_utils(sentinel_soc_vip_spi_test)

    SpiEnvConfig  spi_cfg;
    SpiEnv        spi_env;
    virtual SpiInterface vif_spi;

    function new(string name, uvm_component parent); super.new(name, parent); endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(virtual SpiInterface)::get(this, "", "vif_spi", vif_spi))
        `uvm_fatal("SPI_TEST", "Could not get vif_spi from config DB")

      spi_cfg = SpiEnvConfig::type_id::create("spi_cfg");
      spi_cfg.noOfSlaves = 1;                    // single spi_csn_o/miso_i/mosi_o on the DUT
      spi_cfg.spiSlaveAgentConfig = new[1];      // must allocate before indexing — dynamic array starts empty

      spi_cfg.spiMasterAgentConfig = SpiMasterAgentConfig::type_id::create("spiMasterAgentConfig");
      spi_cfg.spiMasterAgentConfig.isActive = UVM_PASSIVE;  // DUT is the real master; VIP master side only monitors

      spi_cfg.spiSlaveAgentConfig[0] = SpiSlaveAgentConfig::type_id::create("spiSlaveAgentConfig0");
      spi_cfg.spiSlaveAgentConfig[0].isActive = UVM_ACTIVE; // VIP plays the external slave the DUT is talking to

      uvm_config_db#(SpiEnvConfig)::set(this, "*", "SpiEnvConfig", spi_cfg);

      spi_env = SpiEnv::type_id::create("spi_env", this);
      uvm_config_db#(virtual SpiInterface)::set(this, "spi_env.*", "vif", vif_spi);
    endfunction

    task run_phase(uvm_phase phase);
      soc_spi_traffic_seq seq;
      phase.raise_objection(this);
      #150;
      seq = soc_spi_traffic_seq::type_id::create("seq");
      seq.start(cpu_agent.sequencer);
      #50000;
      phase.drop_objection(this);
    endtask
  endclass

  // -------------------------------------------------------------------------
  // QSPI VIP Integration Test
  // -------------------------------------------------------------------------
  class soc_qspi_flash_seq extends uvm_sequence #(obi_seq_item);
    `uvm_object_utils(soc_qspi_flash_seq)
    function new(string name = "soc_qspi_flash_seq"); super.new(name); endfunction
    task body();
      obi_seq_item item = obi_seq_item::type_id::create("item");
      start_item(item);
      item.addr = 32'h1050_0000; // QSPI Base
      item.data = 32'h0300_0000; // Read command
      item.we = 1; item.be = 4'hF;
      finish_item(item);
    endtask
  endclass

  class sentinel_soc_vip_qspi_test extends sentinel_soc_vip_base_test;
    `uvm_component_utils(sentinel_soc_vip_qspi_test)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    task run_phase(uvm_phase phase);
      soc_qspi_flash_seq seq;
      phase.raise_objection(this);
      #150; seq = soc_qspi_flash_seq::type_id::create("seq"); seq.start(cpu_agent.sequencer); #50000;
      phase.drop_objection(this);
    endtask
  endclass

  // -------------------------------------------------------------------------
  // GPIO VIP Integration Test
  // -------------------------------------------------------------------------
  class soc_gpio_toggle_seq extends uvm_sequence #(obi_seq_item);
    `uvm_object_utils(soc_gpio_toggle_seq)
    function new(string name = "soc_gpio_toggle_seq"); super.new(name); endfunction
    task body();
      obi_seq_item item = obi_seq_item::type_id::create("item");
      start_item(item);
      item.addr = 32'h1060_0000; // GPIO DIR
      item.data = 32'hFFFF_FFFF; 
      item.we = 1; item.be = 4'hF;
      finish_item(item);
    endtask
  endclass

  class sentinel_soc_vip_gpio_test extends sentinel_soc_vip_base_test;
    `uvm_component_utils(sentinel_soc_vip_gpio_test)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    task run_phase(uvm_phase phase);
      soc_gpio_toggle_seq seq;
      phase.raise_objection(this);
      #150; seq = soc_gpio_toggle_seq::type_id::create("seq"); seq.start(cpu_agent.sequencer); #50000;
      phase.drop_objection(this);
    endtask
  endclass
  
  // -------------------------------------------------------------------------
  // JTAG VIP Integration Test
  // -------------------------------------------------------------------------
  class sentinel_soc_vip_jtag_test extends sentinel_soc_vip_base_test;
    `uvm_component_utils(sentinel_soc_vip_jtag_test)

    JtagEnvConfig  jtag_cfg;
    JtagEnv        jtag_env;
    virtual JtagIf vif_jtag;

    function new(string name, uvm_component parent); super.new(name, parent); endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(virtual JtagIf)::get(this, "", "vif_jtag", vif_jtag))
        `uvm_fatal("JTAG_TEST", "Could not get vif_jtag from config DB")
    
      jtag_cfg = JtagEnvConfig::type_id::create("jtag_cfg");
      jtag_cfg.jtagControllerDeviceAgentConfig = JtagControllerDeviceAgentConfig::type_id::create("jtagControllerDeviceAgentConfig");
      jtag_cfg.jtagControllerDeviceAgentConfig.is_active = UVM_ACTIVE;
    
      jtag_cfg.jtagTargetDeviceAgentConfig = JtagTargetDeviceAgentConfig::type_id::create("jtagTargetDeviceAgentConfig");
      jtag_cfg.jtagTargetDeviceAgentConfig.is_active = UVM_PASSIVE;
    
      uvm_config_db#(JtagEnvConfig)::set(this, "*", "jtagEnvConfig", jtag_cfg);
    
      jtag_env = JtagEnv::type_id::create("jtag_env", this);
      uvm_config_db#(virtual JtagIf)::set(this, "jtag_env.*", "vif", vif_jtag);
    endfunction

    task run_phase(uvm_phase phase);
      // TODO: replace with an actual JtagControllerDevice sequence
      // (e.g. JtagControllerDevicePatternBasedSequence) started on
      // jtag_env's controller sequencer, once a concrete debug
      // operation (DMI read/write, halt/resume) is decided
      phase.raise_objection(this);
      `uvm_info("JTAG_TEST", "Running SoC JTAG Traffic Test...", UVM_LOW)
      #50000;
      phase.drop_objection(this);
    endtask
  endclass

  // -------------------------------------------------------------------------
  // TIMER VIP Integration Test
  // -------------------------------------------------------------------------
  class soc_timer_irq_seq extends uvm_sequence #(obi_seq_item);
    `uvm_object_utils(soc_timer_irq_seq)
    function new(string name = "soc_timer_irq_seq"); super.new(name); endfunction
    task body();
      obi_seq_item item = obi_seq_item::type_id::create("item");
      start_item(item);
      item.addr = 32'h1050_1000; // Timer Base
      item.data = 32'h0000_0010; 
      item.we = 1; item.be = 4'hF;
      finish_item(item);
    endtask
  endclass

  class sentinel_soc_vip_timer_test extends sentinel_soc_vip_base_test;
    `uvm_component_utils(sentinel_soc_vip_timer_test)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    task run_phase(uvm_phase phase);
      soc_timer_irq_seq seq;
      phase.raise_objection(this);
      #150; seq = soc_timer_irq_seq::type_id::create("seq"); seq.start(cpu_agent.sequencer); #50000;
      phase.drop_objection(this);
    endtask
  endclass

endpackage
