# R3 Parsing Library Documentation

## Overview

`parse.r3` provides comprehensive text parsing capabilities for R3, including number parsing in multiple formats, string scanning, and pattern matching. It supports decimal, hexadecimal, binary, and fixed-point number formats with robust error handling.

## Dependencies
- `r3/lib/math.r3` - Mathematical operations for number conversion
- `r3/lib/str.r3` - String manipulation functions

## Number Parsing System

### Global Variables
```r3
#basen        // Current number base (2, 10, 16)
#parte0       // Integer part for fixed-point parsing
#f            // Fractional part storage
#e            // Exponent storage
```

## Integer Parsing

### Basic Integer Parsing
```r3
str>nro    | str -- str' number        // Parse integer (supports +, -, $hex, %bin)
?sint      | str -- str' number        // Parse signed integer (decimal only)
getnro     | str -- str' number        // Parse with whitespace trimming
```

**Supported Formats:**
- **Decimal**: `123`, `-456`, `+789`
- **Hexadecimal**: `$FF`, `$1A2B` 
- **Binary**: `%1010`, `%11110000`

**Examples:**
```r3
"123" str>nro                        // Returns pointer + 123
"$FF" str>nro                        // Returns pointer + 255
"%1010" str>nro                      // Returns pointer + 10
"-456" str>nro                       // Returns pointer + -456
```

### Specialized Hex/Binary Parsing
```r3
str$>nro   | str -- str' number        // Parse hexadecimal digits
str%>nro   | str -- str' number        // Parse binary digits
```

### Number Validation
```r3
?numero    | str -- 0 / str' nro 1     // Test if string starts with number
isNro      | str -- type/0             // Identify number type (1-4)
isHex      | str -- 3/0               // Test for hexadecimal format
isBin      | str -- 2/0               // Test for binary format
```

**Number Types:**
- `1` - Decimal integer
- `2` - Binary number  
- `3` - Hexadecimal number
- `4` - Fixed-point number
- `0` - Not a number

## Fixed-Point Parsing

### Basic Fixed-Point
```r3
?fnumero   | str -- 0 / str' fix 1     // Parse fixed-point number
str>fix    | str -- str' fix           // Parse fixed-point (no validation)
str>fnro   | str -- str' fix           // Parse with fractional support
```

**Supported Formats:**
- `1.5` - Simple decimal
- `-3.14159` - Negative decimal
- `.5` - Leading decimal point
- `42.` - Trailing decimal point

**Examples:**
```r3
"1.5" ?fnumero                       // Returns address + 98304 + 1 (1.5 in 16.16)
"3.14159" str>fix                    // Converts to fixed-point format
```

### Advanced Fixed-Point
```r3
str>anro   | str -- str' number        // Auto-detect integer or fixed-point
getfenro   | str -- str' fix           // Parse with scientific notation (e/E)
```

**Scientific Notation Support:**
```r3
"1.5e2" getfenro                     // Parses 1.5 × 10² = 150.0
"2.5e-1" getfenro                    // Parses 2.5 × 10⁻¹ = 0.25
```

## String Scanning and Pattern Matching

### Pattern Scanning
```r3
scanp      | str "pattern" -- str'/0   // Scan for exact pattern match
scann      | str "pattern" -- str'     // Scan to pattern, skip pattern
scanc      | char str -- str'/0        // Scan for character
```

**Examples:**
```r3
"Hello World" "Wor" scanp            // Returns pointer to "World" or 0
"data:value" ":" scanc               // Returns pointer to "value"
```

### Data Extraction
```r3
scanstr    | str buffer -- str'       // Extract string to buffer
scannro    | str 'variable -- str'    // Extract number to variable
```

**Examples:**
```r3
:parse-assignment | "var=123" --
    dup "=" scanc                    // Find '='
    dup 0? ( 2drop "Invalid format" print ; )
    swap 'var-name scanstr           // Extract variable name  
    'var-value scannro ;             // Extract value
```

## Complete Parsing Examples

### Configuration File Parser
```r3
#config-width 800
#config-height 600
#config-fullscreen 0

:parse-config-line | "line" --
    trim                             // Remove leading whitespace
    dup c@ 35 =? ( 2drop ; )        // Skip comments (#)
    dup c@ 0? ( drop ; )            // Skip empty lines
    
    "width=" scanp? ( 'config-width scannro drop ; )
    "height=" scanp? ( 'config-height scannro drop ; )  
    "fullscreen=" scanp? ( 'config-fullscreen scannro drop ; )
    drop ;

:load-config | "filename" --
    fload                            // Load file content
    ( >>cr dup c@ 1? parse-config-line ) drop ;

| Usage:
"config.txt" load-config
```

