// =============================================================================
// uart_agent.sv
// UVM agent: bundles driver + monitor + sequencer for the UART interface.
// =============================================================================

class uart_agent extends uvm_agent;
  `uvm_component_utils(uart_agent)

  uart_driver    driver;
  uart_monitor   monitor;
  uvm_sequencer #(uart_seq_item) sequencer;

  // Analysis port forwarded from monitor — connect to scoreboard
  uvm_analysis_port #(uart_seq_item) ap;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    monitor   = uart_monitor::type_id::create("monitor", this);
    ap        = new("ap", this);
    if (is_active == UVM_ACTIVE) begin
      driver    = uart_driver::type_id::create("driver", this);
      sequencer = uvm_sequencer #(uart_seq_item)::type_id::create("sequencer", this);
    end
  endfunction

  function void connect_phase(uvm_phase phase);
    if (is_active == UVM_ACTIVE)
      driver.seq_item_port.connect(sequencer.seq_item_export);
    monitor.ap.connect(ap);
  endfunction

endclass : uart_agent
