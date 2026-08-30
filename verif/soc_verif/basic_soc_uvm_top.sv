`timescale 1ns/1ps

module basic_soc_uvm_top;
  import uvm_pkg::*;
  import basic_soc_uvm_pkg::*;

  // ---------------------------------------------------------------------------
  // Clock & Reset
  // ---------------------------------------------------------------------------
  logic clk_i;
  logic rst_ni;

  initial begin
    clk_i = 0;
    forever #10 clk_i = ~clk_i; // 50 MHz
  end

  initial begin
    rst_ni = 0;
    #100;
    rst_ni = 1;
  end

  // ---------------------------------------------------------------------------
  // Interface Instantiation
  // ---------------------------------------------------------------------------
  basic_soc_if vif(clk_i, rst_ni);

  // Enable DIFT
  initial vif.dift_en_i = 1'b1;

  // ---------------------------------------------------------------------------
  // DUT Instantiation
  // ---------------------------------------------------------------------------
  basic_soc_top u_dut (
    .clk_i              ( vif.clk_i ),
    .rst_ni             ( vif.rst_ni ),
    .uart_tx_o          ( vif.uart_tx_o ),
    .uart_rx_i          ( vif.uart_rx_i ),
`ifdef DIFT
    .dift_en_i          ( vif.dift_en_i ),
`endif
    .instr_req_o        ( vif.instr_req_o ),
    .instr_gnt_i        ( vif.instr_gnt_i ),
    .instr_rvalid_i     ( vif.instr_rvalid_i ),
    .instr_addr_o       ( vif.instr_addr_o ),
    .instr_rdata_i      ( vif.instr_rdata_i ),
    .instr_rdata_intg_i ( vif.instr_rdata_intg_i ),
    .instr_err_i        ( vif.instr_err_i )
  );

  // ---------------------------------------------------------------------------
  // Internal Probes Wire-Up
  // ---------------------------------------------------------------------------
  assign vif.apb_paddr   = u_dut.apb_req.paddr;
  assign vif.apb_pwdata  = u_dut.apb_req.pwdata;
  assign vif.apb_pwrite  = u_dut.apb_req.pwrite;
  assign vif.apb_psel    = u_dut.u_apb_uart.PSEL;
  assign vif.apb_penable = u_dut.apb_req.penable;
  
`ifdef DIFT
  assign vif.irq_dift    = u_dut.irq_dift;
`else
  assign vif.irq_dift    = 1'b0;
`endif

  // ---------------------------------------------------------------------------
  // UVM Initialization
  // ---------------------------------------------------------------------------
  initial begin
    uvm_config_db#(virtual basic_soc_if)::set(null, "uvm_test_top.*", "vif", vif);
    uvm_config_db#(virtual basic_soc_if)::set(null, "uvm_test_top.env", "vif", vif); 
    run_test("basic_soc_test");
  end

  // ---------------------------------------------------------------------------
  // Waveform Dumping
  // ---------------------------------------------------------------------------
  initial begin
    $shm_open("waves.shm");
    $shm_probe("ACMT");
  end

endmodule
