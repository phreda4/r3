# R3forth Programming Manual

**A Concatenative Language Derived from ColorForth**

*Pablo H. Reda - 2025*

*English Translation and Corrections*

Repository: https://github.com/phreda4/r3

---

## Quick Reference Guide

- **Getting Started** → [Programming a Computer](#programming-a-computer)
- **Language Basics** → [R3 Language](#r3-language)
- **Stack Operations** → [Data Stack](#data-stack)
- **Control Flow** → [Conditionals](#conditionals), [Repetition](#repetition)
- **Memory & Variables** → [Variables and Memory](#variables-and-memory)
- **Common Errors** → [Debugging Guide](#debugging-guide)
- **Complete Examples** → [Simple Game](#complete-example-simple-game)
- **Word Reference** → [Base Dictionary](#appendix-1---base-dictionary)

---

## Table of Contents

1. [Programming a Computer](#programming-a-computer)
2. [R3 Language](#r3-language)
3. [Dictionary System](#dictionary-system)
4. [Data Stack](#data-stack)
5. [Arithmetic Operations](#arithmetic-operations)
6. [Fixed Point Operations](#fixed-point-operations)
7. [Conditionals](#conditionals)
8. [Repetition](#repetition)
9. [Recursion](#recursion)
10. [Variables and Memory](#variables-and-memory)
11. [Text and Memory](#text-and-memory)
12. [Registers A and B](#registers-a-and-b)

13. [Return Stack](#return-stack)
14. [Operating System Connection](#operating-system-connection)
15. [Libraries](#libraries)
16. [Complete Example: Simple Game](#complete-example-simple-game)
17. [Debugging Guide](#debugging-guide)
18. [Common Patterns](#common-patterns)
19. [Performance Considerations](#performance-considerations)
20. [Appendix 1 - Base Dictionary](#appendix-1---base-dictionary)

---

## Programming a Computer

A computer is a mechanism that needs a program to function - that is, a description of what it has to do.

This description is in a language the machine understands. But the programming process begins earlier.

First comes an idea, for example, drawing a circle. Then we write code so the machine draws a circle with radius 1 in a specific language, for example:

```forth
:draw 1 circle ;
: draw ;
```

The computer first translates this code into another language called machine code, which is the only one it can really understand. This process is called **compilation**.

Once the code written in the program is compiled, the result is executed on the computer.

If the code we write cannot be compiled, then there's an error in the code.

```forth
:draw 1 cicle ;  | Error: 'cicle' not found
: draw ;
```

When we try to compile, the computer tells us there's an error and doesn't execute anything.

Another possibility is that the program is well written but doesn't do what we want.

To accomplish this we need:

1. Have a problem or task to solve
2. Have an idea of how to solve it
3. Translate the idea into the programming language, make the program or code
4. Compile the code without errors
5. Execute the code and have it do what we imagine

> **Important:** We can only program what we know how to solve or test some solution we invent. We cannot program what we don't know how it works.

---

## R3 Language

### Introduction

Programming a computer means building a mechanism that will produce behavior in the machine, making the "recipe" of this behavior. This RECIPE is called SOURCE CODE or PROGRAM.

The program consists of 2 types of definitions:

- **DATA**, which we can also call MEMORY, STATE, or VARIABLE
- **CODE**, which we also call ORDER, ROUTINE, FUNCTION, or ACTION

As DATA we need to represent places in memory where to store numbers, which can represent or be used as:

- **QUANTITY**, for example: 3 lives
- **ADDRESS or LOCATION**, for example: position 100 on the screen
- **STATE**, for example: jumping or falling

As CODE we need to build ACTIONS.

We can build any behavior with the following elements:

- **SEQUENCE**: one order follows the next
- **CONDITION**: only if a condition is met is an order followed
- **REPETITION**: repeat an order in some indicated way
- **RECURSION**: define an action by referring to the same action (least used)

### Core Concepts

The program is a text file, the SOURCE CODE, where it's separated into words. A WORD is defined as a sequence of letters, digits, or characters, separated by spaces. Valid words are:

```forth
LIVES 134 -*jump*- lives
```

Case is not considered, so LIVES and lives are the same for the language.

### Essential Terminology

Before proceeding, let's establish key terms used throughout this manual:

**Stack Terms:**
- **TOS** = Top Of Stack (the last value pushed, most recent)
- **NOS** = Next Of Stack (the second-to-last value)
- **Stack cell** = One storage location (8 bytes / 64 bits)

**Memory Terms:**
- **byte** = 8 bits (c@ c! operations)
- **word** = 16 bits (w@ w! operations)
- **dword** = 32 bits / double word (d@ d! operations)
- **qword** = 64 bits / quad word (@ ! operations - default)

**Code Terms:**
- **Word** = A named function or data definition
- **Definition** = The code/data associated with a word
- **Dictionary** = The collection of all defined words

### Stack-Based Execution

All operations work through a data stack using postfix notation:

```forth
5 3 +     | Pushes 5, pushes 3, adds them → stack contains 8
10 dup *  | Pushes 10, duplicates it, multiplies → stack contains 100
```

### Word-Based Dictionary

Programs consist of words (space-separated tokens). The language searches a dictionary from last-defined to first-defined word.

> **Important:** Spaces define word boundaries. Often a code error is missing a space. The form of separation doesn't matter - it's the same if there's one space, several spaces, or it's on the next line.

### Compilation Process

1. Parse source code word by word
2. Prefixed words → interpret according to prefix
3. Numbers → push to stack
4. Known words → execute
5. Unknown words → compilation error

> **If you are a expert read this.** r3 is not like other forth, all the program is compiled and then execute, when say push to stack, te exac term is compile to push to stack and when say execute, the exac behavior is compile to execute the word.

### Prefix System

8 prefixes are recognized in words. These have meaning in the code we write:

| Prefix | Meaning | Example | Description |
|--------|---------|---------|-------------|
| `\|` | Comment | `\| This is a comment` | Not executed, ends at line end |
| `^` | Include | `^r3/lib/console.r3` | Include code from indicated file |
| `"` | String | `"Hello"` | Define text string, ends with `"` |
| `:` | Action | `:myword` | Define actions |
| `#` | Data | `#variable 5` | Define data/variables |
| `$` | Hexadecimal | `$FF` | Hexadecimal numbers |
| `%` | Binary | `%1010` | Binary numbers |
| `'` | Address | `'word` | Address of a word |

> **Note:** The address prefix needs a valid word, otherwise it's an error. Base dictionary words don't have addresses.

---

## Dictionary System

The language begins with a predefined dictionary. This dictionary has around 200 words that are the basic functions the computer performs. (See Appendix 1)

From here, new words are defined with prefixes `:` and `#`, and added to the dictionary to be used later.

When the language searches for a word in the dictionary, this search is performed from last to first. Words with the same name can be defined, but only the last defined will be executed.

> **Programming is creating words:** Programming is defining new words in this dictionary and finally calling the first word that will execute the entire program.

The inclusion prefix `^` takes the indicated text file and adds to the dictionary all words defined in this text that are marked as exported: double `::` for code and double `##` for data. the other words defined are private for this include.

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

| Program entry point (always last line)
: main-word ;
```

### Forward References Not Allowed

Words must be defined before use:

```forth
:word1 
    word2 ;         | ✗ ERROR - word2 not yet defined

:word2
    "hello" ;

| Correct order:
:word2
    "hello" ;

:word1
    word2 ;         | ✓ OK - word2 now exists
```

### Example Program

```forth
#side 5
:square dup * ;
: side square ;
```

Line 1 defines a variable with value 5.  
Line 2 defines a word that duplicates the top of stack and multiplies these two numbers.  
Line 3 is the program start, pushes 5 (the value of variable 'side'), then calls square.

At the end of the program, the stack will have the number 25.

### Understanding the Semicolon

The semicolon `;` terminates execution and returns to the caller. This means:

- A word definition can have multiple exit points (multiple semicolons)
- A word can have no semicolon (falls through to next definition - advanced technique)
- The semicolon is about control flow, not just marking the end of a definition

```forth
:example | n -- result
    0? ( ; )           | First exit point: return 0 if input is 0
    1 =? ( ; )         | Second exit point: return 1 if input is 1
    dup * ;            | Default exit: return n squared
```

---

## Data Stack

The stack is a concept in computing to represent values within a determined order and functioning. The first number to enter the stack is the last to leave it (LIFO - Last In, First Out).

When numbers are found in source code, they will be stacked as the code executes.

This is where all operations are performed. Here values are stored that will be used for calculations and to indicate parameters to other words.

### Stack Notation

Each word can take and/or leave values on the data stack. As help to the programmer, a comment is put with a stack state diagram before and after the word, separated by two dashes `--`.

**Format:** `| before -- after description`

```forth
:square | n -- n²
    dup * ;

:distance | x1 y1 x2 y2 -- dist
    rot - dup *         | x1 x2 dy²
    rot rot - dup *     | dy² dx²  
    + sqrt ;            | distance
```

### Stack Manipulation Words

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `DUP` | `a -- a a` | Duplicate top of stack |
| `SWAP` | `a b -- b a` | Exchange top two items |
| `DROP` | `a --` | Remove top of stack |
| `ROT` | `a b c -- b c a` | Rotate three items |
| `-ROT` | `a b c -- c a b` | Rotate inv three items |
| `OVER` | `a b -- a b a` | Copy second to top |
| `NIP` | `a b -- b` | Remove second item |
| `PICK2` | `a b c -- a b c a` | Copy third item to top |
| `PICK3` | `a b c d -- a b c d a` | Copy fourth item to top |
| `2DUP` | `a b -- a b a b` | Duplicate top two items |
| `2DROP` | `a b --` | Remove top two items |
| `2SWAP` | `a b c d -- c d a b` | Exchange top two pairs |

### Stack Visualization Practice

Understanding stack operations is crucial. Here's a step-by-step example:

```forth
| Exercise: Track the stack after each operation
5 3          | Stack: 5 3 (TOS=3, NOS=5)
+            | Stack: 8 (TOS=8)
dup          | Stack: 8 8 (TOS=8, NOS=8)
2 *          | Stack: 8 2 (TOS=2, NOS=8)
             | then: 8 16 (TOS=16, NOS=8)
swap         | Stack: 16 8 (TOS=8, NOS=16)
-            | Stack: 8 (TOS=8)
```

Some words PRODUCE numbers (like DUP duplicating the top of stack), others CONSUME numbers (like DROP eliminating the top), and some don't affect the stack or both consume and produce.

> **Stack Balance:** If your definition makes the stack grow indefinitely or consumes all numbers, the program has an error. This cannot be detected before execution - the program will freeze or stop.

### Stack Balance Rules

1. **Within a word:** Net stack effect should match the stack comment
2. **Within a loop:** Each iteration should leave the stack at the same height
3. **Within conditionals:** All branches should have the same stack effect

```forth
| ✗ WRONG - Stack imbalance in branches
:bad-example | n --
    5 >? ( dup )        | Branch adds to stack
    drop ;              | Fails if branch executed

| ✓ CORRECT - Balanced branches  
:good-example | n --
    5 >? ( dup drop )   | Branch is balanced
    drop ;              | Always works
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
| `>>` | `a b -- c` | Right bit shift (c = a >> b, signed) |
| `>>>` | `a b -- c` | Right bit shift (c = a >>> b, unsigned) |

**Examples:**
```forth
5 2 <<    | pushes 20 (5 * 4)
5 1 >>    | pushes 2 (5 / 2, signed)
-2 1 >>   | pushes -1 (sign bit preserved)
-1 1 >>>  | pushes 9223372036854775807 (sign bit not preserved)
```

### Other Operations

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `NEG` | `a -- -a` | Negate value |
| `ABS` | `a -- \|a\|` | Absolute value |
| `SQRT` | `a -- b` | Square root (integer) |
| `*/` | `a b c -- d` | d = a*b/c without bit loss |

The `*/` operation is particularly useful for scaling without overflow:

```forth
| Scale a value from 0-100 to 0-255
75 255 100 */    | Result: 191 (no intermediate overflow)
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

R3forth uses **48.16 fixed point format**: 48 bits for the integer part, 16 bits for the fractional part. This provides good precision while avoiding floating point complexity.

To operate with fixed point, the language recognizes numbers with decimal points and translates them to this representation:

```forth
1.5      | Stored as 98304 (1.5 * 65536)
3.14159  | Stored as 205887 (3.14159 * 65536)
```

### Fixed Point Bit Layout

```
64-bit number (qword):
[sign bit][47 integer bits][16 fractional bits]
   

Example: 3.5 in 16.16 format
Integer part: 3 = 0000000000000011 (binary)
Fraction: 0.5 = 1000000000000000 (binary, 0.5 = 32768/65536)
Combined: 00000000000000111000000000000000 (binary) = 229376 (decimal)
```

### Basic Fixed Point Operations

With these numbers, addition and subtraction are the same as integers, but multiplication and division need special words defined in `r3/lib/math.r3`:

```forth
^r3/lib/math.r3

| Fixed point operations
*.     | f f -- f  multiply two fixed point numbers
/.     | f f -- f  divide two fixed point numbers
int.   | f -- a    convert to integer (discard fractional part)
```

### Trigonometric and Math Functions

```forth
| Trigonometric functions (angle in turns: 180 degrees = 0.5)
cos    | f -- cos(f)   | 0.0 = 0°, 0.25 = 90°, 0.5 = 180°
sin    | f -- sin(f)   | 0.0 = 0°, 0.25 = 90°, 0.5 = 180°
tan    | f -- tan(f)
sqrt.  | f -- sqrt(f)  | Fixed point square root
ln.    | x -- r        | Natural logarithm
exp.   | x -- r        | Exponential
root.  | base root -- r | Nth root
```

**Example: Angle in turns**
```forth
0.0 sin    | sin(0°) = 0.0
0.25 sin   | sin(90°) = 1.0
0.5 sin    | sin(180°) = 0.0
0.75 sin   | sin(270°) = -1.0
```

### Custom Fixed Point Formats

The language also provides special operations for any bit distribution:

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `*>>` | `a b c -- d` | d = (a*b)>>c without bit loss |
| `<</` | `a b c -- d` | d = (a<<c)/b without bit loss |

**Example: 24.8 format operations**
```forth
| For 24.8 format (8 fractional bits):
a b 8 *>>    | Multiply two 24.8 numbers
a b 8 <</    | Divide two 24.8 numbers
```

---

## Conditionals

Parentheses are used to indicate code blocks. Note that they are words too and must be separated by spaces:

```forth
( code block )
```

Along with code blocks, we have conditional words that make comparisons to build conditionals and repetitions.

### Stack-Only Conditionals

These conditionals only check the top of stack **without consuming it**:

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `0?` | `a -- a` | True when a = 0 |
| `1?` | `a -- a` | True when a ≠ 0 |
| `-?` | `a -- a` | True when a < 0 |
| `+?` | `a -- a` | True when a ≥ 0 |

### Comparison Conditionals

These compare TOS with NOS, **consuming only TOS**:

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `=?` | `a b -- a` | a = b? (consume b, keep a) |
| `<?` | `a b -- a` | a < b? (consume b, keep a) |
| `<=?` | `a b -- a` | a ≤ b? (consume b, keep a) |
| `>?` | `a b -- a` | a > b? (consume b, keep a) |
| `>=?` | `a b -- a` | a ≥ b? (consume b, keep a) |
| `<>?` | `a b -- a` | a ≠ b? (consume b, keep a) |
| `AND?` | `a b -- a` | a AND b ≠ 0? (consume b, keep a) |
| `NAND?` | `a b -- a` | a NAND b ≠ 0? (consume b, keep a) |
| `IN?` | `a b c -- a` | b ≤ a ≤ c? (consume b and c, keep a) |

### Building Conditionals

A condition is built with a word indicating the condition followed by a code block that executes only if the condition is met:

```forth
3
4 >? ( "Greater than 4" .print )
4 <? ( "Less than 4" .print )
drop
```

Line 2 asks if there's a number greater than 4 on top of stack, and if so prints the text.  
The second of stack is not consumed, so conditions can be chained for a determined value.

### Critical Pattern: Value Persistence

**The tested value remains on stack after the test:**

```forth
x 
0? ( "Zero!" .print )
drop | MUST explicitly remove x when done
```

**Chaining conditionals** works because value persists:

```forth
x 
0? ( "Zero" .print )
+? ( "Positive or zero" .print )
-? ( "Negative" .print )
drop | Clean up once at end
```

### Stack Mechanics Example

```forth
| Start: 5 10 (TOS=10, NOS=5)
5 10 >? ( "10 > 5" .print )
| Comparison: 10 > 5? YES
| After test: 10 (comparison consumed 5, kept 10)
| Block executes because condition was true
| After block: 10 (still on stack)
drop | Remove remaining value

| Multiple comparisons:
x 5 >? ( 10 <? ( "Between 5 and 10" .print ) ) | exclusive
| First test: x > 5? (consumes 5, leaves x)
| Second test: x < 10? (consumes 10, leaves x)
| After both tests: x (still on stack!)
drop

| More readable with IN?:
x 6 9 IN? ( "Between 5 and 10" .print ) | exclusive
drop
```

### Early Exit Example

```forth
:min | a b -- c (minimum of a and b)
    over >? ( drop ; )  | If a > b, drop b and return a
    nip ;               | Otherwise drop a and return b
```

### Understanding IF-ELSE Absence

R3forth doesn't have IF-ELSE construction. This absence encourages factorization - it forces you to separate logic or find another way to solve the algorithm.

**Why no IF-ELSE? The Philosophy:**

Traditional languages use IF-ELSE as a crutch:
```c
// Traditional approach
if (x > 5) {
    action1();
} else {
    action2();  
}
```

R3 forces you to think: "What if I factored this differently?"

**R3 approach - factor the decision:**
```forth
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

To replicate IF-ELSE behavior when absolutely necessary:

```forth
| Instead of: A ?? ( B ) else ( C ) D
| Pattern 1: Use early exit
:condition A ?? ( B ; ) C ;
condition D
```

### Switch-Case Alternatives

**For sequential integers, use jump tables:**

```forth
:a0 "action 0" .print ;
:a1 "action 1" .print ;
:a2 "action 2" .print ;
:a3 "action 3" .print ;
:a4 "action 4" .print ;

#list 'a0 'a1 'a2 'a3 'a4

:action | n -- execute action n
    3 <<        | Multiply by 8 (cell size)
    'list + @ ex ;

2 action  | Prints "action 2"
```

**For non-sequential values, use comparison chains:**

```forth
:cases | value -- value string
    5 <? ( "less than 5" ; )
    6 =? ( "is 6" ; )
    7 =? ( "is 7" ; )
    111 <? ( "between 8 and 110" ; )
    "greater or equal to 111" ;

| Usage:
15 cases .print drop  | Prints "between 8 and 110"
```

> **Stack Balance:** Ensure all branches produce the same stack behavior, unless intentionally different.

### Common Conditional Errors

**ERROR 1: Forgetting to clean stack**
```forth
| ✗ WRONG - Stack pollution
:bad-example | value --
    5 >? ( "Greater" .print )
    | PROBLEM: value still on stack!
    ;

| ✓ CORRECT - Clean stack
:good-example | value --
    5 >? ( "Greater" .print )
    drop ;  | Remove value
```

**ERROR 2: Misunderstanding consumption**
```forth
| Start with: 10 5 (TOS=5, NOS=10)
10 5 >? ( "Yes" .print )
| After: 5 (10 was kept, 5 was consumed for comparison)
| Many expect: 10 (wrong!)
```

**ERROR 3: Nested conditions without drops**
```forth
| ✗ WRONG
x 5 >? ( 10 <? ( "Between" .print ) )
| Leaves x on stack twice if both conditions true!

| ✓ CORRECT
x 5 >? ( 10 <? ( "Between" .print drop ; ) )
drop
```

---

## Repetition

When the conditional is inside the block, a repetition is constructed. While this condition is met, the block repeats. When false, execution jumps to the next word after the block.

```forth
( condition code )
```

### Counting Up

```forth
1 ( 10 <?
    dup "%d " .print
    1 + ) drop
| Prints: 1 2 3 4 5 6 7 8 9
```

This code prints numbers 1 to 9. When TOS becomes 10 on line 2, it jumps to line 3 after the closing parenthesis.

### Preferred Pattern - Countdown

Conditionals that don't consume stack execute faster. Zero becomes the preferred end marker:

```forth
10 ( 1? 1 - ) drop
| Counts from 10 down to 1
```

Whether we need 0 in the loop determines if we put our code before or after the decrement:

```forth
| Code BEFORE decrement (includes 0)
10 ( 1? dup process 1 - ) drop

| Code AFTER decrement (excludes 0)  
10 ( 1? 1 - dup process ) drop
```

### Nested Loops - 10x10 Table

```forth
#table * 800  | 10 x 10 x 8 (8 bytes per number)

'table
0 ( 10 <? 1 +
    0 ( 10 <? 1 +
        rot @+ "%d " .print
        rot rot
    ) drop
    .cr
) drop
```

### Controlled Iteration with Processing

```forth
:print-squares | n --
    0 ( over <? 
        dup dup * swap
		"%d² = %d" .print .cr
        1 + 
    ) 
    2drop ;

5 print-squares
| Prints:
| 0² = 0
| 1² = 1
| 2² = 4
| 3² = 9
| 4² = 16
```

### Memory Traversal Patterns

#### Pattern 1: Null-Terminated Strings

```forth
"text" ( c@+ 1?
    process-char  | Process consumes char value
) 2drop
| Leaves address+1 and 0, both dropped
```

When traversing memory with a termination marker (usually 0):

```forth
"hello" ( c@+ 1?
    use-each-character 
) 2drop
```

> **Careful:** When exiting the loop, besides the address, we have 0 pushed on stack (from the terminator).

#### Pattern 2: Counted Structures

Using a count requires more stack juggling:

```forth
"hello" 5 ( 1? 1 -
    swap c@+ 
    use-each-character  | Must consume the character
    swap 
) 2drop
```

Compare the two approaches:

```forth
| With terminator (cleaner):
'array ( @+ -1 <>?
    process-value
) 2drop

| With count (more complex):
'array count ( 1? 1 -
    swap @+ process-value
    swap
) 2drop
```

#### Pattern 3: Loop with Early Exit

```forth
:find-zero | addr cnt -- addr|0
    ( 1? 1 -
        over @ 0? ( 2drop 0 ; ) drop  | Early exit with 0
        swap 8 + swap
    ) 
    2drop 0 ;  | Normal exit also returns 0
```

**Critical Pattern**: Use `;` inside loop to exit early with specific return value. 

⚠️ **WARNING**: Take care of stack state in exit condition!

#### Pattern 4: Nested Loops

```forth
:fill-2d | value rows cols --
    0 ( pick2 <? | Outer loop: row counter
        0 ( pick2 <? | Inner loop: col counter
            pick4 write-value | Use value from deep stack
            1 +
        ) drop
        1 +
    ) 
    4drop ; | Remove value, rows, cols, and final counter!
```

**Problem**: Deep stack access gets messy. **Solution**: Factor or use registers (see next section).

#### Pattern 5: Loop with Accumulator

```forth
:sum-array | addr cnt -- sum
    0 swap        | addr acc cnt
    ( 1? 1 -      | Loop while count > 0
        -rot      | cnt addr acc
        swap @+   | cnt acc addr' value
        rot +     | cnt addr' newacc
        rot       | addr' newacc cnt
    ) 
    drop nip ;    | Remove cnt and addr, keep sum
```

**Alternative with register A**:

```forth
:sum-array | addr cnt -- sum
    0 >a          | Accumulator to register A
    ( 1? 1 -
        swap @+ a> + >a swap
    ) 2drop
    a> ;
```

**Alternative with register for address**  (much cleaner):

```forth
:sum-array | addr cnt -- sum
    swap >a       | Address to register A
    0             | Accumulator on stack
    ( swap 1? 1 -
        swap a@+ +
    ) drop ;      | Register A is "dirty" but acceptable in local scope
```

### Multiple Exit Conditions

Valid to perform multiple comparisons to exit the loop:

```forth
"text" ( c@+ 1?    | Continue while not zero
    13 <>?         | AND not carriage return
    10 <>?         | AND not line feed
    drop 
) 2drop

| Here we have either: 0, 13, or 10 on stack (plus address)
```

Each loop exit must have the same stack behavior.

### Memory Operations Example

```forth
#buffer * 80   | Allocate 80 bytes (10 qwords)

| Fill buffer with values
'buffer 10 ( 1? 1 -
    dup rot !+    | Store counter and increment addr
    swap
) 2drop

| Read buffer values  
'buffer 10 ( 1? 1 -
    swap @+ "%d " .print
    swap
) 2drop
| Prints: 10 9 8 7 6 5 4 3 2 1
```

---

## Recursion

Recursion is built by calling the word being defined from within itself.

As soon as a word definition starts, it can be invoked, so recursion occurs naturally.

### Fibonacci Example

The Fibonacci sequence starts with 1 at positions 0 and 1, with each subsequent term being the sum of the two previous ones.

```forth
:fibonacci | n -- f
    2 <? ( 1 nip ; )        | Base case: fib(0) = fib(1) = 1
    1 - dup                 | Calculate n-1, duplicate it
    1 - fibonacci           | Calculate fib(n-2)
    swap fibonacci          | Calculate fib(n-1)
    + ;                     | Sum them
```

> **Recursion Guidelines:** As with all recursive definitions, special care must be taken with the termination condition and stack state when the word terminates.

### Factorial Example

```forth
:factorial | n -- n!
    dup 1 <=? ( drop 1 ; )  | Base case: 0! = 1! = 1
    dup 1 -                 | n (n-1)
    factorial               | n (n-1)!
    * ;                     | n!

5 factorial | Result: 120
```

### Tail Call Optimization

When a word is called before `;` (end of word), the language internally doesn't return from this word to terminate, but terminates in the called word. This is called "tail call" optimization.

In recursion, if the last word calls itself, it transforms into a loop:

```forth
:loopback | n -- 0
    0? ( ; )      | Base case: if n=0, exit
    1 -           | Decrement
    loopback ;    | Tail call: becomes a loop!

10 loopback | Efficiently counts down without stack growth
```

### Recursion vs Iteration

**When to use recursion:**
- Tree traversal
- Divide and conquer algorithms
- When the problem naturally breaks into smaller similar problems

**When to use iteration (loops):**
- Simple counting
- Linear traversal

```forth
| Recursion: Natural for tree problems
:tree-sum | node -- sum
    dup 0? ( ; )              | Null node = 0
    dup @ swap                | Get node value
    8 + @ tree-sum            | Sum left child
    + swap                    | Add to total
    16 + @ tree-sum           | Sum right child
    + ;                       | Add to total

| Iteration: Better for linear problems
:array-sum | addr cnt -- sum
    0 swap ( 1? 1 -
        swap @+ rot + swap
    ) 2drop ;
```

### Common Recursion Pitfalls

**ERROR 1: Missing base case**
```forth
| ✗ WRONG - Infinite recursion
:bad-countdown | n --
    dup "%d " .print
    1 - bad-countdown ;  | Never stops!

| ✓ CORRECT
:good-countdown | n --
    dup 0? ( drop ; )    | Base case
    dup "%d " .print
    1 - good-countdown ;
```

**ERROR 2: Stack imbalance between base and recursive cases**
```forth
| ✗ WRONG
:bad-fib | n -- result
    2 <? ( 1 ; )         | Base case leaves 1 value
    dup 1 -              | But this leaves 2 values!
    bad-fib + ;

| ✓ CORRECT
:good-fib | n -- result
    2 <? ( 1 nip ; )     | Base case: replace n with 1
    1 - dup              | Duplicate for two recursive calls
    1 - good-fib
    swap good-fib + ;    | Always leaves 1 value
```

---

## Variables and Memory

Variables define memory for data storage. Variables have a name, a memory address, and a value stored at that memory location. The actual address where each variable is located is obtained when executed - it's not necessary to know this address value, just use its name to represent it.

```forth
#lives 3
#positionX #positionY
#map * $400  | 1KB
#list 3 1 4
#energy 1000
```

Using hex address $1000 as an example, this code reflects in memory as:

| Line | Name | Address | Value |
|------|------|---------|--------|
| 1 | lives | $1000 (4096) | 3 |
| 2 | positionx | $1008 (4104) | 0 |
| 2 | positiony | $1010 (4112) | 0 |
| 3 | map | $1018 (4120) | 0 0 0 ... 0 |
| 4 | list | $1418 (5144) | 3 1 4 |
| 5 | energy | $1430 (5168) | 1000 |

### Variable Definition and Usage

Variables in R3forth define memory maps. When compiled, data and code memory are separated regardless of definition order:

```forth
#var            | Define one 64-bit cell with value 0
#var 33         | Define one cell with value 33  
#var 33 11      | Two cells: first=33, second=11 (16 bytes total)
```

### Mixed Data Types in Definitions

```forth
#data 33 11 [ 1 2 ] ( 3 4 )
```

**Memory layout at 'data:**

| Offset | Size | Value | Type | Notes |
|--------|------|-------|------|-------|
| +0 | 8 bytes | 33 | qword | Default size |
| +8 | 8 bytes | 11 | qword | Default size |
| +16 | 4 bytes | 1 | dword | From [ ] bracket |
| +20 | 4 bytes | 2 | dword | From [ ] bracket |
| +24 | 1 byte | 3 | byte | From ( ) parenthesis |
| +25 | 1 byte | 4 | byte | From ( ) parenthesis |

### String Definitions

String definitions create byte sequences:

```forth
#string "hola" "que" 0
```

**Memory layout at 'string:**

| Offset | Content | Bytes |
|--------|---------|-------|
| +0 | 'h' 'o' 'l' 'a' 0 | 5 bytes |
| +5 | 'q' 'u' 'e' 0 | 4 bytes |
| +9 | 0 (qword) | 8 bytes |

### Variable Access

```forth
| Basic access:
5 'var !         | Store 5 in var variable
'var @           | Fetch value from var variable  
var              | Same as 'var @ - pushes variable value
1 'var +!        | Add 1 to var variable
```

### Memory Access Words

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `!` | `value address --` | STORE - write value to address |
| `@` | `address -- value` | FETCH - read value from address |
| `+!` | `val address --` | Add val to value at address |
| `!+` | `value address -- address+8` | Store and increment address by 8 |
| `@+` | `address -- address+8 value` | Fetch and increment address by 8 |

> **Memory Layout:** Each number in memory is stored in 8 bytes (64 bits). If there's a sequence of numbers, they will be at this distance apart.

### Example Usage

```forth
:listshow
    'list
    @+ "%d " .print  | prints 3
    @+ "%d " .print  | prints 1  
    drop ;

'list 8 + @         | pushes 1
1 'positionX +!     | add 1 to positionX
listshow            | prints 3 1

5 6                 | 5 6
'list               | 5 6 $1418
!+                  | 5 $1420
!                   |
listshow            | prints 6 5
```

### Different Memory Access Sizes

| Size | Fetch | Store | Fetch+ | Store+ | Increment |
|------|-------|-------|--------|--------|-----------|
| 8 bits | `c@` | `c!` | `c@+` | `c!+` | +1 byte |
| 16 bits | `w@` | `w!` | `w@+` | `w!+` | +2 bytes |
| 32 bits | `d@` | `d!` | `d@+` | `d!+` | +4 bytes |
| 64 bits | `@` | `!` | `@+` | `!+` | +8 bytes |

**Critical correction from original manual:** The increment operations advance the address by the appropriate size:

```forth
| ✓ CORRECT increments:
'buffer c@+  | Fetch byte, increment by 1
'buffer w@+  | Fetch word, increment by 2
'buffer d@+  | Fetch dword, increment by 4
'buffer @+   | Fetch qword, increment by 8
```

### Memory Buffer Management

```forth
| Memory buffer with pointer
#buffer * 1000      | 1000 bytes
#buffer> 'buffer    | Pointer to next free position

:+element | element --
    buffer> !+ 'buffer> ! ;

:traverse
    'buffer ( buffer> <?
        @+ "%d " .print
    ) drop ;

3 +element
4 +element  
5 +element
traverse | prints 3 4 5
```

### Memory Alignment Considerations

When mixing data sizes, be aware of alignment:

```forth
#mixed [ 1 2 ] 5 ( 3 4 )

| Actual memory layout:
| +0:  1 (dword, 4 bytes)
| +4:  2 (dword, 4 bytes)
| +8:  5 (qword, 8 bytes) - aligned to 8-byte boundary
| +16: 3 (byte, 1 byte)
| +17: 4 (byte, 1 byte)
| +18-23: padding (6 bytes to next qword boundary)
```

---

## Text and Memory

Double quotes handle text within the program. Text is identified by this prefix and terminated with another double quote.

Text in source code is called a string or character chain.

Text can be thought of as a sequence of bytes in memory - text handling is the same as memory handling, but the unit is bytes instead of qwords (8 bytes).

### String Examples

```forth
"example text"
" example text "  | with spaces
"Say ""HELLO"" to everyone"  | embedded quotes (double the quote)
```

When R3 encounters text, it stores it in memory. Each character occupies one byte corresponding to ASCII code. A zero byte is added at the end indicating the text's end. The ADDRESS of the text start is then pushed onto the stack.

> **String Storage:** Text is stored in separate memory from variables, unless the text is in a variable definition, in which case it will be in the variables memory area.

```forth
#lives 3
#text "BEWARE of the dog"
#dogs 4
```

### Character-by-Character Processing

```forth
:printascii | t --
    ( c@+ 1? "%d " .print ) 2drop ;

"AB" printascii  | prints: 65 66 
```

### Formatted Output with sprint

The `sprint` word (in r3/lib/mem.r3) processes text with % placeholders:

| Format | Description | Example |
|--------|-------------|---------|
| `%d` | Print number in decimal | `255 "%d"` → "255" |
| `%b` | Print number in binary | `5 "%b"` → "101" |
| `%h` | Print number in hexadecimal | `255 "%h"` → "ff" |
| `%s` | Print text from address | `"hello" "%s"` → "hello" |
| `%%` | Print % sign | `"%%"` → "%" |

```forth
253 254 255 "%d %b %h" .print
| prints: 255 11111110 fc
```

> **Careful:** The text format consumes requested values from the stack. Sometimes we need an `over` or `dup` to maintain these numbers on the stack.
> **for experts** the format string is the only stack effect outside r3. this make hard to static stack calc.

### String Processing Libraries

Useful definitions for text handling are in libraries ^r3/lib/str.r3 and ^r3/lib/parse.r3.

For example, to count characters in text:

```forth
::count | s1 -- s1 cnt
    0 over ( c@+ 1?
        drop swap 1 + swap 
    ) 2drop ;

| Usage:
"hello" count  | Leaves "hello" 5 on stack
```

This traverses until finding a 0 byte, adding to a counter on stack. When finished, removes the last 0 and address, leaving the count on stack.

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

---

## Registers A and B

We have something like two privileged variables called registers A and B. These registers are very useful for traversing memory, for reading or writing values. Additionally, they are maintained between word calls.

**Safe usage patterns:**
1. Use `ab[` ... `]ba` to save/restore registers
2. Pass values on stack instead when calling other words
3. Document register usage in stack comments

### Register Operations

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `>A` | `a --` | Load register A |
| `A>` | `-- a` | Push register A value |
| `A+` | `a --` | Add to register A |
| `A@` | `-- a` | Fetch qword from memory at A |
| `A!` | `a --` | Store qword in memory at A |
| `A@+` | `-- a` | Fetch qword from A and increment A by 8 |
| `A!+` | `a --` | Store qword at A and increment A by 8 |

**Size-specific operations:**

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `cA@` | `-- a` | Fetch byte from A |
| `cA!` | `a --` | Store byte at A |
| `cA@+` | `-- a` | Fetch byte from A and increment A by 1 |
| `cA!+` | `a --` | Store byte at A and increment A by 1 |
| `dA@` | `-- a` | Fetch dword from A |
| `dA!` | `a --` | Store dword at A |
| `dA@+` | `-- a` | Fetch dword from A and increment A by 4 |
| `dA!+` | `a --` | Store dword at A and increment A by 4 |

Register B has identical operations: `>B`, `B>`, `B+`, `B@`, `B!`, `B@+`, `B!+`, `cB@`, `cB!`, etc.

> **use of registers** the main pourpose of register is keep address for traverse memory, for read an write.

### Example: Finding Minimum Values

```forth
#list1 * $ffff  | 64kb
#list2 * $ffff  | 64kb  
#minimum

:search | --  (uses register A)
    a@+ minimum <? ( 'minimum ! ; ) drop ;

:find-minimums | --
    'list1 >a              | Set register A to list1
    a@ 'minimum !          | Initialize minimum
    1000 ( 1? 1- search ) drop

    'list2 >a              | Set register A to list2
    a@ 'minimum !          | Re-initialize minimum
    1000 ( 1? 1- search ) drop ;
```

The word `search` will use the address in register A. On line 8 it will be list1, on line 12 it will be list2. This could be passed as a parameter on the stack but would require moving the element counter. The variable minimum will have the minimum value of each list when the loop terminates.

### Nested Loops with Registers

The nested loop example with registers avoids the stack manipulation needed to retrieve address, recover value, and advance:

```forth
#table * 800  | 10 x 10 x 8 (8 bytes per number)

'table >a
0 ( 10 <? 1 +
    0 ( 10 <? 1 +  
        a@+ "%d " .print
    ) drop
    .cr
) drop
```

### Register Save/Restore

When you must preserve registers across calls:

```forth
| Manual save/restore is stack
:needs-registers | --
    a> b>           | Save A and B to stack
    ... use registers ...
    >b >a ;         | Restore A and B

| Using save/restore words, not pollute the stack
:with-saved-registers | --
    ab[             | Save registers
    ... use registers freely ...
    ]ba ;           | Restore registers
```

### When to Use Registers

✓ **Good uses:**
- Linear memory traversal in a single word
- Accumulator in loops
- Temporary address storage

✗ **Bad uses:**
- Long-term storage (use variables instead)

---

## Return Stack

There exists a second stack that handles calls between words, storing the return address that will be used each time a word termination `;` is executed.

We have the following words to manipulate the return stack:

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `>R` | `a -- rstack: -- a` | Push to return stack |
| `R>` | `-- a rstack: a --` | Pop from return stack |
| `R@` | `-- a rstack: a -- a` | Copy top of return stack |

When a word is called (a code definition, not data), the language pushes onto the return stack the location where it should return once the called word's execution terminates.

⚠️ **WARNING:** It's advisable not to use this stack since an imbalance between calls will cause the code to break. However, it can be used as an alternative place to save or retrieve values, always being careful that each word that pushes values here must pop them precisely.

### Safe Return Stack Usage

**Pattern: Temporary storage in a loop**

```forth
:example | a b c --
    >r >r           | Save b and c to return stack
    ... work with a ...
    r> r>           | Restore c and b
    ... continue ...
    ;
```

**Pattern: Index preservation**

```forth
:process-array | addr cnt --
    ( 1? >r         | Save counter to return stack
        @+ process-value
        r>          | Restore counter
        1 -
    ) 2drop ;
```

### Return Stack Dangers

**ERROR: Imbalanced return stack**

```forth
| ✗ WRONG - Return stack imbalance
:bad-word | n --
    >r
    ... code ...
    ; | Forgot r> - will return to wrong address!

| ✓ CORRECT
:good-word | n --
    >r
    ... code ...
    r> drop ;  | Or use the value
```

**ERROR: Conditional imbalance**

```forth
| ✗ WRONG
:bad-conditional | n --
    >r
    condition? ( r> process )  | Only pops in one branch!
    ;

| ✓ CORRECT
:good-conditional | n --
    >r
    condition? ( r> process ; )
    r> drop ;  | Ensure both branches balance
```

### Advanced: Return Stack for Control Flow

It's possible to alter the return stack to change execution flow, but you must think very carefully about what will happen:

```forth
| Advanced technique - exit from nested calls
:early-exit | --
    r> r> 2drop     | Remove two return addresses
    ;               | Return to caller's caller

:level2 | --
    condition? ( early-exit )
    "level2" .print ;

:level1 | --
    level2
    "level1" .print ;  | Skipped if early-exit called

level1  | Might print just "level1" or both
```

> **Use with extreme caution:** Manipulating the return stack for control flow is error-prone and makes code hard to understand. Prefer factoring and early exits with `;` instead.


# Memory Management in R3forth

## Introduction

One key difference between R3forth and other programming languages is its approach to memory management.

R3 encourages building a **real memory map** - that is, a detailed description of how memory is laid out during code execution. This explicit approach gives programmers direct control and understanding of their program's memory usage.

---

## Static Memory - Variable Definitions

Each variable definition allocates memory cells with the indicated names.

### Basic Variable Definition

```forth
#var1 1234
```

The variable `var1` is the name of the memory address where the number 1234 is stored in 8 bytes of memory (64 bits).

### Different Memory Sizes

Memory can be defined in different sizes:

```forth
#var32 [ 1234 ]    | 32 bits (dword)
#var8 ( 123 )      | 8 bits (byte)
```

| Syntax | Size | Type | Example |
|--------|------|------|---------|
| `#var n` | 64 bits | qword | `#var 1234` |
| `#var [ n ]` | 32 bits | dword | `#var [ 1234 ]` |
| `#var ( n )` | 8 bits | byte | `#var ( 123 )` |

### Memory Maps

Variables define the memory map in the order they are defined.

Additionally, multiple memory cells can be allocated by indicating numbers as a list:

```forth
#lista 1 2 3 4
```

Any size modifier can be used:

```forth
#listavar 1 2 [ 3 4 ] ( 5 6 7 ) 8
```

**Memory layout of `listavar`:**

| Offset | Value | Size | Type |
|--------|-------|------|------|
| +0 | 1 | 8 bytes | qword |
| +8 | 2 | 8 bytes | qword |
| +16 | 3 | 4 bytes | dword (from `[ ]`) |
| +20 | 4 | 4 bytes | dword (from `[ ]`) |
| +24 | 5 | 1 byte | byte (from `( )`) |
| +25 | 6 | 1 byte | byte (from `( )`) |
| +26 | 7 | 1 byte | byte (from `( )`) |
| +27-31 | padding | 5 bytes | alignment |
| +32 | 8 | 8 bytes | qword |

### Word Addresses in Data Definitions

When defining memory, references to words are always addresses. Therefore, these two definitions are equivalent:

```forth
#vector1 'suma
#vector2 suma
```

Both store the address of the word `suma` in memory.

### Memory Buffers

A memory fragment can be defined with the `*` (multiply) operator:

```forth
#buffer * $ffff    | 64 KB
#pad * 1024        | 1 KB
```

The variable names indicate the beginning of these memory fragments.

**Example: Buffer allocation**

```forth
#scratch * 4096    | 4KB scratch buffer
#image-data * $10000  | 64KB for image data
#text-buffer * 8192   | 8KB for text
```

---

## Dynamic Memory

The only word the language provides for accessing free memory is:

```forth
MEM  | -- address_of_start_of_free_memory
```

Of course, you can call OS functions via libraries for memory allocation or deallocation, but the current distribution does not use this mechanism.

### Free Memory Start

The start of free memory is immediately after variable definitions.

From this word, a mechanism is generated that allows managing free memory.

### Memory Management Words

This mechanism consists of three words that have a different meaning than in other Forth systems:

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `HERE` | `-- addr` | Variable containing the next free memory address |
| `MARK` | `--` | Save HERE on a stack (mark current free memory) |
| `EMPTY` | `--` | Pop HERE from stack (release used memory) |

#### HERE

`HERE` is a variable that contains the free memory address that increments as memory is used.

#### MARK

`MARK` saves HERE on a stack - that is, it marks where the current free memory is located.

#### EMPTY

`EMPTY` pops HERE from the stack, functioning as a memory release. **Important:** It's a stack - it doesn't need marks to indicate if memory is used or not.

### Memory Organization Implications

From this mechanism, it follows that when we define memory we can have:
- **Many fixed-size fragments**
- **Only one variable-size fragment (the last one)**

This requires organizing how we use memory. The advantage is that **no garbage collector is needed**.

### Benefits of This Scheme

This memory scheme requires being more careful about memory allocation, and this care improves the system.

Systems that need memory on demand are generally creation programs, where variable-size memory can be placed at the end of this address stack. When deeper reorganization is needed, this fragment stack is rebuilt.

### Memory Retention Example

It may happen that part of this memory stops being used and yet the decision is made to keep this memory. For example:
1. Load a text
2. Tokenize the text
3. Use this tokenization

The text stops being used directly but can be left in memory.

### Dynamic Memory Usage Pattern

```forth
| Mark current free memory position
MARK

| Allocate and use temporary data
HERE 1000 + 'HERE !    | Allocate 1000 bytes
HERE 500 - 'temp !     | Use some memory

| ... do work with temporary memory ...

| Release all temporary memory
EMPTY
```

### Nested Memory Allocation

```forth
:process-data | --
    MARK                      | Mark level 1
    HERE 'buffer1 !
    1024 'HERE +!            | Allocate 1KB
    
    MARK                      | Mark level 2
    HERE 'buffer2 !
    2048 'HERE +!            | Allocate 2KB
    
    | Use buffer2
    process-with-buffer2
    
    EMPTY                     | Release buffer2
    
    | Use buffer1
    process-with-buffer1
    
    EMPTY ;                   | Release buffer1
```

---

## Strings - Character Sequences

Strings are sequences of bytes, defined by enclosing them in double quotes.

To represent a quote mark, use two double quotes:

```forth
"Say ""HELLO"" to everyone"
```

The end of line is included within the string, so it's possible to define multi-line strings:

```forth
#multiline "This is line one
This is line two
This is line three"
```

### Two Types of String Definitions

There are two places where strings can be defined:

#### 1. When Defining Code

```forth
:hola "hola mundo" print ;
```

Here it's saved in a string constants memory area, separate from variables. What this does is **push this memory address** onto the stack.

**Characteristics:**
- Stored in separate string constant area
- Returns address when executed
- Cannot be modified
- Shared if same string appears multiple times

#### 2. When Defining Data

```forth
#palabras "uno"
```

In this case, the string leaves the corresponding bytes in memory and adds a zero byte at the end of the string. The memory where this is saved is in the same place where variables are.

**Characteristics:**
- Stored in variable memory area
- Null-terminated (0 byte at end)
- Can be part of data structures
- Each definition creates separate copy

### String Arrays

If you want to make a list of string addresses using variables, you must define the variable and then use its address:

```forth
#a "uno"
#b "dos"
#c "tres"
#lista 'a 'b 'c
```

**Memory layout:**

```
Address $1000: 'u' 'n' 'o' 0        | Variable 'a'
Address $1004: 'd' 'o' 's' 0        | Variable 'b'
Address $1008: 't' 'r' 'e' 's' 0    | Variable 'c'
Address $100D: $1000 $1004 $1008    | Variable 'lista' (addresses)
```

This is different from the following definition which generates another structure:

```forth
#lista "uno" "dos" "tres"
```

**Memory layout:**

```
Address $1000: 'u' 'n' 'o' 0 'd' 'o' 's' 0 't' 'r' 'e' 's' 0
               |______a____| |____b____| |______c______|
```

In this case, `lista` points to the beginning, but there's no array of addresses - the strings are contiguous in memory.

### String Manipulation Examples

```forth
| Define string constants
:msg1 "Hello" ;
:msg2 "World" ;

| Define string variables
#str1 "Initial text"
#str2 * 256    | Buffer for string (256 bytes)

| Copy string to buffer
:copy-to-buffer | src --
    'str2 ( c@+ 1?
        over c! 1 +
    ) 2drop c! ;

"New text" copy-to-buffer
```

### String Constant vs String Variable

```forth
| String in code (constant)
:show-constant
    "This is a constant" print ;  | Address pushed each time

| String in data (variable)
#text "This is a variable"

:show-variable
    text print ;                   | Address of 'text' variable
```

---

## Memory Layout Summary

### Complete Memory Map

```
┌─────────────────────────────────────┐
│  CODE MEMORY (Program)              │
│  - Compiled word definitions        │
│  - Cannot be modified at runtime    │
└─────────────────────────────────────┘
┌─────────────────────────────────────┐
│  STRING CONSTANTS (Code strings)    │
│  - Strings defined in : definitions │
│  - Read-only                        │
└─────────────────────────────────────┘
┌─────────────────────────────────────┐
│  VARIABLE MEMORY (Data)             │
│  - # variable definitions           │
│  - Data strings                     │
│  - Fixed-size buffers               │
└─────────────────────────────────────┘
         │
         │ HERE points here
         ▼
┌─────────────────────────────────────┐
│  FREE MEMORY (Dynamic)              │
│  - Managed by MEM/HERE/MARK/EMPTY   │
│  - Grows upward as allocated        │
└─────────────────────────────────────┘
```

### Variable Memory Example

```forth
#var1 100              | Offset +0:  8 bytes
#var2 [ 200 ]          | Offset +8:  4 bytes
#var3 ( 50 )           | Offset +12: 1 byte
                       | Offset +13: 3 bytes padding
#str "hello"           | Offset +16: 6 bytes ('h''e''l''l''o'0)
                       | Offset +22: 2 bytes padding
#buffer * 1024         | Offset +24: 1024 bytes
#ptr 'var1             | Offset +1048: 8 bytes (address of var1)
```

---

## Best Practices

### ✓ DO:

1. **Plan your memory map** before coding
2. **Use fixed buffers** for known maximum sizes
3. **Use MARK/EMPTY pairs** properly (like brackets)
4. **Document memory layouts** in comments
5. **Keep dynamic memory simple** - one growing region

### ✗ DON'T:

1. **Mix memory types** carelessly
2. **Forget to EMPTY** after MARK
3. **Assume garbage collection** - it doesn't exist
4. **Use dynamic memory** when static works
5. **Create fragmented allocations** - keep it stack-like

---

## Advanced Patterns

### Pattern: Temporary Buffer

```forth
:with-temp-buffer | size 'word --
    swap >r         | Save word address
    MARK            | Mark memory
    HERE swap       | Get buffer address
    dup r> ex       | Execute word with buffer
    EMPTY ;         | Release memory

| Usage:
1024 '[ process-data-with-buffer ] with-temp-buffer
```

### Pattern: Memory Pool

```forth
#pool-start 0
#pool-end 0

:init-pool | size --
    MARK
    HERE 'pool-start !
    HERE + 'pool-end ! ;

:release-pool | --
    EMPTY
    0 'pool-start !
    0 'pool-end ! ;

| Usage:
4096 init-pool
| ... use pool-start to pool-end ...
release-pool
```

### Pattern: String Builder

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
    0 str-pos c!      | Null terminate
    str-buffer ;

| Usage:
str-reset
"Hello " str-add
"World" str-add
str-get print         | Prints "Hello World"
```

---

## Operating System Connection

The computer only works with numbers, and any communication with the user or the rest of the world is done through words that the operating system resolves, independent of the language but dependent on its connection to it.

Access to external libraries is fundamental because it allows us to access hardware capabilities not directly available, either by manufacturer criteria that doesn't want its internal workings seen, or by resource complexity that doesn't want to be reprogrammed.

Generally, library documentation is needed to know what functions to import, and the use and functioning of these words will be the library's responsibility. Once we have access to the library, we can build our program from there.


### Console Access Example

```forth
^r3/lib/console.r3

: "hello world" .println ;
```

The key word is `.println` whose function is to take the text address and print it to terminal and go to the next line. This word is built from OS calls and necessary processing to make it easier to use.

### Advanced Operating System Connection

The OS connection is built through function calls to dynamic libraries. In Windows these are called .DLL (dynamic link libraries).

The current distribution, besides connecting to the OS, uses the hardware's graphics capabilities through SDL version 2 libraries, since it's multiplatform.

| Windows DLL | R3 Library | Purpose |
|-------------|------------|---------|
| SDL2.dll | `^r3/lib/sdl2.r3` | Graphics and window management |
| SDL2_image.dll | `^r3/lib/sdl2image.r3` | Image loading (PNG, JPG) |
| SDL2_mixer.dll | `^r3/lib/sdl2mixer.r3` | Audio playback |
| SDL2_net.dll | `^r3/lib/sdl2net.r3` | Network communication |
| SDL2_ttf.dll | `^r3/lib/sdl2ttf.r3` | TrueType font rendering |

> **Platform Support:** R3 is prepared for use on Linux, MAC, or RPI, though these are not yet available.

### Library Loading

The way to connect to a library is through 2 words: one to load the library and one to get the address of the function to execute, plus a set of words that make the call.

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `LOADLIB` | `"name" -- liba` | Load dynamic library |
| `GETPROC` | `liba "name" -- aa` | Get function address |

Words to call these functions take parameters from the stack according to parameter count and leave the OS response:

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `SYS0` | `aa -- r` | Call function with 0 parameters |
| `SYS1` | `a aa -- r` | Call function with 1 parameter |
| `SYS2` | `a b aa -- r` | Call function with 2 parameters |
| `SYS3` | `a b c aa -- r` | Call function with 3 parameters |
| ... | ... | ... |
| `SYS10` | `a b c d e f g h i j aa -- r` | Call function with 10 parameters |

### Example: Loading a Library

```forth
| Load a Windows DLL
"user32.dll" LOADLIB 'user32 !

| Get a function address
user32 @ "MessageBoxA" GETPROC 'msgbox !

| Call the function: MessageBoxA(NULL, "Hello", "Title", MB_OK)
0 "Hello" "Title" 0 msgbox @ SYS4 drop
```

---

## Libraries

Most common words from main libraries.

### Operating System Communication

#### ^r3/lib/core.r3

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `::msec` | `-- msec` | Push system milliseconds since program start |
| `::time` | `-- hms` | Push current time (hours, minutes, seconds) in one value |
| `::date` | `-- ymd` | Push current date (year, month, day) in one value |

#### Time Display Example

```forth
:.time | -- ; print time in hh:mm:ss format
    time
    dup 16 >> $ff and "%d:" .print  | hour
    dup 8 >> $ff and "%d:" .print   | minute  
    $ff and "%d" .print             | second
    ;

:.date | -- ; print date in yyyy-mm-dd format
    date
    dup 16 >> $ffff and "%d-" .print  | year
    dup 8 >> $ff and "%d-" .print     | month
    $ff and "%d" .print               | day
    ;
```

### Console Printing

The language starts in a window called console where only text can be written. The writing position is called cursor and moves as characters are placed. When it reaches the console end, it scrolls up to make room.

#### ^r3/lib/console.r3

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `::.cls` | `--` | Clear console, erase all characters |
| `::.write` | `"text" --` | Write text to console |
| `::.print` | `.. "text with %" --` | Write formatted text, extract values from stack for % |
| `::.println` | `"text" --` | Write text and newline |
| `::.home` | `--` | Move cursor to console start |
| `::.at` | `x y --` | Position cursor at row y, column x |
| `::.fc` | `color --` | Set foreground color for text |
| `::.bc` | `color --` | Set background color for text |
| `::.input` | `--` | Wait and save a line of text entered from keyboard |
| `::.inkey` | `-- key` | Return pressed key, zero if none |
| `::.cr` | `--` | Print carriage return (new line) |

> **Input Buffer:** The `##pad` variable contains the entered text after `.input`.

### Random Numbers

#### ^r3/lib/rand.r3

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `::rerand` | `s1 s2 --` | Initialize random generator with two seeds |
| `::rand` | `-- rand` | Push a 64-bit random number |
| `::randmax` | `max -- value` | Push random number between 0 and MAX-1 |

#### Random Number Usage

```forth
time msec rerand        | Initialize with variable time values
10.0 randmax            | Random number 0.0 to 9.999...
5.0 randmax 5.0 -       | Random number -5.0 to 0.0
5.0 randmax 5.0 +       | Random number 5.0 to 10.0
100 randmax             | Random integer 0 to 99
```

### Graphics with SDL2 Library

The SDL2 library allows access to graphics capabilities. https://www.libsdl.org/

This library allows starting a graphics window and drawing on it. Besides the graphics window, mechanisms are needed to respond to KEYBOARD and MOUSE buttons.

#### Graphics Window - ^r3/lib/sdl2.r3

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `::SDLinit` | `"title" w h --` | Start graphics window w×h pixels with title |
| `::SDLfull` | `--` | Set window to fullscreen |
| `::SDLquit` | `--` | Exit graphics window |
| `::SDLcls` | `color --` | Clear screen with chosen color |
| `::SDLredraw` | `--` | Refresh screen |
| `::SDLshow` | `'word --` | Execute WORD each time screen redraws |
| `::exit` | `--` | Exit from SHOW loop |

#### Input Variables

| Variable | Description |
|----------|-------------|
| `##SDLkey` | Code of pressed key, zero if no key |
| `##SDLchar` | Character code representation |
| `##SDLx`, `##SDLy` | Mouse cursor position x and y in window |
| `##SDLb` | Mouse button state, zero when none pressed |

#### Keyboard Constants

```forth
| Common key codes (use with SDLkey)
>esc<  | Escape key pressed
>le<   | Left arrow pressed  
>ri<   | Right arrow pressed
>up<   | Up arrow pressed
>dn<   | Down arrow pressed
<le>   | Left arrow down
<ri>   | Right arrow down
<up>   | Up arrow down
<dn>   | Down arrow down
```

#### Loading Graphics Files - ^r3/lib/sdl2image.r3

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `::loadimg` | `"file" -- img` | Load image file (PNG with transparency, JPG without) |
| `::unloadimg` | `img --` | Remove image from memory |

#### Drawing Graphics - ^r3/lib/sdl2gfx.r3

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `::SDLColor` | `col --` | Set drawing color (RGB format $RRGGBB) |
| `::SDLPoint` | `x y --` | Draw a pixel |
| `::SDLLine` | `x1 y1 x2 y2 --` | Draw line from x1,y1 to x2,y2 |
| `::SDLFRect` | `x y w h --` | Draw filled rectangle |
| `::SDLRect` | `x y w h --` | Draw rectangle outline |
| `::SDLFCircle` | `r x y --` | Draw filled circle |
| `::SDLCircle` | `r x y --` | Draw circle outline |
| `::SDLFEllipse` | `rx ry x y --` | Draw filled ellipse |
| `::SDLEllipse` | `rx ry x y --` | Draw ellipse outline |
| `::SDLFRound` | `r x y w h --` | Draw filled rounded rectangle |
| `::SDLRound` | `r x y w h --` | Draw rounded rectangle outline |
| `::SDLTriangle` | `x1 y1 x2 y2 x3 y3 --` | Draw filled triangle |

#### Image Drawing

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `::SDLimagewh` | `img -- w h` | Get image width and height |
| `::SDLImage` | `x y img --` | Draw image at position |
| `::SDLImages` | `x y w h img --` | Draw image at position with size |
| `::SDLImageb` | `box img --` | Draw image in defined box |
| `::SDLImagebb` | `box box img --` | Draw part of image in defined box |
| `::SDLspriteZ` | `x y zoom img --` | Draw image at position with scale |
| `::SDLSpriteR` | `x y ang img --` | Draw image at position with rotation |
| `::SDLspriteRZ` | `x y ang zoom img --` | Draw image with rotation and scale |

#### Tile Sheets

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `::tsload` | `w h filename -- ts` | Load image as tile sheet |
| `::tscolor` | `rrggbb 'ts --` | Set tile color (tints white color) |
| `::tsdraw` | `n 'ts x y --` | Draw tile n on screen |
| `::tsdraws` | `n 'ts x y w h --` | Draw tile n on screen with size |

#### Sprite Sheets

Sprites are parts of an image, drawn from the center of defined size.

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `::ssload` | `w h file -- ss` | Load sprite sheet (w h are pixels per sprite) |
| `::ssprite` | `x y n ss --` | Draw sprite N at centered position |
| `::sspriter` | `x y ang n ss --` | Draw sprite N centered with rotation |
| `::sspritez` | `x y zoom n ss --` | Draw sprite N centered with scale |
| `::sspriterz` | `x y ang zoom n ss --` | Draw sprite N centered with rotation and scale |

---

## Complete Example: Simple Game

```forth
^r3/lib/sdl2gfx.r3
^r3/lib/rand.r3

#sprites
#x 320.0 #y 240.0
#vx 0.0 #vy 0.0

:player
    x int. y int. 2.0 0 sprites sspritez
    vx 'x +! vy 'y +! ;

:game-update
    SDLkey
    >esc< =? ( exit )            | Exit on Escape
    <le> =? ( -2.0 'vx ! )       | Left arrow
    <ri> =? ( 2.0 'vx ! )        | Right arrow  
    <up> =? ( -2.0 'vy ! )       | Up arrow
    <dn> =? ( 2.0 'vy ! )        | Down arrow
    >le< =? ( 0.0 'vx ! )        | Stop on key release
    >ri< =? ( 0.0 'vx ! )
    >up< =? ( 0.0 'vy ! )
    >dn< =? ( 0.0 'vy ! )
    drop ;

:game-draw  
    0 SDLcls                     | Clear screen
    player                       | Draw and update player
    SDLredraw ;                  | Update display

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

Debugging R3forth programs requires understanding stack state and execution flow.

### Common Error Messages

| Error | Meaning | Solution |
|-------|---------|----------|
| `Error: 'word' not found` | Word misspelled or not defined yet | Check spelling, verify word is defined before use |
| `Stack underflow` | Trying to use more values than available | Check stack balance, add needed values |
| `Stack overflow` | Loop growing stack indefinitely | Check loop stack balance, add drops |
| `Division by zero` | Dividing by zero | Add zero check before division |

### Debugging Techniques

#### Technique 1: Stack Inspection

```forth
:debug-print | value -- value
    dup "DEBUG: %d" .print .cr .;

| Usage:
5 3 + debug-print  | Shows "DEBUG: 8" and leaves 8 on stack
```

#### Technique 2: Show Stack State

```forth
:s3 | a b c -- a b c (leaves stack unchanged)
    ".s: " .print
    pick2 "%d " .print  | Show third value
    over "%d " .print   | Show second value
    dup "%d" .print .cr | Show top value
    ;

| Usage:
1 2 3 .s3    | Prints: .s: 1 2 3
```

#### Technique 3: Trace Execution

```forth
:trace | "msg" --
    "TRACE: " .write .println ;

:problematic-word | n --
    "Entering problematic-word" trace
    dup 0? ( "Found zero" trace drop ; )
    "Processing non-zero" trace
    process-value ;
```

### Common Bug Patterns

**Bug 1: Missing DROP after conditional**

```forth
| Symptom: Stack grows unexpectedly
| ✗ WRONG:
:buggy | n --
    5 >? ( "Greater" .print )
    ;  | n still on stack!

| ✓ CORRECT:
:fixed | n --
    5 >? ( "Greater" .print )
    drop ;
```

**Bug 2: Loop stack imbalance**

```forth
| Symptom: Program crashes or freezes
| ✗ WRONG:
:buggy-loop | --
    10 ( 1? 1 -
        dup process  | Each iteration adds value!
    ) ;

| ✓ CORRECT:
:fixed-loop | --
    10 ( 1? 1 -
        dup process drop  | Consume the value
    ) drop ;
```

**Bug 3: Register collision**

```forth
| Symptom: Unexpected values
| ✗ WRONG:
:outer | addr --
    >a
    process-items  | If this uses register A, disaster!
    a> @ ;

| ✓ CORRECT:
:outer | addr --
    process-items  | Pass on stack instead
    @ ;
```

**Bug 4: Forgetting NIP after comparison**

```forth
| Symptom: Extra value on stack
| ✗ WRONG:
:min | a b -- min
    over >? ( drop ; )  | Returns a, but...
    ;  | Returns b correctly

| After: 5 3 min leaves 3 (correct)
| After: 3 5 min leaves 3 5 (wrong - leaves both!)

| ✓ CORRECT:
:min | a b -- min
    over >? ( drop ; )
    nip ;  | Remove the first value
```

### Debugging Workflow

1. **Isolate the problem:** Comment out code until error disappears
2. **Check stack balance:** Ensure each word leaves stack as documented
3. **Add trace statements:** Print values at key points
4. **Test with simple inputs:** Use known values to verify logic
5. **Check boundary conditions:** Test with 0, negative, large values

---

## Common Patterns

This section collects frequently-used programming patterns in R3forth.

### Pattern: Bounded Value (Clamp)

```forth
:clamp | value min max -- clamped
    rot               | min max value
    over              | min max value max
    <? ( nip ; )      | If value < max, drop max and continue
    nip               | Drop min, leaving max
    over              | max value max
    >? ( drop ; )     | If value > max, drop value, return max
    nip ;             | Drop max, return value

| Usage:
x 0 100 clamp  | Ensure x is between 0 and 100
```

### Pattern: Safe Division

```forth
:safe-divide | a b -- result|0
    0? ( nip 0 ; )    | Check for division by zero, return 0
    / ;               | Safe to divide

| Usage:
10 0 safe-divide  | Returns 0 instead of crashing
10 5 safe-divide  | Returns 2
```

### Pattern: Jump Table Dispatch

```forth
:action0 "Action 0" .print ;
:action1 "Action 1" .print ;
:action2 "Action 2" .print ;

#jump-table 'action0 'action1 'action2

:dispatch | n --
    3 <<               | Multiply by 8 (cell size)  
    'jump-table + @ ex ;

1 dispatch             | Executes action1
```

### Pattern: Buffer Management

```forth
#buffer * 8000         | Space for 1000 qwords
#buffer> 'buffer       | Buffer pointer

:reset-buffer | --
    'buffer 'buffer> ! ;

:add-item | item --
    buffer> !+         | Store and advance pointer
    'buffer> ! ;       | Update pointer

:process-buffer | --
    'buffer ( buffer> <?
        @+ process-item
    ) drop ;

:buffer-count | -- n
    buffer> 'buffer - 3 >> ;  | Divide by 8

| Usage:
reset-buffer
5 add-item
10 add-item
15 add-item
process-buffer
buffer-count  | Returns 3
```

### Pattern: State Machine

```forth
#state 0

:check-condition-0 | -- new-state|-1
    | Some logic to determine state change
    player-hit? ( 1 ; )  | Change to state 1 if hit
    -1 ;                 | -1 means no change

:state0 
    check-condition-0 
    +? ( 'state ! ; ) drop
    handle-state-0 ;

:check-condition-1 | -- new-state|-1
    | Some logic to determine state change
    player-safe? ( 0 ; )  | Change to state 0 if safe
    -1 ;

:state1
    check-condition-1 
    +? ( 'state ! ; ) drop
    handle-state-1 ;

#state-table 'state0 'state1

:update-state | --
    state 3 << 'state-table + @ ex ;

| Usage in game loop:
:game-loop
    update-state
    draw-game
    ;
```

### Pattern: Circular Buffer

```forth
#cbuffer * 800         | 100 qwords circular buffer
#cwrite 'cbuffer       | Write pointer
#cread 'cbuffer        | Read pointer
#ccount 0              | Number of items

:cbuffer-full? | -- flag
    ccount 100 >=? ;

:cbuffer-empty? | -- flag
    ccount 0 = ;

:cbuffer-write | value --
	ccount 100 >=? ( 2drop ; ) drop | Don't write if full
    cwrite !+              | Store value
    dup 'cbuffer 800 + >=? ( drop 'cbuffer )  | Wrap around
    'cwrite !
    1 'ccount +! ;

:cbuffer-read | -- value
    ccount 0? ( ; ) drop   | Return 0 if empty
    cread @+               | Read value
    dup 'cbuffer 800 + >=? ( drop 'cbuffer )  | Wrap around
    'cread !
    -1 'ccount +!
    ;

| Usage:
10 cbuffer-write
20 cbuffer-write
cbuffer-read  | Returns 10
cbuffer-read  | Returns 20
```

### Pattern: Linked List Node (really not usefull)

```forth
| Node structure: [value][next-pointer]

:node-create | value -- node
    mem dup 16 +      | Allocate 16 bytes (2 qwords)
    swap 0 swap !+    | Store value, zero next pointer
    drop ;

:node-value@ | node -- value
    @ ;

:node-next@ | node -- next
    8 + @ ;

:node-next! | next node --
    8 + ! ;

:list-add | value list-head -- list-head
    over node-create  | value list-head new-node
    swap over node-next!  | value new-node (link to old head)
    nip ;             | Return new head

:list-print | list-head --
    ( dup 1?
        dup node-value@ "%d " .print
        node-next@
    ) drop ;

| Usage:
0               | Empty list
10 over list-add
20 over list-add
30 over list-add
list-print      | Prints: 30 20 10
```

---

## Performance Considerations

Understanding performance characteristics helps write efficient R3forth code.

### Stack vs Memory Operations

**Stack operations are fastest:**
```forth
| Fast: Pure stack operations
:fast-calculation | a b -- result
    dup * swap dup * + sqrt ;

| Slower: Memory access
:slow-calculation | --
    vara @ dup *
    varb @ dup * + sqrt ;
```

**Guideline:** Keep frequently-used values on stack rather than in variables.

### Register Usage

**Registers are faster than repeated memory access:**

```forth
| Slow: Repeated memory access
:slow-loop | addr cnt --
    ( 1? 1 -
        over @ process
        swap 8 + swap
    ) 2drop ;

| Fast: Use register for address
:fast-loop | addr cnt --
    swap >a
    ( 1? 1 -
        a@+ process
    ) drop ;
```

**Guideline:** Use registers A and B for linear memory traversal.

### Countdown vs Count-up Loops

**Countdown loops are faster** because they use `1?` (non-consuming test):

```forth
| Faster: Countdown
10 ( 1? 1 - 
    process 
) drop

| Slower: Count-up (requires stack manipulation)
0 ( 10 <?
    dup process
    1 +
) drop
```

**Why:** The `1?` test doesn't consume the counter, while `<?` consumes TOS, requiring more stack operations.

### Early Exit Benefits

**Exit early to avoid unnecessary work:**

```forth
| Good: Early exit
:find-value | addr cnt target -- addr|0
    >r  | Save target on return stack
    ( 1? 1 -
        over @ r@ =? ( r> 3drop ; )  | Found it!
        swap 8 + swap
    ) r> 3drop 0 ;

| Less efficient: Always traverse entire array
:bad-find | addr cnt target -- flag
    >r 0 >a  | flag accumulator
    ( 1? 1 -
        over @ r@ =? ( drop 1 >a )
        swap 8 + swap
    ) r> 3drop a> ;
```

### Memory Access Patterns

**Sequential access is faster than random access:**

```forth
| Fast: Sequential access
'array 100 ( 1? 1 -
    swap @+ process
    swap
) 2drop

| Slower: Random/scattered access
100 ( 1? 1 -
    dup 8 * 'array + @ process
    1 -
) drop
```

### Factorization and Inlining

**Small, frequently-called words have overhead:**

```forth
| Overhead from many tiny calls:
:tiny-helper | n -- n*2
    2 * ;

:main-loop | --
    1000 ( 1? 1 -
        dup tiny-helper process
    ) drop ;

| Better: Inline simple operations
:main-loop | --
    1000 ( 1? 1 -
        dup 2 * process
    ) drop ;
```

**Guideline:** Factor for clarity, but inline trivial operations in tight loops.

---

## Appendix 1 - Base Dictionary

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
| `IN?` | `a b c -- a` | True if b≤a≤c (removes TOS and NOS) |

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
| `-ROT` | `a b c -- c a b` | Rotate 3 elements reverse |
| `2DUP` | `a b -- a b a b` | Duplicate 2 values |
| `2DROP` | `a b --` | Remove 2 elements |
| `3DROP` | `a b c --` | Remove 3 elements |
| `4DROP` | `a b c d --` | Remove 4 elements |
| `2OVER` | `a b c d -- a b c d a b` | Duplicate 2 from 3rd position |
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
| `>>` | `a b -- c` | a shift right b (signed) |
| `>>>` | `a b -- c` | a shift right b (unsigned) |
| `MOD` | `a b -- c` | c = a mod b |
| `/MOD` | `a b -- c d` | c = a/b, d = a mod b |
| `*/` | `a b c -- d` | d = a*b/c without bit loss |
| `*>>` | `a b c -- d` | d = (a*b)>>c without bit loss |
| `<</` | `a b c -- d` | d = (a<<c)/b without bit loss |
| `NEG` | `a -- b` | b = -a |
| `ABS` | `a -- b` | b = |a| |
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

| Word | Stack Effect | Description | Increment |
|------|--------------|-------------|-----------|
| `@` | `a -- [a]` | Fetch qword from address | - |
| `C@` | `a -- byte[a]` | Fetch byte from address | - |
| `W@` | `a -- word[a]` | Fetch word from address | - |
| `D@` | `a -- dword[a]` | Fetch dword from address | - |
| `@+` | `a -- b [a]` | Fetch qword and increment | +8 |
| `C@+` | `a -- b byte[a]` | Fetch byte and increment | +1 |
| `W@+` | `a -- b word[a]` | Fetch word and increment | +2 |
| `D@+` | `a -- b dword[a]` | Fetch dword and increment | +4 |
| `!` | `a b --` | Store A at address B | - |
| `C!` | `a b --` | Store byte A at address B | - |
| `W!` | `a b --` | Store word A at address B | - |
| `D!` | `a b --` | Store dword A at address B | - |
| `!+` | `a b -- c` | Store A at B and increment | +8 |
| `C!+` | `a b -- c` | Store byte A at B and increment | +1 |
| `W!+` | `a b -- c` | Store word A at B and increment | +2 |
| `D!+` | `a b -- c` | Store dword A at B and increment | +4 |
| `+!` | `a b --` | Add A to value at address B | - |
| `C+!` | `a b --` | Add A to byte at address B | - |
| `W+!` | `a b --` | Add A to word at address B | - |
| `D+!` | `a b --` | Add A to dword at address B | - |

### Register Operations

| Word | Stack Effect | Description | Increment |
|------|--------------|-------------|-----------|
| `>A` | `a --` | Load register A | - |
| `>B` | `a --` | Load register B | - |
| `B>` | `-- a` | Push register B | - |
| `A>` | `-- a` | Push register A | - |
| `A+` | `a --` | Add to A | - |
| `B+` | `a --` | Add to B | - |
| `A@` | `-- a` | Fetch qword from A | - |
| `B@` | `-- a` | Fetch qword from B | - |
| `cA@` | `-- a` | Fetch byte from A | - |
| `cB@` | `-- a` | Fetch byte from B | - |
| `dA@` | `-- a` | Fetch dword from A | - |
| `dB@` | `-- a` | Fetch dword from B | - |
| `A!` | `a --` | Store qword at A | - |
| `B!` | `a --` | Store qword at B | - |
| `cA!` | `a --` | Store byte at A | - |
| `cB!` | `a --` | Store byte at B | - |
| `dA!` | `a --` | Store dword at A | - |
| `dB!` | `a --` | Store dword at B | - |
| `A@+` | `-- a` | Fetch qword from A and increment | +8 |
| `B@+` | `-- a` | Fetch qword from B and increment | +8 |
| `cA@+` | `-- a` | Fetch byte from A and increment | +1 |
| `cB@+` | `-- a` | Fetch byte from B and increment | +1 |
| `dA@+` | `-- a` | Fetch dword from A and increment | +4 |
| `dB@+` | `-- a` | Fetch dword from B and increment | +4 |
| `A!+` | `a --` | Store qword at A and increment | +8 |
| `B!+` | `a --` | Store qword at B and increment | +8 |
| `cA!+` | `a --` | Store byte at A and increment | +1 |
| `cB!+` | `a --` | Store byte at B and increment | +1 |
| `dA!+` | `a --` | Store dword at A and increment | +4 |
| `dB!+` | `a --` | Store dword at B and increment | +4 |

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

## Conclusion

This manual provides comprehensive coverage of R3forth programming concepts and syntax. R3forth offers a unique approach to concatenative programming with its explicit prefix system, 64-bit architecture, and modern library integration.

### Key Takeaways

- **Stack-based programming:** All operations work through the data stack using postfix notation
- **Prefix system:** 8 prefixes define word behavior explicitly
- **No traditional control structures:** Uses conditional words with code blocks
- **Memory flexibility:** Access memory in 8, 16, 32, or 64-bit sizes
- **Modern integration:** SDL2 support for graphics and multimedia
- **Factorization encouraged:** Language design promotes clean code separation

### Learning Path

1. **Beginner:** Master stack operations and simple definitions
2. **Intermediate:** Learn conditionals, loops, and memory operations
3. **Advanced:** Use registers efficiently, understand recursion, build complex systems
4. **Expert:** Optimize performance, create libraries, understand system integration

### Best Practices Summary

✓ **DO:**
- Write stack comments for every word
- Factor code into small, reusable words
- Use countdown loops (more efficient)
- Keep frequently-used values on stack
- Test with boundary conditions
- Balance stack in all code paths

✗ **DON'T:**
- Forget to drop values after conditionals
- Assume registers persist across calls
- Use deep stack operations (factor instead)
- Optimize prematurely
- Mix memory access sizes carelessly
- Leave stack imbalanced

### Resources

- **Repository:** https://github.com/phreda4/r3
- **Examples:** Check the r3/r3-games directory
- **Libraries:** Explore r3/lib/ for ready-to-use code
- **Community:** Join discussions on the repository

### Example Programs to Study

1. **Hello World** (console output)
2. **Calculator** (stack operations and user input)
3. **Snake Game** (graphics, input, game loop)
4. **Particle System** (arrays, registers, performance)
5. **Text Editor** (string manipulation, memory buffers)

### Glossary

| Term | Definition |
|------|------------|
| **Concatenative** | Language where programs are built by composing functions |
| **Postfix notation** | Operators follow operands (5 3 + instead of 5 + 3) |
| **Stack effect** | Description of how a word affects the data stack |
| **Factoring** | Breaking code into smaller, reusable words |
| **TOS** | Top Of Stack - the most recent value pushed |
| **NOS** | Next Of Stack - the second-most recent value |
| **Tail call** | Function call as last operation (optimized to jump) |
| **Register** | Fast temporary storage (A and B in R3) |
| **Cell** | One memory unit (8 bytes / 64 bits in R3) |
| **Word** | A named function or data definition |
| **Dictionary** | Collection of all defined words |
| **Prefix** | First character determining word type (: # " etc.) |

---

## Final Notes

R3forth is a living language that continues to evolve. This manual represents the core concepts and most stable features. Always refer to the latest repository for updates and new libraries.

The philosophy of R3forth encourages:
- **Simplicity** over complexity
- **Composition** over monolithic design
- **Explicitness** over magic
- **Performance** through understanding

Happy coding in R3forth!
