`ifndef GPIOAGENTCONFIG_INCLUDED_
`define GPIOAGENTCONFIG_INCLUDED_

class GpioAgentConfig extends uvm_object;
  `uvm_object_utils(GpioAgentConfig)
  // UVM_ACTIVE needed for input-pad / PADIN / interrupt tests.
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

  // ---- scoreboard knobs ----
  // Cycles after any stimulus (reg write / VIP drive) before pins/PADIN/INTSTATUS are checked.
  int unsigned settle_cycles       = 6;
  // Expect pad = Z on enabled pins with PADDIR=0 and VIP not driving.
  bit          check_hiz_on_input  = 1;
  // PADIN (and interrupt edges) also reflect pins configured as outputs.   (PULP behaviour)
  bit          padin_sees_outputs  = 1;
  bit          model_intstatus     = 1;
  bit          intstatus_clr_on_rd = 1;   // confirmed in apb_gpio.sv
  // apb_gpio drives gpio_out/gpio_dir with NO GPIOEN gating. Set to 1 only if your
  // top-level pad wrapper gates the pad with GPIOEN (then disabled pins are not checked).
  bit          gpioen_gates_output = 0;

  // ---- vacuity guard: report_phase errors if fewer checks than this actually ran ----
  int unsigned min_pin_checks   = 1;
  int unsigned min_rd_checks    = 1;
  int unsigned min_padin_checks = 0;
  int unsigned min_int_checks   = 0;

  extern function new(string name = "GpioEnvConfig");
endclass

function GpioEnvConfig::new(string name = "GpioEnvConfig");
  super.new(name);
endfunction

`endif