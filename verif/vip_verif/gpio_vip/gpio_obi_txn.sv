// Completed OBI transaction (request + response) seen by GpioObiMonitor.
class gpio_obi_txn extends uvm_sequence_item;
  bit [31:0]       addr;
  bit [31:0]       wdata;
  logic [31:0]     rdata;   // logic: keep X visible
  bit              we;
  bit [3:0]        be;
  bit              err;
  longint unsigned cyc;     // cycle of rvalid
  `uvm_object_utils(gpio_obi_txn)
  function new(string name = "gpio_obi_txn");
    super.new(name);
  endfunction
endclass