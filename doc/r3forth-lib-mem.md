# R3Forth Memory Library (mem.r3)

A comprehensive memory management library for R3Forth providing dynamic memory allocation, data serialization, string formatting, and memory stack management.

## Overview

This library provides:
- **Dynamic memory allocation** with `here` pointer
- **Data serialization** to memory (comma operators)
- **Memory stack** for save/restore operations
- **String formatting** with printf-style functions
- **Memory alignment** utilities

---

## Memory Pointer

### The `here` Pointer

- **`here`** - Global variable pointing to next free memory location
  ```r3forth
  here   | Get current free memory address
  ```
  - Automatically advanced by comma operators
  - Use for building data structures dynamically
  - Can be saved/restored with `mark`/`empty`

---

## Data Serialization (Comma Operators)

These functions append data to memory at `here` and advance the pointer.

### Basic Data Types

- **`,`** `( value -- )` - Append 32-bit value (4 bytes)
  ```r3forth
  42 ,  | Store 32-bit integer
  ```

- **`,c`** `( byte -- )` - Append byte (1 byte)
  ```r3forth
  65 ,c  | Store 'A'
  ```

- **`,q`** `( qword -- )` - Append quad-word (8 bytes)
  ```r3forth
  value ,q
  ```

- **`,w`** `( word -- )` - Append word (2 bytes)
  ```r3forth
  1000 ,w
  ```

### String Serialization

- **`,s`** `( "str" -- )` - Append counted string with null terminator
  ```r3forth
  "Hello" ,s  | Stores "Hello\0"
  ```

- **`,word`** `( "str" -- )` - Append word (until space) with null terminator
  ```r3forth
  "word rest" ,word  | Stores "word\0"
  ```

- **`,line`** `( "str" -- )` - Append line (until CR/LF)
  ```r3forth
  "First line
  Second" ,line  | Stores "First line"
  ```

### Number to String Serialization

- **`,d`** `( n -- )` - Append decimal number as string
  ```r3forth
  42 ,d  | Appends "42" (the string, not the number)
  ```

- **`,2d`** `( n -- )` - Append decimal with leading zero if needed
  ```r3forth
  5 ,2d  | Appends "05"
  23 ,2d | Appends "23"
  ```

- **`,h`** `( n -- )` - Append hexadecimal string
  ```r3forth
  255 ,h  | Appends "ff"
  ```

- **`,b`** `( n -- )` - Append binary string
  ```r3forth
  5 ,b  | Appends "101"
  ```

- **`,o`** `( n -- )` - Append octal string
  ```r3forth
  64 ,o  | Appends "100"
  ```

- **`,f`** `( fix -- )` - Append fixed-point as decimal string
  ```r3forth
  65536 ,f  | Appends "1.0000"
  ```

### Floating Point Conversion

- **`,ifp`** `( int -- )` - Convert integer to float32 and append
  ```r3forth
  42 ,ifp  | Stores as IEEE 754 float
  ```

- **`,ffp`** `( fix -- )` - Convert fixed-point to float32 and append
  ```r3forth
  65536 ,ffp  | 1.0 in fixed-point -> float32
  ```

### Special Characters

- **`,cr`** - Append carriage return (13)
- **`,eol`** - Append null terminator (0)
- **`,sp`** - Append space (32)
- **`,nl`** - Append newline (CR+LF: 13,10)
  ```r3forth
  "Line 1" ,s ,nl
  "Line 2" ,s ,eol
  ```

- **`,nsp`** `( n -- )` - Append n spaces
  ```r3forth
  10 ,nsp  | Append 10 spaces
  ```

---

## Memory Alignment

Align memory pointer to specific boundaries for efficient access.

- **`align32`** `( mem -- mem' )` - Align to 32-byte boundary
  ```r3forth
  here align32 'here !
  ```

- **`align16`** `( mem -- mem' )` - Align to 16-byte boundary

- **`align8`** `( mem -- mem' )` - Align to 8-byte boundary
  ```r3forth
  here align8 'here !  | Align for 64-bit values
  ```

---

## Memory Stack

The library maintains a stack of memory positions for save/restore operations.

### Stack Operations

- **`mark`** - Save current `here` position
  ```r3forth
  mark
  | ... build temporary data ...
  empty  | Restore here pointer
  ```

- **`empty`** - Restore `here` to last marked position
  ```r3forth
  mark
  "Temporary" ,s
  empty  | Discard temporary data
  ```
  - Returns to initial memory state if no marks exist

### Memory Persistence

