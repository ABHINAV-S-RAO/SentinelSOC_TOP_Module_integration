// =============================================================================
// tb_secure_boot.sv -- unit test for rtl/soc/soc_secure_boot.sv
//
// soc_secure_boot + the real rtl/crypto engine, fed from an ISRAM model that
// holds the signed image from verif/debugger/images (TEST-ONLY key):
//   1. signed image      -> signature_valid=1, verified=1, fetch allowed only
//                           inside the code range [entry, entry + 4*M)
//   2. one code bit flip -> rejected, fetch blocked
// Run from the repo root:  verif/secure_boot/run_verilator.sh
// =============================================================================
`timescale 1ns/1ps
`ifndef DIV
`define DIV 2
`endif
module tb_secure_boot;
  logic clk = 0, rst_n = 1;
  always #5 clk = ~clk;

  logic [31:0] isram [1024];
  logic        vreq, vgnt, vrv;
  logic [31:0] vaddr, vrdata;
  logic        req, we;
  logic [31:0] addr, wdata, rdata;
  logic        rvalid, fok, verified;
  logic [31:0] faddr = '0;
  logic        facc = 1'b0, entered, started;
  int          fails = 0;

  assign vgnt = vreq;                              // ISRAM model: gnt=req, rvalid next cycle
  always_ff @(posedge clk) begin
    vrv    <= vreq;
    vrdata <= isram[(vaddr - 32'h1_0000) >> 2];
  end

  soc_secure_boot #(.CRYPTO_CLK_DIV(`DIV)) dut (
    .clk_i(clk), .rst_ni(rst_n),
    .req_i(req), .we_i(we), .be_i(4'hF), .addr_i(addr), .wdata_i(wdata),
    .gnt_o(), .rvalid_o(rvalid), .rdata_o(rdata), .err_o(),
    .ver_req_o(vreq), .ver_addr_o(vaddr), .ver_gnt_i(vgnt), .ver_rvalid_i(vrv), .ver_rdata_i(vrdata),
    .isram_write_i(1'b0), .fetch_addr_i(faddr), .fetch_accept_i(facc), .fetch_ok_o(fok),
    .verified_o(verified), .fw_entered_o(entered), .verify_started_o(started));

  logic [31:0]  pk [8];
  logic [255:0] otp_key;

  task automatic reg_wr(logic [31:0] a, logic [31:0] d);
    @(negedge clk); req = 1; we = 1; addr = a; wdata = d;
    @(negedge clk); req = 0; we = 0;
  endtask
  task automatic reg_rd(logic [31:0] a, output logic [31:0] d);
    @(negedge clk); req = 1; we = 0; addr = a;
    @(negedge clk); req = 0;
    d = rdata;
  endtask

  task automatic run(string name, bit expect_ok);
    logic [31:0] st;
    int n = 0;
    #1 rst_n = 0; repeat (5) @(posedge clk); rst_n = 1; repeat (3) @(posedge clk);
    dut.u_otp.otp_mem = otp_key;                   // TEST-ONLY key "fused"
    reg_wr(32'h0, 32'h1);                          // VERIFY_CTRL.start
    do begin reg_rd(32'h4, st); n++; end while (!st[1] && n < 1_000_000);
    if (started !== 1'b1) begin fails++; $display("  FAIL verify_started=%b after start", started); end
    // Before the handoff: single entry -- only ENTRY may be fetched
    if (entered !== 1'b0) begin fails++; $display("  FAIL fw_entered=%b before any fetch", entered); end
    faddr = 32'h1_0044; #1; if (fok !== expect_ok) begin fails++; $display("  FAIL fetch_ok(entry)=%b", fok); end
    faddr = 32'h1_0048; #1; if (fok !== 1'b0)      begin fails++; $display("  FAIL fetch_ok(entry+4, before handoff)=%b", fok); end
    faddr = 32'h1_0040; #1; if (fok !== 1'b0)      begin fails++; $display("  FAIL fetch_ok(header)=%b", fok); end
    // A fetch handshake somewhere else never hands over
    @(negedge clk); faddr = 32'h1_0048; facc = 1; @(negedge clk); facc = 0;
    if (entered !== 1'b0) begin fails++; $display("  FAIL fw_entered after a fetch at entry+4"); end
    // Fetch handshake at ENTRY: hands over only if verified
    @(negedge clk); faddr = 32'h1_0044; facc = 1; @(negedge clk); facc = 0;
    if (entered !== expect_ok) begin fails++; $display("  FAIL fw_entered=%b after fetch at entry", entered); end
    faddr = 32'h1_0048; #1; if (fok !== expect_ok) begin fails++; $display("  FAIL fetch_ok(entry+4, after handoff)=%b", fok); end
    faddr = 32'h1_0060; #1; if (fok !== expect_ok) begin fails++; $display("  FAIL fetch_ok(last code word)=%b", fok); end
    faddr = 32'h1_0064; #1; if (fok !== 1'b0)      begin fails++; $display("  FAIL fetch_ok(past end)=%b", fok); end
    faddr = 32'h1_0040; #1; if (fok !== 1'b0)      begin fails++; $display("  FAIL fetch_ok(header, after handoff)=%b", fok); end
    if (st[3] !== expect_ok || st[2] !== expect_ok || st[4]) begin fails++; $display("  FAIL status"); end
    $display("%-16s err=%b verified=%b valid=%b done=%b busy=%b entered=%b started=%b (%0d polls)",
             name, st[4], st[3], st[2], st[1], st[0], entered, started, n);
  endtask

  initial begin
    req = 0; we = 0; addr = 0; wdata = 0;
    foreach (isram[i]) isram[i] = '0;
    $readmemh("verif/debugger/images/recovery_signed.mem", isram);
    $readmemh("verif/debugger/images/otp_pubkey.mem", pk);
    foreach (pk[i]) otp_key[32*i +: 32] = pk[i];
    run("signed image", 1'b1);
    isram[20] ^= 32'h1;
    run("tampered image", 1'b0);
    if (fails == 0) $display("TEST PASSED"); else $display("TEST FAILED (%0d)", fails);
    $finish;
  end
endmodule
