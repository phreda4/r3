# R3Forth — Reference Manual for AI Assistants

> **Purpose**: This manual is written for AI models that program well in C99 but struggle with R3Forth.
> Every section shows the C equivalent alongside R3Forth to anchor the concept.
> Official repository: https://github.com/phreda4/r3

---

## 1. Mental Model: Postfix C Without Types

R3Forth is postfix C where **everything lives on a 64-bit data stack**. There are no types: a cell holds an integer, an address, or a packed fixed-point float (48.16). The compiler performs no type checking.

| C99 | R3Forth | Notes |
|---|---|---|
| `a + b` | `a b +` | operands first, operator after |
| `f(a, b)` | `a b f` | same — arguments are the stack state |
| `x = 5;` | `5 'x !` | `'x` is the address, `!` is store |
| `int x = 5;` | `#x 5` | global declaration with initial value |
| `int x;` | `#x` | global declaration, value 0 |
| `void f() {}` | `:f ;` | word definition |
| `// comment` | `\| comment` | comment to end of line |
| `#include "file.h"` | `^./file.r3` | relative include |
| `#include <lib/math.h>` | `^r3/lib/math.r3` | library include |

---

## 2. The Prefix System (8 Special Characters)

The first character of every token determines how it is compiled.

```
|  comment            | this is a comment
^  include            ^r3/lib/math.r3
"  string literal     "hello world"
:  define word        :myfunction ... ;
#  define data        #myvar 42
$  hex number         $FF  $1800
%  binary number      %1010
'  address of         'myvar  →  pushes the address of myvar
```

### Private vs Exported: `:` vs `::` and `#` vs `##`

```r3
| PRIVATE — only visible inside this file
:myfunction ... ;
#mydata 0

| EXPORTED — visible when the file is included with ^
::myfunction ... ;
##mydata 0
```

This is the module system. Only `::` and `##` definitions cross the file boundary.

---

## 3. The Stack — The Only Working Memory

All operands and results pass through the stack. Comments document the effect:

```r3
| Notation: | before -- after
:square | n -- n²
    dup * ;

| Stack trace of  5 square:
| push 5      →  [ 5 ]
| dup         →  [ 5 5 ]
| *           →  [ 25 ]
```

### Stack Manipulation Words

| Word | Effect | C mental model |
|---|---|---|
| `dup` | `a → a a` | copy a local variable |
| `drop` | `a →` | discard a value |
| `swap` | `a b → b a` | swap two values |
| `over` | `a b → a b a` | copy the second item |
| `nip` | `a b → b` | drop the second item |
| `rot` | `a b c → b c a` | rotate 3 upward |
| `-rot` | `a b c → c a b` | rotate 3 downward |
| `pick2` | `a b c → a b c a` | copy the third item |
| `pick3` | `a b c d → a b c d a` | copy the fourth item |
| `2dup` | `a b → a b a b` | duplicate top pair |
| `2drop` | `a b →` | discard top pair |
| `2swap` | `a b c d → c d a b` | swap two pairs |
| `3drop` | `a b c →` | discard three items |
| `4drop` | `a b c d →` | discard four items |

---

## 4. Variables and Memory

### Declaration

```r3
#lives 3              | one cell (8 bytes), value 3
#x #y #z              | three cells, value 0
#buffer * 1024        | 1024 bytes reserved, zero-initialized
#list 10 20 30        | three cells with values
#table [ 1 2 3 ]      | three dwords (4 bytes each)
#bytes ( 65 66 67 )   | three bytes
```

The `*` syntax reserves zero-initialized bytes, like `uint8_t buf[1024] = {0};` in C.

### Read and Write

```r3
lives          | push the value  (same as 'lives @)
'lives @       | fetch from address
5 'lives !     | store 5 at address of lives
1 'lives +!    | add 1 to lives  (like lives++)
```

### Typed Memory Access

