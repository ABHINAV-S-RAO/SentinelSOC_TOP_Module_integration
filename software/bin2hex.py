#!/usr/bin/env python3
"""
bin2hex.py - Convert flat binary to Verilog \ format.
Output: one 32-bit word per line, little-endian, no prefix.
Usage: python3 bin2hex.py input.bin output.hex
"""
import sys
import struct

def main():
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} input.bin output.hex")
        sys.exit(1)

    in_path, out_path = sys.argv[1], sys.argv[2]

    with open(in_path, 'rb') as f:
        data = f.read()

    # Pad to word boundary
    remainder = len(data) % 4
    if remainder:
        data += b'\x00' * (4 - remainder)

    num_words = len(data) // 4
    words = struct.unpack(f'<{num_words}I', data)

    with open(out_path, 'w') as f:
        for w in words:
            f.write(f'{w:08x}\n')

    print(f"[bin2hex] Wrote {num_words} words to {out_path}")

if __name__ == '__main__':
    main()
