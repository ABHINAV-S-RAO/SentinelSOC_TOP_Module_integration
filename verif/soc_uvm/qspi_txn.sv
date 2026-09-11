`ifndef QSPI_TXN_SV
`define QSPI_TXN_SV

class qspi_txn extends uvm_sequence_item;
  rand bit [7:0]   opcode;
  rand bit [23:0]  address;
  rand bit [31:0]  data[$];
  rand bit [1:0]   bus_mode;     // 2'b00: Single SPI, 2'b01: Dual SPI, 2'b10: Quad SPI
  rand bit [2:0]   clk_divider;  // Prescaler setting

  `uvm_object_utils_begin(qspi_txn)
    `uvm_field_int(opcode,      UVM_DEFAULT)
    `uvm_field_int(address,     UVM_DEFAULT)
    `uvm_field_queue_int(data,  UVM_DEFAULT)
    `uvm_field_int(bus_mode,    UVM_DEFAULT)
    `uvm_field_int(clk_divider, UVM_DEFAULT)
  `uvm_object_utils_end

  function new(string name = "qspi_txn");
    super.new(name);
  endfunction
endclass

`endif