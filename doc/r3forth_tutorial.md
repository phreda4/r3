# R3forth — Programming Tutorial

**A Concatenative Language Derived from ColorForth**

*Pablo H. Reda*

Repository: https://github.com/phreda4/r3

---

## What is R3forth?

R3forth is a small, fast, concatenative programming language inspired by ColorForth. It compiles programs to native 64-bit code and is designed for direct OS interaction, real-time applications, and games.

If you've used Forth before, you'll feel at home quickly. If you haven't — don't worry. R3forth has a very small core that's easy to learn, and this tutorial will guide you step by step.

> **Note for Forth programmers:** Unlike most Forth implementations, R3 compiles the entire program first and then executes it. Phrases like "pushes to stack" in this manual describe runtime behavior, not interactive REPL behavior.

---

## Table of Contents

1. [Programming a Computer](#programming-a-computer)
2. [The R3 Language](#the-r3-language)
3. [Dictionary System](#dictionary-system)
4. [Data Stack](#data-stack)
5. [Arithmetic Operations](#arithmetic-operations)
6. [Fixed Point Operations](#fixed-point-operations)
7. [Conditionals](#conditionals)
8. [Repetition](#repetition)
9. [Recursion](#recursion)
10. [Variables and Memory](#variables-and-memory)
11. [Text and Strings](#text-and-strings)
12. [Registers A and B](#registers-a-and-b)
13. [Return Stack](#return-stack)
14. [Operating System Connection](#operating-system-connection)
15. [Libraries](#libraries)
16. [Complete Example: Simple Game](#complete-example-simple-game)
17. [Debugging Guide](#debugging-guide)
18. [Common Patterns](#common-patterns)
19. [Performance Considerations](#performance-considerations)

---

## Programming a Computer

A computer needs a program to function — a precise description of what it should do.

This description is written in a language the machine understands. But the programming process begins earlier.

First comes an idea — for example, drawing a circle. Then we write code so the machine draws a circle with radius 1:

```forth
:draw 1 circle ;
```

The computer first translates this code into machine code, the only language it truly understands. This process is called **compilation**.

Once compiled, the result is executed. If the code cannot be compiled, there is an error:

```forth
:draw 1 cicle ;   | Error: 'cicle' not found
```

When we try to compile, the computer reports the error and executes nothing. Another possibility is that the program compiles correctly but doesn't do what we intended — a logic error.

To build a working program we need to:

1. Have a problem or task to solve
2. Have an idea of how to solve it
3. Translate the idea into the programming language
4. Compile without errors
5. Execute and verify the result matches what we imagined

> **Important:** We can only program what we understand well enough to describe. We cannot program what we don't know how it works.

---

## The R3 Language

### Introduction

Programming means building a recipe that describes behavior. This recipe is called **source code** or **program**.

A program has two kinds of definitions:

- **DATA** — also called memory, state, or variable
- **CODE** — also called order, routine, function, or action

As data we need to store numbers that represent:

- **Quantities** — for example: 3 lives
- **Addresses or locations** — for example: position 100 on the screen
- **States** — for example: jumping = 1, falling = 2

As code we build actions. Any behavior can be expressed with four elements:

- **Sequence** — one instruction follows the next
- **Condition** — an instruction runs only if a condition is met
- **Repetition** — an instruction repeats in some defined way
- **Recursion** — a word defined in terms of itself (least used)

### Core Concepts

The source code is a text file separated into **words**. A word is any sequence of letters, digits, or characters separated by spaces:

```forth
LIVES   134   -*jump*-   lives
```

Case is not significant — `LIVES` and `lives` are the same word.

### Essential Terminology

**Stack terms:**
- **TOS** = Top Of Stack (the most recently pushed value)
- **NOS** = Next Of Stack (the second-to-last value)
- **Stack cell** = one storage slot (8 bytes / 64 bits)

**Memory terms:**
- **byte** = 8 bits — `c@` / `c!` operations
- **word** = 16 bits — `w@` / `w!` operations
- **dword** = 32 bits — `d@` / `d!` operations
- **qword** = 64 bits — `@` / `!` operations (default)

**Code terms:**
- **Word** = a named function or data definition
- **Definition** = the code or data associated with a word
- **Dictionary** = the collection of all defined words

### Stack-Based Execution

All operations work through a data stack using **postfix notation**: operands come first, then the operator.

```forth
5 3 +     | Push 5, push 3, add → stack contains 8
10 dup *  | Push 10, duplicate it, multiply → stack contains 100
```

### Word Boundaries

> **Important:** Spaces define word boundaries. A very common source of errors is a missing space. The exact form of whitespace doesn't matter — one space, several spaces, or a newline are all equivalent.

### Compilation Process

1. Parse source code word by word
2. Prefixed words → interpret according to prefix
3. Numbers → push to stack
4. Known words → execute
5. Unknown words → compilation error

### Prefix System

R3 recognizes 8 prefixes. The first character of a word determines how it is interpreted:

| Prefix | Meaning | Example | Description |
|--------|---------|---------|-------------|
| `\|` | Comment | `\| This is a comment` | Ignored by the compiler, ends at line end |
| `^` | Include | `^r3/lib/console.r3` | Include code from the indicated file (entire line is the filename) |
| `"` | String | `"Hello"` | Define a text string, ends with `"` |
| `:` | Action | `:myword` | Define a code word |
| `#` | Data | `#variable 5` | Define data / variables |
| `$` | Hexadecimal | `$FF` | Hexadecimal number |
| `%` | Binary | `%1010` | Binary number |
| `'` | Address | `'word` | Address of a word |

> **Note:** The address prefix `'` requires a valid user-defined word. Base dictionary words do not have addressable locations.

---

## Dictionary System

The language starts with a predefined dictionary of around 200 words that represent basic computer operations (see the Reference document).

New words are added using the `:` and `#` prefixes. When the compiler searches for a word, it searches from the **last defined to the first**. You can redefine words — only the most recent definition is used.

> **Programming is creating words.** A program is a dictionary that grows until you call the final word, which runs the whole thing.

### Modules and Exports

The `^` prefix includes an external file and imports its exported definitions:

- Use `::` instead of `:` to export a code word (visible when the file is included).
- Use `##` instead of `#` to export a data word.
- All other definitions in the file remain **private** to that file.

This gives you a clean module system: only the API you intend to share becomes visible.

### Program Structure

```forth
| Comments and documentation
^r3/lib/needed-library.r3

| Data definitions
#global-var1 0
#global-var2 * 100

| Helper words (private to this file)
:utility-word1 ... ;
:utility-word2 ... ;

| Exported words (accessible when included)
::public-word1 ... ;
::public-word2 ... ;

| Program entry point (always the last line)
: main-word ;
```

### Forward References Are Not Allowed

Words must be defined before they are used:

```forth
| ✗ WRONG — word2 is not yet defined
:word1
    word2 ;

:word2
    "hello" ;

| ✓ CORRECT — define word2 first
:word2
    "hello" ;

:word1
    word2 ;
```

### Example Program

```forth
#side 5
:square dup * ;
: side square ;
```

Line 1 defines a variable with value 5.
Line 2 defines `square`: duplicates the top of stack and multiplies the two copies.
Line 3 is the program entry point — it pushes 5 (the value of `side`), then calls `square`.

At the end, the stack contains 25.

### Understanding the Semicolon

The semicolon `;` ends execution of a word and returns to the caller. This means:

- A word can have **multiple exit points** (multiple semicolons)
- The semicolon is about control flow, not just marking the end of a definition

```forth
:example | n -- result
    0? ( ; )           | First exit: return 0 if input is 0
    1 =? ( ; )         | Second exit: return 1 if input is 1
    dup * ;            | Default exit: return n squared
```

### Fall-Through Definitions

A word definition without a closing `;` **falls through** into the next definition. This is a deliberate feature:

```forth
:word1
    something
:word2          | no ; here — word1 continues directly into word2
    something-more ;

word1  | executes: something, something-more, end
word2  | executes: something-more, end
```

This avoids the overhead of an extra call when one word always leads to another. Use it intentionally and document it with a comment like `| falls through to word2`.

---

## Data Stack

The data stack is R3forth's primary workspace. Think of it as a stack of plates: you can only add or remove from the top. The last value you put in is the first to come out — this is called **LIFO** (Last In, First Out).

All operations read their inputs from the stack and write their results back to it.

When numbers appear in source code, they are pushed onto the stack in order.

### Stack Notation

Each word can take and/or leave values on the data stack. A comment describes the stack state before and after the word, separated by `--`:

**Format:** `| before -- after`

```forth
:square | n -- n²
    dup * ;

:distance | x1 y1 x2 y2 -- dist
    rot - square    | x1 x2 dy²
    -rot - square   | dy² dx²
    + sqrt ;        | distance
```

### Stack Manipulation Words

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `DUP` | `a -- a a` | Duplicate top of stack |
| `SWAP` | `a b -- b a` | Exchange top two items |
| `DROP` | `a --` | Remove top of stack |
| `ROT` | `a b c -- b c a` | Rotate three items |
| `-ROT` | `a b c -- c a b` | Rotate three items (inverse) |
| `OVER` | `a b -- a b a` | Copy second to top |
| `NIP` | `a b -- b` | Remove second item |
| `PICK2` | `a b c -- a b c a` | Copy third item to top |
| `PICK3` | `a b c d -- a b c d a` | Copy fourth item to top |
| `2DUP` | `a b -- a b a b` | Duplicate top two items |
| `2DROP` | `a b --` | Remove top two items |
| `2SWAP` | `a b c d -- c d a b` | Exchange top two pairs |

### Stack Visualization

Step-by-step example — track the stack after each operation:

```forth
5 3          | Stack: 5 3        (NOS=5, TOS=3)
+            | Stack: 8          (TOS=8)
dup          | Stack: 8 8        (NOS=8, TOS=8)
2            | Stack: 8 8 2      (TOS=2)
*            | Stack: 8 16       (TOS=16)
swap         | Stack: 16 8       (TOS=8)
-            | Stack: 8          (TOS=8)
```

Some words **produce** values (like `DUP`), others **consume** them (like `DROP`), and some do both.

### Stack Balance Rules

> **Stack Balance:** If your word makes the stack grow indefinitely or empties it unexpectedly, the program has an error. This often cannot be detected before execution.

1. **Within a word:** the net stack effect must match the stack comment.
2. **Within a loop:** each iteration must leave the stack at the same depth.
3. **Within conditionals:** all branches must have the same stack effect.

```forth
| ✗ WRONG — branches leave different stack depths
:bad-example | n --
    5 >? ( dup )        | Branch adds a value
    drop ;              | Fails if branch ran

| ✓ CORRECT — balanced branches
:good-example | n --
    5 >? ( dup drop )   | Branch is net-zero
    drop ;              | Always works
```

The stack is for passing values between words, not for storing data. If you need a real stack structure, build one:

```forth
#mystack * 800      | 100 cells
#mystack> 'mystack

::mypush  | v --
    mystack> !+ 'mystack> ! ;

::mypop  | -- v
    -8 'mystack> +! mystack> @ ;

::mydepth | -- d
    mystack> 'mystack - 3 >> ;    | divide by 8
```

---

## Arithmetic Operations

### Addition and Subtraction

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `+` | `a b -- c` | c = a + b |
| `-` | `a b -- c` | c = a - b |

### Multiplication and Division

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `*` | `a b -- c` | c = a * b |
| `/` | `a b -- c` | c = a / b (integer division) |
| `MOD` | `a b -- c` | c = a mod b (remainder) |
| `/MOD` | `a b -- c d` | c = a/b, d = a mod b |

### Bit Shifting

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `<<` | `a b -- c` | Left bit shift (c = a << b) |
| `>>` | `a b -- c` | Right bit shift, signed (c = a >> b) |
| `>>>` | `a b -- c` | Right bit shift, unsigned (c = a >>> b) |

```forth
5 2 <<    | 20  (5 × 4)
5 1 >>    | 2   (5 / 2, signed)
-2 1 >>   | -1  (sign bit preserved)
-1 1 >>>  | 9223372036854775807  (sign bit cleared)
```

### Other Operations

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `NEG` | `a -- -a` | Negate |
| `ABS` | `a -- \|a\|` | Absolute value |
| `SQRT` | `a -- b` | Integer square root |
| `*/` | `a b c -- d` | d = a×b/c without intermediate overflow |

`*/` is particularly useful for proportional scaling:

```forth
| Scale a value from 0–100 to 0–255
75 255 100 */    | Result: 191 (no overflow)
```

### Logical Operations

| Word | Stack Effect | Example |
|------|--------------|---------|
| `AND` | `a b -- c` | `$ff $55 AND` → $55 |
| `NAND` | `a b -- c` | `$ff $1 NAND` → $fe |
| `OR` | `a b -- c` | `$2 $1 OR` → 3 |
| `XOR` | `a b -- c` | `$3 2 XOR` → 1 |
| `NOT` | `a -- b` | `0 NOT` → -1 (all bits set) |

---

## Fixed Point Operations

R3forth uses **48.16 fixed-point format**: 48 bits for the integer part and 16 bits for the fractional part, all stored in a standard 64-bit cell (the same cell used for integers and addresses).

The practical rule: multiply any real number by 65536 (2¹⁶) to get its internal representation.

```
Example: 3.5 in 48.16 format
    Integer part:  3   × 65536 = 196608
    Fractional:    0.5 × 65536 =  32768
    Stored value:               229376

Example: 1.5
    1.5 × 65536 = 98304
```

Since only 16 bits are fractional, the integer range is enormous (up to ~281 trillion), making overflow virtually impossible in practice.

The language recognizes decimal-point literals and converts them automatically:

```forth
1.5      | Stored as 98304  (1.5  × 65536)
3.14159  | Stored as 205887 (3.14159 × 65536)
```

### Fixed Point Bit Layout

```
64-bit cell:
[sign bit][47 integer bits][16 fractional bits]
```

### Basic Fixed Point Operations

Addition and subtraction work exactly like integers. Multiplication and division need special words from `r3/lib/math.r3`:

```forth
^r3/lib/math.r3

*.     | f f -- f   multiply two fixed-point numbers
/.     | f f -- f   divide two fixed-point numbers
int.   | f -- a     convert to integer (discard fractional part)
```

### Trigonometric and Math Functions

Angles are expressed in **turns** (not degrees or radians): 1.0 = full circle, 0.5 = 180°, 0.25 = 90°.

```forth
| Available from r3/lib/math.r3
cos    | f -- cos(f)
sin    | f -- sin(f)
tan    | f -- tan(f)
sqrt.  | f -- sqrt(f)   fixed-point square root
ln.    | x -- r         natural logarithm
exp.   | x -- r         exponential
root.  | base root -- r nth root
```

```forth
| Angle examples (in turns)
0.0  sin   | sin(0°)   = 0.0
0.25 sin   | sin(90°)  = 1.0
0.5  sin   | sin(180°) = 0.0
0.75 sin   | sin(270°) = -1.0
```

### Custom Fixed Point Formats

For other bit distributions, R3 provides:

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `*>>` | `a b c -- d` | d = (a×b)>>c without bit loss |
| `<</` | `a b c -- d` | d = (a<<c)/b without bit loss |

```forth
| For 24.8 format (8 fractional bits):
a b 8 *>>    | multiply two 24.8 numbers
a b 8 <</    | divide two 24.8 numbers
```

---

## Conditionals

Parentheses mark **code blocks**. They are words too, and must be separated by spaces:

```forth
( code block )
```

A conditional word followed by a code block executes the block only when the condition is true.

### Two Families of Conditionals

There are two families with different stack behavior — understanding this distinction is essential.

**Unary conditionals** check TOS without consuming it. The value stays on the stack, available for the next comparison or for `drop`.

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `0?` | `a -- a` | True when a = 0 |
| `1?` | `a -- a` | True when a ≠ 0 |
| `-?` | `a -- a` | True when a < 0 |
| `+?` | `a -- a` | True when a ≥ 0 |

**Binary conditionals** compare NOS (`a`) against TOS (`b`). They consume TOS and leave NOS on the stack, regardless of the result. Think of `a b >?` as asking "is `a` greater than `b`?" — just as you would write it in mathematics.

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `=?` | `a b -- a` | True if a = b |
| `<?` | `a b -- a` | True if a < b |
| `<=?` | `a b -- a` | True if a ≤ b |
| `>?` | `a b -- a` | True if a > b |
| `>=?` | `a b -- a` | True if a ≥ b |
| `<>?` | `a b -- a` | True if a ≠ b |
| `AND?` | `a b -- a` | True if a AND b ≠ 0 |
| `NAND?` | `a b -- a` | True if a NAND b ≠ 0 |
| `IN?` | `a b c -- a` | True if b ≤ a ≤ c (consumes b and c) |

### Building Conditionals

```forth
3
4 >? ( "Greater than 4" .print )   | is 3 > 4? No — block skipped
4 <? ( "Less than 4" .print )      | is 3 < 4? Yes — block runs
drop
```

Because binary conditionals leave `a` (NOS) on the stack, you can chain multiple tests on the same value:

```forth
var
4 >?  ( ... )    | is var > 4?  consumes 4, leaves var
2 <?  ( ... )    | is var < 2?  consumes 2, leaves var
drop             | clean up var
```

### Stack Mechanics — Worked Example

```forth
| Stack before: 10 5  (NOS=10, TOS=5)
10 5 >? ( "10 > 5" .print )
| >? asks: is NOS > TOS? → is 10 > 5? → YES, block runs
| After test: 10  (TOS=5 was consumed, NOS=10 remains)
drop

| Contrast — asking "is 5 > 10?":
5 10 >? ( ... )
| Stack before: 5 10  (NOS=5, TOS=10)
| >? asks: is 5 > 10? → NO, block skipped
| After test: 5  (TOS=10 consumed, NOS=5 remains)
drop
```

> **Practical rule:** `a b >?` asks "is `a` greater than `b`?". The value that stays on the stack is always `a` (NOS).

### Value Persistence — The Critical Pattern

After any test, the original value is still on the stack. You must remove it explicitly:

```forth
x
0? ( "Zero!" .print )
drop    | MUST explicitly remove x when done
```

Chaining works because the value persists across tests:

```forth
x
0? ( "Zero"     .print )
+? ( "Non-negative" .print )
-? ( "Negative" .print )
drop    | clean up once at the end
```

### Early Exit Pattern

```forth
:min | a b -- min
    over >? ( drop ; )  | If a > b: drop b, return a
    nip ;               | Otherwise: drop a, return b
```

### No IF-ELSE — By Design

R3forth omits IF-ELSE deliberately. This is not a limitation — it's a design choice that encourages you to break logic into small, named words (a practice called **factoring**). The result is code that reads almost like English and is much easier to test and reuse.

Compare the two styles:

```c
// Traditional approach
if (x > 5) {
    action1();
} else {
    action2();
}
```

```forth
| R3 approach — factor the decision:
:handle-small | x --
    "Small value" .print
    some-action ;

:handle-large | x --
    "Large value" .print
    other-action ;

:handler | x --
    5 >? ( handle-large ; )
    handle-small ;
```

To replicate IF-ELSE when absolutely necessary, use early exit:

```forth
| Instead of: condition ( A ) else ( B )
:conditional  condition ( A ; ) B ;
```

### Switch-Case Alternatives

For sequential integers, use jump tables:

```forth
:a0 "action 0" .print ;
:a1 "action 1" .print ;
:a2 "action 2" .print ;

#list 'a0 'a1 'a2

:action | n --
    3 <<           | multiply by 8 (cell size)
    'list + @ ex ;

2 action  | Prints "action 2"
```

For non-sequential values, chain comparisons with early exit:

```forth
:classify | value -- string
    5 <?  ( "less than 5"   ; )
    6 =?  ( "is 6"          ; )
    7 =?  ( "is 7"          ; )
    111 <? ( "between 8 and 110" ; )
    "111 or more" ;

15 classify .print drop   | "between 8 and 110"
```

### Common Conditional Errors

**ERROR 1: Forgetting to clean the stack**
```forth
| ✗ WRONG — value still on stack at end
:bad | value --
    5 >? ( "Greater" .print )
    ;

| ✓ CORRECT
:good | value --
    5 >? ( "Greater" .print )
    drop ;
```

**ERROR 2: Misreading which value is consumed**
```forth
| Stack before: 10 5  (NOS=10, TOS=5)
10 5 >? ( "Yes" .print )
| After: 10  (TOS=5 consumed, NOS=10 kept)
| Many expect the result to be 5 — it's not!
```

**ERROR 3: Nested conditions without cleanup**
```forth
| ✗ WRONG — extra value left on stack
x 5 >? ( 10 <? ( "Between" .print ) )
| leaves x on stack at the end

| ✓ CORRECT
x 5 >? ( 10 <? ( "Between" .print drop ; ) )
drop
```

---

## Repetition

When a conditional is placed **inside** a code block, it becomes a loop. While the condition is true, the block repeats. When false, execution jumps to the word after `)`.

```forth
( condition-word  body )
```

### Counting Up

```forth
1 ( 10 <?
    dup "%d " .print
    1 + ) drop
| Prints: 1 2 3 4 5 6 7 8 9
```

When TOS reaches 10, `<?` is false and the loop ends. The counter is dropped after.

### Preferred Pattern: Countdown

Unary conditionals (`1?`) don't consume the stack, making countdown loops faster:

```forth
10 ( 1? 1 - ) drop
| Counts from 10 down to 1
```

Whether to include 0 in the loop depends on where you place your code:

```forth
| Code BEFORE decrement — includes 0 in the iteration
10 ( 1? dup process 1 - ) drop

| Code AFTER decrement — excludes 0
10 ( 1? 1 - dup process ) drop
```

### Nested Loops

```forth
#table * 800  | 10 × 10 × 8 bytes

'table >a
0 ( 10 <? 1 +
    0 ( 10 <? 1 +
        a@+ "%d " .print
    ) drop
    .cr
) drop
```

### Memory Traversal Patterns

**Null-terminated strings:**
```forth
"hello" ( c@+ 1?
    use-each-character
) 2drop
| When the loop exits: address+1 and 0 are on stack, both dropped
```

**With a count:**
```forth
"hello" 5 ( 1? 1 -
    swap c@+
    use-each-character
    swap
) 2drop
```

**Loop with early exit:**
```forth
:find-zero | addr cnt -- addr|0
    ( 1? 1 -
        over @ 0? ( 2drop 0 ; ) drop
        swap 8 + swap
    )
    2drop 0 ;
```

**Loop with accumulator — three styles:**
```forth
| Pure stack (hard to read with many values):
:sum-array | addr cnt -- sum
    0 swap
    ( 1? 1 -
        -rot swap @+ rot + rot
    )
    drop nip ;

| Register for accumulator (cleaner):
:sum-array | addr cnt -- sum
    0 >a
    ( 1? 1 -
        swap @+ a> + >a swap
    ) 2drop
    a> ;

| Register for address (cleanest):
:sum-array | addr cnt -- sum
    swap >a
    0
    ( swap 1? 1 -
        swap a@+ +
    ) drop ;
```

### Multiple Exit Conditions

```forth
"text" ( c@+ 1?     | continue while not zero
    13 <>?          | AND not carriage return
    10 <>?          | AND not line feed
    drop
) 2drop
| On exit: the terminating character and the address are on stack
```

---

## Recursion

Recursion happens naturally: as soon as a word definition begins, the word can call itself.

```forth
:fibonacci | n -- f
    2 <? ( 1 nip ; )       | Base case: fib(0) = fib(1) = 1
    1 - dup                | n-1, n-1
    1 - fibonacci          | n-1, fib(n-2)
    swap fibonacci         | fib(n-2), fib(n-1)
    + ;                    | fib(n)

:factorial | n -- n!
    dup 1 <=? ( drop 1 ; ) | Base case: 0! = 1! = 1
    dup 1 -
    factorial
    * ;

5 factorial    | Result: 120
```

> **Recursion rule:** Always ensure the termination condition is correct and that the stack is balanced between the base case and the recursive case.

### Tail Call Optimization

When a word is called as the last operation before `;`, R3 turns the call into a jump instead of a real call — no stack growth occurs. Tail-recursive words become loops:

```forth
:loopback | n -- 0
    0? ( ; )       | Base case
    1 -
    loopback ;     | Tail call → compiled as jump

10 loopback        | Counts down efficiently
```

### Recursion vs Iteration

Use recursion when the problem naturally decomposes into smaller identical sub-problems (trees, divide-and-conquer). Use loops for linear traversal and simple counting.

```forth
| Recursion: natural for trees
:tree-sum | node -- sum
    dup 0? ( ; )
    dup @ swap
    8  + @ tree-sum +
    swap
    16 + @ tree-sum + ;

| Iteration: better for arrays
:array-sum | addr cnt -- sum
    0 swap ( 1? 1 -
        swap @+ rot + swap
    ) 2drop ;
```

### Common Recursion Pitfalls

**Missing base case:**
```forth
| ✗ WRONG — infinite recursion
:bad-countdown | n --
    dup "%d " .print
    1 - bad-countdown ;

| ✓ CORRECT
:good-countdown | n --
    dup 0? ( drop ; )
    dup "%d " .print
    1 - good-countdown ;
```

**Stack imbalance between cases:**
```forth
| ✗ WRONG — base case leaves wrong number of values
:bad-fib | n -- result
    2 <? ( 1 ; )       | Leaves n and 1 on stack
    dup 1 - bad-fib + ;

| ✓ CORRECT
:good-fib | n -- result
    2 <? ( 1 nip ; )   | Replaces n with 1
    1 - dup
    1 - good-fib
    swap good-fib + ;
```

---

## Variables and Memory

Variables define named locations in memory. The actual address is assigned at compile time — you don't need to know it, just use the name.

```forth
#lives 3
#positionX #positionY
#map * $400       | 1 KB buffer
#list 3 1 4
#energy 1000
```

Using $1000 as an example base address:

| Name | Address | Value |
|------|---------|-------|
| lives | $1000 | 3 |
| positionx | $1008 | 0 |
| positiony | $1010 | 0 |
| map | $1018 | 0 0 0 … 0 (1KB) |
| list | $1418 | 3 1 4 |
| energy | $1430 | 1000 |

### Defining Variables

```forth
#var           | one 64-bit cell, value 0
#var 33        | one cell, value 33
#var 33 11     | two cells: 33 and 11 (16 bytes total)
```

### Memory Reservation with `*`

The `*` syntax inside a `#` definition is **not** the multiply operator. It reserves a zero-initialized block of the given number of bytes:

```forth
#buffer  * 1024     | reserve 1024 bytes, all zeros
#image   * $10000   | reserve 64KB, zero-initialized
#pad     * 80       | reserve 80 bytes
```

The variable name becomes a pointer to the start of the block. Compare with listing values:

```forth
#data 1 2 3       | Three 64-bit cells with values 1, 2, 3 (24 bytes)
#data * 24        | 24 bytes of zeros — same size, different content
```

Use `*` whenever you need a buffer or array that you'll fill at runtime.

### Mixed Data Types

```forth
#data 33 11 [ 1 2 ] ( 3 4 )
```

| Offset | Size | Value | Type |
|--------|------|-------|------|
| +0 | 8 bytes | 33 | qword (default) |
| +8 | 8 bytes | 11 | qword (default) |
| +16 | 4 bytes | 1 | dword (from `[ ]`) |
| +20 | 4 bytes | 2 | dword (from `[ ]`) |
| +24 | 1 byte | 3 | byte (from `( )`) |
| +25 | 1 byte | 4 | byte (from `( )`) |

### String Definitions in Data

```forth
#string "hola" "que" 0
```

| Offset | Content | Bytes |
|--------|---------|-------|
| +0 | 'h' 'o' 'l' 'a' 0 | 5 |
| +5 | 'q' 'u' 'e' 0 | 4 |
| +9 | 0 (qword) | 8 |

### Variable Access

```forth
5 'var !         | Store 5 at the address of var
'var @           | Fetch value from var
var              | Same as 'var @ — pushes the value
1 'var +!        | Add 1 to var
```

### Memory Access Words

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `!` | `value address --` | Store value at address |
| `@` | `address -- value` | Fetch value from address |
| `+!` | `val address --` | Add val to value at address |
| `!+` | `value address -- address+8` | Store and advance address by 8 |
| `@+` | `address -- address+8 value` | Fetch and advance address by 8 |

> **Memory layout:** Each default cell is 8 bytes (64 bits). Sequential cells are 8 bytes apart.

### Memory Access Sizes

| Size | Fetch | Store | Fetch+ | Store+ | Increment |
|------|-------|-------|--------|--------|-----------|
| 8 bits | `c@` | `c!` | `c@+` | `c!+` | +1 byte |
| 16 bits | `w@` | `w!` | `w@+` | `w!+` | +2 bytes |
| 32 bits | `d@` | `d!` | `d@+` | `d!+` | +4 bytes |
| 64 bits | `@` | `!` | `@+` | `!+` | +8 bytes |

### Example Usage

```forth
:listshow
    'list
    @+ "%d " .print    | prints 3
    @+ "%d " .print    | prints 1
    drop ;

'list 8 + @            | pushes 1 (second element)
1 'positionX +!        | add 1 to positionX
listshow               | prints 3 1
```

### Dynamic Memory

The language exposes the start of free memory with `MEM`. Beyond that, three words manage a simple stack-based allocator:

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `HERE` | `-- addr` | Next free memory address |
| `MARK` | `--` | Save HERE (mark current position) |
| `EMPTY` | `--` | Restore HERE (release since last MARK) |

```forth
MARK                        | mark level 1
HERE 'buffer1 !
1024 'HERE +!               | allocate 1KB

    MARK                    | mark level 2
    HERE 'buffer2 !
    2048 'HERE +!           | allocate 2KB
    process-with-buffer2
    EMPTY                   | release buffer2

process-with-buffer1
EMPTY                       | release buffer1
```

The advantage of this scheme: **no garbage collector is needed**.

### Complete Memory Map

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
│  fixed-size buffers                 │
└─────────────────────────────────────┘
              ↑ HERE points here
┌─────────────────────────────────────┐
│  FREE MEMORY (Dynamic)              │
│  Managed by MEM / HERE / MARK /     │
│  EMPTY — grows upward               │
└─────────────────────────────────────┘
```

---

## Text and Strings

Text is a sequence of bytes in memory. Strings in source code are enclosed in double quotes:

```forth
"example text"
" with leading and trailing spaces "
"Say ""HELLO"" to everyone"    | embed quotes by doubling them
```

When R3 encounters a string literal, it stores the bytes in memory, appends a zero byte (null terminator), and pushes the **address** of the first character onto the stack.

### Two Kinds of Strings

**In code definitions** (`:`):
```forth
:greet "Hello" .println ;
```
The string is stored in the string constants area and the address is pushed each time the word runs.

**In data definitions** (`#`):
```forth
#greeting "Hello"
```
The bytes are stored in variable memory, including the null terminator. `'greeting` is the address.

### Character-by-Character Processing

```forth
:printascii | t --
    ( c@+ 1? "%d " .print ) 2drop ;

"AB" printascii    | prints: 65 66
```

### Formatted Output

The `.print` word processes a format string with `%` placeholders, consuming values from the stack:

| Format | Description | Example |
|--------|-------------|---------|
| `%d` | Decimal number | `255 "%d"` → "255" |
| `%b` | Binary number | `5 "%b"` → "101" |
| `%h` | Hexadecimal | `255 "%h"` → "ff" |
| `%s` | String address | `"hello" "%s"` → "hello" |
| `%%` | Literal % | `"%%"` → "%" |

```forth
253 254 255 "%d %b %h" .print
| prints: 255 11111110 fc
```

> **Note:** The format string consumes values from the stack in right-to-left order matching the `%` placeholders. Use `dup` or `over` if you need to keep values on the stack after printing.

### Common String Operations

```forth
| String length
:strlen | str -- str len
    0 over ( c@+ 1? drop swap 1 + swap ) 2drop ;

| String copy
:strcpy | dest src --
    ( c@+ 1? over c! swap 1 + swap ) 2drop c! ;

| String compare (returns 0 if equal)
:strcmp | str1 str2 -- n
    ( c@+ 1?
        rot c@+ rot - 1? ( rot 2drop ; )
        drop swap
    ) 3drop 0 ;
```

### String Arrays

To create an array of string pointers:
```forth
#a "uno"
#b "dos"
#c "tres"
#lista 'a 'b 'c     | array of addresses
```

To create a contiguous block of strings:
```forth
#lista "uno" "dos" "tres"   | bytes packed together (no address table)
```

---

## Registers A and B

Registers A and B are two fast auxiliary variables optimized for memory traversal. Unlike stack values, they persist between word calls.

> **Primary use:** Load an address into A or B, then use `A@+` / `A!+` to read or write sequentially. This is much cleaner than managing pointer arithmetic on the data stack.

### Register Operations

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `>A` | `a --` | Load register A |
| `A>` | `-- a` | Push register A value |
| `A+` | `a --` | Add to register A |
| `A@` | `-- a` | Fetch qword from address in A |
| `A!` | `a --` | Store qword at address in A |
| `A@+` | `-- a` | Fetch qword from A, then A += 8 |
| `A!+` | `a --` | Store qword at A, then A += 8 |
| `cA@+` | `-- a` | Fetch byte from A, then A += 1 |
| `cA!+` | `a --` | Store byte at A, then A += 1 |
| `dA@+` | `-- a` | Fetch dword from A, then A += 4 |
| `dA!+` | `a --` | Store dword at A, then A += 4 |

Register B has identical operations: `>B`, `B>`, `B+`, `B@`, `B!`, `B@+`, `B!+`, etc.

### Example: Finding a Minimum

```forth
#list1 * $ffff
#list2 * $ffff
#minimum

:search | --
    a@+ minimum <? ( 'minimum ! ; ) drop ;

:find-minimums | --
    'list1 >a
    a@ 'minimum !
    1000 ( 1? 1- search ) drop

    'list2 >a
    a@ 'minimum !
    1000 ( 1? 1- search ) drop ;
```

`search` uses the address in register A. The first loop uses `list1`, the second uses `list2` — no need to pass the address through the stack.

### Nested Loops with Registers

```forth
#table * 800    | 10 × 10 × 8 bytes

'table >a
0 ( 10 <? 1 +
    0 ( 10 <? 1 +
        a@+ "%d " .print
    ) drop
    .cr
) drop
```

### Saving and Restoring Registers

Registers persist across word calls. When you must call another word that may use registers, save them first:

```forth
| Using the data stack:
:needs-registers | --
    a> b>               | save A and B
    ... use registers ...
    >b >a ;             | restore (note reversed order)

| Using the built-in save/restore pair (cleaner):
:with-saved-registers | --
    ab[                 | save A and B to return stack
    ... use registers freely ...
    ]ba ;               | restore A and B
```

### When to Use Registers

✓ **Good:** linear memory traversal, accumulator in loops, temporary address storage within a single word.

✗ **Avoid:** long-term storage across many words (use variables instead), or anywhere it would make the code harder to follow without documentation.

---

## Return Stack

There is a second stack that handles word calls — storing the return address used each time a `;` executes.

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `>R` | `a --` | Push to return stack |
| `R>` | `-- a` | Pop from return stack |
| `R@` | `-- a` | Copy top of return stack (non-destructive) |

> **Use with care:** The return stack is safe to use as temporary storage *within a single word*, as long as every `>R` is matched by an `R>` before any `;` (including conditional exits). Avoid using it across word boundaries — each word must leave the return stack exactly as it found it.

### Safe Usage Patterns

**Temporary storage:**
```forth
:example | a b c --
    >r >r           | save b and c
    ... work with a ...
    r> r> ;         | restore c and b
```

**Index preservation in a loop:**
```forth
:process-array | addr cnt --
    ( 1? >r
        @+ process-value
        r>
        1 -
    ) 2drop ;
```

### Common Errors

**Imbalanced return stack:**
```forth
| ✗ WRONG
:bad-word | n --
    >r
    ... code ...
    ;   | forgot r> — returns to wrong address!

| ✓ CORRECT
:good-word | n --
    >r
    ... code ...
    r> drop ;
```

**Conditional imbalance:**
```forth
| ✗ WRONG
:bad | n --
    >r
    condition? ( r> process )  | only pops in one branch!
    ;

| ✓ CORRECT
:good | n --
    >r
    condition? ( r> process ; )
    r> drop ;
```

---

## Operating System Connection

R3forth connects to the operating system through dynamic libraries (`.dll` on Windows, `.so` on Linux). This lets you call any C-compatible function from R3 code.

The pattern is always the same:

1. Load the library with `LOADLIB`
2. Get the function address with `GETPROC`
3. Call it with `SYS0`–`SYS10` depending on the number of arguments

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `LOADLIB` | `"name" -- liba` | Load a dynamic library |
| `GETPROC` | `liba "name" -- aa` | Get a function address |
| `SYS0` | `aa -- r` | Call function (0 parameters) |
| `SYS1` | `a aa -- r` | Call function (1 parameter) |
| `SYS2` | `a b aa -- r` | Call function (2 parameters) |
| `SYS3..10` | `... aa -- r` | Call function (3–10 parameters) |

### Example

```forth
"user32.dll" LOADLIB 'user32 !

user32 @ "MessageBoxA" GETPROC 'msgbox !

| MessageBoxA(NULL, text, title, MB_OK)
0 "Hello" "Title" 0 msgbox @ SYS4 drop
```

### Console Access

The simplest starting point — just include the console library:

```forth
^r3/lib/console.r3

: "hello world" .println ;
```

### Available Libraries

| Windows DLL | R3 Library | Purpose |
|-------------|------------|---------|
| SDL2.dll | `^r3/lib/sdl2.r3` | Graphics and window management |
| SDL2_image.dll | `^r3/lib/sdl2image.r3` | Image loading (PNG, JPG) |
| SDL2_mixer.dll | `^r3/lib/sdl2mixer.r3` | Audio playback |
| SDL2_net.dll | `^r3/lib/sdl2net.r3` | Network communication |
| SDL2_ttf.dll | `^r3/lib/sdl2ttf.r3` | TrueType font rendering |

> **Platform support:** R3 is designed for Linux, macOS, and Raspberry Pi, though these ports are in progress.

---

## Libraries

### Core — `^r3/lib/core.r3`

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `::msec` | `-- msec` | Milliseconds since program start |
| `::time` | `-- hms` | Current time (hours, minutes, seconds packed) |
| `::date` | `-- ymd` | Current date (year, month, day packed) |

```forth
:.time | --
    time
    dup 16 >> $ff and "%d:" .print    | hour
    dup  8 >> $ff and "%d:" .print    | minute
    $ff and "%d" .print               | second
    ;
```

### Console — `^r3/lib/console.r3`

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `::.cls` | `--` | Clear console |
| `::.write` | `"text" --` | Write text |
| `::.print` | `.. "fmt" --` | Formatted output |
| `::.println` | `"text" --` | Write text + newline |
| `::.home` | `--` | Move cursor to top-left |
| `::.at` | `x y --` | Position cursor |
| `::.fc` | `color --` | Set foreground color |
| `::.bc` | `color --` | Set background color |
| `::.input` | `--` | Read line of text from keyboard |
| `::.inkey` | `-- key` | Return pressed key (0 = none) |
| `::.cr` | `--` | Newline |

> After `.input`, the entered text is in the `##pad` variable.

### Random Numbers — `^r3/lib/rand.r3`

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `::rerand` | `s1 s2 --` | Initialize generator with two seeds |
| `::rand` | `-- rand` | 64-bit random number |
| `::randmax` | `max -- value` | Random number in [0, max) |

```forth
time msec rerand       | seed with time
100 randmax            | random integer 0–99
5.0 randmax 5.0 -      | random fixed-point -5.0 to 0.0
```

### Graphics — `^r3/lib/sdl2.r3`

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `::SDLinit` | `"title" w h --` | Open window |
| `::SDLfull` | `--` | Set fullscreen |
| `::SDLquit` | `--` | Close window |
| `::SDLcls` | `color --` | Clear screen |
| `::SDLredraw` | `--` | Flip buffers |
| `::SDLshow` | `'word --` | Run word every frame |
| `::exit` | `--` | Exit the show loop |

**Input variables:**

| Variable | Description |
|----------|-------------|
| `##SDLkey` | Pressed key code (0 = none) |
| `##SDLchar` | Character code |
| `##SDLx`, `##SDLy` | Mouse position |
| `##SDLb` | Mouse button state |

### Drawing — `^r3/lib/sdl2gfx.r3`

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `::SDLColor` | `col --` | Set color ($RRGGBB) |
| `::SDLPoint` | `x y --` | Draw pixel |
| `::SDLLine` | `x1 y1 x2 y2 --` | Draw line |
| `::SDLFRect` | `x y w h --` | Filled rectangle |
| `::SDLRect` | `x y w h --` | Rectangle outline |
| `::SDLFCircle` | `r x y --` | Filled circle |
| `::SDLCircle` | `r x y --` | Circle outline |
| `::SDLTriangle` | `x1 y1 x2 y2 x3 y3 --` | Filled triangle |

**Images:**

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `::SDLImage` | `x y img --` | Draw image |
| `::SDLImages` | `x y w h img --` | Draw image scaled |
| `::SDLspriteZ` | `x y zoom img --` | Draw with zoom |
| `::SDLSpriteR` | `x y ang img --` | Draw with rotation |

**Sprite sheets:**

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `::ssload` | `w h file -- ss` | Load sprite sheet |
| `::ssprite` | `x y n ss --` | Draw sprite N centered |
| `::sspriter` | `x y ang n ss --` | Draw with rotation |
| `::sspritez` | `x y zoom n ss --` | Draw with scale |

---

## Complete Example: Simple Game

```forth
^r3/lib/sdl2gfx.r3
^r3/lib/rand.r3

#sprites
#x 320.0  #y 240.0
#vx 0.0   #vy 0.0

:player
    x int. y int. 2.0 0 sprites sspritez
    vx 'x +!  vy 'y +! ;

:game-update
    SDLkey
    >esc< =? ( exit )
    <le>  =? ( -2.0 'vx ! )
    <ri>  =? (  2.0 'vx ! )
    <up>  =? ( -2.0 'vy ! )
    <dn>  =? (  2.0 'vy ! )
    >le<  =? ( 0.0 'vx ! )
    >ri<  =? ( 0.0 'vx ! )
    >up<  =? ( 0.0 'vy ! )
    >dn<  =? ( 0.0 'vy ! )
    drop ;

:game-draw
    0 SDLcls
    player
    SDLredraw ;

:game-loop
    game-update
    game-draw ;

:main
    "R3forth Game Demo" 640 480 SDLinit
    time msec rerand
    16 16 "player.png" ssload 'sprites !
    'game-loop SDLshow
    SDLquit ;

: main ;
```

---

## Debugging Guide

> **Note:** Debugging tools are still under development.

### Common Error Messages

| Error | Meaning | Solution |
|-------|---------|----------|
| `Error: 'word' not found` | Misspelled or undefined | Check spelling; define before use |
| `Stack underflow` | Used more values than available | Check stack balance |
| `Stack overflow` | Loop growing stack indefinitely | Check loop balance; add drops |
| `Division by zero` | Dividing by zero | Check before dividing |

### Debugging Techniques

**Print a value without consuming it:**
```forth
:debug-print | value -- value
    dup "DEBUG: %d" .print .cr ;

5 3 + debug-print    | Shows "DEBUG: 8", leaves 8 on stack
```

**Show the top 3 stack values:**
```forth
:s3 | a b c -- a b c
    ".s: " .print
    pick2 "%d " .print
    over  "%d " .print
    dup   "%d"  .print .cr ;

1 2 3 s3    | .s: 1 2 3
```

**Trace execution:**
```forth
:trace | "msg" --
    "TRACE: " .write .println ;

:suspicious-word | n --
    "Entering" trace
    dup 0? ( "Found zero" trace drop ; )
    "Processing" trace
    process-value ;
```

### Common Bug Patterns

**Missing DROP after conditional:**
```forth
| Symptom: stack grows unexpectedly
| ✗ n still on stack at end
:buggy | n --
    5 >? ( "Greater" .print )
    ;

| ✓
:fixed | n --
    5 >? ( "Greater" .print )
    drop ;
```

**Loop stack imbalance:**
```forth
| Symptom: crash or freeze
| ✗ each iteration adds a value
:buggy-loop | --
    10 ( 1? 1 -
        dup process
    ) ;

| ✓
:fixed-loop | --
    10 ( 1? 1 -
        dup process drop
    ) drop ;
```

**Register collision:**
```forth
| ✗ process-items may use register A
:outer | addr --
    >a
    process-items
    a> @ ;

| ✓ pass on stack or save registers
:outer | addr --
    ab[
    >a
    process-items
    ]ba
    @ ;
```

### Debugging Workflow

1. Isolate the problem — comment out code until the error disappears
2. Check stack balance — verify each word matches its stack comment
3. Add trace statements — print values at key points
4. Test with simple inputs — use known values to verify logic
5. Check boundary conditions — test with 0, negative, and large values

---

## Common Patterns

### Bounded Value (Clamp)

```forth
:clamp | value min max -- clamped
    rot
    over <? ( nip ; )    | value < min → return min
    nip
    over >? ( drop ; )   | value > max → return max
    nip ;
```

### Circular Buffer

```forth
#cbuffer * 800    | 100 cells
#cwrite 'cbuffer
#cread  'cbuffer
#ccount 0

:cbuffer-write | value --
    ccount 100 >=? ( 2drop ; ) drop
    cwrite !+
    dup 'cbuffer 800 + >=? ( drop 'cbuffer )
    'cwrite !
    1 'ccount +! ;

:cbuffer-read | -- value
    ccount 0? ( ; ) drop
    cread @+
    dup 'cbuffer 800 + >=? ( drop 'cbuffer )
    'cread !
    -1 'ccount +! ;
```

### State Machine

```forth
#state 0

:state0
    player-hit? ( 1 'state ! ; ) drop
    handle-state-0 ;

:state1
    player-safe? ( 0 'state ! ; ) drop
    handle-state-1 ;

#state-table 'state0 'state1

:update-state | --
    state 3 << 'state-table + @ ex ;
```

### String Builder

```forth
#str-buffer * 4096
#str-pos 'str-buffer

:str-reset | --
    'str-buffer 'str-pos ! ;

:str-add | "text" --
    ( c@+ 1?
        str-pos c!+
        'str-pos !
    ) 2drop ;

:str-get | -- "result"
    0 str-pos c!
    str-buffer ;

str-reset
"Hello " str-add
"World"  str-add
str-get .println    | "Hello World"
```

---

## Performance Considerations

### Stack vs Memory

Stack operations are fastest. Keep frequently-used values on the stack rather than in variables.

```forth
| Fast — pure stack
:fast | a b -- result
    dup * swap dup * + sqrt ;

| Slower — memory reads
:slow | --
    vara @ dup *
    varb @ dup * + sqrt ;
```

### Registers for Memory Traversal

```forth
| Slow — pointer managed on stack
:slow-loop | addr cnt --
    ( 1? 1 -
        over @ process
        swap 8 + swap
    ) 2drop ;

| Fast — pointer in register A
:fast-loop | addr cnt --
    swap >a
    ( 1? 1 -
        a@+ process
    ) drop ;
```

### Countdown vs Count-up

Countdown loops are faster because `1?` doesn't consume the counter:

```forth
| Faster
10 ( 1? 1 - process ) drop

| Slower — requires more stack work
0 ( 10 <? dup process 1 + ) drop
```

### Early Exit

Exit as soon as the answer is known:

```forth
:find-value | addr cnt target -- addr|0
    >r
    ( 1? 1 -
        over @ r@ =? ( r> 3drop ; )
        swap 8 + swap
    ) r> 3drop 0 ;
```

### Factoring vs Inlining

Factor for clarity, but inline trivial operations in tight loops:

```forth
| Overhead: tiny-helper is called 1000 times
:main-loop | --
    1000 ( 1? 1 - dup tiny-helper process ) drop ;

| Better for tight loops: inline
:main-loop | --
    1000 ( 1? 1 - dup 2 * process ) drop ;
```

---

## Best Practices

✓ **DO:**
- Write stack comments for every word
- Factor code into small, reusable words
- Use countdown loops (faster than count-up)
- Keep frequently-used values on the stack
- Test with boundary conditions (0, negative, large)
- Balance the stack in all code paths

✗ **DON'T:**
- Leave the stack imbalanced — every word should consume exactly what its stack comment promises
- Assume registers persist across calls to other words (save them if needed)
- Use deep stack operations — factor instead
- Optimize prematurely
- Mix memory access sizes carelessly
- Forget to `drop` after conditionals

---

*R3forth Tutorial — see the companion Reference document for the complete base dictionary.*
