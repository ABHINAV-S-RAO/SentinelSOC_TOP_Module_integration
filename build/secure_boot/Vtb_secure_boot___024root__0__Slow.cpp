// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtb_secure_boot.h for the primary calling header

#include "Vtb_secure_boot__pch.h"

VL_ATTR_COLD void Vtb_secure_boot_sha512_pkg___eval_static__TOP__sha512_pkg(Vtb_secure_boot_sha512_pkg* vlSelf);
void Vtb_secure_boot___024root___timing_ready(Vtb_secure_boot___024root* vlSelf);

VL_ATTR_COLD void Vtb_secure_boot___024root___eval_static(Vtb_secure_boot___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_secure_boot___024root___eval_static\n"); );
    Vtb_secure_boot__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    Vtb_secure_boot_sha512_pkg___eval_static__TOP__sha512_pkg((&vlSymsp->TOP__sha512_pkg));
    {
        // Inlined CFunc: _eval_static__TOP
        vlSelfRef.tb_secure_boot__DOT__clk = 0U;
        vlSelfRef.tb_secure_boot__DOT__rst_n = 1U;
        vlSelfRef.tb_secure_boot__DOT__faddr = 0U;
        vlSelfRef.tb_secure_boot__DOT__fails = 0U;
    }
    vlSelfRef.__Vtrigprevexpr___TOP__tb_secure_boot__DOT__clk__0 = 0U;
    vlSelfRef.__Vtrigprevexpr___TOP__tb_secure_boot__DOT__rst_n__0 = 1U;
    vlSelfRef.__Vtrigprevexpr___TOP__tb_secure_boot__DOT__dut__DOT__clk_crypto__0 
        = vlSelfRef.tb_secure_boot__DOT__dut__DOT__clk_crypto;
    Vtb_secure_boot___024root___timing_ready(vlSelf);
    do {
        vlSelfRef.__VactTriggeredAcc[vlSelfRef.__Vi] 
            = vlSelfRef.__VactTriggered[vlSelfRef.__Vi];
        vlSelfRef.__Vi = ((IData)(1U) + vlSelfRef.__Vi);
    } while ((0U >= vlSelfRef.__Vi));
}

