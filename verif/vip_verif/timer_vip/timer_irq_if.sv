`ifndef TIMER_IRQ_IF_SV
`define TIMER_IRQ_IF_SV
interface timer_irq_if(input logic clk_i, input logic rst_ni);
  logic irq_timer;
endinterface
`endif
