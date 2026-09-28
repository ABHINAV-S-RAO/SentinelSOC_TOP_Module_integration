// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtb_secure_boot.h for the primary calling header

#include "Vtb_secure_boot__pch.h"

VlCoroutine Vtb_secure_boot___024root___eval_initial__TOP__Vtiming__0(Vtb_secure_boot___024root* vlSelf);
VlCoroutine Vtb_secure_boot___024root___eval_initial__TOP__Vtiming__1(Vtb_secure_boot___024root* vlSelf);

void Vtb_secure_boot___024root___eval_initial(Vtb_secure_boot___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_secure_boot___024root___eval_initial\n"); );
    Vtb_secure_boot__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    Vtb_secure_boot___024root___eval_initial__TOP__Vtiming__0(vlSelf);
    Vtb_secure_boot___024root___eval_initial__TOP__Vtiming__1(vlSelf);
}

void Vtb_secure_boot___024root____VbeforeTrig_hedba2121__0(Vtb_secure_boot___024root* vlSelf, const char* __VeventDescription);
void Vtb_secure_boot___024root____VbeforeTrig_hedba20e2__0(Vtb_secure_boot___024root* vlSelf, const char* __VeventDescription);

VlCoroutine Vtb_secure_boot___024root___eval_initial__TOP__Vtiming__0(Vtb_secure_boot___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_secure_boot___024root___eval_initial__TOP__Vtiming__0\n"); );
    Vtb_secure_boot__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    IData/*31:0*/ tb_secure_boot__DOT__unnamedblk1__DOT__i;
    tb_secure_boot__DOT__unnamedblk1__DOT__i = 0;
    CData/*0:0*/ __Vtask_tb_secure_boot__DOT__run__0__expect_ok;
    __Vtask_tb_secure_boot__DOT__run__0__expect_ok = 0;
    IData/*31:0*/ __Vtask_tb_secure_boot__DOT__run__0__tb_secure_boot__DOT__unnamedblk1_1__DOT____Vrepeat0;
    __Vtask_tb_secure_boot__DOT__run__0__tb_secure_boot__DOT__unnamedblk1_1__DOT____Vrepeat0 = 0;
    IData/*31:0*/ __Vtask_tb_secure_boot__DOT__run__0__tb_secure_boot__DOT__unnamedblk1_2__DOT____Vrepeat1;
    __Vtask_tb_secure_boot__DOT__run__0__tb_secure_boot__DOT__unnamedblk1_2__DOT____Vrepeat1 = 0;
    IData/*31:0*/ __Vtask_tb_secure_boot__DOT__run__0__st;
    __Vtask_tb_secure_boot__DOT__run__0__st = 0;
    IData/*31:0*/ __Vtask_tb_secure_boot__DOT__run__0__n;
    __Vtask_tb_secure_boot__DOT__run__0__n = 0;
    IData/*31:0*/ __Vtask_tb_secure_boot__DOT__reg_wr__1__a;
    __Vtask_tb_secure_boot__DOT__reg_wr__1__a = 0;
    IData/*31:0*/ __Vtask_tb_secure_boot__DOT__reg_wr__1__d;
    __Vtask_tb_secure_boot__DOT__reg_wr__1__d = 0;
    IData/*31:0*/ __Vtask_tb_secure_boot__DOT__reg_rd__2__a;
    __Vtask_tb_secure_boot__DOT__reg_rd__2__a = 0;
    IData/*31:0*/ __Vtask_tb_secure_boot__DOT__reg_rd__2__d;
    __Vtask_tb_secure_boot__DOT__reg_rd__2__d = 0;
    CData/*0:0*/ __Vtask_tb_secure_boot__DOT__run__3__expect_ok;
    __Vtask_tb_secure_boot__DOT__run__3__expect_ok = 0;
    IData/*31:0*/ __Vtask_tb_secure_boot__DOT__run__3__tb_secure_boot__DOT__unnamedblk1_1__DOT____Vrepeat0;
    __Vtask_tb_secure_boot__DOT__run__3__tb_secure_boot__DOT__unnamedblk1_1__DOT____Vrepeat0 = 0;
    IData/*31:0*/ __Vtask_tb_secure_boot__DOT__run__3__tb_secure_boot__DOT__unnamedblk1_2__DOT____Vrepeat1;
    __Vtask_tb_secure_boot__DOT__run__3__tb_secure_boot__DOT__unnamedblk1_2__DOT____Vrepeat1 = 0;
    IData/*31:0*/ __Vtask_tb_secure_boot__DOT__run__3__st;
    __Vtask_tb_secure_boot__DOT__run__3__st = 0;
    IData/*31:0*/ __Vtask_tb_secure_boot__DOT__run__3__n;
    __Vtask_tb_secure_boot__DOT__run__3__n = 0;
    IData/*31:0*/ __Vtask_tb_secure_boot__DOT__reg_wr__4__a;
    __Vtask_tb_secure_boot__DOT__reg_wr__4__a = 0;
    IData/*31:0*/ __Vtask_tb_secure_boot__DOT__reg_wr__4__d;
    __Vtask_tb_secure_boot__DOT__reg_wr__4__d = 0;
    IData/*31:0*/ __Vtask_tb_secure_boot__DOT__reg_rd__5__a;
    __Vtask_tb_secure_boot__DOT__reg_rd__5__a = 0;
    IData/*31:0*/ __Vtask_tb_secure_boot__DOT__reg_rd__5__d;
    __Vtask_tb_secure_boot__DOT__reg_rd__5__d = 0;
    // Body
    vlSelfRef.tb_secure_boot__DOT__req = 0U;
    vlSelfRef.tb_secure_boot__DOT__we = 0U;
    vlSelfRef.tb_secure_boot__DOT__addr = 0U;
    vlSelfRef.tb_secure_boot__DOT__wdata = 0U;
    tb_secure_boot__DOT__unnamedblk1__DOT__i = 0U;
    while (VL_GTES_III(32, 0x000003ffU, tb_secure_boot__DOT__unnamedblk1__DOT__i)) {
        vlSelfRef.tb_secure_boot__DOT__isram[(0x000003ffU 
                                              & tb_secure_boot__DOT__unnamedblk1__DOT__i)] = 0U;
        tb_secure_boot__DOT__unnamedblk1__DOT__i = 
            ((IData)(1U) + tb_secure_boot__DOT__unnamedblk1__DOT__i);
    }
    VL_READMEM_N(true, 32, 1024, 0, "verif/debugger/images/recovery_signed.mem"s
                 ,  &(vlSelfRef.tb_secure_boot__DOT__isram)
                 , 0, ~0ULL);
    VL_READMEM_N(true, 32, 8, 0, "verif/debugger/images/otp_pubkey.mem"s
                 ,  &(vlSelfRef.tb_secure_boot__DOT__pk)
                 , 0, ~0ULL);
    vlSelfRef.tb_secure_boot__DOT__otp_key[0U] = vlSelfRef.tb_secure_boot__DOT__pk[0U];
    vlSelfRef.tb_secure_boot__DOT__otp_key[1U] = (IData)(
                                                         (((QData)((IData)(vlSelfRef.tb_secure_boot__DOT__pk[2U])) 
                                                           << 0x00000020U) 
                                                          | (QData)((IData)(vlSelfRef.tb_secure_boot__DOT__pk[1U]))));
    vlSelfRef.tb_secure_boot__DOT__otp_key[2U] = (IData)(
                                                         ((((QData)((IData)(vlSelfRef.tb_secure_boot__DOT__pk[2U])) 
                                                            << 0x00000020U) 
                                                           | (QData)((IData)(vlSelfRef.tb_secure_boot__DOT__pk[1U]))) 
                                                          >> 0x00000020U));
    vlSelfRef.tb_secure_boot__DOT__otp_key[3U] = vlSelfRef.tb_secure_boot__DOT__pk[3U];
    vlSelfRef.tb_secure_boot__DOT__otp_key[4U] = (IData)(
                                                         (((QData)((IData)(vlSelfRef.tb_secure_boot__DOT__pk[5U])) 
                                                           << 0x00000020U) 
                                                          | (QData)((IData)(vlSelfRef.tb_secure_boot__DOT__pk[4U]))));
    vlSelfRef.tb_secure_boot__DOT__otp_key[5U] = (IData)(
                                                         ((((QData)((IData)(vlSelfRef.tb_secure_boot__DOT__pk[5U])) 
                                                            << 0x00000020U) 
                                                           | (QData)((IData)(vlSelfRef.tb_secure_boot__DOT__pk[4U]))) 
                                                          >> 0x00000020U));
    vlSelfRef.tb_secure_boot__DOT__otp_key[6U] = (IData)(
                                                         (((QData)((IData)(vlSelfRef.tb_secure_boot__DOT__pk[7U])) 
                                                           << 0x00000020U) 
                                                          | (QData)((IData)(vlSelfRef.tb_secure_boot__DOT__pk[6U]))));
    vlSelfRef.tb_secure_boot__DOT__otp_key[7U] = (IData)(
                                                         ((((QData)((IData)(vlSelfRef.tb_secure_boot__DOT__pk[7U])) 
                                                            << 0x00000020U) 
                                                           | (QData)((IData)(vlSelfRef.tb_secure_boot__DOT__pk[6U]))) 
                                                          >> 0x00000020U));
    __Vtask_tb_secure_boot__DOT__run__0__expect_ok = 1U;
    vlSelfRef.__Vtask_tb_secure_boot__DOT__run__0__name = "signed image"s;
    __Vtask_tb_secure_boot__DOT__run__0__tb_secure_boot__DOT__unnamedblk1_1__DOT____Vrepeat0 = 0U;
    __Vtask_tb_secure_boot__DOT__run__0__tb_secure_boot__DOT__unnamedblk1_2__DOT____Vrepeat1 = 0U;
    __Vtask_tb_secure_boot__DOT__run__0__st = 0;
    __Vtask_tb_secure_boot__DOT__run__0__n = 0U;
    co_await vlSelfRef.__VdlySched.delay(0x00000000000003e8ULL, 
                                         nullptr, "verif/secure_boot/tb_secure_boot.sv", 
                                         57);
    vlSelfRef.tb_secure_boot__DOT__rst_n = 0U;
    __Vtask_tb_secure_boot__DOT__run__0__tb_secure_boot__DOT__unnamedblk1_1__DOT____Vrepeat0 = 5U;
    while (VL_LTS_III(32, 0U, __Vtask_tb_secure_boot__DOT__run__0__tb_secure_boot__DOT__unnamedblk1_1__DOT____Vrepeat0)) {
        Vtb_secure_boot___024root____VbeforeTrig_hedba2121__0(vlSelf, 
                                                              "@(posedge tb_secure_boot.clk)");
        co_await vlSelfRef.__VtrigSched_hedba2121__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(posedge tb_secure_boot.clk)", 
                                                             "verif/secure_boot/tb_secure_boot.sv", 
                                                             57);
        __Vtask_tb_secure_boot__DOT__run__0__tb_secure_boot__DOT__unnamedblk1_1__DOT____Vrepeat0 
            = (__Vtask_tb_secure_boot__DOT__run__0__tb_secure_boot__DOT__unnamedblk1_1__DOT____Vrepeat0 
               - (IData)(1U));
    }
    vlSelfRef.tb_secure_boot__DOT__rst_n = 1U;
    __Vtask_tb_secure_boot__DOT__run__0__tb_secure_boot__DOT__unnamedblk1_2__DOT____Vrepeat1 = 3U;
    while (VL_LTS_III(32, 0U, __Vtask_tb_secure_boot__DOT__run__0__tb_secure_boot__DOT__unnamedblk1_2__DOT____Vrepeat1)) {
        Vtb_secure_boot___024root____VbeforeTrig_hedba2121__0(vlSelf, 
                                                              "@(posedge tb_secure_boot.clk)");
        co_await vlSelfRef.__VtrigSched_hedba2121__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(posedge tb_secure_boot.clk)", 
                                                             "verif/secure_boot/tb_secure_boot.sv", 
                                                             57);
        __Vtask_tb_secure_boot__DOT__run__0__tb_secure_boot__DOT__unnamedblk1_2__DOT____Vrepeat1 
            = (__Vtask_tb_secure_boot__DOT__run__0__tb_secure_boot__DOT__unnamedblk1_2__DOT____Vrepeat1 
               - (IData)(1U));
    }
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_otp__DOT__otp_mem[0U] 
        = vlSelfRef.tb_secure_boot__DOT__otp_key[0U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_otp__DOT__otp_mem[1U] 
        = vlSelfRef.tb_secure_boot__DOT__otp_key[1U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_otp__DOT__otp_mem[2U] 
        = vlSelfRef.tb_secure_boot__DOT__otp_key[2U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_otp__DOT__otp_mem[3U] 
        = vlSelfRef.tb_secure_boot__DOT__otp_key[3U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_otp__DOT__otp_mem[4U] 
        = vlSelfRef.tb_secure_boot__DOT__otp_key[4U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_otp__DOT__otp_mem[5U] 
        = vlSelfRef.tb_secure_boot__DOT__otp_key[5U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_otp__DOT__otp_mem[6U] 
        = vlSelfRef.tb_secure_boot__DOT__otp_key[6U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_otp__DOT__otp_mem[7U] 
        = vlSelfRef.tb_secure_boot__DOT__otp_key[7U];
    __Vtask_tb_secure_boot__DOT__reg_wr__1__d = 1U;
    __Vtask_tb_secure_boot__DOT__reg_wr__1__a = 0U;
    Vtb_secure_boot___024root____VbeforeTrig_hedba20e2__0(vlSelf, 
                                                          "@(negedge tb_secure_boot.clk)");
    co_await vlSelfRef.__VtrigSched_hedba20e2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge tb_secure_boot.clk)", 
                                                         "verif/secure_boot/tb_secure_boot.sv", 
                                                         45);
    vlSelfRef.tb_secure_boot__DOT__req = 1U;
    vlSelfRef.tb_secure_boot__DOT__we = 1U;
    vlSelfRef.tb_secure_boot__DOT__addr = __Vtask_tb_secure_boot__DOT__reg_wr__1__a;
    vlSelfRef.tb_secure_boot__DOT__wdata = __Vtask_tb_secure_boot__DOT__reg_wr__1__d;
    Vtb_secure_boot___024root____VbeforeTrig_hedba20e2__0(vlSelf, 
                                                          "@(negedge tb_secure_boot.clk)");
    co_await vlSelfRef.__VtrigSched_hedba20e2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge tb_secure_boot.clk)", 
                                                         "verif/secure_boot/tb_secure_boot.sv", 
                                                         46);
    vlSelfRef.tb_secure_boot__DOT__req = 0U;
    vlSelfRef.tb_secure_boot__DOT__we = 0U;
    do {
        __Vtask_tb_secure_boot__DOT__reg_rd__2__a = 4U;
        __Vtask_tb_secure_boot__DOT__reg_rd__2__d = 0;
        Vtb_secure_boot___024root____VbeforeTrig_hedba20e2__0(vlSelf, 
                                                              "@(negedge tb_secure_boot.clk)");
        co_await vlSelfRef.__VtrigSched_hedba20e2__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(negedge tb_secure_boot.clk)", 
                                                             "verif/secure_boot/tb_secure_boot.sv", 
                                                             49);
        vlSelfRef.tb_secure_boot__DOT__req = 1U;
        vlSelfRef.tb_secure_boot__DOT__we = 0U;
        vlSelfRef.tb_secure_boot__DOT__addr = __Vtask_tb_secure_boot__DOT__reg_rd__2__a;
        Vtb_secure_boot___024root____VbeforeTrig_hedba20e2__0(vlSelf, 
                                                              "@(negedge tb_secure_boot.clk)");
        co_await vlSelfRef.__VtrigSched_hedba20e2__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(negedge tb_secure_boot.clk)", 
                                                             "verif/secure_boot/tb_secure_boot.sv", 
                                                             50);
        vlSelfRef.tb_secure_boot__DOT__req = 0U;
        __Vtask_tb_secure_boot__DOT__reg_rd__2__d = vlSelfRef.tb_secure_boot__DOT__rdata;
        __Vtask_tb_secure_boot__DOT__run__0__st = __Vtask_tb_secure_boot__DOT__reg_rd__2__d;
        __Vtask_tb_secure_boot__DOT__run__0__n = ((IData)(1U) 
                                                  + __Vtask_tb_secure_boot__DOT__run__0__n);
    } while (((~ (__Vtask_tb_secure_boot__DOT__run__0__st 
                  >> 1U)) & VL_GTS_III(32, 0x000f4240U, __Vtask_tb_secure_boot__DOT__run__0__n)));
    vlSelfRef.tb_secure_boot__DOT__faddr = 0x00010044U;
    co_await vlSelfRef.__VdlySched.delay(0x00000000000003e8ULL, 
                                         nullptr, "verif/secure_boot/tb_secure_boot.sv", 
                                         61);
    if (VL_UNLIKELY((((IData)(vlSelfRef.tb_secure_boot__DOT__fok) 
                      != (IData)(__Vtask_tb_secure_boot__DOT__run__0__expect_ok))))) {
        vlSelfRef.tb_secure_boot__DOT__fails = ((IData)(1U) 
                                                + vlSelfRef.tb_secure_boot__DOT__fails);
        VL_WRITEF_NX("  FAIL fetch_ok(entry)=%b\n",1
                     , '#',1,vlSelfRef.tb_secure_boot__DOT__fok);
    }
    vlSelfRef.tb_secure_boot__DOT__faddr = 0x00010040U;
    co_await vlSelfRef.__VdlySched.delay(0x00000000000003e8ULL, 
                                         nullptr, "verif/secure_boot/tb_secure_boot.sv", 
                                         62);
    vlSelfRef.tb_secure_boot__DOT__faddr = 0x00010064U;
    if (VL_UNLIKELY((vlSelfRef.tb_secure_boot__DOT__fok))) {
        vlSelfRef.tb_secure_boot__DOT__fails = ((IData)(1U) 
                                                + vlSelfRef.tb_secure_boot__DOT__fails);
        VL_WRITEF_NX("  FAIL fetch_ok(header)=%b\n",1
                     , '#',1,vlSelfRef.tb_secure_boot__DOT__fok);
    }
    co_await vlSelfRef.__VdlySched.delay(0x00000000000003e8ULL, 
                                         nullptr, "verif/secure_boot/tb_secure_boot.sv", 
                                         63);
    if (VL_UNLIKELY((vlSelfRef.tb_secure_boot__DOT__fok))) {
        vlSelfRef.tb_secure_boot__DOT__fails = ((IData)(1U) 
                                                + vlSelfRef.tb_secure_boot__DOT__fails);
        VL_WRITEF_NX("  FAIL fetch_ok(past end)=%b\n",1
                     , '#',1,vlSelfRef.tb_secure_boot__DOT__fok);
    }
    if (VL_UNLIKELY(((1U & ((((1U & (__Vtask_tb_secure_boot__DOT__run__0__st 
                                     >> 3U)) != (IData)(__Vtask_tb_secure_boot__DOT__run__0__expect_ok)) 
                             | ((1U & (__Vtask_tb_secure_boot__DOT__run__0__st 
                                       >> 2U)) != (IData)(__Vtask_tb_secure_boot__DOT__run__0__expect_ok))) 
                            | (__Vtask_tb_secure_boot__DOT__run__0__st 
                               >> 4U)))))) {
        vlSelfRef.tb_secure_boot__DOT__fails = ((IData)(1U) 
                                                + vlSelfRef.tb_secure_boot__DOT__fails);
        VL_WRITEF_NX("  FAIL status\n",0);
    }
    VL_WRITEF_NX("%-16s err=%b verified=%b valid=%b done=%b busy=%b  fetch: entry ok, header/past-end blocked  (%0d polls)\n",7
                 , 'S',&(vlSelfRef.__Vtask_tb_secure_boot__DOT__run__0__name)
                 , '#',1,(1U & (__Vtask_tb_secure_boot__DOT__run__0__st 
                                >> 4U)), '#',1,(1U 
                                                & (__Vtask_tb_secure_boot__DOT__run__0__st 
                                                   >> 3U))
                 , '#',1,(1U & (__Vtask_tb_secure_boot__DOT__run__0__st 
                                >> 2U)), '#',1,(1U 
                                                & (__Vtask_tb_secure_boot__DOT__run__0__st 
                                                   >> 1U))
                 , '#',1,(1U & __Vtask_tb_secure_boot__DOT__run__0__st)
                 , '~',32,__Vtask_tb_secure_boot__DOT__run__0__n);
    vlSelfRef.tb_secure_boot__DOT__isram[20U] = (1U 
                                                 ^ vlSelfRef.tb_secure_boot__DOT__isram[20U]);
    __Vtask_tb_secure_boot__DOT__run__3__expect_ok = 0U;
    vlSelfRef.__Vtask_tb_secure_boot__DOT__run__3__name = "tampered image"s;
    __Vtask_tb_secure_boot__DOT__run__3__tb_secure_boot__DOT__unnamedblk1_1__DOT____Vrepeat0 = 0U;
    __Vtask_tb_secure_boot__DOT__run__3__tb_secure_boot__DOT__unnamedblk1_2__DOT____Vrepeat1 = 0U;
    __Vtask_tb_secure_boot__DOT__run__3__st = 0;
    __Vtask_tb_secure_boot__DOT__run__3__n = 0U;
    co_await vlSelfRef.__VdlySched.delay(0x00000000000003e8ULL, 
                                         nullptr, "verif/secure_boot/tb_secure_boot.sv", 
                                         57);
    vlSelfRef.tb_secure_boot__DOT__rst_n = 0U;
    __Vtask_tb_secure_boot__DOT__run__3__tb_secure_boot__DOT__unnamedblk1_1__DOT____Vrepeat0 = 5U;
    while (VL_LTS_III(32, 0U, __Vtask_tb_secure_boot__DOT__run__3__tb_secure_boot__DOT__unnamedblk1_1__DOT____Vrepeat0)) {
        Vtb_secure_boot___024root____VbeforeTrig_hedba2121__0(vlSelf, 
                                                              "@(posedge tb_secure_boot.clk)");
        co_await vlSelfRef.__VtrigSched_hedba2121__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(posedge tb_secure_boot.clk)", 
                                                             "verif/secure_boot/tb_secure_boot.sv", 
                                                             57);
        __Vtask_tb_secure_boot__DOT__run__3__tb_secure_boot__DOT__unnamedblk1_1__DOT____Vrepeat0 
            = (__Vtask_tb_secure_boot__DOT__run__3__tb_secure_boot__DOT__unnamedblk1_1__DOT____Vrepeat0 
               - (IData)(1U));
    }
    vlSelfRef.tb_secure_boot__DOT__rst_n = 1U;
    __Vtask_tb_secure_boot__DOT__run__3__tb_secure_boot__DOT__unnamedblk1_2__DOT____Vrepeat1 = 3U;
    while (VL_LTS_III(32, 0U, __Vtask_tb_secure_boot__DOT__run__3__tb_secure_boot__DOT__unnamedblk1_2__DOT____Vrepeat1)) {
        Vtb_secure_boot___024root____VbeforeTrig_hedba2121__0(vlSelf, 
                                                              "@(posedge tb_secure_boot.clk)");
        co_await vlSelfRef.__VtrigSched_hedba2121__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(posedge tb_secure_boot.clk)", 
                                                             "verif/secure_boot/tb_secure_boot.sv", 
                                                             57);
        __Vtask_tb_secure_boot__DOT__run__3__tb_secure_boot__DOT__unnamedblk1_2__DOT____Vrepeat1 
            = (__Vtask_tb_secure_boot__DOT__run__3__tb_secure_boot__DOT__unnamedblk1_2__DOT____Vrepeat1 
               - (IData)(1U));
    }
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_otp__DOT__otp_mem[0U] 
        = vlSelfRef.tb_secure_boot__DOT__otp_key[0U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_otp__DOT__otp_mem[1U] 
        = vlSelfRef.tb_secure_boot__DOT__otp_key[1U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_otp__DOT__otp_mem[2U] 
        = vlSelfRef.tb_secure_boot__DOT__otp_key[2U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_otp__DOT__otp_mem[3U] 
        = vlSelfRef.tb_secure_boot__DOT__otp_key[3U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_otp__DOT__otp_mem[4U] 
        = vlSelfRef.tb_secure_boot__DOT__otp_key[4U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_otp__DOT__otp_mem[5U] 
        = vlSelfRef.tb_secure_boot__DOT__otp_key[5U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_otp__DOT__otp_mem[6U] 
        = vlSelfRef.tb_secure_boot__DOT__otp_key[6U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_otp__DOT__otp_mem[7U] 
        = vlSelfRef.tb_secure_boot__DOT__otp_key[7U];
    __Vtask_tb_secure_boot__DOT__reg_wr__4__d = 1U;
    __Vtask_tb_secure_boot__DOT__reg_wr__4__a = 0U;
    Vtb_secure_boot___024root____VbeforeTrig_hedba20e2__0(vlSelf, 
                                                          "@(negedge tb_secure_boot.clk)");
    co_await vlSelfRef.__VtrigSched_hedba20e2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge tb_secure_boot.clk)", 
                                                         "verif/secure_boot/tb_secure_boot.sv", 
                                                         45);
    vlSelfRef.tb_secure_boot__DOT__req = 1U;
    vlSelfRef.tb_secure_boot__DOT__we = 1U;
    vlSelfRef.tb_secure_boot__DOT__addr = __Vtask_tb_secure_boot__DOT__reg_wr__4__a;
    vlSelfRef.tb_secure_boot__DOT__wdata = __Vtask_tb_secure_boot__DOT__reg_wr__4__d;
    Vtb_secure_boot___024root____VbeforeTrig_hedba20e2__0(vlSelf, 
                                                          "@(negedge tb_secure_boot.clk)");
    co_await vlSelfRef.__VtrigSched_hedba20e2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge tb_secure_boot.clk)", 
                                                         "verif/secure_boot/tb_secure_boot.sv", 
                                                         46);
    vlSelfRef.tb_secure_boot__DOT__req = 0U;
    vlSelfRef.tb_secure_boot__DOT__we = 0U;
    do {
        __Vtask_tb_secure_boot__DOT__reg_rd__5__a = 4U;
        __Vtask_tb_secure_boot__DOT__reg_rd__5__d = 0;
        Vtb_secure_boot___024root____VbeforeTrig_hedba20e2__0(vlSelf, 
                                                              "@(negedge tb_secure_boot.clk)");
        co_await vlSelfRef.__VtrigSched_hedba20e2__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(negedge tb_secure_boot.clk)", 
                                                             "verif/secure_boot/tb_secure_boot.sv", 
                                                             49);
        vlSelfRef.tb_secure_boot__DOT__req = 1U;
        vlSelfRef.tb_secure_boot__DOT__we = 0U;
        vlSelfRef.tb_secure_boot__DOT__addr = __Vtask_tb_secure_boot__DOT__reg_rd__5__a;
        Vtb_secure_boot___024root____VbeforeTrig_hedba20e2__0(vlSelf, 
                                                              "@(negedge tb_secure_boot.clk)");
        co_await vlSelfRef.__VtrigSched_hedba20e2__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(negedge tb_secure_boot.clk)", 
                                                             "verif/secure_boot/tb_secure_boot.sv", 
                                                             50);
        vlSelfRef.tb_secure_boot__DOT__req = 0U;
        __Vtask_tb_secure_boot__DOT__reg_rd__5__d = vlSelfRef.tb_secure_boot__DOT__rdata;
        __Vtask_tb_secure_boot__DOT__run__3__st = __Vtask_tb_secure_boot__DOT__reg_rd__5__d;
        __Vtask_tb_secure_boot__DOT__run__3__n = ((IData)(1U) 
                                                  + __Vtask_tb_secure_boot__DOT__run__3__n);
    } while (((~ (__Vtask_tb_secure_boot__DOT__run__3__st 
                  >> 1U)) & VL_GTS_III(32, 0x000f4240U, __Vtask_tb_secure_boot__DOT__run__3__n)));
    vlSelfRef.tb_secure_boot__DOT__faddr = 0x00010044U;
    co_await vlSelfRef.__VdlySched.delay(0x00000000000003e8ULL, 
                                         nullptr, "verif/secure_boot/tb_secure_boot.sv", 
                                         61);
    if (VL_UNLIKELY((((IData)(vlSelfRef.tb_secure_boot__DOT__fok) 
                      != (IData)(__Vtask_tb_secure_boot__DOT__run__3__expect_ok))))) {
        vlSelfRef.tb_secure_boot__DOT__fails = ((IData)(1U) 
                                                + vlSelfRef.tb_secure_boot__DOT__fails);
        VL_WRITEF_NX("  FAIL fetch_ok(entry)=%b\n",1
                     , '#',1,vlSelfRef.tb_secure_boot__DOT__fok);
    }
    vlSelfRef.tb_secure_boot__DOT__faddr = 0x00010040U;
    co_await vlSelfRef.__VdlySched.delay(0x00000000000003e8ULL, 
                                         nullptr, "verif/secure_boot/tb_secure_boot.sv", 
                                         62);
    vlSelfRef.tb_secure_boot__DOT__faddr = 0x00010064U;
    if (VL_UNLIKELY((vlSelfRef.tb_secure_boot__DOT__fok))) {
        vlSelfRef.tb_secure_boot__DOT__fails = ((IData)(1U) 
                                                + vlSelfRef.tb_secure_boot__DOT__fails);
        VL_WRITEF_NX("  FAIL fetch_ok(header)=%b\n",1
                     , '#',1,vlSelfRef.tb_secure_boot__DOT__fok);
    }
    co_await vlSelfRef.__VdlySched.delay(0x00000000000003e8ULL, 
                                         nullptr, "verif/secure_boot/tb_secure_boot.sv", 
                                         63);
    if (VL_UNLIKELY((vlSelfRef.tb_secure_boot__DOT__fok))) {
        vlSelfRef.tb_secure_boot__DOT__fails = ((IData)(1U) 
                                                + vlSelfRef.tb_secure_boot__DOT__fails);
        VL_WRITEF_NX("  FAIL fetch_ok(past end)=%b\n",1
                     , '#',1,vlSelfRef.tb_secure_boot__DOT__fok);
    }
    if (VL_UNLIKELY(((1U & ((((1U & (__Vtask_tb_secure_boot__DOT__run__3__st 
                                     >> 3U)) != (IData)(__Vtask_tb_secure_boot__DOT__run__3__expect_ok)) 
                             | ((1U & (__Vtask_tb_secure_boot__DOT__run__3__st 
                                       >> 2U)) != (IData)(__Vtask_tb_secure_boot__DOT__run__3__expect_ok))) 
                            | (__Vtask_tb_secure_boot__DOT__run__3__st 
                               >> 4U)))))) {
        vlSelfRef.tb_secure_boot__DOT__fails = ((IData)(1U) 
                                                + vlSelfRef.tb_secure_boot__DOT__fails);
        VL_WRITEF_NX("  FAIL status\n",0);
    }
    VL_WRITEF_NX("%-16s err=%b verified=%b valid=%b done=%b busy=%b  fetch: entry ok, header/past-end blocked  (%0d polls)\n",7
                 , 'S',&(vlSelfRef.__Vtask_tb_secure_boot__DOT__run__3__name)
                 , '#',1,(1U & (__Vtask_tb_secure_boot__DOT__run__3__st 
                                >> 4U)), '#',1,(1U 
                                                & (__Vtask_tb_secure_boot__DOT__run__3__st 
                                                   >> 3U))
                 , '#',1,(1U & (__Vtask_tb_secure_boot__DOT__run__3__st 
                                >> 2U)), '#',1,(1U 
                                                & (__Vtask_tb_secure_boot__DOT__run__3__st 
                                                   >> 1U))
                 , '#',1,(1U & __Vtask_tb_secure_boot__DOT__run__3__st)
                 , '~',32,__Vtask_tb_secure_boot__DOT__run__3__n);
    if ((0U == vlSelfRef.tb_secure_boot__DOT__fails)) {
        VL_WRITEF_NX("TEST PASSED\n",0);
    } else {
        VL_WRITEF_NX("TEST FAILED (%0d)\n",1, '~',32,vlSelfRef.tb_secure_boot__DOT__fails);
    }
    VL_FINISH_MT("verif/secure_boot/tb_secure_boot.sv", 79, "");
    co_return;
}

