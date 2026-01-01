# Manual: Translating C to R3forth

## Introduction

R3forth is a concatenative stack-based programming language that uses Reverse Polish Notation (RPN). This manual explains how to systematically translate C code to R3forth.

---

## Fundamental Concepts

### Type System and Memory

#### Memory Cells
- **All cells are 64 bits (8 bytes)**
- A variable defined with `#` stores a 64-bit value
- No separate types: integers and fixed-point use the same format

#### Fixed Point 48.16
Decimal numbers are represented in fixed-point format:
- 48 bits: integer part
- 16 bits: fractional part
- **Same access as integers** (no special access operators)

```r3
| Define variables
#x 100
#y 1.5

| Use values
x y *.    | multiply 100 * 1.5 (fixed point)
```

### Postfix Notation

**Fundamental rule**: Operands come first, then the operator.

```c
// C
int result = (a + b) * c;
```

```r3
| R3forth
a b + c *
```

---

## Variables and Memory Access

### Variable Definition

```r3
#var              | One cell (8 bytes), value 0
#var 100          | One cell, value 100
#var 10 20        | Two consecutive cells: 10, 20
#buffer * 1000    | 1000 bytes (uninitialized buffer)
```

### Access Methods

```r3
| Define variable
#x 50

| 1. By NAME (pushes the VALUE)
x             | Pushes: 50

| 2. By ADDRESS with '
'x            | Pushes: address of x

| 3. Read from address with @
'x @          | Pushes: value at x (50)
              | Equivalent to: x

| 4. Write to address with !
100 'x !      | x is now 100

| 5. Modify value with +!
5 'x +!       | x = x + 5
```

**Critical rule**:
- `x` → value of x
- `'x` → address of x
- Memory operators (`!`, `@`, `+!`) **always** require address

### Comparative Examples

```c
// C
int x = 100;
x = x + 5;
y = x * 2;
x += 10;
```

```r3
| R3forth
#x 100
5 'x +!           | x = x + 5
x 2 * 'y !        | y = x * 2
10 'x +!          | x += 10
```

---

## Memory Access Sizes

R3 provides different operators depending on data size:

| Size  | Read | Write | Read+ | Write+ | Bytes |
|-------|------|-------|-------|--------|-------|
| byte  | `c@` | `c!`  | `c@+` | `c!+`  | 1     |
| word  | `w@` | `w!`  | `w@+` | `w!+`  | 2     |
| dword | `d@` | `d!`  | `d@+` | `d!+`  | 4     |
| qword | `@`  | `!`   | `@+`  | `!+`   | 8     |

**Important**: The `@+` and `!+` operators **increment** the address by the data size:
- `c@+` increments +1
- `w@+` increments +2  
- `d@+` increments +4
- `@+` increments +8

```r3
| Read consecutive bytes
#buffer * 100
'buffer c@+    | Read byte at [0], leaves address [1]
        c@+    | Read byte at [1], leaves address [2]
        c@     | Read byte at [2]
        3drop  | Clean stack
```

---

## Control Structures

### Conditionals

#### IF without ELSE

```c
// C
if (x > 5) {
    doSomething();
}
doAlways();
```

```r3
| R3forth
x 5 >? ( drop doSomething ) drop
doAlways
```

**CRITICAL**: Comparisons in R3 **only consume TOS** (top of stack).

```r3
a b <?          | Compares: a < b
                | Consumes: b (TOS)
                | Leaves: a on stack
```

#### IF-ELSE Pattern

R3 **has no ELSE**. Use early exit with `;`:

```c
// C
if (condition) {
    branch1();
} else {
    branch2();
}
```

```r3
| R3forth - Early exit
:myword
    condition? ( drop branch1 ; )  | If true: execute and exit
    branch2 ;                       | If false: continue here
```

Alternative with helper word:

```r3
:true_branch
    branch1 ;

:myword
    condition? ( drop true_branch ; )
    branch2 ;
```

#### SWITCH/CASE

```c
// C
switch(type) {
    case 0: action0(); break;
    case 1: action1(); break;
    case 2: action2(); break;
    default: actionDefault();
}
```

```r3
| R3forth
type
0 =? ( drop action0 ; )
1 =? ( drop action1 ; )
2 =? ( drop action2 ; )
drop actionDefault ;
```

### Loops

#### Countdown Loop (PREFERRED - faster)

```c
// C
for (int i = 10; i > 0; i--) {
    process(i);
}
```

```r3
| R3forth
10 ( 1? 1-        | While != 0, decrement
    dup process
) drop
```

