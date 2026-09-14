// Workaround module for Xcelium struct array indexing bug in obi_demux

module soc_obi_demux #(
  /// The OBI configuration for all ports.
  parameter obi_pkg::obi_cfg_t ObiCfg      = obi_pkg::ObiDefaultConfig,
  /// The request struct for all ports.
  parameter type               obi_req_t   = logic,
  /// The response struct for all ports.
  parameter type               obi_rsp_t   = logic,
  /// The number of manager ports.
  parameter int unsigned       NumMgrPorts = 32'd0,
  /// The maximum number of outstanding transactions.
  parameter int unsigned       NumMaxTrans = 32'd0,
  /// The type of the port select signal.
  parameter type               select_t    = logic [cf_math_pkg::idx_width(NumMgrPorts)-1:0]
) (
  input  logic                       clk_i,
  input  logic                       rst_ni,

  input  select_t                    sbr_port_select_i,
  input  obi_req_t                   sbr_port_req_i,
  output obi_rsp_t                   sbr_port_rsp_o,

  output obi_req_t [NumMgrPorts-1:0] mgr_ports_req_o,
  input  obi_rsp_t [NumMgrPorts-1:0] mgr_ports_rsp_i
);

  if (ObiCfg.Integrity) begin : gen_integrity_err
    $fatal(1, "unimplemented");
  end

  // stall requests to ensure in-order behavior (could be handled differently with rready)
  localparam int unsigned CounterWidth = cf_math_pkg::idx_width(NumMaxTrans);

  logic cnt_up, cnt_down, overflow;
  logic [CounterWidth-1:0] in_flight;
  logic sbr_port_gnt;
  logic sbr_port_rready;
  logic rsp_phase_stalled;

  select_t select_d, select_q;

  always_comb begin : proc_req
    select_d = select_q;
    cnt_up = 1'b0;
    sbr_port_gnt = 1'b0;
    
    // Explicit 0 assignment for all ports
    mgr_ports_req_o = '0;

    if (!overflow && (sbr_port_select_i == select_q || (!rsp_phase_stalled &&
          (in_flight == '0 || (in_flight == 1 && cnt_down))))) begin
      // Active grant path
      sbr_port_gnt = mgr_ports_rsp_i[sbr_port_select_i].gnt;
      
      // Xcelium Workaround: Unroll the struct array assignment to avoid loop/index bugs
      case (sbr_port_select_i)
        0:  begin mgr_ports_req_o[0].req = sbr_port_req_i.req;  mgr_ports_req_o[0].a = sbr_port_req_i.a; end
        1:  if (NumMgrPorts > 1) begin mgr_ports_req_o[1].req = sbr_port_req_i.req;  mgr_ports_req_o[1].a = sbr_port_req_i.a; end
        2:  if (NumMgrPorts > 2) begin mgr_ports_req_o[2].req = sbr_port_req_i.req;  mgr_ports_req_o[2].a = sbr_port_req_i.a; end
        3:  if (NumMgrPorts > 3) begin mgr_ports_req_o[3].req = sbr_port_req_i.req;  mgr_ports_req_o[3].a = sbr_port_req_i.a; end
        4:  if (NumMgrPorts > 4) begin mgr_ports_req_o[4].req = sbr_port_req_i.req;  mgr_ports_req_o[4].a = sbr_port_req_i.a; end
        5:  if (NumMgrPorts > 5) begin mgr_ports_req_o[5].req = sbr_port_req_i.req;  mgr_ports_req_o[5].a = sbr_port_req_i.a; end
        6:  if (NumMgrPorts > 6) begin mgr_ports_req_o[6].req = sbr_port_req_i.req;  mgr_ports_req_o[6].a = sbr_port_req_i.a; end
        7:  if (NumMgrPorts > 7) begin mgr_ports_req_o[7].req = sbr_port_req_i.req;  mgr_ports_req_o[7].a = sbr_port_req_i.a; end
        8:  if (NumMgrPorts > 8) begin mgr_ports_req_o[8].req = sbr_port_req_i.req;  mgr_ports_req_o[8].a = sbr_port_req_i.a; end
        9:  if (NumMgrPorts > 9) begin mgr_ports_req_o[9].req = sbr_port_req_i.req;  mgr_ports_req_o[9].a = sbr_port_req_i.a; end
        10: if (NumMgrPorts > 10) begin mgr_ports_req_o[10].req = sbr_port_req_i.req; mgr_ports_req_o[10].a = sbr_port_req_i.a; end
        11: if (NumMgrPorts > 11) begin mgr_ports_req_o[11].req = sbr_port_req_i.req; mgr_ports_req_o[11].a = sbr_port_req_i.a; end
        12: if (NumMgrPorts > 12) begin mgr_ports_req_o[12].req = sbr_port_req_i.req; mgr_ports_req_o[12].a = sbr_port_req_i.a; end
        13: if (NumMgrPorts > 13) begin mgr_ports_req_o[13].req = sbr_port_req_i.req; mgr_ports_req_o[13].a = sbr_port_req_i.a; end
        14: if (NumMgrPorts > 14) begin mgr_ports_req_o[14].req = sbr_port_req_i.req; mgr_ports_req_o[14].a = sbr_port_req_i.a; end
        15: if (NumMgrPorts > 15) begin mgr_ports_req_o[15].req = sbr_port_req_i.req; mgr_ports_req_o[15].a = sbr_port_req_i.a; end
        default: ;
      endcase
    end

    if (mgr_ports_req_o[sbr_port_select_i].req && mgr_ports_rsp_i[sbr_port_select_i].gnt) begin
      select_d = sbr_port_select_i;
      cnt_up = 1'b1;
    end
  end

  assign sbr_port_rsp_o.gnt    = sbr_port_gnt;
  assign sbr_port_rsp_o.r      = mgr_ports_rsp_i[select_q].r;
  assign sbr_port_rsp_o.rvalid = mgr_ports_rsp_i[select_q].rvalid;

  if (ObiCfg.UseRReady) begin : gen_rready
    assign sbr_port_rready = sbr_port_req_i.rready;
    assign rsp_phase_stalled = sbr_port_rsp_o.rvalid && !sbr_port_rready;

    for (genvar i = 0; i < NumMgrPorts; i++) begin : gen_rready
      assign mgr_ports_req_o[i].rready = sbr_port_req_i.rready;
    end
  end else begin : gen_no_rready
    assign sbr_port_rready = 1'b1;
    assign rsp_phase_stalled = 1'b0;
  end

  // R-6: retire the active response only after its R phase transfer completes
  assign cnt_down = sbr_port_rsp_o.rvalid && sbr_port_rready;

  delta_counter #(
    .WIDTH           ( CounterWidth ),
    .STICKY_OVERFLOW ( 1'b0         )
  ) i_counter (
    .clk_i,
    .rst_ni,

    .clear_i   ( 1'b0                           ),
    .en_i      ( cnt_up ^ cnt_down              ),
    .load_i    ( 1'b0                           ),
    .down_i    ( cnt_down                       ),
    .delta_i   ( {{CounterWidth-1{1'b0}}, 1'b1} ),
    .d_i       ( '0                             ),
    .q_o       ( in_flight                      ),
    .overflow_o( overflow                       )
  );

  always_ff @(posedge clk_i or negedge rst_ni) begin : proc_select
    if(!rst_ni) begin
      select_q <= '0;
    end else begin
      select_q <= select_d;
    end
  end

endmodule
