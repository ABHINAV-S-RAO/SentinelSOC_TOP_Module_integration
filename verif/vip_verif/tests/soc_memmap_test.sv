// =============================================================================
// soc_memmap_test.sv -- memory-map decode test (checklist 6.7)
//
// "Every address range hit; unmapped access returns the defined error."
//
// The UVM CPU agent (no-core mode) accesses every region of final_soc_top's
// data map:
//   - the first and last word of each RAM/ROM window,
//   - a known register in every CSR / peripheral window (with reset values
//     checked where they are fixed),
//   - write + read-back on every writable RAM and on a few harmless registers,
//   - the address just past the end of each fixed-size window, the holes
//     between windows, unmapped offsets inside CLINT/PLIC, APB addresses with
//     no peripheral, and the top of the address space.
// Every access must complete (no hang) with the expected err bit.
//
// Expected results follow the RTL in this state: CPU switched off, so
// boot_done = 0, not in recovery, not in debug mode, ISRAM unlocked:
//   - soc_addr_decode: BootROM read OK / write -> error; ISRAM 8 KB; DSRAM,
//     CTRL, VERIFY 4 KB each; BUF unimplemented -> error; anything unmapped
//     -> error responder (DEAD_BEEF, err=1)
//   - clint_obi / plic_regmap: unknown offsets inside the window -> error
//   - final_soc_top APB mux: an APB address outside every peripheral window
//     -> PSLVERR -> error
// Writes are kept away from registers with side effects (CTRL0 would lock
// ISRAM, CLINT msip would raise a software interrupt, PLIC claim/complete).
// =============================================================================

