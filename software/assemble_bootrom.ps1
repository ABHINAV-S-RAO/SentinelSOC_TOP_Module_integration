# assemble_bootrom.ps1 - Robust RV32I assembler for bootrom.S
$ErrorActionPreference = "Stop"

$regMap = @{
    "zero"=0; "ra"=1; "sp"=2; "gp"=3; "tp"=4; "t0"=5; "t1"=6; "t2"=7;
    "s0"=8; "fp"=8; "s1"=9; "a0"=10; "a1"=11; "a2"=12; "a3"=13;
    "a4"=14; "a5"=15; "a6"=16; "a7"=17; "s2"=18; "s3"=19; "s4"=20;
    "s5"=21; "s6"=22; "s7"=23; "s8"=24; "s9"=25; "s10"=26; "s11"=27;
    "t3"=28; "t4"=29; "t5"=30; "t6"=31
}

$csrMap = @{
    "mstatus"=0x300; "mie"=0x304; "mtvec"=0x305; "mepc"=0x341; "mcause"=0x342
}

function Encode-R($funct7, $rs2, $rs1, $funct3, $rd, $opcode) {
    $v = (([int64]$funct7 -band 0x7F) -shl 25) -bor (([int64]$rs2 -band 0x1F) -shl 20) -bor (([int64]$rs1 -band 0x1F) -shl 15) -bor (([int64]$funct3 -band 0x7) -shl 12) -bor (([int64]$rd -band 0x1F) -shl 7) -bor ([int64]$opcode -band 0x7F)
    return [uint32]($v -band 0xFFFFFFFF)
}

function Encode-I($imm, $rs1, $funct3, $rd, $opcode) {
    $v = (([int64]$imm -band 0xFFF) -shl 20) -bor (([int64]$rs1 -band 0x1F) -shl 15) -bor (([int64]$funct3 -band 0x7) -shl 12) -bor (([int64]$rd -band 0x1F) -shl 7) -bor ([int64]$opcode -band 0x7F)
    return [uint32]($v -band 0xFFFFFFFF)
}

function Encode-S($imm, $rs2, $rs1, $funct3, $opcode) {
    $imm11_5 = ([int64]$imm -shr 5) -band 0x7F
    $imm4_0  = [int64]$imm -band 0x1F
    $v = ($imm11_5 -shl 25) -bor (([int64]$rs2 -band 0x1F) -shl 20) -bor (([int64]$rs1 -band 0x1F) -shl 15) -bor (([int64]$funct3 -band 0x7) -shl 12) -bor ($imm4_0 -shl 7) -bor ([int64]$opcode -band 0x7F)
    return [uint32]($v -band 0xFFFFFFFF)
}

function Encode-B($imm, $rs2, $rs1, $funct3, $opcode) {
    $imm12   = ($imm -shr 12) -band 1
    $imm10_5 = ($imm -shr 5)  -band 0x3F
    $imm4_1  = ($imm -shr 1)  -band 0xF
    $imm11   = ($imm -shr 11) -band 1
    $v = ([int64]$imm12 -shl 31) -bor ([int64]$imm10_5 -shl 25) -bor (([int64]$rs2 -band 0x1F) -shl 20) -bor (([int64]$rs1 -band 0x1F) -shl 15) -bor (([int64]$funct3 -band 0x7) -shl 12) -bor (([int64]$imm4_1) -shl 8) -bor (([int64]$imm11) -shl 7) -bor ([int64]$opcode -band 0x7F)
    return [uint32]($v -band 0xFFFFFFFF)
}

function Encode-U($imm, $rd, $opcode) {
    $v = (([int64]$imm -band 0xFFFFF) -shl 12) -bor (([int64]$rd -band 0x1F) -shl 7) -bor ([int64]$opcode -band 0x7F)
    return [uint32]($v -band 0xFFFFFFFF)
}

function Encode-J($imm, $rd, $opcode) {
    $imm20   = ($imm -shr 20) -band 1
    $imm10_1 = ($imm -shr 1)  -band 0x3FF
    $imm11   = ($imm -shr 11) -band 1
    $imm19_12= ($imm -shr 12) -band 0xFF
    $v = ([int64]$imm20 -shl 31) -bor ([int64]$imm19_12 -shl 12) -bor ([int64]$imm11 -shl 20) -bor ([int64]$imm10_1 -shl 21) -bor (([int64]$rd -band 0x1F) -shl 7) -bor ([int64]$opcode -band 0x7F)
    return [uint32]($v -band 0xFFFFFFFF)
}

class Inst {
    [int]$pc
    [string]$op
    [string[]]$args
    [string]$targetLabel
}

$raw = Get-Content "software/bootrom.S"

$parsed = [System.Collections.Generic.List[Inst]]::new()
$labels = @{}
$localLabels = [System.Collections.Generic.List[hashtable]]::new()

