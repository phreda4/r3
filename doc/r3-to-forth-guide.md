# R3forth Quick Reference for FORTH programmers

## Critical Differences from Standard Forth

### 1. **Compilation Model**
- **ALL code is compiled first, then executed** (not interactive like standard Forth)
- When we say "push to stack" = "compile code to push to stack"
- When we say "execute" = "compile code to execute the word"

### 2. **Forward References NOT Allowed**
Words must be defined BEFORE use:
```forth
| ✗ WRONG - word2 not yet defined
:word1 word2 ;
:word2 ... ;

| ✓ CORRECT
:word2 ... ;
:word1 word2 ;
```

### 3. **No IF-ELSE Construction**
R3forth uses conditionals with code blocks instead:
```forth
| Standard Forth style (NOT valid in R3):
| IF action1 ELSE action2 THEN

| R3forth style:
condition? ( action1 ; )  | Early exit if true
action2                    | Execute if false
```

### 4. **Conditionals Coupled with Code Blocks**
**CRITICAL:** In R3forth, conditionals are ALWAYS followed by `( )` blocks and DON'T leave booleans on stack:

```forth
| Standard Forth (leaves boolean):
| 5 3 > IF ... THEN     → evaluates to true/false on stack

| R3forth (no boolean, direct execution):
5 3 >? ( ... )          → executes block if true, NO stack effect
```

**The conditional and block are ONE unit** - you cannot separate them:
```forth
| ✗ WRONG - Cannot use conditional alone
5 3 >?    | ERROR: missing ( ) block

| ✓ CORRECT - Always paired with block
5 3 >? ( "greater" .print )
```

## Core Syntax

### Prefixes (8 types)

| Prefix | Purpose | Example |
|--------|---------|---------|
| `\|` | Comment | `\| This is a comment` |
| `^` | Include file | `^r3/lib/console.r3` |
| `"` | String literal | `"Hello World"` |
| `:` | Code definition | `:myword ... ;` |
| `#` | Data definition | `#var 100` |
| `$` | Hexadecimal | `$FF` → 255 |
| `%` | Binary | `%1010` → 10 |
| `'` | Address of word | `'word` |

### Program Structure
```forth
| 1. Includes
^r3/lib/needed.r3

| 2. Data definitions
#globalvar 0

| 3. Private words
:helper ... ;

| 4. Public words (exported)
::public-word ... ;

| 5. Entry point (ALWAYS last line)
: main-word ;
```

## Stack Operations

### Stack Notation: `| before -- after description`

### Basic Stack Manipulation

| Word | Effect | Description |
|------|--------|-------------|
| `DUP` | `a -- a a` | Duplicate TOS |
| `DROP` | `a --` | Remove TOS |
| `SWAP` | `a b -- b a` | Exchange top two |
| `OVER` | `a b -- a b a` | Copy second to top |
| `NIP` | `a b -- b` | Remove second |
| `ROT` | `a b c -- b c a` | Rotate three left |
| `-ROT` | `a b c -- c a b` | Rotate three right |
| `PICK2` | `a b c -- a b c a` | Copy third to top |
| `PICK3` | `a b c d -- a b c d a` | Copy fourth to top |
| `PICK4` | `a b c d e -- a b c d e a` | Copy fifth to top |

### Multi-Element Stack Operations

| Word | Effect | Description |
|------|--------|-------------|
| `2DUP` | `a b -- a b a b` | Duplicate top two |
| `2DROP` | `a b --` | Remove top two |
| `3DROP` | `a b c --` | Remove top three |
| `4DROP` | `a b c d --` | Remove top four |
| `2OVER` | `a b c d -- a b c d a b` | Copy 3rd and 4th to top |
| `2SWAP` | `a b c d -- c d a b` | Exchange top two pairs |

**Critical Rule:** Every word must balance its stack effect!

## Conditionals - MAJOR DIFFERENCE

### Stack-Only Tests (DON'T consume value)

