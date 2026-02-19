# R3forth — Language Reference

**A Concatenative Language Derived from ColorForth**

*Pablo H. Reda*

Repository: https://github.com/phreda4/r3

---

## Quick Reference Card

### The 8 Prefixes

| Prefix | Meaning | Example |
|--------|---------|---------|
| `\|` | Comment (rest of line) | `\| this is ignored` |
| `^` | Include file | `^r3/lib/console.r3` |
| `"` | String literal | `"hello world"` |
| `:` | Define code word | `:myword ... ;` |
| `#` | Define data / variable | `#var 0` |
| `$` | Hexadecimal literal | `$FF` |
| `%` | Binary literal | `%1010` |
| `'` | Address of word | `'myword` |

### Key Conventions

- `a b -- c` means: consumes `a` and `b`, produces `c`
- **TOS** = Top Of Stack (most recently pushed)
- **NOS** = Next Of Stack (second from top)
- All cells are 64-bit (8 bytes) by default
- `a b >?` asks "is `a` greater than `b`?" — NOS is always `a`
- Unary conditionals (`0?`, `1?`, `-?`, `+?`) do **not** consume the stack
- Binary conditionals (`>?`, `<?`, etc.) consume TOS, leave NOS
- **Fixed-point:** 48.16 format — multiply any real by 65536 to get the stored integer
- **Angles:** in turns (0.0–1.0 = 0°–360°; 0.25 = 90°, 0.5 = 180°)

---

## Table of Contents

