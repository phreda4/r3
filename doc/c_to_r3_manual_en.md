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
#x 100.0  | need . 
#y 1.5
x y *.    | 100.0 * 1.5, fixed point
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

In C every local is a variable. In idiomatic R3forth most of them are not: temporaries live on the stack. See [Replacing Variables with Stack References](#replacing-variables-with-stack-references) for when and how to remove them.

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
'buffer c@+          | new_addr v0
        swap c@+     | v0 new_addr2 v1
        swap c@      | v0 v1 v2
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
| ?? stands for any conditional (0? 1? =? <? >? ...)
:myword
    ?? ( branch1 ; )              | true: run branch1 and return
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

A block repeats when it contains an exit test (a conditional inside the block, not followed by its own `( )`); the loop ends when that test is false. See Tutorial → Repetition → IF and WHILE. Each iteration must leave the stack the same height it started with.

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
| `nand?` | `(a and b) = 0` | `a b -- a` |
| `in?` | `b ≤ a ≤ c` | `a b c -- a` |

```r3
x 5 10 in? ( "Between 5 and 10" .write ) drop
```

Tested values are never dropped automatically — clean up once, after all the tests:
```r3
x 0? ( "Is zero" .write )
  +? ( "Is positive" .write )    | x still on stack here
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

### Truncation and rounding

`/` and `*/` truncate toward zero; `>>` (arithmetic shift) rounds toward minus infinity. Rounding to the nearest after a truncation does not work, because the information is already gone:

```r3
| WRONG: v is already truncated, (v+1)>>1 is not a rounding
-dy size len */ 1 + 2/          | -dy*size/len, then /2
```

Found in `r3logo`: with `size = 2` and an angle of 120 degrees both offsets of a thick line came out as 0, and the side of the triangle vanished (no error, only a missing line). Scale first, truncate last, round at the end:

```r3
| round(v * size / len / 2): 16.16 keeps the fraction, $8000 is one half
:half | v -- o
	size * 65536 len */ 1 >> $8000 + 16 >> ;
```

Rule: to round `a*b/c` to the nearest, compute it with 16 extra bits, add the half (`$8000`), and shift back with `>>`. Test the rounding with values on both sides of zero: `>>` floors negatives, `/` truncates them.

### Bit Operations

| Word | Effect |
|------|--------|
| `<<` `>>` | shift left / signed shift right |
| `>>>` | unsigned shift right |
| `and` `or` `xor` `nand` | bitwise ops, `a b -- c` (`nand` is a and not b) |
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

`pick4` is the deepest copy: only the top 5 items are reachable (see [Replacing Variables with Stack References](#replacing-variables-with-stack-references)).

---

## Registers A and B

Two global pointer registers for walking memory without touching the stack. B has the same words as A.

| Word | Effect |
|------|--------|
| `>a` / `a>` | store TOS in A / push A |
| `a+` | add TOS to A |
| `a@` / `a!` | read/write qword at A |
| `a@+` / `a!+` | read/write qword at A, then A += 8 |

Size variants: `ca@ ca!` `ca@+ ca!+` (byte, ±1), `wa@…` (word, ±2), `da@…` (dword, ±4). Same for B: `>b`, `db!+`, ...

```r3
'array >a
100 ( 1? 1- a@+ process ) drop      | read, A += 8
```

### Rules

1. **Registers are global.** If anything you call (even indirectly) uses A or B, it overwrites yours and the loop reads garbage.
2. **A word that uses A or B wraps its body in `ab[ ... ]ba`.** `ab[` saves the caller's A and B on the return stack, `]ba` restores them. Then callers never have to protect anything. Put it once at the entry of the word that owns the loop, not inside the loop.
3. Helpers called only from such a word may use A and B freely. Mark them in the comment: `; uses A, B`.
4. Never leave between `ab[` and `]ba` with `;`. Restore first: `]ba ;`.
5. A loop that calls a word you did not write (a callback through `ex`, a library you have not read) must not keep its pointer in A or B across that call. Use a variable, or `ab[ call ]ba`.

```r3
:setd | v n 'dst --              ; uses A
	ab[ >a
	( 1? 1- over da!+ ) 2drop    | write v, n times
	]ba ;
```

### Patterns

| Task | Code |
|------|------|
| copy n dwords A to B | `( 1? 1- da@+ db!+ ) drop` |
| fill n dwords | `( 1? 1- v da!+ ) drop` |
| skip one dword | `4 a+` |
| write the second dword of an 8-byte pair | `4 a+ da! 4 a+` |
| copy backwards (A, B at the last element) | `( 1? 1- da@ -4 a+ db! -4 b+ ) drop` |
| split a qword into low and high dword | `a@+ dup $ffffffff and swap 32 >>` |
| row start moves by a fixed step | `over >a ... swap 256 + swap` (pointer on the stack, reload A each row) |

A countdown `( 1? 1- ... )` never ends if the count is negative. When the count is computed (`hi lo - 1+`), guard it with `0 max`.

### Check that a word protects the registers

Set A and B to known values, call the word, compare. Then remove its `ab[ ]ba` and confirm the test fails; otherwise the test proves nothing.

```r3
:rg 12345 >a 67890 >b ;
:chk | "name" --
	a> 12345 =? ( drop b> 67890 =? ( 2drop ; ) ) drop
	"A/B clobbered by " .write .println ;

