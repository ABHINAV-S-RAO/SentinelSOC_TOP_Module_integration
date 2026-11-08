`uvm_analysis_imp_decl(_gobi)
`uvm_analysis_imp_decl(_gmon)

// Reference model + checker for apb_gpio (PAD_NUM=32) behind the OBI->APB bridge.
//  1. RW register readback incl. reset values: PADDIR GPIOEN PADOUT INTEN INTTYPE0/1 PADCFG0-3
//  2. Reads that must be 0: PADOUTSET/CLR, pin 32-63 bank (0x38-0x6C)
//  3. Pad level every settled cycle: PADDIR=1 -> PADOUT bit; PADDIR=0 & VIP idle -> Z; VIP driving -> VIP value
//  4. PADIN vs pad level. Input clock is gated per GROUP OF 4 PINS (any GPIOEN bit in the group enables it)
//  5. INTSTATUS vs edge model (INTEN & GPIOEN[i] & INTTYPE 2-bit field), clear-on-read
//  6. OBI err (PSLVERR is tied 0 in RTL)
//  7. report_phase: errors if a check category ran fewer times than cfg.min_*
class GpioScoreboard extends uvm_scoreboard;
  `uvm_component_utils(GpioScoreboard)

  uvm_analysis_imp_gobi #(gpio_obi_txn, GpioScoreboard) gobi_export;
  uvm_analysis_imp_gmon #(gpio_mon_txn, GpioScoreboard) gmon_export;

  GpioEnvConfig cfg;

  bit [31:0] dir, gpioen, out, inten, intt0, intt1;
  bit [31:0] padcfg[4];
  bit [31:0] status_exp;

  bit [31:0] vip_en, vip_val;

  longint unsigned cur_cyc, last_stim_cyc;
  bit              have_first;

  bit [31:0] pad_prev, pad_known_prev;
  bit [31:0] last_mism;
  bit        tb_cont_reported;

  int unsigned n_pin, n_rd, n_padin, n_padin_skip, n_int, n_int_skip;

  function new(string name = "GpioScoreboard", uvm_component parent = null);
    super.new(name, parent);
    gobi_export = new("gobi_export", this);
    gmon_export = new("gmon_export", this);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(GpioEnvConfig)::get(this, "", "gpioEnvConfig", cfg))
      `uvm_fatal("GPIOSB", "cannot get gpioEnvConfig from uvm_config_db")
  endfunction

  // ---------------------------------------------------------------- helpers
  // input sync flops of pin i run only if any GPIOEN bit in its nibble is set
  function bit grp_en(int i);
    return |gpioen[(i/4)*4 +: 4];
  endfunction

  function void get_pad(output bit [31:0] ex, output bit [31:0] kn);
    ex = '0; kn = '0;
    for (int i = 0; i < 32; i++) begin
      if (!grp_en(i)) continue;
      if (!dir[i] && vip_en[i]) begin
        ex[i] = vip_val[i]; kn[i] = 1;
      end
      else if (dir[i] && !vip_en[i] && cfg.padin_sees_outputs) begin
        ex[i] = out[i]; kn[i] = 1;
      end
    end
  endfunction

  function bit int_event(bit [1:0] t, bit rise, bit fall);
    case (t)
      GPIO_INT_FALL: return fall;
      GPIO_INT_RISE: return rise;
      GPIO_INT_BOTH: return rise | fall;
      default:       return 0;
    endcase
  endfunction

  function void note_stim(longint unsigned c);
    if (c > last_stim_cyc) last_stim_cyc = c;
  endfunction

  // ---------------------------------------------------------------- pin side (every clock)
  virtual function void write_gmon(gpio_mon_txn m);
    bit [31:0] en_n, val_n;
    en_n  = m.vip_en;
    val_n = m.vip_val;
    cur_cyc = m.cyc;

    if (!have_first) begin
      have_first = 1;
      vip_en = en_n; vip_val = val_n;
      last_stim_cyc = m.cyc;
    end
    if (en_n !== vip_en || val_n !== vip_val) begin
      vip_en = en_n; vip_val = val_n;
      note_stim(m.cyc);
    end

    if (cfg.model_intstatus) update_int_model();

    if (cur_cyc - last_stim_cyc >= cfg.settle_cycles) begin
      if (cur_cyc - last_stim_cyc == cfg.settle_cycles) n_pin++;
      check_pins(m);
    end
  endfunction

  function void update_int_model();
    bit [31:0] ex, kn;
    get_pad(ex, kn);
    for (int i = 0; i < 32; i++) begin
      if (kn[i] && pad_known_prev[i]) begin
        bit        rise = !pad_prev[i] &&  ex[i];
        bit        fall =  pad_prev[i] && !ex[i];
        bit [31:0] rg   = (i < 16) ? intt0 : intt1;
        bit [1:0]  ty   = rg[2*(i%16) +: 2];
        if (inten[i] && gpioen[i] && int_event(ty, rise, fall))
          status_exp[i] = 1;
      end
    end
    pad_prev       = ex;
    pad_known_prev = kn;
  endfunction

  function void check_pins(gpio_mon_txn m);
    bit [31:0] mism = '0;
    for (int i = 0; i < 32; i++) begin
      logic e;
      bit   chk = 0;
      if (cfg.gpioen_gates_output && !gpioen[i]) continue;
      if (dir[i] && vip_en[i]) begin
        if (!tb_cont_reported) begin
          tb_cont_reported = 1;
          `uvm_error("GPIOSB_TB", $sformatf("TB contention: pin[%0d] PADDIR=1 while VIP drives it (release VIP before making the pad an output)", i))
        end
      end
      else if (dir[i])    begin e = out[i];     chk = 1; end
      else if (vip_en[i]) begin e = vip_val[i]; chk = 1; end
      else if (cfg.check_hiz_on_input) begin e = 1'bz; chk = 1; end
      if (chk && (m.pins[i] !== e)) mism[i] = 1;
    end
    if (mism != '0 && mism != last_mism)
      `uvm_error("GPIOSB_PIN", $sformatf("pad mismatch mask=%08h | pins=%b | dir=%08h out=%08h en=%08h vip_en=%08h vip_val=%08h",
                                        mism, m.pins, dir, out, gpioen, vip_en, vip_val))
    last_mism = mism;
  endfunction

  // ---------------------------------------------------------------- bus side
  virtual function void write_gobi(gpio_obi_txn t);
    bit [31:0] off;
    if (t.addr < GPIO_BASE || t.addr >= GPIO_BASE + 32'h1000) return;
    off = t.addr - GPIO_BASE;

    if (t.err && off < 32'h70)
      `uvm_error("GPIOSB_ERR", $sformatf("OBI err on GPIO access off=0x%0h we=%0b (PSLVERR is tied 0)", off, t.we))

    if (t.we) do_write(off, t);
    else      do_read(off, t);
  endfunction

  function void do_write(bit [31:0] off, gpio_obi_txn t);
    case (off)
      GPIO_PADDIR:    begin dir    = t.wdata;  note_stim(t.cyc); end
      GPIO_GPIOEN:    begin gpioen = t.wdata;  note_stim(t.cyc); end
      GPIO_PADOUT:    begin out    = t.wdata;  note_stim(t.cyc); end
      GPIO_PADOUTSET: begin out   |= t.wdata;  note_stim(t.cyc); end
      GPIO_PADOUTCLR: begin out   &= ~t.wdata; note_stim(t.cyc); end
      GPIO_INTEN:     begin inten  = t.wdata;  note_stim(t.cyc); end
      GPIO_INTTYPE0:  begin intt0  = t.wdata;  note_stim(t.cyc); end
      GPIO_INTTYPE1:  begin intt1  = t.wdata;  note_stim(t.cyc); end
      GPIO_PADCFG0:   padcfg[0] = t.wdata;
      GPIO_PADCFG1:   padcfg[1] = t.wdata;
      GPIO_PADCFG2:   padcfg[2] = t.wdata;
      GPIO_PADCFG3:   padcfg[3] = t.wdata;
      default: ;      // PADIN, INTSTATUS, upper bank: write ignored
    endcase
  endfunction

  function void rd_cmp(string nm, bit [31:0] exp_v, gpio_obi_txn t);
    n_rd++;
    if (t.rdata !== exp_v)
      `uvm_error("GPIOSB_RD", $sformatf("%s read mismatch: expected=%08h actual=%h", nm, exp_v, t.rdata))
  endfunction

  function void do_read(bit [31:0] off, gpio_obi_txn t);
    case (off)
      GPIO_PADDIR:    rd_cmp("PADDIR",   dir,       t);
      GPIO_GPIOEN:    rd_cmp("GPIOEN",   gpioen,    t);
      GPIO_PADOUT:    rd_cmp("PADOUT",   out,       t);
      GPIO_INTEN:     rd_cmp("INTEN",    inten,     t);
      GPIO_INTTYPE0:  rd_cmp("INTTYPE0", intt0,     t);
      GPIO_INTTYPE1:  rd_cmp("INTTYPE1", intt1,     t);
      GPIO_PADCFG0:   rd_cmp("PADCFG0",  padcfg[0], t);
      GPIO_PADCFG1:   rd_cmp("PADCFG1",  padcfg[1], t);
      GPIO_PADCFG2:   rd_cmp("PADCFG2",  padcfg[2], t);
      GPIO_PADCFG3:   rd_cmp("PADCFG3",  padcfg[3], t);
      GPIO_PADOUTSET: rd_cmp("PADOUTSET", 32'h0,    t);
      GPIO_PADOUTCLR: rd_cmp("PADOUTCLR", 32'h0,    t);
      GPIO_PADIN:     check_padin(t);
      GPIO_INTSTATUS: check_intstatus(t);
      default: if (off >= GPIO_UPPER_FIRST && off <= GPIO_UPPER_LAST) rd_cmp("UPPER_BANK", 32'h0, t);
    endcase
  endfunction

  function void check_padin(gpio_obi_txn t);
    bit [31:0] ex, kn;
    if (t.cyc - last_stim_cyc < cfg.settle_cycles) begin n_padin_skip++; return; end
    get_pad(ex, kn);
    if (kn == '0) begin n_padin_skip++; return; end
    n_padin++;
    if ((t.rdata & kn) !== (ex & kn))
      `uvm_error("GPIOSB_PADIN", $sformatf("PADIN mismatch: mask=%08h expected=%08h actual=%h", kn, ex & kn, t.rdata & kn))
  endfunction

  function void check_intstatus(gpio_obi_txn t);
    if (!cfg.model_intstatus) return;
    if (t.cyc - last_stim_cyc < cfg.settle_cycles) begin
      n_int_skip++;
      `uvm_warning("GPIOSB_INT", "INTSTATUS read too close to stimulus - not checked (add an idle before the read)")
    end
    else begin
      n_int++;
      if (t.rdata !== status_exp)
        `uvm_error("GPIOSB_INT", $sformatf("INTSTATUS mismatch: expected=%08h actual=%h (INTEN=%08h T0=%08h T1=%08h)",
                                          status_exp, t.rdata, inten, intt0, intt1))
    end
    if (cfg.intstatus_clr_on_rd) status_exp = '0;
  endfunction

  virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("GPIOSB", $sformatf("checks done: pin_settle=%0d reg_rd=%0d padin=%0d (skipped %0d) intstatus=%0d (skipped %0d)",
              n_pin, n_rd, n_padin, n_padin_skip, n_int, n_int_skip), UVM_NONE)
    if (n_pin   < cfg.min_pin_checks)
      `uvm_error("GPIOSB_VACUOUS", $sformatf("pin checks %0d < required %0d", n_pin, cfg.min_pin_checks))
    if (n_rd    < cfg.min_rd_checks)
      `uvm_error("GPIOSB_VACUOUS", $sformatf("reg readback checks %0d < required %0d", n_rd, cfg.min_rd_checks))
    if (n_padin < cfg.min_padin_checks)
      `uvm_error("GPIOSB_VACUOUS", $sformatf("PADIN checks %0d < required %0d", n_padin, cfg.min_padin_checks))
    if (n_int   < cfg.min_int_checks)
      `uvm_error("GPIOSB_VACUOUS", $sformatf("INTSTATUS checks %0d < required %0d", n_int, cfg.min_int_checks))
  endfunction
endclass