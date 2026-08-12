// SPDX-License-Identifier: SHL-0.51
//
// Ceiled division and index-width helpers used by OBI and other PULP blocks.

package cf_math_pkg;

  function automatic integer unsigned idx_width(input integer unsigned num_idx);
    return (num_idx > 32'd1) ? unsigned'($clog2(num_idx)) : 32'd1;
  endfunction

endpackage