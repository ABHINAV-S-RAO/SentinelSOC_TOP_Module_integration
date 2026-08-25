#!/bin/bash
xrun -64bit -sv -uvm \
  -f verif/soc_verif/soc_basic_files.f \
  +UVM_TESTNAME=basic_soc_test \
  -top basic_soc_uvm_top \
  -access +rwc \
  -timescale 1ns/1ps
