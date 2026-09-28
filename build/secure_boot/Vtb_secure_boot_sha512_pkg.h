// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vtb_secure_boot.h for the primary calling header

#ifndef VERILATED_VTB_SECURE_BOOT_SHA512_PKG_H_
#define VERILATED_VTB_SECURE_BOOT_SHA512_PKG_H_  // guard

#include "verilated.h"
#include "verilated_timing.h"
#include "Vtb_secure_boot_sha512_pkg.h"


class Vtb_secure_boot__Syms;
struct Vtb_secure_boot_csa_t__struct__0 {
    QData/*63:0*/ __PVT__sum;
    QData/*63:0*/ __PVT__carry;

    bool operator==(const Vtb_secure_boot_csa_t__struct__0& rhs) const {
        return __PVT__sum == rhs.__PVT__sum
            && __PVT__carry == rhs.__PVT__carry;
    }
    bool operator!=(const Vtb_secure_boot_csa_t__struct__0& rhs) const {
        return !(*this == rhs);
    }

    bool operator<(const Vtb_secure_boot_csa_t__struct__0& rhs) const {
        if (__PVT__sum < rhs.__PVT__sum) return true;
        if (rhs.__PVT__sum < __PVT__sum) return false;
        if (__PVT__carry < rhs.__PVT__carry) return true;
        if (rhs.__PVT__carry < __PVT__carry) return false;
        return false;
    }
};
template <>
struct VlIsCustomStruct<Vtb_secure_boot_csa_t__struct__0> : public std::true_type {};

class alignas(VL_CACHE_LINE_BYTES) Vtb_secure_boot_sha512_pkg final {
  public:

    // DESIGN SPECIFIC STATE
    VlUnpacked<QData/*63:0*/, 8> SHA512_IV;
    VlUnpacked<QData/*63:0*/, 80> K;

    // INTERNAL VARIABLES
    Vtb_secure_boot__Syms* vlSymsp;
    const char* vlNamep;

    // CONSTRUCTORS
    Vtb_secure_boot_sha512_pkg();
    ~Vtb_secure_boot_sha512_pkg();
    void ctor(Vtb_secure_boot__Syms* symsp, const char* namep);
    void dtor();
    VL_UNCOPYABLE(Vtb_secure_boot_sha512_pkg);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
};


#endif  // guard
