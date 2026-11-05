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

The library words (`math.r3`, `str.r3`, `mem.r3`, `core.r3`, `console.r3`, `sdl2.r3`, ...) are
described in `r3forth-libs.md` and `r3forth-util.md`.

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
