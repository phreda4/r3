# R3forth Word Reference

Complete reference of base dictionary and core libraries.

---

## Base Dictionary

### Control Flow

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `;` | `--` | End word execution |
| `(` | `--` | Start block for IF or WHILE |
| `)` | `--` | End block for IF or WHILE |
| `[` | `-- v` | Start nameless definition |
| `]` | `v --` | End nameless definition |
| `EX` | `v --` | Execute word from address |

### Conditionals

#### Stack-Only Tests (don't consume)
| Word | Stack Effect | Description |
|------|--------------|-------------|
| `0?` | `a -- a` | True if TOS = 0 |
| `1?` | `a -- a` | True if TOS ≠ 0 |
| `+?` | `a -- a` | True if TOS ≥ 0 |
| `-?` | `a -- a` | True if TOS < 0 |

#### Comparisons (consume TOS only)
| Word | Stack Effect | Description |
|------|--------------|-------------|
| `<?` | `a b -- a` | True if a < b (removes TOS) |
| `>?` | `a b -- a` | True if a > b (removes TOS) |
| `=?` | `a b -- a` | True if a = b (removes TOS) |
| `>=?` | `a b -- a` | True if a ≥ b (removes TOS) |
| `<=?` | `a b -- a` | True if a ≤ b (removes TOS) |
| `<>?` | `a b -- a` | True if a ≠ b (removes TOS) |
| `AND?` | `a b -- c` | True if a AND b (removes TOS) |
| `NAND?` | `a b -- c` | True if a NAND b (removes TOS) |
| `IN?` | `a b c -- a` | True if b ≤ a ≤ c (removes 2TOS) |

### Stack Operations

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `DUP` | `a -- a a` | Duplicate TOS |
| `DROP` | `a --` | Remove TOS |
| `OVER` | `a b -- a b a` | Duplicate second of stack |
| `PICK2` | `a b c -- a b c a` | Pick 3rd element |
| `PICK3` | `a b c d -- a b c d a` | Pick 4th element |
| `PICK4` | `a b c d e -- a b c d e a` | Pick 5th element |
| `SWAP` | `a b -- b a` | Swap TOS and NOS |
| `NIP` | `a b -- b` | Remove NOS |
| `ROT` | `a b c -- b c a` | Rotate 3 elements |
| `-ROT` | `a b c -- c a b` | Rotate 3 elements reverse |
| `2DUP` | `a b -- a b a b` | Duplicate 2 top values |
| `2DROP` | `a b --` | Remove 2 elements |
| `3DROP` | `a b c --` | Remove 3 elements |
| `4DROP` | `a b c d --` | Remove 4 elements |
| `2OVER` | `a b c d -- a b c d a b` | Copy 2 lower elements |
| `2SWAP` | `a b c d -- c d a b` | Swap 4 elements |

### Return Stack

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `>R` | `a -- (r: -- a)` | Push to return stack |
| `R>` | `-- a (r: a --)` | Pop from return stack |
| `R@` | `-- a (r: a -- a)` | Copy top of return stack |

### Logic Operators

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `AND` | `a b -- c` | c = a AND b |
| `OR` | `a b -- c` | c = a OR b |
| `XOR` | `a b -- c` | c = a XOR b |
| `NOT` | `a -- b` | b = NOT a |
| `NAND` | `a b -- c` | c = NOT (a AND b) |

### Arithmetic Operators

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `+` | `a b -- c` | c = a + b |
| `-` | `a b -- c` | c = a - b |
| `*` | `a b -- c` | c = a × b |
| `/` | `a b -- c` | c = a ÷ b (integer) |
| `<<` | `a b -- c` | c = a shift left b |
| `>>` | `a b -- c` | c = a shift right b (signed) |
| `>>>` | `a b -- c` | c = a shift right b (unsigned) |
| `MOD` | `a b -- c` | c = a mod b |
| `/MOD` | `a b -- c d` | c = a÷b, d = a mod b |
| `*/` | `a b c -- d` | d = (a×b)÷c (no bit loss) |
| `*>>` | `a b c -- d` | d = (a×b)>>c (no bit loss) |
| `<</` | `a b c -- d` | d = (a<<c)÷b (no bit loss) |
| `NEG` | `a -- b` | b = -a |
| `ABS` | `a -- b` | b = \|a\| |
| `SQRT` | `a -- b` | b = √a (integer) |
| `CLZ` | `a -- b` | b = count leading zeros |

