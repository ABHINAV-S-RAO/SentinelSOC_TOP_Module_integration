// =============================================================================
// spi_flash_model.sv -- behavioural SPI NOR flash (external boot flash)
//
// SPI mode 0 (CPOL=0, CPHA=0), MSB first, matching rtl/peripheral/apb_spi_master:
// the master shifts on SCLK falling edges and samples on rising edges, so this
// model samples MOSI on posedge SCLK and drives MISO after each negedge.
// Supported commands (enough for the boot ROM):
//   0x03 READ   24-bit address, then data bytes (address auto-increments)
//   0x9F RDID   JEDEC ID EF 40 16 (W25Q32-like)
// Anything else: MISO stays 0. Contents come from INIT_FILE (one byte per
// line, $readmemh); unwritten bytes read as 0xFF like erased flash.
// =============================================================================
`timescale 1ns/1ps
module spi_flash_model #(
  parameter int unsigned SIZE_BYTES = 1 << 20,
  parameter string       INIT_FILE  = ""
) (
  input  logic sck,
  input  logic csn,
  input  logic mosi,
  output logic miso
);
  logic [7:0]  mem [SIZE_BYTES];
  logic [7:0]  cmd;
  logic [23:0] addr;
  int unsigned bit_cnt;
  int unsigned reads;               // READ commands served (for the TB)

  initial begin
    foreach (mem[i]) mem[i] = 8'hFF;
    if (INIT_FILE != "") $readmemh(INIT_FILE, mem);
    miso  = 1'b0;
    reads = 0;
  end

  // A new command starts on every CS assertion
  always @(negedge csn) begin
    bit_cnt = 0;
    cmd     = '0;
    addr    = '0;
    miso    = 1'b0;
  end
  always @(posedge csn) miso = 1'b0;

  always @(posedge sck) if (!csn) begin
    if (bit_cnt < 8)
      cmd = {cmd[6:0], mosi};
    else if (bit_cnt < 32 && cmd == 8'h03)
      addr = {addr[22:0], mosi};
    bit_cnt++;
    if (bit_cnt == 32 && cmd == 8'h03) reads++;
  end

  always @(negedge sck) if (!csn) begin
    int unsigned k;
    logic [7:0]  b;
    if (cmd == 8'h03 && bit_cnt >= 32) begin
      k    = bit_cnt - 32;
      b    = mem[(addr + k / 8) % SIZE_BYTES];
      miso = b[7 - k % 8];
    end else if (cmd == 8'h9F && bit_cnt >= 8) begin
      k    = bit_cnt - 8;
      case (k / 8)
        0: b = 8'hEF;
        1: b = 8'h40;
        2: b = 8'h16;
        default: b = 8'h00;
      endcase
      miso = b[7 - k % 8];
    end
  end
endmodule : spi_flash_model
