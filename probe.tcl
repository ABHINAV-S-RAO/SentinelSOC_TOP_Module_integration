database -open waves -shm
probe -create ibex_core_tb.dut -depth all -database waves
run 34500ns
examine -radix binary ibex_core_tb.dut.id_stage_i.controller_i.tag_err
examine -radix binary ibex_core_tb.dut.id_stage_i.controller_i.lsu_tag_err_i
examine -radix binary ibex_core_tb.dut.id_stage_i.controller_i.ex_tag_err_i
run
database -close waves
exit
