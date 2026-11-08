import re

with open('verif/debugger/dbg_tb_top.sv', 'r') as f:
    c = f.read()

# 1. Point the bootrom to our hex file
c = re.sub(r'\.HEX_FILE\s*\(\s*""\s*\)', '.HEX_FILE ( "verif/debugger/bootrom.hex" )', c, count=1)

# 2. Increase the polling limit to 5000
c = c.replace('poll > 500', 'poll > 5000')
c = c.replace('poll > 2000', 'poll > 5000')

# 3. Add tracing so we can see what the Debug Module is returning
c = re.sub(r'(dmi_read\s*\(\s*7\'h11\s*,\s*dmi_rdata\s*\)\s*;)', 
           r'\1 $display("[%0t] Polled dmstatus = 0x%08x", $time, dmi_rdata);', c)

with open('verif/debugger/dbg_tb_top.sv', 'w') as f:
    f.write(c)