- **`savemem`** `( "filename" -- )` - Save marked memory block to file
  ```r3forth
  mark
  "data" ,s
  42 ,
  "output.bin" savemem
  ```
  - Saves from last mark to current `here`

- **`sizemem`** `( -- size )` - Get size of current memory block
  ```r3forth
  mark
  "test" ,s
  sizemem  | Returns 5 (4 chars + null)
  ```

- **`memsize`** `( -- addr size )` - Get marked memory block address and size
  ```r3forth
  mark
  100 ,
  memsize  | Returns start address and byte count
  ```

### Incremental Save

- **`savememinc`** `( "filename" -- )` - Append memory block to file
  ```r3forth
  mark
  "First chunk" ,s
  "log.txt" savememinc
  
  mark
  "Second chunk" ,s
  "log.txt" savememinc  | Appends to file
  ```
  - First call creates/overwrites file
  - Subsequent calls append

### Memory Operations

- **`cpymem`** `( 'dest -- )` - Copy marked memory block to destination
  ```r3forth
  mark
  "Source data" ,s
  'buffer cpymem  | Copy to buffer
  ```

- **`appendmem`** `( "filename" -- )` - Append marked memory to file
  ```r3forth
  mark
  "Additional data" ,s
  "file.dat" appendmem
  ```

---

## String Formatting

Printf-style formatting with `sprint` family functions.

### Format Specifiers

| Specifier | Type | Example |
|-----------|------|---------|
| `%d` | Decimal integer | `42 "%d" sprint` → "42" |
| `%h` | Hexadecimal | `255 "%h" sprint` → "ff" |
| `%b` | Binary | `5 "%b" sprint` → "101" |
| `%o` | Octal | `64 "%o" sprint` → "100" |
| `%f` | Fixed-point | `65536 "%f" sprint` → "1.0000" |
| `%s` | String | `"text" "%s" sprint` → "text" |
| `%w` | Word (until space) | `"word rest" "%w" sprint` → "word" |
| `%l` | Line (until newline) | `"line\nmore" "%l" sprint` → "line" |
| `%k` | Character | `65 "%k" sprint` → "A" |
| `%i` | Integer part (fixed) | `98304 "%i" sprint` → "1" |
| `%j` | Fractional part (fixed) | `98304 "%j" sprint` → "32768" |
| `%.` | Newline (CR) | `"text%." sprint` → "text\r" |
| `%%` | Literal % | `"%%" sprint` → "%" |

### Formatting Functions

- **`,print`** `( ... "format" -- )` - Format to memory at `here`
  ```r3forth
  mark
  42 100 "x=%d y=%d" ,print
  ,eol
  ```

- **`sprint`** `( ... "format" -- str )` - Format to temporary buffer
  ```r3forth
  42 "Value: %d" sprint
  | Returns pointer to formatted string
  ```
  - Uses internal 4KB buffer
  - String is null-terminated
  - Automatically manages mark/empty

- **`sprintln`** `( ... "format" -- str )` - Format with newline
  ```r3forth
  100 200 "Size: %d x %d" sprintln
  | Returns "Size: 100 x 200\n\r\0"
  ```
  - Appends LF + CR + null

- **`sprintc`** `( ... "format" -- str cnt )` - Format and return count
  ```r3forth
  "Hello" "%s World" sprintc
  | Returns pointer and byte count
  ```
  - Useful for functions expecting counted strings

- **`sprintlnc`** `( ... "format" -- str cnt )` - Format with newline and count
  ```r3forth
  42 "Answer: %d" sprintlnc
  | Returns pointer and byte count (with newline)
  ```

---

## Usage Examples

### Build Data Structure
```r3forth
#person-name 0
#person-age 0
#person-salary 0

:create-person | "name" age salary --
  mark
  'person-salary !
  'person-age !
  
  ,s         | Name (null-terminated)
  person-age ,   | Age (8 bytes)
  person-salary , | Salary (8 bytes)
  ;

"John Doe" 30 50000 create-person
```

### Build Array
```r3forth
:build-array | n --
  0 ( over <?
    dup dup * ,  | Store squares
    1+
  ) 2drop ;

mark
10 build-array  | Array of squares: 0,1,4,9...81
"squares.dat" savemem
empty
```

### Format Report
```r3forth
:report | sales tax total --
  "Sales Report" .println
  "=============" .println 
  
  "Sales:  $%d" .println 
  "Tax:    $%d" .println  
  "Total:  $%d" .println ;

1000 80 1080 report
```