VL_ATTR_COLD void Vtb_secure_boot___024root___eval_final(Vtb_secure_boot___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_secure_boot___024root___eval_final\n"); );
    Vtb_secure_boot__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_secure_boot___024root___dump_triggers__stl(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag);
#endif  // VL_DEBUG
VL_ATTR_COLD bool Vtb_secure_boot___024root___eval_phase__stl(Vtb_secure_boot___024root* vlSelf);

VL_ATTR_COLD void Vtb_secure_boot___024root___eval_settle(Vtb_secure_boot___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_secure_boot___024root___eval_settle\n"); );
    Vtb_secure_boot__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    IData/*31:0*/ __VstlIterCount;
    // Body
    __VstlIterCount = 0U;
    vlSelfRef.__VstlFirstIteration = 1U;
    do {
        if (VL_UNLIKELY(((0x00002710U < __VstlIterCount)))) {
#ifdef VL_DEBUG
            Vtb_secure_boot___024root___dump_triggers__stl(vlSelfRef.__VstlTriggered, "stl"s);
#endif
            VL_FATAL_MT("verif/secure_boot/tb_secure_boot.sv", 15, "", "DIDNOTCONVERGE: Settle region did not converge after '--converge-limit' of 10000 tries");
        }
        __VstlIterCount = ((IData)(1U) + __VstlIterCount);
        vlSelfRef.__VstlPhaseResult = Vtb_secure_boot___024root___eval_phase__stl(vlSelf);
        vlSelfRef.__VstlFirstIteration = 0U;
    } while (vlSelfRef.__VstlPhaseResult);
}

VL_ATTR_COLD bool Vtb_secure_boot___024root___trigger_anySet__stl(const VlUnpacked<QData/*63:0*/, 1> &in);

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_secure_boot___024root___dump_triggers__stl(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_secure_boot___024root___dump_triggers__stl\n"); );
    // Body
    if ((1U & (~ (IData)(Vtb_secure_boot___024root___trigger_anySet__stl(triggers))))) {
        VL_DBG_MSGS("         No '" + tag + "' region triggers active\n");
    }
    if ((1U & (IData)(triggers[0U]))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 0 is active: Internal 'stl' trigger - first iteration\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD bool Vtb_secure_boot___024root___trigger_anySet__stl(const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_secure_boot___024root___trigger_anySet__stl\n"); );
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

extern const VlUnpacked<CData/*2:0*/, 2048> Vtb_secure_boot__ConstPool__TABLE_h54cb72e1_0;
extern const VlUnpacked<CData/*0:0*/, 2048> Vtb_secure_boot__ConstPool__TABLE_hcb85b0e9_0;
extern const VlWide<16>/*511:0*/ Vtb_secure_boot__ConstPool__CONST_h93e1b771_0;
extern const VlUnpacked<CData/*4:0*/, 2048> Vtb_secure_boot__ConstPool__TABLE_h377e3154_0;
extern const VlUnpacked<CData/*4:0*/, 2048> Vtb_secure_boot__ConstPool__TABLE_ha6b46106_0;
extern const VlWide<9>/*287:0*/ Vtb_secure_boot__ConstPool__CONST_h0efaa2d9_0;
extern const VlUnpacked<CData/*0:0*/, 512> Vtb_secure_boot__ConstPool__TABLE_h5dcdb5a1_0;

VL_ATTR_COLD void Vtb_secure_boot___024root___stl_sequent__TOP__0(Vtb_secure_boot___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_secure_boot___024root___stl_sequent__TOP__0\n"); );
    Vtb_secure_boot__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    VlWide<16>/*511:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__pm_input;
    VL_ZERO_W(512, tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__pm_input);
    VlWide<9>/*262:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__u_pm_reducer__DOT__stage1_sum;
    VL_ZERO_W(263, tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__u_pm_reducer__DOT__stage1_sum);
    Vtb_secure_boot_csa_t__struct__0 tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_round__DOT__r1;
    tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_round__DOT__r1.__PVT__sum = 0;
    tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_round__DOT__r1.__PVT__carry = 0;
    Vtb_secure_boot_csa_t__struct__0 tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_round__DOT__r2;
    tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_round__DOT__r2.__PVT__sum = 0;
    tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_round__DOT__r2.__PVT__carry = 0;
    Vtb_secure_boot_csa_t__struct__0 tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_round__DOT__r3;
    tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_round__DOT__r3.__PVT__sum = 0;
    tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_round__DOT__r3.__PVT__carry = 0;
    QData/*63:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT____VlemCall_1__lower_sigma0;
    QData/*63:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT____VlemCall_0__lower_sigma1;
    Vtb_secure_boot_csa_t__struct__0 tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__stage1;
    tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__stage1.__PVT__sum = 0;
    tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__stage1.__PVT__carry = 0;
    Vtb_secure_boot_csa_t__struct__0 tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__stage2;
    tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__stage2.__PVT__sum = 0;
    tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__stage2.__PVT__carry = 0;
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
    VlWide<9>/*256:0*/ __VdfgRegularize_h6e95ff9d_0_20;
    VL_ZERO_W(257, __VdfgRegularize_h6e95ff9d_0_20);
    VlWide<9>/*256:0*/ __VdfgRegularize_h6e95ff9d_0_21;
    VL_ZERO_W(257, __VdfgRegularize_h6e95ff9d_0_21);
    QData/*63:0*/ __VdfgRegularize_h6e95ff9d_0_26;
    __VdfgRegularize_h6e95ff9d_0_26 = 0;
    VlWide<4>/*127:0*/ __Vtemp_1;
    VlWide<4>/*127:0*/ __Vtemp_2;
    VlWide<9>/*287:0*/ __Vtemp_4;
    VlWide<9>/*287:0*/ __Vtemp_5;
    VlWide<9>/*287:0*/ __Vtemp_7;
    VlWide<9>/*287:0*/ __Vtemp_9;
    VlWide<9>/*287:0*/ __Vtemp_10;
    VlWide<9>/*287:0*/ __Vtemp_11;
    VlWide<9>/*287:0*/ __Vtemp_12;
    VlWide<8>/*255:0*/ __Vtemp_13;
    VlWide<8>/*255:0*/ __Vtemp_16;
    // Body
    vlSelfRef.tb_secure_boot__DOT__vreq = ((1U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__state_q)) 
                                           | ((4U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__state_q)) 
                                              | (0x0aU 
                                                 == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__state_q))));
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_prep__DOT__C 
        = (0x0000003fU & ((0x1cU <= (0x0000001fU & vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__msg_length))
                           ? ((IData)(0x3dU) - (0x0000001fU 
                                                & vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__msg_length))
                           : ((IData)(0x1dU) - (0x0000001fU 
                                                & vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__msg_length))));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_23 = (1U 
                                                 & (~ (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_prep__DOT__state)));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_24 = (1U 
                                                 & (~ 
                                                    ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_prep__DOT__state) 
                                                     >> 1U)));
    if ((8U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__state_q))) {
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__c_wdata 
            = vlSelfRef.tb_secure_boot__DOT__dut__DOT__word_q;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__c_addr 
            = ((4U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__state_q))
                ? (0x0014U & (- (IData)((1U & (~ (0U 
                                                  != 
                                                  (3U 
                                                   & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__state_q))))))))
                : (4U & (- (IData)((1U & (~ (0U != 
                                             (3U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__state_q)))))))));
    } else if ((4U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__state_q))) {
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__c_wdata 
            = ((2U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__state_q))
                ? ((1U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__state_q))
                    ? 1U : vlSelfRef.tb_secure_boot__DOT__dut__DOT__word_q)
                : vlSelfRef.tb_secure_boot__DOT__dut__DOT__word_q);
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__c_addr 
            = ((- (IData)((1U & (~ (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__state_q))))) 
               & (((8U >= (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__idx_q))
                    ? 0x000cU : 0x0010U) & (- (IData)(
                                                      (1U 
                                                       & ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__state_q) 
                                                          >> 1U))))));
    } else {
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__c_wdata 
            = vlSelfRef.tb_secure_boot__DOT__dut__DOT__word_q;
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__c_addr 
            = (8U & (- (IData)((3U == (3U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__state_q))))));
    }
    vlSelfRef.tb_secure_boot__DOT__dut__DOT____Vcellinp__u_crypto__start_verify_i 
        = ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__g_div__DOT__div_q) 
           & (7U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__state_q)));
    vlSelfRef.tb_secure_boot__DOT__fok = ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__verified_q) 
                                          & ((0x00010044U 
                                              <= vlSelfRef.tb_secure_boot__DOT__faddr) 
                                             & (vlSelfRef.tb_secure_boot__DOT__faddr 
                                                < ((IData)(0x00010044U) 
                                                   + 
                                                   ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__code_words_q) 
                                                    << 2U)))));
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_valid 
        = (IData)((((0x22U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state)) 
                    & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__x_eq_flag)) 
                   & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__y_eq_flag)));
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
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__prep_start 
        = ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_wen) 
           & ((0x20U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_addr)) 
              & vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_wdata));
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__prep_word_ack 
        = ((2U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__state)) 
           | ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_wen) 
              & ((0x20U > (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_addr)) 
                 & (1U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__state)))));
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__shift_amt 
        = (7U & ((3U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__count)) 
                 + (3U & ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__count) 
                          >> 2U))));
    if ((1U & (~ (IData)(vlSelfRef.tb_secure_boot__DOT__clk)))) {
        vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto_cg__DOT__en_latch 
            = vlSelfRef.tb_secure_boot__DOT__dut__DOT__g_div__DOT__div_q;
    }
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_done 
        = (IData)((0x22U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state)));
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
    __VdfgRegularize_h6e95ff9d_0_26 = (- (QData)((IData)(
                                                         ((1U 
                                                           == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__state)) 
                                                          & (0x10U 
                                                             > (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__count))))));
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__c_we = (IData)(
                                                            (8U 
                                                             != (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__state_q)));
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__c_gnt 
        = ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__g_div__DOT__div_q) 
           & ((8U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__state_q))
               ? (~ (0U != (3U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__state_q))))
               : ((4U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__state_q))
                   ? ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__state_q) 
                      >> 1U) : (3U == (3U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__state_q))))));
    if (vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__seq_done_reg) {
        vlSelfRef.__VdfgRegularize_h6e95ff9d_0_15 = 9U;
        vlSelfRef.__VdfgRegularize_h6e95ff9d_0_16 = 0x14U;
    } else {
        vlSelfRef.__VdfgRegularize_h6e95ff9d_0_15 = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state;
        vlSelfRef.__VdfgRegularize_h6e95ff9d_0_16 = vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state;
    }
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
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__clk_crypto 
        = ((IData)(vlSelfRef.tb_secure_boot__DOT__clk) 
           & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto_cg__DOT__en_latch));
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__otp_data 
        = (((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__otp_rd_en) 
            & ((~ (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_done)) 
               & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__boot_q)))
            ? vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_otp__DOT__otp_mem
           [(0x07ffffffU & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__otp_idx))]
            : 0U);
    __Vtemp_1[0U] = (IData)((((2U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__count))
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
    __Vtemp_1[1U] = (IData)(((((2U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__count))
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
    __Vtemp_1[2U] = 0U;
    __Vtemp_1[3U] = 0U;
    __Vtemp_2[0U] = (IData)((((8U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__count))
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
    __Vtemp_2[1U] = (IData)(((((8U & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__count))
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
    __Vtemp_2[2U] = 0U;
    __Vtemp_2[3U] = 0U;
    VL_MUL_W(4, vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__prod, __Vtemp_1, __Vtemp_2);
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_1 = ((IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__c_we) 
                                                & (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__c_gnt));
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
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ctrl_wr 
        = ((0U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__c_addr)) 
           & (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_1));
    vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__datain_wr 
        = ((0x0014U == (IData)(vlSelfRef.tb_secure_boot__DOT__dut__DOT__c_addr)) 
           & (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_1));
    __Vtemp_4[0U] = tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__pm_input[8U];
    __Vtemp_4[1U] = tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__pm_input[9U];
    __Vtemp_4[2U] = tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__pm_input[10U];
    __Vtemp_4[3U] = tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__pm_input[11U];
    __Vtemp_4[4U] = tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__pm_input[12U];
    __Vtemp_4[5U] = tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__pm_input[13U];
    __Vtemp_4[6U] = tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__pm_input[14U];
    __Vtemp_4[7U] = tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__pm_input[15U];
    __Vtemp_4[8U] = 0U;
    VL_MUL_W(9, __Vtemp_5, Vtb_secure_boot__ConstPool__CONST_h0efaa2d9_0, __Vtemp_4);
    __Vtemp_7[0U] = __Vtemp_5[0U];
    __Vtemp_7[1U] = __Vtemp_5[1U];
    __Vtemp_7[2U] = __Vtemp_5[2U];
    __Vtemp_7[3U] = __Vtemp_5[3U];
    __Vtemp_7[4U] = __Vtemp_5[4U];
    __Vtemp_7[5U] = __Vtemp_5[5U];
    __Vtemp_7[6U] = __Vtemp_5[6U];
    __Vtemp_7[7U] = __Vtemp_5[7U];
    __Vtemp_7[8U] = (0x0000003fU & __Vtemp_5[8U]);
    __Vtemp_9[0U] = tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__pm_input[0U];
    __Vtemp_9[1U] = tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__pm_input[1U];
    __Vtemp_9[2U] = tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__pm_input[2U];
    __Vtemp_9[3U] = tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__pm_input[3U];
    __Vtemp_9[4U] = tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__pm_input[4U];
    __Vtemp_9[5U] = tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__pm_input[5U];
    __Vtemp_9[6U] = tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__pm_input[6U];
    __Vtemp_9[7U] = tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__pm_input[7U];
    __Vtemp_9[8U] = 0U;
    VL_ADD_W(9, __Vtemp_10, __Vtemp_7, __Vtemp_9);
    tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__u_pm_reducer__DOT__stage1_sum[0U] 
        = __Vtemp_10[0U];
    tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__u_pm_reducer__DOT__stage1_sum[1U] 
        = __Vtemp_10[1U];
    tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__u_pm_reducer__DOT__stage1_sum[2U] 
        = __Vtemp_10[2U];
    tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__u_pm_reducer__DOT__stage1_sum[3U] 
        = __Vtemp_10[3U];
    tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__u_pm_reducer__DOT__stage1_sum[4U] 
        = __Vtemp_10[4U];
    tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__u_pm_reducer__DOT__stage1_sum[5U] 
        = __Vtemp_10[5U];
    tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__u_pm_reducer__DOT__stage1_sum[6U] 
        = __Vtemp_10[6U];
    tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__u_pm_reducer__DOT__stage1_sum[7U] 
        = __Vtemp_10[7U];
    tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__u_pm_reducer__DOT__stage1_sum[8U] 
        = (0x0000007fU & __Vtemp_10[8U]);
    VL_SUB_W(9, __Vtemp_11, __VdfgRegularize_h6e95ff9d_0_21, __VdfgRegularize_h6e95ff9d_0_20);
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_14[0U] = __Vtemp_11[0U];
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_14[1U] = __Vtemp_11[1U];
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_14[2U] = __Vtemp_11[2U];
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_14[3U] = __Vtemp_11[3U];
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_14[4U] = __Vtemp_11[4U];
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_14[5U] = __Vtemp_11[5U];
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_14[6U] = __Vtemp_11[6U];
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_14[7U] = __Vtemp_11[7U];
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_14[8U] = 
        (1U & __Vtemp_11[8U]);
    VL_ADD_W(9, __Vtemp_12, __VdfgRegularize_h6e95ff9d_0_20, __VdfgRegularize_h6e95ff9d_0_21);
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_22[0U] = __Vtemp_12[0U];
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_22[1U] = __Vtemp_12[1U];
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_22[2U] = __Vtemp_12[2U];
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_22[3U] = __Vtemp_12[3U];
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_22[4U] = __Vtemp_12[4U];
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_22[5U] = __Vtemp_12[5U];
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_22[6U] = __Vtemp_12[6U];
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_22[7U] = __Vtemp_12[7U];
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_22[8U] = 
        (1U & __Vtemp_12[8U]);
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
    __Vtemp_13[0U] = (0x00001fffU & ((IData)(0x0013U) 
                                     * (0x000000ffU 
                                        & ((tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__u_pm_reducer__DOT__stage1_sum[8U] 
                                            << 1U) 
                                           | (tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__u_pm_reducer__DOT__stage1_sum[7U] 
                                              >> 0x0000001fU)))));
    __Vtemp_13[1U] = 0U;
    __Vtemp_13[2U] = 0U;
    __Vtemp_13[3U] = 0U;
    __Vtemp_13[4U] = 0U;
    __Vtemp_13[5U] = 0U;
    __Vtemp_13[6U] = 0U;
    __Vtemp_13[7U] = 0U;
    __Vtemp_16[0U] = tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__u_pm_reducer__DOT__stage1_sum[0U];
    __Vtemp_16[1U] = tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__u_pm_reducer__DOT__stage1_sum[1U];
    __Vtemp_16[2U] = tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__u_pm_reducer__DOT__stage1_sum[2U];
    __Vtemp_16[3U] = tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__u_pm_reducer__DOT__stage1_sum[3U];
    __Vtemp_16[4U] = tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__u_pm_reducer__DOT__stage1_sum[4U];
    __Vtemp_16[5U] = tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__u_pm_reducer__DOT__stage1_sum[5U];
    __Vtemp_16[6U] = tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__u_pm_reducer__DOT__stage1_sum[6U];
    __Vtemp_16[7U] = (0x7fffffffU & tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__u_pm_reducer__DOT__stage1_sum[7U]);
    VL_ADD_W(8, vlSelfRef.tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__u_pm_reducer__DOT__stage2_sum, __Vtemp_13, __Vtemp_16);
}

VL_ATTR_COLD bool Vtb_secure_boot___024root___eval_phase__stl(Vtb_secure_boot___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_secure_boot___024root___eval_phase__stl\n"); );
    Vtb_secure_boot__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VstlExecute;
    // Body
    {
        // Inlined CFunc: _eval_triggers_vec__stl
        vlSelfRef.__VstlTriggered[0U] = ((0xfffffffffffffffeULL 
                                          & vlSelfRef.__VstlTriggered[0U]) 
                                         | (IData)((IData)(vlSelfRef.__VstlFirstIteration)));
    }
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vtb_secure_boot___024root___dump_triggers__stl(vlSelfRef.__VstlTriggered, "stl"s);
    }
#endif
    __VstlExecute = Vtb_secure_boot___024root___trigger_anySet__stl(vlSelfRef.__VstlTriggered);
    if (__VstlExecute) {
        {
            // Inlined CFunc: _eval_stl
            if ((1ULL & vlSelfRef.__VstlTriggered[0U])) {
                Vtb_secure_boot___024root___stl_sequent__TOP__0(vlSelf);
            }
        }
    }
    return (__VstlExecute);
}

bool Vtb_secure_boot___024root___trigger_anySet__act(const VlUnpacked<QData/*63:0*/, 1> &in);

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_secure_boot___024root___dump_triggers__act(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_secure_boot___024root___dump_triggers__act\n"); );
    // Body
    if ((1U & (~ (IData)(Vtb_secure_boot___024root___trigger_anySet__act(triggers))))) {
        VL_DBG_MSGS("         No '" + tag + "' region triggers active\n");
    }
    if ((1U & (IData)(triggers[0U]))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 0 is active: @(posedge tb_secure_boot.clk)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 1U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 1 is active: @(negedge tb_secure_boot.rst_n)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 2U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 2 is active: @(posedge tb_secure_boot.dut.clk_crypto)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 3U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 3 is active: @([true] __VdlySched.awaitingCurrentTime())\n");
    }
    if ((1U & (IData)((triggers[0U] >> 4U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 4 is active: @(negedge tb_secure_boot.clk)\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD void Vtb_secure_boot___024root___ctor_var_reset(Vtb_secure_boot___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_secure_boot___024root___ctor_var_reset\n"); );
    Vtb_secure_boot__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    const uint64_t __VscopeHash = VL_MURMUR64_HASH(vlSelf->vlNamep);
    for (int __Vi0 = 0; __Vi0 < 1024; ++__Vi0) {
        vlSelf->tb_secure_boot__DOT__isram[__Vi0] = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 7583377857279446920ull);
    }
    vlSelf->tb_secure_boot__DOT__vreq = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 3300049399393039346ull);
    vlSelf->tb_secure_boot__DOT__vrv = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 12508918666093444023ull);
    vlSelf->tb_secure_boot__DOT__vrdata = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 13258178916571116476ull);
    vlSelf->tb_secure_boot__DOT__req = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 4136238353746396691ull);
    vlSelf->tb_secure_boot__DOT__we = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 10366296922420325615ull);
    vlSelf->tb_secure_boot__DOT__addr = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 4802885324986501780ull);
    vlSelf->tb_secure_boot__DOT__wdata = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 8884714778406565961ull);
    vlSelf->tb_secure_boot__DOT__rdata = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 16717339309882925789ull);
    vlSelf->tb_secure_boot__DOT__fok = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 9458102359033771449ull);
    for (int __Vi0 = 0; __Vi0 < 8; ++__Vi0) {
        vlSelf->tb_secure_boot__DOT__pk[__Vi0] = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 16317591668895003268ull);
    }
    VL_SCOPED_RAND_RESET_W(256, vlSelf->tb_secure_boot__DOT__otp_key, __VscopeHash, 12478909879454341667ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__clk_crypto = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 18211070980365763622ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__c_we = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 8500366729894676034ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__c_addr = VL_SCOPED_RAND_RESET_I(12, __VscopeHash, 6180127170996697502ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__c_wdata = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 1272226928712205399ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__c_rdata = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 708599197357693890ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__c_gnt = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 11647821795481391198ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__c_rvalid_q = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 10198573214442865495ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__otp_rd_en = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 16299131420994416225ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__otp_data = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 11800021130374613892ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT____Vcellinp__u_crypto__start_verify_i = 0;
    vlSelf->tb_secure_boot__DOT__dut__DOT__state_q = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 9627464073746832069ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__idx_q = VL_SCOPED_RAND_RESET_I(11, __VscopeHash, 3245079635749377584ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__left_q = VL_SCOPED_RAND_RESET_I(11, __VscopeHash, 12143733710508824626ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__code_words_q = VL_SCOPED_RAND_RESET_I(11, __VscopeHash, 844905823838251146ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__word_q = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 2710257104289868265ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__done_q = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 18231744027124757450ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__valid_q = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 6790094175462172199ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__verified_q = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 18175676764122195879ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__err_q = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 7817194263369487589ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__ran_q = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 9241648672135131403ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__dirty_q = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 9820789178567812416ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__g_div__DOT__div_q = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 17308612562713687088ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_addr = VL_SCOPED_RAND_RESET_I(6, __VscopeHash, 7323711648301526964ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_wen = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 17691563746706081089ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_wdata = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 3649457255318772093ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_rdata = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 9214138266787963409ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_intr = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 27100693446383930ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_start = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 13796201560160958353ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_done = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 10814776055176005275ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_valid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 5055002359757561756ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_ext_we = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 2152991709901769256ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_dest = VL_SCOPED_RAND_RESET_I(5, __VscopeHash, 18323331917510153212ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_dsel = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 12029193161651197861ull);
    VL_SCOPED_RAND_RESET_W(256, vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_din, __VscopeHash, 12914363489183794482ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__state = VL_SCOPED_RAND_RESET_I(5, __VscopeHash, 7739816584213367750ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_len_reg = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 7392798166229452738ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__msg_len_csr = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 9123834488039953753ull);
    VL_SCOPED_RAND_RESET_W(256, vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__s_reg, __VscopeHash, 12012619435444802489ull);
    VL_SCOPED_RAND_RESET_W(256, vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_reg, __VscopeHash, 12349190667269405784ull);
    VL_SCOPED_RAND_RESET_W(256, vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__pubkey_reg, __VscopeHash, 15209719112821525858ull);
    VL_SCOPED_RAND_RESET_W(512, vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg, __VscopeHash, 5339729063515975707ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_fed = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 1431748368489466818ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__blk_ptr = VL_SCOPED_RAND_RESET_I(5, __VscopeHash, 14548933205980760311ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__otp_idx = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 12271288447111318234ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_idx = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 893852473715161970ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_idx = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 683311201087777324ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__load_idx = VL_SCOPED_RAND_RESET_I(5, __VscopeHash, 13083935412475219992ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__data_in_reg = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 2019322733503373124ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__data_pending = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 4188323856781192848ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__start_latch = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 14514695231672662272ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__boot_q = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 16782036293380255672ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ctrl_wr = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 6623432291789774709ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__datain_wr = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 13251035734016743434ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__reg_we = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 7147820176139723233ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__cmp_eq = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 1077580449338660530ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__mult_done = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 16469260789658842417ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__x_sign = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 2195213125615868279ull);
    VL_SCOPED_RAND_RESET_W(256, vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__u_pm_reducer__DOT__stage2_sum, __VscopeHash, 9088532145114407002ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__state = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 10231297783948394194ull);
    VL_SCOPED_RAND_RESET_W(256, vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__a_reg, __VscopeHash, 13581839827427094945ull);
    VL_SCOPED_RAND_RESET_W(256, vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__b_reg, __VscopeHash, 16512907207770045251ull);
    VL_SCOPED_RAND_RESET_W(512, vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg, __VscopeHash, 2712124791553204071ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__count = VL_SCOPED_RAND_RESET_I(5, __VscopeHash, 16031138428940864100ull);
    VL_SCOPED_RAND_RESET_W(128, vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__prod, __VscopeHash, 13342300920138145773ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__shift_amt = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 2464500823302027312ull);
    VL_SCOPED_RAND_RESET_W(512, vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__shifted_prod_r, __VscopeHash, 16386911917175627170ull);
    for (int __Vi0 = 0; __Vi0 < 32; ++__Vi0) {
        VL_SCOPED_RAND_RESET_W(256, vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem[__Vi0], __VscopeHash, 6352595023932105569ull);
    }
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__sub_step = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 18239275016402762895ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__step_counter = VL_SCOPED_RAND_RESET_I(6, __VscopeHash, 16541595674966299888ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__seq_done_reg = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 7476408132627861831ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state = VL_SCOPED_RAND_RESET_I(6, __VscopeHash, 12276636415312940119ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__next_state = VL_SCOPED_RAND_RESET_I(6, __VscopeHash, 11641945834354387867ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__return_state = VL_SCOPED_RAND_RESET_I(6, __VscopeHash, 8662300891928215550ull);
    VL_SCOPED_RAND_RESET_W(256, vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__scalar_reg, __VscopeHash, 15514745669855018009ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__bit_counter = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 15575871632310645058ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__target_exponent = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 2283461306450687772ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__is_decomp_pubkey = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 11735596518344485032ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__x_eq_flag = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 617786809643695798ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__y_eq_flag = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 17635116920636998255ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__start_seq_reg = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 444469880463428255ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__state = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 520928999599564763ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__round_count = VL_SCOPED_RAND_RESET_I(7, __VscopeHash, 6039200947398342397ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__word_count = VL_SCOPED_RAND_RESET_I(6, __VscopeHash, 1155314586624005911ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__is_last_block = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 15415606249919130687ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__msg_length = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 10486508074013421569ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__a = VL_SCOPED_RAND_RESET_Q(64, __VscopeHash, 12466763028983282963ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__b = VL_SCOPED_RAND_RESET_Q(64, __VscopeHash, 7833690488364273470ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__c = VL_SCOPED_RAND_RESET_Q(64, __VscopeHash, 6666366510232925159ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__d = VL_SCOPED_RAND_RESET_Q(64, __VscopeHash, 14668238986950644637ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__e = VL_SCOPED_RAND_RESET_Q(64, __VscopeHash, 8194930900101582267ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__f = VL_SCOPED_RAND_RESET_Q(64, __VscopeHash, 6804897152467283059ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__g = VL_SCOPED_RAND_RESET_Q(64, __VscopeHash, 17514414492610996214ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__h = VL_SCOPED_RAND_RESET_Q(64, __VscopeHash, 10997063209291775960ull);
    for (int __Vi0 = 0; __Vi0 < 8; ++__Vi0) {
        vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H[__Vi0] = VL_SCOPED_RAND_RESET_Q(64, __VscopeHash, 940192666175915575ull);
    }
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__w_i = VL_SCOPED_RAND_RESET_Q(64, __VscopeHash, 12915559621123216598ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__k_i = VL_SCOPED_RAND_RESET_Q(64, __VscopeHash, 9567513040242554631ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__prep_start = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 4726874850583381201ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__prep_word_ack = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 2886422428546540854ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__sched_addr = VL_SCOPED_RAND_RESET_I(5, __VscopeHash, 5387136590349263844ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__sched_wdata = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 1432602574022003512ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_round__DOT__t1 = VL_SCOPED_RAND_RESET_Q(64, __VscopeHash, 6008484179467764477ull);
    for (int __Vi0 = 0; __Vi0 < 16; ++__Vi0) {
        vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w[__Vi0] = VL_SCOPED_RAND_RESET_Q(64, __VscopeHash, 1496462171523544113ull);
    }
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w_next = VL_SCOPED_RAND_RESET_Q(64, __VscopeHash, 11235212107497283518ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_prep__DOT__state = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 12794895939018495871ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_prep__DOT__N_cnt = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 10968935750771125219ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_prep__DOT__C_cnt = VL_SCOPED_RAND_RESET_I(6, __VscopeHash, 1573815974517842430ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_prep__DOT__C = VL_SCOPED_RAND_RESET_I(6, __VscopeHash, 11889054141775540701ull);
    VL_SCOPED_RAND_RESET_W(256, vlSelf->tb_secure_boot__DOT__dut__DOT__u_otp__DOT__otp_mem, __VscopeHash, 975396047976761512ull);
    vlSelf->tb_secure_boot__DOT__dut__DOT__u_crypto_cg__DOT__en_latch = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 11572943827692037307ull);
    vlSelf->__VdfgRegularize_h6e95ff9d_0_0 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_1 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_2 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_8 = 0;
    VL_ZERO_RESET_W(192, vlSelf->__VdfgRegularize_h6e95ff9d_0_10);
    vlSelf->__VdfgRegularize_h6e95ff9d_0_13 = 0;
    VL_ZERO_RESET_W(257, vlSelf->__VdfgRegularize_h6e95ff9d_0_14);
    vlSelf->__VdfgRegularize_h6e95ff9d_0_15 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_16 = 0;
    VL_ZERO_RESET_W(257, vlSelf->__VdfgRegularize_h6e95ff9d_0_22);
    vlSelf->__VdfgRegularize_h6e95ff9d_0_23 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_24 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_25 = 0;
    vlSelf->__Vdly__tb_secure_boot__DOT__dut__DOT__idx_q = 0;
    VL_ZERO_RESET_W(256, vlSelf->__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_reg);
    VL_ZERO_RESET_W(256, vlSelf->__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__s_reg);
    vlSelf->__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__data_pending = 0;
    vlSelf->__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__start_latch = 0;
    vlSelf->__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__state = 0;
    vlSelf->__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_fed = 0;
    vlSelf->__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__blk_ptr = 0;
    vlSelf->__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__otp_idx = 0;
    vlSelf->__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_idx = 0;
    vlSelf->__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__load_idx = 0;
    VL_ZERO_RESET_W(512, vlSelf->__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg);
    vlSelf->__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_idx = 0;
    vlSelf->__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_wdata = 0;
    VL_ZERO_RESET_W(512, vlSelf->__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg);
    vlSelf->__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__count = 0;
    vlSelf->__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__state = 0;
    vlSelf->__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__sub_step = 0;
    vlSelf->__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__seq_done_reg = 0;
    VL_ZERO_RESET_W(256, vlSelf->__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__scalar_reg);
    vlSelf->__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__bit_counter = 0;
    vlSelf->__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__word_count = 0;
    vlSelf->__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__is_last_block = 0;
    vlSelf->__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__state = 0;
    vlSelf->__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__a = 0;
    vlSelf->__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__b = 0;
    vlSelf->__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__c = 0;
    vlSelf->__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__d = 0;
    vlSelf->__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__e = 0;
    vlSelf->__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__f = 0;
    vlSelf->__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__g = 0;
    vlSelf->__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__h = 0;
    vlSelf->__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__round_count = 0;
    vlSelf->__Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_prep__DOT__state = 0;
    vlSelf->__VdlySet__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v0 = 0;
    vlSelf->__VdlySet__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v8 = 0;
    vlSelf->__VdlySet__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v10 = 0;
    vlSelf->__VdlySet__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v16 = 0;
    vlSelf->__VdlySet__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v17 = 0;
    vlSelf->__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v0 = 0;
    vlSelf->__VdlyDim0__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v0 = 0;
    vlSelf->__VdlySet__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v0 = 0;
    vlSelf->__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v1 = 0;
    vlSelf->__VdlyDim0__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v1 = 0;
    vlSelf->__VdlySet__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v1 = 0;
    vlSelf->__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v2 = 0;
    vlSelf->__VdlySet__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v2 = 0;
    vlSelf->__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v3 = 0;
    vlSelf->__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v4 = 0;
    vlSelf->__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v5 = 0;
    vlSelf->__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v6 = 0;
    vlSelf->__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v7 = 0;
    vlSelf->__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v8 = 0;
    vlSelf->__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v9 = 0;
    vlSelf->__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v10 = 0;
    vlSelf->__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v11 = 0;
    vlSelf->__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v12 = 0;
    vlSelf->__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v13 = 0;
    vlSelf->__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v14 = 0;
    vlSelf->__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v15 = 0;
    vlSelf->__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v16 = 0;
    vlSelf->__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v17 = 0;
    vlSelf->__VdlySet__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v18 = 0;
    VL_ZERO_RESET_W(256, vlSelf->__VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0);
    vlSelf->__VdlyDim0__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0 = 0;
    vlSelf->__VdlySet__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0 = 0;
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        vlSelf->__VstlTriggered[__Vi0] = 0;
    }
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        vlSelf->__VactTriggered[__Vi0] = 0;
    }
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        vlSelf->__VactTriggeredAcc[__Vi0] = 0;
    }
    vlSelf->__Vtrigprevexpr___TOP__tb_secure_boot__DOT__clk__0 = 0;
    vlSelf->__Vtrigprevexpr___TOP__tb_secure_boot__DOT__rst_n__0 = 0;
    vlSelf->__Vtrigprevexpr___TOP__tb_secure_boot__DOT__dut__DOT__clk_crypto__0 = 0;
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        vlSelf->__VnbaTriggered[__Vi0] = 0;
    }
    vlSelf->__Vi = 0;
}
