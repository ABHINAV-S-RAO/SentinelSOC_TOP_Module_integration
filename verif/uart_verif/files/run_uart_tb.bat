@echo off
REM =============================================================================
REM  run_uart_tb.bat
REM  Compiles and runs the SentinelSoC UART UVM testbench under XSim.
REM
REM  Usage:
REM    run_uart_tb.bat                        (runs uart_full_test)
REM    run_uart_tb.bat uart_echo_test         (runs echo test)
REM    run_uart_tb.bat uart_irq_test          (runs IRQ test)
REM    run_uart_tb.bat uart_banner_test       (runs banner test)
REM    run_uart_tb.bat uart_stress_test       (runs stress test)
REM =============================================================================
setlocal EnableDelayedExpansion

set TEST=%1
if "%TEST%"=="" set TEST=uart_full_test

set VV=C:\Xilinx\Vivado\2024.2\bin
set ROOT=E:\SENTINELSOC
set OT=%ROOT%\opentitan\opentitan\hw\ip
set PRIM=%ROOT%\ibex\vendor\lowrisc_ip\ip\prim\rtl
set IBEX=%ROOT%\ibex\rtl
set OBI=%ROOT%\pulp obi\obi\src
set WF=%ROOT%\written_files
set TB=%ROOT%\uart_uvm_tb
set WORK=xil_defaultlib
set OUT=D:\Xilinx_Workspace\SENTINELSOC\SENTINELSOC.sim\sim_1\behav\xsim

if not exist "%OUT%" mkdir "%OUT%"
cd /d "%OUT%"
if exist xvlog.log del xvlog.log
if exist xelab.log del xelab.log

set E=0
goto :main

:sv
  if not exist "%~1" ( echo [SKIP] %~nx1 & goto :eof )
  echo [SV  ] %~nx1
  "%VV%\xvlog" --sv --work %WORK% "%~1" >> xvlog.log 2>&1
  if !ERRORLEVEL! NEQ 0 ( echo [ERR ] %~nx1 & set /a E+=1 )
goto :eof

:main
echo.
echo ================================================================
echo  SentinelSoC UART UVM TB  —  Test: %TEST%
echo ================================================================

REM ── RTL compile (same order as compile_sim.bat) ──────────────────────────
echo [1] prim_util_pkg
call :sv "%PRIM%\prim_util_pkg.sv"

echo [2] lc_ctrl
call :sv "%OT%\lc_ctrl\rtl\lc_ctrl_state_pkg.sv"
call :sv "%OT%\lc_ctrl\rtl\lc_ctrl_reg_pkg.sv"
call :sv "%OT%\lc_ctrl\rtl\lc_ctrl_pkg.sv"

echo [3] Ibex vendor prim
call :sv "%PRIM%\prim_assert.sv"
call :sv "%PRIM%\prim_buf.sv"
call :sv "%PRIM%\prim_flop.sv"
call :sv "%PRIM%\prim_flop_2sync.sv"
call :sv "%PRIM%\prim_lc_sender.sv"
call :sv "%PRIM%\prim_lc_sync.sv"
call :sv "%PRIM%\prim_mubi4_sender.sv"
call :sv "%PRIM%\prim_mubi4_sync.sv"
call :sv "%PRIM%\prim_onehot_check.sv"
call :sv "%PRIM%\prim_ram_1p.sv"
call :sv "%PRIM%\prim_ram_1p_adv.sv"
call :sv "%PRIM%\prim_secded_inv_39_32_enc.sv"
call :sv "%PRIM%\prim_secded_inv_39_32_dec.sv"
call :sv "%PRIM%\prim_secded_inv_64_57_enc.sv"
call :sv "%PRIM%\prim_secded_inv_64_57_dec.sv"
call :sv "%PRIM%\prim_lfsr.sv"
call :sv "%PRIM%\prim_alert_sender.sv"
call :sv "%PRIM%\prim_alert_receiver.sv"

