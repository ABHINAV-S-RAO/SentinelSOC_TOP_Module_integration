// =============================================================================
// dbg_tb_top.sv -- self-checking core+DIFT+riscv-dbg debugger testbench
// =============================================================================
// Flow: JTAG TAP reset -> activate DM -> halt hart -> abstract-command write
// GPR x1 -> abstract-command read GPR x1, check round-trip -> resume hart,
// check dmstatus.allrunning. Reports PASS/FAIL and $finish's.
//
// Scope: core (Ibex+DIFT) + riscv-dbg only. UART/QSPI/PLIC/crypto ports are
// tied to safe idle values -- basic_soc_top instantiates them internally so
// they must compile, but nothing here exercises them.
// =============================================================================
`timescale 1ns/1ps

module dbg_tb_top;
  import dm::*;

  // ---------------------------------------------------------------------
  // Clock / Reset
  // ---------------------------------------------------------------------
  localparam time CLK_PERIOD = 10ns;   // 100 MHz system clock

  logic clk_i;
  logic rst_ni;

  initial clk_i = 1'b0;
  always #(CLK_PERIOD/2) clk_i = ~clk_i;

  initial begin
    rst_ni = 1'b0;
    repeat (10) @(posedge clk_i);
    rst_ni = 1'b1;
  end

  // ---------------------------------------------------------------------
  // JTAG driver (TCK well below sys clk freq, per riscv-dbg's own README
  // guidance -- 3x the system clock period here)
  // ---------------------------------------------------------------------
  logic jtag_tck, jtag_tms, jtag_trst_n, jtag_tdi, jtag_tdo;

  jtag_if #(
    .TCK_HALF_PERIOD ( CLK_PERIOD * 3 )
  ) u_jtag (
    .tck_o   ( jtag_tck    ),
    .tms_o   ( jtag_tms    ),
    .trst_no ( jtag_trst_n ),
    .tdi_o   ( jtag_tdi    ),
    .tdo_i   ( jtag_tdo    )
  );

  // ---------------------------------------------------------------------
  // DUT-facing signals
  // ---------------------------------------------------------------------
  logic        bootrom_req, bootrom_gnt, bootrom_rvalid, bootrom_we, bootrom_err;
  logic [3:0]  bootrom_be;
  logic [31:0] bootrom_addr, bootrom_wdata, bootrom_rdata;

  logic        isram_req, isram_gnt, isram_rvalid, isram_we, isram_err;
  logic [3:0]  isram_be;
  logic [31:0] isram_addr, isram_wdata, isram_rdata;

  logic        data_req, data_gnt, data_rvalid, data_we, data_err;
  logic [3:0]  data_be;
  logic [31:0] data_addr, data_wdata, data_rdata;

  logic crypto_verified;
  assign crypto_verified = 1'b1;   // CSR-gating not under test here, keep it out of the way

  logic uart_tx, uart_rx;
  assign uart_rx = 1'b1;           // idle (UART not under test)

  logic        spi_clk;
  logic [3:0]  spi_csn;
  logic [1:0]  spi_mode;
  logic [3:0]  spi_sdo, spi_sdi;
  assign spi_sdi = 4'h0;           // QSPI not under test, safe tie

`ifdef DIFT
  logic dift_en;
  assign dift_en = 1'b1;
`endif

  // ---------------------------------------------------------------------
  // DUT
  // ---------------------------------------------------------------------
  basic_soc_top u_dut (
    .clk_i              ( clk_i ),
    .rst_ni             ( rst_ni ),
    .crypto_verified_i  ( crypto_verified ),
    .uart_tx_o          ( uart_tx ),
    .uart_rx_i          ( uart_rx ),
`ifdef DIFT
    .dift_en_i          ( dift_en ),
