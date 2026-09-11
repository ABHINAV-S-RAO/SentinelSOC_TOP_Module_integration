`ifndef SW_STATUS_MONITOR_SV
`define SW_STATUS_MONITOR_SV

import uvm_pkg::*;
`include "uvm_macros.svh"

class sw_status_monitor extends uvm_subscriber #(obi_seq_item);
  `uvm_component_utils(sw_status_monitor)

  localparam bit [31:0] SYS_CTRL_STATUS_ADDR = 32'h0002_0008; // DSRAM_BASE + 0x8
  localparam bit [31:0] TEST_PASS_CODE       = 32'h600D_C0DE;
  localparam bit [31:0] TEST_FAIL_CODE       = 32'h0BAD_C0DE;

  uvm_phase current_run_phase;
  bit       test_finished = 1'b0;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void write(obi_seq_item t);
    // Check if transaction is a write to the DSRAM status completion address
    if (t.we == OBI_WRITE && t.addr == SYS_CTRL_STATUS_ADDR) begin
      if (!test_finished) begin
        
        if (t.wdata == TEST_PASS_CODE) begin
          test_finished = 1'b1;
          `uvm_info("SW_STATUS", "==============================================", UVM_NONE)
          `uvm_info("SW_STATUS", " FIRMWARE SIGNALED: TEST PASSED (0x600DC0DE) ", UVM_NONE)
          `uvm_info("SW_STATUS", "==============================================", UVM_NONE)
          
          if (current_run_phase != null) begin
            current_run_phase.drop_objection(this, "Firmware execution complete.");
          end
        end else if (t.wdata == TEST_FAIL_CODE) begin
          test_finished = 1'b1;
          `uvm_error("SW_STATUS", $sformatf("FIRMWARE SIGNALED: TEST FAILED with Code: 0x%0h (DSRAM Mismatch)", t.wdata))
          
          if (current_run_phase != null) begin
            current_run_phase.drop_objection(this, "Firmware execution failed.");
          end
        end else begin
          `uvm_warning("SW_STATUS", $sformatf("Unexpected status code written to DSRAM status addr: 0x%0h", t.wdata))
        end

      end
    end
  endfunction

  // Store run_phase reference to drop objection dynamically on SW completion
  task run_phase(uvm_phase phase);
    current_run_phase = phase;
    phase.raise_objection(this, "SW Status Monitor waiting for firmware completion...");
  endtask

endclass

`endif