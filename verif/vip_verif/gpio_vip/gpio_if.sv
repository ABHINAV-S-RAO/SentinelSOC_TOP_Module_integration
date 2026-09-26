`ifndef GPIO_IF_SV
`define GPIO_IF_SV
interface gpio_if(input logic clk_i, input logic rst_ni);
  wire  [31:0] gpio_pins;        // shared bidirectional bus to DUT
  logic [31:0] drv_val;          // VIP's driven value per pin
  logic [31:0] drv_en;           // 1 = VIP drives this pin (DUT should have dir=0 there)
  assign gpio_pins = drv_en ? drv_val : {32{1'bz}};
endinterface
`endif
