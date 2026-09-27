#!/usr/bin/env python3
"""
gen_signed_image.py -- build the Ed25519-signed ISRAM test image for
verif/debugger/dift_dbg_tb.sv (secure boot / JTAG recovery scenarios).

Image layout (byte-exact, as it sits in ISRAM at 0x0001_0000 and in flash):

    +0x00  sha_len   big-endian u32 = 16 + code_words   (R + A(pubkey) + M)
    +0x04  R         32 bytes  (signature, RFC 8032)
    +0x24  S         32 bytes
    +0x44  code      M = code_words * 4 bytes  <- entry point, signed message

This is rtl/crypto/scripts/build_mem.py's flash layout. soc_secure_boot's
feeder reads each ISRAM word (little-endian) and byte-swaps it, which gives
exactly the big-endian words build_mem.py feeds top_most. The code is the
same bytes the core executes, so "what was verified" == "what runs".

KEY: a FIXED, TEST-ONLY private key derived from a public string, so the
outputs are reproducible. Never use it for a real device.

Outputs (next to this script):
    recovery_signed.mem  ISRAM words as the core sees them (little-endian)
    otp_pubkey.mem       8 public-key words in rtl/crypto pubkey.mem format
                         (otp_mem[32*i +: 32] = word i)
"""
import hashlib
import os
import struct

from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PrivateKey
from cryptography.hazmat.primitives.serialization import Encoding, PublicFormat

HERE = os.path.dirname(os.path.abspath(__file__))

# DSRAM word indices used by the image (must match dift_dbg_tb.sv)
W_HB, W_MARK = 12, 15
MARK_OK = 0x600DB007

# --- tiny RV32I encoder -------------------------------------------------------
def i_type(imm, rs1, f3, rd, op): return ((imm & 0xFFF) << 20) | (rs1 << 15) | (f3 << 12) | (rd << 7) | op
def s_type(imm, rs2, rs1, f3):     return (((imm >> 5) & 0x7F) << 25) | (rs2 << 20) | (rs1 << 15) | (f3 << 12) | ((imm & 0x1F) << 7) | 0x23
def lui(rd, imm20):                return ((imm20 & 0xFFFFF) << 12) | (rd << 7) | 0x37
def addi(rd, rs1, imm):            return i_type(imm, rs1, 0, rd, 0x13)
def sw(rs2, rs1, imm):             return s_type(imm, rs2, rs1, 2)
def jal(rd, off):
    o = off & 0x1FFFFF
    return (((o >> 20) & 1) << 31) | (((o >> 1) & 0x3FF) << 21) | (((o >> 11) & 1) << 20) | \
           (((o >> 12) & 0xFF) << 12) | (rd << 7) | 0x6F

T0, T1, A1 = 5, 6, 11
code_words = [
    lui (T0, 0x20),                      # t0 = DSRAM base 0x2_0000
    lui (T1, MARK_OK >> 12),
    addi(T1, T1, MARK_OK & 0xFFF),       # t1 = 0x600DB007
    sw  (T1, T0, 4 * W_MARK),            # mark "verified image ran"
    addi(A1, 0, 0),
    addi(A1, A1, 1),                     # loop: heartbeat++
    sw  (A1, T0, 4 * W_HB),
    jal (0, -8),
]
code = b"".join(struct.pack("<I", w) for w in code_words)   # bytes as executed

seed = hashlib.sha256(b"SentinelSoC dift_dbg_tb TEST-ONLY signing key").digest()
sk = Ed25519PrivateKey.from_private_bytes(seed)
pub = sk.public_key().public_bytes(Encoding.Raw, PublicFormat.Raw)
sig = sk.sign(code)
sk.public_key().verify(sig, code)                           # sanity
R, S = sig[:32], sig[32:]

sha_len = 16 + len(code_words)
image = struct.pack(">I", sha_len) + R + S + code
assert len(image) % 4 == 0

with open(os.path.join(HERE, "recovery_signed.mem"), "w") as f:
    f.write(f"// signed recovery image: {len(image)//4} words, sha_len={sha_len}, entry=+0x44\n")
    for i in range(0, len(image), 4):
        f.write(f"{struct.unpack('<I', image[i:i+4])[0]:08x}\n")

with open(os.path.join(HERE, "otp_pubkey.mem"), "w") as f:
    f.write("// TEST-ONLY Ed25519 public key, rtl/crypto pubkey.mem format\n")
    for i in range(0, 32, 4):
        f.write(f"{struct.unpack('>I', pub[i:i+4])[0]:08x}\n")

print(f"image words={len(image)//4} sha_len={sha_len} pubkey={pub.hex()}")
