`ifndef SOC_COVERAGE_SV
`define SOC_COVERAGE_SV

// One collector per checked interface, each fed by the corresponding
// monitor's analysis port via analysis_imp (bound in soc_env.sv). Coverage
// closure against this class IS the "exhaustive" part of the test plan —
// TESTPLAN.md lists which firmware/test_all.s additions are needed to hit
// each bin, since stimulus comes from firmware, not from a sequence you
// can just constrain-random.

class soc_coverage extends uvm_component;
  `uvm_component_utils(soc_coverage)

  uvm_analysis_imp_addr #(addr_decode_event, soc_coverage) addr_imp;
  uvm_analysis_imp_qspi #(qspi_txn,          soc_coverage) qspi_imp;
  uvm_analysis_imp_dift #(dift_event,        soc_coverage) dift_imp;
  uvm_analysis_imp_apb  #(apb_txn,           soc_coverage) apb_imp;

  addr_decode_event a_ev;
  qspi_txn          q_ev;
  dift_event        d_ev;
  apb_txn           u_ev;

  // -- address decoder: every region, plus every region's boundary bytes
  covergroup addr_cg;
    option.per_instance = 1;
    region: coverpoint a_ev.region_id {
      bins regions[] = {REGION_BOOTROM, REGION_ISRAM, REGION_DSRAM, REGION_SYS_CTRL,
                        REGION_BUFFER, REGION_SHA512, REGION_UART, REGION_QSPI,
                        REGION_PLIC, REGION_DBG, REGION_UNMAPPED};
    }
    fetch: coverpoint a_ev.is_fetch;
    boundary: coverpoint a_ev.addr {
      bins bootrom_lo  = {32'h0000_0000};
      bins bootrom_hi  = {32'h0000_FFFF};
      bins isram_lo    = {32'h0001_0000};
      bins isram_hi    = {32'h0001_FFFF};
      bins dsram_lo    = {32'h0002_0000};
      bins dsram_hi    = {32'h0002_FFFF};
      bins dsram_sentinel = {32'h0002_0008}; // status sentinel address specifically
      bins uart_lo     = {32'h1000_0000};
      bins qspi_lo     = {32'h1000_1000};
      bins gap_just_below_qspi = {32'h1000_0FFF}; // one below QSPI base: must NOT select QSPI
      bins gap_between_sysctrl_and_buffer = {32'h0003_FFFF, 32'h0004_0000};
      bins others = default;
    }
    region_x_fetch: cross region, fetch;
    violation: coverpoint (a_ev.onehot_violation || a_ev.region_mismatch);
  endgroup

  // -- QSPI: mode x opcode x dummy-cycle-count, plus back-to-back reads
  covergroup qspi_cg;
    option.per_instance = 1;
    mode: coverpoint q_ev.mode {
      bins std = {2'b00}; bins quad_tx = {2'b01}; bins quad_rx = {2'b10};
    }
    dummy: coverpoint q_ev.dummy_cycles {
      bins low = {[0:3]}; bins mid = {[4:7]}; bins high = {[8:$]};
    }
    xfer_len: coverpoint q_ev.data.size() {
      bins single_byte = {1};
      bins multi_byte  = {[2:15]};
      bins burst       = {[16:$]}; // crosses a page/word boundary at least once
    }
    mode_x_dummy: cross mode, dummy;
    mode_x_len: cross mode, xfer_len;
  endgroup

  // -- DIFT: tag value x load/store x exception
  covergroup dift_cg;
    option.per_instance = 1;
    tag: coverpoint d_ev.tag_in;
    ld:  coverpoint d_ev.is_load;
    exc: coverpoint d_ev.exception;
    tag_x_ld_x_exc: cross tag, ld, exc;
  endgroup

  // -- UART: TX vs RX, and PSLVERR access (misaligned/illegal offset)
  covergroup uart_cg;
    option.per_instance = 1;
    offset: coverpoint u_ev.paddr[2:0] {
      bins thr_rbr = {3'h0};
      bins lsr     = {3'h5};
      bins other   = default;
    }
    dir: coverpoint u_ev.write;
    err: coverpoint u_ev.pslverr;
    offset_x_dir: cross offset, dir;
  endgroup

  function new(string name, uvm_component parent);
    super.new(name, parent);
    addr_imp = new("addr_imp", this);
    qspi_imp = new("qspi_imp", this);
    dift_imp = new("dift_imp", this);
    apb_imp  = new("apb_imp", this);
    addr_cg = new(); qspi_cg = new(); dift_cg = new(); uart_cg = new();
  endfunction

  function void write_addr(addr_decode_event e); a_ev = e; addr_cg.sample(); endfunction
  function void write_qspi(qspi_txn t);          q_ev = t; qspi_cg.sample(); endfunction
  function void write_dift(dift_event e);        d_ev = e; dift_cg.sample(); endfunction
  function void write_apb(apb_txn t);            if (t.periph == "UART") begin u_ev = t; uart_cg.sample(); end endfunction

  function void report_phase(uvm_phase phase);
    `uvm_info("COV", $sformatf(
      "addr=%.1f%% qspi=%.1f%% dift=%.1f%% uart=%.1f%%",
      addr_cg.get_coverage(), qspi_cg.get_coverage(), dift_cg.get_coverage(), uart_cg.get_coverage()),
      UVM_LOW)
  endfunction

endclass

`endif