echo [4] Ibex RTL
call :sv "%IBEX%\ibex_pkg.sv"
call :sv "%IBEX%\ibex_alu.sv"
call :sv "%IBEX%\ibex_branch_predict.sv"
call :sv "%IBEX%\ibex_compressed_decoder.sv"
call :sv "%IBEX%\ibex_csr.sv"
call :sv "%IBEX%\ibex_counter.sv"
call :sv "%IBEX%\ibex_decoder.sv"
call :sv "%IBEX%\ibex_fetch_fifo.sv"
call :sv "%IBEX%\ibex_if_stage.sv"
call :sv "%IBEX%\ibex_load_store_unit.sv"
call :sv "%IBEX%\ibex_multdiv_fast.sv"
call :sv "%IBEX%\ibex_multdiv_slow.sv"
call :sv "%IBEX%\ibex_pmp.sv"
call :sv "%IBEX%\ibex_register_file_ff.sv"
call :sv "%IBEX%\ibex_register_file_fpga.sv"
call :sv "%IBEX%\ibex_ex_block.sv"
call :sv "%IBEX%\ibex_cs_registers.sv"
call :sv "%IBEX%\ibex_controller.sv"
call :sv "%IBEX%\ibex_id_stage.sv"
call :sv "%IBEX%\ibex_wb_stage.sv"
call :sv "%IBEX%\ibex_core.sv"
call :sv "%IBEX%\ibex_top.sv"

echo [5] PULP OBI
call :sv "%OBI%\obi_pkg.sv"
call :sv "%OBI%\obi_intf.sv"
call :sv "%OBI%\obi_err_sbr.sv"
call :sv "%OBI%\obi_cut.sv"
call :sv "%OBI%\obi_mux.sv"
call :sv "%OBI%\obi_demux.sv"
call :sv "%OBI%\obi_xbar.sv"
call :sv "%OBI%\apb_to_obi.sv"
call :sv "%OBI%\obi_to_apb.sv"
call :sv "%OBI%\obi_sram_shim.sv"

echo [6] Project RTL
call :sv "%WF%\soc_bootrom.sv"
call :sv "%WF%\soc_sram.sv"
call :sv "%WF%\soc_ctrl_regs.sv"
call :sv "%WF%\soc_buffer.sv"
call :sv "%WF%\sha_ed25519_obi_wrapper.sv"
call :sv "%WF%\top_most.sv"
call :sv "%WF%\soc_addr_decode.sv"
call :sv "%WF%\soc_top.sv"

echo [7] UVM TB
REM XSim ships with UVM 1.2 built in — just use --uvm flag
"%VV%\xvlog" --sv --work %WORK% --uvm ^
  "%TB%\uart_if.sv"      ^
  "%TB%\uart_seq_item.sv" ^
  "%TB%\uart_driver.sv"  ^
  "%TB%\uart_monitor.sv" ^
  "%TB%\uart_scoreboard.sv" ^
  "%TB%\uart_agent.sv"   ^
  "%TB%\uart_sequences.sv" ^
  "%TB%\uart_env.sv"     ^
  "%TB%\uart_tests.sv"   ^
  "%TB%\tb_top.sv"       >> xvlog.log 2>&1
if !ERRORLEVEL! NEQ 0 ( echo [ERR ] UVM TB files & set /a E+=1 )

if !E! GTR 0 (
  echo.
  echo COMPILE FAILED: !E! error^(s^) — check xvlog.log
  goto :done
)

REM ── Elaborate ────────────────────────────────────────────────────────────
echo.
echo Elaborating...
"%VV%\xelab" --sv --debug typical ^
  --timescale 1ns/1ps ^
  --uvm ^
  --work %WORK% ^
  --snapshot uart_tb_snap ^
  --log xelab.log ^
  %WORK%.tb_top

if !ERRORLEVEL! NEQ 0 (
  echo Elaboration FAILED — check xelab.log
  goto :done
)

REM ── Simulate ─────────────────────────────────────────────────────────────
echo.
echo Running test: %TEST%
echo.
"%VV%\xsim" uart_tb_snap ^
  --runall ^
  --sv_seed random ^
  --testplusarg "UVM_TESTNAME=%TEST%" ^
  --testplusarg "UVM_VERBOSITY=UVM_LOW" ^
  --log xsim_%TEST%.log

echo.
echo ================================================================
echo  Simulation complete. Log: %OUT%\xsim_%TEST%.log
echo  Grep for PASS/FAIL:
echo    findstr /i "passed failed error fatal" xsim_%TEST%.log
echo ================================================================

:done
endlocal
