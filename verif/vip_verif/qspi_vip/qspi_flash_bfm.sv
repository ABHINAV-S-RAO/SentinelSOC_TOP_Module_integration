`ifndef QSPI_FLASH_BFM_SV
`define QSPI_FLASH_BFM_SV

// Behavioral QSPI NOR-flash slave model. Passive: samples spi_sdo0-3 on
// posedge spi_clk, drives spi_sdi0-3 on negedge spi_clk. Decodes
// CMD -> ADDR -> DUMMY -> DATA phases, width per phase taken from spi_mode
// as driven by apb_spi_master (STD=2'b00, QUAD_TX=2'b01, QUAD_RX=2'b10).
//
// ASSUMPTIONS (unverified against spi_master_rx/tx — check first waveform):
//   1. Bit order is MSB-first within each byte/nibble.
//   2. In STD mode the active line is sdo0/sdi0 only.
//   3. Slave samples on posedge, drives on negedge (SPI mode 0).
// If a captured cmd/addr byte comes out reversed or shifted by one bit,
// flip ASSUMPTION 1 (LSB-first) or the sample/drive edges first.

module qspi_flash_bfm #(
    parameter int FLASH_SIZE = 1 << 20  // 1 MB behavioral flash
) (
    input  logic       spi_clk,
    input  logic       spi_csn0,
    input  logic [1:0] spi_mode,
    input  logic       spi_sdo0,
    input  logic       spi_sdo1,
    input  logic       spi_sdo2,
    input  logic       spi_sdo3,
    output logic       spi_sdi0,
    output logic       spi_sdi1,
    output logic       spi_sdi2,
    output logic       spi_sdi3
);

  localparam logic [1:0] STD      = 2'b00;
  localparam logic [1:0] QUAD_TX  = 2'b01;
  localparam logic [1:0] QUAD_RX  = 2'b10;

  typedef enum int {PH_IDLE, PH_CMD, PH_ADDR, PH_DUMMY, PH_DATA} phase_e;
  phase_e phase;

  byte unsigned flash_mem[FLASH_SIZE];

  // Per-transaction state
  logic [7:0]  cmd_byte;
  logic [31:0] addr_reg;
  int unsigned bit_cnt;      // bits captured/driven in current phase
  int unsigned addr_bits_needed = 24;   // 3-byte address, adjust if your addr_len differs
  int unsigned dummy_cycles_seen;
  int unsigned data_byte_idx;
  byte unsigned cur_out_byte;
  byte unsigned cur_in_byte;

  // number of bits per spi_clk edge in the current phase, per current mode
  function automatic int unsigned lane_width(logic [1:0] mode);
    return (mode == STD) ? 1 : 4;
  endfunction

  task automatic reset_txn();
    phase            = PH_IDLE;
    bit_cnt          = 0;
    cmd_byte         = '0;
    addr_reg         = '0;
    dummy_cycles_seen = 0;
    data_byte_idx    = 0;
  endtask

  initial reset_txn();

  // CS deasserted -> transaction over, go idle
  always @(posedge spi_csn0) reset_txn();

  // Sample MOSI-side lines on rising edge while selected
  always @(posedge spi_clk) begin
    if (!spi_csn0) begin
      case (phase)
        PH_IDLE: begin
          phase   = PH_CMD;
          bit_cnt = 0;
        end

        PH_CMD: begin
          if (lane_width(spi_mode) == 1) begin
            cmd_byte = {cmd_byte[6:0], spi_sdo0};
            bit_cnt++;
            if (bit_cnt == 8) begin
              phase   = PH_ADDR;
              bit_cnt = 0;
            end
          end else begin
            cmd_byte = {cmd_byte[3:0], spi_sdo3, spi_sdo2, spi_sdo1, spi_sdo0};
            bit_cnt += 4;
            if (bit_cnt == 8) begin
              phase   = PH_ADDR;
              bit_cnt = 0;
            end
          end
        end

        PH_ADDR: begin
          if (lane_width(spi_mode) == 1) begin
            addr_reg = {addr_reg[30:0], spi_sdo0};
            bit_cnt++;
          end else begin
            addr_reg = {addr_reg[27:0], spi_sdo3, spi_sdo2, spi_sdo1, spi_sdo0};
            bit_cnt += 4;
          end
          if (bit_cnt == addr_bits_needed) begin
            phase             = PH_DUMMY;
            bit_cnt           = 0;
            dummy_cycles_seen = 0;
            data_byte_idx     = 0;
            cur_out_byte      = flash_mem[addr_reg[$clog2(FLASH_SIZE)-1:0]];
          end
        end

        PH_DUMMY: begin
          dummy_cycles_seen++;
          if (dummy_cycles_seen == 8) phase = PH_DATA;  // adjust to actual spi_dummy_rd count if known
        end

        PH_DATA: begin
          // read-path: master clocks, flash drives on the negedge block below;
          // just track bit position here so the drive block knows what's next
          bit_cnt += lane_width(spi_mode);
          if (bit_cnt >= 8) begin
            bit_cnt = 0;
            data_byte_idx++;
            addr_reg     = addr_reg + 1;
            cur_out_byte = flash_mem[addr_reg[$clog2(FLASH_SIZE)-1:0]];
          end
        end

        default: ;
      endcase
    end
  end

  // Drive MISO-side lines on falling edge, half a cycle ahead of the sample
  always @(negedge spi_clk) begin
    if (!spi_csn0 && phase == PH_DATA) begin
      if (lane_width(spi_mode) == 1) begin
        spi_sdi0 <= cur_out_byte[7 - bit_cnt];
        spi_sdi1 <= 1'b0;
        spi_sdi2 <= 1'b0;
        spi_sdi3 <= 1'b0;
      end else begin
        spi_sdi3 <= cur_out_byte[7 - bit_cnt];
        spi_sdi2 <= cur_out_byte[6 - bit_cnt];
        spi_sdi1 <= cur_out_byte[5 - bit_cnt];
        spi_sdi0 <= cur_out_byte[4 - bit_cnt];
      end
    end else begin
      spi_sdi0 <= 1'b0;
      spi_sdi1 <= 1'b0;
      spi_sdi2 <= 1'b0;
      spi_sdi3 <= 1'b0;
    end
  end

  // Call before the QSPI test phase starts. Loads a firmware .hex
  // (word-addressed, same format as your other $readmemh images) into the
  // byte-addressed flash_mem array starting at byte offset `base`.
  task automatic load_flash_image(string hex_path, int unsigned base = 0);
    logic [31:0] word_mem[0:(FLASH_SIZE/4)-1];
    int unsigned i;
    $readmemh(hex_path, word_mem);
    for (i = 0; i < FLASH_SIZE/4; i++) begin
      flash_mem[base + i*4 + 0] = word_mem[i][7:0];
      flash_mem[base + i*4 + 1] = word_mem[i][15:8];
      flash_mem[base + i*4 + 2] = word_mem[i][23:16];
      flash_mem[base + i*4 + 3] = word_mem[i][31:24];
    end
  endtask

  // Direct byte-poke for expected-value setup from the test/scoreboard side
  function automatic byte unsigned peek_byte(int unsigned addr);
    return flash_mem[addr[$clog2(FLASH_SIZE)-1:0]];
  endfunction

endmodule

`endif