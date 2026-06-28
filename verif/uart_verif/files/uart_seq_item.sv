// =============================================================================
// uart_seq_item.sv
// UVM sequence item representing one UART byte transaction.
// Covers both TX (SoC→TB) and RX (TB→SoC) directions.
// =============================================================================

class uart_seq_item extends uvm_sequence_item;
  `uvm_object_utils_begin(uart_seq_item)
    `uvm_field_int(data,      UVM_ALL_ON)
    `uvm_field_enum(dir_e, direction, UVM_ALL_ON)
    `uvm_field_int(parity_err, UVM_ALL_ON)
    `uvm_field_int(framing_err, UVM_ALL_ON)
  `uvm_object_utils_end

  // Direction: are we sending TO the SoC, or did we capture FROM the SoC?
  typedef enum {TX_TO_SOC, RX_FROM_SOC} dir_e;

  rand logic [7:0] data;
       dir_e       direction;
       logic       parity_err;
       logic       framing_err;

  // Timestamp in clocks (set by monitor)
  longint unsigned timestamp_clks;

  function new(string name = "uart_seq_item");
    super.new(name);
    parity_err  = 1'b0;
    framing_err = 1'b0;
  endfunction

  function string convert2string();
    return $sformatf("UART[%s] data=0x%02h (%0d) t=%0d%s%s",
      direction == TX_TO_SOC ? "→SoC" : "←SoC",
      data, data, timestamp_clks,
      parity_err  ? " PARITY_ERR"  : "",
      framing_err ? " FRAMING_ERR" : "");
  endfunction

endclass : uart_seq_item
