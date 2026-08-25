`ifndef BASIC_SOC_IF_SV
`define BASIC_SOC_IF_SV
`timescale 1ns/1ps

interface basic_soc_if(input logic clk_i, input logic rst_ni);

  // ---------------------------------------------------------------------------
  // DUT Top-level Signals
  // ---------------------------------------------------------------------------
  logic uart_tx_o;
  logic uart_rx_i;
  
`ifdef DIFT
  logic dift_en_i;
`endif

  // Instruction Fetch OBI Interface
  logic        instr_req_o;
  logic        instr_gnt_i;
  logic        instr_rvalid_i;
  logic [31:0] instr_addr_o;
  logic [31:0] instr_rdata_i;
  logic [6:0]  instr_rdata_intg_i;
  logic        instr_err_i;

  // ---------------------------------------------------------------------------
  // Internal Probes (driven by tb top)
  // ---------------------------------------------------------------------------
  logic [31:0] apb_paddr;
  logic [31:0] apb_pwdata;
  logic        apb_pwrite;
  logic        apb_psel;
  logic        apb_penable;
  
  // DIFT internal exception
  logic        irq_dift;

  // ---------------------------------------------------------------------------
  // Clocking block for clean sampling
  // ---------------------------------------------------------------------------
  clocking cb @(posedge clk_i);
    default input #1ps output #1ns;
    input  uart_tx_o;
    output uart_rx_i;
    
    input  instr_req_o;
    output instr_gnt_i;
    output instr_rvalid_i;
    input  instr_addr_o;
    output instr_rdata_i;
    output instr_rdata_intg_i;
    output instr_err_i;
    
    input apb_paddr;
    input apb_pwdata;
    input apb_pwrite;
    input apb_psel;
    input apb_penable;
    input irq_dift;
  endclocking

endinterface

`endif
