`ifndef GPIO_PIN_TXN_SV
`define GPIO_PIN_TXN_SV

// Driver stimulus item. The driver applies drv_en/drv_val, waits hold_cycles,
// and then LEAVES the value applied (it no longer auto-releases).
// To release the pins send an item with drv_en = 0.
class gpio_pin_txn extends uvm_sequence_item;
  rand bit [31:0]   drv_en;
  rand logic [31:0] drv_val;
  rand int unsigned hold_cycles;

  constraint c_hold { hold_cycles inside {[1:1000]}; }

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