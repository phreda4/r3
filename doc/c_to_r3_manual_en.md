# Manual: Translating C to R3forth

## Introduction

R3forth is a concatenative, stack-based language using Reverse Polish Notation (RPN). This manual gives the rules and patterns needed to systematically translate C code to R3forth. Words are case-insensitive.

---

## Fundamental Concepts

### Memory Cells

- All cells are **64 bits (8 bytes)**.
- A variable defined with `#` stores one 64-bit cell.
- No separate types: integers and fixed-point numbers use the same 64-bit format.

### Fixed Point 48.16

Real numbers are stored as fixed-point: 48 integer bits + 16 fractional bits. Same storage and access as integers — only the arithmetic words differ (`*.`, `/.` instead of `*`, `/`).

```r3
#x 100
#y 1.5
x y *.    | 100 * 1.5, fixed point
```

### Postfix Notation

Operands first, operator last.

```c
int result = (a + b) * c;
```
```r3
a b + c *
```

---

## Variables and Memory Access

```r3
#var              | one cell (8 bytes), value 0
#var 100          | one cell, value 100
#var 10 20        | two consecutive cells: 10, 20
#buffer * 1000    | 1000 bytes, zeroed
```

```r3
#x 50

x             | value of x        -> 50
'x            | address of x
'x @          | read at address   -> 50 (same as `x`)
100 'x !      | write: x = 100
5 'x +!       | modify: x = x + 5
```

**Rule**: `x` is the value, `'x` is the address. `!`, `@`, `+!` always operate on an address.

```c
int x = 100;
x = x + 5;
y = x * 2;
x += 10;
```
```r3
#x 100
5 'x +!           | x = x + 5
x 2 * 'y !        | y = x * 2
10 'x +!          | x += 10
```

### Memory Access Sizes

| Size  | Read | Write | Read+ | Write+ | Bytes |
|-------|------|-------|-------|--------|-------|
| byte  | `c@` | `c!`  | `c@+` | `c!+`  | 1     |
| word  | `w@` | `w!`  | `w@+` | `w!+`  | 2     |
| dword | `d@` | `d!`  | `d@+` | `d!+`  | 4     |
| qword | `@`  | `!`   | `@+`  | `!+`   | 8     |

The `@+`/`!+` variants **advance the address by the size read/written** — `c@+` by 1, `w@+` by 2, `d@+` by 4, `@+` by 8. Never assume +1. Their stack effect is `addr -- new_addr value` — the incremented address ends up *under* the value, not on top, so chaining raw calls means juggling with `swap`:

```r3
#buffer * 100
'buffer c@+           | new_addr v0
        swap c@+      | v0 new_addr2 v1
        swap c@+      | v0 v1 new_addr3 v2
        nip           | v0 v1 v2   (drop the now-unneeded address)
```

This is exactly why registers exist: `ca@+`/`ca@` do the same increment in A, off the stack, so nothing needs swapping:

```r3
'buffer >a
ca@+ ca@+ ca@         | v0 v1 v2 — no swaps, no address to clean up
```

Prefer the register form whenever you're reading more than one value in sequence.

---

## Control Structures

### IF without ELSE

```c
if (x > 5) {
    doSomething();
}
doAlways();
```
```r3
x 5 >? ( doSomething ) drop
doAlways
```

**Comparisons only consume TOS.** `a b <?` compares `a < b`, consumes `b`, leaves `a` on the stack. `x` is still there after the test either way, so it needs exactly **one** `drop` — placed *after* the block, so it runs whether or not the block ran. Do **not** also `drop` inside the block: that only balances the true branch, and leaves the false branch (block skipped) one item too high — or, if `doSomething` itself doesn't produce a replacement value, an outright stack mismatch between branches. `doSomething` here must not touch `x` (leave the stack as it found it); if it needs to consume `x`, see the early-exit pattern below instead.

### Stack balance is a choice, not automatic

R3 never balances the stack for you — *you* decide how. There are exactly two shapes that stay correct, and mixing them is the most common source of bugs:

