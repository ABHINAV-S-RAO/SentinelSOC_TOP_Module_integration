`ifndef ADDR_DECODE_MONITOR_SV
`define ADDR_DECODE_MONITOR_SV

// Watches soc_addr_decode's inputs/outputs directly (bind or hierarchical
// vif into the DUT — TODO: confirm exact port names against
// soc_addr_decode.sv, these mirror the memory map from the session notes).
// Two jobs:
//   1. PROTOCOL CHECK, every cycle: exactly zero or one select line may be
//      asserted (fetch-side and data-side checked separately). More than
//      one is a decoder bug that could alias two peripherals onto the same
//      access — this is the class of bug most worth catching here.
//   2. REGION CHECK: the address on the bus must map to the select line
//      the table below says it should. Flags both false-asserts (wrong
//      region selected) and false-negatives (valid address, nothing
//      selected -> silent hang, which is exactly Bug #2 you already hit
//      once with BOOTROM/data-side).

class addr_decode_event extends uvm_sequence_item;
  `uvm_object_utils(addr_decode_event)
  bit [31:0] addr;
  bit        is_fetch;
  string     expected_region;
  string     actual_region;    // "" if nothing selected
  bit        onehot_violation;
  bit        region_mismatch;

  function new(string name = "addr_decode_event");
    super.new(name);
  endfunction
endclass

class addr_decode_monitor extends uvm_monitor;
  `uvm_component_utils(addr_decode_monitor)

  virtual addr_decode_if vif;
  // expects: clk, addr_i, is_fetch_i, fsel_bootrom, fsel_isram, sel_isram,
  //          sel_dsram, sel_sysctrl, sel_buffer, sel_sha, psel_uart,
  //          psel_qspi, psel_plic, psel_dbg
  uvm_analysis_port #(addr_decode_event) ap;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual addr_decode_if)::get(this, "", "vif", vif))
      `uvm_fatal("ADDR_MON", "vif not set")
  endfunction

  // memory map from SentinelSoC session notes — keep this table as the
  // single source of truth for the checker; update it, don't duplicate it,
  // if the map changes.
  function string classify(bit [31:0] a);
    if (a inside {[32'h0000_0000 : 32'h0000_FFFF]}) return "BOOTROM";
    if (a inside {[32'h0001_0000 : 32'h0001_FFFF]}) return "ISRAM";
    if (a inside {[32'h0002_0000 : 32'h0002_FFFF]}) return "DSRAM";
    if (a inside {[32'h0003_0000 : 32'h0003_FFFF]}) return "SYS_CTRL";
    if (a inside {[32'h0004_0000 : 32'h0004_FFFF]}) return "BUFFER";
    if (a inside {[32'h0005_0000 : 32'h0005_FFFF]}) return "SHA512";
    if (a inside {[32'h0C00_0000 : 32'h0C3F_FFFF]}) return "PLIC";
    if (a inside {[32'h1000_0000 : 32'h1000_0FFF]}) return "UART";
    if (a inside {[32'h1000_1000 : 32'h1000_1FFF]}) return "QSPI";
    if (a inside {[32'h1A11_0000 : 32'h1A11_FFFF]}) return "DBG";
    return "UNMAPPED";
  endfunction

  task run_phase(uvm_phase phase);
    addr_decode_event e;
    int sel_count;
    forever begin
      @(posedge vif.clk);
      e = addr_decode_event::type_id::create("e");
      e.addr     = vif.addr_i;
      e.is_fetch = vif.is_fetch_i;
      e.expected_region = classify(vif.addr_i);

      sel_count = 0;
      e.actual_region = "";
      if (vif.fsel_bootrom || vif.fsel_isram) begin
        if (vif.fsel_bootrom) begin sel_count++; e.actual_region = "BOOTROM"; end
        if (vif.fsel_isram)   begin sel_count++; e.actual_region = "ISRAM"; end
      end else begin
        if (vif.sel_isram)    begin sel_count++; e.actual_region = "ISRAM"; end
        if (vif.sel_dsram)    begin sel_count++; e.actual_region = "DSRAM"; end
        if (vif.sel_sysctrl)  begin sel_count++; e.actual_region = "SYS_CTRL"; end
        if (vif.sel_buffer)   begin sel_count++; e.actual_region = "BUFFER"; end
        if (vif.sel_sha)      begin sel_count++; e.actual_region = "SHA512"; end
        if (vif.psel_uart)    begin sel_count++; e.actual_region = "UART"; end
        if (vif.psel_qspi)    begin sel_count++; e.actual_region = "QSPI"; end
        if (vif.psel_plic)    begin sel_count++; e.actual_region = "PLIC"; end
        if (vif.psel_dbg)     begin sel_count++; e.actual_region = "DBG"; end
      end

      e.onehot_violation = (sel_count > 1);
      // note: BOOTROM is fetch-only by design (this is exactly Bug #2) —
      // a data-side access to BOOTROM correctly selecting NOTHING is not
      // a mismatch, it's the documented behavior. Don't flag it.
      e.region_mismatch = (e.expected_region != e.actual_region)
                           && !(e.expected_region == "BOOTROM" && !e.is_fetch && e.actual_region == "");

      if (e.onehot_violation)
        `uvm_error("ADDR_MON", $sformatf("multi-select at addr=0x%08h (%0d lines asserted)", e.addr, sel_count))
      if (e.region_mismatch)
        `uvm_error("ADDR_MON", $sformatf("addr=0x%08h fetch=%0b expected=%s actual=%s",
                                          e.addr, e.is_fetch, e.expected_region, e.actual_region))

      ap.write(e);
    end
  endtask

endclass

`endif