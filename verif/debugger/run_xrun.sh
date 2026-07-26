#!/bin/bash
# =============================================================================
# run_xrun.sh -- compile + elaborate + run the debug-module regression
#
# Usage: ./run_xrun.sh [path/to/files.f]
# Defaults to ./files.f -- the single merged filelist (your RTL + the new
# debug regression TB), see files.f for exactly what changed vs. your
# original list and why.
# =============================================================================
set -e

SOC_FILELIST="${1:-files.f}"
TOP="tb_dm_ibex_top"

xrun \
  -64bit \
  -sv \
  -access +rwc \
  -timescale 1ns/1ps \
  -top ${TOP} \
  -f ${SOC_FILELIST} \
  -l xrun_debug_regress.log \
  +define+SIM \
  -input @'run -all; exit'
  # Add -gui if you want to bring up SimVision interactively instead of
  # the batch "run -all" above.

echo "----------------------------------------------------------------"
grep -E "PASS|FAIL|TB PASSED|TB FAILED|Error|error" xrun_debug_regress.log || true
echo "----------------------------------------------------------------"
