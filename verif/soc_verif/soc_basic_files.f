// =============================================================================
// soc_basic_files.f
// Compilation filelist for exhaustive basic SoC testing (Clean, no ED25519)
// =============================================================================

// Include directories for Prim IP and Bender checkouts
+incdir+rtl/core/ibex_core/vendor/lowrisc_ip/dv/sv/dv_utils
+incdir+rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl
+incdir+rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim_generic/rtl
+incdir+.bender/git/checkouts/common_cells-229df333cc9dff23/include
+incdir+.bender/git/checkouts/apb-1b178314edfb6925/include
+incdir+.bender/git/checkouts/obi-75858655e8b256db/include
+incdir+rtl/obi_wrapper
+incdir+rtl/peripheral/apb_uart

.bender/git/checkouts/tech_cells_generic-c280dda8b91b4f97/src/rtl/tc_sram.sv
.bender/git/checkouts/tech_cells_generic-c280dda8b91b4f97/src/rtl/tc_sram_impl.sv
.bender/git/checkouts/tech_cells_generic-c280dda8b91b4f97/src/rtl/tc_clk.sv
.bender/git/checkouts/tech_cells_generic-c280dda8b91b4f97/src/deprecated/cluster_pwr_cells.sv
.bender/git/checkouts/tech_cells_generic-c280dda8b91b4f97/src/deprecated/generic_memory.sv
.bender/git/checkouts/tech_cells_generic-c280dda8b91b4f97/src/deprecated/generic_rom.sv
.bender/git/checkouts/tech_cells_generic-c280dda8b91b4f97/src/deprecated/pad_functional.sv
.bender/git/checkouts/tech_cells_generic-c280dda8b91b4f97/src/deprecated/pulp_buffer.sv
.bender/git/checkouts/tech_cells_generic-c280dda8b91b4f97/src/deprecated/pulp_pwr_cells.sv
.bender/git/checkouts/tech_cells_generic-c280dda8b91b4f97/src/tc_pwr.sv
.bender/git/checkouts/tech_cells_generic-c280dda8b91b4f97/src/deprecated/pulp_clock_gating_async.sv
.bender/git/checkouts/tech_cells_generic-c280dda8b91b4f97/src/deprecated/cluster_clk_cells.sv
.bender/git/checkouts/tech_cells_generic-c280dda8b91b4f97/src/deprecated/pulp_clk_cells.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/binary_to_gray.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/cb_filter_pkg.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/cc_onehot.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/cdc_reset_ctrlr_pkg.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/cf_math_pkg.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/clk_int_div.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/credit_counter.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/delta_counter.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/ecc_pkg.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/edge_propagator_tx.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/exp_backoff.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/fifo_v3.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/gray_to_binary.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/heaviside.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/isochronous_4phase_handshake.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/isochronous_spill_register.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/lfsr.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/lfsr_16bit.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/lfsr_8bit.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/lossy_valid_to_stream.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/mv_filter.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/onehot_to_bin.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/plru_tree.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/passthrough_stream_fifo.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/popcount.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/ring_buffer.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/rr_arb_tree.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/rstgen_bypass.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/serial_deglitch.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/shift_reg.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/shift_reg_gated.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/spill_register_flushable.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/stream_demux.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/stream_filter.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/stream_fork.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/stream_join_dynamic.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/stream_mux.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/stream_throttle.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/sub_per_hash.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/sync.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/sync_wedge.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/unread.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/read.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/addr_decode_dync.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/boxcar.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/cdc_2phase.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/cdc_4phase.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/clk_int_div_static.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/trip_counter.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/addr_decode.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/addr_decode_napot.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/multiaddr_decode.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/cb_filter.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/cdc_fifo_2phase.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/counter.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/ecc_decode.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/ecc_encode.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/edge_detect.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/lzc.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/max_counter.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/rstgen.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/spill_register.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/stream_delay.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/stream_fifo.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/stream_fork_dynamic.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/stream_join.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/cdc_reset_ctrlr.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/cdc_fifo_gray.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/fall_through_register.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/id_queue.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/stream_to_mem.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/stream_arbiter_flushable.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/stream_fifo_optimal_wrap.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/stream_register.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/stream_xbar.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/cdc_fifo_gray_clearable.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/cdc_2phase_clearable.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/mem_to_banks_detailed.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/stream_arbiter.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/stream_omega_net.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/mem_to_banks.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/deprecated/clock_divider_counter.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/deprecated/clk_div.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/deprecated/find_first_one.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/deprecated/generic_LFSR_8bit.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/deprecated/generic_fifo.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/deprecated/prioarbiter.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/deprecated/pulp_sync.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/deprecated/pulp_sync_wedge.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/deprecated/rrarbiter.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/deprecated/clock_divider.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/deprecated/fifo_v2.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/deprecated/fifo_v1.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/edge_propagator_ack.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/edge_propagator.sv
.bender/git/checkouts/common_cells-229df333cc9dff23/src/edge_propagator_rx.sv
.bender/git/checkouts/apb-1b178314edfb6925/src/apb_pkg.sv
.bender/git/checkouts/obi-75858655e8b256db/src/obi_pkg.sv
.bender/git/checkouts/obi-75858655e8b256db/src/obi_rready_converter.sv
.bender/git/checkouts/obi-75858655e8b256db/src/apb_to_obi.sv
rtl/obi_wrapper/obi_to_apb.sv

