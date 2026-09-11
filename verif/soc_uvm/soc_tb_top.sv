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
  import soc_uvm_pkg::*;
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

  // Data path -- unchanged by the restructuring
  logic        data_req, data_gnt, data_rvalid, data_err, data_we;
  logic [3:0]  data_be;
  logic [31:0] data_addr, data_wdata, data_rdata;

  // BootROM export -- OBI-style, port list confirmed against basic_soc_top.sv
  logic        bootrom_req, bootrom_gnt, bootrom_rvalid, bootrom_err, bootrom_we;
  logic [3:0]  bootrom_be;
  logic [31:0] bootrom_addr, bootrom_wdata, bootrom_rdata;

  // ISRAM export -- OBI-style, read/write
  logic        isram_req, isram_gnt, isram_rvalid, isram_err, isram_we;
  logic [3:0]  isram_be;
  logic [31:0] isram_addr, isram_wdata, isram_rdata;

  // QSPI pins -- confirmed against basic_soc_top.sv. No real flash BFM yet;
  // tied off below until one exists.
  logic        spi_clk_o;
  logic [3:0]  spi_csn_o;
  logic [1:0]  spi_mode_o;
  logic [3:0]  spi_sdo_o;
  logic [3:0]  spi_sdi_i;

  string firmware_file;
  string firmware_isram_file;

  initial begin
    crypto_verified = 1'b1; // Pass signature verification (secure-boot on hold)
    dift_en         = 1'b1; // Enable DIFT tracking
    uart_rx_i       = 1'b1; // Idle high

    // No real flash yet -- park QSPI inputs safe/idle so an accidental
    // firmware QSPI transaction doesn't hang on X.
    spi_sdi_i = 4'h0;
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

    .bootrom_req_o       ( bootrom_req ),
    .bootrom_gnt_i       ( bootrom_gnt ),
    .bootrom_rvalid_i    ( bootrom_rvalid ),
    .bootrom_addr_o      ( bootrom_addr ),
    .bootrom_we_o        ( bootrom_we ),
    .bootrom_be_o        ( bootrom_be ),
    .bootrom_wdata_o     ( bootrom_wdata ),
    .bootrom_rdata_i     ( bootrom_rdata ),
    .bootrom_err_i       ( bootrom_err ),

    .isram_req_o         ( isram_req ),
    .isram_gnt_i         ( isram_gnt ),
    .isram_rvalid_i      ( isram_rvalid ),
    .isram_addr_o        ( isram_addr ),
    .isram_we_o          ( isram_we ),
    .isram_be_o          ( isram_be ),
    .isram_wdata_o       ( isram_wdata ),
    .isram_rdata_i       ( isram_rdata ),
    .isram_err_i         ( isram_err ),

    .spi_clk_o           ( spi_clk_o ),
    .spi_csn_o           ( spi_csn_o ),
    .spi_mode_o          ( spi_mode_o ),
    .spi_sdo_o           ( spi_sdo_o ),
    .spi_sdi_i           ( spi_sdi_i ),

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
  // BootROM backing memory (replaces old direct u_tb_instr_mem wiring).
  // we_i/be_i/wdata_i wired to the DUT's real outputs rather than hardcoded
  // -- if soc_addr_decode's write-blocking to this region ever has a bug,
  // this will surface it instead of silently absorbing it.
  tb_memory_model u_tb_bootrom (
    .clk_i              ( clk_i ),
    .rst_ni             ( rst_ni ),
    .req_i              ( bootrom_req ),
    .gnt_o              ( bootrom_gnt ),
    .rvalid_o           ( bootrom_rvalid ),
    .addr_i             ( bootrom_addr ),
    .we_i               ( bootrom_we ),
    .be_i               ( bootrom_be ),
    .wdata_i            ( bootrom_wdata ),
    .rdata_o            ( bootrom_rdata ),
    .err_o              ( bootrom_err )
  );

  // ISRAM backing memory
  tb_memory_model u_tb_isram (
    .clk_i              ( clk_i ),
    .rst_ni             ( rst_ni ),
    .req_i              ( isram_req ),
    .gnt_o              ( isram_gnt ),
    .rvalid_o           ( isram_rvalid ),
    .addr_i             ( isram_addr ),
    .we_i               ( isram_we ),
    .be_i               ( isram_be ),
    .wdata_i            ( isram_wdata ),
    .rdata_o            ( isram_rdata ),
    .err_o              ( isram_err )
  );

  // Data Memory Model -- unchanged
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
  // Loads into BootROM, since that's what the CPU fetches from at reset via
  // soc_addr_decode (BOOTROM = 0x0000_0000). Layer-1 direct-load testing
  // preloads BootROM directly rather than going through a real QSPI->ISRAM
  // copy flow -- correct for now since Layer 3 (real flash boot) isn't
  // built yet.
  initial begin
    if ($value$plusargs("FIRMWARE=%s", firmware_file)) begin
      int fd;
      fd = $fopen(firmware_file, "r");
      if (fd == 0) begin
        $fatal(1, "[TB TOP] ERROR: Firmware file '%s' could not be opened!", firmware_file);
      end else begin
        $fclose(fd);
      end

      $display("[TB TOP] Pre-zeroing BootROM memory array...");
      foreach (u_tb_bootrom.mem[i]) begin
        u_tb_bootrom.mem[i] = 32'h00000013; // real NOP (addi x0, x0, 0)
      end

      $display("[TB TOP] Loading binary memory image: %s", firmware_file);
      $readmemh(firmware_file, u_tb_bootrom.mem);
    end else begin
      $display("[TB TOP] WARNING: No +FIRMWARE=<path.hex> plusarg supplied!");
    end
    if ($value$plusargs("FIRMWARE_ISRAM=%s", firmware_isram_file)) begin
      int fd_isram;
      fd_isram = $fopen(firmware_isram_file, "r");
      if (fd_isram == 0) begin
        $fatal(1, "[TB TOP] ERROR: ISRAM Firmware file '%s' could not be opened!", firmware_isram_file);
      end else begin
        $fclose(fd_isram);
      end

      $display("[TB TOP] Pre-zeroing ISRAM memory array...");
      foreach (u_tb_isram.mem[i]) begin
        u_tb_isram.mem[i] = 32'h00000000;
      end

      $display("[TB TOP] Loading ISRAM memory image: %s", firmware_isram_file);
      $readmemh(firmware_isram_file, u_tb_isram.mem);
    end else begin
      $display("[TB TOP] WARNING: No +FIRMWARE_ISRAM=<path.hex> plusarg supplied!");
    end
  end

  // ---------------------------------------------------------------------------
  // Interface Probes Wiring
  // ---------------------------------------------------------------------------
  // Instruction fetch is internal-only post-restructuring (routes through
  // soc_addr_decode to BootROM/ISRAM). Probed hierarchically off u_dut,
  // consistent with how dift_if already probes u_dut.tag_req/irq_dift below.
  assign instr_obi_if.req    = u_dut.instr_req_int;
  assign instr_obi_if.gnt    = u_dut.instr_gnt_int;
  assign instr_obi_if.rvalid = u_dut.instr_rvalid_int;
  assign instr_obi_if.we     = 1'b0;
  assign instr_obi_if.be     = 4'hF;
  assign instr_obi_if.addr   = u_dut.instr_addr_int;
  assign instr_obi_if.wdata  = 32'h0;
  assign instr_obi_if.rdata  = u_dut.instr_rdata_int;
  assign instr_obi_if.err    = u_dut.instr_err_int;

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