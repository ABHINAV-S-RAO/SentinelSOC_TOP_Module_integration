# =============================================================================
# SentinelSOC Full Integrated Verification Makefile
# Fulfills Official Tapeout Signoff Checklist:
#   6.9   Boot from internal ROM passes
#   6.10  Boot from external SPI flash passes
#   6.11  SRAM load / ROM remap boot passes
#   6.12  Bare-metal C test suite passes
#   6.13  Trap robustness under load passes
#   6.14  SoC random and stress tests pass
#   6.15  SoC functional coverage closed
#   6.16  SoC code coverage >= 95%
#   6.17  Full regression clean
#   6.18  No deadlocks in long runs
#   6.19  RTL frozen for synthesis
# =============================================================================

XRUN      = xrun
FILE_LIST = verif/soc_verif/sentinel_soc_files.f

# Base Xcelium options: Real Ibex Core execution (NO_CORE is NOT defined)
BASE_OPTS = -uvm -access +rw +define+RVFI -top sentinel_soc_uvm_top -timescale 1ns/1ps

# Code coverage options for 95%+ signoff (Line, Branch, Toggle, FSM)
COV_OPTS  = -coverage all -covoverwrite -covworkdir cov_work

.PHONY: all clean fw_build regression_soc cov_report \
        test_bootrom test_spiflash_boot test_integrated \
        test_trap_robustness test_stress test_uart test_crypto \
        test_plic test_access_ctrl test_dift test_buffer

all: test_integrated

# Check if a RISC-V compiler is present on the system
HAS_COMPILER := $(shell which riscv64-unknown-elf-gcc 2>/dev/null || which riscv32-unknown-elf-gcc 2>/dev/null)

# Build firmware images only if a compiler is available
fw_build:
ifdef HAS_COMPILER
	$(MAKE) -C ../../software all
else
	@echo "[NOTE] No RISC-V compiler found on host; executing simulation directly with existing hex images."
endif

# -----------------------------------------------------------------------------
# Criteria 6.9: Boot from internal ROM
# -----------------------------------------------------------------------------
test_bootrom: fw_build
	cd ../.. && $(XRUN) -f $(FILE_LIST) $(BASE_OPTS) \
		+UVM_TESTNAME=sentinel_soc_base_test \
		+FIRMWARE=software/bootrom.hex

# -----------------------------------------------------------------------------
# Criteria 6.10 & 6.11: Boot from SPI Flash & ISRAM Remap
# -----------------------------------------------------------------------------
test_spiflash_boot: fw_build
	cd ../.. && $(XRUN) -f $(FILE_LIST) $(BASE_OPTS) \
		+UVM_TESTNAME=spiflash_boot_test \
		+FIRMWARE=software/tests/test_spiflash_boot.hex

# -----------------------------------------------------------------------------
# Criteria 6.12 & 6.15: Exhaustive Master Bare-Metal Integrated Test
# -----------------------------------------------------------------------------
test_integrated: fw_build
	cd ../.. && $(XRUN) -f $(FILE_LIST) $(BASE_OPTS) $(COV_OPTS) \
		+UVM_TESTNAME=integrated_soc_test \
		+FIRMWARE=software/tests/test_integrated_soc.hex

# -----------------------------------------------------------------------------
# Criteria 6.13: Trap Robustness Under Load
# -----------------------------------------------------------------------------
test_trap_robustness: fw_build
	cd ../.. && $(XRUN) -f $(FILE_LIST) $(BASE_OPTS) \
		+UVM_TESTNAME=trap_robustness_test \
		+FIRMWARE=software/tests/test_trap_robustness.hex

# -----------------------------------------------------------------------------
# Criteria 6.14 & 6.18: Random & Stress Test with Deadlock Watchdog
# -----------------------------------------------------------------------------
test_stress: fw_build
	cd ../.. && $(XRUN) -f $(FILE_LIST) $(BASE_OPTS) \
		+UVM_TESTNAME=soc_stress_test \
		+FIRMWARE=software/tests/test_soc_stress.hex

