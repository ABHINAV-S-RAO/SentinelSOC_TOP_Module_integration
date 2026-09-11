`ifndef ADDR_DECODE_IF_SV
`define ADDR_DECODE_IF_SV

interface addr_decode_if (
  input logic clk_i,
  input logic rst_ni
);
  logic [31:0] addr;
  logic        req;
  logic        is_fetch;
  logic [15:0] region_sel;
  logic        error;
endinterface

`endif