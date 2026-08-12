`ifndef COMMON_CELLS_REGISTERS_DEPRECATED_SVH_
`define COMMON_CELLS_REGISTERS_DEPRECATED_SVH_

`ifndef TARGET_CC_NO_DEPRECATED

`define FFARN(__q, __d, __reset_value, __clk = `REG_DFLT_CLK, __arst_n = `REG_DFLT_RST_N) \
  `FF(__q, __d, __reset_value, __clk, __arst_n)

`define FFLARN(__q, __d, __load, __reset_value, __clk = `REG_DFLT_CLK, __arst_n = `REG_DFLT_RST_N) \
  `FFL(__q, __d, __load, __reset_value, __clk, __arst_n)

`endif

`endif