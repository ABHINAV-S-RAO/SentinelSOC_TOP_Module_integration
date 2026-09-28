// =============================================================================
// full_soc_tb.sv -- end-to-end SentinelSoC boot: power-on reset to firmware
//
// No JTAG, no backdoor into the CPU: the only stimulus is power-on reset.
//   BootROM (verif/soc/images/bootrom.hex, from software/boot/bootrom.S)
//     -> reads the signed image from the external SPI flash model
//     -> copies it to ISRAM, locks ISRAM, starts hardware Ed25519 verification
//     -> verified: sets boot_done and jumps to the firmware entry
//   Firmware (software/app/app_demo.S, signed into app.flash.hex)
//     -> UART, SPI #2 byte, CLINT timer IRQ, PLIC external IRQ, PASS signature
// The only model-level shortcut: the TEST-ONLY public key is forced into the
// OTP model (on silicon it is fused at manufacturing).
//
// Checks: UART transcript (decoded from the uart_tx pin), SPI #2 byte on the
// pins, DSRAM result word, boot_done, interrupt counts.
//
// +TRACE   bounded bring-up trace (fetches, data bus, APB, traps, FSM)
// +TAMPER  flips one bit of the firmware in flash: the ROM must report the
//          verification failure and the firmware must never run.
// Build images first: software/build_sim_images.sh (run from repo root).
// =============================================================================
`timescale 1ns/1ps

module full_soc_tb;

  localparam time         CLK_PERIOD  = 10ns;                // 100 MHz
  localparam int unsigned UART_BIT    = 16;                  // bootrom UART_DIV+1
  localparam logic [31:0] TEST_PASS   = 32'hB007_B007;

  logic clk_i = 1'b0, rst_ni = 1'b0;
  always #(CLK_PERIOD/2) clk_i = ~clk_i;

  bit tamper;

  // ---------------------------------------------------------------------------
  // DUT
  // ---------------------------------------------------------------------------
  logic        bootrom_req, bootrom_gnt, bootrom_rvalid, bootrom_we, bootrom_err;
  logic [3:0]  bootrom_be;
  logic [31:0] bootrom_addr, bootrom_wdata, bootrom_rdata;
  logic        isram_req, isram_gnt, isram_rvalid, isram_we, isram_err;
  logic [3:0]  isram_be;
  logic [31:0] isram_addr, isram_wdata, isram_rdata;
  logic        data_req, data_gnt, data_rvalid, data_we, data_err;
  logic [3:0]  data_be;
  logic [31:0] data_addr, data_wdata, data_rdata;

  logic        uart_tx;
  logic        qspi_clk;
  logic [3:0]  qspi_csn, qspi_sdo, qspi_sdi;
  logic [1:0]  qspi_mode;
  logic        spi2_clk, spi2_sdo;
  logic [3:0]  spi2_csn;
  logic [31:0] gpio_out, gpio_dir;
  logic        jtag_tdo;
  logic        flash_miso;

  assign qspi_sdi = {2'b00, flash_miso, 1'b0};   // standard SPI: MISO on IO1

  basic_soc_top #(
    .BOOT_WDT_CYCLES   ( 3_000_000 ),
    .SECURE_BOOT       ( 1'b1      ),
    .CRYPTO_CLK_DIV    ( 2         )
  ) u_dut (
    .clk_i             ( clk_i          ),
    .rst_ni            ( rst_ni         ),
    .crypto_verified_i ( 1'b0           ),     // unused with SECURE_BOOT=1
    .boot_mode_i       ( 1'b0           ),     // normal boot
    .uart_tx_o         ( uart_tx        ),
    .uart_rx_i         ( 1'b1           ),
`ifdef DIFT
    .dift_en_i         ( 1'b1           ),
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
    .spi_clk_o         ( qspi_clk       ),
    .spi_csn_o         ( qspi_csn       ),
    .spi_mode_o        ( qspi_mode      ),
    .spi_sdo_o         ( qspi_sdo       ),
    .spi_sdi_i         ( qspi_sdi       ),
    .spi2_clk_o        ( spi2_clk       ),
    .spi2_csn_o        ( spi2_csn       ),
    .spi2_sdo_o        ( spi2_sdo       ),
    .spi2_sdi_i        ( 1'b0           ),
    .gpio_in_i         ( 32'h0          ),
    .gpio_out_o        ( gpio_out       ),
    .gpio_dir_o        ( gpio_dir       ),
    .data_req_o        ( data_req       ),
    .data_gnt_i        ( data_gnt       ),
    .data_rvalid_i     ( data_rvalid    ),
    .data_addr_o       ( data_addr      ),
    .data_we_o         ( data_we        ),
    .data_be_o         ( data_be        ),
    .data_wdata_o      ( data_wdata     ),
    .data_rdata_i      ( data_rdata     ),
    .data_err_i        ( data_err       ),
    .jtag_tck_i        ( 1'b0           ),     // no debugger attached
    .jtag_tms_i        ( 1'b1           ),
    .jtag_trst_ni      ( 1'b0           ),
    .jtag_tdi_i        ( 1'b0           ),
    .jtag_tdo_o        ( jtag_tdo       )
  );

  // ---------------------------------------------------------------------------
  // Memories + external flash
  // ---------------------------------------------------------------------------
  bootrom_model #(.DEPTH(16384), .HEX_FILE("verif/soc/images/bootrom.hex")) u_bootrom (
    .clk_i(clk_i), .rst_ni(rst_ni), .req_i(bootrom_req), .gnt_o(bootrom_gnt),
    .rvalid_o(bootrom_rvalid), .addr_i(bootrom_addr), .we_i(bootrom_we),
    .be_i(bootrom_be), .wdata_i(bootrom_wdata), .rdata_o(bootrom_rdata), .err_o(bootrom_err));

  isram_model #(.DEPTH(65536), .HEX_FILE("")) u_isram (
    .clk_i(clk_i), .rst_ni(rst_ni), .req_i(isram_req), .gnt_o(isram_gnt),
    .rvalid_o(isram_rvalid), .addr_i(isram_addr), .we_i(isram_we),
    .be_i(isram_be), .wdata_i(isram_wdata), .rdata_o(isram_rdata), .err_o(isram_err));

  dsram_model #(.DEPTH(16384), .HEX_FILE("")) u_dsram (
    .clk_i(clk_i), .rst_ni(rst_ni), .req_i(data_req), .gnt_o(data_gnt),
    .rvalid_o(data_rvalid), .addr_i(data_addr), .we_i(data_we),
    .be_i(data_be), .wdata_i(data_wdata), .rdata_o(data_rdata), .err_o(data_err));

  spi_flash_model #(.INIT_FILE("verif/soc/images/app.flash.hex")) u_flash (
    .sck(qspi_clk), .csn(qspi_csn[0]), .mosi(qspi_sdo[0]), .miso(flash_miso));

  // TEST-ONLY public key "fused" into OTP
  logic [31:0]  otp_key_w [8];
  logic [255:0] otp_key;
  initial begin
    $readmemh("verif/soc/images/app.pubkey.mem", otp_key_w);
    foreach (otp_key_w[i]) otp_key[32*i +: 32] = otp_key_w[i];
    force u_dut.g_secure_boot.u_secure_boot.u_otp.otp_mem = otp_key;
  end

  // ---------------------------------------------------------------------------
  // UART receiver (8N1, UART_BIT clk cycles per bit) -> transcript
  // ---------------------------------------------------------------------------
  string transcript = "";
  string line = "";

  initial begin
    logic [7:0] ch;
    forever begin
      @(negedge uart_tx);                           // start bit
      repeat (UART_BIT / 2) @(posedge clk_i);
      if (uart_tx !== 1'b0) continue;               // glitch
      for (int b = 0; b < 8; b++) begin
        repeat (UART_BIT) @(posedge clk_i);
        ch[b] = uart_tx;
      end
      repeat (UART_BIT) @(posedge clk_i);           // stop bit
      transcript = {transcript, string'(ch)};
      if (ch == 8'h0A) begin
        $display("[%0t] UART | %s", $time, line);
        line = "";
      end else if (ch != 8'h0D) begin
        line = {line, string'(ch)};
      end
    end
  end

  // ---------------------------------------------------------------------------
  // SPI #2 monitor (mode 0, CS0): collect transmitted bytes
  // ---------------------------------------------------------------------------
  logic [7:0] spi2_bytes[$];
  initial begin
    logic [7:0] sh;
    int n;
    forever begin
      @(negedge spi2_csn[0]);
      n = 0;
      while (spi2_csn[0] === 1'b0) begin
        @(posedge spi2_clk or posedge spi2_csn[0]);
        if (spi2_csn[0] !== 1'b0) break;
        sh = {sh[6:0], spi2_sdo};
        if (++n % 8 == 0) begin
          spi2_bytes.push_back(sh);
          $display("[%0t] SPI2 | byte 0x%02h", $time, sh);
        end
      end
    end
  end

  // ---------------------------------------------------------------------------
  // Bring-up trace (first TRACE_MAX events of each kind): instruction fetches,
  // core data-bus transactions, APB handshakes, traps, controller state.
  // ---------------------------------------------------------------------------
  localparam int TRACE_MAX = 120;
  `define TB_CORE u_dut.u_ibex_top.u_ibex_core
  int n_if = 0, n_d = 0, n_apb = 0, n_trap = 0, n_fsm = 0;
  logic [3:0] fsm_q;

  bit trace_on;
  initial trace_on = $test$plusargs("TRACE");

  always @(posedge clk_i) if (rst_ni && trace_on) begin
    if (u_dut.instr_req_int && u_dut.instr_gnt_int && n_if < TRACE_MAX) begin
      n_if++;
      $display("[%0t] TR IF  req addr=%08h", $time, u_dut.instr_addr_int);
    end
    if (u_dut.instr_rvalid_int && n_if < TRACE_MAX && n_if > 0)
      $display("[%0t] TR IF  rsp data=%08h err=%b", $time, u_dut.instr_rdata_int, u_dut.instr_err_int);
    if (u_dut.core_data_req && n_d < TRACE_MAX) begin
      if (u_dut.core_data_gnt) n_d++;
      $display("[%0t] TR D   req addr=%08h we=%b wdata=%08h gnt=%b", $time, u_dut.core_data_addr,
               u_dut.core_data_we, u_dut.core_data_wdata, u_dut.core_data_gnt);
    end
    if (u_dut.core_data_rvalid && n_d < TRACE_MAX && n_d > 0)
      $display("[%0t] TR D   rsp rdata=%08h err=%b", $time, u_dut.core_data_rdata, u_dut.core_data_err);
    if (u_dut.apb_req_struct.psel && n_apb < TRACE_MAX) begin
      n_apb++;
      $display("[%0t] TR APB psel paddr=%08h pwrite=%b penable=%b pready=%b pslverr=%b", $time,
               u_dut.apb_req_struct.paddr, u_dut.apb_req_struct.pwrite, u_dut.apb_req_struct.penable,
               u_dut.apb_rsp_struct.pready, u_dut.apb_rsp_struct.pslverr);
    end
    if (`TB_CORE.id_stage_i.controller_i.pc_set_o &&
        `TB_CORE.id_stage_i.controller_i.pc_mux_o == ibex_pkg::PC_EXC && n_trap < 20) begin
      n_trap++;
      $display("[%0t] TR TRAP pc_id=%08h mcause(next)=%0d", $time, `TB_CORE.pc_id,
               `TB_CORE.id_stage_i.controller_i.exc_cause_o);
    end
    fsm_q <= `TB_CORE.id_stage_i.controller_i.ctrl_fsm_cs;
    if (`TB_CORE.id_stage_i.controller_i.ctrl_fsm_cs != fsm_q && n_fsm++ < 40)
      $display("[%0t] TR FSM %s", $time, `TB_CORE.id_stage_i.controller_i.ctrl_fsm_cs.name());
  end

  // ---------------------------------------------------------------------------
  // Test sequence
  // ---------------------------------------------------------------------------
  int errors = 0;

  task automatic check(bit cond, string what);
    if (cond) $display("[%0t] [PASS] %s", $time, what);
    else begin
      $display("[%0t] [FAIL] %s", $time, what);
      errors++;
    end
  endtask

  function automatic bit has(string s);
    for (int i = 0; i + s.len() <= transcript.len(); i++)
      if (transcript.substr(i, i + s.len() - 1) == s) return 1;
    return 0;
  endfunction

  initial begin
    tamper = $test$plusargs("TAMPER");
    #1;
    if (tamper) begin
      u_flash.mem[16'h0080] ^= 8'h01;               // one bit inside the signed code
      $display("*** +TAMPER: flipped one firmware bit in flash ***");
    end
    repeat (20) @(posedge clk_i);
    rst_ni = 1'b1;

    // Poll (every 1k cycles) until the flow reaches its end state
    if (!tamper) begin
      while (!(u_dsram.mem[0] == TEST_PASS || u_dsram.mem[0][31:16] == 16'hDEAD || has("ERROR")))
        repeat (1000) @(posedge clk_i);
      repeat (2000) @(posedge clk_i);              // let the last UART line drain
    end else begin
      while (!(has("verification FAILED") || u_dut.boot_done === 1'b1))
        repeat (1000) @(posedge clk_i);
      repeat (20000) @(posedge clk_i);
    end

    $display("\n================ full_soc_tb summary ================");
    check(has("[BOOT] SentinelSoC secure boot ROM"), "bootrom ran (UART banner)");
    check(has("[BOOT] image copied from SPI flash to ISRAM") && u_flash.reads > 0,
          $sformatf("image read from external SPI flash (%0d READ commands)", u_flash.reads));
    if (!tamper) begin
      check(has("[BOOT] Ed25519 signature VERIFIED"), "hardware Ed25519 verification passed");
      check(u_dut.boot_done === 1'b1, "boot_done set by the ROM");
      check(has("[APP] hello from verified firmware in ISRAM"), "firmware running from ISRAM");
      check(spi2_bytes.size() == 1 && spi2_bytes[0] == 8'hA5,
            $sformatf("SPI #2 transmitted 0xA5 (%0d byte(s))", spi2_bytes.size()));
      check(has("[APP] CLINT timer interrupt OK") && u_dsram.mem[1] == 1,
            $sformatf("CLINT timer interrupt taken (count=%0d)", u_dsram.mem[1]));
      check(has("[APP] PLIC external interrupt OK") && u_dsram.mem[2] == 5,
            $sformatf("PLIC claimed source 5 (APB timer) (id=%0d)", u_dsram.mem[2]));
      check(u_dsram.mem[0] == TEST_PASS, $sformatf("firmware result = %08h", u_dsram.mem[0]));
      check(!has("ERROR") && !has("FAIL"), "no errors reported on UART");
    end else begin
      check(has("[BOOT] ERROR: signature verification FAILED"), "tampered image rejected by the ROM");
      check(u_dut.boot_done !== 1'b1, "boot_done NOT set for a tampered image");
      check(!has("[APP]") && u_dsram.mem[0] != TEST_PASS, "tampered firmware never executed");
    end
    $display("=====================================================");
    if (errors == 0) $display("[full_soc_tb] TEST PASSED%s -- power-on to %s",
                              tamper ? " (+TAMPER)" : "",
                              tamper ? "rejected tampered firmware" : "verified firmware running");
    else             $display("[full_soc_tb] TEST FAILED -- %0d error(s)", errors);
    $finish;
  end

  initial begin
    #30ms;
    $display("[full_soc_tb] TEST FAILED -- watchdog timeout. UART so far:\n%s", transcript);
    $finish;
  end

endmodule : full_soc_tb