| Word | Test | Leaves Value |
|------|------|--------------|
| `0?` | `a = 0` | `a` on stack |
| `1?` | `a ≠ 0` | `a` on stack |
| `+?` | `a ≥ 0` | `a` on stack |
| `-?` | `a < 0` | `a` on stack |

### Comparison Tests (consume TOS, keep NOS)

| Word | Test | Stack Effect |
|------|------|--------------|
| `=?` | `a = b` | `a b -- a` (consumes b) |
| `<?` | `a < b` | `a b -- a` (consumes b) |
| `>?` | `a > b` | `a b -- a` (consumes b) |
| `<=?` | `a ≤ b` | `a b -- a` (consumes b) |
| `>=?` | `a ≥ b` | `a b -- a` (consumes b) |
| `<>?` | `a ≠ b` | `a b -- a` (consumes b) |

### Logical Tests (consume TOS, keep NOS)

| Word | Test | Stack Effect |
|------|------|--------------|
| `AND?` | `(a AND b) ≠ 0` | `a b -- a` (consumes b) |
| `NAND?` | `(a NAND b) ≠ 0` | `a b -- a` (consumes b) |

### Ternary Range Test (consume TOS and NOS, keep 3OS)

| Word | Test | Stack Effect |
|------|------|--------------|
| `IN?` | `b ≤ a ≤ c` | `a b c -- a` (consumes b and c) |

**Example:**
```forth
x 5 10 IN? ( "Between 5 and 10" .print ) drop
| Tests if 5 ≤ x ≤ 10 (inclusive)
```

### Conditional Execution Pattern

```forth
value condition? ( code-if-true ) code-after

| Example:
x 5 >? ( "Greater" .print )  | If x>5, print message
drop                          | MUST drop x when done!
```

### Critical Pattern: Value Persists After Test

```forth
| The tested value STAYS on stack!
x 0? ( "Zero" .print )
  +? ( "Positive" .print )  | x still there!
drop  | Clean up at end
```

### Early Exit Pattern (replaces IF-ELSE)

```forth
:min | a b -- min
    over >? ( drop ; )  | If a>b, drop b and return a
    nip ;               | Otherwise drop a and return b
```

## Arithmetic Operations

### Basic Arithmetic

| Word | Effect | Description |
|------|--------|-------------|
| `+` | `a b -- c` | c = a + b |
| `-` | `a b -- c` | c = a - b |
| `*` | `a b -- c` | c = a × b |
| `/` | `a b -- c` | c = a ÷ b (integer division) |
| `MOD` | `a b -- c` | c = a mod b (remainder) |
| `/MOD` | `a b -- c d` | c = a÷b, d = a mod b |
| `NEG` | `a -- -a` | Negate |
| `ABS` | `a -- \|a\|` | Absolute value |
| `SQRT` | `a -- √a` | Integer square root |
| `CLZ` | `a -- n` | Count leading zeros |

### Double-Precision Arithmetic (NO bit loss)

**CRITICAL for accurate calculations:**

| Word | Effect | Description |
|------|--------|-------------|
| `*/` | `a b c -- d` | d = (a×b)÷c without overflow |
| `*>>` | `a b c -- d` | d = (a×b)>>c without bit loss |
| `<</` | `a b c -- d` | d = (a<<c)÷b without bit loss |

**Why important:** Prevents overflow in intermediate calculations:
```forth
| Example: Scale from 0-100 to 0-255
75 255 100 */    | = (75×255)÷100 = 191 (no overflow!)

| For custom fixed-point (e.g., 24.8 format):
a b 8 *>>        | Multiply two 24.8 numbers
a b 8 <</        | Divide two 24.8 numbers
```

### Bit Operations

| Word | Effect | Description |
|------|--------|-------------|
| `<<` | `a b -- c` | c = a << b (shift left) |
| `>>` | `a b -- c` | c = a >> b (signed shift right) |
| `>>>` | `a b -- c` | c = a >>> b (unsigned shift right) |
| `AND` | `a b -- c` | Bitwise AND |
| `OR` | `a b -- c` | Bitwise OR |
| `XOR` | `a b -- c` | Bitwise XOR |
| `NOT` | `a -- b` | Bitwise NOT (all bits flipped) |
| `NAND` | `a b -- c` | Bitwise NAND |

