module clint_obi #(
  parameter int unsigned AW = 32,   // OBI address width
  parameter int unsigned DW = 32    // OBI data width
)(
  input  logic            clk_i,
  input  logic            rst_ni,

  // ── OBI Slave Interface ──────────────────────────────────────────────────
  input  logic            req_i,
  output logic            gnt_o,
  output logic            rvalid_o,
  input  logic [AW-1:0]   addr_i,
  input  logic            we_i,
  input  logic [DW/8-1:0] be_i,
  input  logic [DW-1:0]   wdata_i,
  output logic [DW-1:0]   rdata_o,
  output logic            err_o,

  // ── Interrupt Outputs → Ibex ─────────────────────────────────────────────
  output logic            msip_o,   // → irq_software_i
  output logic            mtip_o    // → irq_timer_i
);

  // ==========================================================================
  // Internal registers
  // ==========================================================================
  logic        msip_q;            // Machine software interrupt pending (1 bit)
  logic [63:0] mtimecmp_q;        // Machine timer compare register
  logic [63:0] mtime_q;           // Free-running machine timer counter

  // ==========================================================================
  // OBI Control
  // ==========================================================================
  // Simple register peripheral: always ready to accept requests
  assign gnt_o = 1'b1;
  
  logic do_access;
  assign do_access = req_i & gnt_o;
  
  logic is_write;
  assign is_write = do_access & we_i;

  // Helper: apply byte enables to a 32-bit register field
  function automatic logic [31:0] apply_be(
    input logic [31:0] current,
    input logic [31:0] wdata,
    input logic [3:0]  be
  );
    logic [31:0] result;
    for (int b = 0; b < 4; b++) begin
      result[b*8 +: 8] = be[b] ? wdata[b*8 +: 8] : current[b*8 +: 8];
    end
    return result;
  endfunction

  // ==========================================================================
  // Register write logic & Timer increment
  // ==========================================================================
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      msip_q     <= 1'b0;
      mtimecmp_q <= 64'hFFFF_FFFF_FFFF_FFFF;  // max value → timer off on reset
      mtime_q    <= 64'h0;
    end else begin
      // ── Free-running mtime (increments every cycle) ───────────────────────
      // Write to mtime_lo / mtime_hi overrides the counter for that half.
      if (is_write && (addr_i[15:0] == 16'hBFF8)) begin
        // Write to mtime_lo — update the low half, keep high
        mtime_q[31:0]  <= apply_be(mtime_q[31:0],  wdata_i, be_i);
        mtime_q[63:32] <= mtime_q[63:32] + 1'b0;  // high word just continues
      end else if (is_write && (addr_i[15:0] == 16'hBFFC)) begin
        // Write to mtime_hi
        mtime_q[63:32] <= apply_be(mtime_q[63:32], wdata_i, be_i);
        mtime_q[31:0]  <= mtime_q[31:0] + 1'b1;  // keep incrementing low word
      end else begin
        // Normal free-running increment
        mtime_q <= mtime_q + 64'h1;
      end

      // ── MSIP ─────────────────────────────────────────────────────────────
      if (is_write && (addr_i[15:0] == 16'h0000)) begin
        msip_q <= be_i[0] ? wdata_i[0] : msip_q;
      end

      // ── MTIMECMP ─────────────────────────────────────────────────────────
      if (is_write && (addr_i[15:0] == 16'h4000)) begin
        mtimecmp_q[31:0]  <= apply_be(mtimecmp_q[31:0],  wdata_i, be_i);
      end
      if (is_write && (addr_i[15:0] == 16'h4004)) begin
        mtimecmp_q[63:32] <= apply_be(mtimecmp_q[63:32], wdata_i, be_i);
      end
    end
  end

  // ==========================================================================
  // Read path & Response phase
  // ==========================================================================
  logic [31:0] read_data;
  logic        addr_err;

  // Combinational read decode
  always_comb begin
    read_data = 32'h0;
    addr_err  = 1'b0;

    if (do_access) begin
      unique case (addr_i[15:0])
        16'h0000: read_data = {31'h0, msip_q};
        16'h4000: read_data = mtimecmp_q[31:0];
        16'h4004: read_data = mtimecmp_q[63:32];
        16'hBFF8: read_data = mtime_q[31:0];
        16'hBFFC: read_data = mtime_q[63:32];
        default:  addr_err  = 1'b1;  // Flag error on unmapped offsets
      endcase
    end
  end

  // 1-cycle latency response
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      rvalid_o <= 1'b0;
      rdata_o  <= '0;
      err_o    <= 1'b0;
    end else begin
      rvalid_o <= do_access;
      if (do_access) begin
        rdata_o <= we_i ? 32'h0 : read_data; // Drive 0 on writes
        err_o   <= addr_err;
      end else begin
        err_o   <= 1'b0;
      end
    end
  end

  // ==========================================================================
  // Interrupt outputs
  // ==========================================================================
  assign mtip_o = (mtime_q >= mtimecmp_q);
  assign msip_o = msip_q;

endmodule