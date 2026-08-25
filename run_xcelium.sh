#!/bin/bash
xrun -64bit -sv -uvm \
  -f verif/soc_verif/soc_basic_files.f \
  +UVM_TESTNAME=basic_soc_test \
  -access +rwc \
  -timescale 1ns/1ps
