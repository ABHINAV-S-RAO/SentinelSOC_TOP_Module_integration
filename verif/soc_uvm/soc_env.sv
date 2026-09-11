`ifndef SOC_ENV_SV
`define SOC_ENV_SV

class soc_env extends uvm_env;
  `uvm_component_utils(soc_env)

  obi_monitor            instr_mon;
  obi_monitor            data_mon;
  qspi_protocol_monitor  qspi_mon;
  apb_periph_monitor     apb_mon_uart;
  apb_periph_monitor     apb_mon_qspi;
  apb_periph_monitor     apb_mon_sysctrl;
  addr_decode_monitor    addr_mon;
  dift_tag_monitor       dift_mon;
  soc_scoreboard         scb;
  soc_coverage           cov;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // instr_mon/data_mon: raw OBI trace only (OBI_MON debug prints), no
    // scoreboard consumer exists for these — soc_scoreboard checks via
    // qspi/apb/addr/dift events instead. Kept for execution-visibility only.
    uvm_config_db#(string)::set(this, "instr_mon", "vif_name", "instr_obi_vif");
    uvm_config_db#(string)::set(this, "data_mon",  "vif_name", "data_obi_vif");

    instr_mon       = obi_monitor::type_id::create("instr_mon", this);
    data_mon        = obi_monitor::type_id::create("data_mon", this);
    qspi_mon        = qspi_protocol_monitor::type_id::create("qspi_mon", this);
    addr_mon        = addr_decode_monitor::type_id::create("addr_mon", this);
    dift_mon        = dift_tag_monitor::type_id::create("dift_mon", this);
    scb             = soc_scoreboard::type_id::create("scb", this);
    cov             = soc_coverage::type_id::create("cov", this);

    apb_mon_uart    = apb_periph_monitor::type_id::create("apb_mon_uart", this);
    apb_mon_qspi    = apb_periph_monitor::type_id::create("apb_mon_qspi", this);
    apb_mon_sysctrl = apb_periph_monitor::type_id::create("apb_mon_sysctrl", this);
    uvm_config_db#(string)::set(this, "apb_mon_uart",    "periph_name", "UART");
    uvm_config_db#(string)::set(this, "apb_mon_qspi",    "periph_name", "QSPI");
    uvm_config_db#(string)::set(this, "apb_mon_sysctrl", "periph_name", "SYS_CTRL");
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    // instr_mon/data_mon intentionally left unconnected — debug trace only.
    qspi_mon.ap.connect(scb.qspi_export);
    qspi_mon.ap.connect(cov.qspi_imp);
    addr_mon.ap.connect(scb.addr_export);
    addr_mon.ap.connect(cov.addr_imp);
    dift_mon.ap.connect(scb.dift_export);
    dift_mon.ap.connect(cov.dift_imp);
    apb_mon_uart.ap.connect(scb.apb_export);
    apb_mon_uart.ap.connect(cov.apb_imp);
    apb_mon_qspi.ap.connect(scb.apb_export);
    apb_mon_sysctrl.ap.connect(scb.apb_export);
  endfunction

endclass

`endif