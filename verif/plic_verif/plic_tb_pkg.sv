// plic_tb_pkg.sv
// Non-UVM, class-based PLIC testbench package, matching the existing
// UART/SHA testbench style (plain classes + virtual interfaces, no uvm_pkg).

package plic_tb_pkg;

  // ---------------------------------------------------------------------
  // Address map (from context: plic_regs as generated)
  // ---------------------------------------------------------------------
  localparam int unsigned N_SOURCE       = 12;
  localparam logic [31:0] PLIC_PRIORITY0 = 32'h0C00_0000; // + 4*i, i=0..12
  localparam logic [31:0] PLIC_IP        = 32'h0C00_1000; // RO
  localparam logic [31:0] PLIC_IE        = 32'h0C00_2000;
  localparam logic [31:0] PLIC_THRESHOLD = 32'h0C20_0000;
  localparam logic [31:0] PLIC_CC        = 32'h0C20_0004;

  // Source ID -> name, for readable log/scoreboard messages
  function automatic string src_name(int unsigned id);
    case (id)
      0:  return "dummy";
      1:  return "irq_uart";
      2:  return "irq_spi";
      3:  return "irq_qspi";
      4:  return "irq_gpio";
      5:  return "irq_timer_periph";
      6:  return "irq_buf";
      7:  return "irq_sha";
      default: return $sformatf("unused_%0d", id);
    endcase
  endfunction

  // ---------------------------------------------------------------------
  // plic_reg_driver: drives/reads the reg_req_t/reg_rsp_t bus via
  // plic_reg_if. One outstanding transaction at a time (matches the
  // simple valid/ready/rvalid protocol described for the OBI-to-reg shim).
  // ---------------------------------------------------------------------
  class plic_reg_driver;
    virtual plic_reg_if.drv vif;
    int unsigned timeout_cycles = 100;

    function new(virtual plic_reg_if.drv vif);
      this.vif = vif;
    endfunction

    task automatic reset();
      vif.drv_cb.valid <= 1'b0;
      vif.drv_cb.write <= 1'b0;
      vif.drv_cb.addr  <= '0;
      vif.drv_cb.wdata <= '0;
      vif.drv_cb.wstrb <= '0;
    endtask

    // Blocking write. Fails via $error on timeout waiting for ready.
    task automatic write(input logic [31:0] addr, input logic [31:0] data,
                          input logic [3:0] wstrb = 4'hF);
      int unsigned n = 0;
      vif.drv_cb.valid <= 1'b1;
      vif.drv_cb.write <= 1'b1;
      vif.drv_cb.addr  <= addr;
      vif.drv_cb.wdata <= data;
      vif.drv_cb.wstrb <= wstrb;
      do begin
        @(vif.drv_cb);
        n++;
        if (n > timeout_cycles)
          $error("[plic_reg_driver] WRITE timeout addr=0x%08h (no ready)", addr);
      end while (!vif.drv_cb.ready && n <= timeout_cycles);
      if (vif.drv_cb.error)
        $error("[plic_reg_driver] WRITE bus error addr=0x%08h", addr);
      vif.drv_cb.valid <= 1'b0;
      vif.drv_cb.write <= 1'b0;
      @(vif.drv_cb);
    endtask

    // Blocking read. Returns rdata by ref.
    task automatic read(input logic [31:0] addr, output logic [31:0] data);
      int unsigned n = 0;
      vif.drv_cb.valid <= 1'b1;
      vif.drv_cb.write <= 1'b0;
      vif.drv_cb.addr  <= addr;
      vif.drv_cb.wstrb <= 4'h0;
      do begin
        @(vif.drv_cb);
        n++;
        if (n > timeout_cycles)
          $error("[plic_reg_driver] READ timeout addr=0x%08h (no ready)", addr);
      end while (!vif.drv_cb.ready && n <= timeout_cycles);
      if (vif.drv_cb.error)
        $error("[plic_reg_driver] READ bus error addr=0x%08h", addr);
      data = vif.drv_cb.rdata;
      vif.drv_cb.valid <= 1'b0;
      @(vif.drv_cb);
    endtask

    // Convenience wrappers for the sparse map
    task automatic write_priority(int unsigned id, logic [31:0] val);
      write(PLIC_PRIORITY0 + 4*id, val);
    endtask
    task automatic read_priority(int unsigned id, output logic [31:0] val);
      read(PLIC_PRIORITY0 + 4*id, val);
    endtask
    task automatic write_ie(logic [31:0] mask);
      write(PLIC_IE, mask);
    endtask
    task automatic read_ie(output logic [31:0] val);
      read(PLIC_IE, val);
    endtask
    task automatic read_ip(output logic [31:0] val);
      read(PLIC_IP, val);
    endtask
    task automatic write_threshold(logic [31:0] val);
      write(PLIC_THRESHOLD, val);
    endtask
    task automatic read_threshold(output logic [31:0] val);
      read(PLIC_THRESHOLD, val);
    endtask
    // Reading CC == claim; writing CC == complete
    task automatic claim(output logic [31:0] id);
      read(PLIC_CC, id);
    endtask
    task automatic complete(logic [31:0] id);
      write(PLIC_CC, id);
    endtask
  endclass

  // ---------------------------------------------------------------------
  // irq_source_driver: drives the N_SOURCE-wide level-triggered irq_src
  // vector directly (bypassing real peripherals), per the verification
  // plan's single-source / multi-source directed tests.
  // ---------------------------------------------------------------------
  class irq_source_driver;
    virtual plic_irq_if.drv vif;
  
    function new(virtual plic_irq_if.drv vif);
      this.vif = vif;
    endfunction
    
    task automatic assert_src(int unsigned id);
      vif.irq_src[id-1] = 1'b1;
    endtask
    task automatic deassert_src(int unsigned id);
      vif.irq_src[id-1] = 1'b0;
    endtask
    task automatic clear_all();
      vif.irq_src = '0;
    endtask
  endclass

  // ---------------------------------------------------------------------
  // plic_model: reference model tracking PRIORITY/IE/THRESHOLD/IP state
  // and predicting claim ID + irq_external, per the arbitration rules:
  //   - effective = ip[i] & ie[i]
  //   - eligible  = effective & (priority[i] > threshold)   (strict >)
  //   - winner    = lowest ID among eligible with max priority
  //   - claim drops that source from arbitration until complete
  // ---------------------------------------------------------------------
  class plic_model;
    logic [2:0]  priority_q[N_SOURCE]; // 2 bits actually valid (MAX_PRIO=3 -> 2b field per plic_regs)
    bit          ie_q[N_SOURCE];
    bit          ip_q[N_SOURCE];       // pending, gateway-tracked
    bit          claimed_q[N_SOURCE];  // held by gateway pending complete
    logic [31:0] threshold_q;

    function new();
      foreach (priority_q[i]) priority_q[i] = '0;
      foreach (ie_q[i])       ie_q[i]       = 0;
      foreach (ip_q[i])       ip_q[i]       = 0;
      foreach (claimed_q[i])  claimed_q[i]  = 0;
      threshold_q = '0;
    endfunction

    function automatic void set_priority(int unsigned id, logic [31:0] val);
      priority_q[id] = val[2:0];
    endfunction
    function automatic void set_ie(logic [31:0] mask);
      foreach (ie_q[i])
    ie_q[i] = mask[i+1];
    endfunction
    function automatic void set_threshold(logic [31:0] val);
      threshold_q = val;
    endfunction
    // Call when testbench asserts/deasserts a source's physical line
    function automatic void set_src_level(int unsigned id, bit level);
      if (level && !claimed_q[id]) ip_q[id] = 1;
      if (!level)                  ip_q[id] = 0; // level deasserted clears pending on this model
    endfunction

    // Returns 1 if some source is eligible, and its id/priority via ref
    function automatic bit compute_expected(output int unsigned winner_id,
                                             output logic [2:0] winner_prio);
      bit found = 0;
      logic [2:0] best_prio = '0;
      int unsigned best_id = 0;
      for (int unsigned i = 0; i < N_SOURCE; i++) begin
        bit eligible = ip_q[i] && ie_q[i] && !claimed_q[i] &&
                       (priority_q[i] > threshold_q[2:0]);
        if (eligible) begin
          if (!found || priority_q[i] > best_prio ||
              (priority_q[i] == best_prio && i < best_id)) begin
            found     = 1;
            best_prio = priority_q[i];
            best_id   = i;
          end
        end
      end
      winner_id   = best_id;
      winner_prio = best_prio;
      return found;
    endfunction

    function automatic logic [31:0] expected_ip();
      logic [31:0] v = '0;
      foreach (ip_q[i]) v[i] = ip_q[i];
      return v;
    endfunction

    // Model-side claim/complete, call alongside driving claim()/complete()
    function automatic void do_claim(int unsigned id);
      claimed_q[id] = 1;
      ip_q[id]      = 0;
    endfunction
    function automatic void do_complete(int unsigned id, bit level_still_asserted);
      claimed_q[id] = 0;
      if (level_still_asserted) ip_q[id] = 1;
    endfunction
  endclass

  // ---------------------------------------------------------------------
  // plic_scoreboard: compares DUT observations against plic_model
  // ---------------------------------------------------------------------
  class plic_scoreboard;
    plic_model model;
    int unsigned pass_count = 0;
    int unsigned fail_count = 0;

    function new(plic_model model);
      this.model = model;
    endfunction

    function automatic void check(string tag, logic actual, logic expected);
      if (actual === expected) begin
        pass_count++;
        $display("[SCB][PASS] %-40s actual=%0b expected=%0b", tag, actual, expected);
      end else begin
        fail_count++;
        $error("[SCB][FAIL] %-40s actual=%0b expected=%0b", tag, actual, expected);
      end
    endfunction

    function automatic void check32(string tag, logic [31:0] actual, logic [31:0] expected);
      if (actual === expected) begin
        pass_count++;
        $display("[SCB][PASS] %-40s actual=0x%08h expected=0x%08h", tag, actual, expected);
      end else begin
        fail_count++;
        $error("[SCB][FAIL] %-40s actual=0x%08h expected=0x%08h", tag, actual, expected);
      end
    endfunction

    function automatic void report();
      $display("=================================================");
      $display("PLIC scoreboard: %0d PASS / %0d FAIL", pass_count, fail_count);
      $display("=================================================");
      if (fail_count > 0) $fatal(1, "PLIC verification FAILED");
    endfunction
  endclass

endpackage