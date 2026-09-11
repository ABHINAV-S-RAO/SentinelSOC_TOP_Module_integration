`ifndef SOC_BASE_TEST_SV
`define SOC_BASE_TEST_SV

import uvm_pkg::*;
`include "uvm_macros.svh"

class soc_base_test extends uvm_test;
  `uvm_component_utils(soc_base_test)

  soc_env env;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = soc_env::type_id::create("env", this);
  endfunction

  task run_phase(uvm_phase phase);
    dift_expect d_exp;
    string expected_str = "SENTINELSOC OK\n";
    byte_arr_t expected_flash;

    phase.raise_objection(this);
    // Safety watchdog timeout (10 ms) in case software gets stuck in an infinite loop
    uvm_top.set_timeout(10ms, 0);

    // 1. Tell Scoreboard what UART output to expect from test_all.s
    foreach (expected_str[i]) begin
      env.scb.expected_uart_stream.push_back(expected_str[i]);
    end

    // 2. Tell Scoreboard what DIFT events to expect from test_all.s
    // (Assuming tag is seeded into DSRAM word 0, it gets loaded, propagated, and stored to word 1)
    // Event 1: Load from DSRAM+0 (0x0002_0000)
    d_exp = new(); d_exp.rf_addr = 10; /* a0=x10 */ d_exp.expected_tag = 1'b1; d_exp.expect_exception = 1'b0;
    env.scb.expected_dift.push_back(d_exp);
    // Event 2: Store to DSRAM+4 (0x0002_0004) from a1 (x11)
    d_exp = new(); d_exp.rf_addr = 11; /* a1=x11 */ d_exp.expected_tag = 1'b1; d_exp.expect_exception = 1'b0;
    env.scb.expected_dift.push_back(d_exp);

    `uvm_info(get_type_name(), "Simulation started. Firmware running...", UVM_LOW)

    // Run for 100 us to let firmware execute and monitors collect data
    #100us;

    `uvm_info(get_type_name(), "Dropping objection to finish test.", UVM_LOW)
    phase.drop_objection(this);
  endtask
endclass

`endif