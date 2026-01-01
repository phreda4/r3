# R3Forth Parse Library (parse.r3)

A comprehensive parsing library for R3Forth providing string-to-number conversion, fixed-point parsing, number validation, and pattern matching utilities.

## Overview

This library provides:
- **String to number conversion** (decimal, hexadecimal, binary)
- **Fixed-point parsing** (48.16 format)
- **Scientific notation** support (e notation)
- **Number validation** without conversion
- **Pattern matching** and scanning utilities

---

## Number Parsing

### Integer Parsing

- **`str>nro`** `( adr -- adr' nro )` - Parse integer (decimal/hex/binary)
  ```r3forth
  "123" str>nro    | Returns pointer after "123" and value 123
  "$FF" str>nro    | Hex: returns value 255
  "%1010" str>nro  | Binary: returns value 10
  "-42" str>nro    | Negative: returns -42
  ```
  - Supports prefixes:
    - `$` for hexadecimal (e.g., `$FF`, `$A3B`)
    - `%` for binary (e.g., `%101`, `%11001`)
    - No prefix for decimal
  - Handles negative numbers with `-` prefix
  - Optional `+` prefix for positive numbers
  - Stops at first non-digit character
  - Returns updated pointer and number

- **`?sint`** `( adr -- adr' nro )` - Parse signed integer (decimal only)
  ```r3forth
  "-123" ?sint  | Returns -123
  "+456" ?sint  | Returns 456
  ```
  - Decimal only (no hex/binary)
  - Handles sign explicitly

- **`?numero`** `( str -- 0 / str' nro 1 )` - Test and parse number
  ```r3forth
  "123abc" ?numero
  1? ( | success: stack has pointer and number
    drop .d .print
  ) drop
  ```
  - Returns 0 if not a valid number
  - Returns string pointer, number, and 1 if valid
  - Safe for validation before parsing

### Hexadecimal Parsing

- **`str$>nro`** `( adr -- adr' nro )` - Parse hexadecimal (no $ prefix needed)
  ```r3forth
  "FF00" str$>nro  | Returns 65280
  "a3b" str$>nro   | Case insensitive: returns 2619
  ```
  - Accepts 0-9, A-F, a-f
  - Stops at first non-hex character

### Binary Parsing

- **`str%>nro`** `( adr -- adr' nro )` - Parse binary (no % prefix needed)
  ```r3forth
  "10101" str%>nro  | Returns 21
  "11110000" str%>nro  | Returns 240
  ```
  - Accepts only 0 and 1
  - Stops at first non-binary digit

---

## Fixed-Point Parsing

Fixed-point numbers use 48.16 format (16 bits for fractional part = 1/65536 precision).

### Basic Fixed-Point

- **`?fnumero`** `( str -- 0 / str' fix 1 )` - Test and parse fixed-point
  ```r3forth
  "3.14" ?fnumero
  1? ( | success: stack has pointer and fixed-point value
    drop .f .print  | Display as decimal
  ) drop
  ```
  - Returns 0 if not a valid number
  - Returns string pointer, fixed-point value, and 1 if valid
  - Format: 48.16 (16 bits fractional)

- **`str>fix`** `( adr -- adr' fix )` - Parse fixed-point number
  ```r3forth
  "1.5" str>fix  | Returns 98304 (1.5 in 48.16 format)
  "-2.75" str>fix  | Returns -180224
  ```
  - Supports decimal point
  - Handles negative values

### Advanced Fixed-Point

- **`str>fnro`** `( adr -- adr fnro )` - Parse fixed-point with more precision
  ```r3forth
  "3.14159" str>fnro  | High precision parsing
  ```
  - Better precision than `str>fix`
  - Returns fixed-point in 48.16 format

- **`str>anro`** `( adr -- adr anro )` - Parse any number (integer or fixed)
  ```r3forth
  "42" str>anro    | Integer: returns 42 << 16
  "3.14" str>anro  | Fixed: returns fixed-point
  ```
  - Automatically detects format
  - Useful when format is unknown

### Scientific Notation

