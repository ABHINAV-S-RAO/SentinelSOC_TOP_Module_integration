`ifndef DIFT_TAG_MONITOR_SV
`define DIFT_TAG_MONITOR_SV

import uvm_pkg::*;
`include "uvm_macros.svh"

class dift_tag_monitor extends uvm_monitor;
  `uvm_component_utils(dift_tag_monitor)

  virtual dift_tag_if vif;
  uvm_analysis_port #(dift_tag_seq_item) ap;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual dift_tag_if)::get(this, "", "dift_tag_vif", vif)) begin
      `uvm_fatal("NO_VIF", {"Virtual interface must be set for: ", get_full_name(), ".dift_tag_vif"});
    end
  endfunction

  task run_phase(uvm_phase phase);
    dift_tag_seq_item item;

    wait(vif.rst_ni == 1'b1);

    forever begin
      @(posedge vif.clk_i);
      if (vif.rst_ni) begin
        if (vif.cb.tag_req || vif.cb.irq_dift) begin
          item = dift_tag_seq_item::type_id::create("item");
          item.tag_addr  = vif.cb.tag_addr;
          item.tag_we    = vif.cb.tag_we;
          item.tag_wdata = vif.cb.tag_wdata;
          item.tag_rdata = vif.cb.tag_rdata;
          item.irq_dift  = vif.cb.irq_dift;
          ap.write(item);
        end
      end
    end
  endtask
endclass

`endif