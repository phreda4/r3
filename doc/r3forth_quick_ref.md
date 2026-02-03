# R3forth Quick Reference
*For experienced programmers*

## Core Concepts

**Stack-based concatenative language** with postfix notation. All code is compiled first, then executed. 64-bit cells (8 bytes). Fixed-point arithmetic (48.16 format).

```r3
5 3 +        | Result: 8
10 dup *     | Result: 100
a b + c *    | (a+b)*c
```

## Critical Differences from Standard Forth

1. **No forward references** - define words before use
2. **No IF-ELSE** - use early exit with `;`
3. **Conditionals don't leave booleans** - always paired with `( )` blocks
4. **Conditionals consume only TOS** - leave NOS on stack
5. **All cells are 64-bit** - no separate float type
6. **Variables by name push value** - use `'` for address

## Program Structure

```r3
| Comments
^r3/lib/library.r3    | Include

#data 100             | Variable (private)
##exported 200        | Variable (exported)

:helper ... ;         | Private word
::public ... ;        | Exported word

: entry-point ;       | Program entry (last line)
```

## Prefixes (8 types)

| Prefix | Meaning | Example |
|--------|---------|---------|
| `\|` | Comment | `\| comment` |
| `^` | Include | `^r3/lib/file.r3` |
| `"` | String | `"text"` |
| `:` | Code | `:word ... ;` |
| `#` | Data | `#var 5` |
| `$` | Hex | `$FF` |
| `%` | Binary | `%1010` |
| `'` | Address | `'var` |

## Variables and Memory

```r3
#x 100               | x = 100 (qword, 8 bytes)
#y [ 50 ]            | y = 50 (dword, 4 bytes)
#z ( 10 )            | z = 10 (byte, 1 byte)
#buf * 1000          | 1000 byte buffer

| Access
x                    | Push value of x
'x                   | Push address of x
'x @                 | Read from x (same as: x)
100 'x !             | Write 100 to x
5 'x +!              | x += 5
```

**CRITICAL**: `x` pushes VALUE, `'x` pushes ADDRESS. Memory operators (`!`, `@`, `+!`) need ADDRESS.

## Memory Access Sizes

| Size | Read | Write | Read+ | Write+ | Inc |
|------|------|-------|-------|--------|-----|
| byte | `c@` | `c!` | `c@+` | `c!+` | +1 |
| word | `w@` | `w!` | `w@+` | `w!+` | +2 |
| dword | `d@` | `d!` | `d@+` | `d!+` | +4 |
| qword | `@` | `!` | `@+` | `!+` | +8 |

## Stack Operations

```r3
dup     | a -- a a
drop    | a --
swap    | a b -- b a
over    | a b -- a b a
nip     | a b -- b
rot     | a b c -- b c a
pick2   | a b c -- a b c a
2dup    | a b -- a b a b
2drop   | a b --
```

## Conditionals