**Examples:**
```forth
5 2 <<      | = 20 (5 × 4)
$FF $55 AND | = $55
0 NOT       | = -1 (all bits set)
```

### Countdown Loop (PREFERRED - faster)

```forth
10 ( 1?    | While count ≠ 0
    dup process
    1 -
) drop
```

### Count-up Loop

```forth
0 ( 10 <?  | While count < 10
    dup process
    1 +
) drop
```

### Critical Loop Rules
1. Each iteration MUST leave stack at same height
2. Use countdown with `1?` when possible (no consumption = faster)
3. Multiple exit conditions are allowed

## Memory Operations

### Data Sizes

| Size | Fetch | Store | Fetch+ | Store+ | Bytes |
|------|-------|-------|--------|--------|-------|
| byte | `c@` | `c!` | `c@+` | `c!+` | 1 |
| word | `w@` | `w!` | `w@+` | `w!+` | 2 |
| dword | `d@` | `d!` | `d@+` | `d!+` | 4 |
| qword | `@` | `!` | `@+` | `!+` | 8 |

**Increment:** `@+` versions advance pointer by size (NOT always 8!)

### Variables

```forth
#var              | One qword (8 bytes), value 0
#var 100          | One qword, value 100
#var 10 20        | Two qwords: 10, 20
#buffer * 1000    | 1000 bytes allocated

| Access:
5 'var !          | Store 5 in var
'var @            | Fetch from var
var               | Same as 'var @ (pushes value)
1 'var +!         | Add 1 to var
```

## Registers A and B

**Fast temporary storage** for addresses:

```forth
| Register A operations
>A    | Load A
A>    | Push A value
A+    | Add to A
A@    | Fetch qword from address in A
A@+   | Fetch and increment A by 8
cA@+  | Fetch byte and increment A by 1

| Register B - identical operations
>B B> B+ B@ B@+ cB@+
```

**Use Case:** Linear memory traversal
```forth
'array >a         | Load address into A
100 ( 1? 1-
    a@+ process   | Fetch from A and advance
) drop
```

**Warning:** Registers are NOT preserved across word calls!

### Register Save/Restore

| Word | Effect | Description |
|------|--------|-------------|
| `AB[` | `--` | Save A and B to return stack |
| `]BA` | `--` | Restore B and A from return stack |

```forth
:safe-register-use | --
    AB[              | Save current A and B
    'data >a         | Use register A
    | ... work ...
    ]BA ;            | Restore original values
```

## Return Stack Operations

| Word | Effect | Description |
|------|--------|-------------|
| `>R` | `a -- (r: -- a)` | Push to return stack |
| `R>` | `-- a (r: a --)` | Pop from return stack |
| `R@` | `-- a (r: a -- a)` | Copy top of return stack |

⚠️ **WARNING:** Return stack imbalance will crash! Use with extreme care.

## Strings

### Two Types of String Storage

1. **In code** (read-only constants):
```forth
:msg "Hello" ;  | String in separate constant area
```

2. **In data** (writable):
```forth
#text "Hello"   | String in variable memory, null-terminated
```

### String Format Codes (sprint from library)
```forth
"%d"  | Decimal number
"%h"  | Hexadecimal
"%b"  | Binary
"%s"  | String from address
```

## Memory Management

### Static Memory (Variables)
```forth
#var1 100         | 8 bytes
#var2 [ 200 ]     | 4 bytes (dword)
#var3 ( 50 )      | 1 byte
```

### Dynamic Memory
```forth
MEM     | -- addr   Start of free memory
HERE    | -- var    Variable with next free address
MARK    | --        Save current HERE
EMPTY   | --        Restore HERE (release memory)

| Pattern:
MARK              | Mark current position
HERE 1000 + 'HERE !  | Allocate 1000 bytes
| ... use memory ...
EMPTY             | Release allocation
```

