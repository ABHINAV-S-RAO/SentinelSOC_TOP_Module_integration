// =============================================================================
// soc_ctrl_regs.sv
// Global Control and Status Register block
// Base address: 0x0003_0000
// Bus: OBI subordinate (flat signals, matched to soc_addr_decode outputs)
// Reset: active-low synchronous
//
// Register Map (word-addressed, 32-bit registers):
//
// Offset 0x00 — CTRL0 (RW)
//   [0]     isram_lock     : ISRAM write lock. Write-once sticky.
//                            Once set to 1, only reset can clear it.
//   [31:1]  reserved
//
// Offset 0x04 — STATUS0 (RO)
//   [0]     crypto_verified: Direct wire from SHA+ED25519 verified output.
//                            1 = firmware signature verified OK.
//                            0 = not yet verified or failed.
//   [1]     isram_locked   : Effective ISRAM write lock: the CTRL0 bit OR the
//                            hardware lock (isram_lock_hw_i, set when a secure-boot
//                            verification starts)
//   [2]     recovery_mode  : 1 = SoC booted in JTAG recovery mode (soc_recovery.sv):
//                            strap or boot watchdog. Sticky until power-on reset.
//                            Lets the recovery image know it was debugger-loaded.
//   [3]     recovery_wdt   : 1 = recovery was forced by the boot watchdog
//                            (boot never handed over), 0 = strap / none.
//   [31:4]  reserved
//
// Offset 0x08 — BOOT_STATUS (RO)
//   [0]     boot_done      : Boot sequence complete. Cleared only by reset.
//                            HW_BOOT_DONE=0: set by software via CTRL1.
//                            HW_BOOT_DONE=1: set by hardware (boot_done_hw_i, the
//                            first verified fetch at the firmware entry); CTRL1 has
//                            no effect.
//   [31:1]  reserved
//
// Offset 0x0C — CTRL1 (RW)
//   [0]     boot_done_set  : Write 1 to set boot_done in BOOT_STATUS (HW_BOOT_DONE=0
//                            only; ignored when HW_BOOT_DONE=1). Read always returns 0.
//   [31:1]  reserved
//
// Access policy (enforced in soc_addr_decode, not here): writes only while
// boot_done=0 and never from a debugger (core in debug mode); reads while
// boot_done=0 or from a debugger.
//
// NOTE: SEL_SHA slot kept in decoder — remove if SHA+ED25519 has no
//       OBI-accessible control/status registers after wrapper is finalized.
// =============================================================================

module soc_ctrl_regs #(
  // 1 = boot_done comes from hardware (boot_done_hw_i) and CTRL1 is ignored
  //     (SECURE_BOOT SoCs: soc_secure_boot fw_entered_o).
  // 0 = legacy: boot_done is set by software through CTRL1.
  parameter bit HW_BOOT_DONE = 1'b0
) (
  input  logic        clk_i,
  input  logic        rst_ni,

  // OBI subordinate interface (flat)
  input  logic        req_i,
  input  logic        we_i,
  input  logic [ 3:0] be_i,
  input  logic [31:0] addr_i,
  input  logic [31:0] wdata_i,
  output logic        gnt_o,
  output logic        rvalid_o,
  output logic [31:0] rdata_o,
  output logic        err_o,

  // Direct wire from SHA+ED25519 verification result
  // 1 = signature verified OK, 0 = not verified / failed
  input  logic        crypto_verified_i,

  // JTAG recovery status from soc_recovery (tie 1'b0 if not integrated)
  input  logic        recovery_i,
  input  logic        recovery_wdt_i,

  // Hardware boot_done (used when HW_BOOT_DONE=1) and hardware ISRAM lock
  // (ORed into the lock in every mode; tie 1'b0 if unused)
  input  logic        boot_done_hw_i,
  input  logic        isram_lock_hw_i,

  // Control outputs
  output logic        boot_done_o  ,  // feeds soc_addr_decode ctrl_boot_done_i
  output logic        isram_lock_o    // feeds soc_addr_decode ctrl_isram_lock_i
);

  // --------------------------------------------------------------------------
  // Register address offsets (word aligned)
  // --------------------------------------------------------------------------
  localparam logic [11:0] CTRL0_OFFSET       = 12'h000;
  localparam logic [11:0] STATUS0_OFFSET     = 12'h004;
  localparam logic [11:0] BOOT_STATUS_OFFSET = 12'h008;
  localparam logic [11:0] CTRL1_OFFSET       = 12'h00C;

  // --------------------------------------------------------------------------
  // Internal registers
  // --------------------------------------------------------------------------
  logic isram_lock_q;    // write-once sticky
  logic boot_done_q;     // software boot_done (HW_BOOT_DONE=0), cleared only by reset

  // --------------------------------------------------------------------------
  // OBI handshake
  // Grant immediately — single-cycle response, no wait states
  // rvalid follows one cycle after req+gnt
  // --------------------------------------------------------------------------
  assign gnt_o = req_i;

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) rvalid_o <= 1'b0;
    else         rvalid_o <= req_i & gnt_o;
  end

  assign err_o = 1'b0; // no error conditions in this block

  // --------------------------------------------------------------------------
  // Write logic
  // --------------------------------------------------------------------------
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      isram_lock_q <= 1'b0;
      boot_done_q  <= 1'b0;
    end else begin
      if (req_i && we_i) begin
        case (addr_i[11:0])

          CTRL0_OFFSET: begin
            // isram_lock is write-once sticky — once set it cannot be cleared
            // by software. Only a full reset clears it.
            if (be_i[0] && wdata_i[0]) begin
              isram_lock_q <= 1'b1;
            end
          end

          CTRL1_OFFSET: begin
            // boot_done_set: write 1 to permanently set boot_done.
            // Ignored when boot_done is owned by hardware.
            if (!HW_BOOT_DONE && be_i[0] && wdata_i[0]) begin
              boot_done_q <= 1'b1;
            end
          end

          default: ; // writes to read-only or reserved registers are silently ignored

        endcase
      end
    end
  end

  // --------------------------------------------------------------------------
  // Read logic
  // --------------------------------------------------------------------------
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      rdata_o <= 32'h0;
    end else begin
      if (req_i && !we_i) begin
        case (addr_i[11:0])

          CTRL0_OFFSET: begin
            rdata_o <= {31'h0, isram_lock_o};
          end

          STATUS0_OFFSET: begin
            rdata_o <= {28'h0, recovery_wdt_i, recovery_i, isram_lock_o, crypto_verified_i};
          end

          BOOT_STATUS_OFFSET: begin
            rdata_o <= {31'h0, boot_done_o};
          end

          CTRL1_OFFSET: begin
            rdata_o <= 32'h0; // boot_done_set always reads 0
          end

          default: begin
            rdata_o <= 32'hDEAD_BEEF; // unmapped offset within ctrl block
          end

        endcase
      end
    end
  end

  // --------------------------------------------------------------------------
  // Output assignments
  // --------------------------------------------------------------------------
  assign isram_lock_o = isram_lock_q | isram_lock_hw_i;
  assign boot_done_o  = HW_BOOT_DONE ? boot_done_hw_i : boot_done_q;

endmodule
