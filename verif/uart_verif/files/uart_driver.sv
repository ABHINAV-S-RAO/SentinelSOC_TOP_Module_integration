// =============================================================================
// uart_driver.sv
// UVM driver: serialises uart_seq_item bytes onto uart_if.rx
// (8N1 format: 1 start bit, 8 data bits LSB-first, 1 stop bit, no parity)
// =============================================================================

class uart_driver extends uvm_driver #(uart_seq_item);
  `uvm_component_utils(uart_driver)

  virtual uart_if.driver_mp vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db #(virtual uart_if)::get(this, "", "uart_vif", vif))
      `uvm_fatal("NOVIF", "uart_driver: no uart_vif in config_db")
  endfunction

  task run_phase(uvm_phase phase);
    uart_seq_item item;
    // Keep rx line idle (high) at startup
    vif.driver_cb.rx <= 1'b1;
    @(vif.driver_cb);
    forever begin
      seq_item_port.get_next_item(item);
      send_byte(item.data);
      seq_item_port.item_done();
    end
  endtask

  // Send one byte in 8N1 format
  task send_byte(input logic [7:0] data);
    int unsigned bpb;
    bpb = vif.baud_clks_per_bit;

    // START bit (low)
    vif.driver_cb.rx <= 1'b0;
    repeat(bpb) @(vif.driver_cb);

    // 8 data bits LSB first
    for (int i = 0; i < 8; i++) begin
      vif.driver_cb.rx <= data[i];
      repeat(bpb) @(vif.driver_cb);
    end

    // STOP bit (high)
    vif.driver_cb.rx <= 1'b1;
    repeat(bpb) @(vif.driver_cb);

    `uvm_info("UART_DRV", $sformatf("Sent byte 0x%02h ('%s')",
              data, (data >= 8'h20 && data < 8'h7f) ? string'(data) : "."),
              UVM_MEDIUM)
  endtask

endclass : uart_driver