## Common Patterns

### Safe Division
```forth
:safe-div | a b -- result
    0? ( ; )  | Return 0 if dividing by 0
    / ;
```

### Array Traversal
```forth
'array >a
100 ( 1? 1-
    a@+ process
) drop
```

## Critical Rules for AI Code Generation

### ✓ DO:
1. Define all words BEFORE using them
2. Balance stack in every word (not balance when pasing parameters)
3. Use countdown loops with `1?`
4. Drop values after conditionals
5. Use early exit with `;` instead of IF-ELSE
6. Comment stack effects: `| before -- after`

### ✗ DON'T:
1. Use forward references
2. Assume IF-ELSE exists
3. Forget that conditionals KEEP the tested value
4. Use registers across word calls without saving
5. Mix interactive and compiled code concepts
6. Forget semicolon `;` to end word execution

## Minimal Working Example

```forth
^r3/lib/console.r3

#counter 0

:increment | --
    1 'counter +! ;

:show | --
    counter "%d" .print .cr ;

:main | --
    10 ( 1? 1-
        increment
        show
    ) drop ;

: main ;  | Entry point - ALWAYS last line
```

## Semicolon Behavior - IMPORTANT

The semicolon `;` ENDS execution and returns to caller:
- Can have multiple `;` in one word (multiple exit points)
- Can have NO `;` (falls through - advanced)
- Semicolon is about CONTROL FLOW, not just syntax

```forth
:example | n -- result
    0? ( ; )        | Exit point 1: return 0 if input is 0
    1 =? ( ; )      | Exit point 2: return 1 if input is 1  
    dup * ;         | Exit point 3: return n²
```

## Library Basics

### Console Output
```forth
^r3/lib/console.r3

.print    | "text" -- print formatted text
.println  | "text" -- print text + newline
.cr       | -- print newline
```

### Graphics (SDL2)
```forth
^r3/lib/sdl2.r3

SDLinit   | "title" w h -- initialize window
SDLcls    | color -- clear screen
SDLredraw | -- refresh display
SDLshow   | 'word -- run word each frame
```

## Memory Layout Summary

```
CODE MEMORY     (compiled definitions)
↓
STRING CONSTANTS (strings in : definitions)
↓
VARIABLE MEMORY  (# definitions)
↓
HERE →
FREE MEMORY     (dynamic allocation)
```

## Fixed Point Math (48.16 format)

```forth
1.5      | Stored as 98304 (1.5 * 65536)

| In r3/lib/math.r3:
*.       | f f -- f   multiply fixed point
/.       | f f -- f   divide fixed point
int.     | f -- n     convert to integer
```

## Quick Debugging

```forth
| Print stack value without consuming
:debug | a -- a
    dup "%d" .print .cr ;

| Usage:
5 3 + debug  | Shows 8, leaves 8 on stack
```

---

## Most Common Errors

1. **Forward reference**: Define words in order of dependency
2. **Missing DROP**: Conditionals leave tested value on stack
3. **Stack imbalance**: Count inputs vs outputs in loops
4. **Wrong loop type**: Use countdown `( 1?` not count-up when possible
5. **Semicolon confusion**: `;` exits immediately, like return

## Key Difference Summary for AI

| Concept | Standard Forth | R3forth |
|---------|---------------|---------|
| Execution | Interactive | Fully compiled |
| IF-ELSE | `IF ELSE THEN` | Early exit with `;` |
| Conditionals | Consume & leave boolean | Coupled with `( )`, no boolean |
| Forward refs | Sometimes OK | Never allowed |
| Loop preference | COUNT loop | COUNTDOWN loop |
| Definition order | Flexible | Strict (top-to-bottom) |
| Conditional usage | `5 3 > IF ... THEN` | `5 3 >? ( ... )` (always with block) |

---

## Complete Base Dictionary

### Control Flow

| Word | Effect | Description |
|------|--------|-------------|
| `;` | `--` | End word execution (return) |
| `(` | `--` | Begin code block |
| `)` | `--` | End code block |
| `[` | `-- vec` | Begin anonymous definition |
| `]` | `vec --` | End anonymous definition |
| `EX` | `vec --` | Execute word by address |

