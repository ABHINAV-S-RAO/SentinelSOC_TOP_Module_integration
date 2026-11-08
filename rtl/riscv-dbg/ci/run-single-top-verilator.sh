#!/usr/bin/env bash
# Copyright 2026 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Authors:
# - Philippe Sauter <phsauter@iis.ee.ethz.ch>

set -euo pipefail

if (($# < 2)); then
  echo "usage: $0 BUILD_DIR TOP_MODULE [VERILATOR_ARG ...]" >&2
  exit 2
fi

readonly ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly BUILD_DIR="$(realpath -m -- "$1")"
readonly TOP_MODULE="$2"
shift 2
readonly FILE_LIST="${ROOT}/build/verilator/sources.flist"

if [[ ! -f "${FILE_LIST}" ]]; then
  echo "error: Verilator file list not found: ${FILE_LIST}" >&2
  echo "run 'make -C ci verilator-sources' first" >&2
  exit 2
fi

mkdir -p "${BUILD_DIR}"
cd "${ROOT}"

verilator \
  --binary \
  --timing \
  -Wno-fatal \
  -DCOMMON_CELLS_ASSERTS_OFF \
  --top-module "${TOP_MODULE}" \
  --Mdir "${BUILD_DIR}/obj_dir" \
  "$@" \
  -f "${FILE_LIST}"

"${BUILD_DIR}/obj_dir/V${TOP_MODULE}"
