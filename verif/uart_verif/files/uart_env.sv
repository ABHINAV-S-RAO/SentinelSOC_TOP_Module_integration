// =============================================================================
// uart_env.sv
// UVM environment: instantiates agent + scoreboard + coverage, wires them up.
// =============================================================================

class uart_env extends uvm_env;
  `uvm_component_utils(uart_env)

  uart_agent       agent;
  uart_scoreboard  scoreboard;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent      = uart_agent::type_id::create("agent", this);
    scoreboard = uart_scoreboard::type_id::create("scoreboard", this);
    // Active agent: drives + monitors
    agent.is_active = UVM_ACTIVE;
  endfunction

  function void connect_phase(uvm_phase phase);
    // Monitor analysis port → scoreboard RX export
    agent.ap.connect(scoreboard.rx_export);
    // NOTE: TX export (bytes we sent) must be connected by sequences
    // or via a second monitor if you want full duplex tracking.
    // For echo mode the scoreboard uses expect_echo() called from sequences.
  endfunction

endclass : uart_env
