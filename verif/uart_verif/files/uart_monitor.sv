// =============================================================================
// uart_monitor.sv
// UVM monitor: deserialises uart_tx_o bits into uart_seq_item bytes.
// Detects framing errors (stop bit not high).
// Broadcasts items on ap (analysis port) for scoreboard and coverage.
// =============================================================================

class uart_monitor extends uvm_monitor;
  `uvm_component_utils(uart_monitor)

  virtual uart_if.monitor_mp vif;

  uvm_analysis_port #(uart_seq_item) ap;

  // Running clock counter for timestamps
  longint unsigned clk_count;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ap = new("ap", this);
    if (!uvm_config_db #(virtual uart_if)::get(this, "", "uart_vif", vif))
      `uvm_fatal("NOVIF", "uart_monitor: no uart_vif in config_db")
  endfunction

  task run_phase(uvm_phase phase);
    clk_count = 0;
    forever begin
      @(vif.monitor_cb);
      clk_count++;
      // Wait for start bit (falling edge on tx)
      if (vif.monitor_cb.tx === 1'b0)
        capture_byte();
    end
  endtask

  task capture_byte();
    uart_seq_item item;
    logic [7:0]   data;
    logic         stop_bit;
    int unsigned  bpb;
    longint unsigned start_time;

    bpb        = vif.baud_clks_per_bit;
    start_time = clk_count;

    // Sample in the middle of the start bit to verify it's real
    repeat(bpb/2) begin
      @(vif.monitor_cb);
      clk_count++;
    end

    if (vif.monitor_cb.tx !== 1'b0) begin
      `uvm_info("UART_MON", "Glitch on tx — ignoring", UVM_HIGH)
      return;
    end

    // Sample 8 data bits at centre of each bit period
    for (int i = 0; i < 8; i++) begin
      repeat(bpb) begin
        @(vif.monitor_cb);
        clk_count++;
      end
      data[i] = vif.monitor_cb.tx;
    end

    // Sample stop bit
    repeat(bpb) begin
      @(vif.monitor_cb);
      clk_count++;
    end
    stop_bit = vif.monitor_cb.tx;

    // Build and broadcast item
    item = uart_seq_item::type_id::create("uart_rx_item");
    item.data         = data;
    item.direction    = uart_seq_item::RX_FROM_SOC;
    item.framing_err  = (stop_bit !== 1'b1);
    item.parity_err   = 1'b0; // 8N1 — no parity
    item.timestamp_clks = start_time;

    ap.write(item);

    `uvm_info("UART_MON", $sformatf("Captured byte 0x%02h ('%s')%s",
              data,
              (data >= 8'h20 && data < 8'h7f) ? string'(data) : ".",
              item.framing_err ? " [FRAMING ERR]" : ""),
              UVM_MEDIUM)
  endtask

endclass : uart_monitor