| Size | Read | Write | Read++ | Write++ | C equivalent |
|---|---|---|---|---|---|
| 8-bit  | `c@` | `c!` | `c@+` | `c!+` | `*p`, `*p++` (uint8) |
| 16-bit | `w@` | `w!` | `w@+` | `w!+` | `*p`, `*p++` (uint16) |
| 32-bit | `d@` | `d!` | `d@+` | `d!+` | `*p`, `*p++` (uint32) |
| 64-bit | `@`  | `!`  | `@+`  | `!+`  | `*p`, `*p++` (uint64) |

The `+` variants auto-advance the address after access, exactly like `*p++` in C.

### Dynamic Memory

```r3
HERE       | -- addr   next free memory address (like sbrk())
MARK       |           save current HERE position
EMPTY      |           restore HERE to last MARK (free since then)

| Example: temporary buffer
MARK
HERE 'tmpbuf !
1024 'HERE +!         | allocate 1024 bytes
... use tmpbuf ...
EMPTY                  | free it — no GC needed
```

---

## 5. Registers A and B — High-Speed Pointer Traversal

Two auxiliary registers hold addresses for fast sequential access. They are optimized for array loops and avoid cluttering the data stack with pointer arithmetic.

```c
// C:
void copy(uint64_t *dst, uint64_t *src, int n) {
    while (n--) *dst++ = *src++;
}
```

```r3
| R3Forth:
:copy | dst src n --
    rot >b         | B = dst
    swap >a        | A = src
    ( 1? 1-
        a@+ b!+    | *B++ = *A++
    ) drop ;
```

### Register Operation Table

| Word | Effect | C equivalent |
|---|---|---|
| `>a` | `addr → (A=addr)` | `ptr_a = addr` |
| `a>` | `→ addr` | push current A |
| `a@` | `→ val` | `*ptr_a` |
| `a!` | `val →` | `*ptr_a = val` |
| `a@+` | `→ val, A+=8` | `*ptr_a++` (64-bit) |
| `a!+` | `val →, A+=8` | `*ptr_a++ = val` (64-bit) |
| `ca@+` | `→ byte, A+=1` | `*(uint8_t*)ptr_a++` |
| `ca!+` | `byte →, A+=1` | `*(uint8_t*)ptr_a++ = val` |
| `da@+` | `→ dword, A+=4` | `*(uint32_t*)ptr_a++` |
| `da!+` | `dword →, A+=4` | `*(uint32_t*)ptr_a++ = val` |

Register **B** has identical operations: `>b`, `b>`, `b@`, `b!`, `b@+`, `b!+`, `db@+`, `db!+`.

### Save and Restore Registers

Registers persist across word calls. If you call a word that also uses A or B, save them first:

```r3
ab[                   | save A and B to return stack
    ... use A and B freely ...
]ba                   | restore A and B
```

---

## 6. Conditionals — Translation from C

R3Forth has **no if-else**. A `;` inside a `( )` block is an early return from the enclosing word.

### Unary Conditionals — do NOT consume the tested value

```r3
| C: if (x == 0) { ... }
x 0? ( ... ) drop

| C: if (x != 0) { ... }
x 1? ( ... ) drop

| C: if (x < 0) { ... }
x -? ( ... ) drop

| C: if (x >= 0) { ... }
x +? ( ... ) drop
```

The value stays on the stack after the test. You must `drop` it when done.

### Binary Conditionals — consume TOS, keep NOS

```r3
| C: if (a > b) { ... }
a b >? ( ... ) drop      | NOS=a, TOS=b → asks "is a > b?"

| C: if (a == b) { ... }
a b =? ( ... ) drop
```

After the test, TOS (b) is consumed. NOS (a) remains. You must `drop` a when done.

All binary conditionals: `=?  <?  <=?  >?  >=?  <>?  and?  nand?`

The `in?` conditional checks a range: `a b c in?` is true if `b ≤ a ≤ c`, consuming b and c.

### Chaining — the switch/case pattern

