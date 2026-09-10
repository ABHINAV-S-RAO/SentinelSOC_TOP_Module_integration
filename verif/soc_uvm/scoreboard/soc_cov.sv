    `ifndef SOC_COV_SV
`define SOC_COV_SV

import uvm_pkg::*;
`include "uvm_macros.svh"

class soc_cov extends uvm_subscriber #(obi_seq_item);
  `uvm_component_utils(soc_cov)

  obi_seq_item sampled_item;

  covergroup soc_mem_cg;
    option.per_instance = 1;

    // Cover accesses across the SoC Address Map
    cp_addr: coverpoint sampled_item.addr {
      bins bootrom      = {[32'h0000_0000 : 32'h0000_FFFF]};
      bins isram        = {[32'h0001_0000 : 32'h0001_FFFF]};
      bins dsram        = {[32'h0002_0000 : 32'h0002_FFFF]};
      bins sys_ctrl     = {[32'h1000_0000 : 32'h1000_0FFF]};
      bins crypto_sram  = {[32'h2000_0000 : 32'h2000_3FFF]};
      bins sha512       = {[32'h2000_4000 : 32'h2000_4FFF]};
      bins plic         = {[32'h3000_0000 : 32'h3000_FFFF]};
      bins apb_periph   = {[32'h4000_0000 : 32'h4000_FFFF]};
    }

    // Cover Read vs Write Operations
    cp_op: coverpoint sampled_item.we {
      bins read_op  = {OBI_READ};
      bins write_op = {OBI_WRITE};
    }

    // Cross address space accesses with Read/Write direction
    cross_addr_x_op: cross cp_addr, cp_op;
  endgroup

  function new(string name, uvm_component parent);
    super.new(name, parent);
    soc_mem_cg = new();
  endfunction

  function void write(obi_seq_item t);
    sampled_item = t;
    soc_mem_cg.sample();
  endfunction
endclass

`endif