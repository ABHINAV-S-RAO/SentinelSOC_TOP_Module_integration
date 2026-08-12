// DIFT–OBI Control Module
// Acts a bridge between the obi for data and obi for tag
// 1. Converts ibex_core's memory interface (req/gnt/rvalid/addr/we/be/
//    wdata/rdata + tag sideband) into OBI req/rsp structs for both the
//    instruction bus and the data bus.
// 2. Provides DIFT tag routing for the DATA bus only:
//      • Writes: forward core_data_wdata_tag_i alongside the OBI write req.
//      • Reads:  capture the tag returned by the tag RAM shim and drive
//                core_data_rdata_tag_o back to ibex_core.
// 3. Provides a tag-aware OBI SRAM shim interface for the shadow tag RAM:
//      • tag_req_o / tag_we_o / tag_addr_o / tag_wdata_o  → shadow tag SRAM
//      • tag_rdata_i                                       ← shadow tag SRAM
//    This is done via an internal instance of dift_tag_sram_shim.
// 4. Drives dift_exception_o from ibex_core directly to system-level
//    interrupt / trap logic.
//
// OBI configuration used: ObiDefaultConfig (32-bit addr, 32-bit data, 1-bit id).
//
// ─────────────────────────────────────────────────────────────────────────────
// Connectivity overview
//
//                 ┌───────────────────────────────────────────────┐
//  ibex_core      │              dift_obi_ctrl                    │   OBI fabric
//  ───────────    │                                               │   ─────────
//  instr_req_o ──►│──► instr_obi_req_o ───────────────────────────┼──► xbar / instr SRAM
//  instr_gnt_i ◄──│◄── instr_obi_rsp_i ─────────────────────────  │
//  instr_rvalid_i │                                               │
//  instr_addr_o ──►│                                               │
//  instr_rdata_i ◄─│                                               │
//                 │                                               │
//  data_req_o  ──►│──► data_obi_req_o ────────────────────────────┼──► xbar / data SRAM
//  data_gnt_i  ◄──│◄── data_obi_rsp_i                             │
//  data_rvalid_i  │                                               │
//  data_addr_o ──►│                                               │
//  data_we_o   ──►│                                               │
//  data_be_o   ──►│                                               │
//  data_wdata_o──►│                                               │
//  data_rdata_i◄──│                                               │
//                 │   ┌─────────────────────────────┐             │
//  wdata_tag_o ──►│──►│   dift_tag_sram_shim        │─ tag_req_o ─┼──► shadow tag RAM
//  rdata_tag_i ◄──│◄──│   (internal instance)       │◄ tag_rdata_i│◄── shadow tag RAM
//                 │   └─────────────────────────────┘             │
//  exception_o ──►│──────────────────────────────────────────────►│ system
//                 └───────────────────────────────────────────────┘
// ─────────────────────────────────────────────────────────────────────────────

