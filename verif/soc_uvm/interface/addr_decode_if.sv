`ifndef ADDR_DECODE_IF_SV
`define ADDR_DECODE_IF_SV

interface addr_decode_if (
  input logic clk_i,
  input logic rst_ni
);
  logic        clk;
  logic [31:0] addr_i;
  logic        is_fetch_i;

  // Select signals sampled by monitor
  logic        fsel_bootrom;
  logic        fsel_isram;
  logic        sel_isram;
  logic        sel_dsram;
  logic        sel_sysctrl;
  logic        sel_buffer;
  logic        sel_sha;
  logic        psel_uart;
  logic        psel_qspi;
  logic        psel_plic;
  logic        psel_dbg;

  assign clk = clk_i;
endinterface

`endif