$currentPC = 0

foreach ($line in $raw) {
    $clean = $line.Split("//")[0].Split("#")[0].Trim()
    if ($clean.Length -eq 0) { continue }
    if ($clean.StartsWith(".section") -or $clean.StartsWith(".global") -or $clean.StartsWith(".align") -or $clean.StartsWith(".word")) { continue }

    if ($clean.StartsWith(".org")) {
        $parts = $clean -split "\s+"
        $currentPC = [System.Convert]::ToInt32($parts[1], 16)
        continue
    }

    # Match labels
    while ($clean -match "^([A-Za-z0-9_]+):\s*(.*)") {
        $lbl = $Matches[1]
        $clean = $Matches[2].Trim()
        if ($lbl -match "^\d+$") {
            $localLabels.Add(@{ name=$lbl; pc=$currentPC })
        } else {
            $labels[$lbl] = $currentPC
        }
    }
    if ($clean.Length -eq 0) { continue }

    $parts = $clean -split "\s+", 2
    $op = $parts[0]
    $argsStr = if ($parts.Length -gt 1) { $parts[1].Trim() } else { "" }
    $args = @()
    if ($argsStr.Length -gt 0) {
        $args = @($argsStr.Split(",") | ForEach-Object { $_.Trim() })
    }

    if ($op -eq "li") {
        $rd = $args[0]
        $val = if ($args[1].StartsWith("0x", 1)) { [System.Convert]::ToInt64($args[1], 16) } else { [int64]$args[1] }
        if ($val -ge -2048 -and $val -le 2047) {
            $parsed.Add([Inst]@{ pc=$currentPC; op="addi"; args=@($rd, "zero", "$val") })
            $currentPC += 4
        } else {
            $uval = [uint32]($val -band 0xFFFFFFFF)
            $upper = ($uval + 0x800) -shr 12
            $lower = [int32]($uval -band 0xFFF)
            if ($lower -ge 2048) { $lower -= 4096 }

            $parsed.Add([Inst]@{ pc=$currentPC; op="lui"; args=@($rd, "0x$($upper.ToString('X'))") })
            $currentPC += 4

            if ($lower -ne 0) {
                $parsed.Add([Inst]@{ pc=$currentPC; op="addi"; args=@($rd, $rd, "$lower") })
                $currentPC += 4
            }
        }
    } elseif ($op -eq "la") {
        $parsed.Add([Inst]@{ pc=$currentPC; op="la"; args=$args; targetLabel=$args[1] })
        $currentPC += 4
    } elseif ($op -eq "j") {
        $parsed.Add([Inst]@{ pc=$currentPC; op="jal"; args=@("zero"); targetLabel=$args[0] })
        $currentPC += 4
    } elseif ($op -eq "bnez") {
        $parsed.Add([Inst]@{ pc=$currentPC; op="bne"; args=@($args[0], "zero"); targetLabel=$args[1] })
        $currentPC += 4
    } elseif ($op -eq "beqz") {
        $parsed.Add([Inst]@{ pc=$currentPC; op="beq"; args=@($args[0], "zero"); targetLabel=$args[1] })
        $currentPC += 4
    } else {
        $inst = [Inst]@{ pc=$currentPC; op=$op; args=$args }
        if ($op -match "^(beq|bne|blt|bge|bltu|bgeu|jal)$") {
            $inst.targetLabel = $args[$args.Length - 1]
        }
        $parsed.Add($inst)
        $currentPC += 4
    }
}

# exc_count address in DSRAM
$labels["exc_count"] = 0x00020080

function Resolve-Target($targetLabel, $pc) {
    if ($targetLabel -match "^(\d+)(b|f)$") {
        $num = $Matches[1]
        $dir = $Matches[2]
        if ($dir -eq "b") {
            # Find closest matching local label before PC
            $best = -1
            foreach ($entry in $localLabels) {
                if ($entry.name -eq $num -and $entry.pc -lt $pc) {
                    $best = $entry.pc
                }
            }
            return $best
        } else {
            # Find first matching local label after PC
            foreach ($entry in $localLabels) {
                if ($entry.name -eq $num -and $entry.pc -gt $pc) {
                    return $entry.pc
                }
            }
        }
    }
    if ($labels.ContainsKey($targetLabel)) {
        return [int]$labels[$targetLabel]
    }
    throw "Unresolved label: $targetLabel at pc 0x$($pc.ToString('X'))"
}

$mem = @{}
$maxWord = 0

