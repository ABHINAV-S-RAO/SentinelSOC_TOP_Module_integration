module rr_arb_tree #(
  parameter int unsigned NumIn     = 64,
  parameter int unsigned DataWidth = 32,
  parameter type         DataType  = logic [DataWidth-1:0],
  parameter bit          AxiVldRdy = 1'b1,
  parameter bit          LockIn    = 1'b0
) (
  input  logic                clk_i,
  input  logic                rst_ni,
  input  logic                flush_i,
  input  logic [NumIn-1:0]    rr_i,
  input  logic [NumIn-1:0]    req_i,
  output logic [NumIn-1:0]    gnt_o,
  input  DataType [NumIn-1:0] data_i,
  output logic                req_o,
  input  logic                gnt_i,
  output DataType             data_o,
  output logic [cf_math_pkg::idx_width(NumIn)-1:0] idx_o
);

  localparam int unsigned IdxWidth = cf_math_pkg::idx_width(NumIn);

  logic [IdxWidth-1:0] rr_q, rr_d;
  logic [IdxWidth-1:0] sel_idx;
  logic sel_valid;

  always_comb begin
    rr_d     = rr_q;
    sel_idx  = rr_q;
    sel_valid = 1'b0;
    gnt_o    = '0;
    req_o    = |req_i;
    data_o   = '0;
    idx_o    = rr_q;

    for (int unsigned k = 0; k < NumIn; k++) begin
      int unsigned i;
      i = (rr_q + k) % NumIn;
      if (!sel_valid && req_i[i]) begin
        sel_idx   = logic'(i[IdxWidth-1:0]);
        sel_valid = 1'b1;
        data_o    = data_i[i];
        idx_o     = logic'(i[IdxWidth-1:0]);
      end
    end

    if (sel_valid && gnt_i) begin
      gnt_o[sel_idx] = 1'b1;
      rr_d = (sel_idx == NumIn-1) ? '0 : sel_idx + 1'b1;
    end
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      rr_q <= '0;
    end else if (flush_i) begin
      rr_q <= '0;
    end else begin
      rr_q <= rr_d;
    end
  end

endmodule