`include "obi/typedef.svh"

module dift_obi_ctrl
  import obi_pkg::*;
#(
  parameter obi_cfg_t ObiCfg = ObiDefaultConfig
) (
  input  logic clk_i,
  input  logic rst_ni,

  // ibex_core instruction bus (instructions not tagged here)
  input  logic                          core_instr_req_i,
  output logic                          core_instr_gnt_o,
  output logic                          core_instr_rvalid_o,
  input  logic [ObiCfg.AddrWidth-1:0]  core_instr_addr_i,
  output logic [ObiCfg.DataWidth-1:0]  core_instr_rdata_o,
  output logic                          core_instr_err_o,

  // ibex_core data bus
  input  logic                          core_data_req_i,
  output logic                          core_data_gnt_o,
  output logic                          core_data_rvalid_o,
  input  logic                          core_data_we_i,
  input  logic [ObiCfg.DataWidth/8-1:0] core_data_be_i,
  input  logic [ObiCfg.AddrWidth-1:0]  core_data_addr_i,
  input  logic [ObiCfg.DataWidth-1:0]  core_data_wdata_i,
  output logic [ObiCfg.DataWidth-1:0]  core_data_rdata_o,
  output logic                          core_data_err_o,

  // DIFT tag sideband (data bus only)
  input  logic                          core_data_wdata_tag_i, // from core: tag of write-data
  output logic                          core_data_rdata_tag_o, // to core:   tag of read-data
  input  logic                          dift_exception_i,      // from core: security exception

  // OBI instruction port (manager, drives instruction SRAM / xbar)
  output logic                          instr_obi_req_o,
  output logic [ObiCfg.AddrWidth-1:0]  instr_obi_addr_o,
  output logic                          instr_obi_we_o,
  output logic [ObiCfg.DataWidth/8-1:0] instr_obi_be_o,
  output logic [ObiCfg.DataWidth-1:0]  instr_obi_wdata_o,
  output logic [ObiCfg.IdWidth-1:0]    instr_obi_aid_o,
  input  logic                          instr_obi_gnt_i,
  input  logic                          instr_obi_rvalid_i,
  input  logic [ObiCfg.DataWidth-1:0]  instr_obi_rdata_i,
  input  logic [ObiCfg.IdWidth-1:0]    instr_obi_rid_i,
  input  logic                          instr_obi_err_i,

  // OBI data port (manager, drives data SRAM / xbar)
  output logic                          data_obi_req_o,
  output logic [ObiCfg.AddrWidth-1:0]  data_obi_addr_o,
  output logic                          data_obi_we_o,
  output logic [ObiCfg.DataWidth/8-1:0] data_obi_be_o,
  output logic [ObiCfg.DataWidth-1:0]  data_obi_wdata_o,
  output logic [ObiCfg.IdWidth-1:0]    data_obi_aid_o,
  input  logic                          data_obi_gnt_i,
  input  logic                          data_obi_rvalid_i,
  input  logic [ObiCfg.DataWidth-1:0]  data_obi_rdata_i,
  input  logic [ObiCfg.IdWidth-1:0]    data_obi_rid_i,
  input  logic                          data_obi_err_i,

  // Shadow tag RAM interface (word-addressed, 1-bit data)
  output logic                              tag_req_o,
  output logic                              tag_we_o,
  output logic [ObiCfg.AddrWidth-3:0]      tag_addr_o,   // word address
  output logic                              tag_wdata_o,
  input  logic                              tag_rdata_i,
  input  logic                              tag_gnt_i,    // tie to 1 if SRAM always accepts

  // System output
  output logic                          dift_exception_o  // system-level security alert
);

  // Instruction bus — wire-through (no tagging on fetch path)
  assign instr_obi_req_o   = core_instr_req_i;
  assign instr_obi_addr_o  = core_instr_addr_i;
  assign instr_obi_we_o    = 1'b0;              // fetch is always a read
  assign instr_obi_be_o    = '1;               // always full-word
  assign instr_obi_wdata_o = '0;
  assign instr_obi_aid_o   = '0;               // single outstanding fetch at a time

  assign core_instr_gnt_o    = instr_obi_gnt_i;
  assign core_instr_rvalid_o = instr_obi_rvalid_i;
  assign core_instr_rdata_o  = instr_obi_rdata_i;
  assign core_instr_err_o    = instr_obi_err_i;

  // Data bus — wire-through
  // OBI A-channel
  assign data_obi_req_o   = core_data_req_i;
  assign data_obi_addr_o  = core_data_addr_i;
  assign data_obi_we_o    = core_data_we_i;
  assign data_obi_be_o    = core_data_be_i;
  assign data_obi_wdata_o = core_data_wdata_i;
  assign data_obi_aid_o   = '0;

  // OBI R-channel back to core
  assign core_data_gnt_o    = data_obi_gnt_i;
  assign core_data_rvalid_o = data_obi_rvalid_i;
  assign core_data_rdata_o  = data_obi_rdata_i;
  assign core_data_err_o    = data_obi_err_i;

  // Tag sideband — instantiate the shadow tag RAM shim
  // The shim observes exactly the same req/gnt/we/addr as the data OBI path
  // and produces a synchronised access to the shadow tag RAM.

  dift_tag_sram_shim #(
    .AddrWidth (ObiCfg.AddrWidth)
  ) u_tag_sram_shim (
    .clk_i             (clk_i),
    .rst_ni            (rst_ni),

    // Mirror of the data OBI A-channel 
    .obi_req_i         (core_data_req_i),
    .obi_gnt_i         (data_obi_gnt_i),
    .obi_we_i          (core_data_we_i),
    .obi_addr_i        (core_data_addr_i),

    // Tag from/to ibex_core
    .core_wdata_tag_i  (core_data_wdata_tag_i),
    .core_rdata_tag_o  (core_data_rdata_tag_o),

    // Shadow tag RAM
    .tag_req_o         (tag_req_o),
    .tag_we_o          (tag_we_o),
    .tag_addr_o        (tag_addr_o),
    .tag_wdata_o       (tag_wdata_o),
    .tag_rdata_i       (tag_rdata_i)
  );

  // Exception passthrough
  assign dift_exception_o = dift_exception_i;


  // Unused inputs
  logic unused_tag_gnt;
  assign unused_tag_gnt = tag_gnt_i;

  logic unused_rid;
  assign unused_rid = ^{instr_obi_rid_i, data_obi_rid_i};

endmodule