**Stack tests** (don't consume):
```r3
0?      | a -- a    | a = 0?
1?      | a -- a    | a ≠ 0?
+?      | a -- a    | a ≥ 0?
-?      | a -- a    | a < 0?
```

**Comparisons** (consume TOS only):
```r3
<?      | a b -- a  | a < b?
>?      | a b -- a  | a > b?
=?      | a b -- a  | a = b?
<=?     | a b -- a  | a ≤ b?
>=?     | a b -- a  | a ≥ b?
<>?     | a b -- a  | a ≠ b?
in?     | a b c -- a| b ≤ a ≤ c?
```

**Usage pattern:**
```r3
x 5 >? ( action ) drop    | If x>5, action

| Value persists:
x 0? ( "zero" print )
  +? ( "positive" print )
drop                      | Clean up once

| Early exit (no ELSE):
:min | a b -- min
    over >? ( drop ; )    | If a>b, drop b and exit
    nip ;                 | Drop a, keep b
```

## Loops

**Countdown (preferred - faster):**
```r3
10 ( 1? 1-               | While ≠ 0
    dup process
) drop
```

**Count-up:**
```r3
0 ( 10 <? 1+             | While < 10
    dup process
) drop
```

**Memory traversal:**
```r3
"text" ( c@+ 1?          | While not null
    process
) 2drop
```

## Arithmetic

```r3
+ - * /                  | Basic (integer)
*. /.                    | Fixed point 48.16
mod                      | Modulo
<< >> >>>                | Bit shifts
and or xor not           | Bitwise
neg abs sqrt             | Unary

| Double precision (prevents overflow):
*/      | a b c -- d    | d = (a*b)/c
*>>     | a b c -- d    | d = (a*b)>>c
<</     | a b c -- d    | d = (a<<c)/b
```

## Registers A and B

**Fast temporary storage** (not preserved across calls):

```r3
>a      | val --        | Load A
a>      | -- val        | Push A
a@      | -- val        | Read qword from A
a!      | val --        | Write qword to A
a@+     | -- val        | Read qword, A+=8
ca@+    | -- val        | Read byte, A+=1

| Same for B: >b b> b@ b! b@+ cb@+

| Save/restore:
ab[                      | Save A and B
... use registers ...
]ba                      | Restore B and A
```

## Return Stack

```r3
>r      | a -- (r: -- a)
r>      | -- a (r: a --)
r@      | -- a (r: a -- a)
```

⚠️ **Use with caution** - imbalance crashes program.

## Strings

```r3
"text"                   | In code: constant area
#str "text"              | In data: variable area

| Traversal:
"hello" ( c@+ 1?
    process
) 2drop
```

## Memory Management

```r3
MEM                      | Start of free memory
HERE                     | Variable: next free address
MARK                     | Save HERE
EMPTY                    | Restore HERE

| Pattern:
MARK
HERE 1000 + 'HERE !      | Allocate 1KB
... use ...
EMPTY                    | Release
```

## Common Patterns

**Safe division:**
```r3
:safe-div | a b -- result
    0? ( ; )             | If b=0, return a
    / ;
```

**Clamp:**
```r3
:clamp | val min max -- clamped
    rot over >? ( drop nip ; ) nip     | Check minimum
    over <? ( drop ; ) nip ;       | Check maximum
```

**Switch/dispatch:**
```r3
#table 'action0 'action1 'action2

:dispatch | n --
    3 <<                 | n * 8
    'table + @ ex ;
```

**Array processing:**
```r3
'array >a
100 ( 1? 1-
    a@+ process
) drop
```

## Performance Tips

1. **Countdown loops faster** - `1?` doesn't consume
2. **Registers faster** than repeated memory access
3. **Stack faster** than variables
4. **Early exit** avoids unnecessary work
5. **Sequential access** faster than random

## Libraries (Common)

```r3
^r3/lib/console.r3       | Console I/O
^r3/lib/sdl2gfx.r3       | Graphics
^r3/lib/math.r3          | Fixed-point math
^r3/lib/rand.r3          | Random numbers

| Console:
.print .println .cr      | Output
.input                   | Input (result in ##pad)

| Graphics:
SDLinit SDLcls SDLredraw | Window management
SDLshow                  | Game loop
SDLkey SDLx SDLy SDLb    | Input state
```

## Example: Complete Program

```r3
^r3/lib/sdl2gfx.r3

#x 320.0 #y 240.0
#vx 0.0 #vy 0.0

:update
    SDLkey
    >esc< =? ( exit )
    <le> =? ( -2.0 'vx ! )
    <ri> =? ( 2.0 'vx ! )
    drop
    
    vx 'x +! vy 'y +! ;

:draw
    0 SDLcls
    $FF0000 SDLColor
    20.0 x y SDLFCircle
    SDLredraw ;

:loop
    update draw ;

:main
    "Game" 640 480 SDLinit
    'loop SDLshow
    SDLquit ;

: main ;
```

## Key Differences Summary

| Feature | Standard Forth | R3forth |
|---------|----------------|---------|
| Execution | Interactive | Fully compiled |
| IF-ELSE | `IF ELSE THEN` | Early exit `;` |
| Conditionals | Leave boolean | Paired with `( )` |
| Forward refs | Sometimes OK | Never allowed |
| Cell size | Variable | 64-bit |
| Floats | Separate | Fixed-point 48.16 |
| Variables | `var @` = value | `var` = value |

## Quick Debugging

```r3
:debug | a -- a
    dup "%d" .println ;

| Usage:
5 3 + debug              | Shows 8, leaves 8
```

## Common Errors

1. **Missing DROP after conditional** - value persists
2. **Using `x` instead of `'x`** for memory ops
3. **Forward reference** - define before use
4. **Stack imbalance in loops** - check each iteration
5. **Forgetting register not preserved** across calls

## Cheat Sheet

```r3
| Variables
#x 5                     | Define
x                        | Get value
'x                       | Get address
10 'x !                  | Set value
1 'x +!                  | Increment

| Conditionals
n 0? ( action ) drop     | If zero
a b <? ( action ) drop   | If a<b

| Loops
10 ( 1? 1- code ) drop   | Countdown
0 ( 10 <? code 1+ ) drop | Count up

| Memory
'buf @                   | Read qword
50 'buf !                | Write qword
'buf c@+                 | Read byte, advance

| Registers
'array >a                | Load address
a@+ process              | Read and advance

| Stack
dup swap over rot        | Basics
pick2 pick3              | Deep access
2dup 2drop               | Pairs
```

---
