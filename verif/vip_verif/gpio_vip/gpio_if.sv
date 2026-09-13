`ifndef GPIO_IF_SV
`define GPIO_IF_SV
interface gpio_if(input logic clk_i, input logic rst_ni);
  logic [31:0] gpio_pins;
endinterface
`endif
