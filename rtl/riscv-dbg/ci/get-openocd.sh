#!/usr/bin/env bash
# Copyright 2026 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51

set -euo pipefail

readonly ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly OPENOCD_REVISION="a88cc98a045cc11d094010878f1880fe3fbc733f"
readonly OPENOCD_PREFIX="${OPENOCD_PREFIX:-${ROOT}/.cache/openocd}"
readonly OPENOCD_SOURCE_DIR="${OPENOCD_SOURCE_DIR:-${ROOT}/.cache/riscv-openocd}"
readonly NUM_JOBS="${NUM_JOBS:-2}"

if [[ -x "${OPENOCD_PREFIX}/bin/openocd" ]] &&
   "${OPENOCD_PREFIX}/bin/openocd" --version 2>&1 | grep -q "${OPENOCD_REVISION:0:7}"; then
  echo "Using cached OpenOCD ${OPENOCD_REVISION}."
  exit 0
fi

mkdir -p "$(dirname "${OPENOCD_SOURCE_DIR}")" "${OPENOCD_PREFIX}"
if [[ ! -d "${OPENOCD_SOURCE_DIR}/.git" ]]; then
  git clone --filter=blob:none https://github.com/pulp-platform/riscv-openocd.git \
    "${OPENOCD_SOURCE_DIR}"
fi

git -C "${OPENOCD_SOURCE_DIR}" fetch --depth 1 origin "${OPENOCD_REVISION}"
git -C "${OPENOCD_SOURCE_DIR}" checkout --detach "${OPENOCD_REVISION}"
git -C "${OPENOCD_SOURCE_DIR}" submodule update --init --depth 1

cd "${OPENOCD_SOURCE_DIR}"
./bootstrap
./configure \
  --prefix="${OPENOCD_PREFIX}" \
  --disable-doxygen-html \
  --disable-doxygen-pdf \
  --disable-werror \
  --enable-remote-bitbang

# This 2019 fork predates GCC 10 changing its default to -fno-common.
make clean
make -j"${NUM_JOBS}" CFLAGS="-O2 -g -fcommon"
make install

"${OPENOCD_PREFIX}/bin/openocd" --version
