#!/usr/bin/env python3
"""
rvasm.py -- minimal two-pass RV32I(+Zicsr) assembler for SentinelSoC boot
code, so ROM/firmware images can be built without a RISC-V toolchain.

Accepts a subset of GNU `as` syntax, so the same .S files assemble with
riscv32-unknown-elf-gcc once it is installed:
  - labels `name:`; comments `#`, `//`, `/* ... */` (single line)
  - directives: .equ/.set NAME, expr   .org OFFSET   .align N (2^N)
                .balign N   .word e[,e]   .byte e[,e]   .ascii/.asciz/.string "s"
                .rept N / .endr   .text/.data/.section/.globl/.global/.type (ignored)
  - RV32I base, csrrw/s/c(+i), mret, wfi, ecall, ebreak, fence
  - pseudo: li la mv not neg j jr ret call nop beqz bnez bltz bgez blez bgtz
            bgt ble bgtu bleu csrr csrw csrs csrc csrwi csrsi csrci
  - expressions: integers, 'c', symbols, + - * / << >> & | ^ ~ ( )
Every instruction is 32-bit (no compressed encodings). `li` uses one
instruction when the value fits 12 bits signed, else lui(+addi); `la` is
always lui+addi (absolute, non-PIC).

Usage: rvasm.py in.S --base 0x0 -o out   -> out.bin, out.hex (32-bit words,
       little-endian, one per line for $readmemh), out.sym
"""
import argparse
import re
import struct
import sys

REGS = {f"x{i}": i for i in range(32)}
REGS.update(dict(zero=0, ra=1, sp=2, gp=3, tp=4, t0=5, t1=6, t2=7, s0=8, fp=8, s1=9,
                 a0=10, a1=11, a2=12, a3=13, a4=14, a5=15, a6=16, a7=17,
                 s2=18, s3=19, s4=20, s5=21, s6=22, s7=23, s8=24, s9=25, s10=26, s11=27,
                 t3=28, t4=29, t5=30, t6=31))
CSRS = dict(mstatus=0x300, misa=0x301, mie=0x304, mtvec=0x305, mscratch=0x340, mepc=0x341,
            mcause=0x342, mtval=0x343, mip=0x344, mhartid=0xF14, mcycle=0xB00, minstret=0xB02,
            dcsr=0x7B0, dpc=0x7B1, tcr=0x7C2, tpr=0x7C3)

R_OPS = {  # name: (funct7, funct3)
    'add': (0x00, 0), 'sub': (0x20, 0), 'sll': (0x00, 1), 'slt': (0x00, 2), 'sltu': (0x00, 3),
    'xor': (0x00, 4), 'srl': (0x00, 5), 'sra': (0x20, 5), 'or': (0x00, 6), 'and': (0x00, 7),
    'mul': (0x01, 0), 'mulh': (0x01, 1), 'mulhsu': (0x01, 2), 'mulhu': (0x01, 3),
    'div': (0x01, 4), 'divu': (0x01, 5), 'rem': (0x01, 6), 'remu': (0x01, 7)}
I_ALU = {'addi': 0, 'slti': 2, 'sltiu': 3, 'xori': 4, 'ori': 6, 'andi': 7}
SHIFTS = {'slli': (0x00, 1), 'srli': (0x00, 5), 'srai': (0x20, 5)}
LOADS = {'lb': 0, 'lh': 1, 'lw': 2, 'lbu': 4, 'lhu': 5}
STORES = {'sb': 0, 'sh': 1, 'sw': 2}
BRANCHES = {'beq': 0, 'bne': 1, 'blt': 4, 'bge': 5, 'bltu': 6, 'bgeu': 7}
CSR_OPS = {'csrrw': 1, 'csrrs': 2, 'csrrc': 3, 'csrrwi': 5, 'csrrsi': 6, 'csrrci': 7}


class AsmError(Exception):
    pass


