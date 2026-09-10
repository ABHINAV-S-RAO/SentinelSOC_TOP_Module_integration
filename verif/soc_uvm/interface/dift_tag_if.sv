`ifndef DIFT_TAG_IF_SV
`define DIFT_TAG_IF_SV

`timescale 1ns/1ps

interface dift_tag_if (
  input logic clk_i,
  input logic rst_ni
);
  logic        tag_req;
  logic        tag_we;
  logic [31:0] tag_addr;
  logic [31:0] tag_wdata;
  logic [31:0] tag_rdata;
  logic        irq_dift;

  clocking cb @(posedge clk_i);
    default input #1ps output #1ns;
    input tag_req, tag_we, tag_addr, tag_wdata, tag_rdata, irq_dift;
  endclocking

endinterface : dift_tag_if

`endif