- **`getfenro`** `( adr -- adr fnro )` - Parse number with exponent (scientific)
  ```r3forth
  "1.5e3" getfenro   | Returns 1500 (1.5 × 10³)
  "2.5e-2" getfenro  | Returns 0.025 (2.5 × 10⁻²)
  ```
  - Supports `e` or `E` for exponent
  - Handles positive and negative exponents
  - Returns fixed-point result

---

## Number Validation

These functions test if a string is a valid number **without** parsing.

- **`isHex`** `( adr -- 3/0 )` - Test if hexadecimal
  ```r3forth
  "FF00" isHex 3 =? ( "Valid hex" .print ; )
  "GG00" isHex 0? ( "Invalid" .print ; )
  ```
  - Returns 3 if valid hex
  - Returns 0 if invalid

- **`isBin`** `( adr -- 2/0 )` - Test if binary
  ```r3forth
  "10101" isBin 2 =? ( "Valid binary" .print ; )
  "10201" isBin 0? ( "Invalid" .print ; )
  ```
  - Returns 2 if valid binary
  - Returns 0 if invalid

- **`isNro`** `( adr -- type/0 )` - Identify number type
  ```r3forth
  "123" isNro     | Returns 1 (decimal)
  "%101" isNro    | Returns 2 (binary)
  "$FF" isNro     | Returns 3 (hexadecimal)
  "3.14" isNro    | Returns 4 (fixed-point)
  "abc" isNro     | Returns 0 (not a number)
  ```
  - Returns: 1=decimal, 2=binary, 3=hex, 4=fixed-point, 0=invalid
  - Handles all formats including signs

---

## Pattern Matching and Scanning

### Pattern Matching

- **`scanp`** `( adr "pattern" -- adr'/0 )` - Scan for exact pattern
  ```r3forth
  "The quick brown fox" "quick" scanp
  0? ( "Not found" .print ; )
  "Found at: " .print
  ```
  - Returns pointer after pattern if found
  - Returns 0 if pattern not found
  - Case-sensitive exact match

- **`scann`** `( adr "pattern" -- adr' )` - Scan until pattern, then skip it
  ```r3forth
  "key:value" ":" scann  | Returns pointer to "value"
  ```
  - Finds first character of pattern
  - Then matches rest of pattern
  - Returns pointer after full pattern match
  - Returns 0 if not found

### Character Scanning

- **`scanc`** `( char adr -- adr'/0 )` - Scan for character
  ```r3forth
  '= "key=value" scanc  | Returns pointer before '='
  ```
  - Returns pointer before character if found
  - Returns 0 if not found

### Data Extraction

- **`scanstr`** `( adr 'buffer -- adr' )` - Copy string to buffer
  ```r3forth
  "Hello World" 'buffer scanstr
  | 'buffer now contains "Hello World\0"
  ```
  - Copies until control character (< 32)
  - Automatically null-terminates
  - Returns pointer after copied portion

- **`scannro`** `( adr 'var -- adr' )` - Parse number into variable
  ```r3forth
  "  123  rest" 'myvar scannro
  | myvar now contains 123
  ```
  - Automatically trims whitespace
  - Parses number
  - Stores in variable
  - Returns pointer after number

---

## Helper Functions

### Low-Level Parsing

- **`getnro`** `( adr -- adr' nro )` - Get number with auto-trim
  ```r3forth
  "  123  " getnro  | Skips leading spaces
  ```
  - Automatically trims whitespace
  - Handles signs
  - Decimal only

---

## Usage Examples

### Command Parser
```r3forth
:parse-command | "cmd arg1 arg2" --
  dup "set" scanp
  1? ( 
    drop
    'var1 scannro  | Parse first arg
    'var2 scannro  | Parse second arg
    drop
    "Variables set" .print
    ; 
  ) drop
  
  "help" scanp 1? ( drop show-help ; ) drop
  "Invalid command" .print ;

"set 42 100" parse-command
```