:main  rg 0 64 'buf setd "setd" chk ;
```

---

### Audit the library before you keep a value in A or B

Rule 1 says that anything you call may overwrite A or B. Do not guess: search the library you call.

```sh
grep -n ">a\|>b\|ab\[" r3/lib/sdl2gfx.r3
```

Result for `sdl2gfx.r3` (the one `r3logo` uses):

| Word | A / B | Consequence |
|---|---|---|
| `line`, `point`, `frect`, `color`, `image` | not used | safe |
| `circle`, `fcircle`, `ellipse`, `fellipse`, `round`, `lineHg`, `lineVg`, `sprite*` | saved with `ab[ ]ba` | safe (but `circle`, `fcircle`, `round` use `here` as scratch: never keep live data at `here`) |
| `polyop`, `polyline`, `triangle` (`drawtri`) | **use A, do not save it** | A is lost after the call |

Wrap the unsafe word once, and call the wrapper:

```r3
:pop | x y --  ab[ polyop ]ba ;
:pln | x y --  ab[ polyline ]ba ;
```

A and B are then free to hold values for the whole word (`thick` keeps the two offsets of the quad in A and B and reads them with `a>` `b>` while it builds the four corners). Helpers that only read them get the mark `; uses A, B` in the comment.

When the loop body calls a widget or any word you do not control, protect only that call, not the whole loop:

```r3
:drawlines | adr rows --         ; uses A
	ab[ swap >a
	( 1? 1-
		a> 'line strcpyln
		ab[ 'line uiLabel ]ba    | the widget may use A and B
		a> >>cr 1+ >a
		) drop
	]ba ;
```

More patterns taken from `r3logo`:

| Task | Code |
|---|---|
| count the lines of a text (no pointer on the stack, no `2drop`) | `ab[ 'text >a 0 ( ca@+ 1? 13 =? ( swap 1+ swap ) drop ) drop ]ba` |
| append a string at the end of a buffer | `ab[ >b 'buf count + >a ( cb@+ 1? ca!+ ) drop 13 ca!+ 0 ca! ]ba` |
| write a text file turning CR into CRLF | `fuente >a ( ca@+ 1? 13 =? ( ,c 10 ) ,c ) drop` |
| hash n dwords | `swap >a 0 swap ( 1? 1- swap 31 * da@+ $ffffffff and + swap ) drop` |

The counting loop returns the count without any cleanup: the last tested value (the 0 byte) is the only thing the final `drop` removes.

## Return Stack

| Word | Effect |
|------|--------|
| `>r` | push TOS to return stack |
| `r>` | pop return stack to TOS |
| `r@` | copy top of return stack |

An unbalanced return stack crashes the word — every `>r` in a word needs a matching `r>` before it returns.

---

## Replacing Variables with Stack References

A direct C translation gives every local a `#variable`. Idiomatic R3forth keeps temporaries **on the stack** and reads them back with `over`, `pick2`, `pick3`, `pick4`. The result is shorter, has no global state to clobber, and is often faster. This section is the method, step by step, taken from the real refactoring of `r3/term/colorscene.r3` (about 75 variables down to 27, not counting buffers, with identical output).

It is a mechanical process, not a rewrite: **the program must give exactly the same results before and after.** Verify that at every step (Step 1 and Step 9).

### When a variable is worth removing

| The variable is... | Do this |
|---|---|
| a loop counter (`xx`, `yy`, `i`) | keep it on the stack as the loop value; pass it to callees as an argument |
| a temporary used only inside one word | stack (or `>r` / `r@`) |
| a parameter written at the top of a word and read below (`'dy ! 'dx !`) | it already *is* on the stack: just don't store it |
| a value computed from another global (`ta` = `tt 8 *`) | inline the expression where it is used, or make it a word with no variable |
| a per-frame constant read many times in a hot loop (`dux`, `dvx`) | keep the variable |
| state that survives between calls or frames | keep the variable |
| something that would need more than 5 live values at once | keep the variable, or split the word |

Removing a variable never changes what the program computes; it only changes where the value lives. If you cannot tell where a value would live, that is the sign to keep the variable.

### Reading the stack: distance and `pick`

The **distance** of a value is how many items are above it. The top is distance 0.

| Word | Copies the item at distance | Stack effect |
|---|---|---|
| `dup` | 0 | `a -- a a` |
| `over` | 1 | `a b -- a b a` |
| `pick2` | 2 | `a b c -- a b c a` |
| `pick3` | 3 | `a b c d -- a b c d a` |
| `pick4` | 4 | `a b c d e -- a b c d e a` |

`pick4` is the deepest: **only the top 5 values are reachable by copy.** `swap`, `rot`, `-rot` and `nip` rearrange or trim the top items; `2over` / `2swap` work on pairs. A word that needs more live values than that must be split into smaller words, or keep a variable (see the table above).

**The moving target.** The distance of a value grows by one every time you push something above it. This is the mistake behind most wrong `pick`s, so count again after every push:

```r3
| stack: f dr dg db i        (i is on top)
pick4                        | copies f    (distance 4)   -> f dr dg db i f
pick4                        | copies dr   (was 3, now 4) -> f dr dg db i f dr
pick2                        | copies i    (was 0, now 2) -> f dr dg db i f dr i
```

### The process

#### Step 1. Freeze a baseline

Before touching anything, make the program produce a **checksum** of its output, with every source of variation fixed: the random seed, the clock value, the screen size. After each change, the checksum must be identical.

```r3
^r3/lib/rand.r3

#hh
:hashmem | adr n --            ; hash of n dwords
	0 'hh !
	( 1? 1- over d@ hh 31 * + 'hh ! swap 4 + swap ) 2drop ;

:main
	12345 'seed !              | same random sequence on every run
	render                     | the code under test
	'buf 64 hashmem
	hh "hash = %h" .println ;
```

For `colorscene.r3` the test ran each of the 7 scenes for a few frames with `tt` (the time) set by hand, then printed one hash per scene. When a hash changed, the last edit was the culprit, so each edit stayed small. If the output is not a buffer, compare the text it prints, or the bytes it emits.

Also hash the files the program writes (`md5sum`), and run the baseline twice: the two runs must match, or the test is not deterministic and proves nothing. If the program already has a test against a reference model, run it too: it checks meaning, the hash checks that nothing moved.

If a hash changes **on purpose** (a bug fix), do it as a separate step, so the refactoring still compares equal to a known-good baseline.

#### Step 2. Write the stack effect first

For every word, state what it takes and returns, in the comment:

```r3
:dist2 | x1 y1 x2 y2 -- d
```

The words that used to be called with global variables (`xx yy`) now get parameters: `:px | x y -- color`. The stack effect is the contract; the body must honor it exactly, on **every** path (see Step 7).

#### Step 3. Trace with stack comments

Write the stack after every line, as a comment. Do not skip this; it is what makes Step 4 mechanical:

```r3
:dist2 | x1 y1 x2 y2 -- d
	rot -                | x1 x2 dy
	dup *                | x1 x2 dy*dy
	-rot swap -          | dy*dy dx
	dup * + ;
```

Keep the comments in the final code when the word is more than a couple of lines long. They are cheap and they are the documentation.

#### Step 4. Turn variable reads into `pick`s

For each variable read, find the value's distance **at that moment** (remember the moving target), and use `dup`, `over` or `pickN`. Example: the cosine palette from `colorscene.r3`, first with variables:

```r3
#pr #pg #pb #pf #pt

:mkpal | f dr dg db --
	'pb ! 'pg ! 'pr ! 'pf !
	0 ( 256 <?
		dup pf * 8 >> 'pt !
		pt pr + cosc  pt pg + cosc  pt pb + cosc  rgb
		over 2 << 'pal + d!
		1+ ) drop ;
```

and then with the stack. The four arguments (`f dr dg db`) stay below the loop counter `i`, and a helper `pch` computes one channel:

```r3
:pch | f d i -- v              ; one channel: cosc( i*f/256 + d )
	rot * 8 >> + cosc ;

:mkpal | f dr dg db --
	0 ( 256 <?                                  | f dr dg db i
		pick4 pick4 pick2 pch 16 << >r              | red   (parked on the return stack)
		pick4 pick3 pick2 pch 8 << r> or >r         | green
		pick4 pick2 pick2 pch r> or                 | blue
		over 2 << 'pal + d!                         | f dr dg db i
		1+ ) 4drop drop ;
```

How each `pick` was chosen (the stack grows by one with each push):

| Line | Wanted | Stack before the pick | Pick |
|---|---|---|---|
| red | `f` | `f dr dg db i` | `pick4` |
| | `dr` | `f dr dg db i f` | `pick4` (it was at 3, `f` pushed one) |
| | `i` | `f dr dg db i f dr` | `pick2` |
| green | `f` | `f dr dg db i` | `pick4` |
| | `dg` | `f dr dg db i f` | `pick3` |
| | `i` | `f dr dg db i f dg` | `pick2` |
| blue | `f` | `f dr dg db i` | `pick4` |
| | `db` | `f dr dg db i f` | `pick2` |
| | `i` | `f dr dg db i f db` | `pick2` |

Both versions give the same palette entry for entry (checked: 0 different entries out of 256). Two things made it fit: the helper `pch` has only three inputs, and the three channels are computed one after the other, so only one partial result (the red or the red+green already combined) is alive at a time.

#### Step 5. Turn variable writes into computation in place

A variable written once and read once disappears: leave the value on the stack, where the next word expects it. When a value must wait while you compute something else, park it on the **return stack**:

| Word | Use |
|---|---|
| `>r` | move TOS to the return stack (park) |
| `r@` | copy it back without removing it |
| `r>` | take it back |

The rules: every `>r` is matched by an `r>` **inside the same word**, and a loop body must leave the return stack as it found it. While a value is parked it is **not on the data stack**, so do not count it when you work out distances for `pick`. The `mkpal` above parks the red component while it computes the green one.

Do not park more than one or two values. If you need more, you are probably missing a helper word. try to avoid this r stack use !

#### Step 6. Factor when you run out of reach

If a body needs a value deeper than `pick4`, do not fight for it. Extract the part that needs only a few inputs into its own word with a clear stack effect, as `pch` did above. A rule of thumb that held in practice: **a word with 3 inputs or fewer is easy to write on the stack; with 5 inputs it is already hard to read.**

For example, a perspective projection that used four variables becomes one three-input word:

```r3
:proj | v z half -- p          ; v*PH / (z<<4) + half
	-rot 4 << swap PH * swap / + ;
```

#### Step 7. Branches and early exits

Conditionals (`=?`, `<?`, `0?`, ...) leave the tested value in place. **Every path through a word must leave the same stack.** When a branch ends with `;`, it has to consume all that word's inputs and leave exactly the result.

```r3
:band | x y -- c               ; y 0..23 : three bands of 8 rows
	dup 8 /                    | x y band
	0? ( 3drop $ff0000 ; )     | band 0: drop band, y and x
	1 =? ( 3drop $00ff00 ; )   | band 1
	3drop $0000ff ;            | any other band
```

`5 3 band` gives `$FF0000`, `5 10 band` gives `$00FF00` and `5 20 band` gives `$0000FF`.

Which values each branch drops is the part that goes wrong. Write the stack before the `;` in a comment for every branch until you are sure.

#### Step 8. Loops and callbacks: replace `xx yy` by parameters

Keep the loop counter on the stack, and put the loop body into a word that receives what it used to read from globals. The counter of the **inner** loop is on top; the outer one is right below it:

```r3
0 ( H <?                       | y
	0 ( W <?                   | y x
		...
		1+ ) drop              | y
	1+ ) drop
```

Generalize the pixel loop to take the per-pixel word as an argument. The callback is called with `x y`, so nothing needs to be global:

```r3
:forpx | 'px --                ; fills 'buf with px ( x y -- c )
	'buf >a
	0 ( H <?
		0 ( W <?                       | px y x
			dup pick2 pick4 ex da!+    | x y px  -> px(x,y) -> store
			1+ ) drop
		1+ ) 2drop ;

:px | x y -- c
	swap 10 * + ;

'px forpx
```

Inside the inner loop the stack is `px y x`; `dup pick2 pick4` builds `x y px` on top (distance of `y` is 2 after the `dup`, and of `px` is 4 after the second pick), `ex` runs the word and leaves its result, and `da!+` stores it. The version with global variables was:

```r3
#xx #yy
:px-var | -- c
	xx 10 * yy + ;
...
	0 ( H <? dup 'yy !
		0 ( W <? dup 'xx !
			px-var da!+
			1+ ) drop
		1+ ) drop
```

Both fill the buffer with the same values. The callback version also lets you reuse the loop for every scene, which is how `colorscene.r3` got `forpx` and `forxy` and dropped `xx` and `yy`.

#### Step 9. Compare, then measure

Run the baseline of Step 1 and check that **every** hash is equal. Then measure time before and after, because the stack version is not always faster in the current VM.

Measured on `colorscene.r3` (milliseconds per frame, same machine, Linux; compare the columns, not the absolute values):

| Part | Original | Stack version | Note |
|---|---|---|---|
| `present` (draw all cells) | 1.54 ms | 0.63 ms | variables removed from the inner loop |
| spectrum, plasma, tunnel, fire, stars, copper | | within 0.1 ms | |
| rotozoomer | 0.27 ms | 0.44 ms | slower: see below |

A second measurement, `r3logo` (headless run of the programs, 40 compiles + runs each, milliseconds, **minimum of 4 runs**):

| Program | Before | After |
|---|---|---|
| tree (recursion, 2 px lines) | 15 | 14 |
| Koch snowflake | 24 | 25 |
| spiral (1 px lines) | 102 | 104 |
| 300 thick lines and circles | 273 | 260 |

The gain is small (about 5% in the heaviest case, none in the others) because the time is spent in SDL drawing and in compiling, not in the words that were changed. A single run had shown 276 → 207 ms (−25%); it was noise. Measure with the minimum of several runs, never with one. The real gains of that refactoring were fewer globals (17 variables removed, 1 added: the cached line count of the help), registers that survive, and the same pixels.

#### If the hash changes and the original is wrong

In `r3logo` the refactored word gave different hashes for 3 of the 9 programs. The method that found the cause in a few minutes:

1. Run the same build twice. The hash was identical both times, so the difference was real, not noise.
2. Make the smallest program that still differs (here: one thick line, then three). Single segments were equal; three segments were not.
3. Dump both images and compare pixel by pixel (`IMG_SavePNG` of the texture, then a few lines of Python). Only 8 pixels differed.
4. Enlarge the area and look at it. The third side of a triangle was **missing in both versions**: the original had a bug that the old baseline had silently recorded.

Then:

1. Fix the bug in the **original** code, in its own step (see [Truncation and rounding](#truncation-and-rounding)).
2. Take a new baseline from the fixed original (and run it twice).
3. Continue the refactoring against the new baseline. All hashes were equal.

A baseline proves "nothing moved", not "it is right". Look at the output at least once.

### Patterns that avoid variables

**Loop state under the counter.** Keep the values the loop reads below the loop value and reach them with `over`, `pick2`, `pick3`. The loop test also reads them from there (`over <?`).

**Build the stack in the order the loop needs.** Push each value with `dup F swap` so the last step consumes `n`:

```r3
| from a source value s, build  a b c n   (n on top: the loop count)
dup fa swap                  | a s
dup fb swap                  | a b s
dup fc swap                  | a b c s
fn                           | a b c n     the last step consumes s
```

**Pass arguments to a test without losing them.** Copy the group: `pick2 pick2 pick2 test` copies the top three values, `pick3 pick3 pick3 test` copies three values that have a fourth on top of them.

**Cut live values with a helper.** A loop body that needs 6 values becomes a word with 3 inputs plus the loop: one word computes the result for one item, the loop word only stores it.

**Walk memory with A and B** instead of recomputing `i 2 << base +` for each element (see [Registers A and B](#registers-a-and-b)). It removes the pointer variable and the address arithmetic at once.

**Recompute instead of carrying the previous value.** A polygon ring drew segment `i` from the previous point to point `i`, so it kept `px py` in variables. Computing the two ends of segment `i` from `i` and `i+1` needs no state; the point function is called twice per side, and the result was the same image:

```r3
0 ( 48 <?
	dup cpt pick2 1+ cpt seg      | i  x y  x' y'  ->  seg consumes four
	1+ ) drop
```

**Choose the order of the uses so that the last one consumes.** A quad is drawn as a fan: `polyop P0, polyline P1, P2, P3`. The corners are `A+o, A-o, B-o, B+o`. With the stack `x1 y1 x2 y2`, a `2swap` brings the pair `A` on top, and every pair is copied (`2dup`) by all uses except the last one, which consumes it. No `2drop` is left at the end:

```r3
caps 2swap
2dup vp pop vm pln              | A+o, A-o   (A consumed)
2dup vm pln vp pln              | B-o, B+o   (B consumed)
```

**Pass a position as parameters, not as two variables.** `tp | cx cy ang len -- x y` replaced the variables `ltcx ltcy`. With three points that use the same center, copy the center with `2dup`, build the points in the order that leaves the center on top for the last use, and use `2swap` between them.

**Compute at the point of use.** A value stored in a variable only to be used later can be computed where it is used, if nothing in between reads or changes what it depends on. If the computation has side effects (it allocates, it advances a counter), check that their order does not matter.

**Reorder independent effects.** When the stack version needs the uses in another order, swapping two writes is safe only if they touch different data and neither reads what the other writes. If in doubt, keep the original order and rearrange the stack instead.

**The zero case can already be the answer.** For a vector `dx dy` with length 0, the offsets that the word must return are `0 0`, which is what is on the stack: `0? ( drop ; )` returns without dropping anything else.

**Early exit that consumes all the inputs.** When a value is not needed at all (a hidden turtle), `lgshow 0? ( 3drop ; ) drop` is the normal shape, not a trailing drop: the `3drop` is the whole result of that path.

### Variables worth keeping

The rotozoomer got slower because the original keeps two variables `uu` and `vv` updated **incrementally**: at the start of each row it sets them, and then adds a constant for each pixel:

```r3
dux 'uu +!   dvx 'vv +!
```

The stack version evaluated `u = (x-hw)*dux - (y-hh)*dvx + tt*700` (and the same for `v`) for every pixel: four multiplications per pixel instead of two additions. It is simpler to read, but it does more work in the innermost loop. Putting the variables back (and keeping everything else on the stack) gave 0.25 ms, the fastest of the three.

The variables that stayed in `colorscene.r3`, and why:

| Variables | Why they stayed |
|---|---|
| `uu vv dux dvx` | incremental update in the innermost loop (speed) |
| `pcx pcy` | computed once per frame, read for every pixel; passing them as parameters would need more than `pick4` |
| `sx sy tx ty ln` | the star's trail needs 7 live values at once |
| `sdz strail` | per-frame parameters shared by many stars |
| `lfg lbg` | cached terminal colors: state that survives between cells |
| `tt fade dt fps scn ...` | global application state |
| `CW CH PW PH` | screen dimensions: read in almost every word |
| the parameters of an operation (a range, a box, a color) | set once by a word and read by the next words of the same chain |
| counters and accumulators | they live across calls to the same word |
| the current object of a callback | a word called by a library loop (`map`, `draw`) or by a script cannot receive extra parameters |

Rule: **keep a variable when it is state, when it saves work in the hot loop, or when removing it would hide the code.** The goal is not zero variables; it is variables that mean something.

### Trailing drops: consume, don't clean up

A word that ends in `drop`, `2drop`, `3drop` or `4drop`, or that digs under its results with `>r >r >r 3drop r> r> r>`, usually left values on the stack that the computation could have consumed. Reorder it:

1. Start from the value on top of the stack, so it is consumed by the operation that uses it last.
2. As soon as a result is finished, park it with `>r`; take the results back with `r>` at the end (the last one parked comes back first).
3. Do not copy with `pick` a value you will not need again.

```r3
| before: c is copied with pick3, then everything is cleaned up at the end
:vsub | 'v cx cy cz -- x y z        ; v - c
	pick3 >a
	a@+ pick3 -
	a@+ pick3 -
	a@  pick3 -
	>r >r >r 4drop r> r> r> ;

| after: each subtraction consumes its own c; results wait on the return stack
:vsub | cx cy cz 'v -- x y z
	>a
	a> 16 + @ swap - >r         | z consumes cz
	a> 8 + @ swap - >r          | y consumes cy
	a@ swap -                   | x consumes cx
	r> r> ;                     | x y z
```

The same idea works when every result needs all the inputs (a rotation, for example): compute the shared temporaries first, then build the results starting with the component that is on top, so each input is used last by its own result.

A `drop` right after a conditional is not this problem: tests never consume their value, so `>? ( drop ... ; ) drop` is the normal way to clean up (see Step 7). If you cannot reorder because several results need the same input until the end, keep it in a variable or split the word.

### Frequent mistakes in this transformation

| Mistake | Symptom | Fix |
|---|---|---|
| `pickN` counted before pushing an intermediate | wrong value, no error | recount after each push (the moving target) |
| a branch with `;` leaves an extra value | the stack grows each call; crash after a while | write the stack before `;` in every branch |
| one path leaves one item more or fewer | corrupted values far from the cause | check that every path ends with the declared stack effect |
| `<?`, `=?`, `0?` assumed to consume the tested value | off-by-one on the stack | binary tests consume only the second operand; unary tests (`0?`, `1?`) consume nothing |
| `>r` without `r>` in some path | crash on return | pair them inside the same word |
| a word ends in `drop`/`2drop`/`4drop` to discard inputs | values kept on the stack instead of consumed; harder to read and to `pick` | reorder so each input is consumed where it is last used (see [Trailing drops](#trailing-drops-consume-dont-clean-up)) |
| a loop with no exit condition of its own | it runs once | the loop test must be a conditional that has no block of its own (`( running 1? drop ... )`) |
| `c@` returns a signed byte | negative values in indexes | mask it: `c@ $ff and` |
| `nip` used to drop the top item | the wrong value survives | `nip` removes the **second** item (`a b -- b`); to drop the top use `drop` |
| a final `drop` after a unary test (`-?`, `0?`) on an input you still need | the input is gone | that `drop` is only for a value you pushed for the test; an input stays |
| an extra `dup` while building arguments | every `pick` after it lands one item off | recount distances from the real stack, not from the plan |
| `;` between `ab[` and `]ba` | A and B of the caller are lost | `]ba ;` |
| `( 1? 1- ... )` with a computed count | endless loop when the count is negative | `0 max` |
| changing a word's signature and its callers in different steps | nothing works, hard to see why | change them in the same step |
| the stack effect comment lies | later edits break silently | update the comment with the code |
| a loop test without `drop` in the body: `( lgrun 1 =? lg.update )` | the tested value stays on the stack once per iteration; the stack grows and the program crashes later, far from the loop | `( lgrun 1 =? drop lg.update ) drop` |
| `>>0` followed by `1+` | the next string loses its first character, or the pointer lands in garbage | `>>0` already points to the next string |
| `.println`/`sprint` arguments pushed in reading order | the values appear swapped | the first `%` takes the last value pushed |
| trusting the stack comment of a library word | extra `drop`s that eat the caller's values | test it with a sentinel the first time you use it |
| a constant and a variable with the same name up to case | height 0, crash on first draw, no compiler message | prefixes; names are case-insensitive |
| `a b c */` and then rounding with `1 + 2/` | zero results for some angles: lines that disappear | scale up first, round at the end (`$8000 + 16 >>`) |
| a word called once per frame with a stack imbalance (`dup 'v ! dup f` written as `dup 'v ! f`) | the program freezes after some seconds | sentinel test of every word that is in the frame path, before the first run |
| keeping a pointer in A across a library call that uses A (`polyline`, `triangle`) | garbage after the call | audit the library, wrap the unsafe word with `ab[ ]ba` |
| code written after a `|` comment on the same line | the word is empty or incomplete; the stack grows; crash far from the cause | a comment runs to the end of the line: put the code on its own line |
| a block that consumes the tested value, followed by a `drop` after the block | one path is right, the other drops one value too many | choose one shape: pass-through (no drop inside) or early exit (`;` inside) |
| assuming what an `over` or `pick` of the original refers to | a value is applied to the wrong item; the hash differs only in some situations | trace the original stack to see which item it copies; compare the old and the new word side by side (see Testing a rewrite) |
| a string built at `here` (`sprint`, `,s`) passed to a word that also writes at `here` (`load`, the compiler) | the string is overwritten: wrong file name, crash | use a constant string, or copy it somewhere else first |
| a word that replaces another loses its export mark (`::` becomes `:`, `##` becomes `#`) | "word not found" in the files that use it | keep the mark; compare the list of exported names before and after |
| a hash that includes values that legitimately change (time, a visual random effect) | it never matches, so it hides real differences | fix the source, or leave those values out of the hash |
| a new word with the same name as a system or library word | strange behavior or a crash in code that never changed | search the name before defining it (see Names are case-insensitive) |
| the run prints only `compile:` and nothing else | no hint | open `error.log`: it has the line and the word not found |

How to find the first wrong line: compare the hash after each edit; if it differs, undo the last edit and redo it in smaller steps. If you changed many words together, apply the edits to the original **one group at a time** and run the test for each group (words whose signature changed go in the same group). The group that fails is the one to review.

To check a single word, call it from a small `:main` with known inputs and put a **sentinel** value under them. If the word honors its stack effect, the sentinel comes back untouched; if it leaks or eats a value, the sentinel is wrong:

```r3
:main
	99 1 2 4 6 dist2 "dist2 = %d" .println     | 25
	"sentinel = %d" .println ;                 | 99
```

### Testing a rewrite

**A test that cannot fail proves nothing.** Break the thing on purpose once (remove a protection, change a constant) and confirm that the test reports it.

**Compare the old word and the new word side by side.** For a word with arithmetic or pointer logic, keep the old version under another name and call both with the same random inputs on two copies of the data. A hash of the whole program says that something differs; this says which word and with which input.

```r3
:trial | --                    ; one random input, both versions
	randomfill 'a 'b copyblock     | two equal copies of the same input
	'a old.word  'b new.word
	'a 64 hashmem hh  'b 64 hashmem hh  <>? ( "differs" .println ) drop ;
```

**Programs that need a window or hardware.** Run a copy of the program where the drawing primitives are renamed to stubs that fold their arguments into the hash. The program runs without a screen, and the hash covers every call it would have drawn, in order. Rename only in code, not in comments, and give each stub exactly the stack effect of the word it replaces.

**Check names and exports.** After replacing words, compare the exported names (`::` and `##`) with the original. A lost mark compiles in the file itself and fails in the files that use it.

### Checklist

1. Make a deterministic checksum of the output and save it.
2. For each word, write its stack effect.
3. Classify every variable (table at the top); only convert the ones that qualify.
4. Trace the stack in comments, one line at a time.
5. Count distances again after every push; never go beyond `pick4`.
6. Make every branch and every loop iteration leave the same stack depth.
7. Look at the last words of each word: a trailing `drop`/`2drop`/`4drop` means a value could have been consumed (reorder, park results with `>r`).
8. Factor out any part that needs more than 3 or 4 inputs.
9. Compare the checksum after every change.
10. Measure the time. If the inner loop got slower, put the variable back.
11. Delete the variable declarations only when no word uses them any more.
12. Sequential memory loops: use A and B, with `ab[ ]ba` at the entry of the word. Test that the caller's A and B survive.
13. Before relying on A or B across a library call, read the library (`grep ">a\|ab\["`) and wrap the words that do not save them.
14. Run the baseline twice. If a hash differs only for some inputs, look for a bug in the original: fix it in its own step and take a new baseline.
15. Compare times with the minimum of several runs; a single run can be 20% off.
16. Look at the output once with your own eyes; a hash only says that nothing changed.
17. For words with arithmetic or pointer logic, compare the old and the new word on random inputs, not only the hash of the whole program.
18. Break the test on purpose once; a test that cannot fail proves nothing.
19. After replacing words, compare the exported names with the original.

### Case study: `r3logo`

Files: `r3/r3vm/logo-turtle.r3` (engine) and `r3/r3vm/r3logo.r3` (interface). Test: `r3/r3vm/logo-check.r3` (hash of the canvas pixels of 8 programs, hash of the log text, A/B survival of the public words, timing).

| Word | Before | After |
|---|---|---|
| `thick` (line with width) | 6 variables (`ax ay bx by ox oy`) and B for the length | stack plus A and B for the two offsets, wrappers for the unsafe library words |
| `ring` (circle with width) | 3 variables (`cr px py`) | radius in B, each side computed from `i` and `i+1` |
| `turtle`, `tp`, `lg.draw` | 4 variables (`lx ly ltcx ltcy`) | the position is a parameter |
| `vmtick1`, `lg.update` | variable `halt` | the end is read from `ip` after the loop |
| `lg.say` | `count` twice over the 4 KB log | B reads, A writes, one pass |
| `loglines`, help viewer | pointer variables `lp`, `hp`, stack juggling | A walks the text, `drawlines` protects only the widget call |
| `savefile` | `c@+ ... 2drop` | `ca@+ ... drop` |
| unused | `lgbudget` (never read) | removed |

Checks that were run and what they found:

- Canvas hashes of 8 programs and a stress program equal to the baseline (after the rounding bug of the original was fixed in its own step).
- The test of the registers: `lg.update` and `lg.draw` first failed ("A clobbered"). `lg.draw` was fixed by wrapping `triangle`. Then the protection of `thick` was removed on purpose and `lg.update` failed again, so the test does detect the problem.
- The log produced the same bytes and the same length (14 and 2208, with the overflow of the buffer) as the original.

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
#mynode
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
:helper "text" .write ;

| correct
:helper "text" .write ;
:main helper ;
```

### Names are case-insensitive, and a later definition wins silently

`LGH` and `lgh` are the same word. A constant `::LGH 480 ;` followed by a variable `##lgh 0` makes every later `LGH` read the variable (here the heading, 0): the canvas texture was created with height 0 and the first draw crashed. The compiler says nothing.

- Do not name a constant and a variable the same up to case.
- A name defined in your file also hides an exported word with the same name for the rest of the file. In a program that includes a GUI library, `fw`, `fh`, `sw`, `sh`, `cx`, `cy`... are already taken: use a prefix (`lgwid`, `lghei`).
- When a value is `0` or garbage for no reason, search for the name first (`grep -in "name"`).

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
    0? ( nip ; )   | b = 0: return 0
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
	rot over >? ( drop nip ; ) nip     | val > max: return max
	over <? ( drop ; ) nip ;           | val < min: return min
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

### Strings: lists and formatted output

**A list of strings** is a run of literals ended by an empty one (`0`). `>>0` moves to the **next** string, past the terminator; do not add `1+`, or you skip the first character of the next string:

```r3
#names "one" "two" "three" 0
'names ( dup c@ 1? drop
	dup show
	>>0 ) 2drop                  | adr 0 are left at the end
```

**Argument order of `sprint` and `.println`:** the first `%` takes the **last** value pushed. Push the values in reverse order, or put the text first:

```r3
12 34 "a=%d b=%d" .println      | a=34 b=12
```

**Library comments can be wrong.** `pad.reset` is documented as `'var max -- 'var max` but the code leaves only `'var`. A `2drop` after it removed one value of the caller as well. Check every library word you meet for the first time with a sentinel (see [Frequent mistakes in this transformation](#frequent-mistakes-in-this-transformation)).

### Random numbers: the same start gives the same run

A program with a fixed seed, or with no random input at all, gives exactly the same result every run. A test needs that. A game or a simulation usually does not.

- **For variety**, seed once per run from the clock (`msec 1 rerand`) and randomize the initial conditions (positions, order, headings), not only the visual effects.
- **For tests**, fix the seed (see Step 1) so that the hash is stable.
- **Check it** by running the program several times: with the clock seed the results must differ, with the fixed seed they must match.
- **To give distinct slots**, shuffle (Fisher-Yates: for `i` from `n-1` down to `1`, swap item `i` with a random item in `0..i`) instead of drawing until there are no repeats.
- **One generator shared by logic and effects**: the effects consume numbers, so the logic sees a different sequence depending on how many effects ran. Use a separate generator for the effects, or leave them out of the logic.

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
10. A word that uses A or B wraps its body in `ab[ ... ]ba`; a loop must not keep its pointer in A/B across a call to a word it does not control.
11. Temporaries and loop counters usually belong on the stack, not in `#variables`; convert them with the method in [Replacing Variables with Stack References](#replacing-variables-with-stack-references).
12. Names are case-insensitive: a constant and a variable that differ only in case are the same word; a later definition hides an earlier one (also an exported one).
13. Round after scaling, not before: truncating first loses the information that the rounding needs.

### Frequent mistakes

```r3
| value vs address
#x 100
x !               | wrong: x is a value, ! needs an address
50 'x !           | correct

| forgetting to drop after a conditional chain
x 0? ( "zero" .write )
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
