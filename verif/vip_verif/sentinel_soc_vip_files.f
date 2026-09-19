+incdir+rtl/core/ibex_core/vendor/lowrisc_ip/dv/sv/dv_utils
+incdir+rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl
+incdir+rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim_generic/rtl
+incdir+.bender/git/checkouts/common_cells-229df333cc9dff23/include
+incdir+.bender/git/checkouts/apb-1b178314edfb6925/include
+incdir+.bender/git/checkouts/obi-75858655e8b256db/include

# Bender deps
-f verif/bender_files.f

rtl/core/ibex_core/rtl/ibex_pkg.sv
rtl/core/ibex_core/rtl/ibex_tracer_pkg.sv
rtl/core/ibex_core/rtl/ibex_tracer.sv

# -------------------------------------------------------
# lowRISC prim packages
# -------------------------------------------------------
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim_generic/rtl/prim_pkg.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim_generic/rtl/prim_ram_1p_pkg.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim_generic/rtl/prim_ram_2p_pkg.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim_generic/rtl/prim_rom_pkg.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl/prim_alert_pkg.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl/prim_cipher_pkg.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl/prim_count_pkg.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl/prim_esc_pkg.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl/prim_mubi_pkg.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl/prim_pad_wrapper_pkg.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl/prim_secded_pkg.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl/prim_subreg_pkg.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl/prim_util_pkg.sv

-y rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl
-y rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim_generic/rtl
+libext+.sv+.svh

rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim_generic/rtl/prim_clock_gating.sv

# DIFT modules
rtl/core/dift/ibex_dift_logic.sv
rtl/core/dift/ibex_dift_mem.sv
rtl/core/dift/ibex_dift_tmu.sv
rtl/core/dift/ibex_register_file_latch_tag.sv

-f rtl/core/ibex_core/rtl/ibex_core.f

rtl/core/ibex_core/rtl/ibex_top.sv
rtl/core/ibex_core/rtl/ibex_top_tracing.sv

rtl/obi_wrapper/dift_obi/dift_obi_pkg.sv
rtl/obi_wrapper/dift_obi/dift_obi_ctrl.sv
rtl/obi_wrapper/dift_obi/dift_tag_sram_shim.sv

rtl/peripheral/apb_uart/io_generic_fifo.sv
rtl/peripheral/apb_uart/uart_rx.sv
rtl/peripheral/apb_uart/uart_tx.sv
rtl/peripheral/apb_uart/uart_interrupt.sv
rtl/peripheral/apb_uart/apb_uart.sv

rtl/peripheral/apb_gpio/rtl/apb_gpio.sv

rtl/peripheral/apb_spi_master/apb_spi_master.sv
rtl/peripheral/apb_spi_master/spi_master_apb_if.sv
rtl/peripheral/apb_spi_master/spi_master_clkgen.sv
rtl/peripheral/apb_spi_master/spi_master_controller.sv
rtl/peripheral/apb_spi_master/spi_master_fifo.sv
rtl/peripheral/apb_spi_master/spi_master_rx.sv
rtl/peripheral/apb_spi_master/spi_master_tx.sv

rtl/Interrupts/plic/plic_regmap.sv
rtl/Interrupts/plic/rv_plic_gateway.sv
rtl/Interrupts/plic/rv_plic_target.sv
rtl/Interrupts/plic/plic_top.sv

rtl/crypto/ed25519/ED25519/ED25519.srcs/sources_1/new/SHA/sha512_pkg.sv
rtl/crypto/ed25519/ED25519/ED25519.srcs/sources_1/new/ALU/pseudo_mersenne.sv
rtl/crypto/ed25519/ED25519/ED25519.srcs/sources_1/new/ALU/multiplier.sv
rtl/crypto/ed25519/ED25519/ED25519.srcs/sources_1/new/ALU/alu.sv
rtl/crypto/ed25519/ED25519/ED25519.srcs/sources_1/new/ALU/alu_top.sv
rtl/crypto/ed25519/ED25519/ED25519.srcs/sources_1/new/SHA/sha512_msg_sched.sv
rtl/crypto/ed25519/ED25519/ED25519.srcs/sources_1/new/SHA/sha512_padder.sv
rtl/crypto/ed25519/ED25519/ED25519.srcs/sources_1/new/SHA/sha512_round.sv
rtl/crypto/ed25519/ED25519/ED25519.srcs/sources_1/new/SHA/sha512_top.sv

