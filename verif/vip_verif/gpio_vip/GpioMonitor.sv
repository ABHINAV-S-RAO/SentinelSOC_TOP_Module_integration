// Samples pins + VIP drive state EVERY clock (so the scoreboard is cycle-driven
// and cannot go silent just because a pin never toggled).
class GpioMonitor extends uvm_monitor;
  `uvm_component_utils(GpioMonitor)

  virtual gpio_if vif;
  uvm_analysis_port #(gpio_mon_txn) ap;

  function new(string name = "GpioMonitor", uvm_component parent = null);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual gpio_if)::get(this, "", "vif_gpio", vif))
      `uvm_fatal("GPIOMON", "cannot get vif_gpio from uvm_config_db")
  endfunction

  virtual task run_phase(uvm_phase phase);
    gpio_mon_txn     t;
    longint unsigned cyc = 0;   // counts from time 0, same as GpioObiMonitor
    forever begin
      @(posedge vif.clk_i);
      cyc++;
      if (vif.rst_ni !== 1'b1) continue;
      t = gpio_mon_txn::type_id::create("t");
      t.pins    = vif.gpio_pins;
      t.vip_en  = vif.drv_en;
      t.vip_val = vif.drv_val;
      t.cyc     = cyc;
      ap.write(t);
    end
  endtask
endclass