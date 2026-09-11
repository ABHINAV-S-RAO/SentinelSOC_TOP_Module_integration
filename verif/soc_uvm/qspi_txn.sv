`ifndef QSPI_TXN_SV
`define QSPI_TXN_SV

class qspi_txn extends uvm_sequence_item;
  `uvm_object_utils(qspi_txn)

  rand bit [1:0]  mode;         // 2'b00: STD, 2'b01: QUAD_TX, 2'b10: QUAD_RX
  rand bit [7:0]  cmd;
  rand bit [31:0] addr;
  rand int        dummy_cycles;
  rand byte       data[$];
  time            t_cs_fall;
  time            t_cs_rise;

  function new(string name = "qspi_txn");
    super.new(name);
  endfunction
endclass

`endif