class qspi_cov extends uvm_subscriber #(qspi_txn);
  `uvm_component_utils(qspi_cov)

  qspi_txn txn;

  covergroup qspi_cg;
    option.per_instance = 1;

    // SPI Command Opcodes
    cmd_cp: coverpoint txn.opcode {
      bins read_id    = {8'h9F};
      bins read_std   = {8'h03};
      bins read_fast  = {8'h0B};
      bins read_quad  = {8'hEB};
      bins page_prog  = {8'h02};
      bins sector_ers = {8'h20};
      bins unmapped   = default;
    }

    // Bus Width Modes
    mode_cp: coverpoint txn.bus_mode {
      bins single_spi = {2'b00};
      bins dual_spi   = {2'b01};
      bins quad_spi   = {2'b10};
    }

    // Clock Prescaler Settings
    clk_div_cp: coverpoint txn.clk_divider {
      bins div2  = {3'd1};
      bins div4  = {3'd2};
      bins div8  = {3'd4};
      bins div16 = {3'd8};
    }

    // Cross Coverage: Bus Mode vs Command
    mode_x_cmd: cross mode_cp, cmd_cp;

    // Cross Coverage: Clock Prescaler vs Bus Mode
    clk_x_mode: cross clk_div_cp, mode_cp;
  endgroup

  function new(string name, uvm_component parent);
    super.new(name, parent);
    qspi_cg = new();
  endfunction

  function void write(qspi_txn t);
    this.txn = t;
    qspi_cg.sample();
  endfunction
endclass