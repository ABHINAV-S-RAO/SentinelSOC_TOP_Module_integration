// Virtual sequences: drive CPU accesses on the OBI sequencer and input pads on the
// GPIO sequencer from one thread. Checking is done by GpioScoreboard (except where noted).

class gpio_vseq_base extends uvm_sequence #(uvm_sequence_item);
  `uvm_object_utils(gpio_vseq_base)

  obi_sequencer                 obi_sqr;
  uvm_sequencer #(gpio_pin_txn) gpio_sqr;   // needs GpioAgentConfig.isActive = UVM_ACTIVE

  // Must be >= GpioEnvConfig.settle_cycles (+ margin). Every drive()/idle() lets the scoreboard settle.
  int unsigned settle_cyc = 10;

  protected bit [31:0] cur_en, cur_val;     // what the VIP is currently driving

  function new(string name = "gpio_vseq_base");
    super.new(name);
  endfunction

  task wr(bit [31:0] off, bit [31:0] data);
    obi_seq_item it = obi_seq_item::type_id::create("wr");
    start_item(it, -1, obi_sqr);
    it.addr = GPIO_BASE + off; it.data = data; it.we = 1; it.be = 4'hF;
    finish_item(it);
  endtask

  task rd(bit [31:0] off, output logic [31:0] data);
    obi_seq_item it = obi_seq_item::type_id::create("rd");
    start_item(it, -1, obi_sqr);
    it.addr = GPIO_BASE + off; it.data = '0; it.we = 0; it.be = 4'hF;
    finish_item(it);
    data = it.data;                          // driver stores rdata in item.data
  endtask

  // Apply VIP pad drive and hold for 'cycles' clocks. Value stays applied afterwards.
  task drive(bit [31:0] en, bit [31:0] val, int unsigned cycles = 0);
    gpio_pin_txn g = gpio_pin_txn::type_id::create("g");
    start_item(g, -1, gpio_sqr);
    g.drv_en = en; g.drv_val = val; g.hold_cycles = (cycles == 0) ? settle_cyc : cycles;
    finish_item(g);
    cur_en = en; cur_val = val;
  endtask

  task idle(int unsigned cycles = 0);
    drive(cur_en, cur_val, cycles);
  endtask

  task release_pins();
    drive('0, '0);
  endtask
endclass

// ---------------------------------------------------------------------------
// 1. Reset values of every register (scoreboard shadow resets to 0)
class gpio_reset_vseq extends gpio_vseq_base;
  `uvm_object_utils(gpio_reset_vseq)
  function new(string name = "gpio_reset_vseq"); super.new(name); endfunction
  task body();
    logic [31:0] d;
    idle(4);
    rd(GPIO_PADDIR, d);   rd(GPIO_GPIOEN, d);    rd(GPIO_PADOUT, d);
    rd(GPIO_INTEN, d);    rd(GPIO_INTTYPE0, d);  rd(GPIO_INTTYPE1, d);
    rd(GPIO_INTSTATUS, d);
  endtask
endclass