def split_args(s):
    out, depth, cur, q = [], 0, '', False
    for ch in s:
        if ch == '"':
            q = not q
        if ch == ',' and depth == 0 and not q:
            out.append(cur.strip()); cur = ''
            continue
        depth += ch == '('
        depth -= ch == ')'
        cur += ch
    if cur.strip():
        out.append(cur.strip())
    return out


class Assembler:
    def __init__(self, base):
        self.base = base
        self.syms = {}
        self.undef = False        # set when pass 1 meets a not-yet-defined symbol

    # ------------------------------------------------------------------ exprs
    def ev(self, e, final):
        e = e.strip()
        e = re.sub(r"'(\\?.)'", lambda m: str(ord(m.group(1)[-1] if m.group(1)[0] != '\\'
                                                  else {'n': '\n', 't': '\t', '0': '\0'}[m.group(1)[1]])), e)
        m = re.fullmatch(r'%(hi|lo)\((.*)\)', e)
        if m:
            v = self.ev(m.group(2), final)
            hi = ((v + 0x800) >> 12) & 0xFFFFF
            return hi if m.group(1) == 'hi' else v - (hi << 12)

        def sym(mo):
            n = mo.group(0)
            if n in self.syms:
                return str(self.syms[n])
            if final:
                raise AsmError(f"undefined symbol '{n}'")
            self.undef = True
            return '0'
        e2 = re.sub(r'\b0[xX][0-9a-fA-F_]+\b', lambda mo: str(int(mo.group(0).replace('_', ''), 16)), e)
        e2 = re.sub(r'(?<![0-9A-Za-z_])[A-Za-z_.][A-Za-z0-9_.]*', sym, e2)
        if not re.fullmatch(r'[0-9\s+\-*/()<>&|^~]*', e2):
            raise AsmError(f"bad expression '{e}'")
        return int(eval(e2.replace('/', '//'), {'__builtins__': {}}))

    def reg(self, r):
        r = r.strip()
        if r not in REGS:
            raise AsmError(f"bad register '{r}'")
        return REGS[r]

    def csr(self, c):
        c = c.strip()
        return CSRS[c] if c in CSRS else self.ev(c, True)

    def memop(self, a, final):
        m = re.fullmatch(r'(.*)\(\s*(\w+)\s*\)', a.strip())
        if not m:
            raise AsmError(f"bad memory operand '{a}'")
        off = self.ev(m.group(1) or '0', final)
        return off, self.reg(m.group(2))

    # ---------------------------------------------------------------- encode
    def chk(self, v, bits, what):
        if not self.final:            # pass 1: forward targets are still unknown
            return
        if not -(1 << (bits - 1)) <= v < (1 << (bits - 1)):
            raise AsmError(f"{what} {v} out of range ({bits}-bit signed)")

    def i_t(self, imm, rs1, f3, rd, op):
        self.chk(imm, 12, 'immediate')
        return ((imm & 0xFFF) << 20) | (rs1 << 15) | (f3 << 12) | (rd << 7) | op

    def s_t(self, imm, rs2, rs1, f3):
        self.chk(imm, 12, 'offset')
        return (((imm >> 5) & 0x7F) << 25) | (rs2 << 20) | (rs1 << 15) | (f3 << 12) | ((imm & 0x1F) << 7) | 0x23

    def b_t(self, off, rs1, rs2, f3):
        self.chk(off, 13, 'branch offset')
        o = off & 0x1FFF
        return (((o >> 12) & 1) << 31) | (((o >> 5) & 0x3F) << 25) | (rs2 << 20) | (rs1 << 15) | \
               (f3 << 12) | (((o >> 1) & 0xF) << 8) | (((o >> 11) & 1) << 7) | 0x63

    def j_t(self, off, rd):
        self.chk(off, 21, 'jump offset')
        o = off & 0x1FFFFF
        return (((o >> 20) & 1) << 31) | (((o >> 1) & 0x3FF) << 21) | (((o >> 11) & 1) << 20) | \
               (((o >> 12) & 0xFF) << 12) | (rd << 7) | 0x6F

    @staticmethod
    def lui(rd, hi):
        return ((hi & 0xFFFFF) << 12) | (rd << 7) | 0x37

    def li_words(self, rd, v):
        v &= 0xFFFFFFFF
        sv = v - (1 << 32) if v & 0x80000000 else v
        if -2048 <= sv < 2048:
            return [self.i_t(sv, 0, 0, rd, 0x13)]
        hi = ((v + 0x800) >> 12) & 0xFFFFF
        lo = sv - ((hi << 12) - (1 << 32) if (hi << 12) & 0x80000000 else (hi << 12))
        lo = ((lo + 2048) & 0xFFF) - 2048
        w = [self.lui(rd, hi)]
        if lo:
            w.append(self.i_t(lo, rd, 0, rd, 0x13))
        return w

    def insn(self, mn, a, pc, final):
        """Return list of 32-bit words for one (pseudo-)instruction."""
        n = len(a)
        R, E = self.reg, lambda x: self.ev(x, final)
        tgt = lambda x: E(x) - pc
        if mn in R_OPS:
            f7, f3 = R_OPS[mn]
            return [(f7 << 25) | (R(a[2]) << 20) | (R(a[1]) << 15) | (f3 << 12) | (R(a[0]) << 7) | 0x33]
        if mn in I_ALU:
            return [self.i_t(E(a[2]), R(a[1]), I_ALU[mn], R(a[0]), 0x13)]
        if mn in SHIFTS:
            f7, f3 = SHIFTS[mn]
            sh = E(a[2])
            if not 0 <= sh < 32:
                raise AsmError('shift amount out of range')
            return [(f7 << 25) | (sh << 20) | (R(a[1]) << 15) | (f3 << 12) | (R(a[0]) << 7) | 0x13]
        if mn in LOADS:
            off, rs1 = self.memop(a[1], final)
            return [self.i_t(off, rs1, LOADS[mn], R(a[0]), 0x03)]
        if mn in STORES:
            off, rs1 = self.memop(a[1], final)
            return [self.s_t(off, R(a[0]), rs1, STORES[mn])]
        if mn in BRANCHES:
            return [self.b_t(tgt(a[2]), R(a[0]), R(a[1]), BRANCHES[mn])]
        if mn == 'lui':
            return [self.lui(R(a[0]), E(a[1]))]
        if mn == 'auipc':
            return [((E(a[1]) & 0xFFFFF) << 12) | (R(a[0]) << 7) | 0x17]
        if mn == 'jal':
            if n == 1:
                return [self.j_t(tgt(a[0]), 1)]
            return [self.j_t(tgt(a[1]), R(a[0]))]
        if mn == 'jalr':
            if n == 1:
                return [self.i_t(0, R(a[0]), 0, 1, 0x67)]
            if n == 2:
                off, rs1 = self.memop(a[1], final)
                return [self.i_t(off, rs1, 0, R(a[0]), 0x67)]
            return [self.i_t(E(a[2]), R(a[1]), 0, R(a[0]), 0x67)]
        if mn in CSR_OPS:
            src = E(a[2]) if mn.endswith('i') else R(a[2])
            return [(self.csr(a[1]) << 20) | (src << 15) | (CSR_OPS[mn] << 12) | (R(a[0]) << 7) | 0x73]
        simple = {'mret': 0x30200073, 'wfi': 0x10500073, 'ecall': 0x00000073,
                  'ebreak': 0x00100073, 'fence': 0x0FF0000F, 'nop': 0x00000013,
                  'ret': 0x00008067}
        if mn in simple:
            return [simple[mn]]
        # ---------------- pseudo-instructions
        if mn == 'li':
            self.undef = False
            v = E(a[1])
            if not final and self.undef:
                return [0, 0]                              # forward ref: assume 2 words
            return self.li_words(R(a[0]), v)
        if mn == 'la':
            v = E(a[1]) & 0xFFFFFFFF
            hi = ((v + 0x800) >> 12) & 0xFFFFF
            lo = ((v - (hi << 12)) + 2048) % 4096 - 2048
            return [self.lui(R(a[0]), hi), self.i_t(lo, R(a[0]), 0, R(a[0]), 0x13)]
        if mn == 'mv':   return [self.i_t(0, R(a[1]), 0, R(a[0]), 0x13)]
        if mn == 'not':  return [self.i_t(-1, R(a[1]), 4, R(a[0]), 0x13)]
        if mn == 'neg':  return [(0x20 << 25) | (R(a[1]) << 20) | (R(a[0]) << 7) | 0x33]
        if mn == 'j':    return [self.j_t(tgt(a[0]), 0)]
        if mn == 'jr':   return [self.i_t(0, R(a[0]), 0, 0, 0x67)]
        if mn == 'call': return [self.j_t(tgt(a[0]), 1)]
        if mn == 'beqz': return [self.b_t(tgt(a[1]), R(a[0]), 0, 0)]
        if mn == 'bnez': return [self.b_t(tgt(a[1]), R(a[0]), 0, 1)]
        if mn == 'bltz': return [self.b_t(tgt(a[1]), R(a[0]), 0, 4)]
        if mn == 'bgez': return [self.b_t(tgt(a[1]), R(a[0]), 0, 5)]
        if mn == 'blez': return [self.b_t(tgt(a[1]), 0, R(a[0]), 5)]
        if mn == 'bgtz': return [self.b_t(tgt(a[1]), 0, R(a[0]), 4)]
        if mn == 'bgt':  return [self.b_t(tgt(a[2]), R(a[1]), R(a[0]), 4)]
        if mn == 'ble':  return [self.b_t(tgt(a[2]), R(a[1]), R(a[0]), 5)]
        if mn == 'bgtu': return [self.b_t(tgt(a[2]), R(a[1]), R(a[0]), 6)]
        if mn == 'bleu': return [self.b_t(tgt(a[2]), R(a[1]), R(a[0]), 7)]
        if mn == 'csrr': return [(self.csr(a[1]) << 20) | (2 << 12) | (R(a[0]) << 7) | 0x73]
        if mn in ('csrw', 'csrs', 'csrc'):
            f3 = {'csrw': 1, 'csrs': 2, 'csrc': 3}[mn]
            return [(self.csr(a[0]) << 20) | (R(a[1]) << 15) | (f3 << 12) | 0x73]
        if mn in ('csrwi', 'csrsi', 'csrci'):
            f3 = {'csrwi': 5, 'csrsi': 6, 'csrci': 7}[mn]
            return [(self.csr(a[0]) << 20) | (E(a[1]) << 15) | (f3 << 12) | 0x73]
        raise AsmError(f"unknown instruction '{mn}'")

    # ------------------------------------------------------------------ passes
    def lines(self, src):
        out, rept = [], None
        for ln_no, raw in enumerate(src.splitlines(), 1):
            line = re.sub(r'/\*.*?\*/', '', raw)
            line = re.split(r'(?<!\\)#|//', line, maxsplit=1)[0] if '"' not in line else \
                re.sub(r'\s(#|//).*$', '', line)
            line = line.strip()
            if not line:
                continue
            m = re.fullmatch(r'\.rept\s+(.*)', line)
            if m:
                rept = (int(self.ev(m.group(1), True)), [])
                continue
            if line == '.endr':
                out.extend(rept[1] * rept[0]); rept = None
                continue
            (rept[1] if rept else out).append((ln_no, line))
        return out

    def run(self, src, final):
        self.final = final
        pc = self.base
        blob = bytearray()

        def emit(b):
            nonlocal pc
            blob.extend(b); pc += len(b)
        for ln_no, line in self.lines(src):
            try:
                while True:
                    m = re.match(r'([A-Za-z_.][\w.]*)\s*:(.*)', line)
                    if not m:
                        break
                    if not final:
                        if m.group(1) in self.syms and self.syms[m.group(1)] != pc:
                            raise AsmError(f"duplicate label '{m.group(1)}'")
                        self.syms[m.group(1)] = pc
                    elif self.syms.get(m.group(1)) != pc:
                        raise AsmError(f"label '{m.group(1)}' moved between passes")
                    line = m.group(2).strip()
                if not line:
                    continue
                mn, _, rest = line.partition(' ')
                mn, args = mn.lower(), split_args(rest)
                if mn in ('.equ', '.set'):
                    self.syms[args[0]] = self.ev(args[1], final)
                elif mn in ('.text', '.data', '.section', '.globl', '.global', '.type', '.size', '.option'):
                    pass
                elif mn == '.org':
                    tgt = self.base + self.ev(args[0], True)
                    if tgt < pc:
                        raise AsmError(".org moves backwards")
                    emit(b'\x00' * (tgt - pc))
                elif mn in ('.align', '.p2align', '.balign'):
                    al = self.ev(args[0], True)
                    al = al if mn == '.balign' else (1 << al)
                    emit(b'\x00' * ((-pc) % al))
                elif mn == '.word':
                    for x in args:
                        emit(struct.pack('<I', self.ev(x, final) & 0xFFFFFFFF))
                elif mn == '.byte':
                    for x in args:
                        emit(bytes([self.ev(x, final) & 0xFF]))
                elif mn in ('.ascii', '.asciz', '.string'):
                    sm = re.fullmatch(r'"(.*)"', rest.strip())
                    s = bytes(sm.group(1), 'utf-8').decode('unicode_escape').encode('latin-1')
                    emit(s + (b'\x00' if mn != '.ascii' else b''))
                elif mn.startswith('.'):
                    raise AsmError(f"unsupported directive '{mn}'")
                else:
                    if pc % 4:
                        raise AsmError("instruction not 4-byte aligned (add .align 2)")
                    for w in self.insn(mn, args, pc, final):
                        emit(struct.pack('<I', w & 0xFFFFFFFF))
            except (AsmError, KeyError, IndexError, ValueError) as e:
                raise AsmError(f"line {ln_no}: {line!r}: {e}")
        return bytes(blob)

    def assemble(self, src):
        self.run(src, False)
        size1 = dict(self.syms)
        out = self.run(src, True)
        assert size1 == {k: v for k, v in self.syms.items() if k in size1}, "layout changed"
        return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('src')
    ap.add_argument('--base', default='0')
    ap.add_argument('-o', required=True, help='output prefix')
    ap.add_argument('--pad-words', type=int, default=0, help='pad .hex to N words')
    args = ap.parse_args()
    asm = Assembler(int(args.base, 0))
    try:
        blob = asm.assemble(open(args.src).read())
    except AsmError as e:
        sys.exit(f"{args.src}: {e}")
    blob += b'\x00' * ((-len(blob)) % 4)
    open(args.o + '.bin', 'wb').write(blob)
    words = [struct.unpack('<I', blob[i:i + 4])[0] for i in range(0, len(blob), 4)]
    words += [0x00000013] * max(0, args.pad_words - len(words))
    with open(args.o + '.hex', 'w') as f:
        f.writelines(f"{w:08x}\n" for w in words)
    with open(args.o + '.sym', 'w') as f:
        for k, v in sorted(asm.syms.items(), key=lambda kv: kv[1]):
            f.write(f"{v:08x} {k}\n")
    print(f"{args.src}: {len(blob)} bytes @ 0x{asm.base:08x}")


if __name__ == '__main__':
    main()
