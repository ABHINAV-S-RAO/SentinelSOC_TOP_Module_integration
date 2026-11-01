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
  logic [31:0] prev_pins = 32'hx; // Initialize to x to force first broadcast
  
  @(posedge vif.rst_ni);
  forever begin
    @(posedge vif.clk_i);
    
    // Only broadcast to the scoreboard if the physical pins have actually toggled
    if (vif.gpio_pins !== prev_pins) begin
      sampled = gpio_pin_txn::type_id::create("sampled");
      sampled.drv_val = vif.gpio_pins;
      ap.write(sampled);
      prev_pins = vif.gpio_pins;
    end
  end
endtask
endclass