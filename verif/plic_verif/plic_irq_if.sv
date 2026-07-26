interface plic_irq_if #(
  parameter int unsigned N_SOURCE = 12
) (
  input logic clk_i
);
  logic [N_SOURCE-1:0] irq_src;
  modport drv (output irq_src);
  modport dut (input irq_src);
endinterface