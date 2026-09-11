// top_most.sv — Secure boot orchestrator, CSR-driven (no streaming FIFO)
// Ibex writes R_IN x8, S_IN x8, MSG_LEN, then CTRL.start, then polls
// STATUS.ready_for_word and writes DATA_IN word-by-word for the message body.

module top_most (
    input  logic        clk,
    input  logic        rst_n,

    // ---------------------------------------------------------------------
    // CSR (OBI-style flat) slave port
    // ---------------------------------------------------------------------
    input  logic        csr_req_i,
    input  logic        csr_we_i,
    input  logic [ 3:0] csr_be_i,     // ignored — firmware always does full-word writes
    input  logic [31:0] csr_addr_i,
    input  logic [31:0] csr_wdata_i,
    output logic        csr_gnt_o,
    output logic        csr_rvalid_o,
    output logic [31:0] csr_rdata_o,
    output logic        csr_err_o,

    input  logic        start_verify_i,
    output logic [2:0]  otp_addr_o,
    output logic        otp_rd_en_o,
    input  logic [31:0] otp_data_i,
    output logic        boot_active_o,
    output logic        verify_done_o,
    output logic        signature_valid_o
);

    // ---------------------------------------------------------------------
    // Ed25519 constants — UNCHANGED
    // ---------------------------------------------------------------------
    localparam logic [255:0] CONST_ZERO = 256'd0;
    localparam logic [255:0] CONST_ONE  = 256'd1;
    localparam logic [255:0] CURVE_D  = 256'h52036cee2b6ffe738cc740797779e89800700a4d4141d8ab75eb4dca135978a3;
    localparam logic [255:0] CURVE_2D = 256'h2406d9dc56dffce7198e80f2eef3d13000e0149a8283b156ebd69b9426b2f159;
    localparam logic [255:0] SQRT_M1  = 256'h2b8324804fc1df0b2b4d00993dfbd7a72f431806ad2fe478c4ee1b274a0ea0b0;
    localparam logic [255:0] G_X      = 256'h216936d3cd6e53fec0a4e231fdd6dc5c692cc7609525a7b2c9562d608f25d51a;
    localparam logic [255:0] G_Y      = 256'h6666666666666666666666666666666666666666666666666666666666666658;
    localparam logic [255:0] G_Z      = 256'd1;
    localparam logic [255:0] G_T      = 256'h67875f0fd78b766566ea4e8e64abe37d20f09f80775152f56dde8ab3a5b7dda3;
    localparam logic [255:0] MU_HI    = 256'h000000000000000000000000000000000000000000000000000000000000000f;
    localparam logic [255:0] MU_LO    = 256'hffffffffffffffffffffffffffffffeb2106215d086329a7ed9ce5a30a2c131b;
    localparam logic [255:0] CURVE_L  = 256'h1000000000000000000000000000000014def9dea2f79cd65812631a5cf5d3ed;

    // ---------------------------------------------------------------------
    // SHA-512 interface — UNCHANGED
    // ---------------------------------------------------------------------
    logic [5:0]  sha_addr;
    logic        sha_wen;
    logic [31:0] sha_wdata, sha_rdata;
    logic        sha_intr;

    sha512_top u_sha (
        .clk(clk), .rst_n(rst_n),
        .addr_i(sha_addr), .wr_en_i(sha_wen),
        .wdata_i(sha_wdata), .rdata_o(sha_rdata), .intr_o(sha_intr)
    );

    // ---------------------------------------------------------------------
    // ED25519 interface — UNCHANGED
    // ---------------------------------------------------------------------
    logic        ed_start, ed_done, ed_valid, ed_ext_we;
    logic [4:0]  ed_dest;
    logic [1:0]  ed_dsel;
    logic [255:0] ed_din;

    top_ed25519 u_ed (
        .clk(clk), .rst_n(rst_n),
        .start_verify(ed_start),
        .ext_data_1(ed_din), .ext_data_2(256'd0), .otp_data(256'd0),
        .data_sel(ed_dsel), .ext_we(ed_ext_we), .ext_dest_sel(ed_dest),
        .verify_done(ed_done), .signature_valid(ed_valid)
    );

    assign verify_done_o     = ed_done;
    assign signature_valid_o = ed_valid;

    // ---------------------------------------------------------------------
    // CSR address map
    // ---------------------------------------------------------------------
    localparam logic [11:0] CTRL_OFF    = 12'h000;
    localparam logic [11:0] STATUS_OFF  = 12'h004;
    localparam logic [11:0] MSGLEN_OFF  = 12'h008;
    localparam logic [11:0] RIN_OFF     = 12'h00C;
    localparam logic [11:0] SIN_OFF     = 12'h010;
    localparam logic [11:0] DATAIN_OFF  = 12'h014;

    // FSM states
    typedef enum logic [4:0] {
        ST_IDLE, ST_SHA_CFG_LEN, ST_SHA_CFG_CTRL, ST_SHA_POLL,
        ST_FEED_R,
        ST_OTP_REQ, ST_OTP_LATCH, ST_BLK_POLL_OTP,
        ST_WAIT_DATA, ST_BLK_POLL,
        ST_WAIT_INTR, ST_READ_HASH, ST_READ_HASH_LAST,
        ST_LOAD_REGS, ST_WAIT_START, ST_ED_START, ST_ED_WAIT, ST_DONE
    } state_t;
    state_t state;

    // Datapath
    logic [31:0]  sha_len_reg, msg_len_csr;
    logic [255:0] s_reg, r_reg, pubkey_reg;
    logic [511:0] hash_reg;
    logic [31:0]  sha_fed;
    logic [4:0]   blk_ptr;
    logic [2:0]   otp_idx;
    logic [2:0]   r_idx;
    logic [3:0]   hash_idx;
    logic [4:0]   load_idx;

    logic [31:0]  data_in_reg;
    logic         data_pending;   // set on DATA_IN write, cleared when FSM consumes it

    logic start_latch, boot_q;

    assign boot_active_o = boot_q & ~ed_done;
    assign otp_addr_o    = otp_idx;

    // ---------------------------------------------------------------------
    // CSR write-strobe decode (combinational)
    // ---------------------------------------------------------------------
    logic ctrl_wr, msglen_wr, rin_wr, sin_wr, datain_wr;
    assign ctrl_wr   = csr_req_i && csr_we_i && (csr_addr_i[11:0] == CTRL_OFF);
    assign msglen_wr = csr_req_i && csr_we_i && (csr_addr_i[11:0] == MSGLEN_OFF);
    assign rin_wr    = csr_req_i && csr_we_i && (csr_addr_i[11:0] == RIN_OFF);
    assign sin_wr    = csr_req_i && csr_we_i && (csr_addr_i[11:0] == SIN_OFF);
    assign datain_wr = csr_req_i && csr_we_i && (csr_addr_i[11:0] == DATAIN_OFF);

    logic ctrl_start_w, ctrl_abort_w, ctrl_softrst_w;
    assign ctrl_start_w   = ctrl_wr && csr_wdata_i[0];
    assign ctrl_abort_w   = ctrl_wr && csr_wdata_i[1];
    assign ctrl_softrst_w = ctrl_wr && csr_wdata_i[2];

    // ---------------------------------------------------------------------
    // STATUS bits (combinational)
    // ---------------------------------------------------------------------
    logic busy_bit, ready_bit, done_bit;
    assign busy_bit  = (state != ST_IDLE);
    assign ready_bit = (state == ST_WAIT_DATA) && !data_pending;
    assign done_bit  = (state == ST_DONE);

    // ---------------------------------------------------------------------
    // CSR bus response (gnt always immediate — single-cycle reg file)
    // ---------------------------------------------------------------------
    assign csr_gnt_o = csr_req_i;
    assign csr_err_o = 1'b0;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) csr_rvalid_o <= 1'b0;
        else        csr_rvalid_o <= csr_req_i;
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            csr_rdata_o <= 32'h0;
        end else if (csr_req_i && !csr_we_i) begin
            unique case (csr_addr_i[11:0])
                STATUS_OFF: csr_rdata_o <= {27'h0, 1'b0 /*error*/, ed_valid,
                                             done_bit, ready_bit, busy_bit};
                MSGLEN_OFF: csr_rdata_o <= msg_len_csr;
                default:    csr_rdata_o <= 32'hDEAD_BEEF; // CTRL/R_IN/S_IN/DATA_IN are WO
            endcase
        end
    end

    // R_IN / S_IN CSR writes — direct shift-register capture.
    // Byte-swap on the way in, same convention the old stream path used, so
    // r_reg[31:0] ends up holding the byte-swapped FIRST word written and
    // r_reg[255:224] the byte-swapped LAST (8th) word written.
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            r_reg <= '0;
            s_reg <= '0;
        end else begin
            if (rin_wr)
                r_reg <= {{csr_wdata_i[7:0], csr_wdata_i[15:8],
                           csr_wdata_i[23:16], csr_wdata_i[31:24]}, r_reg[255:32]};
            if (sin_wr)
                s_reg <= {{csr_wdata_i[7:0], csr_wdata_i[15:8],
                           csr_wdata_i[23:16], csr_wdata_i[31:24]}, s_reg[255:32]};
        end
    end

    // MSG_LEN capture
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) msg_len_csr <= 32'h0;
        else if (msglen_wr) msg_len_csr <= csr_wdata_i;
    end

    // DATA_IN capture — single-word handshake register
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_in_reg  <= 32'h0;
            data_pending <= 1'b0;
        end else begin
            if (datain_wr) begin
                data_in_reg  <= csr_wdata_i;
                data_pending <= 1'b1;
            end else if (state == ST_WAIT_DATA && data_pending) begin
                data_pending <= 1'b0; // consumed this cycle by the FSM below
            end
        end
    end

    // ---------------------------------------------------------------------
    // Main FSM
    // ---------------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state       <= ST_IDLE;
            sha_fed     <= 0; blk_ptr <= 0;
            otp_idx     <= 0; hash_idx <= 0; load_idx <= 0; r_idx <= 0;
            start_latch <= 0; boot_q <= 1;
            sha_len_reg <= 0; pubkey_reg <= 0; hash_reg <= 0;
            sha_addr    <= 0; sha_wen <= 0; sha_wdata <= 0;
            ed_start    <= 0; ed_ext_we <= 0; ed_dest <= 0; ed_dsel <= 0; ed_din <= 0;
            otp_rd_en_o <= 0;
        end else begin
            // Defaults
            sha_wen <= 0; ed_start <= 0; otp_rd_en_o <= 0;

            if (start_verify_i) start_latch <= 1;
            if (ed_done)        boot_q      <= 0;

            if (ctrl_softrst_w || ctrl_abort_w) begin
                // Boot-time-only design: abort/soft_reset just walk back to
                // IDLE and drop in-flight counters. No retry semantics needed.
                state    <= ST_IDLE;
                sha_fed  <= 0; blk_ptr <= 0; otp_idx <= 0; r_idx <= 0;
            end else begin
                case (state)

                    ST_IDLE: begin
                        if (ctrl_start_w) begin
                            sha_len_reg <= msg_len_csr; // already includes R+A prefix (64B)
                            sha_fed     <= 0;
                            blk_ptr     <= 0;
                            otp_idx     <= 0;
                            r_idx       <= 0;
                            state       <= ST_SHA_CFG_LEN;
                        end
                    end

                    ST_SHA_CFG_LEN: begin
                        sha_addr<=6'h32; sha_wdata<=sha_len_reg; sha_wen<=1;
                        state <= ST_SHA_CFG_CTRL;
                    end
                    ST_SHA_CFG_CTRL: begin
                        sha_addr<=6'h20; sha_wdata<=32'h03; sha_wen<=1;
                        state <= ST_SHA_POLL;
                    end
                    ST_SHA_POLL: begin
                        sha_addr <= 6'h21;
                        if (sha_rdata[0]) state <= ST_FEED_R;
                    end

                    // Feed the 8 words of r_reg into SHA, low word first
                    // (arrival order of the original R_IN writes).
                    ST_FEED_R: begin
                        sha_addr  <= 6'(blk_ptr);
                        sha_wdata <= r_reg[r_idx*32 +: 32];
                        sha_wen   <= 1;
                        sha_fed   <= sha_fed + 1;
                        blk_ptr   <= blk_ptr + 1;
                        r_idx     <= r_idx + 1;
                        if (r_idx == 7) state <= ST_OTP_REQ;
                    end

                    // Fetch Public Key from OTP — UNCHANGED pattern
                    ST_OTP_REQ: begin
                        otp_rd_en_o <= 1;
                        state       <= ST_OTP_LATCH;
                    end
                    ST_OTP_LATCH: begin
                        pubkey_reg <= {{otp_data_i[7:0], otp_data_i[15:8], otp_data_i[23:16], otp_data_i[31:24]}, pubkey_reg[255:32]};
                        sha_addr   <= 6'(blk_ptr);
                        sha_wdata  <= {otp_data_i[7:0], otp_data_i[15:8], otp_data_i[23:16], otp_data_i[31:24]};
                        sha_wen    <= 1;
                        sha_fed    <= sha_fed + 1;
                        blk_ptr    <= blk_ptr + 1;

                        if (otp_idx == 7) begin
                            if (sha_fed + 1 == sha_len_reg) begin
                                state <= ST_WAIT_INTR;
                            end else if (blk_ptr == 31) begin
                                blk_ptr <= 0; state <= ST_BLK_POLL;
                            end else begin
                                state <= ST_WAIT_DATA;
                            end
                        end else begin
                            otp_idx <= otp_idx + 1;
                            if (blk_ptr == 31) begin
                                blk_ptr <= 0; state <= ST_BLK_POLL_OTP;
                            end else begin
                                state <= ST_OTP_REQ;
                            end
                        end
                    end

                    ST_BLK_POLL_OTP: begin
                        sha_addr <= 6'h21;
                        if (sha_rdata[0]) state <= ST_OTP_REQ;
                    end

                    // Wait for firmware to write DATA_IN (STATUS.ready_for_word
                    // tells it when). No FIFO — this is the single-word
                    // register/handshake called for in the design.
                    ST_WAIT_DATA: begin
                        if (data_pending) begin
                            sha_addr  <= 6'(blk_ptr);
                            sha_wdata <= {data_in_reg[7:0], data_in_reg[15:8], data_in_reg[23:16], data_in_reg[31:24]};
                            sha_wen   <= 1;
                            sha_fed   <= sha_fed + 1;
                            blk_ptr   <= blk_ptr + 1;

                            if (sha_fed + 1 == sha_len_reg) begin
                                state <= ST_WAIT_INTR;
                            end else if (blk_ptr == 31) begin
                                blk_ptr <= 0; state <= ST_BLK_POLL;
                            end
                        end
                    end

                    ST_BLK_POLL: begin
                        sha_addr <= 6'h21;
                        if (sha_rdata[0]) state <= ST_WAIT_DATA;
                    end

                    ST_WAIT_INTR: begin
                        if (sha_intr) begin
                            hash_idx <= 0;
                            sha_addr <= 6'h22;
                            state    <= ST_READ_HASH;
                        end
                    end

                    // Extract 512-bit Hash — UNCHANGED
                    ST_READ_HASH: begin
                        hash_reg <= {{sha_rdata[7:0], sha_rdata[15:8], sha_rdata[23:16], sha_rdata[31:24]}, hash_reg[511:32]};
                        hash_idx <= hash_idx + 1;
                        if (hash_idx == 14) begin
                            sha_addr <= 6'h31;
                            state    <= ST_READ_HASH_LAST;
                        end else begin
                            sha_addr <= 6'h22 + {2'b0, hash_idx + 1};
                        end
                    end

                    ST_READ_HASH_LAST: begin
                        hash_reg <= {{sha_rdata[7:0], sha_rdata[15:8], sha_rdata[23:16], sha_rdata[31:24]}, hash_reg[511:32]};
                        load_idx <= 0;
                        state    <= ST_LOAD_REGS;
                    end

                    // Load ED25519 Math Registers — UNCHANGED
                    ST_LOAD_REGS: begin
                        ed_ext_we <= 1;
                        ed_dsel   <= 2'b01;
                        load_idx  <= load_idx + 1;

                        case (load_idx)
                            0:  begin ed_dest<=24; ed_din<=CONST_ZERO;        end
                            1:  begin ed_dest<=25; ed_din<=CONST_ONE;         end
                            2:  begin ed_dest<=26; ed_din<=CURVE_D;           end
                            3:  begin ed_dest<=27; ed_din<=CURVE_2D;          end
                            4:  begin ed_dest<=28; ed_din<=SQRT_M1;           end
                            5:  begin ed_dest<=4;  ed_din<=G_X;               end
                            6:  begin ed_dest<=5;  ed_din<=G_Y;               end
                            7:  begin ed_dest<=6;  ed_din<=G_Z;               end
                            8:  begin ed_dest<=7;  ed_din<=G_T;               end
                            9:  begin ed_dest<=10; ed_din<=MU_HI;             end
                            10: begin ed_dest<=11; ed_din<=CURVE_L;           end
                            11: begin ed_dest<=12; ed_din<=MU_LO;             end
                            12: begin ed_dest<=23; ed_din<=s_reg;             end
                            13: begin ed_dest<=20; ed_din<=r_reg;             end
                            14: begin ed_dest<=21; ed_din<=pubkey_reg;        end
                            15: begin ed_dest<=8;  ed_din<=hash_reg[255:0];   end
                            16: begin ed_dest<=9;  ed_din<=hash_reg[511:256]; end
                            default: ;
                        endcase

                        if (load_idx == 17) begin
                            ed_ext_we <= 0;
                            state     <= ST_WAIT_START;
                        end
                    end

                    ST_WAIT_START: begin
                        ed_dsel <= 2'b00;
                        if (start_latch || start_verify_i) begin
                            start_latch <= 0;
                            state       <= ST_ED_START;
                        end
                    end

                    ST_ED_START: begin ed_start<=1; state<=ST_ED_WAIT; end
                    ST_ED_WAIT:  begin if (ed_done) state<=ST_DONE;    end
                    ST_DONE:     ;

                    default: state <= ST_IDLE;
                endcase
            end
        end
    end

endmodule