// 1. Local Bender Files (All base dependencies, corrected to relative paths)

// 2. Ibex Packages and Primitives
rtl/core/ibex_core/rtl/ibex_pkg.sv
rtl/core/ibex_core/rtl/ibex_tracer_pkg.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim_generic/rtl/prim_pkg.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl/prim_assert.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl/prim_util_pkg.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl/prim_count_pkg.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl/prim_count.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl/prim_secded_pkg.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl/prim_secded_22_16_dec.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl/prim_secded_22_16_enc.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl/prim_secded_64_57_dec.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl/prim_secded_64_57_enc.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl/prim_secded_hamming_22_16_dec.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl/prim_secded_hamming_22_16_enc.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl/prim_secded_hamming_39_32_dec.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl/prim_secded_hamming_39_32_enc.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl/prim_secded_hamming_72_64_dec.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl/prim_secded_hamming_72_64_enc.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl/prim_mubi_pkg.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim_generic/rtl/prim_ram_1p_pkg.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl/prim_ram_1p_adv.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl/prim_ram_1p_scr.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim_generic/rtl/prim_ram_1p.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim_generic/rtl/prim_clock_gating.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim_generic/rtl/prim_buf.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim_generic/rtl/prim_clock_mux2.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim_generic/rtl/prim_flop.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim_generic/rtl/prim_and2.sv

// Shared lowRISC code
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl/prim_cipher_pkg.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl/prim_lfsr.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl/prim_secded_inv_28_22_enc.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl/prim_secded_inv_28_22_dec.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl/prim_secded_inv_39_32_enc.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl/prim_secded_inv_39_32_dec.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl/prim_secded_inv_72_64_enc.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl/prim_secded_inv_72_64_dec.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl/prim_prince.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl/prim_subst_perm.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl/prim_secded_28_22_enc.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl/prim_secded_28_22_dec.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl/prim_secded_39_32_enc.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl/prim_secded_39_32_dec.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl/prim_secded_72_64_enc.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl/prim_secded_72_64_dec.sv

// 3. DIFT Modules
rtl/core/dift/ibex_dift_logic.sv
rtl/core/dift/ibex_dift_mem.sv
rtl/core/dift/ibex_dift_tmu.sv
rtl/core/dift/ibex_register_file_latch_tag.sv
rtl/obi_wrapper/dift_obi/dift_tag_sram_shim.sv
rtl/obi_wrapper/dift_obi/dift_obi_ctrl.sv

// 4. Ibex Core
-f rtl/core/ibex_core/rtl/ibex_core.f
rtl/core/ibex_core/rtl/ibex_top_tracing.sv
rtl/core/ibex_core/rtl/ibex_top.sv

// 5. OBI to APB Bridge

// 6. UART Submodule
rtl/peripheral/apb_uart/io_generic_fifo.sv
rtl/peripheral/apb_uart/uart_rx.sv
rtl/peripheral/apb_uart/uart_tx.sv
rtl/peripheral/apb_uart/uart_interrupt.sv
rtl/peripheral/apb_uart/apb_uart_sv.sv

// 7. Basic SoC Top and Testbench
rtl/soc/basic_soc_top.sv
verif/soc_verif/basic_soc_tb.sv