// ---------------------------------------------------------------------------
// 2. Register write/readback: walking 1, walking 0, random, on every RW register
class gpio_reg_rw_vseq extends gpio_vseq_base;
  `uvm_object_utils(gpio_reg_rw_vseq)
  int unsigned n_rand = 16;
  function new(string name = "gpio_reg_rw_vseq"); super.new(name); endfunction

  task wr_rd(bit [31:0] off, bit [31:0] v);
    logic [31:0] d;
    wr(off, v);
    rd(off, d);
  endtask

  task body();
    bit [31:0] regs[$] = {GPIO_PADDIR, GPIO_GPIOEN, GPIO_PADOUT, GPIO_INTEN, GPIO_INTTYPE0, GPIO_INTTYPE1,
                        GPIO_PADCFG0, GPIO_PADCFG1, GPIO_PADCFG2, GPIO_PADCFG3};
    foreach (regs[r]) begin
      for (int b = 0; b < 32; b++) begin
        wr_rd(regs[r],  32'h1 << b);
        wr_rd(regs[r], ~(32'h1 << b));
      end
      repeat (n_rand) wr_rd(regs[r], $urandom);
      wr_rd(regs[r], 32'h0);
    end
    // SET/CLR read as 0; pin 32-63 bank: writes ignored, reads 0; PADIN/INTSTATUS writes ignored
    wr_rd(GPIO_PADOUTSET, $urandom);  wr(GPIO_PADOUT, 32'h0);
    wr_rd(GPIO_PADOUTCLR, $urandom);
    for (bit [31:0] o = GPIO_UPPER_FIRST; o <= GPIO_UPPER_LAST; o += 4) wr_rd(o, $urandom);
    wr_rd(GPIO_PADIN, $urandom);
    wr_rd(GPIO_INTSTATUS, $urandom);
    idle();
  endtask
endclass

// ---------------------------------------------------------------------------
// 3. Output path: PADOUT / SET / CLR / PADDIR mixes. Scoreboard checks pads after each settle.
class gpio_out_vseq extends gpio_vseq_base;
  `uvm_object_utils(gpio_out_vseq)
  int unsigned n_rand = 16;
  function new(string name = "gpio_out_vseq"); super.new(name); endfunction

  task body();
    logic [31:0] d;
    release_pins();
    wr(GPIO_GPIOEN, '1);
    wr(GPIO_PADDIR, '1);
    wr(GPIO_PADOUT, 32'h0);          idle();
    // walking 1 / walking 0
    for (int b = 0; b < 32; b++) begin
      wr(GPIO_PADOUT,  32'h1 << b);      idle();
      wr(GPIO_PADOUT, ~(32'h1 << b));    idle();
    end
    // random PADOUT
    repeat (n_rand) begin wr(GPIO_PADOUT, $urandom); idle(); end
    // SET / CLR
    wr(GPIO_PADOUT, 32'h0); idle();
    repeat (n_rand) begin
      wr(GPIO_PADOUTSET, $urandom); idle();
      wr(GPIO_PADOUTCLR, $urandom); idle();
    end
    // pads must tri-state when PADDIR=0
    repeat (n_rand) begin
      wr(GPIO_PADDIR, $urandom); idle();
    end
    wr(GPIO_PADOUT, '1); wr(GPIO_PADDIR, 32'h0); idle();
    rd(GPIO_PADOUT, d);              // PADOUT readable regardless of PADDIR
    wr(GPIO_PADOUT, 32'h0);
    idle();
  endtask
endclass

// ---------------------------------------------------------------------------
// 4. Input path: VIP drives pads, CPU reads PADIN (scoreboard compares)
class gpio_in_vseq extends gpio_vseq_base;
  `uvm_object_utils(gpio_in_vseq)
  int unsigned n_rand = 16;
  function new(string name = "gpio_in_vseq"); super.new(name); endfunction

  task body();
    logic [31:0] d;
    release_pins();
    wr(GPIO_PADDIR, 32'h0);
    wr(GPIO_GPIOEN, '1);
    idle();
    rd(GPIO_PADIN, d);               // all pads floating -> nothing to compare, just must not hang
    for (int b = 0; b < 32; b++) begin
      drive('1, 32'h1 << b);       rd(GPIO_PADIN, d);
      drive('1, ~(32'h1 << b));    rd(GPIO_PADIN, d);
    end
    repeat (n_rand) begin drive('1, $urandom); rd(GPIO_PADIN, d); end
    // partially driven: floating pads must read as Z on the pin, driven ones on PADIN
    repeat (n_rand) begin drive($urandom, $urandom); rd(GPIO_PADIN, d); end
    release_pins();
  endtask
endclass

// ---------------------------------------------------------------------------
// 5. Mixed direction: random PADDIR; outputs from PADOUT, inputs from VIP; PADIN sees both
class gpio_mixed_vseq extends gpio_vseq_base;
  `uvm_object_utils(gpio_mixed_vseq)
  int unsigned n_iter = 32;
  function new(string name = "gpio_mixed_vseq"); super.new(name); endfunction

  task body();
    logic [31:0] d;
    bit [31:0]   m;
    wr(GPIO_GPIOEN, '1);
    repeat (n_iter) begin
      m = $urandom;
      release_pins();                       // never let VIP and DUT drive the same pad
      wr(GPIO_PADDIR, m);
      wr(GPIO_PADOUT, $urandom);
      drive(~m, $urandom);                  // VIP drives input pads only
      rd(GPIO_PADIN, d);
      rd(GPIO_PADOUT, d);
      rd(GPIO_PADDIR, d);
    end
    release_pins();
    wr(GPIO_PADDIR, 32'h0); wr(GPIO_PADOUT, 32'h0);
    idle();
  endtask
endclass

// ---------------------------------------------------------------------------
// 6. GPIOEN gating of the input path. Sequence-level check (scoreboard skips disabled pins).
//    apb_gpio gates the input sync flops per GROUP OF 4 PINS (enabled if any GPIOEN bit in the group is set);
//    pins in a fully disabled group hold their last PADIN value.
class gpio_en_gating_vseq extends gpio_vseq_base;
  `uvm_object_utils(gpio_en_gating_vseq)
  bit expect_hold = 1;
  function new(string name = "gpio_en_gating_vseq"); super.new(name); endfunction

  task body();
    logic [31:0] d0, d1, d2;
    bit [31:0]   a, m, gm, expv;
    bit [31:0]   masks[$] = {32'h0, 32'hFFFF_FFFF, 32'h0000_0001, 32'h0, 32'h0};
    masks[3] = $urandom; masks[4] = $urandom & 32'h0F0F_F0F0;

    release_pins();
    wr(GPIO_PADDIR, 32'h0);
    foreach (masks[k]) begin
      m = masks[k];
      a = $urandom;
      wr(GPIO_GPIOEN, '1);
      drive('1, a);              rd(GPIO_PADIN, d0);   // scoreboard: == a
      wr(GPIO_GPIOEN, m);
      drive('1, ~a);             rd(GPIO_PADIN, d1);
      for (int i = 0; i < 32; i++) gm[i] = |m[(i/4)*4 +: 4];   // group clock enable
      expv = (a & ~gm) | (~a & gm);                    // enabled groups follow, disabled groups hold
      if (expect_hold && d1 !== expv)
        `uvm_error("GPIO_EN_SEQ", $sformatf("GPIOEN=%08h: PADIN=%h expected %08h (disabled pins should hold)", m, d1, expv))
      wr(GPIO_GPIOEN, '1);
      idle();                    rd(GPIO_PADIN, d2);   // scoreboard: == ~a
    end
    release_pins();
  endtask
endclass

// ---------------------------------------------------------------------------
// 7. Interrupts: edge types x INTEN, clear-on-read. Scoreboard predicts INTSTATUS.
class gpio_int_vseq extends gpio_vseq_base;
  `uvm_object_utils(gpio_int_vseq)
  int unsigned n_iter = 16;
  function new(string name = "gpio_int_vseq"); super.new(name); endfunction

  task body();
    logic [31:0] d;
    bit [31:0]   t0, t1, lvl, nlvl;   // t0: pins 0-15, t1: pins 16-31 (2 bits/pin)
    bit [1:0]    enc[4] = '{GPIO_INT_FALL, GPIO_INT_RISE, GPIO_INT_BOTH, GPIO_INT_NONE};

    release_pins();
    wr(GPIO_PADDIR, 32'h0);
    wr(GPIO_GPIOEN, '1);
    wr(GPIO_INTEN,  32'h0);
    drive('1, 32'h0);                           // known level before any edge is armed
    rd(GPIO_INTSTATUS, d);

    repeat (n_iter) begin
      for (int i = 0; i < 16; i++) begin
        t0[2*i +: 2] = enc[$urandom_range(0, 3)];
        t1[2*i +: 2] = enc[$urandom_range(0, 3)];
      end
      lvl = $urandom;
      wr(GPIO_INTEN, 32'h0);
      wr(GPIO_INTTYPE0, t0); wr(GPIO_INTTYPE1, t1);
      drive('1, lvl);                           // set start level with INTEN=0
      rd(GPIO_INTSTATUS, d);                    // flush (expected 0)
      wr(GPIO_INTEN, $urandom);
      idle();
      nlvl = $urandom;
      drive('1, nlvl);  rd(GPIO_INTSTATUS, d);  // edges lvl->nlvl
      rd(GPIO_INTSTATUS, d);                    // clear-on-read: expected 0
      drive('1, lvl);   rd(GPIO_INTSTATUS, d);  // edges back
      rd(GPIO_INTSTATUS, d);
    end
    wr(GPIO_INTEN, 32'h0);
    release_pins();
  endtask
endclass

// ---------------------------------------------------------------------------
// Regression: runs the above in order. which = all|reset|reg_rw|out|in|mixed|gating|int
class gpio_regress_vseq extends gpio_vseq_base;
  `uvm_object_utils(gpio_regress_vseq)
  string which = "all";
  function new(string name = "gpio_regress_vseq"); super.new(name); endfunction

  task run_sub(gpio_vseq_base s);
    s.obi_sqr = obi_sqr; s.gpio_sqr = gpio_sqr; s.settle_cyc = settle_cyc;
    s.start(null, this);
  endtask

  task body();
    gpio_reset_vseq       s_reset  = gpio_reset_vseq::type_id::create("s_reset");
    gpio_reg_rw_vseq      s_regrw  = gpio_reg_rw_vseq::type_id::create("s_regrw");
    gpio_out_vseq         s_out    = gpio_out_vseq::type_id::create("s_out");
    gpio_in_vseq          s_in     = gpio_in_vseq::type_id::create("s_in");
    gpio_mixed_vseq       s_mixed  = gpio_mixed_vseq::type_id::create("s_mixed");
    gpio_en_gating_vseq   s_gate   = gpio_en_gating_vseq::type_id::create("s_gate");
    gpio_int_vseq         s_int    = gpio_int_vseq::type_id::create("s_int");

    if (which == "all" || which == "reset")  run_sub(s_reset);   // must be first: checks reset values
    if (which == "all" || which == "reg_rw") run_sub(s_regrw);
    if (which == "all" || which == "out")    run_sub(s_out);
    if (which == "all" || which == "in")     run_sub(s_in);
    if (which == "all" || which == "mixed")  run_sub(s_mixed);
    if (which == "all" || which == "gating") run_sub(s_gate);
    if (which == "all" || which == "int")    run_sub(s_int);
  endtask
endclass