VlCoroutine Vtb_secure_boot___024root___eval_initial__TOP__Vtiming__1(Vtb_secure_boot___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_secure_boot___024root___eval_initial__TOP__Vtiming__1\n"); );
    Vtb_secure_boot__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    while (VL_LIKELY(!vlSymsp->_vm_contextp__->gotFinish())) {
        co_await vlSelfRef.__VdlySched.delay(0x0000000000001388ULL, 
                                             nullptr, 
                                             "verif/secure_boot/tb_secure_boot.sv", 
                                             17);
        vlSelfRef.tb_secure_boot__DOT__clk = (1U & 
                                              (~ (IData)(vlSelfRef.tb_secure_boot__DOT__clk)));
    }
    co_return;
}

bool Vtb_secure_boot___024root___trigger_anySet__act(const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_secure_boot___024root___trigger_anySet__act\n"); );
    // Locals
    IData/*31:0*/ n;
    // Body
    n = 0U;
    do {
        if (in[n]) {
            return (1U);
        }
        n = ((IData)(1U) + n);
    } while ((1U > n));
    return (0U);
}

extern const VlWide<8>/*255:0*/ Vtb_secure_boot__ConstPool__CONST_h9e67c271_0;

void Vtb_secure_boot___024root___nba_sequent__TOP__0(Vtb_secure_boot___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_secure_boot___024root___nba_sequent__TOP__0\n"); );
    Vtb_secure_boot__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    IData/*31:0*/ __Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_prep__DOT__N_cnt;
    __Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_prep__DOT__N_cnt = 0;
    CData/*5:0*/ __Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_prep__DOT__C_cnt;
    __Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_prep__DOT__C_cnt = 0;
    // Body
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__data_pending 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__data_pending;
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_reg[0U] 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_reg[0U];
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_reg[1U] 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_reg[1U];
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_reg[2U] 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_reg[2U];
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_reg[3U] 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_reg[3U];
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_reg[4U] 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_reg[4U];
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_reg[5U] 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_reg[5U];
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_reg[6U] 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_reg[6U];
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_reg[7U] 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_reg[7U];
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__s_reg[0U] 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__s_reg[0U];
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__s_reg[1U] 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__s_reg[1U];
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__s_reg[2U] 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__s_reg[2U];
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__s_reg[3U] 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__s_reg[3U];
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__s_reg[4U] 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__s_reg[4U];
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__s_reg[5U] 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__s_reg[5U];
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__s_reg[6U] 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__s_reg[6U];
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__s_reg[7U] 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__s_reg[7U];
    __Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_prep__DOT__N_cnt 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_prep__DOT__N_cnt;
    __Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_prep__DOT__C_cnt 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_prep__DOT__C_cnt;
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[0U] 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[0U];
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[1U] 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[1U];
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[2U] 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[2U];
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[3U] 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[3U];
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[4U] 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[4U];
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[5U] 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[5U];
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[6U] 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[6U];
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[7U] 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[7U];
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[8U] 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[8U];
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[9U] 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[9U];
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[10U] 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[10U];
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[11U] 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[11U];
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[12U] 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[12U];
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[13U] 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[13U];
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[14U] 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[14U];
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[15U] 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[15U];
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__state 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__state;
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__count 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__count;
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__scalar_reg[0U] 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__scalar_reg[0U];
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__scalar_reg[1U] 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__scalar_reg[1U];
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__scalar_reg[2U] 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__scalar_reg[2U];
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__scalar_reg[3U] 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__scalar_reg[3U];
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__scalar_reg[4U] 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__scalar_reg[4U];
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__scalar_reg[5U] 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__scalar_reg[5U];
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__scalar_reg[6U] 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__scalar_reg[6U];
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__scalar_reg[7U] 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__scalar_reg[7U];
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__bit_counter 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__bit_counter;
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__is_last_block 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__is_last_block;
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__a 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__a;
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__b 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__b;
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__c 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__c;
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__d 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__d;
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__round_count 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__round_count;
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__word_count 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__word_count;
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__state 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__state;
    vlSelfRef.__VdlySet__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v0 = 0U;
    vlSelfRef.__VdlySet__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v8 = 0U;
    vlSelfRef.__VdlySet__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v10 = 0U;
    vlSelfRef.__VdlySet__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v16 = 0U;
    vlSelfRef.__VdlySet__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v17 = 0U;
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__e 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__e;
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__f 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__f;
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__g 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__g;
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__h 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__h;
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__sub_step 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__sub_step;
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__seq_done_reg 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__seq_done_reg;
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__start_latch 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__start_latch;
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__state 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__state;
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_fed 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_fed;
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__blk_ptr 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__blk_ptr;
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_idx 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_idx;
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__load_idx 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__load_idx;
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[0U] 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[0U];
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[1U] 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[1U];
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[2U] 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[2U];
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[3U] 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[3U];
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[4U] 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[4U];
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[5U] 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[5U];
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[6U] 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[6U];
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[7U] 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[7U];
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[8U] 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[8U];
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[9U] 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[9U];
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[10U] 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[10U];
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[11U] 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[11U];
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[12U] 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[12U];
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[13U] 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[13U];
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[14U] 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[14U];
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[15U] 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[15U];
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_idx 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_idx;
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__otp_idx 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__otp_idx;
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_wdata 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_wdata;
    vlSelfRef.__VdlySet__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v0 = 0U;
    vlSelfRef.__VdlySet__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v1 = 0U;
    vlSelfRef.__VdlySet__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v2 = 0U;
    vlSelfRef.__VdlySet__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v18 = 0U;
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_prep__DOT__state 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_prep__DOT__state;
    if (vlSelfRef.tb_secure_boot__DOT__rst_n) {
        if (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__datain_wr) {
            vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__data_pending = 1U;
        } else if (((8U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__state)) 
                    & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__data_pending))) {
            vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__data_pending = 0U;
        }
        if (((0x000cU == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__c_addr)) 
             & (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_1))) {
            vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_reg[0U] 
                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_reg[1U];
            vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_reg[1U] 
                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_reg[2U];
            vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_reg[2U] 
                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_reg[3U];
            vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_reg[3U] 
                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_reg[4U];
            vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_reg[4U] 
                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_reg[5U];
            vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_reg[5U] 
                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_reg[6U];
            vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_reg[6U] 
                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_reg[7U];
            vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_reg[7U] 
                = ((((0x0000ff00U & (vlSelfRef.tb_secure_boot__DOT__dut__DOT__c_wdata 
                                     << 8U)) | (0x000000ffU 
                                                & (vlSelfRef.tb_secure_boot__DOT__dut__DOT__c_wdata 
                                                   >> 8U))) 
                    << 0x00000010U) | ((0x0000ff00U 
                                        & (vlSelfRef.tb_secure_boot__DOT__dut__DOT__c_wdata 
                                           >> 8U)) 
                                       | (vlSelfRef.tb_secure_boot__DOT__dut__DOT__c_wdata 
                                          >> 0x18U)));
        }
        if (((0x0010U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__c_addr)) 
             & (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_1))) {
            vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__s_reg[0U] 
                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__s_reg[1U];
            vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__s_reg[1U] 
                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__s_reg[2U];
            vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__s_reg[2U] 
                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__s_reg[3U];
            vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__s_reg[3U] 
                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__s_reg[4U];
            vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__s_reg[4U] 
                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__s_reg[5U];
            vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__s_reg[5U] 
                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__s_reg[6U];
            vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__s_reg[6U] 
                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__s_reg[7U];
            vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__s_reg[7U] 
                = ((((0x0000ff00U & (vlSelfRef.tb_secure_boot__DOT__dut__DOT__c_wdata 
                                     << 8U)) | (0x000000ffU 
                                                & (vlSelfRef.tb_secure_boot__DOT__dut__DOT__c_wdata 
                                                   >> 8U))) 
                    << 0x00000010U) | ((0x0000ff00U 
                                        & (vlSelfRef.tb_secure_boot__DOT__dut__DOT__c_wdata 
                                           >> 8U)) 
                                       | (vlSelfRef.tb_secure_boot__DOT__dut__DOT__c_wdata 
                                          >> 0x18U)));
        }
        if (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__prep_start) {
            __Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_prep__DOT__N_cnt = 0U;
            __Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_prep__DOT__C_cnt = 0U;
        } else if (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__prep_word_ack) {
            if ((0U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_prep__DOT__state))) {
                __Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_prep__DOT__N_cnt 
                    = ((IData)(1U) + vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_prep__DOT__N_cnt);
            }
            if ((3U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_prep__DOT__state))) {
                __Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_prep__DOT__C_cnt 
                    = (0x0000003fU & ((IData)(1U) + (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_prep__DOT__C_cnt)));
            }
        }
        if (((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__prep_word_ack) 
             & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__sched_addr))) {
            vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v0 
                = ((((0x0000ff00U & (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__sched_wdata 
                                     << 8U)) | (0x000000ffU 
                                                & (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__sched_wdata 
                                                   >> 8U))) 
                    << 0x00000010U) | ((0x0000ff00U 
                                        & (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__sched_wdata 
                                           >> 8U)) 
                                       | (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__sched_wdata 
                                          >> 0x18U)));
            vlSelfRef.__VdlyDim0__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v0 
                = (0x0000000fU & ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__sched_addr) 
                                  >> 1U));
            vlSelfRef.__VdlySet__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v0 = 1U;
        } else if (((~ (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__sched_addr)) 
                    & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__prep_word_ack))) {
            vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v1 
                = ((((0x0000ff00U & (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__sched_wdata 
                                     << 8U)) | (0x000000ffU 
                                                & (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__sched_wdata 
                                                   >> 8U))) 
                    << 0x00000010U) | ((0x0000ff00U 
                                        & (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__sched_wdata 
                                           >> 8U)) 
                                       | (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__sched_wdata 
                                          >> 0x18U)));
            vlSelfRef.__VdlyDim0__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v1 
                = (0x0000000fU & ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__sched_addr) 
                                  >> 1U));
            vlSelfRef.__VdlySet__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v1 = 1U;
        } else if ((3U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__state))) {
            vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v2 
                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w[1U];
            vlSelfRef.__VdlySet__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v2 = 1U;
            vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v3 
                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w[2U];
            vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v4 
                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w[3U];
            vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v5 
                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w[4U];
            vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v6 
                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w[5U];
            vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v7 
                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w[6U];
            vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v8 
                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w[7U];
            vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v9 
                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w[8U];
            vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v10 
                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w[9U];
            vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v11 
                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w[10U];
            vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v12 
                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w[11U];
            vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v13 
                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w[12U];
            vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v14 
                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w[13U];
            vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v15 
                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w[14U];
            vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v16 
                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w[15U];
            vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v17 
                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w_next;
        }
        vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_prep__DOT__state 
            = ((4U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_prep__DOT__state))
                ? (((1U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_prep__DOT__state))
                     ? ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_prep__DOT__state) 
                        & (- (IData)((1U & (~ (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__prep_word_ack))))))
                     : ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__prep_word_ack)
                         ? 5U : (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_prep__DOT__state))) 
                   & (- (IData)((IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_24))))
                : ((2U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_prep__DOT__state))
                    ? ((1U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_prep__DOT__state))
                        ? (((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__prep_word_ack) 
                            & (((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_prep__DOT__C) 
                                - (IData)(1U)) == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_prep__DOT__C_cnt)))
                            ? 4U : (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_prep__DOT__state))
                        : ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__prep_word_ack)
                            ? ((0U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_prep__DOT__C))
                                ? 4U : 3U) : (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_prep__DOT__state)))
                    : ((((0U == vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__msg_length) 
                         & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__prep_start))
                         ? 2U : (((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__prep_word_ack) 
                                  & (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_prep__DOT__N_cnt 
                                     == (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__msg_length 
                                         - (IData)(1U))))
                                  ? 2U : (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_prep__DOT__state))) 
                       & (- (IData)((IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_23))))));
        if (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_done) {
            vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__boot_q = 0U;
        }
        if (((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_wen) 
             & (0x32U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_addr)))) {
            vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__msg_length 
                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_wdata;
        }
    } else {
        vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__data_pending = 0U;
        VL_ASSIGN_W(256, vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_reg, Vtb_secure_boot__ConstPool__CONST_h9e67c271_0);
        VL_ASSIGN_W(256, vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__s_reg, Vtb_secure_boot__ConstPool__CONST_h9e67c271_0);
        __Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_prep__DOT__N_cnt = 0U;
        __Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_prep__DOT__C_cnt = 0U;
        vlSelfRef.__VdlySet__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v18 = 1U;
        vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_prep__DOT__state = 0U;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__boot_q = 1U;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__msg_length = 0U;
    }
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_prep__DOT__C_cnt 
        = __Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_prep__DOT__C_cnt;
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_prep__DOT__N_cnt 
        = __Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_prep__DOT__N_cnt;
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_prep__DOT__C 
        = (0x0000003fU & ((0x1cU <= (0x0000001fU & vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__msg_length))
                           ? ((IData)(0x3dU) - (0x0000001fU 
                                                & vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__msg_length))
                           : ((IData)(0x1dU) - (0x0000001fU 
                                                & vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__msg_length))));
}

