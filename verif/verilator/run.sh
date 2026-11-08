#!/bin/bash
# =============================================================================
# run.sh -- build and run the SoC testbenches with Verilator (no Xcelium needed)
#
#   verif/verilator/run.sh full        [plusargs]   full_soc_tb
#   verif/verilator/run.sh secure_dbg  [plusargs]   secure_boot_dbg_tb
#   verif/verilator/run.sh dift_dbg    [plusargs]   dift_dbg_tb
#   verif/verilator/run.sh all                      every TB and mode
#
# Run from the repo root. Needs: verilator >= 5.0, bender dependencies checked
# out (`bender checkout`), simulation images (software/build_sim_images.sh).
# Build output: build/verilator/<tb>/ (git-ignored). Logs: build/verilator/*.log
# Set NOBUILD=1 to rerun an existing build.
# =============================================================================
set -e
cd "$(dirname "$0")/../.."
OUT=build/verilator
mkdir -p $OUT

build() {   # build <filelist> <top>
  local f=$1 top=$2 dir=$OUT/$2
  [ -n "$NOBUILD" ] && [ -x $dir/sim ] && return 0
  python3 verif/verilator/mkf.py $f > $OUT/$top.vf
  verilator --binary --timing -j 0 -Wno-fatal -Wno-lint -Wno-style -Wno-MULTIDRIVEN \
    -Wno-TIMESCALEMOD -Wno-WIDTHEXPAND -Wno-WIDTHTRUNC -Wno-DEFOVERRIDE \
    --top-module $top -Mdir $dir -o sim -f $OUT/$top.vf > $OUT/$top.build.log 2>&1 \
    || { grep -E "%Error" $OUT/$top.build.log | head -20; echo "BUILD FAILED: $top"; exit 1; }
}

run() {     # run <top> <tag> [plusargs]
  local top=$1 tag=$2; shift 2
  $OUT/$top/sim "$@" > $OUT/$tag.log 2>&1 || true
  grep -E "TEST PASSED|TEST FAILED|Global watchdog" $OUT/$tag.log | tail -1 | sed "s/^/[$tag] /"
}

case "$1" in
  full)       shift; build verif/soc/files_full_soc.f full_soc_tb;                run full_soc_tb full "$@" ;;
  secure_dbg) shift; build verif/debugger/files_secure_boot_dbg.f secure_boot_dbg_tb; run secure_boot_dbg_tb secure_dbg "$@" ;;
  dift_dbg)   shift; build verif/debugger/files_dift_dbg.f dift_dbg_tb;            run dift_dbg_tb dift_dbg "$@" ;;
  all)
    build verif/soc/files_full_soc.f full_soc_tb
    build verif/debugger/files_secure_boot_dbg.f secure_boot_dbg_tb
    build verif/debugger/files_dift_dbg.f dift_dbg_tb
    run full_soc_tb        full
    run full_soc_tb        full_tamper   +TAMPER
    run full_soc_tb        full_bigimage +BIGIMAGE
    run secure_boot_dbg_tb secure_dbg
    run dift_dbg_tb        dift_dbg
    ;;
  *) sed -n 2,16p "$0"; exit 1 ;;
esac
