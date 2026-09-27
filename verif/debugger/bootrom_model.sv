// bootrom_model.sv -- simple OBI-compliant read-only memory model
// 1-cycle gnt, 1-cycle rvalid. Preload via $readmemh if HEX_FILE defined.
// Writes are accepted (gnt goes high) but silently ignored (ROM).
`timescale 1ns/1ps
module bootrom_model #(
  parameter int unsigned DEPTH    = 16384,  // 64 KB / 4 bytes
  parameter string       HEX_FILE = ""
)(
  input  logic        clk_i,
  input  logic        rst_ni,
  // OBI subordinate
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
    for (int i = 0; i < DEPTH; i++) mem[i] = 32'h0000_0013; // NOP (addi x0,x0,0)
    if (HEX_FILE != "") $readmemh(HEX_FILE, mem);
  end

  // gnt: always ready combinatorially when requested
  assign gnt_o = req_i;

  // rvalid: 1 cycle after gnt
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
        rdata_q <= mem[idx];
        // probe: let sim see every bootrom access
        $display("[BOOTROM @%0t] addr=0x%08h rdata=0x%08h we=%0b",
                 $time, addr_i, mem[idx], we_i);
      end
    end
  end

  assign rvalid_o = rvalid_q;
  assign rdata_o  = rdata_q;
  assign err_o    = 1'b0;
endmodule