### Memory Fetch and Store

#### Qword (64-bit) Operations
| Word | Stack Effect | Description | Increment |
|------|--------------|-------------|-----------|
| `@` | `a -- [a]` | Fetch qword | - |
| `@+` | `a -- b [a]` | Fetch qword and increment | +8 |
| `!` | `a b --` | Store A at address B | - |
| `!+` | `a b -- c` | Store A at B and increment | +8 |
| `+!` | `a b --` | Add A to value at address B | - |

#### Dword (32-bit) Operations
| Word | Stack Effect | Description | Increment |
|------|--------------|-------------|-----------|
| `D@` | `a -- dword[a]` | Fetch dword | - |
| `D@+` | `a -- b dword[a]` | Fetch dword and increment | +4 |
| `D!` | `a b --` | Store dword A at address B | - |
| `D!+` | `a b -- c` | Store dword A at B and increment | +4 |
| `D+!` | `a b --` | Add A to dword at address B | - |

#### Word (16-bit) Operations
| Word | Stack Effect | Description | Increment |
|------|--------------|-------------|-----------|
| `W@` | `a -- word[a]` | Fetch word | - |
| `W@+` | `a -- b word[a]` | Fetch word and increment | +2 |
| `W!` | `a b --` | Store word A at address B | - |
| `W!+` | `a b -- c` | Store word A at B and increment | +2 |
| `W+!` | `a b --` | Add A to word at address B | - |

#### Byte (8-bit) Operations
| Word | Stack Effect | Description | Increment |
|------|--------------|-------------|-----------|
| `C@` | `a -- byte[a]` | Fetch byte | - |
| `C@+` | `a -- b byte[a]` | Fetch byte and increment | +1 |
| `C!` | `a b --` | Store byte A at address B | - |
| `C!+` | `a b -- c` | Store byte A at B and increment | +1 |
| `C+!` | `a b --` | Add A to byte at address B | - |

### Auxiliary Registers

#### Register A
| Word | Stack Effect | Description | Increment |
|------|--------------|-------------|-----------|
| `>A` | `a --` | Load register A | - |
| `A>` | `-- a` | Push register A | - |
| `A+` | `a --` | Add to register A | - |
| `A@` | `-- a` | Fetch qword from A | - |
| `A!` | `a --` | Store qword at A | - |
| `A@+` | `-- a` | Fetch qword from A and increment | +8 |
| `A!+` | `a --` | Store qword at A and increment | +8 |
| `CA@` | `-- a` | Fetch byte from A | - |
| `CA!` | `a --` | Store byte at A | - |
| `CA@+` | `-- a` | Fetch byte from A and increment | +1 |
| `CA!+` | `a --` | Store byte at A and increment | +1 |
| `DA@` | `-- a` | Fetch dword from A | - |
| `DA!` | `a --` | Store dword at A | - |
| `DA@+` | `-- a` | Fetch dword from A and increment | +4 |
| `DA!+` | `a --` | Store dword at A and increment | +4 |

