#!/usr/bin/env python3
"""
sign_image.py -- wrap a firmware binary into a SentinelSoC signed boot image.

Image layout (flash byte offset 0, copied byte-exact to ISRAM 0x0001_0000):
    +0x00  sha_len   big-endian u32 = 16 + code_words   (R + A(pubkey) + M)
    +0x04  R         32 bytes  Ed25519 signature (RFC 8032)
    +0x24  S         32 bytes
    +0x44  code      the signed message M; linked to run at ISRAM+0x44
Same layout as rtl/crypto/scripts/build_mem.py; verified in hardware by
rtl/soc/soc_secure_boot.sv against the OTP public key.

KEY: by default a FIXED, TEST-ONLY key derived from a public string (the one
verif/debugger/images uses), so simulation images are reproducible. Pass
--key-seed-hex with a real 32-byte seed for anything that matters.

Outputs:
    <out>.flash.hex   one byte per line ($readmemh into the SPI flash model)
    <out>.bin         raw image bytes
    <out>.pubkey.mem  8 public-key words (rtl/crypto pubkey.mem / OTP format)
"""
import argparse
import hashlib
import struct

from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PrivateKey
from cryptography.hazmat.primitives.serialization import Encoding, PublicFormat

TEST_SEED = hashlib.sha256(b"SentinelSoC dift_dbg_tb TEST-ONLY signing key").digest()
ISRAM_WORDS = 2048


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("code_bin")
    ap.add_argument("-o", required=True, help="output prefix")
    ap.add_argument("--key-seed-hex", help="32-byte Ed25519 private seed (hex)")
    args = ap.parse_args()

    code = open(args.code_bin, "rb").read()
    code += b"\x00" * ((-len(code)) % 4)
    seed = bytes.fromhex(args.key_seed_hex) if args.key_seed_hex else TEST_SEED
    sk = Ed25519PrivateKey.from_private_bytes(seed)
    pub = sk.public_key().public_bytes(Encoding.Raw, PublicFormat.Raw)
    sig = sk.sign(code)
    sk.public_key().verify(sig, code)

    code_words = len(code) // 4
    sha_len = 16 + code_words
    if 1 + sha_len > ISRAM_WORDS:
        raise SystemExit(f"image {1 + sha_len} words does not fit ISRAM ({ISRAM_WORDS})")
    image = struct.pack(">I", sha_len) + sig[:32] + sig[32:] + code

    open(args.o + ".bin", "wb").write(image)
    with open(args.o + ".flash.hex", "w") as f:
        f.writelines(f"{b:02x}\n" for b in image)
    with open(args.o + ".pubkey.mem", "w") as f:
        f.write("// Ed25519 public key, rtl/crypto pubkey.mem format\n")
        f.writelines(f"{struct.unpack('>I', pub[i:i+4])[0]:08x}\n" for i in range(0, 32, 4))
    print(f"signed image: {len(image)} bytes, code_words={code_words}, sha_len={sha_len}, "
          f"key={'TEST-ONLY' if not args.key_seed_hex else 'custom'} pubkey={pub.hex()}")


if __name__ == "__main__":
    main()
