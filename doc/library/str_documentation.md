# R3 String Manipulation Library Documentation

## Overview

`str.r3` provides comprehensive string manipulation functions for R3, including copying, comparison, searching, parsing, and number conversion. It uses optimized algorithms for performance-critical operations and integrates with the R3 math library for numeric conversions.

## Dependencies
- `r3/lib/math.r3` - Mathematical functions for numeric conversions

## String Copying and Manipulation

### Basic Copying
```r3
strcpyl    | src dest -- new_dest     // Copy string, return end pointer
strcpy     | src dest --              // Copy string  
strcat     | src dest --              // Concatenate to existing string
strcpylnl  | src dest -- new_dest     // Copy until newline
strcpyln   | src dest --              // Copy until newline (no return)
```

**Examples:**
```r3
"Hello" buffer strcpy                 // Copy "Hello" to buffer
"World" buffer strcat                // buffer now contains "HelloWorld"
```

### Specialized Copying
```r3
copynom    | src dest --              // Copy until whitespace
copystr    | src dest --              // Copy until quote (")
strpath    | src dest --              // Copy path (until last /)
```

**Use Cases:**
- **copynom**: Extract tokens from text
- **copystr**: Parse quoted strings
- **strpath**: Extract directory from file path

**Examples:**
```r3
"filename.txt" buffer copynom         // Copies "filename.txt"
"\"Hello World\"" buffer copystr      // Copies "Hello World"
"/home/user/file.txt" buffer strpath  // Copies "/home/user/"
```

## Character Operations

### Case Conversion
```r3
toupp      | c -- C                  // Convert to uppercase
tolow      | c -- c                  // Convert to lowercase
```

**Examples:**
```r3
97 toupp                             // Returns 65 ('A')
65 tolow                             // Returns 97 ('a')
```

## String Length and Analysis

### Length Calculation
```r3
count      | str -- str count        // Get string length (optimized)
utf8count  | str -- str count        // Count UTF-8 characters
```

The `count` function uses an optimized algorithm that processes 8 bytes at a time, making it significantly faster than naive character-by-character counting.

**Examples:**
```r3
"Hello" count                        // Returns "Hello" 5
"Café" utf8count                     // Counts Unicode characters properly
```

## String Comparison

### Case-Sensitive Comparison
```r3
=          | str1 str2 -- 1/0        // Equal comparison (case insensitive)
cmpstr     | str1 str2 -- -1/0/1     // Compare strings (lexicographic)
```

### Case-Insensitive Comparison  
```r3
=s         | str1 str2 -- 1/0        // Equal comparison (case insensitive)
=w         | str1 str2 -- 1/0        // Word comparison (stops at whitespace)
```

**Examples:**
```r3
"Hello" "HELLO" =s                   // Returns 1 (equal, case insensitive)
"apple" "banana" cmpstr              // Returns -1 (apple < banana)
"test" "testing" =w                  // Returns 1 (word match)
```

### Pattern Matching
```r3
=pre       | str "prefix" -- str 1/0  // Check if string starts with prefix
=pos       | str "suffix" -- str 1/0  // Check if string ends with suffix  
=lpos      | end_ptr "suffix" -- str 1/0 // Check suffix from end pointer
```

**Examples:**
```r3
"filename.txt" ".txt" =pos           // Returns 1 (ends with .txt)
"hello" "he" =pre                    // Returns 1 (starts with he)
```

## String Searching

### Character Search
```r3
findchar   | str char -- addr/0      // Find character in string
```

### Substring Search
```r3
findstr    | str "pattern" -- addr/0 // Find substring (case sensitive)
findstri   | str "pattern" -- addr/0 // Find substring (case insensitive)
```

**Examples:**
```r3
"Hello World" 87 findchar            // Find 'W', returns pointer to "World"
"Hello World" "Wor" findstr          // Returns pointer to "World"
"Hello World" "wor" findstri         // Case insensitive search
```

## Number to String Conversion

### Global Buffer
```r3
#mbuff * 65                          // 65-byte conversion buffer
```

### Conversion Functions
```r3
.d         | value -- "string"       // Decimal conversion
.b         | value -- "string"       // Binary conversion  
.h         | value -- "string"       // Hexadecimal conversion
.o         | value -- "string"       // Octal conversion
.f         | fixed -- "string"       // Fixed-point conversion (4 decimals)
.f2        | fixed -- "string"       // Fixed-point conversion (2 decimals)
.f1        | fixed -- "string"       // Fixed-point conversion (1 decimal)
```

**Examples:**
```r3
255 .d                               // Returns "255"
255 .h                               // Returns "FF"  
255 .b                               // Returns "11111111"
1.5 .f                               // Returns "1.5000"
1.5 .f1                              // Returns "1.5"
```

### Formatting
```r3
.r.        | buffer digits --        // Right-align with spaces
```

## String Parsing and Trimming

### Whitespace Handling
```r3
trim       | str -- str'             // Skip leading whitespace
trimc      | char str -- str'        // Skip leading instances of character
trimcar    | str -- str' char        // Skip whitespace, return first char
trimstr    | str -- str'             // Skip to content inside quotes
```

