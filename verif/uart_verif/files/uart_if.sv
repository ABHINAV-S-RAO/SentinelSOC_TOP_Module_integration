// =============================================================================
// uart_if.sv
// Physical UART interface + clocking block for the UVM testbench.
// Connects to soc_top's uart_tx_o and uart_rx_i pins.
//
// The TB drives uart_rx_i (feeding bytes INTO the SoC).
// The TB monitors uart_tx_o (capturing bytes the SoC sends out).
// =============================================================================

interface uart_if (input logic clk);

  // Physical pins — match soc_top port names
  logic tx;   // SoC → TB  (we monitor this)
  logic rx;   // TB → SoC  (we drive this)

  // Baud clock — derived from clocking block, used by driver/monitor
  // Actual baud rate is set as a parameter in the env.
  // Default: 115200 baud at 50 MHz system clock → 434 clocks/bit
  // Override via uart_if.baud_clks_per_bit before test starts.
  int unsigned baud_clks_per_bit = 434;

  // Clocking block for synchronous driving (TB → SoC on rx)
  clocking driver_cb @(posedge clk);
    default input  #1step
            output #1;
    output rx;
  endclocking

  // Clocking block for monitoring (SoC → TB on tx)
  clocking monitor_cb @(posedge clk);
    default input #1step;
    input  tx;
  endclocking

  // Modport for driver
  modport driver_mp  (clocking driver_cb,  input clk);
  // Modport for monitor
  modport monitor_mp (clocking monitor_cb, input clk);

endinterface : uart_if
