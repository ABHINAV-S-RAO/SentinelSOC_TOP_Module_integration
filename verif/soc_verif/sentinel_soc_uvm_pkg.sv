package sentinel_soc_uvm_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  `include "sentinel_soc_coverage_collector.sv"

  // ---------------------------------------------------------------------------
  // Sentinel SoC Base Test
  // Boots the SoC with Ibex core executing firmware loaded into BootROM/ISRAM.
  // Backdoor polls DSRAM[0] for PASS (0xB007B007) or FAIL (0xDEADxxxx).
  // Includes functional coverage collection and timeout monitoring.
  // ---------------------------------------------------------------------------
  class sentinel_soc_base_test extends uvm_test;
    `uvm_component_utils(sentinel_soc_base_test);

    virtual sentinel_soc_if vif;
    sentinel_soc_coverage_collector cov_collector;

    // Simulation timeout in nanoseconds (default 10ms for long crypto/stress runs)
    int timeout_ns = 10000000;
    localparam int POLL_NS = 200; // Check every 200ns

    localparam logic [31:0] PASS_SIG = 32'hB007_B007;
    localparam logic [31:0] FAIL_SIG = 32'hDEAD_DEAD;

    function new(string name="sentinel_soc_base_test", uvm_component parent=null);
      super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(!uvm_config_db#(virtual sentinel_soc_if)::get(this, "", "vif", vif))
        `uvm_fatal("NOVIF", "virtual interface must be set for: vif")

      // Instantiate Functional Coverage Collector (Signoff 6.15)
      cov_collector = sentinel_soc_coverage_collector::type_id::create("cov_collector", this);

      void'($value$plusargs("TIMEOUT_NS=%d", timeout_ns));
    endfunction

    virtual task run_phase(uvm_phase phase);
      logic [31:0] dsram0;
      int elapsed_ns;
      phase.raise_objection(this);

      `uvm_info("BASE_TEST", "Waiting for reset deassertion...", UVM_LOW)
      @(posedge vif.rst_n);
      `uvm_info("BASE_TEST", "Reset deasserted - real Ibex core executing firmware.", UVM_LOW)

      elapsed_ns = 0;
      forever begin
        #(POLL_NS * 1ns);
        elapsed_ns += POLL_NS;

        // Backdoor poll of DSRAM[0]
        dsram0 = sentinel_soc_uvm_top.u_dut.u_dsram.mem[0];

        if (dsram0 == PASS_SIG) begin
          `uvm_info("BASE_TEST",
            $sformatf("========================================================\n"
                    ~ "  PASS: Firmware wrote 0x%08X to DSRAM[0] after %0d ns\n"
                    ~ "========================================================",
                      dsram0, elapsed_ns), UVM_LOW)
          break;
        end else if (((dsram0 & 32'hFFFF_0000) == 32'hDEAD_0000) || (dsram0 == FAIL_SIG)) begin
          `uvm_error("BASE_TEST",
            $sformatf("========================================================\n"
                    ~ "  FAIL: Firmware reported ERROR: DSRAM[0]=0x%08X\n"
                    ~ "        Failure Code: 0x%04X after %0d ns\n"
                    ~ "========================================================",
                      dsram0, dsram0[15:0], elapsed_ns))
          break;
        end else if (elapsed_ns >= timeout_ns) begin
          `uvm_error("BASE_TEST",
            $sformatf("========================================================\n"
                    ~ "  TIMEOUT: DSRAM[0]=0x%08X after %0d ns\n"
                    ~ "           Firmware did not terminate within limit!\n"
                    ~ "========================================================",
                      dsram0, elapsed_ns))
          break;
        end
      end

      `uvm_info("BASE_TEST", "Test run_phase complete.", UVM_LOW)
      phase.drop_objection(this);
    endtask

  endclass

  // ---------------------------------------------------------------------------
  // Dedicated Signoff Test Classes (Criteria 6.9 - 6.14)
  // ---------------------------------------------------------------------------
  class integrated_soc_test extends sentinel_soc_base_test;
    `uvm_component_utils(integrated_soc_test)
    function new(string name="integrated_soc_test", uvm_component parent=null);
      super.new(name, parent);
    endfunction
  endclass

  class spiflash_boot_test extends sentinel_soc_base_test;
    `uvm_component_utils(spiflash_boot_test)
    function new(string name="spiflash_boot_test", uvm_component parent=null);
      super.new(name, parent);
    endfunction
  endclass

  class trap_robustness_test extends sentinel_soc_base_test;
    `uvm_component_utils(trap_robustness_test)
    function new(string name="trap_robustness_test", uvm_component parent=null);
      super.new(name, parent);
    endfunction
  endclass

  class soc_stress_test extends sentinel_soc_base_test;
    `uvm_component_utils(soc_stress_test)
    function new(string name="soc_stress_test", uvm_component parent=null);
      super.new(name, parent);
    endfunction
  endclass

  class rv32imc_isa_test extends sentinel_soc_base_test;
    `uvm_component_utils(rv32imc_isa_test)
    function new(string name="rv32imc_isa_test", uvm_component parent=null);
      super.new(name, parent);
    endfunction
  endclass

  class memory_exhaustive_test extends sentinel_soc_base_test;
    `uvm_component_utils(memory_exhaustive_test)
    function new(string name="memory_exhaustive_test", uvm_component parent=null);
      super.new(name, parent);
    endfunction
  endclass

  class plic_priority_test extends sentinel_soc_base_test;
    `uvm_component_utils(plic_priority_test)
    function new(string name="plic_priority_test", uvm_component parent=null);
      super.new(name, parent);
    endfunction
  endclass

  class benchmark_dhrystone_test extends sentinel_soc_base_test;
    `uvm_component_utils(benchmark_dhrystone_test)
    function new(string name="benchmark_dhrystone_test", uvm_component parent=null);
      super.new(name, parent);
    endfunction
  endclass

  // Targeted Subsystem Tests
  class uart_boot_test extends sentinel_soc_base_test;
    `uvm_component_utils(uart_boot_test)
    function new(string name="uart_boot_test", uvm_component parent=null);
      super.new(name, parent);
    endfunction
  endclass

  class crypto_test extends sentinel_soc_base_test;
    `uvm_component_utils(crypto_test)
    function new(string name="crypto_test", uvm_component parent=null);
      super.new(name, parent);
    endfunction
  endclass

  class plic_test extends sentinel_soc_base_test;
    `uvm_component_utils(plic_test)
    function new(string name="plic_test", uvm_component parent=null);
      super.new(name, parent);
    endfunction
  endclass

  class access_ctrl_test extends sentinel_soc_base_test;
    `uvm_component_utils(access_ctrl_test)
    function new(string name="access_ctrl_test", uvm_component parent=null);
      super.new(name, parent);
    endfunction
  endclass

  class dift_test extends sentinel_soc_base_test;
    `uvm_component_utils(dift_test)
    function new(string name="dift_test", uvm_component parent=null);
      super.new(name, parent);
    endfunction
  endclass

  class dift_off_test extends dift_test;
    `uvm_component_utils(dift_off_test)
    function new(string name="dift_off_test", uvm_component parent=null);
      super.new(name, parent);
    endfunction
  endclass

  class soc_buffer_test extends sentinel_soc_base_test;
    `uvm_component_utils(soc_buffer_test)
    function new(string name="soc_buffer_test", uvm_component parent=null);
      super.new(name, parent);
    endfunction
  endclass

endpackage
