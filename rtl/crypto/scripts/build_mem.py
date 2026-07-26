# build_mem.py
import struct

def be_words(data: bytes):
    assert len(data) % 4 == 0
    return [struct.unpack('>I', data[i:i+4])[0] for i in range(0, len(data), 4)]

firmware = open("rtl/crypto/scripts/bins/firmware.bin", "rb").read()
pubkey   = open("rtl/crypto/scripts/bins/pubkey.bin", "rb").read()
R        = open("rtl/crypto/scripts/bins/sig_R.bin", "rb").read()
S        = open("rtl/crypto/scripts/bins/sig_S.bin", "rb").read()

r_words   = be_words(R)        # 8 words
s_words   = be_words(S)        # 8 words
msg_words = be_words(firmware) # firmware/4 words
pub_words = be_words(pubkey)   # 8 words

sha_len = 8 + 8 + len(msg_words)   # matches R + A(pubkey) + M word count

flash_words = [sha_len] + r_words + s_words + msg_words
with open("rtl/crypto/scripts/mems/flash.mem", "w") as f:
    for w in flash_words:
        f.write(f"{w:08x}\n")

with open("rtl/crypto/scripts/mems/pubkey.mem", "w") as f:
    for w in pub_words:
        f.write(f"{w:08x}\n")

print(f"flash.mem: {len(flash_words)} words / {len(flash_words)*4} bytes")
print(f"sha_len_reg = {sha_len} (0x{sha_len:x})")