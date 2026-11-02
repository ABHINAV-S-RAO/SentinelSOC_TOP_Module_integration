// =============================================================================
// soc_deadlock_monitor.sv
// Deadlock, Protocol Hang & CPU Progress Monitor for SentinelSOC Signoff 6.18
// Asserts no bus lockups or ungranted stalls across all OBI and APB channels.
// =============================================================================

`ifndef SOC_DEADLOCK_MONITOR_SV
`define SOC_DEADLOCK_MONITOR_SV

module soc_deadlock_monitor (
  input logic clk,
  input logic rst_n
);

  localparam int MAX_OBI_GRANT_CYCLES = 256;
  localparam int MAX_APB_READY_CYCLES = 512;
  localparam int MAX_PC_STALL_CYCLES  = 100000;

  int instr_stall_cnt = 0;
  int data_stall_cnt  = 0;
  int apb_stall_cnt   = 0;
  int pc_stall_cnt    = 0;

  logic [31:0] prev_pc = 32'h0;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      instr_stall_cnt <= 0;
      data_stall_cnt  <= 0;
      apb_stall_cnt   <= 0;
      pc_stall_cnt    <= 0;
      prev_pc         <= 32'h0;
    end else begin
      // 1. Instruction OBI Grant Deadlock Check
      if (sentinel_soc_uvm_top.u_dut.instr_req && !sentinel_soc_uvm_top.u_dut.instr_gnt) begin
        instr_stall_cnt <= instr_stall_cnt + 1;
        if (instr_stall_cnt >= MAX_OBI_GRANT_CYCLES) begin
          $fatal(1, "[DEADLOCK_MONITOR] FATAL: Instruction bus request stalled for %0d cycles at addr 0x%08X without grant!",
                 instr_stall_cnt, sentinel_soc_uvm_top.u_dut.instr_addr);
        end
      end else begin
        instr_stall_cnt <= 0;
      end

      // 2. Data OBI Grant Deadlock Check
      if (sentinel_soc_uvm_top.u_dut.data_req && !sentinel_soc_uvm_top.u_dut.data_gnt) begin
        data_stall_cnt <= data_stall_cnt + 1;
        if (data_stall_cnt >= MAX_OBI_GRANT_CYCLES) begin
          $fatal(1, "[DEADLOCK_MONITOR] FATAL: Data bus request stalled for %0d cycles at addr 0x%08X without grant!",
                 data_stall_cnt, sentinel_soc_uvm_top.u_dut.data_addr);
        end
      end else begin
        data_stall_cnt <= 0;
      end

      // 3. APB PREADY Deadlock Check
      if (sentinel_soc_uvm_top.u_dut.apb_req.psel && !sentinel_soc_uvm_top.u_dut.apb_rsp.pready) begin
        apb_stall_cnt <= apb_stall_cnt + 1;
        if (apb_stall_cnt >= MAX_APB_READY_CYCLES) begin
          $fatal(1, "[DEADLOCK_MONITOR] FATAL: APB peripheral access stalled for %0d cycles at paddr 0x%08X without pready!",
                 apb_stall_cnt, sentinel_soc_uvm_top.u_dut.apb_req.paddr);
        end
      end else begin
        apb_stall_cnt <= 0;
      end

      // 4. CPU Execution Progress Watchdog
      if (sentinel_soc_uvm_top.u_dut.u_core.u_ibex_top.u_ibex_core.pc_id == prev_pc) begin
        // Only increment stall count if not in WFI (waiting for interrupt) or debug halt
        if (!sentinel_soc_uvm_top.u_dut.u_core.u_ibex_top.u_ibex_core.id_stage_i.controller_i.ctrl_fsm_cs) begin
          pc_stall_cnt <= pc_stall_cnt + 1;
          if (pc_stall_cnt >= MAX_PC_STALL_CYCLES) begin
            $fatal(1, "[DEADLOCK_MONITOR] FATAL: CPU PC stalled at 0x%08X for %0d cycles!",
                   prev_pc, pc_stall_cnt);
          end
        end
      end else begin
        pc_stall_cnt <= 0;
        prev_pc      <= sentinel_soc_uvm_top.u_dut.u_core.u_ibex_top.u_ibex_core.pc_id;
      end
    end
  end

endmodule

`endif
