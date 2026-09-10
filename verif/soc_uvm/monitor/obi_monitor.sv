`ifndef OBI_MONITOR_SV
`define OBI_MONITOR_SV

import uvm_pkg::*;
`include "uvm_macros.svh"

class obi_monitor extends uvm_monitor;
  `uvm_component_utils(obi_monitor)

  virtual obi_if vif;
  uvm_analysis_port #(obi_seq_item) ap;
  string interface_name = "instr_obi_vif";

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(string)::get(this, "", "vif_name", interface_name)) begin
      // Fallback if not specified in config_db
    end
    if (!uvm_config_db#(virtual obi_if)::get(this, "", interface_name, vif)) begin
      `uvm_fatal("NO_VIF", $sformatf("Virtual interface '%s' not found for %s", interface_name, get_full_name()))
    end
  endfunction

  task run_phase(uvm_phase phase);
    obi_seq_item pending_q[$];
    obi_seq_item item;

    wait(vif.rst_ni == 1'b1);

    fork
      // Address Phase Sampler (req && gnt)
      forever begin
        @(posedge vif.clk_i);
        if (vif.rst_ni && vif.cb.req && vif.cb.gnt) begin
          item = obi_seq_item::type_id::create("item");
          item.addr  = vif.cb.addr;
          item.we    = obi_trans_kind_e'(vif.cb.we);
          item.be    = vif.cb.be;
          item.wdata = vif.cb.wdata;
          pending_q.push_back(item);
        end
      end

      // Response Phase Sampler (rvalid)
      forever begin
        @(posedge vif.clk_i);
        if (vif.rst_ni && vif.cb.rvalid) begin
          if (pending_q.size() > 0) begin
            obi_seq_item resp_item = pending_q.pop_front();
            resp_item.rdata = vif.cb.rdata;
            resp_item.err   = vif.cb.err;
            ap.write(resp_item);
          end else begin
            `uvm_error("OBI_MON", "Received rvalid without matching pending request!")
          end
        end
      end
    join_none
  endtask
endclass

`endif