#!/bin/bash
# Build the full-SoC simulation images (no RISC-V toolchain needed):
#   verif/soc/images/bootrom.hex      BootROM contents (32-bit words)
#   verif/soc/images/app.flash.hex    signed firmware image, one byte per line
#   verif/soc/images/app.pubkey.mem   matching (TEST-ONLY) OTP public key
# Run from the repo root.
set -e
OUT=verif/soc/images
BLD=build/sw
mkdir -p "$OUT" "$BLD"
python3 software/tools/rvasm.py software/boot/bootrom.S --base 0x00000000 -o "$BLD/bootrom" --pad-words 1024
python3 software/tools/rvasm.py software/app/app_demo.S --base 0x00010044 -o "$BLD/app"
python3 software/tools/sign_image.py "$BLD/app.bin" -o "$BLD/app"
cp "$BLD/bootrom.hex" "$OUT/bootrom.hex"
cp "$BLD/app.flash.hex" "$OUT/app.flash.hex"
cp "$BLD/app.pubkey.mem" "$OUT/app.pubkey.mem"
cp "$BLD/bootrom.sym" "$OUT/bootrom.sym"
cp "$BLD/app.sym" "$OUT/app.sym"
echo "images in $OUT"