void Vtb_secure_boot___024root___nba_sequent__TOP__1(Vtb_secure_boot___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_secure_boot___024root___nba_sequent__TOP__1\n"); );
    Vtb_secure_boot__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    IData/*31:0*/ __Vfunc_tb_secure_boot__DOT__dut__DOT__bswap__6__Vfuncout;
    __Vfunc_tb_secure_boot__DOT__dut__DOT__bswap__6__Vfuncout = 0;
    IData/*31:0*/ __Vfunc_tb_secure_boot__DOT__dut__DOT__bswap__6__v;
    __Vfunc_tb_secure_boot__DOT__dut__DOT__bswap__6__v = 0;
    IData/*31:0*/ __Vfunc_tb_secure_boot__DOT__dut__DOT__bswap__7__Vfuncout;
    __Vfunc_tb_secure_boot__DOT__dut__DOT__bswap__7__Vfuncout = 0;
    IData/*31:0*/ __Vfunc_tb_secure_boot__DOT__dut__DOT__bswap__7__v;
    __Vfunc_tb_secure_boot__DOT__dut__DOT__bswap__7__v = 0;
    IData/*31:0*/ __Vfunc_tb_secure_boot__DOT__dut__DOT__bswap__8__Vfuncout;
    __Vfunc_tb_secure_boot__DOT__dut__DOT__bswap__8__Vfuncout = 0;
    IData/*31:0*/ __Vfunc_tb_secure_boot__DOT__dut__DOT__bswap__8__v;
    __Vfunc_tb_secure_boot__DOT__dut__DOT__bswap__8__v = 0;
    IData/*31:0*/ __Vfunc_tb_secure_boot__DOT__dut__DOT__bswap__9__v;
    __Vfunc_tb_secure_boot__DOT__dut__DOT__bswap__9__v = 0;
    IData/*31:0*/ __Vfunc_tb_secure_boot__DOT__dut__DOT__bswap__10__v;
    __Vfunc_tb_secure_boot__DOT__dut__DOT__bswap__10__v = 0;
    IData/*31:0*/ __Vfunc_tb_secure_boot__DOT__dut__DOT__bswap__11__v;
    __Vfunc_tb_secure_boot__DOT__dut__DOT__bswap__11__v = 0;
    IData/*31:0*/ __Vfunc_tb_secure_boot__DOT__dut__DOT__bswap__12__v;
    __Vfunc_tb_secure_boot__DOT__dut__DOT__bswap__12__v = 0;
    CData/*3:0*/ __Vdly__tb_secure_boot__DOT__dut__DOT__state_q;
    __Vdly__tb_secure_boot__DOT__dut__DOT__state_q = 0;
    CData/*0:0*/ __Vdly__tb_secure_boot__DOT__dut__DOT__ran_q;
    __Vdly__tb_secure_boot__DOT__dut__DOT__ran_q = 0;
    SData/*10:0*/ __Vdly__tb_secure_boot__DOT__dut__DOT__left_q;
    __Vdly__tb_secure_boot__DOT__dut__DOT__left_q = 0;
    // Body
    __Vdly__tb_secure_boot__DOT__dut__DOT__ran_q = vlSelfRef.tb_secure_boot__DOT__dut__DOT__ran_q;
    __Vdly__tb_secure_boot__DOT__dut__DOT__left_q = vlSelfRef.tb_secure_boot__DOT__dut__DOT__left_q;
    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__idx_q 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__idx_q;
    __Vdly__tb_secure_boot__DOT__dut__DOT__state_q 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__state_q;
    if (vlSelfRef.tb_secure_boot__DOT__rst_n) {
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__g_div__DOT__div_q 
            = (1U & ((~ (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__g_div__DOT__div_q)) 
                     & ((IData)(1U) + (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__g_div__DOT__div_q))));
        if (((IData)(vlSelfRef.tb_secure_boot__DOT__req) 
             & (~ (IData)(vlSelfRef.tb_secure_boot__DOT__we)))) {
            vlSelfRef.tb_secure_boot__DOT__rdata = 
                ((4U == (0x00000fffU & vlSelfRef.tb_secure_boot__DOT__addr))
                  ? ((((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__err_q) 
                       << 4U) | (((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__verified_q) 
                                  << 3U) | ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__valid_q) 
                                            << 2U))) 
                     | (((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__done_q) 
                         << 1U) | (0U != (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__state_q))))
                  : ((8U == (0x00000fffU & vlSelfRef.tb_secure_boot__DOT__addr))
                      ? (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__code_words_q)
                      : ((0x000cU == (0x00000fffU & vlSelfRef.tb_secure_boot__DOT__addr))
                          ? 0x00010044U : 0U)));
        }
        if ((8U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__state_q))) {
            if ((4U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__state_q))) {
                if ((2U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__state_q))) {
                    __Vdly__tb_secure_boot__DOT__dut__DOT__state_q = 0U;
                } else if ((1U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__state_q))) {
                    if (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_done) {
                        vlSelfRef.tb_secure_boot__DOT__dut__DOT__done_q = 1U;
                        vlSelfRef.tb_secure_boot__DOT__dut__DOT__valid_q 
                            = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_valid;
                        vlSelfRef.tb_secure_boot__DOT__dut__DOT__verified_q 
                            = ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_valid) 
                               & (~ (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__dirty_q)));
                        __Vdly__tb_secure_boot__DOT__dut__DOT__ran_q = 1U;
                        __Vdly__tb_secure_boot__DOT__dut__DOT__state_q = 0U;
                    }
                } else if (vlSelfRef.tb_secure_boot__DOT__dut__DOT__c_gnt) {
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__idx_q 
                        = (0x000007ffU & ((IData)(1U) 
                                          + (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__idx_q)));
                    __Vdly__tb_secure_boot__DOT__dut__DOT__left_q 
                        = (0x000007ffU & ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__left_q) 
                                          - (IData)(1U)));
                    __Vdly__tb_secure_boot__DOT__dut__DOT__state_q = 8U;
                }
            } else if ((2U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__state_q))) {
                if ((1U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__state_q))) {
                    if (vlSelfRef.tb_secure_boot__DOT__vrv) {
                        __Vfunc_tb_secure_boot__DOT__dut__DOT__bswap__6__v 
                            = vlSelfRef.tb_secure_boot__DOT__vrdata;
                        __Vfunc_tb_secure_boot__DOT__dut__DOT__bswap__6__Vfuncout 
                            = ((((0x0000ff00U & (__Vfunc_tb_secure_boot__DOT__dut__DOT__bswap__6__v 
                                                 << 8U)) 
                                 | (0x000000ffU & (__Vfunc_tb_secure_boot__DOT__dut__DOT__bswap__6__v 
                                                   >> 8U))) 
                                << 0x00000010U) | (
                                                   (0x0000ff00U 
                                                    & (__Vfunc_tb_secure_boot__DOT__dut__DOT__bswap__6__v 
                                                       >> 8U)) 
                                                   | (__Vfunc_tb_secure_boot__DOT__dut__DOT__bswap__6__v 
                                                      >> 0x18U)));
                        vlSelfRef.tb_secure_boot__DOT__dut__DOT__word_q 
                            = __Vfunc_tb_secure_boot__DOT__dut__DOT__bswap__6__Vfuncout;
                        __Vdly__tb_secure_boot__DOT__dut__DOT__state_q = 0x0cU;
                    }
                } else if (vlSelfRef.tb_secure_boot__DOT__vreq) {
                    __Vdly__tb_secure_boot__DOT__dut__DOT__state_q = 0x0bU;
                }
            } else if ((1U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__state_q))) {
                if (vlSelfRef.tb_secure_boot__DOT__dut__DOT__c_rvalid_q) {
                    __Vdly__tb_secure_boot__DOT__dut__DOT__state_q 
                        = ((2U & vlSelfRef.tb_secure_boot__DOT__dut__DOT__c_rdata)
                            ? 0x0aU : 8U);
                }
            } else if ((0U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__left_q))) {
                __Vdly__tb_secure_boot__DOT__dut__DOT__state_q = 0x0dU;
            } else if (vlSelfRef.tb_secure_boot__DOT__dut__DOT__c_gnt) {
                __Vdly__tb_secure_boot__DOT__dut__DOT__state_q = 9U;
            }
        } else if ((4U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__state_q))) {
            if ((2U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__state_q))) {
                if ((1U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__state_q))) {
                    if (vlSelfRef.tb_secure_boot__DOT__dut__DOT__c_gnt) {
                        __Vdly__tb_secure_boot__DOT__dut__DOT__state_q = 8U;
                    }
                } else if (vlSelfRef.tb_secure_boot__DOT__dut__DOT__c_gnt) {
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__idx_q 
                        = (0x000007ffU & ((IData)(1U) 
                                          + (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__idx_q)));
                    __Vdly__tb_secure_boot__DOT__dut__DOT__state_q 
                        = ((0x0010U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__idx_q))
                            ? 7U : 4U);
                }
            } else if ((1U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__state_q))) {
                if (vlSelfRef.tb_secure_boot__DOT__vrv) {
                    __Vfunc_tb_secure_boot__DOT__dut__DOT__bswap__7__v 
                        = vlSelfRef.tb_secure_boot__DOT__vrdata;
                    __Vfunc_tb_secure_boot__DOT__dut__DOT__bswap__7__Vfuncout 
                        = ((((0x0000ff00U & (__Vfunc_tb_secure_boot__DOT__dut__DOT__bswap__7__v 
                                             << 8U)) 
                             | (0x000000ffU & (__Vfunc_tb_secure_boot__DOT__dut__DOT__bswap__7__v 
                                               >> 8U))) 
                            << 0x00000010U) | ((0x0000ff00U 
                                                & (__Vfunc_tb_secure_boot__DOT__dut__DOT__bswap__7__v 
                                                   >> 8U)) 
                                               | (__Vfunc_tb_secure_boot__DOT__dut__DOT__bswap__7__v 
                                                  >> 0x18U)));
                    vlSelfRef.tb_secure_boot__DOT__dut__DOT__word_q 
                        = __Vfunc_tb_secure_boot__DOT__dut__DOT__bswap__7__Vfuncout;
                    __Vdly__tb_secure_boot__DOT__dut__DOT__state_q = 6U;
                }
            } else if (vlSelfRef.tb_secure_boot__DOT__vreq) {
                __Vdly__tb_secure_boot__DOT__dut__DOT__state_q = 5U;
            }
        } else if ((2U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__state_q))) {
            if ((1U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__state_q))) {
                if (vlSelfRef.tb_secure_boot__DOT__dut__DOT__c_gnt) {
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__idx_q = 1U;
                    __Vdly__tb_secure_boot__DOT__dut__DOT__state_q = 4U;
                }
            } else if (vlSelfRef.tb_secure_boot__DOT__vrv) {
                __Vfunc_tb_secure_boot__DOT__dut__DOT__bswap__8__v 
                    = vlSelfRef.tb_secure_boot__DOT__vrdata;
                __Vfunc_tb_secure_boot__DOT__dut__DOT__bswap__9__v 
                    = vlSelfRef.tb_secure_boot__DOT__vrdata;
                __Vfunc_tb_secure_boot__DOT__dut__DOT__bswap__8__Vfuncout 
                    = ((((0x0000ff00U & (__Vfunc_tb_secure_boot__DOT__dut__DOT__bswap__8__v 
                                         << 8U)) | 
                         (0x000000ffU & (__Vfunc_tb_secure_boot__DOT__dut__DOT__bswap__8__v 
                                         >> 8U))) << 0x00000010U) 
                       | ((0x0000ff00U & (__Vfunc_tb_secure_boot__DOT__dut__DOT__bswap__8__v 
                                          >> 8U)) | 
                          (__Vfunc_tb_secure_boot__DOT__dut__DOT__bswap__8__v 
                           >> 0x18U)));
                vlSelfRef.tb_secure_boot__DOT__dut__DOT____VlemCall_0__bswap 
                    = ((((0x0000ff00U & (__Vfunc_tb_secure_boot__DOT__dut__DOT__bswap__9__v 
                                         << 8U)) | 
                         (0x000000ffU & (__Vfunc_tb_secure_boot__DOT__dut__DOT__bswap__9__v 
                                         >> 8U))) << 0x00000010U) 
                       | ((0x0000ff00U & (__Vfunc_tb_secure_boot__DOT__dut__DOT__bswap__9__v 
                                          >> 8U)) | 
                          (__Vfunc_tb_secure_boot__DOT__dut__DOT__bswap__9__v 
                           >> 0x18U)));
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__word_q 
                    = __Vfunc_tb_secure_boot__DOT__dut__DOT__bswap__8__Vfuncout;
                __Vfunc_tb_secure_boot__DOT__dut__DOT__bswap__10__v 
                    = vlSelfRef.tb_secure_boot__DOT__vrdata;
                vlSelfRef.tb_secure_boot__DOT__dut__DOT____VlemCall_1__bswap 
                    = ((((0x0000ff00U & (__Vfunc_tb_secure_boot__DOT__dut__DOT__bswap__10__v 
                                         << 8U)) | 
                         (0x000000ffU & (__Vfunc_tb_secure_boot__DOT__dut__DOT__bswap__10__v 
                                         >> 8U))) << 0x00000010U) 
                       | ((0x0000ff00U & (__Vfunc_tb_secure_boot__DOT__dut__DOT__bswap__10__v 
                                          >> 8U)) | 
                          (__Vfunc_tb_secure_boot__DOT__dut__DOT__bswap__10__v 
                           >> 0x18U)));
                if (((0x00000011U > vlSelfRef.tb_secure_boot__DOT__dut__DOT____VlemCall_0__bswap) 
                     | (0x000003efU < (vlSelfRef.tb_secure_boot__DOT__dut__DOT____VlemCall_1__bswap 
                                       - (IData)(0x00000010U))))) {
                    vlSelfRef.tb_secure_boot__DOT__dut__DOT__err_q = 1U;
                    vlSelfRef.tb_secure_boot__DOT__dut__DOT__done_q = 1U;
                    __Vdly__tb_secure_boot__DOT__dut__DOT__state_q = 0U;
                } else {
                    __Vfunc_tb_secure_boot__DOT__dut__DOT__bswap__11__v 
                        = vlSelfRef.tb_secure_boot__DOT__vrdata;
                    __Vfunc_tb_secure_boot__DOT__dut__DOT__bswap__12__v 
                        = vlSelfRef.tb_secure_boot__DOT__vrdata;
                    vlSelfRef.tb_secure_boot__DOT__dut__DOT____VlemCall_2__bswap 
                        = ((((0x0000ff00U & (__Vfunc_tb_secure_boot__DOT__dut__DOT__bswap__11__v 
                                             << 8U)) 
                             | (0x000000ffU & (__Vfunc_tb_secure_boot__DOT__dut__DOT__bswap__11__v 
                                               >> 8U))) 
                            << 0x00000010U) | ((0x0000ff00U 
                                                & (__Vfunc_tb_secure_boot__DOT__dut__DOT__bswap__11__v 
                                                   >> 8U)) 
                                               | (__Vfunc_tb_secure_boot__DOT__dut__DOT__bswap__11__v 
                                                  >> 0x18U)));
                    vlSelfRef.tb_secure_boot__DOT__dut__DOT____VlemCall_3__bswap 
                        = ((((0x0000ff00U & (__Vfunc_tb_secure_boot__DOT__dut__DOT__bswap__12__v 
                                             << 8U)) 
                             | (0x000000ffU & (__Vfunc_tb_secure_boot__DOT__dut__DOT__bswap__12__v 
                                               >> 8U))) 
                            << 0x00000010U) | ((0x0000ff00U 
                                                & (__Vfunc_tb_secure_boot__DOT__dut__DOT__bswap__12__v 
                                                   >> 8U)) 
                                               | (__Vfunc_tb_secure_boot__DOT__dut__DOT__bswap__12__v 
                                                  >> 0x18U)));
                    vlSelfRef.tb_secure_boot__DOT__dut__DOT__code_words_q 
                        = (0x000007ffU & (vlSelfRef.tb_secure_boot__DOT__dut__DOT____VlemCall_2__bswap 
                                          - (IData)(0x0010U)));
                    __Vdly__tb_secure_boot__DOT__dut__DOT__left_q 
                        = (0x000007ffU & (vlSelfRef.tb_secure_boot__DOT__dut__DOT____VlemCall_3__bswap 
                                          - (IData)(0x0010U)));
                    __Vdly__tb_secure_boot__DOT__dut__DOT__state_q = 3U;
                }
            }
        } else if ((1U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__state_q))) {
            if (vlSelfRef.tb_secure_boot__DOT__vreq) {
                __Vdly__tb_secure_boot__DOT__dut__DOT__state_q = 2U;
            }
        } else if (((IData)(vlSelfRef.tb_secure_boot__DOT__req) 
                    & ((IData)(vlSelfRef.tb_secure_boot__DOT__we) 
                       & ((0U == (0x00000fffU & vlSelfRef.tb_secure_boot__DOT__addr)) 
                          & vlSelfRef.tb_secure_boot__DOT__wdata)))) {
            vlSelfRef.tb_secure_boot__DOT__dut__DOT__done_q = 0U;
            vlSelfRef.tb_secure_boot__DOT__dut__DOT__valid_q = 0U;
            vlSelfRef.tb_secure_boot__DOT__dut__DOT__verified_q = 0U;
            vlSelfRef.tb_secure_boot__DOT__dut__DOT__dirty_q = 0U;
            if (vlSelfRef.tb_secure_boot__DOT__dut__DOT__ran_q) {
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__err_q = 1U;
            } else {
                vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__idx_q = 0U;
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__err_q = 0U;
                __Vdly__tb_secure_boot__DOT__dut__DOT__state_q = 1U;
            }
        }
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__ran_q 
            = __Vdly__tb_secure_boot__DOT__dut__DOT__ran_q;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__left_q 
            = __Vdly__tb_secure_boot__DOT__dut__DOT__left_q;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__state_q 
            = __Vdly__tb_secure_boot__DOT__dut__DOT__state_q;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__c_rvalid_q 
            = ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__c_gnt) 
               & (~ (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__c_we)));
    } else {
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__g_div__DOT__div_q = 0U;
        vlSelfRef.tb_secure_boot__DOT__rdata = 0U;
        vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__idx_q = 0U;
        __Vdly__tb_secure_boot__DOT__dut__DOT__left_q = 0U;
        __Vdly__tb_secure_boot__DOT__dut__DOT__state_q = 0U;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__code_words_q = 0U;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__word_q = 0U;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__done_q = 0U;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__valid_q = 0U;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__verified_q = 0U;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__err_q = 0U;
        __Vdly__tb_secure_boot__DOT__dut__DOT__ran_q = 0U;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__dirty_q = 0U;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__ran_q 
            = __Vdly__tb_secure_boot__DOT__dut__DOT__ran_q;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__left_q 
            = __Vdly__tb_secure_boot__DOT__dut__DOT__left_q;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__state_q 
            = __Vdly__tb_secure_boot__DOT__dut__DOT__state_q;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__c_rvalid_q = 0U;
    }
}

extern const VlUnpacked<CData/*4:0*/, 2048> Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0;
extern const VlWide<8>/*255:0*/ Vtb_secure_boot__ConstPool__CONST_h02361856_0;
extern const VlUnpacked<CData/*0:0*/, 2048> Vtb_secure_boot__ConstPool__TABLE_hcb85b0e9_0;
extern const VlWide<8>/*255:0*/ Vtb_secure_boot__ConstPool__CONST_h90cf5efa_0;
extern const VlUnpacked<CData/*0:0*/, 2048> Vtb_secure_boot__ConstPool__TABLE_h30ac052b_0;
extern const VlUnpacked<CData/*4:0*/, 2048> Vtb_secure_boot__ConstPool__TABLE_h377e3154_0;
extern const VlUnpacked<CData/*4:0*/, 2048> Vtb_secure_boot__ConstPool__TABLE_h11331d69_0;

