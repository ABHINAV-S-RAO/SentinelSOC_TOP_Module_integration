`ifndef SOC_ENV_SV
`define SOC_ENV_SV

// Wires monitors -> scoreboard + coverage. sw_status_monitor.sv and
// soc_addr_decode's virtual interfaces are assumed already bound in
// soc_tb_top.sv (per session notes) — this env only ADDS the four new
// monitors and the scoreboard/coverage upgrade, it doesn't replace your
// existing objection-drop flow.
//
// vif binding: qspi_if / apb_if / addr_decode_if / dift_if are thin
// interfaces you'll need to declare and instantiate in soc_tb_top.sv,
// wired to the actual DUT nets (spi_*, paddr/psel_* per peripheral,
// soc_addr_decode's select outputs, and the DIFT tag path signals flagged
// as currently-unwired in the session notes — that wiring gap has to close
// before dift_tag_monitor sees anything but zeros).

class soc_env extends uvm_env;
  `uvm_component_utils(soc_env)

  qspi_protocol_monitor qspi_mon;
  apb_periph_monitor    apb_mon_uart;
  apb_periph_monitor    apb_mon_qspi;
  apb_periph_monitor    apb_mon_sysctrl;
  addr_decode_monitor   addr_mon;
  dift_tag_monitor      dift_mon;
  soc_scoreboard        scb;
  soc_coverage          cov;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
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