#### Register B
| Word | Stack Effect | Description | Increment |
|------|--------------|-------------|-----------|
| `>B` | `a --` | Load register B | - |
| `B>` | `-- a` | Push register B | - |
| `B+` | `a --` | Add to register B | - |
| `B@` | `-- a` | Fetch qword from B | - |
| `B!` | `a --` | Store qword at B | - |
| `B@+` | `-- a` | Fetch qword from B and increment | +8 |
| `B!+` | `a --` | Store qword at B and increment | +8 |
| `CB@` | `-- a` | Fetch byte from B | - |
| `CB!` | `a --` | Store byte at B | - |
| `CB@+` | `-- a` | Fetch byte from B and increment | +1 |
| `CB!+` | `a --` | Store byte at B and increment | +1 |
| `DB@` | `-- a` | Fetch dword from B | - |
| `DB!` | `a --` | Store dword at B | - |
| `DB@+` | `-- a` | Fetch dword from B and increment | +4 |
| `DB!+` | `a --` | Store dword at B and increment | +4 |

#### Register Save/Restore
| Word | Stack Effect | Description |
|------|--------------|-------------|
| `AB[` | `--` | Save A and B to return stack |
| `]BA` | `--` | Restore B and A from return stack |

### Memory Copy and Fill

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `MOVE` | `d s c --` | Copy S to D, C qwords |
| `MOVE>` | `d s c --` | Copy S to D, C qwords reverse |
| `FILL` | `d v c --` | Fill D, C qwords with V |
| `CMOVE` | `d s c --` | Copy S to D, C bytes |
| `CMOVE>` | `d s c --` | Copy S to D, C bytes reverse |
| `CFILL` | `d v c --` | Fill D, C bytes with V |
| `DMOVE` | `d s c --` | Copy S to D, C dwords |
| `DMOVE>` | `d s c --` | Copy S to D, C dwords reverse |
| `DFILL` | `d v c --` | Fill D, C dwords with V |

### Operating System

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `MEM` | `-- a` | Start of free memory |
| `LOADLIB` | `"name" -- liba` | Load dynamic library |
| `GETPROC` | `liba "name" -- aa` | Get function address |
| `SYS0` | `aa -- r` | Call function with 0 parameters |
| `SYS1` | `a aa -- r` | Call function with 1 parameter |
| `SYS2` | `a b aa -- r` | Call function with 2 parameters |
| ... | ... | ... up to SYS10 |

---

## Library: math.r3

**Fixed-point arithmetic and mathematical functions**

### Basic Size Operations

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `cell+` | `a -- a+8` | Add cell size (8 bytes) |
| `ncell+` | `n a -- a+n*8` | Add n cells |
| `1+` | `a -- a+1` | Increment by 1 |
| `1-` | `a -- a-1` | Decrement by 1 |
| `2/` | `a -- a/2` | Divide by 2 (shift right) |
| `2*` | `a -- a*2` | Multiply by 2 (shift left) |

### Fixed Point Operations (48.16 format)

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `*.` | `a b -- c` | Multiply fixed-point (full precision) |
| `*.s` | `a b -- c` | Multiply fixed-point (small numbers) |
| `*.f` | `a b -- c` | Multiply fixed-point (full adjust) |
| `/.` | `a b -- c` | Divide fixed-point |
| `2/.` | `a -- a/2` | Divide by 2 with adjustment |
| `ceil` | `a -- a` | Ceiling (round up) |
| `int.` | `f -- n` | Convert to integer (f >> 16) |
| `fix.` | `n -- f` | Convert to fixed-point (n << 16) |
| `sign` | `v -- v s` | Get value and sign |

### Trigonometric Functions

**Angles in turns: 0.0 = 0°, 0.25 = 90°, 0.5 = 180°, 1.0 = 360°**

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `cos` | `bangle -- r` | Cosine (angle in turns) |
| `sin` | `bangle -- r` | Sine (angle in turns) |
| `tan` | `v -- f` | Tangent |
| `sincos` | `bangle -- sin cos` | Both sine and cosine |
| `atan2` | `x y -- bangle` | Arctangent (returns angle in turns) |