void Vtb_secure_boot___024root___nba_sequent__TOP__2(Vtb_secure_boot___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_secure_boot___024root___nba_sequent__TOP__2\n"); );
    Vtb_secure_boot__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    VlWide<8>/*255:0*/ __Vtemp_3;
    VlWide<8>/*255:0*/ __Vtemp_4;
    VlWide<8>/*255:0*/ __Vtemp_5;
    // Body
    vlSelfRef.__VdlySet__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0 = 0U;
    if (((0U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
          ? (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_ext_we)
          : (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__reg_we))) {
        if ((2U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_dsel))) {
            VL_ASSIGN_W(256, vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0, Vtb_secure_boot__ConstPool__CONST_h9e67c271_0);
        } else if ((1U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_dsel))) {
            vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[0U] 
                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_din[0U];
            vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[1U] 
                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_din[1U];
            vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[2U] 
                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_din[2U];
            vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[3U] 
                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_din[3U];
            vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[4U] 
                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_din[4U];
            vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[5U] 
                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_din[5U];
            vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[6U] 
                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_din[6U];
            vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[7U] 
                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_din[7U];
        } else if (vlSelfRef.__VdfgRegularize_h6e95ff9d_0_13) {
            if (vlSelfRef.__VdfgRegularize_h6e95ff9d_0_8) {
                if (vlSelfRef.__VdfgRegularize_h6e95ff9d_0_2) {
                    if (((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__x_sign) 
                         == (1U & vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                             [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                             [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][0U]))) {
                        vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[0U] 
                            = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                            [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                            [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][0U];
                        vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[1U] 
                            = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                            [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                            [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][1U];
                        vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[2U] 
                            = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                            [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                            [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][2U];
                        vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[3U] 
                            = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                            [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                            [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][3U];
                        vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[4U] 
                            = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                            [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                            [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][4U];
                        vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[5U] 
                            = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                            [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                            [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][5U];
                        vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[6U] 
                            = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                            [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                            [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][6U];
                        vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[7U] 
                            = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                            [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                            [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][7U];
                    } else {
                        VL_SUB_W(8, vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0, Vtb_secure_boot__ConstPool__CONST_h02361856_0, vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                                 [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                                 [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]]);
                    }
                } else {
                    vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[0U] 
                        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                        [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                        [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][0U];
                    vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[1U] 
                        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                        [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                        [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][1U];
                    vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[2U] 
                        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                        [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                        [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][2U];
                    vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[3U] 
                        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                        [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                        [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][3U];
                    vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[4U] 
                        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                        [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                        [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][4U];
                    vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[5U] 
                        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                        [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                        [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][5U];
                    vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[6U] 
                        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                        [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                        [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][6U];
                    vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[7U] 
                        = (0x7fffffffU & vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                           [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                           [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][7U]);
                }
            } else if (vlSelfRef.__VdfgRegularize_h6e95ff9d_0_2) {
                if (Vtb_secure_boot__ConstPool__TABLE_hcb85b0e9_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]) {
                    if ((1U & vlSelfRef.__VdfgRegularize_h6e95ff9d_0_14[8U])) {
                        __Vtemp_3[0U] = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_14[0U];
                        __Vtemp_3[1U] = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_14[1U];
                        __Vtemp_3[2U] = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_14[2U];
                        __Vtemp_3[3U] = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_14[3U];
                        __Vtemp_3[4U] = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_14[4U];
                        __Vtemp_3[5U] = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_14[5U];
                        __Vtemp_3[6U] = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_14[6U];
                        __Vtemp_3[7U] = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_14[7U];
                        VL_SUB_W(8, vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0, __Vtemp_3, Vtb_secure_boot__ConstPool__CONST_h90cf5efa_0);
                    } else {
                        vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[0U] 
                            = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_14[0U];
                        vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[1U] 
                            = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_14[1U];
                        vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[2U] 
                            = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_14[2U];
                        vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[3U] 
                            = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_14[3U];
                        vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[4U] 
                            = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_14[4U];
                        vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[5U] 
                            = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_14[5U];
                        vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[6U] 
                            = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_14[6U];
                        vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[7U] 
                            = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_14[7U];
                    }
                } else {
                    vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[0U] 
                        = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_14[0U];
                    vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[1U] 
                        = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_14[1U];
                    vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[2U] 
                        = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_14[2U];
                    vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[3U] 
                        = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_14[3U];
                    vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[4U] 
                        = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_14[4U];
                    vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[5U] 
                        = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_14[5U];
                    vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[6U] 
                        = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_14[6U];
                    vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[7U] 
                        = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_14[7U];
                }
            } else {
                vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[0U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][0U];
                vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[1U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][1U];
                vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[2U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][2U];
                vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[3U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][3U];
                vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[4U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][4U];
                vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[5U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][5U];
                vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[6U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][6U];
                vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[7U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][7U];
            }
        } else if (vlSelfRef.__VdfgRegularize_h6e95ff9d_0_8) {
            if (vlSelfRef.__VdfgRegularize_h6e95ff9d_0_2) {
                vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[0U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][0U];
                vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[1U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][1U];
                vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[2U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][2U];
                vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[3U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][3U];
                vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[4U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][4U];
                vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[5U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][5U];
                vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[6U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][6U];
                vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[7U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][7U];
            } else if (Vtb_secure_boot__ConstPool__TABLE_hcb85b0e9_0
                       [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]) {
                if (VL_LTE_W(8, Vtb_secure_boot__ConstPool__CONST_h02361856_0, vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__u_pm_reducer__DOT__stage2_sum)) {
                    VL_SUB_W(8, vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0, vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__u_pm_reducer__DOT__stage2_sum, Vtb_secure_boot__ConstPool__CONST_h02361856_0);
                } else {
                    vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[0U] 
                        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__u_pm_reducer__DOT__stage2_sum[0U];
                    vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[1U] 
                        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__u_pm_reducer__DOT__stage2_sum[1U];
                    vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[2U] 
                        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__u_pm_reducer__DOT__stage2_sum[2U];
                    vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[3U] 
                        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__u_pm_reducer__DOT__stage2_sum[3U];
                    vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[4U] 
                        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__u_pm_reducer__DOT__stage2_sum[4U];
                    vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[5U] 
                        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__u_pm_reducer__DOT__stage2_sum[5U];
                    vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[6U] 
                        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__u_pm_reducer__DOT__stage2_sum[6U];
                    vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[7U] 
                        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__u_pm_reducer__DOT__stage2_sum[7U];
                }
            } else if (Vtb_secure_boot__ConstPool__TABLE_h30ac052b_0
                       [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]) {
                vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[0U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[8U];
                vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[1U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[9U];
                vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[2U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[10U];
                vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[3U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[11U];
                vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[4U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[12U];
                vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[5U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[13U];
                vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[6U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[14U];
                vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[7U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[15U];
            } else {
                vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[0U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[0U];
                vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[1U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[1U];
                vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[2U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[2U];
                vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[3U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[3U];
                vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[4U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[4U];
                vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[5U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[5U];
                vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[6U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[6U];
                vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[7U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[7U];
            }
        } else if (vlSelfRef.__VdfgRegularize_h6e95ff9d_0_2) {
            if (VL_GTE_W(8, vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                         [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                         [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]], vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                         [Vtb_secure_boot__ConstPool__TABLE_h377e3154_0
                         [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]])) {
                VL_SUB_W(8, vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0, vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                         [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                         [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]], vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                         [Vtb_secure_boot__ConstPool__TABLE_h377e3154_0
                         [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]]);
            } else {
                vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[0U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][0U];
                vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[1U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][1U];
                vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[2U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][2U];
                vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[3U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][3U];
                vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[4U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][4U];
                vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[5U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][5U];
                vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[6U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][6U];
                vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[7U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][7U];
            }
        } else if (Vtb_secure_boot__ConstPool__TABLE_hcb85b0e9_0
                   [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]) {
            __Vtemp_4[0U] = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_22[0U];
            __Vtemp_4[1U] = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_22[1U];
            __Vtemp_4[2U] = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_22[2U];
            __Vtemp_4[3U] = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_22[3U];
            __Vtemp_4[4U] = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_22[4U];
            __Vtemp_4[5U] = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_22[5U];
            __Vtemp_4[6U] = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_22[6U];
            __Vtemp_4[7U] = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_22[7U];
            if ((1U & (VL_LTE_W(8, Vtb_secure_boot__ConstPool__CONST_h02361856_0, __Vtemp_4) 
                       | ((~ (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_2)) 
                          & ((~ (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_13)) 
                             & ((~ (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_8)) 
                                & vlSelfRef.__VdfgRegularize_h6e95ff9d_0_22[8U])))))) {
                __Vtemp_5[0U] = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_22[0U];
                __Vtemp_5[1U] = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_22[1U];
                __Vtemp_5[2U] = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_22[2U];
                __Vtemp_5[3U] = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_22[3U];
                __Vtemp_5[4U] = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_22[4U];
                __Vtemp_5[5U] = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_22[5U];
                __Vtemp_5[6U] = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_22[6U];
                __Vtemp_5[7U] = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_22[7U];
                VL_SUB_W(8, vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0, __Vtemp_5, Vtb_secure_boot__ConstPool__CONST_h02361856_0);
            } else {
                vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[0U] 
                    = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_22[0U];
                vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[1U] 
                    = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_22[1U];
                vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[2U] 
                    = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_22[2U];
                vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[3U] 
                    = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_22[3U];
                vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[4U] 
                    = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_22[4U];
                vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[5U] 
                    = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_22[5U];
                vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[6U] 
                    = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_22[6U];
                vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[7U] 
                    = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_22[7U];
            }
        } else {
            vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[0U] 
                = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_22[0U];
            vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[1U] 
                = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_22[1U];
            vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[2U] 
                = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_22[2U];
            vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[3U] 
                = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_22[3U];
            vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[4U] 
                = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_22[4U];
            vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[5U] 
                = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_22[5U];
            vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[6U] 
                = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_22[6U];
            vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[7U] 
                = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_22[7U];
        }
        vlSelfRef.__VdlyDim0__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0 
            = ((0U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
                ? (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_dest)
                : Vtb_secure_boot__ConstPool__TABLE_h11331d69_0
               [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]);
        vlSelfRef.__VdlySet__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0 = 1U;
    }
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__k_i 
        = ((0x4fU >= (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__round_count))
            ? vlSymsp->TOP__sha512_pkg.K[vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__round_count]
            : 0ULL);
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__w_i 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w[0U];
}

extern const VlUnpacked<CData/*2:0*/, 2048> Vtb_secure_boot__ConstPool__TABLE_h54cb72e1_0;
extern const VlUnpacked<CData/*0:0*/, 2048> Vtb_secure_boot__ConstPool__TABLE_h6554e332_0;
extern const VlWide<8>/*255:0*/ Vtb_secure_boot__ConstPool__CONST_h4e9f510d_0;
extern const VlWide<8>/*255:0*/ Vtb_secure_boot__ConstPool__CONST_hbf60ba67_0;
extern const VlWide<8>/*255:0*/ Vtb_secure_boot__ConstPool__CONST_h54eb12df_0;
extern const VlWide<8>/*255:0*/ Vtb_secure_boot__ConstPool__CONST_h2107f3e0_0;
extern const VlWide<8>/*255:0*/ Vtb_secure_boot__ConstPool__CONST_h577f31a6_0;
extern const VlWide<8>/*255:0*/ Vtb_secure_boot__ConstPool__CONST_h0d6d13b6_0;
extern const VlWide<8>/*255:0*/ Vtb_secure_boot__ConstPool__CONST_h6a034bfc_0;
extern const VlWide<8>/*255:0*/ Vtb_secure_boot__ConstPool__CONST_h57168600_0;
extern const VlWide<8>/*255:0*/ Vtb_secure_boot__ConstPool__CONST_h3c06021b_0;
extern const VlWide<8>/*255:0*/ Vtb_secure_boot__ConstPool__CONST_h06733129_0;
extern const VlWide<16>/*511:0*/ Vtb_secure_boot__ConstPool__CONST_h93e1b771_0;
extern const VlWide<9>/*287:0*/ Vtb_secure_boot__ConstPool__CONST_h0efaa2d9_0;

void Vtb_secure_boot___024root___nba_sequent__TOP__4(Vtb_secure_boot___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_secure_boot___024root___nba_sequent__TOP__4\n"); );
    Vtb_secure_boot__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    VlWide<16>/*511:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__pm_input;
    VL_ZERO_W(512, tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__pm_input);
    VlWide<9>/*262:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__u_pm_reducer__DOT__stage1_sum;
    VL_ZERO_W(263, tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__u_pm_reducer__DOT__stage1_sum);
    QData/*63:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT____VlemCall_1__lower_sigma0;
    QData/*63:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT____VlemCall_0__lower_sigma1;
    Vtb_secure_boot_csa_t__struct__0 tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__stage1;
    tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__stage1.__PVT__sum = 0;
    tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__stage1.__PVT__carry = 0;
    Vtb_secure_boot_csa_t__struct__0 tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__stage2;
    tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__stage2.__PVT__sum = 0;
    tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__stage2.__PVT__carry = 0;
    QData/*63:0*/ __Vfunc_lower_sigma1__26__x;
    __Vfunc_lower_sigma1__26__x = 0;
    QData/*63:0*/ __Vfunc_lower_sigma1__26____VlefCall_2__shr;
    __Vfunc_lower_sigma1__26____VlefCall_2__shr = 0;
    QData/*63:0*/ __Vfunc_lower_sigma1__26____VlefCall_1__rotr;
    __Vfunc_lower_sigma1__26____VlefCall_1__rotr = 0;
    QData/*63:0*/ __Vfunc_lower_sigma1__26____VlefCall_0__rotr;
    __Vfunc_lower_sigma1__26____VlefCall_0__rotr = 0;
    QData/*63:0*/ __Vfunc_rotr__27__Vfuncout;
    __Vfunc_rotr__27__Vfuncout = 0;
    QData/*63:0*/ __Vfunc_rotr__27__value;
    __Vfunc_rotr__27__value = 0;
    QData/*63:0*/ __Vfunc_rotr__28__Vfuncout;
    __Vfunc_rotr__28__Vfuncout = 0;
    QData/*63:0*/ __Vfunc_rotr__28__value;
    __Vfunc_rotr__28__value = 0;
    QData/*63:0*/ __Vfunc_shr__29__Vfuncout;
    __Vfunc_shr__29__Vfuncout = 0;
    QData/*63:0*/ __Vfunc_shr__29__value;
    __Vfunc_shr__29__value = 0;
    QData/*63:0*/ __Vfunc_lower_sigma0__30__x;
    __Vfunc_lower_sigma0__30__x = 0;
    QData/*63:0*/ __Vfunc_lower_sigma0__30____VlefCall_2__shr;
    __Vfunc_lower_sigma0__30____VlefCall_2__shr = 0;
    QData/*63:0*/ __Vfunc_lower_sigma0__30____VlefCall_1__rotr;
    __Vfunc_lower_sigma0__30____VlefCall_1__rotr = 0;
    QData/*63:0*/ __Vfunc_lower_sigma0__30____VlefCall_0__rotr;
    __Vfunc_lower_sigma0__30____VlefCall_0__rotr = 0;
    QData/*63:0*/ __Vfunc_rotr__31__Vfuncout;
    __Vfunc_rotr__31__Vfuncout = 0;
    QData/*63:0*/ __Vfunc_rotr__31__value;
    __Vfunc_rotr__31__value = 0;
    QData/*63:0*/ __Vfunc_rotr__32__Vfuncout;
    __Vfunc_rotr__32__Vfuncout = 0;
    QData/*63:0*/ __Vfunc_rotr__32__value;
    __Vfunc_rotr__32__value = 0;
    QData/*63:0*/ __Vfunc_shr__33__Vfuncout;
    __Vfunc_shr__33__Vfuncout = 0;
    QData/*63:0*/ __Vfunc_shr__33__value;
    __Vfunc_shr__33__value = 0;
    Vtb_secure_boot_csa_t__struct__0 __Vfunc_csa64__34__Vfuncout;
    __Vfunc_csa64__34__Vfuncout.__PVT__sum = 0;
    __Vfunc_csa64__34__Vfuncout.__PVT__carry = 0;
    QData/*63:0*/ __Vfunc_csa64__34__a;
    __Vfunc_csa64__34__a = 0;
    QData/*63:0*/ __Vfunc_csa64__34__b;
    __Vfunc_csa64__34__b = 0;
    QData/*63:0*/ __Vfunc_csa64__34__c;
    __Vfunc_csa64__34__c = 0;
    Vtb_secure_boot_csa_t__struct__0 __Vfunc_csa64__34__res;
    __Vfunc_csa64__34__res.__PVT__sum = 0;
    __Vfunc_csa64__34__res.__PVT__carry = 0;
    Vtb_secure_boot_csa_t__struct__0 __Vfunc_csa64__35__Vfuncout;
    __Vfunc_csa64__35__Vfuncout.__PVT__sum = 0;
    __Vfunc_csa64__35__Vfuncout.__PVT__carry = 0;
    QData/*63:0*/ __Vfunc_csa64__35__a;
    __Vfunc_csa64__35__a = 0;
    QData/*63:0*/ __Vfunc_csa64__35__b;
    __Vfunc_csa64__35__b = 0;
    QData/*63:0*/ __Vfunc_csa64__35__c;
    __Vfunc_csa64__35__c = 0;
    Vtb_secure_boot_csa_t__struct__0 __Vfunc_csa64__35__res;
    __Vfunc_csa64__35__res.__PVT__sum = 0;
    __Vfunc_csa64__35__res.__PVT__carry = 0;
    QData/*63:0*/ __VdfgRegularize_h6e95ff9d_0_26;
    __VdfgRegularize_h6e95ff9d_0_26 = 0;
    QData/*63:0*/ __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v0;
    __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v0 = 0;
    QData/*63:0*/ __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v1;
    __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v1 = 0;
    QData/*63:0*/ __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v2;
    __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v2 = 0;
    QData/*63:0*/ __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v3;
    __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v3 = 0;
    QData/*63:0*/ __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v4;
    __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v4 = 0;
    QData/*63:0*/ __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v5;
    __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v5 = 0;
    QData/*63:0*/ __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v6;
    __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v6 = 0;
    QData/*63:0*/ __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v7;
    __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v7 = 0;
    QData/*63:0*/ __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v8;
    __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v8 = 0;
    QData/*63:0*/ __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v9;
    __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v9 = 0;
    QData/*63:0*/ __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v10;
    __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v10 = 0;
    QData/*63:0*/ __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v11;
    __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v11 = 0;
    QData/*63:0*/ __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v12;
    __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v12 = 0;
    QData/*63:0*/ __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v13;
    __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v13 = 0;
    QData/*63:0*/ __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v14;
    __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v14 = 0;
    QData/*63:0*/ __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v15;
    __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v15 = 0;
    QData/*63:0*/ __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v16;
    __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v16 = 0;
    QData/*63:0*/ __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v17;
    __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v17 = 0;
    QData/*63:0*/ __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v18;
    __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v18 = 0;
    QData/*63:0*/ __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v19;
    __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v19 = 0;
    QData/*63:0*/ __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v20;
    __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v20 = 0;
    QData/*63:0*/ __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v21;
    __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v21 = 0;
    QData/*63:0*/ __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v22;
    __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v22 = 0;
    QData/*63:0*/ __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v23;
    __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v23 = 0;
    VlWide<10>/*319:0*/ __Vtemp_6;
    VlWide<4>/*127:0*/ __Vtemp_8;
    VlWide<4>/*127:0*/ __Vtemp_9;
    VlWide<9>/*287:0*/ __Vtemp_11;
    VlWide<9>/*287:0*/ __Vtemp_12;
    VlWide<9>/*287:0*/ __Vtemp_14;
    VlWide<9>/*287:0*/ __Vtemp_16;
    VlWide<9>/*287:0*/ __Vtemp_17;
    VlWide<8>/*255:0*/ __Vtemp_18;
    VlWide<8>/*255:0*/ __Vtemp_21;
    // Body
    if (vlSelfRef.__VdlySet__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v0) {
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w[vlSelfRef.__VdlyDim0__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v0] 
            = ((0xffffffff00000000ULL & vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w
                [vlSelfRef.__VdlyDim0__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v0]) 
               | (IData)((IData)(vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v0)));
    }
    if (vlSelfRef.__VdlySet__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v1) {
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w[vlSelfRef.__VdlyDim0__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v1] 
            = ((0x00000000ffffffffULL & vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w
                [vlSelfRef.__VdlyDim0__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v1]) 
               | ((QData)((IData)(vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v1)) 
                  << 0x00000020U));
    }
    if (vlSelfRef.__VdlySet__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v2) {
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w[0U] 
            = vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v2;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w[1U] 
            = vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v3;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w[2U] 
            = vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v4;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w[3U] 
            = vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v5;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w[4U] 
            = vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v6;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w[5U] 
            = vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v7;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w[6U] 
            = vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v8;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w[7U] 
            = vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v9;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w[8U] 
            = vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v10;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w[9U] 
            = vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v11;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w[10U] 
            = vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v12;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w[11U] 
            = vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v13;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w[12U] 
            = vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v14;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w[13U] 
            = vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v15;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w[14U] 
            = vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v16;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w[15U] 
            = vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v17;
    }
    if (vlSelfRef.__VdlySet__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v18) {
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w[0U] = 0ULL;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w[1U] = 0ULL;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w[2U] = 0ULL;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w[3U] = 0ULL;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w[4U] = 0ULL;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w[5U] = 0ULL;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w[6U] = 0ULL;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w[7U] = 0ULL;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w[8U] = 0ULL;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w[9U] = 0ULL;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w[10U] = 0ULL;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w[11U] = 0ULL;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w[12U] = 0ULL;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w[13U] = 0ULL;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w[14U] = 0ULL;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w[15U] = 0ULL;
    }
    if (vlSelfRef.tb_secure_boot__DOT__rst_n) {
        if (((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__c_gnt) 
             & (~ (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__c_we)))) {
            vlSelfRef.tb_secure_boot__DOT__dut__DOT__c_rdata 
                = ((4U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__c_addr))
                    ? ((((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_valid) 
                         << 3U) | ((0x11U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__state)) 
                                   << 2U)) | ((((~ (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__data_pending)) 
                                                & (8U 
                                                   == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__state))) 
                                               << 1U) 
                                              | (0U 
                                                 != (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__state))))
                    : ((8U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__c_addr))
                        ? vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__msg_len_csr
                        : 0xdeadbeefU));
        }
        if ((6U == Vtb_secure_boot__ConstPool__TABLE_h54cb72e1_0
             [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0])) {
            vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__x_sign 
                = ((~ (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_2)) 
                   & ((vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                       [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                       [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][7U] 
                       >> 0x0000001fU) & (3U == (3U 
                                                 & (Vtb_secure_boot__ConstPool__TABLE_h54cb72e1_0
                                                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0] 
                                                    >> 1U)))));
        }
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__reg_we = 0U;
        if ((4U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__sub_step))) {
            if ((2U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__sub_step))) {
                vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__sub_step = 0U;
            } else if ((1U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__sub_step))) {
                vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__sub_step = 0U;
            } else if (Vtb_secure_boot__ConstPool__TABLE_h6554e332_0
                       [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]) {
                vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__seq_done_reg = 1U;
                vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__sub_step = 0U;
            } else {
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__step_counter 
                    = (0x0000003fU & ((IData)(1U) + (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__step_counter)));
                vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__sub_step = 1U;
            }
        } else if ((2U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__sub_step))) {
            if ((1U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__sub_step))) {
                if (((2U != Vtb_secure_boot__ConstPool__TABLE_h54cb72e1_0
                      [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]) 
                     | (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__mult_done))) {
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__sub_step = 4U;
                    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__reg_we = 1U;
                }
            } else {
                vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__sub_step = 3U;
            }
        } else if ((1U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__sub_step))) {
            vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__sub_step 
                = ((2U == Vtb_secure_boot__ConstPool__TABLE_h54cb72e1_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0])
                    ? 2U : 3U);
        } else {
            vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__seq_done_reg = 0U;
            if (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__start_seq_reg) {
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__step_counter = 0U;
                vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__sub_step = 1U;
            }
        }
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_wen = 0U;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_start = 0U;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__otp_rd_en = 0U;
        if (vlSelfRef.tb_secure_boot__DOT__dut__DOT____Vcellinp__u_crypto__start_verify_i) {
            vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__start_latch = 1U;
        }
        if (((IData)((0U != (6U & vlSelfRef.tb_secure_boot__DOT__dut__DOT__c_wdata))) 
             & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ctrl_wr))) {
            vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__state = 0U;
            vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_fed = 0U;
            vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__blk_ptr = 0U;
            vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__otp_idx = 0U;
            vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_idx = 0U;
        } else if ((0x00000010U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__state))) {
            if ((8U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__state))) {
                vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__state = 0U;
            } else if ((4U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__state))) {
                vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__state = 0U;
            } else if ((2U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__state))) {
                vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__state = 0U;
            } else if ((1U & (~ (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__state)))) {
                if (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_done) {
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__state = 0x11U;
                }
            }
        } else if ((8U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__state))) {
            if ((4U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__state))) {
                if ((2U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__state))) {
                    if ((1U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__state))) {
                        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_start = 1U;
                        vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__state = 0x10U;
                    } else {
                        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_dsel = 0U;
                        if (((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__start_latch) 
                             | (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT____Vcellinp__u_crypto__start_verify_i))) {
                            vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__start_latch = 0U;
                            vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__state = 0x0fU;
                        }
                    }
                } else if ((1U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__state))) {
                    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_ext_we = 1U;
                    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_dsel = 1U;
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__load_idx 
                        = (0x0000001fU & ((IData)(1U) 
                                          + (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__load_idx)));
                    if (((((((((0U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__load_idx)) 
                               | (1U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__load_idx))) 
                              | (2U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__load_idx))) 
                             | (3U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__load_idx))) 
                            | (4U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__load_idx))) 
                           | (5U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__load_idx))) 
                          | (6U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__load_idx))) 
                         | (7U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__load_idx)))) {
                        if ((0U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__load_idx))) {
                            vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_dest = 0x18U;
                            VL_ASSIGN_W(256, vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_din, Vtb_secure_boot__ConstPool__CONST_h9e67c271_0);
                        } else if ((1U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__load_idx))) {
                            vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_dest = 0x19U;
                            VL_ASSIGN_W(256, vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_din, Vtb_secure_boot__ConstPool__CONST_h4e9f510d_0);
                        } else if ((2U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__load_idx))) {
                            vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_dest = 0x1aU;
                            VL_ASSIGN_W(256, vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_din, Vtb_secure_boot__ConstPool__CONST_hbf60ba67_0);
                        } else if ((3U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__load_idx))) {
                            vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_dest = 0x1bU;
                            VL_ASSIGN_W(256, vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_din, Vtb_secure_boot__ConstPool__CONST_h54eb12df_0);
                        } else if ((4U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__load_idx))) {
                            vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_dest = 0x1cU;
                            VL_ASSIGN_W(256, vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_din, Vtb_secure_boot__ConstPool__CONST_h2107f3e0_0);
                        } else if ((5U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__load_idx))) {
                            vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_dest = 4U;
                            VL_ASSIGN_W(256, vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_din, Vtb_secure_boot__ConstPool__CONST_h577f31a6_0);
                        } else if ((6U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__load_idx))) {
                            vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_dest = 5U;
                            VL_ASSIGN_W(256, vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_din, Vtb_secure_boot__ConstPool__CONST_h0d6d13b6_0);
                        } else {
                            vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_dest = 6U;
                            VL_ASSIGN_W(256, vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_din, Vtb_secure_boot__ConstPool__CONST_h4e9f510d_0);
                        }
                    } else if (((((((((8U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__load_idx)) 
                                      | (9U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__load_idx))) 
                                     | (0x0aU == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__load_idx))) 
                                    | (0x0bU == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__load_idx))) 
                                   | (0x0cU == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__load_idx))) 
                                  | (0x0dU == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__load_idx))) 
                                 | (0x0eU == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__load_idx))) 
                                | (0x0fU == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__load_idx)))) {
                        if ((8U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__load_idx))) {
                            vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_dest = 7U;
                            VL_ASSIGN_W(256, vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_din, Vtb_secure_boot__ConstPool__CONST_h6a034bfc_0);
                        } else if ((9U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__load_idx))) {
                            vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_dest = 0x0aU;
                            VL_ASSIGN_W(256, vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_din, Vtb_secure_boot__ConstPool__CONST_h57168600_0);
                        } else if ((0x0aU == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__load_idx))) {
                            vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_dest = 0x0bU;
                            VL_ASSIGN_W(256, vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_din, Vtb_secure_boot__ConstPool__CONST_h3c06021b_0);
                        } else if ((0x0bU == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__load_idx))) {
                            vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_dest = 0x0cU;
                            VL_ASSIGN_W(256, vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_din, Vtb_secure_boot__ConstPool__CONST_h06733129_0);
                        } else if ((0x0cU == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__load_idx))) {
                            vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_dest = 0x17U;
                            vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_din[0U] 
                                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__s_reg[0U];
                            vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_din[1U] 
                                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__s_reg[1U];
                            vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_din[2U] 
                                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__s_reg[2U];
                            vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_din[3U] 
                                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__s_reg[3U];
                            vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_din[4U] 
                                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__s_reg[4U];
                            vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_din[5U] 
                                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__s_reg[5U];
                            vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_din[6U] 
                                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__s_reg[6U];
                            vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_din[7U] 
                                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__s_reg[7U];
                        } else if ((0x0dU == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__load_idx))) {
                            vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_dest = 0x14U;
                            vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_din[0U] 
                                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_reg[0U];
                            vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_din[1U] 
                                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_reg[1U];
                            vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_din[2U] 
                                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_reg[2U];
                            vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_din[3U] 
                                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_reg[3U];
                            vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_din[4U] 
                                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_reg[4U];
                            vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_din[5U] 
                                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_reg[5U];
                            vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_din[6U] 
                                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_reg[6U];
                            vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_din[7U] 
                                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_reg[7U];
                        } else if ((0x0eU == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__load_idx))) {
                            vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_dest = 0x15U;
                            vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_din[0U] 
                                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__pubkey_reg[0U];
                            vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_din[1U] 
                                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__pubkey_reg[1U];
                            vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_din[2U] 
                                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__pubkey_reg[2U];
                            vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_din[3U] 
                                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__pubkey_reg[3U];
                            vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_din[4U] 
                                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__pubkey_reg[4U];
                            vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_din[5U] 
                                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__pubkey_reg[5U];
                            vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_din[6U] 
                                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__pubkey_reg[6U];
                            vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_din[7U] 
                                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__pubkey_reg[7U];
                        } else {
                            vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_dest = 8U;
                            vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_din[0U] 
                                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[0U];
                            vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_din[1U] 
                                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[1U];
                            vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_din[2U] 
                                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[2U];
                            vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_din[3U] 
                                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[3U];
                            vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_din[4U] 
                                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[4U];
                            vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_din[5U] 
                                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[5U];
                            vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_din[6U] 
                                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[6U];
                            vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_din[7U] 
                                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[7U];
                        }
                    } else if ((0x10U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__load_idx))) {
                        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_dest = 9U;
                        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_din[0U] 
                            = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[8U];
                        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_din[1U] 
                            = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[9U];
                        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_din[2U] 
                            = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[10U];
                        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_din[3U] 
                            = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[11U];
                        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_din[4U] 
                            = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[12U];
                        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_din[5U] 
                            = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[13U];
                        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_din[6U] 
                            = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[14U];
                        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_din[7U] 
                            = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[15U];
                    }
                    if ((0x11U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__load_idx))) {
                        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_ext_we = 0U;
                        vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__state = 0x0eU;
                    }
                } else {
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[0U] 
                        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[1U];
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[1U] 
                        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[2U];
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[2U] 
                        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[3U];
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[3U] 
                        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[4U];
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[4U] 
                        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[5U];
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[5U] 
                        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[6U];
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[6U] 
                        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[7U];
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[7U] 
                        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[8U];
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[8U] 
                        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[9U];
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[9U] 
                        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[10U];
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[10U] 
                        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[11U];
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[11U] 
                        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[12U];
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[12U] 
                        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[13U];
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[13U] 
                        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[14U];
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[14U] 
                        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[15U];
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[15U] 
                        = ((((0x0000ff00U & (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_rdata 
                                             << 8U)) 
                             | (0x000000ffU & (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_rdata 
                                               >> 8U))) 
                            << 0x00000010U) | ((0x0000ff00U 
                                                & (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_rdata 
                                                   >> 8U)) 
                                               | (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_rdata 
                                                  >> 0x18U)));
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__load_idx = 0U;
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__state = 0x0dU;
                }
            } else if ((2U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__state))) {
                if ((1U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__state))) {
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_idx 
                        = (0x0000000fU & ((IData)(1U) 
                                          + (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_idx)));
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[0U] 
                        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[1U];
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[1U] 
                        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[2U];
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[2U] 
                        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[3U];
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[3U] 
                        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[4U];
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[4U] 
                        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[5U];
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[5U] 
                        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[6U];
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[6U] 
                        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[7U];
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[7U] 
                        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[8U];
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[8U] 
                        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[9U];
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[9U] 
                        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[10U];
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[10U] 
                        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[11U];
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[11U] 
                        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[12U];
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[12U] 
                        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[13U];
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[13U] 
                        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[14U];
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[14U] 
                        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[15U];
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[15U] 
                        = ((((0x0000ff00U & (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_rdata 
                                             << 8U)) 
                             | (0x000000ffU & (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_rdata 
                                               >> 8U))) 
                            << 0x00000010U) | ((0x0000ff00U 
                                                & (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_rdata 
                                                   >> 8U)) 
                                               | (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_rdata 
                                                  >> 0x18U)));
                    if ((0x0eU == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_idx))) {
                        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_addr = 0x31U;
                        vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__state = 0x0cU;
                    } else {
                        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_addr 
                            = (0x0000003fU & ((IData)(0x23U) 
                                              + (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_idx)));
                    }
                } else if (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_intr) {
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_idx = 0U;
                    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_addr = 0x22U;
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__state = 0x0bU;
                }
            } else if ((1U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__state))) {
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_addr = 0x21U;
                if ((1U & vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_rdata)) {
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__state = 8U;
                }
            } else if (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__data_pending) {
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_addr 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__blk_ptr;
                vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_wdata 
                    = ((((0x0000ff00U & (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__data_in_reg 
                                         << 8U)) | 
                         (0x000000ffU & (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__data_in_reg 
                                         >> 8U))) << 0x00000010U) 
                       | ((0x0000ff00U & (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__data_in_reg 
                                          >> 8U)) | 
                          (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__data_in_reg 
                           >> 0x18U)));
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_wen = 1U;
                vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_fed 
                    = ((IData)(1U) + vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_fed);
                vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__blk_ptr 
                    = (0x0000001fU & ((IData)(1U) + (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__blk_ptr)));
                if ((((IData)(1U) + vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_fed) 
                     == vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_len_reg)) {
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__state = 0x0aU;
                } else if ((0x1fU == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__blk_ptr))) {
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__blk_ptr = 0U;
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__state = 9U;
                }
            }
        } else if ((4U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__state))) {
            if ((2U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__state))) {
                if ((1U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__state))) {
                    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_addr = 0x21U;
                    if ((1U & vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_rdata)) {
                        vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__state = 5U;
                    }
                } else {
                    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__pubkey_reg[0U] 
                        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__pubkey_reg[1U];
                    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__pubkey_reg[1U] 
                        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__pubkey_reg[2U];
                    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__pubkey_reg[2U] 
                        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__pubkey_reg[3U];
                    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__pubkey_reg[3U] 
                        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__pubkey_reg[4U];
                    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__pubkey_reg[4U] 
                        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__pubkey_reg[5U];
                    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__pubkey_reg[5U] 
                        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__pubkey_reg[6U];
                    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__pubkey_reg[6U] 
                        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__pubkey_reg[7U];
                    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__pubkey_reg[7U] 
                        = ((((0x0000ff00U & (vlSelfRef.tb_secure_boot__DOT__dut__DOT__otp_data 
                                             << 8U)) 
                             | (0x000000ffU & (vlSelfRef.tb_secure_boot__DOT__dut__DOT__otp_data 
                                               >> 8U))) 
                            << 0x00000010U) | ((0x0000ff00U 
                                                & (vlSelfRef.tb_secure_boot__DOT__dut__DOT__otp_data 
                                                   >> 8U)) 
                                               | (vlSelfRef.tb_secure_boot__DOT__dut__DOT__otp_data 
                                                  >> 0x18U)));
                    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_addr 
                        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__blk_ptr;
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_wdata 
                        = ((((0x0000ff00U & (vlSelfRef.tb_secure_boot__DOT__dut__DOT__otp_data 
                                             << 8U)) 
                             | (0x000000ffU & (vlSelfRef.tb_secure_boot__DOT__dut__DOT__otp_data 
                                               >> 8U))) 
                            << 0x00000010U) | ((0x0000ff00U 
                                                & (vlSelfRef.tb_secure_boot__DOT__dut__DOT__otp_data 
                                                   >> 8U)) 
                                               | (vlSelfRef.tb_secure_boot__DOT__dut__DOT__otp_data 
                                                  >> 0x18U)));
                    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_wen = 1U;
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_fed 
                        = ((IData)(1U) + vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_fed);
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__blk_ptr 
                        = (0x0000001fU & ((IData)(1U) 
                                          + (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__blk_ptr)));
                    if ((7U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__otp_idx))) {
                        if ((((IData)(1U) + vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_fed) 
                             == vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_len_reg)) {
                            vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__state = 0x0aU;
                        } else if ((0x1fU == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__blk_ptr))) {
                            vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__blk_ptr = 0U;
                            vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__state = 9U;
                        } else {
                            vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__state = 8U;
                        }
                    } else {
                        vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__otp_idx 
                            = (7U & ((IData)(1U) + (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__otp_idx)));
                        if ((0x1fU == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__blk_ptr))) {
                            vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__blk_ptr = 0U;
                            vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__state = 7U;
                        } else {
                            vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__state = 5U;
                        }
                    }
                }
            } else if ((1U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__state))) {
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__otp_rd_en = 1U;
                vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__state = 6U;
            } else {
                vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_fed 
                    = ((IData)(1U) + vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_fed);
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_addr 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__blk_ptr;
                vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_wdata 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_reg
                    [(7U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_idx))];
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_wen = 1U;
                vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__blk_ptr 
                    = (0x0000001fU & ((IData)(1U) + (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__blk_ptr)));
                vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_idx 
                    = (7U & ((IData)(1U) + (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_idx)));
                if ((7U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_idx))) {
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__state = 5U;
                }
            }
        } else if ((2U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__state))) {
            if ((1U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__state))) {
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_addr = 0x21U;
                if ((1U & vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_rdata)) {
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__state = 4U;
                }
            } else {
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_addr = 0x20U;
                vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_wdata = 3U;
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_wen = 1U;
                vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__state = 3U;
            }
        } else if ((1U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__state))) {
            vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_addr = 0x32U;
            vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_wdata 
                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_len_reg;
            vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_wen = 1U;
            vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__state = 2U;
        } else if ((vlSelfRef.tb_secure_boot__DOT__dut__DOT__c_wdata 
                    & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ctrl_wr))) {
            vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_len_reg 
                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__msg_len_csr;
            vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_fed = 0U;
            vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__blk_ptr = 0U;
            vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__otp_idx = 0U;
            vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_idx = 0U;
            vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__state = 1U;
        }
        if ((0U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__state))) {
            if ((2U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__sub_step))) {
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__a_reg[0U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][0U];
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__a_reg[1U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][1U];
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__a_reg[2U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][2U];
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__a_reg[3U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][3U];
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__a_reg[4U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][4U];
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__a_reg[5U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][5U];
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__a_reg[6U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][6U];
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__a_reg[7U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][7U];
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__b_reg[0U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_h377e3154_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][0U];
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__b_reg[1U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_h377e3154_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][1U];
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__b_reg[2U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_h377e3154_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][2U];
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__b_reg[3U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_h377e3154_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][3U];
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__b_reg[4U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_h377e3154_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][4U];
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__b_reg[5U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_h377e3154_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][5U];
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__b_reg[6U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_h377e3154_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][6U];
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__b_reg[7U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_h377e3154_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][7U];
                VL_ASSIGN_W(512, vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg, Vtb_secure_boot__ConstPool__CONST_h93e1b771_0);
                vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__count = 0U;
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__mult_done = 0U;
                vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__state = 1U;
            }
        } else if ((1U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__state))) {
            if ((2U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__sub_step))) {
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__a_reg[0U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][0U];
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__a_reg[1U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][1U];
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__a_reg[2U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][2U];
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__a_reg[3U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][3U];
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__a_reg[4U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][4U];
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__a_reg[5U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][5U];
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__a_reg[6U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][6U];
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__a_reg[7U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][7U];
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__b_reg[0U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_h377e3154_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][0U];
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__b_reg[1U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_h377e3154_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][1U];
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__b_reg[2U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_h377e3154_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][2U];
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__b_reg[3U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_h377e3154_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][3U];
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__b_reg[4U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_h377e3154_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][4U];
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__b_reg[5U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_h377e3154_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][5U];
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__b_reg[6U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_h377e3154_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][6U];
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__b_reg[7U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_h377e3154_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][7U];
                VL_ASSIGN_W(512, vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg, Vtb_secure_boot__ConstPool__CONST_h93e1b771_0);
                vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__count = 0U;
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__mult_done = 0U;
            } else {
                VL_ADD_W(16, vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg, vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg, vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__shifted_prod_r);
                vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__count 
                    = (0x0000001fU & ((IData)(1U) + (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__count)));
                if ((0x10U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__count))) {
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__state = 2U;
                    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__mult_done = 1U;
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__count = 0U;
                }
            }
        } else if ((2U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__state))) {
            if ((2U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__sub_step))) {
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__a_reg[0U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][0U];
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__a_reg[1U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][1U];
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__a_reg[2U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][2U];
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__a_reg[3U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][3U];
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__a_reg[4U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][4U];
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__a_reg[5U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][5U];
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__a_reg[6U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][6U];
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__a_reg[7U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][7U];
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__b_reg[0U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_h377e3154_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][0U];
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__b_reg[1U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_h377e3154_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][1U];
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__b_reg[2U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_h377e3154_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][2U];
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__b_reg[3U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_h377e3154_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][3U];
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__b_reg[4U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_h377e3154_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][4U];
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__b_reg[5U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_h377e3154_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][5U];
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__b_reg[6U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_h377e3154_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][6U];
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__b_reg[7U] 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                    [Vtb_secure_boot__ConstPool__TABLE_h377e3154_0
                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][7U];
                VL_ASSIGN_W(512, vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg, Vtb_secure_boot__ConstPool__CONST_h93e1b771_0);
                vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__count = 0U;
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__mult_done = 0U;
                vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__state = 1U;
            }
        } else {
            vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__state = 0U;
        }
        if (((0x20U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state)) 
             & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__seq_done_reg))) {
            vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__x_eq_flag 
                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__cmp_eq;
        }
        if (((0x21U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state)) 
             & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__seq_done_reg))) {
            vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__y_eq_flag 
                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__cmp_eq;
        }
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__start_seq_reg 
            = (((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__next_state) 
                != (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state)) 
               & (((((((((((((((((((((((((((1U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__next_state)) 
                                           | (2U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__next_state))) 
                                          | (3U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__next_state))) 
                                         | (4U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__next_state))) 
                                        | (6U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__next_state))) 
                                       | (8U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__next_state))) 
                                      | (9U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__next_state))) 
                                     | (0x0aU == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__next_state))) 
                                    | (0x0bU == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__next_state))) 
                                   | (0x0cU == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__next_state))) 
                                  | (0x0dU == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__next_state))) 
                                 | (0x0eU == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__next_state))) 
                                | (0x0fU == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__next_state))) 
                               | (0x10U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__next_state))) 
                              | (0x11U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__next_state))) 
                             | (0x12U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__next_state))) 
                            | (0x13U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__next_state))) 
                           | (0x14U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__next_state))) 
                          | (0x16U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__next_state))) 
                         | (0x18U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__next_state))) 
                        | (0x19U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__next_state))) 
                       | (0x1aU == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__next_state))) 
                      | (0x1cU == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__next_state))) 
                     | (0x1eU == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__next_state))) 
                    | (0x1fU == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__next_state))) 
                   | (0x20U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__next_state))) 
                  | (0x21U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__next_state))));
        if ((((2U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state)) 
              | (0x18U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))) 
             & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__seq_done_reg))) {
            vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__scalar_reg[0U] 
                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][0U];
            vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__scalar_reg[1U] 
                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][1U];
            vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__scalar_reg[2U] 
                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][2U];
            vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__scalar_reg[3U] 
                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][3U];
            vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__scalar_reg[4U] 
                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][4U];
            vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__scalar_reg[5U] 
                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][5U];
            vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__scalar_reg[6U] 
                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][6U];
            vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__scalar_reg[7U] 
                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][7U];
            vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__bit_counter = 0xffU;
        } else if (((7U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state)) 
                    | (0x1dU == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state)))) {
            VL_SHIFTL_WWI(256,256,32, vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__scalar_reg, vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__scalar_reg, 1U);
            vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__bit_counter 
                = (0x000000ffU & ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__bit_counter) 
                                  - (IData)(1U)));
        } else if (((8U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state)) 
                    & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__seq_done_reg))) {
            vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__is_decomp_pubkey = 1U;
        } else if (((0x12U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state)) 
                    & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__seq_done_reg))) {
            vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__is_decomp_pubkey = 0U;
        } else if (((0x0bU == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state)) 
                    & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__seq_done_reg))) {
            vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__target_exponent = 0U;
            vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__bit_counter = 0xfeU;
            vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__return_state = 0x0cU;
        } else if (((0x0dU == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state)) 
                    & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__seq_done_reg))) {
            vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__target_exponent = 1U;
            vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__bit_counter = 0xfbU;
            vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__return_state = 0x0eU;
        } else if ((0x17U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))) {
            vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__bit_counter 
                = (0x000000ffU & ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__bit_counter) 
                                  - (IData)(1U)));
        }
        if (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__datain_wr) {
            vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__data_in_reg 
                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__c_wdata;
        }
        if ((0U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__state))) {
            vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_intr = 0U;
            vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__word_count = 0U;
            vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__is_last_block = 0U;
            if (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__prep_start) {
                vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__state = 1U;
                if ((2U & vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_wdata)) {
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__a 
                        = vlSymsp->TOP__sha512_pkg.SHA512_IV[0U];
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__b 
                        = vlSymsp->TOP__sha512_pkg.SHA512_IV[1U];
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__c 
                        = vlSymsp->TOP__sha512_pkg.SHA512_IV[2U];
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__d 
                        = vlSymsp->TOP__sha512_pkg.SHA512_IV[3U];
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__e 
                        = vlSymsp->TOP__sha512_pkg.SHA512_IV[4U];
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__f 
                        = vlSymsp->TOP__sha512_pkg.SHA512_IV[5U];
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__g 
                        = vlSymsp->TOP__sha512_pkg.SHA512_IV[6U];
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__h 
                        = vlSymsp->TOP__sha512_pkg.SHA512_IV[7U];
                    __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v0 
                        = vlSymsp->TOP__sha512_pkg.SHA512_IV[0U];
                    vlSelfRef.__VdlySet__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v0 = 1U;
                    __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v1 
                        = vlSymsp->TOP__sha512_pkg.SHA512_IV[1U];
                    __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v2 
                        = vlSymsp->TOP__sha512_pkg.SHA512_IV[2U];
                    __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v3 
                        = vlSymsp->TOP__sha512_pkg.SHA512_IV[3U];
                    __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v4 
                        = vlSymsp->TOP__sha512_pkg.SHA512_IV[4U];
                    __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v5 
                        = vlSymsp->TOP__sha512_pkg.SHA512_IV[5U];
                    __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v6 
                        = vlSymsp->TOP__sha512_pkg.SHA512_IV[6U];
                    __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v7 
                        = vlSymsp->TOP__sha512_pkg.SHA512_IV[7U];
                } else {
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__a 
                        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H[0U];
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__b 
                        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H[1U];
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__c 
                        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H[2U];
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__d 
                        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H[3U];
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__e 
                        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H[4U];
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__f 
                        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H[5U];
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__g 
                        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H[6U];
                    vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__h 
                        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H[7U];
                }
            }
        } else if ((1U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__state))) {
            if (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__prep_word_ack) {
                vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__word_count 
                    = (0x0000003fU & ((IData)(1U) + (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__word_count)));
            }
            if (((0x20U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__word_count)) 
                 | ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__prep_word_ack) 
                    & (0x1fU == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__word_count))))) {
                vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__state = 3U;
                vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__round_count = 0U;
            } else if ((0U != (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_prep__DOT__state))) {
                vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__state = 2U;
            }
        } else if ((2U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__state))) {
            vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__word_count 
                = (0x0000003fU & ((IData)(1U) + (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__word_count)));
            if ((((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_prep__DOT__state) 
                  >> 2U) & ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__prep_word_ack) 
                            & (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_25)))) {
                vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__is_last_block = 1U;
            }
            if ((0x1fU == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__word_count))) {
                vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__state = 3U;
                vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__round_count = 0U;
            }
        } else if ((3U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__state))) {
            vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__round_count 
                = (0x0000007fU & ((IData)(1U) + (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__round_count)));
            if ((1U <= (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__round_count))) {
                vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__a 
                    = (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_round__DOT__t1 
                       + (((vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__a 
                            & vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__b) 
                           ^ ((vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__a 
                               & vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__c) 
                              ^ (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__b 
                                 & vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__c))) 
                          + (((vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__a 
                               >> 0x0000001cU) | (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__a 
                                                  << 0x00000024U)) 
                             ^ (((vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__a 
                                  >> 0x00000022U) | 
                                 (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__a 
                                  << 0x0000001eU)) 
                                ^ ((vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__a 
                                    >> 0x00000027U) 
                                   | (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__a 
                                      << 0x00000019U))))));
                vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__h 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__g;
                vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__b 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__a;
                vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__g 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__f;
                vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__c 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__b;
                vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__f 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__e;
                vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__e 
                    = (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__d 
                       + vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_round__DOT__t1);
                vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__d 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__c;
            }
            if ((0x50U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__round_count))) {
                vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__state = 4U;
            }
        } else if ((4U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__state))) {
            __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v8 
                = (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H[0U] 
                   + vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__a);
            vlSelfRef.__VdlySet__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v8 = 1U;
            __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v9 
                = (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H[1U] 
                   + vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__b);
            vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__word_count = 0U;
            __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v10 
                = (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H[2U] 
                   + vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__c);
            vlSelfRef.__VdlySet__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v10 = 1U;
            __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v11 
                = (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H[3U] 
                   + vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__d);
            __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v12 
                = (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H[4U] 
                   + vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__e);
            __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v13 
                = (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H[5U] 
                   + vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__f);
            __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v14 
                = (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H[6U] 
                   + vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__g);
            __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v15 
                = (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H[7U] 
                   + vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__h);
            if (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__is_last_block) {
                vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__state = 5U;
            } else {
                vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__a 
                    = (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H[0U] 
                       + vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__a);
                vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__b 
                    = (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H[1U] 
                       + vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__b);
                vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__c 
                    = (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H[2U] 
                       + vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__c);
                vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__state 
                    = ((0U != (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_prep__DOT__state))
                        ? 2U : 1U);
                vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__d 
                    = (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H[3U] 
                       + vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__d);
                vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__e 
                    = (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H[4U] 
                       + vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__e);
                vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__f 
                    = (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H[5U] 
                       + vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__f);
                vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__g 
                    = (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H[6U] 
                       + vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__g);
                vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__h 
                    = (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H[7U] 
                       + vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__h);
            }
        } else if ((5U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__state))) {
            vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_intr = 1U;
            vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__state = 0U;
        }
        if (((8U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__c_addr)) 
             & (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_1))) {
            vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__msg_len_csr 
                = vlSelfRef.tb_secure_boot__DOT__dut__DOT__c_wdata;
        }
        if ((2U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__sub_step))) {
            VL_ASSIGN_W(512, vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__shifted_prod_r, Vtb_secure_boot__ConstPool__CONST_h93e1b771_0);
        } else if ((1U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__state))) {
            if ((4U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__shift_amt))) {
                if ((2U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__shift_amt))) {
                    if ((1U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__shift_amt))) {
                        VL_ASSIGN_W(512, vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__shifted_prod_r, Vtb_secure_boot__ConstPool__CONST_h93e1b771_0);
                    } else {
                        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__shifted_prod_r[0U] = 0U;
                        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__shifted_prod_r[1U] = 0U;
                        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__shifted_prod_r[2U] = 0U;
                        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__shifted_prod_r[3U] = 0U;
                        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__shifted_prod_r[4U] = 0U;
                        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__shifted_prod_r[5U] = 0U;
                        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__shifted_prod_r[6U] = 0U;
                        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__shifted_prod_r[7U] = 0U;
                        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__shifted_prod_r[8U] = 0U;
                        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__shifted_prod_r[9U] = 0U;
                        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__shifted_prod_r[10U] = 0U;
                        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__shifted_prod_r[11U] = 0U;
                        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__shifted_prod_r[12U] 
                            = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__prod[0U];
                        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__shifted_prod_r[13U] 
                            = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__prod[1U];
                        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__shifted_prod_r[14U] 
                            = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__prod[2U];
                        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__shifted_prod_r[15U] 
                            = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__prod[3U];
                    }
                } else {
                    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__shifted_prod_r[0U] = 0U;
                    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__shifted_prod_r[1U] = 0U;
                    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__shifted_prod_r[2U] = 0U;
                    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__shifted_prod_r[3U] = 0U;
                    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__shifted_prod_r[4U] = 0U;
                    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__shifted_prod_r[5U] = 0U;
                    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__shifted_prod_r[6U] = 0U;
                    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__shifted_prod_r[7U] = 0U;
                    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__shifted_prod_r[8U] 
                        = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_10[0U];
                    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__shifted_prod_r[9U] 
                        = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_10[1U];
                    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__shifted_prod_r[10U] 
                        = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_10[2U];
                    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__shifted_prod_r[11U] 
                        = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_10[3U];
                    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__shifted_prod_r[12U] 
                        = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_10[4U];
                    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__shifted_prod_r[13U] 
                        = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_10[5U];
                    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__shifted_prod_r[14U] = 0U;
                    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__shifted_prod_r[15U] = 0U;
                }
            } else {
                if ((2U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__shift_amt))) {
                    __Vtemp_6[0U] = 0U;
                    __Vtemp_6[1U] = 0U;
                    __Vtemp_6[2U] = 0U;
                    __Vtemp_6[3U] = 0U;
                    __Vtemp_6[4U] = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_10[0U];
                    __Vtemp_6[5U] = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_10[1U];
                    __Vtemp_6[6U] = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_10[2U];
                    __Vtemp_6[7U] = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_10[3U];
                    __Vtemp_6[8U] = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_10[4U];
                    __Vtemp_6[9U] = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_10[5U];
                } else {
                    __Vtemp_6[0U] = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_10[0U];
                    __Vtemp_6[1U] = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_10[1U];
                    __Vtemp_6[2U] = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_10[2U];
                    __Vtemp_6[3U] = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_10[3U];
                    __Vtemp_6[4U] = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_10[4U];
                    __Vtemp_6[5U] = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_10[5U];
                    __Vtemp_6[6U] = 0U;
                    __Vtemp_6[7U] = 0U;
                    __Vtemp_6[8U] = 0U;
                    __Vtemp_6[9U] = 0U;
                }
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__shifted_prod_r[0U] 
                    = __Vtemp_6[0U];
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__shifted_prod_r[1U] 
                    = __Vtemp_6[1U];
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__shifted_prod_r[2U] 
                    = __Vtemp_6[2U];
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__shifted_prod_r[3U] 
                    = __Vtemp_6[3U];
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__shifted_prod_r[4U] 
                    = __Vtemp_6[4U];
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__shifted_prod_r[5U] 
                    = __Vtemp_6[5U];
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__shifted_prod_r[6U] 
                    = __Vtemp_6[6U];
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__shifted_prod_r[7U] 
                    = __Vtemp_6[7U];
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__shifted_prod_r[8U] 
                    = __Vtemp_6[8U];
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__shifted_prod_r[9U] 
                    = __Vtemp_6[9U];
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__shifted_prod_r[10U] = 0U;
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__shifted_prod_r[11U] = 0U;
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__shifted_prod_r[12U] = 0U;
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__shifted_prod_r[13U] = 0U;
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__shifted_prod_r[14U] = 0U;
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__shifted_prod_r[15U] = 0U;
            }
        }
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state 
            = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__next_state;
    } else {
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__c_rdata = 0U;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__x_sign = 0U;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__step_counter = 0U;
        vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__sub_step = 0U;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__reg_we = 0U;
        vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__seq_done_reg = 0U;
        vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__start_latch = 0U;
        VL_ASSIGN_W(256, vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__pubkey_reg, Vtb_secure_boot__ConstPool__CONST_h9e67c271_0);
        VL_ASSIGN_W(512, vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg, Vtb_secure_boot__ConstPool__CONST_h93e1b771_0);
        vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__state = 0U;
        vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_fed = 0U;
        vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__blk_ptr = 0U;
        vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__otp_idx = 0U;
        vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_idx = 0U;
        vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__load_idx = 0U;
        vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_idx = 0U;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_len_reg = 0U;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_addr = 0U;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_wen = 0U;
        vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_wdata = 0U;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_start = 0U;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_ext_we = 0U;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_dest = 0U;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_dsel = 0U;
        VL_ASSIGN_W(256, vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_din, Vtb_secure_boot__ConstPool__CONST_h9e67c271_0);
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__otp_rd_en = 0U;
        vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__state = 0U;
        vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__count = 0U;
        VL_ASSIGN_W(256, vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__a_reg, Vtb_secure_boot__ConstPool__CONST_h9e67c271_0);
        VL_ASSIGN_W(256, vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__b_reg, Vtb_secure_boot__ConstPool__CONST_h9e67c271_0);
        VL_ASSIGN_W(512, vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg, Vtb_secure_boot__ConstPool__CONST_h93e1b771_0);
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__mult_done = 0U;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__return_state = 0U;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__start_seq_reg = 0U;
        vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__bit_counter = 0U;
        VL_ASSIGN_W(256, vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__scalar_reg, Vtb_secure_boot__ConstPool__CONST_h9e67c271_0);
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__target_exponent = 0U;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__is_decomp_pubkey = 1U;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__x_eq_flag = 0U;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__y_eq_flag = 0U;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__data_in_reg = 0U;
        __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v16 
            = vlSymsp->TOP__sha512_pkg.SHA512_IV[0U];
        vlSelfRef.__VdlySet__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v16 = 1U;
        vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__state = 0U;
        vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__word_count = 0U;
        vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__is_last_block = 0U;
        vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__round_count = 0U;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_intr = 0U;
        vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__a = 0ULL;
        vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__b = 0ULL;
        vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__c = 0ULL;
        vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__d = 0ULL;
        vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__e = 0ULL;
        vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__f = 0ULL;
        vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__g = 0ULL;
        vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__h = 0ULL;
        __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v17 
            = vlSymsp->TOP__sha512_pkg.SHA512_IV[1U];
        vlSelfRef.__VdlySet__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v17 = 1U;
        __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v18 
            = vlSymsp->TOP__sha512_pkg.SHA512_IV[2U];
        __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v19 
            = vlSymsp->TOP__sha512_pkg.SHA512_IV[3U];
        __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v20 
            = vlSymsp->TOP__sha512_pkg.SHA512_IV[4U];
        __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v21 
            = vlSymsp->TOP__sha512_pkg.SHA512_IV[5U];
        __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v22 
            = vlSymsp->TOP__sha512_pkg.SHA512_IV[6U];
        __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v23 
            = vlSymsp->TOP__sha512_pkg.SHA512_IV[7U];
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__msg_len_csr = 0U;
        VL_ASSIGN_W(512, vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__shifted_prod_r, Vtb_secure_boot__ConstPool__CONST_h93e1b771_0);
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state = 0U;
    }
    __Vfunc_lower_sigma1__26__x = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w[14U];
    __Vfunc_rotr__27__value = __Vfunc_lower_sigma1__26__x;
    __Vfunc_rotr__27__Vfuncout = ((__Vfunc_rotr__27__value 
                                   >> 0x00000013U) 
                                  | (__Vfunc_rotr__27__value 
                                     << 0x0000002dU));
    __Vfunc_lower_sigma1__26____VlefCall_0__rotr = __Vfunc_rotr__27__Vfuncout;
    __Vfunc_rotr__28__value = __Vfunc_lower_sigma1__26__x;
    __Vfunc_rotr__28__Vfuncout = ((__Vfunc_rotr__28__value 
                                   >> 0x0000003dU) 
                                  | (__Vfunc_rotr__28__value 
                                     << 3U));
    __Vfunc_lower_sigma1__26____VlefCall_1__rotr = __Vfunc_rotr__28__Vfuncout;
    __Vfunc_shr__29__value = __Vfunc_lower_sigma1__26__x;
    __Vfunc_shr__29__Vfuncout = (__Vfunc_shr__29__value 
                                 >> 6U);
    __Vfunc_lower_sigma1__26____VlefCall_2__shr = __Vfunc_shr__29__Vfuncout;
    tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT____VlemCall_0__lower_sigma1 
        = ((__Vfunc_lower_sigma1__26____VlefCall_0__rotr 
            ^ __Vfunc_lower_sigma1__26____VlefCall_1__rotr) 
           ^ __Vfunc_lower_sigma1__26____VlefCall_2__shr);
    __Vfunc_lower_sigma0__30__x = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w[1U];
    __Vfunc_rotr__31__value = __Vfunc_lower_sigma0__30__x;
    __Vfunc_rotr__31__Vfuncout = ((__Vfunc_rotr__31__value 
                                   >> 1U) | (__Vfunc_rotr__31__value 
                                             << 0x0000003fU));
    __Vfunc_lower_sigma0__30____VlefCall_0__rotr = __Vfunc_rotr__31__Vfuncout;
    __Vfunc_rotr__32__value = __Vfunc_lower_sigma0__30__x;
    __Vfunc_rotr__32__Vfuncout = ((__Vfunc_rotr__32__value 
                                   >> 8U) | (__Vfunc_rotr__32__value 
                                             << 0x00000038U));
    __Vfunc_lower_sigma0__30____VlefCall_1__rotr = __Vfunc_rotr__32__Vfuncout;
    __Vfunc_shr__33__value = __Vfunc_lower_sigma0__30__x;
    __Vfunc_shr__33__Vfuncout = (__Vfunc_shr__33__value 
                                 >> 7U);
    __Vfunc_lower_sigma0__30____VlefCall_2__shr = __Vfunc_shr__33__Vfuncout;
    tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT____VlemCall_1__lower_sigma0 
        = ((__Vfunc_lower_sigma0__30____VlefCall_0__rotr 
            ^ __Vfunc_lower_sigma0__30____VlefCall_1__rotr) 
           ^ __Vfunc_lower_sigma0__30____VlefCall_2__shr);
    __Vfunc_csa64__34__c = tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT____VlemCall_1__lower_sigma0;
    __Vfunc_csa64__34__b = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w[9U];
    __Vfunc_csa64__34__a = tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT____VlemCall_0__lower_sigma1;
    __Vfunc_csa64__34__res.__PVT__sum = 0;
    __Vfunc_csa64__34__res.__PVT__carry = 0;
    __Vfunc_csa64__34__res.__PVT__sum = ((__Vfunc_csa64__34__a 
                                          ^ __Vfunc_csa64__34__b) 
                                         ^ __Vfunc_csa64__34__c);
    __Vfunc_csa64__34__res.__PVT__carry = (((__Vfunc_csa64__34__a 
                                             & __Vfunc_csa64__34__b) 
                                            | (__Vfunc_csa64__34__b 
                                               & __Vfunc_csa64__34__c)) 
                                           | (__Vfunc_csa64__34__a 
                                              & __Vfunc_csa64__34__c));
    __Vfunc_csa64__34__Vfuncout = __Vfunc_csa64__34__res;
    tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__stage1 
        = __Vfunc_csa64__34__Vfuncout;
    __Vfunc_csa64__35__c = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w[0U];
    __Vfunc_csa64__35__b = (tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__stage1
                            .__PVT__carry << 1U);
    __Vfunc_csa64__35__a = tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__stage1
        .__PVT__sum;
    __Vfunc_csa64__35__res.__PVT__sum = 0;
    __Vfunc_csa64__35__res.__PVT__carry = 0;
    __Vfunc_csa64__35__res.__PVT__sum = ((__Vfunc_csa64__35__a 
                                          ^ __Vfunc_csa64__35__b) 
                                         ^ __Vfunc_csa64__35__c);
    __Vfunc_csa64__35__res.__PVT__carry = (((__Vfunc_csa64__35__a 
                                             & __Vfunc_csa64__35__b) 
                                            | (__Vfunc_csa64__35__b 
                                               & __Vfunc_csa64__35__c)) 
                                           | (__Vfunc_csa64__35__a 
                                              & __Vfunc_csa64__35__c));
    __Vfunc_csa64__35__Vfuncout = __Vfunc_csa64__35__res;
    tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__stage2 
        = __Vfunc_csa64__35__Vfuncout;
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w_next 
        = (tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__stage2
           .__PVT__sum + (tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__stage2
                          .__PVT__carry << 1U));
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__start_latch 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__start_latch;
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_fed 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_fed;
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__blk_ptr 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__blk_ptr;
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_idx 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_idx;
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__load_idx 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__load_idx;
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__s_reg[0U] 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__s_reg[0U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__s_reg[1U] 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__s_reg[1U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__s_reg[2U] 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__s_reg[2U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__s_reg[3U] 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__s_reg[3U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__s_reg[4U] 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__s_reg[4U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__s_reg[5U] 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__s_reg[5U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__s_reg[6U] 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__s_reg[6U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__s_reg[7U] 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__s_reg[7U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_reg[0U] 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_reg[0U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_reg[1U] 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_reg[1U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_reg[2U] 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_reg[2U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_reg[3U] 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_reg[3U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_reg[4U] 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_reg[4U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_reg[5U] 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_reg[5U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_reg[6U] 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_reg[6U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_reg[7U] 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_reg[7U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[0U] 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[0U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[1U] 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[1U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[2U] 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[2U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[3U] 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[3U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[4U] 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[4U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[5U] 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[5U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[6U] 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[6U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[7U] 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[7U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[8U] 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[8U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[9U] 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[9U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[10U] 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[10U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[11U] 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[11U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[12U] 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[12U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[13U] 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[13U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[14U] 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[14U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[15U] 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg[15U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_idx 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_idx;
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__otp_idx 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__otp_idx;
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__state 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__state;
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__data_pending 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__data_pending;
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[0U] 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[0U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[1U] 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[1U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[2U] 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[2U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[3U] 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[3U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[4U] 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[4U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[5U] 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[5U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[6U] 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[6U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[7U] 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[7U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[8U] 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[8U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[9U] 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[9U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[10U] 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[10U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[11U] 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[11U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[12U] 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[12U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[13U] 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[13U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[14U] 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[14U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[15U] 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[15U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__count 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__count;
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__scalar_reg[0U] 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__scalar_reg[0U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__scalar_reg[1U] 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__scalar_reg[1U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__scalar_reg[2U] 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__scalar_reg[2U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__scalar_reg[3U] 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__scalar_reg[3U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__scalar_reg[4U] 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__scalar_reg[4U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__scalar_reg[5U] 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__scalar_reg[5U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__scalar_reg[6U] 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__scalar_reg[6U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__scalar_reg[7U] 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__scalar_reg[7U];
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__bit_counter 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__bit_counter;
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__seq_done_reg 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__seq_done_reg;
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__is_last_block 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__is_last_block;
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__a 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__a;
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__b 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__b;
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__c 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__c;
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__d 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__d;
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__round_count 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__round_count;
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__word_count 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__word_count;
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_wdata 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_wdata;
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__state 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__state;
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_prep__DOT__state 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_prep__DOT__state;
    if (vlSelfRef.__VdlySet__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v0) {
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H[0U] 
            = __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v0;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H[1U] 
            = __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v1;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H[2U] 
            = __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v2;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H[3U] 
            = __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v3;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H[4U] 
            = __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v4;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H[5U] 
            = __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v5;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H[6U] 
            = __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v6;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H[7U] 
            = __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v7;
    }
    if (vlSelfRef.__VdlySet__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v8) {
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H[0U] 
            = __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v8;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H[1U] 
            = __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v9;
    }
    if (vlSelfRef.__VdlySet__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v10) {
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H[2U] 
            = __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v10;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H[3U] 
            = __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v11;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H[4U] 
            = __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v12;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H[5U] 
            = __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v13;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H[6U] 
            = __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v14;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H[7U] 
            = __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v15;
    }
    if (vlSelfRef.__VdlySet__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v16) {
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H[0U] 
            = __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v16;
    }
    if (vlSelfRef.__VdlySet__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v17) {
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H[1U] 
            = __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v17;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H[2U] 
            = __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v18;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H[3U] 
            = __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v19;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H[4U] 
            = __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v20;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H[5U] 
            = __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v21;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H[6U] 
            = __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v22;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H[7U] 
            = __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v23;
    }
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__e 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__e;
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__f 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__f;
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__g 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__g;
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__h 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__h;
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__prep_start 
        = ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_wen) 
           & ((0x20U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_addr)) 
              & vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_wdata));
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__prep_word_ack 
        = ((2U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__state)) 
           | ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_wen) 
              & ((0x20U > (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_addr)) 
                 & (1U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__state)))));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_23 = (1U 
                                                 & (~ (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_prep__DOT__state)));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_24 = (1U 
                                                 & (~ 
                                                    ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_prep__DOT__state) 
                                                     >> 1U)));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_25 = (IData)(
                                                        (1U 
                                                         == 
                                                         (3U 
                                                          & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_prep__DOT__state))));
    if ((2U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__state))) {
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__sched_addr 
            = (0x0000001fU & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__word_count));
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__sched_wdata 
            = ((4U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_prep__DOT__state))
                ? ((- (IData)((IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_25))) 
                   & ((((0x0000e000U & (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__msg_length 
                                        << 0x0000000dU)) 
                        | (0x000000ffU & (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__msg_length 
                                          >> 3U))) 
                       << 0x00000010U) | ((0x0000ff00U 
                                           & (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__msg_length 
                                              >> 3U)) 
                                          | (0x000000ffU 
                                             & (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__msg_length 
                                                >> 0x00000013U)))))
                : (0x00000080U & ((- (IData)((1U & 
                                              (~ (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_prep__DOT__state))))) 
                                  & (- (IData)((1U 
                                                & ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_prep__DOT__state) 
                                                   >> 1U)))))));
    } else {
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__sched_addr 
            = (0x0000001fU & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_addr));
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__sched_wdata 
            = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_wdata;
    }
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_rdata 
        = ((0x21U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_addr))
            ? ((1U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__state)) 
               | (0U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__state)))
            : (((1U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_addr))
                 ? (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H
                           [(7U & (((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_addr) 
                                    - (IData)(0x22U)) 
                                   >> 1U))]) : (IData)(
                                                       (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H
                                                        [
                                                        (7U 
                                                         & (((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_addr) 
                                                             - (IData)(0x22U)) 
                                                            >> 1U))] 
                                                        >> 0x00000020U))) 
               & (- (IData)(((0x22U <= (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_addr)) 
                             & (0x31U >= (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_addr)))))));
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__sub_step 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__sub_step;
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__shift_amt 
        = (7U & ((3U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__count)) 
                 + (3U & ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__count) 
                          >> 2U))));
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__state 
        = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__state;
    __VdfgRegularize_h6e95ff9d_0_26 = (- (QData)((IData)(
                                                         ((1U 
                                                           == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__state)) 
                                                          & (0x10U 
                                                             > (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__count))))));
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_valid 
        = (IData)((((0x22U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state)) 
                    & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__x_eq_flag)) 
                   & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__y_eq_flag)));
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_done 
        = (IData)((0x22U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state)));
    if (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__seq_done_reg) {
        vlSelfRef.__VdfgRegularize_h6e95ff9d_0_15 = 9U;
        vlSelfRef.__VdfgRegularize_h6e95ff9d_0_16 = 0x14U;
    } else {
        vlSelfRef.__VdfgRegularize_h6e95ff9d_0_15 = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state;
        vlSelfRef.__VdfgRegularize_h6e95ff9d_0_16 = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state;
    }
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0 = (((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__step_counter) 
                                                 << 5U) 
                                                | ((0x00000020U 
                                                    & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
                                                    ? 
                                                   ((- (IData)(
                                                               (1U 
                                                                & (~ 
                                                                   ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state) 
                                                                    >> 3U))))) 
                                                    & ((- (IData)(
                                                                  (1U 
                                                                   & (~ 
                                                                      ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state) 
                                                                       >> 2U))))) 
                                                       & ((- (IData)(
                                                                     (1U 
                                                                      & (~ 
                                                                         ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state) 
                                                                          >> 1U))))) 
                                                          & (((1U 
                                                               & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
                                                               ? 0x16U
                                                               : 0x15U) 
                                                             & (- (IData)(
                                                                          (1U 
                                                                           & (~ 
                                                                              ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state) 
                                                                               >> 4U)))))))))
                                                    : 
                                                   ((0x00000010U 
                                                     & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
                                                     ? 
                                                    ((8U 
                                                      & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
                                                      ? 
                                                     ((4U 
                                                       & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
                                                       ? 
                                                      ((2U 
                                                        & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
                                                        ? 
                                                       ((1U 
                                                         & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
                                                         ? 2U
                                                         : 0x14U)
                                                        : 
                                                       (2U 
                                                        & (- (IData)(
                                                                     (1U 
                                                                      & (~ (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state)))))))
                                                       : 
                                                      ((2U 
                                                        & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
                                                        ? 
                                                       (1U 
                                                        & (- (IData)(
                                                                     (1U 
                                                                      & (~ (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))))))
                                                        : 
                                                       ((1U 
                                                         & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
                                                         ? 3U
                                                         : 0x17U)))
                                                      : 
                                                     ((4U 
                                                       & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
                                                       ? 
                                                      ((2U 
                                                        & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
                                                        ? 
                                                       (9U 
                                                        & (- (IData)(
                                                                     (1U 
                                                                      & (~ (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))))))
                                                        : 
                                                       (8U 
                                                        & (- (IData)(
                                                                     (1U 
                                                                      & (~ (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state)))))))
                                                       : 
                                                      ((2U 
                                                        & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
                                                        ? 
                                                       ((1U 
                                                         & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
                                                         ? 0x12U
                                                         : 0x13U)
                                                        : 
                                                       ((1U 
                                                         & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
                                                         ? 0x11U
                                                         : 0x10U))))
                                                     : 
                                                    ((8U 
                                                      & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
                                                      ? 
                                                     ((4U 
                                                       & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
                                                       ? 
                                                      ((2U 
                                                        & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
                                                        ? 
                                                       ((1U 
                                                         & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
                                                         ? 0x0fU
                                                         : 0x0eU)
                                                        : 
                                                       ((1U 
                                                         & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
                                                         ? 0x0dU
                                                         : 0x0aU))
                                                       : 
                                                      ((2U 
                                                        & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
                                                        ? 
                                                       ((1U 
                                                         & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
                                                         ? 7U
                                                         : 6U)
                                                        : 
                                                       ((1U 
                                                         & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
                                                         ? 
                                                        ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__is_decomp_pubkey)
                                                          ? 0x0bU
                                                          : 0x0cU)
                                                         : 5U)))
                                                      : 
                                                     ((4U 
                                                       & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
                                                       ? 
                                                      ((2U 
                                                        & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
                                                        ? 
                                                       (2U 
                                                        & (- (IData)(
                                                                     (1U 
                                                                      & (~ (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))))))
                                                        : 
                                                       (1U 
                                                        & (- (IData)(
                                                                     (1U 
                                                                      & (~ (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state)))))))
                                                       : 
                                                      (((1U 
                                                         & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
                                                         ? 3U
                                                         : 4U) 
                                                       & (- (IData)(
                                                                    (1U 
                                                                     & ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state) 
                                                                        >> 1U))))))))));
    __Vtemp_8[0U] = (IData)((((2U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__count))
                               ? ((1U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__count))
                                   ? (((QData)((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__b_reg[7U])) 
                                       << 0x00000020U) 
                                      | (QData)((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__b_reg[6U])))
                                   : (((QData)((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__b_reg[5U])) 
                                       << 0x00000020U) 
                                      | (QData)((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__b_reg[4U]))))
                               : ((1U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__count))
                                   ? (((QData)((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__b_reg[3U])) 
                                       << 0x00000020U) 
                                      | (QData)((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__b_reg[2U])))
                                   : (((QData)((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__b_reg[1U])) 
                                       << 0x00000020U) 
                                      | (QData)((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__b_reg[0U]))))) 
                             & __VdfgRegularize_h6e95ff9d_0_26));
    __Vtemp_8[1U] = (IData)(((((2U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__count))
                                ? ((1U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__count))
                                    ? (((QData)((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__b_reg[7U])) 
                                        << 0x00000020U) 
                                       | (QData)((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__b_reg[6U])))
                                    : (((QData)((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__b_reg[5U])) 
                                        << 0x00000020U) 
                                       | (QData)((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__b_reg[4U]))))
                                : ((1U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__count))
                                    ? (((QData)((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__b_reg[3U])) 
                                        << 0x00000020U) 
                                       | (QData)((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__b_reg[2U])))
                                    : (((QData)((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__b_reg[1U])) 
                                        << 0x00000020U) 
                                       | (QData)((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__b_reg[0U]))))) 
                              & __VdfgRegularize_h6e95ff9d_0_26) 
                             >> 0x00000020U));
    __Vtemp_8[2U] = 0U;
    __Vtemp_8[3U] = 0U;
    __Vtemp_9[0U] = (IData)((((8U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__count))
                               ? ((4U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__count))
                                   ? (((QData)((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__a_reg[7U])) 
                                       << 0x00000020U) 
                                      | (QData)((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__a_reg[6U])))
                                   : (((QData)((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__a_reg[5U])) 
                                       << 0x00000020U) 
                                      | (QData)((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__a_reg[4U]))))
                               : ((4U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__count))
                                   ? (((QData)((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__a_reg[3U])) 
                                       << 0x00000020U) 
                                      | (QData)((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__a_reg[2U])))
                                   : (((QData)((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__a_reg[1U])) 
                                       << 0x00000020U) 
                                      | (QData)((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__a_reg[0U]))))) 
                             & __VdfgRegularize_h6e95ff9d_0_26));
    __Vtemp_9[1U] = (IData)(((((8U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__count))
                                ? ((4U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__count))
                                    ? (((QData)((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__a_reg[7U])) 
                                        << 0x00000020U) 
                                       | (QData)((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__a_reg[6U])))
                                    : (((QData)((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__a_reg[5U])) 
                                        << 0x00000020U) 
                                       | (QData)((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__a_reg[4U]))))
                                : ((4U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__count))
                                    ? (((QData)((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__a_reg[3U])) 
                                        << 0x00000020U) 
                                       | (QData)((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__a_reg[2U])))
                                    : (((QData)((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__a_reg[1U])) 
                                        << 0x00000020U) 
                                       | (QData)((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__a_reg[0U]))))) 
                              & __VdfgRegularize_h6e95ff9d_0_26) 
                             >> 0x00000020U));
    __Vtemp_9[2U] = 0U;
    __Vtemp_9[3U] = 0U;
    VL_MUL_W(4, vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__prod, __Vtemp_8, __Vtemp_9);
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_2 = (1U 
                                                & Vtb_secure_boot__ConstPool__TABLE_h54cb72e1_0
                                                [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]);
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_8 = (1U 
                                                & (Vtb_secure_boot__ConstPool__TABLE_h54cb72e1_0
                                                   [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0] 
                                                   >> 1U));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_13 = (1U 
                                                 & (Vtb_secure_boot__ConstPool__TABLE_h54cb72e1_0
                                                    [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0] 
                                                    >> 2U));
    if (((2U == Vtb_secure_boot__ConstPool__TABLE_h54cb72e1_0
          [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]) 
         & Vtb_secure_boot__ConstPool__TABLE_hcb85b0e9_0
         [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0])) {
        tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__pm_input[0U] 
            = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[0U];
        tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__pm_input[1U] 
            = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[1U];
        tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__pm_input[2U] 
            = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[2U];
        tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__pm_input[3U] 
            = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[3U];
        tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__pm_input[4U] 
            = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[4U];
        tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__pm_input[5U] 
            = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[5U];
        tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__pm_input[6U] 
            = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[6U];
        tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__pm_input[7U] 
            = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[7U];
        tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__pm_input[8U] 
            = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[8U];
        tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__pm_input[9U] 
            = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[9U];
        tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__pm_input[10U] 
            = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[10U];
        tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__pm_input[11U] 
            = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[11U];
        tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__pm_input[12U] 
            = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[12U];
        tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__pm_input[13U] 
            = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[13U];
        tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__pm_input[14U] 
            = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[14U];
        tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__pm_input[15U] 
            = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg[15U];
    } else {
        VL_ASSIGN_W(512, tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__pm_input, Vtb_secure_boot__ConstPool__CONST_h93e1b771_0);
    }
    if ((1U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__shift_amt))) {
        vlSelfRef.__VdfgRegularize_h6e95ff9d_0_10[0U] = 0U;
        vlSelfRef.__VdfgRegularize_h6e95ff9d_0_10[1U] = 0U;
        vlSelfRef.__VdfgRegularize_h6e95ff9d_0_10[2U] 
            = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__prod[0U];
        vlSelfRef.__VdfgRegularize_h6e95ff9d_0_10[3U] 
            = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__prod[1U];
        vlSelfRef.__VdfgRegularize_h6e95ff9d_0_10[4U] 
            = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__prod[2U];
        vlSelfRef.__VdfgRegularize_h6e95ff9d_0_10[5U] 
            = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__prod[3U];
    } else {
        vlSelfRef.__VdfgRegularize_h6e95ff9d_0_10[0U] 
            = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__prod[0U];
        vlSelfRef.__VdfgRegularize_h6e95ff9d_0_10[1U] 
            = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__prod[1U];
        vlSelfRef.__VdfgRegularize_h6e95ff9d_0_10[2U] 
            = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__prod[2U];
        vlSelfRef.__VdfgRegularize_h6e95ff9d_0_10[3U] 
            = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__prod[3U];
        vlSelfRef.__VdfgRegularize_h6e95ff9d_0_10[4U] = 0U;
        vlSelfRef.__VdfgRegularize_h6e95ff9d_0_10[5U] = 0U;
    }
    __Vtemp_11[0U] = tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__pm_input[8U];
    __Vtemp_11[1U] = tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__pm_input[9U];
    __Vtemp_11[2U] = tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__pm_input[10U];
    __Vtemp_11[3U] = tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__pm_input[11U];
    __Vtemp_11[4U] = tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__pm_input[12U];
    __Vtemp_11[5U] = tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__pm_input[13U];
    __Vtemp_11[6U] = tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__pm_input[14U];
    __Vtemp_11[7U] = tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__pm_input[15U];
    __Vtemp_11[8U] = 0U;
    VL_MUL_W(9, __Vtemp_12, Vtb_secure_boot__ConstPool__CONST_h0efaa2d9_0, __Vtemp_11);
    __Vtemp_14[0U] = __Vtemp_12[0U];
    __Vtemp_14[1U] = __Vtemp_12[1U];
    __Vtemp_14[2U] = __Vtemp_12[2U];
    __Vtemp_14[3U] = __Vtemp_12[3U];
    __Vtemp_14[4U] = __Vtemp_12[4U];
    __Vtemp_14[5U] = __Vtemp_12[5U];
    __Vtemp_14[6U] = __Vtemp_12[6U];
    __Vtemp_14[7U] = __Vtemp_12[7U];
    __Vtemp_14[8U] = (0x0000003fU & __Vtemp_12[8U]);
    __Vtemp_16[0U] = tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__pm_input[0U];
    __Vtemp_16[1U] = tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__pm_input[1U];
    __Vtemp_16[2U] = tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__pm_input[2U];
    __Vtemp_16[3U] = tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__pm_input[3U];
    __Vtemp_16[4U] = tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__pm_input[4U];
    __Vtemp_16[5U] = tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__pm_input[5U];
    __Vtemp_16[6U] = tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__pm_input[6U];
    __Vtemp_16[7U] = tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__pm_input[7U];
    __Vtemp_16[8U] = 0U;
    VL_ADD_W(9, __Vtemp_17, __Vtemp_14, __Vtemp_16);
    tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__u_pm_reducer__DOT__stage1_sum[0U] 
        = __Vtemp_17[0U];
    tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__u_pm_reducer__DOT__stage1_sum[1U] 
        = __Vtemp_17[1U];
    tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__u_pm_reducer__DOT__stage1_sum[2U] 
        = __Vtemp_17[2U];
    tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__u_pm_reducer__DOT__stage1_sum[3U] 
        = __Vtemp_17[3U];
    tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__u_pm_reducer__DOT__stage1_sum[4U] 
        = __Vtemp_17[4U];
    tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__u_pm_reducer__DOT__stage1_sum[5U] 
        = __Vtemp_17[5U];
    tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__u_pm_reducer__DOT__stage1_sum[6U] 
        = __Vtemp_17[6U];
    tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__u_pm_reducer__DOT__stage1_sum[7U] 
        = __Vtemp_17[7U];
    tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__u_pm_reducer__DOT__stage1_sum[8U] 
        = (0x0000007fU & __Vtemp_17[8U]);
    __Vtemp_18[0U] = (0x00001fffU & ((IData)(0x0013U) 
                                     * (0x000000ffU 
                                        & ((tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__u_pm_reducer__DOT__stage1_sum[8U] 
                                            << 1U) 
                                           | (tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__u_pm_reducer__DOT__stage1_sum[7U] 
                                              >> 0x0000001fU)))));
    __Vtemp_18[1U] = 0U;
    __Vtemp_18[2U] = 0U;
    __Vtemp_18[3U] = 0U;
    __Vtemp_18[4U] = 0U;
    __Vtemp_18[5U] = 0U;
    __Vtemp_18[6U] = 0U;
    __Vtemp_18[7U] = 0U;
    __Vtemp_21[0U] = tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__u_pm_reducer__DOT__stage1_sum[0U];
    __Vtemp_21[1U] = tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__u_pm_reducer__DOT__stage1_sum[1U];
    __Vtemp_21[2U] = tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__u_pm_reducer__DOT__stage1_sum[2U];
    __Vtemp_21[3U] = tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__u_pm_reducer__DOT__stage1_sum[3U];
    __Vtemp_21[4U] = tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__u_pm_reducer__DOT__stage1_sum[4U];
    __Vtemp_21[5U] = tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__u_pm_reducer__DOT__stage1_sum[5U];
    __Vtemp_21[6U] = tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__u_pm_reducer__DOT__stage1_sum[6U];
    __Vtemp_21[7U] = (0x7fffffffU & tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__u_pm_reducer__DOT__stage1_sum[7U]);
    VL_ADD_W(8, vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__u_pm_reducer__DOT__stage2_sum, __Vtemp_18, __Vtemp_21);
}

extern const VlUnpacked<CData/*0:0*/, 512> Vtb_secure_boot__ConstPool__TABLE_h5dcdb5a1_0;

void Vtb_secure_boot___024root___nba_comb__TOP__2(Vtb_secure_boot___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_secure_boot___024root___nba_comb__TOP__2\n"); );
    Vtb_secure_boot__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    Vtb_secure_boot_csa_t__struct__0 tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_round__DOT__r1;
    tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_round__DOT__r1.__PVT__sum = 0;
    tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_round__DOT__r1.__PVT__carry = 0;
    Vtb_secure_boot_csa_t__struct__0 tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_round__DOT__r2;
    tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_round__DOT__r2.__PVT__sum = 0;
    tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_round__DOT__r2.__PVT__carry = 0;
    Vtb_secure_boot_csa_t__struct__0 tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_round__DOT__r3;
    tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_round__DOT__r3.__PVT__sum = 0;
    tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_round__DOT__r3.__PVT__carry = 0;
    Vtb_secure_boot_csa_t__struct__0 __Vfunc_csa64__23__Vfuncout;
    __Vfunc_csa64__23__Vfuncout.__PVT__sum = 0;
    __Vfunc_csa64__23__Vfuncout.__PVT__carry = 0;
    QData/*63:0*/ __Vfunc_csa64__23__a;
    __Vfunc_csa64__23__a = 0;
    QData/*63:0*/ __Vfunc_csa64__23__b;
    __Vfunc_csa64__23__b = 0;
    QData/*63:0*/ __Vfunc_csa64__23__c;
    __Vfunc_csa64__23__c = 0;
    Vtb_secure_boot_csa_t__struct__0 __Vfunc_csa64__23__res;
    __Vfunc_csa64__23__res.__PVT__sum = 0;
    __Vfunc_csa64__23__res.__PVT__carry = 0;
    Vtb_secure_boot_csa_t__struct__0 __Vfunc_csa64__24__Vfuncout;
    __Vfunc_csa64__24__Vfuncout.__PVT__sum = 0;
    __Vfunc_csa64__24__Vfuncout.__PVT__carry = 0;
    QData/*63:0*/ __Vfunc_csa64__24__a;
    __Vfunc_csa64__24__a = 0;
    QData/*63:0*/ __Vfunc_csa64__24__b;
    __Vfunc_csa64__24__b = 0;
    QData/*63:0*/ __Vfunc_csa64__24__c;
    __Vfunc_csa64__24__c = 0;
    Vtb_secure_boot_csa_t__struct__0 __Vfunc_csa64__24__res;
    __Vfunc_csa64__24__res.__PVT__sum = 0;
    __Vfunc_csa64__24__res.__PVT__carry = 0;
    Vtb_secure_boot_csa_t__struct__0 __Vfunc_csa64__25__Vfuncout;
    __Vfunc_csa64__25__Vfuncout.__PVT__sum = 0;
    __Vfunc_csa64__25__Vfuncout.__PVT__carry = 0;
    QData/*63:0*/ __Vfunc_csa64__25__a;
    __Vfunc_csa64__25__a = 0;
    QData/*63:0*/ __Vfunc_csa64__25__b;
    __Vfunc_csa64__25__b = 0;
    QData/*63:0*/ __Vfunc_csa64__25__c;
    __Vfunc_csa64__25__c = 0;
    Vtb_secure_boot_csa_t__struct__0 __Vfunc_csa64__25__res;
    __Vfunc_csa64__25__res.__PVT__sum = 0;
    __Vfunc_csa64__25__res.__PVT__carry = 0;
    VlWide<9>/*256:0*/ __VdfgRegularize_h6e95ff9d_0_20;
    VL_ZERO_W(257, __VdfgRegularize_h6e95ff9d_0_20);
    VlWide<9>/*256:0*/ __VdfgRegularize_h6e95ff9d_0_21;
    VL_ZERO_W(257, __VdfgRegularize_h6e95ff9d_0_21);
    VlWide<9>/*287:0*/ __Vtemp_1;
    VlWide<9>/*287:0*/ __Vtemp_2;
    // Body
    __Vfunc_csa64__23__c = ((vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__e 
                             & vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__f) 
                            ^ ((~ vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__e) 
                               & vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__g));
    __Vfunc_csa64__23__b = (((vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__e 
                              >> 0x0000000eU) | (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__e 
                                                 << 0x00000032U)) 
                            ^ (((vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__e 
                                 >> 0x00000012U) | 
                                (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__e 
                                 << 0x0000002eU)) ^ 
                               ((vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__e 
                                 >> 0x00000029U) | 
                                (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__e 
                                 << 0x00000017U))));
    __Vfunc_csa64__23__a = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__h;
    __Vfunc_csa64__23__res.__PVT__sum = 0;
    __Vfunc_csa64__23__res.__PVT__carry = 0;
    __Vfunc_csa64__23__res.__PVT__sum = ((__Vfunc_csa64__23__a 
                                          ^ __Vfunc_csa64__23__b) 
                                         ^ __Vfunc_csa64__23__c);
    __Vfunc_csa64__23__res.__PVT__carry = (((__Vfunc_csa64__23__a 
                                             & __Vfunc_csa64__23__b) 
                                            | (__Vfunc_csa64__23__b 
                                               & __Vfunc_csa64__23__c)) 
                                           | (__Vfunc_csa64__23__a 
                                              & __Vfunc_csa64__23__c));
    __Vfunc_csa64__23__Vfuncout = __Vfunc_csa64__23__res;
    tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_round__DOT__r1 
        = __Vfunc_csa64__23__Vfuncout;
    __Vfunc_csa64__24__c = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__k_i;
    __Vfunc_csa64__24__b = (tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_round__DOT__r1
                            .__PVT__carry << 1U);
    __Vfunc_csa64__24__a = tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_round__DOT__r1
        .__PVT__sum;
    __Vfunc_csa64__24__res.__PVT__sum = 0;
    __Vfunc_csa64__24__res.__PVT__carry = 0;
    __Vfunc_csa64__24__res.__PVT__sum = ((__Vfunc_csa64__24__a 
                                          ^ __Vfunc_csa64__24__b) 
                                         ^ __Vfunc_csa64__24__c);
    __Vfunc_csa64__24__res.__PVT__carry = (((__Vfunc_csa64__24__a 
                                             & __Vfunc_csa64__24__b) 
                                            | (__Vfunc_csa64__24__b 
                                               & __Vfunc_csa64__24__c)) 
                                           | (__Vfunc_csa64__24__a 
                                              & __Vfunc_csa64__24__c));
    __Vfunc_csa64__24__Vfuncout = __Vfunc_csa64__24__res;
    tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_round__DOT__r2 
        = __Vfunc_csa64__24__Vfuncout;
    __Vfunc_csa64__25__c = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__w_i;
    __Vfunc_csa64__25__b = (tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_round__DOT__r2
                            .__PVT__carry << 1U);
    __Vfunc_csa64__25__a = tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_round__DOT__r2
        .__PVT__sum;
    __Vfunc_csa64__25__res.__PVT__sum = 0;
    __Vfunc_csa64__25__res.__PVT__carry = 0;
    __Vfunc_csa64__25__res.__PVT__sum = ((__Vfunc_csa64__25__a 
                                          ^ __Vfunc_csa64__25__b) 
                                         ^ __Vfunc_csa64__25__c);
    __Vfunc_csa64__25__res.__PVT__carry = (((__Vfunc_csa64__25__a 
                                             & __Vfunc_csa64__25__b) 
                                            | (__Vfunc_csa64__25__b 
                                               & __Vfunc_csa64__25__c)) 
                                           | (__Vfunc_csa64__25__a 
                                              & __Vfunc_csa64__25__c));
    __Vfunc_csa64__25__Vfuncout = __Vfunc_csa64__25__res;
    tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_round__DOT__r3 
        = __Vfunc_csa64__25__Vfuncout;
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_round__DOT__t1 
        = (tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_round__DOT__r3
           .__PVT__sum + (tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_round__DOT__r3
                          .__PVT__carry << 1U));
    __VdfgRegularize_h6e95ff9d_0_20[0U] = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
        [Vtb_secure_boot__ConstPool__TABLE_h377e3154_0
        [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][0U];
    __VdfgRegularize_h6e95ff9d_0_20[1U] = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
        [Vtb_secure_boot__ConstPool__TABLE_h377e3154_0
        [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][1U];
    __VdfgRegularize_h6e95ff9d_0_20[2U] = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
        [Vtb_secure_boot__ConstPool__TABLE_h377e3154_0
        [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][2U];
    __VdfgRegularize_h6e95ff9d_0_20[3U] = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
        [Vtb_secure_boot__ConstPool__TABLE_h377e3154_0
        [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][3U];
    __VdfgRegularize_h6e95ff9d_0_20[4U] = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
        [Vtb_secure_boot__ConstPool__TABLE_h377e3154_0
        [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][4U];
    __VdfgRegularize_h6e95ff9d_0_20[5U] = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
        [Vtb_secure_boot__ConstPool__TABLE_h377e3154_0
        [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][5U];
    __VdfgRegularize_h6e95ff9d_0_20[6U] = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
        [Vtb_secure_boot__ConstPool__TABLE_h377e3154_0
        [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][6U];
    __VdfgRegularize_h6e95ff9d_0_20[7U] = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
        [Vtb_secure_boot__ConstPool__TABLE_h377e3154_0
        [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][7U];
    __VdfgRegularize_h6e95ff9d_0_20[8U] = 0U;
    __VdfgRegularize_h6e95ff9d_0_21[0U] = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
        [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
        [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][0U];
    __VdfgRegularize_h6e95ff9d_0_21[1U] = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
        [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
        [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][1U];
    __VdfgRegularize_h6e95ff9d_0_21[2U] = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
        [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
        [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][2U];
    __VdfgRegularize_h6e95ff9d_0_21[3U] = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
        [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
        [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][3U];
    __VdfgRegularize_h6e95ff9d_0_21[4U] = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
        [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
        [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][4U];
    __VdfgRegularize_h6e95ff9d_0_21[5U] = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
        [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
        [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][5U];
    __VdfgRegularize_h6e95ff9d_0_21[6U] = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
        [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
        [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][6U];
    __VdfgRegularize_h6e95ff9d_0_21[7U] = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
        [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
        [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][7U];
    __VdfgRegularize_h6e95ff9d_0_21[8U] = 0U;
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__cmp_eq 
        = (0U == ((((((((vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                         [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                         [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][0U] 
                         ^ vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                         [Vtb_secure_boot__ConstPool__TABLE_h377e3154_0
                         [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][0U]) 
                        | (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                           [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                           [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][1U] 
                           ^ vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                           [Vtb_secure_boot__ConstPool__TABLE_h377e3154_0
                           [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][1U])) 
                       | (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                          [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                          [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][2U] 
                          ^ vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                          [Vtb_secure_boot__ConstPool__TABLE_h377e3154_0
                          [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][2U])) 
                      | (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                         [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                         [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][3U] 
                         ^ vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                         [Vtb_secure_boot__ConstPool__TABLE_h377e3154_0
                         [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][3U])) 
                     | (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                        [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                        [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][4U] 
                        ^ vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                        [Vtb_secure_boot__ConstPool__TABLE_h377e3154_0
                        [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][4U])) 
                    | (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                       [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                       [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][5U] 
                       ^ vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                       [Vtb_secure_boot__ConstPool__TABLE_h377e3154_0
                       [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][5U])) 
                   | (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                      [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                      [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][6U] 
                      ^ vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                      [Vtb_secure_boot__ConstPool__TABLE_h377e3154_0
                      [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][6U])) 
                  | (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                     [Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0
                     [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][7U] 
                     ^ vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem
                     [Vtb_secure_boot__ConstPool__TABLE_h377e3154_0
                     [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0]][7U])));
    VL_SUB_W(9, __Vtemp_1, __VdfgRegularize_h6e95ff9d_0_21, __VdfgRegularize_h6e95ff9d_0_20);
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_14[0U] = __Vtemp_1[0U];
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_14[1U] = __Vtemp_1[1U];
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_14[2U] = __Vtemp_1[2U];
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_14[3U] = __Vtemp_1[3U];
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_14[4U] = __Vtemp_1[4U];
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_14[5U] = __Vtemp_1[5U];
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_14[6U] = __Vtemp_1[6U];
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_14[7U] = __Vtemp_1[7U];
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_14[8U] = 
        (1U & __Vtemp_1[8U]);
    VL_ADD_W(9, __Vtemp_2, __VdfgRegularize_h6e95ff9d_0_20, __VdfgRegularize_h6e95ff9d_0_21);
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_22[0U] = __Vtemp_2[0U];
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_22[1U] = __Vtemp_2[1U];
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_22[2U] = __Vtemp_2[2U];
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_22[3U] = __Vtemp_2[3U];
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_22[4U] = __Vtemp_2[4U];
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_22[5U] = __Vtemp_2[5U];
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_22[6U] = __Vtemp_2[6U];
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_22[7U] = __Vtemp_2[7U];
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_22[8U] = 
        (1U & __Vtemp_2[8U]);
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__next_state 
        = ((0x00000020U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
            ? ((- (IData)((1U & (~ ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state) 
                                    >> 3U))))) & ((- (IData)(
                                                             (1U 
                                                              & (~ 
                                                                 ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state) 
                                                                  >> 2U))))) 
                                                  & (((2U 
                                                       & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
                                                       ? 
                                                      ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state) 
                                                       & (- (IData)(
                                                                    (1U 
                                                                     & (~ (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))))))
                                                       : 
                                                      ((1U 
                                                        & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
                                                        ? 
                                                       ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__seq_done_reg)
                                                         ? 0x22U
                                                         : (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
                                                        : 
                                                       ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__seq_done_reg)
                                                         ? 0x21U
                                                         : (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state)))) 
                                                     & (- (IData)(
                                                                  (1U 
                                                                   & (~ 
                                                                      ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state) 
                                                                       >> 4U))))))))
            : ((0x00000010U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
                ? ((8U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
                    ? ((4U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
                        ? ((2U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
                            ? ((1U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
                                ? ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__seq_done_reg)
                                    ? 0x20U : (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
                                : ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__seq_done_reg)
                                    ? 0x1fU : (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state)))
                            : ((1U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
                                ? ((0U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__bit_counter))
                                    ? 0x1eU : 0x1aU)
                                : ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__seq_done_reg)
                                    ? 0x1dU : (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))))
                        : ((2U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
                            ? ((1U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
                                ? ((vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__scalar_reg[7U] 
                                    >> 0x0000001fU)
                                    ? 0x1cU : 0x1dU)
                                : ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__seq_done_reg)
                                    ? 0x1bU : (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state)))
                            : ((1U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
                                ? ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__seq_done_reg)
                                    ? 0x1aU : (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
                                : ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__seq_done_reg)
                                    ? 0x19U : (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state)))))
                    : ((4U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
                        ? ((2U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
                            ? ((1U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
                                ? ((0U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__bit_counter))
                                    ? (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__return_state)
                                    : 0x14U) : ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__seq_done_reg)
                                                 ? 0x17U
                                                 : (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state)))
                            : ((1U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
                                ? (Vtb_secure_boot__ConstPool__TABLE_h5dcdb5a1_0
                                   [(((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__bit_counter) 
                                      << 1U) | (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__target_exponent))]
                                    ? 0x16U : 0x17U)
                                : ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__seq_done_reg)
                                    ? 0x15U : (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))))
                        : ((2U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
                            ? ((1U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
                                ? ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__seq_done_reg)
                                    ? 0x18U : (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
                                : (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_15))
                            : ((1U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
                                ? ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__seq_done_reg)
                                    ? ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__is_decomp_pubkey)
                                        ? 0x12U : 0x13U)
                                    : (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
                                : ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__seq_done_reg)
                                    ? 0x11U : (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))))))
                : ((8U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
                    ? ((4U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
                        ? ((2U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
                            ? ((1U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
                                ? ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__seq_done_reg)
                                    ? 0x10U : (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
                                : ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__seq_done_reg)
                                    ? ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__cmp_eq)
                                        ? 0x10U : 0x0fU)
                                    : (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state)))
                            : ((1U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
                                ? (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_16)
                                : ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__seq_done_reg)
                                    ? 0x0dU : (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))))
                        : ((2U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
                            ? ((1U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
                                ? (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_16)
                                : ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__seq_done_reg)
                                    ? 0x0bU : (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state)))
                            : ((1U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
                                ? ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__seq_done_reg)
                                    ? 0x0aU : (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
                                : (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_15))))
                    : ((4U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
                        ? ((2U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
                            ? ((1U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
                                ? ((0U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__bit_counter))
                                    ? 8U : 4U) : ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__seq_done_reg)
                                                   ? 7U
                                                   : (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state)))
                            : ((1U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
                                ? ((vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__scalar_reg[7U] 
                                    >> 0x0000001fU)
                                    ? 6U : 7U) : ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__seq_done_reg)
                                                   ? 5U
                                                   : (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))))
                        : ((2U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
                            ? ((1U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
                                ? ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__seq_done_reg)
                                    ? 4U : (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
                                : ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__seq_done_reg)
                                    ? 3U : (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state)))
                            : ((1U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
                                ? ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__seq_done_reg)
                                    ? 2U : (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))
                                : ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_start)
                                    ? 1U : (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state))))))));
}

void Vtb_secure_boot___024root___eval_nba(Vtb_secure_boot___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_secure_boot___024root___eval_nba\n"); );
    Vtb_secure_boot__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((6ULL & vlSelfRef.__VnbaTriggered[0U])) {
        Vtb_secure_boot___024root___nba_sequent__TOP__0(vlSelf);
    }
    if ((3ULL & vlSelfRef.__VnbaTriggered[0U])) {
        Vtb_secure_boot___024root___nba_sequent__TOP__1(vlSelf);
    }
    if ((4ULL & vlSelfRef.__VnbaTriggered[0U])) {
        Vtb_secure_boot___024root___nba_sequent__TOP__2(vlSelf);
    }
    if ((0x000000000000000bULL & vlSelfRef.__VnbaTriggered[0U])) {
        {
            // Inlined CFunc: _act_sequent__TOP__0
            if ((1U & (~ (IData)(vlSelfRef.tb_secure_boot__DOT__clk)))) {
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto_cg__DOT__en_latch 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__g_div__DOT__div_q;
            }
            vlSelfRef.tb_secure_boot__DOT__dut__DOT__clk_crypto 
                = ((IData)(vlSelfRef.tb_secure_boot__DOT__clk) 
                   & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto_cg__DOT__en_latch));
        }
    }
    if ((1ULL & vlSelfRef.__VnbaTriggered[0U])) {
        {
            // Inlined CFunc: _nba_sequent__TOP__3
            vlSelfRef.tb_secure_boot__DOT__vrv = vlSelfRef.tb_secure_boot__DOT__vreq;
            vlSelfRef.tb_secure_boot__DOT__vrdata = vlSelfRef.tb_secure_boot__DOT__isram
                [(0x000003ffU & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__idx_q))];
        }
    }
    if ((6ULL & vlSelfRef.__VnbaTriggered[0U])) {
        Vtb_secure_boot___024root___nba_sequent__TOP__4(vlSelf);
    }
    if ((0x000000000000001bULL & vlSelfRef.__VnbaTriggered[0U])) {
        {
            // Inlined CFunc: _nba_comb__TOP__1
            vlSelfRef.tb_secure_boot__DOT__fok = ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__verified_q) 
                                                  & ((0x00010044U 
                                                      <= vlSelfRef.tb_secure_boot__DOT__faddr) 
                                                     & (vlSelfRef.tb_secure_boot__DOT__faddr 
                                                        < 
                                                        ((IData)(0x00010044U) 
                                                         + 
                                                         ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__code_words_q) 
                                                          << 2U)))));
        }
    }
    if ((3ULL & vlSelfRef.__VnbaTriggered[0U])) {
        {
            // Inlined CFunc: _nba_sequent__TOP__5
            vlSelfRef.tb_secure_boot__DOT__vreq = (
                                                   (1U 
                                                    == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__state_q)) 
                                                   | ((4U 
                                                       == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__state_q)) 
                                                      | (0x0aU 
                                                         == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__state_q))));
            vlSelfRef.tb_secure_boot__DOT__dut__DOT__idx_q 
                = vlSelfRef.__Vdly__tb_secure_boot__DOT__dut__DOT__idx_q;
            vlSelfRef.tb_secure_boot__DOT__dut__DOT__c_we 
                = (IData)((8U != (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__state_q)));
            vlSelfRef.tb_secure_boot__DOT__dut__DOT__c_gnt 
                = ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__g_div__DOT__div_q) 
                   & ((8U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__state_q))
                       ? (~ (0U != (3U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__state_q))))
                       : ((4U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__state_q))
                           ? ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__state_q) 
                              >> 1U) : (3U == (3U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__state_q))))));
            vlSelfRef.tb_secure_boot__DOT__dut__DOT____Vcellinp__u_crypto__start_verify_i 
                = ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__g_div__DOT__div_q) 
                   & (7U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__state_q)));
            if ((8U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__state_q))) {
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__c_wdata 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__word_q;
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__c_addr 
                    = ((4U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__state_q))
                        ? (0x0014U & (- (IData)((1U 
                                                 & (~ 
                                                    (0U 
                                                     != 
                                                     (3U 
                                                      & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__state_q))))))))
                        : (4U & (- (IData)((1U & (~ 
                                                  (0U 
                                                   != 
                                                   (3U 
                                                    & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__state_q)))))))));
            } else if ((4U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__state_q))) {
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__c_wdata 
                    = ((2U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__state_q))
                        ? ((1U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__state_q))
                            ? 1U : vlSelfRef.tb_secure_boot__DOT__dut__DOT__word_q)
                        : vlSelfRef.tb_secure_boot__DOT__dut__DOT__word_q);
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__c_addr 
                    = ((- (IData)((1U & (~ (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__state_q))))) 
                       & (((8U >= (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__idx_q))
                            ? 0x000cU : 0x0010U) & 
                          (- (IData)((1U & ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__state_q) 
                                            >> 1U))))));
            } else {
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__c_wdata 
                    = vlSelfRef.tb_secure_boot__DOT__dut__DOT__word_q;
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__c_addr 
                    = (8U & (- (IData)((3U == (3U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__state_q))))));
            }
            vlSelfRef.__VdfgRegularize_h6e95ff9d_0_1 
                = ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__c_we) 
                   & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__c_gnt));
            vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ctrl_wr 
                = ((0U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__c_addr)) 
                   & (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_1));
            vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__datain_wr 
                = ((0x0014U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__c_addr)) 
                   & (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_1));
        }
    }
    if ((4ULL & vlSelfRef.__VnbaTriggered[0U])) {
        {
            // Inlined CFunc: _nba_sequent__TOP__6
            if (vlSelfRef.__VdlySet__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0) {
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem[vlSelfRef.__VdlyDim0__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0][0U] 
                    = vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[0U];
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem[vlSelfRef.__VdlyDim0__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0][1U] 
                    = vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[1U];
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem[vlSelfRef.__VdlyDim0__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0][2U] 
                    = vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[2U];
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem[vlSelfRef.__VdlyDim0__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0][3U] 
                    = vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[3U];
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem[vlSelfRef.__VdlyDim0__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0][4U] 
                    = vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[4U];
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem[vlSelfRef.__VdlyDim0__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0][5U] 
                    = vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[5U];
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem[vlSelfRef.__VdlyDim0__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0][6U] 
                    = vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[6U];
                vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem[vlSelfRef.__VdlyDim0__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0][7U] 
                    = vlSelfRef.__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0[7U];
            }
        }
    }
    if ((6ULL & vlSelfRef.__VnbaTriggered[0U])) {
        Vtb_secure_boot___024root___nba_comb__TOP__2(vlSelf);
    }
    if ((0x000000000000001fULL & vlSelfRef.__VnbaTriggered[0U])) {
        {
            // Inlined CFunc: _nba_comb__TOP__3
            vlSelfRef.tb_secure_boot__DOT__dut__DOT__otp_data 
                = (((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__otp_rd_en) 
                    & ((~ (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_done)) 
                       & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__boot_q)))
                    ? vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_otp__DOT__otp_mem
                   [(0x07ffffffU & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__otp_idx))]
                    : 0U);
        }
    }
}

void Vtb_secure_boot___024root___timing_ready(Vtb_secure_boot___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_secure_boot___024root___timing_ready\n"); );
    Vtb_secure_boot__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1ULL & vlSelfRef.__VactTriggered[0U])) {
        vlSelfRef.__VtrigSched_hedba2121__0.ready("@(posedge tb_secure_boot.clk)");
    }
    if ((0x0000000000000010ULL & vlSelfRef.__VactTriggered[0U])) {
        vlSelfRef.__VtrigSched_hedba20e2__0.ready("@(negedge tb_secure_boot.clk)");
    }
}

void Vtb_secure_boot___024root___timing_resume(Vtb_secure_boot___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_secure_boot___024root___timing_resume\n"); );
    Vtb_secure_boot__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__VtrigSched_hedba2121__0.moveToResumeQueue(
                                                          "@(posedge tb_secure_boot.clk)");
    vlSelfRef.__VtrigSched_hedba20e2__0.moveToResumeQueue(
                                                          "@(negedge tb_secure_boot.clk)");
    vlSelfRef.__VtrigSched_hedba2121__0.resume("@(posedge tb_secure_boot.clk)");
    vlSelfRef.__VtrigSched_hedba20e2__0.resume("@(negedge tb_secure_boot.clk)");
    if ((8ULL & vlSelfRef.__VactTriggered[0U])) {
        vlSelfRef.__VdlySched.resume();
    }
}

void Vtb_secure_boot___024root___trigger_orInto__act_vec_vec(VlUnpacked<QData/*63:0*/, 1> &out, const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_secure_boot___024root___trigger_orInto__act_vec_vec\n"); );
    // Locals
    IData/*31:0*/ n;
    // Body
    n = 0U;
    do {
        out[n] = (out[n] | in[n]);
        n = ((IData)(1U) + n);
    } while ((0U >= n));
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_secure_boot___024root___dump_triggers__act(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag);
#endif  // VL_DEBUG

bool Vtb_secure_boot___024root___eval_phase__act(Vtb_secure_boot___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_secure_boot___024root___eval_phase__act\n"); );
    Vtb_secure_boot__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VactExecute;
    // Body
    {
        // Inlined CFunc: _eval_triggers_vec__act
        vlSelfRef.__VactTriggered[0U] = (QData)((IData)(
                                                        ((((~ (IData)(vlSelfRef.tb_secure_boot__DOT__clk)) 
                                                           & (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_secure_boot__DOT__clk__0)) 
                                                          << 4U) 
                                                         | (((vlSelfRef.__VdlySched.awaitingCurrentTime() 
                                                              << 3U) 
                                                             | (((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__clk_crypto) 
                                                                 & (~ (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_secure_boot__DOT__dut__DOT__clk_crypto__0))) 
                                                                << 2U)) 
                                                            | ((((~ (IData)(vlSelfRef.tb_secure_boot__DOT__rst_n)) 
                                                                 & (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_secure_boot__DOT__rst_n__0)) 
                                                                << 1U) 
                                                               | ((IData)(vlSelfRef.tb_secure_boot__DOT__clk) 
                                                                  & (~ (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_secure_boot__DOT__clk__0))))))));
        vlSelfRef.__Vtrigprevexpr___TOP__tb_secure_boot__DOT__clk__0 
            = vlSelfRef.tb_secure_boot__DOT__clk;
        vlSelfRef.__Vtrigprevexpr___TOP__tb_secure_boot__DOT__rst_n__0 
            = vlSelfRef.tb_secure_boot__DOT__rst_n;
        vlSelfRef.__Vtrigprevexpr___TOP__tb_secure_boot__DOT__dut__DOT__clk_crypto__0 
            = vlSelfRef.tb_secure_boot__DOT__dut__DOT__clk_crypto;
    }
    Vtb_secure_boot___024root___timing_ready(vlSelf);
    Vtb_secure_boot___024root___trigger_orInto__act_vec_vec(vlSelfRef.__VactTriggered, vlSelfRef.__VactTriggeredAcc);
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vtb_secure_boot___024root___dump_triggers__act(vlSelfRef.__VactTriggered, "act"s);
    }
#endif
    Vtb_secure_boot___024root___trigger_orInto__act_vec_vec(vlSelfRef.__VnbaTriggered, vlSelfRef.__VactTriggered);
    __VactExecute = Vtb_secure_boot___024root___trigger_anySet__act(vlSelfRef.__VactTriggered);
    if (__VactExecute) {
        vlSelfRef.__VactTriggeredAcc.fill(0ULL);
        Vtb_secure_boot___024root___timing_resume(vlSelf);
        {
            // Inlined CFunc: _eval_act
            if ((0x0000000000000019ULL & vlSelfRef.__VactTriggered[0U])) {
                {
                    // Inlined CFunc: _act_comb__TOP__0
                    vlSelfRef.tb_secure_boot__DOT__fok 
                        = ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__verified_q) 
                           & ((0x00010044U <= vlSelfRef.tb_secure_boot__DOT__faddr) 
                              & (vlSelfRef.tb_secure_boot__DOT__faddr 
                                 < ((IData)(0x00010044U) 
                                    + ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__code_words_q) 
                                       << 2U)))));
                    vlSelfRef.tb_secure_boot__DOT__dut__DOT__otp_data 
                        = (((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__otp_rd_en) 
                            & ((~ (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_done)) 
                               & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__boot_q)))
                            ? vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_otp__DOT__otp_mem
                           [(0x07ffffffU & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__otp_idx))]
                            : 0U);
                }
            }
            if ((8ULL & vlSelfRef.__VactTriggered[0U])) {
                {
                    // Inlined CFunc: _act_sequent__TOP__0
                    if ((1U & (~ (IData)(vlSelfRef.tb_secure_boot__DOT__clk)))) {
                        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto_cg__DOT__en_latch 
                            = vlSelfRef.tb_secure_boot__DOT__dut__DOT__g_div__DOT__div_q;
                    }
                    vlSelfRef.tb_secure_boot__DOT__dut__DOT__clk_crypto 
                        = ((IData)(vlSelfRef.tb_secure_boot__DOT__clk) 
                           & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto_cg__DOT__en_latch));
                }
            }
        }
    }
    return (__VactExecute);
}

