#!/usr/bin/env python3
"""
mkf.py -- turn one of the Xcelium filelists (verif/**/files_*.f) into a
Verilator filelist: absolute paths, Xcelium-only options dropped, packages
first (Verilator needs them before their users), plus the few Ibex/prim files
that are only referenced from disabled generate blocks.

Usage (from the repo root): python3 verif/verilator/mkf.py verif/soc/files_full_soc.f
"""
import os
import sys

R = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
# The Xcelium filelists carry the original machine's checkout path for the
# bender dependencies; map it to this checkout.
OLD = "/home/ibexcore/project/SentinelSOC_TOP_Module_integration"
SKIP = ("pad_functional", "tc_sram", "cluster_pwr", "pulp_pwr", "tc_pwr")
PRIM = os.path.join(R, "rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl")
EXTRA_PKGS = [os.path.join(PRIM, f) for f in ("prim_util_pkg.sv", "prim_cipher_pkg.sv", "prim_mubi_pkg.sv")]
EXTRA_SRCS = [os.path.join(R, "rtl/core/ibex_core/rtl/ibex_pmp.sv"),
              os.path.join(R, "rtl/core/ibex_core/rtl/ibex_dummy_instr.sv"),
              os.path.join(PRIM, "prim_ram_1p_scr.sv")]


def conv(path, opts, files):
    for raw in open(path):
        line = raw.split("//")[0].strip().replace(OLD, R)
        toks = line.split()
        i = 0
        while i < len(toks):
            t = toks[i]
            if t == "-f":
                sub = toks[i + 1]
                conv(sub if sub.startswith("/") else os.path.join(R, sub), opts, files)
                i += 2
                continue
            if t in ("-timescale", "-access", "-top", "-l", "-coverage"):
                i += 2
                continue
            if t.startswith("+incdir+"):
                d = t[len("+incdir+"):]
                opts.append("+incdir+" + (d if d.startswith("/") else os.path.join(R, d)))
            elif t.startswith("+define+"):
                opts.append(t)
            elif not t.startswith(("-", "+")):
                f = t if t.startswith("/") else os.path.join(R, t)
                # some filelists name verif/debugger/interface/jtag_if.sv
                if not os.path.exists(f) and os.path.exists(f.replace("/interface/", "/")):
                    f = f.replace("/interface/", "/")
                if not any(k in f for k in SKIP):
                    files.append(f)
            i += 1


opts, files = [], []
conv(os.path.join(R, sys.argv[1]), opts, files)
pkgs = [f for f in files if f.endswith("_pkg.sv")]
srcs = [f for f in files if not f.endswith("_pkg.sv")]
seen, out = set(), []
for f in opts + EXTRA_PKGS + pkgs + srcs + EXTRA_SRCS:
    if f not in seen:
        seen.add(f)
        out.append(f)
missing = [f for f in out if not f.startswith("+") and not os.path.exists(f)]
if missing:
    sys.exit("missing files:\n  " + "\n  ".join(missing))
print("\n".join(out))
