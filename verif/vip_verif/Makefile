# -----------------------------------------------------------------------------
# Makefile for VIP-Driven "NoCore" SoC Verification
# -----------------------------------------------------------------------------

# Xcelium Execution Command
XRUN = xrun

# Global Options: 
#   -uvm: Enable UVM
#   -access +rw: Enable read/write access for waveform dumping and force statements
#   +define+NO_CORE: Tells our UVM Top to disable the Ibex CPU and enable the CPU Agent
XRUN_OPTS = -uvm -access +rw +define+NO_CORE -top sentinel_soc_vip_uvm_top

# The Master File List (You can edit this .f file to add/remove VIPs to save memory)
FILE_LIST = verif/vip_verif/sentinel_soc_vip_files.f

.PHONY: all clean test_reg test_uart test_spi test_qspi test_gpio test_jtag test_timer

all: test_reg

# -----------------------------------------------------------------------------
# Test Targets (Run these one by one as you develop tests for each peripheral)
# -----------------------------------------------------------------------------

# Basic Address Decoding Test (Proves OBI Agent can route to APB)
test_reg:
	cd ../.. && $(XRUN) -f $(FILE_LIST) $(XRUN_OPTS) +UVM_TESTNAME=sentinel_soc_vip_base_test

# UART Traffic Test (Uses UART AVIP)
test_uart:
	cd ../.. && $(XRUN) -f $(FILE_LIST) $(XRUN_OPTS) +UVM_TESTNAME=sentinel_soc_vip_uart_test

# SPI Master Test (Uses SPI AVIP)
test_spi:
	cd ../.. && $(XRUN) -f $(FILE_LIST) $(XRUN_OPTS) +UVM_TESTNAME=sentinel_soc_vip_spi_test

# QSPI Flash Test (Uses QSPI BFM)
test_qspi:
	cd ../.. && $(XRUN) -f $(FILE_LIST) $(XRUN_OPTS) +UVM_TESTNAME=sentinel_soc_vip_qspi_test

# GPIO Toggle Test (Uses GPIO IF)
test_gpio:
	cd ../.. && $(XRUN) -f $(FILE_LIST) $(XRUN_OPTS) +UVM_TESTNAME=sentinel_soc_vip_gpio_test

# JTAG Debug Test (Uses JTAG AVIP)
test_jtag:
	cd ../.. && $(XRUN) -f $(FILE_LIST) $(XRUN_OPTS) +UVM_TESTNAME=sentinel_soc_vip_jtag_test

# Timer Interrupt Test (Uses Timer IRQ IF)
test_timer:
	cd ../.. && $(XRUN) -f $(FILE_LIST) $(XRUN_OPTS) +UVM_TESTNAME=sentinel_soc_vip_timer_test

# -----------------------------------------------------------------------------
# Cleanup
# -----------------------------------------------------------------------------
clean:
	rm -rf xcelium.d xrun.history xrun.log waves_vip.shm *.err *.trn *.dsn
