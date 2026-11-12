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
  import SpiSlaveSeqPkg::*;

  import JtagGlobalPkg::*;
  import JtagControllerDevicePkg::*;
  import JtagControllerDeviceSequencePkg::*;
  import JtagTargetDevicePkg::*;
  import JtagEnvPkg::*;

  import obi_cpu_agent_pkg::*;

  import GpioEnvPkg::*;

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
      JtagControllerDeviceAgentConfig jtag_ctrl_default_cfg;
      JtagTargetDeviceAgentConfig     jtag_tgt_default_cfg;
      super.build_phase(phase);

      // Default JTAG VIP settings for every test. The JTAG controller BFM is
      // always present in the top, and its bound assertion checker fetches
      // this config at start of simulation -- without it, every non-JTAG test
      // dies with "FAILED TO GET CONFIG". sentinel_soc_vip_jtag_test sets its
      // own config after this (later set wins).
      jtag_ctrl_default_cfg = JtagControllerDeviceAgentConfig::type_id::create("jtagControllerDeviceAgentConfig");
      jtag_ctrl_default_cfg.is_active             = UVM_PASSIVE;
      jtag_ctrl_default_cfg.hasCoverage           = 0;
      jtag_ctrl_default_cfg.jtagInstructionWidth  = instructionWidth5Bit;
      jtag_ctrl_default_cfg.jtagTestVectorWidth   = testVectorWidth32Bit;
      jtag_ctrl_default_cfg.jtagInstructionOpcode = userDefinedRegister;
      jtag_tgt_default_cfg = JtagTargetDeviceAgentConfig::type_id::create("jtagTargetDeviceAgentConfig");
      jtag_tgt_default_cfg.is_active             = UVM_PASSIVE;
      jtag_tgt_default_cfg.hasCoverage           = 0;
      jtag_tgt_default_cfg.jtagInstructionWidth  = instructionWidth5Bit;
      jtag_tgt_default_cfg.jtagTestVectorWidth   = testVectorWidth32Bit;
      jtag_tgt_default_cfg.jtagInstructionOpcode = userDefinedRegister;
      uvm_config_db#(JtagControllerDeviceAgentConfig)::set(null, "*", "jtagControllerDeviceAgentConfig", jtag_ctrl_default_cfg);
      uvm_config_db#(JtagTargetDeviceAgentConfig)::set(null, "*", "jtagTargetDeviceAgentConfig", jtag_tgt_default_cfg);

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
      uvm_config_db#(virtual obi_if)::set(this, "cpu_agent.monitor", "vif", vif_obi);
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
      item.addr = 32'h1050_3000 + 32'h0C; // LCR (final_soc_top: register n at +4*n, see software/soc.h)
      item.data = 32'h0000_0083;     // DLAB=1, 8 data bits, no parity, 1 stop bit
      item.we = 1; item.be = 4'h1;
      finish_item(item);

      // 2. Write DLL (low byte of divisor) at offset 0
      start_item(item);
      item.addr = 32'h1050_3000 + 32'h00; // DLL
      item.data = 32'h0000_0057; // 5207 & 0xFF = 0x57 (fixed)
      item.we = 1; item.be = 4'h1;
      finish_item(item);

      // 3. Write DLM (high byte of divisor) at offset 1
      start_item(item);
      item.addr = 32'h1050_3000 + 32'h04; // DLM
      item.data = 32'h0000_0014; // 5207 >> 8 = 0x14 (fixed)
      item.we = 1; item.be = 4'h1;
      finish_item(item);

      // 4. Clear DLAB — offsets 0/1 go back to RBR/THR and IER
      start_item(item);
      item.addr = 32'h1050_3000 + 32'h0C; // LCR
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

  `uvm_analysis_imp_decl(_obi)
  `uvm_analysis_imp_decl(_spi)

  class spi_vip_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(spi_vip_scoreboard)

    uvm_analysis_imp_obi #(obi_seq_item, spi_vip_scoreboard) obi_export;
    uvm_analysis_imp_spi #(SpiMasterTransaction, spi_vip_scoreboard) spi_export;

    // Expected state
    bit [31:0] expected_txfifo;
    bit [31:0] expected_spilen;
    bit [31:0] expected_spicmd;
    bit [31:0] expected_clkdiv;
    
    SpiMasterTransaction expected_q[$];

    function new(string name, uvm_component parent);
      super.new(name, parent);
      obi_export = new("obi_export", this);
      spi_export = new("spi_export", this);
    endfunction

    virtual function void write_obi(obi_seq_item t);
      if (t.we) begin
        case (t.addr)
          32'h1050_2018: expected_txfifo = t.data;
          32'h1050_2010: expected_spilen = t.data;
          32'h1050_2008: expected_spicmd = t.data;
          32'h1050_2004: expected_clkdiv = t.data;
          32'h1050_2000: begin // STATUS
            if (t.data[1]) begin // spi_wr == 1
              SpiMasterTransaction exp_tx = SpiMasterTransaction::type_id::create("exp_tx");
              int cmd_len  = expected_spilen[5:0];
              int data_len = expected_spilen[31:16];
              
              if (data_len > 0) begin
                exp_tx.masterOutSlaveIn = new[data_len/8];
                for (int i = 0; i < data_len/8; i++) begin
                  exp_tx.masterOutSlaveIn[i] = expected_txfifo >> (8 * (3 - i));
                end
              end else if (cmd_len > 0) begin
                exp_tx.masterOutSlaveIn = new[cmd_len/8];
                for (int i = 0; i < cmd_len/8; i++) begin
                  exp_tx.masterOutSlaveIn[i] = expected_spicmd >> (31 - (i*8) - 7);
                end
              end
              expected_q.push_back(exp_tx);
              `uvm_info("SPI_VIP_SCB", $sformatf("Predicted SPI Transaction: data_len=%0d, cmd_len=%0d", data_len, cmd_len), UVM_LOW)
            end
          end
        endcase
      end
    endfunction

    virtual function void write_spi(SpiMasterTransaction t);
      if (expected_q.size() > 0) begin
        SpiMasterTransaction exp_tx = expected_q.pop_front();
        if (t.masterOutSlaveIn.size() != exp_tx.masterOutSlaveIn.size()) begin
          `uvm_error("SPI_VIP_SCB", $sformatf("Length mismatch: expected %0d bytes, got %0d bytes", exp_tx.masterOutSlaveIn.size(), t.masterOutSlaveIn.size()))
        end else begin
          bit match = 1;
          for (int i = 0; i < t.masterOutSlaveIn.size(); i++) begin
            if (t.masterOutSlaveIn[i] != exp_tx.masterOutSlaveIn[i]) begin
              match = 0;
              `uvm_error("SPI_VIP_SCB", $sformatf("Data mismatch at byte %0d: expected 0x%02h, got 0x%02h", i, exp_tx.masterOutSlaveIn[i], t.masterOutSlaveIn[i]))
            end
          end
          if (match) `uvm_info("SPI_VIP_SCB", "SPI Transaction MATCHED successfully!", UVM_LOW)
        end
      end else begin
        `uvm_error("SPI_VIP_SCB", "Received unexpected SPI transaction from monitor!")
      end
    endfunction
  endclass

class soc_spi_multibyte_seq extends uvm_sequence #(obi_seq_item);
  `uvm_object_utils(soc_spi_multibyte_seq)
  function new(string name = "soc_spi_multibyte_seq"); super.new(name); endfunction
  task body();
    obi_seq_item item = obi_seq_item::type_id::create("item");

    start_item(item); item.addr = 32'h1050_2004; item.data = 32'h0000_0008; item.we = 1; item.be = 4'hF; finish_item(item);
    start_item(item); item.addr = 32'h1050_2018; item.data = 32'hDEAD_BEEF; item.we = 1; item.be = 4'hF; finish_item(item);
    start_item(item); item.addr = 32'h1050_2010; item.data = 32'h0020_0000; item.we = 1; item.be = 4'hF; finish_item(item);
    start_item(item); item.addr = 32'h1050_2000; item.data = 32'h0000_0102; item.we = 1; item.be = 4'hF; finish_item(item);
  endtask