### Configuration File Parser
```r3forth
:parse-config-line | "key=value" --
  'keybuf scanstr  | Copy key
  "=" scanp 0? ( drop "Invalid format" .print ; )
  
  'valuebuf scanstr  | Copy value
  drop
  
  keybuf "width" = 1? ( 
    valuebuf str>nro drop 'screen-width !
  )
  keybuf "height" = 1? (
    valuebuf str>nro drop 'screen-height !
  )
  drop ;

"width=1920" parse-config-line
"height=1080" parse-config-line
```

### Calculator
```r3forth
:calculate | "123 + 456" --
  str>nro >r     | Parse first number
  trim           | Skip spaces
  c@+ >r         | Get operator
  str>nro drop   | Parse second number
  r> r>          | operator num1 num2
  
  '+' =? ( drop + ; )
  '-' =? ( drop - ; )
  '*' =? ( drop * ; )
  '/' =? ( drop / ; )
  drop 3drop 0 ;

"123 + 456" calculate  | Returns 579
```

### CSV Parser
```r3forth
#field1 * 64
#field2 * 64
#field3 * 64

:parse-csv-line | "val1,val2,val3" --
  'field1 scanstr
  "," scanp 0? ( drop "Invalid CSV" .print ; )
  
  'field2 scanstr
  "," scanp 0? ( drop "Invalid CSV" .print ; )
  
  'field3 scanstr
  drop
  
  field1 .print " | "
  field2 .print " | "
  field3 .print cr ;

"Alice,30,Engineer" parse-csv-line
```

### Number Format Detector
```r3forth
:show-number-type | "str" --
  dup isNro
  0 =? ( drop "Not a number" .print ; )
  1 =? ( drop "Decimal" .print ; )
  2 =? ( drop "Binary" .print ; )
  3 =? ( drop "Hexadecimal" .print ; )
  4 =? ( drop "Fixed-point" .print ; )
  drop "Unknown" .print ;

"$FF" show-number-type    | Output: "Hexadecimal"
"3.14" show-number-type   | Output: "Fixed-point"
```

### Expression Parser
```r3forth
:parse-expr | "x=42" --
  dup 'vname scanstr  | Copy variable name
  "=" scanp 0? ( drop "Invalid" .print ; )
  
  str>nro drop  | Parse value
  
  vname "x" = 1? ( drop 'x ! ; )
  vname "y" = 1? ( drop 'y ! ; )
  drop "Unknown variable" .print ;

"x=100" parse-expr
"y=200" parse-expr
```

### Scientific Calculator
```r3forth
:eval-scientific | "1.5e3" --
  getfenro
  .f .print  | Display as fixed-point
  " = "
  16 >> .d .print  | Display integer part
  ;

"1.5e3" eval-scientific   | Output: "1500.0000 = 1500"
"2.5e-1" eval-scientific  | Output: "0.2500 = 0"
```

### Range Parser
```r3forth
:parse-range | "10-50" -- min max
  str>nro >r    | Parse min
  "-" scanp 0? ( drop r> 0 ; )
  str>nro drop  | Parse max
  r> swap ;

"10-50" parse-range  | Returns 10 and 50
```

### Hex Color Parser
```r3forth
:parse-color | "#FF0080" -- r g b
  "#" scanp 0? ( drop 0 0 0 ; )
  
  2 'basen !  | Switch to hex mode
  str$>nro drop
  
  dup 16 >> $FF and      | Red
  over 8 >> $FF and      | Green  
  swap $FF and ;         | Blue

"#FF0080" parse-color  | Returns 255 0 128
```

### Token Counter
```r3forth
:count-tokens | "str" -- count
  0 swap | count str
  ( c@ 32 >?
    swap 1+ swap
    >>sp  | Skip to space
    trim  | Skip spaces
  ) drop ;

"one two three four" count-tokens  | Returns 4
```

---

## Best Practices

1. **Always check return values for validation functions**
   ```r3forth
   "input" ?numero
   0? ( drop "Invalid input" .print ; )
   | ... use parsed number ...
   ```

