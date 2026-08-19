// =============================================================================
// dift_obi_ctrl_tb.sv
// Testbench for the DIFT OBI Control Wrapper module.
// Verifies native-to-OBI translation and Tag SRAM synchronization.
// =============================================================================
`timescale 1ns/1ps

module dift_obi_ctrl_tb;
  import obi_pkg::*;

  localparam CLK_PERIOD = 10;
  logic clk, rst_ni;
  initial clk = 0;
  always #(CLK_PERIOD/2) clk = ~clk;

  // DIFT enable
  logic dift_en_i;

  // Core instruction interface
  logic                          core_instr_req_i;
  logic                          core_instr_gnt_o;
  logic                          core_instr_rvalid_o;
  logic [31:0]                   core_instr_addr_i;
  logic [31:0]                   core_instr_rdata_o;
  logic                          core_instr_err_o;

  // Core data interface
  logic                          core_data_req_i;
  logic                          core_data_gnt_o;
  logic                          core_data_rvalid_o;
  logic                          core_data_we_i;
  logic [3:0]                    core_data_be_i;
  logic [31:0]                   core_data_addr_i;
  logic [31:0]                   core_data_wdata_i;
  logic [31:0]                   core_data_rdata_o;
  logic                          core_data_err_o;

  // DIFT tag sideband
  logic                          core_data_wdata_tag_i;
  logic                          core_data_rdata_tag_o;
  logic                          dift_exception_i;
  logic                          dift_exception_o;

  // OBI instruction port
  logic                          instr_obi_req_o;
  logic [31:0]                   instr_obi_addr_o;
  logic                          instr_obi_we_o;
  logic [3:0]                    instr_obi_be_o;
  logic [31:0]                   instr_obi_wdata_o;
  logic [0:0]                    instr_obi_aid_o;
  logic                          instr_obi_gnt_i;
  logic                          instr_obi_rvalid_i;
  logic [31:0]                   instr_obi_rdata_i;
  logic [0:0]                    instr_obi_rid_i;
  logic                          instr_obi_err_i;

  // OBI data port
  logic                          data_obi_req_o;
  logic [31:0]                   data_obi_addr_o;
  logic                          data_obi_we_o;
  logic [3:0]                    data_obi_be_o;
  logic [31:0]                   data_obi_wdata_o;
  logic [0:0]                    data_obi_aid_o;
  logic                          data_obi_gnt_i;
  logic                          data_obi_rvalid_i;
  logic [31:0]                   data_obi_rdata_i;
  logic [0:0]                    data_obi_rid_i;
  logic                          data_obi_err_i;

  // Shadow tag RAM interface
  logic                          tag_req_o;
  logic                          tag_we_o;
  logic [29:0]                   tag_addr_o;
  logic                          tag_wdata_o;
  logic                          tag_rdata_i;
  logic                          tag_gnt_i;

  // ---------------------------------------------------------
  // DUT Instantiation
  // ---------------------------------------------------------
  dift_obi_ctrl #(
    .ObiCfg(obi_pkg::ObiDefaultConfig)
  ) dut (
    .clk_i                (clk),
    .rst_ni               (rst_ni),

    .core_instr_req_i     (core_instr_req_i),
    .core_instr_gnt_o     (core_instr_gnt_o),
    .core_instr_rvalid_o  (core_instr_rvalid_o),
    .core_instr_addr_i    (core_instr_addr_i),
    .core_instr_rdata_o   (core_instr_rdata_o),
    .core_instr_err_o     (core_instr_err_o),

    .core_data_req_i      (core_data_req_i),
    .core_data_gnt_o      (core_data_gnt_o),
    .core_data_rvalid_o   (core_data_rvalid_o),
    .core_data_we_i       (core_data_we_i),
    .core_data_be_i       (core_data_be_i),
    .core_data_addr_i     (core_data_addr_i),
    .core_data_wdata_i    (core_data_wdata_i),
    .core_data_rdata_o    (core_data_rdata_o),
    .core_data_err_o      (core_data_err_o),

    .core_data_wdata_tag_i(core_data_wdata_tag_i),
    .core_data_rdata_tag_o(core_data_rdata_tag_o),
    .dift_exception_i     (dift_exception_i),
    .dift_en_i            (dift_en_i),

    .instr_obi_req_o      (instr_obi_req_o),
    .instr_obi_addr_o     (instr_obi_addr_o),
    .instr_obi_we_o       (instr_obi_we_o),
    .instr_obi_be_o       (instr_obi_be_o),
    .instr_obi_wdata_o    (instr_obi_wdata_o),
    .instr_obi_aid_o      (instr_obi_aid_o),
    .instr_obi_gnt_i      (instr_obi_gnt_i),
    .instr_obi_rvalid_i   (instr_obi_rvalid_i),
    .instr_obi_rdata_i    (instr_obi_rdata_i),
    .instr_obi_rid_i      (instr_obi_rid_i),
    .instr_obi_err_i      (instr_obi_err_i),

    .data_obi_req_o       (data_obi_req_o),
    .data_obi_addr_o      (data_obi_addr_o),
    .data_obi_we_o        (data_obi_we_o),
    .data_obi_be_o        (data_obi_be_o),
    .data_obi_wdata_o     (data_obi_wdata_o),
    .data_obi_aid_o       (data_obi_aid_o),
    .data_obi_gnt_i       (data_obi_gnt_i),
    .data_obi_rvalid_i    (data_obi_rvalid_i),
    .data_obi_rdata_i     (data_obi_rdata_i),
    .data_obi_rid_i       (data_obi_rid_i),
    .data_obi_err_i       (data_obi_err_i),

    .tag_req_o            (tag_req_o),
    .tag_we_o             (tag_we_o),
    .tag_addr_o           (tag_addr_o),
    .tag_wdata_o          (tag_wdata_o),
    .tag_rdata_i          (tag_rdata_i),
    .tag_gnt_i            (tag_gnt_i),

    .dift_exception_o     (dift_exception_o)
  );

  // ---------------------------------------------------------
  // Simple Memory Models (OBI + Tag RAM)
  // ---------------------------------------------------------
  logic [31:0] instr_mem [0:1023];
  logic [31:0] data_mem  [0:1023];
  logic        tag_mem   [0:1023];

  // Instruction SRAM Model (Read-Only)
  assign instr_obi_gnt_i = instr_obi_req_o; // always grant immediately
  assign instr_obi_rid_i = '0;
  assign instr_obi_err_i = 1'b0;
  
  always_ff @(posedge clk or negedge rst_ni) begin
    if (!rst_ni) begin
      instr_obi_rvalid_i <= 1'b0;
      instr_obi_rdata_i  <= '0;
    end else begin
      instr_obi_rvalid_i <= instr_obi_req_o && instr_obi_gnt_i;
      if (instr_obi_req_o && instr_obi_gnt_i) begin
        instr_obi_rdata_i <= instr_mem[instr_obi_addr_o[11:2]];
      end
    end
  end

  // Data SRAM Model
  assign data_obi_gnt_i = data_obi_req_o; // always grant immediately
  assign data_obi_rid_i = '0;
  assign data_obi_err_i = 1'b0;

  always_ff @(posedge clk or negedge rst_ni) begin
    if (!rst_ni) begin
      data_obi_rvalid_i <= 1'b0;
      data_obi_rdata_i  <= '0;
    end else begin
      data_obi_rvalid_i <= data_obi_req_o && data_obi_gnt_i;
      if (data_obi_req_o && data_obi_gnt_i) begin
        if (data_obi_we_o) begin
          if (data_obi_be_o[0]) data_mem[data_obi_addr_o[11:2]][7:0]   <= data_obi_wdata_o[7:0];
          if (data_obi_be_o[1]) data_mem[data_obi_addr_o[11:2]][15:8]  <= data_obi_wdata_o[15:8];
          if (data_obi_be_o[2]) data_mem[data_obi_addr_o[11:2]][23:16] <= data_obi_wdata_o[23:16];
          if (data_obi_be_o[3]) data_mem[data_obi_addr_o[11:2]][31:24] <= data_obi_wdata_o[31:24];
        end else begin
          data_obi_rdata_i <= data_mem[data_obi_addr_o[11:2]];
        end
      end
    end
  end

  // Tag SRAM Model
  assign tag_gnt_i = 1'b1;
  always_ff @(posedge clk or negedge rst_ni) begin
    if (!rst_ni) begin
      tag_rdata_i <= 1'b0;
    end else begin
      if (tag_req_o && tag_gnt_i) begin
        if (tag_we_o) begin
          tag_mem[tag_addr_o[9:0]] <= tag_wdata_o;
        end else begin
          tag_rdata_i <= tag_mem[tag_addr_o[9:0]];
        end
      end
    end
  end

  // ---------------------------------------------------------
  // Test Sequence
  // ---------------------------------------------------------
  int pass_count = 0;
  int fail_count = 0;

  task automatic pass_t(string msg);
    $display("[PASS] %s", msg);
    pass_count++;
  endtask

  task automatic fail_t(string msg);
    $display("[FAIL] %s", msg);
    fail_count++;
  endtask

  task automatic reset_tb();
    rst_ni = 0;
    dift_en_i = 1'b1;
    core_instr_req_i = 0;
    core_instr_addr_i = 0;
    core_data_req_i = 0;
    core_data_we_i = 0;
    core_data_be_i = 0;
    core_data_addr_i = 0;
    core_data_wdata_i = 0;
    core_data_wdata_tag_i = 0;
    dift_exception_i = 0;
    
    for(int i=0; i<1024; i++) begin
      instr_mem[i] = 32'h0;
      data_mem[i]  = 32'h0;
      tag_mem[i]   = 1'b0;
    end
    repeat (3) @(posedge clk);
    rst_ni = 1;
    @(posedge clk);
  endtask

  task automatic do_read(input logic [31:0] addr, output logic [31:0] rdata, output logic tag);
    core_data_req_i  = 1'b1;
    core_data_we_i   = 1'b0;
    core_data_addr_i = addr;
    core_data_be_i   = 4'hF;
    @(posedge clk);
    while (!core_data_gnt_o) @(posedge clk);
    core_data_req_i = 1'b0;
    while (!core_data_rvalid_o) @(posedge clk);
    rdata = core_data_rdata_o;
    tag   = core_data_rdata_tag_o;
  endtask

  task automatic do_write(input logic [31:0] addr, input logic [31:0] wdata, input logic tag);
    core_data_req_i  = 1'b1;
    core_data_we_i   = 1'b1;
    core_data_addr_i = addr;
    core_data_wdata_i = wdata;
    core_data_wdata_tag_i = tag;
    core_data_be_i   = 4'hF;
    @(posedge clk);
    while (!core_data_gnt_o) @(posedge clk);
    core_data_req_i = 1'b0;
    // Wait for write to finish (rvalid marks response)
    while (!core_data_rvalid_o) @(posedge clk);
  endtask

  initial begin
    logic [31:0] rdata;
    logic        rtag;

    $display("=================================================");
    $display(" Starting dift_obi_ctrl_tb");
    $display("=================================================");

    reset_tb();

    // Test 1: Basic Write and Read with DIFT enabled
    dift_en_i = 1'b1;
    do_write(32'h0000_1000, 32'hDEADBEEF, 1'b1);
    do_read(32'h0000_1000, rdata, rtag);
    if (rdata == 32'hDEADBEEF && rtag == 1'b1)
      pass_t("Test 1: Write/Read with DIFT tag = 1");
    else
      fail_t($sformatf("Test 1: Expected DEADBEEF (1), got %h (%b)", rdata, rtag));

    do_write(32'h0000_1004, 32'hCAFEBABE, 1'b0);
    do_read(32'h0000_1004, rdata, rtag);
    if (rdata == 32'hCAFEBABE && rtag == 1'b0)
      pass_t("Test 2: Write/Read with DIFT tag = 0");
    else
      fail_t($sformatf("Test 2: Expected CAFEBABE (0), got %h (%b)", rdata, rtag));

    // Test 3: DIFT Bypass Mode
    dift_en_i = 1'b0;
    do_write(32'h0000_1008, 32'h12345678, 1'b1); // Attempt to write tag=1 but dift_en=0
    do_read(32'h0000_1008, rdata, rtag);
    if (rdata == 32'h12345678 && rtag == 1'b0)
      pass_t("Test 3: dift_en_i=0 correctly masked the tag to 0 on write");
    else
      fail_t($sformatf("Test 3: Expected dift_en=0 masking (rtag=0), got rtag=%b", rtag));

    // Test 4: Exception passthrough
    dift_en_i = 1'b1;
    dift_exception_i = 1'b1;
    #1;
    if (dift_exception_o == 1'b1)
      pass_t("Test 4a: Exception passthrough works when DIFT enabled");
    else
      fail_t("Test 4a: Exception passthrough failed");

    dift_en_i = 1'b0;
    #1;
    if (dift_exception_o == 1'b0)
      pass_t("Test 4b: Exception masked when DIFT disabled");
    else
      fail_t("Test 4b: Exception masking failed");

    $display("=================================================");
    $display(" Simulation finished: %0d PASS, %0d FAIL", pass_count, fail_count);
    $display("=================================================");
    $finish;
  end

endmodule
