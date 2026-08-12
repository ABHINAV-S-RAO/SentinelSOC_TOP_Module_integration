`timescale 1ns/1ps

import ibex_pkg::*; // change to ibex_pkg

module ibex_dift_logic
(
  // Propagation Interface
  input  logic [ALU_MODE_WIDTH-1:0] operator_i,      // From Tag Propagation Register
  input  logic                      operand_a_tag_i, // Tag of Source 1
  input  logic                      operand_b_tag_i, // Tag of Source 2
  input  logic                      instr_tag_i,    // Tag of the instruction (for control flow)
  
  // Check Interface
  input  logic                      check_s1_i,      // Enable check for Source 1
  input  logic                      check_s2_i,      // Enable check for Source 2
  input  logic                      check_d_i,       // Enable check for Destination
  input  logic                      is_load_i,       // Bypass check if instruction is LOAD
  
  // Outputs
  output logic                      result_tag_o,    // Calculated tag for result
  output logic                      rf_enable_tag_o, // Enable writing tag to RegFile
  output logic                      pc_enable_tag_o, // Enable tag update for PC
  output logic                      exception_o      // DIFT Violation Exception
);

// --- 1. Propagation Logic + 2. Check Logic (merged to avoid result_tag_o ordering issue) ---
  always_comb begin
    result_tag_o    = 1'b0;
    rf_enable_tag_o = 1'b1;
    pc_enable_tag_o = 1'b1;
    exception_o     = 1'b0;

    unique case (operator_i)
      ALU_MODE_OLD: begin
        rf_enable_tag_o = 1'b0;
        pc_enable_tag_o = 1'b0;
      end
      ALU_MODE_AND:   result_tag_o = operand_a_tag_i & operand_b_tag_i;
      ALU_MODE_OR:    result_tag_o = operand_a_tag_i | operand_b_tag_i;
      ALU_MODE_CLEAR: result_tag_o = 1'b0;
      default:        result_tag_o = 1'b0;
    endcase

    // PC/control-flow taint always propagates into result when mode is active
    //if (rf_enable_tag_o) begin
      //result_tag_o = result_tag_o | instr_tag_i;
    //end

    // Check logic: exception if policy bit set AND tag is present
    // Loads bypass this — their check is done by riscv_load_check at core level
    if (~is_load_i) begin
      exception_o = (operand_a_tag_i & check_s1_i) ||
                    (operand_b_tag_i & check_s2_i) ||
                    (result_tag_o    & check_d_i);
    end
  end
/*
  // --- 1. Propagation Logic (ALU Mode Based) ---
  always_comb
  begin
    result_tag_o    = 1'b0;
    rf_enable_tag_o = 1'b1;
    pc_enable_tag_o = 1'b1;

    unique case (operator_i)
      ALU_MODE_OLD: begin            // include ALU_MODE in pkg - WIDTH, OLD, AND, OR, CLEAR
        rf_enable_tag_o = 1'b0;
        pc_enable_tag_o = 1'b0;
      end
      ALU_MODE_AND:   result_tag_o = operand_a_tag_i & operand_b_tag_i;
      ALU_MODE_OR:    result_tag_o = operand_a_tag_i | operand_b_tag_i;
      ALU_MODE_CLEAR: result_tag_o = 1'b0;
      default:        result_tag_o = 1'b0;
    endcase
  
    //PC taint always propagates regardless of ALU mode = Control flow tainted = result tainted
   if (rf_enable_tag_o) begin
      result_tag_o = result_tag_o | instr_tag_i;
    end
  end

  // --- 2. Check Logic (Security Enforcement) ---
  always_comb
  begin
    // Exceptions are raised if a check is enabled AND the corresponding operand is tainted.
    // Loads are bypassed here as they usually get their tag from memory.
    if (~is_load_i) begin
      exception_o = (operand_a_tag_i & check_s1_i) || 
                    (operand_b_tag_i & check_s2_i) || 
                    (result_tag_o    & check_d_i);
    end else begin
      exception_o = 1'b0;
    end
  end
*/
endmodule