**Why preferred**: `1?` doesn't consume the value, it's more efficient.

#### Count-up Loop

```c
// C
for (int i = 0; i < 10; i++) {
    process(i);
}
```

```r3
| R3forth
0 ( 10 <? 1+      | While < 10, increment
    dup process
) drop
```

#### While Loop

```c
// C
while (condition()) {
    body();
}
```

```r3
| R3forth
( condition
    body
) drop
```

**Critical rule**: Each iteration MUST leave stack at same height.

---

## Conditional Operators

### Stack Tests (DON'T consume)

| Word | Test | Stack |
|------|------|-------|
| `0?` | `a = 0` | `a -- a` |
| `1?` | `a ≠ 0` | `a -- a` |
| `+?` | `a ≥ 0` | `a -- a` |
| `-?` | `a < 0` | `a -- a` |

### Comparisons (consume TOS, keep NOS)

| Word | Test | Stack |
|------|------|-------|
| `=?` | `a = b` | `a b -- a` |
| `<?` | `a < b` | `a b -- a` |
| `>?` | `a > b` | `a b -- a` |
| `<=?` | `a ≤ b` | `a b -- a` |
| `>=?` | `a ≥ b` | `a b -- a` |
| `<>?` | `a ≠ b` | `a b -- a` |

### Logical Tests (consume TOS)

| Word | Test | Stack |
|------|------|-------|
| `and?` | `(a AND b) ≠ 0` | `a b -- a` |
| `nand?` | `(a NAND b) ≠ 0` | `a b -- a` |

### Range Test (consume two values)

| Word | Test | Stack |
|------|------|-------|
| `in?` | `b ≤ a ≤ c` | `a b c -- a` |

**Important example**:
```r3
x 5 10 in? ( "Between 5 and 10" print ) drop
```

### Usage Pattern

```r3
| Value persists after test
x 0? ( "Is zero" print )
  +? ( "Is positive" print )    | x still on stack
drop                             | Clean up at end
```

---

## Arithmetic

### Basic Operations

| Word | Effect | Description |
|------|--------|-------------|
| `+` | `a b -- c` | c = a + b |
| `-` | `a b -- c` | c = a - b |
| `*` | `a b -- c` | c = a × b (integers) |
| `*.` | `a b -- c` | c = a × b (fixed point) |
| `/` | `a b -- c` | c = a ÷ b (integers) |
| `/.` | `a b -- c` | c = a ÷ b (fixed point) |
| `mod` | `a b -- c` | c = a mod b |
| `neg` | `a -- -a` | Negate |
| `abs` | `a -- |a|` | Absolute value |

### Double-Precision Arithmetic (CRITICAL)

**Prevents overflow in intermediate calculations**:

| Word | Effect | Description |
|------|--------|-------------|
| `*/` | `a b c -- d` | d = (a×b)÷c no overflow |
| `*>>` | `a b c -- d` | d = (a×b)>>c no loss |
| `<</` | `a b c -- d` | d = (a<<c)÷b no loss |

**Example**: Scale from 0-100 to 0-255
```r3
| C (can overflow)
result = (value * 255) / 100;

| R3forth (safe)
value 255 100 */
```

### Bit Operations

| Word | Effect | Description |
|------|--------|-------------|
| `<<` | `a b -- c` | Shift left |
| `>>` | `a b -- c` | Shift right (signed) |
| `>>>` | `a b -- c` | Shift right (unsigned) |
| `and` | `a b -- c` | Bitwise AND |
| `or` | `a b -- c` | Bitwise OR |
| `xor` | `a b -- c` | Bitwise XOR |
| `not` | `a -- b` | Bitwise NOT |
| `nand` | `a b -- c` | Bitwise NAND |

---

## Stack Operations

### Basic Manipulation

| Word | Effect | Description |
|------|--------|-------------|
| `dup` | `a -- a a` | Duplicate TOS |
| `drop` | `a --` | Remove TOS |
| `swap` | `a b -- b a` | Exchange top two |
| `over` | `a b -- a b a` | Copy second to top |
| `nip` | `a b -- b` | Remove second |
| `rot` | `a b c -- b c a` | Rotate three left |
| `-rot` | `a b c -- c a b` | Rotate three right |
| `pick2` | `a b c -- a b c a` | Copy third |
| `pick3` | `a b c d -- a b c d a` | Copy fourth |
| `pick4` | `a b c d e -- a b c d e a` | Copy fifth |

### Multi-Element

