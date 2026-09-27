// =============================================================================
// soc_secure_boot.sv -- hardware-fed Ed25519 firmware verification
//
// Wraps the SHA-512 + Ed25519 engine (rtl/crypto/top_most.sv, unchanged) and
// its OTP public key, and feeds it FROM ISRAM IN HARDWARE, so the verdict is
// bound to the exact bytes that will execute. Software (bootrom, or the
// debugger in JTAG recovery) can only start a verification and read the
// result -- it can never choose the words that get hashed. The engine's own
// CSR port is reachable only from the feeder below.
//
// Image layout in ISRAM (rtl/crypto/scripts/build_mem.py flash layout,
// byte-exact; see verif/debugger/images/gen_signed_image.py):
//   ISRAM_BASE+0x00  sha_len (big-endian) = 16 + M      (R + A + M words)
//   ISRAM_BASE+0x04  R  (8 words)
//   ISRAM_BASE+0x24  S  (8 words)
//   ISRAM_BASE+0x44  M code words  <- entry point, the signed message
// The public key A comes from OTP, never from the image.
//
// Verification result -> ISRAM fetch gate:
//   verified_o = last run ended with a valid signature AND ISRAM was not
//   written since that run started. Any later ISRAM write clears it (no
//   swap-after-verify). fetch_ok_o additionally restricts execution to the
//   verified code range [entry, entry + 4*M): header and any unsigned tail of
//   ISRAM never execute.
//
// Crypto clock: CRYPTO_CLK_DIV-divided, same source, built with a clock gate
// (one clk_i pulse every CRYPTO_CLK_DIV cycles) -> synchronous, no CDC. The
// bridge presents each engine CSR access only in the cycle before a crypto
// clock edge (ce=1), so single-cycle strobes are never missed.
// The engine is one-shot per reset (it only reads OTP until its first
// verify_done): a second start without a system reset (ndmreset) reports
// STATUS.error.
//
// Registers (OBI subordinate, soc_addr_decode SHA window 0x0005_0000):
//   0x000 VERIFY_CTRL   (W)  [0] start (ignored while busy)
//   0x004 VERIFY_STATUS (R)  [0] busy  [1] done  [2] signature_valid
//                            [3] verified (ISRAM fetch enabled)  [4] error
//   0x008 CODE_WORDS    (R)  M, number of verified code words
//   0x00C ENTRY         (R)  entry address = ISRAM_BASE + 0x44
// =============================================================================
module soc_secure_boot #(
  parameter int unsigned CRYPTO_CLK_DIV = 2,              // >= 1
  parameter logic [31:0] ISRAM_BASE     = 32'h0001_0000,
  parameter int unsigned ISRAM_WORDS    = 1024            // 4 KB
) (
  input  logic        clk_i,
  input  logic        rst_ni,           // system reset (incl. ndmreset)

  // VERIFY registers (OBI subordinate)
  input  logic        req_i,
  input  logic        we_i,
  input  logic [ 3:0] be_i,
  input  logic [31:0] addr_i,
  input  logic [31:0] wdata_i,
  output logic        gnt_o,
  output logic        rvalid_o,
  output logic [31:0] rdata_o,
  output logic        err_o,

  // ISRAM read master (lowest-priority requester in soc_addr_decode)
  output logic        ver_req_o,
  output logic [31:0] ver_addr_o,
  input  logic        ver_gnt_i,
  input  logic        ver_rvalid_i,
  input  logic [31:0] ver_rdata_i,

  // Any accepted ISRAM write (invalidates the verdict)
  input  logic        isram_write_i,

  // ISRAM fetch gate
  input  logic [31:0] fetch_addr_i,
  output logic        fetch_ok_o,
  output logic        verified_o
);

  localparam int unsigned HDR_WORDS = 17;                 // sha_len + R + S
  localparam int unsigned MAX_CODE  = ISRAM_WORDS - HDR_WORDS;
  localparam logic [31:0] ENTRY     = ISRAM_BASE + 4 * HDR_WORDS;

  // top_most CSR offsets / STATUS bits
  localparam logic [11:0] C_CTRL = 12'h000, C_STATUS = 12'h004, C_MSGLEN = 12'h008,
                          C_RIN  = 12'h00C, C_SIN    = 12'h010, C_DATAIN = 12'h014;
  localparam int unsigned C_ST_READY = 1;

  function automatic logic [31:0] bswap(logic [31:0] v);
    return {v[7:0], v[15:8], v[23:16], v[31:24]};
  endfunction

  // ---------------------------------------------------------------------------
  // Divided crypto clock (clock gate, synchronous to clk_i)
  // ---------------------------------------------------------------------------
  logic ce;
  logic clk_crypto;

  if (CRYPTO_CLK_DIV <= 1) begin : g_no_div
    assign ce = 1'b1;
  end else begin : g_div
    logic [$clog2(CRYPTO_CLK_DIV)-1:0] div_q;
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni)                         div_q <= '0;
      else if (div_q == CRYPTO_CLK_DIV-1)  div_q <= '0;
      else                                 div_q <= div_q + 1'b1;
    end
    assign ce = (div_q == CRYPTO_CLK_DIV-1);
  end

  prim_clock_gating u_crypto_cg (
    .clk_i     ( clk_i      ),
    .en_i      ( ce         ),
    .test_en_i ( 1'b0       ),
    .clk_o     ( clk_crypto )
  );

  // ---------------------------------------------------------------------------
  // Crypto engine + OTP public key
  // ---------------------------------------------------------------------------
  logic        c_req, c_we;
  logic [11:0] c_addr;
  logic [31:0] c_wdata, c_rdata;
  logic        c_gnt, c_rvalid_q;
  logic        eng_start;
  logic [2:0]  otp_addr;
  logic        otp_rd_en, boot_active;
  logic [31:0] otp_data;
  logic        eng_done, eng_valid;

  // Bridge: an access is presented only in a ce cycle, so the engine samples
  // it at the very next crypto edge; its registered read data is valid in the
  // following clk_i cycle.
  assign c_gnt = c_req & ce;
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) c_rvalid_q <= 1'b0;
    else         c_rvalid_q <= c_gnt & ~c_we;
  end

  top_most u_crypto (
    .clk               ( clk_crypto          ),
    .rst_n             ( rst_ni              ),
    .csr_req_i         ( c_gnt               ),
    .csr_we_i          ( c_we                ),
    .csr_be_i          ( 4'hF                ),
    .csr_addr_i        ( {20'h0, c_addr}     ),
    .csr_wdata_i       ( c_wdata             ),
    .csr_gnt_o         (                     ),
    .csr_rvalid_o      (                     ),
    .csr_rdata_o       ( c_rdata             ),
    .csr_err_o         (                     ),
    .start_verify_i    ( eng_start & ce      ),
    .otp_addr_o        ( otp_addr            ),
    .otp_rd_en_o       ( otp_rd_en           ),
    .otp_data_i        ( otp_data            ),
    .boot_active_o     ( boot_active         ),
    .verify_done_o     ( eng_done            ),
    .signature_valid_o ( eng_valid           )
  );

  // Programming port unused on-chip (keys are fused at manufacturing).
  otp #(
    .RD_ADDRW     ( 3   ),
    .PUB_KEY_BITS ( 256 )
  ) u_otp (
    .clk         ( clk_crypto  ),
    .rst         ( ~rst_ni     ),
    .boot_active ( boot_active ),
    .rd_en       ( otp_rd_en   ),
    .rd_addr     ( otp_addr    ),
    .rd_data     ( otp_data    ),
    .prog_en     ( 1'b0        ),
    .prog_addr   ( '0          ),
    .prog_data   ( 1'b0        ),
    .test_mode   ( 1'b0        ),
    .otp_lock    (             )
  );

  // ---------------------------------------------------------------------------
  // Feeder FSM: ISRAM -> engine CSR port
  // ---------------------------------------------------------------------------
  typedef enum logic [3:0] {
    S_IDLE, S_LEN_REQ, S_LEN_RSP, S_MSGLEN, S_HDR_REQ, S_HDR_RSP, S_HDR_WR,
    S_START, S_POLL_REQ, S_POLL_RSP, S_BODY_REQ, S_BODY_RSP, S_BODY_WR, S_WAIT_DONE
  } state_e;
  state_e state_q;

  logic [$clog2(ISRAM_WORDS):0] idx_q;       // ISRAM word being read
  logic [$clog2(ISRAM_WORDS):0] left_q;      // code words still to feed
  logic [$clog2(ISRAM_WORDS):0] code_words_q;
  logic [31:0] word_q;
  logic        done_q, valid_q, verified_q, err_q, ran_q, dirty_q;

  logic start_w;
  assign start_w = req_i && we_i && (addr_i[11:0] == 12'h000) && wdata_i[0];

  // ISRAM read master
  assign ver_req_o  = (state_q inside {S_LEN_REQ, S_HDR_REQ, S_BODY_REQ});
  assign ver_addr_o = ISRAM_BASE + {idx_q, 2'b00};

  // Engine CSR master
  always_comb begin
    c_req   = 1'b0;
    c_we    = 1'b1;
    c_addr  = C_CTRL;
    c_wdata = word_q;
    unique case (state_q)
      S_MSGLEN:   begin c_req = 1'b1; c_addr = C_MSGLEN; end
      S_HDR_WR:   begin c_req = 1'b1; c_addr = (idx_q <= 8) ? C_RIN : C_SIN; end
      S_START:    begin c_req = 1'b1; c_addr = C_CTRL; c_wdata = 32'h1; end
      S_POLL_REQ: begin c_req = 1'b1; c_addr = C_STATUS; c_we = 1'b0; end
      S_BODY_WR:  begin c_req = 1'b1; c_addr = C_DATAIN; end
      default: ;
    endcase
  end
  assign eng_start = (state_q == S_START);   // latched by top_most, used after its register load

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      state_q      <= S_IDLE;
      idx_q        <= '0;
      left_q       <= '0;
      code_words_q <= '0;
      word_q       <= '0;
      done_q       <= 1'b0;
      valid_q      <= 1'b0;
      verified_q   <= 1'b0;
      err_q        <= 1'b0;
      ran_q        <= 1'b0;
      dirty_q      <= 1'b0;
    end else begin
      // Any ISRAM write kills the verdict, and taints an in-flight run.
      if (isram_write_i) begin
        verified_q <= 1'b0;
        dirty_q    <= 1'b1;
      end

      unique case (state_q)
        S_IDLE: begin
          if (start_w) begin
            done_q     <= 1'b0;
            valid_q    <= 1'b0;
            verified_q <= 1'b0;
            dirty_q    <= 1'b0;
            if (ran_q) begin
              err_q <= 1'b1;               // engine is one-shot per reset
            end else begin
              err_q   <= 1'b0;
              idx_q   <= '0;
              state_q <= S_LEN_REQ;
            end
          end
        end

        S_LEN_REQ: if (ver_gnt_i) state_q <= S_LEN_RSP;
        S_LEN_RSP: if (ver_rvalid_i) begin
          word_q <= bswap(ver_rdata_i);   // sha_len
          if (bswap(ver_rdata_i) < 17 || bswap(ver_rdata_i) - 16 > MAX_CODE) begin
            err_q   <= 1'b1;
            done_q  <= 1'b1;
            state_q <= S_IDLE;
          end else begin
            code_words_q <= ($clog2(ISRAM_WORDS)+1)'(bswap(ver_rdata_i) - 16);
            left_q       <= ($clog2(ISRAM_WORDS)+1)'(bswap(ver_rdata_i) - 16);
            state_q      <= S_MSGLEN;
          end
        end
        S_MSGLEN: if (c_gnt) begin
          idx_q   <= 1;
          state_q <= S_HDR_REQ;
        end

        // R (words 1..8) and S (words 9..16)
        S_HDR_REQ: if (ver_gnt_i) state_q <= S_HDR_RSP;
        S_HDR_RSP: if (ver_rvalid_i) begin
          word_q  <= bswap(ver_rdata_i);
          state_q <= S_HDR_WR;
        end
        S_HDR_WR: if (c_gnt) begin
          idx_q   <= idx_q + 1;
          state_q <= (idx_q == 16) ? S_START : S_HDR_REQ;
        end

        S_START: if (c_gnt) state_q <= S_POLL_REQ;

        // Code words, one per engine ready handshake
        S_POLL_REQ: begin
          if (left_q == 0)  state_q <= S_WAIT_DONE;
          else if (c_gnt)   state_q <= S_POLL_RSP;
        end
        S_POLL_RSP: if (c_rvalid_q) begin
          state_q <= c_rdata[C_ST_READY] ? S_BODY_REQ : S_POLL_REQ;
        end
        S_BODY_REQ: if (ver_gnt_i) state_q <= S_BODY_RSP;
        S_BODY_RSP: if (ver_rvalid_i) begin
          word_q  <= bswap(ver_rdata_i);
          state_q <= S_BODY_WR;
        end
        S_BODY_WR: if (c_gnt) begin
          idx_q   <= idx_q + 1;
          left_q  <= left_q - 1;
          state_q <= S_POLL_REQ;
        end

        S_WAIT_DONE: if (eng_done) begin
          done_q     <= 1'b1;
          valid_q    <= eng_valid;
          verified_q <= eng_valid & ~dirty_q & ~isram_write_i;
          ran_q      <= 1'b1;
          state_q    <= S_IDLE;
        end

        default: state_q <= S_IDLE;
      endcase
    end
  end

  // ---------------------------------------------------------------------------
  // Fetch gate
  // ---------------------------------------------------------------------------
  logic [31:0] code_end;
  assign code_end   = ENTRY + {code_words_q, 2'b00};
  assign verified_o = verified_q;
  assign fetch_ok_o = verified_q && (fetch_addr_i >= ENTRY) && (fetch_addr_i < code_end);

  // ---------------------------------------------------------------------------
  // VERIFY registers (OBI subordinate: gnt immediately, rvalid next cycle)
  // ---------------------------------------------------------------------------
  assign gnt_o = req_i;
  assign err_o = 1'b0;

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      rvalid_o <= 1'b0;
      rdata_o  <= '0;
    end else begin
      rvalid_o <= req_i;
      if (req_i && !we_i) begin
        unique case (addr_i[11:0])
          12'h004: rdata_o <= {27'h0, err_q, verified_q, valid_q, done_q, (state_q != S_IDLE)};
          12'h008: rdata_o <= 32'(code_words_q);
          12'h00C: rdata_o <= ENTRY;
          default: rdata_o <= 32'h0;
        endcase
      end
    end
  end

  logic unused_be;
  assign unused_be = ^be_i;

endmodule : soc_secure_boot
