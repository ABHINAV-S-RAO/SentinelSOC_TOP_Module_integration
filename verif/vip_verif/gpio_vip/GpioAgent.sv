class GpioAgent extends uvm_agent;
  `uvm_component_utils(GpioAgent)

  GpioAgentConfig cfg;
  GpioMonitor     monitor;
  GpioDriver      driver;
  uvm_sequencer #(gpio_pin_txn) sequencer;

  function new(string name = "GpioAgent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(GpioAgentConfig)::get(this, "", "gpioAgentConfig", cfg))
      `uvm_fatal("GPIOAGT", "cannot get gpioAgentConfig from uvm_config_db")

    monitor = GpioMonitor::type_id::create("monitor", this);

    if (cfg.isActive == UVM_ACTIVE) begin
      driver    = GpioDriver::type_id::create("driver", this);
      sequencer = uvm_sequencer#(gpio_pin_txn)::type_id::create("sequencer", this);
    end
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (cfg.isActive == UVM_ACTIVE)
      driver.seq_item_port.connect(sequencer.seq_item_export);
  endfunction
endclass