rtl/crypto/ed25519/ED25519/ED25519.srcs/sources_1/new/reg_file.sv
rtl/crypto/ed25519/ED25519/ED25519.srcs/sources_1/new/micro_seq.sv
rtl/crypto/ed25519/ED25519/ED25519.srcs/sources_1/new/master_fsm.sv
rtl/crypto/ed25519/ED25519/ED25519.srcs/sources_1/new/top_ed25519.sv
rtl/crypto/top_most.sv

rtl/soc/soc_bootrom.sv
rtl/soc/soc_sram.sv
rtl/crypto/otp.sv

rtl/riscv-dbg/src/dm_pkg.sv
rtl/riscv-dbg/debug_rom/debug_rom.sv
rtl/riscv-dbg/debug_rom/debug_rom_one_scratch.sv
rtl/riscv-dbg/src/dm_mem.sv
rtl/riscv-dbg/src/dm_csrs.sv
rtl/riscv-dbg/src/dm_sba.sv
rtl/riscv-dbg/src/dm_obi_top.sv
rtl/riscv-dbg/src/dm_top.sv
rtl/riscv-dbg/src/dmi_cdc.sv
rtl/riscv-dbg/src/dmi_jtag_tap.sv
rtl/riscv-dbg/src/dmi_jtag.sv
rtl/riscv-dbg/src/dmi_intf.sv

rtl/soc/soc_obi_demux.sv
rtl/soc/soc_addr_decode.sv
rtl/soc/soc_ctrl_regs.sv
rtl/soc/soc_buffer.sv
rtl/soc/sentinel_soc_top.sv

# -----------------------------------------------------------------------------
# VIP Integration
# -----------------------------------------------------------------------------
# UART AVIP
+incdir+verif/vip/uart_avip/src/hvlTop/uartTxAgent/uartTxSequences/
+incdir+verif/vip/uart_avip/src/hvlTop/uartTxAgent/
+incdir+verif/vip/uart_avip/src/hvlTop/uartEnv/virtualSequencer/
+incdir+verif/vip/uart_avip/src/hvlTop/tb/uartVirtualSequences/
+incdir+verif/vip/uart_avip/src/hvlTop/uartEnv
+incdir+verif/vip/uart_avip/src/hvlTop/uartRxAgent
+incdir+verif/vip/uart_avip/src/hvlTop/uartRxAgent/uartRxSequences/
+incdir+verif/vip/uart_avip/src/hvlTop/tb
verif/vip/uart_avip/src/globals/UartGlobalPkg.sv
verif/vip/uart_avip/src/hvlTop/uartTxAgent/UartTxPkg.sv
verif/vip/uart_avip/src/hvlTop/uartRxAgent/UartRxPkg.sv
verif/vip/uart_avip/src/hvlTop/uartTxAgent/uartTxSequences/UartTxSequencePkg.sv
verif/vip/uart_avip/src/hvlTop/uartRxAgent/uartRxSequences/UartRxSequencePkg.sv
verif/vip/uart_avip/src/hvlTop/uartEnv/UartEnvPkg.sv
verif/vip/uart_avip/src/hvlTop/tb/uartVirtualSequences/UartVirtualSequencePkg.sv
verif/vip/uart_avip/src/hvlTop/tb/UartBaseTestPkg.sv
verif/vip/uart_avip/src/hdlTop/uartInterface/UartInterface.sv
verif/vip/uart_avip/src/hdlTop/uartTxAgentBfm/UartTxDriverBfm.sv
verif/vip/uart_avip/src/hdlTop/uartTxAgentBfm/UartTxMonitorBfm.sv
verif/vip/uart_avip/src/hdlTop/uartTxAgentBfm/UartTxAgentBfm.sv
verif/vip/uart_avip/src/hdlTop/uartTxAgentBfm/UartTxAssertions.sv
verif/vip/uart_avip/src/hdlTop/uartRxAgentBfm/UartRxDriverBfm.sv
verif/vip/uart_avip/src/hdlTop/uartRxAgentBfm/UartRxAssertions.sv
verif/vip/uart_avip/src/hdlTop/uartRxAgentBfm/UartRxMonitorBfm.sv
verif/vip/uart_avip/src/hdlTop/uartRxAgentBfm/UartRxAgentBfm.sv

