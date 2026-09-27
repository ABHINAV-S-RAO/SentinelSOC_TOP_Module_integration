// =============================================================================
// dbg_tb_top.sv -- self-checking core+DIFT+riscv-dbg debugger testbench
// =============================================================================
`timescale 1ns/1ps

module dbg_tb_top;
  import dm::*;

  // -------------------------------------------------------------------------
  // Clock / Reset
  // -------------------------------------------------------------------------
  localparam time CLK_PERIOD = 10ns;  // 100 MHz

  logic clk_i;
  logic rst_ni;

  initial clk_i = 1'b0;
  always #(CLK_PERIOD/2) clk_i = ~clk_i;

  initial begin
    rst_ni = 1'b0;
    repeat (10) @(posedge clk_i);
    rst_ni = 1'b1;
  end

  // -------------------------------------------------------------------------
  // JTAG interface instance -- interface, NOT a module, so no port map.
  // Signals are accessed via hierarchical reference u_jtag.tck etc.
  // -------------------------------------------------------------------------
  jtag_if u_jtag();

  // Set TCK half-period slower than sys clk so dmi_cdc has time to settle.
  initial u_jtag.tck_half_period = CLK_PERIOD * 3;  // 30 ns -> ~16 MHz JTAG

  // Wire interface signals to DUT port names
  wire jtag_tck    = u_jtag.tck;
  wire jtag_tms    = u_jtag.tms;
  wire jtag_trst_n = u_jtag.trst_n;
  wire jtag_tdi    = u_jtag.tdi;

  // TDO goes the other way: DUT output drives into the interface
  wire jtag_tdo_dut;
  assign u_jtag.tdo = jtag_tdo_dut;

  // -------------------------------------------------------------------------
  // DUT-facing memory signals
  // -------------------------------------------------------------------------
  logic        bootrom_req, bootrom_gnt, bootrom_rvalid, bootrom_we, bootrom_err;
  logic [3:0]  bootrom_be;
  logic [31:0] bootrom_addr, bootrom_wdata, bootrom_rdata;

  logic        isram_req, isram_gnt, isram_rvalid, isram_we, isram_err;
  logic [3:0]  isram_be;
  logic [31:0] isram_addr, isram_wdata, isram_rdata;

  logic        data_req, data_gnt, data_rvalid, data_we, data_err;
  logic [3:0]  data_be;
  logic [31:0] data_addr, data_wdata, data_rdata;

  // Peripheral ties (not under test)
  logic        uart_tx;
  logic        spi_clk;
  logic [3:0]  spi_csn;
  logic [1:0]  spi_mode;
  logic [3:0]  spi_sdo;

`ifdef DIFT
  logic dift_en;
  assign dift_en = 1'b1;
`endif

  // -------------------------------------------------------------------------
  // DUT
  // -------------------------------------------------------------------------
  basic_soc_top u_dut (
    .clk_i             ( clk_i          ),
    .rst_ni            ( rst_ni         ),
    .crypto_verified_i ( 1'b1           ),
    .uart_tx_o         ( uart_tx        ),
    .uart_rx_i         ( 1'b1           ),
`ifdef DIFT
    .dift_en_i         ( dift_en        ),
