// =============================================================================
// soc_irq_test.sv -- interrupt path, end to end (checklist 6.5 / 6.15)
//
// "Every source verified from peripheral event to controller input; masking
//  and priority checked."
//
// No-core mode: the UVM CPU agent programs the peripherals and the PLIC /
// CLINT over the bus; irq_mon_if watches the interrupt lines that go into
// Ibex (irq_external from the PLIC, irq_timer / irq_software from the CLINT).
//
// PLIC sources in final_soc_top: 1 UART, 2 SPI #2, 3 QSPI, 4 GPIO, 5 timer,
// 8 DIFT (core violation -- needs a running core, so not testable here).
//
// Per PLIC source:
//   trigger the peripheral with the source DISABLED -> pending bit set,
//     irq_external stays 0                                   (enable masking)
//   enable it                     -> irq_external = 1
//   threshold = priority          -> irq_external = 0        (threshold masking)
//   threshold = 0                 -> irq_external = 1
//   claim                         -> returns the source ID, pending cleared,
//                                    irq_external = 0
//   clear the source at the peripheral, complete
//                                 -> nothing re-pends, irq_external stays 0
// Then priority: two pending sources -> the higher priority is claimed first;
// equal priority -> the lower ID first.
// CLINT: mtimecmp <= mtime raises the timer IRQ, mtimecmp = max clears it;
// msip = 1 / 0 raises / clears the software IRQ.
// =============================================================================