class soc_memmap_seq extends uvm_sequence #(obi_seq_item);
  `uvm_object_utils(soc_memmap_seq)

  int n_checks;
  int n_fail;

  function new(string name = "soc_memmap_seq");
    super.new(name);
  endfunction

  // One access. exp_err: expected err bit. chk: also compare the read data.
  task access(string what, logic [31:0] a, bit we, logic [31:0] wd,
                        bit exp_err, bit chk = 1'b0, logic [31:0] exp = '0);
    obi_seq_item it;
    it = obi_seq_item::type_id::create("it");
    start_item(it);
    it.addr = a;
    it.we   = we;
    it.be   = 4'hF;
    it.data = wd;
    finish_item(it);

    n_checks++;
    if (it.err !== exp_err) begin
      n_fail++;
      `uvm_error("MEMMAP", $sformatf("[FAIL] %-34s %s %08h : err=%b, expected %b (rdata=%08h)",
                                     what, we ? "W" : "R", a, it.err, exp_err, it.data))
    end else if (!we && !exp_err && chk && it.data !== exp) begin
      n_fail++;
      `uvm_error("MEMMAP", $sformatf("[FAIL] %-34s R %08h : rdata=%08h, expected %08h",
                                     what, a, it.data, exp))
    end else begin
      `uvm_info("MEMMAP", $sformatf("[PASS] %-34s %s %08h : err=%b%s", what, we ? "W" : "R", a, it.err,
                                    (!we && !exp_err) ? $sformatf(" rdata=%08h", it.data) : ""), UVM_LOW)
    end
  endtask

  // Write a pattern and read it back
  task rw(string what, logic [31:0] a, logic [31:0] pat);
    access({what, " write"}, a, 1'b1, pat, 1'b0);
    access({what, " read-back"}, a, 1'b0, '0, 1'b0, 1'b1, pat);
  endtask

  task body();
    n_checks = 0;
    n_fail   = 0;

    // ---------------------------------------------------------------- BootROM
    access("BootROM first word",            32'h0000_0000, 0, '0, 0);
    access("BootROM last word",             32'h0000_0FFC, 0, '0, 0);
    access("BootROM write refused",         32'h0000_0000, 1, 32'h1234_5678, 1);
    access("hole after BootROM",            32'h0000_1000, 0, '0, 1);
    access("hole after BootROM (write)",    32'h0000_1000, 1, 32'h1, 1);
    access("hole below ISRAM",              32'h0000_FFFC, 0, '0, 1);

    // ---------------------------------------------------------------- ISRAM (8 KB)
    rw    ("ISRAM first word",              32'h0001_0000, 32'hA5A5_0001);
    rw    ("ISRAM last word",               32'h0001_1FFC, 32'h5A5A_0002);
    access("past ISRAM end (8 KB)",         32'h0001_2000, 0, '0, 1);

    // ---------------------------------------------------------------- DSRAM (4 KB)
    rw    ("DSRAM first word",              32'h0002_0000, 32'hC0DE_0003);
    rw    ("DSRAM last word",               32'h0002_0FFC, 32'hBEEF_0004);
    access("past DSRAM end (4 KB)",         32'h0002_1000, 0, '0, 1);

    // ---------------------------------------------------------------- CTRL
    access("CTRL0 (ISRAM lock = 0)",        32'h0003_0000, 0, '0, 0, 1, 32'h0);
    access("past CTRL window",              32'h0003_1000, 0, '0, 1);

    // ---------------------------------------------------------------- BUF (unimplemented)
    access("BUF window (unimplemented)",    32'h0004_0000, 0, '0, 1);

    // ---------------------------------------------------------------- VERIFY (secure boot)
    access("VERIFY_STATUS",                 32'h0005_0004, 0, '0, 0);
    access("VERIFY ENTRY = 0x0001_0044",    32'h0005_000C, 0, '0, 0, 1, 32'h0001_0044);
    access("past VERIFY window",            32'h0005_1000, 0, '0, 1);
    access("hole 0x0006_0000",              32'h0006_0000, 0, '0, 1);
    access("hole 0x0100_0000",              32'h0100_0000, 0, '0, 1);

    // ---------------------------------------------------------------- CLINT
    access("CLINT msip = 0",                32'h0200_0000, 0, '0, 0, 1, 32'h0);
    access("CLINT mtimecmp lo reset",       32'h0200_4000, 0, '0, 0, 1, 32'hFFFF_FFFF);
    access("CLINT mtimecmp hi reset",       32'h0200_4004, 0, '0, 0, 1, 32'hFFFF_FFFF);
    access("CLINT mtime lo",                32'h0200_BFF8, 0, '0, 0);
    access("CLINT mtime hi",                32'h0200_BFFC, 0, '0, 0);
    access("CLINT unmapped offset",         32'h0200_0008, 0, '0, 1);
    access("past CLINT window",             32'h0201_0000, 0, '0, 1);

    // ---------------------------------------------------------------- PLIC
    access("PLIC priority[1] = 0",          32'h0C00_0004, 0, '0, 0, 1, 32'h0);
    rw    ("PLIC priority[1]",              32'h0C00_0004, 32'h0000_0003);
    access("PLIC priority[1] restore",      32'h0C00_0004, 1, 32'h0, 0);
    access("PLIC pending",                  32'h0C00_1000, 0, '0, 0);
    access("PLIC enable = 0",               32'h0C00_2000, 0, '0, 0, 1, 32'h0);
    access("PLIC threshold = 0",            32'h0C20_0000, 0, '0, 0, 1, 32'h0);
    access("PLIC unmapped offset",          32'h0C00_0100, 0, '0, 1);
    access("past PLIC window (4 MB)",       32'h0C40_0000, 0, '0, 1);

    // ---------------------------------------------------------------- APB peripherals
    access("QSPI (0x1050_0000)",            32'h1050_0000, 0, '0, 0);
    access("Timer 0 VALUE",                 32'h1050_1000, 0, '0, 0);
    rw    ("Timer 0 CMP",                   32'h1050_1008, 32'h0000_1234);
    access("Timer 0 CMP restore",           32'h1050_1008, 1, 32'h0, 0);
    access("SPI #2 (0x1050_2000)",          32'h1050_2000, 0, '0, 0);
    access("UART LSR (0x1050_3014)",        32'h1050_3014, 0, '0, 0);
    access("GPIO (0x1060_0000)",            32'h1060_0000, 0, '0, 0);
    access("APB, no peripheral 0x1000_0000",32'h1000_0000, 0, '0, 1);
    access("APB, no peripheral 0x1050_4000",32'h1050_4000, 0, '0, 1);
    access("APB, past GPIO 0x1060_1000",    32'h1060_1000, 0, '0, 1);
    access("APB, no peripheral (write)",    32'h1050_4000, 1, 32'h1, 1);

    // ---------------------------------------------------------------- Debug module
    access("Debug module data0",            32'h1A11_0380, 0, '0, 0);
    access("APB, past debug module",        32'h1A12_0000, 0, '0, 1);

    // ---------------------------------------------------------------- above the map
    access("unmapped 0x2000_0000",          32'h2000_0000, 0, '0, 1);
    access("unmapped 0x2000_0000 (write)",  32'h2000_0000, 1, 32'h1, 1);
    access("unmapped 0x8000_0000",          32'h8000_0000, 0, '0, 1);
    access("unmapped 0xFFFF_FFFC",          32'hFFFF_FFFC, 0, '0, 1);

    // ---------------------------------------------------------------- still alive?
    // After all the error responses the bus must still work normally.
    rw    ("DSRAM after error responses",   32'h0002_0010, 32'h600D_B05E);
  endtask
endclass

class sentinel_soc_vip_memmap_test extends sentinel_soc_vip_base_test;
  `uvm_component_utils(sentinel_soc_vip_memmap_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    soc_memmap_seq seq;
    phase.raise_objection(this);

    wait (vif_obi.rst_ni === 1'b1);
    repeat (5) @(posedge vif_obi.clk_i);

    `uvm_info("MEMMAP", "--- memory-map decode test (checklist 6.7) ---", UVM_LOW)
    seq = soc_memmap_seq::type_id::create("seq");
    seq.start(cpu_agent.sequencer);

    if (seq.n_fail == 0)
      `uvm_info("MEMMAP", $sformatf(">>> MEMMAP PASSED: %0d accesses, every range hit, every unmapped access returned the error <<<",
                                    seq.n_checks), UVM_LOW)
    else
      `uvm_error("MEMMAP", $sformatf(">>> MEMMAP FAILED: %0d of %0d accesses wrong <<<", seq.n_fail, seq.n_checks))

    repeat (20) @(posedge vif_obi.clk_i);
    phase.drop_objection(this);
  endtask
endclass
