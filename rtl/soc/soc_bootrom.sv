// =============================================================================
// soc_bootrom.sv
// PLACEHOLDER behavioral boot ROM — NOT for tapeout.
// TODO (per soc_top.sv): replace with foundry ROM/SRAM macro when available.
//
// Read-only, word-addressed, 1-cycle read latency (gnt same cycle, rvalid
// one cycle later) — matches the reg-bus latency style already used
// elsewhere in soc_top.sv (see the PLIC reg adapter's rvalid registration).
//
// Optional firmware load: set InitFile parameter to a $readmemh-compatible
// hex file (word-per-line, 32-bit hex). Leave "" for all-zero contents.
// =============================================================================
module soc_bootrom #(
  parameter int unsigned NumWords = 1024,
  parameter string        InitFile = ""
) (
  input  logic        clk_i,
  input  logic        rst_ni,

  input  logic        req_i,
  input  logic [31:0] addr_i,
  output logic [31:0] rdata_o,
  output logic        rvalid_o,
  output logic        gnt_o,
  output logic        err_o
);

  localparam int unsigned AddrBits = $clog2(NumWords);

  logic [31:0] mem [NumWords];

  initial begin
    if (InitFile != "") begin
      $display("[soc_bootrom] Loading firmware from %s", InitFile);
      $readmemh(InitFile, mem);
    end
  end

  // Word-aligned index from byte address
  wire [AddrBits-1:0] word_idx = addr_i[AddrBits+1:2];

  // Always ready to accept a request (no backpressure)
  assign gnt_o = req_i;
  assign err_o = 1'b0; // no out-of-range checking in this placeholder

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      rvalid_o <= 1'b0;
      rdata_o  <= 32'h0;
    end else begin
      rvalid_o <= req_i & gnt_o;
      if (req_i & gnt_o) rdata_o <= mem[word_idx];
    end
  end

endmodule : soc_bootrom