// =============================================================================
// sentinel_soc_coverage_collector.sv
// UVM Functional Coverage Collector for Full SentinelSOC Integration Signoff
// Covers: Memory Map, APB Slaves, Byte Enables, PLIC IRQs, Security Lifecycle,
//         and Trap/Robustness.
// =============================================================================

`ifndef SENTINEL_SOC_COVERAGE_COLLECTOR_SV
`define SENTINEL_SOC_COVERAGE_COLLECTOR_SV

import uvm_pkg::*;
`include "uvm_macros.svh"

class sentinel_soc_coverage_collector extends uvm_component;
  `uvm_component_utils(sentinel_soc_coverage_collector)

  virtual sentinel_soc_if vif;

  // Variables sampled by covergroups
  logic [31:0] sample_addr;
  logic        sample_we;
  logic [ 3:0] sample_be;
  logic [ 3:0] sample_irq_source;
  logic [ 1:0] sample_irq_prio;
  logic        sample_isram_locked;
  logic        sample_boot_done;
  logic        sample_crypto_verified;
  logic [31:0] sample_mcause;

  // ---------------------------------------------------------------------------
  // Covergroup 1: SoC Bus Address Map & Access Protocol
  // ---------------------------------------------------------------------------
  covergroup cg_soc_address_map;
    option.per_instance = 1;
    option.name = "cg_soc_address_map";

    cp_addr_region: coverpoint sample_addr {
      bins bin_bootrom   = {[32'h0000_0000 : 32'h0000_0FFF]};
      bins bin_isram     = {[32'h0001_0000 : 32'h0001_0FFF]};
      bins bin_dsram     = {[32'h0002_0000 : 32'h0002_0FFF]};
      bins bin_ctrl      = {[32'h0003_0000 : 32'h0003_0FFF]};
      bins bin_buf       = {[32'h0004_0000 : 32'h0004_0FFF]};
      bins bin_crypto    = {[32'h0005_0000 : 32'h0005_0FFF]};
      bins bin_plic      = {[32'h0C00_0000 : 32'h0C3F_FFFF]};
      bins bin_apb_qspi  = {[32'h1050_0000 : 32'h1050_0FFF]};
      bins bin_apb_timer = {[32'h1050_1000 : 32'h1050_1FFF]};
      bins bin_apb_spi   = {[32'h1050_2000 : 32'h1050_2FFF]};
      bins bin_apb_uart  = {[32'h1050_3000 : 32'h1050_3FFF]};
      bins bin_apb_gpio  = {[32'h1060_0000 : 32'h1060_0FFF]};
      bins bin_dbg       = {[32'h1A11_0000 : 32'h1A11_FFFF]};
    }

    cp_we: coverpoint sample_we {
      bins read  = {1'b0};
      bins write = {1'b1};
    }

    cp_be: coverpoint sample_be {
      bins byte0     = {4'b0001};
      bins byte1     = {4'b0010};
      bins byte2     = {4'b0100};
      bins byte3     = {4'b1000};
      bins half_low  = {4'b0011};
      bins half_high = {4'b1100};
      bins full_word = {4'b1111};
    }

    cross_addr_we: cross cp_addr_region, cp_we;
    cross_addr_be: cross cp_addr_region, cp_be;
  endgroup

  // ---------------------------------------------------------------------------
  // Covergroup 2: PLIC Interrupt Sources & Priorities
  // ---------------------------------------------------------------------------
  covergroup cg_soc_plic_cov;
    option.per_instance = 1;
    option.name = "cg_soc_plic_cov";

    cp_source: coverpoint sample_irq_source {
      bins uart  = {4'd1};
      bins spi   = {4'd2};
      bins qspi  = {4'd3};
      bins gpio  = {4'd4};
      bins timer = {4'd5};
      bins buf   = {4'd6};
      bins sha   = {4'd7};
      bins dift  = {4'd8};
    }

    cp_prio: coverpoint sample_irq_prio {
      bins prio0 = {2'd0};
      bins prio1 = {2'd1};
      bins prio2 = {2'd2};
      bins prio3 = {2'd3};
    }

    cross_src_prio: cross cp_source, cp_prio;
  endgroup

  // ---------------------------------------------------------------------------
  // Covergroup 3: SoC Security Lifecycle & Remap
  // ---------------------------------------------------------------------------
  covergroup cg_soc_lifecycle;
    option.per_instance = 1;
    option.name = "cg_soc_lifecycle";

    cp_isram_lock: coverpoint sample_isram_locked {
      bins unlocked = {1'b0};
      bins locked   = {1'b1};
      bins trans_to_lock = (1'b0 => 1'b1);
    }

    cp_boot_done: coverpoint sample_boot_done {
      bins boot_active = {1'b0};
      bins boot_sealed = {1'b1};
      bins trans_to_done = (1'b0 => 1'b1);
    }

    cp_crypto_verif: coverpoint sample_crypto_verified {
      bins unverified = {1'b0};
      bins verified   = {1'b1};
    }
  endgroup

  // ---------------------------------------------------------------------------
  // Covergroup 4: Trap Robustness & Exception Causes
  // ---------------------------------------------------------------------------
  covergroup cg_soc_traps;
    option.per_instance = 1;
    option.name = "cg_soc_traps";

    cp_cause: coverpoint sample_mcause[3:0] {
      bins illegal_instr    = {4'd2};
      bins load_misaligned  = {4'd4};
      bins load_fault       = {4'd5};
      bins store_misaligned = {4'd6};
      bins store_fault      = {4'd7};
      bins external_irq     = {4'd11};
    }
  endgroup

  function new(string name="sentinel_soc_coverage_collector", uvm_component parent=null);
    super.new(name, parent);
    cg_soc_address_map = new();
    cg_soc_plic_cov    = new();
    cg_soc_lifecycle   = new();
    cg_soc_traps       = new();
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual sentinel_soc_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "sentinel_soc_coverage_collector vif not found in config_db")
  endfunction

  virtual task run_phase(uvm_phase phase);
    fork
      sample_bus_loop();
      sample_lifecycle_loop();
    join
  endtask

  // Monitor internal DUT signals hierarchically to sample bus transfers
  task sample_bus_loop();
    forever begin
      @(posedge vif.clk);
      if (vif.rst_n) begin
        // Sample core data bus
        if (sentinel_soc_uvm_top.u_dut.data_req && sentinel_soc_uvm_top.u_dut.data_gnt) begin
          sample_addr = sentinel_soc_uvm_top.u_dut.data_addr;
          sample_we   = sentinel_soc_uvm_top.u_dut.data_we;
          sample_be   = sentinel_soc_uvm_top.u_dut.data_be;
          cg_soc_address_map.sample();
        end

        // Sample instruction bus
        if (sentinel_soc_uvm_top.u_dut.instr_req && sentinel_soc_uvm_top.u_dut.instr_gnt) begin
          sample_addr = sentinel_soc_uvm_top.u_dut.instr_addr;
          sample_we   = 1'b0;
          sample_be   = 4'b1111;
          cg_soc_address_map.sample();
        end

        // Sample traps
        if (sentinel_soc_uvm_top.u_dut.u_core.u_ibex_top.u_ibex_core.cs_registers_i.mcause_q != 0) begin
          sample_mcause = sentinel_soc_uvm_top.u_dut.u_core.u_ibex_top.u_ibex_core.cs_registers_i.mcause_q;
          cg_soc_traps.sample();
        end

        // Sample PLIC Interrupt triggers
        if (sentinel_soc_uvm_top.u_dut.u_plic.irq_sources_i != 0) begin
          for (int s = 1; s <= 8; s++) begin
            if (sentinel_soc_uvm_top.u_dut.u_plic.irq_sources_i[s-1]) begin
              sample_irq_source = s;
              sample_irq_prio   = sentinel_soc_uvm_top.u_dut.u_plic.u_plic_regmap.prio_q[s];
              cg_soc_plic_cov.sample();
            end
          end
        end
      end
    end
  endtask

  task sample_lifecycle_loop();
    forever begin
      @(posedge vif.clk);
      if (vif.rst_n) begin
        sample_isram_locked    = sentinel_soc_uvm_top.u_dut.isram_locked;
        sample_boot_done       = sentinel_soc_uvm_top.u_dut.boot_done;
        sample_crypto_verified = sentinel_soc_uvm_top.u_dut.crypto_verified;
        cg_soc_lifecycle.sample();
      end
    end
  endtask

  virtual function void report_phase(uvm_phase phase);
    real cov_addr, cov_plic, cov_life, cov_trap, cov_total;
    super.report_phase(phase);

    cov_addr  = cg_soc_address_map.get_coverage();
    cov_plic  = cg_soc_plic_cov.get_coverage();
    cov_life  = cg_soc_lifecycle.get_coverage();
    cov_trap  = cg_soc_traps.get_coverage();
    cov_total = (cov_addr + cov_plic + cov_life + cov_trap) / 4.0;

    `uvm_info("SIGNOFF_COV", "=================================================================", UVM_LOW)
    `uvm_info("SIGNOFF_COV", "         SENTINEL SOC FUNCTIONAL COVERAGE REPORT (SIGNOFF 6.15)   ", UVM_LOW)
    `uvm_info("SIGNOFF_COV", "=================================================================", UVM_LOW)
    `uvm_info("SIGNOFF_COV", $sformatf(" [1] SoC Bus Address Map & Protocol Coverage : %6.2f %%", cov_addr), UVM_LOW)
    `uvm_info("SIGNOFF_COV", $sformatf(" [2] PLIC Interrupt Sources & Priority Cov    : %6.2f %%", cov_plic), UVM_LOW)
    `uvm_info("SIGNOFF_COV", $sformatf(" [3] Security Lifecycle & Lock Transition Cov : %6.2f %%", cov_life), UVM_LOW)
    `uvm_info("SIGNOFF_COV", $sformatf(" [4] Trap Robustness & Exception Cause Cov   : %6.2f %%", cov_trap), UVM_LOW)
    `uvm_info("SIGNOFF_COV", "-----------------------------------------------------------------", UVM_LOW)
    `uvm_info("SIGNOFF_COV", $sformatf(" OVERALL SOC FUNCTIONAL COVERAGE METRIC     : %6.2f %%", cov_total), UVM_LOW)
    `uvm_info("SIGNOFF_COV", "=================================================================", UVM_LOW)
  endfunction

endclass

`endif