| Word | Effect | Description |
|------|--------|-------------|
| `2dup` | `a b -- a b a b` | Duplicate top two |
| `2drop` | `a b --` | Remove top two |
| `3drop` | `a b c --` | Remove top three |
| `4drop` | `a b c d --` | Remove top four |
| `2over` | `a b c d -- a b c d a b` | Copy 3rd and 4th |
| `2swap` | `a b c d -- c d a b` | Exchange pairs |

---

## Registers A and B

**Fast temporary storage** for addresses:

### Register A Operations

| Word | Effect | Description |
|------|--------|-------------|
| `>a` | `val --` | Load A |
| `a>` | `-- val` | Push A value |
| `a+` | `val --` | Add to A |
| `a@` | `-- val` | Read qword from A |
| `a!` | `val --` | Write qword to A |
| `a@+` | `-- val` | Read qword, A+=8 |
| `a!+` | `val --` | Write qword, A+=8 |

**Size variants**:
- `ca@`, `ca!`, `ca@+`, `ca!+` (byte, +1)
- `wa@`, `wa!`, `wa@+`, `wa!+` (word, +2)
- `da@`, `da!`, `da@+`, `da!+` (dword, +4)

### Register B Operations

Identical to A: `>b`, `b>`, `b+`, `b@`, `b!`, `b@+`, etc.

### Use Case

```r3
| Process array
'array >a
100 ( 1? 1-
    a@+ process    | Read from A and advance +8
) drop
```

**⚠️ WARNING**: Registers are NOT preserved across word calls.

### Save/Restore Registers

```r3
ab[               | Save A and B
'data >a
| ... use A ...
]ba               | Restore B and A
```

---

## Return Stack

| Word | Effect | Description |
|------|--------|-------------|
| `>r` | `a -- (r: -- a)` | Push to return stack |
| `r>` | `-- a (r: a --)` | Pop from return stack |
| `r@` | `-- a (r: a -- a)` | Copy top of return stack |

**⚠️ DANGER**: Return stack imbalance will crash. Use with extreme care.

---

## Data Structures from C

### Translating Structs

```c
// C
typedef struct {
    uint8_t type;    // offset 0 (1 byte)
    uint8_t note;    // offset 1 (1 byte)
    int value;       // offset 8 (64-bit alignment)
} Node;
```

```r3
| R3forth - In 64-bit cells
| Cell 0: type | note | padding (packed)
| Cell 1: value

| Accessors
:n.type     @ $ff and ;              | addr -- type
:n.note     @ 8 >> $ff and ;         | addr -- note
:n.value    1 << + ;                 | addr -- addr_value

| Pack
:pack_node  | type note value -- addr
    here >r
    rot rot 8 << or ,    | Pack type|note
    ,                     | value
    r> ;

| Use
0 60 100 pack_node 'mynode !
mynode @ n.type    | → 0
mynode @ n.note    | → 60
mynode @ n.value @ | → 100
```

### Arrays

```c
// C
int array[10];
array[5] = 100;
x = array[5];
```

```r3
| R3forth
#array * 80        | 10 cells * 8 bytes

| Write
100 'array 5 3 << + !     | array[5] = 100
                          | 3 << = *8 (cell size)

| Read
'array 5 3 << + @         | x = array[5]
```

---

## Definition Order

**CRITICAL**: In R3 you CANNOT use a word before defining it.

```r3
| ✗ INCORRECT
:main helper ;
:helper "text" print ;

| ✓ CORRECT
:helper "text" print ;
:main helper ;
```

**Dependency order**:
```
base_function
    ↓
intermediate_function (uses base_function)
    ↓
main_function (uses intermediate_function)
```

---

## Common Patterns

### Safe Division

```c
// C
int safe_div(int a, int b) {
    if (b == 0) return 0;
    return a / b;
}
```

```r3
| R3forth
:safe_div | a b -- result
    0? ( ; )    | If b=0, leave a and exit
    / ;         | Otherwise, divide
```

### Clamp/Bounds

```c
// C
int clamp(int val, int min, int max) {
    if (val < min) return min;
    if (val > max) return max;
    return val;
}
```

```r3
| R3forth
:clamp | val min max -- clamped
    rot over <? ( nip ; ) nip     | Check minimum
    over >? ( drop ; ) nip ;       | Check maximum
```

### Process Array

```c
// C
void process_array(int* arr, int count) {
    for (int i = 0; i < count; i++) {
        process(arr[i]);
    }
}
```

