`timescale 1ns/1ps

module tb_memory_model #(
  parameter int MEM_SIZE_WORDS = 65536 // 256 KB memory
)(
  input  logic        clk_i,
  input  logic        rst_ni,

  // OBI Subordinate Interface
  input  logic        req_i,
  output logic        gnt_o,
  output logic        rvalid_o,
  input  logic [31:0] addr_i,
  input  logic        we_i,
  input  logic [3:0]  be_i,
  input  logic [31:0] wdata_i,
  output logic [31:0] rdata_o,
  output logic        err_o
);

  logic [31:0] mem [MEM_SIZE_WORDS];

  assign gnt_o = req_i;
  assign err_o = 1'b0;

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      rvalid_o <= 1'b0;
      rdata_o  <= 32'h0;
    end else begin
      rvalid_o <= req_i;
      if (req_i) begin
        if (we_i) begin
          if (be_i[0]) mem[addr_i[17:2]][ 7: 0] <= wdata_i[ 7: 0];
          if (be_i[1]) mem[addr_i[17:2]][15: 8] <= wdata_i[15: 8];
          if (be_i[2]) mem[addr_i[17:2]][23:16] <= wdata_i[23:16];
          if (be_i[3]) mem[addr_i[17:2]][31:24] <= wdata_i[31:24];
        end else begin
          rdata_o <= mem[addr_i[17:2]];
        end
      end
    end
  end

endmodule

module soc_tb_top;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // ---------------------------------------------------------------------------
  // Clock & Reset Generation
  // ---------------------------------------------------------------------------
  logic clk_i;
  logic rst_ni;

  initial begin
    clk_i = 1'b0;
    forever #10 clk_i = ~clk_i; // 50 MHz
  end

  initial begin
    rst_ni = 1'b0;
    #100;
    rst_ni = 1'b1;
  end

  // ---------------------------------------------------------------------------
  // Interface Instantiations
  // ---------------------------------------------------------------------------
  obi_if      instr_obi_if (.clk_i(clk_i), .rst_ni(rst_ni));
  obi_if      data_obi_if  (.clk_i(clk_i), .rst_ni(rst_ni));
  dift_tag_if dift_if      (.clk_i(clk_i), .rst_ni(rst_ni));

  // ---------------------------------------------------------------------------
  // Signal Declarations
  // ---------------------------------------------------------------------------
  logic uart_tx_o;
  logic uart_rx_i;
  logic dift_en;
  logic crypto_verified;

  logic        instr_req, instr_gnt, instr_rvalid, instr_err;
  logic [31:0] instr_addr, instr_rdata;

  logic        data_req, data_gnt, data_rvalid, data_err, data_we;
  logic [3:0]  data_be;
  logic [31:0] data_addr, data_wdata, data_rdata;

  string firmware_file;

  initial begin
    crypto_verified = 1'b1; // Pass signature verification
    dift_en         = 1'b1; // Enable DIFT tracking
    uart_rx_i       = 1'b1; // Idle high
  end

  // ---------------------------------------------------------------------------
  // DUT Instantiation
  // ---------------------------------------------------------------------------
  basic_soc_top u_dut (
    .clk_i               ( clk_i ),
    .rst_ni              ( rst_ni ),
    .crypto_verified_i   ( crypto_verified ),
`ifdef DIFT
    .dift_en_i           ( dift_en ),