```r3
| C: if/else if/else chain
x
5 =?  ( "five"    ; )     | early return = exit this word
10 =? ( "ten"     ; )
20 =? ( "twenty"  ; )
"other" ;                  | default case
```

### Simulating if-else

```r3
| C: if (cond) { A } else { B }
condition ( A ; ) B ;
```

### Critical Rule: Stack Must Balance on All Paths

```r3
| WRONG — 'n' leaks on the stack at exit
:bad | n --
    5 >? ( "greater" .print )
    ;

| CORRECT
:good | n --
    5 >? ( "greater" .print )
    drop ;
```

---

## 7. Loops — Translation from C

A `( )` block without a preceding conditional is a loop. The condition lives **inside** the block.

### Countdown (preferred — fastest)

```c
// C:
int n = 10;
while (n) { f(); n--; }
```

```r3
| R3Forth:
10 ( 1? 1- f ) drop       | 1? = while non-zero, does not consume counter
```

### Count-up loop

```c
// C:
for (int i = 0; i < 10; i++) { use(i); }
```

```r3
| R3Forth:
0 ( 10 <? dup use 1+ ) drop
```

### Array traversal with register A

```c
// C:
uint64_t *p = arr;
for (int i = 0; i < n; i++) { process(*p++); }
```

```r3
arr >a
n ( 1? 1- a@+ process ) drop
```

### Early exit from a loop

```r3
:find | addr cnt target -- addr|0
    >r swap >a             | save target in R, addr in A
    ( 1? 1-
        a@+ r@ =? ( r> 2drop a> 8 - ; )  | found: return address
        drop
    ) r> 3drop 0 ;         | not found: return 0
```

### Multiple exit conditions

```r3
| Loop ends when any condition triggers
"text" ( c@+  1?       | continue while not null
         13 <>?        | AND not carriage return
         10 <>?        | AND not line feed
         drop
) 2drop
```

---

## 8. Recursion

Words can call themselves immediately once defined. Tail calls (last operation before `;`) are compiled as jumps, so tail-recursive words become loops with no stack growth.

```r3
:factorial | n -- n!
    dup 1 <=? ( drop 1 ; )    | base case: 0! = 1! = 1
    dup 1 -
    factorial
    * ;

5 factorial    | → 120
```

---

## 9. Return Stack — Temporary Storage

The return stack holds return addresses. It can safely be used for temporary storage **within a single word**, as long as every `>r` is matched by `r>` before any `;`, including early exits.

```r3
:example | a b c --
    >r >r           | save b and c
    ... work with a ...
    r> r> ;         | restore c then b

| WRONG — forgets to pop before ;
:bad | n --
    >r
    ... code ...
    ;               | crash: corrupted return address

| WRONG — conditional imbalance
:bad2 | n --
    >r
    condition? ( r> use )    | only pops in one branch!
    ;

| CORRECT
:good2 | n --
    >r
    condition? ( r> use ; )
    r> drop ;
```

---

## 10. Arithmetic and Fixed-Point

### Integer Arithmetic

```r3
5 3 +      | 8
10 3 -     | 7
10 3 *     | 30
10 3 /     | 3    (integer division)
10 3 mod   | 1    (remainder)
10 3 */    | a*b/c  without intermediate overflow (scale)
5 neg      | -5
5 abs      | 5
```

### Bit Operations

```r3
2 3 <<     | 16   (left shift)
16 2 >>    | 4    (right shift, signed)
16 2 >>>   | 4    (right shift, unsigned)
$ff $0f and | $0f
$f0 $0f or  | $ff
$ff $0f xor | $f0
5 not      | -6   (bitwise NOT — all bits flipped)
```

### Fixed-Point 48.16 Format

R3Forth uses **48.16 fixed-point**: 48 integer bits + 16 fractional bits, stored in one 64-bit cell. Multiply any real number by 65536 to get its stored form.