```r3
| R3forth - Option 1
:process_array | addr count --
    ( 1? 1-
        swap @+ process swap
    ) 2drop ;

| R3forth - Option 2 (with register)
:process_array | addr count --
    swap >a
    ( 1? 1-
        a@+ process
    ) drop ;
```

---

## Converting C Functions

### Simple Function

```c
// C
int add_five(int x) {
    return x + 5;
}
```

```r3
| R3forth
:add_five | x -- result
    5 + ;
```

### Function with Multiple Returns

```c
// C
int classify(int x) {
    if (x < 0) return -1;
    if (x == 0) return 0;
    return 1;
}
```

```r3
| R3forth
:classify | x -- class
    dup 0 <? ( drop -1 ; )    | Negative
    0? ( ; )                   | Zero
    drop 1 ;                   | Positive
```

### Function with Local Variables

```c
// C
int calculate(int a, int b) {
    int temp = a * 2;
    int result = temp + b;
    return result;
}
```

```r3
| R3forth - Option 1: No variables
:calculate | a b -- result
    swap 2 * + ;

| R3forth - Option 2: With return stack
:calculate | a b -- result
    >r 2 * r> + ;

| R3forth - Option 3: With variables (less efficient)
:calculate | a b -- result
    'temp_b ! 2 * temp_b + ;
#temp_b 0
```

---

## Translation Checklist

### ✓ Do:
1. Define all words BEFORE using them
2. Balance stack in every word
3. Use countdown loops with `1?` when possible
4. Drop values after conditionals
5. Use early exit `;` instead of IF-ELSE
6. Comment stack effects: `| before -- after`
7. Use `*/` for safe scaling
8. Use `'var` for memory operations

### ✗ Don't:
1. Forward references
2. Assume IF-ELSE exists
3. Forget that conditionals KEEP the tested value
4. Use registers across calls without saving
5. Assume `@+` always increments +1
6. Use `x` when you need `'x` for memory
7. Forget that cells are 8 bytes

---

## Complete Example: C → R3forth

```c
// C
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
| R3forth
^r3/lib/console.r3

:fibonacci | n -- fib(n)
    dup 1 <=? ( ; )              | If n≤1, return n
    dup 1 - fibonacci            | fib(n-1)
    swap 2 - fibonacci           | fib(n-2)
    + ;                          | add

:main | --
    10 0 ( over <? 
        dup fibonacci "%d " .print
        1+
    ) 2drop 
    .cr ;

: main ;
```

---

## Common Errors

### Error 1: Confusing value with address

```r3
| ✗ INCORRECT
#x 100
x !               | Error: x is the value, not address

| ✓ CORRECT
#x 100
50 'x !           | 'x is the address
```

### Error 2: Forgetting DROP after conditionals

```r3
| ✗ INCORRECT
x 0? ( "zero" print )
  5 =? ( "five" print )
| x still on stack!

| ✓ CORRECT
x 0? ( "zero" print )
  5 =? ( "five" print )
drop
```

### Error 3: Forward references

```r3
| ✗ INCORRECT
:main helper ;
:helper ... ;

| ✓ CORRECT
:helper ... ;
:main helper ;
```

### Error 4: Overflow in calculations

```r3
| ✗ CAN OVERFLOW
big_number 1000 * 1000000 /

| ✓ SAFE
big_number 1000 1000000 */
```

### Error 5: Assuming +1 increment

```r3
| ✗ INCORRECT (assumes +1)
'buffer @+ @+ @+    | Reads at offsets 0, 8, 16 (not 0,1,2)

| ✓ CORRECT for consecutive bytes
'buffer c@+ c@+ c@+  | Reads at offsets 0, 1, 2
```

---

## Key Differences Summary

| Concept | C | R3forth |
|---------|---|---------|
| Variables | `int x = 5;` | `#x 5` |
| Access value | `x` | `x` |
| Access address | `&x` | `'x` |
| Assignment | `x = 10;` | `10 'x !` |
| Increment | `x += 5;` | `5 'x +!` |
| If-else | `if {} else {}` | `condition? ( ; ) else_code` |
| For loop | `for(;;)` | `( 1? 1- ... )` |
| Arrays | `arr[i]` | `'arr i 3 << + @` |
| Structs | `node.field` | `node field_offset + @` |

---

## Resources and References

For more details about R3forth, consult the complete manual `r3forth-guide.md` which includes:
- Complete word dictionary
- Standard library details
- Advanced examples
- Design patterns

**Remember**: R3forth favors factoring code into small, single-purpose words rather than complex control structures.