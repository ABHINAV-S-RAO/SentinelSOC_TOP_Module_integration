`ifndef QSPI_PROTOCOL_MONITOR_SV
`define QSPI_PROTOCOL_MONITOR_SV

// Passive QSPI monitor. Deliberately reimplements the CMD/ADDR/DUMMY/DATA
// phase decode INDEPENDENTLY of qspi_flash_bfm (same pin assumptions, but
// a separate state machine) so the scoreboard can cross-check the BFM's
// own view of a transaction against this one. If they ever disagree, the
// bug is in one of the two decoders, not in the DUT — cheap to isolate.
//
// SAME ASSUMPTIONS AS qspi_flash_bfm.sv, kept in sync deliberately:
//   MSB-first, STD mode uses sdo0/sdi0 only, sample posedge / drive negedge.
// If you flip an assumption in the BFM, flip it here too or the two will
// spuriously disagree on every transaction.

class qspi_txn extends uvm_sequence_item;
  `uvm_object_utils(qspi_txn)
  rand bit [1:0]  mode;         // STD/QUAD_TX/QUAD_RX as driven at txn start
  rand bit [7:0]  cmd;
  rand bit [31:0] addr;
  rand int        dummy_cycles;
  rand byte       data[$];      // bytes seen in DATA phase, in order
  time            t_cs_fall;
  time            t_cs_rise;

  function new(string name = "qspi_txn");
    super.new(name);
  endfunction
endclass

class qspi_protocol_monitor extends uvm_monitor;
  `uvm_component_utils(qspi_protocol_monitor)

  virtual qspi_if vif;  // expects: spi_clk, spi_csn0, spi_mode, spi_sdo0-3, spi_sdi0-3
  uvm_analysis_port #(qspi_txn) ap;

  typedef enum {PH_IDLE, PH_CMD, PH_ADDR, PH_DUMMY, PH_DATA} phase_e;
  phase_e phase;
  qspi_txn cur;
  int bit_cnt, addr_bits_needed = 24, dummy_cnt;
  byte cur_byte;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual qspi_if)::get(this, "", "vif", vif))
      `uvm_fatal("QSPI_MON", "vif not set — connect qspi_if in soc_env")
  endfunction

  function int unsigned lane_width();
    return (vif.spi_mode == 2'b00) ? 1 : 4;
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      @(negedge vif.spi_csn0);
      cur = qspi_txn::type_id::create("cur");
      cur.t_cs_fall = $time;
      cur.mode = vif.spi_mode;
      phase_reset();
      fork
        decode_until_csn_high();
      join_none
      @(posedge vif.spi_csn0);
      disable fork;
      cur.t_cs_rise = $time;
      ap.write(cur);
    end
  endtask

  function void phase_reset();
    phase = PH_CMD; bit_cnt = 0; dummy_cnt = 0;
    cur.cmd = '0; cur.addr = '0; cur.data = {};
  endfunction

  task decode_until_csn_high();
    forever begin
      @(posedge vif.spi_clk);
      unique case (phase)
        PH_CMD: begin
          shift_in_cmd();
          if (bit_cnt == 8) begin phase = PH_ADDR; bit_cnt = 0; end
        end
        PH_ADDR: begin
          shift_in_addr();
          if (bit_cnt == addr_bits_needed) begin
            phase = PH_DUMMY; bit_cnt = 0; dummy_cnt = 0;
          end
        end
        PH_DUMMY: begin
          dummy_cnt++;
          cur.dummy_cycles = dummy_cnt;
          if (dummy_cnt == 8) phase = PH_DATA;  // TODO: confirm real dummy count vs spi_dummy_rd
        end
        PH_DATA: begin
          bit_cnt += lane_width();
          // sample MISO the monitor's own way, independent of BFM internals
          if (lane_width() == 1) cur_byte = {cur_byte[6:0], vif.spi_sdi0};
          else cur_byte = {cur_byte[3:0], vif.spi_sdi3, vif.spi_sdi2, vif.spi_sdi1, vif.spi_sdi0};
          if (bit_cnt >= 8) begin
            cur.data.push_back(cur_byte);
            bit_cnt = 0;
          end
        end
        default: ;
      endcase
    end
  endtask

  function void shift_in_cmd();
    if (lane_width() == 1) begin
      cur.cmd = {cur.cmd[6:0], vif.spi_sdo0}; bit_cnt++;
    end else begin
      cur.cmd = {cur.cmd[3:0], vif.spi_sdo3, vif.spi_sdo2, vif.spi_sdo1, vif.spi_sdo0};
      bit_cnt += 4;
    end
  endfunction

  function void shift_in_addr();
    if (lane_width() == 1) begin
      cur.addr = {cur.addr[30:0], vif.spi_sdo0}; bit_cnt++;
    end else begin
      cur.addr = {cur.addr[27:0], vif.spi_sdo3, vif.spi_sdo2, vif.spi_sdo1, vif.spi_sdo0};
      bit_cnt += 4;
    end
  endfunction

endclass

`endif