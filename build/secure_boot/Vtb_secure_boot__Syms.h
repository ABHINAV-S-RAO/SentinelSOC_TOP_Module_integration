// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table internal header
//
// Internal details; most calling programs do not need this header,
// unless using verilator public meta comments.

#ifndef VERILATED_VTB_SECURE_BOOT__SYMS_H_
#define VERILATED_VTB_SECURE_BOOT__SYMS_H_  // guard

#include "verilated.h"

// INCLUDE MODEL CLASS

#include "Vtb_secure_boot.h"

// INCLUDE MODULE CLASSES
#include "Vtb_secure_boot___024root.h"
#include "Vtb_secure_boot___024unit.h"
#include "Vtb_secure_boot_sha512_pkg.h"

// SYMS CLASS (contains all model state)
class alignas(VL_CACHE_LINE_BYTES) Vtb_secure_boot__Syms final : public VerilatedSyms {
  public:
    // INTERNAL STATE
    Vtb_secure_boot* const __Vm_modelp;
    VlDeleter __Vm_deleter;
    bool __Vm_didInit = false;

    // MODULE INSTANCE STATE
    Vtb_secure_boot___024root      TOP;
    Vtb_secure_boot_sha512_pkg     TOP__sha512_pkg;

    // CONSTRUCTORS
    Vtb_secure_boot__Syms(VerilatedContext* contextp, const char* namep, Vtb_secure_boot* modelp);
    ~Vtb_secure_boot__Syms();

    // METHODS
    const char* name() const { return TOP.vlNamep; }
};

#endif  // guard