### Polar/Cartesian Conversion

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `xy+polar` | `x y bangle r -- x y` | Add polar offset to coordinates |
| `xy+polar2` | `x y r ang -- x y` | Add polar offset (r first) |
| `ar>xy` | `xc yc bangle r -- xc yc x y` | Polar to cartesian from center |
| `polar` | `bangle largo -- dx dy` | Convert polar to cartesian |
| `polar2` | `largo bangle -- dx dy` | Convert polar (length first) |

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
| `exp.` | `x -- r` | Exponential (e^x) |
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
| `clamps16` | `v -- v` | Clamp to signed 16-bit |
| `between` | `v min max -- flag` | Check if between min and max |
| `msb` | `n -- pos` | Most significant bit position |

### Special Functions

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `tanh.` | `x -- r` | Hyperbolic tangent |
| `fastanh.` | `x -- r` | Fast approximation of tanh |
| `cubicpulse` | `c w x -- v` | Cubic pulse function |

### Optimized Operations

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `10*` | `n -- n*10` | Multiply by 10 |
| `100*` | `n -- n*100` | Multiply by 100 |
| `1000*` | `n -- n*1000` | Multiply by 1000 |
| `10000*` | `n -- n*10000` | Multiply by 10000 |
| `100000*` | `n -- n*100000` | Multiply by 100000 |
| `1000000*` | `n -- n*1000000` | Multiply by 1000000 |
| `10/` | `n -- n/10` | Divide by 10 |
| `10/mod` | `n -- q r` | Divide by 10, get quotient and remainder |
| `1000000/` | `n -- n/1000000` | Divide by 1000000 |
| `6*` | `n -- n*6` | Multiply by 6 |
| `6/` | `n -- n/6` | Divide by 6 |
| `6mod` | `n -- n%6` | Modulo 6 |

### Bit Manipulation

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `bswap32` | `v -- vs` | Byte swap 32 bits |
| `bswap64` | `v -- vs` | Byte swap 64 bits |
| `nextpow2` | `v -- p2` | Next power of 2 |

### Float Conversion (IEEE 754)

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `i2fp` | `i -- fp` | Integer to float32 |
| `f2fp` | `f -- fp` | Fixed-point to float32 |
| `fp2f` | `fp -- f` | Float32 to fixed-point |
| `fp2i` | `fp -- i` | Float32 to integer |
| `fp16f` | `fp16 -- f` | Float16 to fixed-point |
| `f2fp24` | `f -- fp` | Fixed 40.24 to float32 |
| `fp2f24` | `fp -- f` | Float32 to fixed 40.24 |
| `byte>float32N` | `byte -- float` | Byte to normalized float (0-1) |
| `float32N>byte` | `f32 -- byte` | Normalized float to byte |

---

## Library: rand.r3

**Random number generation**

### Basic Random

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `rand` | `-- rand` | Generate random 64-bit number |
| `rerand` | `s1 s2 --` | Re-initialize random seed |
| `randmax` | `max -- rand` | Random from 0 to max-1 |
| `randminmax` | `min max -- rand` | Random from min to max |

### Xorshift Algorithm

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `rnd` | `-- rand` | Xorshift random |
| `rndmax` | `max -- rand` | Xorshift random 0 to max-1 |
| `rndminmax` | `min max -- rand` | Xorshift random min to max |

### Xorshift128+ Algorithm

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `rnd128` | `-- n` | Xorshift128+ random |

### LoopMix128 Algorithm

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `loopMix128` | `-- rand` | LoopMix128 random generator |

---

## Library: str.r3

**String manipulation**

