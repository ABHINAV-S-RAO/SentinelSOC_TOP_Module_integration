`ifndef GPIOAGENTCONFIG_INCLUDED_
`define GPIOAGENTCONFIG_INCLUDED_

class GpioAgentConfig extends uvm_object;
  `uvm_object_utils(GpioAgentConfig)

  // UVM_PASSIVE (default): monitor only — use this for testing DUT-driven
  // output pads (PADDIR=1), which is all soc_gpio_padout_seq covers today.
  // UVM_ACTIVE: also builds a driver/sequencer, for exercising input-
  // configured pads (PADDIR=0) by driving gpio_pins externally.
  uvm_active_passive_enum isActive = UVM_PASSIVE;

  extern function new(string name = "GpioAgentConfig");
endclass

function GpioAgentConfig::new(string name = "GpioAgentConfig");
  super.new(name);
endfunction

`endif

`ifndef GPIOENVCONFIG_INCLUDED_
`define GPIOENVCONFIG_INCLUDED_

class GpioEnvConfig extends uvm_object;
  `uvm_object_utils(GpioEnvConfig)

  bit hasScoreboard = 1;
  GpioAgentConfig gpioAgentConfig;

  extern function new(string name = "GpioEnvConfig");
endclass

function GpioEnvConfig::new(string name = "GpioEnvConfig");
  super.new(name);
endfunction

`endif