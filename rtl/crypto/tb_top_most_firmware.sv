`timescale 1ns/1ps

module tb_top_most_firmware;

    logic        clk = 0, rst_n = 0;

    // -----------------------------------------------------------------
    // CSR (OBI-style flat) slave port driven by this TB, standing in
    // for Ibex/BootROM
    // -----------------------------------------------------------------
    logic        csr_req_i, csr_we_i;
    logic [ 3:0] csr_be_i;
    logic [31:0] csr_addr_i, csr_wdata_i;
    logic        csr_gnt_o, csr_rvalid_o;
    logic [31:0] csr_rdata_o;
    logic        csr_err_o;

    logic        start_verify;
    logic [2:0]  otp_addr;
    logic        otp_rd_en;
    logic [31:0] otp_data;
    logic        boot_active;
    logic        verify_done, sig_valid;

    always #5 clk = ~clk;

    // -----------------------------------------------------------------
    // CSR address map — must match top_most.sv
    // -----------------------------------------------------------------
    localparam logic [11:0] CTRL_OFF    = 12'h000;
    localparam logic [11:0] STATUS_OFF  = 12'h004;
    localparam logic [11:0] MSGLEN_OFF  = 12'h008;
    localparam logic [11:0] RIN_OFF     = 12'h00C;
    localparam logic [11:0] SIN_OFF     = 12'h010;
    localparam logic [11:0] DATAIN_OFF  = 12'h014;

    localparam int ST_BUSY  = 0;
    localparam int ST_READY = 1;
    localparam int ST_DONE  = 2;
    localparam int ST_VALID = 3;

    // -----------------------------------------------------------------
    // DUT
    // -----------------------------------------------------------------
    top_most dut (
        .clk               (clk),
        .rst_n             (rst_n),

        .csr_req_i         (csr_req_i),
        .csr_we_i          (csr_we_i),
        .csr_be_i          (csr_be_i),
        .csr_addr_i        (csr_addr_i),
        .csr_wdata_i       (csr_wdata_i),
        .csr_gnt_o         (csr_gnt_o),
        .csr_rvalid_o      (csr_rvalid_o),
        .csr_rdata_o       (csr_rdata_o),
        .csr_err_o         (csr_err_o),

        .start_verify_i    (start_verify),
        .otp_addr_o        (otp_addr),
        .otp_rd_en_o       (otp_rd_en),
        .otp_data_i        (otp_data),
        .boot_active_o     (boot_active),
        .verify_done_o     (verify_done),
        .signature_valid_o (sig_valid)
    );

    // -----------------------------------------------------------------
    // Real OTP module — unchanged, still driven directly (not via CSR)
    // -----------------------------------------------------------------
    logic       otp_prog_en, otp_prog_data, otp_test_mode;
    logic [8:0] otp_prog_addr;

    otp #(.RD_ADDRW(3), .PUB_KEY_BITS(256)) u_otp (
        .clk(clk), .rst(~rst_n), .boot_active(boot_active),
        .rd_en(otp_rd_en), .rd_addr(otp_addr), .rd_data(otp_data),
        .prog_en(otp_prog_en), .prog_addr(otp_prog_addr),
        .prog_data(otp_prog_data), .test_mode(otp_test_mode), .otp_lock()
    );

    // -----------------------------------------------------------------
    // Task: bit-serial OTP programming from pubkey.mem, then lock.
    // Unchanged from the streaming-era TB — OTP programming never went
    // through the accelerator's front-end, so this isn't affected by
    // the CSR refactor.
    // -----------------------------------------------------------------
    task automatic program_otp_from_file(string path);
        integer fd, code;
        logic [31:0] word;
        int w, b;
        begin
            fd = $fopen(path, "r");
            if (fd == 0) $fatal(1, "Cannot open %s", path);
            otp_test_mode = 1'b1;
            w = 0;
            while (!$feof(fd)) begin
                code = $fscanf(fd, "%h\n", word);
                if (code != 1) continue;
                for (b = 0; b < 32; b++) begin
                    @(negedge clk);
                    otp_prog_en   = 1'b1;
                    otp_prog_addr = w*32 + b;
                    otp_prog_data = word[b];
                end
                w++;
            end
            @(negedge clk); otp_prog_en = 1'b0;
            @(negedge clk);                    // lock
            otp_prog_en   = 1'b1;
            otp_prog_addr = 9'h1FF;            // all-ones, out of valid 0-255 range
            otp_prog_data = 1'b1;
            @(negedge clk); otp_prog_en = 1'b0;
            otp_test_mode = 1'b0;
            $fclose(fd);
        end
    endtask

    // -----------------------------------------------------------------
    // CSR bus primitives.
    // gnt is combinational/immediate (csr_gnt_o = csr_req_i), and
    // rvalid_o/rdata_o are registered one cycle behind req. Drive
    // req/we/addr/wdata from a negedge so they're stable across the
    // posedge the DUT samples on, then sample the registered response
    // from the following negedge.
    // -----------------------------------------------------------------
    task automatic csr_write(input logic [11:0] addr, input logic [31:0] data);
        begin
            @(negedge clk);
            csr_req_i   = 1'b1;
            csr_we_i    = 1'b1;
            csr_be_i    = 4'hF;
            csr_addr_i  = {20'h0, addr};
            csr_wdata_i = data;
            @(negedge clk);   // holds req/we/addr/wdata stable across one posedge
            csr_req_i   = 1'b0;
            csr_we_i    = 1'b0;
        end
    endtask

    task automatic csr_read(input logic [11:0] addr, output logic [31:0] data);
        begin
            @(negedge clk);
            csr_req_i  = 1'b1;
            csr_we_i   = 1'b0;
            csr_be_i   = 4'hF;
            csr_addr_i = {20'h0, addr};
            @(negedge clk);   // rvalid_o/rdata_o now reflect this request
            data = csr_rdata_o;
            csr_req_i  = 1'b0;
        end
    endtask

    // -----------------------------------------------------------------
    // Task: drive R_IN x8 / S_IN x8 / MSG_LEN / CTRL.start / DATA_IN
    // from flash.mem, exactly mirroring the BootROM pseudocode:
    //   file layout: [word0 = total word count fed to SHA (R+pubkey+msg)]
    //                [8 words R] [8 words S] [remaining words = message]
    // -----------------------------------------------------------------
    int unsigned data_wait_iters = 0; // counts extra poll spins on DATA_IN handshake

    task automatic drive_flash_mem(string path);
        integer fd, code;
        logic [31:0] word;
        logic [31:0] msg_len_word;
        logic [31:0] r_words [0:7];
        logic [31:0] s_words [0:7];
        logic [31:0] status;
        int i;
        int spins;
        begin
            fd = $fopen(path, "r");
            if (fd == 0) $fatal(1, "Cannot open %s", path);

            // word 0 — total SHA word count
            code = $fscanf(fd, "%h\n", msg_len_word);
            if (code != 1) $fatal(1, "flash.mem missing length word");

            // next 8 — R
            for (i = 0; i < 8; i++) begin
                code = $fscanf(fd, "%h\n", word);
                if (code != 1) $fatal(1, "flash.mem short on R words");
                r_words[i] = word;
            end

            // next 8 — S
            for (i = 0; i < 8; i++) begin
                code = $fscanf(fd, "%h\n", word);
                if (code != 1) $fatal(1, "flash.mem short on S words");
                s_words[i] = word;
            end

            // Firmware order: R_IN x8, S_IN x8, MSG_LEN, then CTRL.start
            for (i = 0; i < 8; i++) csr_write(RIN_OFF, r_words[i]);
            for (i = 0; i < 8; i++) csr_write(SIN_OFF, s_words[i]);
            csr_write(MSGLEN_OFF, msg_len_word);
            csr_write(CTRL_OFF, 32'h1); // start

            // Remaining words = message body, fed one at a time behind
            // STATUS.ready_for_word — this is the actual CPU-paced
            // single-word handshake under test.
            while (!$feof(fd)) begin
                code = $fscanf(fd, "%h\n", word);
                if (code != 1) continue;

                spins = 0;
                csr_read(STATUS_OFF, status);
                while (!status[ST_READY]) begin
                    spins++;
                    csr_read(STATUS_OFF, status);
                end
                if (spins > 0) data_wait_iters += spins;

                csr_write(DATAIN_OFF, word);
            end

            $fclose(fd);
        end
    endtask

    int fail = 0;

    initial begin
        $display("==================================================");
        $display("Starting Secure Boot Simulation (CSR Firmware TB)...");
        $display("==================================================");

        csr_req_i = 0; csr_we_i = 0; csr_be_i = 4'h0;
        csr_addr_i = 0; csr_wdata_i = 0;
        start_verify = 0;
        otp_prog_en = 0; otp_prog_addr = 0; otp_prog_data = 0; otp_test_mode = 0;

        @(negedge clk); rst_n = 1;   // negedge avoids racing otp's sync-reset flop
        repeat(2) @(posedge clk);

        // 1. Program OTP with the pubkey generated by sign_firmware.py / build_mem.py
        program_otp_from_file("rtl/crypto/scripts/mems/pubkey.mem");

        repeat(5) @(posedge clk);

        // 2. Drive R_IN/S_IN/MSG_LEN/CTRL.start, then stream DATA_IN
        //    word-by-word behind STATUS.ready_for_word — replaces the old
        //    FIFO-backpressured stream_flash_mem task.
        drive_flash_mem("rtl/crypto/scripts/mems/flash.mem");

        // Allow time for SHA processing and OTP reads after the last
        // DATA_IN write. Confirmed sufficient for a 512KB firmware run;
        // re-check if firmware size changes substantially.
        repeat(20000) @(posedge clk);

        @(posedge clk); #1;
        start_verify = 1;
        @(posedge clk); #1;
        start_verify = 0;

        wait(verify_done);
        @(posedge clk);

        $display("==================================================");
        if (sig_valid) begin
            $display("SUCCESS: signature_valid=1, signature verified correctly");
        end else begin
            $display("FAILURE: signature_valid=0, verification failed on valid signature");
            fail++;
        end

        if (boot_active) begin
            $display("FAILURE: boot_active did not deassert after verify_done");
            fail++;
        end else begin
            $display("PASS: boot_active correctly deasserted after verify_done");
        end

        if (data_wait_iters == 0) begin
            $display("NOTE: STATUS.ready_for_word was always set on first poll —");
            $display("      the wait side of the handshake was never exercised.");
        end else begin
            $display("PASS: DATA_IN handshake made the TB poll-spin %0d time(s) —",
                      data_wait_iters);
            $display("      CPU-paced ready/busy backpressure is real.");
        end

        if (fail == 0)
            $display("SUCCESS: all functional tests passed");
        else
            $display("FAILURE: %0d test(s) failed", fail);

        $finish;
    end

    initial #200000000 begin
        $display("FAILURE: timeout waiting for verify_done");
        $finish;
    end

endmodule