`ifndef OBI_IF_SV
`define OBI_IF_SV

interface obi_if(input logic clk_i, input logic rst_ni);
  logic        req = 0;
  logic        gnt;
  logic        rvalid;
  logic        we = 0;
  logic [3:0]  be = 0;
  logic [31:0] addr = 0;
  logic [31:0] wdata = 0;
  logic [31:0] rdata = 0;
  logic        err = 0;
endinterface

`endif
