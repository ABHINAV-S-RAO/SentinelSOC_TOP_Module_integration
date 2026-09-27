# Copyright 2026 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Authors:
# - Philippe Sauter <phsauter@iis.ee.ethz.ch>
#
# Re-elaborates tb_dm_mem across register-access and bus-width configurations.
# Each run is logged, and any Questa error or fatal makes the script fail.

set regression_failed 0
file mkdir logs

proc run_access_width_test {
    name bus_width max_access_width hart_sel aar_size expect_supported
} {
    global regression_failed

    puts "================================================================"
    puts [format "= Running %s: bus=%d max_access=%d hart=%d aarsize=%d" \
        $name $bus_width $max_access_width $hart_sel $aar_size]
    puts "================================================================"

    set transcript_name "logs/dm_mem.${name}.vsim.log"
    file delete -force $transcript_name
    transcript file $transcript_name

    vsim -t 1ps -voptargs=+acc -sv_seed 1 \
        -GBusWidth=$bus_width \
        -GMaxRegisterAccessWidth=$max_access_width \
        -GHartSel=$hart_sel \
        -GAarSize=$aar_size \
        -GExpectSupported=$expect_supported \
        -wlf "logs/dm_mem.${name}.wlf" \
        tb_dm_mem

    onfinish stop
    set StdArithNoWarnings 1
    set NumericStdNoWarnings 1
    run -all
    quit -sim

    transcript file {}
    set transcript_fd [open $transcript_name r]
    set transcript_data [read $transcript_fd]
    close $transcript_fd
    if {[regexp -line {^# \*\* (Error|Fatal)( \([^)]*\))?:} $transcript_data]} {
        puts "Regression errors detected in $transcript_name"
        set regression_failed 1
    }
}

# Fields: name BusWidth MaxRegisterAccessWidth HartSel AarSize ExpectSupported
run_access_width_test bus32_max32_aar32 32 32 0 2 1
run_access_width_test bus32_max32_aar64 32 32 1 3 0
run_access_width_test bus32_max64_aar32 32 64 0 2 1
run_access_width_test bus32_max64_aar64 32 64 1 3 1
run_access_width_test bus64_max32_aar32 64 32 1 2 1
run_access_width_test bus64_max32_aar64 64 32 0 3 0
run_access_width_test bus64_max64_aar64 64 64 1 3 1

quit -code $regression_failed -f
