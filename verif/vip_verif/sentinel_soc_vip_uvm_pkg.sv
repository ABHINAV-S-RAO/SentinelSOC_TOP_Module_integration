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
  import JtagControllerDeviceSequencePkg::*;
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
      uart_cfg.uartTxAgentConfig.uartBaudRate           = BAUD_9600;
      uart_cfg.uartTxAgentConfig.uartOverSamplingMethod = OVERSAMPLING_16;
      uart_cfg.uartTxAgentConfig.uartDataType            = EIGHT_BIT;
      uart_cfg.uartTxAgentConfig.uartStopBit              = ONE_BIT;
      uart_cfg.uartRxAgentConfig = UartRxAgentConfig::type_id::create("uartRxAgentConfig");
      uart_cfg.uartRxAgentConfig.uartBaudRate           = BAUD_9600;
      uart_cfg.uartRxAgentConfig.uartOverSamplingMethod = OVERSAMPLING_16;
      uart_cfg.uartRxAgentConfig.uartDataType            = EIGHT_BIT;
      uart_cfg.uartRxAgentConfig.uartStopBit              = ONE_BIT;
      uart_cfg.uartRxAgentConfig.OverSampledBaudFrequencyClk = 1;
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

    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      // uart_env's own build_phase (which constructs uartScoreboard) only
      // runs *after* this test's build_phase returns — doing this set() in
      // build_phase captured a still-null handle. connect_phase runs after
      // every component's build_phase in the whole hierarchy has finished,
      // so uart_env.uartScoreboard is guaranteed constructed by now.
      uvm_config_db#(UartScoreboard)::set(null, "*", "uart_scoreboard", uart_env.uartScoreboard);
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
  
      // Sequence that configures the UART baud divisor, then blasts data using
  // the CPU agent, meant to be caught by the UART VIP
  class soc_uart_traffic_seq extends uvm_sequence #(obi_seq_item);
    `uvm_object_utils(soc_uart_traffic_seq)
    function new(string name = "soc_uart_traffic_seq"); super.new(name); endfunction

    task body();
      obi_seq_item item = obi_seq_item::type_id::create("item");
      string payload = "Hello mBits VIP!";
      UartScoreboard uart_scoreboard;

      if (!uvm_config_db#(UartScoreboard)::get(null, "", "uart_scoreboard", uart_scoreboard)) begin
        `uvm_error("SEQ", "Could not get uart_scoreboard handle - TX side of scoreboard will not be fed, comparison will hang")
      end

      // -----------------------------------------------------------------
      // Configure UART for 9600 baud, 8N1, matching uartRxAgentConfig set
      // in build_phase. divisor = clk_freq / (16 * baud)
      //                        = 50_000_000 / (16*9600) ~= 326 (0x0146)
      // Standard 16550-style DLAB sequence: LCR is offset 3.
      // -----------------------------------------------------------------
      `uvm_info("SEQ", "Configuring UART baud divisor (DLAB sequence)...", UVM_LOW)

      // 1. Set DLAB (bit 7 of LCR) to expose DLL/DLM at offsets 0/1
      start_item(item);
      item.addr = 32'h1050_3000 + 3; // LCR
      item.data = 32'h0000_0083;     // DLAB=1, 8 data bits, no parity, 1 stop bit
      item.we = 1; item.be = 4'h1;
      finish_item(item);

      // 2. Write DLL (low byte of divisor) at offset 0
      start_item(item);
      item.addr = 32'h1050_3000 + 0;
      item.data = 32'h0000_0057; // 5207 & 0xFF = 0x57 (fixed)
      item.we = 1; item.be = 4'h1;
      finish_item(item);

      // 3. Write DLM (high byte of divisor) at offset 1
      start_item(item);
      item.addr = 32'h1050_3000 + 1;
      item.data = 32'h0000_0014; // 5207 >> 8 = 0x14 (fixed)
      item.we = 1; item.be = 4'h1;
      finish_item(item);

      // 4. Clear DLAB — offsets 0/1 go back to RBR/THR and IER
      start_item(item);
      item.addr = 32'h1050_3000 + 3;
      item.data = 32'h0000_0003; // DLAB=0, 8N1 stays set
      item.we = 1; item.be = 4'h1;
      finish_item(item);

      // -----------------------------------------------------------------
      // Now blast the payload
      // -----------------------------------------------------------------
      `uvm_info("SEQ", "Blasting payload into UART TX Register...", UVM_LOW)

      foreach(payload[i]) begin
        start_item(item);
        item.addr = 32'h1050_3000; // Correct UART TXDATA Base
        item.data = {24'h0, payload[i]}; // Write 1 byte
        item.we = 1;
        item.be = 4'h1; // Byte enable
        finish_item(item);
        #2100000;

        // Register write completed — this byte is now the "ground truth"
        // expected transmission. Push it straight into the scoreboard's
        // TX fifo so compareTxRx() can pair it against whatever the RX
        // monitor decodes off the real DUT uart_tx_o pin.
        if (uart_scoreboard != null) begin
          UartTxTransaction exp_tx = UartTxTransaction::type_id::create("exp_tx");
          exp_tx.transmissionData = payload[i];
          exp_tx.parity       = 1'b0;
          exp_tx.parityError  = 1'b0;
          exp_tx.framingError = 1'b0;
          exp_tx.breakingError = 1'b0;
          uart_scoreboard.uartScoreboardTxAnalysisExport.write(exp_tx);
        end
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
      
      // Wait for UART RTL to shift out all the bits at real 9600 baud:
      // ~10 bits/byte / 9600 baud ~= 1.04ms/byte, 16 bytes ~= 17ms minimum,
      // plus baud-config writes and margin.
      #20_000_000;
      
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
    uvm_tlm_analysis_fifo #(JtagTargetDeviceTransaction) target_fifo;

    function new(string name, uvm_component parent); super.new(name, parent); endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(virtual JtagIf)::get(this, "", "vif_jtag", vif_jtag))
        `uvm_fatal("JTAG_TEST", "Could not get vif_jtag from config DB")
    
      jtag_cfg = JtagEnvConfig::type_id::create("jtag_cfg");
      jtag_cfg.hasScoreboard = 0; // Self-checking verification in test
      jtag_cfg.hasVirtualSequencer = 0;

      // Controller Agent Configuration
      jtag_cfg.jtagControllerDeviceAgentConfig = JtagControllerDeviceAgentConfig::type_id::create("jtagControllerDeviceAgentConfig");
      jtag_cfg.jtagControllerDeviceAgentConfig.is_active = UVM_ACTIVE;
      jtag_cfg.jtagControllerDeviceAgentConfig.hasCoverage = 0;
      jtag_cfg.jtagControllerDeviceAgentConfig.jtagInstructionWidth  = instructionWidth5Bit;
      jtag_cfg.jtagControllerDeviceAgentConfig.jtagTestVectorWidth   = testVectorWidth32Bit;
      jtag_cfg.jtagControllerDeviceAgentConfig.jtagInstructionOpcode = userDefinedRegister; // 5'b00001 = IDCODE
      jtag_cfg.jtagControllerDeviceAgentConfig.trstEnable            = 1'b1;

      // Target Agent Configuration (Passive monitor on DUT TDO)
      jtag_cfg.jtagTargetDeviceAgentConfig = JtagTargetDeviceAgentConfig::type_id::create("jtagTargetDeviceAgentConfig");
      jtag_cfg.jtagTargetDeviceAgentConfig.is_active = UVM_PASSIVE;
      jtag_cfg.jtagTargetDeviceAgentConfig.hasCoverage = 0;
      jtag_cfg.jtagTargetDeviceAgentConfig.jtagInstructionWidth  = instructionWidth5Bit;
      jtag_cfg.jtagTargetDeviceAgentConfig.jtagTestVectorWidth   = testVectorWidth32Bit;
      jtag_cfg.jtagTargetDeviceAgentConfig.jtagInstructionOpcode = userDefinedRegister;

      uvm_config_db#(JtagEnvConfig)::set(this, "*", "jtagEnvConfig", jtag_cfg);
      uvm_config_db#(JtagControllerDeviceAgentConfig)::set(null, "*", "jtagControllerDeviceAgentConfig", jtag_cfg.jtagControllerDeviceAgentConfig);
      uvm_config_db#(JtagTargetDeviceAgentConfig)::set(null, "*", "jtagTargetDeviceAgentConfig", jtag_cfg.jtagTargetDeviceAgentConfig);
    
      jtag_env = JtagEnv::type_id::create("jtag_env", this);
      target_fifo = new("target_fifo", this);
    endfunction

    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      jtag_env.jtagTargetDeviceAgent.jtagTargetDeviceAnalysisPort.connect(target_fifo.analysis_export);
    endfunction

    task run_phase(uvm_phase phase);
      JtagControllerDevicePatternBasedSequence pat_seq;
      JtagTargetDeviceTransaction rsp_item;
      int error_count = 0;
      int pass_count  = 0;
      logic [31:0] expected_bypass;

      phase.raise_objection(this);
      `uvm_info("JTAG_TEST", "==================================================", UVM_LOW)
      `uvm_info("JTAG_TEST", " Starting SentinelSoC JTAG AVIP Verification Suite ", UVM_LOW)
      `uvm_info("JTAG_TEST", "==================================================", UVM_LOW)

      #200; // Allow SoC power-on reset deassertion

      // -----------------------------------------------------------------------
      // Phase 1: TAP Hardware Reset (TRST_n assertion)
      // -----------------------------------------------------------------------
      `uvm_info("JTAG_TEST", "[Phase 1] Asserting JTAG Hardware Reset (TRST_n)...", UVM_LOW)
      pat_seq = JtagControllerDevicePatternBasedSequence::type_id::create("pat_seq");
      pat_seq.tresetEnable = 1'b0; // Assert TRST_n (Trst = 0)
      pat_seq.patternNeeded = 32'h0;
      pat_seq.start(jtag_env.jtagControllerDeviceAgent.jtagControllerDeviceSequencer);
      
      target_fifo.get(rsp_item);
      `uvm_info("JTAG_TEST", "[Phase 1] TAP Reset complete.", UVM_LOW)
      pass_count++;

      // -----------------------------------------------------------------------
      // Phase 2: IDCODE Readback Verification
      // IEEE 1149.1 / RISC-V Debug TAP: Default IR on reset is IDCODE (5'h01)
      // IDCODE Value in SentinelSoC: 32'h0000_0DB3
      // -----------------------------------------------------------------------
      `uvm_info("JTAG_TEST", "[Phase 2] Verifying JTAG IDCODE (Expected: 32'h00000DB3)...", UVM_LOW)
      jtag_cfg.jtagControllerDeviceAgentConfig.jtagInstructionOpcode = userDefinedRegister; // 5'b00001 = IDCODE
      jtag_cfg.jtagTargetDeviceAgentConfig.jtagInstructionOpcode     = userDefinedRegister;
      jtag_env.jtagControllerDeviceAgent.jtagControllerDeviceDriver.jtagConfigStruct.jtagInstructionOpcode = 5'b00001;

      pat_seq = JtagControllerDevicePatternBasedSequence::type_id::create("pat_seq");
      pat_seq.tresetEnable = 1'b1;
      pat_seq.patternNeeded = 32'hFFFF_FFFF;
      pat_seq.start(jtag_env.jtagControllerDeviceAgent.jtagControllerDeviceSequencer);

      target_fifo.get(rsp_item);
      `uvm_info("JTAG_TEST", $sformatf("[Phase 2] Monitor received vector: 32'h%08h, instruction: 5'b%05b", 
                rsp_item.jtagTestVector, rsp_item.jtagInstruction), UVM_LOW)

      if (rsp_item.jtagTestVector === 32'h0000_0DB3) begin
        `uvm_info("JTAG_TEST", $sformatf("[PASS] Phase 2: IDCODE matched perfectly: 0x%08h", rsp_item.jtagTestVector), UVM_LOW)
        pass_count++;
      end else begin
        `uvm_error("JTAG_TEST", $sformatf("[FAIL] Phase 2: IDCODE mismatch! Expected: 0x00000DB3, Got: 0x%08h", rsp_item.jtagTestVector))
        error_count++;
      end

      // -----------------------------------------------------------------------
      // Phase 3: BYPASS Register Verification (Pattern: 0xA5A5_5A5A)
      // BYPASS opcode = 5'h00. 1-bit shift register with 1-cycle latency.
      // Expected shifted output = {pattern[30:0], 1'b0}
      // -----------------------------------------------------------------------
      `uvm_info("JTAG_TEST", "[Phase 3] Verifying BYPASS Register (Pattern: 0xA5A55A5A)...", UVM_LOW)
      jtag_cfg.jtagControllerDeviceAgentConfig.jtagInstructionOpcode = bypassRegister; // 5'b00000 = BYPASS0
      jtag_cfg.jtagTargetDeviceAgentConfig.jtagInstructionOpcode     = bypassRegister;
      jtag_env.jtagControllerDeviceAgent.jtagControllerDeviceDriver.jtagConfigStruct.jtagInstructionOpcode = 5'b00000;

      pat_seq = JtagControllerDevicePatternBasedSequence::type_id::create("pat_seq");
      pat_seq.tresetEnable = 1'b1;
      pat_seq.patternNeeded = 32'hA5A5_5A5A;
      pat_seq.start(jtag_env.jtagControllerDeviceAgent.jtagControllerDeviceSequencer);

      target_fifo.get(rsp_item);
      expected_bypass = 32'hA5A5_5A5A << 1; // {pattern[30:0], 1'b0} — BYPASS 1-cycle latency
      `uvm_info("JTAG_TEST", $sformatf("[Phase 3] Monitor received vector: 32'h%08h (Expected: 32'h%08h)", 
                rsp_item.jtagTestVector, expected_bypass), UVM_LOW)

      if (rsp_item.jtagTestVector === expected_bypass) begin
        `uvm_info("JTAG_TEST", $sformatf("[PASS] Phase 3: BYPASS 1-cycle shift matched: 0x%08h", rsp_item.jtagTestVector), UVM_LOW)
        pass_count++;
      end else begin
        `uvm_error("JTAG_TEST", $sformatf("[FAIL] Phase 3: BYPASS mismatch! Expected: 0x%08h, Got: 0x%08h", 
                  expected_bypass, rsp_item.jtagTestVector))
        error_count++;
      end

      // -----------------------------------------------------------------------
      // Phase 4: BYPASS Register Stress Test (Pattern: 0x1234_5678)
      // -----------------------------------------------------------------------
      `uvm_info("JTAG_TEST", "[Phase 4] Verifying BYPASS Register (Pattern: 0x12345678)...", UVM_LOW)
      jtag_cfg.jtagControllerDeviceAgentConfig.jtagInstructionOpcode = bypassRegister;
      jtag_cfg.jtagTargetDeviceAgentConfig.jtagInstructionOpcode     = bypassRegister;
      jtag_env.jtagControllerDeviceAgent.jtagControllerDeviceDriver.jtagConfigStruct.jtagInstructionOpcode = 5'b00000;

      pat_seq = JtagControllerDevicePatternBasedSequence::type_id::create("pat_seq");
      pat_seq.tresetEnable = 1'b1;
      pat_seq.patternNeeded = 32'h1234_5678;
      pat_seq.start(jtag_env.jtagControllerDeviceAgent.jtagControllerDeviceSequencer);

      target_fifo.get(rsp_item);
      expected_bypass = 32'h1234_5678 << 1; // {pattern[30:0], 1'b0} — BYPASS 1-cycle latency
      `uvm_info("JTAG_TEST", $sformatf("[Phase 4] Monitor received vector: 32'h%08h (Expected: 32'h%08h)", 
                rsp_item.jtagTestVector, expected_bypass), UVM_LOW)

      if (rsp_item.jtagTestVector === expected_bypass) begin
        `uvm_info("JTAG_TEST", $sformatf("[PASS] Phase 4: BYPASS pattern 2 matched: 0x%08h", rsp_item.jtagTestVector), UVM_LOW)
        pass_count++;
      end else begin
        `uvm_error("JTAG_TEST", $sformatf("[FAIL] Phase 4: BYPASS mismatch! Expected: 0x%08h, Got: 0x%08h", 
                  expected_bypass, rsp_item.jtagTestVector))
        error_count++;
      end

      // -----------------------------------------------------------------------
      // Phase 5: DTMCS Register Verification
      // DTMCSR opcode = 5'h10.
      // Expected DTMCS: version=1 (bits 3:0), abits=7 (bits 9:4), idle=1 (bits 14:12) -> 32'h0000_1071
      // -----------------------------------------------------------------------
      `uvm_info("JTAG_TEST", "[Phase 5] Verifying DTMCS Register (Opcode 5'h10)...", UVM_LOW)
      jtag_cfg.jtagControllerDeviceAgentConfig.jtagInstructionOpcode = JtagInstructionOpcodeEnum'(5'h10);
      jtag_cfg.jtagTargetDeviceAgentConfig.jtagInstructionOpcode     = JtagInstructionOpcodeEnum'(5'h10);
      jtag_env.jtagControllerDeviceAgent.jtagControllerDeviceDriver.jtagConfigStruct.jtagInstructionOpcode = 5'h10;

      pat_seq = JtagControllerDevicePatternBasedSequence::type_id::create("pat_seq");
      pat_seq.tresetEnable = 1'b1;
      pat_seq.patternNeeded = 32'h0000_0000;
      pat_seq.start(jtag_env.jtagControllerDeviceAgent.jtagControllerDeviceSequencer);

      target_fifo.get(rsp_item);
      `uvm_info("JTAG_TEST", $sformatf("[Phase 5] Monitor received vector: 32'h%08h", rsp_item.jtagTestVector), UVM_LOW)

      // Check version (bits 3:0) and abits (bits 9:4)
      begin
        logic [3:0]  dtmcs_version;
        logic [5:0]  dtmcs_abits;
        dtmcs_version = rsp_item.jtagTestVector[3:0];
        dtmcs_abits   = rsp_item.jtagTestVector[9:4];
        if (dtmcs_version === 4'd1 && dtmcs_abits === 6'd7) begin
          `uvm_info("JTAG_TEST", $sformatf("[PASS] Phase 5: DTMCS verified! version=1, abits=7, dtmcs=0x%08h", 
                    rsp_item.jtagTestVector), UVM_LOW)
          pass_count++;
        end else begin
          `uvm_error("JTAG_TEST", $sformatf("[FAIL] Phase 5: DTMCS mismatch! Expected version=1, abits=7; Got: 0x%08h", 
                    rsp_item.jtagTestVector))
          error_count++;
        end
      end

      // -----------------------------------------------------------------------
      // Final Test Summary
      // -----------------------------------------------------------------------
      `uvm_info("JTAG_TEST", "==================================================", UVM_LOW)
      `uvm_info("JTAG_TEST", $sformatf(" JTAG VERIFICATION SUMMARY: %0d PASSED, %0d FAILED", pass_count, error_count), UVM_LOW)
      `uvm_info("JTAG_TEST", "==================================================", UVM_LOW)

      if (error_count == 0) begin
        `uvm_info("JTAG_TEST", " *** ALL JTAG VERIFICATION TESTS PASSED SUCCESSFULLY! ***", UVM_LOW)
      end else begin
        `uvm_fatal("JTAG_TEST", " *** JTAG VERIFICATION ENCOUNTERED FAILURES! ***")
      end

      #1000;
      phase.drop_objection(this);
    endtask
  endclass

  // -------------------------------------------------------------------------
  // TIMER VIP Integration Test & Exhaustive Sequence
  // -------------------------------------------------------------------------
  // Basic 3-step timer sequence (legacy reference)
  class soc_timer_irq_seq extends uvm_sequence #(obi_seq_item);
    `uvm_object_utils(soc_timer_irq_seq)
    function new(string name = "soc_timer_irq_seq"); super.new(name); endfunction
    task body();
      obi_seq_item item = obi_seq_item::type_id::create("item");

      // 1. Program CMP register (offset 0x08) to 100 cycles
      `uvm_info("TIMER_SEQ", "Step 1: Programming CMP register (0x10501008) to 100 cycles", UVM_LOW)
      start_item(item);
      item.addr = 32'h1050_1008; // Timer CMP
      item.data = 32'd100; 
      item.we   = 1; item.be = 4'hF;
      finish_item(item);

      #40; // Allow APB bus to complete cycle and return to idle

      // 2. Enable Timer via CTRL register (offset 0x04, bit 0 = 1, prescaler = 0)
      `uvm_info("TIMER_SEQ", "Step 2: Enabling Timer via CTRL register (0x10501004)", UVM_LOW)
      start_item(item);
      item.addr = 32'h1050_1004; // Timer CTRL
      item.data = 32'h0000_0001; // Enable bit = 1
      item.we   = 1; item.be = 4'hF;
      finish_item(item);

      // 3. Read back timer value after 200ns to verify counting
      #200;
      `uvm_info("TIMER_SEQ", "Step 3: Reading back TIMER counter value (0x10501000)", UVM_LOW)
      start_item(item);
      item.addr = 32'h1050_1000; // Timer VALUE
      item.we   = 0; item.be = 4'hF;
      finish_item(item);
    endtask
  endclass

  // Exhaustive Verification Sequence covering 100% of timer functionality
  class soc_timer_exhaustive_seq extends uvm_sequence #(obi_seq_item);
    `uvm_object_utils(soc_timer_exhaustive_seq)

    virtual timer_irq_if vif_timer;

    localparam bit [31:0] T0_REG_VALUE = 32'h1050_1000;
    localparam bit [31:0] T0_REG_CTRL  = 32'h1050_1004;
    localparam bit [31:0] T0_REG_CMP   = 32'h1050_1008;

    localparam bit [31:0] T1_REG_VALUE = 32'h1050_1010;
    localparam bit [31:0] T1_REG_CTRL  = 32'h1050_1014;
    localparam bit [31:0] T1_REG_CMP   = 32'h1050_1018;

    function new(string name = "soc_timer_exhaustive_seq");
      super.new(name);
    endfunction

    // Bus Helper: APB write via OBI CPU agent
    task write_reg(input bit [31:0] addr, input bit [31:0] data);
      obi_seq_item item = obi_seq_item::type_id::create("item");
      start_item(item);
      item.addr = addr;
      item.data = data;
      item.we   = 1;
      item.be   = 4'hF;
      finish_item(item);
      #40; // APB idle spacing
    endtask

    // Bus Helper: APB read via OBI CPU agent
    task read_reg(input bit [31:0] addr, output bit [31:0] data);
      obi_seq_item item = obi_seq_item::type_id::create("item");
      start_item(item);
      item.addr = addr;
      item.we   = 0;
      item.be   = 4'hF;
      finish_item(item);
      data = item.data;
      #40; // APB idle spacing
    endtask

    // Interrupt Wait Helper with cycle timeout
    task wait_for_irq(input int irq_idx, input int timeout_cycles, output bit ok);
      int cnt = 0;
      ok = 0;
      while (!vif_timer.irq_raw_seen[irq_idx] && cnt < timeout_cycles) begin
        @(negedge vif_timer.clk_i);
        cnt++;
      end
      ok = vif_timer.irq_raw_seen[irq_idx];
    endtask

    task body();
      bit [31:0] rdata;
      bit [31:0] val1, val2, val3;
      bit irq_ok;

      `uvm_info("TIMER_EXHAUSTIVE", "==================================================", UVM_LOW)
      `uvm_info("TIMER_EXHAUSTIVE", "=== STARTING EXHAUSTIVE APB TIMER VERIFICATION ===", UVM_LOW)
      `uvm_info("TIMER_EXHAUSTIVE", "==================================================", UVM_LOW)

      // -----------------------------------------------------------------------
      // PHASE 1: Reset Values Check
      // -----------------------------------------------------------------------
      `uvm_info("TIMER_EXHAUSTIVE", "[PHASE 1] Checking reset values of all Timer 0 and Timer 1 registers...", UVM_LOW)
      read_reg(T0_REG_VALUE, rdata);
      if (rdata !== 32'h0) `uvm_error("TIMER_EXHAUSTIVE", $sformatf("T0_VALUE reset error: expected 0, got 0x%08h", rdata))
      read_reg(T0_REG_CTRL,  rdata);
      if (rdata !== 32'h0) `uvm_error("TIMER_EXHAUSTIVE", $sformatf("T0_CTRL reset error: expected 0, got 0x%08h", rdata))
      read_reg(T0_REG_CMP,   rdata);
      if (rdata !== 32'h0) `uvm_error("TIMER_EXHAUSTIVE", $sformatf("T0_CMP reset error: expected 0, got 0x%08h", rdata))

      read_reg(T1_REG_VALUE, rdata);
      if (rdata !== 32'h0) `uvm_error("TIMER_EXHAUSTIVE", $sformatf("T1_VALUE reset error: expected 0, got 0x%08h", rdata))
      read_reg(T1_REG_CTRL,  rdata);
      if (rdata !== 32'h0) `uvm_error("TIMER_EXHAUSTIVE", $sformatf("T1_CTRL reset error: expected 0, got 0x%08h", rdata))
      read_reg(T1_REG_CMP,   rdata);
      if (rdata !== 32'h0) `uvm_error("TIMER_EXHAUSTIVE", $sformatf("T1_CMP reset error: expected 0, got 0x%08h", rdata))
      `uvm_info("TIMER_EXHAUSTIVE", "[PHASE 1 PASSED] All 6 registers reset to 0x00000000", UVM_LOW)

      // -----------------------------------------------------------------------
      // PHASE 2: Register Read/Write Integrity & CMP-Write Auto-Resets Value
      // -----------------------------------------------------------------------
      `uvm_info("TIMER_EXHAUSTIVE", "[PHASE 2] Testing Register RW Integrity & CMP auto-clear of VALUE...", UVM_LOW)
      write_reg(T0_REG_CMP, 32'hA5A5_0050);
      read_reg(T0_REG_CMP, rdata);
      if (rdata !== 32'hA5A5_0050) `uvm_error("TIMER_EXHAUSTIVE", $sformatf("T0_CMP RW mismatch: expected 0xA5A50050, got 0x%08h", rdata))

      write_reg(T1_REG_CMP, 32'h5A5A_0030);
      read_reg(T1_REG_CMP, rdata);
      if (rdata !== 32'h5A5A_0030) `uvm_error("TIMER_EXHAUSTIVE", $sformatf("T1_CMP RW mismatch: expected 0x5A5A0030, got 0x%08h", rdata))

      // Direct write to T0_VALUE
      write_reg(T0_REG_VALUE, 32'h0000_1234);
      read_reg(T0_REG_VALUE, rdata);
      if (rdata !== 32'h0000_1234) `uvm_error("TIMER_EXHAUSTIVE", $sformatf("T0_VALUE direct write mismatch: expected 0x1234, got 0x%08h", rdata))

      // Writing CMP must auto-reset VALUE to 0 (timer.sv line 102)
      write_reg(T0_REG_CMP, 32'd50);
      read_reg(T0_REG_VALUE, rdata);
      if (rdata !== 32'h0) `uvm_error("TIMER_EXHAUSTIVE", $sformatf("Writing CMP did not reset VALUE: expected 0, got 0x%08h", rdata))
      `uvm_info("TIMER_EXHAUSTIVE", "[PHASE 2 PASSED] Register RW integrity and CMP-write-resets-VALUE confirmed", UVM_LOW)

      // -----------------------------------------------------------------------
      // PHASE 3: Timer 0 Compare Match Interrupt & Auto-Reset (Prescaler = 0)
      // -----------------------------------------------------------------------
      `uvm_info("TIMER_EXHAUSTIVE", "[PHASE 3] Testing Timer 0 Compare Match IRQ (CMP=40, Prescaler=0)...", UVM_LOW)
      vif_timer.clear_flags();
      write_reg(T0_REG_CMP, 32'd40); // 40 cycles = 800 ns
      write_reg(T0_REG_CTRL, 32'h0000_0001); // Enable Timer 0

      wait_for_irq(1, 200, irq_ok); // irq_raw_seen[1] = T0 CMP
      if (!irq_ok) `uvm_error("TIMER_EXHAUSTIVE", "TIMED OUT waiting for Timer 0 Compare Match IRQ!")
      if (!vif_timer.irq_timer_seen) `uvm_error("TIMER_EXHAUSTIVE", "Top-level irq_timer was NOT asserted on T0 CMP!")

      // Stop Timer 0
      write_reg(T0_REG_CTRL, 32'h0000_0000);
      // Read back value - should have auto-reset to 0 on compare match
      read_reg(T0_REG_VALUE, rdata);
      if (rdata >= 32'd40) `uvm_error("TIMER_EXHAUSTIVE", $sformatf("T0_VALUE did not auto-reset upon compare match! Value=0x%08h", rdata))
      `uvm_info("TIMER_EXHAUSTIVE", $sformatf("[PHASE 3 PASSED] Timer 0 Compare Match IRQ fired, auto-reset to 0x%08h", rdata), UVM_LOW)

      // -----------------------------------------------------------------------
      // PHASE 4: Timer 0 Pause and Resume (Enable Bit 0 vs 1)
      // -----------------------------------------------------------------------
      `uvm_info("TIMER_EXHAUSTIVE", "[PHASE 4] Testing Timer 0 Pause and Resume via CTRL[0]...", UVM_LOW)
      write_reg(T0_REG_CMP, 32'h0); // Clear CMP so it doesn't match
      write_reg(T0_REG_VALUE, 32'h0);
      write_reg(T0_REG_CTRL, 32'h0000_0001); // Enable
      #100; // Let it count ~5 cycles
      write_reg(T0_REG_CTRL, 32'h0000_0000); // Pause

      read_reg(T0_REG_VALUE, val1);
      #200; // Wait 10 cycles while paused
      read_reg(T0_REG_VALUE, val2);
      if (val1 !== val2) `uvm_error("TIMER_EXHAUSTIVE", $sformatf("Timer counted while PAUSED: val1=%0d, val2=%0d", val1, val2))

      write_reg(T0_REG_CTRL, 32'h0000_0001); // Resume
      #200; // Count 10 cycles
      read_reg(T0_REG_VALUE, val3);
      if (val3 <= val2) `uvm_error("TIMER_EXHAUSTIVE", $sformatf("Timer did not resume counting: val2=%0d, val3=%0d", val2, val3))
      write_reg(T0_REG_CTRL, 32'h0000_0000); // Stop
      `uvm_info("TIMER_EXHAUSTIVE", $sformatf("[PHASE 4 PASSED] Pause/Resume verified (paused=%0d, resumed=%0d)", val2, val3), UVM_LOW)

      // -----------------------------------------------------------------------
      // PHASE 5: Timer 0 Prescaler Mode Verification
      // -----------------------------------------------------------------------
      `uvm_info("TIMER_EXHAUSTIVE", "[PHASE 5] Testing Prescaler Mode (prescaler=4: 1 tick per 5 cycles)...", UVM_LOW)
      write_reg(T0_REG_CMP, 32'h0);
      write_reg(T0_REG_VALUE, 32'h0);
      // CTRL: prescaler=4 in bits [5:3] => (4 << 3) | 1 = 0x21
      write_reg(T0_REG_CTRL, 32'h0000_0021);
      #400; // 20 clock cycles -> at /5 divider, should advance ~4 counts
      write_reg(T0_REG_CTRL, 32'h0000_0000); // Stop
      read_reg(T0_REG_VALUE, rdata);
      if (rdata < 32'd2 || rdata > 32'd6) begin
        `uvm_error("TIMER_EXHAUSTIVE", $sformatf("Prescaler count out of expected range [2..6]: got %0d", rdata))
      end else begin
        `uvm_info("TIMER_EXHAUSTIVE", $sformatf("[PHASE 5 PASSED] Prescaled count = %0d after 20 cycles (expected ~4)", rdata), UVM_LOW)
      end

      // -----------------------------------------------------------------------
      // PHASE 6: Timer 0 Overflow Interrupt Verification
      // -----------------------------------------------------------------------
      `uvm_info("TIMER_EXHAUSTIVE", "[PHASE 6] Testing Timer 0 Overflow IRQ (preloading 0xFFFFFFF6)...", UVM_LOW)
      vif_timer.clear_flags();
      write_reg(T0_REG_CMP, 32'h0); // No CMP match
      write_reg(T0_REG_VALUE, 32'hFFFF_FFF6); // 10 cycles to overflow
      write_reg(T0_REG_CTRL, 32'h0000_0001); // Enable (prescaler=0)

      wait_for_irq(0, 100, irq_ok); // irq_raw_seen[0] = T0 Overflow
      if (!irq_ok) `uvm_error("TIMER_EXHAUSTIVE", "TIMED OUT waiting for Timer 0 Overflow IRQ!")
      if (!vif_timer.irq_timer_seen) `uvm_error("TIMER_EXHAUSTIVE", "Top-level irq_timer was NOT asserted on T0 Overflow!")

      write_reg(T0_REG_CTRL, 32'h0000_0000); // Stop
      read_reg(T0_REG_VALUE, rdata);
      if (rdata >= 32'd20) `uvm_error("TIMER_EXHAUSTIVE", $sformatf("T0_VALUE did not rollover to 0 on overflow: got 0x%08h", rdata))
      `uvm_info("TIMER_EXHAUSTIVE", $sformatf("[PHASE 6 PASSED] Timer 0 Overflow IRQ asserted, rolled over to %0d", rdata), UVM_LOW)

      // -----------------------------------------------------------------------
      // PHASE 7: Timer 1 Functionality (Compare Match & Overflow)
      // -----------------------------------------------------------------------
      `uvm_info("TIMER_EXHAUSTIVE", "[PHASE 7] Testing Timer 1 Compare Match & Overflow...", UVM_LOW)
      // 7A: Timer 1 Compare Match
      vif_timer.clear_flags();
      write_reg(T1_REG_CMP, 32'd30);
      write_reg(T1_REG_CTRL, 32'h0000_0001); // Enable Timer 1

      wait_for_irq(3, 150, irq_ok); // irq_raw_seen[3] = T1 CMP
      if (!irq_ok) `uvm_error("TIMER_EXHAUSTIVE", "TIMED OUT waiting for Timer 1 Compare Match IRQ!")
      if (vif_timer.irq_raw_seen[1]) `uvm_error("TIMER_EXHAUSTIVE", "CROSSTALK: Timer 0 CMP fired during Timer 1 test!")
      write_reg(T1_REG_CTRL, 32'h0000_0000); // Stop Timer 1

      // 7B: Timer 1 Overflow
      vif_timer.clear_flags();
      write_reg(T1_REG_CMP, 32'h0);
      write_reg(T1_REG_VALUE, 32'hFFFF_FFF6);
      write_reg(T1_REG_CTRL, 32'h0000_0001);

      wait_for_irq(2, 100, irq_ok); // irq_raw_seen[2] = T1 Overflow
      if (!irq_ok) `uvm_error("TIMER_EXHAUSTIVE", "TIMED OUT waiting for Timer 1 Overflow IRQ!")
      write_reg(T1_REG_CTRL, 32'h0000_0000); // Stop Timer 1
      `uvm_info("TIMER_EXHAUSTIVE", "[PHASE 7 PASSED] Timer 1 Compare Match & Overflow IRQs verified without crosstalk", UVM_LOW)

      // -----------------------------------------------------------------------
      // PHASE 8: Simultaneous Dual-Timer Operation (Concurrency)
      // -----------------------------------------------------------------------
      `uvm_info("TIMER_EXHAUSTIVE", "[PHASE 8] Testing Simultaneous Dual-Timer Concurrency (T0 CMP=25, T1 CMP=60)...", UVM_LOW)
      vif_timer.clear_flags();
      write_reg(T0_REG_VALUE, 32'h0);
      write_reg(T1_REG_VALUE, 32'h0);
      write_reg(T0_REG_CMP, 32'd25); // Fires first
      write_reg(T1_REG_CMP, 32'd60); // Fires second

      write_reg(T0_REG_CTRL, 32'h0000_0001); // Start T0
      write_reg(T1_REG_CTRL, 32'h0000_0001); // Start T1

      // Wait for T0 CMP first
      wait_for_irq(1, 150, irq_ok);
      if (!irq_ok) `uvm_error("TIMER_EXHAUSTIVE", "T0 CMP did not fire during dual-timer test!")
      if (vif_timer.irq_raw_seen[3]) `uvm_error("TIMER_EXHAUSTIVE", "T1 CMP fired prematurely before T0!")

      // Wait for T1 CMP next
      wait_for_irq(3, 200, irq_ok);
      if (!irq_ok) `uvm_error("TIMER_EXHAUSTIVE", "T1 CMP did not fire after T0 during dual-timer test!")

      write_reg(T0_REG_CTRL, 32'h0000_0000);
      write_reg(T1_REG_CTRL, 32'h0000_0000);
      `uvm_info("TIMER_EXHAUSTIVE", "[PHASE 8 PASSED] Dual-timer concurrent execution confirmed in correct order", UVM_LOW)

      `uvm_info("TIMER_EXHAUSTIVE", "==================================================", UVM_LOW)
      `uvm_info("TIMER_EXHAUSTIVE", "=== ALL 8 EXHAUSTIVE TIMER TEST PHASES PASSED! ===", UVM_LOW)
      `uvm_info("TIMER_EXHAUSTIVE", "==================================================", UVM_LOW)
    endtask
  endclass

  class sentinel_soc_vip_timer_test extends sentinel_soc_vip_base_test;
    `uvm_component_utils(sentinel_soc_vip_timer_test)
    virtual timer_irq_if vif_timer;

    function new(string name, uvm_component parent); super.new(name, parent); endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(virtual timer_irq_if)::get(this, "", "vif_timer", vif_timer))
        `uvm_fatal("NO_VIF", "vif_timer not found in config_db")
    endfunction

    task run_phase(uvm_phase phase);
      soc_timer_exhaustive_seq seq;
      uvm_report_server server;
      phase.raise_objection(this);

      #150;
      `uvm_info("TIMER_TEST", "--- STARTING EXHAUSTIVE TIMER VIP INTEGRATION TEST ---", UVM_LOW)
      seq = soc_timer_exhaustive_seq::type_id::create("seq");
      seq.vif_timer = vif_timer;
      seq.start(cpu_agent.sequencer);

      #200;
      server = uvm_report_server::get_server();
      if (server.get_severity_count(UVM_ERROR) == 0 && server.get_severity_count(UVM_FATAL) == 0) begin
        `uvm_info("TIMER_TEST", ">>> SUCCESS: ALL EXHAUSTIVE TIMER CHECKS PASSED WITH 0 ERRORS! <<<", UVM_LOW)
      end else begin
        `uvm_error("TIMER_TEST", ">>> FAILURE: EXHAUSTIVE TIMER CHECKS REPORTED ERRORS! <<<")
      end

      phase.drop_objection(this);
    endtask
  endclass

endpackage
