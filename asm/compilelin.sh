#!/bin/bash
fasm asm/r3fasm_lin.asm asm/r3fasmlin.o
ld -o r3forth asm/r3fasmlin.o -ldl --dynamic-linker /lib64/ld-linux-x86-64.so.2
chmod +x r3forth