### Line Processing
```r3
>>cr       | str -- str'             // Skip to after CR/LF
>>0        | str -- str'             // Skip to after null terminator
>>sp       | str -- str'             // Skip to next space
>>str      | str -- str'             // Skip to next quote
```

**Examples:**
```r3
"   Hello" trim                      // Returns pointer to "Hello"
"###data" 35 trimc                   // Skip '#' chars, returns "data"
```

### List Processing
```r3
l0count    | list -- count           // Count null-terminated strings in list
n>>0       | str n -- str'           // Skip n null-terminated strings
```

### Line Ending Normalization
```r3
only13     | str -- str              // Convert LF to CR, remove CR+LF sequences
```

## Advanced String Processing Examples

### Tokenization
```r3
:tokenize | "input" buffer -- count
    0 >r                             // Counter
    ( dup c@ 1?                      // While not end of string
        over >>sp                    // Find next space
        over over - dup 0 >?         // If token length > 0
        ( pick3 pick3 swap cmove     // Copy token
          r> 1+ >r                   // Increment counter
          pick2 0 swap c!            // Null terminate
        ) drop
        trim                         // Skip whitespace
    ) 2drop r> ;

| Usage:
"hello world test" token-buffer tokenize  // Returns 3
```

### Path Operations
```r3
:get-filename | "path" -- "filename"
    dup count + 1-                   // Start from end
    ( dup c@ 47 <>? 1- )            // Find last '/'
    1+ ;                             // Skip the '/'

:get-extension | "filename" -- "ext"  
    dup count + 1-                   // Start from end
    ( dup c@ 46 <>? 1- )            // Find last '.'
    1+ ;                             // Skip the '.'

| Usage:
"/path/to/file.txt" get-filename    // Returns "file.txt"
"document.pdf" get-extension        // Returns "pdf"
```

### String Builder Pattern
```r3
:string-builder | -- builder
    here ;

:sb-add | builder "text" -- builder
    over swap strcpy ;

:sb-add-num | builder n -- builder  
    over swap .d strcpy ;

:sb-finish | builder -- "result"
    0 over c! ;

| Usage:
string-builder
"Result: " sb-add
42 sb-add-num
sb-finish                           // Returns "Result: 42"
```

### Configuration Parser
```r3
:parse-key-value | "line" -- "key" "value"
    dup 61 findchar                 // Find '='
    dup 0 over c!                   // Null terminate key
    1+ trim ;                       // Return value part

:parse-config | "config" -- 
    ( >>cr dup c@ 1?                // For each line
        dup 35 findchar             // Check for comment '#'
        0? ( parse-key-value process-setting )
        drop
    ) drop ;

| Usage:
"key1=value1\nkey2=value2" parse-config
```

## Performance Optimization

### Fast String Length
The `count` function uses a sophisticated bit manipulation technique that processes 8 bytes simultaneously:

```r3
count | s1 -- s1 cnt
    0 over ( @+ dup $0101010101010101 -
        swap nand $8080808080808080 nand? 
        drop swap 8 + swap )
    // ... bit manipulation to find exact position
```

This provides significant speed improvements over character-by-character scanning.

### Memory Efficiency
- **Shared Buffer**: Number conversion functions use a single shared buffer
- **In-Place Operations**: Many functions modify strings in-place when possible
- **Null Termination**: Consistent null termination allows safe string operations

## Common Patterns

### String Validation
```r3
:is-numeric | "str" -- flag
    1 swap ( c@+ 1?
        dup 48 < over 57 > or? ( 2drop 0 nip ; )
        drop
    ) drop ;

:is-email | "str" -- flag
    dup 64 findchar              // Must contain @
    dup 0? ( 2drop 0 ; )
    46 findchar                  // Must contain . after @
    0 <> ;
```

### String Formatting
```r3
:format-bytes | bytes -- "formatted"
    1024 /? ( .d " KB" string-cat )
    1048576 /? ( .d " MB" string-cat )
    .d " bytes" string-cat ;
```

### File Extension Matching
```r3
:is-image-file | "filename" -- flag
    ".jpg" =pos? ( 1 ; )
    ".png" =pos? ( 1 ; ) 
    ".gif" =pos? ( 1 ; )
    0 ;
```

## Best Practices

1. **Buffer Management**: Use adequate buffer sizes for string operations
2. **Null Termination**: Ensure strings are properly null-terminated
3. **Case Handling**: Use appropriate case-sensitive/insensitive functions
4. **Performance**: Use optimized functions like `count` for better performance
5. **Memory Safety**: Check for null pointers when using search functions

## Integration with Other Libraries

This string library integrates seamlessly with:
- **Memory Library**: For dynamic string building
- **File I/O**: For reading and processing text files
- **Parser Libraries**: For tokenization and parsing tasks
- **User Interface**: For text display and input processing

The library provides a solid foundation for text processing in R3 applications, with both high-level convenience functions and low-level optimized operations for performance-critical code.