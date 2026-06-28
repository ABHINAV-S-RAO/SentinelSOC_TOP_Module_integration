// =============================================================================
// uart_tests.sv
// All UVM test classes for SentinelSoC UART verification.
//
// Tests:
//   uart_base_test      — base test: build env, connect vif, apply reset
//   uart_banner_test    — check SoC transmits boot banner after reset
//   uart_echo_test      — send bytes, check SoC echoes them back
//   uart_irq_test       — send byte, verify UART RX IRQ fires in time
//   uart_stress_test    — high-speed back-to-back transfer stress
//   uart_full_test      — runs all scenarios in sequence
// =============================================================================

// =============================================================================
// BASE TEST
// =============================================================================
class uart_base_test extends uvm_test;
  `uvm_component_utils(uart_base_test)

  uart_env         env;
  virtual uart_if  uart_vif;
  virtual          soc_top_if soc_vif; // clock/reset/IRQ probe interface

  // Baud rate config — 115200 at 50 MHz → 434 clks/bit
  // Match this to what you program into the UART divisor register
  localparam int unsigned BAUD_CLKS = 434;
  localparam int unsigned CLK_PERIOD_NS = 20; // 50 MHz

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = uart_env::type_id::create("env", this);

    // Get virtual interfaces from config DB (set in top module)
    if (!uvm_config_db #(virtual uart_if)::get(this, "", "uart_vif", uart_vif))
      `uvm_fatal("NOVIF", "No uart_vif in config_db")
    if (!uvm_config_db #(virtual soc_top_if)::get(this, "", "soc_vif", soc_vif))
      `uvm_fatal("NOVIF", "No soc_vif in config_db")

    // Push vif down to driver and monitor
    uvm_config_db #(virtual uart_if)::set(this, "env.agent.*", "uart_vif", uart_vif);

    // Set baud rate on the interface
    uart_vif.baud_clks_per_bit = BAUD_CLKS;
  endfunction

  // Apply reset then release
  task apply_reset();
    `uvm_info("TEST", "Applying reset...", UVM_LOW)
    soc_vif.rst_n = 1'b0;
    uart_vif.rx   = 1'b1; // idle
    repeat(20) @(posedge soc_vif.clk);
    soc_vif.rst_n = 1'b1;
    repeat(10) @(posedge soc_vif.clk);
    `uvm_info("TEST", "Reset released.", UVM_LOW)
  endtask

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    apply_reset();
    // Subclass runs scenario here
    run_scenario(phase);
    // Drain time for last transaction to complete
    repeat(BAUD_CLKS * 20) @(posedge soc_vif.clk);
    phase.drop_objection(this);
  endtask

  // Override in subclasses
  virtual task run_scenario(uvm_phase phase);
  endtask

endclass : uart_base_test


// =============================================================================
// TEST 1: BOOT BANNER
// After reset, the SoC firmware should transmit a banner string over UART.
// We capture it via the monitor and check it contains "SentinelSoC".
// =============================================================================
class uart_banner_test extends uart_base_test;
  `uvm_component_utils(uart_banner_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_scenario(uvm_phase phase);
    int unsigned wait_clks;

    `uvm_info("TEST", "=== BANNER TEST: waiting for boot banner ===", UVM_LOW)

    // Switch scoreboard to banner mode
    env.scoreboard.mode            = uart_scoreboard::BANNER_MODE;
    env.scoreboard.expected_banner = "SentinelSoC";

    // Wait long enough for firmware to print its banner
    // 64 chars × 10 bits × 434 clks = ~278,000 clocks
    wait_clks = 64 * 10 * BAUD_CLKS;
    repeat(wait_clks) @(posedge soc_vif.clk);

    // Check banner
    env.scoreboard.check_banner();

    `uvm_info("TEST", $sformatf("Captured banner: '%s'",
              env.scoreboard.captured_banner), UVM_LOW)
  endtask

endclass : uart_banner_test


// =============================================================================
// TEST 2: ECHO TEST
// Sends 16 printable ASCII bytes and expects them echoed back.
// Firmware must implement: while(1) uart_putc(uart_getc());
// =============================================================================
class uart_echo_test extends uart_base_test;
  `uvm_component_utils(uart_echo_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_scenario(uvm_phase phase);
    uart_echo_seq echo_seq;

    `uvm_info("TEST", "=== ECHO TEST ===", UVM_LOW)

    env.scoreboard.mode = uart_scoreboard::ECHO_MODE;
    echo_seq            = uart_echo_seq::type_id::create("echo_seq");
    echo_seq.sb         = env.scoreboard;

    assert(echo_seq.randomize() with { num_bytes == 16; })
    else `uvm_fatal("TEST", "Randomization failed")

    echo_seq.start(env.agent.sequencer);

    // Wait for all echos to arrive: 16 bytes × 2 directions × 10 bits × BAUD_CLKS + margin
    repeat(16 * 2 * 10 * BAUD_CLKS * 2) @(posedge soc_vif.clk);

    // Check echo queue is empty (all echoes received)
    if (env.scoreboard.echo_expected.size() > 0) begin
      `uvm_error("ECHO_TEST", $sformatf(
        "%0d echo bytes never received",
        env.scoreboard.echo_expected.size()))
    end

  endtask

endclass : uart_echo_test


// =============================================================================
// TEST 3: IRQ TEST
// Sends one byte and checks that the UART RX interrupt (irq_uart) fires
// within 2 × byte_time of the byte arriving.
// =============================================================================
class uart_irq_test extends uart_base_test;
  `uvm_component_utils(uart_irq_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_scenario(uvm_phase phase);
    uart_single_byte_seq seq;
    int unsigned         irq_timeout;
    bit                  irq_seen;
    longint unsigned     t_send, t_irq;

    `uvm_info("TEST", "=== IRQ TEST ===", UVM_LOW)

    env.scoreboard.mode = uart_scoreboard::FREE_MODE;
    seq                 = uart_single_byte_seq::type_id::create("seq");
    seq.payload         = 8'hA5;

    // Record time before send
    t_send = $time;
    seq.start(env.agent.sequencer);

    // Wait for IRQ — irq_uart comes from PLIC through soc_vif
    // Timeout = 3 full byte times
    irq_timeout = 3 * 10 * BAUD_CLKS;
    irq_seen    = 1'b0;

    fork
      begin
        // Wait for IRQ to go high
        @(posedge soc_vif.irq_uart);
        t_irq    = $time;
        irq_seen = 1'b1;
      end
      begin
        repeat(irq_timeout) @(posedge soc_vif.clk);
      end
    join_any
    disable fork;

    if (irq_seen) begin
      `uvm_info("IRQ_TEST", $sformatf(
        "PASS: irq_uart asserted %0t ns after byte sent (t_send=%0t t_irq=%0t)",
        t_irq - t_send, t_send, t_irq), UVM_LOW)
      env.scoreboard.checks_passed++;
    end else begin
      `uvm_error("IRQ_TEST", $sformatf(
        "FAIL: irq_uart did not assert within %0d cycles",
        irq_timeout))
      env.scoreboard.checks_failed++;
    end

  endtask

endclass : uart_irq_test


// =============================================================================
// TEST 4: STRESS TEST
// 128 back-to-back random bytes, no inter-byte gap.
// Checks no framing errors occur.
// =============================================================================
class uart_stress_test extends uart_base_test;
  `uvm_component_utils(uart_stress_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_scenario(uvm_phase phase);
    uart_stress_seq stress_seq;

    `uvm_info("TEST", "=== STRESS TEST ===", UVM_LOW)

    env.scoreboard.mode = uart_scoreboard::FREE_MODE;
    stress_seq          = uart_stress_seq::type_id::create("stress_seq");
    assert(stress_seq.randomize() with { num_bytes == 128; })
    else `uvm_fatal("TEST", "Randomization failed")
    stress_seq.start(env.agent.sequencer);

    // Wait for all bytes to flush through
    repeat(128 * 10 * BAUD_CLKS * 3) @(posedge soc_vif.clk);

    // Scoreboard will flag framing errors in report_phase
    `uvm_info("TEST", $sformatf("Stress done. Framing errors: %0d",
              env.scoreboard.framing_errors), UVM_LOW)
    if (env.scoreboard.framing_errors == 0)
      env.scoreboard.checks_passed++;
    else
      env.scoreboard.checks_failed++;

  endtask

endclass : uart_stress_test


// =============================================================================
// TEST 5: FULL TEST (runs all scenarios back to back)
// =============================================================================
class uart_full_test extends uart_base_test;
  `uvm_component_utils(uart_full_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_scenario(uvm_phase phase);
    uart_full_test_seq full_seq;

    `uvm_info("TEST", "=== FULL TEST ===", UVM_LOW)

    env.scoreboard.mode = uart_scoreboard::ECHO_MODE;
    full_seq            = uart_full_test_seq::type_id::create("full_seq");
    full_seq.sb         = env.scoreboard;
    full_seq.start(env.agent.sequencer);

    repeat(BAUD_CLKS * 100) @(posedge soc_vif.clk);
  endtask

endclass : uart_full_test