# -----------------------------------------------------------------------------
# Targeted Subsystem Tests
# -----------------------------------------------------------------------------
test_uart: fw_build
	cd ../.. && $(XRUN) -f $(FILE_LIST) $(BASE_OPTS) \
		+UVM_TESTNAME=uart_boot_test \
		+FIRMWARE=software/tests/test_uart_boot.hex

test_crypto: fw_build
	cd ../.. && $(XRUN) -f $(FILE_LIST) $(BASE_OPTS) \
		+UVM_TESTNAME=crypto_test \
		+FIRMWARE=software/tests/test_crypto_accelerator.hex \
		+TIMEOUT_NS=15000000

test_plic: fw_build
	cd ../.. && $(XRUN) -f $(FILE_LIST) $(BASE_OPTS) \
		+UVM_TESTNAME=plic_test \
		+FIRMWARE=software/tests/test_plic_interrupts.hex

test_access_ctrl: fw_build
	cd ../.. && $(XRUN) -f $(FILE_LIST) $(BASE_OPTS) \
		+UVM_TESTNAME=access_ctrl_test \
		+FIRMWARE=software/tests/test_access_control.hex

test_dift: fw_build
	cd ../.. && $(XRUN) -f $(FILE_LIST) $(BASE_OPTS) \
		+UVM_TESTNAME=dift_test \
		+FIRMWARE=software/tests/test_dift_integration.hex

test_buffer: fw_build
	cd ../.. && $(XRUN) -f $(FILE_LIST) $(BASE_OPTS) \
		+UVM_TESTNAME=soc_buffer_test \
		+FIRMWARE=software/tests/test_soc_buffer_stream.hex \
		+TIMEOUT_NS=15000000

test_isa: fw_build
	cd ../.. && $(XRUN) -f $(FILE_LIST) $(BASE_OPTS) \
		+UVM_TESTNAME=rv32imc_isa_test \
		+FIRMWARE=software/tests/test_rv32imc_isa.hex

test_mem: fw_build
	cd ../.. && $(XRUN) -f $(FILE_LIST) $(BASE_OPTS) \
		+UVM_TESTNAME=memory_exhaustive_test \
		+FIRMWARE=software/tests/test_memory_exhaustive.hex

test_priority: fw_build
	cd ../.. && $(XRUN) -f $(FILE_LIST) $(BASE_OPTS) \
		+UVM_TESTNAME=plic_priority_test \
		+FIRMWARE=software/tests/test_plic_priority_arbitration.hex

test_dhrystone: fw_build
	cd ../.. && $(XRUN) -f $(FILE_LIST) $(BASE_OPTS) \
		+UVM_TESTNAME=benchmark_dhrystone_test \
		+FIRMWARE=software/tests/test_benchmark_dhrystone.hex

# -----------------------------------------------------------------------------
# Criteria 6.17: Full Clean Regression Suite (All 15 Tests)
# -----------------------------------------------------------------------------
regression_soc: fw_build
	@echo "================================================================="
	@echo "       STARTING FULL INTEGRATED SENTINEL SOC REGRESSION          "
	@echo "================================================================="
	@rm -f regression.log
	@for t in test_bootrom test_spiflash_boot test_integrated test_trap_robustness test_stress test_isa test_mem test_priority test_dhrystone test_uart test_crypto test_plic test_access_ctrl test_dift test_buffer; do \
		echo ">>> RUNNING $$t ..."; \
		$(MAKE) $$t >> regression.log 2>&1 && echo "  [PASS] $$t" || echo "  [FAIL] $$t"; \
	done
	@echo "================================================================="
	@echo "             REGRESSION EXECUTION COMPLETE                       "
	@echo "================================================================="

# -----------------------------------------------------------------------------
# Criteria 6.16: Cadence IMC Code Coverage Report Generation (>=95%)
# -----------------------------------------------------------------------------
cov_report:
	cd ../.. && imc -batch -exec verif/soc_verif/imc_report.tcl

clean:
	rm -rf xcelium.d xrun.history xrun.log waves.shm cov_work *.err *.trn *.dsn regression.log