`endif
    .uart_tx_o           ( uart_tx_o ),
    .uart_rx_i           ( uart_rx_i ),

    .instr_req_o         ( instr_req ),
    .instr_gnt_i         ( instr_gnt ),
    .instr_rvalid_i      ( instr_rvalid ),
    .instr_addr_o        ( instr_addr ),
    .instr_rdata_i       ( instr_rdata ),
    .instr_rdata_intg_i  ( 7'h0 ),
    .instr_err_i         ( 1'b0 ),

    .data_req_o          ( data_req ),
    .data_gnt_i          ( data_gnt ),
    .data_rvalid_i       ( data_rvalid ),
    .data_addr_o         ( data_addr ),
    .data_we_o           ( data_we ),
    .data_be_o           ( data_be ),
    .data_wdata_o        ( data_wdata ),
    .data_rdata_i        ( data_rdata ),
    .data_err_i          ( data_err )
  );

  // ---------------------------------------------------------------------------
  // Testbench Memory Models
  // ---------------------------------------------------------------------------
  // Instruction Memory Model
  tb_memory_model u_tb_instr_mem (
    .clk_i              ( clk_i ),
    .rst_ni             ( rst_ni ),
    .req_i              ( instr_req ),
    .gnt_o              ( instr_gnt ),
    .rvalid_o           ( instr_rvalid ),
    .addr_i             ( instr_addr ),
    .we_i               ( 1'b0 ),
    .be_i               ( 4'hF ),
    .wdata_i            ( 32'h0 ),
    .rdata_o            ( instr_rdata ),
    .err_o              ( instr_err )
  );

  // Data Memory Model
  tb_memory_model u_tb_data_mem (
    .clk_i              ( clk_i ),
    .rst_ni             ( rst_ni ),
    .req_i              ( data_req ),
    .gnt_o              ( data_gnt ),
    .rvalid_o           ( data_rvalid ),
    .addr_i             ( data_addr ),
    .we_i               ( data_we ),
    .be_i               ( data_be ),
    .wdata_i            ( data_wdata ),
    .rdata_o            ( data_rdata ),
    .err_o              ( data_err )
  );

  // ---------------------------------------------------------------------------
  // Dynamic Firmware Loader Mechanism (+FIRMWARE=)
  // ---------------------------------------------------------------------------
  initial begin
    if ($value$plusargs("FIRMWARE=%s", firmware_file)) begin
      $display("[TB TOP] Loading binary memory image to TB Instruction Memory: %s", firmware_file);
      $readmemh(firmware_file, u_tb_instr_mem.mem);
    end else begin
      $display("[TB TOP] WARNING: No +FIRMWARE=<path.hex> plusarg supplied!");
    end
  end

  // ---------------------------------------------------------------------------
  // Interface Probes Wiring
  // ---------------------------------------------------------------------------
  // Instruction OBI Probes
  assign instr_obi_if.req    = instr_req;
  assign instr_obi_if.gnt    = instr_gnt;
  assign instr_obi_if.rvalid = instr_rvalid;
  assign instr_obi_if.we     = 1'b0;
  assign instr_obi_if.be     = 4'hF;
  assign instr_obi_if.addr   = instr_addr;
  assign instr_obi_if.wdata  = 32'h0;
  assign instr_obi_if.rdata  = instr_rdata;
  assign instr_obi_if.err    = instr_err;

  // Data OBI Probes
  assign data_obi_if.req    = data_req;
  assign data_obi_if.gnt    = data_gnt;
  assign data_obi_if.rvalid = data_rvalid;
  assign data_obi_if.we     = data_we;
  assign data_obi_if.be     = data_be;
  assign data_obi_if.addr   = data_addr;
  assign data_obi_if.wdata  = data_wdata;
  assign data_obi_if.rdata  = data_rdata;
  assign data_obi_if.err    = data_err;

  // DIFT Tag Probes
`ifdef DIFT
  assign dift_if.tag_req   = u_dut.tag_req;
  assign dift_if.tag_we    = u_dut.tag_we;
  assign dift_if.tag_addr  = u_dut.tag_addr;
  assign dift_if.tag_wdata = u_dut.tag_wdata;
  assign dift_if.tag_rdata = u_dut.tag_rdata;
  assign dift_if.irq_dift  = u_dut.irq_dift;
`else
  assign dift_if.irq_dift  = 1'b0;
`endif

  // ---------------------------------------------------------------------------
  // UVM Config DB Setup & Test Launch
  // ---------------------------------------------------------------------------
  initial begin
    uvm_config_db#(virtual obi_if)::set(null, "*", "instr_obi_vif", instr_obi_if);
    uvm_config_db#(virtual obi_if)::set(null, "*", "data_obi_vif",  data_obi_if);
    uvm_config_db#(virtual dift_tag_if)::set(null, "*", "dift_tag_vif", dift_if);

    run_test();
  end

  // Waveform Dumping
  initial begin
    $shm_open("waves.shm");
    $shm_probe("ACMT");
  end

endmodule