### String Copy Operations

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `strcpyl` | `src des -- ndes` | Copy string, return new address |
| `strcpy` | `src des --` | Copy string |
| `strcat` | `src des --` | Concatenate strings |
| `strcpylnl` | `src des -- ndes` | Copy until newline |
| `strcpyln` | `src des --` | Copy until newline (no return) |
| `copynom` | `sc s1 --` | Copy until space |
| `copystr` | `sc s1 --` | Copy until quote (") |
| `strpath` | `src dst --` | Copy path only (needs /) |

### Character Conversion

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `toupp` | `c -- C` | To uppercase |
| `tolow` | `C -- c` | To lowercase |

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

### String Comparison

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `=` | `s1 s2 -- 1/0` | Compare strings (case-insensitive) |
| `cmpstr` | `a b -- n` | Compare strings (returns -/0/+) |
| `=s` | `s1 s2 -- 0/1` | Compare until space |
| `=w` | `s1 s2 -- 1/0` | Compare words |
| `=pre` | `adr "str" -- adr 1/0` | Check prefix |
| `=pos` | `s1 ".pos" -- s1 1/0` | Check suffix |
| `=lpos` | `lstr ".pos" -- str 1/0` | Check suffix from last address |

### String Search

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `findchar` | `adr char -- adr'/0` | Find character in string |
| `findstr` | `adr "texto" -- adr'/0` | Find substring |
| `findstri` | `adr "texto" -- adr'/0` | Find substring (case-insensitive) |

### Number to String Conversion

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `.d` | `val -- str` | Decimal to string |
| `.b` | `bin -- str` | Binary to string |
| `.h` | `hex -- str` | Hexadecimal to string |
| `.o` | `oct -- str` | Octal to string |
| `.f` | `fix -- str` | Fixed-point to string (4 decimals) |
| `.f2` | `fix -- str` | Fixed-point to string (2 decimals) |
| `.f1` | `fix -- str` | Fixed-point to string (1 decimal) |
| `.r.` | `b nro -- b` | Right-align with spaces |

### String Trimming

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `trim` | `adr -- adr'` | Trim leading whitespace |
| `trimc` | `car adr -- adr'` | Trim leading specific character |
| `trimcar` | `adr -- adr' c` | Trim and return first char |
| `trimstr` | `adr -- adr'` | Trim until quote |
| `>>cr` | `adr -- adr'` | Skip to CR/LF |
| `>>0` | `adr -- adr'` | Skip to null |
| `n>>0` | `adr n -- adr'` | Skip N nulls |
| `>>sp` | `adr -- adr'` | Skip to space |
| `>>str` | `adr -- adr'` | Skip to quote |

### String List Operations

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `l0count` | `list -- cnt` | Count null-terminated strings |
| `only13` | `adr -- 'adr` | Remove LF, keep only CR |

---

## Library: mem.r3

**Memory management and formatted output**

### Memory Management

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `mark` | `--` | Mark current free memory position |
| `empty` | `--` | Restore to last mark |
| `align32` | `mem -- mem` | Align to 32-byte boundary |
| `align16` | `mem -- mem` | Align to 16-byte boundary |
| `align8` | `mem -- mem` | Align to 8-byte boundary |

### Compile to Memory

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

**Format codes:**
- `%d` - Decimal number
- `%h` - Hexadecimal
- `%b` - Binary
- `%s` - String from address
- `%f` - Fixed-point
- `%w` - Word (until space)
- `%k` - Character
- `%l` - Line (until CR/LF)
- `%i` - Integer part of fixed
- `%j` - Fractional part of fixed
- `%o` - Octal
- `%.` - CR (end line)
- `%%` - Literal %

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `,print` | `p p .. "" --` | Format and compile to HERE |
| `sprint` | `p p .. "" -- adr` | Format to buffer |
| `sprintln` | `p p .. "" -- adr` | Format to buffer with newline |
| `sprintc` | `p p .. "" -- adr c` | Format and return with count |
| `sprintlnc` | `p p .. "" -- adr c` | Format with newline and count |

---

## Library: core.r3

**Operating system interface (Windows)**

### Time Functions

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `ms` | `ms --` | Sleep for milliseconds |
| `msec` | `-- msec` | Get milliseconds since start |
| `time` | `-- hms` | Get current time (packed: H:M:S) |
| `date` | `-- ymd` | Get current date (packed: Y/M/D) |
| `sysdate` | `-- 'dt` | Get system date structure |

### Time/Date Unpacking

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `date.d` / `time.ms` | `ymd/hms -- day/milliseconds` | Extract day or milliseconds |
| `date.dw` / `time.s` | `ymd/hms -- dayofweek/seconds` | Extract day of week or seconds |
| `date.m` / `time.m` | `ymd/hms -- month/minutes` | Extract month or minutes |
| `date.y` / `time.h` | `ymd/hms -- year/hours` | Extract year or hours |

### File System - File Finding

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `ffirst` | `"path//*" -- fdd/0` | Find first file
| `fnext` | `-- fdd/0` | Find next file |
| `findata` | `-- 'fdd` | Get find data structure |

### File Data Access

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `FNAME` | `adr -- adrname` | Get filename (offset +44) |
| `FDIR` | `adr -- 1/0` | Is directory? |
| `FSIZEF` | `adr -- sizebytes` | Get file size in bytes |
| `FCREADT` | `adr -- 'timedate` | Get creation date/time |
| `FLASTDT` | `adr -- 'timedate` | Get last access date/time |
| `FWRITEDT` | `adr -- 'timedate` | Get last write date/time |

### File Operations

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `load` | `'from "filename" -- 'to` | Load file to memory |
| `save` | `'from cnt "filename" --` | Save memory to file |
| `append` | `'from cnt "filename" --` | Append to file |
| `delete` | `"filename" --` | Delete file |
| `filexist` | `"file" -- 0/1` | Check if file exists |

### File Information

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `fileinfo` | `"file" -- 0/1` | Get file attributes |
| `fileisize` | `-- size` | Get file size from info |
| `fileijul` | `-- jul` | Get Julian date from file |
| `filecreatetime` | `-- 'ft` | Creation time pointer |
| `filelastactime` | `-- 'ft` | Last access time pointer |
| `filelastwrtime` | `-- 'ft` | Last write time pointer |

### Process Execution

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `sys` | `"" --` | Execute program and wait |
| `sysnew` | `"" --` | Execute in new console |
| `sysdebug` | `"" --` | Execute with debugger |

---

## Usage Examples

### Basic Stack Operations
```r3
5 3 +           | Result: 8
10 dup *        | Result: 100
a b + c *       | Result: (a+b)*c
```

### Conditionals
```r3
x 5 >? ( "Greater" print ) drop
x 0? ( "Zero" print )
  +? ( "Positive" print )
drop
```

### Loops
```r3
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
```r3
| Store and fetch
100 'variable !
variable @

| Array traversal
'array >a
100 ( 1? 1-
    a@+ process
) drop
```

### String Operations
```r3
"hello" "world" strcpy
"prefix" adr =pre
"file.txt" ".txt" =pos
```

### Fixed-Point Math
```r3
1.5 2.0 *.      | Multiply: 3.0
10.0 3.0 /.     | Divide: 3.333...
0.25 sin        | sin(90°) = 1.0
```

### Random Numbers
```r3
time msec rerand    | Initialize
100 randmax         | 0-99
10.0 randmax        | 0.0-9.999...
-5.0 5.0 randminmax | -5.0 to 5.0
```

### File Operations
```r3
| Load file
'buffer "data.txt" load

| Save file
'buffer 1024 "output.txt" save

| Find files
"*.r3" ffirst ( 1?
    dup FNAME print cr
    fnext
) drop
```

### Memory Buffer
```r3
mark
HERE 1000 + 'HERE !  | Allocate 1KB
... use memory ...
empty                | Release
```

### Formatted Output
```r3
42 255 "Value: %d Hex: %h" sprint
| Result: "Value: 42 Hex: ff"
```

---

## Notes

- **Stack notation:** `before -- after`
- **Conditionals:** Always paired with `( )` blocks
- **TOS:** Top Of Stack (last value pushed)
- **NOS:** Next Of Stack (second value)
- **Registers A and B:** Not preserved across calls
- **Memory cells:** 64-bit (8 bytes) by default
- **Fixed-point:** 48.16 format (48 integer bits, 16 fractional)
- **Angles:** Specified in turns (0.0-1.0 = 0°-360°)

---

**Repository:** https://github.com/phreda4/r3</parameter>