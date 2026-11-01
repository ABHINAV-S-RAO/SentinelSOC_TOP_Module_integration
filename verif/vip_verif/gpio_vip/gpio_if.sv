`ifndef GPIO_IF_SV
`define GPIO_IF_SV
interface gpio_if(input logic clk_i, input logic rst_ni);
  wire  [31:0] gpio_pins;        // shared bidirectional bus to DUT
  logic [31:0] drv_val;          // VIP's driven value per pin
  logic [31:0] drv_en;           // 1 = VIP drives this pin (DUT should have dir=0 there)

  // Initialise to 0 so the pins are released (hi-Z) at time-0.
  // This is critical in passive mode where GpioDriver.run_phase never fires
  // and drv_en would otherwise stay X, driving gpio_pins to X and masking
  // the DUT's output value.
  initial begin
    drv_val = '0;
    drv_en  = '0;
  end

  // Per-bit assignment: each pin is either driven by the VIP (drv_en[i]=1)
  // or released to hi-Z so the DUT can drive it (drv_en[i]=0).
  // A single 32-bit ternary with a scalar drv_en would drive ALL bits to
  // drv_val whenever drv_en was X, conflicting with the DUT on every pin.
  genvar gi;
  generate
    for (gi = 0; gi < 32; gi++) begin : gen_gpio_drv
      assign gpio_pins[gi] = drv_en[gi] ? drv_val[gi] : 1'bz;
    end
  endgenerate
endinterface
`endif