2. **Use appropriate parsing function**
   - `str>nro` - General integer parsing
   - `str>fix` - Fixed-point decimals
   - `str>anro` - Unknown format
   - `getfenro` - Scientific notation

3. **Handle whitespace**
   ```r3forth
   trim str>nro  | Skip leading spaces
   ```

4. **Use scanp for exact matches**
   ```r3forth
   "command args" "command" scanp
   1? ( | Pattern found, process args
   ) drop
   ```

5. **Store patterns in variables for reuse**
   ```r3forth
   #pattern "delimiter"
   input pattern scanp
   ```

---

## Format Specifications

### Number Formats

| Format | Example | Prefix | Notes |
|--------|---------|--------|-------|
| Decimal | `123`, `-42` | None | Base 10 |
| Hexadecimal | `$FF`, `$A3B` | `$` | Base 16, case-insensitive |
| Binary | `%101`, `%11001` | `%` | Base 2 |
| Fixed-point | `3.14`, `-2.5` | None | 48.16 format |
| Scientific | `1.5e3`, `2.5e-2` | None | With exponent |

### Sign Handling

- `+` prefix: Optional for positive numbers
- `-` prefix: Required for negative numbers
- Signs work with all formats except when using `str$>nro` or `str%>nro` directly

---

## Performance Notes

1. **Validation is faster than parsing**
   ```r3forth
   | Fast check
   input isNro 0? ( drop ; )
   
   | Then parse if needed
   input str>nro drop
   ```

2. **Direct format parsing is faster**
   ```r3forth
   | Faster if you know it's hex
   "FF" str$>nro
   
   | Slower (checks for prefix)
   "$FF" str>nro
   ```

3. **Reuse buffers**
   ```r3forth
   | Reuse same buffer for multiple scans
   input 'buffer scanstr
   process-buffer
   ```

---

## Common Patterns

### Safe Number Input
```r3forth
:safe-input | "str" -- n / 0
  dup isNro 0? ( drop 0 ; )
  str>nro drop ;
```

### Parse Pair
```r3forth
:parse-pair | "10,20" -- n1 n2
  str>nro >r
  "," scanp drop
  str>nro drop r> ;
```

### Extract Quoted String
```r3forth
:extract-quote | "text" -- "quoted"
  $22 scanc 1+  | Skip to opening quote
  dup
  $22 scanc     | Find closing quote
  over - ;      | Length
```

---

## Error Handling

Most parsing functions don't throw errors but return indicators:

```r3forth
| Check if parsing succeeded
input str>nro
over c@ 33 <? (  | Check if at end/whitespace
  | Success - entire string was number
) drop

| For validation functions
input ?numero
0? ( | Parsing failed
  "Invalid number" .print
) drop

| For pattern matching
input "pattern" scanp
0? ( | Pattern not found
  "Pattern not found" .print
) drop
```

---

## Notes

- **Fixed-point format:** 48.16 (16 fractional bits = 1/65536 precision)
- **Hexadecimal:** Case-insensitive (accepts A-F and a-f)
- **Binary:** Only accepts 0 and 1
- **Whitespace:** Most functions don't auto-trim (use `trim` first)
- **Return pointers:** Point to character after parsed content
- **Base variable:** Internal `basen` variable tracks current base
- **Thread safety:** Not thread-safe (uses shared variables)
- **Buffer overruns:** `scanstr` doesn't check buffer size - ensure sufficient space
- **Scientific notation:** Exponent can be positive or negative

---

## Integration Example

```r3forth
| Complete command-line parser
:parse-cmdline | "cmd arg1 arg2 ..." --
  trim
  
  | Extract command
  dup 'cmdbuf scanstr
  >>sp trim
  
  | Parse first argument
  dup isNro 1 =? (
    drop str>nro 'arg1 !
  ) drop
  
  | Parse second argument  
  >>sp trim
  dup isNro 1 =? (
    drop str>nro 'arg2 !
  ) drop
  
  drop
  
  | Execute command
  cmdbuf "add" = 1? ( 
    arg1 arg2 + "Result: %d" .print
  )
  drop ;
```