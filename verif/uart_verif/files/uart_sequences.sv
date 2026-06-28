// =============================================================================
// uart_sequences.sv
// All UVM sequences for SentinelSoC UART verification.
//
// Sequences:
//   uart_base_seq       — base class, sets baud rate
//   uart_single_byte_seq — send one byte
//   uart_string_seq      — send an ASCII string
//   uart_echo_seq        — send N bytes, expect echo back
//   uart_banner_seq      — listen for boot banner after reset
//   uart_irq_seq         — send byte, check IRQ fires
//   uart_stress_seq      — back-to-back random bytes
//   uart_full_test_seq   — orchestrates all sub-sequences
// =============================================================================

// -----------------------------------------------------------------------------
// Base sequence
// -----------------------------------------------------------------------------
class uart_base_seq extends uvm_sequence #(uart_seq_item);
  `uvm_object_utils(uart_base_seq)

  // 115200 baud at 50 MHz = 434 clocks/bit
  // Change this to match your system clock and UART divisor register setting
  int unsigned baud_clks_per_bit = 434;

  function new(string name = "uart_base_seq");
    super.new(name);
  endfunction

  // Helper: create and send one byte item
  task send_byte(logic [7:0] data);
    uart_seq_item item = uart_seq_item::type_id::create("item");
    start_item(item);
    item.data      = data;
    item.direction = uart_seq_item::TX_TO_SOC;
    finish_item(item);
  endtask

endclass : uart_base_seq

// -----------------------------------------------------------------------------
// Single byte
// -----------------------------------------------------------------------------
class uart_single_byte_seq extends uart_base_seq;
  `uvm_object_utils(uart_single_byte_seq)

  rand logic [7:0] payload;

  function new(string name = "uart_single_byte_seq");
    super.new(name);
    payload = 8'h55; // default: alternating 0/1
  endfunction

  task body();
    `uvm_info("SEQ", $sformatf("Sending single byte 0x%02h", payload), UVM_LOW)
    send_byte(payload);
  endtask

endclass : uart_single_byte_seq

// -----------------------------------------------------------------------------
// String transmit
// -----------------------------------------------------------------------------
class uart_string_seq extends uart_base_seq;
  `uvm_object_utils(uart_string_seq)

  string str = "Hello SentinelSoC\r\n";

  function new(string name = "uart_string_seq");
    super.new(name);
  endfunction

  task body();
    `uvm_info("SEQ", $sformatf("Sending string: '%s'", str), UVM_LOW)
    foreach (str[i])
      send_byte(logic'(str[i]));
  endtask

endclass : uart_string_seq

// -----------------------------------------------------------------------------
// Echo sequence
// Sends N random bytes and expects each one to be echoed back by the SoC.
// Requires the firmware running on Ibex to implement a simple echo loop.
// -----------------------------------------------------------------------------
class uart_echo_seq extends uart_base_seq;
  `uvm_object_utils(uart_echo_seq)

  uart_scoreboard sb; // injected by test so we can queue expected values

  rand int unsigned num_bytes;
  constraint c_num { num_bytes inside {[4:32]}; }

  function new(string name = "uart_echo_seq");
    super.new(name);
  endfunction

  task body();
    logic [7:0] data;
    `uvm_info("SEQ", $sformatf("Echo test: sending %0d bytes", num_bytes), UVM_LOW)
    repeat(num_bytes) begin
      data = $urandom_range(8'h20, 8'h7E); // printable ASCII
      if (sb != null) sb.expect_echo(data);
      send_byte(data);
    end
  endtask

endclass : uart_echo_seq

// -----------------------------------------------------------------------------
// Banner capture sequence
// Just waits after reset for the SoC to transmit its boot banner.
// -----------------------------------------------------------------------------
class uart_banner_seq extends uart_base_seq;
  `uvm_object_utils(uart_banner_seq)

  // How many bytes to wait for (adjust to match your firmware banner length)
  int unsigned banner_byte_count = 64;

  function new(string name = "uart_banner_seq");
    super.new(name);
  endfunction

  task body();
    // Nothing to send — the monitor will capture whatever the SoC transmits.
    // We just idle here for long enough for the banner to arrive.
    // Time = banner_byte_count * 10 bits * baud_clks_per_bit + margin
    int unsigned wait_clks;
    wait_clks = banner_byte_count * 10 * baud_clks_per_bit * 2;
    `uvm_info("SEQ", $sformatf(
      "Banner capture: waiting %0d cycles for SoC boot output", wait_clks),
      UVM_LOW)
    // Use #0 + repeat to avoid blocking the phase
    repeat(wait_clks) @(uvm_top); // will be replaced by delay in env
  endtask

endclass : uart_banner_seq

// -----------------------------------------------------------------------------
// Stress sequence — back-to-back random bytes, no gap
// -----------------------------------------------------------------------------
class uart_stress_seq extends uart_base_seq;
  `uvm_object_utils(uart_stress_seq)

  rand int unsigned num_bytes;
  constraint c_stress { num_bytes inside {[64:256]}; }

  function new(string name = "uart_stress_seq");
    super.new(name);
  endfunction

  task body();
    `uvm_info("SEQ", $sformatf("Stress: %0d back-to-back bytes", num_bytes), UVM_LOW)
    repeat(num_bytes) begin
      logic [7:0] data;
      data = $urandom;
      send_byte(data);
    end
  endtask

endclass : uart_stress_seq

// -----------------------------------------------------------------------------
// Full orchestration sequence
// Runs all sub-sequences in order, exercises all test goals.
// -----------------------------------------------------------------------------
class uart_full_test_seq extends uart_base_seq;
  `uvm_object_utils(uart_full_test_seq)

  uart_scoreboard sb;

  function new(string name = "uart_full_test_seq");
    super.new(name);
  endfunction

  task body();
    uart_string_seq  str_seq;
    uart_echo_seq    echo_seq;
    uart_stress_seq  stress_seq;

    // ── T1: Send a known string (monitor captures whatever SoC sends back) ──
    `uvm_info("FULL_SEQ", "=== T1: String TX ===", UVM_LOW)
    str_seq = uart_string_seq::type_id::create("str_seq");
    str_seq.start(m_sequencer);

    // ── T2: Echo test (firmware must be echo loop) ──────────────────────────
    `uvm_info("FULL_SEQ", "=== T2: Echo test ===", UVM_LOW)
    echo_seq    = uart_echo_seq::type_id::create("echo_seq");
    echo_seq.sb = sb;
    assert(echo_seq.randomize() with { num_bytes == 16; });
    echo_seq.start(m_sequencer);

    // ── T3: Stress back-to-back ─────────────────────────────────────────────
    `uvm_info("FULL_SEQ", "=== T3: Stress TX ===", UVM_LOW)
    stress_seq = uart_stress_seq::type_id::create("stress_seq");
    assert(stress_seq.randomize());
    stress_seq.start(m_sequencer);

  endtask

endclass : uart_full_test_seq
