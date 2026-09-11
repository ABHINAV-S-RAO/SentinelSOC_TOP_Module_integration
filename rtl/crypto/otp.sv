`timescale 1ns / 1ps
module otp #(
    parameter RD_ADDRW     = 3,                    // word address: 256/32 = 8 words
    parameter PUB_KEY_BITS = 256,
    parameter PROG_ADDRW   = $clog2(PUB_KEY_BITS) + 1  // bit address + 1 spare bit for lock sentinel
)(
    input  logic clk,
    input  logic rst,
    input  logic boot_active,

    input  logic rd_en,
    input  logic [RD_ADDRW-1:0] rd_addr,
    output logic [31:0] rd_data,

    input  logic prog_en,
    input  logic [PROG_ADDRW-1:0] prog_addr,
    input  logic prog_data,
    input  logic test_mode,

    output logic otp_lock
);

    logic [PUB_KEY_BITS-1:0] otp_mem;
    logic lock_bit;

    assign otp_lock = lock_bit;

    localparam logic [PROG_ADDRW-1:0] LOCK_SENTINEL = {PROG_ADDRW{1'b1}}; // out of valid range

    // --- Read path: combinational, zero-latency ---
    // NOTE: was previously registered (always_ff), which meant rd_data only became
    // valid one cycle after rd_en, and reverted to 0 as soon as rd_en dropped.
    // top_most's OTP_REQ -> OTP_LATCH protocol holds rd_en high for exactly one
    // cycle and samples rd_data on that same cycle, so a registered read could
    // never be observed as valid. Changed to combinational to match that protocol.
    always_comb begin
        if (boot_active && rd_en) rd_data = otp_mem[rd_addr*32 +: 32];
        else                      rd_data = 32'h0;
    end

    // --- Program/lock path: unchanged, registered (real writes need a clock) ---
    always_ff @(posedge clk) begin
        if (rst) begin
            lock_bit <= 1'b0;
        end else begin
            if (prog_en && test_mode && !lock_bit && prog_addr < PUB_KEY_BITS)
                otp_mem[prog_addr] <= prog_data;

            if (prog_en && test_mode && prog_addr == LOCK_SENTINEL && prog_data == 1'b1)
                lock_bit <= 1'b1;
        end
    end

endmodule