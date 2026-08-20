// =============================================================================
// dift_obi_ctrl_tb.sv
// Exhaustive Testbench for the DIFT OBI Control Wrapper module.
// Verifies native-to-OBI translation, Tag SRAM synchronization, and edge cases.
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

  // Configurable delays for memory response
  int instr_gnt_delay = 0;
  int instr_rvalid_delay = 0;
  int data_gnt_delay = 0;
  int data_rvalid_delay = 0;

  // Instruction SRAM Model
  initial begin
    instr_obi_gnt_i = 0;
    instr_obi_rvalid_i = 0;
    instr_obi_rdata_i = 0;
    instr_obi_err_i = 0;
    instr_obi_rid_i = 0;
    forever begin
      @(posedge clk);
      if (instr_obi_req_o) begin
        repeat(instr_gnt_delay) @(posedge clk);
        instr_obi_gnt_i = 1'b1;
        @(posedge clk);
        instr_obi_gnt_i = 1'b0;
        
        repeat(instr_rvalid_delay) @(posedge clk);
        instr_obi_rvalid_i = 1'b1;
        instr_obi_rdata_i = instr_mem[instr_obi_addr_o[11:2]];
        @(posedge clk);
        instr_obi_rvalid_i = 1'b0;
      end
    end
  end

  // Data SRAM Model
  initial begin
    data_obi_gnt_i = 0;
    data_obi_rvalid_i = 0;
    data_obi_rdata_i = 0;
    data_obi_err_i = 0;
    data_obi_rid_i = 0;
    forever begin
      @(posedge clk);
      if (data_obi_req_o) begin
        repeat(data_gnt_delay) @(posedge clk);
        data_obi_gnt_i = 1'b1;
        @(posedge clk);
        data_obi_gnt_i = 1'b0;
        
        // Write happens on grant cycle
        if (data_obi_we_o) begin
          if (data_obi_be_o[0]) data_mem[data_obi_addr_o[11:2]][7:0]   = data_obi_wdata_o[7:0];
          if (data_obi_be_o[1]) data_mem[data_obi_addr_o[11:2]][15:8]  = data_obi_wdata_o[15:8];
          if (data_obi_be_o[2]) data_mem[data_obi_addr_o[11:2]][23:16] = data_obi_wdata_o[23:16];
          if (data_obi_be_o[3]) data_mem[data_obi_addr_o[11:2]][31:24] = data_obi_wdata_o[31:24];
        end

        repeat(data_rvalid_delay) @(posedge clk);
        data_obi_rvalid_i = 1'b1;
        if (!data_obi_we_o) begin
          data_obi_rdata_i = data_mem[data_obi_addr_o[11:2]];
        end
        @(posedge clk);
        data_obi_rvalid_i = 1'b0;
      end
    end
  end

  // Tag SRAM Model
  assign tag_gnt_i = 1'b1; // Always grant tag SRAM immediately
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

  task automatic do_read(input logic [31:0] addr, input logic [3:0] be, output logic [31:0] rdata, output logic tag);
    core_data_req_i  = 1'b1;
    core_data_we_i   = 1'b0;
    core_data_addr_i = addr;
    core_data_be_i   = be;
    @(posedge clk);
    while (!core_data_gnt_o) @(posedge clk);
    core_data_req_i = 1'b0;
    while (!core_data_rvalid_o) @(posedge clk);
    rdata = core_data_rdata_o;
    tag   = core_data_rdata_tag_o;
  endtask

  task automatic do_write(input logic [31:0] addr, input logic [3:0] be, input logic [31:0] wdata, input logic tag);
    core_data_req_i  = 1'b1;
    core_data_we_i   = 1'b1;
    core_data_addr_i = addr;
    core_data_wdata_i = wdata;
    core_data_wdata_tag_i = tag;
    core_data_be_i   = be;
    @(posedge clk);
    while (!core_data_gnt_o) @(posedge clk);
    core_data_req_i = 1'b0;
    // Wait for write to finish (rvalid marks response)
    while (!core_data_rvalid_o) @(posedge clk);
  endtask

  task automatic do_instr_fetch(input logic [31:0] addr, output logic [31:0] rdata);
    core_instr_req_i = 1'b1;
    core_instr_addr_i = addr;
    @(posedge clk);
    while (!core_instr_gnt_o) @(posedge clk);
    core_instr_req_i = 1'b0;
    while (!core_instr_rvalid_o) @(posedge clk);
    rdata = core_instr_rdata_o;
  endtask

  initial begin
    logic [31:0] rdata;
    logic        rtag;

    $display("=================================================");
    $display(" Starting Exhaustive dift_obi_ctrl_tb");
    $display("=================================================");

    reset_tb();

    // -------------------------------------------------------------
    // PHASE 1: DIFT ENABLED = 1
    // -------------------------------------------------------------
    $display("\n--- PHASE 1: dift_en = 1 ---");
    dift_en_i = 1'b1;

    // Edge Case 1: Standard Word Write/Read (Tag=1)
    do_write(32'h0000_1000, 4'hF, 32'hDEADBEEF, 1'b1);
    do_read(32'h0000_1000, 4'hF, rdata, rtag);
    if (rdata == 32'hDEADBEEF && rtag == 1'b1) pass_t("DIFT=1: Word Write/Read Tag=1");
    else fail_t($sformatf("DIFT=1: Expected DEADBEEF (1), got %h (%b)", rdata, rtag));

    // Edge Case 2: Standard Word Write/Read (Tag=0)
    do_write(32'h0000_1004, 4'hF, 32'hCAFEBABE, 1'b0);
    do_read(32'h0000_1004, 4'hF, rdata, rtag);
    if (rdata == 32'hCAFEBABE && rtag == 1'b0) pass_t("DIFT=1: Word Write/Read Tag=0");
    else fail_t($sformatf("DIFT=1: Expected CAFEBABE (0), got %h (%b)", rdata, rtag));

    // Edge Case 3: Byte-aligned Write (Should still write the single tag bit to the whole word)
    do_write(32'h0000_1008, 4'h1, 32'h000000FF, 1'b1);
    do_read(32'h0000_1008, 4'hF, rdata, rtag); // read back whole word
    if (rdata == 32'h000000FF && rtag == 1'b1) pass_t("DIFT=1: Byte Write Tag=1");
    else fail_t($sformatf("DIFT=1: Expected Byte Write to preserve tag (1), got %h (%b)", rdata, rtag));
    
    // Edge Case 4: Exception passthrough when enabled
    dift_exception_i = 1'b1;
    #1;
    if (dift_exception_o == 1'b1) pass_t("DIFT=1: Exception passthrough working");
    else fail_t("DIFT=1: Exception passthrough failed");
    dift_exception_i = 1'b0;

    // -------------------------------------------------------------
    // PHASE 2: DIFT ENABLED = 0
    // -------------------------------------------------------------
    $display("\n--- PHASE 2: dift_en = 0 ---");
    dift_en_i = 1'b0;

    // Edge Case 5: Write Tag=1 with DIFT=0 (Tag should be masked to 0)
    do_write(32'h0000_100C, 4'hF, 32'h12345678, 1'b1);
    do_read(32'h0000_100C, 4'hF, rdata, rtag);
    // Since we wrote with dift_en=0, core_wdata_tag_i was masked to 0. 
    // The tag memory should contain 0.
    if (rdata == 32'h12345678 && rtag == 1'b0) pass_t("DIFT=0: Write Tag=1 -> Masked to Tag=0");
    else fail_t($sformatf("DIFT=0: Expected dift_en=0 masking (rtag=0), got rtag=%b", rtag));

    // Edge Case 6: Write Tag=0 with DIFT=0 
    do_write(32'h0000_1010, 4'hF, 32'hAABBCCDD, 1'b0);
    do_read(32'h0000_1010, 4'hF, rdata, rtag);
    if (rdata == 32'hAABBCCDD && rtag == 1'b0) pass_t("DIFT=0: Write Tag=0 -> Remains Tag=0");
    else fail_t($sformatf("DIFT=0: Expected AABBCCDD (0), got %h (%b)", rdata, rtag));

    // Edge Case 7: Exception passthrough when disabled (should be masked)
    dift_exception_i = 1'b1;
    #1;
    if (dift_exception_o == 1'b0) pass_t("DIFT=0: Exception correctly masked");
    else fail_t("DIFT=0: Exception failed to mask");
    dift_exception_i = 1'b0;

    // -------------------------------------------------------------
    // PHASE 3: Instruction Bus & Protocol Delays
    // -------------------------------------------------------------
    $display("\n--- PHASE 3: Inst Bus & Delays ---");
    
    // Test Instruction fetch translation
    instr_mem[32'h1000/4] = 32'hFEEDFACE;
    do_instr_fetch(32'h0000_1000, rdata);
    if (rdata == 32'hFEEDFACE) pass_t("Instr Bus: Fetch translation successful");
    else fail_t($sformatf("Instr Bus: Expected FEEDFACE, got %h", rdata));

    // Test with simulated SRAM delays
    data_gnt_delay = 1;
    data_rvalid_delay = 2;
    dift_en_i = 1'b1;
    
    do_write(32'h0000_1014, 4'hF, 32'hDELAY_WR, 1'b1);
    do_read(32'h0000_1014, 4'hF, rdata, rtag);
    if (rdata == 32'hDELAY_WR && rtag == 1'b1) pass_t("Delay Mode: Write/Read Tag=1 works with delayed OBI memory");
    else fail_t($sformatf("Delay Mode: Expected DELAY_WR (1), got %h (%b)", rdata, rtag));

    $display("\n=================================================");
    $display(" Simulation finished: %0d PASS, %0d FAIL", pass_count, fail_count);
    $display("=================================================");
    $finish;
  end

endmodule