### CSV Generation
```r3forth
:csv-header
  mark
  "Name" ,s "," ,s
  "Age" ,s "," ,s
  "Salary" ,s ,nl ;

:csv-row | "name" age salary --
  rot ,s "," ,s
  ,d "," ,s
  ,d ,nl ;

mark
csv-header
"Alice" 25 45000 csv-row
"Bob" 30 55000 csv-row
"output.csv" savemem
empty
```

### Log System
```r3forth
:log-entry | level "message" --
  mark
  date ,2d "/" ,s ,2d "/" ,s ,d " " ,s
  time ,2d ":" ,s ,2d ":" ,s ,2d " " ,s
  "[" ,s
  swap
  0 =? ( "INFO" ,s )
  1 =? ( "WARN" ,s )
  2 =? ( "ERROR" ,s )
  drop
  "] " ,s
  ,s ,nl
  "system.log" savememinc 
  empty ;

0 "System started" log-entry
1 "Low disk space" log-entry
2 "Connection failed" log-entry
```

### Table Formatter
```r3forth
:table-row | col1 col2 col3 --
  "| " ,s ,d 10 .r. .print
  "| " ,s ,d 10 .r. .print
  "| " ,s ,d 10 .r. .print
  "|" ,s .cr
  ;

"| ID        | Age       | Score     |" .println 
"+-----------+-----------+-----------+" .println
1 25 87 table-row
2 30 92 table-row
3 28 85 table-row
```

### Configuration File
```r3forth
:truefalse
	1? ( "true" ; ) "false" ;
:write-config | width height fullscreen --
  mark
  rot "width=" ,s ,d ,nl
  swap "height=" ,s ,d ,nl
  "fullscreen=" ,s truefalse ,s ,nl
  drop
  "config.ini" savemem 
  empty ;

1920 1080 1 write-config
```

---

## Best Practices

1. **Always use mark/empty for temporary data**
   ```r3forth
   mark
   | ... build temporary string ...
   here .print
   empty  | Clean up
   ```

2. **Check buffer sizes for sprint functions**
   - Internal buffer is 4KB
   - For larger output, build directly to memory

3. **Align memory for structures**
   ```r3forth
   here align8 'here !  | Before storing 64-bit values
   ```

4. **Close memory blocks properly**
   ```r3forth
   mark
   | ... operations ...
   "data.bin" savemem  
   empty | <<< close memory
   ```

5. **Use ,eol to terminate strings**
   ```r3forth
   "text" ,s ,eol  | Null-terminated
   ```

---

## Performance Tips

1. **Batch comma operations** - Minimize function calls
2. **Use ,nsp instead of loops** for repeated spaces
3. **Pre-calculate string sizes** when possible
4. **Reuse sprint buffer** - It's automatically managed
5. **Align memory** for faster structure access

---

## Common Patterns

### String Accumulator
```r3forth
:accumulate
  mark
  ( condition? 
	data ,s " " ,s
	)
  ,eol
  here ;
```

### Serialization
```r3forth
:serialize | struct --
  mark
  @+ ,    | field1
  @+ ,    | field2
  @ ,     | field3
  "struct.dat" savemem 
  empty ;
```

### Format Cache
```r3forth
#cached-string 0

:format-once | value --
  cached-string 0? ( drop
    "%d items" sprint
    'cached-string !
  ) drop
  cached-string ;
```

---

## Memory Stack Details

The memory stack can hold up to 64 marks (512 bytes / 8 bytes per mark).

```r3forth
mark  | Push position 1
  mark  | Push position 2
    mark  | Push position 3
    empty  | Pop to position 2
  empty  | Pop to position 1
empty  | Pop to initial
```

**Stack overflow:** stack more than 64 marks will corrupt memory

---

## Notes

- **Buffer size:** `sprint` family uses 4KB buffer
- **Memory stack:** Supports up to 64 nested marks
- **Alignment:** Important for performance on some architectures
- **Thread safety:** Not thread-safe (uses global `here` pointer)
- **String encoding:** UTF-8 compatible
- **Float conversion:** Uses IEEE 754 single precision (32-bit)
- **Format limit:** Single format call processes entire string
- **Null termination:** Always add `,eol` for C-compatible strings

---

## Format String Examples

```r3forth
| Simple substitution
42 "Answer: %d" sprint

| Multiple values
10 20 "Point: (%d, %d)" sprint

| Mixed types
"file.txt" 1024 "Loaded %s (%d bytes)" sprint

| With literals
100 "Progress: %d%%" sprint  | Output: "Progress: 100%"

| Newlines
"Error" "Status: %s%." sprint  | "Status: Error\r"

| Hexadecimal addresses
$FF00 "Address: 0x%h" sprint

| Fixed-point display
98304 "Value: %f" sprint  | "Value: 1.5000"
```