### All Stack Operations

| Word | Effect | Description |
|------|--------|-------------|
| `DUP` | `a -- a a` | Duplicate TOS |
| `DROP` | `a --` | Remove TOS |
| `SWAP` | `a b -- b a` | Exchange top two |
| `OVER` | `a b -- a b a` | Copy second to top |
| `NIP` | `a b -- b` | Remove second |
| `ROT` | `a b c -- b c a` | Rotate three left |
| `-ROT` | `a b c -- c a b` | Rotate three right (inverse) |
| `PICK2` | `a b c -- a b c a` | Copy third to top |
| `PICK3` | `a b c d -- a b c d a` | Copy fourth to top |
| `PICK4` | `a b c d e -- a b c d e a` | Copy fifth to top |
| `2DUP` | `a b -- a b a b` | Duplicate top two |
| `2DROP` | `a b --` | Remove top two |
| `3DROP` | `a b c --` | Remove top three |
| `4DROP` | `a b c d --` | Remove top four |
| `2OVER` | `a b c d -- a b c d a b` | Copy 3rd,4th to top |
| `2SWAP` | `a b c d -- c d a b` | Exchange top two pairs |

### All Conditional Tests

**Stack-only (don't consume):**
| Word | Test | Effect |
|------|------|--------|
| `0?` | `a = 0` | `a -- a` |
| `1?` | `a ≠ 0` | `a -- a` |
| `+?` | `a ≥ 0` | `a -- a` |
| `-?` | `a < 0` | `a -- a` |

**Comparisons (consume TOS):**
| Word | Test | Effect |
|------|------|--------|
| `=?` | `a = b` | `a b -- a` |
| `<?` | `a < b` | `a b -- a` |
| `>?` | `a > b` | `a b -- a` |
| `<=?` | `a ≤ b` | `a b -- a` |
| `>=?` | `a ≥ b` | `a b -- a` |
| `<>?` | `a ≠ b` | `a b -- a` |
| `AND?` | `(a AND b) ≠ 0` | `a b -- a` |
| `NAND?` | `(a NAND b) ≠ 0` | `a b -- a` |
| `IN?` | `b ≤ a ≤ c` | `a b c -- a` |

### All Arithmetic Operations

| Word | Effect | Description |
|------|--------|-------------|
| `+` | `a b -- c` | Addition |
| `-` | `a b -- c` | Subtraction |
| `*` | `a b -- c` | Multiplication |
| `/` | `a b -- c` | Integer division |
| `MOD` | `a b -- c` | Modulo (remainder) |
| `/MOD` | `a b -- c d` | Divide and modulo |
| `*/` | `a b c -- d` | (a×b)÷c no overflow |
| `*>>` | `a b c -- d` | (a×b)>>c no bit loss |
| `<</` | `a b c -- d` | (a<<c)÷b no bit loss |
| `NEG` | `a -- -a` | Negate |
| `ABS` | `a -- \|a\|` | Absolute value |
| `SQRT` | `a -- √a` | Integer square root |
| `CLZ` | `a -- n` | Count leading zeros |

### All Bit Operations

| Word | Effect | Description |
|------|--------|-------------|
| `<<` | `a b -- c` | Shift left |
| `>>` | `a b -- c` | Signed shift right |
| `>>>` | `a b -- c` | Unsigned shift right |
| `AND` | `a b -- c` | Bitwise AND |
| `OR` | `a b -- c` | Bitwise OR |
| `XOR` | `a b -- c` | Bitwise XOR |
| `NOT` | `a -- b` | Bitwise NOT |
| `NAND` | `a b -- c` | Bitwise NAND |

### All Memory Operations

**Qword (8 bytes):**
| Word | Effect | Description |
|------|--------|-------------|
| `@` | `addr -- val` | Fetch qword |
| `!` | `val addr --` | Store qword |
| `@+` | `addr -- addr+8 val` | Fetch and increment |
| `!+` | `val addr -- addr+8` | Store and increment |
| `+!` | `val addr --` | Add to memory |

**Dword (4 bytes):**
| Word | Effect | Description |
|------|--------|-------------|
| `D@` | `addr -- val` | Fetch dword |
| `D!` | `val addr --` | Store dword |
| `D@+` | `addr -- addr+4 val` | Fetch and increment |
| `D!+` | `val addr -- addr+4` | Store and increment |
| `D+!` | `val addr --` | Add to dword |

**Word (2 bytes):**
| Word | Effect | Description |
|------|--------|-------------|
| `W@` | `addr -- val` | Fetch word |
| `W!` | `val addr --` | Store word |
| `W@+` | `addr -- addr+2 val` | Fetch and increment |
| `W!+` | `val addr -- addr+2` | Store and increment |
| `W+!` | `val addr --` | Add to word |

**Byte (1 byte):**
| Word | Effect | Description |
|------|--------|-------------|
| `C@` | `addr -- val` | Fetch byte |
| `C!` | `val addr --` | Store byte |
| `C@+` | `addr -- addr+1 val` | Fetch and increment |
| `C!+` | `val addr -- addr+1` | Store and increment |
| `C+!` | `val addr --` | Add to byte |

### All Register A Operations

| Word | Effect | Description |
|------|--------|-------------|
| `>A` | `val --` | Load register A |
| `A>` | `-- val` | Push register A |
| `A+` | `val --` | Add to register A |
| `A@` | `-- val` | Fetch qword from A |
| `A!` | `val --` | Store qword at A |
| `A@+` | `-- val` | Fetch qword, A += 8 |
| `A!+` | `val --` | Store qword, A += 8 |
| `DA@` | `-- val` | Fetch dword from A |
| `DA!` | `val --` | Store dword at A |
| `DA@+` | `-- val` | Fetch dword, A += 4 |
| `DA!+` | `val --` | Store dword, A += 4 |
| `CA@` | `-- val` | Fetch byte from A |
| `CA!` | `val --` | Store byte at A |
| `CA@+` | `-- val` | Fetch byte, A += 1 |
| `CA!+` | `val --` | Store byte, A += 1 |

### All Register B Operations

| Word | Effect | Description |
|------|--------|-------------|
| `>B` | `val --` | Load register B |
| `B>` | `-- val` | Push register B |
| `B+` | `val --` | Add to register B |
| `B@` | `-- val` | Fetch qword from B |
| `B!` | `val --` | Store qword at B |
| `B@+` | `-- val` | Fetch qword, B += 8 |
| `B!+` | `val --` | Store qword, B += 8 |
| `DB@` | `-- val` | Fetch dword from B |
| `DB!` | `val --` | Store dword at B |
| `DB@+` | `-- val` | Fetch dword, B += 4 |
| `DB!+` | `val --` | Store dword, B += 4 |
| `CB@` | `-- val` | Fetch byte from B |
| `CB!` | `val --` | Store byte at B |
| `CB@+` | `-- val` | Fetch byte, B += 1 |
| `CB!+` | `val --` | Store byte, B += 1 |

### Register Save/Restore

| Word | Effect | Description |
|------|--------|-------------|
| `AB[` | `--` | Save A,B to return stack |
| `]BA` | `--` | Restore B,A from return stack |

### Return Stack

| Word | Effect | Description |
|------|--------|-------------|
| `>R` | `a -- (r: -- a)` | Push to return stack |
| `R>` | `-- a (r: a --)` | Pop from return stack |
| `R@` | `-- a (r: a -- a)` | Copy top of return stack |

### Memory Block Operations

| Word | Effect | Description |
|------|--------|-------------|
| `MOVE` | `dest src cnt --` | Copy cnt qwords |
| `MOVE>` | `dest src cnt --` | Copy cnt qwords reverse |
| `FILL` | `dest val cnt --` | Fill cnt qwords |
| `CMOVE` | `dest src cnt --` | Copy cnt bytes |
| `CMOVE>` | `dest src cnt --` | Copy cnt bytes reverse |
| `CFILL` | `dest val cnt --` | Fill cnt bytes |
| `DMOVE` | `dest src cnt --` | Copy cnt dwords |
| `DMOVE>` | `dest src cnt --` | Copy cnt dwords reverse |
| `DFILL` | `dest val cnt --` | Fill cnt dwords |

### Memory Management

| Word | Effect | Description |
|------|--------|-------------|
| `MEM` | `-- addr` | Start of free memory |
| `HERE` | `-- var` | Variable: next free address |
| `MARK` | `--` | Save HERE position |
| `EMPTY` | `--` | Restore HERE position |

### System Interface

| Word | Effect | Description |
|------|--------|-------------|
| `LOADLIB` | `"name" -- lib` | Load dynamic library |
| `GETPROC` | `lib "name" -- addr` | Get function address |
| `SYS0` to `SYS10` | `... addr -- result` | Call with 0-10 params |

---

## Critical Notes

### 1. Conditional Blocks Are Mandatory
```forth
| ✗ WRONG - Conditional without block
x 5 >?
drop

| ✓ CORRECT - Always use ( ) with conditionals
x 5 >? ( "greater" .print )
drop
```

### 2. No Boolean Logic Separate from Conditionals
```forth
| ✗ WRONG - Standard Forth style (not valid)
5 3 > IF ... THEN

| ✓ CORRECT - R3forth style
5 3 >? ( ... )
```

### 3. Double-Precision Math for Scaling
```forth
| ✗ WRONG - May overflow
big-number 1000 * 1000000 /

| ✓ CORRECT - Use */ to prevent overflow
big-number 1000 1000000 */
```

### 4. IN? for Range Checking
```forth
| ✗ INEFFICIENT - Multiple comparisons
x 5 >=? ( 10 <=? ( "in range" .print ) )

| ✓ CORRECT - Use IN?
x 5 10 IN? ( "in range" .print )
```

### 5. Register Operations Not Preserved
```forth
| ✗ WRONG - Assumes A is preserved
:outer
    'data >a
    helper-word    | May destroy A!
    a@ process ;

| ✓ CORRECT - Use AB[ ]BA or pass on stack
:outer
    AB[
    'data >a
    helper-word
    a@ process
    ]BA ;
```

### 6. Memory Increment Sizes
```forth
| REMEMBER: @+ variants increment by their SIZE
'buffer @+     | Increments by 8 (qword)
'buffer d@+    | Increments by 4 (dword)
'buffer w@+    | Increments by 2 (word)
'buffer c@+    | Increments by 1 (byte)
```

### 7. Stack Balance in Loops
```forth
| ✗ WRONG - Stack grows
10 ( 1? 1-
    dup process    | Leaves value on stack!
) drop

| ✓ CORRECT - Consume or drop
10 ( 1? 1-
    dup process drop
) drop
```

## Common Patterns for AI

### Pattern: Clamp/Bounds
```forth
:clamp | val min max -- clamped
    rot over <? ( nip ; ) nip    | Check minimum
    over >? ( drop ; ) nip ;      | Check maximum
```

### Pattern: Array Processing
```forth
:process-array | addr count --
    ( 1? 1-
        swap @+ process-item swap
    ) 2drop ;

| Or with register:
:process-array | addr count --
    swap >a
    ( 1? 1-
        a@+ process-item
    ) drop ;
```

### Pattern: Safe Division
```forth
:safe-div | a b -- result
    0? ( ; )
    / ;
```

### Pattern: Switch/Case
```forth
#actions 'action0 'action1 'action2

:dispatch | n --
    3 <<                  | n * 8 (qword size)
    'actions + @ ex ;     | Get and execute action
```

### Pattern: Range Map (with */)
```forth
| Map value from [0..100] to [0..255]
:map-0-100-to-0-255 | n -- mapped
    255 100 */ ;

| Map with custom ranges [in_min..in_max] to [out_min..out_max]
:map-range | val in_min in_max out_min out_max --
    >r >r               | Save out_min, out_max
    over - rot rot -    | (in_max-in_min) (val-in_min)
    r> r>               | (in_max-in_min) (val-in_min) out_min out_max
    over - rot rot      | (out_max-out_min) (in_max-in_min) (val-in_min)
    swap */ + ;         | out_min + (val-in_min)*(out_max-out_min)/(in_max-in_min)
```

### Pattern: Fixed Point (24.8 example)
```forth
| Multiply two 24.8 fixed point numbers
:fp-mul | a b -- result
    8 *>> ;

| Divide two 24.8 fixed point numbers
:fp-div | a b -- result
    8 <</ ;
```

## Most Common AI Generation Errors

### Error 1: Using Standalone Conditionals
```forth
| ✗ AI MIGHT GENERATE (WRONG):
x 5 >
IF do-something THEN

| ✓ CORRECT R3FORTH:
x 5 >? ( do-something )
```

### Error 2: Forgetting DROP After Chained Conditionals
```forth
| ✗ WRONG:
x 0? ( "zero" .print )
  5 =? ( "five" .print )
  | x still on stack!

| ✓ CORRECT:
x 0? ( "zero" .print )
  5 =? ( "five" .print )
drop
```

### Error 3: Using Forward References
```forth
| ✗ WRONG ORDER:
:main helper ;
:helper "text" .print ;

| ✓ CORRECT ORDER:
:helper "text" .print ;
:main helper ;
```

### Error 4: Not Using Double-Precision
```forth
| ✗ MAY OVERFLOW:
12345 6789 * 1000 /

| ✓ SAFE:
12345 6789 1000 */
```

### Error 5: Assuming Boolean Result
```forth
| ✗ WRONG (thinking like C/JavaScript):
:is-positive | n -- bool
    0 > ;        | ERROR: > is not a word!

| ✓ CORRECT:
:is-positive | n -- bool
    0 >? ( drop 1 ; )
    drop 0 ;

| ✓ BETTER (if you just need the test):
:process-if-positive | n --
    0 >? ( process ; )
    drop ;
```

### Error 6: Wrong Memory Increment Assumption
```forth
| ✗ WRONG (assuming always +1):
'buffer c@+ swap c@+ swap c@    | Gets 3 bytes at offsets 0,1,2 ✓

| ✗ WRONG (assuming always +1):
'buffer @+ swap @+ swap @       | Gets 3 qwords at offsets 0,8,16 (not 0,1,2!)
```

## Quick Reference Card

### Must Remember:
1. **Conditionals ALWAYS need ( ) blocks**
2. **Conditionals DON'T leave booleans**
3. **Define words BEFORE using them**
4. **Countdown loops are faster**
5. **Use */ for scaled math**
6. **Use IN? for range checks**
7. **Drop values after conditional chains**
8. **@+ increments by SIZE, not always 1**

### Common Fixes:
| If You Want | Don't Use | Use Instead |
|-------------|-----------|-------------|
| If-else | `IF THEN ELSE` | Early exit with `;` |
| Boolean AND | `AND` alone | `AND?` with `( )` |
| Range test | Multiple `<?` `>?` | `IN?` |
| Scale value | `* /` separate | `*/` |
| Forward ref | Define later | Define earlier |
| Boolean result | Comparison alone | Conditional with return values |

---

**Remember:** R3forth encourages factoring code into small, single-purpose words rather than complex control structures. When unsure, break the problem into simpler words.

## Example: Complete Pattern

```forth
^r3/lib/console.r3

#value 0
#min 0
#max 100

| Helper words defined FIRST
:in-range? | val -- val flag
    min max IN? ( 1 ; )
    0 ;

:clamp-value | val -- clamped
    min max clamp ;

:process-value | --
    value in-range?
    1 =? ( value "Value %d in range" .print drop ; )
    drop
    value clamp-value 'value !
    "Value clamped to %d" .print ;

| Main program defined LAST
:main | --
    150 'value !
    process-value ;

: main ;  | Entry point
```
