`ifndef COMMON_CELLS_ASSERTIONS_SVH
`define COMMON_CELLS_ASSERTIONS_SVH

`ifndef ASSERTS_OFF
`ifndef SYNTHESIS
`ifndef XSIM
`define INC_ASSERT
`endif
`endif
`endif

`define ASSERT_STRINGIFY(__x) `"__x`"
`define ASSERT_RPT(__name, __desc = "") $error("[ASSERT FAILED] [%m] %s: %s (%s:%0d)", __name, __desc, `__FILE__, `__LINE__)

`define ASSERT_INIT(__name, __prop, __desc = "") \
`ifdef INC_ASSERT                                    \
  initial begin                                       \
    __name: assert (__prop)                           \
      else begin                                      \
        `ASSERT_RPT(`ASSERT_STRINGIFY(__name), __desc); \
      end                                             \
  end                                                 \
`endif

`define ASSERT(__name, __prop, __clk = clk_i, __rst = !rst_ni, __desc = "") \
`ifdef INC_ASSERT                                                      \
  __name: assert property (@(posedge __clk) disable iff ((__rst) !== '0) (__prop)) \
    else begin                                                       \
      `ASSERT_RPT(`ASSERT_STRINGIFY(__name), __desc);                \
    end                                                              \
`endif

`endif