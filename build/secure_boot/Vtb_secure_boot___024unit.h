// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vtb_secure_boot.h for the primary calling header

#ifndef VERILATED_VTB_SECURE_BOOT___024UNIT_H_
#define VERILATED_VTB_SECURE_BOOT___024UNIT_H_  // guard

#include "verilated.h"
#include "verilated_timing.h"


class Vtb_secure_boot__Syms;

class alignas(VL_CACHE_LINE_BYTES) Vtb_secure_boot___024unit final {
  public:

    // INTERNAL VARIABLES
    Vtb_secure_boot__Syms* vlSymsp;
    const char* vlNamep;

    // CONSTRUCTORS
    Vtb_secure_boot___024unit();
    ~Vtb_secure_boot___024unit();
    void ctor(Vtb_secure_boot__Syms* symsp, const char* namep);
    void dtor();
    VL_UNCOPYABLE(Vtb_secure_boot___024unit);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
};


#endif  // guard
