# R3Forth String Library (str.r3)

A comprehensive string manipulation library for R3Forth providing copying, comparison, searching, conversion, and UTF-8 support.

## Overview

This library provides efficient string operations for null-terminated strings (C-style). All strings in R3Forth end with byte 0.

**Key features:**
- String copying and concatenation
- Case-insensitive comparison
- String searching
- Number to string conversion (decimal, binary, hex, octal, fixed-point)
- UTF-8 character counting and manipulation
- String trimming and parsing utilities

---

## String Copying

### Basic Copying

- **`strcpyl`** `( src dst -- ndst )` - Copy string and return pointer to end
  ```r3forth
  "Hello" here strcpyl
  " World" swap strcpy  | Concatenate
  ```

- **`strcpy`** `( src dst -- )` - Copy string
  ```r3forth
  "Source" 'buffer strcpy
  ```

- **`strcat`** `( src dst -- )` - Concatenate string to existing string
  ```r3forth
  "Hello" 'buffer strcpy
  " World" 'buffer strcat  | buffer now contains "Hello World"
  ```

### Special Copying

- **`strcpylnl`** `( src dst -- ndst )` - Copy until newline (10 or 13)
  ```r3forth
  "Line1
  Line2" here strcpylnl  | Copies only "Line1"
  ```

- **`strcpyln`** `( src dst -- )` - Copy until newline (drops return pointer)

- **`copynom`** `( src dst -- )` - Copy until space (non-whitespace only)
  ```r3forth
  "word rest" 'buffer copynom  | buffer = "word"
  ```

