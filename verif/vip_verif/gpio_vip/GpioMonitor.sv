class GpioMonitor extends uvm_monitor;
  `uvm_component_utils(GpioMonitor)

  virtual gpio_if vif;
  uvm_analysis_port #(gpio_pin_txn) ap;

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
    gpio_pin_txn sampled;
    @(posedge vif.rst_ni);
    forever begin
      @(posedge vif.clk_i);
      sampled = gpio_pin_txn::type_id::create("sampled");
      // Bits neither the DUT (PADDIR=0) nor the driver (drv_en=0) are
      // driving read back as X here — that's real floating-bus behavior,
      // not a bug, since apb_gpio's gpio_in_sync port is left unconnected
      // (no synchronizer in the actual datapath).
      sampled.drv_val = vif.gpio_pins;
      ap.write(sampled);
    end
  endtask
endclass