// UNCONFIRMED: obi_seq_item.addr / .data / .we field names are assumed to
// match the fields used in soc_gpio_toggle_seq (addr/data/we/be). Grep
// obi_seq_item.sv to confirm before trusting write_obi() compiles/works —
// same caution as the isActive vs is_active naming trap hit on SPI/JTAG.
`uvm_analysis_imp_decl(_obi)
`uvm_analysis_imp_decl(_gpio)

class GpioScoreboard extends uvm_scoreboard;
  `uvm_component_utils(GpioScoreboard)

  uvm_analysis_imp_obi  #(obi_seq_item, GpioScoreboard) obi_export;
  uvm_analysis_imp_gpio #(gpio_pin_txn, GpioScoreboard) gpio_export;

  bit [31:0] dir_shadow;
  bit [31:0] out_shadow;
  bit        dir_valid;  // 1 once a PADDIR write has been observed
  bit        out_valid;  // 1 once a PADOUT/SET/CLR write has been observed

  localparam bit [31:0] BASE       = 32'h1060_0000;
  localparam bit [31:0] OFF_PADDIR = 32'h00;
  localparam bit [31:0] OFF_PADOUT = 32'h0C;
  localparam bit [31:0] OFF_SET    = 32'h10;
  localparam bit [31:0] OFF_CLR    = 32'h14;

  function new(string name = "GpioScoreboard", uvm_component parent = null);
    super.new(name, parent);
    obi_export  = new("obi_export", this);
    gpio_export = new("gpio_export", this);
  endfunction

  // Snoop register writes on the OBI bus to keep a shadow of DIR/OUT.
  // INTEN/INTTYPE/INTSTATUS/PADCFG offsets are not modeled — this
  // scoreboard only checks the output-pad datapath.
  virtual function void write_obi(obi_seq_item tr);
    bit [31:0] off;
    if (!tr.we) return;
    if (tr.addr < BASE || tr.addr >= BASE + 32'h1000) return;
    off = tr.addr - BASE;
    case (off)
      OFF_PADDIR: begin dir_shadow = tr.data;        dir_valid = 1; end
      OFF_PADOUT: begin out_shadow = tr.data;        out_valid = 1; end
      OFF_SET:    begin out_shadow |= tr.data;       out_valid = 1; end
      OFF_CLR:    begin out_shadow &= ~tr.data;      out_valid = 1; end
      default: ; // not modeled
    endcase
  endfunction

  // Check sampled pins against the shadow, only on bits configured as
  // output — input-configured pads are checked separately by whichever
  // test drives them via GpioDriver and reads PADIN back, not here.
  virtual function void write_gpio(gpio_pin_txn tr);
    if (!dir_valid || !out_valid) return;
    for (int i = 0; i < 32; i++) begin
      if (dir_shadow[i]) begin
        bit exp = out_shadow[i];
        bit act = tr.drv_val[i];
        if (act !== exp)
          `uvm_error("GPIOSB",
            $sformatf("pin[%0d] mismatch: expected=%0b actual=%0b", i, exp, act))
      end
    end
  endfunction
endclass