`endif
    .bootrom_req_o      ( bootrom_req ),
    .bootrom_gnt_i      ( bootrom_gnt ),
    .bootrom_rvalid_i   ( bootrom_rvalid ),
    .bootrom_addr_o     ( bootrom_addr ),
    .bootrom_we_o       ( bootrom_we ),
    .bootrom_be_o       ( bootrom_be ),
    .bootrom_wdata_o    ( bootrom_wdata ),
    .bootrom_rdata_i    ( bootrom_rdata ),
    .bootrom_err_i      ( bootrom_err ),

    .isram_req_o        ( isram_req ),
    .isram_gnt_i        ( isram_gnt ),
    .isram_rvalid_i     ( isram_rvalid ),
    .isram_addr_o       ( isram_addr ),
    .isram_we_o         ( isram_we ),
    .isram_be_o         ( isram_be ),
    .isram_wdata_o      ( isram_wdata ),
    .isram_rdata_i      ( isram_rdata ),
    .isram_err_i        ( isram_err ),

    .spi_clk_o          ( spi_clk ),
    .spi_csn_o          ( spi_csn ),
    .spi_mode_o         ( spi_mode ),
    .spi_sdo_o          ( spi_sdo ),
    .spi_sdi_i          ( spi_sdi ),

    .data_req_o         ( data_req ),
    .data_gnt_i         ( data_gnt ),
    .data_rvalid_i      ( data_rvalid ),
    .data_addr_o        ( data_addr ),
    .data_we_o          ( data_we ),
    .data_be_o          ( data_be ),
    .data_wdata_o       ( data_wdata ),
    .data_rdata_i       ( data_rdata ),
    .data_err_i         ( data_err ),

    .jtag_tck_i         ( jtag_tck ),
    .jtag_tms_i         ( jtag_tms ),
    .jtag_trst_ni       ( jtag_trst_n ),
    .jtag_tdi_i         ( jtag_tdi ),
    .jtag_tdo_o         ( jtag_tdo )
  );

  // ---------------------------------------------------------------------
  // Memory models
  // ---------------------------------------------------------------------
  simple_obi_mem_model #(
    .SIZE_WORDS ( 1024 ),
    .READ_ONLY  ( 1'b1 )
  ) u_bootrom (
    .clk_i ( clk_i ), .rst_ni ( rst_ni ),
    .req_i ( bootrom_req ), .gnt_o ( bootrom_gnt ), .rvalid_o ( bootrom_rvalid ),
    .addr_i ( bootrom_addr ), .we_i ( bootrom_we ), .be_i ( bootrom_be ),
    .wdata_i ( bootrom_wdata ), .rdata_o ( bootrom_rdata ), .err_o ( bootrom_err )
  );

  simple_obi_mem_model #(
    .SIZE_WORDS ( 1024 )
  ) u_isram (
    .clk_i ( clk_i ), .rst_ni ( rst_ni ),
    .req_i ( isram_req ), .gnt_o ( isram_gnt ), .rvalid_o ( isram_rvalid ),
    .addr_i ( isram_addr ), .we_i ( isram_we ), .be_i ( isram_be ),
    .wdata_i ( isram_wdata ), .rdata_o ( isram_rdata ), .err_o ( isram_err )
  );

  // NOTE: basic_soc_top's internal DIFT tag SRAM only covers the first
  // DSRAM_SIZE_WORDS=1024 words (localparam fixed inside basic_soc_top).
  // Sized larger here (4096) for headroom; only the bottom 4KB gets DIFT
  // tag tracking. Not a blocker for this test (no DIFT-tag checks here).
  simple_obi_mem_model #(
    .SIZE_WORDS ( 4096 )
  ) u_dsram (
    .clk_i ( clk_i ), .rst_ni ( rst_ni ),
    .req_i ( data_req ), .gnt_o ( data_gnt ), .rvalid_o ( data_rvalid ),
    .addr_i ( data_addr ), .we_i ( data_we ), .be_i ( data_be ),
    .wdata_i ( data_wdata ), .rdata_o ( data_rdata ), .err_o ( data_err )
  );

  // ---------------------------------------------------------------------
  // Waveform dump + DM-handshake probe log
  // ---------------------------------------------------------------------
  initial begin
    $dumpfile("dbg_tb_top.vcd");
    $dumpvars(0, dbg_tb_top);
  end

  // Top-level-port-only probes (safe against basic_soc_top's internal
  // hierarchy, which has conditional lockstep generate blocks that would
  // make a deeper hierarchical path into ibex_core fragile to hardcode).
  logic dbg_req_core_q, ndmreset_q, dmactive_q;
  always @(posedge clk_i) begin
    dbg_req_core_q <= u_dut.dbg_req_core;
    ndmreset_q     <= u_dut.ndmreset;
    dmactive_q     <= u_dut.dmactive;
    if (u_dut.dbg_req_core !== dbg_req_core_q ||
        u_dut.ndmreset     !== ndmreset_q     ||
        u_dut.dmactive     !== dmactive_q) begin
      $display("[%0t] PROBE debug_req_core=%0b ndmreset=%0b dmactive=%0b",
                $time, u_dut.dbg_req_core, u_dut.ndmreset, u_dut.dmactive);
    end
  end

  // If you want core PC visibility too, confirm the exact instance path in
  // YOUR ibex_top (it differs depending on whether the lockstep generate
  // block is enabled) and uncomment/adjust, e.g.:
  // always @(posedge clk_i) if (u_dut.u_ibex_top.u_ibex_core.instr_valid_id)
  //   $display("[%0t] PROBE pc_id=%08h", $time, u_dut.u_ibex_top.u_ibex_core.pc_id_o);

  // ---------------------------------------------------------------------
  // Self-checking test sequence
  // ---------------------------------------------------------------------
  int          errors;
  logic [31:0] rdata;
  logic [31:0] dmstatus_val;

  initial begin
    errors = 0;
    u_jtag.idle_drive();
    wait (rst_ni == 1'b1);
    repeat (5) @(posedge clk_i);

    // --- [1] JTAG TAP reset + activate DM ------------------------------
    $display("=== [1] JTAG TAP reset + activate DM ===");
    u_jtag.tap_reset();
    u_jtag.shift_ir(u_jtag.IR_DMI);
    u_jtag.dm_activate();

    u_jtag.dmi_read(dm::DMControl, rdata);
    if (rdata[0] !== 1'b1) begin
      $error("[FAIL] dmactive did not read back 1 (dmcontrol=%08h)", rdata);
      errors++;
    end else begin
      $display("[PASS] DM active (dmcontrol=%08h)", rdata);
    end

    // --- [2] Halt the hart ----------------------------------------------
    $display("=== [2] Halt the hart ===");
    u_jtag.dmi_write(dm::DMControl, 32'h8000_0001);   // haltreq=1, dmactive=1

    fork
      begin : halt_poll
        dmstatus_val = 32'h0;
        while (!dmstatus_val[9]) begin   // allhalted
          u_jtag.dmi_read(dm::DMStatus, dmstatus_val);
          if (!dmstatus_val[9]) repeat (50) @(posedge clk_i);
        end
      end
      begin : halt_timeout
        repeat (20000) @(posedge clk_i);
        $error("[FAIL] Timed out waiting for dmstatus.allhalted");
        errors++;
      end
    join_any
    disable fork;
    if (dmstatus_val[9]) $display("[PASS] Hart halted (dmstatus=%08h)", dmstatus_val);

    u_jtag.dmi_write(dm::DMControl, 32'h0000_0001);   // clear haltreq, keep dmactive

    // --- [3] Abstract command: write GPR x1 = 0xCAFEF00D -----------------
    $display("=== [3] Abstract command: write x1 = CAFEF00D ===");
    u_jtag.dmi_write(dm::Data0, 32'hCAFE_F00D);
    // command_t: cmdtype[31:24]=AccessRegister(0), control[23:0]=
    //   {zero1(1b), aarsize=3'd2 (32-bit), aarpostincrement(1b)=0,
    //    postexec(1b)=0, transfer(1b)=1, write(1b)=1, regno[15:0]=0x1001 (x1)}
    u_jtag.dmi_write(dm::Command, {8'h00, 1'b0, 3'd2, 1'b0, 1'b0, 1'b1, 1'b1, 16'h1001});
    u_jtag.wait_abstract_cmd_done(errors);

    // --- [4] Abstract command: read back GPR x1 ---------------------------
    $display("=== [4] Abstract command: read back x1 ===");
    u_jtag.dmi_write(dm::Command, {8'h00, 1'b0, 3'd2, 1'b0, 1'b0, 1'b1, 1'b0, 16'h1001});
    u_jtag.wait_abstract_cmd_done(errors);
    u_jtag.dmi_read(dm::Data0, rdata);
    if (rdata !== 32'hCAFE_F00D) begin
      $error("[FAIL] x1 read-back mismatch: expected CAFEF00D, got %08h", rdata);
      errors++;
    end else begin
      $display("[PASS] x1 read back correctly: %08h", rdata);
    end

    // --- [5] Resume the hart ----------------------------------------------
    $display("=== [5] Resume the hart ===");
    u_jtag.dmi_write(dm::DMControl, 32'h4000_0001);   // resumereq=1, dmactive=1

    fork
      begin : resume_poll
        dmstatus_val = 32'h0;
        while (!dmstatus_val[11]) begin   // allrunning
          u_jtag.dmi_read(dm::DMStatus, dmstatus_val);
          if (!dmstatus_val[11]) repeat (50) @(posedge clk_i);
        end
      end
      begin : resume_timeout
        repeat (20000) @(posedge clk_i);
        $error("[FAIL] Timed out waiting for dmstatus.allrunning");
        errors++;
      end
    join_any
    disable fork;
    if (dmstatus_val[11]) $display("[PASS] Hart resumed (dmstatus=%08h)", dmstatus_val);

    repeat (200) @(posedge clk_i);

    $display("=====================================================");
    if (errors == 0) $display("TEST PASSED -- core+DIFT+riscv-dbg debug session OK");
    else              $display("TEST FAILED -- %0d error(s)", errors);
    $display("=====================================================");
    $finish;
  end

  // Global watchdog -- catches a hung simulation (e.g. dmstatus never
  // updating because of a wiring mistake) instead of running forever.
  initial begin
    #2ms;
    $error("[FAIL] Global watchdog timeout -- simulation hung");
    $finish;
  end

endmodule : dbg_tb_top
