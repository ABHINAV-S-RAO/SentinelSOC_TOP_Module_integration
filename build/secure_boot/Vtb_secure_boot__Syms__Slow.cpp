// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table implementation internals

#include "Vtb_secure_boot__pch.h"

Vtb_secure_boot__Syms::Vtb_secure_boot__Syms(VerilatedContext* contextp, const char* namep, Vtb_secure_boot* modelp)
    : VerilatedSyms{contextp}
    // Setup internal state of the Syms class
    , __Vm_modelp{modelp}
    // Setup top module instance
    , TOP{this, namep}
{
    // Check resources
    Verilated::stackCheck(4616);
    // Setup sub module instances
    TOP__sha512_pkg.ctor(this, "sha512_pkg");
    // Configure time unit / time precision
    _vm_contextp__->timeunit(-9);
    _vm_contextp__->timeprecision(-12);
    // Setup each module's pointers to their submodules
    TOP.__PVT__sha512_pkg = &TOP__sha512_pkg;
    // Setup each module's pointer back to symbol table (for public functions)
    TOP.__Vconfigure(true);
    TOP__sha512_pkg.__Vconfigure(true);
}

Vtb_secure_boot__Syms::~Vtb_secure_boot__Syms() {
    // Tear down scopes
    // Tear down sub module instances
    TOP__sha512_pkg.dtor();
}
