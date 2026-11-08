// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vtb_secure_boot.h for the primary calling header

#ifndef VERILATED_VTB_SECURE_BOOT___024ROOT_H_
#define VERILATED_VTB_SECURE_BOOT___024ROOT_H_  // guard

#include "verilated.h"
#include "verilated_timing.h"
#include "Vtb_secure_boot_sha512_pkg.h"


class Vtb_secure_boot__Syms;

class alignas(VL_CACHE_LINE_BYTES) Vtb_secure_boot___024root final {
  public:
    // CELLS
    Vtb_secure_boot_sha512_pkg* __PVT__sha512_pkg;

    // DESIGN SPECIFIC STATE
    // Anonymous structures to workaround compiler member-count bugs
    struct {
        CData/*0:0*/ tb_secure_boot__DOT__clk;
        CData/*0:0*/ tb_secure_boot__DOT__rst_n;
        CData/*0:0*/ tb_secure_boot__DOT__vreq;
        CData/*0:0*/ tb_secure_boot__DOT__vrv;
        CData/*0:0*/ tb_secure_boot__DOT__req;
        CData/*0:0*/ tb_secure_boot__DOT__we;
        CData/*0:0*/ tb_secure_boot__DOT__fok;
        CData/*0:0*/ tb_secure_boot__DOT__facc;
        CData/*0:0*/ tb_secure_boot__DOT__dut__DOT__clk_crypto;
        CData/*0:0*/ tb_secure_boot__DOT__dut__DOT__c_we;
        CData/*0:0*/ tb_secure_boot__DOT__dut__DOT__c_gnt;
        CData/*0:0*/ tb_secure_boot__DOT__dut__DOT__c_rvalid_q;
        CData/*0:0*/ tb_secure_boot__DOT__dut__DOT__otp_rd_en;
        CData/*0:0*/ tb_secure_boot__DOT__dut__DOT____Vcellinp__u_crypto__start_verify_i;
        CData/*3:0*/ tb_secure_boot__DOT__dut__DOT__state_q;
        CData/*0:0*/ tb_secure_boot__DOT__dut__DOT__done_q;
        CData/*0:0*/ tb_secure_boot__DOT__dut__DOT__valid_q;
        CData/*0:0*/ tb_secure_boot__DOT__dut__DOT__verified_q;
        CData/*0:0*/ tb_secure_boot__DOT__dut__DOT__err_q;
        CData/*0:0*/ tb_secure_boot__DOT__dut__DOT__ran_q;
        CData/*0:0*/ tb_secure_boot__DOT__dut__DOT__dirty_q;
        CData/*0:0*/ tb_secure_boot__DOT__dut__DOT__start_w;
        CData/*0:0*/ tb_secure_boot__DOT__dut__DOT__entered_q;
        CData/*0:0*/ tb_secure_boot__DOT__dut__DOT__started_q;
        CData/*0:0*/ tb_secure_boot__DOT__dut__DOT__g_div__DOT__div_q;
        CData/*5:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_addr;
        CData/*0:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_wen;
        CData/*0:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_intr;
        CData/*0:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_start;
        CData/*0:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_done;
        CData/*0:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_valid;
        CData/*0:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_ext_we;
        CData/*4:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_dest;
        CData/*1:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_dsel;
        CData/*4:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__state;
        CData/*4:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__blk_ptr;
        CData/*2:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__otp_idx;
        CData/*2:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_idx;
        CData/*3:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_idx;
        CData/*4:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__load_idx;
        CData/*0:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__data_pending;
        CData/*0:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__start_latch;
        CData/*0:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__boot_q;
        CData/*0:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ctrl_wr;
        CData/*0:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__datain_wr;
        CData/*0:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__reg_we;
        CData/*0:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__cmp_eq;
        CData/*0:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__mult_done;
        CData/*0:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__x_sign;
        CData/*1:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__state;
        CData/*4:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__count;
        CData/*2:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__shift_amt;
        CData/*2:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__sub_step;
        CData/*5:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__step_counter;
        CData/*0:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__seq_done_reg;
        CData/*5:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__state;
        CData/*5:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__next_state;
        CData/*5:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__return_state;
        CData/*7:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__bit_counter;
        CData/*0:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__target_exponent;
        CData/*0:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__is_decomp_pubkey;
        CData/*0:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__x_eq_flag;
        CData/*0:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__y_eq_flag;
        CData/*0:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__start_seq_reg;
    };
    struct {
        CData/*2:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__state;
        CData/*6:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__round_count;
        CData/*5:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__word_count;
        CData/*0:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__is_last_block;
        CData/*0:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__prep_start;
        CData/*0:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__prep_word_ack;
        CData/*4:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__sched_addr;
        CData/*2:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_prep__DOT__state;
        CData/*5:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_prep__DOT__C_cnt;
        CData/*5:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_prep__DOT__C;
        CData/*0:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto_cg__DOT__en_latch;
        CData/*0:0*/ __VdfgRegularize_h6e95ff9d_0_1;
        CData/*0:0*/ __VdfgRegularize_h6e95ff9d_0_2;
        CData/*0:0*/ __VdfgRegularize_h6e95ff9d_0_8;
        CData/*0:0*/ __VdfgRegularize_h6e95ff9d_0_13;
        CData/*5:0*/ __VdfgRegularize_h6e95ff9d_0_15;
        CData/*5:0*/ __VdfgRegularize_h6e95ff9d_0_16;
        CData/*0:0*/ __VdfgRegularize_h6e95ff9d_0_23;
        CData/*0:0*/ __VdfgRegularize_h6e95ff9d_0_24;
        CData/*0:0*/ __VdfgRegularize_h6e95ff9d_0_25;
        CData/*0:0*/ __Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__data_pending;
        CData/*0:0*/ __Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__start_latch;
        CData/*4:0*/ __Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__state;
        CData/*4:0*/ __Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__blk_ptr;
        CData/*2:0*/ __Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__otp_idx;
        CData/*2:0*/ __Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_idx;
        CData/*4:0*/ __Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__load_idx;
        CData/*3:0*/ __Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_idx;
        CData/*4:0*/ __Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__count;
        CData/*1:0*/ __Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__state;
        CData/*2:0*/ __Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__sub_step;
        CData/*0:0*/ __Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_seq__DOT__seq_done_reg;
        CData/*7:0*/ __Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__bit_counter;
        CData/*5:0*/ __Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__word_count;
        CData/*0:0*/ __Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__is_last_block;
        CData/*2:0*/ __Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__state;
        CData/*6:0*/ __Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__round_count;
        CData/*2:0*/ __Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_prep__DOT__state;
        CData/*0:0*/ __VdlySet__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v0;
        CData/*0:0*/ __VdlySet__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v8;
        CData/*0:0*/ __VdlySet__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v10;
        CData/*0:0*/ __VdlySet__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v16;
        CData/*0:0*/ __VdlySet__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H__v17;
        CData/*3:0*/ __VdlyDim0__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v0;
        CData/*0:0*/ __VdlySet__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v0;
        CData/*3:0*/ __VdlyDim0__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v1;
        CData/*0:0*/ __VdlySet__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v1;
        CData/*0:0*/ __VdlySet__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v2;
        CData/*0:0*/ __VdlySet__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v18;
        CData/*4:0*/ __VdlyDim0__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0;
        CData/*0:0*/ __VdlySet__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0;
        CData/*0:0*/ __VstlFirstIteration;
        CData/*0:0*/ __VstlPhaseResult;
        CData/*0:0*/ __Vtrigprevexpr___TOP__tb_secure_boot__DOT__clk__0;
        CData/*0:0*/ __Vtrigprevexpr___TOP__tb_secure_boot__DOT__rst_n__0;
        CData/*0:0*/ __Vtrigprevexpr___TOP__tb_secure_boot__DOT__dut__DOT__clk_crypto__0;
        CData/*0:0*/ __VactPhaseResult;
        CData/*0:0*/ __VinactPhaseResult;
        CData/*0:0*/ __VnbaPhaseResult;
        SData/*11:0*/ tb_secure_boot__DOT__dut__DOT__c_addr;
        SData/*10:0*/ tb_secure_boot__DOT__dut__DOT__idx_q;
        SData/*10:0*/ tb_secure_boot__DOT__dut__DOT__left_q;
        SData/*10:0*/ tb_secure_boot__DOT__dut__DOT__code_words_q;
        SData/*10:0*/ __VdfgRegularize_h6e95ff9d_0_0;
    };
    struct {
        SData/*10:0*/ __Vdly__tb_secure_boot__DOT__dut__DOT__idx_q;
        IData/*31:0*/ tb_secure_boot__DOT__vrdata;
        IData/*31:0*/ tb_secure_boot__DOT__addr;
        IData/*31:0*/ tb_secure_boot__DOT__wdata;
        IData/*31:0*/ tb_secure_boot__DOT__rdata;
        IData/*31:0*/ tb_secure_boot__DOT__faddr;
        IData/*31:0*/ tb_secure_boot__DOT__fails;
        VlWide<8>/*255:0*/ tb_secure_boot__DOT__otp_key;
        IData/*31:0*/ tb_secure_boot__DOT__dut__DOT____VlemCall_3__bswap;
        IData/*31:0*/ tb_secure_boot__DOT__dut__DOT____VlemCall_2__bswap;
        IData/*31:0*/ tb_secure_boot__DOT__dut__DOT____VlemCall_1__bswap;
        IData/*31:0*/ tb_secure_boot__DOT__dut__DOT____VlemCall_0__bswap;
        IData/*31:0*/ tb_secure_boot__DOT__dut__DOT__c_wdata;
        IData/*31:0*/ tb_secure_boot__DOT__dut__DOT__c_rdata;
        IData/*31:0*/ tb_secure_boot__DOT__dut__DOT__otp_data;
        IData/*31:0*/ tb_secure_boot__DOT__dut__DOT__word_q;
        IData/*31:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_wdata;
        IData/*31:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_rdata;
        VlWide<8>/*255:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__ed_din;
        IData/*31:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_len_reg;
        IData/*31:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__msg_len_csr;
        VlWide<8>/*255:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__s_reg;
        VlWide<8>/*255:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_reg;
        VlWide<8>/*255:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__pubkey_reg;
        VlWide<16>/*511:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg;
        IData/*31:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_fed;
        IData/*31:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__data_in_reg;
        VlWide<8>/*255:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_comb_alu__DOT__u_pm_reducer__DOT__stage2_sum;
        VlWide<8>/*255:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__a_reg;
        VlWide<8>/*255:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__b_reg;
        VlWide<16>/*511:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg;
        VlWide<4>/*127:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__prod;
        VlWide<16>/*511:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__shifted_prod_r;
        VlWide<8>/*255:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__scalar_reg;
        IData/*31:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__msg_length;
        IData/*31:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__sched_wdata;
        IData/*31:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_prep__DOT__N_cnt;
        VlWide<8>/*255:0*/ tb_secure_boot__DOT__dut__DOT__u_otp__DOT__otp_mem;
        VlWide<6>/*191:0*/ __VdfgRegularize_h6e95ff9d_0_10;
        VlWide<9>/*256:0*/ __VdfgRegularize_h6e95ff9d_0_14;
        VlWide<9>/*256:0*/ __VdfgRegularize_h6e95ff9d_0_22;
        VlWide<8>/*255:0*/ __Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__r_reg;
        VlWide<8>/*255:0*/ __Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__s_reg;
        IData/*31:0*/ __Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_fed;
        VlWide<16>/*511:0*/ __Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__hash_reg;
        IData/*31:0*/ __Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__sha_wdata;
        VlWide<16>/*511:0*/ __Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_alu__DOT__u_booth_mult__DOT__p_reg;
        VlWide<8>/*255:0*/ __Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_fsm__DOT__scalar_reg;
        IData/*31:0*/ __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v0;
        IData/*31:0*/ __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v1;
        VlWide<8>/*255:0*/ __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem__v0;
        IData/*31:0*/ __VactIterCount;
        IData/*31:0*/ __VinactIterCount;
        IData/*31:0*/ __Vi;
        QData/*63:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__a;
        QData/*63:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__b;
        QData/*63:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__c;
        QData/*63:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__d;
        QData/*63:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__e;
        QData/*63:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__f;
        QData/*63:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__g;
        QData/*63:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__h;
        QData/*63:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__w_i;
        QData/*63:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__k_i;
    };
    struct {
        QData/*63:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_round__DOT__t1;
        QData/*63:0*/ tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w_next;
        QData/*63:0*/ __Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__a;
        QData/*63:0*/ __Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__b;
        QData/*63:0*/ __Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__c;
        QData/*63:0*/ __Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__d;
        QData/*63:0*/ __Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__e;
        QData/*63:0*/ __Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__f;
        QData/*63:0*/ __Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__g;
        QData/*63:0*/ __Vdly__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__h;
        QData/*63:0*/ __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v2;
        QData/*63:0*/ __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v3;
        QData/*63:0*/ __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v4;
        QData/*63:0*/ __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v5;
        QData/*63:0*/ __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v6;
        QData/*63:0*/ __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v7;
        QData/*63:0*/ __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v8;
        QData/*63:0*/ __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v9;
        QData/*63:0*/ __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v10;
        QData/*63:0*/ __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v11;
        QData/*63:0*/ __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v12;
        QData/*63:0*/ __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v13;
        QData/*63:0*/ __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v14;
        QData/*63:0*/ __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v15;
        QData/*63:0*/ __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v16;
        QData/*63:0*/ __VdlyVal__tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w__v17;
        VlUnpacked<IData/*31:0*/, 1024> tb_secure_boot__DOT__isram;
        VlUnpacked<IData/*31:0*/, 8> tb_secure_boot__DOT__pk;
        VlUnpacked<VlWide<8>/*255:0*/, 32> tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_ed__DOT__u_regs__DOT__mem;
        VlUnpacked<QData/*63:0*/, 8> tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__H;
        VlUnpacked<QData/*63:0*/, 16> tb_secure_boot__DOT__dut__DOT__u_crypto__DOT__u_sha__DOT__u_sched__DOT__w;
        VlUnpacked<QData/*63:0*/, 1> __VstlTriggered;
        VlUnpacked<QData/*63:0*/, 1> __VactTriggered;
        VlUnpacked<QData/*63:0*/, 1> __VactTriggeredAcc;
        VlUnpacked<QData/*63:0*/, 1> __VnbaTriggered;
    };
    std::string __Vtask_tb_secure_boot__DOT__run__0__name;
    std::string __Vtask_tb_secure_boot__DOT__run__3__name;
    VlDelayScheduler __VdlySched;
    VlTriggerScheduler __VtrigSched_hedba2121__0;
    VlTriggerScheduler __VtrigSched_hedba20e2__0;

    // INTERNAL VARIABLES
    Vtb_secure_boot__Syms* vlSymsp;
    const char* vlNamep;

    // CONSTRUCTORS
    Vtb_secure_boot___024root(Vtb_secure_boot__Syms* symsp, const char* namep);
    ~Vtb_secure_boot___024root();
    VL_UNCOPYABLE(Vtb_secure_boot___024root);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
};


#endif  // guard
