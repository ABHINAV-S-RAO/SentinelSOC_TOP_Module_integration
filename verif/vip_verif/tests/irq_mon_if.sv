`ifndef IRQ_MON_IF_SV
`define IRQ_MON_IF_SV
// Interrupt lines of final_soc_top, observed by the interrupt-source test
// (soc_irq_test.sv). Driven from the testbench top; the test only reads them.
interface irq_mon_if (input logic clk_i, input logic rst_ni);
  logic        irq_external;   // PLIC target 0 -> Ibex irq_external_i
  logic        irq_mtimer;     // CLINT mtip    -> Ibex irq_timer_i
  logic        irq_msoft;      // CLINT msip    -> Ibex irq_software_i
  logic [12:0] plic_src;       // PLIC source inputs, bit n = source n (bit 0 unused)
endinterface
`endif