foreach ($inst in $parsed) {
    $word = [uint32]0
    $op = $inst.op
    $pc = $inst.pc

    switch ($op) {
        "lui" {
            $rd = $regMap[$inst.args[0]]
            $imm = if ($inst.args[1].StartsWith("0x", 1)) { [System.Convert]::ToInt32($inst.args[1], 16) } else { [int]$inst.args[1] }
            $word = Encode-U $imm $rd 0x37
        }
        "la" {
            $rd = $regMap[$inst.args[0]]
            $target = Resolve-Target $inst.targetLabel $pc
            $upper = ($target + 0x800) -shr 12
            $word = Encode-U $upper $rd 0x37
        }
        "addi" {
            $rd = $regMap[$inst.args[0]]
            $rs1 = $regMap[$inst.args[1]]
            $imm = [int]$inst.args[2]
            $word = Encode-I $imm $rs1 0 $rd 0x13
        }
        "andi" {
            $rd = $regMap[$inst.args[0]]
            $rs1 = $regMap[$inst.args[1]]
            $imm = [int]$inst.args[2]
            $word = Encode-I $imm $rs1 7 $rd 0x13
        }
        "sll" {
            $rd = $regMap[$inst.args[0]]
            $rs1 = $regMap[$inst.args[1]]
            $shamt = [int]$inst.args[2]
            $word = Encode-I $shamt $rs1 1 $rd 0x13
        }
        "sw" {
            $rs2 = $regMap[$inst.args[0]]
            $inst.args[1] -match "(-?[0-9xX]+)?\((\w+)\)" | Out-Null
            $imm = if ($Matches[1]) { if ($Matches[1].StartsWith("0x", 1)) { [System.Convert]::ToInt32($Matches[1], 16) } else { [int]$Matches[1] } } else { 0 }
            $rs1 = $regMap[$Matches[2]]
            $word = Encode-S $imm $rs2 $rs1 2 0x23
        }
        "lw" {
            $rd = $regMap[$inst.args[0]]
            $inst.args[1] -match "(-?[0-9xX]+)?\((\w+)\)" | Out-Null
            $imm = if ($Matches[1]) { if ($Matches[1].StartsWith("0x", 1)) { [System.Convert]::ToInt32($Matches[1], 16) } else { [int]$Matches[1] } } else { 0 }
            $rs1 = $regMap[$Matches[2]]
            $word = Encode-I $imm $rs1 2 $rd 0x03
        }
        "lh" {
            $rd = $regMap[$inst.args[0]]
            $inst.args[1] -match "(-?[0-9xX]+)?\((\w+)\)" | Out-Null
            $imm = if ($Matches[1]) { [int]$Matches[1] } else { 0 }
            $rs1 = $regMap[$Matches[2]]
            $word = Encode-I $imm $rs1 1 $rd 0x03
        }
        "jal" {
            $rd = $regMap[$inst.args[0]]
            $target = Resolve-Target $inst.targetLabel $pc
            $offset = $target - $pc
            $word = Encode-J $offset $rd 0x6F
        }
        "bne" {
            $rs1 = $regMap[$inst.args[0]]
            $rs2 = $regMap[$inst.args[1]]
            $target = Resolve-Target $inst.targetLabel $pc
            $offset = $target - $pc
            $word = Encode-B $offset $rs2 $rs1 1 0x63
        }
        "beq" {
            $rs1 = $regMap[$inst.args[0]]
            $rs2 = $regMap[$inst.args[1]]
            $target = Resolve-Target $inst.targetLabel $pc
            $offset = $target - $pc
            $word = Encode-B $offset $rs2 $rs1 0 0x63
        }
        "csrwi" {
            $csr = $csrMap[$inst.args[0]]
            $imm = [int]$inst.args[1]
            $word = Encode-I $csr $imm 5 0 0x73 # csrrwi x0, csr, imm
        }
        "csrr" {
            $rd = $regMap[$inst.args[0]]
            $csr = $csrMap[$inst.args[1]]
            $word = Encode-I $csr 0 2 $rd 0x73 # csrrs rd, csr, x0
        }
        "csrw" {
            $csr = $csrMap[$inst.args[0]]
            $rs1 = $regMap[$inst.args[1]]
            $word = Encode-I $csr $rs1 1 0 0x73 # csrrw x0, csr, rs1
        }
        "mret" {
            $word = [uint32]0x30200073
        }
        default {
            Write-Warning "Unknown instruction $op at PC 0x$($pc.ToString('X'))"
        }
    }

    $wordIdx = [int]($pc / 4)
    $mem[$wordIdx] = $word
    if ($wordIdx -gt $maxWord) { $maxWord = $wordIdx }
}

# Write hex output (word per line, 32-bit hex)
$hexLines = @()
for ($i = 0; $i -le $maxWord; $i++) {
    $val = if ($mem.ContainsKey($i)) { $mem[$i] } else { [uint32]0 }
    $hexLines += "$($val.ToString('x8'))"
}

Set-Content -Path "software/bootrom.hex" -Value $hexLines
Write-Host "SUCCESS: Generated software/bootrom.hex with $($hexLines.Count) words!"