### Mathematical Expression Evaluator
```r3
:eval-number | "expr" -- expr' result
    str>anro ;                       // Handle integers and decimals

:eval-factor | "expr" -- expr' result  
    trim
    dup c@ 40 =? ( 1+ eval-expr ")" scanc ; )  // Handle parentheses
    eval-number ;

:eval-term | "expr" -- expr' result
    eval-factor
    ( trim dup c@
        42 =? ( 1+ eval-factor *. )   // Multiplication  
        47 =? ( 1+ eval-factor /. )   // Division
        drop )
    ;

:eval-expr | "expr" -- expr' result
    eval-term  
    ( trim dup c@
        43 =? ( 1+ eval-term + )      // Addition
        45 =? ( 1+ eval-term - )      // Subtraction  
        drop )
    ;

| Usage:
"3.5 + 2 * 4" eval-expr drop        // Returns 11.5
```

### CSV Parser
```r3
#csv-buffer * 1024
#field-count

:parse-csv-field | str buffer -- str' 
    swap dup c@ 34 =? ( 1+ swap       // Handle quoted fields
        ( c@+ 34 <>? rot c!+ swap ) 2drop
        c@+ drop                      // Skip closing quote
    ; )
    swap                              // Handle unquoted fields
    ( c@+ dup 44 =? ( 2drop 0 swap c!+ ; )  // Comma delimiter
      dup 10 =? ( 2drop 0 swap c!+ ; )      // Newline
      dup 13 =? ( 2drop 0 swap c!+ ; )      // Carriage return
      0? ( 2drop 0 swap c!+ ; )             // End of string
      rot c!+ swap ) 
    drop 0 swap c!+ ;

:parse-csv-line | "line" -- field_count
    0 'field-count !
    'csv-buffer
    ( over c@ 1?                     // While source has data
        parse-csv-field               // Parse one field
        >>0                          // Skip to next field
        field-count 1+ 'field-count !
    ) 2drop
    field-count ;

| Usage:  
"John,25,Engineer" parse-csv-line    // Returns 3 fields
```

### URL Parser
```r3
#url-protocol * 32
#url-host * 128  
#url-port
#url-path * 256

:parse-url | "url" --
    trim
    
    | Extract protocol
    "://" scann 
    0? ( "Invalid URL" print ; )
    swap 'url-protocol scanstr
    
    | Extract host and port
    "/" scanc 
    dup 0? ( 'url-host scanstr 80 'url-port ! ; )
    swap ":" scanc
    dup 0? ( 'url-host scanstr 80 'url-port ! )
    ( swap 'url-host scanstr 'url-port scannro )
    
    | Extract path  
    'url-path scanstr ;

| Usage:
"https://example.com:8080/path/to/file" parse-url
```

## Performance Optimizations

### Number Parsing Speed
The library uses several optimizations:
- **Single-pass parsing**: Numbers parsed in one scan
- **Base detection**: Automatic format detection without backtracking
- **Minimal memory allocation**: Uses fixed buffers where possible

### Error Handling Strategy
- **Graceful degradation**: Invalid input returns 0 or safe defaults
- **Position tracking**: Returns updated string position for continued parsing
- **Type validation**: Separate validation functions for pre-checking

## Integration Patterns

### With Memory System
```r3
:parse-to-memory | "data" --
    mark                             // Save memory position
    ( >>cr dup c@ 1?                 // For each line
        str>anro ,                   // Parse and store number
    ) drop
    empty ;                          // Restore memory
```

### With String System
```r3
:format-parsed | number --
    dup isNro
    1 =? ( drop .d ; )              // Format as decimal
    3 =? ( drop "$" swap .h string-cat ; )  // Format as hex
    4 =? ( drop .f ; )              // Format as fixed-point
    drop "Invalid" ;
```

## Error Handling Best Practices

1. **Check return values**: Always validate parsing results
2. **Handle edge cases**: Empty strings, malformed input
3. **Provide fallbacks**: Default values for invalid input
4. **Position tracking**: Use returned positions for error reporting
5. **Type validation**: Use validation functions before parsing

## Common Parsing Patterns

### State Machine Parser
```r3
#parse-state 0

:parse-state-0 | char -- next_state
    48 57 between? ( 1 'parse-state ! ; )  // Digit -> number state
    65 90 between? ( 2 'parse-state ! ; )  // Letter -> identifier state
    0 ;

:parse-char | char --
    parse-state
    0 =? ( parse-state-0 )
    1 =? ( parse-state-1 )  
    2 =? ( parse-state-2 )
    drop ;
```

### Recursive Descent Parser
```r3
:parse-expression | str -- str' value
    parse-term
    ( trim dup c@ 43 =? ( 1+ parse-term + ) drop ) ;

:parse-term | str -- str' value  
    parse-factor
    ( trim dup c@ 42 =? ( 1+ parse-factor *. ) drop ) ;

:parse-factor | str -- str' value
    trim dup c@ 40 =? ( 1+ parse-expression ")" scanc ; )
    str>anro ;
```

This parsing library provides a robust foundation for text processing in R3, supporting everything from simple number conversion to complex structured data parsing with good performance and error handling characteristics.