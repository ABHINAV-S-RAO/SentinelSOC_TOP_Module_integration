`ifndef APB_PERIPH_MONITOR_SV
`define APB_PERIPH_MONITOR_SV

// Generic APB monitor. One instance per peripheral, distinguished by
// `psel_name` (a string set via config_db, used only for reporting/coverage
// labels — the actual PSEL line is whichever one is wired to `vif`).
// Fires an apb_txn on every completed SETUP->ACCESS handshake
// (PSEL & PENABLE & PREADY), including PSLVERR so illegal-address /
// unmapped-region accesses show up as transactions, not silence.

class apb_txn extends uvm_sequence_item;
  `uvm_object_utils(apb_txn)
  string        periph;
  bit           write;
  bit [31:0]    paddr;
  bit [31:0]    pdata;   // pwdata if write, prdata if read
  bit           pslverr;
  time          t;

  function new(string name = "apb_txn");
    super.new(name);
  endfunction
endclass

class apb_periph_monitor extends uvm_monitor;
  `uvm_component_utils(apb_periph_monitor)

  virtual apb_if vif;  // expects: pclk, presetn, psel, penable, pwrite, paddr, pwdata, prdata, pready, pslverr
  uvm_analysis_port #(apb_txn) ap;
  string periph_name;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual apb_if)::get(this, "", "apb_vif", vif))
      `uvm_fatal("APB_MON", "vif not set")
    if (!uvm_config_db#(string)::get(this, "", "periph_name", periph_name))
      periph_name = "UNKNOWN";
  endfunction

  task run_phase(uvm_phase phase);
    apb_txn t;
    forever begin
      @(posedge vif.pclk);
      if (vif.presetn && vif.psel && vif.penable && vif.pready) begin
        t = apb_txn::type_id::create("t");
        t.periph  = periph_name;
        t.write   = vif.pwrite;
        t.paddr   = vif.paddr;
        t.pdata   = vif.pwrite ? vif.pwdata : vif.prdata;
        t.pslverr = vif.pslverr;
        t.t       = $time;
        ap.write(t);
      end
    end
  endtask

endclass

`endif