`endif
    .bootrom_req_o     ( bootrom_req    ),
    .bootrom_gnt_i     ( bootrom_gnt    ),
    .bootrom_rvalid_i  ( bootrom_rvalid ),
    .bootrom_addr_o    ( bootrom_addr   ),
    .bootrom_we_o      ( bootrom_we     ),
    .bootrom_be_o      ( bootrom_be     ),
    .bootrom_wdata_o   ( bootrom_wdata  ),
    .bootrom_rdata_i   ( bootrom_rdata  ),
    .bootrom_err_i     ( bootrom_err    ),

    .isram_req_o       ( isram_req      ),
    .isram_gnt_i       ( isram_gnt      ),
    .isram_rvalid_i    ( isram_rvalid   ),
    .isram_addr_o      ( isram_addr     ),
    .isram_we_o        ( isram_we       ),
    .isram_be_o        ( isram_be       ),
    .isram_wdata_o     ( isram_wdata    ),
    .isram_rdata_i     ( isram_rdata    ),
    .isram_err_i       ( isram_err      ),

    .data_req_o        ( data_req       ),
    .data_gnt_i        ( data_gnt       ),
    .data_rvalid_i     ( data_rvalid    ),
    .data_addr_o       ( data_addr      ),
    .data_we_o         ( data_we        ),
    .data_be_o         ( data_be        ),
    .data_wdata_o      ( data_wdata     ),
    .data_rdata_i      ( data_rdata     ),
    .data_err_i        ( data_err       ),

    .spi_clk_o         ( spi_clk        ),
    .spi_csn_o         ( spi_csn        ),
    .spi_mode_o        ( spi_mode       ),
    .spi_sdo_o         ( spi_sdo        ),
    .spi_sdi_i         ( 4'h0           ),

    .jtag_tck_i        ( jtag_tck       ),
    .jtag_tms_i        ( jtag_tms       ),
    .jtag_trst_ni      ( jtag_trst_n    ),
    .jtag_tdi_i        ( jtag_tdi       ),
    .jtag_tdo_o        ( jtag_tdo_dut   )
  );

  // -------------------------------------------------------------------------
  // Memory models
  // -------------------------------------------------------------------------
  bootrom_model #(
    .DEPTH    ( 16384 ),
    .HEX_FILE ( ""    )
  ) u_bootrom (
    .clk_i    ( clk_i          ),
    .rst_ni   ( rst_ni         ),
    .req_i    ( bootrom_req    ),
    .gnt_o    ( bootrom_gnt    ),
    .rvalid_o ( bootrom_rvalid ),
    .addr_i   ( bootrom_addr   ),
    .we_i     ( bootrom_we     ),
    .be_i     ( bootrom_be     ),
    .wdata_i  ( bootrom_wdata  ),
    .rdata_o  ( bootrom_rdata  ),
    .err_o    ( bootrom_err    )
  );

  isram_model #(
    .DEPTH    ( 65536 ),
    .HEX_FILE ( ""    )
  ) u_isram (
    .clk_i    ( clk_i         ),
    .rst_ni   ( rst_ni        ),
    .req_i    ( isram_req     ),
    .gnt_o    ( isram_gnt     ),
    .rvalid_o ( isram_rvalid  ),
    .addr_i   ( isram_addr    ),
    .we_i     ( isram_we      ),
    .be_i     ( isram_be      ),
    .wdata_i  ( isram_wdata   ),
    .rdata_o  ( isram_rdata   ),
    .err_o    ( isram_err     )
  );

  dsram_model #(
    .DEPTH    ( 16384 ),
    .HEX_FILE ( ""    )
  ) u_dsram (
    .clk_i    ( clk_i        ),
    .rst_ni   ( rst_ni       ),
    .req_i    ( data_req     ),
    .gnt_o    ( data_gnt     ),
    .rvalid_o ( data_rvalid  ),
    .addr_i   ( data_addr    ),
    .we_i     ( data_we      ),
    .be_i     ( data_be      ),
    .wdata_i  ( data_wdata   ),
    .rdata_o  ( data_rdata   ),
    .err_o    ( data_err     )
  );

  // -------------------------------------------------------------------------
  // Waveform dump
  // -------------------------------------------------------------------------
  initial begin
    $dumpfile("dbg_tb_top.vcd");
    $dumpvars(0, dbg_tb_top);
  end

  // -------------------------------------------------------------------------
  // DM signal probes (hierarchical into basic_soc_top internal signals)
  // -------------------------------------------------------------------------
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

  // -------------------------------------------------------------------------
  // Self-checking test sequence
  // -------------------------------------------------------------------------
  int          errors;
  logic [31:0] rdata;
  logic [31:0] dmstatus_val;
  logic [1:0]  resp;
  logic [31:0] abstractcs_val;

  // Helper: poll abstractcs.busy until clear, flag cmderr != 0
  task automatic wait_abstract_done();
    int poll;
    poll = 0;
    do begin
      u_jtag.dmi_read(dm::dm_csr_e'(dm::AbstractCS), abstractcs_val);
      poll++;
      if (poll > 5000) begin
        $error("[FAIL] abstractcs.busy never cleared (abstractcs=%08h)", abstractcs_val);
        errors++;
        return;
      end
    end while (abstractcs_val[12]);  // busy bit
    if (abstractcs_val[10:8] != 3'h0) begin
      $error("[FAIL] abstractcs.cmderr=%0d after command (abstractcs=%08h)",
             abstractcs_val[10:8], abstractcs_val);
      errors++;
      // Clear cmderr by writing 3'h7 to abstractcs.cmderr (W1C field)
      u_jtag.dmi_write(dm::dm_csr_e'(dm::AbstractCS), 32'h0000_0700);
    end
  endtask

  initial begin
    errors = 0;

    // Initialise JTAG pins to safe idle state
    u_jtag.tck    = 1'b0;
    u_jtag.tms    = 1'b1;
    u_jtag.tdi    = 1'b0;
    u_jtag.trst_n = 1'b0;

    wait (rst_ni === 1'b1);
    repeat (5) @(posedge clk_i);

    // -----------------------------------------------------------------
    // [1] JTAG TAP reset + activate DM
    // -----------------------------------------------------------------
    $display("=== [1] JTAG TAP reset + activate DM ===");
    u_jtag.tap_reset();

    // Write dmcontrol: dmactive=1
    u_jtag.dmi_write(dm::dm_csr_e'(dm::DMControl), 32'h0000_0001);
    u_jtag.idle_ticks(10);
    u_jtag.dmi_read(dm::dm_csr_e'(dm::DMControl), rdata);
    if (rdata[0] !== 1'b1) begin
      $error("[FAIL] dmactive did not read back 1 (dmcontrol=%08h)", rdata);
      errors++;
    end else
      $display("[PASS] DM active (dmcontrol=%08h)", rdata);

    // -----------------------------------------------------------------
    // [2] Halt the hart
    // -----------------------------------------------------------------
    $display("=== [2] Halt the hart ===");
    // haltreq=1, dmactive=1
    u_jtag.dmi_write(dm::dm_csr_e'(dm::DMControl), 32'h8000_0001);

    begin : halt_poll
      int poll;
      dmstatus_val = 32'h0;
      poll = 0;
      while (!dmstatus_val[9]) begin  // allhalted
        u_jtag.idle_ticks(20);
        u_jtag.dmi_read(dm::dm_csr_e'(dm::DMStatus), dmstatus_val);
        poll++;
        if (poll > 500) begin
          $error("[FAIL] Timed out waiting for dmstatus.allhalted (dmstatus=%08h)",
                 dmstatus_val);
          errors++;
          disable halt_poll;
        end
      end
    end
    if (dmstatus_val[9])
      $display("[PASS] Hart halted (dmstatus=%08h)", dmstatus_val);

    // Clear haltreq
    u_jtag.dmi_write(dm::dm_csr_e'(dm::DMControl), 32'h0000_0001);

    // -----------------------------------------------------------------
    // [3] Abstract command: write x1 = 0xCAFEF00D
    // -----------------------------------------------------------------
    $display("=== [3] Abstract command: write x1 = CAFEF00D ===");
    u_jtag.dmi_write(dm::dm_csr_e'(dm::Data0), 32'hCAFE_F00D);
    // cmdtype=0 (AccessReg), aarsize=2 (32-bit), transfer=1, write=1, regno=0x1001 (x1)
    u_jtag.dmi_write(dm::dm_csr_e'(dm::Command),
                     {8'h00, 1'b0, 3'd2, 1'b0, 1'b0, 1'b1, 1'b1, 16'h1001});
    wait_abstract_done();

    // -----------------------------------------------------------------
    // [4] Abstract command: read back x1
    // -----------------------------------------------------------------
    $display("=== [4] Abstract command: read back x1 ===");
    // cmdtype=0, aarsize=2, transfer=1, write=0, regno=0x1001
    u_jtag.dmi_write(dm::dm_csr_e'(dm::Command),
                     {8'h00, 1'b0, 3'd2, 1'b0, 1'b0, 1'b1, 1'b0, 16'h1001});
    wait_abstract_done();
    u_jtag.dmi_read(dm::dm_csr_e'(dm::Data0), rdata);
    if (rdata !== 32'hCAFE_F00D) begin
      $error("[FAIL] x1 mismatch: expected CAFEF00D, got %08h", rdata);
      errors++;
    end else
      $display("[PASS] x1 read back correctly: %08h", rdata);

    // -----------------------------------------------------------------
    // [5] Resume the hart
    // -----------------------------------------------------------------
    $display("=== [5] Resume the hart ===");
    // resumereq=1, dmactive=1
    u_jtag.dmi_write(dm::dm_csr_e'(dm::DMControl), 32'h4000_0001);

    begin : resume_poll
      int poll;
      dmstatus_val = 32'h0;
      poll = 0;
      while (!dmstatus_val[11]) begin  // allrunning
        u_jtag.idle_ticks(20);
        u_jtag.dmi_read(dm::dm_csr_e'(dm::DMStatus), dmstatus_val);
        poll++;
        if (poll > 500) begin
          $error("[FAIL] Timed out waiting for dmstatus.allrunning (dmstatus=%08h)",
                 dmstatus_val);
          errors++;
          disable resume_poll;
        end
      end
    end
    if (dmstatus_val[11])
      $display("[PASS] Hart resumed (dmstatus=%08h)", dmstatus_val);

    repeat (200) @(posedge clk_i);

    $display("=====================================================");
    if (errors == 0) $display("TEST PASSED -- core+DIFT+riscv-dbg debug session OK");
    else              $display("TEST FAILED -- %0d error(s)", errors);
    $display("=====================================================");
    $finish;
  end

  // Global watchdog
  initial begin
    #5ms;
    $error("[FAIL] Global watchdog timeout -- simulation hung");
    $finish;
  end

endmodule : dbg_tb_top