# Copyright 2026 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Authors:
# - Philippe Sauter <phsauter@iis.ee.ethz.ch>

ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/..)
TB := $(ROOT)/tb
VERILATOR_FILE_LIST := $(ROOT)/build/verilator/sources.flist

NUM_JOBS ?= 2
OPENOCD_PREFIX ?= $(ROOT)/.cache/openocd

.PHONY: all compliance dm-mem firmware full-model jtag-dmi multihart-resume openocd \
	verilator-sources

all: dm-mem jtag-dmi multihart-resume compliance

verilator-sources:
	cd $(ROOT) && bender checkout
	mkdir -p $(dir $(VERILATOR_FILE_LIST))
	cd $(ROOT) && bender script flist-plus \
		--relative-path \
		-t riscv-dbg:simulation \
		-t riscv-dbg:test \
		-t riscv-dbg:dm_mem_test \
		-t riscv-dbg:multihart_resume_test \
		-t tech_cells_generic:tech_cells_generic_exclude_deprecated \
		> $(VERILATOR_FILE_LIST)

full-model:
	$(MAKE) -C $(TB) -j1 download_deps
	$(MAKE) -C $(TB) verilate

firmware:
	$(MAKE) -C $(TB) prog/test.hex

openocd:
	NUM_JOBS=$(NUM_JOBS) OPENOCD_PREFIX=$(OPENOCD_PREFIX) \
		$(ROOT)/ci/get-openocd.sh

jtag-dmi: verilator-sources
	JTAG_BUILD_DIR=$(ROOT)/build/jtag-verilator \
		$(ROOT)/ci/run-jtag-verilator.sh

dm-mem: verilator-sources
	DM_MEM_BUILD_DIR=$(ROOT)/build/dm-mem-verilator \
		$(ROOT)/ci/run-dm-mem-verilator.sh

multihart-resume: verilator-sources
	MULTIHART_BUILD_DIR=$(ROOT)/build/multihart-verilator \
		$(ROOT)/ci/run-multihart-verilator.sh

compliance: full-model firmware openocd
	cd $(TB) && \
		OPENOCD=$(OPENOCD_PREFIX)/bin/openocd \
		OPENOCD_SCRIPT=dm_compliance_test.cfg \
		./veri-run-openocd.py