```
0.5 stored as:  0.5 × 65536 = 32768
3.14 stored as: 3.14 × 65536 ≈ 205887
```

Decimal literals like `1.5` or `3.14` are automatically converted at compile time.

**Angles are in turns**: 1.0 = full circle, 0.5 = 180°, 0.25 = 90°.

```r3
| Fixed-point multiply and divide (from r3/lib/math.r3)
a b *.         | a × b
a b /.         | a / b

| Convert integer ↔ fixed-point
5 fix.         | 5 → 5.0 in 48.16  (shift left 16)
valor int.     | 5.0 → 5 (truncate, shift right 16)

| Trig (angles in turns)
0.25 sin       | ≈ 1.0  (sin of 90°)
0.25 cos       | ≈ 0.0
angle sincos   | → sin cos   (cos is TOS, sin is NOS)

| sincos order is critical:
cam_yaw sincos 'cy ! 'sy !
| cy = cos(yaw)  ← stored first (TOS)
| sy = sin(yaw)  ← stored second

| Convert between fixed-point and IEEE float32 (for OpenGL)
value f2fp     | 48.16 fixed → float32 IEEE
float fp2f     | float32 IEEE → 48.16 fixed
n i2fp         | integer → float32 IEEE
float fp2i     | float32 IEEE → integer
```

---

## 11. Strings

```r3
| A string literal pushes its address (null-terminated)
"hello world"               | → address

| Print with format specifiers
42 "the value is %d" .print | → "the value is 42"
| Format codes: %d decimal, %h hex, %b binary, %s string, %% literal %
| Values are consumed right-to-left matching the % placeholders

| Iterate character by character
"hello" ( c@+ 1? process ) 2drop

| Length
"hello" count              | → address 5

| Formatted output to HERE (temporary buffer)
42 "value=%d" sprint       | → address of formatted string at HERE

| Embed a quote inside a string by doubling it
"say ""hello"" to everyone"
```

### Defining String Data

```r3
| In a # definition: stored in variable memory, null-terminated
#greeting "Hello"          | 'greeting is the address of "Hello\0"

| String array (pointer table)
#s1 "one"
#s2 "two"
#s3 "three"
#names 's1 's2 's3         | array of 3 addresses
```

---

## 12. Program Structure and Word Definitions

### Fall-Through (deliberate feature)

A word definition without a closing `;` falls through into the next definition:

```r3
:word1
    something
:word2          | no ; here — word1 continues directly into word2
    more ;

word1   | executes: something + more, then return
word2   | executes: more, then return
```

### Jump Tables (switch on integer)

```r3
:action0 "zero"  .print ;
:action1 "one"   .print ;
:action2 "two"   .print ;

#actions 'action0 'action1 'action2

:dispatch | n --
    3 << 'actions + @ ex ;    | multiply by 8 (cell size), fetch address, execute

2 dispatch    | prints "two"
```

### Word Export and Module Pattern

```r3
| file: mylib.r3

| Private helpers — not visible outside
:internal-helper ... ;
#private-state 0

| Public API — visible when ^./mylib.r3 is included
::exported-func | a b -- result
    internal-helper ... ;
##exported-var 0
```

---

## 13. Library: math.r3

```r3
^r3/lib/math.r3
```

#### Fixed-Point Arithmetic

```r3
::*.    ( a. b. -- c. )     | multiply two fixed-point values
::/.    ( a. b. -- c. )     | divide two fixed-point values
::2/.   ( a. -- a/2. )      | divide by 2, sign-correct
::fix.  ( n -- n. )         | integer → fixed-point (n × 65536)
::int.  ( a. -- n )         | fixed-point → integer (truncate)
::ceil  ( a. -- n )         | fixed-point → integer (ceiling)
::sign  ( v -- v s )        | push +1 or -1 without consuming v
```

#### Trigonometry (angles in turns: 0.0–1.0)

