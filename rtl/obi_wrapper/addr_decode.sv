module addr_decode #(
  parameter int unsigned NoIndices = 32'd0,
  parameter int unsigned NoRules   = 32'd1,
  parameter type         addr_t    = logic,
  parameter type         rule_t    = logic,
  parameter type         idx_t     = logic [cf_math_pkg::idx_width(NoIndices)-1:0]
) (
  input  addr_t               addr_i,
  input  rule_t [NoRules-1:0]  addr_map_i,
  output idx_t                 idx_o,
  output logic                 dec_valid_o,
  output logic                 dec_error_o,
  input  logic                 en_default_idx_i,
  input  idx_t                 default_idx_i
);

  always_comb begin
    idx_o        = default_idx_i;
    dec_valid_o  = 1'b0;
    dec_error_o  = en_default_idx_i ? 1'b0 : 1'b1;

    for (int unsigned i = 0; i < NoRules; i++) begin
      if ((addr_i >= addr_map_i[i].start_addr) &&
          ((addr_i <= addr_map_i[i].end_addr) || (addr_map_i[i].end_addr == '0))) begin
        idx_o       = idx_t'(addr_map_i[i].idx);
        dec_valid_o  = 1'b1;
        dec_error_o  = 1'b0;
      end
    end

    if (!dec_valid_o && en_default_idx_i) begin
      dec_valid_o = 1'b1;
      dec_error_o = 1'b0;
    end
  end

endmodule