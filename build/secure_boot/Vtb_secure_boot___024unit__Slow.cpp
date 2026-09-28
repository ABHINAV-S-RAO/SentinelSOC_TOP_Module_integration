// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtb_secure_boot.h for the primary calling header

#include "Vtb_secure_boot__pch.h"


Vtb_secure_boot___024unit::Vtb_secure_boot___024unit() = default;
Vtb_secure_boot___024unit::~Vtb_secure_boot___024unit() = default;

void Vtb_secure_boot___024unit::ctor(Vtb_secure_boot__Syms* symsp, const char* namep) {
    vlSymsp = symsp;
    vlNamep = strdup(Verilated::catName(vlSymsp->name(), namep));
    // Reset structure values
}

void Vtb_secure_boot___024unit::__Vconfigure(bool first) {
    (void)first;  // Prevent unused variable warning
}

void Vtb_secure_boot___024unit::dtor() {
    VL_DO_DANGLING(std::free(const_cast<char*>(vlNamep)), vlNamep);
}