bool Vtb_secure_boot___024root___eval_phase__inact(Vtb_secure_boot___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_secure_boot___024root___eval_phase__inact\n"); );
    Vtb_secure_boot__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VinactExecute;
    // Body
    __VinactExecute = vlSelfRef.__VdlySched.awaitingZeroDelay();
    if (__VinactExecute) {
        VL_FATAL_MT("verif/secure_boot/tb_secure_boot.sv", 15, "", "ZERODLY: Design Verilated with '--no-sched-zero-delay', but #0 delay executed at runtime");
    }
    return (__VinactExecute);
}

void Vtb_secure_boot___024root___trigger_clear__act(VlUnpacked<QData/*63:0*/, 1> &out) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_secure_boot___024root___trigger_clear__act\n"); );
    // Locals
    IData/*31:0*/ n;
    // Body
    n = 0U;
    do {
        out[n] = 0ULL;
        n = ((IData)(1U) + n);
    } while ((1U > n));
}

bool Vtb_secure_boot___024root___eval_phase__nba(Vtb_secure_boot___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_secure_boot___024root___eval_phase__nba\n"); );
    Vtb_secure_boot__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VnbaExecute;
    // Body
    __VnbaExecute = Vtb_secure_boot___024root___trigger_anySet__act(vlSelfRef.__VnbaTriggered);
    if (__VnbaExecute) {
        Vtb_secure_boot___024root___eval_nba(vlSelf);
        Vtb_secure_boot___024root___trigger_clear__act(vlSelfRef.__VnbaTriggered);
    }
    return (__VnbaExecute);
}

