// dsram_model.sv -- OBI data SRAM model (read/write)
// Identical to isram_model but separate instance so you can size it differently.
`timescale 1ns/1ps
module dsram_model #(
  parameter int unsigned DEPTH    = 16384,  // 64 KB / 4 bytes
  parameter string       HEX_FILE = ""
)(
  input  logic        clk_i,
  input  logic        rst_ni,
  input  logic        req_i,
  output logic        gnt_o,
  output logic        rvalid_o,
  input  logic [31:0] addr_i,
  input  logic        we_i,
  input  logic [3:0]  be_i,
  input  logic [31:0] wdata_i,
  output logic [31:0] rdata_o,
  output logic        err_o
);
  logic [31:0] mem [0:DEPTH-1];

  initial begin
    for (int i = 0; i < DEPTH; i++) mem[i] = '0;
    if (HEX_FILE != "") $readmemh(HEX_FILE, mem);
  end

  assign gnt_o = req_i;

  logic        rvalid_q;
  logic [31:0] rdata_q;

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      rvalid_q <= 1'b0;
      rdata_q  <= '0;
    end else begin
      rvalid_q <= req_i;
      if (req_i) begin
        automatic int unsigned idx = addr_i[31:2] % DEPTH;
        if (we_i) begin
          if (be_i[0]) mem[idx][ 7: 0] <= wdata_i[ 7: 0];
          if (be_i[1]) mem[idx][15: 8] <= wdata_i[15: 8];
          if (be_i[2]) mem[idx][23:16] <= wdata_i[23:16];
          if (be_i[3]) mem[idx][31:24] <= wdata_i[31:24];
          rdata_q <= '0;
        end else begin
          rdata_q <= mem[idx];
        end
        $display("[DSRAM   @%0t] addr=0x%08h we=%0b data=0x%08h",
                 $time, addr_i, we_i, we_i ? wdata_i : mem[idx]);
      end
    end
  end

  assign rvalid_o = rvalid_q;
  assign rdata_o  = rdata_q;
  assign err_o    = 1'b0;
endmodule