`ifndef SOC_SCOREBOARD_SV
`define SOC_SCOREBOARD_SV

import uvm_pkg::*;
`include "uvm_macros.svh"

`uvm_analysis_imp_decl(_data_obi)
`uvm_analysis_imp_decl(_dift_tag)

class soc_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(soc_scoreboard)

  uvm_analysis_imp_data_obi #(obi_seq_item, soc_scoreboard)      data_obi_imp;
  uvm_analysis_imp_dift_tag #(dift_tag_seq_item, soc_scoreboard) dift_tag_imp;

  // Shadow memory model for 1-bit DIFT metadata tags (Key: Word Address)
  bit shadow_tag_mem[bit [31:0]];

  int unsigned total_data_reads   = 0;
  int unsigned total_data_writes  = 0;
  int unsigned total_dift_tag_ops = 0;
  int unsigned total_dift_alerts  = 0;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    data_obi_imp = new("data_obi_imp", this);
    dift_tag_imp = new("dift_tag_imp", this);
  endfunction

  // Handle Data OBI transactions (CPU load/store operations)
  function void write_data_obi(obi_seq_item item);
    if (item.we == OBI_WRITE) begin
      total_data_writes++;
      `uvm_info("SCB_DATA", $sformatf("Data WRITE | Addr: 0x%0h | Data: 0x%0h", item.addr, item.wdata), UVM_HIGH)
    end else begin
      total_data_reads++;
      `uvm_info("SCB_DATA", $sformatf("Data READ  | Addr: 0x%0h | Data: 0x%0h", item.addr, item.rdata), UVM_HIGH)
    end
  endfunction

  // Handle DIFT Tag operations and policy checking
  function void write_dift_tag(dift_tag_seq_item item);
    total_dift_tag_ops++;

    // Track DIFT Exception Interrupts
    if (item.irq_dift) begin
      total_dift_alerts++;
      `uvm_warning("SCB_DIFT", $sformatf("DIFT Security Violation Alert Asserted! Addr: 0x%0h", item.tag_addr))
    end

    // Track/Check Shadow-RAM Taints
    if (item.tag_we) begin
      shadow_tag_mem[item.tag_addr] = item.tag_wdata[0];
      `uvm_info("SCB_DIFT", $sformatf("DIFT Tag WRITE | Addr: 0x%0h | Tag: %0b", item.tag_addr, item.tag_wdata[0]), UVM_HIGH)
    end else begin
      if (shadow_tag_mem.exists(item.tag_addr)) begin
        bit expected_tag = shadow_tag_mem[item.tag_addr];
        if (item.tag_rdata[0] !== expected_tag) begin
          `uvm_error("SCB_DIFT", $sformatf("DIFT Tag Mismatch at 0x%0h! Exp: %0b, Got: %0b",
                                         item.tag_addr, expected_tag, item.tag_rdata[0]))
        end
      end
    end
  endfunction

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("SCB_REPORT", "==================================================", UVM_LOW)
    `uvm_info("SCB_REPORT", $sformatf("Total Data Read Trans  : %0d", total_data_reads), UVM_LOW)
    `uvm_info("SCB_REPORT", $sformatf("Total Data Write Trans : %0d", total_data_writes), UVM_LOW)
    `uvm_info("SCB_REPORT", $sformatf("Total DIFT Tag Ops     : %0d", total_dift_tag_ops), UVM_LOW)
    `uvm_info("SCB_REPORT", $sformatf("Total DIFT Violations  : %0d", total_dift_alerts), UVM_LOW)
    `uvm_info("SCB_REPORT", "==================================================", UVM_LOW)
  endfunction
endclass

`endif