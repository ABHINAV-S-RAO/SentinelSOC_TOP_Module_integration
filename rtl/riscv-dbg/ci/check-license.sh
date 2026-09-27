#!/usr/bin/env bash
# Copyright 2026 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Authors:
# - Philippe Sauter <phsauter@iis.ee.ethz.ch>

set -euo pipefail

readonly ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly LICENSE_PATTERN='SPDX-License-Identifier|[Ll]icensed under|[Ll]icense details|Solderpad Hardware License|Permission to use, copy|Copying and distribution|Redistribution and use|This copyrighted material'

cd "${ROOT}"

status=0
while IFS= read -r -d '' file; do
  [[ -f "${file}" ]] || continue
  if ! head -n 40 "${file}" | grep -Eq "${LICENSE_PATTERN}"; then
    echo "::error file=${file}::No license notice found in the first 40 lines"
    status=1
  fi
done < <(
  git ls-files -z \
    '*.c' '*.cc' '*.cpp' '*.h' '*.ld' '*.mk' '*.py' '*.sh' \
    '*.sv' '*.svh' '*.tcl' '*.v' '*.yaml' '*.yml' '*.S' \
    'Makefile'
)

exit "${status}"