- **`copystr`** `( src dst -- )` - Copy until double quote (")
  ```r3forth
  "text""more" 'buffer copystr  | buffer = "text"
  ```

- **`strpath`** `( src dst -- )` - Copy path only (up to last /)
  ```r3forth
  "/path/to/file.txt" 'buffer strpath  | buffer = "/path/to"
  ```

---

## Character Case Conversion

- **`toupp`** `( c -- C )` - Convert character to uppercase
  ```r3forth
  97 toupp  | Returns 65 ('a' -> 'A')
  ```

- **`tolow`** `( C -- c )` - Convert character to lowercase
  ```r3forth
  65 tolow  | Returns 97 ('A' -> 'a')
  ```

---

## String Length

- **`count`** `( str -- str cnt )` - Get string length
  ```r3forth
  "Hello" count  | Returns "Hello" 5
  ```
  - Uses optimized 8-byte scanning algorithm
  - Leaves string pointer unchanged

---

## UTF-8 Support

### UTF-8 Character Counting

- **`utf8count`** `( str -- str count )` - Count UTF-8 characters (not bytes)
  ```r3forth
  "Hola: 你好" utf8count  | Returns string and character count
  ```
  - Correctly handles multi-byte UTF-8 sequences
  - 1-byte: ASCII (0x00-0x7F)
  - 2-byte: 0xC0-0xDF
  - 3-byte: 0xE0-0xEF
  - 4-byte: 0xF0-0xF7

### UTF-8 Manipulation

- **`utf8ncpy`** `( src dst cnt -- dst )` - Copy n UTF-8 characters
  ```r3forth
  "Hello世界" 'buffer 3 utf8ncpy  | Copies 3 chars: "Hel"
  ```
  - Respects UTF-8 boundaries
  - Won't split multi-byte characters

- **`utf8bytes`** `( str cnt -- str bytes )` - Get byte length of n UTF-8 characters
  ```r3forth
  "Hello世界" 6 utf8bytes  | Returns byte count for 6 chars
  ```
  - Useful for calculating buffer sizes

---

## String Comparison

### Exact Comparison

- **`=`** `( s1 s2 -- 1/0 )` - Case-insensitive equality
  ```r3forth
  "Hello" "HELLO" = 1? ( "Equal" print )
  ```
  - Compares entire strings
  - Returns 1 if equal, 0 if different

- **`cmpstr`** `( a b -- n )` - Lexicographic comparison
  ```r3forth
  "apple" "banana" cmpstr
  | Returns: negative if a<b, 0 if equal, positive if a>b
  ```
  - Case-sensitive
  - Returns difference value

### Word Comparison

- **`=s`** `( s1 s2 -- 1/0 )` - Compare until space (case-insensitive)
  ```r3forth
  "word rest" "WORD other" =s  | Returns 1
  ```
  - Stops at space or control characters
  - Useful for parsing commands

- **`=w`** `( s1 s2 -- 1/0 )` - Word equality (case-insensitive)
  ```r3forth
  "Hello" "hello " =w  | Returns 1
  ```

### Prefix and Suffix

- **`=pre`** `( str "prefix" -- str 1/0 )` - Check if string starts with prefix
  ```r3forth
  "filename.txt" ".txt" =pre 0? ( "No match" print ) 
  ```
  - Case-insensitive
  - Preserves original string pointer

- **`=pos`** `( str "suffix" -- str 1/0 )` - Check if string ends with suffix
  ```r3forth
  "document.pdf" ".pdf" =pos 1? ( "PDF file" print )
  ```
  - Case-sensitive
  - Checks end of string

- **`=lpos`** `( lstr "suffix" -- str 1/0 )` - Check suffix from last address
  ```r3forth
  | lstr points to last byte of string
  lastaddr ".txt" =lpos
  ```

---

## String Searching

### Character Search

- **`findchar`** `( str char -- adr'/0 )` - Find first occurrence of character
  ```r3forth
  "Hello World" 'W findchar  | Returns pointer to 'W'
  0? ( "Not found" print )
  ```
  - Returns 0 if not found
  - Returns pointer to character if found

### Substring Search

- **`findstr`** `( str "text" -- adr'/0 )` - Find substring (case-sensitive)
  ```r3forth
  "The quick brown fox" "quick" findstr
  0? ( "Not found" print )
  FNAME print  | Print from match point
  ```

- **`findstri`** `( str "text" -- adr'/0 )` - Find substring (case-insensitive)
  ```r3forth
  "Hello World" "WORLD" findstri
  0? ( "Not found" print ; )
  "Found!" print
  ```

---

## Number to String Conversion

### Integer Formats

- **`.d`** `( val -- str )` - Convert to decimal string
  ```r3forth
  42 .d print  | Output: "42"
  -100 .d print  | Output: "-100"
  ```
  - Handles full 64-bit signed integers
  - Minimum value: "-9223372036854775808"

- **`.b`** `( bin -- str )` - Convert to binary string
  ```r3forth
  5 .b print  | Output: "101"
  ```

- **`.h`** `( hex -- str )` - Convert to hexadecimal string
  ```r3forth
  255 .h print  | Output: "ff"
  ```
  - Lowercase letters

- **`.o`** `( oct -- str )` - Convert to octal string
  ```r3forth
  64 .o print  | Output: "100"
  ```

### Fixed-Point Formats

Fixed-point numbers use 16.16 format (16 bits integer, 16 bits fractional).

- **`.f`** `( fix -- str )` - Convert fixed-point to decimal (4 decimals)
  ```r3forth
  65536 .f print  | Output: "1.0000"
  98304 .f print  | Output: "1.5000"
  ```
  - Shows 4 decimal places

- **`.f2`** `( fix -- str )` - Convert to decimal (2 decimals)
  ```r3forth
  98304 .f2 print  | Output: "1.50"
  ```

- **`.f1`** `( fix -- str )` - Convert to decimal (1 decimal)
  ```r3forth
  98304 .f1 print  | Output: "1.5"
  ```

### Formatting

- **`.r.`** `( base nro -- base )` - Right-align with spaces
  ```r3forth
  'buffer 42 .d .r. 10 .r.  | Pad to 10 chars wide
  ```
  - Adds spaces on the left
  - Used for column alignment

---

## String Trimming and Parsing

### Whitespace Trimming

- **`trim`** `( str -- str' )` - Skip leading whitespace and control chars
  ```r3forth
  "  Hello" trim  | Returns pointer to "Hello"
  ```
  - Skips chars < 33 (space and control)

- **`trimc`** `( char str -- str' )` - Skip leading specific character
  ```r3forth
  $2f "/path/file" trimc  | Skip leading slashes $2f = '/ 
  ```

- **`trimcar`** `( str -- str' c )` - Skip whitespace and return first char
  ```r3forth
  "  A" trimcar  | Returns pointer to "A" and character 65
  ```

- **`trimstr`** `( str -- str' )` - Skip to content inside quotes
  ```r3forth
  """text"" more" trimstr  | Returns pointer to "text"
  ```

### Line Parsing

- **`>>cr`** `( str -- str' )` - Skip to newline (CR or LF)
  ```r3forth
  "Line1
  Line2" >>cr  | Returns pointer to cr
  ```

- **`>>0`** `( str -- str' )` - Skip to next null terminator
  ```r3forth
  #list "word1" "word2" 0
  'list >>0  | Skip past first word
  ```

- **`l0count`** `( list -- cnt )` - Count null-separated strings
  ```r3forth
  #list "word1" "word2" "word3" 0
  'list l0count  | Returns 3
  ```

- **`n>>0`** `( str n -- str' )` - Skip n null-terminated strings
  ```r3forth
  'list 2 n>>0  | Skip 2 strings
  ```

### Special Parsing

- **`only13`** `( str -- str )` - Replace LF (10) with CR (13)
  ```r3forth
  "Line1
  Line2" here strcpy
  here only13  | Converts \n to \r
  ```
  - Normalizes line endings
  - Modifies string in place

- **`>>sp`** `( str -- str' )` - Skip to next space
  ```r3forth
  "word rest" >>sp  | Returns pointer to " rest"
  ```

- **`>>str`** `( str -- str' )` - Skip to next unescaped quote
  ```r3forth
  """text"" more" >>str  | Skip to closing quote
  ```

---

## Usage Examples

### String Concatenation
```r3forth
#buffer * 256

:buildpath | "dir" "file" -- 'buffer
  'buffer strcpy
  "/" 'buffer strcat
  'buffer strcat
  'buffer ;

"home" "document.txt" buildpath print
| Output: "home/document.txt"
```

### Parse Command Line
```r3forth
:parse-command | "cmd args" --
  'buffer copynom  | Extract command
  'buffer "quit" = 1? ( drop "Exiting" print ; )
  'buffer "help" = 1? ( drop show-help ; )
  drop
  "Unknown command" print ;

"help parameters" parse-command
```

### File Extension Check
```r3forth
:is-source | "filename" -- 1/0
  dup ".r3" =pos 1? ( nip ; )
  dup ".4th" =pos 1? ( nip ; )
  drop 0 ;

"program.r3" is-source 1? ( "Source file" print )
```

### Number Formatting
```r3forth
:print-table
  0 ( 10 <?
    dup .d .r. 5 .r. "| " .print
    dup dup * .d .r. 8 .r. .cr
    1+ ) drop ;

| Output:
|    0 |       0
|    1 |       1
|    2 |       4
|  ...
```

### UTF-8 Text Processing
```r3forth
:truncate-utf8 | "text" maxchars -- 'buffer
  'buffer swap utf8ncpy
  'buffer ;

"Hello 世界 World" 7 truncate-utf8 .print
| Output: "Hello 世"
```

### Path Manipulation
```r3forth
:get-filename | "path/to/file.txt" -- "file.txt"
  dup count + | Get end of string
  ( 1- dup c@ $2f <>? drop ) | $2f = '/
  1+ ;

"/home/user/doc.txt" get-filename .print
| Output: "doc.txt"
```

### Parse CSV Line
```r3forth
:next-field | str -- str' field-start
  dup 
  ( c@+ 1?
    $2c =? ( drop 1- 0 over c! 1+ swap ; ) | $2c = ',
    drop
  ) drop ;

"field1,field2,field3"
next-field .print  | "field1"
next-field .print  | "field2"
next-field .print  | "field3"
```

### Case-Insensitive Menu
```r3forth
:check-command | "input" --
  dup "START" =s 1? ( drop start-game ; )
  dup "QUIT" =s 1? ( drop quit-game ; )
  dup "HELP" =s 1? ( drop show-help ; )
  drop "Unknown command" print ;
```

---

## Best Practices

1. **Always allocate sufficient buffer space**
   ```r3forth
   #buffer * 256  | 256 bytes for string operations
   ```

2. **Check search results before use**
   ```r3forth
   "text" "pattern" findstr
   0? ( "Not found" print drop ; )
   | ... use result ...
   ```

3. **Use appropriate comparison function**
   - `=` - Full string, case-insensitive
   - `cmpstr` - Sorting/ordering
   - `=s` - Commands/words
   - `=pre` - File extensions/prefixes

4. **Preserve original string when needed**
   ```r3forth
   "prefix" =pre  .. | "=pre" Keep original pointer
   dup "this" = ..   | "=" use both param
   ```

5. **Handle UTF-8 carefully**
   ```r3forth
   | Use utf8count instead of count for display width
   "文本" utf8count  | 2 characters
   "文本" count      | 6 bytes
   ```

6. **Use strcpyl for chaining**
   ```r3forth
   "Part1" 'buffer strcpyl
   "Part2" swap strcpyl
   "Part3" swap strcpy
   ```

---

## Performance Notes

1. **`count` is optimized** - Uses 8-byte scanning for speed
2. **Case conversion** - Uses bitwise operations (very fast)
3. **UTF-8 counting** - Linear scan, proportional to string length
4. **String search** - Naive algorithm, O(n*m) worst case
5. **Number conversion** - Uses internal buffer, no allocation

---

## Common Patterns

### Build Formatted String
```r3forth
:format-info | n1 n2 -- 'buffer
  "Values: " 'buffer strcpy
  .d 'buffer strcat
  " and " 'buffer strcat
  .d 'buffer strcat
  'buffer ;
```

---

## Notes

- **Null-terminated:** All strings must end with 0
- **Case conversion:** Works for ASCII only (A-Z, a-z)
- **UTF-8:** Full support for multi-byte characters
- **Buffer reuse:** `.d`, `.h`, `.b`, `.o`, `.f` share internal buffer
- **No allocation:** All functions work with provided buffers
- **Thread safety:** Not thread-safe (uses shared buffer for conversions)
- **Encoding:** UTF-8 for all text, null-terminated C-style strings