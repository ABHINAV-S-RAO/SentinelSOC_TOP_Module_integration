#!/bin/bash
# Build the full-SoC simulation images (no RISC-V toolchain needed):
#   verif/soc/images/bootrom.hex      BootROM contents (32-bit words)
#   verif/soc/images/app.flash.hex    signed firmware image, one byte per line
#   verif/soc/images/app.pubkey.mem   matching (TEST-ONLY) OTP public key
#   verif/soc/images/app_max.flash.hex the same firmware padded to the largest
#                                     image that fits ISRAM (8 KB): sizes the
#                                     boot watchdog (full_soc_tb +BIGIMAGE)
# Run from the repo root.
set -e
OUT=verif/soc/images
BLD=build/sw
mkdir -p "$OUT" "$BLD"
python3 software/tools/rvasm.py software/boot/bootrom.S --base 0x00000000 -o "$BLD/bootrom" --pad-words 1024
python3 software/tools/rvasm.py software/app/app_demo.S --base 0x00010044 -o "$BLD/app"
python3 software/tools/sign_image.py "$BLD/app.bin" -o "$BLD/app"
# Largest image that fits ISRAM: 2048 words - 17 header words = 2031 code words
python3 software/tools/rvasm.py software/app/app_demo.S --base 0x00010044 -o "$BLD/app_max"
python3 -c "import sys; p=sys.argv[1]; b=open(p,'rb').read(); open(p,'wb').write(b + bytes(2031*4 - len(b)))" "$BLD/app_max.bin"
python3 software/tools/sign_image.py "$BLD/app_max.bin" -o "$BLD/app_max"
cp "$BLD/bootrom.hex" "$OUT/bootrom.hex"
cp "$BLD/app.flash.hex" "$OUT/app.flash.hex"
cp "$BLD/app_max.flash.hex" "$OUT/app_max.flash.hex"
cp "$BLD/app.pubkey.mem" "$OUT/app.pubkey.mem"
cp "$BLD/bootrom.sym" "$OUT/bootrom.sym"
cp "$BLD/app.sym" "$OUT/app.sym"
echo "images in $OUT"
