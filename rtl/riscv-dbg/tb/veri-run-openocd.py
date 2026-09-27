#!/usr/bin/env python3
# Copyright 2026 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51

"""Launch the Verilator testbench and run the OpenOCD compliance suite."""

import os
import shlex
import subprocess
import sys


def stop_process(process: subprocess.Popen[str] | None) -> None:
    """Stop a child process if it is still running."""
    if process is None or process.poll() is not None:
        return
    process.terminate()
    try:
        process.wait(timeout=2)
    except subprocess.TimeoutExpired:
        process.kill()
        process.wait()


def main() -> int:
    verilator_process = None
    openocd_process = None
    try:
        verilator_process = subprocess.Popen(
            ["make", "veri-run"],
            stdin=subprocess.DEVNULL,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
        )
        assert verilator_process.stdout is not None
        for line in verilator_process.stdout:
            print(line, end="")
            if "Listening on port" in line:
                print("Starting OpenOCD")
                break
            if "failed to bind socket" in line:
                print(
                    "The remote-bitbang port is already in use.",
                    file=sys.stderr,
                )
                return 1
        else:
            print("The Verilator testbench stopped before opening its port.", file=sys.stderr)
            return 1

        openocd = os.getenv("OPENOCD")
        if not openocd:
            riscv = os.getenv("RISCV")
            openocd = os.path.join(riscv, "bin", "openocd") if riscv else "openocd"
        openocd_script = os.getenv("OPENOCD_SCRIPT", "dm_compliance_test.cfg")
        openocd_command = [*shlex.split(openocd), "-f", openocd_script]

        print(f"Using '{openocd}'")
        openocd_process = subprocess.Popen(
            openocd_command,
            stdin=subprocess.DEVNULL,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
        )
        assert openocd_process.stdout is not None

        passed = False
        for line in openocd_process.stdout:
            print(line, end="")
            passed |= "ALL TESTS PASSED" in line

        return 0 if passed and openocd_process.wait() == 0 else 1
    finally:
        stop_process(openocd_process)
        stop_process(verilator_process)


if __name__ == "__main__":
    sys.exit(main())
