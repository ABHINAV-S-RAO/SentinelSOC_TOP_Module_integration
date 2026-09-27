// Copyright 2026 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Authors:
// - Philippe Sauter <phsauter@iis.ee.ethz.ch>
//
// Checks multi-hart resume requests through the complete debug-module path
// The default test uses three harts with a non-trivial selectable-hart mask
// All variants drive both DMI DMControl and debug-memory Resuming writes

module tb_dm_top_multihart_resume #(
  parameter int unsigned NrHarts = 3,
  parameter int unsigned BusWidth = 32,
  parameter logic [NrHarts-1:0] SelectableHarts =
      (NrHarts == 3) ? 3'b101 : {NrHarts{1'b1}}
);

  localparam logic [11:0] HaltedAddr   = 12'h100;
  localparam logic [11:0] GoingAddr    = 12'h108;
  localparam logic [11:0] ResumingAddr = 12'h110;
  localparam int unsigned HartOne = (NrHarts > 1) ? 1 : 0;
  localparam int unsigned HartTwo = (NrHarts > 2) ? 2 : 0;
  localparam int unsigned LastHart = NrHarts - 1;
  localparam int unsigned HartSelLen = (NrHarts == 1) ? 1 : $clog2(NrHarts);
  localparam int unsigned InvalidDebugHart = 2**HartSelLen;
  localparam int unsigned HartsPerFlagWord = BusWidth / 8;
  localparam logic [BusWidth-1:0] InactiveUpperWdata = BusWidth'(64'hdead_beef_0000_0000);

  logic clk, rst_n;

  logic ndmreset, dmactive;

  logic        slave_req, slave_we;
  logic [BusWidth-1:0] slave_addr, slave_wdata;
  logic [BusWidth/8-1:0] slave_be;
  logic [NrHarts-1:0] unavailable_i;

  logic dmi_req_valid, dmi_req_ready;
  dm::dmi_req_t dmi_req;
  logic dmi_resp_valid;
  dm::dmi_resp_t dmi_resp;

  initial begin
    clk = 1'b0;
    forever #5ns clk = ~clk;
  end

  dm_top #(
    .NrHarts        ( NrHarts        ),
    .BusWidth       ( BusWidth       ),
    .SelectableHarts ( SelectableHarts )
  ) dut (
    .clk_i                  ( clk             ),
    .rst_ni                 ( rst_n           ),
    .next_dm_addr_i         ( '0              ),
    .testmode_i             ( 1'b0            ),
    .ndmreset_o             ( ndmreset        ),
    .ndmreset_ack_i         ( 1'b0            ),
    .dmactive_o             ( dmactive        ),
    .debug_req_o            (                 ),
    .unavailable_i          ( unavailable_i   ),
    .hartinfo_i             ( '0              ),
    .slave_req_i            ( slave_req       ),
    .slave_we_i             ( slave_we        ),
    .slave_addr_i           ( slave_addr      ),
    .slave_be_i             ( slave_be        ),
    .slave_wdata_i          ( slave_wdata     ),
    .slave_rdata_o          (                 ),
    .master_req_o           (                 ),
    .master_add_o           (                 ),
    .master_we_o            (                 ),
    .master_wdata_o         (                 ),
    .master_be_o            (                 ),
    .master_gnt_i           ( 1'b0            ),
    .master_r_valid_i       ( 1'b0            ),
    .master_r_err_i         ( 1'b0            ),
    .master_r_other_err_i   ( 1'b0            ),
    .master_r_rdata_i       ( '0              ),
    .dmi_rst_ni             ( rst_n           ),
    .dmi_req_valid_i        ( dmi_req_valid   ),
    .dmi_req_ready_o        ( dmi_req_ready   ),
    .dmi_req_i              ( dmi_req         ),
    .dmi_resp_valid_o       ( dmi_resp_valid  ),
    .dmi_resp_ready_i       ( 1'b1            ),
    .dmi_resp_o             ( dmi_resp        )
  );

  task automatic write_dmcontrol(
    input logic [19:0] hartsel,
    input logic        request_resume,
    input logic        request_ndmreset,
    input logic        request_haltreq = 1'b0,
    input logic        request_dmactive = 1'b1
  );
    dm::dmcontrol_t dmcontrol;

    dmcontrol            = '0;
    dmcontrol.hartsello  = hartsel[9:0];
    dmcontrol.hartselhi  = hartsel[19:10];
    dmcontrol.haltreq    = request_haltreq;
    dmcontrol.resumereq  = request_resume;
    dmcontrol.ndmreset   = request_ndmreset;
    dmcontrol.dmactive   = request_dmactive;
    write_dmi(8'(dm::DMControl), dmcontrol);
  endtask

  task automatic write_dmi(input logic [7:0] address, input logic [31:0] data);
    if (clk !== 1'b0) begin
      @(negedge clk);
    end
    while (!dmi_req_ready) begin
      @(negedge clk);
    end
    dmi_req.addr  = address[6:0];
    dmi_req.op    = dm::DTM_WRITE;
    dmi_req.data  = data;
    dmi_req_valid = 1'b1;
    @(posedge clk);
    if (!dmi_req_ready) begin
      $fatal(1, "DMI write was not accepted");
    end
    @(negedge clk);
    dmi_req_valid = 1'b0;
    #1ns;
    if (!dmi_resp_valid || dmi_resp.resp != dm::DTM_SUCCESS || dmi_resp.data != '0) begin
      $fatal(1, "DMI write to %02x failed (resp=%0d data=%08x)",
             address, dmi_resp.resp, dmi_resp.data);
    end
    @(posedge clk);
  endtask

  task automatic read_dmi(input logic [7:0] address, output logic [31:0] data);
    if (clk !== 1'b0) begin
      @(negedge clk);
    end
    while (!dmi_req_ready) begin
      @(negedge clk);
    end
    dmi_req.addr  = address[6:0];
    dmi_req.op    = dm::DTM_READ;
    dmi_req.data  = '0;
    dmi_req_valid = 1'b1;
    @(posedge clk);
    if (!dmi_req_ready) begin
      $fatal(1, "DMI read was not accepted");
    end
    @(negedge clk);
    dmi_req_valid = 1'b0;
    #1ns;
    if (!dmi_resp_valid || dmi_resp.resp != dm::DTM_SUCCESS) begin
      $fatal(1, "DMI read from %02x failed (resp=%0d)", address, dmi_resp.resp);
    end
    data = dmi_resp.data;
    @(posedge clk);
  endtask

  task automatic execute_access_register_command(
    input int unsigned command_hart,
    input bit          expect_resume_rejection = 1'b0
  );
    logic [BusWidth-1:0] flags_data;
    logic [31:0] abstractcs_data;
    dm::abstractcs_t abstractcs;
    dm::ac_ar_cmd_t access_register;
    dm::command_t command;
    bit command_retired;

    access_register            = '0;
    access_register.aarsize   = 3'd2;
    access_register.transfer  = 1'b1;
    access_register.regno     = 16'h1001;
    command                   = '0;
    command.cmdtype           = dm::AccessRegister;
    command.control           = access_register;
    write_dmcontrol(20'(command_hart), 1'b0, 1'b0);
    write_dmi(8'(dm::Command), command);

    read_dmi(8'(dm::AbstractCS), abstractcs_data);
    abstractcs = dm::abstractcs_t'(abstractcs_data);
    if (expect_resume_rejection) begin
      if (abstractcs.busy || abstractcs.cmderr != dm::CmdErrorHaltResume) begin
        $fatal(1, "pending resume command was not rejected (busy=%0b cmderr=%0d)",
               abstractcs.busy, abstractcs.cmderr);
      end
      read_debug_memory(12'(12'h400 + command_hart), flags_data);
      if (flags_data[(command_hart % HartsPerFlagWord) * 8 +: 2] !== 2'b10) begin
        $fatal(1, "pending resume command changed flags[%0d] (data=%08x)",
               command_hart, flags_data);
      end
      expect_resume_request(command_hart, 1'b1);
      write_dmi(8'(dm::AbstractCS), 32'h0000_0700);
      return;
    end
    if (!abstractcs.busy) begin
      $fatal(1, "access register command for hart %0d was lost while a resume was pending",
             command_hart);
    end

    // The hart observes Go before reporting that it is going
    read_debug_memory(12'(12'h400 + command_hart), flags_data);
    if (flags_data[(command_hart % HartsPerFlagWord) * 8] !== 1'b1) begin
      $fatal(1, "Go flag[%0d] was not asserted (data=%08x)", command_hart, flags_data);
    end
    write_debug_memory(GoingAddr, 0);
    read_dmi(8'(dm::AbstractCS), abstractcs_data);
    abstractcs = dm::abstractcs_t'(abstractcs_data);
    if (!abstractcs.busy) begin
      $fatal(1, "abstract command did not remain busy after Going for hart %0d", command_hart);
    end

    // The hart returns to Halted, retiring the command
    write_debug_memory(HaltedAddr, command_hart);
    command_retired = 1'b0;
    repeat (8) begin
      read_dmi(8'(dm::AbstractCS), abstractcs_data);
      abstractcs = dm::abstractcs_t'(abstractcs_data);
      if (!abstractcs.busy) begin
        command_retired = 1'b1;
        break;
      end
    end
    if (!command_retired) begin
      $fatal(1, "abstract command for hart %0d did not retire", command_hart);
    end
    if (abstractcs.cmderr != dm::CmdErrNone) begin
      $fatal(1, "abstract command for hart %0d retired with cmderr %0d",
             command_hart, abstractcs.cmderr);
    end
  endtask

  task automatic expect_dmcontrol_write_only_fields_zero;
    if (clk !== 1'b0) begin
      @(negedge clk);
    end
    dmi_req.op    = dm::DTM_READ;
    dmi_req_valid = 1'b1;
    @(posedge clk);
    if (!dmi_req_ready) begin
      $fatal(1, "DMControl read was not accepted");
    end
    @(negedge clk);
    dmi_req_valid = 1'b0;
    #1ns;
    if (!dmi_resp_valid || dmi_resp.resp != dm::DTM_SUCCESS ||
        dmi_resp.data[31:30] !== 2'b00) begin
      $fatal(1, "DMControl haltreq/resumereq are not read-zero (data=%08x)", dmi_resp.data);
    end
    dmi_req.op = dm::DTM_WRITE;
    @(posedge clk);
  endtask

  // Exercise memory-write-over-clear and ndmreset-over-clear/ack precedence
  // by accepting the DMI write and ResumingAddr write on the same clock edge
  task automatic write_dmcontrol_and_resuming(
    input logic [19:0] hartsel,
    input logic        request_resume,
    input logic        request_ndmreset,
    input int unsigned resuming_hart
  );
    dm::dmcontrol_t dmcontrol;

    dmcontrol            = '0;
    dmcontrol.hartsello  = hartsel[9:0];
    dmcontrol.hartselhi  = hartsel[19:10];
    dmcontrol.resumereq  = request_resume;
    dmcontrol.ndmreset   = request_ndmreset;
    dmcontrol.dmactive   = 1'b1;

    @(negedge clk);
    while (!dmi_req_ready) begin
      @(negedge clk);
    end
    dmi_req.addr = 7'(dm::DMControl);
    dmi_req.op    = dm::DTM_WRITE;
    dmi_req.data  = dmcontrol;
    dmi_req_valid = 1'b1;
    slave_we      = 1'b1;
    slave_req     = 1'b1;
    slave_addr    = BusWidth'(ResumingAddr);
    slave_wdata   = BusWidth'(resuming_hart);
    slave_be      = '1;
    @(posedge clk);
    @(negedge clk);
    dmi_req_valid = 1'b0;
    slave_req     = 1'b0;
    #1ns;
    if (!dmi_resp_valid || dmi_resp.resp != dm::DTM_SUCCESS || dmi_resp.data != '0) begin
      $fatal(1, "combined DMControl/ResumingAddr write failed");
    end
    @(posedge clk);
  endtask

  task automatic write_debug_memory(
    input logic [11:0]             address,
    input int unsigned             hart,
    input logic [BusWidth-1:0]     inactive_wdata = '0
  );
    @(negedge clk);
    slave_we    = 1'b1;
    slave_req   = 1'b1;
    slave_addr  = BusWidth'(address);
    slave_wdata = BusWidth'(hart) | inactive_wdata;
    slave_be      = '0;
    slave_be[3:0] = 4'hf;
    @(posedge clk);
    @(negedge clk);
    slave_req   = 1'b0;
  endtask

  task automatic read_debug_memory(input logic [11:0] address,
                                   output logic [BusWidth-1:0] data);
    @(negedge clk);
    slave_we    = 1'b0;
    slave_req   = 1'b1;
    slave_addr  = BusWidth'(address);
    slave_wdata = '0;
    slave_be    = '0;
    @(posedge clk);
    #1ns;
    data        = dut.slave_rdata_o;
    @(negedge clk);
    slave_req   = 1'b0;
    slave_we    = 1'b1;
  endtask

  task automatic expect_resume_request(input int unsigned hart, input logic expected);
    #1ns;
    if (dut.resumereq[hart] !== expected) begin
      $fatal(1, "resumereq[%0d]=%0b, expected %0b", hart, dut.resumereq[hart], expected);
    end
  endtask

  task automatic expect_resume_ack(input int unsigned hart, input logic expected);
    #1ns;
    if (dut.resumeack[hart] !== expected) begin
      $fatal(1, "resumeack[%0d]=%0b, expected %0b", hart, dut.resumeack[hart], expected);
    end
  endtask

  task automatic expect_halted(input int unsigned hart, input logic expected);
    #1ns;
    if (dut.halted[hart] !== expected) begin
      $fatal(1, "halted[%0d]=%0b, expected %0b", hart, dut.halted[hart], expected);
    end
  endtask

  task automatic expect_resume_ack_vector(input logic [NrHarts-1:0] expected);
    #1ns;
    if (dut.resumeack !== expected) begin
      $fatal(1, "resumeack=%b, expected %b", dut.resumeack, expected);
    end
  endtask

  task automatic expect_resume_flag(input int unsigned hart, input logic expected);
    logic [BusWidth-1:0] data;

    read_debug_memory(12'(12'h400 + hart), data);
    if (data[(hart % HartsPerFlagWord) * 8 + 1] !== expected) begin
      $fatal(1, "resume flag[%0d]=%0b, expected %0b (data=%08x)",
             hart, data[(hart % HartsPerFlagWord) * 8 + 1], expected, data);
    end
  endtask

  task automatic expect_halted_vector(input logic [NrHarts-1:0] expected);
    #1ns;
    if (dut.halted !== expected) begin
      $fatal(1, "halted=%b, expected %b", dut.halted, expected);
    end
  endtask

  task automatic check_invalid_debug_hart;
    logic [NrHarts-1:0] halted_before;
    logic [NrHarts-1:0] resumeack_before;
    logic [NrHarts-1:0] resumereq_before;

    // Exercise halted, acknowledged, and pending hart 0 states
    write_debug_memory(HaltedAddr, 0);
    write_debug_memory(ResumingAddr, 0);
    expect_halted(0, 1'b0);
    expect_resume_ack(0, 1'b1);
    halted_before    = dut.halted;
    resumeack_before = dut.resumeack;
    resumereq_before = dut.resumereq;
    write_debug_memory(HaltedAddr, InvalidDebugHart);
    if (dut.halted !== halted_before || dut.resumeack !== resumeack_before ||
        dut.resumereq !== resumereq_before) begin
      $fatal(1, "invalid HaltedAddr hart %0d changed valid hart state", InvalidDebugHart);
    end

    if (NrHarts == 9 && BusWidth == 64) begin
      // 64-bit ROM stores carry only the lower 32-bit hart ID
      write_debug_memory(HaltedAddr, 0, InactiveUpperWdata);
      expect_halted(0, 1'b1);
      write_debug_memory(ResumingAddr, 0, InactiveUpperWdata);
      expect_halted(0, 1'b0);
      expect_resume_ack(0, 1'b1);
    end

    write_debug_memory(HaltedAddr, 0);
    write_dmcontrol(0, 1'b1, 1'b0);
    expect_halted(0, 1'b1);
    expect_resume_ack(0, 1'b0);
    expect_resume_request(0, 1'b1);
    halted_before    = dut.halted;
    resumeack_before = dut.resumeack;
    resumereq_before = dut.resumereq;
    write_debug_memory(ResumingAddr, InvalidDebugHart);
    if (dut.halted !== halted_before || dut.resumeack !== resumeack_before ||
        dut.resumereq !== resumereq_before) begin
      $fatal(1, "invalid ResumingAddr hart %0d changed valid hart state", InvalidDebugHart);
    end

    write_debug_memory(ResumingAddr, 0);
  endtask

  initial begin
    logic [NrHarts-1:0] resumeack_before_invalid;
    logic [NrHarts-1:0] expected_resumeack_before_ndmreset;

    rst_n       = 1'b0;
    slave_req   = 1'b0;
    slave_we    = 1'b1;
    slave_addr  = '0;
    slave_wdata = '0;
    slave_be    = '0;
    unavailable_i = '0;
    dmi_req_valid = 1'b0;
    dmi_req       = '0;
    dmi_req.addr  = 7'(dm::DMControl);
    dmi_req.op    = dm::DTM_WRITE;

    repeat (3) @(posedge clk);
    rst_n = 1'b1;
    @(posedge clk);
    #1ns;

    // Activate the DM
    write_dmcontrol(0, 1'b0, 1'b0);
    if (!dmactive) begin
      $fatal(1, "debug module did not become active");
    end

    if (NrHarts == 3 || NrHarts >= 5) begin
      check_invalid_debug_hart();
    end

    if (NrHarts == 3) begin
      // Harts 0 and 2 are selectable; hart 1 is intentionally masked out to
      // exercise the non-trivial SelectableHarts parameter
      // A stale halted cache must not create a request for an unavailable hart
      write_debug_memory(HaltedAddr, HartTwo);
      write_debug_memory(ResumingAddr, HartTwo);
      write_debug_memory(HaltedAddr, HartTwo);
      unavailable_i[HartTwo] = 1'b1;
      write_dmcontrol(20'(HartTwo), 1'b1, 1'b0);
      expect_resume_request(HartTwo, 1'b0);
      expect_resume_flag(HartTwo, 1'b0);
      expect_resume_ack(HartTwo, 1'b0);
      begin
        logic [31:0] status_data;
        dm::dmstatus_t status;
        read_dmi(8'(dm::DMStatus), status_data);
        status = dm::dmstatus_t'(status_data);
        if (!status.allunavail || !status.anyunavail || status.allhalted ||
            status.anyhalted || status.allresumeack || status.anyresumeack) begin
          $fatal(1, "DMStatus did not report unavailable hart %0d correctly", HartTwo);
        end
      end
      unavailable_i[HartTwo] = 1'b0;

      // Leave hart 2's acknowledgement stale, then request hart 0
      write_debug_memory(HaltedAddr, HartTwo);
      write_debug_memory(ResumingAddr, HartTwo);
      expect_resume_ack(HartTwo, 1'b1);
      write_debug_memory(HaltedAddr, 0);
      write_debug_memory(ResumingAddr, 0);
      expect_resume_ack(0, 1'b1);
      write_debug_memory(HaltedAddr, 0);
      write_dmcontrol(0, 1'b1, 1'b0, 1'b1);
      expect_resume_request(0, 1'b0);
      expect_resume_ack(0, 1'b1);
      expect_dmcontrol_write_only_fields_zero();
      if (dut.haltreq[0] !== 1'b1) begin
        $fatal(1, "DMControl read changed the active halt request");
      end
      write_dmcontrol(0, 1'b1, 1'b0);
      expect_resume_request(0, 1'b1);
      expect_resume_ack(HartTwo, 1'b1);

      // A pending resume must reject a command for the same hart
      execute_access_register_command(0, 1'b1);

      // A pending resume for hart 0 must not block a command for hart 2
      write_debug_memory(HaltedAddr, HartTwo);
      execute_access_register_command(HartTwo);
      expect_resume_request(0, 1'b1);

      // Accept a second request without retiring the first one
      write_debug_memory(HaltedAddr, HartTwo);
      write_dmcontrol(20'(HartTwo), 1'b1, 1'b0);
      expect_resume_request(HartTwo, 1'b1);
      expect_resume_request(0, 1'b1);
      expect_resume_ack(HartTwo, 1'b0);
      // A non-requesting write changes hartsel but cannot cancel either action
      write_dmcontrol(20'(HartTwo), 1'b0, 1'b0);
      expect_dmcontrol_write_only_fields_zero();
      expect_resume_flag(0, 1'b1);
      expect_resume_flag(HartTwo, 1'b1);

      // Acknowledge the two harts independently
      write_debug_memory(ResumingAddr, HartTwo);
      expect_resume_ack(HartTwo, 1'b1);
      @(posedge clk);
      expect_resume_request(HartTwo, 1'b0);
      expect_resume_request(0, 1'b1);
      expect_resume_flag(0, 1'b1);
      write_debug_memory(ResumingAddr, 0);
      @(posedge clk);
      expect_resume_request(0, 1'b0);
      expect_resume_request(HartTwo, 1'b0);

      // A stale acknowledgement is cleared for the effective target
      write_debug_memory(HaltedAddr, 0);
      write_debug_memory(ResumingAddr, 0);
      expect_resume_ack(0, 1'b1);
      write_debug_memory(HaltedAddr, 0);
      write_dmcontrol(20'd0, 1'b1, 1'b0);
      expect_resume_request(0, 1'b1);
      expect_resume_ack(0, 1'b0);

      // A memory acknowledgement on the same edge as a new request's clear
      // must win over the clear, leaving resumeack set for completion
      write_dmcontrol_and_resuming(20'd0, 1'b1, 1'b0, 0);
      expect_resume_ack(0, 1'b1);
      expect_resume_request(0, 1'b0);

      // Raw hartsel=4 is WARL-masked to hart 0 for NrHarts=3.  A stale
      // acknowledgement must be cleared for the effective target, and the
      // resulting request must remain outstanding until a fresh acknowledgement
      write_debug_memory(HaltedAddr, 0);
      write_dmcontrol(20'd4, 1'b1, 1'b0);
      expect_resume_request(0, 1'b1);
      expect_resume_ack(0, 1'b0);
      write_debug_memory(ResumingAddr, 0);
      @(posedge clk);
      expect_resume_request(0, 1'b0);

      // Raw hartsel=3 is effective-invalid for NrHarts=3.  It must neither
      // clear an acknowledgement nor create a request for any valid hart
      expect_resume_ack(HartTwo, 1'b1);
      resumeack_before_invalid = dut.resumeack;
      write_dmcontrol(20'd3, 1'b1, 1'b0);
      if (dut.resumeack !== resumeack_before_invalid || dut.resumereq !== '0) begin
        $fatal(1, "invalid hartsel changed per-hart resume state");
      end
      // Recover from the invalid selection with a valid, non-requesting write
      write_dmcontrol(0, 1'b0, 1'b0);
      if (dut.resumereq !== '0 || dut.resumeack !== resumeack_before_invalid) begin
        $fatal(1, "invalid hartsel recovery changed resume state");
      end

      // Hart 1 is masked out, so its request and acknowledgement are ignored
      write_debug_memory(HaltedAddr, HartOne);
      write_dmcontrol(20'(HartOne), 1'b1, 1'b0);
      expect_resume_request(HartOne, 1'b0);
      expect_resume_ack(0, 1'b1);
      write_debug_memory(ResumingAddr, HartOne);
      expect_resume_ack(HartOne, 1'b0);
      expect_resume_ack(0, 1'b1);

      // Deactivating the debug module clears acknowledgements and pending actions
      expect_resume_ack(0, 1'b1);
      write_debug_memory(HaltedAddr, HartTwo);
      write_dmcontrol(20'(HartTwo), 1'b1, 1'b0);
      expect_resume_request(HartTwo, 1'b1);
      write_dmcontrol(20'(HartTwo), 1'b0, 1'b0, 1'b0, 1'b0);
      if (dmactive || dut.resumereq !== '0) begin
        $fatal(1, "DM deactivation retained resume state");
      end
      expect_resume_flag(HartTwo, 1'b0);
      expect_resume_ack(0, 1'b0);
      expect_resume_ack(HartTwo, 1'b0);
      write_dmcontrol(0, 1'b0, 1'b0);
      if (!dmactive) begin
        $fatal(1, "debug module did not reactivate");
      end

      // Keep an unavailable request outstanding across ndmreset
      write_debug_memory(HaltedAddr, 0);
      write_debug_memory(ResumingAddr, 0);
      expect_resume_ack(0, 1'b1);
      write_debug_memory(HaltedAddr, HartTwo);
      write_dmcontrol(20'(HartTwo), 1'b1, 1'b0);
      expect_resume_request(HartTwo, 1'b1);
      unavailable_i[HartTwo] = 1'b1;
      write_dmcontrol(20'(HartTwo), 1'b0, 1'b1);
      @(posedge clk);
      #1ns;
      if (!ndmreset) begin
        $fatal(1, "ndmreset did not assert");
      end
      expect_halted(HartTwo, 1'b0);
      expect_resume_ack(0, 1'b1);
      expect_resume_ack(HartTwo, 1'b0);
      expect_resume_request(HartTwo, 1'b1);

      // The unavailable request remains pending after reset while another hart
      // executes an access register command
      write_dmcontrol(20'(HartTwo), 1'b0, 1'b0);
      if (ndmreset) begin
        $fatal(1, "ndmreset did not deassert");
      end
      begin
        logic [31:0] abstractcs_data;
        dm::abstractcs_t abstractcs;
        read_dmi(8'(dm::AbstractCS), abstractcs_data);
        abstractcs = dm::abstractcs_t'(abstractcs_data);
        if (abstractcs.busy) begin
          $fatal(1, "ndmreset left AbstractCS busy for a pending resume");
        end
      end
      write_debug_memory(HaltedAddr, 0);
      execute_access_register_command(0);
      unavailable_i[HartTwo] = 1'b0;
      expect_resume_request(HartTwo, 1'b1);
    end else if (NrHarts == 1) begin
      // The singleton case still exercises stale-ack clearing and normal
      // request completion before checking ndmreset acknowledgement retention
      write_debug_memory(HaltedAddr, 0);
      write_debug_memory(ResumingAddr, 0);
      expect_resume_ack(0, 1'b1);
      write_debug_memory(HaltedAddr, 0);
      write_dmcontrol(0, 1'b1, 1'b0);
      expect_resume_ack(0, 1'b0);
      expect_resume_request(0, 1'b1);
      write_debug_memory(ResumingAddr, 0);
      expect_resume_ack(0, 1'b1);
      @(posedge clk);
      expect_resume_request(0, 1'b0);

      write_debug_memory(HaltedAddr, 0);
      write_debug_memory(ResumingAddr, 0);
      write_debug_memory(HaltedAddr, 0);
      expect_halted_vector('1);
      expect_resume_ack_vector('1);
      write_dmcontrol(0, 1'b0, 1'b1);
      @(posedge clk);
      #1ns;
      if (!ndmreset) begin
        $fatal(1, "singleton ndmreset did not assert");
      end
      expect_halted_vector('0);
      expect_resume_ack_vector('1);
      write_dmcontrol(0, 1'b0, 1'b0);
      if (ndmreset) begin
        $fatal(1, "singleton ndmreset did not deassert");
      end
      expect_halted_vector('0);
      expect_resume_ack_vector('1);
    end else if (NrHarts == 4) begin
      // Power-of-two hart selection must preserve an unrelated stale
      // acknowledgement and support same-edge clear/ack traffic
      write_debug_memory(HaltedAddr, 0);
      write_debug_memory(HaltedAddr, LastHart);
      write_debug_memory(ResumingAddr, 0);
      write_debug_memory(ResumingAddr, LastHart);
      expect_resume_ack(0, 1'b1);
      expect_resume_ack(LastHart, 1'b1);

      write_debug_memory(HaltedAddr, 0);
      write_dmcontrol(0, 1'b1, 1'b0);
      expect_resume_request(0, 1'b1);
      expect_resume_ack(0, 1'b0);
      expect_resume_ack(LastHart, 1'b1);

      write_debug_memory(ResumingAddr, 0);
      expect_resume_ack(0, 1'b1);
      @(posedge clk);
      expect_resume_request(0, 1'b0);
      write_debug_memory(HaltedAddr, 0);
      write_debug_memory(HaltedAddr, LastHart);
      write_dmcontrol(20'(LastHart), 1'b1, 1'b0);
      expect_resume_request(LastHart, 1'b1);
      expect_resume_ack(LastHart, 1'b0);
      expect_resume_ack(0, 1'b1);

      // Clear hart 0 while acknowledging hart 3 on the same edge.  The
      // cross-hart effects must remain independent
      write_dmcontrol_and_resuming(20'd0, 1'b1, 1'b0, LastHart);
      expect_resume_ack(0, 1'b0);
      expect_resume_ack(LastHart, 1'b1);
      expect_resume_request(0, 1'b1);
      write_debug_memory(ResumingAddr, 0);
      expect_resume_ack(0, 1'b1);
      @(posedge clk);
      expect_resume_request(0, 1'b0);

      // Set every halted bit so ndmreset clears the halted cache only
      write_debug_memory(HaltedAddr, 0);
      write_debug_memory(HaltedAddr, 1);
      write_debug_memory(HaltedAddr, 2);
      write_debug_memory(HaltedAddr, LastHart);
      expect_halted_vector('1);
      expected_resumeack_before_ndmreset = '0;
      expected_resumeack_before_ndmreset[0] = 1'b1;
      expected_resumeack_before_ndmreset[LastHart] = 1'b1;
      expect_resume_ack_vector(expected_resumeack_before_ndmreset);
      write_dmcontrol(0, 1'b0, 1'b1);
      @(posedge clk);
      #1ns;
      if (!ndmreset) begin
        $fatal(1, "four-hart ndmreset did not assert");
      end
      expect_halted_vector('0);
      expect_resume_ack_vector(expected_resumeack_before_ndmreset);
      write_dmcontrol(0, 1'b0, 1'b0);
      if (ndmreset) begin
        $fatal(1, "four-hart ndmreset did not deassert");
      end
      expect_halted_vector('0);
      expect_resume_ack_vector(expected_resumeack_before_ndmreset);
    end else if (NrHarts >= 5) begin
      // Exercise the same per-hart behavior at non-power-of-two and wide-bus
      // configurations, targeting the highest implemented hart
      write_debug_memory(HaltedAddr, LastHart);
      write_debug_memory(ResumingAddr, LastHart);
      write_debug_memory(HaltedAddr, LastHart);
      unavailable_i[LastHart] = 1'b1;
      write_dmcontrol(20'(LastHart), 1'b1, 1'b0);
      expect_resume_request(LastHart, 1'b0);
      expect_resume_flag(LastHart, 1'b0);
      expect_resume_ack(LastHart, 1'b0);
      begin
        logic [31:0] status_data;
        dm::dmstatus_t status;
        read_dmi(8'(dm::DMStatus), status_data);
        status = dm::dmstatus_t'(status_data);
        if (!status.allunavail || !status.anyunavail || status.allhalted ||
            status.anyhalted || status.allresumeack || status.anyresumeack) begin
          $fatal(1, "DMStatus did not report unavailable hart %0d correctly", LastHart);
        end
      end
      unavailable_i[LastHart] = 1'b0;

      write_debug_memory(HaltedAddr, 0);
      write_dmcontrol(0, 1'b1, 1'b0);
      write_debug_memory(HaltedAddr, LastHart);
      execute_access_register_command(LastHart);
      expect_resume_request(0, 1'b1);
      write_debug_memory(ResumingAddr, 0);
      @(posedge clk);
      expect_resume_request(0, 1'b0);
      expect_resume_ack(0, 1'b1);

      write_debug_memory(HaltedAddr, LastHart);
      write_dmcontrol(20'(LastHart), 1'b1, 1'b0);
      expect_resume_flag(LastHart, 1'b1);
      unavailable_i[LastHart] = 1'b1;
      write_dmcontrol(20'(LastHart), 1'b0, 1'b1);
      @(posedge clk);
      expect_resume_flag(LastHart, 1'b0);
      expect_resume_ack(0, 1'b1);
      write_dmcontrol(20'(LastHart), 1'b0, 1'b0);
      begin
        logic [31:0] abstractcs_data;
        dm::abstractcs_t abstractcs;
        read_dmi(8'(dm::AbstractCS), abstractcs_data);
        abstractcs = dm::abstractcs_t'(abstractcs_data);
        if (abstractcs.busy) begin
          $fatal(1, "ndmreset left AbstractCS busy for hart %0d resume", LastHart);
        end
      end
      write_debug_memory(HaltedAddr, 0);
      execute_access_register_command(0);
      expect_resume_flag(LastHart, 1'b1);
      expect_resume_request(LastHart, 1'b1);
      unavailable_i[LastHart] = 1'b0;
    end else begin
      $fatal(1, "unsupported NrHarts=%0d", NrHarts);
    end

    $display("tb_dm_top_multihart_resume: passed");
    $finish;
  end

  initial begin
    #5us;
    $fatal(1, "tb_dm_top_multihart_resume: timeout");
  end

endmodule
