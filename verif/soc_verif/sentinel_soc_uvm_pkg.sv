package sentinel_soc_uvm_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // ---------------------------------------------------------------------------
  // Base Test
  // ---------------------------------------------------------------------------
  // ---------------------------------------------------------------------------
  // Sentinel SoC Base Test
  // Boots the SoC, loads bootrom.hex firmware, then polls DSRAM[0] for the
  // firmware's PASS (0xB007B007) or FAIL (0xDEADDEAD) signature.
  // Times out after TIMEOUT_NS nanoseconds if signature never appears.
  // ---------------------------------------------------------------------------
  class sentinel_soc_base_test extends uvm_test;
    `uvm_component_utils(sentinel_soc_base_test);

    virtual sentinel_soc_if vif;

    // Maximum simulation time to wait for firmware to complete (ns)
    // Bootrom executes ~200 instructions at 50MHz -> ~4000ns; generous margin.
    localparam int TIMEOUT_NS  = 50000;
    localparam int POLL_NS     = 200;    // check every 200ns

    localparam logic [31:0] PASS_SIG = 32'hB007_B007;
    localparam logic [31:0] FAIL_SIG = 32'hDEAD_DEAD;

    function new(string name="sentinel_soc_base_test", uvm_component parent=null);
      super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(!uvm_config_db#(virtual sentinel_soc_if)::get(this, "", "vif", vif))
        `uvm_fatal("NOVIF", "virtual interface must be set for: vif")
    endfunction

    virtual task run_phase(uvm_phase phase);
      logic [31:0] dsram0;
      int elapsed_ns;
      phase.raise_objection(this);

      `uvm_info("BASE_TEST", "Waiting for reset to deassert...", UVM_LOW)
      @(posedge vif.rst_n);
      `uvm_info("BASE_TEST", "Reset deasserted — firmware executing.", UVM_LOW)

      // Poll DSRAM[0] via hierarchical reference until firmware writes PASS/FAIL
      elapsed_ns = 0;
      forever begin
        #(POLL_NS * 1ns);
        elapsed_ns += POLL_NS;

        // Peek directly into DUT DSRAM (behavioral sim backdoor)
        dsram0 = sentinel_soc_uvm_top.u_dut.u_dsram.mem[0];

        if (dsram0 == PASS_SIG) begin
          `uvm_info("BASE_TEST",
            $sformatf("PASS: firmware wrote 0x%08X to DSRAM[0] after %0d ns",
                      dsram0, elapsed_ns), UVM_LOW)
          break;
        end else if (dsram0 == FAIL_SIG) begin
          `uvm_error("BASE_TEST",
            $sformatf("FAIL: firmware wrote 0x%08X to DSRAM[0] after %0d ns",
                      dsram0, elapsed_ns))
          break;
        end else if (elapsed_ns >= TIMEOUT_NS) begin
          `uvm_error("BASE_TEST",
            $sformatf("TIMEOUT: DSRAM[0]=0x%08X after %0d ns — firmware never completed",
                      dsram0, elapsed_ns))
          break;
        end
      end

      `uvm_info("BASE_TEST", "Test run_phase complete.", UVM_LOW)
      phase.drop_objection(this);
    endtask

  endclass

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