void Vtb_secure_boot___024root___eval(Vtb_secure_boot___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_secure_boot___024root___eval\n"); );
    Vtb_secure_boot__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    IData/*31:0*/ __VnbaIterCount;
    // Body
    __VnbaIterCount = 0U;
    do {
        if (VL_UNLIKELY(((0x00002710U < __VnbaIterCount)))) {
#ifdef VL_DEBUG
            Vtb_secure_boot___024root___dump_triggers__act(vlSelfRef.__VnbaTriggered, "nba"s);
#endif
            VL_FATAL_MT("verif/secure_boot/tb_secure_boot.sv", 15, "", "DIDNOTCONVERGE: NBA region did not converge after '--converge-limit' of 10000 tries");
        }
        __VnbaIterCount = ((IData)(1U) + __VnbaIterCount);
        vlSelfRef.__VinactIterCount = 0U;
        do {
            if (VL_UNLIKELY(((0x00002710U < vlSelfRef.__VinactIterCount)))) {
                VL_FATAL_MT("verif/secure_boot/tb_secure_boot.sv", 15, "", "DIDNOTCONVERGE: Inactive region did not converge after '--converge-limit' of 10000 tries");
            }
            vlSelfRef.__VinactIterCount = ((IData)(1U) 
                                           + vlSelfRef.__VinactIterCount);
            vlSelfRef.__VactIterCount = 0U;
            do {
                if (VL_UNLIKELY(((0x00002710U < vlSelfRef.__VactIterCount)))) {
#ifdef VL_DEBUG
                    Vtb_secure_boot___024root___dump_triggers__act(vlSelfRef.__VactTriggered, "act"s);
#endif
                    VL_FATAL_MT("verif/secure_boot/tb_secure_boot.sv", 15, "", "DIDNOTCONVERGE: Active region did not converge after '--converge-limit' of 10000 tries");
                }
                vlSelfRef.__VactIterCount = ((IData)(1U) 
                                             + vlSelfRef.__VactIterCount);
                vlSelfRef.__VactPhaseResult = Vtb_secure_boot___024root___eval_phase__act(vlSelf);
            } while (vlSelfRef.__VactPhaseResult);
            vlSelfRef.__VinactPhaseResult = Vtb_secure_boot___024root___eval_phase__inact(vlSelf);
        } while (vlSelfRef.__VinactPhaseResult);
        vlSelfRef.__VnbaPhaseResult = Vtb_secure_boot___024root___eval_phase__nba(vlSelf);
    } while (vlSelfRef.__VnbaPhaseResult);
}

