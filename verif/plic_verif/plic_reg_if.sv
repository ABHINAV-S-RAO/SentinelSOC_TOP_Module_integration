// plic_reg_if.sv
// Driver-side interface for the plic_top reg_req_t/reg_rsp_t bus.
// ADAPT: field names below assume:
//   req: valid, write, addr[31:0], wdata[31:0], wstrb[3:0]
//   rsp: ready, rdata[31:0], error
// If your reg_pkg struct differs (extra fields, different widths), update here only.

interface plic_reg_if (
  input logic clk_i,
  input logic rst_ni
);

  logic        valid;
  logic        write;
  logic [31:0] addr;
  logic [31:0] wdata;
  logic [3:0]  wstrb;
  logic        ready;
  logic [31:0] rdata;
  logic        error;

  clocking drv_cb @(posedge clk_i);
    output valid, write, addr, wdata, wstrb;
    input  ready, rdata, error;
  endclocking

  modport drv (clocking drv_cb, input rst_ni);
  modport dut (input valid, write, addr, wdata, wstrb, output ready, rdata, error);

  task automatic reset_bus();
    valid = 1'b0;
    write = 1'b0;
    addr  = '0;
    wdata = '0;
    wstrb = '0;
  endtask

endinterface