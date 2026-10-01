// =============================================================================
// clint_if.sv
// OBI-style driver interface for the clint_obi DUT.
//
// Exposes the flat OBI slave port of clint_obi as a clocking-block driven
// interface, mirroring the pattern used by plic_reg_if in plic_verif/.
// =============================================================================

interface clint_if (
  input logic clk_i,
  input logic rst_ni
);

  // OBI request signals (driven by TB / testbench driver)
  logic        req;
  logic [31:0] addr;
  logic        we;
  logic [ 3:0] be;
  logic [31:0] wdata;

  // OBI response signals (driven by DUT)
  logic        gnt;
  logic        rvalid;
  logic [31:0] rdata;
  logic        err;

  // Clocking block — all driver outputs are synchronised to posedge clk_i
  clocking drv_cb @(posedge clk_i);
    output req, addr, we, be, wdata;
    input  gnt, rvalid, rdata, err;
  endclocking

  modport drv (clocking drv_cb, input rst_ni);
  modport dut (
    input  req, addr, we, be, wdata,
    output gnt, rvalid, rdata, err
  );

  // Convenience task: de-assert all request lines (idle state)
  task automatic idle();
    req   = 1'b0;
    addr  = '0;
    we    = 1'b0;
    be    = 4'h0;
    wdata = '0;
  endtask

endinterface : clint_if
