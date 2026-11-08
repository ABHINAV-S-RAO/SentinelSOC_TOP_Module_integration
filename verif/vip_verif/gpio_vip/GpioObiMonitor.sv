// Completed-transaction OBI monitor (one item per access, with rdata/err).
// Replaces cpu_agent.monitor for GPIO checking: the stock one fires on req&&gnt
// (no read data) and can re-fire if gnt stays high while req is held.
class GpioObiMonitor extends uvm_monitor;
  `uvm_component_utils(GpioObiMonitor)

  virtual obi_if vif;
  uvm_analysis_port #(gpio_obi_txn) ap;

  function new(string name = "GpioObiMonitor", uvm_component parent = null);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual obi_if)::get(this, "", "vif_obi", vif))
      `uvm_fatal("GPIOOBIMON", "cannot get vif_obi from uvm_config_db")
  endfunction

  virtual task run_phase(uvm_phase phase);
    gpio_obi_txn     t;
    bit              pending = 0;
    longint unsigned cyc = 0;
    forever begin
      @(posedge vif.clk_i);
      cyc++;
      if (vif.rst_ni !== 1'b1) begin pending = 0; continue; end
      if (!pending) begin
        if (vif.req === 1'b1 && vif.gnt === 1'b1) begin
          t = gpio_obi_txn::type_id::create("t");
          t.addr  = vif.addr;
          t.we    = vif.we;
          t.be    = vif.be;
          t.wdata = vif.wdata;
          pending = 1;
        end
      end
      else if (vif.rvalid === 1'b1) begin
        t.rdata = vif.rdata;
        t.err   = (vif.err === 1'b1);
        t.cyc   = cyc;
        pending = 0;
        ap.write(t);
      end
    end
  endtask
endclass