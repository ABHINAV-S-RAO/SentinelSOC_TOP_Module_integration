// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtb_secure_boot.h for the primary calling header

#include "Vtb_secure_boot__pch.h"

void Vtb_secure_boot___024root___ctor_var_reset(Vtb_secure_boot___024root* vlSelf);

Vtb_secure_boot___024root::Vtb_secure_boot___024root(Vtb_secure_boot__Syms* symsp, const char* namep)
    : __VdlySched{*symsp->_vm_contextp__}
 {
    vlSymsp = symsp;
    vlNamep = strdup(namep);
    // Reset structure values
    Vtb_secure_boot___024root___ctor_var_reset(this);
}

void Vtb_secure_boot___024root::__Vconfigure(bool first) {
    (void)first;  // Prevent unused variable warning
}

Vtb_secure_boot___024root::~Vtb_secure_boot___024root() {
    VL_DO_DANGLING(std::free(const_cast<char*>(vlNamep)), vlNamep);
}
