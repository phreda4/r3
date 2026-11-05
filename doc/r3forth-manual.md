# R3forth — Manual

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

- Words are case-insensitive
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
13. [Libraries](#libraries)
14. [Usage Examples](#usage-examples)
15. [Glossary](#glossary)

---

## Control Flow

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `;` | `--` | End word execution, return to caller |
| `(` | `--` | Begin block: IF body or WHILE loop (see Tutorial → Repetition) |
| `)` | `--` | End code block |
| `[` | `-- a` | Begin anonymous word definition |
| `]` | `-- a` | End anonymous word definition |
| `EX` | `a --` | Execute word by address |

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
| `NAND?` | `a b -- a` | a AND b = 0 |
| `IN?` | `a b c -- a` | b ≤ a ≤ c (consumes both b and c) |

### Conditional Usage Pattern

```forth
value
?? ( block-if-true )        | ?? is any conditional word: 0? 1? =? <? ...
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
| `NAND` | `a b -- c` | c = a AND NOT b (clears the bits of b) |

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
| `MARK` | `--` | save here on the memory stack (64 levels at most); undo it with empty |
| `EMPTY` | `--` | restore here to the last mark and drop it (to the start of free memory if none) |

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

## Libraries

#### Contents

### lib/ — Core Libraries
1. [math.r3](#mathr3) — Fixed-point math, trig, float conversion
2. [dmath.r3](#dmathr3) — Double-precision (32.32) math
3. [str.r3](#strr3) — String operations
4. [mem.r3](#memr3) — Heap memory and formatted output
5. [core.r3](#corer3) — Time, files, directories and processes
6. [parse.r3](#parser3) — String parsing and number parsing
7. [rand.r3](#randr3) — Random number generators
8. [vec2.r3](#vec2r3) — 2D vector operations
9. [vec3.r3](#vec3r3) — 3D vector and quaternion operations
10. [color.r3](#colorr3) — Color space conversions and blending
11. [jul.r3](#julr3) — Julian date calculations
12. [console.r3](#consoler3) — Terminal I/O with ANSI colors
13. [trace.r3](#tracer3) — Debug tracing tools
14. [crc32.r3](#crc32r3) — Checksums (CRC32, Adler32)
15. [base64.r3](#base64r3) — Base64 encode/decode
16. [sdl2.r3](#sdl2r3) — SDL2 window, renderer, events (cross-platform base)
17. [sdl2gfx.r3](#sdl2gfxr3) — SDL2 drawing primitives and sprites
18. [sdl2image.r3](#sdl2imager3) — SDL2_image: PNG/JPG/SVG loading
19. [sdl2ttf.r3](#sdl2ttfr3) — SDL2_ttf: TrueType font rendering
20. [sdl2mixer.r3](#sdl2mixerr3) — SDL2_mixer: audio playback
21. [sdl2net.r3](#sdl2netr3) — SDL2_net: TCP/UDP networking
22. [sdl2poly.r3](#sdl2polyr3) — Polygon and thick-line drawing
23. [sdl2gl.r3](#sdl2glr3) — OpenGL access via SDL2
24. [sdlkeys.r3](#sdlkeysr3) — SDL2 keyboard constants
25. [gui.r3](#guir3) — Base immediate-mode GUI (SDL2)
26. [input.r3](#inputr3) — Text input widget
27. [3d.r3](#3dr3) — 3D camera and projection
28. [3dgl.r3](#3dglr3) — 4×4 matrix stack for OpenGL
29. [isospr.r3](#isosprr3) — Isometric sprite rendering
30. [vdraw.r3](#vdrawr3) — Virtual (pixel-callback) drawing
31. [memshare.r3](#memsharer3) — Cross-process shared memory
32. [memavx.r3](#memavxr3) — AVX-accelerated buffer conversion |WIN|
33. [netsock.r3](#netsockr3) — High-level socket wrapper
34. [webcam.r3](#webcamr3) — Webcam capture (cross-platform)
35. [glutil.r3](#glutilr3) — OpenGL utility helpers
36. [onnx.r3](#onnxr3) — ONNX runtime bindings |WIN|
37. [tflite.r3](#tfliter3) — TensorFlow Lite bindings |WIN|
38. [sdl2gl-const.r3](#sdl2gl-constr3) — OpenGL constants (included by sdl2gl.r3)
39. [sdl2gl-constv.r3](#sdl2gl-constvr3) — OpenGL constants, extended set
40. [clipboard.r3](#clipboardr3) — Clipboard (platform-provided)

### lib/win/ — Windows System Bindings
41. [win/kernel32.r3](#winkernel32r3) — Win32 API bindings
42. [win/clipboard.r3](#winclipboardr3) — Win32 clipboard
43. [win/win-term.r3](#winwin-termr3) — Windows console terminal
44. [win/inet.r3](#wininetr3) — WinInet HTTP download
45. [win/winhttp.r3](#winwinhttpr3) — WinHTTP HTTP client
46. [win/winsock.r3](#winwinsockr3) — Winsock2 raw bindings
47. [win/ws2.r3](#winws2r3) — Winsock2 with ws2- prefix
48. [win/urlmon.r3](#winurlmonr3) — URL download helper
49. [win/ffmpeg.r3](#winffmpegr3) — FFmpeg video playback |WIN|
50. [win/debugapi.r3](#windebugapir3) — Windows debug API

### lib/posix/ — Linux System Bindings
51. [posix/posix.r3](#posixposixr3) — POSIX syscall bindings
52. [posix/lin-term.r3](#posixlin-termr3) — Linux terminal

> **util/ libraries** (object pools, sorting, fonts, GUI, tile maps, etc.) are documented in `r3forth-util.md`.

---

## lib/ — Core Libraries

---

### math.r3

Fixed-point (48.16) arithmetic, trigonometry, statistics, and float32 conversion. Foundation library included by almost everything.

**No dependencies.**

#### Size Constants
```
##cell 8              -- cell size in bytes
```

#### Integer Helpers
```
::cell+ ( n -- n' )         add the cell size (8)
::ncell+ ( adr n -- adr' )  adr + n * 8 (address of cell n of a table)
::1+ ( n -- n+1 )           increment
::1- ( n -- n-1 )           decrement
::2/ ( n -- n/2 )           arithmetic shift right by 1 (rounds toward minus infinity)
::2* ( n -- n*2 )           shift left by 1
```

#### 48.16 Fixed-Point Arithmetic
All values with `.` suffix are 48.16 fixed-point (integer × 65536).
```
::*.s ( a b -- c )     fixed point multiply (a*b >> 16), only for small numbers: the product must fit in 64 bits
::*. ( a b -- c )      fixed point multiply (a*b >> 16 with a 128-bit product), rounds toward minus infinity
::*.f ( a b -- c )     like *. but rounds toward zero
::/. ( a b -- c )      fixed point divide ((a << 16) / b with a 128-bit intermediate)
::2/. ( a -- a/2 )     divide by 2 rounding toward zero
::ceil ( fix -- int )  round up to an integer
::int. ( fix -- int )  integer part (shift right 16, rounds toward minus infinity)
::fix. ( int -- fix )  integer to 48.16 fixed point (shift left 16)
::sign ( v -- v s )    s = 1 if v >= 0, -1 if v < 0
```

#### Trigonometry (binary angles)
Binary angle: `0`=0°, `0.25`=90°, `0.5`=180°, `1.0`≈360°. Results are 48.16 fixed-point in range -1.0..1.0.
```
::sin ( bangle -- r )                    sine of a binary angle (1.0 = full turn); r is fixed point -1.0..1.0
::cos ( bangle -- r )                    cosine of a binary angle (1.0 = full turn); r is fixed point -1.0..1.0
::tan ( bangle -- r )                    tangent of a binary angle (fixed point)
::sincos ( bangle -- sin cos )           sine and cosine (cos on top)
::atan2 ( x y -- bangle )                angle of the vector (x,y) as binary angle: 0 for +x, 0.25 for +y; fast, low precision
::polar ( bangle len -- dx dy )          dx = sin*len, dy = cos*len
::polar2 ( len bangle -- dx dy )         like polar with len and bangle swapped
::xy+polar ( x y bangle r -- x' y' )     move the point by r in the direction bangle: x += sin*r, y += cos*r
::xy+polar2 ( x y r bangle -- x' y' )    like xy+polar with r and bangle swapped
::ar>xy ( xc yc bangle r -- xc yc x y )  point at distance r and direction bangle from the center xc yc (the center is kept)
```

#### Distance and Geometry
```
::distfast ( dx dy -- dist )  approximate distance: max*31/32 + min*3/8 (rough for small integers)
::average ( x y -- v )        (x+y)/2 rounded down, without overflow
```

#### Min/Max/Clamp
```
::min ( a b -- m )            the smaller one
::max ( a b -- m )            the larger one
::clampmax ( v max -- v )     v limited to at most max
::clampmin ( v min -- v )     v limited to at least min
::clamp0 ( v -- v )           v limited to at least 0
::clamp0max ( v max -- v )    v limited to 0..max
::clamps16 ( v -- v )         v limited to -32768..32767
::between ( v min max -- n )  n < 0 if v is outside min..max, n >= 0 if inside
```

#### Advanced Math
```
::msb ( x -- n )             index (0-63) of the most significant bit; undefined for 0
::sqrt. ( x -- r )           square root of a fixed point number (0 if x <= 0)
::log2. ( y -- r )           base 2 logarithm of a fixed point number (0 if y <= 0)
::pow2. ( y -- r )           2 to the power y (fixed point)
::pow. ( x y -- r )          x to the power y (fixed point; 0 if x = 0)
::root. ( x n -- r )         nth root of x (fixed point); n is fixed point too: 3.0 for the cube root
::ln. ( x -- r )             natural logarithm (fixed point)
::exp. ( x -- r )            e to the power x (fixed point)
::tanh. ( x -- r )           hyperbolic tangent (fixed point)
::fastanh. ( x -- r )        fast approximation of tanh (piecewise polynomial)
::gamma. ( x -- r )          gamma function, approximation (fixed point)
::beta. ( x y -- r )         beta function, approximation (fixed point; 0 if x or y < 0)
::cubicpulse ( c w x -- v )  smooth bump (Inigo Quilez): 1.0 at x = c, 0 when |x-c| >= w (fixed point)
::pow ( base exp -- r )      integer power (exp >= 0)
```

#### Bit Utilities
```
::bswap32 ( v -- vs )   swap the 4 low bytes; the upper bits of the result are garbage (mask with $ffffffff)
::bswap64 ( v -- vs )   swap the 8 bytes
::nextpow2 ( v -- p2 )  smallest power of 2 that is >= v (0 for 0)
```

#### Integer Multiply/Divide Shortcuts
```
::6*  ::6/  ::6mod ::10* :10/  ::10/mod 
```

#### Float32 Conversions
```
::i2fp ( i -- fp )                 integer to float32 bits (in the low 32 bits)
::f2fp ( fix -- fp )               48.16 fixed point to float32 bits (in the low 32 bits)
::fp2f ( fp -- fix )               float32 bits to 48.16 fixed point; negative values need fp sign-extended to 64 bits (as d@ reads it)
::fp2i ( fp -- int )               float32 bits to integer, truncated; negative values need fp sign-extended like in fp2f
::fp16f ( fp16 -- fix )            half float (16 bits) to 48.16 fixed point; negative values need the 16 bits sign-extended (as w@ reads it)
::f2fp24 ( f -- fp )               40.24 fixed point to float32 bits
::fp2f24 ( fp -- f )               float32 bits to 40.24 fixed point; negative values need fp sign-extended like in fp2f
::byte>float32N ( byte -- float )  byte 0..255 to float32 normalized 0..1
::float32N>byte ( f32 -- byte )    float32 normalized 0..1 to byte 0..255, rounded (negative gives 0, >= 1.0 gives 255)
```

---

```
::ndword+ ( adr n -- adr' )          adr + n * 4 (address of dword n of a table)
::nword+ ( adr n -- adr' )           adr + n * 2 (address of word n of a table)
::dir2vec ( dx dy -- vx vy )         unit vector (length 1.0, fixed point) of the direction dx dy; 0 0 gives 0 0
::sdir2vec ( scale dx dy -- vx vy )  like dir2vec multiplied by scale (fixed point)
::atan2x ( x y -- bangle )           like atan2 but more precise
::ctz ( x -- n )                     number of trailing zero bits (64 if x = 0)
::10/ ( n -- n/10 )                  divide by 10 (multiplies by the reciprocal, rounds toward minus infinity)
::1000000/ ( n -- n/1000000 )        divide by one million (multiplies by the reciprocal)
::memfloat ( cnt adr -- )            convert in place cnt 32-bit fixed point values at adr to float32
::mem2float ( cnt src dst -- )       convert cnt 64-bit fixed point values at src to float32 (4 bytes each) at dst
::memd2float ( cnt src dst -- )      convert cnt 32-bit fixed point values at src to float32 (4 bytes each) at dst
```

### dmath.r3

Double-precision 32.32 fixed-point math. Higher precision version of math.r3.

**Dependencies:** `^r3/lib/math.r3`, `^r3/lib/str.r3`

All `.d` words operate on 32.32 fixed-point values (integer × 2^32).

```
::*.d ( a b -- c )        32.32 fixed point multiply (rounds toward minus infinity)
::*.df ( a b -- c )       like *.d but rounds toward zero
::/.d ( a b -- c )        32.32 fixed point divide
::ceil.d ( a -- int )     round up to an integer (the result is an integer, not 32.32)

-- Conversions --
::.d>i ( a -- int )       integer part (shift right 32, rounds toward minus infinity)
::i>.d ( int -- a )       integer to 32.32 fixed point
::f>.d ( fix -- a )       48.16 fixed point (math.r3) to 32.32
::.d>f ( a -- fix )       32.32 fixed point to 48.16 (math.r3)

-- Trig --
::sin.d ( bangle -- r )   sine of a binary angle in 32.32 (1.0 = full turn); error under 2e-10 (1 LSB)
::cos.d ( bangle -- r )   cosine of a binary angle in 32.32 (1.0 = full turn); error under 2e-10 (1 LSB)
::tan.d ( bangle -- r )   tangent, rough approximation
::tan.dc ( bangle -- r )  tangent as sin/cos

-- Higher math --
::sqrt.d ( x -- r )       square root in 32.32 (all 32 fractional bits, rounded to nearest; 0 if x <= 0)
::log2.d ( x -- r )       base 2 logarithm in 32.32 (0 if x <= 0)
::pow2.d ( y -- r )       2 to the power y in 32.32
::pow.d ( x y -- r )      x to the power y (0 if x = 0)
::root.d ( x n -- r )     nth root of x (n in 32.32, 3.0 for the cube root); 0 if x <= 0
::ln.d ( x -- r )         natural logarithm in 32.32
::exp.d ( x -- r )        e to the power x in 32.32
::tanh.d ( x -- r )       hyperbolic tangent in 32.32
::gamma.d ( x -- r )      gamma function (BUG: the Stirling step adds x instead of subtracting it and the x <= 0 branch lacks exp.d; gamma 5 gives 3.73 instead of 24)
::beta.d ( x y -- r )     beta function (BUG: same Stirling problem as gamma.d; beta 2 3 gives 0.0129 instead of 0.0833)

```

---

```
::str>f.d ( adr -- adr' fix )  skip blanks and read a decimal number with sign and fraction (-43.04) as 32.32; 0 if there is no number
::f32! ( "str" 'var -- )       read the decimal number of the text and store it (32.32) at 'var
```

### str.r3

String manipulation words. Strings are zero-terminated (C style).

**Dependencies:** `^r3/lib/math.r3`

```
-- Copy and Concatenate --
::strcpyl ( src des -- ndes )         copy string src (with its 0) to des, ndes = address after the final 0
::strcpy ( src des -- )               copy string src (with its 0) to des
::strcat ( src des -- )               append string src to the end of string des
::strcpylnl ( src des -- ndes )       copy src to des up to CR, LF or 0, add a 0; ndes = address after it
::strcpyln ( src des -- )             copy a line of src to des (up to CR, LF or 0), add a 0
::copynom ( dst src -- )              copy the first word of src (up to a char <= 32) to dst, add a 0
::copystr ( dst src -- )              copy src to dst up to the first " (not included), add a 0
::strpath ( src dst -- )              copy the path of src to dst (all before the last /, without it)

-- Case --
::toupp ( c -- C )                    clear bit 5: a-z to A-Z, no range check (only for letters)
::tolow ( C -- c )                    set bit 5: A-Z to a-z, no range check (only for letters)

-- Length / Count --
::count ( s1 -- s1 cnt )              string length in bytes, reading 8 bytes at a time
::utf8count ( str -- str count )      number of UTF-8 characters of str
::utf8ncpy ( str 'dst cnt -- 'end )   copy cnt UTF-8 chars of str to 'dst; 'end is after the last byte, no 0 added
::utf8bytes ( str cnt -- str bytes )  byte length of the first cnt UTF-8 chars of str (up to the final 0)

-- Comparison --
::= ( s1 s2 -- 1/0 )                  1 if s1 equals s2 ignoring case; s2 may continue after a blank
::=s ( s1 s2 -- 1/0 )                 1 if the first word of s1 equals the first word of s2, ignoring case
::=w ( s1 s2 -- 1/0 )                 like =s but ASCII only: a byte >= 128 ends the word (use =s for UTF-8)
::cmpstr ( a b -- n )                 compare strings (case-sensitive): <0 if a<b, 0 if equal, >0 if a>b
::=pre ( adr "str" -- adr 1/0 )       1 if the string at adr starts with "str", ignoring case
::=pos ( s1 ".pos" -- s1 1/0 )        1 if s1 ends with ".pos", ignoring case
::=lpos ( lstr ".pos" -- str 0/1) ends-with, lstr is end pointer

-- Search --
::findchar ( adr char -- adr'/0 )     address of the first char in the string at adr, 0 if not found
::findstr ( adr "text" -- adr'/0 )    address of the first "text" in the string at adr, 0 if not found
::findstri ( adr "text" -- adr'/0 )   like findstr ignoring case

-- Number Formatting --
::.d ( val -- str )                   signed integer to decimal string
::.b ( bin -- str )                   binary string of val, unsigned
::.h ( hex -- str )                   hexadecimal string of val, uppercase, no prefix, unsigned
::.o ( oct -- str )                   octal string of val, unsigned
::.f ( fix -- str )                   48.16 fixed point to decimal string with 4 decimals, rounded
::.fd ( fix -- str )                  32.32 fixed point to decimal string with 8 decimals, rounded
```

---

```
::utf8c? ( c -- flag )                      0 if c is a UTF-8 continuation byte (10xxxxxx), else not 0
::utf8len ( c -- n )                        length (1-4) of the UTF-8 sequence that starts with byte c, 0 if invalid
::utf8skip ( adr -- adr' )                  skip the continuation bytes at adr
::utf8next ( adr -- adr' )                  address of the next UTF-8 character (stays at the final 0)
::utf8lead ( adr -- adr' )                  go back to the first byte of the character that contains adr
::utf8prev ( adr -- adr' )                  address of the previous UTF-8 character
::utf8@+ ( adr -- adr' cp )                 read the UTF-8 character at adr as a code point; an invalid byte is returned as is
::utf8!+ ( cp adr -- adr' )                 write code point cp as UTF-8 (1 to 4 bytes) at adr, no 0
::rfindstri ( start "text" adr -- adr'/0 )  search "text" backwards from adr down to start, ignoring case; 0 if none
::.f2 ( fix -- str )                        48.16 fixed point to decimal string with 2 decimals, rounded
::.f1 ( fix -- str )                        48.16 fixed point to decimal string with 1 decimal, rounded
::.r. ( str width -- str' )                 pad on the left with spaces up to width chars; str comes from .d .h .f ...
::trim ( adr -- adr' )                      skip chars <= 32; adr' is the first one > 32 or the final 0
::trimc ( char adr -- adr' )                address of the first char found, or of the final 0 if none
::trimcar ( adr -- adr' c )                 skip chars <= 32 and read the next char c (0 at the end); adr' is after c
::trimstr ( adr -- adr' )                   address of the closing " of the string text at adr ("" is escaped quote)
::>>cr ( adr -- adr' )                      address of the next CR or LF, or of the final 0
::>>0 ( adr -- adr' )                       address after the next 0 (the next string of a list of strings)
::l0count ( list -- cnt )                   number of strings of a list of 0-terminated strings (the list ends with an empty string)
::n>>0 ( adr n -- adr' )                    skip n strings of a list of 0-terminated strings
::only10 ( adr -- 'end )                    in place, change CRLF, CR and LFCR to LF; 'end is after the final 0
::only13 ( adr -- 'end )                    in place, change CRLF, LF and LFCR to CR; 'end is after the final 0
::>>sp ( adr -- adr' )                      address of the next char <= 32 (blank), or of the final 0
::>>str ( adr -- adr' )                     address after the closing " of the string text at adr ("" is escaped quote)
```

### mem.r3

Heap memory management and formatted print words. Provides `here` as a bump-pointer allocator with mark/empty for temporary use.

**Dependencies:** `^r3/lib/str.r3`, `^r3/lib/core.r3`

```
##here ( 'addr )            current heap top pointer

-- Store to Heap --
::, ( d -- )                write a 32-bit value at here, advance here by 4
::,c ( c -- )               write a byte at here, advance here by 1
::,w ( w -- )               write a 16-bit value at here, advance here by 2
::,q ( q -- )               write a 64-bit value at here, advance here by 8
::,s ( str -- )             write the string str at here, without its final 0
::,word ( str -- )          write the first word of str (up to a char <= 32) at here, no 0

-- Formatted Append to Heap --
::,2d ( n -- )              write n as decimal text; if n < 10 a 0 is written first (use for 2-digit fields)
::,d ( n -- )               write n as decimal text (see .d)
::,h ( n -- )               write n as hexadecimal text, uppercase (see .h)
::,b ( n -- )               write n as binary text (see .b)
::,f ( fix -- )             write the 48.16 fixed point as decimal text with 4 decimals (see .f)
::,ifp ( i -- )             write the integer i as a float32 (4 bytes)
::,ffp ( fix -- )           write the 48.16 fixed point as a float32 (4 bytes)
::,cr ( -- )                write a CR (13)
::,eol ( -- )               write a 0 byte (end of string)
::,sp ( -- )                write a space
::,nl ( -- )                write CR LF
::,nsp ( n -- )             write n spaces

-- Alignment --
::align32 ( mem -- mem' )   round mem up to a multiple of 32
::align16 ( mem -- mem' )   round mem up to a multiple of 16
::align8 ( mem -- mem' )    round mem up to a multiple of 8

-- Heap Management --
::mark ( -- )               save here on the memory stack (64 levels at most); undo it with empty
::empty ( -- )              restore here to the last mark and drop it (to the start of free memory if none)
::savemem ( "file" -- )     save to file the memory written since the last mark
::sizemem ( -- size )       bytes written since the last mark
::memsize ( -- mem size )   address of the last mark and bytes written since it
::savememinc ( "file" -- )  append to file what was written since the previous call (the first time, since the last mark)
::cpymem ( 'dst -- )        copy to 'dst the memory written since the last mark
```

---

```
::,line ( str -- )               write the first line of str (up to CR or LF, not included) at here, no 0
::appendmem ( "file" -- )        append to file the memory written since the last mark
::,print ( p p .. "" -- )        write formatted text at here (no 0); the first % takes the last value pushed. %d %h %b %o number, %s str, %w word, %l line, %k char, %f %m %a fixed point 4/2/1 decimals, %p 32.32 8 decimals, %i %j fixed int/frac part, %% percent, %. CR
::sprint ( p p .. "" -- adr )    like ,print into a shared 4 KB buffer, with a final 0; valid until the next sprint/sprintln
::sprintln ( p p .. "" -- adr )  like sprint, ending with CR LF
```

### core.r3

Time, files, directories and processes for all platforms. The platform code is selected with `|WIN|`, `|LIN|` and `|MAC|`.

**Dependencies:** `^r3/lib/str.r3`, `^r3/lib/posix/posix.r3` |LIN|, `^r3/lib/win/kernel32.r3` |WIN|, `^r3/lib/mac/posix.r3` |MAC|

```
-- Time --
::ms ( ms -- )      sleep for ms milliseconds
::msec ( -- msec )  milliseconds counter (monotonic clock; Windows: since the system start)

-- Date and time --
::time ( -- hms )           current local time as hour<<16 | minute<<8 | second
::date ( -- ymd )           current local date as year<<16 | month<<8 | day
::sysdate ( -- 'timedate )  current local date and time (read it with date.* and time.*; shared buffer)
::date.d ( adr -- day )     day of the month (1..31) of a timedate (from filetimeD, sysdate, FWRITEDT ...)
::date.dw ( adr -- dw )     day of the week of a timedate (0 = Sunday)
::date.m ( adr -- month )   month (1..12) of a timedate
::date.y ( adr -- year )    year (4 digits) of a timedate
::time.ms ( adr -- ms )     milliseconds of a timedate (always 0 on Linux/Mac)
::time.s ( adr -- sec )     seconds of a timedate
::time.m ( adr -- min )     minutes of a timedate
::time.h ( adr -- hour )    hours of a timedate

-- Files --
::load ( 'from "filename" -- 'to )    read the whole file into memory at 'from; 'to = address after the last byte read ('from if it can't be opened), no 0 added
::save ( 'from cnt "filename" -- )    write cnt bytes from 'from to a file (created or truncated)
::append ( 'from cnt "filename" -- )  append cnt bytes from 'from to a file (created if missing)
::delete ( "filename" -- )            delete the file
::filexist ( "file" -- 0=no )         not 0 if the file exists, 0 if it does not

-- File information --
::fileinfo ( "file" -- 0=not exist )  load the information of a file (for fileisize, fileijul, file*time); 0 if it does not exist
::fileisize ( -- size )               size in bytes of the file of the last fileinfo
::fileijul ( -- jul )                 julian day number of the last write date (UTC) of the file of the last fileinfo
::filecreatetime ( -- 'time )         address of the creation time of the last fileinfo (status change time on Linux); use filetimeD
::filelastactime ( -- 'time )         address of the last access time of the last fileinfo; use filetimeD
::filelastwrtime ( -- 'time )         address of the last write time of the last fileinfo; use filetimeD
::filetimeD ( 'time -- 'timedate )    convert a time address (file*time) to local date and time, read it with date.* and time.* (shared buffer)

-- Directory listing --
::ffirst ( "path" -- entry/0 )   start a directory listing, returns the first entry or 0 if none; Windows needs "path//*", the other systems the plain path
::fnext ( -- entry/0 )           next entry of the directory listing, 0 at the end
::findata ( -- adr )             address of the data of the directory search
::FNAME ( adr -- adrname )       address of the name of a directory entry (from ffirst/fnext)
::FDIR ( adr -- 1/0 )            1 if the directory entry is a directory
::FSIZEF ( adr -- sizebytes )    size in bytes of a directory entry (Linux/Mac: only of the current entry, until the next fnext)
::FCREADT ( adr -- 'timedate )   creation date of a directory entry (Linux: status change date; only the current entry)
::FLASTDT ( adr -- 'timedate )   last access date of a directory entry (Linux/Mac: only the current entry)
::FWRITEDT ( adr -- 'timedate )  last write date of a directory entry (Linux/Mac: only the current entry)

-- Processes --
::sys ( "" -- )       run a command line and wait for it to end
::sysnew ( "" -- )    run a command line (Windows: in a new console)
::sysdebug ( "" -- )  run a program as a debugged process (Windows only)
```

---
### parse.r3

Parse numbers and tokens from strings.

**Dependencies:** `^r3/lib/math.r3`, `^r3/lib/str.r3`

```
::str$>nro ( adr -- adr' nro )      hexadecimal digits at adr (no $ prefix), stops at the first other char; adr' = that char
::str%>nro ( adr -- adr' nro )      binary digits at adr (no % prefix; also . counts as 0 and / as 1), stops at the first other char
::str>nro ( adr -- adr' nro )       number at adr: 1234 $12f %101 -12 (no leading blanks); adr' = first char after it, nro = 0 if there is none
::?sint ( adr -- adr' nro )         signed decimal integer at adr (+ or - optional); adr' = first char after the digits
::?numero ( str -- str' nro flag )  like str>nro, flag = 1 if the number ends at a blank or the end of the string, else 0
::str>fix ( adr -- adr' fix )       same as str>fnro: 48.16 fixed point (-43.04 gives $ffffffffffd4f5c3)
::getnro ( adr -- adr' nro )        skip blanks, then a decimal integer (+ or - optional); no $ or % forms
::str>fnro ( adr -- adr' fix )      skip blanks, then a decimal number with optional fraction (-43.04) as 48.16 fixed point
::str>anro ( adr -- adr' n )        any number: an integer (decimal, $hex, %bin) if it ends at a blank, else a decimal with fraction as 48.16 fixed point
::getfenro ( adr -- adr' fix )      skip blanks, decimal with fraction and optional exponent (1.5e3, the . is required before the e) as 48.16 fixed point
::isHex ( adr -- 3/0 )              3 if the chars at adr (just after the $) are hex digits up to a blank or the end, else 0
::isBin ( adr -- 2/0 )              2 if the chars at adr (just after the %) are binary digits up to a blank or the end, else 0
::isNro ( adr -- type/0 )           type of the number at adr (up to a blank or the end): 1 decimal, 2 binary, 3 hexadecimal, 4 fixed point, 0 not a number
::scanp ( adr "str" -- adr'/0 )     adr' = address after "str" if the text at adr starts with it, 0 if not
::scanstr ( adr 'str -- adr' )      copy the chars at adr to 'str up to a control char (<= 31), no 0 added; adr' = that char; 0 if adr is 0
::scannro ( adr 'nro -- adr' )      skip blanks, read a number (see ?numero) and store it at 'nro; adr' = address after it, adr itself if there is no number
::scanc ( c adr -- adr'/0 )         address of the first char c found at adr, 0 if not found (or adr is 0)
::scann ( adr "str" -- adr'/0 )     address after "str" found at adr; only the first occurrence of the first char of str is tried; 0 if not found
```

---

### rand.r3

Random number generators. Two independent generators: a fast 8-bit one and a full 64-bit one.

**No dependencies.**

```
##seed8 ( initial seed )          seed for 8-bit generator
##seed ( initial seed )           seed for 64-bit generator

::rand8 ( -- r8 )                 fast 8-bit random number 0..255 (shift register on seed8)
::rerand ( s1 s2 -- )             set the seed of rand, rnd and rndmax from two values
::rand ( -- rand )                64-bit random number (multiply-add generator on seed), can be negative
::randmax ( max -- rand )         random number 0..max-1 (max itself is never returned)
::randminmax ( min max -- rand )  random number min..max-1 (max itself is never returned)
::rnd ( -- rand )                 64-bit random number (from the seed variable), can be negative
::rndmax ( max -- rand )          like randmax but using rnd: 0..max-1
::rndminmax ( min max -- rand )   like randminmax but using rnd: min..max-1
::rnd128 ( -- n )                 64-bit random number (xorshift128+, its own state)
::loopMix128 ( -- rand )          64-bit random number (LoopMix128 generator by Daniel Cota, its own state)
```

---

### vec2.r3

2D vector math. Vectors are 2-cell structures `{x y}` (48.16 fixed-point).

**Dependencies:** `^r3/lib/math.r3`

```
::v2= ( 'v1 'v2 -- )        v1 = v2 (copy)
::v2+ ( 'v1 'v2 -- )        v1 = v1 + v2
::v2- ( 'v1 'v2 -- )        v1 = v1 - v2
::v2+* ( m 'v1 'v2 -- )     v1 = v1 + v2 * m (m fixed point)
::v2-* ( m 'v1 'v2 -- )     v1 = v1 - v2 * m (m fixed point)
::v2* ( 'v1 n -- )          v1 = v1 * n (n fixed point)
::v2/ ( 'v1 n -- )          v1 = v1 / n (n fixed point; n = 0 crashes)
::v2len ( 'v -- m )         length of the vector (fixed point)
::v2nor ( 'v -- )           scale the vector to length 1.0 (a zero vector crashes)
::v2lim ( 'v lim -- )       limit the length of the vector to lim (fixed point)
::v2rot ( 'v bang -- )      x' = x*sin - y*cos, y' = x*cos + y*sin
::v2dot ( 'v1 'v2 -- dot )  dot product (fixed point)
::v2perp ( 'dst 'src -- )   dst = (-src.y, src.x): src turned 90 degrees counter-clockwise
```

---

### vec3.r3

3D vector math and quaternion operations. Vectors are 3-cell structures `{x y z}`.

**Dependencies:** `^r3/lib/math.r3`

```
-- 3D Vectors --
::v3len ( 'v -- l )                  length of the 3d vector (fixed point)
::v3nor ( 'v -- )                    scale the vector to length 1.0 (a zero vector stays 0 0 0)
::v3ddot ( 'v1 'v2 -- r )            dot product v1.v2 (fixed point)
::v3vec ( 'v1 'v2 -- )               v1 = v1 x v2 (cross product)
::v3- ( 'v1 'v2 -- )                 v1 = v1 - v2
::v3+ ( 'v1 'v2 -- )                 v1 = v1 + v2
::v3* ( 'v1 s -- )                   v1 = v1 * s (s fixed point)
::v3= ( 'v1 'v2 -- )                 v1 = v2 (copy)

::normInt2Fix ( x y z -- xf yf zf )  normalize the integer vector x y z (values on the stack) to a fixed point unit vector (0 0 0 stays 0 0 0)
::normFix ( x y z -- x y z )         normalize the fixed point vector x y z (values on the stack) to length 1.0 (0 0 0 stays 0 0 0)

-- Quaternions (4-cell: x y z w) --
::q4= ( 'q1 'q2 -- )                 q1 = q2 (copy of the 4 cells x y z w)
::q4W ( 'q 'dest -- )                copy x y z of q to dest and set w = -sqrt(|1 - x*x - y*y - z*z|)
::q4dot ( 'q1 'q2 -- dot )           4d dot product of two quaternions (fixed point)
::q4inv ( 'q 'dest -- )              dest = inverse of q (its conjugate divided by dot(q,q))
::q4conj ( 'q 'dest -- )             dest = conjugate of q (-x -y -z w)
::q4len ( 'q -- len )                length of the quaternion (fixed point)
::q4nor ( 'q -- )                    normalize the quaternion to length 1.0 (a zero quaternion becomes the identity 0 0 0 1.0)
```

---

```
::v3+* ( 'v1 'v2 s -- )                   v1 = v1 + v2 * s (s fixed point)
::v3rotX ( 'dst 'src angle -- )           dst = src rotated around the X axis (angle: 1.0 = full turn): y' = y*cos - z*sin, z' = y*sin + z*cos
::v3rotY ( 'dst 'src angle -- )           dst = src rotated around the Y axis (angle: 1.0 = full turn): x' = x*cos + z*sin, z' = z*cos - x*sin
::v3rotZ ( 'dst 'src angle -- )           dst = src rotated around the Z axis (angle: 1.0 = full turn): x' = x*cos - y*sin, y' = x*sin + y*cos
::v3rotAxis ( 'dst 'src 'axis angle -- )  dst = src rotated around the vector axis, which must be a unit vector (angle: 1.0 = full turn)
::q4lenf ( 'q -- 1/len )                  fast approximation of 1/length, only good for lengths near 1
::q4norf ( 'q -- )                        fast normalization with q4lenf, only for quaternions already near unit length
::q4integrate ( 'q 'omega dt -- )         advance quaternion q by the angular velocity vector omega during dt (fixed point), then renormalize with q4norf
```

### color.r3

Color space conversions, blending, and manipulation. Colors are packed 32-bit ARGB.

**Dependencies:** `^r3/lib/math.r3`

```
-- Byte Order --
::swapcolor ( color -- swapcolor )   swap the red and blue channels of a 32-bit color ($AARRGGBB to $AABBGGRR)
::bgr2rgb ( BGR -- RGB )             swap the red and blue channels of a 24-bit color (the alpha byte is dropped)

-- Mixing --
::colavg ( a b -- c )                per-byte average of two 32-bit colors, rounded up
::col50% ( c1 c2 -- c )              50% mix of two 24-bit colors
::col25% ( c1 c2 -- c )              75% of c1 plus 25% of c2 (24-bit colors)
::col33% ( c1 c2 -- c )              roughly 67% of c1 plus 33% of c2 (24-bit colors), made with bit masks
::colmix ( c1 c2 a -- c )            mix 24-bit colors: c1 + (c2-c1)*a/256, a = 0..255; the result is in the low 24 bits (upper bits have garbage)
::colmix4 ( c1 c2 a -- c )           like colmix for 12-bit colors $RGB: a = 0..255 (only its high 4 bits count); the result is in the low 12 bits
::blend2 ( c1 c2 i -- c )            per channel, high nibble only: (c1 >> i) + (c2 >> 1); i = 1 gives the 50% average
::diffrgb2 ( a b -- v )              sum of the absolute differences of the red, green and blue channels of two 24-bit colors

-- Color Shading --
::shadow8 ( color shadow -- color )  24-bit color scaled by shadow/256 per channel (shadow 0..255)
::light8 ( color light -- color )    add light to each channel of a 24-bit color, saturating at 255

-- Color Space Conversions --
::yuv2rgb ( y u v -- r g b )         video YUV (y 16..235, u v around 128) to RGB 0..255
::yuv32 ( y u v -- col )             like yuv2rgb but returns the packed color $RRGGBB
::hsv2rgb ( h s v -- rgb )           h s v in fixed point 0..1.0 (h: 1.0 is a full circle) to a packed color $RRGGBB
::rgb2hsv ( argb -- h s v )          packed color to h 0..1.0, s 0..1.0 and v = largest channel << 8 (0..$ff00); alpha is ignored
::rgb2ycocg ( r g b -- y co cg )     reversible YCoCg-R transform of 0..255 values (co and cg can be negative)
::ycocg2rgb ( y co cg -- r g b )     inverse of rgb2ycocg
::rgb2ycc ( RGB -- y co cg )         like rgb2ycocg from a packed color $RRGGBB
::rgb2yuv2 ( g b r -- y u v )        y = g + (b+r-2g)/4, u = b-g, v = r-g (note the order of the arguments)
::yuv2rgb2 ( y u v -- g b r )        inverse of rgb2yuv2
::RGB>Gbr ( R G B -- G b r )         G, B-G and R-G (the differences wrap to 0..255)
::Gbr>RGB ( G b r -- R G B )         inverse of RGB>Gbr

-- Packed Color Helpers --
::b2color ( col -- color )           12-bit color $RGB to 24-bit $RRGGBB (each nibble repeated)
::4bcol ( col -- color )             16-bit color $ARGB (4 bits per channel) to 32-bit $AARRGGBB (each nibble repeated)
::4bicol ( col -- color )            like 4bcol but the three color nibbles are read in reverse order (red and blue swapped)
```

---

```
::colmul ( c1 a -- c )   24-bit color scaled by a/256, a = 0..255; the result is in the low 24 bits (upper bits have garbage)
::colmul4 ( c1 a -- c )  like colmul for 12-bit colors $RGB: a = 0..15; the result is in the low 12 bits
```

### jul.r3

Julian day number calculations for date arithmetic.

**No dependencies.**

```
::date2jul ( d m y -- jul )  calendar date to Julian day
::jul2date ( jul -- d m y )  Julian day to calendar date
::date2day ( d m y -- num )  day of week number
::jul2day ( jul -- num )     Julian day to day of week
::date2daystr ( d m y -- )   print day name
::jul2daystr ( jul -- )      print day name from Julian
```

---

### console.r3

Terminal I/O with ANSI escape sequences. Uses buffered output for performance. All `.` prefix words output to the console buffer.

**Dependencies:** `^r3/lib/posix/lin-term.r3` |LIN|, `^r3/lib/win/win-term.r3` |WIN|, `^r3/lib/mac/mac-term.r3` |MAC|, `^r3/lib/mem.r3`, `^r3/lib/parse.r3`

#### Key Code Constants
Named constants for ANSI/VT key sequences: `[ESC]`, `[ENTER]`, `[BACK]`, `[TAB]`, `[DEL]`, `[INS]`, `[UP]`, `[DN]`, `[RI]`, `[LE]`, `[PGUP]`, `[PGDN]`, `[HOME]`, `[END]`, `[F1]`..`[F12]`, `[SHIFT+*]` variants.

#### Output Buffer
```
::.cl ( -- )                 empty the output buffer without writing it
::.flush ( -- )              write the output buffer to the terminal and empty it
::.type ( str cnt -- )       add cnt bytes of str to the output buffer (it is flushed first if they do not fit)
::.emit ( char -- )          add a byte to the output buffer (flushes when full)
::.cr ( -- )                 add a new line (emits LF then CR)
::.sp ( -- )                 add a space
::.nch ( n char -- )         add char repeated n times, with the terminal repeat sequence (n >= 2, one-byte chars only)
::.write ( str -- )          add the string str to the output buffer
::.print ( p p .. "" -- )    add formatted text to the output buffer (same format codes as ,print; no flush)
::.println ( p p .. "" -- )  like .print, then a new line and a flush
::.fwrite ( str -- )         like .write and flush
::.fprint ( p p .. "" -- )   like .print and flush
::.rep ( cnt "car" -- )      add the string car cnt times (multibyte safe)
```

#### Cursor Movement
```
::.home ( -- )       move the cursor to the top left corner
::.cls ( -- )        clear the screen and move the cursor to the top left corner
::.at ( x y -- )     move the cursor to column x, row y (1 is the first)
::.col ( x -- )      move the cursor to column x (1 is the first)
::.savec ( -- )      save the cursor position
::.restorec ( -- )   restore the saved cursor position
::.eline ( -- )      erase from the cursor to the end of the line
::.escreen ( -- )    erase from the cursor to the end of the screen
::.escreenup ( -- )  erase from the cursor to the beginning of the screen
::.nsp ( n -- )      add n spaces (n >= 2: it uses the repeat sequence)
```

#### Cursor Style
```
::.showc ( -- )   show the cursor
::.hidec ( -- )   hide the cursor
::.blc ( -- )     enable cursor blinking
::.unblc ( -- )   disable cursor blinking
::.ovec ( -- )    default cursor shape (blinking block)
::.insc ( -- )    cursor shape: blinking underscore
::.blockc ( -- )  cursor shape: steady block
::.underc ( -- )  cursor shape: steady underscore
```

#### Screen Buffers and Scrolling
```
::.alsb ( -- )            switch to the alternate screen buffer and flush
::.masb ( -- )            go back to the main screen buffer and flush
::.scrolloff ( rows -- )  limit the scrolling region to lines 1..rows
::.scrollon ( -- )        scrolling region back to the whole screen
```

#### ANSI Colors
Standard foreground: `.Black` `.Red` `.Green` `.Yellow` `.Blue` `.Magenta` `.Cyan` `.White` (and bright variants with `l` suffix).
Standard background: `.BBlack` `.BRed` `.BGreen` `.BYellow` `.BBlue` `.BMagenta` `.BCyan` `.BWhite`.
```
::.fc ( n -- )         set the foreground color n of the 256 color palette
::.bc ( n -- )         set the background color n of the 256 color palette
::.fgrgb ( r g b -- )  set the foreground true color (each 0..255)
::.bgrgb ( r g b -- )  set the background true color (each 0..255)
```

#### Text Attributes
`.Bold` `.Dim` `.Ital` `.Under` `.Blink` `.Rever` `.Hidden` `.Strike` `.Reset`

#### Input
```
::getch ( -- key )          flush the output and wait for a key, returns its code (see [ESC], [UP] ...)
::waitesc ( -- )            wait until the ESC key is pressed
::waitkey ( -- )            wait until any key is pressed
##pad                       128-byte input scratch buffer
::.input ( -- )             read a line of text into pad (echo, UTF-8, up to 120 bytes); Enter accepts, ESC cancels leaving pad empty
::.printe ( p p .. "" -- )  like .print but each ^ is sent as ESC (to write control sequences)
::strcpybuf ( 'mem -- )     copy the output buffer (with a final 0) to 'mem and empty it
```

---

```
::.uemit ( cp -- )        add the Unicode code point cp, encoded as UTF-8, to the output buffer (invalid ones are ignored)
::.^[ ( -- )              add ESC [ (start of a terminal control sequence)
::.[w ( str -- )          add ESC [ and the string str (control sequence)
::.[p ( p p .. "" -- )    add ESC [ and formatted text (control sequence)
::.ndel ( n -- )          erase n characters from the cursor, the cursor does not move
::.Blackl ( -- )          set the bright foreground color black
::.Redl ( -- )            set the bright foreground color red
::.Greenl ( -- )          set the bright foreground color green
::.Yellowl ( -- )         set the bright foreground color yellow
::.Bluel ( -- )           set the bright foreground color blue
::.Magental ( -- )        set the bright foreground color magenta
::.Cyanl ( -- )           set the bright foreground color cyan
::.Whitel ( -- )          set the bright foreground color white
::.BBlackl ( -- )         set the bright background color black
::.BRedl ( -- )           set the bright background color red
::.BGreenl ( -- )         set the bright background color green
::.BYellowl ( -- )        set the bright background color yellow
::.BBluel ( -- )          set the bright background color blue
::.BMagental ( -- )       set the bright background color magenta
::.BCyanl ( -- )          set the bright background color cyan
::.BWhitel ( -- )         set the bright background color white
::.fg32 ( rgb -- )        set the foreground true color rrggbb
::.bg32 ( rgb -- )        set the background true color rrggbb
::.NBold ( -- )           text attribute: bold off
::.NItal ( -- )           text attribute: italic off
::.NUnder ( -- )          text attribute: underline off
::.Rev ( -- )             text attribute: reverse video
::.NRev ( -- )            text attribute: reverse video off
::.ukey ( key -- key n )  n = bytes (1-4) of the UTF-8 character coded in key, 0 if it is not valid text
::r3run ( "" -- )         run the program "" with the r3 executable of the system and wait for it to end
```

### trace.r3

Debug tracing and memory dump utilities. Outputs to console.

**Dependencies:** `^r3/lib/console.r3`

```
::<<trace ( -- )             print stack contents
::<<traceh ( -- )            print stack in hex
::<<memdump ( adr cnt -- )   hex dump of memory region
::<<memdumpc ( adr cnt -- )  hex dump with ASCII
::clearlog ( -- )            clear log
::filelog ( .. str -- )      write formatted data to log file
::<<memmap ( inimem -- )     display memory map from base
```

---

### crc32.r3

Checksum algorithms.

**No dependencies.**

```
::crc32 ( a n -- u )     a n - u
::crc32n ( a n p -- u )  a n p - u
::adler32 ( a n -- u )   a n - u
```

---

### base64.r3

Base64 encoding and decoding.

**Dependencies:** `^r3/lib/math.r3`

```
::base64decode ( src dest -- 'dest )      decode base64 string to binary
::base64encode ( len src dest -- 'dest )  encode binary to base64 string
```

---

### sdl2.r3

SDL2 window creation, renderer, textures, events, and audio. Core SDL2 binding — all graphics libraries depend on this.

**Dependencies:** `^r3/lib/core.r3`, `^r3/lib/console.r3`, `^r3/lib/sdlkeys.r3`

#### Global State
```
##SDL_windows      window handle
##SDLrenderer      renderer handle
##sw ##sh          screen width and height (fixed-point friendly)
##SDLevent * 56    event buffer
##SDLkey           last key from event
##SDLchar          last character from event
##SDLx ##SDLy      mouse x, y
##SDLb             mouse button state
##SDLw             mouse wheel
##.exit 0          set non-zero to quit
```

#### Initialization
```
::SDLinit ( "title" w h -- )             initialize SDL, create a centered window w x h with its renderer (SDL_windows, SDLrenderer, sw, sh) and raise it
::SDLmini ( "title" w h -- )             like SDLinit without raising the window
::SDLinitScr ( "title" display w h -- )  like SDLinit on the display number given
::sdlinitR ( "title" w h -- )            like SDLinit with a resizable window
::SDLfullw ( "title" display -- )        borderless window with the size of the display (sets sw sh)
::SDLfull ( -- )                         switch the window to fullscreen
::SDLquit ( -- )                         destroy the renderer and the window and quit SDL
```

#### Main Loop
```
::SDLshow ( 'word -- )    main loop: SDLupdate and execute 'word every frame until exit is called
::SDLeventR ( 'vec -- )   word to execute when the window is resized (sw and sh are updated first)
::SDLupdate ( -- )        wait 10 ms and process the pending events, updating SDLkey, SDLchar, SDLx, SDLy, SDLb and SDLw
::SDLredraw ( -- )        show the frame (SDL_RenderPresent of the renderer)
::SDLClick ( 'event -- )  execute 'event once when the mouse button is released after being pressed (call it every frame)
::exit ( -- )             end the SDLshow loop
::sdlbreak ( -- )         debug stop: redraw and wait until F12 or ESC is pressed
::%w ( frac -- px )       fixed point fraction of the screen width (1.0 = sw) in pixels
::%h ( frac -- px )       fixed point fraction of the screen height (1.0 = sh) in pixels
```

#### Texture and Surface Management
```
::SDLframebuffer ( w h -- texture )  streaming texture w x h in ARGB8888 format, to draw pixels
::SDLblend ( -- )                    enable alpha blending for the renderer drawing
::SDLTexwh ( tex -- w h )            width and height of a texture (reads the SDL_Texture structure)
```

#### Raw SDL2 Bindings
Direct wrappers for: `SDL_Init`, `SDL_Quit`, `SDL_CreateWindow`, `SDL_CreateRenderer`, `SDL_CreateTexture`, `SDL_DestroyTexture`, `SDL_DestroyRenderer`, `SDL_UpdateTexture`, `SDL_RenderClear`, `SDL_RenderCopy`, `SDL_RenderCopyEx`, `SDL_RenderPresent`, `SDL_SetRenderDrawColor`, `SDL_PollEvent`, `SDL_GetTicks`, `SDL_Delay`, `SDL_GL_*`, `SDL_OpenAudioDevice`, `SDL_QueueAudio`, `SDL_GetClipboardText`, `SDL_SetClipboardText`, and many more.

---

```
::SDLdfullsw ( display -- sw sh )  current resolution of the display
```

### sdl2gfx.r3

SDL2 2D drawing primitives, sprite/tileset system.

**Dependencies:** `^r3/lib/sdl2.r3`, `^r3/lib/sdl2image.r3`

#### Color and State
```
::color ( rgb -- )    set the draw color from $RRGGBB (alpha 255)
::colorA ( argb -- )  set the draw color from $AARRGGBB
::cls ( rgb -- )      clear the target with the color $RRGGBB
```

#### Drawing Primitives
```
::point ( x y -- )                   draw a point
::getpixel ( x y -- rgb )            color $RRGGBB of the pixel
::line ( x1 y1 x2 y2 -- )            draw a line
::lineH ( x1 y x2 -- )               horizontal line from x1 to x2 (both included) at y
::lineV ( x y1 y2 -- )               vertical line from y1 to y2 (both included) at x
::rect ( x y w h -- )                rectangle outline (same area as frect)
::frect ( x y w h -- )               filled rectangle (it covers x..x+w-1, y..y+h-1)
::ellipse ( rx ry x y -- )           ellipse outline with radii rx ry centered at x y
::fellipse ( rx ry x y -- )          filled ellipse with radii rx ry centered at x y
::triangle ( x1 y1 x2 y2 x3 y3 -- )  filled triangle
::round ( r x y w h -- )             outline of a rectangle x y w h with rounded corners of radius r
::fround ( r x y w h -- )            filled rectangle x y w h with rounded corners of radius r
::circle ( r x y -- )                circle outline of radius r centered at x y
::fcircle ( r x y -- )               filled circle of radius r centered at x y
```

#### Image and Texture Drawing
```
::image ( x y img -- )          draw the texture at x y with its own size
::images ( x y w h img -- )     draw the texture scaled to the rectangle x y w h
::imageb ( 'dst img -- )        draw the whole texture into the box 'dst (x y w h, four int32)
::imagebb ( 'src 'dst img -- )  draw the box 'src of the texture into the box 'dst (x y w h, four int32 each)
```

#### Tileset System
Tileset: a single image divided into equal-sized tiles. Each tile has an index `n`.
```
::tsload ( w h "file" -- ts )  load an image as a tileset of tiles w x h (left to right, top to bottom); the table is kept in memory at here
::tscolor ( rgb ts -- )        color modulation $RRGGBB of the tileset texture
::tsalpha ( alpha ts -- )      alpha modulation (0..255) of the tileset texture
::tsdraw ( n ts x y -- )       draw tile n of the tileset at x y (its own size)
::tsdraws ( n ts x y w h -- )  draw tile n scaled to the rectangle x y w h
::tsbox ( 'box n ts -- )       fill the 'box (x y w h, four int32) with the source rectangle of tile n
::tsfree ( ts -- )             free the texture of the tileset (the table stays in memory)
```

#### Single-Image Sprite Drawing
Draw textures with optional rotation and zoom, centered on the given point.
```
::sprite ( x y img -- )             draw the texture centered at x y
::spriteZ ( x y zoom img -- )       draw the texture centered at x y with zoom (fixed point, 1.0 = normal size)
::spriteR ( x y ang img -- )        draw the texture centered at x y rotated by ang (1.0 = full turn)
::spriteRZ ( x y ang zoom img -- )  draw the texture centered at x y rotated by ang (1.0 = full turn) with zoom (fixed point)
```

#### Sprite-Sheet (ssload) System
Sprite-sheet: all frames packed into one image in a grid. Frames are addressed by index `n` inside the sheet. UV coordinates are pre-computed at load time for GPU efficiency.
```
::ssload ( w h "file" -- ssprite )         load an image as a spritesheet of frames w x h (left to right, top to bottom) for the ssprite words; the table is kept in memory at here
::sspritewh ( ssprite -- w h )             size of a frame
::ssprite ( x y n ssprite -- )             draw frame n of the spritesheet centered at x y
::sspriter ( x y ang n ssprite -- )        draw frame n centered at x y rotated by ang (1.0 = full turn)
::sspritez ( x y zoom n ssprite -- )       draw frame n centered at x y with zoom (fixed point, 1.0 = normal size)
::sspriterz ( x y ang zoom n ssprite -- )  draw frame n centered at x y rotated by ang (1.0 = full turn) with zoom
::sstint ( argb -- )                       tint color $AARRGGBB (with alpha) used by the ssprite words
::ssnotint ( -- )                          no tint for the ssprite words ($ffffffff)
```

#### Surface and Texture Composition
```
::createSurf ( w h -- surface )           create a 32-bit ARGB surface
::Surf>pix ( surface -- surface pixels )  also leave the address of the pixels
::Surf>wha ( surface -- surface 'wh )     also leave the address of w and h (two int32)
::Surf>wh ( surface -- surface w h )      also leave the width and the height
::Surf>pixpi ( surface -- pixels pitch )  address of the pixels and bytes per row (the surface is consumed)
::texIni ( w h -- )                       create a target texture w x h and draw into it (instead of the window) until texEnd; only one at a time
::texEnd ( -- texture )                   stop drawing into the texture, back to the window, and return the texture
::texEndAlpha ( -- texture )              like texEnd with alpha blending enabled on the texture
::Tex2Surface ( tex -- tex surface )      copy the pixels of a target texture into a new surface
::Tex2Static ( tex -- newtex )            convert a target texture into a static one (the original texture is freed)
```
---

```
::polyop ( x y -- )               start a filled polygon with its first point
::sscnt ( ssprite -- ssprite n )  number of frames (only right after ssload, while here has not changed)
```

### sdl2image.r3

SDL2_image bindings: load PNG, JPG, SVG, and animated images.

**Dependencies:** `^r3/lib/sdl2.r3`

```
::IMG_Load ( "file" -- surface )              load image as surface
::IMG_LoadTexture ( rend "file" -- texture )  load directly as texture
::IMG_LoadSizedSVG_RW ( src w h -- surface )  load SVG at size
::IMG_LoadAnimation ( "file" -- anim )        load animated image
::IMG_FreeAnimation ( anim -- )
::IMG_SavePNG ( surface "file" -- )
::IMG_SaveJPG ( surface "file" quality -- )

-- High-level helpers --
::loadimg ( "" -- texture )                   load image as texture
::unloadimg ( adr -- )                        free texture
::loadsvg ( w h "" -- tex )                   load SVG as texture
```

---

### sdl2ttf.r3

SDL2_ttf bindings for TrueType font rendering.

**Dependencies:** `^r3/lib/core.r3`

Direct wrappers: `TTF_Init`, `TTF_Quit`, `TTF_OpenFont`, `TTF_CloseFont`, `TTF_SetFontStyle`, `TTF_SetFontSize`, `TTF_SetFontSDF`, `TTF_SetFontOutline`, `TTF_SetFontLineSkip`, `TTF_SizeText`, `TTF_SizeUTF8`, `TTF_MeasureUTF8`, `TTF_RenderText_Solid`, `TTF_RenderUTF8_Solid`, `TTF_RenderUTF8_Blended`, `TTF_RenderUTF8_Blended_Wrapped`, `TTF_RenderUNICODE_Blended`.

---

### sdl2mixer.r3

SDL2_mixer bindings for audio playback.

**Dependencies:** `^r3/lib/sdl2.r3`

```
-- Raw bindings --
::Mix_Init          ::Mix_Quit
::Mix_OpenAudio ( freq format channels chunksize -- )  open the audio device (for example 44100 $8010 2 4096)
::Mix_CloseAudio ( -- )                       close the audio device
::Mix_LoadWAV ( "file" -- chunk )             load a sound effect file (WAV, and OGG, MP3... depending on the loaders) as a chunk; 0 on error
::Mix_LoadMUS ( "file" -- music )             load a music file; 0 on error
::Mix_FreeChunk ( chunk -- )                  free a chunk loaded with Mix_LoadWAV
::Mix_FreeMusic ( music -- )                  free a music loaded with Mix_LoadMUS
::Mix_PlayChannelTimed ( channel chunk loops ticks -- channel )  play the chunk: channel -1 = the first free one, loops 0 = once and -1 = forever, ticks -1 = no time limit; returns the channel used or -1
::Mix_HaltChannel ( channel -- )              stop the channel (-1 = all channels)
::Mix_FadeOutChannel ( channel ms -- )        fade out the channel in ms milliseconds (-1 = all channels)
::Mix_PlayMusic ( music loops -- )            play the music (loops -1 = forever)
::Mix_HaltMusic ( -- )                        stop the music
::Mix_FadeOutMusic ( ms -- )                  fade out the music in ms milliseconds
::Mix_VolumeMusic ( volume -- )               set the music volume (0..128)
::Mix_PlayingMusic ( -- bool )                1 if the music is playing
::Mix_Playing ( channel -- n )                1 if the channel is playing (channel -1: number of channels playing)
::Mix_MasterVolume ( volume -- )              set the master volume (0..128; needs SDL_mixer 2.6 or newer)

-- High-level helpers --
::SNDInit ( -- )                              open the audio at 44100 Hz, 16 bit signed, stereo, 4096 samples per buffer (it is called when the library is loaded)
::SNDplay ( chunk -- )                        play the chunk once in the first free channel
::SNDplayn ( channel chunk -- )               play the chunk once in the given channel
::SNDQuit ( -- )                              close the audio
```

---

### sdl2net.r3

SDL2_net bindings for TCP and UDP networking.

**Dependencies:** `^r3/lib/core.r3`

Direct wrappers: `SDLNet_Init`, `SDLNet_Quit`, `SDLNet_ResolveHost`, `SDLNet_ResolveIP`, `SDLNet_TCP_Open`, `SDLNet_TCP_OpenServer`, `SDLNet_TCP_OpenClient`, `SDLNet_TCP_Accept`, `SDLNet_TCP_Send`, `SDLNet_TCP_Recv`, `SDLNet_TCP_Close`, `SDLNet_UDP_Open`, `SDLNet_UDP_Send`, `SDLNet_UDP_Recv`, `SDLNet_UDP_Close`, `SDLNet_AllocPacket`, `SDLNet_FreePacket`.

---

### sdl2poly.r3

Polygon and thick-line drawing (on top of sdl2gfx).

**Dependencies:** `^r3/lib/sdl2gfx.r3`

```

-- Thick lines --
::linegr! ( grosor -- )  set line thickness (in pixels)
::linegr ( -- grosor )   get line thickness
::gop ( x y -- )         start thick polyline
::gline ( x y -- )       extend thick polyline
```

---

```
::fngon ( ang n r x y -- )
::ngon ( ang n r x y -- )
```

### sdl2gl.r3

OpenGL bindings accessed via SDL2's GL context.

**Dependencies:** `^r3/lib/sdl2.r3`, `^r3/lib/sdl2gl-constv.r3`

Direct wrappers for: `glCreateProgram`, `glCreateShader`, `glShaderSource`, `glCompileShader`, `glGetShaderiv`, `glAttachShader`, `glGetAttribLocation`, `glGenBuffers`, `glBindBuffer`, `glBufferData`, `glBufferSubData`, `glClearColor`, `glClear`, `glUseProgram`, `glValidateProgram`, `glEnableVertexAttribArray`, `glVertexAttribPointer`, `glDrawElements`, `glDrawArrays`, `glDrawArraysInstanced`, `glMapBuffer`, `glUnmapBuffer`, `glGetUniformBlockIndex`, `glUniformBlockBinding`, `glBindBufferBase`, `glGetTexImage`, and more.

---

```
::immBox ( x y w h -- )
::immFull ( -- )
::immMouse ( -- state )
::immZone ( -- )                 Interaction is cx,cy,cw,th
::SDLinitGL ( "title" w h -- )
::SDLinitSGL ( "title" w h -- )
::GLpaper ( $ffffff -- )
::GlDepth ( deeph -- )
::GLIni ( w h -- )
::GLIniFull ( -- )
```

### sdlkeys.r3

SDL2 keyboard scancode constants.

**No dependencies.**

⚠️ Runtime binding — constants defined via SDL2 event system. Used by `sdl2.r3` and `input.r3`. Provides named constants for all SDL_Scancode values.

---

### gui.r3

Base immediate-mode GUI framework for SDL2. Handles hot/focused state and input routing.

**Dependencies:** `^r3/lib/sdl2.r3`

```
##xr1 ##yr1 ##xr2 ##yr2   current widget rect (set by guiBox/guiRect)
##foco                     keyboard-focused widget ID
##clkbtn                   last clicked button
##idf                      current keyboard focus ID
##idl                      last focus ID
##guin?                    mouse-in-rect predicate (for custom checks)

-- Widget Region Setup --
::gui ( -- )                   start of a gui frame: call it once per frame before the widgets (resets the widget ids)
::guiBox ( x1 y1 w h -- )      start a widget with the rectangle x1 y1 w h: takes the next id and tests the mouse (sets guin?)
::guiRect ( x1 y1 x2 y2 -- )   like guiBox but with the two corners of the rectangle
::guiPrev ( -- )               the next guiBox or guiRect reuses the id of the last widget (several regions with the same id)

-- Event Handlers (call after guiBox/guiRect) --
::onClick ( 'click -- )        execute 'click when the mouse button is released over the widget that was pressed (clkbtn = the button)
::onClickFoco ( 'click -- )    like onClick and also gives the keyboard focus to the widget
::onMove ( 'move -- )          execute 'move while the button is pressed and the mouse is over the widget
::onMoveA ( 'move -- )         execute 'move while the button is held after pressing over the widget, even if the mouse leaves it
::onDnMove ( 'dn 'move -- )    execute 'dn when the button is pressed over the widget and 'move while it is held there
::onDnMoveA ( 'dn 'move -- )   like onDnMove but it keeps calling 'move after the mouse leaves the widget
::onMap ( 'dn 'move 'up -- )   'dn when pressed over the widget, 'move while held, 'up when released
::onMapA ( 'dn 'move 'up -- )  like onMap but it keeps tracking after the mouse leaves the widget

-- Input/Output Vectors --
::guiI ( 'vector -- )          execute 'vector if the mouse is inside the widget
::guiO ( 'vector -- )          execute 'vector if the mouse is outside the widget
::guiIO ( 'vi 'vo -- )         execute 'vi if the mouse is inside the widget, else 'vo

-- Focus Management --
::nextfoco ( -- )              move the keyboard focus to the next focusable widget (wraps to the first) and clear sdlkey
::prevfoco ( -- )              move the keyboard focus to the previous focusable widget (wraps to the last) and clear sdlkey
::setfoco ( nro -- )           give the keyboard focus to the focusable widget number nro (1 = the first)
::clickfoco ( -- )             give the keyboard focus to the last registered focusable widget (call it after its w/foco, for example when it is clicked)
::refreshfoco ( -- )           clear the keyboard focus: the first focusable widget takes it in the next frame
::focovoid ( -- )              register a focusable widget without code (it takes a place in the focus order)
::esfoco? ( -- n )             -1 if the next focusable widget to be registered has the keyboard focus, another nonzero value if not (compare with -1)
::w/foco ( 'in 'start -- )     focusable widget: with the keyboard focus it executes 'start the first frame and 'in in the next ones; without focus it only registers itself
::in/foco ( 'in -- )           focusable widget that executes 'in while it has the keyboard focus
::lostfoco ( 'acc -- )         focusable widget: when it has the focus it executes 'acc and moves the focus to the next widget
```

---

```
::clickfoco1 ( -- )  give the keyboard focus to the next focusable widget to be registered
```

### input.r3

Text input line editor widget (uses bfont for display).

**Dependencies:** `^r3/util/bfont.r3`, `^r3/lib/sdlkeys.r3`, `^r3/lib/gui.r3`

```
::input ( 'var max -- )             single-line text input
::inputex ( 'vector 'var max  -- )  input with external event handler
::inputdump ( -- )                  print current input state
::inputint ( 'var -- )              integer input field
::tbtn ( 'ev "text" -- )            text button with keyboard activation
```

---

### 3d.r3

3D camera projection system. Works with 3dgl.r3 matrix stack.

**Dependencies:** `^r3/lib/sdl2.r3`, `^r3/lib/3dgl.r3`

```
##xf ##yf     focal distances (x, y)
##ox ##oy     screen offset (center)

-- Camera Modes --
::2dmode ( -- )                  2d mode: put the origin ox oy at the center of the screen
::3dmode ( fov -- )              perspective mode: xf = yf = fov * screen height (fixed point), origin at the screen center, matrix reset (matini)
::Omode ( -- )                   orthogonal mode: 1.0 unit = the smaller side of the screen (xf = yf = min(sw, sh)), origin at the center, matrix reset
::whmode ( w h -- )              like Omode for an area of w x h pixels: origin at its center, xf = yf = min(w, h), matrix reset
::o3dmode ( w h -- )             same as whmode

-- Projection Words --
::p3d ( x y z -- x y )           perspective projection: x*xf/z + ox, y*yf/z + oy (z = 0 crashes)
::p3dz ( x y z -- x y z )        like p3d, keeping z
::p3di ( x y z -- z y x )        like p3d but returns z y' x' (x' on top)
::project ( x y z -- u v )       project an already transformed point (no matrix): x*xf/z + ox, y*yf/z + oy; the center if z = 0
::projectv ( x y z -- u v )      like project without the z = 0 check
::invproject3d ( x y z -- x y )  screen point x y at depth z back to the 3d plane: (x-ox)*z/xf, (y-oy)*z/yf
::project3d ( x y z -- u v )     transform the point with the current matrix and project it (the center ox oy if the transformed z is 0)
::project3dz ( x y z -- z x y )  like project3d, also returns the transformed z (y' on top)
::projectdim ( x y z -- u v )    project a size (no ox oy): transform with the current matrix, then x*xf/z', y*yf/z'; 0 0 if z' = 0
::proyect2d ( x y z -- x y )     no projection: x+ox, y+oy (z is dropped)
::inscreen ( -- x y )            screen position of the origin of the current matrix (the center if its z is 0)
::aspect ( -- a )                screen aspect ratio sw/sh (fixed point)

-- Transform Matrix Helpers --
::mtrans ( x y z -- )            translate the current matrix by x y z along the parent (world) axes: adds to its translation
::mtransi ( x y z -- )           translate the current matrix by x y z along its own (local) axes
::mrotxi ( x -- )                rotate the current matrix around X by x (1.0 = full turn), translation unchanged; at 0.25 (0,1,0) goes to (0,0,-1)
::mrotyi ( y -- )                rotate the current matrix around Y by y (1.0 = full turn), translation unchanged; at 0.25 (1,0,0) goes to (0,0,1)
::mrotzi ( z -- )                rotate the current matrix around Z by z (1.0 = full turn), translation unchanged; at 0.25 (1,0,0) goes to (0,-1,0)
```

---

### 3dgl.r3

4×4 matrix stack for OpenGL transformations. Stack depth: 20 matrices.

**Dependencies:** `^r3/lib/vec3.r3`

```
##mat>    current matrix pointer (into matrix stack 'mats)

-- Stack Management --
::matini ( -- )                            reset the matrix stack: one identity matrix as the current one
::matinim ( 'mat -- )                      reset the matrix stack: a copy of 'mat (16 cells) as the only matrix
::mpush ( -- )                             push a copy of the current matrix on the matrix stack (20 levels)
::mpushi ( -- )                            push a new identity matrix on the matrix stack
::mpop ( -- )                              pop the current matrix (there is no check for the bottom of the stack)
::nmpop ( n -- )                           pop n matrices (there is no check for the bottom of the stack)

-- Float Export --
::getfmat ( -- fmat )                      convert the current matrix to 16 float32 values written just after it in the stack; returns their address
::gettfmat ( -- )                          like getfmat but transposed; the values are at mat> 128 + (the address is not returned)
::mcpyf ( fmat -- )                        write the current matrix as 16 float32 values at fmat
::mcpyft ( fmat -- )                       like mcpyf but transposed
::midf ( fmat -- )                         write the identity matrix as 16 float32 values at fmat

-- Projection Setup --
::mperspective ( near far cot aspect -- )  make the current matrix an OpenGL perspective projection: m0 = cot*aspect, m5 = cot (cot = cotangent of half the field of view; aspect acts as height/width)
::mortho ( r l t b f n -- )                make the current matrix an OpenGL orthographic projection (right left top bottom far near)
::mlookat ( eye to up -- )                 make the current matrix an OpenGL view matrix looking from eye toward to; eye, to and up are addresses of vec3

-- Translations --
::mtran ( x y z -- )                       translate the current OpenGL matrix by x y z along its local axes (changes m12 to m15)
::mtranx ( x -- )                          like mtran along the local x axis only
::mtrany ( y -- )                          like mtran along the local y axis only
::mtranz ( z -- )                          like mtran along the local z axis only

-- Rotations --
::mrotx ( rx -- )                          rotate the current OpenGL matrix around its local X axis (1.0 = full turn)
::mroty ( ry -- )                          rotate the current OpenGL matrix around its local Y axis (1.0 = full turn)
::mrotz ( rz -- )                          rotate the current OpenGL matrix around its local Z axis (1.0 = full turn)

-- Scale --
::mscale ( x y z -- )                      multiply the four values of row 0 by x, of row 1 by y and of row 2 by z (translation included)
::mscalei ( x y z -- )                     scale the local axes: multiply the columns of the 3x3 part by x y z (translation unchanged)
::muscalei ( s -- )                        uniform scale of the 3x3 part of the matrix by s (translation unchanged)

-- Transform Points --
::transform ( x y z -- x y z )             transform a point by the current matrix: x' = x*m0 + y*m1 + z*m2 + m3, y' = x*m4 + y*m5 + z*m6 + m7, z' = x*m8 + y*m9 + z*m10 + m11
::transformr ( x y z -- x y z )            like transform without the translation (for directions)
::ztransform ( x y z -- z )                only the z of transform
::oztransform ( -- z )                     z of the transformed origin (m11)
::oxyztransform ( -- x y z )               the transformed origin (m3 m7 m11)

-- Matrix Operations --
::matinv ( -- )                            push the inverse of the current 4x4 matrix as a new matrix; nothing is pushed if it has no inverse
::mcpy ( 'mat -- )                         copy the current matrix (16 cells) to 'mat
::m* ( -- )                                multiply the two top matrices (previous * current) and push the result as a new matrix
::mm* ( 'mat -- )                          push current * 'mat as a new matrix
::mmi* ( 'mat -- )                         push 'mat * current as a new matrix

-- Convenience Aliases --
::mtra ( x y z -- )                        set the current matrix to an identity with the translation x y z (m12 m13 m14)
::mrot ( rx ry rz -- )                     set the current matrix to the rotation of three angles (1.0 = full turn), no translation
::mpos ( x y z -- )                        set the translation m12 m13 m14 of the current matrix, the rest is unchanged
::mrpos ( r16 x y z -- )                   set the current matrix to a rotation and the position x y z; r16 packs the angles as $xxxxyyyyzzzz (16 bits each, $10000 = full turn)

-- Packed Rotation/Position --
::packrota ( rx ry rz -- rp )              pack three angles of 16 bits: rx<<32 | ry<<16 | rz (for mrpos)
::+rota ( ra rb -- rr )                    add two packed rotations (the lowest bit of each 16 bit field is lost)
::pack21 ( vx vy vz -- vp )                pack three 21-bit values: vx<<42 | vy<<21 | vz
::+p21 ( va vb -- vr )                     add two pack21 values (the lowest bit of each 21 bit field is lost)
```

---

```
::mview ( eye to up -- )            mpush, mlookat and m*: pushes the view matrix and the product previous * view (arguments of mlookat)
::mproj ( near far cot aspect -- )  mpush, mperspective and m*: pushes the projection and the product previous * projection (the arguments are the ones of mperspective, not fov asp zn zf)
```

### isospr.r3

*Location: `libex/`.*

Isometric sprite rendering system with z-sort.

**Dependencies:** `^r3/lib/sdl2gfx.r3`

```
##isang 0.22     isometric x-angle
##isalt 0.28     isometric y-angle (altitude factor)
##isxo           screen x offset for isometric origin
##isyo           screen y offset for isometric origin

::xyz2iso ( x y z -- x y )          3D iso coords → screen coords
::2iso ( x y z -- x y )             alias
::isocam ( -- )                     set camera to isometric defaults
::resetcam ( -- )                   reset camera
::loadss ( w h "file" -- ssprite )  load sprite sheet
::isospr ( x y a z 'ss -- )         draw isometric sprite (angle a, z-depth z)
```

---

### vdraw.r3

Virtual drawing surface with pluggable set/get pixel callbacks. Used for off-screen rendering into arbitrary buffers.

**Dependencies:** `^r3/lib/mem.r3`, `^r3/lib/math.r3`

```
::vset! ( 'set -- )           set pixel callback: ( x y color -- )
::vget! ( 'get -- )           get pixel callback: ( x y -- color )
::vsize! ( w h -- )           set virtual canvas dimensions

::vop ( x y  -- )             set current pen position
::vline ( x y -- )            draw line from pen to x,y
::vfill ( c x y -- )          fill region with color c from x,y
::vrect ( x1 y1 x2 y2 -- )    hollow rectangle
::vfrect ( x1 y1 x2 y2 -- )   filled rectangle
::vellipse ( rx ry x y -- )   hollow ellipse
::vellipseb ( rx ry x y -- )  filled ellipse
```

---

### memshare.r3

Cross-process shared memory mapping (Windows and Linux).

**Dependencies:** `^r3/lib/mem.r3`

Structure layout: `offset 0`=map handle, `8`=file handle, `16`=size, `24`=filename.

```
::inisharev ( 'varshare -- )  open or create shared memory mapping
::endSharev ( 'varshare -- )  close shared memory mapping
```

---

### memavx.r3

AVX-accelerated buffer conversions between float32, fixed-point 48.16, and packed RGB. |WIN| only.

**Dependencies:** `^r3/lib/win/kernel32.r3`

⚠️ Loads `memavx.dll` at runtime. Specific exported word names depend on DLL version. Used for high-speed image data type conversion (e.g., float arrays to/from pixel buffers).

---

### netsock.r3

High-level cross-platform TCP socket wrapper.

**Dependencies:** `^r3/lib/mem.r3`, `^r3/lib/posix/posix.r3` |LIN|, `^r3/lib/mac/posix.r3` |MAC|, `^r3/lib/win/ws2.r3` |WIN|

```
::socket-ini ( -- )                           Windows: inicializar Winsock2
::socket-end ( -- )                           Windows: limpiar Winsock2
::socket-create ( family type protocol -- sock )
::socket-set-nonblock ( sock -- result )
::socket-set-reuseaddr ( sock -- result )
::socket-bind ( sock addr port -- result )
::socket-listen ( sock backlog -- result )
::socket-accept ( sock addr addrlen -- newsock )
::socket-connect ( sock addr addrlen -- result )
::socket-send ( sock data len flags -- bytes_sent )
::socket-recv ( sock buf len flags -- bytes_recv )
::socket-close ( sock -- result )
::net-addr-to-int ( "ip-string" -- addr )
::net-htons ( port -- network_port )
::net-get-last-error ( -- error_code )
::server-socket ( port -- sock )  create listening server socket
::client-socket ( -- sock )  create client socket
::socket-final ( sock -- )  close and cleanup
```

---

### webcam.r3

Cross-platform webcam capture via `webcam.dll`/`.so`.

**No dependencies.**

```
-- Format Constants --
##WEBCAM_FMT_RGB24  ##WEBCAM_FMT_RGB32  ##WEBCAM_FMT_YUYV
##WEBCAM_FMT_YUV420  ##WEBCAM_FMT_MJPEG

-- Parameter Constants --
##WEBCAM_PARAM_BRIGHTNESS  ##WEBCAM_PARAM_CONTRAST  ##WEBCAM_PARAM_SATURATION
##WEBCAM_PARAM_EXPOSURE  ##WEBCAM_PARAM_FOCUS  ##WEBCAM_PARAM_ZOOM
##WEBCAM_PARAM_GAIN  ##WEBCAM_PARAM_SHARPNESS

-- API --
::webcam_list_devices ( 'count -- 'devlist )
::webcam_free_list ( 'devlist -- )
::webcam_query_capabilities ( devname -- 'caps )
::webcam_free_capabilities ( 'caps -- )
::webcam_find_best_format ( 'caps w h fmt -- 'format )
::webcam_open ( devname w h fmt -- handle )
::webcam_capture ( handle 'frame -- 0/1 )
::webcam_release_frame ( handle -- )
::webcam_close ( handle -- )
::webcam_get_actual_width ( handle -- w )
::webcam_get_actual_height ( handle -- h )
::webcam_get_format ( handle -- fmt )
::webcam_get_parameter ( handle param -- value )
::webcam_set_parameter ( handle param value -- )
::webcam_set_auto ( handle param auto -- )
::webcam_set_conversion_size ( handle w h -- )
::webcam_get_converted_frame ( handle 'buf sz -- 'frame )
```

---

### glutil.r3

OpenGL helper words layered on `sdl2gl.r3`: shader loading/compilation, uniform setters, texture loading from images, and a ready-made textured cube.

**Dependencies:** `^r3/lib/mem.r3`, `^r3/lib/sdl2.r3`, `^r3/lib/sdl2gl.r3`, `^r3/lib/sdl2image.r3`

```
-- Shader Loading --
::loadShaderv ( "shader" -- idprogram )  compile+link a combined vertex/fragment/geometry
                                              shader source (marked with @V/@F/@G section tags);
                                              0 on failure
::loadShader ( "shader" -- idprogram )   load a shader file by name and call loadShaderv

-- Uniforms --
::shadera!i ( int shader "name"  -- )    set an attribute location to an int (via glUniform1i)
::shader!i ( int shader "name"  -- )     set a uniform int
::shader!v3 ( 'v3 shader "name" -- )     set a uniform vec3
::shader!v4 ( 'v4 shader "name" -- )     set a uniform vec4
::shader!m4 ( 'm4 shader "name" -- )     set a uniform mat4
::shader!f1 ( 'f shader "name" -- )      set a uniform float

-- Textures --
::glImgFnt ( "" -- t )                   load image → GL texture, GL_NEAREST filtering (for fonts)
::glImgTex ( "" -- texid )               load image → GL texture, GL_LINEAR filtering;
                                              also sets ##glimgw/##glimgh to the image size
::glColorTex ( col -- texid )            make a 1×1 solid-color texture

-- Cube Primitive --
::initcube ( -- )                        build the VAO/VBO for a unit textured cube (position+normal+UV)
::rendercube ( -- )                      draw the cube built by initcube
```

`##glimgw`/`##glimgh` hold the pixel size of the last texture loaded via `glImgTex`.

---

### onnx.r3

*Location: `libex/`.*

Direct bindings to the [ONNX Runtime C API](https://onnxruntime.ai/docs/api/c/) (`onnxruntime.dll`), for running neural network models. |WIN|

**Dependencies:** `^r3/lib/win/kernel32.r3`

This is a near-complete 1:1 mirror of the official `OrtApi` function table — roughly 190 functions covering environment/session setup, tensors, memory info, sparse tensors, execution providers (CUDA, TensorRT, ROCm, DirectML, Dnnl...), IO binding, and LoRA adapters. Every real ONNX Runtime C API function `OrtApi->Xxx(...)` is exposed here as `::OrtXxx`, in the same argument order, via the standard `sysN` DLL-call mechanism (`N` = argument count). A few conveniences are added on top:

```
::OrtgetVersionString ( -- 'str )             ONNX Runtime version string
::ortSess_CPU ( 'options threads -- 'status ) append the CPU execution provider
::ortSess_MDL ( 'options threads -- 'status ) append the MDL execution provider
```

Given the size and 1:1 nature of the rest, function-by-function stack docs aren't reproduced here — the [official OrtApi reference](https://onnxruntime.ai/docs/api/c/struct_ort_api.html) applies directly: whatever a given `OrtXxx` takes in C, the r3 word `::OrtXxx` takes on the stack in the same left-to-right order (with the trailing output pointer(s) becoming stack outputs). Typical flow: `OrtCreateEnv` → `OrtCreateSessionOptions` (+ `ortSess_CPU`/`ortSess_MDL` or one of the `SessionOptionsAppendExecutionProvider_*` words) → `OrtCreateSession` → `OrtRun`.

---

### tflite.r3

*Location: `libex/`.*

Bindings to the [TensorFlow Lite C API](https://www.tensorflow.org/lite/api_docs/c) (`tensorflowlite_c.dll`), for running `.tflite` models. |WIN|

**Dependencies:** `^r3/lib/win/kernel32.r3`

```
-- Setup --

-- Tensors --

-- Run --

-- Cleanup --
```

**Typical flow:** `TfLiteModelCreateFromFile` → `TfLiteInterpreterOptionsCreate` (+ `TfLiteXNNPackDelegateCreate`/`TfLiteInterpreterOptionsAddDelegate` if using the XNNPACK delegate) → `TfLiteInterpreterCreate` → `TfLiteInterpreterAllocateTensors` → get input tensor(s), `TfLiteTensorCopyFromBuffer` → `TfLiteInterpreterInvoke` → get output tensor(s), `TfLiteTensorCopyToBuffer`.

---

### sdl2gl-const.r3

OpenGL constant definitions, included by `sdl2gl.r3`. Not called directly — just a table of `$`-prefixed GL enum values (booleans, buffer bits, etc.).

---

### sdl2gl-constv.r3

Extended set of OpenGL constants, companion to `sdl2gl-const.r3`.

---

### clipboard.r3

Clipboard access. Platform-specific implementation in `lib/win/` or `lib/posix/`.

**No exported words in base file** — see platform sections below.

---

## lib/win/ — Windows System Bindings

---

### win/kernel32.r3

Raw Win32 kernel32.dll bindings. Includes: Console management (`AllocConsole`, `FreeConsole`, `GetConsoleMode`, `SetConsoleMode`, `SetConsoleTitle`, `ReadConsoleInput`, `WriteConsole`), File operations (`CreateFile`, `CloseHandle`, `ReadFile`, `WriteFile`, `SetFilePointer`, `SetEndOfFile`, `DeleteFile`, `MoveFile`, `GetFileAttributes`, `GetFileSize`), Memory (`GetProcessHeap`, `HeapAlloc`, `HeapFree`, `HeapReAlloc`, `GlobalAlloc`, `GlobalLock`, `GlobalFree`), Process/Thread (`CreateProcess`, `Sleep`, `WaitForSingleObject`, `GetLastError`), File Mapping (`OpenFileMappingA`, `CreateFileMappingA`, `MapViewOfFile`, `UnmapViewOfFile`), Directory (`CreateDirectory`, `RemoveDirectory`, `SetCurrentDirectory`, `FindFirstFile`, `FindNextFile`, `FindClose`), System (`GetLocalTime`, `GetTickCount`, `FileTimeToSystemTime`, `SetConsoleOutputCP`).

---

### win/clipboard.r3

Windows clipboard raw bindings plus helpers.

```
-- Raw Win32 --
::OpenClipboard ( hwnd -- )
::CloseClipboard ( -- )
::EmptyClipboard ( -- )
::IsClipboardFormatAvailable ( fmt -- 0/1 )
::GetClipboardData ( fmt -- handle )
::SetClipboardData ( fmt handle -- )

-- High-level --
::copyclipboard ( 'mem cnt -- )              copy n bytes of text to clipboard
::pasteclipboard ( 'mem -- )                 paste from clipboard to 'mem
```

---

### win/win-term.r3

Windows terminal event handling — keyboard, mouse, resize.

```
##stdin ##stdout ##stderr    standard handle globals

::type ( str cnt -- )         write to stdout
##rows ##cols                terminal size

::.onresize ( 'callback -- )  'callback -
::evtkey ( -- key )           read key event
::evtkey2 ( -- key )          read key (alternate)
##evtmx ##evtmy   mouse coords
##evtmb              mouse buttons
##evtmw              mouse wheel
::evtmxy ( -- x y )           push mouse coordinates
::inevt ( -- type )           check for event (no wait; 0=none)
::getevt ( -- type )          wait for any event
::inkey ( -- key )            0 if no key pressed

::.enable-mouse ( -- )        enable mouse reporting
::.disable-mouse ( -- )       disable mouse reporting
::.free ( -- )                free/release console
::.reterm ( -- )              set console modes for ANSI/VT + window events
```

---

### win/inet.r3

WinInet HTTP download.

```
::InternetOpen ( agent flags proxy bypass ctx -- handle )
::InternetOpenUrl ( net url headers hlen flags ctx -- handle )
::InternetReadFile ( h buf len 'read -- )
::InternetCloseHandle ( h -- )
::DeleteUrlCacheEntry ( url -- )

::openurl ( url header buff -- buff )         open URL and read to buffer
```

---

### win/winhttp.r3

WinHTTP HTTP client bindings.

```
::WinHttpOpen ( agent proxy bypass flags -- session )
::WinHttpConnect ( session host port flags -- conn )
::WinHttpOpenRequest ( conn verb url ver refer accept flags -- req )
::WinHttpSendRequest ( req headers hlen opt olen ctx -- )
::WinHttpReceiveResponse ( req reserved -- )
::WinHttpQueryDataAvailable ( req 'num -- )
::WinHttpReadData ( req buf len 'read -- )
::WinHttpCloseHandle ( h -- )

::loadurl ( buff url -- buff )                load URL content to buffer
```

---

### win/winsock.r3

Raw Winsock2 bindings (Windows-specific names).

```
::WSAStartup ( ver 'wsadata -- )
::WSACleanup ( -- )
::socket ( family type proto -- sock )
::bind ( sock 'addr addrlen -- )
::listen ( sock backlog -- )
::accept ( sock 'addr 'addrlen -- newsock )
::select ( nfds 'rset 'wset 'eset 'timeout -- n )
::closesocket ( sock -- )
::shutdown ( sock how -- )
::send ( sock 'buf len flags -- n )
::recv ( sock 'buf len flags -- n )
::getaddrinfo ( node svc 'hints 'res -- )
::ioctlsocket ( sock cmd 'arg -- )
```

---

### win/ws2.r3

Winsock2 bindings with `ws2-` prefix to avoid collision with posix names.

All words are `ws2-*` versions: `ws2-WSAStartup`, `ws2-socket`, `ws2-bind`, `ws2-listen`, `ws2-accept`, `ws2-connect`, `ws2-send`, `ws2-recv`, `ws2-closesocket`, `ws2-setsockopt`, `ws2-ioctlsocket`, `ws2-inet_addr`, `ws2-htons`, `ws2-getaddrinfo`, `ws2-freeaddrinfo`, `ws2-gethostbyname`, `ws2-gethostbyaddr`, `ws2-gethostname`, `ws2-WSAGetLastError`, `ws2-WSASetLastError`, etc.

---

### win/urlmon.r3

URL file download via urlmon.dll.

```
::URLDownloadToFile ( caller url file res callback -- )
::URLOpenBlockingStreamA ( caller url 'stream flags cb -- )

::url2file ( url file -- )                    download URL to file (no cache)
::url2filec ( url file -- )                   with cache
```

---

### win/ffmpeg.r3

FFmpeg video playback via FFmpeg DLL. |WIN| only.

```
-- Video Flags --
##LOADING     $20     video still loading
##VID_NO_AUDIO $10   no audio
##VID_LOOP    $8      loop video
##VID_WAIT    $4      wait for sync

-- API --
::IniVideo ( dllpath -- )              load FFmpeg DLL
::LoadVideo ( flags "file" -- video )  load video file
::VideoBox ( video 'box -- )           set render target box
::VideoPoly ( v x1 y1 x2 y2 -- )       render to polygon
::VideoFlag ( video -- flags )         get video flags
::VideoTex ( video -- tex )            get current frame texture
::PlayVideo ( video -- )               start playback
::StopVideo ( video -- )               stop playback
::VideoTime ( video -- len )           video duration
::VideoSize ( video -- w h )           video dimensions

-- Render Helpers --
::vshow ( x y img -- )                 show frame at position
::vshowZ ( x y zoom img -- )           show with zoom
::vshowR ( x y ang img -- )            show with rotation
::vshowRZ ( x y ang zoom img -- )      show with rotation and zoom
```

---

### win/debugapi.r3

Windows Debug API bindings.

```
::IsDebuggerPresent ( -- 0/1 )
::OutputDebugStringA ( str -- )               send string to debugger
::OutputDebugStringW ( str -- )               wide string version
::DebugBreak ( -- )                           trigger breakpoint
::ContinueDebugEvent ( pid tid cont -- )
::WaitForDebugEvent ( 'event timeout -- )
::DebugActiveProcess ( pid -- )
::DebugActiveProcessStop ( pid -- )
::CheckRemoteDebuggerPresent ( proc 'present -- )
```

---

## lib/posix/ — Linux System Bindings

---

### posix/posix.r3

Raw POSIX syscall bindings. All words are `libc-*` prefixed.

Includes: `libc-open`, `libc-close`, `libc-read`, `libc-write`, `libc-lseek`, `libc-fork`, `libc-wait`, `libc-waitpid`, `libc-mmap`, `libc-munmap`, `libc-malloc`, `libc-free`, `libc-realloc`, `libc-usleep`, `libc-ftruncate`, `libc-fsync`, `libc-mprotect`, `libc-signal`, `libc-chdir`, `libc-mkdir`, `libc-rmdir`, `libc-opendir`, `libc-closedir`, `libc-readdir`, `libc-fstatat`, `libc-clock_gettime`, `libc-fcntl`, `libc-tcgetattr`, `libc-tcsetattr`, `libc-system`, `libc-select`, `libc-stat`, `libc-access`, `libc-setlocale`, `libc-popen`, `libc-pclose`, `libc-socket`, `libc-bind`, `libc-listen`, `libc-accept`, `libc-connect`, `libc-send`, `libc-recv`, `libc-setsockopt`, `libc-inet_addr`, `libc-htons`, `libc-getaddrinfo`, `libc-gethostbyname`, plus: `shm_open`, `shm_unlink`, `msync`.

---

### posix/lin-term.r3

Linux terminal event handling.

```
::type ( str cnt -- )         write to stdout
::.reterm ( -- )              set terminal raw mode
::.free ( -- )                restore terminal
::.getterminfo ( -- )         read terminal size
::.onresize ( 'callback -- )  'callback -
##rows ##cols                   terminal dimensions
::kbhit ( -- 0/1 )            non-blocking key check
::inkey ( -- key )            0 if no key pressed
##evtmx ##evtmy ##evtmb ##evtmw
::evtmxy ( -- x y )
::inevt ( -- type )           0 if no event
::getevt ( -- type )          wait for event
::evtkey ( -- key )
::.enable-mouse ( -- )
::.disable-mouse ( -- )
```

---



## util/ — Utility Libraries

#### Contents

1. [arr8.r3](#arr8r3) — Fixed 8-value object pool
2. [arr16.r3](#arr16r3) — Fixed 16-value object pool with sort/map
3. [blist.r3](#blistr3) — Sorted byte list
4. [dlist.r3](#dlistr3) — FIFO deque
5. [heap.r3](#heapr3) — Min-heap priority queue
6. [hash2d.r3](#hash2dr3) — 2D spatial hash for collision
7. [sort.r3](#sortr3) — ShellSort variants
8. [sortradix.r3](#sortradixr3) — RadixSort 16/32/64-bit
9. [sortradixm.r3](#sortradixmr3) — RadixSort with offset keys
10. [penner.r3](#pennerr3) — 30 Penner easing functions
11. [varanim.r3](#varanimr3) — Timeline-based variable animator
12. [utfg.r3](#utfgr3) — 8×8 bitmap font terminal output
13. [bfont.r3](#bfontr3) — Fixed-width bitmap font (SDL2)
14. [pcfont.r3](#pcfontr3) — PC/DOS-style 16×32 font (SDL2)
15. [ttfont.r3](#ttfontr3) — TrueType font rendering (SDL2_ttf)
16. [txfont.r3](#txfontr3) — TrueType atlas font with pseudo-UTF8
17. [ttext.r3](#ttextr3) — Tilesheet-based terminal text (SDL2)
18. [textb.r3](#textbr3) — Wrapped text box renderer (SDL2+TTF)
19. [sdlgui.r3](#sdlguir3) — Immediate-mode GUI with TTF (SDL2)
20. [sdlfiledlg.r3](#sdlfiledlgr3) — File dialog (sdlgui-based)
21. [dlgcol.r3](#dlgcolr3) — Color picker dialog (SDL2)
22. [dlgfile.r3](#dlgfiler3) — File browser dialog (SDL2)
23. [immi.r3](#immir3) — Modern grid-based immediate-mode GUI (SDL2, v3)
24. [imcolor.r3](#imcolorr3) — Color selector widget for immi
25. [imedit.r3](#imeditr3) — Code editor with syntax highlight for immi
26. [imfiledlg.r3](#imfiledlgr3) — File dialog for immi
27. [immdatetime.r3](#immdatetimer3) — Calendar/datetime widget for immi
28. [tui.r3](#tuir3) — Text UI framework (terminal)
29. [tuiedit.r3](#tuieditr3) — Full text editor widget (terminal)
30. [vscreen.r3](#vscreenr3) — Virtual resolution with auto-scaling
31. [tilesheet.r3](#tilesheetr3) — Tile map with scrolling
32. [bmap.r3](#bmapr3) — Multi-layer tile map for games
33. [loadobj.r3](#loadobjr3) — Wavefront OBJ/MTL 3D model loader
34. [datetime.r3](#datetimer3) — Date/time formatting
35. [dbtxt.r3](#dbtxtr3) — Text database v1 (pipe/caret separators)
36. [filedirs.r3](#filedirsr3) — Filesystem scanner for UI trees

---


### arr8.r3

Fixed object pool for 8-value (64-byte) objects. Object index 0 is reserved as "null".

**Dependencies:** `^r3/lib/mem.r3`

```
::p8.ini ( cnt list -- )       initialize pool with `cantidad` slots
::p8.clear ( list -- )         reset pool (keep allocation)

-- Allocation --
::p8!+ ( 'act list -- adr )    allocate next; 'act = optional init callback
::p8! ( list -- adr )          allocate next (no callback)

-- Access --
::p8.nro ( adr list -- nro )   get object address by index (from start)
::p8.last ( ;ist -- adr )      get from end (reverse index)
::p8.cnt ( list -- cnt )       current count of active objects

-- Operations --
::p8.cpy ( adr 'list -- )      copy object adr into list
::p8.del ( adr list -- )       delete object (swap with last)
::p8.draw ( list -- )          call default draw for all
::p8.drawo ( list -- )         call default draw (ordered)
::p8.mapv ( 'vector list -- )  call vector for each object
::p8.mapd ( 'vector list -- )  call vector for each (reverse)
```

---

```
::p8.adr ( nro list -- adr )
::p8.map2 ( 'vec 'list --- )
::p8.sort ( col 'list -- )
::p8.isort ( col 'list -- )
```

### arr16.r3

Fixed object pool for 16-value (128-byte) objects. Like arr8 but larger objects with sorting and mapping.

**Dependencies:** `^r3/lib/mem.r3`

```
::p.ini ( cnt list -- )       initialize pool
::p.clear ( list -- )         reset pool

-- Allocation --
::p!+ ( 'act list -- adr )    allocate with init callback
::p! ( list -- adr )          allocate without callback

-- Access --
::p.adr ( nro list -- adr )   get object address by index
::p.nro ( adr list -- nro )   get index from address
::p.cnt ( list -- cnt )       active object count

-- Operations --
::p.del ( adr list -- )       delete object (swap with last)
::p.draw ( list -- )          call draw for all objects
::p.drawo ( list -- )         call draw (ordered)
::p.mapv ( 'vector list -- )  call vector for each
::p.mapd ( 'vector list -- )  call vector for each (desc)
::p.map2 ( 'vec 'list --- )   call 'vec with list

-- Sorting --
::p.sort ( col 'list -- )     sort by column `col` ascending
::p.isort ( col 'list -- )    sort by column `col` descending
```

---

### blist.r3

Ordered byte list (sorted insertion/lookup).

**Dependencies:** `^r3/lib/console.r3`

```
::blistdel ( 'list 'from -- )  delete item 'from from list
::blist! ( f 'list -- )        insert f into list (sorted)
::blist- ( f 'list -- )        remove f from list
::blist@ ( 'list -- f/0 )      get first item (or 0)
::blist? ( f 'list -- f/0 )    find f in list (0 if not found)
```

---

### dlist.r3

Double-ended deque / FIFO queue.

**Dependencies:** `^r3/lib/mem.r3`

```
::dc.ini ( max 'dc -- )  mac 'dc dc.ini
::dc.clear ( list -- )   clear deque
::dc? ( list -- cnt )    current item count
::dcn@ ( n l -- v )      get item at index n
::dc@ ( list -- val )    peek front item
::dc! ( val list -- )    enqueue (add to back)
::dc@- ( list -- val )   dequeue (remove from front)
```

---

### heap.r3

Min-heap priority queue.

**Dependencies:** `^r3/lib/mem.r3`

```
::heapini ( max 'h -- )  initialize heap with max capacity
::heap! ( nodo 'h -- )   insert node (smaller value = higher priority)
::heap@ ( 'h -- nodo )   remove and return min-priority node
```

---

### hash2d.r3

2D spatial hash for fast proximity/collision queries.

**Dependencies:** `^r3/lib/mem.r3`

```
##checkmax 32   maximum check radius in pixels

::H2d.ini ( maxobj -- )                   reserve at here the hash table, the object list and the contact list for up to maxobj objects (ids 0..65534)
::H2d.clear ( -- )                        empty the hash table and the contact list (call it every frame before adding the objects)
::H2d.list ( -- 'adr cnt )                list of contacts found: cnt dwords, each (newer object nro << 16) | older object nro

::h2d+! ( nro r x y -- )                  add object nro (0..65534) with radius r (0..1023) at x y (pixels, 19 bits) and add to the list its contacts with the objects already added (square test: max(|dx|,|dy|) < r1 + r2)
::h2d! ( x y zoom nro size -- x y zoom )  add object nro at x y with the radius size*zoom (zoom fixed point) and leave x y zoom
```

---

### sort.r3

ShellSort with optimal gaps. Input arrays are key-value pairs.

**Dependencies:** `^r3/lib/math.r3`

```
::shellsort ( len list -- )   list of value-data pairs
::shellsort2 ( len list -- )  list of data-value pairs
::shellsort1 ( len list -- )  list of cells packed as data|value
::sortstr ( len list -- )     list of pstr-value pairs (string pointer, value)
```

---

### sortradix.r3

O(n) RadixSort for fixed-width integer keys. Sorts key-value pair arrays.

**Dependencies:** `^r3/lib/mem.r3`

```
::radixsort32 ( cnt '2array -- )  sort by 32-bit key
::radixsort16 ( cnt '2array -- )  sort by 16-bit key
::radixsort64 ( cnt '2array -- )  sort by 64-bit key
```

The `'2array` points to an array of (key, value) pairs, each 2 cells.

---

### sortradixm.r3

RadixSort variant with offset keys.

**Dependencies:** `^r3/lib/mem.r3`

```
::radixsort ( cnt 'array -- )   sort with default offset
::radixsortm ( cnt 'array -- )  sort with modified offset keys
```

---

### penner.r3

30 Penner easing functions in 48.16 fixed-point. Input `t` is in range `[0.0 .. 1.0]` (fixed-point), output is in `[0.0 .. 1.0]`.

**Dependencies:** `^r3/lib/math.r3`

```
-- Linear --
::Lineal ( t -- t )                  no easing (linear): t unchanged; all the easing words take and return t in fixed point 0..1.0

-- Quadratic --
::Quad_In        ::Quad_Out        ::Quad_InOut

-- Cubic --
::Cub_In         ::Cub_Out         ::Cub_InOut

-- Quartic --
::Quar_In        ::Quar_Out        ::Quar_InOut

-- Quintic --
::Quin_In        ::Quin_Out        ::Quin_InOut

-- Sinusoidal --
::Sin_In         ::Sin_Out         ::Sin_InOut

-- Exponential --
::Exp_In         ::Exp_Out         ::Exp_InOut

-- Circular --
::Cir_In         ::Cir_Out         ::Cir_InOut

-- Elastic --
::Ela_In         ::Ela_Out         ::Ela_InOut

-- Back (overshoot) --
::Bac_In         ::Bac_Out         ::Bac_InOut

-- Bounce --
::Bou_In         ::Bou_Out         ::Bou_InOut

-- Dispatch table --
##easet 0        pointer to ease function table
::ease ( t nro -- t' )               apply the easing number nro to t: 0 linear, then In Out InOut of 1-3 Quad, 4-6 Cub, 7-9 Quar, 10-12 Quin, 13-15 Sin, 16-18 Exp, 19-21 Cir, 22-24 Ela, 25-27 Bac, 28-30 Bou (no range check above 30)
::easem ( t nro -- t' )              like ease with a short table, only the low 4 bits of nro count: 0 linear, then In Out InOut of 1-3 Sin, 4-6 Exp, 7-9 Bac, 10-12 Ela, 13-15 Bou

-- Interpolation --
::catmullRom ( p0 p1 p2 p3 t -- v )  Catmull-Rom spline value between p1 (t = 0) and p2 (t = 1.0) using the neighbours p0 and p3
```

---

### varanim.r3

Timeline-based variable animator. Drives values from `ini` to `fin` over time using a Penner ease.

**Dependencies:** `^r3/lib/mem.r3`, `^r3/lib/color.r3`, `^r3/util/penner.r3`

```
-- Global State --
##deltatime     time delta for current frame (ms)

::timer< ( -- )                               reset the timer (deltatime = 0)
::timer. ( -- )                               update the timer: deltatime = milliseconds since the previous call
::timer+ ( n -- n' )                          add deltatime to n
::timer- ( n -- n' )                          subtract deltatime from n

-- Setup --
::vareset ( -- )                              remove all the events and restart the animation clock
::vaini ( max -- )                            reserve at here the memory for up to max events at the same time and reset
::vaempty ( -- n )                            number of events in the list (waiting or running)
::vkillgroup ( group -- )                     remove all the events of the group (0..15)
::vkillvar ( 'var -- )                        remove the animations of the variable 'var

-- Update --
::vupdate ( -- )                              advance the animations with the time elapsed since the last call (once per frame): starts the events whose time has come, updates the variables and removes the finished ones

-- Add Animations --
::+vanim ( 'var fin ini ease dur. start -- )  animate the cell 'var from ini to fin (the first value is the destination); ease = easing number (0 linear, 1 Quad_In... see ease in penner.r3), dur. and start in seconds (fixed point); the animation starts at the first vupdate after start
::+vboxanim ( 'var fin ini ease dur. start -- )  animate the four 16-bit values packed in the cell (see xywh64), each one on its own
::+vxyanim ( 'var fin ini ease dur. start -- )  animate the two 32-bit values packed in the cell (see xy32), each one on its own
::+vcolanim ( 'var fin ini ease dur. start -- )  animate a color $AARRGGBB mixing ini and fin channel by channel (alpha included)
::+vexe ( 'exe start -- )                     execute 'exe once after start seconds; 'exe receives the address of the stored parameters and must leave it on the stack
::+vvexe ( v 'exe start -- )                  like +vexe with a parameter: 'exe receives an address and reads v with dup @
::+vvvexe ( v1 v2 'exe start -- )             like +vexe with two parameters: 'exe reads them with dup @+ swap @ (v2 deeper, v1 on top) and leaves the address

-- with group (0..15)
::+vanimg ( 'var fin ini ease dur. start group -- )  like +vanim in a group (0..15) that vkillgroup can remove
::+vboxanimg ( 'var fin ini ease dur. start group -- )  like +vboxanim in a group (0..15)
::+vxyanimg ( 'var fin ini ease dur. start group -- )  like +vxyanim in a group (0..15)
::+vcolanimg ( 'var fin ini ease dur. start group -- )  like +vcolanim in a group (0..15)
::+vexeg ( 'exe start group -- )              like +vexe in a group (0..15)
::+vvexeg ( v 'exe start group -- )           like +vvexe in a group (0..15)
::+vvvexeg ( v1 v2 'exe start group -- )      like +vvvexe in a group (0..15)

-- Packed Value Helpers --
::64xy ( b -- x y )                           unpack the first two signed 16-bit values (x in the highest 16 bits)
::64wh ( b -- w h )                           unpack the last two signed 16-bit values
::64xywh ( b -- x y w h )                     unpack four signed 16-bit values
::xywh64 ( x y w h -- b )                     pack four 16-bit values (x in the highest 16 bits)
::64xyrz ( b -- x y r z )                     unpack a sprite: x y in 16 bits, r (rotation) with 2 bits less of precision and z (zoom) with 4 bits less
::xyrz64 ( x y r z -- b )                     pack a sprite (see 64xyrz)
::64box ( b adr -- )                          write the four 16-bit values of b as four dwords x y w h at adr (an SDL_Rect)
::32xy ( b -- x y )                           unpack two signed 32-bit values (x in the high half)
::xy32 ( x y -- b )                           pack two 32-bit values (x in the high half)
```

---

```
::aniInit ( ini cnt fps -- V )  value of a frame animation: first frame ini (12 bits), cnt frames (up to 256) and fps in fixed point (10.0 = 10 frames per second, 0 = still)
::ani+! ( dt 'V -- )            advance the frame animation in 'V by dt milliseconds: as many frames as dt covers (the time left over is kept); after the last frame it goes back to the first
::aniFrame ( V -- f )           current frame number (ini + step)
::aniCnt ( V -- n )             current step 0..cnt-1 of the animation (it is not the number of frames)
::ani+timer! ( 'V -- )          advance the frame animation in 'V by deltatime
```

### utfg.r3

8×8 bitmap Unicode font for terminal output. Outputs to console buffer via `.write`.

**Dependencies:** `^r3/lib/console.r3`

```
-- Character Output --
::.xwrite ( str -- )       write string to terminal using bitmap font
::.awrite ( str -- )       write string (alternate mode)

-- Line Drawing --
::.vline ( h -- )          draw vertical line h chars tall
::.hline ( w -- )          draw horizontal line w chars wide
::.vlined ( h -- )         draw double vertical line
::.hlined ( w -- )         draw double horizontal line

-- Box Drawing --
::.boxl ( x y w h -- )     draw box (single line)
::.boxc ( x y w h -- )     draw box (corner style)
::.boxd ( x y w h -- )     draw box (double line)
::.boxf ( x y w h -- )     fill current box area

-- Text Alignment --
::lalign ( cnt str -- )    left-align string in cnt columns
::calign ( cnt str -- )    center-align
::ralign ( cnt str -- )    right-align
::lwrite ( w "str" -- )    left aligned text for txText (ignores w)
::cwrite ( w "str" -- )    centered text in w pixels for txText
::rwrite ( w "str" -- )    right aligned text in w pixels for txText
::xalign ( $VH -- )        set alignment ($V=vertical bits, $H=horizontal bits)
::xwrite ( w "str" -- )    write with current alignment
::xText ( w h x y "" -- )  draw aligned text in box
```

---

```
::.vline2 ( h -- )
::.vlined2 ( h -- )
::rgb4t ( col12 -- col256 )
```

### bfont.r3

Fixed-width bitmap font rendered to SDL2 from an image file.

**Dependencies:** `^r3/lib/sdl2gfx.r3`, `^r3/lib/sdl2image.r3`

```
##wp ##hp   glyph width, height (pixels)

-- Setup --
::bmfont ( w h "file" -- )         load the font image (a 16x16 grid of 256 characters of w x h pixels: column = low nibble, row = high nibble of the ASCII code) and set the character size
::bfont1 ( -- )                    load the font media/img/VGA8x16.png (8x16 characters)
::bfont2 ( -- )                    load the font media/img/font16x24.png (16x24 characters)

-- Colors --
::bcolor ( rgb -- )                color $RRGGBB of the font texture (color modulation)
::bfbox ( -- )                     fill the character cell at the cursor with the draw color
::bbox ( -- )                      outline of the character cell at the cursor
::bbox2 ( -- )                     outline of the lower half of the character cell at the cursor

-- Cursor Positioning --
::bat ( x y -- )                   move the cursor to the pixel position x y
::ccx ( -- x )                     cursor x in pixels (also defined in pcfont)
::ccy ( -- y )                     cursor y in pixels (also defined in pcfont)
::gotoxy ( x y -- )                move the cursor to the character cell x y (also defined in pcfont)
::gotox ( x -- )                   move the cursor to the character column x, same y (also defined in pcfont)

-- Rendering --
::bemit ( ascii -- )               draw the character at the cursor and move the cursor one character to the right
::bprint ( .. "" -- )              formatted print (see sprint) at the cursor
::bprintd ( .. "" -- )             formatted print with double width
::bprint2 ( .. "" -- )             formatted print with double width and height
::bemits ( "" -- )                 print the string at the cursor
::bemitsd ( "" -- )                print the string with double width
::bemits2 ( "" -- )                print the string with double width and height
::bprintz ( .. "" size -- )        formatted print scaled by size (fixed point, 1.0 = normal)
::bemitsz ( "" size -- )           print the string scaled by size (fixed point, 1.0 = normal)
::bfillemit ( "" -- "" )           fill with the draw color the area the string would use at the cursor
::bfcemit ( cnt -- )               fill with the draw color the area of cnt characters at the cursor
::bcr ( -- )                       new line: x = 0 and y down one character
::bcr2 ( -- )                      new line for double height text (y down two characters)
::bcrz ( size -- )                 new line for text scaled by size (fixed point)
::bsp ( -- )                       move the cursor one character to the right
::bnsp ( n -- )                    move the cursor n characters to the right

-- Measurement --
::bsize ( "" -- "" w h )           size in pixels of the string (count * wp, hp)
::bpos ( -- x y )                  cursor position in pixels
::brect ( "" -- "" x y w h )       rectangle (position and size in pixels) of the string at the cursor
::bsrcsize ( x y w h -- x y w h )  convert the two pairs from character cells to pixels (x*wp y*hp w*wp h*hp)

-- Cursor Display --
::bcursor ( n -- )                 fill with the draw color the character cell n characters to the right of the cursor (block cursor)
::bcursori ( n -- )                like bcursor but a bar of a quarter of the height at the bottom (insert cursor)
::bcursor2 ( n -- )                like bcursor for double size characters
::bcursori2 ( n -- )               like bcursori for double size characters
```

---

```
::bfillline ( x y w h -- )  fill with the draw color the rectangle given in character cells (x y w h)
```

### pcfont.r3

PC/DOS-style font (16×32 grid per image) for SDL2.

**Dependencies:** `^r3/lib/sdl2gfx.r3`, `^r3/lib/sdl2image.r3`

Similar API to bfont.r3 but for PC-font-style rendering. Key words:

```
::pcfont ( -- )                load the font media/img/VGA8x16.png (8x16 characters in a 16x16 grid) and set the cursor size
::pccolor ( rgb -- )           color $RRGGBB of the font texture (color modulation)
::pcemit ( ascii -- )          draw the character (8x16) at the cursor and move the cursor one character to the right
::pcprint ( .. "" -- )         formatted print (see sprint) at the cursor
::pcemits ( "" -- )            print the string at the cursor
::pcat ( x y -- )              move the cursor to the pixel position x y
::gotoxy ( x y -- )            move the cursor to the character cell x y (also defined in pcfont)
::gotox ( x -- )               move the cursor to the character column x, same y (also defined in pcfont)
::pccr ( -- )                  new line: x = 0 and y down 16 pixels
::pcsp ( -- )                  move the cursor one character (8 pixels) to the right
::pcnsp ( n -- )               move the cursor n characters to the right
::pcsize ( "" -- "" w h )      size in pixels of the string (count * 8, 16)
::pcrect ( "" -- "" x y w h )  rectangle (position and size in pixels) of the string at the cursor
::pcpos ( -- x y )             cursor position in pixels
::pccursor ( n -- )            fill with the draw color the character cell n characters to the right of the cursor (block cursor)
::pccursori ( n -- )           like pccursor but a bar of a quarter of the height at the bottom (insert cursor)
::pcfbox ( -- )                fill the character cell at the cursor with the draw color
::pcbox ( -- )                 outline of the character cell at the cursor
::pcbox2 ( -- )                outline of the lower half of the character cell at the cursor
::pcfillline ( x y w h -- )    fill with the draw color the rectangle given in character cells (x y w h)
::pcprintz ( .. "" size -- )   formatted print scaled by size (fixed point, 1.0 = normal)
::pcemitsz ( "" size -- )      print the string scaled by size (fixed point, 1.0 = normal)
```

---

```
::pcsrcsize ( x y w h -- x y w h )  convert the two pairs from character cells to pixels (x*8 y*16 w*8 h*16)
::pcfillemit ( "" -- "" )           fill with the draw color the area the string would use at the cursor
::pcprintd ( .. "" -- )             formatted print with double width
::pcemitsd ( "" -- )                print the string with double width
::pcprint2 ( .. "" -- )             formatted print with double width and height
::pcemits2 ( "" -- )                print the string with double width and height
```

### ttfont.r3

TrueType font rendering for SDL2 using SDL2_ttf.

**Dependencies:** `^r3/lib/sdl2gfx.r3`, `^r3/lib/sdl2ttf.r3`

```
##ttx ##tty   current text cursor position

::ttcolor ( rrggbb -- )            text color (stored with red and blue swapped, as SDL_Color wants it)
::ttfont! ( font -- )              set the font (from TTF_OpenFont) used by the tt words
::ttprint ( .. "" -- )             formatted print (see sprint) at the cursor
::ttemits ( "" -- )                draw the string at the cursor and move the cursor to its end (a texture is created for each call)
::ttat ( x y -- )                  move the cursor to the pixel position x y
::+ttat ( x y -- )                 move the cursor by x y pixels
::ttsize ( size -- )               set the point size of the current font
::ttcursor ( str strcur -- str )   fill with the draw color the block cursor of the character at strcur (an address inside str); the string is cut there temporarily
::ttcursori ( str strcur -- str )  like ttcursor but a bar of 2 pixels at the bottom (insert cursor)
::ttrect ( "" -- "" x y w h )      rectangle (position and size in pixels) of the string at the cursor
```

---

```
::ttwh ( "" -- "" w h )    size in pixels of the string with the current font
::ttstyle ( style -- )     set the style of the current font: bit 0 bold, 1 italic, 2 underline, 3 strikethrough
::ttemitc ( width "" -- )  draw the string centered in width pixels starting at the cursor
::ttemitr ( "" -- )        draw the string right aligned: it ends at the cursor x
::ttboxcc ( w h "" -- )    draw the string centered in a box w x h starting at the cursor
```

### txfont.r3

TrueType font atlas renderer with pseudo-UTF8 support and glyph caching.

**Dependencies:** `^r3/lib/sdl2gfx.r3`, `^r3/lib/sdl2ttf.r3`

```
-- Font Loading --
::txloadwicon ( "font" size -- nfont )  load a TTF font at that size into an atlas texture (ASCII 32..127, the accented letters of the utf8 list and the Font Awesome icons of media/ttf/Font Awesome 7 Free-Solid-900.otf from code 192); returns the atlas (texture and table kept at here)
::txload ( "font" size -- nfont )       like txloadwicon without the icons
::txfont ( font -- )                    select the atlas font (from txload) used by the tx words
::txfont@ ( -- font )                   the atlas font selected now

-- Color --
::txrgb ( c -- )                        color $RRGGBB of the font texture (color modulation)

-- Measurement --
::txcw ( adr car -- adr' width )        width in pixels of a character: car is the byte just read at adr-1; a two byte accented character reads its second byte (adr' is after it)
::txw ( "" -- "" width )                width in pixels of the string
::txch ( adr car -- adr' h )            height of a character (same protocol as txcw)
::txh ( -- h )                          height of the font (line height)

-- Positioning --
::txat ( x y -- )                       move the cursor to the pixel position x y
::tx+at ( x y -- )                      move the cursor by x y pixels
::txpos ( -- x y )                      cursor position in pixels

-- Rendering --
::txemit ( adr car -- adr' )            draw one character at the cursor and advance it (same protocol as txcw)
::txwrite ( "" -- )                     draw the string at the cursor
::txemitr ( "" -- )                     draw the string right aligned: it ends at the cursor x
::txprint ( .. "" -- )                  formatted print (see sprint) at the cursor
::txprintr ( .. "" -- )                 formatted print right aligned
::txcur ( str cur -- )                  fill with the draw color the block cursor of the character at cur (an address inside str); it moves the cursor x to that character
::txcuri ( str cur -- )                 like txcur but a bar of a quarter of the height at the bottom (insert cursor)
::lwrite ( w "str" -- )                 left aligned text for txText (ignores w)
::cwrite ( w "str" -- )                 centered text in w pixels for txText
::rwrite ( w "str" -- )                 right aligned text in w pixels for txText
::txalign ( $VH -- )                    alignment for txText: low 2 bits horizontal (0 left, 1 center, 2 right), bits 4-5 vertical (0 top, 1 center, 2 bottom)
::txText ( w h x y "" -- )              draw the string wrapped by words in the box x y w h with the txalign alignment; CR, LF and ; start a new line
```

---

```
::txfit ( w "" -- ncar )              number of bytes of the string that fit in w pixels
::txcr ( -- )                         new line: x = 0 and y down one line height
::txemitc ( w "" -- )                 draw the string centered in w pixels starting at the cursor x
::pad.reset ( 'var max -- 'var max )  prepare the line editor on the buffer 'var of max bytes: cursor at the end, insert mode
::pad.draw ( 'buff -- )               draw the edited line at the cursor with a blinking cursor and handle the keys: SDLchar to insert or overwrite, left, right, backspace, delete, home, end and insert to change the mode
```

### ttext.r3

Tilesheet-based terminal text renderer for SDL2. Uses a sprite sheet for characters.

**Dependencies:** `^r3/lib/sdl2gfx.r3`, `^r3/lib/sdl2image.r3`

```
##advx ##advy   character advance width/height

-- Font Setup --
::tfnt ( size w h "file" -- )      load a font image (16x16 grid of characters of w x h pixels) and set its zoom size (fixed point)
::tini ( -- )                      load the default font media/img/VGA8x16.png (8x16) at size 1.0
::tsize ( zoom -- )                set the character size as the font size times zoom (fixed point, 1.0 = normal)

-- Colors / Palette --
::trgb ( c -- )                    color $RRGGBB of the font texture (color modulation)
::tpal ( c -- rgb )                color of the palette entry c (low 4 bits: 0 black, 1 blue, 2 cyan, 3 green, 4 purple, 5 red, 6 white, 7 yellow, 8..15 the bright ones) of the style in termcolor (style0 Campbell)
::tcol ( c -- )                    set the text color from the palette entry c
::tfbox ( -- )                     fill the character cell at the cursor with the draw color
::tbox ( -- )                      outline of the character cell at the cursor

-- Positioning --
::tat ( x y -- )                   move the cursor to the pixel position x y
::tatx ( x -- )                    set the cursor x in pixels
::txy ( x y -- )                   move the cursor to the character cell x y
::tx ( x -- )                      move the cursor to the character column x
::tcx ( -- x )                     cursor x in pixels
::tcy ( -- y )                     cursor y in pixels
::tpos ( -- x y )                  cursor position in pixels
::tcr ( -- )                       new line: x = 0 and y down one character
::tsp ( -- )                       move the cursor one character to the right
::tnsp ( n -- )                    move the cursor n characters to the right

-- Rendering --
::temit ( ascii -- )               draw the character at the cursor and move the cursor one character to the right
::tprint ( .. "" -- )              formatted print (see sprint) at the cursor
::temits ( "" -- )                 print the string at the cursor

-- Measurement --
::tsbox ( 'box n ts -- )           fill the 'box (x y w h, four int32) with the source rectangle of tile n
::trect ( "" -- "" x y w h )       rectangle (position and size in pixels) of the string at the cursor
::tsrcsize ( x y w h -- x y w h )  convert the two pairs from character cells to pixels

-- Cursor Rendering --
::tcursor ( n -- )                 fill with the draw color the character cell n characters to the right of the cursor (block cursor)
::tcursori ( n -- )                like tcursor but a bar of a quarter of the height at the bottom (insert cursor)
```

---

### textb.r3

Renders text into a box with word wrapping, color, and offset parameters.

**Dependencies:** `^r3/lib/math.r3`, `^r3/lib/color.r3`, `^r3/lib/sdl2gfx.r3`, `^r3/lib/sdl2ttf.r3`

```
::textbox ( str $colb-colo-ofvh-colf w h font -- texture )
```

Parameters: `str`=text string, `$colb`=background color, `$colo`=text outline color, `$ofvh`=packed vertical/horizontal offset, `$colf`=foreground color, `w h`=box dimensions, `font`=TTF font handle. Returns SDL texture.

---

### sdlgui.r3

Immediate-mode GUI framework with TrueType font rendering for SDL2.

**Dependencies:** `^r3/lib/gui.r3`, `^r3/lib/sdl2gfx.r3`, `^r3/util/ttfont.r3`

#### Theme Variables
```
##padx 2  ##pady 2         padding between widgets
##curx 10  ##cury 10        current cursor position
##boxw 100  ##boxh 20       default widget size
##immcolorwin  $666666      window background color
##immcolortwin $444444      title bar background color
##immcolortex  $ffffff      text color
##immcolorbtn  $0000ff      button color
```

#### Setup and Layout
```
::immgui ( -- )             start of a gui frame, once per frame before the widgets: calls gui and resets the layout (cursor at 0 0, box = screen width by font height + 8)
::immSDL ( font -- )        start the gui with the TTF font and load the icons media/img/icong16.png (tiles of 24x21)
::immat ( x y -- )          set the cursor (position of the next widget)
::immat+ ( x y -- )         move the cursor by x y pixels
::immbox ( x y w h -- )     set widget size
::immfont! ( font -- )      set the TTF font used by the widgets and measure its height
::immpad! ( padx pady -- )  set the padding around the widgets
::immwinxy ( x y -- )       set the origin of the window and put the cursor inside it with the padding
::imm>> ( -- )              move the cursor one widget to the right (box width plus the padding of both sides)
::imm<< ( -- )              move the cursor one widget to the left
::immdn ( -- )              move the cursor one widget down (box height plus the padding of both sides)
::immcr ( -- )              new line: x back to the left of the window and y down one widget
::immln ( -- )              new line: x back to the left of the window and y down only the box height
::plgui ( -- )              start a widget at the cursor: guiBox of the current box with the padding
::plxywh ( -- x y w h )     rectangle of the widget at the cursor, with the padding

-- Cursor Save/Restore --
::immcur ( x y w h -- )     set the guiBox of the rectangle x y w h (relative to the window), draw a gray outline around it and make it the cursor and the box
::immcur> ( -- cur )        pack the cursor and the box in one value: curx | cury<<16 | boxw<<32 | boxh<<48
::imm>cur ( cur -- )        restore the cursor and the box packed by immcur>

::immwidth ( w -- )         set the width of the next widgets
```

#### Widget Words
```
::immlabel ( "" -- )                  draw the text (formatted, see ttprint) at the left of the current box, vertically centered
::immlabelc ( "" -- )                 draw the text centered in the current box
::immlabelr ( "" -- )                 draw the text right aligned in the current box
::imm. ( "" -- )                      draw the text (formatted with sprint) at the cursor and move the cursor right by its width plus padding (inline text)
::immStrC ( "" -- )                   draw the text centered in the current box (no format)
::immListBox ( lines -- )             guiBox of a list area of that many box heights
::immback ( color -- )                fill the current box with the color (for the lines of a list)
::immblabel ( "" -- )                 text of a list line at the left of the current box (without the vertical padding)
::immicon ( nro x y -- )              draw the icon nro of the icon set at x y
::immiconb ( nro -- )                 draw the icon nro centered in the current box with the text color
::immbtn ( 'click "" -- )             button with centered text: moves 2 pixels while the mouse is over it and executes 'click when clicked
::immibtn ( 'click nro -- )           button with the icon nro
::immtbtn ( 'click "" -- )            button as wide as its text; the background shows only while the mouse is over it
::immebtn ( 'click "" -- )            button with the text only (no background), as wide as its text
::immzone ( -- )                      Interaction is cx,cy,cw,th
::immSliderf ( min max 'value -- )    horizontal slider of a fixed point value between min and max (it shows the value with 2 decimals)
::immSlideri ( min max 'value -- )    horizontal slider of an integer value between min and max
::immCheck ( 'val "text" -- )         check box: a click toggles bit 0 of the variable
::immScrollv ( 0 max 'value -- )      vertical scroll bar for the value between 0 and max (the code notes it is incorrect)
::immRadio ( 'val "op1|op2|op3" -- )  radio buttons, one line per option: the variable holds the number (0 is the first) of the chosen one
::immCombo ( 'val "op1|op2|op3" -- )  shows the chosen option; a click goes to the next one (it is not a drop down list)
::immInputLine ( 'buff max -- )       line editor of the text in 'buff (max bytes): insert or overwrite (Ins), left, right, home, end, backspace and delete; tab and enter go to the next widget
::immInputInt ( 'var -- )             integer input: the digits typed are appended, backspace or delete divide by 10 (no negative numbers)
```

#### Window Management
```
::immwin! ( 'winword -- )     add a window to the list drawn by immRedraw ('winword draws the window and its widgets); it is not added twice
::immwin ( 'win -- 0/flags )  draw the window of the record 'win (flags, x y w h in four dwords, title): flag 1 = open, flag 2 = comes to the front; handles dragging by the title and the close button; returns 0 if it is closed, else puts the cursor and the box inside the window
::immnowin ( x y w h -- )     set the region for the widgets without a window frame
::immwinbottom ( 'win -- )    set the height of the window record to the cursor y reached (the window fits its content)
::winexit ( -- )              close the window that has the mouse over it (it is the action of the close button)
::immRedraw ( -- )            execute the word of every window of the list, bring the clicked window to the front and execute the key handler set with immkey!
::immwins ( 'win -- )         like immwin for a fixed window: no dragging, no close button
```

---

```
::immwin$ ( 'winword -- )  remove the window from the list
```

### sdlfiledlg.r3

File open/save dialog using sdlgui.r3.

**Dependencies:** `^r3/util/sdlgui.r3`

```
::immlist ( cnt -- )                 the list of files of the dialog with cnt lines: a click selects, a second click on the same line enters the folder or accepts the file; it has a scroll bar
::filedlgini ( -- )                  start the file dialog: 15 lines and memory reserved at here (a table of 1024 entries and 64 KB of names)
::immfileload ( 'vecload 'file -- )  show load dialog; calls 'vecload on confirm
::immfilesave ( 'vecload 'file -- )  show save dialog; calls 'vecload on confirm
::fullfilename ( -- )                push full path to stack
```

---

### dlgcol.r3

Interactive color picker dialog for SDL2.

**Dependencies:** `^r3/lib/sdl2gfx.r3`, `^r3/lib/color.r3`, `^r3/lib/gui.r3`, `^r3/util/bfont.r3`

```
##colord 0        currently selected color

::color! ( color -- )     set the selected color $RRGGBB and move the marks of the picker to it
::dlgColor ( -- )         draw the color dialog: the current color box (a click opens or closes the picker with hue bar, saturation and value square and alpha bar) and the palette of 3x20 colors (the old comment x y is not used, see xydlgColor!)
::dlgColorIni ( -- )      start the color dialog: build the 128 step hue bar and the palette, color white, alpha 127
::xydlgColor! ( x y -- )  position of the color dialog and rebuild its geometry
```

---

### dlgfile.r3

File browser dialog for SDL2 (uses gui.r3 input system).

**Dependencies:** `^r3/lib/sdl2gfx.r3`, `^r3/lib/gui.r3`, `^r3/lib/input.r3`

```
::dlgFileLoad ( -- fn/0 )   modal dialog to choose a file to load (it runs its own SDLshow loop; up, down, enter and esc keys, click on a line); returns the full file name, or 0 if it was cancelled
::dlgFileSave ( -- fn/0 )   modal dialog to write the name of a file to save (editable name, 64 characters); returns the full file name, or 0 if it was cancelled
::dlgSetPath ( "path" -- )  set the folder where the file dialogs start
```

---

### immi.r3

Modern grid-layout immediate-mode GUI for SDL2 (version 3, 2025). Uses txfont for rendering.

**Dependencies:** `^r3/lib/sdl2gfx.r3`, `^r3/lib/color.r3`, `^r3/util/txfont.r3`

#### Layout System
The layout cursor `(cx, cy, cw, ch)` tracks current widget position. The frame stack allows push/pop for nested layouts.

```
##cx ##cy ##cw ##ch    current widget cursor (position + size)
::%cw ( -- w )                                percent of frame width
::%ch ( -- h )                                percent of frame height

-- Frame Management --
::uiBox ( x y w h -- )                        set frame
::uiFull ( -- )                               fill entire window
::uiPush ( -- )                               push frame state
::uiPop ( -- )                                pop frame state
::uiRest ( -- )                               restore frame
::uiPading ( x y -- )                         set padding
::uiAt ( x y -- )                             absolute position within frame
::uiTo ( w h -- )                             set widget size

-- Splits (divide current frame) --
::uiN ( lineas -- )                           take N lines from top
::uiS ( lineas -- )                           take N lines from bottom
::uiE ( cols -- )                             take N columns from right
::uiO ( cols -- )                             take N columns from left
::uiGrid ( c r -- )                           adjust for fit
::uiNext ( -- )                               advance to next grid cell
::uiNextV ( -- )                              advance vertically

-- Input State Queries --
::uiEx? ( -- 0/1 )                            mouse over?
::uiOvr ( 'v -- )                             execute if mouse over
::uiDwn ( 'v -- )                             execute if mouse down in widget
::uiSel ( 'v -- )                             execute if selected
::uiClk ( 'v -- )                             execute if clicked
::uiUp ( 'v -- )                              execute on mouse release
::uiFocusIn ( 'v -- )                         execute when focus enters
::uiFocus ( 'v -- )                           execute while focused

-- Frame Lifecycle --
::uiStart ( -- )                              begin UI frame
::uiEnd ( -- )                                end UI frame
::uiZone ( -- )                               Interaction is cx,cy,cw,th
::uiZoneL ( nlines -- )                       Interaction is cx,cy,cw,th*lines
::uiZoneW ( --	; Interaction is cx,cy,cw,ch ) zone filling cw×ch
::uiZoneBox ( x y w h -- )                    explicit zone rect
::uiSaveLast ( x y w h 'vector -- )           save last zone dimensions
::uiBackBox ( -- )                            draw background box
::uiExitWidget ( -- )                         early exit from widget
::uiPlace ( n -- )                            place widget at grid position n
```

#### Focus
```
::uiRefocus ( -- )  reset focus
::uiFocus>> ( -- )  move to next focusable
::uiFocus<< ( -- )  move to previous
::tabfocus ( -- )   advance focus on Tab key
```

#### Drawing Helpers
```
::uiFill ( -- )            fill cx cy cw ch
::uiRect ( -- )            outline cx cy cw ch
::uiRFill ( -- )           rounded filled
::uiRRect ( -- )           rounded outline
::uiCRect ( -- )           circle outline (uses min of w,h)
::uiCFill ( -- )           circle filled
::uiTex ( tex -- )         draw texture in widget area
::uiWinBox ( -- x y w h )  window bounds
::uiLineGridV ( -- )       draw vertical grid lines
::uiLineGridH ( -- )       draw horizontal grid lines
::uiLineGrid ( -- )        draw both grid lines
```

#### Status Styles
```
::stDang ( -- )  danger style (red)
::stWarn ( -- )  warning style (amber)
::stSucc ( -- )  success style (green)
::stInfo ( -- )  info style (blue)
::stLink ( -- )  link style
::stDark ( -- )  dark style
::stLigt ( -- )  light/white style
```

#### Widgets
```
-- Labels and Text --
::uiTlabel ( -- )                    text label from stack
::uiLabel ( -- )                     centered label
::uiLabelC ( -- )                    explicitly centered
::uiLabelR ( -- )                    right-aligned
::uiText ( "" align -- )             text with alignment
::ttwrite ( "text" -- )              write text (left)
::ttwritec ( "text" -- )             write centered
::ttwriter ( "text" -- )             write right

-- Buttons --
::uiBtn ( 'click "" -- )             standard button
::uiRBtn ( 'click "" -- )            rounded button
::uiCBtn ( 'click "" -- )            circular button
::uiTBtn ( 'click "" align -- )      text button with alignment
::uiNBtn ( v "" -- )                 width from text

-- Input --
::uiInputLine ( 'buff max -- )       single-line text input
::uiCheck ( 'var 'list -- )          checkbox (list = option strings)
::uiRadio ( 'var 'list -- )          radio group
::uiCombo ( 'var 'list -- )          combo box / dropdown
::uiList ( 'var cntl 'list -- )      scrollable list
::uiTree ( 'var cntl list -- )       collapsible tree
::uiNindx ( n -- str )               get list item string n

-- Sliders and Progress --
::uiSliderf ( 0.0 1.0 'value -- )    horizontal float slider
::uiSlideri ( 0 255 'value -- )      horizontal integer slider
::uiVSliderf ( 0.0 1.0 'value -- )   vertical float slider
::uiVSlideri ( 0 255 'value -- )     vertical integer slider
::uiProgressf ( 0.0 1.0 'value -- )  float progress bar
::uiProgressi ( 0 255 'value -- )    integer progress bar
```

> **Note:** `immi.r3` (v3) is single-window/full-screen — it has no `immwin`/`immnowin`-style multi-window API. That API (`immwin`, `immwin!`, `immnowin`, `winexit`, `immRedraw`, `immwins`, `immSDL`, `immblabel`, `immicon`, `immiconb`, `immwidth`, etc.) belongs to `sdlgui.r3`, which is documented in its own section above. An earlier version of this reference mistakenly duplicated that list here.

---

```
::stColor ( rgb -- )
```

### imcolor.r3

Color selector widget for immi.

**Dependencies:** `^r3/lib/color.r3`, `^r3/util/immi.r3`

```
::color! ( color -- )   set the selected color $RRGGBB and move the marks of the picker to it
::uiColor ( 'var -- )   full color selector widget (HSV + RGB sliders)
::uiColorH ( 'var -- )  compact horizontal color selector
```

---

### imedit.r3

Code editor widget for immi with syntax highlighting and marks.

**Dependencies:** `^r3/lib/parse.r3`, `^r3/lib/color.r3`, `^r3/util/immi.r3`

```
##ycursor ##xcursor    cursor row, column
##edfilename * 1024    current file path
##inisel               selection start
##finsel               selection end
##fuente               editable text buffer
##fuente>              cursor pointer into buffer

-- Syntax Marks --
::clearmark ( -- )             clear all syntax marks
::addmark ( -- )               add mark at current position
::addsrcmark ( src color -- )  add colored mark
::showmark ( -- )              render marks

-- Editor Display --
::edcodedraw ( -- )            draw code with syntax highlighting
::edfill ( -- )                fill editor background
::edtoolbar ( -- )             render editor toolbar

-- Focus --
::edfocus ( -- )               interactive code editor (focused)
::edfocusro ( -- )             read-only editor

-- Editor RAM Management --
::edram ( -- )                 allocate editor RAM

-- Widget Setup --
::edwin ( x y w h -- )         set editor window position/size
::edloadmem ( "" -- )          load text from string into editor
::edload ( "" -- )             load file into editor
::edsave ( -- )                save editor contents to file
```

---

```
::edlinenum! ( 0/1 -- )  show or hide the line number
::edlinenum ( -- 0/1 )
```

### imfiledlg.r3

File open/save dialog for immi.

**Dependencies:** `^r3/util/immi.r3`

```
::immfileload ( 'vecload 'file -- )  show load dialog
::immfilesave ( 'vecload 'file -- )  show save dialog
::fullfilename ( -- )                push current full path
::uiFileName ( 'var -- )             file name input widget
```

---

### immdatetime.r3

Calendar and time picker widgets for immi.

**Dependencies:** `^r3/lib/jul.r3`, `^r3/util/immi.r3`, `^r3/util/datetime.r3`

```
::uiDateTime ( 'var -- )  full date+time picker widget
::uiDate ( 'var -- )      date-only calendar widget
::uiTime ( 'var -- )      time-only picker widget
```

The variable stores packed date/time as a 64-bit value; use `datetime.r3` words to interpret it.

---

### tui.r3

Text UI layout framework for terminal interfaces.

**Dependencies:** `^r3/lib/console.r3`, `^r3/util/utfg.r3`

#### Frame Layout
A "frame" defines a rectangular region of the terminal. Frames can be split and nested.

```
##fx ##fy ##fw ##fh   current frame (x y width height)

-- Frame Setup --
::flx! ( x y w h -- )            set frame
::flx ( -- )                     restore frame from stack
::flxpush ( -- )                 push current frame
::flxpop ( -- )                  pop frame
::flxRest ( -- )                 restore last
::flxvalid? ( -- 0= not valid )  0 = frame is not valid

-- Frame Splits --
::flxN ( lineas -- )             take from top
::flxS ( lineas -- )             take from bottom
::flxE ( cols -- )               take from right
::flxO ( cols -- )               take from left
::fw% ( -- w. )                  percent of frame width (48.16)
::fh% ( -- h. )                  percent of frame height

-- Utilities --
::flpad ( x y -- )               add padding to frame
::flin? ( x y -- 0/-1 )          is x,y inside current frame?
::flin?1 ( x y -- 0/-1 )         inside? (alternate)
```

#### Event Flags
```
##uikey            current key code

::exit ( -- )    end the SDLshow loop
::tuX? ( -- f )  check for pending action (local flag)
::tuR! ( -- )    request redraw
::tuC! ( -- )    enable cursor
```

#### Main Loop
```
::tui ( -- )             run TUI event loop
::onTui ( 'vector -- )   set main TUI handler
::onTuia ( 'vector -- )  set TUI handler (alternate, no clear)
::tuiw ( -- flag )       is current widget active? (interactive zone)
::tuiw1 ( -- flag )      1 line only zone
::tuif ( -- flag )       is focused?
::tuRefocus ( -- )       reset focus
```

#### Window Drawing
```
::.wfill ( -- )            fill current frame
::.wborde ( -- )           single-line border
::.wborded ( -- )          double-line border
::.wbordec ( -- )          corner-style border
::.wtitle ( place "" -- )  draw title in frame
::tuWin ( -- )             draw window (border+fill)
::tuWina ( -- )            draw window (no fill)
::.tdebug ( -- )           show debug info
```

#### Widgets
```
-- Buttons and Labels --
::tuTBtn ( 'ev "" -- )           toggle button
::tuBtn ( -- )                   standard button
::tuLabel ( "" -- )              left-aligned label
::tuLabelC ( "" -- )             centered label
::tuLabelR ( "" -- )             right-aligned label
::tuText ( "" align -- )         text with alignment

-- Lists --
::tuList ( 'var list -- )        scrollable list
::tuTree ( 'var list -- )        collapsible tree
::uiNindx ( n -- str )           get list item n

-- Input --
::tuInputLine ( 'buff max -- )   single-line text input
::tuCheck ( 'var "label" -- )    checkbox
::tuRadio ( n 'var "label" -- )  radio button (option n)
::tuSlider ( 'var min max -- )   slider
::tuProgress ( percent -- )      progress bar (0..100)

-- Write helpers --
::xwrite! ( -- )                 reset write state
::xwrite.reset ( -- )            reset accumulated write
##padi>                   write start offset

```

---

```
::fhome ( -- )                              top-left of the panel
::tuiexit                                   exit from tui
::onTuiResize ( vec -- )
::tuListN ( 'var listn -- )
::flVisibleIndex ( listadr adr -- idx/-1 )  adr debe ser un item de listadr
::pal! ( 'pal -- )
::cbg ( n -- )
::cfg ( n -- )
::fcr ( -- )                                next line (and reset the table columns)
::pan ( "title" -- )                        fondo bg1, padding 1, titulo en acento
::.lines ( 'v n -- )
::tcols ( 'def -- )
::hdr ( "a|b|c" -- )
::tbw ( -- n )                              total width of the boxed table
::tbrowc ( "a|b|c" 'color -- )              boxed table row, 'color = color word
::tbrow ( "a|b|c" -- )                      boxed table row
::tbhdr ( "a|b|c" -- )                      boxed table header
::flxRoot ( -- )                            fullscr
::flxC ( w h -- )                           frame w x h cent
::tuDlg ( "title" w h -- )
::tuDlgEnd ( -- )
```

### tuiedit.r3

Full-featured text editor widget for TUI framework. Supports selection, clipboard, and undo.

**Dependencies:** `^r3/util/tui.r3`, `^r3/lib/clipboard.r3`

```
##filename * 1024     current file path
##fuente              text buffer pointer
##fuente>             cursor pointer
##$fuente             end of text pointer

-- Cursor Control --
::tuiecursor! ( cursor -- )  set cursor to pointer
::tuipos! ( pos -- )         set cursor to integer position

-- Hash / Change Detection --

-- Key Handlers --
::tueKeyMove ( -- )          process cursor movement keys

-- Display --
::tuEditShowCursor ( -- )    display cursor
::tuecursor. ( -- )          render cursor indicator

-- Editor Modes --
::tuEditCode ( -- )          interactive code editor (normal fonts)
::tuReadCode ( -- )          read-only code display
::tuReadCodeMono ( -- )      read-only monospace display

-- File Operations --
::TuLoadMem ( "" -- )        load text from string
::TuLoadMemC ( "" -- )       load text (already sanitized)
::TuLoadCode ( "" -- )       load from file
::TuNewCode ( -- )           new/empty file
::TuSaveCode ( -- )          save to current ##filename

-- Marks (Syntax / Search) --
::tokenCursor ( 'mark -- )   set cursor to mark
```

---

```
::tuTheme! ( 'theme -- )     'themeold / 'themenew
::tuiposq! ( pos -- )
::tuelstart ( adr -- adr' )  start of the line of adr
::tuejpush ( -- )            saves the place of the cursor
::tuejdepth ( -- n )         how many places are saved (32 at most)
::tuejback ( -- )            back to the last saved place
::tuegodef ( -- )            goes to the definition of the word under the cursor, saving the place to come back
::tuefindword ( -- )         the next whole word like the one under the cursor (wraps), the place is saved
::tueinsat ( 'str adr -- )
::tuEditLN! ( n -- )         line number place
```

### vscreen.r3

Virtual resolution rendering. Renders to an internal texture at logical size, then scales to the actual window.

**Dependencies:** `^r3/lib/sdl2.r3`

```
::vscreen ( w h -- )  create a virtual screen of w x h pixels (a render target) shown in the window centered with the aspect ratio kept and linear filtering; it follows the window resizes
::vini ( -- )         start drawing into the virtual screen (it becomes the render target)
::vredraw ( -- )      draw the virtual screen in the window and present it
::vfree ( -- )        free the virtual screen texture

::sdlx ( -- x )       mouse x position (16 bits)
::sdly ( -- y )       mouse y position
::%w ( frac -- px )   fixed point fraction of the screen width (1.0 = sw) in pixels
::%h ( frac -- px )   fixed point fraction of the screen height (1.0 = sh) in pixels
```

---

```
::vscreenf ( w h -- )  like vscreen with nearest neighbor scaling (sharp pixels)
```

### tilesheet.r3

Tile map system with scrolling view.

**Dependencies:** `^r3/lib/mem.r3`, `^r3/lib/math.r3`, `^r3/lib/sdl2image.r3`, `^r3/lib/sdl2gfx.r3`

```
::[map] ( x y -- ad )                         address of tile at x,y in map
::loadtilemap ( "" -- amap )                  load tile map from file

-- Rendering --
::drawtile ( y x tile -- y x )                draw single tile
::tiledraw ( w h x y sx sy 'amap -- )         draw tilemap (sx/sy = scroll offset)
::tiledrawv ( w h x y sx sy 'amap 'vec -- )   draw + call 'vec for each tile
::tiledraws ( w h x y sx sy sw sh 'amap -- )  draw subregion of map
::tiledrawvs ( w h x y sx sy sw sh 'amap 'v -- )  draw subregion + callback

-- Coordinate Conversion --
::scr2view ( xs ys -- xv yv )                 screen to view coordinates
::scr2tile ( x y -- adr : only after tilemapdraw (set the vars) )  screen to tile address (valid after tiledraw)
```

---

### bmap.r3

Multi-layer tile map for 2D games with isometric and z-sorted sprite rendering.

**Dependencies:** `^r3/lib/rand.r3`, `^r3/lib/console.r3`, `^r3/lib/sdl2gfx.r3`, `^r3/util/arr16.r3`

```
##bsprdraw  draw sprite function pointer (redefine for custom sprite drawing)

::inisprite ( -- )           start the list of sprites drawn in order with the map rows (call it every frame before +sprite); the list is in free memory at here
::+sprite ( N x y -- )       add the sprite N at screen position x y to the sorted list; it is ignored if it is outside the screen
::drawmaps ( xvp yvp -- )    draw the map with its sprites from the viewport position xvp yvp in pixels (tiles of 32x32): back layers, then the sprites row by row, then the front layers
::loadmap ( "filename" -- )  load a map file (8 bytes header, mapw maph, mapw*maph cells of 64 bits, tilew tileh, tileset image name) and its tileset; the view is 34x23 tiles of 32 pixels
::bmap2xy ( x y -- x y )     tile position x y to the pixel position in the tileset size (x*tilew, y*tileh) as fixed point
::whbmap ( -- w h )          size of the map in tiles
::xyinmap@ ( x y -- cell )   map cell (64 bits) at the position x y given as fixed point pixels (no range check)
::xytrigger ( x y -- x y )   mark with the trigger flag (bit 51) the conditional tiles (bit 50) of the cells around x y; drawmaps clears the flag at the end of the frame
```

---

### loadobj.r3

Wavefront OBJ/MTL 3D model loader.

**Dependencies:** `^r3/lib/mem.r3`, `^r3/lib/parse.r3`, `^r3/lib/sdl2image.r3`

```
-- Vertex Data (after loadobj) --
##verl  ##nver        vertex list, count
##facel ##nface       face list, count (triangles or quads)
##norml #nnorm        normal list, count (nnorm is private, unlike its siblings)
##texl  ##ntex        UV coordinate list, count
##paral #npara        parameter list, count (npara is private, unlike its siblings)
##colorl ##ncolor     color list, count

-- Accessors --
::]face ( nro -- FACE ( p1 p2 p3 color) )  address of face nro (fields: p1 p2 p3 color)
::]vert ( nro -- vertex )                  address of vertex nro
::]norm ( nro -- normal )                  address of normal nro
::]uv ( nro -- uv )                        address of UV coord nro

-- Material (MTL) Accessors --
::]Ka@  ::]Kd@  ::]Ks@  ::]Ke@   ambient/diffuse/specular/emission
::]Ns@  ::]Ni@  ::]d@   ::]i@    shininess/refraction/dissolve/illumination
::]Mkd@ ::]MNs@ ::]Mbp@           texture map filenames

-- Loading --
::loadobj ( "" -- mem )                    load OBJ file, return memory base

-- Geometry Operations --
##xmin ##ymin ##zmin ##xmax ##ymax ##zmax   bounding box (after objminmax)
::objminmax ( -- )                         compute bounding box of all vertices
::objmove ( x y z -- )                     translate all vertices
::objcentra ( -- )                         center model at origin
::objescala ( mul div -- )                 scale all vertices by mul/div
::objescalax ( mul div -- )                scale X only
::objescalay ( mul div -- )                scale Y only
::objescalaz ( mul div -- )                scale Z only
::objcube ( lado -- )                      generate a unit cube of side `lado`
::getpath ( str -- str )                   extract directory path from filepath
::>>cr ( adr -- adr' )                     address of the next CR or LF, or of the final 0
::cnt/ ( -- )                              count faces
```

---

### datetime.r3

Date and time formatting in Spanish. Provides string output words.

**Dependencies:** `^r3/lib/mem.r3`

```
-- Append to Heap (,time / ,date style) --
::,time ( -- )                 write the current time as h:mm:ss (hour without leading zero)
::,ti:me ( -- )                write the current time as h:mm with a blinking colon (a space on odd seconds)
::,date ( -- )                 write the current date as d/m/yyyy
::,date- ( -- )                write the current date as yyyy-mm-dd

-- Raw String Generation --
::str_DMA ( -- str )           the current date as " d/m/yyyy " in a temporary string (at here, valid until the next write to memory)
::str_HMS ( -- str )           the current time as " h:mm:ss " in a temporary string (at here)
::str_HM ( -- str )            the current time as " h:mm " (blinking colon) in a temporary string (at here)
::str_fullday ( -- str )       current date as "weekday, d month yyyy " in Spanish, zero-terminated, in a temporary string (BUG: the month name is one too far: date.m is 1..12 and >mesname takes 0..11)
::str_hhmmss ( -- str )        current time as hh:mm:ss (2 digits each), zero-terminated, in a temporary string (at here)

-- Day and Month Names --
::>dianame ( n -- str )        Spanish name of the weekday n (0 = domingo .. 6 = sabado), no range check
::>mesname ( n -- str )        Spanish name of the month n (0 = enero .. 11 = diciembre), no range check

-- SQL / Database Formats --
::dt2timesql ( 'timedate -- )  write a timedate (address from sysdate or filetimeD) as yyyy-mm-dd hh:mm:ss at here (no final 0)

-- 64-bit Packed DateTime --
::dt>64 ( 'timedate -- dt64 )  pack a timedate in 64 bits: year<<48 | month<<44 | weekday<<40 | day<<32 | hour<<24 | minute<<16 | second<<8 | ms>>2
::,64>dtf ( dt64 -- )          write a dt64 as dd/mm/yyyy hh:mm
::,64>dtd ( dt64 -- )          write the date of a dt64 as d/m/yyyy followed by a space
::,64>dtt ( dt64 -- )          write the time of a dt64 as hh:mm:ss
::64>dtc ( dt64 -- )           write a dt64 as date and time (BUG: it writes "yyyy mm-dd-hh:mm:ss"; the separator after the year should be - and the one after the day a space)
```

---

### dbtxt.r3

Text database: fields are separated by `|` and records by `^`.

**Dependencies:** `^r3/lib/console.r3`

```
##rowdb    current row pointer after search

-- File Loading --
::getnfilename ( n "path" -- filename/0 )  name of the nth file of a folder (Windows only: it uses the Windows directory entry layout); 0 if there are fewer
::loadnfile ( "path" -- filename )         incremental: each call returns the next file name of the folder, the position is kept in the file "path.now" and wraps to the first (Windows only)
::loaddb-i ( "filename" -- )               incremental: load the record number kept in "filename.now" and split it in fields (read them with dbfld), then advance to the next record (wraps at the end)
::prevdb-i ( "filename" -- )               step the position kept in "filename.now" back one record (the next loaddb-i loads the previous one)
::loaddb ( "filename" -- 'db )             load a text database (records field|field|..^) at here, where it stays, and return its address; 0 if the file is empty or missing

-- Record Iteration --
::>>line ( adr -- adr' )                   address after the next ^ (end of record), or the final 0 if there is none

-- Field Access --
::dbfld ( nro -- str )                     field nro (0 is the first) of the record loaded with loaddb-i; an empty string if there are fewer fields
::getdbrow ( id 'db -- 'row )              address of record number id (0 is the first) of a database loaded with loaddb
::findbrow ( 'key 'db -- 'row/0 )          first record whose first 8 bytes equal the 8 bytes at 'key (the original comment called it hash); 0 if none
::cntdbrow ( 'db -- cnt )                  number of records (count of ^); 0 if 'db is 0
::>>fld ( adr -- adr' )                    address after the next | (next field); it stops at a ^ (end of record) without skipping it
::getdbfld ( nro 'row -- 'fld )            address of field nro (0 is the first) of a record; the field ends at | or ^, not at a 0
::cpydbfld ( 'fld 'str -- )                copy the text of a field (up to | or ^) to 'str with a final 0
::cpydbfldn ( max 'fld 'str -- )           like cpydbfld copying at most max characters
```

---

### filedirs.r3

Filesystem scanner providing file/directory trees for UI list and tree widgets.

**Dependencies:** `^r3/lib/mem.r3`, `^r3/util/datetime.r3`, `^r3/util/tui.r3`

```
##uiDirs     pointer to directory list
##uiFiles    pointer to file list

-- File Path Operations --
::flcpy ( 'file 'str -- )                 copy a list entry up to | or the final 0 into 'str, with a final 0
::flTreePath ( n -- str )                 path of node n of the tree shown by the tui tree widget (it uses the widget state of tui: only meaningful inside it)

-- Scanning --
::FlGetFiles ( "path" -- )                fill uiFiles with the names of the files (no folders) of the folder; the memory was reserved by flScanDir
::flScanDir ( "path" -- )                 scan the folders under path recursively into uiDirs and reserve 64 KB for uiFiles; call it only once
::flScanFullDir ( "path" -- )             like flScanDir but uiDirs also has the files (the folders end with /)
::flOpenFullPath ( "root/a/b" -- place )  open the folders of a path in the uiDirs list of flScanFullDir (the first component, the root, is skipped; the string is modified); returns the row of the last entry in the visible tree
```

---

*End of r3forth `util/` Library Reference*

```
::flOpenSearch ( "text" -- adr/0 )  first entry of uiDirs that contains the text (ignoring case): its folders are opened and its address is returned; 0 if not found
::flCloseAll ( -- )                 close all the folders of uiDirs
```


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
"hello" 'buf strcpy                          | copy to a buffer
"hello world" "hello" =pre 1? ( "yes" .print ) drop drop     | starts with
"file.txt" ".txt" =pos 1? ( "yes" .print ) drop drop        | ends with
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
"." ffirst ( 1?                | on Windows: ".//*"
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
255 42 "Value: %d Hex: %h" sprint
| Result: "Value: 42 Hex: FF" (the first % takes the top of the stack)
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
$FF 42 "The answer is %d (hex: %h)" .println
```

---

## Notes

- **Stack notation:** `before -- after`
- **Conditionals:** followed by a `( )` block (inside a loop they end it when they fail)
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
