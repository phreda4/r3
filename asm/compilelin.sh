#!/bin/bash
# Linux build: asm/code.asm asm/data.asm asm/set.asm -> executable
# usage (from the r3 root):  asm/compilelin.sh [output]    default output: r3forth
out=${1:-r3forth}
fasm -m 262144 asm/r3fasm_lin.asm asm/r3fasmlin.o || exit 1
ld -e start -o "$out" asm/r3fasmlin.o -ldl -lc --dynamic-linker /lib64/ld-linux-x86-64.so.2 || exit 1
chmod +x "$out"
