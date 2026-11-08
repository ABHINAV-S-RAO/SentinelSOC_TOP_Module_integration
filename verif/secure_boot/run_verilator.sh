#!/bin/bash
# Unit test for soc_secure_boot (real rtl/crypto engine). Run from repo root.
set -e
mkdir -p build/secure_boot
CRYPTO=$(tr -d '\r' < rtl/crypto/files.f | grep '\.sv$' | grep -v tb_top_most)
verilator --binary --timing -j 0 -Wno-fatal -Wno-lint -Wno-style -Wno-MULTIDRIVEN -Wno-TIMESCALEMOD \
  --top-module tb_secure_boot -Mdir build/secure_boot -o sim \
  $CRYPTO rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim_generic/rtl/prim_clock_gating.sv \
  rtl/soc/soc_secure_boot.sv verif/secure_boot/tb_secure_boot.sv
build/secure_boot/sim