- **Pass-through**: the block leaves the tested value in place (doesn't drop or consume it), so one `drop` *after* the block balances both branches, taken or not.
- **Early exit**: the block consumes the value and ends the word with `;`. Code after the block then only ever runs on the branch where the block was skipped, so it starts from a clean, independent stack — no shared drop needed. This is the pattern the real codebase uses almost everywhere a value must be consumed inside the branch:

```r3
| games/minesweeper.r3
1 >? ( drop marca ; ) drop
```

Here the true branch drops the tested value, calls `marca`, and exits — it never reaches the trailing `drop`. The false branch skips the block entirely, so the trailing `drop` is what cleans it up. Two different paths, each independently balanced — never both `drop`s executing back to back.

### IF-ELSE

R3 has no `else`. Use early exit with `;`: any conditional test can be followed by a block, and a `;` inside that block returns from the word immediately, so code after the block only runs when the test was false.

```c
if (condition) {
    branch1();
} else {
    branch2();
}
```
```r3
:myword
    condition? ( branch1 ; )  | true: run branch1 and return
    branch2 ;                 | false: falls through to here
```

`condition?` above stands for any test ending in `?` (`0?`, `=?`, a user word, ...) — whatever leaves a true/false result for the block to act on.

### SWITCH/CASE

```c
switch(type) {
    case 0: action0(); break;
    case 1: action1(); break;
    default: actionDefault();
}
```
```r3
type
0 =? ( drop action0 ; )
1 =? ( drop action1 ; )
drop actionDefault ;
```

### Loops

`(` opens a repeating block; it loops back to `(` as long as the value tested at that point is non-zero. Each iteration must leave the stack the same height it started with.

**Countdown (preferred — `1?` doesn't consume, so it's cheaper):**
```c
for (int i = 10; i > 0; i--) {
    process(i);
}
```
```r3
10 ( 1? 1-
    dup process   | dup if process consumes the count
) drop
```

**Count-up**, matching `for (i = 0; i < 10; i++)` — increment *after* using `i`, so `process` sees 0..9:
```c
for (int i = 0; i < 10; i++) {
    process(i);
}
```
```r3
0 ( 10 <?
    dup process
    1+
) drop
```
(Incrementing *before* `process` instead is also valid R3 — it just shifts what `process` receives to 1..10. Pick the order that matches the range you need.)

**While:**
```c
while (condition()) {
    body();
}
```
```r3
( condition 1? drop   | condition must leave a 0/1 for the test
    body
) drop
```

---

## Conditional Operators

### Unary tests (don't consume)

| Word | Test | Stack |
|------|------|-------|
| `0?` | `a = 0` | `a -- a` |
| `1?` | `a ≠ 0` | `a -- a` |
| `+?` | `a ≥ 0` | `a -- a` |
| `-?` | `a < 0` | `a -- a` |

### Binary comparisons (consume TOS, keep NOS)

| Word | Test | Stack |
|------|------|-------|
| `=?` | `a = b` | `a b -- a` |
| `<?` | `a < b` | `a b -- a` |
| `>?` | `a > b` | `a b -- a` |
| `<=?` | `a ≤ b` | `a b -- a` |
| `>=?` | `a ≥ b` | `a b -- a` |
| `<>?` | `a ≠ b` | `a b -- a` |
| `and?` | `(a and b) ≠ 0` | `a b -- a` |
| `nand?` | `(a nand b) ≠ 0` | `a b -- a` |
| `in?` | `b ≤ a ≤ c` | `a b c -- a` |

```r3
x 5 10 in? ( "Between 5 and 10" print ) drop
```

Tested values are never dropped automatically — clean up once, after all the tests:
```r3
x 0? ( "Is zero" print )
  +? ( "Is positive" print )    | x still on stack here
drop
```

---

## Arithmetic

| Word | Effect | Description |
|------|--------|-------------|
| `+` `-` | `a b -- c` | add / subtract |
| `*` `/` `mod` | `a b -- c` | multiply / divide / remainder (integer) |
| `*.` `/.` | `a b -- c` | multiply / divide (fixed point) |
| `neg` | `a -- -a` | negate |
| `abs` | `a -- \|a\|` | absolute value |

**Double-precision ops** avoid overflow in the intermediate result — use them for scaling:

| Word | Effect | Description |
|------|--------|-------------|
| `*/` | `a b c -- d` | d = (a×b)÷c, no overflow |
| `*>>` | `a b c -- d` | d = (a×b)>>c, no loss |
| `<</` | `a b c -- d` | d = (a<<c)÷b, no loss |

```c
result = (value * 255) / 100;   // can overflow
```
```r3
value 255 100 */                | safe
```

### Bit Operations

| Word | Effect |
|------|--------|
| `<<` `>>` | shift left / signed shift right |
| `>>>` | unsigned shift right |
| `and` `or` `xor` `nand` | bitwise ops, `a b -- c` |
| `not` | bitwise NOT, `a -- b` |

---

## Stack Operations

| Word | Effect |
|------|--------|
| `dup` | `a -- a a` |
| `drop` | `a --` |
| `swap` | `a b -- b a` |
| `over` | `a b -- a b a` |
| `nip` | `a b -- b` |
| `rot` | `a b c -- b c a` |
| `-rot` | `a b c -- c a b` |
| `pick2/3/4` | copy 3rd/4th/5th item to top |
| `2dup` / `2drop` | duplicate / drop top pair |
| `3drop` / `4drop` | drop top 3 / 4 |
| `2over` | `a b c d -- a b c d a b` |
| `2swap` | `a b c d -- c d a b` |

---

## Registers A and B

Fast scratch pointers for tight loops. Same operation set for both, prefixed `a`/`b`:

| Word | Effect |
|------|--------|
| `>a` / `a>` | store TOS in A / push A |
| `a+` | add TOS to A |
| `a@` / `a!` | read/write qword at A |
| `a@+` / `a!+` | read/write qword at A, then A += 8 |

Size variants: `ca@`/`ca!`/`ca@+`/`ca!+` (byte, ±1), `wa@…` (word, ±2), `da@…` (dword, ±4). Same set exists for B (`>b`, `b@+`, ...).

```r3
'array >a
100 ( 1? 1-
    a@+ process    | read from A, A += 8
) drop
```

**Registers are global and not preserved across word calls.** They're not local loop variables — they're two shared slots the whole program uses. If `process` above also uses `>a`/`a@+` internally (directly, or through *anything it calls*), it silently overwrites your traversal pointer and the loop reads garbage from then on:

```r3
| BROKEN if `process` touches A internally
'array >a
100 ( 1? 1-
    a@+ process    | process() clobbers A -> next a@+ is corrupted
) drop
```

Fix by saving/restoring A (and B) around the call that might reuse them — `ab[` pushes both to the return stack, `]ba` pops and restores them:

```r3
'array >a
100 ( 1? 1-
    a@+ ab[ process ]ba   | A is safe across process, even if it uses A/B
) drop
```

Or, cheaper when only the *traversal* needs protecting and `process` is the one using registers internally: keep the pointer in a normal variable instead of a register, and only load it into A for the instruction that actually needs it. As a rule: prefer registers for tight, leaf-level loops that call nothing register-using; reach for `ab[ ]ba` as soon as the loop body calls a word you didn't write yourself (or don't know the internals of).