```r3
::sin       ( a. -- sin. )
::cos       ( a. -- cos. )
::tan       ( a. -- tan. )
::sincos    ( a. -- sin. cos. )   | cos is TOS
::atan2     ( x. y. -- angle. )
::polar     ( angle. dist. -- dx. dy. )
```

#### Min / Max / Clamp

```r3
::min         ( a b -- m )
::max         ( a b -- m )
::clampmax    ( v max -- v )      | clamp to ≤ max
::clampmin    ( v min -- v )      | clamp to ≥ min
::clamp0      ( v -- v )          | clamp to ≥ 0
::clamp0max   ( v max -- v )      | clamp to 0..max
::between     ( v min max -- f )  | negative if outside range
```

#### Advanced Math

```r3
::sqrt.       ( x. -- r. )        | square root
::log2.       ( y. -- r. )        | log base 2
::pow.        ( x. y. -- r. )     | x ^ y
::ln.         ( x. -- r. )        | natural log
::exp.        ( x. -- r. )        | e ^ x
::pow         ( base exp -- r )   | integer power
::msb         ( n -- pos )        | position of most significant bit
```

#### Float32 IEEE Conversion (for OpenGL/GPU data)

```r3
::i2fp        ( i -- fp )         | integer → float32 IEEE
::f2fp        ( f. -- fp )        | fixed-point → float32 IEEE
::fp2f        ( fp -- f. )        | float32 IEEE → fixed-point
::fp2i        ( fp -- i )         | float32 IEEE → integer
```

#### Integer Shortcuts

```r3
::2*  ::2/                         | multiply / divide by 2
::10*  ::100*  ::1000*             | scale by powers of 10
::10/  ::10/mod ( n -- q r )
::6*  ::6/  ::6mod
::*/  ( a b c -- a*b/c )          | scale without overflow
```

---

## 14. Library: rand.r3

```r3
^r3/lib/rand.r3
```

```r3
::rerand   ( s1 s2 -- )      | initialize generator with two seeds
::rand     ( -- n )           | 64-bit random number
::randmax  ( max -- n )       | random integer in [0, max)

| Typical initialization:
time msec rerand               | seed with current time + milliseconds

| Usage:
100 randmax                    | random integer 0..99
5.0 randmax 5.0 -.             | random fixed-point -5.0..0.0
```

---

## 15. Library: str.r3

```r3
^r3/lib/str.r3
```

```r3
::strlen   ( str -- str len )     | length without consuming address
::strcpy   ( dst src -- )         | copy null-terminated string
::strcmp   ( s1 s2 -- n )         | 0 if equal, non-zero if different
::strcat   ( dst src -- )         | append src to dst
::strupr   ( str -- )             | convert to uppercase in place
::strlwr   ( str -- )             | convert to lowercase in place
::strfind  ( haystack needle -- addr|0 )  | find substring
```

---

## 16. Library: console.r3

Terminal I/O with ANSI colors. Use this for tools and utilities.

```r3
^r3/lib/console.r3
```

```r3
::.cls     ( -- )              | clear console
::.write   ( "text" -- )       | write text without newline
::.print   ( .. "fmt" -- )     | formatted output (same as .print)
::.println ( "text" -- )       | write text + newline
::.cr      ( -- )              | newline only
::.home    ( -- )              | move cursor to top-left
::.at      ( x y -- )          | position cursor at column x, row y
::.fc      ( color -- )        | set foreground color (ANSI 0..15)
::.bc      ( color -- )        | set background color (ANSI 0..15)
::.input   ( -- )              | read a line from keyboard into ##pad
::.inkey   ( -- key )          | return currently pressed key, 0 if none
```

After `.input`, the entered text is in the exported variable `##pad`.

---

## 17. Library: sdl2.r3 — Window and Events

```r3
^r3/lib/sdl2.r3
```

#### Window Management

