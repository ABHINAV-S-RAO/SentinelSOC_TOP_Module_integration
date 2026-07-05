// =============================================================================
// dbg_uart_test_stub.sv
// SIMULATION-ONLY STUBS — DO NOT USE FOR SYNTHESIS OR TAPEOUT.
//
// Purpose: soc_top.sv currently instantiates dm_top/dmi_jtag with a port
// list that does NOT match the real pulp-platform/riscv-dbg source
// (e.g. it connects a non-existent "slave_rvalid_o" port, and omits several
// required inputs like next_dm_addr_i, hartinfo_i, dmi_rst_ni). Rather than
// edit soc_top.sv right now, these stubs present the EXACT port list
// soc_top.sv already expects, tied to safe idle values, so soc_top.sv
// elaborates unmodified while UART verification proceeds.
//
// JTAG/debug functionality is NOT exercised or validated by these stubs.
// When real debug-module integration work happens:
//   1. Remove this file from files.f
//   2. Add the real rtl/riscv-dbg/src/*.sv files instead
//   3. Fix soc_top.sv's dm_top instantiation (see notes from port-list
//      review: drop slave_rvalid_o, add next_dm_addr_i, ndmreset_ack_i,
//      hartinfo_i, dmi_rst_ni, master_r_err_i, master_r_other_err_i)
// =============================================================================

module dm_top #(
  parameter int unsigned NrHarts  = 1,
  parameter int unsigned BusWidth = 32
) (
  input  logic                 clk_i,
  input  logic                 rst_ni,
  input  logic                 testmode_i,
  output logic                  ndmreset_o,
  output logic                  dmactive_o,
  output logic [NrHarts-1:0]    debug_req_o,
  input  logic [NrHarts-1:0]    unavailable_i,

  input  logic [40:0]           dmi_req_i,
  input  logic                  dmi_req_valid_i,
  output logic                  dmi_req_ready_o,
  output logic [33:0]           dmi_resp_o,
  output logic                  dmi_resp_valid_o,
  input  logic                  dmi_resp_ready_i,

  input  logic                  slave_req_i,
  input  logic                  slave_we_i,
  input  logic [BusWidth-1:0]   slave_addr_i,
  input  logic [BusWidth/8-1:0] slave_be_i,
  input  logic [BusWidth-1:0]   slave_wdata_i,
  output logic                  slave_rvalid_o,
  output logic [BusWidth-1:0]   slave_rdata_o,

  output logic                  master_req_o,
  output logic [BusWidth-1:0]   master_add_o,
  output logic                  master_we_o,
  output logic [BusWidth-1:0]   master_wdata_o,
  output logic [BusWidth/8-1:0] master_be_o,
  input  logic                  master_gnt_i,
  input  logic                  master_r_valid_i,
  input  logic [BusWidth-1:0]   master_r_rdata_i
);

  assign ndmreset_o       = 1'b0;
  assign dmactive_o       = 1'b0;
  assign debug_req_o      = '0;
  assign dmi_req_ready_o  = 1'b0;   // never accept — no real DTM traffic expected
  assign dmi_resp_o       = '0;
  assign dmi_resp_valid_o = 1'b0;
  assign slave_rvalid_o   = 1'b0;
  assign slave_rdata_o    = '0;
  assign master_req_o     = 1'b0;
  assign master_add_o     = '0;
  assign master_we_o      = 1'b0;
  assign master_wdata_o   = '0;
  assign master_be_o      = '0;

endmodule : dm_top


module dmi_jtag #(
  parameter logic [31:0] IdcodeValue = 32'h00000DB3
) (
  input  logic clk_i,
  input  logic rst_ni,
  input  logic testmode_i,

  input  logic td_i,
  input  logic tck_i,
  input  logic tms_i,
  input  logic trst_ni,
  output logic td_o,
  output logic tdo_oe_o,

  output logic [40:0] dmi_req_o,
  output logic        dmi_req_valid_o,
  input  logic        dmi_req_ready_i,
  input  logic [33:0]  dmi_resp_i,
  input  logic         dmi_resp_valid_i,
  output logic         dmi_resp_ready_o
);

  assign td_o             = 1'b0;
  assign tdo_oe_o         = 1'b0;
  assign dmi_req_o        = '0;
  assign dmi_req_valid_o  = 1'b0;   // never issues a DMI request
  assign dmi_resp_ready_o = 1'b1;   // sinks anything, harmless since never requested

endmodule : dmi_jtag