# -----------------------------------------------------------------------------
# SPI AVIP
# -----------------------------------------------------------------------------
+incdir+verif/vip/spi_avip/src/hvlTop/spiMaster/spiMasterSequences
+incdir+verif/vip/spi_avip/src/hvlTop/spiMaster
+incdir+verif/vip/spi_avip/src/hvlTop/spiSlave/spiSlaveSequences
+incdir+verif/vip/spi_avip/src/hvlTop/spiSlave
+incdir+verif/vip/spi_avip/src/hvlTop/spiEnv/virtualSequencer
+incdir+verif/vip/spi_avip/src/hvlTop/spiEnv
+incdir+verif/vip/spi_avip/src/hvlTop/tb/virtualSequences
+incdir+verif/vip/spi_avip/src/hvlTop/tb/test
+incdir+verif/vip/spi_avip/src/hvlTop/tb

verif/vip/spi_avip/src/globals/SpiGlobalsPkg.sv

verif/vip/spi_avip/src/hvlTop/spiMaster/SpiMasterPkg.sv
verif/vip/spi_avip/src/hvlTop/spiMaster/spiMasterSequences/SpiMasterSeqPkg.sv
verif/vip/spi_avip/src/hvlTop/spiSlave/SpiSlavePkg.sv
verif/vip/spi_avip/src/hvlTop/spiSlave/spiSlaveSequences/SpiSlaveSeqPkg.sv
verif/vip/spi_avip/src/hvlTop/spiEnv/SpiEnvPkg.sv
verif/vip/spi_avip/src/hvlTop/tb/virtualSequences/SpiVirtualSeqPkg.sv
verif/vip/spi_avip/src/hvlTop/tb/test/SpiTestPkg.sv

verif/vip/spi_avip/src/hdlTop/spiInterface/SpiInterface.sv
verif/vip/spi_avip/src/hdlTop/masterAgentBFM/SpiMasterDriverBFM.sv
verif/vip/spi_avip/src/hdlTop/masterAgentBFM/SpiMasterMonitorBFM.sv
verif/vip/spi_avip/src/hdlTop/masterAgentBFM/SpiMasterAgentBFM.sv
verif/vip/spi_avip/src/hdlTop/slaveAgentBFM/SpiSlaveDriverBFM.sv
verif/vip/spi_avip/src/hdlTop/slaveAgentBFM/SpiSlaveMonitorBFM.sv
verif/vip/spi_avip/src/hdlTop/slaveAgentBFM/SpiSlaveAgentBFM.sv
verif/vip/spi_avip/src/hdlTop/SpiMasterAssertions.sv
verif/vip/spi_avip/src/hdlTop/SpiMasterAssertionsTB.sv
verif/vip/spi_avip/src/hdlTop/SpiSlaveAssertions.sv
verif/vip/spi_avip/src/hdlTop/SpiSlaveAssertionsTB.sv