```r3
::SDLinit   ( "title" w h -- )   | create window and renderer
::SDLfull   ( -- )               | toggle fullscreen
::SDLquit   ( -- )               | destroy window
::SDLcls    ( color -- )         | clear screen with color ($RRGGBB)
::SDLredraw ( -- )               | flip buffers (show frame)
::SDLshow   ( 'word -- )         | run word every frame (main loop)
::exit      ( -- )               | exit the SDLshow loop
```

#### Input Variables (read each frame)

| Variable | Description |
|---|---|
| `##SDLkey` | Currently pressed key code (0 = none) |
| `##SDLchar` | Character code of pressed key |
| `##SDLx` `##SDLy` | Mouse position in pixels |
| `##SDLb` | Mouse button state |
| `##SDLw` | Mouse wheel delta |

In the project-specific wrappers these are named `sdlkey`, `sdlx`, `sdly`, `sdlb`, `SDLw`, `sw`, `sh`.

#### Key Code Constants (from sdlkeys.r3)

Key codes use angle bracket notation:

```r3
sdlkey
>esc< =? ( exit )          | Escape key — note >esc< means "escape released"
<w>   =? ( move_forward )  | W key pressed
>w<   =? ( stop_forward )  | W key released
<tab> =? ( next_item )
<up>  =? ( go_up )
<dn>  =? ( go_down )
<le>  =? ( go_left )
<ri>  =? ( go_right )
<ret> =? ( confirm )
<spc> =? ( jump )
drop
```

Pattern: `<key>` = pressed, `>key<` = released.

---

## 18. Library: sdl2gfx.r3 — 2D Drawing

```r3
^r3/lib/sdl2gfx.r3
```

#### Color and Primitives

```r3
::SDLColor   ( col -- )              | set color ($RRGGBB or $AARRGGBB)
::SDLPoint   ( x y -- )              | draw pixel
::SDLLine    ( x1 y1 x2 y2 -- )      | draw line
::SDLFRect   ( x y w h -- )          | filled rectangle
::SDLRect    ( x y w h -- )          | rectangle outline
::SDLFCircle ( r x y -- )            | filled circle
::SDLCircle  ( r x y -- )            | circle outline
::SDLTriangle( x1 y1 x2 y2 x3 y3 -- ) | filled triangle
```

#### Images

```r3
::SDLImage   ( x y img -- )          | draw image at (x,y) full size
::SDLImages  ( x y w h img -- )      | draw image scaled to w×h
::SDLspriteZ ( x y zoom img -- )     | draw with zoom factor
::SDLSpriteR ( x y angle img -- )    | draw with rotation (turns)
```

#### Sprite Sheets

```r3
::ssload     ( w h "file" -- ss )    | load sprite sheet (w×h per sprite)
::ssprite    ( x y n ss -- )         | draw sprite n, centered at (x,y)
::sspriter   ( x y angle n ss -- )   | draw with rotation
::sspritez   ( x y zoom n ss -- )    | draw with scale
```

---

## 19. Common AI Mistakes in R3Forth

### ❌ Mistake 1: Stack imbalance at exit

```r3
| WRONG — value 'n' leaks on the caller's stack
:bad | n --
    5 >? ( "greater" .print )
    ;

| CORRECT
:good | n --
    5 >? ( "greater" .print )
    drop ;
```

### ❌ Mistake 2: Confusing a name with its address

```r3
| WRONG — pushes the VALUE of lives, not its address
lives !         | crash

| CORRECT — 'lives pushes the ADDRESS
5 'lives !
```

### ❌ Mistake 3: Using `*` instead of `*.` for fixed-point

```r3
| WRONG — * is integer multiply
2.0 3.0 *      | gives garbage (integer multiply of two big fixed-point numbers)

| CORRECT
2.0 3.0 *.     | gives 6.0 in fixed-point
```

### ❌ Mistake 4: Forgetting `fix.` when mixing int with fixed-point

```r3
| level is an integer, but camEye component is fixed-point
'camEye 8 + @ level -     | WRONG — type mismatch
'camEye 8 + @ level fix. - | CORRECT — convert level to fixed-point first
```

