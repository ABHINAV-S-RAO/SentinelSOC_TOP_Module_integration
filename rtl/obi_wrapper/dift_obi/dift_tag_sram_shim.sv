// dift_tag_sram_shim.sv
//
// Shadow tag RAM adapter — sits beside obi_sram_shim for the DATA bus only.
//
// Connectivity diagram:
//   ibex_core ─── data_wdata_tag_o ──► [ this module ] ──► tag_we_o / tag_wdata_o
//   ibex_core ◄── data_rdata_tag_i ──  [ this module ] ◄── tag_rdata_i
//
//   The OBI data bus req/gnt/rvalid handshake is observed (read-only) so the
//   shim can produce tag_req_o / tag_we_o that are perfectly synchronised
//   with the data SRAM access driven by obi_sram_shim.
//
// The shadow tag RAM is word-addressed just like the data RAM.
// Word address = data_addr[AddrWidth-1:2]  (byte-addressed, word granularity).
//
// Tag RAM interface follows the same single-cycle registered-output SRAM
// convention as ibex_sram / most PULP SRAMs:
//   cycle N   : req_o=1, addr_o=X  →  (RAM accepts)
//   cycle N+1 : rdata_i contains the read result
//
// This matches exactly what obi_sram_shim delivers to the data RAM, so both
// shims can share the same clock-enable and address signals.

module dift_tag_sram_shim #(
  parameter int unsigned AddrWidth = 32
) (
  input  logic                     clk_i,
  input  logic                     rst_ni,

  // ── OBI data channel sideband (observe-only, no driving) ──────────────
  // These mirror the obi_sram_shim outputs so the tag shim stays in lock-step.
  input  logic                     obi_req_i,    // same as obi_sram_shim req_o
  input  logic                     obi_gnt_i,    // same as obi_sram_shim gnt_i
  input  logic                     obi_we_i,     // same as obi_sram_shim we_o
  input  logic [AddrWidth-1:0]     obi_addr_i,   // same as obi_sram_shim addr_o

  //  DIFT tag wires from ibex_core 
  input  logic                     core_wdata_tag_i,  // data_wdata_tag_o from core
  output logic                     core_rdata_tag_o,  // data_rdata_tag_i to core

  // Shadow tag RAM interface 
  output logic                     tag_req_o,
  output logic                     tag_we_o,
  output logic [AddrWidth-3:0]     tag_addr_o,   // word address (drop 2 LSBs)
  output logic                     tag_wdata_o,
  input  logic                     tag_rdata_i
);

  // -----------------------------------------------------------------------
  // A-channel: generate tag RAM access in lock-step with the data SRAM.
  // A transaction is accepted on the cycle where obi_req_i & obi_gnt_i.
  // -----------------------------------------------------------------------
  assign tag_req_o   = obi_req_i;
  assign tag_we_o    = obi_we_i;
  assign tag_addr_o  = obi_addr_i[AddrWidth-1:2];   // word-address
  assign tag_wdata_o = core_wdata_tag_i;

  // -----------------------------------------------------------------------
  // R-channel: the tag RAM returns rdata one cycle after the accepted request
  // (exactly the same pipeline depth as obi_sram_shim / ibex_sram).
  // obi_sram_shim sets rvalid_q = req & gnt, so the tag is valid on the same
  // cycle as obi_rsp_o.rvalid.  We just forward tag_rdata_i directly.
  // -----------------------------------------------------------------------
  assign core_rdata_tag_o = tag_rdata_i;

endmodule
