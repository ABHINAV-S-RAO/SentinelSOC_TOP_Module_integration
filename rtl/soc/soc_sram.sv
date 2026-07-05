// =============================================================================
// soc_sram.sv
// PLACEHOLDER behavioral single-port SRAM — NOT for tapeout.
// TODO (per soc_top.sv): replace with foundry SRAM macro when available.
//
// Word-addressed, byte-enable writes, 1-cycle read latency (gnt same cycle,
// rvalid one cycle later) — same latency convention as soc_bootrom.sv.
// Used for both ISRAM and DSRAM instances in soc_top.sv.
// =============================================================================
module soc_sram #(
  parameter int unsigned NumWords = 1024
) (
  input  logic        clk_i,
  input  logic        rst_ni,

  input  logic        req_i,
  input  logic        we_i,
  input  logic [3:0]  be_i,
  input  logic [31:0] addr_i,
  input  logic [31:0] wdata_i,
  output logic [31:0] rdata_o,
  output logic        rvalid_o,
  output logic        gnt_o,
  output logic        err_o
);

  localparam int unsigned AddrBits = $clog2(NumWords);

  logic [31:0] mem [NumWords];

  wire [AddrBits-1:0] word_idx = addr_i[AddrBits+1:2];

  assign gnt_o = req_i;
  assign err_o = 1'b0; // no out-of-range checking in this placeholder

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      rvalid_o <= 1'b0;
      rdata_o  <= 32'h0;
    end else begin
      rvalid_o <= req_i & gnt_o;
      if (req_i & gnt_o) begin
        if (we_i) begin
          if (be_i[0]) mem[word_idx][ 7:0]  <= wdata_i[ 7:0];
          if (be_i[1]) mem[word_idx][15:8]  <= wdata_i[15:8];
          if (be_i[2]) mem[word_idx][23:16] <= wdata_i[23:16];
          if (be_i[3]) mem[word_idx][31:24] <= wdata_i[31:24];
          rdata_o <= 32'h0; // write, no meaningful read data
        end else begin
          rdata_o <= mem[word_idx];
        end
      end
    end
  end

endmodule : soc_sram