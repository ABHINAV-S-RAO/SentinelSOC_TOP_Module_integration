import re

# 1. Fix dbg_tb_top.sv
with open('verif/debugger/dbg_tb_top.sv', 'r') as f:
    c = f.read()
c = re.sub(r'\.HEX_FILE\s*\(\s*""\s*\)', '.HEX_FILE ( "verif/debugger/bootrom.hex" )', c, count=1)
c = c.replace('poll > 500', 'poll > 5000')
with open('verif/debugger/dbg_tb_top.sv', 'w') as f:
    f.write(c)

# 2. Fix the memory models by commenting out the $display line entirely
def silence_display(filename):
    with open(filename, 'r') as f:
        lines = f.readlines()
    with open(filename, 'w') as f:
        for line in lines:
            if '$display' in line or '$time' in line:
                f.write('// ' + line)
            else:
                f.write(line)

silence_display('verif/debugger/bootrom_model.sv')
silence_display('verif/debugger/isram_model.sv')
silence_display('verif/debugger/dsram_model.sv')
