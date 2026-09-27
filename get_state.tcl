run 4999ms
puts "\n============================================="
puts ">>> CORE STATE AT 4.99ms (Right before crash):"
describe -value *
puts "core_instr_req:    [value dbg_tb_top.dut.core_instr_req]"
puts "core_instr_gnt:    [value dbg_tb_top.dut.core_instr_gnt]"
puts "core_instr_rvalid: [value dbg_tb_top.dut.core_instr_rvalid]"
puts "core_instr_addr:   [value dbg_tb_top.dut.core_instr_addr]"
puts "debug_req_i:       [value dbg_tb_top.dut.u_core.u_ibex_core.debug_req_i]"
puts "=============================================\n"
run
exit
