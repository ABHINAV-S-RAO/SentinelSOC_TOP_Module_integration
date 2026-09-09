module flash #(
  parameter int unsigned MEM_SIZE_BYTES = 1024 * 1024 // 1 MB default
)(
  input  logic       csn_i,
  input  logic       sck_i,
  inout  logic [3:0] io_io
);

  // Internal memory array to hold firmware and signature data
  logic [7:0] mem [MEM_SIZE_BYTES];

  initial begin
    // Load your compiled firmware/flash binary hex file here
    $readmemh("flash_boot.hex", mem);
  end

  logic mosi;
  logic miso;
  logic miso_en;

  assign mosi = io_io[0];
  assign io_io[1] = miso_en ? miso : 1'bz;
  assign io_io[2] = 1'bz;
  assign io_io[3] = 1'bz;

  logic [7:0]  cmd_reg;
  logic [31:0] bit_cnt;
  logic [31:0] addr_reg;
  
  logic [23:0] jedec_id = 24'hEF_40_16; 

  // SPI Controller State Machine for Command / Address tracking
  always_ff @(posedge sck_i or posedge csn_i) begin
    if (csn_i) begin
      bit_cnt  <= 0;
      cmd_reg  <= 0;
      addr_reg <= 0;
    end else begin
      if (bit_cnt < 8) begin
        cmd_reg <= {cmd_reg[6:0], mosi};
      end else if (bit_cnt >= 8 && bit_cnt < 32) begin
        // Capture 24-bit address sent after standard read commands (e.g., 0x03)
        addr_reg <= {addr_reg[30:0], mosi};
      end
      bit_cnt <= bit_cnt + 1;
    end
  end

  // Data Driving Logic (Read JEDEC ID or Read Data Array)
  always_ff @(negedge sck_i or posedge csn_i) begin
    if (csn_i) begin
      miso_en <= 1'b0;
      miso    <= 1'b0;
    end else begin
      if (cmd_reg == 8'h9F) begin
        // Handle JEDEC ID Read Request
        if (bit_cnt >= 8 && bit_cnt < 32) begin
          miso_en <= 1'b1;
          miso    <= jedec_id[31 - bit_cnt];
        end else begin
          miso_en <= 1'b0;
        end
      end else if (cmd_reg == 8'h03) begin
        // Handle Standard Read Array (Command 0x03 + 24-bit address)
        if (bit_cnt >= 32) begin
          miso_en <= 1'b1;
          // Pull byte from memory array based on address, shifting bits out MSB first
          int byte_idx;
          int bit_idx;
          byte_idx = addr_reg + ((bit_cnt - 32) / 8);
          bit_idx  = 7 - ((bit_cnt - 32) % 8);
          miso     <= mem[byte_idx][bit_idx];
        end else begin
          miso_en <= 1'b0;
        end
      end else begin
        miso_en <= 1'b0;
      end
    end
  end

endmodule