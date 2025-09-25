# R3forth Programming Guide for AI/Developers

## Overview

R3forth is a concatenative, stack-based programming language derived from ColorForth. It uses a 64-bit architecture and features an explicit prefix system for word classification. The language emphasizes factorization, direct hardware access, and modern library integration through SDL2.

## Core Concepts

### Stack-Based Execution
All operations work through a data stack using postfix notation:
```forth
5 3 +     | Pushes 5, pushes 3, adds them → stack contains 8
10 dup *  | Pushes 10, duplicates it, multiplies → stack contains 100
```

### Word-Based Dictionary
Programs consist of words (space-separated tokens). The language searches a dictionary from last-defined to first-defined word.

### Compilation Process
1. Parse source code word by word
2. Numbers → push to stack
3. Known words → execute immediately
4. Prefixed words → interpret according to prefix
5. Unknown words → compilation error

## Prefix System

R3forth uses 8 prefixes to classify words explicitly:

| Prefix | Purpose | Example | Description |
|--------|---------|---------|-------------|
| `|` | Comment | `| This is a comment` | Ignored, ends at line break |
| `^` | Include | `^lib/console.r3` | Include external file |
| `"` | String | `"Hello world"` | Text literal |
| `:` | Code | `:square dup * ;` | Define executable word |
| `#` | Data | `#counter 0` | Define variable |
| `$` | Hex | `$FF` | Hexadecimal number |
| `%` | Binary | `%1010` | Binary number |
| `'` | Address | `'variable` | Get address of word |

## Basic Programming Patterns

### Variable Definition and Usage
Variables in R3forth define memory maps. When compiled, data and code memory are separated regardless of definition order:

```forth
#var            | Define one 64-bit cell with value 0
#var 33         | Define one cell with value 33  
#var 33 11      | Two cells: first=33, second=11 (16 bytes total)

| Mixed data types in one definition:
#data 33 11 [ 1 2 ] ( 3 4 )
| Memory layout at 'data:
| +0:  33 (8 bytes - qword)
| +8:  11 (8 bytes - qword) 
| +16: 1  (4 bytes - dword, from [ ])
| +20: 2  (4 bytes - dword)
| +24: 3  (1 byte - byte, from ( ))
| +25: 4  (1 byte - byte)

| String definitions create byte sequences:
#string "hola" "que" 0
| Memory layout at 'string:
| +0: 'h' 'o' 'l' 'a' 0    (5 bytes)
| +5: 'q' 'u' 'e' 0        (4 bytes) 
| +9: 0 0 0 0 0 0 0 0      (8 bytes - qword 0)

| Usage:
5 'var !         | Store 5 in var variable
'var @           | Fetch value from var variable  
var              | Same as 'var @ - pushes variable value
1 'var +!        | Add 1 to var variable
```

### Code Definition
```forth
:square         | Define word named 'square'
    dup * ;     | Duplicate top of stack and multiply

:distance       | Calculate distance between two points
    - dup *     | dx² 
    swap - dup * | dy²
    + sqrt ;    | √(dx² + dy²)

5 square        | Call square with 5 → result is 25
```

### Program Structure
```forth
| Program entry point (last line)
: main-word ;
```

## Stack Operations

### Basic Stack Manipulation
```forth
dup    | a -- a a           | Duplicate top
drop   | a --               | Remove top
swap   | a b -- b a         | Exchange top two
over   | a b -- a b a       | Copy second to top
rot    | a b c -- b c a     | Rotate three items
nip    | a b -- b           | Remove second item
```

### Stack State Examples
```forth
5 3 2           | Stack: 5 3 2 (top)
dup             | Stack: 5 3 2 2
+               | Stack: 5 3 4
over            | Stack: 5 3 4 3
*               | Stack: 5 3 12
```

## Control Flow

### Conditionals
R3forth uses conditional words with code blocks in parentheses:

```forth
| Stack-only conditionals (don't consume TOS)
0?  | True if top of stack is 0
1?  | True if top of stack is non-zero
+?  | True if top of stack is positive or zero
-?  | True if top of stack is negative

| Comparison conditionals (consume second item)
=?  | a b -- a | True if a equals b
<?  | a b -- a | True if a less than b
>?  | a b -- a | True if a greater than b

| Usage example
x 5 >? ( "Greater than 5" .print )
x 0 =? ( "Zero detected" .print ) | Note: can also use x 0? for zero check
drop
```

### Loops
Loops use conditionals inside code blocks:
```forth
| Count from 1 to 10
1 ( 10 <?
    dup "%d " .print    | .print is from console library
    1 + ) drop

| Countdown pattern (preferred)
10 ( 1? 1 -
    dup "%d " .print
) drop

| Memory traversal until zero
'text ( c@+ 1?
    process-char
) 2drop
```

### Early Exit Pattern
```forth
:find-item | array item -- index|-1
    0 swap          | index array item
    ( over @ 1?     | Check if array value exists
        2dup =? ( 2drop ; )  | Found it, return index
        swap 8 + swap        | Next array position
        rot 1 + rot          | Increment index
    ) 3drop -1 ;    | Not found
```

## Memory Management

### Memory Access Sizes
```forth
| 64-bit (default)
@  !  @+  !+    | Fetch/store 8 bytes
| 32-bit  
d@ d! d@+ d!+   | Fetch/store 4 bytes
| 16-bit
w@ w! w@+ w!+   | Fetch/store 2 bytes  
| 8-bit
c@ c! c@+ c!+   | Fetch/store 1 byte
```

### Memory Operations Example
```forth
#buffer * 100   | Allocate 100 * 8 bytes

| Fill buffer with values
'buffer 10 ( 1? 1 -
    over !+     | Store and increment
    swap
) 2drop

| Read buffer values  
'buffer 10 ( 1? 1 -
    over @+ .print
    swap
) 2drop
```

### Register Usage (A and B)
```forth
>A  A>  A@  A!  A@+  A!+  A+    | Register A operations
>B  B>  B@  B!  B@+  B!+  B+    | Register B operations

| Register isolation to prevent conflicts
AB[                 | Save current A and B registers
'array >A           | Load array address into A
100 ( 1? 1 -        | Process 100 elements
    A@+ process-element
) drop
]BA                 | Restore previous A and B values

| Example: Array processing without conflicts
'data1 >A
AB[                 | Isolate register usage
    'data2 >B       | Use both registers safely
    process-data
]BA                 | Restore original A value
```

## Text Processing

### String Handling
```forth
"Hello"         | Push address of string to stack
c@+             | Fetch character and increment address
count           | Count characters in string (from lib)

| Character-by-character processing
"text" ( c@+ 1?
    process-char
) 2drop

| Formatted output
x y "%d,%d" .print   | Print coordinates
```

## Arithmetic and Logic

### Basic Arithmetic
```forth
+  -  *  /          | Basic operations
mod                 | Modulo
neg abs sqrt        | Unary operations
<<  >>  >>>         | Bit shifting
*/                  | a*b/c without overflow
*>>                 | (a*b)>>c without overflow
<</                 | (a<<c)/b without overflow
```

### Logical Operations
```forth
and or xor not      | Bitwise operations
and? nand?          | Logical operations for conditionals

| Example
$FF $0F and         | Result: $0F
5 0 and?            | False (0)
5 1 and?            | True (non-zero)
```

### Fixed Point Math (48.16 format)
```forth
^lib/math.r3        | Include math library

3.14159 2.0 *.      | Fixed point multiplication  
10.5 3.0 /.         | Fixed point division
45.0 sin            | Sine (angle in turns: 0.5 = 180°)
2.0 sqrt.           | Fixed point square root
```

## Common Programming Patterns

### Error Handling Pattern
```forth
:safe-divide | a b -- result | 0 on error
    0=? ( 2drop 0 ; )   | Check for division by zero
    / ;                 | Safe to divide
```

