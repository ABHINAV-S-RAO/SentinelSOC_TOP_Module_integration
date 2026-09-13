`ifndef OBI_IF_SV
`define OBI_IF_SV

interface obi_if(input logic clk_i, input logic rst_ni);
  logic        req;
  logic        gnt;
  logic        rvalid;
  logic        we;
  logic [3:0]  be;
  logic [31:0] addr;
  logic [31:0] wdata;
  logic [31:0] rdata;
  logic        err;
endinterface

`endif