---

## Return Stack

| Word | Effect |
|------|--------|
| `>r` | push TOS to return stack |
| `r>` | pop return stack to TOS |
| `r@` | copy top of return stack |

An unbalanced return stack crashes the word — every `>r` in a word needs a matching `r>` before it returns.

---

## Data Structures from C

### Structs

R3 has no struct type — a "struct" is just a plain memory region you index by hand-picked byte offsets. There's no compiler to check field sizes or overlaps, so the offsets in the comments **are** the struct definition; get them wrong and you silently read/write the wrong field. Pack small fields into one cell manually; give each field an offset-based accessor.

```c
typedef struct {
    uint8_t type;   // byte 0
    uint8_t note;   // byte 1
    int value;      // offset 8 (next cell)
} Node;
```
```r3
| cell 0: type | note (packed)
| cell 1: value

:n.type     @ $ff and ;        | addr -- type
:n.note     @ 8 >> $ff and ;   | addr -- note
:n.value    8 + ;              | addr -- addr_value

:pack_node  | type note value -- addr
    here >a
    rot rot 8 << or a!+        | pack type|note
    a!+                        | value
    here a> 'here ! ;          | return start address

0 60 100 pack_node 'mynode !
mynode n.type       | -> 0
mynode n.note        | -> 60
mynode n.value @      | -> 100
```