### Jump Table Pattern
```forth
:action0 "Action 0" .print ;
:action1 "Action 1" .print ;
:action2 "Action 2" .print ;

#jump-table 'action0 'action1 'action2

:dispatch | n --
    3 <<            | Multiply by 8 (cell size)  
    'jump-table + @ ex ;

1 dispatch          | Executes action1
```

### Buffer Management Pattern
```forth
#buffer * 1000
#buffer> 'buffer    | Buffer pointer

:add-item | item --
    buffer> !+      | Store and advance pointer
    'buffer> ! ;    | Update pointer

:process-buffer
    'buffer ( buffer> <?
        @+ process-item
    ) drop ;
```

### State Machine Pattern
```forth
#state 0

:state0 
    condition? ( 1 'state ! ; )
    handle-state0 ;

:state1
    other-condition? ( 0 'state ! ; )  
    handle-state1 ;

#state-table 'state0 'state1

:update-state
    state 3 << 'state-table + @ ex ;
```

## Library Integration

### Console Output
```forth
^lib/console.r3

.print              | Print formatted text
.println            | Print with newline
.write              | Write plain text
cls                 | Clear screen
.at                 | Position cursor
```

### Graphics (SDL2)
```forth
^lib/sdl2gfx.r3

"Window" 640 480 SDLinit    | Initialize window
$FF0000 SDLcolor           | Set red color
100 100 50 50 SDLFRect     | Draw filled rectangle
SDLredraw                  | Update display
```

### Game Loop Pattern
```forth
^lib/sdl2.r3

:game-update
    | Game logic here
    SDLkey              | Get keyboard input
    >esc< =? ( exit )   | Exit on Escape
    drop ;

:game-draw  
    0 SDLcls           | Clear screen
    | Draw game objects
    SDLredraw ;        | Update display

:game-loop
    game-update
    game-draw ;

:main
    "Game" 800 600 SDLinit
    'game-loop SDLshow  | Start main loop
    SDLquit ;

: main ;               | Program entry point
```

## Scoping and Visibility

### No Local Variables
R3forth has no concept of local variables. All data is either:
- Global variables (defined with `#`)
- Values on the data stack
- Values in registers A/B
- Values on return stack (discouraged)

### File-Level Privacy
Words defined with double prefixes are only accessible within their file:
```forth
| In mylib.r3:
::internal-helper | Private to this file
    some-logic ;

##private-data 100  | Private variable

:public-interface   | Accessible when file is included
    private-data internal-helper ;

| In main program:
^mylib.r3
public-interface    | ✓ Works
internal-helper     | ✗ Error - not accessible
```

### Forward References Not Allowed
Words must be defined before use:
```forth
:word1 
    word2 ;         | ✗ Error - word2 not yet defined

:word2
    "hello" ;

| Correct order:
:word2
    "hello" ;

:word1
    word2 ;         | ✓ Now word2 exists
```

### Variable Usage Philosophy
Variables can help solve complex algorithms initially, but the goal is to find stack-based solutions that avoid them. Variables pollute the execution model and should be temporary stepping stones:

```forth
| Initial solution with variables:
#temp-x #temp-y #temp-result

:complex-calc | a b c d -- result
    'temp-x ! 'temp-y !     | Store intermediate values
    * temp-x + temp-y / 
    'temp-result ! 
    temp-result ;

| Better: Find algorithm that works with stack:
:stack-calc | a b c d -- result
    >a >b           | Use registers for deep values
    * a> + b> / ;   | Or factor into smaller operations

| Best: Refactor to eliminate storage needs:
:factored-calc | a b c d -- result
    rot * rot + / ; | Direct stack manipulation
```

The language encourages finding pure stack-based algorithms rather than relying on variable storage.

### 1. Stack Balance - Data Flow Communication
Stack balance is about managing data producers and consumers. Words either produce values (push to stack), consume values (pop from stack), or both. Programming in R3forth means creating chains of words where producers and consumers are properly matched.

The overall program execution should not leave the stack with overflow or underflow, and loops should not grow or shrink the stack indefinitely. However, intermediate states can be unbalanced - this is normal as parameters flow from one word to another:

