// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "Vtb_secure_boot__pch.h"

//============================================================
// Constructors

Vtb_secure_boot::Vtb_secure_boot(VerilatedContext* _vcontextp__, const char* _vcname__)
    : VerilatedModel{*_vcontextp__}
    , vlSymsp{new Vtb_secure_boot__Syms(contextp(), _vcname__, this)}
    , __PVT__sha512_pkg{vlSymsp->TOP.__PVT__sha512_pkg}
    , rootp{&(vlSymsp->TOP)}
{
    // Register model with the context
    contextp()->addModel(this);
}

Vtb_secure_boot::Vtb_secure_boot(const char* _vcname__)
    : Vtb_secure_boot(Verilated::threadContextp(), _vcname__)
{
}

//============================================================
// Destructor

Vtb_secure_boot::~Vtb_secure_boot() {
    delete vlSymsp;
}

//============================================================
// Evaluation function

#ifdef VL_DEBUG
void Vtb_secure_boot___024root___eval_debug_assertions(Vtb_secure_boot___024root* vlSelf);
#endif  // VL_DEBUG
void Vtb_secure_boot___024root___eval_static(Vtb_secure_boot___024root* vlSelf);
void Vtb_secure_boot___024root___eval_initial(Vtb_secure_boot___024root* vlSelf);
void Vtb_secure_boot___024root___eval_settle(Vtb_secure_boot___024root* vlSelf);
void Vtb_secure_boot___024root___eval(Vtb_secure_boot___024root* vlSelf);

void Vtb_secure_boot::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vtb_secure_boot::eval_step\n"); );
#ifdef VL_DEBUG
    // Debug assertions
    Vtb_secure_boot___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    vlSymsp->__Vm_deleter.deleteAll();
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) {
        VL_DEBUG_IF(VL_DBG_MSGF("+ Initial\n"););
        Vtb_secure_boot___024root___eval_static(&(vlSymsp->TOP));
        Vtb_secure_boot___024root___eval_initial(&(vlSymsp->TOP));
        Vtb_secure_boot___024root___eval_settle(&(vlSymsp->TOP));
        vlSymsp->__Vm_didInit = true;
    }
    VL_DEBUG_IF(VL_DBG_MSGF("+ Eval\n"););
    Vtb_secure_boot___024root___eval(&(vlSymsp->TOP));
    // Evaluate cleanup
    Verilated::endOfEval(vlSymsp->__Vm_evalMsgQp);
}

//============================================================
// Events and timing
bool Vtb_secure_boot::eventsPending() { return !vlSymsp->TOP.__VdlySched.empty() && !contextp()->gotFinish(); }

uint64_t Vtb_secure_boot::nextTimeSlot() { return vlSymsp->TOP.__VdlySched.nextTimeSlot(); }

//============================================================
// Utilities

const char* Vtb_secure_boot::name() const {
    return vlSymsp->name();
}

//============================================================
// Invoke final blocks

void Vtb_secure_boot___024root___eval_final(Vtb_secure_boot___024root* vlSelf);

VL_ATTR_COLD void Vtb_secure_boot::final() {
    contextp()->executingFinal(true);
    Vtb_secure_boot___024root___eval_final(&(vlSymsp->TOP));
    contextp()->executingFinal(false);
}

//============================================================
// Implementations of abstract methods from VerilatedModel

const char* Vtb_secure_boot::hierName() const { return vlSymsp->name(); }
const char* Vtb_secure_boot::modelName() const { return "Vtb_secure_boot"; }
unsigned Vtb_secure_boot::threads() const { return 1; }
void Vtb_secure_boot::prepareClone() const { contextp()->prepareClone(); }
void Vtb_secure_boot::atClone() const {
    contextp()->threadPoolpOnClone();
}
