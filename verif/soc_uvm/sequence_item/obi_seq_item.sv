`ifndef OBI_SEQ_ITEM_SV
`define OBI_SEQ_ITEM_SV

import uvm_pkg::*;
`include "uvm_macros.svh"

typedef enum bit {
  OBI_READ  = 1'b0,
  OBI_WRITE = 1'b1
} obi_trans_kind_e;

class obi_seq_item extends uvm_sequence_item;
  rand bit [31:0]       addr;
  rand bit [31:0]       wdata;
  rand bit [31:0]       rdata;
  rand bit [3:0]        be;
  rand obi_trans_kind_e we;
  rand bit              err;

  `uvm_object_utils_begin(obi_seq_item)
    `uvm_field_int(addr, UVM_ALL_ON)
    `uvm_field_int(wdata, UVM_ALL_ON)
    `uvm_field_int(rdata, UVM_ALL_ON)
    `uvm_field_int(be, UVM_ALL_ON)
    `uvm_field_enum(obi_trans_kind_e, we, UVM_ALL_ON)
    `uvm_field_int(err, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "obi_seq_item");
    super.new(name);
  endfunction
endclass

`endif