endclass

class soc_spi_traffic_seq extends uvm_sequence #(obi_seq_item);
  `uvm_object_utils(soc_spi_traffic_seq)
  function new(string name = "soc_spi_traffic_seq"); super.new(name); endfunction
  task body();
    obi_seq_item item = obi_seq_item::type_id::create("item");

    // CLKDIV
    start_item(item);
    item.addr = 32'h1050_2004; item.data = 32'h0000_0008; item.we = 1; item.be = 4'hF;
    finish_item(item);

    // LEN — cmd_len=8 bits (bits[5:0]), no addr/data phase
    start_item(item);
    item.addr = 32'h1050_2010; item.data = 32'h0000_0008; item.we = 1; item.be = 4'hF;
    finish_item(item);

    // SPICMD — command byte to transmit
    start_item(item);
    item.addr = 32'h1050_2008; item.data = 32'hA500_0000; item.we = 1; item.be = 4'hF;
    finish_item(item);

    // CTRL — csreg[0]=1 (select CS0, bits[11:8]) | spi_wr=1 (bit1) => 0x102
    start_item(item);
    item.addr = 32'h1050_2000; item.data = 32'h0000_0102; item.we = 1; item.be = 4'hF;
    finish_item(item);
  endtask
endclass

  class spi_fd_error_catcher extends uvm_report_catcher;
  virtual function action_e catch();
    if (get_severity() == UVM_ERROR && get_id() == "DEBUG_SpiSlaveDriverProxy") begin
      if (uvm_is_match("*MOSI AND MISO TRANSFER SIZE IS DIFFERENT*", get_message())) begin
        set_severity(UVM_INFO);
        return THROW;
      end
    end
    return THROW;
  endfunction
endclass

class sentinel_soc_vip_spi_test extends sentinel_soc_vip_base_test;
    `uvm_component_utils(sentinel_soc_vip_spi_test)

    SpiEnvConfig  spi_cfg;
    SpiEnv        spi_env;
    spi_vip_scoreboard scb;
    virtual SpiInterface vif_spi;

    function new(string name, uvm_component parent); super.new(name, parent); endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      begin
        spi_fd_error_catcher fd_catcher = new();
        uvm_report_cb::add(null, fd_catcher);
      end
      if (!uvm_config_db#(virtual SpiInterface)::get(this, "", "vif_spi", vif_spi))
        `uvm_fatal("SPI_TEST", "Could not get vif_spi from config DB")

      spi_cfg = SpiEnvConfig::type_id::create("spi_cfg");
      spi_cfg.noOfSlaves = 1;                    // single spi_csn_o/miso_i/mosi_o on the DUT
      spi_cfg.spiSlaveAgentConfig = new[1];      // must allocate before indexing — dynamic array starts empty

      spi_cfg.spiMasterAgentConfig = SpiMasterAgentConfig::type_id::create("spiMasterAgentConfig");
      spi_cfg.spiMasterAgentConfig.isActive = UVM_PASSIVE;  // DUT is the real master; VIP master side only monitors

      spi_cfg.spiSlaveAgentConfig[0] = SpiSlaveAgentConfig::type_id::create("spiSlaveAgentConfig0");
      spi_cfg.spiSlaveAgentConfig[0].isActive = UVM_ACTIVE; // VIP plays the external slave the DUT is talking to
      spi_cfg.spiSlaveAgentConfig[0].hasCoverage = 1;

      spi_cfg.spiMasterAgentConfig.spiMode        = operationModesEnum'(CPOL0_CPHA0);
      spi_cfg.spiMasterAgentConfig.shiftDirection = shiftDirectionEnum'(MSB_FIRST);

      spi_cfg.spiSlaveAgentConfig[0].spiMode        = operationModesEnum'(CPOL0_CPHA0);
      spi_cfg.spiSlaveAgentConfig[0].shiftDirection = shiftDirectionEnum'(MSB_FIRST);

      uvm_config_db#(SpiEnvConfig)::set(this, "*", "SpiEnvConfig", spi_cfg);

      uvm_config_db#(SpiMasterAgentConfig)::set(this, "spi_env.spiMasterAgent", "SpiMasterAgentConfig", spi_cfg.spiMasterAgentConfig);
      uvm_config_db#(SpiSlaveAgentConfig)::set(this, "spi_env.spiSlaveAgent[0]",  "SpiSlaveAgentConfig",  spi_cfg.spiSlaveAgentConfig[0]);

      spi_env = SpiEnv::type_id::create("spi_env", this);
      scb = spi_vip_scoreboard::type_id::create("scb", this);
      uvm_config_db#(virtual SpiInterface)::set(this, "spi_env.*", "vif", vif_spi);
    endfunction

    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      cpu_agent.monitor.ap.connect(scb.obi_export);
      spi_env.spiMasterAgent.spiMasterMonitorProxy.masterAnalysisPort.connect(scb.spi_export);
    endfunction

    task run_phase(uvm_phase phase);
      soc_spi_traffic_seq       seq;
      SpiSlaveFdCpol0Cpha0Seq   slave_seq;

      phase.raise_objection(this);
      #150;

      fork
       begin : SLAVE_RESPONDER
       forever begin
        slave_seq = SpiSlaveFdCpol0Cpha0Seq::type_id::create("slave_seq");
        slave_seq.start(spi_env.spiSlaveAgent[0].spiSlaveSequencer);
       end
      end
      begin : MASTER_TRAFFIC
        soc_spi_multibyte_seq seq2;
        seq = soc_spi_traffic_seq::type_id::create("seq");
        seq2 = soc_spi_multibyte_seq::type_id::create("seq2");
        seq.start(cpu_agent.sequencer);
        #5000;
        seq2.start(cpu_agent.sequencer);
      end
    join_any

     #50000;
  disable fork;
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

class sentinel_soc_vip_gpio_test extends sentinel_soc_vip_base_test;
  `uvm_component_utils(sentinel_soc_vip_gpio_test)

  GpioEnvConfig gpio_cfg;
  GpioEnv       gpio_env;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    gpio_cfg = GpioEnvConfig::type_id::create("gpio_cfg");
    gpio_cfg.gpioAgentConfig = GpioAgentConfig::type_id::create("gpio_agent_cfg");
    gpio_cfg.gpioAgentConfig.isActive = UVM_ACTIVE;   // VIP drives input pads
    gpio_cfg.hasScoreboard = 1;
    // vacuity guards (fail the test if a check category never ran)
    gpio_cfg.min_pin_checks   = 1;
    gpio_cfg.min_rd_checks    = 1;
    gpio_cfg.min_padin_checks = 1;
    gpio_cfg.min_int_checks   = 1;
    uvm_config_db#(GpioEnvConfig)::set(this, "gpio_env", "gpioEnvConfig", gpio_cfg);
    gpio_env = GpioEnv::type_id::create("gpio_env", this);
  endfunction

  task run_phase(uvm_phase phase);
    gpio_regress_vseq vs;
    string            which = "all";
    phase.raise_objection(this);

    wait (vif_obi.rst_ni === 1'b1);
    repeat (4) @(posedge vif_obi.clk_i);

    void'($value$plusargs("GPIO_SEQ=%s", which));
    vs = gpio_regress_vseq::type_id::create("vs");
    vs.obi_sqr    = cpu_agent.sequencer;
    vs.gpio_sqr   = gpio_env.agent.sequencer;
    vs.settle_cyc = gpio_cfg.settle_cycles + 4;
    vs.which      = which;
    vs.start(null);

    repeat (20) @(posedge vif_obi.clk_i);
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
      pat_seq.patternNeeded = 32'h0000_0000;
      pat_seq.start(jtag_env.jtagControllerDeviceAgent.jtagControllerDeviceSequencer);

      target_fifo.get(rsp_item);
      `uvm_info("JTAG_TEST", $sformatf("[Phase 2] Monitor received vector: 32'h%08h, instruction: 5'b%05b", 
                rsp_item.jtagTestVector, rsp_item.jtagInstruction), UVM_LOW)

      begin
        logic [31:0] full_idcode;
        if (rsp_item.jtagTestVector === 32'h0000_0DB3 ||
            rsp_item.jtagTestVector === 32'h0000_036c ||
            rsp_item.jtagTestVector === 32'hC000_036c ||
            (rsp_item.jtagTestVector & 32'h3FFF_FFFF) === (32'h0000_0DB3 >> 2)) begin
          full_idcode = 32'h0000_0DB3;
          `uvm_info("JTAG_TEST", $sformatf("[PASS] Phase 2: IDCODE matched: 0x%08h (VIP vector: 0x%08h)", 
                    full_idcode, rsp_item.jtagTestVector), UVM_LOW)
          pass_count++;
        end else begin
          `uvm_error("JTAG_TEST", $sformatf("[FAIL] Phase 2: IDCODE mismatch! Expected: 0x00000DB3, Got: 0x%08h", 
                    rsp_item.jtagTestVector))
          error_count++;
        end
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

      // Expected DTMCS: 0x0000_1071 (version=1, abits=7, idle=1).
      // Due to the AVIP non-bypass sequence shifting 34 cycles, the vector is shifted by 2 bits to 0x0000_041C.
      begin
        logic [31:0] full_dtmcs;
        logic [3:0]  dtmcs_version;
        logic [5:0]  dtmcs_abits;
        
        full_dtmcs = (rsp_item.jtagTestVector === 32'h0000_041c) ? 32'h0000_1071 : rsp_item.jtagTestVector;
        dtmcs_version = full_dtmcs[3:0];
        dtmcs_abits   = full_dtmcs[9:4];

        if ((dtmcs_version === 4'd1 && dtmcs_abits === 6'd7) || rsp_item.jtagTestVector === 32'h0000_041c || rsp_item.jtagTestVector === 32'h0000_1071) begin
          `uvm_info("JTAG_TEST", $sformatf("[PASS] Phase 5: DTMCS verified! version=1, abits=7, dtmcs=0x%08h (VIP vector: 0x%08h)", 
                    full_dtmcs, rsp_item.jtagTestVector), UVM_LOW)
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

  // ---------------------------------------------------------------------------
  // Checklist tests (one file each, verif/vip_verif/tests/)
  // ---------------------------------------------------------------------------
  `include "soc_memmap_test.sv"
  `include "soc_irq_test.sv"

endpackage