```forth
:area | width height -- area
    * ;             | Consumes 2, produces 1

:rectangle | width height x y --
    2swap area      | Intermediate unbalance: produces area value
    draw-rect ;     | Consumes area + coordinates

5 10 area          | 5 and 10 consumed, area (50) produced
```

The key is that each word's stack effect must be predictable and documented to enable proper composition.

### 2. Factor Early and Often
Break complex operations into simple, reusable words:
```forth
:draw-centered-text | text x y --
    over str-width 2 / -    | Adjust x for centering
    draw-text ;

:draw-health-bar | health max-health x y --
    2over 2over draw-bar-background
    rot * swap / draw-bar-fill ;
```

### 3. Use Meaningful Names
```forth
:vel-update         | Better than :vu
:player-collision   | Better than :pc  
:init-game-state    | Better than :igs
```

### 4. Consistent Stack Comments
```forth
:distance | x1 y1 x2 y2 -- distance
    rot - dup *         | x1 y1 dx dx²
    rot rot - dup *     | x1 dx² dy dy²  
    + sqrt ;            | distance
```

### 5. Avoid Deep Stack Operations
R3forth limits deep stack access (no PICK5 or deeper). When you need values buried in the stack, consider factoring or changing parameter order:

```forth
| Complex operation needing deep access:
:complex-calc | a b c d e f -- result
    pick4 pick3 * pick2 + / ;  | Hard to read, error-prone

| Factor into logical steps:
:calc-base | a b c -- base
    rot * + ;
:apply-factors | base d e f -- result  
    rot / ;
:better-calc | a b c d e f -- result
    rot rot rot calc-base    | Reorder parameters
    rot rot apply-factors ;

| Alternative: Use registers for deep values
:using-registers | a b c d e f -- result
    >a >b           | Save deep values to registers
    calc-base       | Work with top values
    a> b> apply-factors ;

| Or restructure the algorithm to avoid the problem:
:restructured | f e d c b a -- result  
    * + / ;      | Simply reverse parameter order
```

## Common Gotchas

1. **Missing Spaces**: `5+` is one word, not `5 +`
2. **words together**: It does not separate words with a space.
3. **Stack Underflow**: Not enough values for operations
4. **Unbalanced Stacks**: Loops that grow/shrink stack indefinitely  
5. **Register Conflicts**: A/B registers shared between words
6. **Memory Alignment**: Different sizes require different increment amounts


## File Structure

Typical R3forth program structure:
```forth
| comments and documentation
^lib/needed-library.r3
^lib/another-library.r3

| Data definitions
#global-var1 0
#global-var2 * 100

| Helper words
:utility-word1 ... ;  
:utility-word2 ... ;

| Main functionality
:main-logic ... ;

| Entry point (always last)
: main-logic ;
```

## Full Base Dictionary

Essential words in the R3 base dictionary:

### Control Flow

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `;` | `--` | End word execution |
| `(` | `--` | Begin code block |
| `)` | `--` | End code block |
| `[` | `-- vec` | Begin anonymous definition |
| `]` | `vec --` | End anonymous definition |
| `EX` | `vec --` | Execute word by address |

### Stack Conditionals

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `0?` | `a -- a` | True if TOS = 0 |
| `1?` | `a -- a` | True if TOS ≠ 0 |
| `+?` | `a -- a` | True if TOS ≥ 0 |
| `-?` | `a -- a` | True if TOS < 0 |
| `<?` | `a b -- a` | True if a < b (removes TOS) |
| `>?` | `a b -- a` | True if a > b (removes TOS) |
| `=?` | `a b -- a` | True if a = b (removes TOS) |
| `>=?` | `a b -- a` | True if a ≥ b (removes TOS) |
| `<=?` | `a b -- a` | True if a ≤ b (removes TOS) |
| `<>?` | `a b -- a` | True if a ≠ b (removes TOS) |
| `AND?` | `a b -- c` | True if a AND b (removes TOS) |
| `NAND?` | `a b -- c` | True if a NAND b (removes TOS) |
| `IN?` | `a b c -- a` | True if a≤b≤c (removes TOS and NOS) |

