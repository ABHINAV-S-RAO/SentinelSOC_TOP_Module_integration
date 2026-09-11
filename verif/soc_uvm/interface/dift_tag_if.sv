`ifndef DIFT_TAG_IF_SV
`define DIFT_TAG_IF_SV

interface dift_tag_if (
  input logic clk_i,
  input logic rst_ni
);
  logic        clk;
  logic        rf_we_tag_lsu;
  logic        dift_exception_o;
  logic [4:0]  rf_waddr;
  logic        rf_wdata_tag_lsu;
  logic        is_load;
  logic [31:0] exception_pc;

  // Probes/tag signals
  logic        tag_req;
  logic        tag_we;
  logic [31:0] tag_addr;
  logic [31:0] tag_wdata;
  logic [31:0] tag_rdata;
  logic        irq_dift;

  assign clk = clk_i;
endinterface

`endif