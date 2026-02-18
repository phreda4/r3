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

---

## Table of Contents

1. [Control Flow](#control-flow)
2. [Conditionals](#conditionals)
3. [Stack Operations](#stack-operations)
4. [Arithmetic Operations](#arithmetic-operations)
5. [Logical Operations](#logical-operations)
6. [Fixed-Point Operations](#fixed-point-operations)
7. [Memory Operations](#memory-operations)
8. [Register Operations](#register-operations)
9. [Memory Block Operations](#memory-block-operations)
10. [Return Stack](#return-stack)
11. [System Interface](#system-interface)
12. [Library: console.r3](#library-consoler3)
13. [Library: core.r3](#library-corer3)
14. [Library: rand.r3](#library-randr3)
15. [Library: math.r3](#library-mathr3)
16. [Library: sdl2.r3](#library-sdl2r3)
17. [Library: sdl2gfx.r3](#library-sdl2gfxr3)
18. [Library: sdl2image.r3](#library-sdl2imager3)
19. [Glossary](#glossary)

---

## Control Flow

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `;` | `--` | End word execution, return to caller |
| `(` | `--` | Begin code block |
| `)` | `--` | End code block |
| `[` | `-- vec` | Begin anonymous word definition |
| `]` | `vec --` | End anonymous word definition |
| `EX` | `vec --` | Execute word by address |

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
:word2
    part-b ;

:word1
    part-a              | no ; — falls through to word2

word1   | executes part-a, then part-b
word2   | executes part-b only
```

---

## Conditionals

### Unary Conditionals (do not consume stack)

| Word | Stack Effect | True when |
|------|--------------|-----------|
| `0?` | `a -- a` | a = 0 |
| `1?` | `a -- a` | a ≠ 0 |
| `-?` | `a -- a` | a < 0 |
| `+?` | `a -- a` | a ≥ 0 |

### Binary Conditionals (consume TOS, leave NOS)

`a b OP?` tests NOS (`a`) against TOS (`b`). TOS is consumed. NOS remains.

| Word | Stack Effect | True when |
|------|--------------|-----------|
| `=?` | `a b -- a` | a = b |
| `<?` | `a b -- a` | a < b |
| `<=?` | `a b -- a` | a ≤ b |
| `>?` | `a b -- a` | a > b |
| `>=?` | `a b -- a` | a ≥ b |
| `<>?` | `a b -- a` | a ≠ b |
| `AND?` | `a b -- a` | a AND b ≠ 0 |
| `NAND?` | `a b -- a` | a NAND b ≠ 0 |
| `IN?` | `a b c -- a` | b ≤ a ≤ c (consumes both b and c) |

### Conditional Usage Pattern

```forth
value
test? ( block-if-true )
drop
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
| `ABS` | `a -- b` | b = |a| |
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
| `NAND` | `a b -- c` | c = a NAND b |
| `OR` | `a b -- c` | c = a OR b |
| `XOR` | `a b -- c` | c = a XOR b |
| `NOT` | `a -- b` | b = NOT a (all bits flipped) |

```forth
$ff $55 AND    | $55
$ff $1  NAND   | $fe
$2  $1  OR     | $3
$3  2   XOR    | $1
0       NOT    | -1  (all bits set)
```

---

## Fixed-Point Operations

R3forth uses **48.16 fixed-point format**: 48 integer bits + 16 fractional bits, stored in a 64-bit cell.

**Rule:** multiply any real number by 65536 (2¹⁶) to get the stored integer.

```
3.5 → 3.5 × 65536 = 229376
1.5 → 1.5 × 65536 = 98304
```

The language parses decimal literals automatically:

```forth
3.5       | parsed as 229376
3.14159   | parsed as 205887
```

Angles use **turns**: 1.0 = full circle, 0.5 = 180°, 0.25 = 90°.

### From `r3/lib/math.r3`

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `*.` | `f f -- f` | Fixed-point multiplication |
| `/.` | `f f -- f` | Fixed-point division |
| `int.` | `f -- a` | Convert to integer (truncate) |
| `sin` | `f -- f` | Sine (angle in turns) |
| `cos` | `f -- f` | Cosine (angle in turns) |
| `tan` | `f -- f` | Tangent (angle in turns) |
| `sqrt.` | `f -- f` | Fixed-point square root |
| `ln.` | `f -- f` | Natural logarithm |
| `exp.` | `f -- f` | Exponential (eˣ) |
| `root.` | `base root -- r` | Nth root |

---

## Memory Operations

### Fetch (read)

| Word | Stack Effect | Reads | Advances |
|------|--------------|-------|---------|
| `@` | `a -- v` | 64 bits | — |
| `D@` | `a -- v` | 32 bits | — |
| `W@` | `a -- v` | 16 bits | — |
| `C@` | `a -- v` | 8 bits | — |
| `@+` | `a -- a+8 v` | 64 bits | +8 |
| `D@+` | `a -- a+4 v` | 32 bits | +4 |
| `W@+` | `a -- a+2 v` | 16 bits | +2 |
| `C@+` | `a -- a+1 v` | 8 bits | +1 |

### Store (write)

| Word | Stack Effect | Writes | Advances |
|------|--------------|--------|---------|
| `!` | `v a --` | 64 bits | — |
| `D!` | `v a --` | 32 bits | — |
| `W!` | `v a --` | 16 bits | — |
| `C!` | `v a --` | 8 bits | — |
| `!+` | `v a -- a+8` | 64 bits | +8 |
| `D!+` | `v a -- a+4` | 32 bits | +4 |
| `W!+` | `v a -- a+2` | 16 bits | +2 |
| `C!+` | `v a -- a+1` | 8 bits | +1 |

### Modify in Place

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `+!` | `v a --` | Add v to 64-bit value at a |
| `D+!` | `v a --` | Add v to 32-bit value at a |
| `W+!` | `v a --` | Add v to 16-bit value at a |
| `C+!` | `v a --` | Add v to 8-bit value at a |

### Variable Syntax Summary

| Definition | Description |
|------------|-------------|
| `#var` | One 64-bit cell, value 0 |
| `#var n` | One 64-bit cell, value n |
| `#var n m` | Two 64-bit cells, values n and m |
| `#var [ n ]` | One 32-bit cell (dword) |
| `#var ( n )` | One 8-bit cell (byte) |
| `#var * size` | `size` bytes, zero-initialized |
| `#var "text"` | Null-terminated string bytes |
| `#var 'word` | 64-bit cell holding address of `word` |

### Dynamic Memory

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `MEM` | `-- a` | Start of free memory |
| `HERE` | `-- a` | Next free address (variable) |
| `MARK` | `--` | Push HERE onto internal stack |
| `EMPTY` | `--` | Pop HERE from internal stack (release memory) |

---

## Register Operations

Registers A and B are fast auxiliary variables optimized for memory traversal. They persist across word calls.

### Register A

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `>A` | `a --` | Set register A |
| `A>` | `-- a` | Push register A |
| `A+` | `a --` | Add to register A |
| `A@` | `-- v` | Fetch qword from address in A |
| `A!` | `v --` | Store qword at address in A |
| `A@+` | `-- v` | Fetch qword at A, then A += 8 |
| `A!+` | `v --` | Store qword at A, then A += 8 |
| `cA@` | `-- v` | Fetch byte from A |
| `cA!` | `v --` | Store byte at A |
| `cA@+` | `-- v` | Fetch byte at A, then A += 1 |
| `cA!+` | `v --` | Store byte at A, then A += 1 |
| `dA@` | `-- v` | Fetch dword from A |
| `dA!` | `v --` | Store dword at A |
| `dA@+` | `-- v` | Fetch dword at A, then A += 4 |
| `dA!+` | `v --` | Store dword at A, then A += 4 |

### Register B

Register B has identical operations: `>B`, `B>`, `B+`, `B@`, `B!`, `B@+`, `B!+`, `cB@`, `cB!`, `cB@+`, `cB!+`, `dB@`, `dB!`, `dB@+`, `dB!+`.

### Save / Restore

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `AB[` | `--` | Save A and B onto return stack |
| `]BA` | `--` | Restore A and B from return stack |

---

## Memory Block Operations

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `MOVE` | `dst src n --` | Copy n qwords from src to dst |
| `MOVE>` | `dst src n --` | Copy n qwords, reverse direction |
| `FILL` | `dst v n --` | Fill n qwords at dst with value v |
| `CMOVE` | `dst src n --` | Copy n bytes from src to dst |
| `CMOVE>` | `dst src n --` | Copy n bytes, reverse direction |
| `CFILL` | `dst v n --` | Fill n bytes at dst with byte v |
| `DMOVE` | `dst src n --` | Copy n dwords from src to dst |
| `DMOVE>` | `dst src n --` | Copy n dwords, reverse direction |
| `DFILL` | `dst v n --` | Fill n dwords at dst with dword v |

---

## Return Stack

The return stack stores return addresses during word calls. It can be used as temporary storage within a single word, but every `>R` must be matched by `R>` before any exit.

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `>R` | `a --` | Push to return stack |
| `R>` | `-- a` | Pop from return stack |
| `R@` | `-- a` | Copy top of return stack (non-destructive) |

> **Warning:** Unbalanced use of `>R` / `R>` will cause the word to return to the wrong address. Always balance within the same word, including all conditional exit paths.

---

## System Interface

Used to call functions in dynamic libraries (`.dll` / `.so`).

| Word | Stack Effect | Description |
|------|--------------|-------------|
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

**Pattern:**
```forth
"library.dll" LOADLIB 'lib !
lib @ "FunctionName" GETPROC 'fn !
arg1 arg2 fn @ SYS2 drop    | call with 2 arguments
```

---

## Library: console.r3

Include with `^r3/lib/console.r3`

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `::.cls` | `--` | Clear console |
| `::.write` | `"text" --` | Write text (no newline) |
| `::.print` | `.. "fmt" --` | Formatted output with `%` placeholders |
| `::.println` | `"text" --` | Write text + newline |
| `::.home` | `--` | Move cursor to top-left |
| `::.at` | `x y --` | Position cursor at column x, row y |
| `::.fc` | `color --` | Set foreground text color |
| `::.bc` | `color --` | Set background text color |
| `::.input` | `--` | Read a line from keyboard (result in `##pad`) |
| `::.inkey` | `-- key` | Return currently pressed key code (0 = none) |
| `::.cr` | `--` | Print newline |

### Format Specifiers for `.print`

| Specifier | Output |
|-----------|--------|
| `%d` | Decimal integer |
| `%b` | Binary integer |
| `%h` | Hexadecimal integer |
| `%s` | String (from address on stack) |
| `%%` | Literal `%` character |

```forth
42 255 "%d in hex is %h" .print
| Output: 42 in hex is ff
```

> Values are consumed from the stack in right-to-left order matching the `%` placeholders.

---

## Library: core.r3

Include with `^r3/lib/core.r3`

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `::msec` | `-- ms` | Milliseconds elapsed since program start |
| `::time` | `-- hms` | Current time packed: bits 23:16 = hours, 15:8 = minutes, 7:0 = seconds |
| `::date` | `-- ymd` | Current date packed: bits 31:16 = year, 15:8 = month, 7:0 = day |

**Unpacking time:**
```forth
time
dup 16 >> $ff and     | hours
swap 8 >> $ff and     | minutes
swap $ff and          | seconds
```

**Unpacking date:**
```forth
date
dup 16 >> $ffff and   | year
swap 8 >> $ff and     | month
swap $ff and          | day
```

---

## Library: rand.r3

Include with `^r3/lib/rand.r3`

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `::rerand` | `s1 s2 --` | Seed the random number generator |
| `::rand` | `-- n` | Generate a 64-bit random number |
| `::randmax` | `max -- n` | Random number in [0, max) |

```forth
time msec rerand       | seed with current time

100 randmax            | integer 0–99
5.0 randmax            | fixed-point 0.0–4.999…
5.0 randmax 5.0 -      | fixed-point -5.0 to -0.001…
```

---

## Library: math.r3

Include with `^r3/lib/math.r3`

All values are in 48.16 fixed-point format. Angles are in **turns** (0.0–1.0 = full circle).

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `*.` | `f f -- f` | Multiply two fixed-point numbers |
| `/.` | `f f -- f` | Divide two fixed-point numbers |
| `int.` | `f -- n` | Convert to integer (truncate) |
| `sin` | `angle -- f` | Sine |
| `cos` | `angle -- f` | Cosine |
| `tan` | `angle -- f` | Tangent |
| `sqrt.` | `f -- f` | Square root |
| `ln.` | `f -- f` | Natural logarithm |
| `exp.` | `f -- f` | Exponential (eˣ) |
| `root.` | `base root -- r` | Nth root |

```forth
| Angle examples (in turns)
0.0  sin   | 0.0  (sin  0°)
0.25 sin   | 1.0  (sin 90°)
0.5  cos   | -1.0 (cos 180°)

| Fixed-point arithmetic
3.5 2.0 *.    | 7.0
10.0 4.0 /.   | 2.5
9.0 sqrt.     | 3.0
```

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

Read these variables inside your frame word:

| Variable | Description |
|----------|-------------|
| `##SDLkey` | Code of currently pressed key (0 = none) |
| `##SDLchar` | Character representation of pressed key |
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
| `<le>` | Left arrow held down |
| `<ri>` | Right arrow held down |
| `<up>` | Up arrow held down |
| `<dn>` | Down arrow held down |

### Minimal Game Loop

```forth
^r3/lib/sdl2.r3

:update
    SDLkey >esc< =? ( exit ) drop
    SDLcls
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

### Primitives

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
| `::tscolor` | `$rrggbb 'ts --` | Tint tile sheet color |
| `::tsdraw` | `n 'ts x y --` | Draw tile n at position |
| `::tsdraws` | `n 'ts x y w h --` | Draw tile n scaled |

### Sprite Sheets

Sprites are drawn from their center.

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
| `::loadimg` | `"file" -- img` | Load PNG (with transparency) or JPG |
| `::unloadimg` | `img --` | Free image memory |

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
| **Register** | Fast temporary storage; A and B in R3forth |
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

---

## Memory Layout Summary

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

Data and code memory are **separated at compile time**, regardless of the order definitions appear in source.

---

*R3forth Reference — see the companion Tutorial document for explanations and examples.*
