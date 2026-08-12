`ifndef OBI_ASSIGN_SVH
`define OBI_ASSIGN_SVH

`define __OBI_TO_A(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep)                       \
  __opt_as __lhs``__lhs_sep``addr       = __rhs``__rhs_sep``addr;                      \
  __opt_as __lhs``__lhs_sep``we         = __rhs``__rhs_sep``we;                        \
  __opt_as __lhs``__lhs_sep``be         = __rhs``__rhs_sep``be;                        \
  __opt_as __lhs``__lhs_sep``wdata      = __rhs``__rhs_sep``wdata;                     \
  __opt_as __lhs``__lhs_sep``aid        = __rhs``__rhs_sep``aid;                       \
  __opt_as __lhs``__lhs_sep``a_optional = __rhs``__rhs_sep``a_optional;

`define __OBI_TO_R(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep)                       \
  __opt_as __lhs``__lhs_sep``rdata      = __rhs``__rhs_sep``rdata;                     \
  __opt_as __lhs``__lhs_sep``rid        = __rhs``__rhs_sep``rid;                       \
  __opt_as __lhs``__lhs_sep``err        = __rhs``__rhs_sep``err;                       \
  __opt_as __lhs``__lhs_sep``r_optional = __rhs``__rhs_sep``r_optional;

`define __OBI_TO_REQ(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep, __lhscfg, __rhscfg) \
  `__OBI_TO_A(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep)                            \
  __opt_as __lhs.req = __rhs.req;                                                       \
  if (__lhscfg.Integrity) begin                                                         \
    if (__rhscfg.Integrity) begin                                                       \
      __opt_as __lhs.reqpar = __rhs.reqpar;                                             \
    end else begin                                                                      \
      __opt_as __lhs.reqpar = ~__rhs.req;                                               \
    end                                                                                 \
  end                                                                                   \
  if (__lhscfg.UseRReady) begin                                                         \
    if (__rhscfg.UseRReady) begin                                                       \
      __opt_as __lhs.rready = __rhs.rready;                                             \
      if (__lhscfg.Integrity) begin                                                     \
        if (__rhscfg.Integrity) begin                                                   \
          __opt_as __lhs.rreadypar = __rhs.rreadypar;                                   \
        end else begin                                                                  \
          __opt_as __lhs.rreadypar = ~__rhs.rready;                                     \
        end                                                                             \
      end                                                                               \
    end else begin                                                                      \
      __opt_as __lhs.rready = 1'b1;                                                     \
      if (__lhscfg.Integrity) begin                                                     \
        __opt_as __lhs.rreadypar = 1'b0;                                                \
      end                                                                               \
    end                                                                                 \
  end else if (__rhscfg.UseRReady) begin                                                \
    $error("Incompatible Configs! Please assign manually!");                          \
  end

`define __OBI_TO_RSP(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep, __lhscfg, __rhscfg) \
  `__OBI_TO_R(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep)                            \
  __opt_as __lhs.gnt    = __rhs.gnt;                                                    \
  __opt_as __lhs.rvalid = __rhs.rvalid;                                                 \
  if (__lhscfg.Integrity) begin                                                         \
    if (__rhscfg.Integrity) begin                                                       \
      __opt_as __lhs.gntpar    = __rhs.gntpar;                                          \
      __opt_as __lhs.rvalidpar = __rhs.rvalidpar;                                       \
    end else begin                                                                      \
      __opt_as __lhs.gntpar    = ~__rhs.gnt;                                            \
      __opt_as __lhs.rvalidpar = ~__rhs.rvalid;                                         \
    end                                                                                 \
  end

`define OBI_ASSIGN_A(dst, src, dstcfg, srccfg)               \
  `__OBI_TO_A(assign, dst, ., src, .)                        \
  assign dst.req = src.req;                                  \
  assign src.gnt = dst.gnt;                                  \
  if (dstcfg.Integrity && srccfg.Integrity) begin            \
    assign dst.reqpar = src.reqpar;                          \
    assign src.gntpar = dst.gntpar;                          \
  end else if (dstcfg.Integrity ^ srccfg.Integrity) begin    \
    $error("Incompatible Configs! Please assign manually!"); \
  end

