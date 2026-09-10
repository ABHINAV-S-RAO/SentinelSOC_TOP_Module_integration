`ifndef DIFT_TAG_SEQ_ITEM_SV
`define DIFT_TAG_SEQ_ITEM_SV

import uvm_pkg::*;
`include "uvm_macros.svh"

class dift_tag_seq_item extends uvm_sequence_item;
  rand bit [31:0] tag_addr;
  rand bit [31:0] tag_wdata;
  rand bit [31:0] tag_rdata;
  rand bit        tag_we;
  rand bit        irq_dift;

  `uvm_object_utils_begin(dift_tag_seq_item)
    `uvm_field_int(tag_addr, UVM_ALL_ON)
    `uvm_field_int(tag_wdata, UVM_ALL_ON)
    `uvm_field_int(tag_rdata, UVM_ALL_ON)
    `uvm_field_int(tag_we, UVM_ALL_ON)
    `uvm_field_int(irq_dift, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "dift_tag_seq_item");
    super.new(name);
  endfunction
endclass

`endif