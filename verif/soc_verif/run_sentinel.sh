#!/bin/bash
TESTNAME=${1:-sentinel_soc_base_test}
FIRMWARE=${2:-software/bootrom.hex}

xrun -64bit -sv -uvm \
  -f verif/soc_verif/sentinel_soc_files.f \
  +UVM_TESTNAME=$TESTNAME \
  +FIRMWARE=$FIRMWARE \
  -top sentinel_soc_uvm_top \
  -access +rwc \
  -coverage all -covoverwrite \
  -timescale 1ns/1ps
