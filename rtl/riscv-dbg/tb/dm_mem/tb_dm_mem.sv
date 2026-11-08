// Copyright 2026 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Authors:
// - Philippe Sauter <phsauter@iis.ee.ethz.ch>
//
// Checks Access Register command acceptance and instruction generation for independent bus and
// register widths. It also verifies the two-word debug-memory mapping used for 64-bit accesses on
// a 32-bit bus without modeling a processor core.

module tb_dm_mem #(
  parameter int unsigned BusWidth               = 32,
  parameter int unsigned MaxRegisterAccessWidth = BusWidth,
  parameter int unsigned HartSel                = 0,
  parameter int unsigned AarSize                = 2,
  parameter bit          ExpectSupported        = 1'b1
);

  localparam int unsigned NrHarts = 2;

  localparam logic [11:0] HaltedAddr      = 12'h100;
  localparam logic [11:0] AbstractCmdAddr = dm::DataAddr - 4 * dm::ProgBufSize - 4 * 10 + 16;
  localparam logic [11:0] DataEndAddr     = dm::DataAddr + 4 * dm::DataCount - 1;

  logic                             clk, rst_n;
  logic                             req, we;
  logic [BusWidth-1:0]              addr, wdata, rdata;
  logic [BusWidth/8-1:0]            be;
  logic [NrHarts-1:0]               halted;
  logic [dm::ProgBufSize-1:0][31:0] progbuf;
  logic [dm::DataCount-1:0][31:0]   data_in, data_out;
  logic                             data_valid, cmd_valid, write_register, cmderror_valid;
  dm::command_t                     command;
  dm::ac_ar_cmd_t                   access_register;
  dm::cmderr_e                      cmderror;

  initial begin
    clk = 1'b0;
    forever #5ns clk = ~clk;
  end

  initial begin
    rst_n = 1'b0;
    repeat (3) @(posedge clk);
    rst_n = 1'b1;
  end

  always_comb begin
    access_register                  = '0;
    access_register.aarsize          = 3'(AarSize);
    access_register.transfer         = 1'b1;
    access_register.write            = write_register;
    access_register.regno            = 16'h1001;
    command                          = '0;
    command.cmdtype                  = dm::AccessRegister;
    command.control                  = access_register;
  end

  dm_mem #(
    .NrHarts                ( NrHarts                ),
    .BusWidth               ( BusWidth               ),
    .MaxRegisterAccessWidth ( MaxRegisterAccessWidth )
  ) i_dm_mem (
    .clk_i                ( clk                    ),
    .rst_ni               ( rst_n                  ),
    .dmactive_i           ( 1'b1                   ),
    .debug_req_o          (                        ),
    .ndmreset_i           ( 1'b0                   ),
    .hartsel_i            ( 20'(HartSel)            ),
    .haltreq_i            ( '0                     ),
    .resumereq_i          ( '0                     ),
    .clear_resumeack_i    ( '0                     ),
    .halted_o             ( halted                 ),
    .resuming_o           (                        ),
    .progbuf_i            ( progbuf                ),
    .data_i               ( data_in                ),
    .data_o               ( data_out               ),
    .data_valid_o         ( data_valid             ),
    .cmd_valid_i          ( cmd_valid              ),
    .cmd_i                ( command                ),
    .cmderror_valid_o     ( cmderror_valid         ),
    .cmderror_o           ( cmderror               ),
    .cmdbusy_o            (                        ),
    .req_i                ( req                    ),
    .we_i                 ( we                     ),
    .addr_i               ( addr                   ),
    .wdata_i              ( wdata                  ),
    .be_i                 ( be                     ),
    .rdata_o              ( rdata                  )
  );

  task automatic start_debug_memory_access(
    input bit                  write,
    input logic [11:0]         access_addr,
    input logic [BusWidth-1:0] write_data
  );
    req   = 1'b1;
    we    = write;
    addr  = BusWidth'(access_addr);
    wdata = write_data;
    be    = write ? '1 : '0;
  endtask

  task automatic finish_debug_memory_access;
    req   = 1'b0;
    we    = 1'b0;
    addr  = '0;
    wdata = '0;
    be    = '0;
  endtask

  task automatic write_debug_memory(
    input logic [11:0]         write_addr,
    input logic [BusWidth-1:0] write_data
  );
    bit writes_data_register;

    writes_data_register = write_addr inside {[dm::DataAddr:DataEndAddr]};
    @(negedge clk);
    start_debug_memory_access(1'b1, write_addr, write_data);
    #1ns;
    if (data_valid !== writes_data_register) begin
      $fatal(1, "write to %03x produced data_valid=%0b, expected %0b",
             write_addr, data_valid, writes_data_register);
    end
    if (writes_data_register) begin
      // Model the CSR storage driven by data_o/data_valid_o in the full debug module.
      data_in = data_out;
    end
    @(negedge clk);
    finish_debug_memory_access();
    #1ns;
    if (data_valid) begin
      $fatal(1, "data_valid remained asserted after write to %03x", write_addr);
    end
  endtask

  task automatic read_debug_memory(
    input  logic [11:0]         read_addr,
    output logic [BusWidth-1:0] read_data
  );
    @(negedge clk);
    start_debug_memory_access(1'b0, read_addr, '0);
    @(negedge clk);
    #1ns;
    read_data = rdata;
    finish_debug_memory_access();
  endtask

  task automatic check_access_register(input bit write_register_value);
    logic [BusWidth-1:0] read_data;
    logic [31:0]         expected_instruction;

    write_register = write_register_value;
    cmd_valid      = 1'b1;
    #1ns;
    if (ExpectSupported) begin
      if (cmderror_valid) begin
        $fatal(1, "aarsize %0d write=%0b unexpectedly rejected with cmderr %0d",
               AarSize, write_register_value, cmderror);
      end
    end else begin
      if (!cmderror_valid || cmderror != dm::CmdErrNotSupported) begin
        $fatal(1, "aarsize %0d write=%0b was not rejected as unsupported",
               AarSize, write_register_value);
      end
    end
    cmd_valid = 1'b0;

    if (!ExpectSupported) begin
      return;
    end

    read_debug_memory(AbstractCmdAddr, read_data);
    expected_instruction = write_register_value ?
        dm::load(3'(AarSize), 5'd1, 5'd0, dm::DataAddr) :
        dm::store(3'(AarSize), 5'd1, 5'd0, dm::DataAddr);
    if (read_data[31:0] !== expected_instruction) begin
      $fatal(1, "generated instruction %08x does not match expected %08x for write=%0b",
             read_data[31:0], expected_instruction, write_register_value);
    end
  endtask

  task automatic check_64_over_32_data_mapping;
    logic [BusWidth-1:0] read_data;
    localparam logic [31:0] StoreLowWord  = 32'h0123_4567;
    localparam logic [31:0] StoreHighWord = 32'h89ab_cdef;
    localparam logic [31:0] LoadLowWord   = 32'h7654_3210;
    localparam logic [31:0] LoadHighWord  = 32'hfedc_ba98;

    if (BusWidth != 32 || MaxRegisterAccessWidth != 64 || AarSize != 3 || !ExpectSupported) begin
      return;
    end

    data_in = '0;
    write_debug_memory(dm::DataAddr, BusWidth'(StoreLowWord));
    write_debug_memory(dm::DataAddr + 4, BusWidth'(StoreHighWord));
    if (data_in[0] !== StoreLowWord || data_in[1] !== StoreHighWord) begin
      $fatal(1, "64-bit store mapping is %08x_%08x, expected %08x_%08x",
             data_in[1], data_in[0], StoreHighWord, StoreLowWord);
    end

    data_in[0] = LoadLowWord;
    data_in[1] = LoadHighWord;
    read_debug_memory(dm::DataAddr, read_data);
    if (read_data[31:0] !== LoadLowWord) begin
      $fatal(1, "data0 read returned %08x, expected %08x", read_data[31:0], LoadLowWord);
    end
    read_debug_memory(dm::DataAddr + 4, read_data);
    if (read_data[31:0] !== LoadHighWord) begin
      $fatal(1, "data1 read returned %08x, expected %08x", read_data[31:0], LoadHighWord);
    end
  endtask

  initial begin
    finish_debug_memory_access();
    progbuf        = '0;
    data_in        = '0;
    cmd_valid      = 1'b0;
    write_register = 1'b0;

    @(posedge rst_n);

    // Mark the selected hart halted through the architected debug-memory handshake.
    write_debug_memory(HaltedAddr, BusWidth'(HartSel));

    if (!halted[HartSel]) begin
      $fatal(1, "failed to halt hart %0d", HartSel);
    end

    check_access_register(1'b0);
    check_access_register(1'b1);
    check_64_over_32_data_mapping();

    $display("tb_dm_mem: BusWidth=%0d MaxRegisterAccessWidth=%0d HartSel=%0d AarSize=%0d passed",
             BusWidth, MaxRegisterAccessWidth, HartSel, AarSize);
    $finish;
  end

  initial begin
    #2us;
    $fatal(1, "tb_dm_mem: timeout");
  end

endmodule
