// Per-cycle sample from GpioMonitor (pins + what the VIP is driving).
class gpio_mon_txn extends uvm_sequence_item;
  logic [31:0]     pins;
  logic [31:0]     vip_en;
  logic [31:0]     vip_val;
  longint unsigned cyc;
  `uvm_object_utils(gpio_mon_txn)
  function new(string name = "gpio_mon_txn");
    super.new(name);
  endfunction
endclass