1. [Control Flow](#control-flow)
2. [Conditionals](#conditionals)
3. [Stack Operations](#stack-operations)
4. [Arithmetic Operations](#arithmetic-operations)
5. [Logical Operations](#logical-operations)
6. [Memory Operations](#memory-operations)
7. [Register Operations](#register-operations)
8. [Memory Block Operations](#memory-block-operations)
9. [Return Stack](#return-stack)
10. [System Interface](#system-interface)
11. [Variable Definition Syntax](#variable-definition-syntax)
12. [Dynamic Memory](#dynamic-memory)
13. [Library: math.r3](#library-mathr3)
14. [Library: rand.r3](#library-randr3)
15. [Library: str.r3](#library-strr3)
16. [Library: mem.r3](#library-memr3)
17. [Library: core.r3](#library-corer3)
18. [Library: console.r3](#library-consoler3)
19. [Library: sdl2.r3](#library-sdl2r3)
20. [Library: sdl2gfx.r3](#library-sdl2gfxr3)
21. [Library: sdl2image.r3](#library-sdl2imager3)
22. [Usage Examples](#usage-examples)
23. [Glossary](#glossary)

---

## Control Flow

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `;` | `--` | End word execution, return to caller |
| `(` | `--` | Begin code block (loop or conditional) |
| `)` | `--` | End code block |
| `[` | `-- v` | Begin anonymous word definition |
| `]` | `v --` | End anonymous word definition |
| `EX` | `v --` | Execute word by address |

### Word Definition Syntax

```forth
:wordname  body ;          | private code word
::wordname body ;          | exported code word (visible when included)
#varname   values          | private data word
##varname  values          | exported data word
```

### Fall-Through (No Semicolon)

A definition without `;` continues execution into the next definition:

```forth
:word1
    part-a              | no ; — falls through to word2
:word2
    part-b ;

word1   | executes part-a, then part-b
word2   | executes part-b only
```

---

## Conditionals

### Unary Conditionals — do not consume the stack

| Word | Stack Effect | True when |
|------|--------------|-----------|
| `0?` | `a -- a` | a = 0 |
| `1?` | `a -- a` | a ≠ 0 |
| `+?` | `a -- a` | a ≥ 0 |
| `-?` | `a -- a` | a < 0 |

### Binary Conditionals — consume TOS, leave NOS

`a b OP?` tests NOS (`a`) against TOS (`b`). TOS is consumed. NOS remains.
Think of `a b >?` as "is `a` greater than `b`?" — exactly as written in math.

| Word | Stack Effect | True when |
|------|--------------|-----------|
| `<?` | `a b -- a` | a < b |
| `>?` | `a b -- a` | a > b |
| `=?` | `a b -- a` | a = b |
| `>=?` | `a b -- a` | a ≥ b |
| `<=?` | `a b -- a` | a ≤ b |
| `<>?` | `a b -- a` | a ≠ b |
| `AND?` | `a b -- a` | a AND b ≠ 0 |
| `NAND?` | `a b -- a` | a NAND b ≠ 0 |
| `IN?` | `a b c -- a` | b ≤ a ≤ c (consumes both b and c) |

### Conditional Usage Pattern

```forth
value
test? ( block-if-true )
drop                        | value always remains; must be cleaned up
```

Chaining multiple tests on the same value:

```forth
var
10 >?  ( "greater than 10" .print )
0  <?  ( "less than 0"     .print )
drop
```

---

## Stack Operations

### Single-Value

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `DUP` | `a -- a a` | Duplicate TOS |
| `DROP` | `a --` | Remove TOS |
| `SWAP` | `a b -- b a` | Exchange TOS and NOS |
| `OVER` | `a b -- a b a` | Copy NOS to top |
| `NIP` | `a b -- b` | Remove NOS |
| `ROT` | `a b c -- b c a` | Rotate 3 elements left |
| `-ROT` | `a b c -- c a b` | Rotate 3 elements right |
| `PICK2` | `a b c -- a b c a` | Copy 3rd element to top |
| `PICK3` | `a b c d -- a b c d a` | Copy 4th element to top |
| `PICK4` | `a b c d e -- a b c d e a` | Copy 5th element to top |

### Multi-Value

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `2DUP` | `a b -- a b a b` | Duplicate top two |
| `2DROP` | `a b --` | Remove top two |
| `3DROP` | `a b c --` | Remove top three |
| `4DROP` | `a b c d --` | Remove top four |
| `2SWAP` | `a b c d -- c d a b` | Exchange two pairs |
| `2OVER` | `a b c d -- a b c d a b` | Copy 3rd and 4th to top |

---

## Arithmetic Operations

### Basic

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `+` | `a b -- c` | c = a + b |
| `-` | `a b -- c` | c = a − b |
| `*` | `a b -- c` | c = a × b |
| `/` | `a b -- c` | c = a ÷ b (integer) |
| `MOD` | `a b -- c` | c = a mod b |
| `/MOD` | `a b -- c d` | c = a÷b, d = a mod b |
| `NEG` | `a -- b` | b = −a |
| `ABS` | `a -- b` | b = \|a\| |
| `SQRT` | `a -- b` | b = integer square root of a |
| `CLZ` | `a -- b` | b = count leading zeros of a |

### Overflow-Safe

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `*/` | `a b c -- d` | d = a×b÷c (no intermediate overflow) |
| `*>>` | `a b c -- d` | d = (a×b)>>c (no overflow) |
| `<</` | `a b c -- d` | d = (a<<c)÷b (no overflow) |

### Bit Shifting

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `<<` | `a b -- c` | c = a << b (left shift) |
| `>>` | `a b -- c` | c = a >> b (signed right shift) |
| `>>>` | `a b -- c` | c = a >>> b (unsigned right shift) |

```forth
5 2 <<     | 20   (5 × 4)
5 1 >>     | 2    (5 ÷ 2, signed)
-2 1 >>    | -1   (sign preserved)
-1 1 >>>   | 9223372036854775807  (sign cleared)
```

---

## Logical Operations

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `AND` | `a b -- c` | c = a AND b (bitwise) |
| `OR` | `a b -- c` | c = a OR b |
| `XOR` | `a b -- c` | c = a XOR b |
| `NOT` | `a -- b` | b = NOT a (all bits flipped) |
| `NAND` | `a b -- c` | c = NOT (a AND b) |

---

## Memory Operations

#### Qword (64-bit)
| Word | Stack Effect | Description | Increment |
|------|--------------|-------------|-----------|
| `@` | `a -- [a]` | Fetch qword | — |
| `@+` | `a -- b [a]` | Fetch qword and increment | +8 |
| `!` | `a b --` | Store A at address B | — |
| `!+` | `a b -- c` | Store A at B and increment | +8 |
| `+!` | `a b --` | Add A to value at address B | — |

#### Dword (32-bit)
| Word | Stack Effect | Description | Increment |
|------|--------------|-------------|-----------|
| `D@` | `a -- dword[a]` | Fetch dword | — |
| `D@+` | `a -- b dword[a]` | Fetch dword and increment | +4 |
| `D!` | `a b --` | Store dword A at address B | — |
| `D!+` | `a b -- c` | Store dword A at B and increment | +4 |
| `D+!` | `a b --` | Add A to dword at address B | — |

#### Word (16-bit)
| Word | Stack Effect | Description | Increment |
|------|--------------|-------------|-----------|
| `W@` | `a -- word[a]` | Fetch word | — |
| `W@+` | `a -- b word[a]` | Fetch word and increment | +2 |
| `W!` | `a b --` | Store word A at address B | — |
| `W!+` | `a b -- c` | Store word A at B and increment | +2 |
| `W+!` | `a b --` | Add A to word at address B | — |

#### Byte (8-bit)
| Word | Stack Effect | Description | Increment |
|------|--------------|-------------|-----------|
| `C@` | `a -- byte[a]` | Fetch byte | — |
| `C@+` | `a -- b byte[a]` | Fetch byte and increment | +1 |
| `C!` | `a b --` | Store byte A at address B | — |
| `C!+` | `a b -- c` | Store byte A at B and increment | +1 |
| `C+!` | `a b --` | Add A to byte at address B | — |

---

## Register Operations

Registers A and B are fast auxiliary variables optimized for memory traversal. They **persist across word calls** — save them with `AB[` / `]BA` if you call words that may use them.

### Register A

| Word | Stack Effect | Description | Increment |
|------|--------------|-------------|-----------|
| `>A` | `a --` | Load register A | — |
| `A>` | `-- a` | Push register A | — |
| `A+` | `a --` | Add to register A | — |
| `A@` | `-- a` | Fetch qword from A | — |
| `A!` | `a --` | Store qword at A | — |
| `A@+` | `-- a` | Fetch qword from A and increment | +8 |
| `A!+` | `a --` | Store qword at A and increment | +8 |
| `CA@` | `-- a` | Fetch byte from A | — |
| `CA!` | `a --` | Store byte at A | — |
| `CA@+` | `-- a` | Fetch byte from A and increment | +1 |
| `CA!+` | `a --` | Store byte at A and increment | +1 |
| `DA@` | `-- a` | Fetch dword from A | — |
| `DA!` | `a --` | Store dword at A | — |
| `DA@+` | `-- a` | Fetch dword from A and increment | +4 |
| `DA!+` | `a --` | Store dword at A and increment | +4 |

### Register B

| Word | Stack Effect | Description | Increment |
|------|--------------|-------------|-----------|
| `>B` | `a --` | Load register B | — |
| `B>` | `-- a` | Push register B | — |
| `B+` | `a --` | Add to register B | — |
| `B@` | `-- a` | Fetch qword from B | — |
| `B!` | `a --` | Store qword at B | — |
| `B@+` | `-- a` | Fetch qword from B and increment | +8 |
| `B!+` | `a --` | Store qword at B and increment | +8 |
| `CB@` | `-- a` | Fetch byte from B | — |
| `CB!` | `a --` | Store byte at B | — |
| `CB@+` | `-- a` | Fetch byte from B and increment | +1 |
| `CB!+` | `a --` | Store byte at B and increment | +1 |
| `DB@` | `-- a` | Fetch dword from B | — |
| `DB!` | `a --` | Store dword at B | — |
| `DB@+` | `-- a` | Fetch dword from B and increment | +4 |
| `DB!+` | `a --` | Store dword at B and increment | +4 |

### Save / Restore

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `AB[` | `--` | Save A and B to return stack |
| `]BA` | `--` | Restore B and A from return stack |

---

## Memory Block Operations

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `MOVE` | `d s c --` | Copy c qwords from s to d |
| `MOVE>` | `d s c --` | Copy c qwords, reverse direction |
| `FILL` | `d v c --` | Fill d with c qwords of value v |
| `CMOVE` | `d s c --` | Copy c bytes from s to d |
| `CMOVE>` | `d s c --` | Copy c bytes, reverse direction |
| `CFILL` | `d v c --` | Fill d with c bytes of value v |
| `DMOVE` | `d s c --` | Copy c dwords from s to d |
| `DMOVE>` | `d s c --` | Copy c dwords, reverse direction |
| `DFILL` | `d v c --` | Fill d with c dwords of value v |

---

## Return Stack

The return stack stores return addresses during word calls. It can be used as temporary storage *within a single word* — every `>R` must be matched by `R>` before any exit, including conditional exits.

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `>R` | `a -- (r: -- a)` | Push to return stack |
| `R>` | `-- a (r: a --)` | Pop from return stack |
| `R@` | `-- a (r: a -- a)` | Copy top of return stack (non-destructive) |

> **Warning:** An unbalanced return stack causes the word to return to the wrong address. Always balance within the same word on all code paths.

---

## System Interface

Used to call functions in dynamic libraries (`.dll` on Windows, `.so` on Linux).

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `MEM` | `-- a` | Start of free memory |
| `LOADLIB` | `"name" -- liba` | Load dynamic library |
| `GETPROC` | `liba "name" -- aa` | Get function address |
| `SYS0` | `aa -- r` | Call with 0 parameters |
| `SYS1` | `a aa -- r` | Call with 1 parameter |
| `SYS2` | `a b aa -- r` | Call with 2 parameters |
| `SYS3` | `a b c aa -- r` | Call with 3 parameters |
| `SYS4` | `a b c d aa -- r` | Call with 4 parameters |
| `SYS5` | `a b c d e aa -- r` | Call with 5 parameters |
| `SYS6` | `a b c d e f aa -- r` | Call with 6 parameters |
| `SYS7` | `a b c d e f g aa -- r` | Call with 7 parameters |
| `SYS8` | `a b c d e f g h aa -- r` | Call with 8 parameters |
| `SYS9` | `a b c d e f g h i aa -- r` | Call with 9 parameters |
| `SYS10` | `a b c d e f g h i j aa -- r` | Call with 10 parameters |

**Usage pattern:**
```forth
"library.dll" LOADLIB 'lib !
lib "FunctionName" GETPROC 'fn !
arg1 arg2 fn SYS2 drop
```

---

## Variable Definition Syntax

| Definition | Description |
|------------|-------------|
| `#var` | One 64-bit cell, value 0 |
| `#var n` | One 64-bit cell, value n |
| `#var n m` | Two 64-bit cells, values n and m |
| `#var [ n ]` | One 32-bit cell (dword) |
| `#var ( n )` | One 8-bit cell (byte) |
| `#var * size` | `size` bytes, zero-initialized (not multiplication) |
| `#var "text"` | Null-terminated string bytes in variable memory |
| `#var 'word` | 64-bit cell holding address of `word` |

Mixed types in one definition:

```forth
#data 33 11 [ 1 2 ] ( 3 4 )
```

| Offset | Size | Value | Type |
|--------|------|-------|------|
| +0 | 8 bytes | 33 | qword |
| +8 | 8 bytes | 11 | qword |
| +16 | 4 bytes | 1 | dword (`[ ]`) |
| +20 | 4 bytes | 2 | dword (`[ ]`) |
| +24 | 1 byte | 3 | byte (`( )`) |
| +25 | 1 byte | 4 | byte (`( )`) |

---

## Dynamic Memory

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `MEM` | `-- a` | Address of start of free memory |
| `HERE` | `-- a` | Next free address (variable) |
| `MARK` | `--` | Push HERE (save current position) |
| `EMPTY` | `--` | Pop HERE (release memory since last MARK) |

```forth
MARK
HERE 'buf !
1024 'HERE +!          | allocate 1KB
... use buf ...
EMPTY                  | release — no garbage collector needed
```

### Memory Layout

```
┌─────────────────────────────────────┐
│  CODE MEMORY                        │
│  Compiled word definitions          │
└─────────────────────────────────────┘
┌─────────────────────────────────────┐
│  STRING CONSTANTS                   │
│  Strings defined inside : words     │
└─────────────────────────────────────┘
┌─────────────────────────────────────┐
│  VARIABLE MEMORY                    │
│  # definitions, data strings,       │
│  fixed-size buffers (* syntax)      │
└─────────────────────────────────────┘
              ↑ HERE starts here
┌─────────────────────────────────────┐
│  FREE MEMORY (Dynamic)              │
│  Managed by MEM / HERE / MARK /     │
│  EMPTY — grows upward               │
└─────────────────────────────────────┘
```

---

## Library: math.r3

Include with `^r3/lib/math.r3`

**Fixed-point arithmetic and mathematical functions.**
All fixed-point values use **48.16 format**. Angles in **turns** (0.25 = 90°, 0.5 = 180°).

### Size Shortcuts

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `cell+` | `a -- a+8` | Add cell size (8 bytes) |
| `ncell+` | `n a -- a+n*8` | Add n cells |
| `1+` | `a -- a+1` | Increment by 1 |
| `1-` | `a -- a-1` | Decrement by 1 |
| `2/` | `a -- a/2` | Divide by 2 (shift right) |
| `2*` | `a -- a*2` | Multiply by 2 (shift left) |

### Fixed-Point Core

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `*.` | `a b -- c` | Multiply fixed-point (full precision) |
| `*.s` | `a b -- c` | Multiply fixed-point (small numbers) |
| `*.f` | `a b -- c` | Multiply fixed-point (full adjust) |
| `/.` | `a b -- c` | Divide fixed-point |
| `2/.` | `a -- a/2` | Divide by 2 with adjustment |
| `ceil` | `a -- a` | Ceiling (round up) |
| `int.` | `f -- n` | Convert fixed-point to integer (f >> 16) |
| `fix.` | `n -- f` | Convert integer to fixed-point (n << 16) |
| `sign` | `v -- v s` | Push sign of v (+1 or -1) |

### Trigonometry

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `sin` | `angle -- r` | Sine (angle in turns) |
| `cos` | `angle -- r` | Cosine (angle in turns) |
| `tan` | `v -- f` | Tangent |
| `sincos` | `angle -- sin cos` | Sine and cosine together |
| `atan2` | `x y -- angle` | Arctangent (returns turns) |

### Polar / Cartesian Conversion

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `polar` | `angle len -- dx dy` | Polar to cartesian |
| `polar2` | `len angle -- dx dy` | Polar to cartesian (length first) |
| `xy+polar` | `x y angle r -- x y` | Add polar offset to coordinates |
| `xy+polar2` | `x y r angle -- x y` | Add polar offset (r first) |
| `ar>xy` | `xc yc angle r -- xc yc x y` | Polar to cartesian from center |

### Mathematical Functions

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `sqrt.` | `x -- r` | Square root (fixed-point) |
| `distfast` | `dx dy -- dis` | Fast distance approximation |
| `log2.` | `y -- r` | Logarithm base 2 |
| `pow2.` | `y -- r` | Power of 2 |
| `pow.` | `x y -- r` | x to the power of y |
| `root.` | `x n -- r` | Nth root of x |
| `ln.` | `x -- r` | Natural logarithm |
| `exp.` | `x -- r` | Exponential (eˣ) |
| `gamma.` | `x -- r` | Gamma function |
| `beta.` | `x y -- r` | Beta function |

### Utility Functions

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `average` | `x y -- v` | Average of two numbers |
| `min` | `a b -- m` | Minimum of two numbers |
| `max` | `a b -- m` | Maximum of two numbers |
| `clampmax` | `v max -- v` | Clamp to maximum |
| `clampmin` | `v min -- v` | Clamp to minimum |
| `clamp0` | `v -- v` | Clamp to 0 minimum |
| `clamp0max` | `v max -- v` | Clamp between 0 and max |
| `clamps16` | `v -- v` | Clamp to signed 16-bit range |
| `between` | `v min max -- flag` | 1 if min ≤ v ≤ max, else 0 |
| `msb` | `n -- pos` | Position of most significant bit |

### Special Functions

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `tanh.` | `x -- r` | Hyperbolic tangent |
| `fastanh.` | `x -- r` | Fast approximation of tanh |
| `cubicpulse` | `c w x -- v` | Cubic pulse function |

### Optimized Multipliers / Divisors

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `10*` | `n -- n*10` | Multiply by 10 |
| `100*` | `n -- n*100` | Multiply by 100 |
| `1000*` | `n -- n*1000` | Multiply by 1000 |
| `10000*` | `n -- n*10000` | Multiply by 10000 |
| `100000*` | `n -- n*100000` | Multiply by 100000 |
| `1000000*` | `n -- n*1000000` | Multiply by 1000000 |
| `10/` | `n -- n/10` | Divide by 10 |
| `10/mod` | `n -- q r` | Quotient and remainder of ÷10 |
| `1000000/` | `n -- n/1000000` | Divide by 1000000 |
| `6*` | `n -- n*6` | Multiply by 6 |
| `6/` | `n -- n/6` | Divide by 6 |
| `6mod` | `n -- n%6` | Modulo 6 |

### Bit Manipulation

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `bswap32` | `v -- vs` | Byte-swap 32 bits |
| `bswap64` | `v -- vs` | Byte-swap 64 bits |
| `nextpow2` | `v -- p2` | Next power of 2 ≥ v |

### Float (IEEE 754) Conversion

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `i2fp` | `i -- fp` | Integer → float32 |
| `f2fp` | `f -- fp` | Fixed-point → float32 |
| `fp2f` | `fp -- f` | Float32 → fixed-point |
| `fp2i` | `fp -- i` | Float32 → integer |
| `fp16f` | `fp16 -- f` | Float16 → fixed-point |
| `f2fp24` | `f -- fp` | Fixed 40.24 → float32 |
| `fp2f24` | `fp -- f` | Float32 → fixed 40.24 |
| `byte>float32N` | `byte -- f` | Byte → normalized float (0–1) |
| `float32N>byte` | `f -- byte` | Normalized float → byte |

---

## Library: rand.r3

Include with `^r3/lib/rand.r3`

### Default Generator

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `rerand` | `s1 s2 --` | Seed the random generator |
| `rand` | `-- n` | 64-bit random number |
| `randmax` | `max -- n` | Random in [0, max) |
| `randminmax` | `min max -- n` | Random in [min, max] |

### Xorshift Generator

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `rnd` | `-- n` | Xorshift random |
| `rndmax` | `max -- n` | Xorshift random in [0, max) |
| `rndminmax` | `min max -- n` | Xorshift random in [min, max] |

### Xorshift128+ Generator

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `rnd128` | `-- n` | Xorshift128+ random |

### LoopMix128 Generator

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `loopMix128` | `-- n` | LoopMix128 random |

```forth
time msec rerand    | seed with current time
100 randmax         | integer 0–99
10.0 randmax        | fixed-point 0.0–9.999…
-5.0 5.0 randminmax | fixed-point -5.0 to 5.0
```

---

## Library: str.r3

Include with `^r3/lib/str.r3`

**String manipulation.**

### Copy Operations

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `strcpyl` | `src des -- ndes` | Copy string, return new address |
| `strcpy` | `src des --` | Copy string |
| `strcat` | `src des --` | Concatenate strings |
| `strcpylnl` | `src des -- ndes` | Copy until newline |
| `strcpyln` | `src des --` | Copy until newline (no return) |
| `copynom` | `sc s1 --` | Copy until space |
| `copystr` | `sc s1 --` | Copy until quote (`"`) |
| `strpath` | `src dst --` | Copy path only (needs `/`) |

### Character Conversion

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `toupp` | `c -- C` | Convert character to uppercase |
| `tolow` | `C -- c` | Convert character to lowercase |

### String Analysis

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `count` | `s1 -- s1 cnt` | Count bytes in string |
| `utf8count` | `str -- str count` | Count UTF-8 characters |
| `utf8bytes` | `str cnt -- str bytes` | Get byte count for N UTF-8 chars |

### UTF-8 Operations

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `utf8ncpy` | `str 'dst cnt -- 'dst` | Copy N UTF-8 characters |

### Comparison

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `=` | `s1 s2 -- 1/0` | Compare strings (case-insensitive) |
| `cmpstr` | `a b -- n` | Compare strings (returns negative/0/positive) |
| `=s` | `s1 s2 -- 0/1` | Compare until space |
| `=w` | `s1 s2 -- 1/0` | Compare words |
| `=pre` | `adr "str" -- adr 1/0` | Check if string starts with prefix |
| `=pos` | `s1 ".ext" -- s1 1/0` | Check if string ends with suffix |
| `=lpos` | `lstr ".ext" -- s 1/0` | Check suffix from last address |

### Search

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `findchar` | `adr char -- adr'/0` | Find first occurrence of character |
| `findstr` | `adr "sub" -- adr'/0` | Find substring |
| `findstri` | `adr "sub" -- adr'/0` | Find substring (case-insensitive) |

### Number to String Conversion

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `.d` | `val -- str` | Decimal integer to string |
| `.b` | `val -- str` | Binary to string |
| `.h` | `val -- str` | Hexadecimal to string |
| `.o` | `val -- str` | Octal to string |
| `.f` | `val -- str` | Fixed-point to string (4 decimals) |
| `.f2` | `val -- str` | Fixed-point to string (2 decimals) |
| `.f1` | `val -- str` | Fixed-point to string (1 decimal) |
| `.r.` | `buf n -- buf` | Right-align with spaces |

### String Trimming and Navigation

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `trim` | `adr -- adr'` | Skip leading whitespace |
| `trimc` | `char adr -- adr'` | Skip leading occurrences of char |
| `trimcar` | `adr -- adr' c` | Skip whitespace, return first non-space char |
| `trimstr` | `adr -- adr'` | Skip to closing quote |
| `>>cr` | `adr -- adr'` | Skip to CR/LF |
| `>>0` | `adr -- adr'` | Skip to null terminator |
| `n>>0` | `adr n -- adr'` | Skip N null terminators |
| `>>sp` | `adr -- adr'` | Skip to space |
| `>>str` | `adr -- adr'` | Skip to quote |

### String List Operations

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `l0count` | `list -- cnt` | Count null-terminated strings in list |
| `only13` | `adr -- adr'` | Remove LF, keep only CR |

---

## Library: mem.r3

Include with `^r3/lib/mem.r3`

**Memory management and formatted output.**

### Memory Management

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `here` | `-- a` | Current free memory position |
| `mark` | `--` | Save current free memory position |
| `empty` | `--` | Restore to last mark |
| `align8` | `mem -- mem` | Align to 8-byte boundary |
| `align16` | `mem -- mem` | Align to 16-byte boundary |
| `align32` | `mem -- mem` | Align to 32-byte boundary |

### Compile to Memory (write to HERE)

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `,` | `val --` | Compile dword to HERE |
| `,c` | `val --` | Compile byte to HERE |
| `,q` | `val --` | Compile qword to HERE |
| `,w` | `val --` | Compile word to HERE |
| `,s` | `str --` | Compile string to HERE |
| `,word` | `str --` | Compile word (until space) |
| `,line` | `str --` | Compile line (until CR/LF) |
| `,d` | `val --` | Compile decimal string |
| `,2d` | `val --` | Compile decimal with leading zero |
| `,h` | `val --` | Compile hexadecimal string |
| `,b` | `val --` | Compile binary string |
| `,f` | `val --` | Compile fixed-point string |
| `,ifp` | `i --` | Compile integer as float32 |
| `,ffp` | `f --` | Compile fixed as float32 |

### Special Characters

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `,cr` | `--` | Compile carriage return |
| `,eol` | `--` | Compile null terminator |
| `,sp` | `--` | Compile space |
| `,nl` | `--` | Compile newline (CRLF) |
| `,nsp` | `n --` | Compile N spaces |

### Memory Operations

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `savemem` | `"" --` | Save memory to file |
| `sizemem` | `-- size` | Get memory size used |
| `memsize` | `-- mem size` | Get memory address and size |
| `savememinc` | `"" --` | Append to file |
| `cpymem` | `'destino --` | Copy memory |
| `appendmem` | `"" --` | Append memory to file |

### Formatted Output to Memory

**Format codes** (used by `sprint`, `,print`, etc.):

- `%d` — Decimal number
- `%h` — Hexadecimal
- `%b` — Binary
- `%s` — String from address
- `%f` — Fixed-point (4 decimal)
- `%m` — Fixed-point (2 decimal)
- `%a` — Fixed-point (1 decimal)
- `%w` — Word (until space)
- `%k` — Character
- `%l` — Line (until CR/LF)
- `%i` — Integer part of fixed
- `%j` — Fractional part of fixed
- `%o` — Octal
- `%.` — CR (end line)
- `%%` — Literal %

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `,print` | `p p .. "" --` | Format and compile to HERE |
| `sprint` | `p p .. "" -- adr` | Format to buffer |
| `sprintln` | `p p .. "" -- adr` | Format to buffer with newline |
| `sprintc` | `p p .. "" -- adr c` | Format and return with count |
| `sprintlnc` | `p p .. "" -- adr c` | Format with newline and count |

---

## Library: core.r3

Include with `^r3/lib/core.r3`

**Operating system interface (Windows / Linux).**

### Time and Sleep

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `ms` | `ms --` | Sleep for ms milliseconds |
| `msec` | `-- ms` | Milliseconds since program start |
| `time` | `-- hms` | Current time packed (bits 23:16=H, 15:8=M, 7:0=S) |
| `date` | `-- ymd` | Current date packed (bits 31:16=Y, 15:8=M, 7:0=D) |
| `sysdate` | `-- 'dt` | Pointer to system date/time structure |

### Time/Date Unpacking

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `date.y` / `time.h` | `ymd/hms -- year/hours` | Extract year or hours |
| `date.m` / `time.m` | `ymd/hms -- month/minutes` | Extract month or minutes |
| `date.d` / `time.ms` | `ymd/hms -- day/milliseconds` | Extract day or milliseconds |
| `date.dw` / `time.s` | `ymd/hms -- dayofweek/seconds` | Extract day of week or seconds |

### File System — Finding Files

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `ffirst` | `"path/*" -- fdd/0` | Find first matching file |
| `fnext` | `-- fdd/0` | Find next matching file |
| `findata` | `-- 'fdd` | Pointer to current find data structure |

### File Data Access

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `FNAME` | `fdd -- adrname` | Filename string (offset +44) |
| `FDIR` | `fdd -- 1/0` | Is this entry a directory? |
| `FSIZEF` | `fdd -- bytes` | File size in bytes |
| `FCREADT` | `fdd -- 'ft` | Pointer to creation date/time |
| `FLASTDT` | `fdd -- 'ft` | Pointer to last access date/time |
| `FWRITEDT` | `fdd -- 'ft` | Pointer to last write date/time |

### File Operations

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `load` | `'from "file" -- 'to` | Load file into memory, return end address |
| `save` | `'from cnt "file" --` | Save cnt bytes from address to file |
| `append` | `'from cnt "file" --` | Append cnt bytes to file |
| `delete` | `"file" --` | Delete file |
| `filexist` | `"file" -- 0/1` | Check if file exists |
| `fileinfo` | `"file" -- 0/1` | Fill file info structure |
| `fileisize` | `-- size` | File size from last fileinfo |
| `filecreatetime` | `-- 'ft` | Creation time pointer |
| `filelastactime` | `-- 'ft` | Last access time pointer |
| `filelastwrtime` | `-- 'ft` | Last write time pointer |

### Process Execution

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `sys` | `"cmd" --` | Execute program and wait for it |
| `sysnew` | `"cmd" --` | Execute program in new console |

---

## Library: console.r3

Include with `^r3/lib/console.r3`

**Terminal handling, ANSI output, and keyboard input.**

All output is buffered. Call `.flush` to send to stdout, or use `.println` which flushes automatically.

### Output Buffer

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `.cl` | `--` | Clear output buffer |
| `.flush` | `--` | Send buffer to stdout |
| `.emit` | `char --` | Add single character to buffer |
| `.type` | `str cnt --` | Add string of length cnt to buffer |
| `.write` | `str --` | Add null-terminated string to buffer |
| `.print` | `p.. "fmt" --` | Format and add to buffer |
| `.println` | `p.. "fmt" --` | Format, add to buffer, then `.cr` and `.flush` |
| `.cr` | `--` | Add CRLF to buffer |
| `.sp` | `--` | Add space to buffer |
| `.nch` | `char n --` | Add n copies of char to buffer |

### Cursor Control

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `.home` | `--` | Move cursor to home position |
| `.cls` | `--` | Clear screen and move cursor to home |
| `.at` | `x y --` | Position cursor at column `x` and row `y` |
| `.col` | `x --` | Move cursor to specific column `x` |
| `.eline` | `--` | Erase line from cursor to end |
| `.ealine` | `--` | Erase the entire current line |
| `.escreen` | `--` | Erase from cursor to end of screen |
| `.showc` / `.hidec` | `--` | Show or hide the terminal cursor |
| `.savec` / `.restorec` | `--` | Save or restore the current cursor position |

### Colors & Text Attributes

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `.Black` to `.White` | `--` | Set standard foreground colors |
| `.fc` | `n --` | Set foreground color using 256-color palette |
| `.bc` | `n --` | Set background color using 256-color palette |
| `.fgrgb` | `r g b --` | Set True Color (RGB) foreground |
| `.bgrgb` | `r g b --` | Set True Color (RGB) background |
| `.Bold` / `.Dim` | `--` | Set text intensity |
| `.Under` / `.Reset` | `--` | Set underline or reset all attributes |

### Input Handling

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `inkey` | `-- key` | 0 if no key pressed |
| `getch` | `-- key` | Wait for and return the keycode of a pressed key |
| `waitkey` | `--` | Wait for any keypress |
| `waitesc` | `--` | Wait specifically for the ESC key |
| `.input` | `--` | Start an interactive input line with echo (result in `##pad`) |

---

## Library: sdl2.r3

Include with `^r3/lib/sdl2.r3`

### Window Management

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `::SDLinit` | `"title" w h --` | Open window, w×h pixels |
| `::SDLfull` | `--` | Switch to fullscreen |
| `::SDLquit` | `--` | Close window and quit |
| `::SDLcls` | `color --` | Clear screen with color ($RRGGBB) |
| `::SDLredraw` | `--` | Flip display buffer (show frame) |
| `::SDLshow` | `'word --` | Run word every frame until `exit` |
| `::exit` | `--` | Stop the `SDLshow` loop |

### Input Variables

| Variable | Description |
|----------|-------------|
| `##SDLkey` | Code of currently pressed key (0 = none) |
| `##SDLchar` | Character code of pressed key |
| `##SDLx` | Mouse cursor X position |
| `##SDLy` | Mouse cursor Y position |
| `##SDLb` | Mouse button state (0 = none) |

### Key Code Constants

| Code | Event |
|------|-------|
| `>esc<` | Escape key pressed |
| `>le<` | Left arrow pressed |
| `>ri<` | Right arrow pressed |
| `>up<` | Up arrow pressed |
| `>dn<` | Down arrow pressed |
| `<le>` | Left arrow held |
| `<ri>` | Right arrow held |
| `<up>` | Up arrow held |
| `<dn>` | Down arrow held |

### Minimal Game Loop

```forth
^r3/lib/sdl2.r3

:update
    SDLkey >esc< =? ( exit ) drop
    0 SDLcls
    SDLredraw ;

: "My Window" 640 480 SDLinit
  'update SDLshow
  SDLquit ;
```

---

## Library: sdl2gfx.r3

Include with `^r3/lib/sdl2gfx.r3`

### Color

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `::SDLColor` | `col --` | Set drawing color ($RRGGBB) |

### Drawing Primitives

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `::SDLPoint` | `x y --` | Draw pixel |
| `::SDLLine` | `x1 y1 x2 y2 --` | Draw line |
| `::SDLFRect` | `x y w h --` | Filled rectangle |
| `::SDLRect` | `x y w h --` | Rectangle outline |
| `::SDLFCircle` | `r x y --` | Filled circle |
| `::SDLCircle` | `r x y --` | Circle outline |
| `::SDLFEllipse` | `rx ry x y --` | Filled ellipse |
| `::SDLEllipse` | `rx ry x y --` | Ellipse outline |
| `::SDLFRound` | `r x y w h --` | Filled rounded rectangle |
| `::SDLRound` | `r x y w h --` | Rounded rectangle outline |
| `::SDLTriangle` | `x1 y1 x2 y2 x3 y3 --` | Filled triangle |

### Images

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `::SDLimagewh` | `img -- w h` | Get image dimensions |
| `::SDLImage` | `x y img --` | Draw image at position |
| `::SDLImages` | `x y w h img --` | Draw image scaled to w×h |
| `::SDLImageb` | `box img --` | Draw image in box |
| `::SDLImagebb` | `srcbox dstbox img --` | Draw sub-region of image |
| `::SDLspriteZ` | `x y zoom img --` | Draw image with zoom |
| `::SDLSpriteR` | `x y ang img --` | Draw image with rotation (turns) |
| `::SDLspriteRZ` | `x y ang zoom img --` | Draw image with rotation and zoom |

### Tile Sheets

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `::tsload` | `w h "file" -- ts` | Load image as tile sheet (w×h per tile) |
| `::tscolor` | `$rrggbb 'ts --` | Tint tile sheet |
| `::tsdraw` | `n 'ts x y --` | Draw tile n at position |
| `::tsdraws` | `n 'ts x y w h --` | Draw tile n scaled |

### Sprite Sheets

Sprites are drawn **centered** on the given coordinates.

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `::ssload` | `w h "file" -- ss` | Load image as sprite sheet |
| `::ssprite` | `x y n ss --` | Draw sprite n centered at x,y |
| `::sspriter` | `x y ang n ss --` | Draw sprite n with rotation |
| `::sspritez` | `x y zoom n ss --` | Draw sprite n with zoom |
| `::sspriterz` | `x y ang zoom n ss --` | Draw sprite n with rotation and zoom |

---

## Library: sdl2image.r3

Include with `^r3/lib/sdl2image.r3`

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `::loadimg` | `"file" -- img` | Load PNG (with alpha) or JPG (no alpha) |
| `::unloadimg` | `img --` | Free image from memory |

---

## Usage Examples

### Basic Stack Operations
```forth
5 3 +           | Result: 8
10 dup *        | Result: 100
a b + c *       | Result: (a+b)*c
```

### Conditionals
```forth
x 5 >? ( "Greater" .print )
  0? ( "Zero" .print )
  +? ( "Positive" .print )
drop
```

### Loops
```forth
| Countdown
10 ( 1? 1-
    dup process
) drop

| Count-up
0 ( 10 <?
    dup process
    1+
) drop
```

### Memory Operations
```forth
| Store and fetch
100 'variable !
variable        | same as 'variable @

| Array traversal
'array >a
100 ( 1? 1-
    a@+ process
) drop
```

### String Operations
```forth
"hello" "world" strcpy
"prefix" adr =pre 1? ( "yes" .print )
"file.txt" ".txt" =pos 1? ( "yes" .print )
```

### Fixed-Point Math
```forth
1.5 2.0 *.      | Multiply: 3.0
10.0 3.0 /.     | Divide: 3.333...
0.25 sin        | sin(90°) = 1.0
```

### Random Numbers
```forth
time msec rerand    | Initialize
100 randmax         | 0-99
10.0 randmax        | 0.0-10.0
-5.0 5.0 randminmax | -5.0 to 5.0
```

### File Operations
```forth
| Load file
'buffer "data.txt" load  | TOS = end address on 'buffer

| Save file
'buffer 1024 "output.txt" save

| Find files
"*.r3" ffirst ( 1?
    dup FNAME .println
    fnext
) drop
```

### Memory Buffer
```forth
mark
HERE 1000 + 'HERE !  | Allocate 1KB
... use memory ...
empty                 | Release
```

### Formatted Output
```forth
42 255 "Value: %d Hex: %h" sprint
| Result: "Value: 42 Hex: ff"
```

### Terminal Example
```forth
| Clear screen and print colored text
.cls
.Red "Error:" .print .Reset " File not found." .println

| Position cursor and use RGB
10 5 .at
255 200 0 .fgrgb "Warning" .println

| Wait for user
"Press any key to continue..." .write .flush
waitkey
```

### Formatted Console Output
```forth
| Print formatted values directly to terminal
42 $FF "The answer is %d (hex: %h)" .println
```

---

## Notes

- **Stack notation:** `before -- after`
- **Conditionals:** Always paired with `( )` blocks
- **TOS:** Top Of Stack (last value pushed)
- **NOS:** Next Of Stack (second value)
- **Registers A and B:** Persist across word calls — save with `AB[` / `]BA` when needed
- **Memory cells:** 64-bit (8 bytes) by default
- **Fixed-point:** 48.16 format (48 integer bits, 16 fractional)
- **Angles:** Specified in turns (0.0–1.0 = 0°–360°)

---

## Glossary

| Term | Definition |
|------|------------|
| **Concatenative** | A language where programs are composed by sequencing functions |
| **Postfix notation** | Operators follow operands: `5 3 +` instead of `5 + 3` |
| **Stack effect** | Description of how a word changes the data stack, written as `before -- after` |
| **Factoring** | Breaking code into smaller, reusable named words |
| **TOS** | Top Of Stack — the most recently pushed value |
| **NOS** | Next Of Stack — the second-most recently pushed value |
| **Tail call** | A word call as the last operation before `;`, compiled as a jump (no stack growth) |
| **Register** | Fast auxiliary storage; A and B in R3forth, persist across calls |
| **Cell** | One memory unit: 8 bytes / 64 bits in R3forth |
| **Word** | A named code or data definition |
| **Dictionary** | The complete collection of defined words, searched last-to-first |
| **Prefix** | The first character of a token, determining how it is interpreted |
| **qword** | 64-bit value (default cell size) |
| **dword** | 32-bit value |
| **word (memory)** | 16-bit value |
| **byte** | 8-bit value |
| **Turn** | Angle unit: 1.0 = full circle, 0.5 = 180°, 0.25 = 90° |
| **48.16** | R3forth fixed-point format: 48 integer bits + 16 fractional bits in a 64-bit cell |
| **Fall-through** | A definition without `;` that continues executing into the next definition |
| **HERE** | Variable pointing to the next free memory address |
| **MARK / EMPTY** | Stack-based dynamic allocator: MARK saves HERE, EMPTY restores it |

---

*R3forth Reference — see the companion Tutorial document for explanations and examples.*
