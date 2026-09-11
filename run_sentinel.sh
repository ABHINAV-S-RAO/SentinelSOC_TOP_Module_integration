#!/bin/bash
xrun -64bit -sv -uvm \
  -f verif/soc_verif/sentinel_soc_files.f \
  +UVM_TESTNAME=sentinel_soc_base_test \
  -top sentinel_soc_uvm_top \
  -access +rwc \
  -coverage all -covoverwrite \
  -timescale 1ns/1ps
