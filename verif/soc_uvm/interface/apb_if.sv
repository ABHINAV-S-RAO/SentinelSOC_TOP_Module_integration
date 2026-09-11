`ifndef APB_IF_SV
`define APB_IF_SV

interface apb_if (
  input logic pclk,
  input logic presetn
);
  logic        psel;
  logic        penable;
  logic        pwrite;
  logic [31:0] paddr;
  logic [31:0] pwdata;
  logic [31:0] prdata;
  logic        pready;
  logic        pslverr;
endinterface

`endif