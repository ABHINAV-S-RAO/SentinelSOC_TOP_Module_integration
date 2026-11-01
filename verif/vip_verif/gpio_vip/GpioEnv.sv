class GpioEnv extends uvm_env;
  `uvm_component_utils(GpioEnv)

  GpioEnvConfig  cfg;
  GpioAgent      agent;
  GpioObiMonitor obi_mon;
  GpioScoreboard scoreboard;

  function new(string name = "GpioEnv", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(GpioEnvConfig)::get(this, "", "gpioEnvConfig", cfg))
      `uvm_fatal("GPIOENV", "cannot get gpioEnvConfig from uvm_config_db")

    uvm_config_db#(GpioAgentConfig)::set(this, "agent", "gpioAgentConfig", cfg.gpioAgentConfig);
    agent = GpioAgent::type_id::create("agent", this);

    if (cfg.hasScoreboard) begin
      uvm_config_db#(GpioEnvConfig)::set(this, "scoreboard", "gpioEnvConfig", cfg);
      obi_mon    = GpioObiMonitor::type_id::create("obi_mon", this);
      scoreboard = GpioScoreboard::type_id::create("scoreboard", this);
    end
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (cfg.hasScoreboard) begin
      agent.monitor.ap.connect(scoreboard.gmon_export);
      obi_mon.ap.connect(scoreboard.gobi_export);
    end
  endfunction
endclass