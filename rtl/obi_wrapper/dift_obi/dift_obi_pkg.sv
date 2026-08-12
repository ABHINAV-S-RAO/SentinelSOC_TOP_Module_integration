// dift_obi_pkg.sv
// DIFT parallel tag sideband definitions for the OBI bus.
//
// Design philosophy:
//   The tag travels as a SEPARATE 1-bit wire beside every OBI transaction,
//   not embedded in the OBI data bus (no 33-bit bus like the Columbia approach).
//   This keeps the OBI infrastructure completely untouched and avoids touching
//   every width-parameterised module in the stack.
//
//   We define a thin struct pair that wraps a normal OBI req/rsp together with
//   its tag sideband.  Only the wrapper and the tag-aware shims use these structs;
//   all internal OBI components see the unmodified obi_pkg types.

package dift_obi_pkg;

  // Tag sideband for the OBI A-channel (address/write phase)
  //   a_tag  : tag of the write-data word (valid when req & we) also carries the load-address-register tag for loads (write=0) so the tag RAM can enforce address-taint policies on both.
  typedef struct packed {
    logic a_tag;   // 1-bit: taint tag associated with the A-channel beat
  } obi_a_tag_t;

  // Tag sideband for the OBI R-channel (read/response phase)
  //   r_tag  : tag bit returned from the shadow tag RAM for a load
  typedef struct packed {
    logic r_tag;   // 1-bit: taint tag from shadow tag RAM
  } obi_r_tag_t;

  // tagged request  (used at the boundary between ibex and SoC)
  typedef struct packed {
    // Normal OBI A-channel fields (must match obi_pkg field names so callers
    // can assign individual members by name)
    logic        req;
    logic [31:0] addr;
    logic        we;
    logic [ 3:0] be;
    logic [31:0] wdata;
    logic [ 0:0] aid;        // 1-bit transaction ID (ObiDefaultConfig.IdWidth=1)
    // Tag sideband
    obi_a_tag_t  tag;
  } dift_obi_req_t;

  // tagged response 
  typedef struct packed {
    logic        gnt;
    logic        rvalid;
    logic [31:0] rdata;
    logic [ 0:0] rid;
    logic        err;
    obi_r_tag_t  tag;
  } dift_obi_rsp_t;

endpackage