class soc_irq_seq extends uvm_sequence #(obi_seq_item);
  `uvm_object_utils(soc_irq_seq)

  virtual irq_mon_if vif_irq;
  virtual gpio_if    vif_gpio;

  int n_checks;
  int n_fail;

  // Address map
  localparam logic [31:0] PLIC_PRIO = 32'h0C00_0000;  // + 4*id
  localparam logic [31:0] PLIC_PEND = 32'h0C00_1000;
  localparam logic [31:0] PLIC_EN   = 32'h0C00_2000;
  localparam logic [31:0] PLIC_THR  = 32'h0C20_0000;
  localparam logic [31:0] PLIC_CC   = 32'h0C20_0004;  // claim (read) / complete (write)
  localparam logic [31:0] CLINT     = 32'h0200_0000;
  localparam logic [31:0] UART      = 32'h1050_3000;  // register n at +4*n
  localparam logic [31:0] SPI2      = 32'h1050_2000;
  localparam logic [31:0] QSPI      = 32'h1050_0000;
  localparam logic [31:0] TIMER     = 32'h1050_1000;
  localparam logic [31:0] GPIO      = 32'h1060_0000;

  localparam int ID_UART = 1, ID_SPI2 = 2, ID_QSPI = 3, ID_GPIO = 4, ID_TIMER = 5;

  function new(string name = "soc_irq_seq");
    super.new(name);
  endfunction

  // ------------------------------------------------------------------ helpers
  task bus(logic [31:0] a, bit we, logic [31:0] wd, output logic [31:0] rdata);
    obi_seq_item it;
    it = obi_seq_item::type_id::create("it");
    start_item(it);
    it.addr = a; it.we = we; it.be = 4'hF; it.data = wd;
    finish_item(it);
    rdata = it.data;
    if (it.err !== 1'b0) begin
      n_fail++;
      `uvm_error("IRQ", $sformatf("[FAIL] bus error on %s %08h", we ? "write" : "read", a))
    end
  endtask

  task wr(logic [31:0] a, logic [31:0] d);
    logic [31:0] unused;
    bus(a, 1'b1, d, unused);
  endtask

  task rd(logic [31:0] a, output logic [31:0] d);
    bus(a, 1'b0, '0, d);
  endtask

  task cycles(int n);
    repeat (n) @(posedge vif_irq.clk_i);
  endtask

  function void check(bit ok, string what);
    n_checks++;
    if (ok) `uvm_info("IRQ", $sformatf("[PASS] %s", what), UVM_LOW)
    else begin
      n_fail++;
      `uvm_error("IRQ", $sformatf("[FAIL] %s", what))
    end
  endfunction

  function string src_name(int id);
    case (id)
      ID_UART:  return "UART";
      ID_SPI2:  return "SPI #2";
      ID_QSPI:  return "QSPI";
      ID_GPIO:  return "GPIO";
      ID_TIMER: return "Timer";
      default:  return $sformatf("source %0d", id);
    endcase
  endfunction

  // ------------------------------------------------- make a peripheral fire
  task trigger(int id);
    logic [31:0] d;
    case (id)
      ID_UART: begin
        wr(UART + 32'h0C, 32'h03);         // LCR: 8N1, DLAB = 0
        wr(UART + 32'h04, 32'h02);         // IER: transmit-holding-empty -> fires (TX FIFO is empty)
      end
      ID_SPI2, ID_QSPI: begin
        // INTCFG: enable, TX threshold 0 (empty FIFO <= 0 -> one pulse),
        // RX threshold 8 (no RX pulse)
        wr((id == ID_SPI2 ? SPI2 : QSPI) + 32'h24, 32'h8000_0800);
      end
      ID_GPIO: begin
        vif_gpio.drv_val[0] = 1'b0;        // pin 0 driven low by the testbench
        vif_gpio.drv_en[0]  = 1'b1;
        wr(GPIO + 32'h00, 32'h0);          // PADDIR: all inputs
        wr(GPIO + 32'h04, 32'h1);          // GPIOEN: pin 0
        wr(GPIO + 32'h1C, 32'hFFFF_FFFD);  // INTTYPE0: pin 0 = rising edge, others none
        wr(GPIO + 32'h20, 32'hFFFF_FFFF);  // INTTYPE1: none
        cycles(10);
        wr(GPIO + 32'h18, 32'h1);          // INTEN: pin 0
        cycles(5);
        vif_gpio.drv_val[0] = 1'b1;        // rising edge -> one pulse
      end
      ID_TIMER: begin
        wr(TIMER + 32'h08, 32'd20);        // timer 0 CMP = 20 (also clears VALUE)
        wr(TIMER + 32'h04, 32'h1);         // CTRL: enable, no prescaler
      end
      default: ;
    endcase
    cycles(60);                            // let the event reach the PLIC
  endtask

  // ------------------------------------------- clear the event at its source
  task quiesce(int id);
    logic [31:0] d;
    case (id)
      ID_UART: begin
        wr(UART + 32'h04, 32'h00);         // IER = 0
        rd(UART + 32'h08, d);              // read IIR: clears the THRE interrupt
      end
      ID_SPI2, ID_QSPI: begin
        wr((id == ID_SPI2 ? SPI2 : QSPI) + 32'h24, 32'h0);   // INTCFG = 0
        rd((id == ID_SPI2 ? SPI2 : QSPI) + 32'h28, d);       // read INTSTA: re-arm
      end
      ID_GPIO: begin
        wr(GPIO + 32'h18, 32'h0);          // INTEN = 0
        rd(GPIO + 32'h24, d);              // INTSTATUS: clear-on-read
        vif_gpio.drv_en[0] = 1'b0;         // release the pin
      end
      ID_TIMER: begin
        wr(TIMER + 32'h04, 32'h0);         // CTRL: stop
        wr(TIMER + 32'h08, 32'h0);         // CMP = 0: compare disabled
      end
      default: ;
    endcase
    cycles(10);
  endtask

  // --------------------------------------- one PLIC source, end to end
  task plic_source(int id);
    logic [31:0] d;
    string n = src_name(id);
    `uvm_info("IRQ", $sformatf("--- PLIC source %0d (%s) ---", id, n), UVM_LOW)

    wr(PLIC_EN, 32'h0);
    wr(PLIC_THR, 32'h0);
    wr(PLIC_PRIO + 4*id, 32'h1);

    trigger(id);
    rd(PLIC_PEND, d);
    check(d[id] === 1'b1, $sformatf("%s: event sets PLIC pending bit %0d (pending=%03h)", n, id, d[12:0]));
    check(vif_irq.irq_external === 1'b0, $sformatf("%s: disabled source does not reach the core (enable masking)", n));

    wr(PLIC_EN, 32'h1 << id);
    rd(PLIC_EN, d);
    check(d[12:0] == 13'(32'h1 << id), $sformatf("%s: enable register reads back bit %0d (enable=%03h)", n, id, d[12:0]));
    cycles(5);
    check(vif_irq.irq_external === 1'b1, $sformatf("%s: enabled -> irq_external to the core", n));

    wr(PLIC_THR, 32'h1);
    cycles(5);
    check(vif_irq.irq_external === 1'b0, $sformatf("%s: threshold = priority masks it", n));
    wr(PLIC_THR, 32'h0);
    cycles(5);
    check(vif_irq.irq_external === 1'b1, $sformatf("%s: threshold 0 -> asserted again", n));

    rd(PLIC_CC, d);
    check(d == id, $sformatf("%s: claim returns ID %0d (got %0d)", n, id, d));
    cycles(5);
    check(vif_irq.irq_external === 1'b0, $sformatf("%s: after claim irq_external drops", n));

    quiesce(id);
    check(vif_irq.plic_src[id] === 1'b0, $sformatf("%s: source line low after clearing it at the peripheral", n));
    wr(PLIC_CC, id);                       // complete
    cycles(20);
    rd(PLIC_PEND, d);
    check(d[id] === 1'b0 && vif_irq.irq_external === 1'b0,
          $sformatf("%s: after complete nothing re-pends (pending=%03h irq_external=%b)", n, d[12:0], vif_irq.irq_external));

    wr(PLIC_EN, 32'h0);
    wr(PLIC_PRIO + 4*id, 32'h0);
  endtask

  // --------------------------------------- priority between two sources
  task plic_priority(int id_a, int prio_a, int id_b, int prio_b, int exp_first, string what);
    logic [31:0] d1, d2, d;
    `uvm_info("IRQ", $sformatf("--- priority: %s ---", what), UVM_LOW)
    wr(PLIC_EN, 32'h0);
    wr(PLIC_THR, 32'h0);
    wr(PLIC_PRIO + 4*id_a, prio_a);
    wr(PLIC_PRIO + 4*id_b, prio_b);
    trigger(id_a);
    trigger(id_b);
    wr(PLIC_EN, (32'h1 << id_a) | (32'h1 << id_b));
    cycles(5);
    rd(PLIC_CC, d1);
    quiesce(d1);
    wr(PLIC_CC, d1);
    cycles(5);
    rd(PLIC_CC, d2);
    quiesce(d2);
    wr(PLIC_CC, d2);
    cycles(10);
    check(d1 == exp_first && d2 == (exp_first == id_a ? id_b : id_a),
          $sformatf("%s: claimed %0d then %0d (expected %0d first)", what, d1, d2, exp_first));
    rd(PLIC_PEND, d);
    check(vif_irq.irq_external === 1'b0 && (d[id_a] | d[id_b]) === 1'b0, $sformatf("%s: both completed, nothing left", what));
    wr(PLIC_EN, 32'h0);
    wr(PLIC_PRIO + 4*id_a, 32'h0);
    wr(PLIC_PRIO + 4*id_b, 32'h0);
  endtask

  // ------------------------------------------------------------------ body
  task body();
    logic [31:0] d, mt;
    n_checks = 0;
    n_fail   = 0;

    check(vif_irq.irq_external === 1'b0 && vif_irq.irq_mtimer === 1'b0 && vif_irq.irq_msoft === 1'b0,
          "after reset no interrupt line is asserted");

    // ---- each PLIC source, end to end
    plic_source(ID_SPI2);
    plic_source(ID_QSPI);
    plic_source(ID_GPIO);
    plic_source(ID_TIMER);
    plic_source(ID_UART);      // last: if its interrupt cannot be cleared, the others are already done

    // ---- priority (sources whose interrupt is a one-shot pulse)
    plic_priority(ID_SPI2, 1, ID_GPIO, 3, ID_GPIO, "higher priority wins (GPIO 3 vs SPI #2 1)");
    plic_priority(ID_QSPI, 2, ID_GPIO, 2, ID_QSPI, "equal priority -> lower ID wins (QSPI vs GPIO)");

    // ---- CLINT machine timer
    `uvm_info("IRQ", "--- CLINT timer / software interrupts ---", UVM_LOW)
    rd(CLINT + 32'hBFF8, mt);
    wr(CLINT + 32'h4000, mt + 32'd300);    // mtimecmp lo (hi is still all ones: no IRQ yet)
    wr(CLINT + 32'h4004, 32'h0);           // mtimecmp hi = 0 -> fires once mtime passes lo
    cycles(5);
    check(vif_irq.irq_mtimer === 1'b0, "CLINT: timer IRQ not yet (mtime < mtimecmp)");
    cycles(400);
    check(vif_irq.irq_mtimer === 1'b1, "CLINT: timer IRQ once mtime >= mtimecmp");
    wr(CLINT + 32'h4004, 32'hFFFF_FFFF);   // push mtimecmp far away
    cycles(5);
    check(vif_irq.irq_mtimer === 1'b0, "CLINT: timer IRQ clears when mtimecmp is moved");

    // ---- CLINT software interrupt
    wr(CLINT + 32'h0000, 32'h1);
    cycles(5);
    check(vif_irq.irq_msoft === 1'b1, "CLINT: msip = 1 raises the software IRQ");
    wr(CLINT + 32'h0000, 32'h0);
    cycles(5);
    check(vif_irq.irq_msoft === 1'b0, "CLINT: msip = 0 clears it");

    `uvm_info("IRQ", "NOTE: PLIC source 8 (DIFT violation) needs a running core; covered by the full-SoC/debugger TBs, not here", UVM_LOW)
  endtask
endclass

class sentinel_soc_vip_irq_test extends sentinel_soc_vip_base_test;
  `uvm_component_utils(sentinel_soc_vip_irq_test)

  virtual irq_mon_if vif_irq;
  virtual gpio_if    vif_gpio;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual irq_mon_if)::get(this, "", "vif_irq", vif_irq))
      `uvm_fatal("IRQ", "vif_irq not found in config_db")
    if (!uvm_config_db#(virtual gpio_if)::get(this, "", "vif_gpio", vif_gpio))
      `uvm_fatal("IRQ", "vif_gpio not found in config_db")
  endfunction

  task run_phase(uvm_phase phase);
    soc_irq_seq seq;
    phase.raise_objection(this);

    wait (vif_obi.rst_ni === 1'b1);
    repeat (10) @(posedge vif_obi.clk_i);

    `uvm_info("IRQ", "--- interrupt sources, masking and priority (checklist 6.5 / 6.15) ---", UVM_LOW)
    seq = soc_irq_seq::type_id::create("seq");
    seq.vif_irq  = vif_irq;
    seq.vif_gpio = vif_gpio;
    seq.start(cpu_agent.sequencer);

    if (seq.n_fail == 0)
      `uvm_info("IRQ", $sformatf(">>> IRQ TEST PASSED: %0d checks <<<", seq.n_checks), UVM_LOW)
    else
      `uvm_error("IRQ", $sformatf(">>> IRQ TEST FAILED: %0d of %0d checks <<<", seq.n_fail, seq.n_checks))

    repeat (20) @(posedge vif_obi.clk_i);
    phase.drop_objection(this);
  endtask
endclass