void Vtb_secure_boot___024root____VbeforeTrig_hedba2121__0(Vtb_secure_boot___024root* vlSelf, const char* __VeventDescription) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_secure_boot___024root____VbeforeTrig_hedba2121__0\n"); );
    Vtb_secure_boot__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    VlUnpacked<QData/*63:0*/, 1> __VTmp;
    // Body
    __VTmp[0U] = (QData)((IData)(((((~ (IData)(vlSelfRef.tb_secure_boot__DOT__clk)) 
                                    & (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_secure_boot__DOT__clk__0)) 
                                   << 4U) | ((IData)(vlSelfRef.tb_secure_boot__DOT__clk) 
                                             & (~ (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_secure_boot__DOT__clk__0))))));
    vlSelfRef.__Vtrigprevexpr___TOP__tb_secure_boot__DOT__clk__0 
        = vlSelfRef.tb_secure_boot__DOT__clk;
    if ((1ULL & __VTmp[0U])) {
        vlSelfRef.__VtrigSched_hedba2121__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hedba2121__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hedba2121__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hedba2121__0.ready(__VeventDescription);
    }
    if ((0x0000000000000010ULL & __VTmp[0U])) {
        vlSelfRef.__VtrigSched_hedba20e2__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hedba20e2__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hedba20e2__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hedba20e2__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hedba20e2__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hedba20e2__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hedba20e2__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hedba20e2__0.ready(__VeventDescription);
    }
    vlSelfRef.__VactTriggeredAcc[0U] = (vlSelfRef.__VactTriggeredAcc[0U] 
                                        | __VTmp[0U]);
}