# -----------------------------------------------------------------------------
# JTAG AVIP
# -----------------------------------------------------------------------------
+incdir+verif/vip/jtag_avip/src/hvlTop/jtagControllerDeviceAgent/jtagControllerDeviceSequences
+incdir+verif/vip/jtag_avip/src/hvlTop/jtagControllerDeviceAgent
+incdir+verif/vip/jtag_avip/src/hvlTop/jtagTargetDeviceAgent/jtagTargetDeviceSequences
+incdir+verif/vip/jtag_avip/src/hvlTop/jtagTargetDeviceAgent
+incdir+verif/vip/jtag_avip/src/hvlTop/jtagEnv/virtualSequencer
+incdir+verif/vip/jtag_avip/src/hvlTop/jtagEnv
+incdir+verif/vip/jtag_avip/src/hvlTop/tb/jtagVirtualSequences
+incdir+verif/vip/jtag_avip/src/hvlTop/tb/test
+incdir+verif/vip/jtag_avip/src/hvlTop/tb

verif/vip/jtag_avip/src/globals/JtagGlobalPkg.sv

verif/vip/jtag_avip/src/hvlTop/jtagControllerDeviceAgent/JtagControllerDevicePkg.sv
verif/vip/jtag_avip/src/hvlTop/jtagControllerDeviceAgent/jtagControllerDeviceSequences/JtagControllerDeviceSequencePkg.sv
verif/vip/jtag_avip/src/hvlTop/jtagTargetDeviceAgent/JtagTargetDevicePkg.sv
verif/vip/jtag_avip/src/hvlTop/jtagTargetDeviceAgent/jtagTargetDeviceSequences/JtagTargetDeviceSequencePkg.sv
verif/vip/jtag_avip/src/hvlTop/jtagEnv/JtagEnvPkg.sv
verif/vip/jtag_avip/src/hvlTop/tb/jtagVirtualSequences/JtagVirtualSequencePkg.sv
verif/vip/jtag_avip/src/hvlTop/tb/test/JtagBaseTestPkg.sv

verif/vip/jtag_avip/src/hdlTop/jtagInterface/JtagInterface.sv
verif/vip/jtag_avip/src/hdlTop/jtagControllerDeviceAgentBfm/JtagControllerDeviceDriverBfm.sv
verif/vip/jtag_avip/src/hdlTop/jtagControllerDeviceAgentBfm/JtagControllerDeviceMonitorBfm.sv
verif/vip/jtag_avip/src/hdlTop/jtagControllerDeviceAgentBfm/JtagControllerDeviceAgentBfm.sv
verif/vip/jtag_avip/src/hdlTop/jtagControllerDeviceAgentBfm/JtagControllerDeviceAssertions.sv
verif/vip/jtag_avip/src/hdlTop/jtagTargetDeviceAgentBfm/JtagTargetDeviceDriverBfm.sv
verif/vip/jtag_avip/src/hdlTop/jtagTargetDeviceAgentBfm/JtagTargetDeviceMonitorBfm.sv
verif/vip/jtag_avip/src/hdlTop/jtagTargetDeviceAgentBfm/JtagTargetDeviceAgentBfm.sv
verif/vip/jtag_avip/src/hdlTop/jtagTargetDeviceAgentBfm/JtagTargetDeviceAssertions.sv

# -----------------------------------------------------------------------------
# New Dedicated VIP Testbench
# -----------------------------------------------------------------------------
verif/vip_verif/cpu_agent/obi_if.sv
verif/vip_verif/cpu_agent/obi_cpu_agent_pkg.sv

verif/vip_verif/qspi_vip/qspi_flash_bfm.sv
verif/vip_verif/gpio_vip/gpio_if.sv
verif/vip_verif/timer_vip/timer_irq_if.sv

verif/soc_verif/sentinel_soc_if.sv
verif/vip_verif/sentinel_soc_vip_uvm_pkg.sv
verif/vip_verif/sentinel_soc_vip_uvm_top.sv