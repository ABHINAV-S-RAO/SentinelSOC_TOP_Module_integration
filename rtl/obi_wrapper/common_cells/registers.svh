`ifndef COMMON_CELLS_REGISTERS_SVH_
`define COMMON_CELLS_REGISTERS_SVH_

`define REG_DFLT_CLK clk_i
`define REG_DFLT_RST rst_i
`define REG_DFLT_RST_N rst_ni

`define FF(__q, __d, __reset_value, __clk = `REG_DFLT_CLK, __arst_n = `REG_DFLT_RST_N) \
  always_ff @(posedge (__clk) or negedge (__arst_n)) begin                              \
    if (!__arst_n) begin                                                                \
      __q <= (__reset_value);                                                           \
    end else begin                                                                      \
      __q <= (__d);                                                                     \
    end                                                                                 \
  end

`define FFL(__q, __d, __load, __reset_value, __clk = `REG_DFLT_CLK, __arst_n = `REG_DFLT_RST_N) \
  always_ff @(posedge (__clk) or negedge (__arst_n)) begin                                      \
    if (!__arst_n) begin                                                                        \
      __q <= (__reset_value);                                                                   \
    end else begin                                                                              \
      if (__load) begin                                                                         \
        __q <= (__d);                                                                           \
      end                                                                                       \
    end                                                                                         \
  end

`define FFLNR(__q, __d, __load, __clk = `REG_DFLT_CLK) \
  always_ff @(posedge (__clk)) begin                   \
    if (__load) begin                                  \
      __q <= (__d);                                    \
    end                                                \
  end

`include "common_cells/deprecated/registers.svh"

`endif