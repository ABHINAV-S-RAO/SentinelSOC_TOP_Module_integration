// =============================================================================
// VIP "NoCore" testbench filelist -- DUT is final_soc_top (the tape-out SoC).
// The chip part below is the same RTL list as verif/soc/files_full_soc.f;
// keep the two in step when RTL files are added or renamed.
// =============================================================================
+define+DIFT

+incdir+rtl/core/ibex_core/vendor/lowrisc_ip/dv/sv/dv_utils
+incdir+rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl
+incdir+rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim_generic/rtl
// Same absolute bender paths as verif/bender_files.f and files_full_soc.f
+incdir+/home/ibexcore/project/SentinelSOC_TOP_Module_integration/.bender/git/checkouts/common_cells-229df333cc9dff23/include
+incdir+/home/ibexcore/project/SentinelSOC_TOP_Module_integration/.bender/git/checkouts/apb-1b178314edfb6925/include
+incdir+/home/ibexcore/project/SentinelSOC_TOP_Module_integration/.bender/git/checkouts/obi-75858655e8b256db/include
+incdir+rtl/obi_wrapper
+incdir+verif/debugger

// -----------------------------------------------------------------------------
// Chip (same as files_full_soc.f)
// -----------------------------------------------------------------------------
-f verif/bender_files.f

// OBI -- vendored sources (NOT the bender obi src/ -- those use obi_pkg which needs the include)
rtl/obi_wrapper/obi_intf.sv
rtl/obi_wrapper/obi_demux.sv
rtl/obi_wrapper/obi_mux.sv

// LowRISC primitives
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim_generic/rtl/prim_ram_1p_pkg.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim/rtl/prim_secded_pkg.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim_generic/rtl/prim_buf.sv

// Ibex Core
rtl/core/ibex_core/rtl/ibex_pkg.sv
rtl/core/ibex_core/rtl/ibex_tracer_pkg.sv
rtl/core/ibex_core/vendor/lowrisc_ip/ip/prim_generic/rtl/prim_clock_gating.sv

// DIFT
rtl/core/dift/ibex_dift_logic.sv
rtl/core/dift/ibex_dift_mem.sv
rtl/core/dift/ibex_dift_tmu.sv
rtl/core/dift/ibex_register_file_latch_tag.sv

-f rtl/core/ibex_core/rtl/ibex_core.f
rtl/core/ibex_core/rtl/ibex_top.sv

// DIFT OBI
rtl/obi_wrapper/dift_obi/dift_obi_ctrl.sv
rtl/obi_wrapper/dift_obi/dift_tag_sram_shim.sv

// APB Peripherals
rtl/peripheral/apb_uart/io_generic_fifo.sv
rtl/peripheral/apb_uart/uart_rx.sv
rtl/peripheral/apb_uart/uart_tx.sv
rtl/peripheral/apb_uart/uart_interrupt.sv
rtl/peripheral/apb_uart/apb_uart.sv

rtl/peripheral/apb_spi_master/spi_master_fifo.sv
rtl/peripheral/apb_spi_master/spi_master_clkgen.sv
rtl/peripheral/apb_spi_master/spi_master_tx.sv
rtl/peripheral/apb_spi_master/spi_master_rx.sv
rtl/peripheral/apb_spi_master/spi_master_apb_if.sv
rtl/peripheral/apb_spi_master/spi_master_controller.sv
rtl/peripheral/apb_spi_master/apb_spi_master.sv

// GPIO (PULP apb_gpio submodule): the VIP top builds the chip with HAS_GPIO=1
rtl/peripheral/apb_gpio/rtl/apb_gpio.sv

// PLIC
rtl/Interrupts/plic/plic_regmap.sv
rtl/Interrupts/plic/rv_plic_gateway.sv
rtl/Interrupts/plic/rv_plic_target.sv
rtl/Interrupts/plic/plic_top.sv

// Timer (PULP apb_timer) + CLINT
rtl/peripheral/apb_timer/src/timer.sv
rtl/peripheral/apb_timer/src/apb_timer.sv
rtl/Interrupts/clint.sv

// Crypto Subsystem (SHA-512 & ED25519) -- current rtl/crypto sources (OTP public key).
// The old rtl/crypto/ed25519/ED25519/ copy (fpga_demo_top, key taken from the
// image) must NOT be compiled: same module names, and it is insecure.
rtl/crypto/SHA/sha512_pkg.sv
rtl/crypto/ALU/pseudo_mersenne.sv
rtl/crypto/ALU/multiplier.sv
rtl/crypto/ALU/alu.sv
rtl/crypto/ALU/alu_top.sv
rtl/crypto/SHA/sha512_msg_sched.sv
rtl/crypto/SHA/sha512_padder.sv
rtl/crypto/SHA/sha512_round.sv
rtl/crypto/SHA/sha512_top.sv
rtl/crypto/ed/reg_file.sv
rtl/crypto/ed/micro_seq.sv
rtl/crypto/ed/master_fsm.sv
rtl/crypto/ed/top_ed25519.sv
rtl/crypto/otp.sv
rtl/crypto/top_most.sv
rtl/crypto/ed25519/sha_ed25519_obi_wrapper.sv

// SoC memories
rtl/soc/soc_bootrom.sv
rtl/soc/soc_sram.sv

// riscv-dbg
rtl/riscv-dbg/src/dm_pkg.sv
rtl/riscv-dbg/src/dm_mem.sv
rtl/riscv-dbg/debug_rom/debug_rom.sv
rtl/riscv-dbg/src/dm_csrs.sv
rtl/riscv-dbg/src/dm_sba.sv
rtl/riscv-dbg/src/dm_obi_top.sv
rtl/riscv-dbg/src/dm_top.sv
rtl/riscv-dbg/src/dmi_cdc.sv
rtl/riscv-dbg/src/dmi_jtag_tap.sv
rtl/riscv-dbg/src/dmi_jtag.sv
rtl/riscv-dbg/src/dmi_intf.sv

// SoC top
rtl/soc/soc_addr_decode.sv
rtl/soc/soc_ctrl_regs.sv
rtl/soc/soc_buffer.sv
rtl/soc/soc_secure_boot.sv
rtl/soc/soc_recovery.sv
rtl/soc/final_soc_top.sv

// External memory models (BootROM / ISRAM / DSRAM macros)
verif/debugger/bootrom_model.sv
verif/debugger/isram_model.sv
verif/debugger/dsram_model.sv

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
+incdir+verif/vip_verif/gpio_vip
verif/vip_verif/cpu_agent/obi_if.sv
verif/vip_verif/cpu_agent/obi_cpu_agent_pkg.sv

verif/vip_verif/qspi_vip/qspi_flash_bfm.sv
//GPIO VIP
verif/vip_verif/gpio_vip/gpio_if.sv
verif/vip_verif/gpio_vip/GpioEnvPkg.sv

verif/vip_verif/timer_vip/timer_irq_if.sv

verif/soc_verif/sentinel_soc_if.sv
verif/vip_verif/sentinel_soc_vip_uvm_pkg.sv
verif/vip_verif/sentinel_soc_vip_uvm_top.sv
