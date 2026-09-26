`ifndef GPIO_PIN_TXN_SV
`define GPIO_PIN_TXN_SV

// Dual-purpose: as a driver stimulus item, drv_en/drv_val/hold_cycles are
// meaningful. As a monitor sample, only drv_val is populated (holds the
// sampled gpio_pins value) and hold_cycles/drv_en are unused — kept as one
// class rather than two so the monitor's analysis_port and the driver's
// sequencer share a type. Split into separate classes if that gets confusing.
class gpio_pin_txn extends uvm_sequence_item;
  rand bit [31:0] drv_en;
  rand bit [31:0] drv_val;
  rand int unsigned hold_cycles;

  constraint c_hold { hold_cycles inside {[2:20]}; }

  `uvm_object_utils_begin(gpio_pin_txn)
    `uvm_field_int(drv_en, UVM_ALL_ON)
    `uvm_field_int(drv_val, UVM_ALL_ON)
    `uvm_field_int(hold_cycles, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "gpio_pin_txn");
    super.new(name);
  endfunction
endclass

`endif