void Vtb_secure_boot___024root____VbeforeTrig_hedba20e2__0(Vtb_secure_boot___024root* vlSelf, const char* __VeventDescription) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_secure_boot___024root____VbeforeTrig_hedba20e2__0\n"); );
    Vtb_secure_boot__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    VlUnpacked<QData/*63:0*/, 1> __VTmp;
    // Body
    __VTmp[0U] = (QData)((IData)(((((~ (IData)(vlSelfRef.tb_secure_boot__DOT__clk)) 
                                    & (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_secure_boot__DOT__clk__0)) 
                                   << 4U) | ((IData)(vlSelfRef.tb_secure_boot__DOT__clk) 
                                             & (~ (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_secure_boot__DOT__clk__0))))));
    vlSelfRef.__Vtrigprevexpr___TOP__tb_secure_boot__DOT__clk__0 
        = vlSelfRef.tb_secure_boot__DOT__clk;
    if ((1ULL & __VTmp[0U])) {
        vlSelfRef.__VtrigSched_hedba2121__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hedba2121__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hedba2121__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hedba2121__0.ready(__VeventDescription);
    }
    if ((0x0000000000000010ULL & __VTmp[0U])) {
        vlSelfRef.__VtrigSched_hedba20e2__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hedba20e2__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hedba20e2__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hedba20e2__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hedba20e2__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hedba20e2__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hedba20e2__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hedba20e2__0.ready(__VeventDescription);
    }
    vlSelfRef.__VactTriggeredAcc[0U] = (vlSelfRef.__VactTriggeredAcc[0U] 
                                        | __VTmp[0U]);
}

#ifdef VL_DEBUG
void Vtb_secure_boot___024root___eval_debug_assertions(Vtb_secure_boot___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_secure_boot___024root___eval_debug_assertions\n"); );
    Vtb_secure_boot__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}
#endif  // VL_DEBUG
