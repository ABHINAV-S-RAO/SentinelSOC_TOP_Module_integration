`ifndef DIFT_TAG_MONITOR_SV
`define DIFT_TAG_MONITOR_SV

class dift_event extends uvm_sequence_item;
  `uvm_object_utils(dift_event)
  bit [4:0]  rf_addr;
  bit        tag_in;
  bit        we;
  bit        is_load;
  bit        exception;
  bit [31:0] exception_pc;
  time       t;

  function new(string name = "dift_event");
    super.new(name);
  endfunction
endclass

class dift_tag_monitor extends uvm_monitor;
  `uvm_component_utils(dift_tag_monitor)

  virtual dift_if vif;
  // expects: clk, rf_waddr, rf_we_tag_lsu, rf_wdata_tag_lsu, is_load,
  //          dift_exception_o, exception_pc
  uvm_analysis_port #(dift_event) ap;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual dift_if)::get(this, "", "vif", vif))
      `uvm_fatal("DIFT_MON", "vif not set")
  endfunction

  task run_phase(uvm_phase phase);
    dift_event e;
    forever begin
      @(posedge vif.clk);
      if (vif.rf_we_tag_lsu || vif.dift_exception_o) begin
        e = dift_event::type_id::create("e");
        e.rf_addr      = vif.rf_waddr;
        e.tag_in       = vif.rf_wdata_tag_lsu;
        e.we           = vif.rf_we_tag_lsu;
        e.is_load      = vif.is_load;
        e.exception    = vif.dift_exception_o;
        e.exception_pc = vif.exception_pc;
        e.t            = $time;
        ap.write(e);
      end
    end
  endtask

endclass

`endif