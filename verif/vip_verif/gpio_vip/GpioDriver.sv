class GpioDriver extends uvm_driver #(gpio_pin_txn);
  `uvm_component_utils(GpioDriver)

  virtual gpio_if vif;

  function new(string name = "GpioDriver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual gpio_if)::get(this, "", "vif_gpio", vif))
      `uvm_fatal("GPIODRV", "cannot get vif_gpio from uvm_config_db")
  endfunction

  virtual task run_phase(uvm_phase phase);
    gpio_pin_txn req;
    vif.drv_en  = '0;
    vif.drv_val = '0;
    forever begin
      seq_item_port.get_next_item(req);
      vif.drv_en  = req.drv_en;
      vif.drv_val = req.drv_val;
      repeat (req.hold_cycles) @(posedge vif.clk_i);
      // Release afterward — only ever drive bits the test explicitly wants
      // driven, since a bit left drv_en=1 while the DUT later configures
      // that same pad as PADDIR=1 (output) would contend the bus.
      vif.drv_en = '0;
      seq_item_port.item_done();
    end
  endtask
endclass