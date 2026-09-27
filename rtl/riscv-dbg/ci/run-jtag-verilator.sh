#!/usr/bin/env bash
# Copyright 2026 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Authors:
# - Philippe Sauter <phsauter@iis.ee.ethz.ch>

set -euo pipefail

readonly ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly BUILD_DIR="${JTAG_BUILD_DIR:-${ROOT}/build/jtag-verilator}"

exec "${ROOT}/ci/run-single-top-verilator.sh" \
  "${BUILD_DIR}" \
  tb_jtag_dmi