### Stack Operations

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `DUP` | `a -- a a` | Duplicate TOS |
| `DROP` | `a --` | Remove TOS |
| `OVER` | `a b -- a b a` | Duplicate NOS |
| `PICK2` | `a b c -- a b c a` | Duplicate 3rd element |
| `PICK3` | `a b c d -- a b c d a` | Duplicate 4th element |
| `PICK4` | `a b c d e -- a b c d e a` | Duplicate 5th element |
| `SWAP` | `a b -- b a` | Exchange TOS and NOS |
| `NIP` | `a b -- b` | Remove NOS |
| `ROT` | `a b c -- b c a` | Rotate 3 elements |
| `-ROT` | `a b c -- c a b` | Rotate 3 elements |
| `2DUP` | `a b -- a b a b` | Duplicate 2 values |
| `2DROP` | `a b --` | Remove 2 elements |
| `3DROP` | `a b c --` | Remove 3 elements |
| `4DROP` | `a b c d --` | Remove 4 elements |
| `2OVER` | `a b c d -- a b c d a b` | Duplicate 2 elements from 3rd position |
| `2SWAP` | `a b c d -- c d a b` | Exchange 4 elements |

### Return Stack

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `>R` | `a -- rstack: -- a` | Push to return stack |
| `R>` | `-- a rstack: a --` | Pop from return stack |
| `R@` | `-- a rstack: a -- a` | Read top of return stack |

### Arithmetic Operations

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `+` | `a b -- c` | c = a + b |
| `-` | `a b -- c` | c = a - b |
| `*` | `a b -- c` | c = a * b |
| `/` | `a b -- c` | c = a / b |
| `<<` | `a b -- c` | a shift left b |
| `>>` | `a b -- c` | a shift right b |
| `>>>` | `a b -- c` | a shift right b unsigned |
| `MOD` | `a b -- c` | c = a mod b |
| `/MOD` | `a b -- c d` | c = a/b, d = a mod b |
| `*/` | `a b c -- d` | d = a*b/c without bit loss |
| `*>>` | `a b c -- d` | d = (a*b)>>c without bit loss |
| `<</` | `a b c -- d` | d = (a<<c)/b without bit loss |
| `NEG` | `a -- b` | b = -a |
| `ABS` | `a -- b` | b = \|a\| |
| `SQRT` | `a -- b` | b = square root(a) |
| `CLZ` | `a -- b` | b = count leading zeros of a |

### Logical Operations

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `AND` | `a b -- c` | c = a AND b |
| `NAND` | `a b -- c` | c = a NAND b |
| `OR` | `a b -- c` | c = a OR b |
| `XOR` | `a b -- c` | c = a XOR b |
| `NOT` | `a -- b` | b = NOT a |

### Memory Operations

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `@` | `a -- [a]` | Fetch qword from address |
| `C@` | `a -- byte[a]` | Fetch byte from address |
| `W@` | `a -- word[a]` | Fetch word from address |
| `D@` | `a -- dword[a]` | Fetch dword from address |
| `@+` | `a -- b [a]` | Fetch qword and increment by 8 |
| `C@+` | `a -- b byte[a]` | Fetch byte and increment by 1 |
| `W@+` | `a -- b word[a]` | Fetch word and increment by 2 |
| `D@+` | `a -- b dword[a]` | Fetch dword and increment by 4 |
| `!` | `a b --` | Store A at address B |
| `C!` | `a b --` | Store byte A at address B |
| `W!` | `a b --` | Store word A at address B |
| `D!` | `a b --` | Store dword A at address B |
| `!+` | `a b -- c` | Store A at B and increment by 8 |
| `C!+` | `a b -- c` | Store byte A at B and increment by 1 |
| `W!+` | `a b -- c` | Store word A at B and increment by 2 |
| `D!+` | `a b -- c` | Store dword A at B and increment by 4 |
| `+!` | `a b --` | Add A to value at address B |
| `C+!` | `a b --` | Add A to byte at address B |
| `W+!` | `a b --` | Add A to word at address B |
| `D+!` | `a b --` | Add A to dword at address B |

