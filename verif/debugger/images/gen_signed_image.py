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
    dift_fw_signed.mem   signed DIFT test firmware for secure_boot_dbg_tb (it
                         boots through the real flow: TB bootrom -> hardware
                         verification -> jump to entry -> hardware boot_done)
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
def lw(rd, rs1, imm):               return i_type(imm, rs1, 2, rd, 0x03)
def csrw(csr, rs1):                return i_type(csr, rs1, 1, 0, 0x73)
def csrr(rd, csr):                 return i_type(csr, 0, 2, rd, 0x73)
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
seed = hashlib.sha256(b"SentinelSoC dift_dbg_tb TEST-ONLY signing key").digest()
sk = Ed25519PrivateKey.from_private_bytes(seed)
pub = sk.public_key().public_bytes(Encoding.Raw, PublicFormat.Raw)


def write_image(name, words, what):
    code = b"".join(struct.pack("<I", w) for w in words)   # bytes as executed
    sig = sk.sign(code)
    sk.public_key().verify(sig, code)                     # sanity
    sha_len = 16 + len(words)
    image = struct.pack(">I", sha_len) + sig[:32] + sig[32:] + code
    assert len(image) % 4 == 0
    with open(os.path.join(HERE, name), "w") as f:
        f.write(f"// {what}: {len(image)//4} words, sha_len={sha_len}, entry=+0x44\n")
        for i in range(0, len(image), 4):
            f.write(f"{struct.unpack('<I', image[i:i+4])[0]:08x}\n")
    print(f"{name}: image words={len(image)//4} sha_len={sha_len}")


write_image("recovery_signed.mem", code_words, "signed recovery image")

# --- DIFT test firmware for secure_boot_dbg_tb ---------------------------------
# Runs from ISRAM after the real secure-boot handoff. DSRAM word indices must
# match secure_boot_dbg_tb.sv. Layout (absolute addresses):
#   0x10044  j main                      <- ENTRY
#   0x10048  nop padding
#   0x10100  vector table (256-aligned, Ibex mtvec is vectored) -> trap
#   0x10180  main: mtvec FIRST (it resets to the BootROM, which is not
#            executable after the handoff), TPR from config, load the four
#            scenario values (taint propagates from the shadow tag RAM), TCR
#            last, then the heartbeat loop at 0x101B4/0x101B8/0x101BC
#   0x101C0  trap: record mcause, count, park
W_TPR, W_TCR, W_S0, W_A0, W_T1, W_S1, W_MCAUSE, W_TRAPCNT = 4, 5, 8, 9, 10, 11, 13, 14
CSR_MTVEC, CSR_MCAUSE, CSR_TCR, CSR_TPR = 0x305, 0x342, 0x7C2, 0x7C3
T2, T3, T4, T5, S0, S1, A0 = 7, 28, 29, 30, 8, 9, 10
ENTRY, VEC, MAIN, TRAP = 0x10044, 0x10100, 0x10180, 0x101C0
fw = {}
fw[ENTRY] = jal(0, MAIN - ENTRY)
for a in range(ENTRY + 4, VEC, 4):
    fw[a] = addi(0, 0, 0)                                   # nop
for i in range(32):
    fw[VEC + 4 * i] = jal(0, TRAP - (VEC + 4 * i))
main = [
    lui (T0, 0x20),                      # t0 = DSRAM
    lui (T3, 0x10),
    addi(T3, T3, VEC - 0x10000 + 1),     # mtvec = 0x10100 | vectored
    csrw(CSR_MTVEC, T3),
    lw  (T2, T0, 4 * W_TPR),
    csrw(CSR_TPR, T2),                   # TPR from config word
    lw  (S0, T0, 4 * W_S0),              # s0 <- secret (tag = tag_mem[8])
    lw  (A0, T0, 4 * W_A0),              # a0 <- secret (tag = tag_mem[9])
    lw  (T1, T0, 4 * W_T1),              # t1 <- secret (tag = tag_mem[10])
    lw  (S1, T0, 4 * W_S1),              # s1 <- clean  (tag = tag_mem[11])
    lw  (T2, T0, 4 * W_TCR),
    csrw(CSR_TCR, T2),                   # TCR last: checks armed now
    addi(A1, 0, 0),
    addi(A1, A1, 1),                     # 0x101B4 loop: heartbeat++
    sw  (A1, T0, 4 * W_HB),              # 0x101B8
    jal (0, -8),                         # 0x101BC
]
for i, w in enumerate(main):
    fw[MAIN + 4 * i] = w
assert MAIN + 4 * len(main) == TRAP
trap = [
    lui (T3, 0x20),
    csrr(T4, CSR_MCAUSE),
    sw  (T4, T3, 4 * W_MCAUSE),
    lw  (T5, T3, 4 * W_TRAPCNT),
    addi(T5, T5, 1),
    sw  (T5, T3, 4 * W_TRAPCNT),
    jal (0, 0),                          # park
]
for i, w in enumerate(trap):
    fw[TRAP + 4 * i] = w
write_image("dift_fw_signed.mem", [fw[a] for a in range(ENTRY, TRAP + 4 * len(trap), 4)],
            "signed DIFT test firmware (secure_boot_dbg_tb)")

with open(os.path.join(HERE, "otp_pubkey.mem"), "w") as f:
    f.write("// TEST-ONLY Ed25519 public key, rtl/crypto pubkey.mem format\n")
    for i in range(0, 32, 4):
        f.write(f"{struct.unpack('>I', pub[i:i+4])[0]:08x}\n")

print(f"pubkey={pub.hex()}")