### ❌ Mistake 5: Misreading binary conditional direction

```r3
| >? asks: "is NOS > TOS?" which means "is a > b?"
| Stack before: a b  (NOS=a, TOS=b)
a b >?                    | true if a > b
drop                      | drop 'a' which remains after test
```

### ❌ Mistake 6: Destroying registers A/B with nested calls

```r3
| WRONG — process may also use register A internally
:outer | --
    'mybuffer >a
    process           | A is now pointing somewhere inside process
    a@+ ... ;         | reading wrong memory

| CORRECT
:outer | --
    ab[
    'mybuffer >a
    process
    ]ba
    a@+ ... ;
```

### ❌ Mistake 7: Early return with dirty stack

```r3
| WRONG — 'a' and 'b' remain on caller's stack
:bad | a b -- result
    over 0? ( ; )     | exits without cleaning a and b
    + ;

| CORRECT
:good | a b -- result
    over 0? ( 2drop 0 ; )   | clean up, return known value
    + ;
```

### ❌ Mistake 8: Return stack imbalance across a conditional

```r3
| WRONG — only one branch pops from return stack
:bad | n --
    >r
    condition? ( r> use )    | only pops if condition true!
    ;                        | crashes if condition false

| CORRECT
:good | n --
    >r
    condition? ( r> use ; )  | pop and return
    r> drop ;                | pop in the other branch too
```

### ❌ Mistake 9: Sincos output order

```r3
| sincos ( angle -- sin cos )  — cos is TOS, sin is NOS
angle sincos 'cy ! 'sy !
| cy = cos(angle)  ← stored first because it is TOS
| sy = sin(angle)  ← stored second
```

### ❌ Mistake 10: Nested conditionals leaving extra values

```r3
| WRONG — 'x' leaks after inner test
x 5 >? ( 10 <? ( "between" .print ) )

| CORRECT — clean all paths
x
5 >? (
    10 <? ( "between" .print drop ; )  | drop x
    drop                                | x > 10 path
; )
drop                                    | x <= 5 path
```

---

## 20. Quick Reference Card

### Prefixes

```
|   comment          ^   include         "   string
:   word def         #   data def        $   hex
%   binary           '   address of
:: exported word     ## exported data
```

### Stack

```
dup drop swap over nip rot -rot
pick2 pick3 2dup 2drop 2swap 3drop 4drop
```

### Memory

```
@ ! +!   @+ !+   c@ c! c@+ c!+   d@ d! d@+ d!+   w@ w! w@+ w!+
>a a> a@ a! a@+ a!+   ca@+ ca!+   da@+ da!+
>b b> b@ b! b@+ b!+   cb@+ cb!+   db@+ db!+
ab[  ]ba
>r r> r@
MARK EMPTY HERE
```

### Arithmetic

```
+ - * / mod */   neg abs   << >> >>>   and or xor not nand
*.  /.  fix.  int.  ceil   f2fp fp2f  i2fp fp2i
sin cos tan sincos atan2   min max clamp0 clamp0max
```

### Conditionals

```
0? 1? +? -?              | unary: keep TOS
=? <? <=? >? >=? <>?     | binary: consume TOS, keep NOS
and? nand? in?
```

### Loops

```
n   ( 1? 1- body ) drop               | countdown while n != 0
0   ( limit <? body 1+ ) drop         | count up to limit
ptr ( c@+ 1? body ) 2drop             | null-terminated string
```

### Output

```
.print    "fmt %d %s" with values on stack
.println  text only, adds newline
sprint    formats to HERE buffer, pushes address
```

---

*Manual derived from the official tutorial at https://github.com/phreda4/r3/blob/main/doc/r3forth_tutorial.md
and the library reference at https://github.com/phreda4/r3/blob/main/doc/r3forth-libs.md*
*Analysis date: June 2026.*
