`ifndef TIMER_IRQ_IF_SV
`define TIMER_IRQ_IF_SV
interface timer_irq_if(input logic clk_i, input logic rst_ni);
  logic       irq_timer;
  logic [3:0] irq_timer_raw;

  // Sticky event flags to reliably capture 1-cycle interrupt pulses
  bit [3:0] irq_raw_seen;
  bit       irq_timer_seen;

  always @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      irq_raw_seen   <= 4'b0;
      irq_timer_seen <= 1'b0;
    end else begin
      irq_raw_seen   <= irq_raw_seen | irq_timer_raw;
      irq_timer_seen <= irq_timer_seen | irq_timer;
    end
  end

  function void clear_flags();
    irq_raw_seen   = 4'b0;
    irq_timer_seen = 1'b0;
  endfunction
endinterface
`endif
