# sign_firmware.py
from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PrivateKey
from cryptography.hazmat.primitives.serialization import Encoding, PrivateFormat, PublicFormat, NoEncryption

TARGET_SIZE = 512 * 1024

with open("rtl/crypto/scripts/bins/firmware_code.bin", "rb") as f:
    code = f.read()

pad_len = TARGET_SIZE - len(code)
if pad_len < 0:
    raise SystemExit("firmware larger than target size")
filler = bytes((i * 2654435761) & 0xFF for i in range(pad_len))
firmware = code + filler
if len(firmware) % 4:
    firmware += b"\x00" * (4 - len(firmware) % 4)

sk = Ed25519PrivateKey.generate()
pubkey_bytes = sk.public_key().public_bytes(Encoding.Raw, PublicFormat.Raw)  # 32B
sig = sk.sign(firmware)          # 64B = R(32) || S(32), RFC 8032 encoding
R_bytes, S_bytes = sig[:32], sig[32:]

open("rtl/crypto/scripts/bins/firmware.bin", "wb").write(firmware)
open("rtl/crypto/scripts/bins/pubkey.bin", "wb").write(pubkey_bytes)
open("rtl/crypto/scripts/bins/sig_R.bin", "wb").write(R_bytes)
open("rtl/crypto/scripts/bins/sig_S.bin", "wb").write(S_bytes)

print("firmware bytes:", len(firmware))
print("pubkey:", pubkey_bytes.hex())
print("R:", R_bytes.hex())
print("S:", S_bytes.hex())