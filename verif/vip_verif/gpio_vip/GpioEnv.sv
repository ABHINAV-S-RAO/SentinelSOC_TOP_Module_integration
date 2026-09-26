class GpioEnv extends uvm_env;
  `uvm_component_utils(GpioEnv)

  GpioEnvConfig  cfg;
  GpioAgent      agent;
  GpioScoreboard scoreboard;

  function new(string name = "GpioEnv", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(GpioEnvConfig)::get(this, "", "gpioEnvConfig", cfg))
      `uvm_fatal("GPIOENV", "cannot get gpioEnvConfig from uvm_config_db")

    uvm_config_db#(GpioAgentConfig)::set(this, "agent", "gpioAgentConfig",
                                          cfg.gpioAgentConfig);
    agent = GpioAgent::type_id::create("agent", this);

    if (cfg.hasScoreboard)
      scoreboard = GpioScoreboard::type_id::create("scoreboard", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (cfg.hasScoreboard)
      agent.monitor.ap.connect(scoreboard.gpio_export);
      // NOTE: scoreboard.obi_export still needs connecting to whatever
      // analysis port cpu_agent's OBI monitor exposes — name/hierarchy not
      // yet confirmed (see obi_cpu_agent_pkg.sv). Without this connection
      // dir_valid/out_valid never go high and write_gpio() is a no-op.
  endfunction
endclass