### Register Operations

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `>A` | `a --` | Load register A |
| `>B` | `a --` | Load register B |
| `B>` | `-- a` | Push register B |
| `A>` | `-- a` | Push register A |
| `A+` | `a --` | Add to A |
| `B+` | `a --` | Add to B |
| `A@` | `-- a` | Fetch from A |
| `B@` | `-- a` | Fetch from B |
| `cA@` | `-- a` | Fetch byte from A |
| `cB@` | `-- a` | Fetch byte from B |
| `dA@` | `-- a` | Fetch dword from A |
| `dB@` | `-- a` | Fetch dword from B |
| `A!` | `a --` | Store in memory at A |
| `B!` | `a --` | Store in memory at B |
| `cA!` | `a --` | Store in memory at A |
| `cB!` | `a --` | Store in memory at B |
| `dA!` | `a --` | Store in memory at A |
| `dB!` | `a --` | Store in memory at B |
| `A@+` | `-- a` | Fetch from A and increment by 8 |
| `B@+` | `-- a` | Fetch from B and increment by 8 |
| `cA@+` | `-- a` | Fetch from A and increment by 8 |
| `cB@+` | `-- a` | Fetch from B and increment by 8 |
| `dA@+` | `-- a` | Fetch from A and increment by 8 |
| `dB@+` | `-- a` | Fetch from B and increment by 8 |
| `A!+` | `a --` | Store at A and increment by 8 |
| `B!+` | `a --` | Store at B and increment by 8 |
| `cA!+` | `a --` | Store at A and increment by 8 |
| `cB!+` | `a --` | Store at B and increment by 8 |
| `dA!+` | `a --` | Store at A and increment by 8 |
| `dB!+` | `a --` | Store at B and increment by 8 |

### Memory Block Operations

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `MOVE` | `d s c --` | Copy S to D, C qwords |
| `MOVE>` | `d s c --` | Copy S to D, C qwords in reverse |
| `FILL` | `d v c --` | Fill D, C qwords with V |
| `CMOVE` | `d s c --` | Copy S to D, C bytes |
| `CMOVE>` | `d s c --` | Copy S to D, C bytes in reverse |
| `CFILL` | `d v c --` | Fill D, C bytes with V |
| `DMOVE` | `d s c --` | Copy S to D, C dwords |
| `DMOVE>` | `d s c --` | Copy S to D, C dwords in reverse |
| `DFILL` | `d v c --` | Fill D, C dwords with V |
| `MEM` | `-- a` | Start of free memory |

### System Interface

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `LOADLIB` | `"name" -- liba` | Load dynamic library |
| `GETPROC` | `liba "name" -- aa` | Get function address |
| `SYS0` | `aa -- r` | Call function with 0 parameters |
| `SYS1` | `a aa -- r` | Call function with 1 parameter |
| `SYS2` | `a b aa -- r` | Call function with 2 parameters |
| `SYS3` | `a b c aa -- r` | Call function with 3 parameters |
| `SYS4` | `a b c d aa -- r` | Call function with 4 parameters |
| `SYS5` | `a b c d e aa -- r` | Call function with 5 parameters |
| `SYS6` | `a b c d e f aa -- r` | Call function with 6 parameters |
| `SYS7` | `a b c d e f g aa -- r` | Call function with 7 parameters |
| `SYS8` | `a b c d e f g h aa -- r` | Call function with 8 parameters |
| `SYS9` | `a b c d e f g h i aa -- r` | Call function with 9 parameters |
| `SYS10` | `a b c d e f g h i j aa -- r` | Call function with 10 parameters |

---


This guide provides the essential patterns and concepts needed to program effectively in R3forth. The language rewards factorization, stack discipline, and clear thinking about data flow.