`define OBI_ASSIGN_R(dst, src, dstcfg, srccfg)               \
  `__OBI_TO_R(assign, dst, ., src, .)                        \
  assign dst.rvalid = src.rvalid;                            \
  if (dstcfg.Integrity && srccfg.Integrity) begin            \
    assign dst.rvalidpar = src.rvalidpar;                    \
  end else if (dstcfg.Integrity ^ srccfg.Integrity) begin    \
    $error("Incompatible Configs! Please assign manually!"); \
  end                                                        \
  if (srccfg.UseRReady) begin                                \
    if (dstcfg.UseRReady) begin                              \
      assign src.rready = dst.rready;                        \
      if (srccfg.Integrity && dstcfg.Integrity) begin        \
        assign src.rreadypar = dst.rreadypar;                \
      end                                                    \
    end else begin                                           \
      assign src.rready = 1'b1;                              \
      if (srccfg.Integrity) begin                            \
        assign src.rreadypar = 1'b0;                         \
      end                                                    \
    end                                                      \
  end else if (dstcfg.UseRReady) begin                       \
    $error("Incompatible Configs! Please assign manually!"); \
  end

`define OBI_ASSIGN(sbr, mgr, sbrcfg, mgrcfg) \
  `OBI_ASSIGN_A(sbr, mgr, sbrcfg, mgrcfg)    \
  `OBI_ASSIGN_R(mgr, sbr, mgrcfg, sbrcfg)

`define OBI_SET_FROM_A(obi_if, a_struct)           `__OBI_TO_A(, obi_if, ., a_struct, .)
`define OBI_SET_FROM_R(obi_if, r_struct)           `__OBI_TO_R(, obi_if, ., r_struct, .)
`define OBI_SET_FROM_REQ(obi_if, req_struct, cfg)  `__OBI_TO_REQ(, obi_if, ., req_struct, .a., cfg, cfg)
`define OBI_SET_FROM_RSP(obi_if, rsp_struct, cfg)  `__OBI_TO_RSP(, obi_if, ., rsp_struct, .r., cfg, cfg)

`define OBI_ASSIGN_FROM_A(obi_if, a_struct)           `__OBI_TO_A(assign, obi_if, ., a_struct, .)
`define OBI_ASSIGN_FROM_R(obi_if, r_struct)           `__OBI_TO_R(assign, obi_if, ., r_struct, .)
`define OBI_ASSIGN_FROM_REQ(obi_if, req_struct, cfg)  `__OBI_TO_REQ(assign, obi_if, ., req_struct, .a., cfg, cfg)
`define OBI_ASSIGN_FROM_RSP(obi_if, rsp_struct, cfg)  `__OBI_TO_RSP(assign, obi_if, ., rsp_struct, .r., cfg, cfg)

`define OBI_SET_A_STRUCT(lhs, rhs)      `__OBI_TO_A(, lhs, ., rhs, .)
`define OBI_SET_R_STRUCT(lhs, rhs)      `__OBI_TO_R(, lhs, ., rhs, .)
`define OBI_SET_REQ_STRUCT(lhs, rhs)  `__OBI_TO_REQ(, lhs, .a., rhs, .a.)
`define OBI_SET_RSP_STRUCT(lhs, rhs)  `__OBI_TO_RSP(, lhs, .r., rhs, .r.)

`define OBI_SET_TO_A(a_struct, obi_if)      `__OBI_TO_A(, a_struct, ., obi_if, .)
`define OBI_SET_TO_R(r_struct, obi_if)      `__OBI_TO_R(, r_struct, ., obi_if, .)
`define OBI_SET_TO_REQ(req_struct, obi_if, cfg)  `__OBI_TO_REQ(, req_struct, .a., obi_if, ., cfg, cfg)
`define OBI_SET_TO_RSP(rsp_struct, obi_if, cfg)  `__OBI_TO_RSP(, rsp_struct, .r., obi_if, ., cfg, cfg)

`define OBI_ASSIGN_TO_A(a_struct, obi_if)      `__OBI_TO_A(assign, a_struct, ., obi_if, .)
`define OBI_ASSIGN_TO_R(r_struct, obi_if)      `__OBI_TO_R(assign, r_struct, ., obi_if, .)
`define OBI_ASSIGN_TO_REQ(req_struct, obi_if, cfg)  `__OBI_TO_REQ(assign, req_struct, .a., obi_if, ., cfg, cfg)
`define OBI_ASSIGN_TO_RSP(rsp_struct, obi_if, cfg)  `__OBI_TO_RSP(assign, rsp_struct, .r., obi_if, ., cfg, cfg)

`endif