Field accessors always take an address and return an address or a value — never assume field order in memory matches field order in the C struct unless you laid it out that way on purpose.

**Signed fields need explicit sign extension.** The stack holds signed 64-bit integers, but a mask (`and`) only extracts bits — it never restores a sign bit that used to be bit 7/15/31 of a smaller field. `n.type` above works because unsigned bytes don't need it, but a *signed* 8-bit field needs the sign put back before it's used as a signed value:

```r3
| WRONG for a signed byte: $ff and only masks, doesn't sign-extend
:n.svalue   @ $ff and ;          | -1 stored as byte becomes 255, not -1

| CORRECT: shift the field up to bit 63, then signed >> back down
:n.svalue   @ 56 << 56 >> ;      | byte at bit 0..7 -> sign-correct 64-bit value
```

The pattern is `<< (64 - field_bits) >> (64 - field_bits)` with a *signed* `>>` — this is how the real libraries sign-extend packed sub-fields (see `varanim.r3`'s `16 << 48 >>` for a packed 16-bit field). Unsigned fields skip this and just `and` with a mask.

**Field layout is a design choice, not just a translation detail.** Pack fields into the same cell when they're always read/written together (like `type`/`note` above) — one `@` fetches both. If fields are accessed independently or don't fit the packing cleanly, give each its own cell instead; the resulting address math (`+ 8`, `+ 16`, ...) is simpler and cheaper than mask/shift for fields you don't always need together.

### Arrays

Cells are 8 bytes, so index with `<< 3` (×8), not `+1`.

```c
int array[10];
array[5] = 100;
x = array[5];
```
```r3
#array * 80                 | 10 cells * 8 bytes

100 'array 5 3 << + !       | array[5] = 100
'array 5 3 << + @           | x = array[5]
```

The shift is `log2(record size in bytes)` — pick it to match your element size, not just single cells:

| Element size | Shift | Meaning |
|---|---|---|
| 8 bytes (1 cell) | `3 <<` | index × 8 |
| 16 bytes (2 cells) | `4 <<` | index × 16 |
| 32 bytes (4 cells) | `5 <<` | index × 32 |

i.e. an array of the `Node` struct above (2 cells = 16 bytes/record) is indexed with `5 nodes 4 << + n.value @` — same idea as `array[i]`, just with the stride made explicit.

### Don't reinvent what the libraries already do

Before hand-rolling packing, string, or math helpers, check `r3forth-lib-*.md` (`core`, `mem`, `str`, `math`) — most common C idioms (bounds clamping, string copy/compare, array fill, random ranges) already exist as words. Translating C byte-for-byte into raw mask/shift/loop code when a library word already does it is extra bugs for no benefit.

### Storing and running code from a variable

A word's address (`'word`) is just a 64-bit value — it can be stored in a variable like any other, fetched later, and run with `EX`. This is how C-style callbacks/function pointers translate:

```c
void (*handler)(int) = on_click;
handler(5);
```
```r3
#handler 0
'on_click 'handler !     | store the address
5 handler EX             | fetch it and run it
```

`EX` just jumps to the address on TOS — it doesn't know or check the stack effect of what it calls. Keep the stack coherent yourself: decide a fixed signature for anything you'll call this way (e.g. "takes one value, leaves nothing") and make every word you might store there follow it, the same discipline as a C function-pointer type.

---

## Definition Order

Words must be defined before use — no forward references.

```r3
| wrong
:main helper ;
:helper "text" print ;

| correct
:helper "text" print ;
:main helper ;
```

---

## Common Patterns

```c
int safe_div(int a, int b) {
    if (b == 0) return 0;
    return a / b;
}
```
```r3
:safe_div | a b -- result
    0? ( nip ; )   | b = 0: keep a, return it
    / ;
```

```c
int clamp(int val, int min, int max) {
    if (val < min) return min;
    if (val > max) return max;
    return val;
}
```
```r3
:clamp | val min max -- clamped
    rot over >? ( drop nip ; ) nip     | below min
    over <? ( drop ; ) nip ;           | above max
```

```c
void process_array(int* arr, int count) {
    for (int i = 0; i < count; i++) {
        process(arr[i]);
    }
}
```
```r3
| without registers
:process_array | addr count --
    ( 1? 1-
        swap @+ process swap
    ) 2drop ;

| with register A
:process_array | addr count --
    swap >a
    ( 1? 1-
        a@+ process
    ) drop ;
```

---

## Converting C Functions

```c
int add_five(int x) {
    return x + 5;
}
```
```r3
:add_five | x -- result
    5 + ;
```

```c
int classify(int x) {
    if (x < 0) return -1;
    if (x == 0) return 0;
    return 1;
}
```
```r3
:classify | x -- class
    -? ( drop -1 ; )
    0? ( ; )
    drop 1 ;
```

```c
int calculate(int a, int b) {
    int temp = a * 2;
    return temp + b;
}
```
```r3
| option 1: no locals needed
:calculate | a b -- result
    swap 2 * + ;

| option 2: return stack as scratch
:calculate | a b -- result
    >r 2 * r> + ;
```

---

## Complete Example: C → R3forth

```c
#include <stdio.h>

int fibonacci(int n) {
    if (n <= 1) return n;
    return fibonacci(n-1) + fibonacci(n-2);
}

int main() {
    for (int i = 0; i < 10; i++) {
        printf("%d ", fibonacci(i));
    }
    return 0;
}
```
```r3
^r3/lib/console.r3

:fibonacci | n -- fib(n)
    1 <=? ( ; )                  | n <= 1: return n
    dup 1 - fibonacci
    swap 2 - fibonacci
    + ;

:main | --
    10 0 ( over <?
        dup fibonacci "%d " .print
        1+
    ) 2drop
    .cr ;

: main ;    | invoke main at load time
```

---

## Translation Checklist

1. Define every word before it's used.
2. Balance the stack in every word and every loop iteration — pick pass-through (drop once, after the block) or early-exit (drop inside, then `;`), never mix the two for the same value.
3. Prefer countdown loops with `1?` — it doesn't consume.
4. `drop` values left over after conditionals.
5. Use early exit (`;` inside a block) instead of reaching for if-else.
6. Comment stack effects: `| before -- after`.
7. Use `*/` (and `*>>`, `<</`) instead of `* /` when the intermediate product can overflow.
8. Use `'var` for `!`/`@`/`+!` — never the bare value.
9. `@+`/`!+` advance by the *access size*, not always by 8.
10. Save registers (`ab[ ... ]ba`) before calling anything that might reuse A/B.

### Frequent mistakes

```r3
| value vs address
#x 100
x !               | wrong: x is a value, ! needs an address
50 'x !           | correct

| forgetting to drop after a conditional chain
x 0? ( "zero" print )
drop              | needed even if no branch matched

| wrong access size for consecutive bytes
'buffer @+ swap @+   | reads offsets 0, 8 (qword step) — probably not what you want
'buffer c@+ swap c@+  | reads offsets 0, 1
```

---

## Key Differences Summary

| Concept | C | R3forth |
|---------|---|---------|
| Declare variable | `int x = 5;` | `#x 5` |
| Read value | `x` | `x` |
| Take address | `&x` | `'x` |
| Assign | `x = 10;` | `10 'x !` |
| Increment | `x += 5;` | `5 'x +!` |
| If/else | `if {} else {}` | `test? ( ...; ) ...` |
| For loop | `for(;;)` | `count ( test ... ) drop` |
| Array index | `arr[i]` | `'arr i 3 << + @` |
| Struct field | `node.field` | `node field_offset + @` |

---

## Further Reading

- `r3forth_reference.md` — full word dictionary and quick-reference card
- `r3forth-manual.md` — complete language and library manual
- `r3-to-forth-guide.md` — extended C-to-R3forth translation guide with more examples

R3forth favors factoring code into small, single-purpose words over nested control structures — when a translation feels awkward, splitting it into another word is usually the fix.
