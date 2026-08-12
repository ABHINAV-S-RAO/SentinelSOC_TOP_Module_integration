module delta_counter #(
    parameter int unsigned WIDTH = 4,
    parameter bit STICKY_OVERFLOW = 1'b0
)(
    input  logic                 clk_i,
    input  logic                 rst_ni,
    input  logic                 clear_i,
    input  logic                 en_i,
    input  logic                 load_i,
    input  logic                 down_i,
    input  logic [WIDTH-1:0]     delta_i,
    input  logic [WIDTH-1:0]     d_i,
    output logic [WIDTH-1:0]     q_o,
    output logic                 overflow_o
);

  logic [WIDTH:0] next_q;

  always_comb begin
    next_q       = {1'b0, q_o};
    overflow_o   = 1'b0;

    if (clear_i) begin
      next_q = '0;
    end else if (load_i) begin
      next_q = {1'b0, d_i};
    end else if (en_i) begin
      if (down_i) begin
        if (q_o < delta_i) begin
          next_q     = '0;
          overflow_o = 1'b1;
        end else begin
          next_q = {1'b0, q_o} - {1'b0, delta_i};
        end
      end else begin
        next_q = {1'b0, q_o} + {1'b0, delta_i};
        if (next_q[WIDTH]) overflow_o = 1'b1;
      end
    end
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      q_o <= '0;
    end else begin
      q_o <= next_q[WIDTH-1:0];
    end
  end

endmodule