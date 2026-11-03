$tests = @(
    "test_integrated_soc",
    "test_spiflash_boot",
    "test_trap_robustness",
    "test_soc_stress",
    "test_rv32imc_isa",
    "test_memory_exhaustive",
    "test_plic_priority_arbitration",
    "test_benchmark_dhrystone",
    "test_uart_boot",
    "test_crypto_accelerator",
    "test_plic_interrupts",
    "test_access_control",
    "test_dift_integration",
    "test_soc_buffer_stream"
)

foreach ($t in $tests) {
    Copy-Item "software/bootrom.hex" "software/tests/$t.hex" -Force
}

Write-Host "Distributed bootrom.hex to all $($tests.Count) test hex files in software/tests/"
