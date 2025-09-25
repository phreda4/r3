# R3 Memory Management Library Documentation

## Overview

`mem.r3` provides comprehensive memory management utilities for R3, including dynamic allocation, memory marking/restoration, alignment functions, and formatted string building. It serves as the foundation for memory operations across the R3 ecosystem.

## Dependencies
- `r3/lib/str.r3` - String manipulation functions
- Platform-specific core libraries (win/core.r3 or posix/core.r3)

## Core Memory System

### Global Variables
```r3
#here 0           // Current memory allocation pointer
#memmap * 512     // Stack of memory marks (64 levels)
#memmap> 'memmap  // Current position in memory mark stack
```

The system uses a simple bump allocator with a mark-and-restore stack for memory management.

## Memory Alignment

### Alignment Functions
```r3
align32  | mem -- aligned_mem    // Align to 32-byte boundary
align16  | mem -- aligned_mem    // Align to 16-byte boundary  
align8   | mem -- aligned_mem    // Align to 8-byte boundary
```

**Examples:**
```r3
here align32 'here !             // Align current position to 32 bytes
buffer-addr align16              // Get 16-byte aligned address
```

**Use Cases:**
- **SIMD Operations**: Align data for vectorized operations
- **Cache Optimization**: Align to cache line boundaries
- **Hardware Requirements**: Some operations require aligned data

## Mark and Restore System

### Memory Stack Operations
```r3
mark     | --           // Push current memory position to stack
empty    | --           // Pop memory position from stack (restore)
```

This provides automatic memory cleanup with scope-based allocation:

**Example:**
```r3
:process-data
    mark                 // Save current memory position
    | Allocate temporary memory
    1000 'here +!        // Allocate 1000 bytes
    | Use temporary memory...
    empty ;              // Automatically free all allocated memory
```

### Memory Information
```r3
sizemem  | -- size      // Size of current memory block
memsize  | -- mem size  // Start address and size of current block
```

## Memory Allocation

### Basic Allocation
```r3
,        | value --     // Store 64-bit value, advance pointer
,c       | byte --      // Store byte, advance pointer
,q       | qword --     // Store 64-bit value (alias for ,)
,w       | word --      // Store 16-bit value, advance pointer
```

**Examples:**
```r3
12345 ,                  // Store integer
65 ,c                    // Store byte 'A'
$1234 ,w                 // Store 16-bit value
```

### String Storage
```r3
,s       | "string" --  // Store string with null terminator
,word    | "string" --  // Store word (stops at whitespace)
,line    | "string" --  // Store line (stops at newline)
,eol     | --           // Store null terminator
```

**Examples:**
```r3
"Hello World" ,s         // Store complete string
"Token" ,word           // Store single word
"Line of text" ,line    // Store line
```

### Special Characters
```r3
,cr      | --           // Store carriage return (13)
,sp      | --           // Store space (32)
,nl      | --           // Store newline sequence (CR+LF)
```

## Formatted Output System

### Numeric Formatting
```r3
,d       | n --         // Store decimal representation
,h       | n --         // Store hexadecimal representation  
,b       | n --         // Store binary representation
,f       | fp --        // Store fixed-point representation
,2d      | n --         // Store 2-digit decimal (zero-padded)
,ifp     | i --         // Store integer as fixed-point
,ffp     | f --         // Store float as fixed-point
```

**Examples:**
```r3
255 ,d                   // "255"
255 ,h                   // "FF"
7 ,b                     // "111" 
1.5 ,f                   // "1.5"
5 ,2d                    // "05"
```

### Formatted String Building

The system supports printf-style formatting with these specifiers:

| Specifier | Function | Description |
|-----------|----------|-------------|
| `%d` | Decimal | Integer as decimal |
| `%h` | Hexadecimal | Integer as hex |
| `%b` | Binary | Integer as binary |
| `%s` | String | Null-terminated string |
| `%f` | Fixed-point | Fixed-point number |
| `%w` | Word | Single word from string |
| `%l` | Line | Line from string |
| `%k` | Character | Single character |
| `%i` | Integer part | Integer part of fixed-point |
| `%j` | Fractional part | Fractional part of fixed-point |
| `%o` | Octal | Integer as octal |
| `%.` | Newline | Carriage return |
| `%%` | Literal | Literal % character |

#### Format Functions
```r3
,print   | p1 p2 ... "format" -- // Build formatted string in memory
sprint   | p1 p2 ... "format" -- adr // Build string, return address
sprintc  | p1 p2 ... "format" -- adr count // String with length
sprintln | p1 p2 ... "format" -- adr // String with newline
sprintlnc| p1 p2 ... "format" -- adr count // String+newline with length
```

**Examples:**
```r3
mark
100 200 "Player at %d, %d" ,print  // Build string in memory
empty

50 75 "Score: %d Lives: %d" sprint  // Returns string address
"Name: %s Age: %d" 0 sprint         // Handles null strings safely
```

## File Operations

### Memory Persistence
```r3
savemem     | "filename" --        // Save current memory block to file
appendmem   | "filename" --        // Append memory block to file
cpymem      | dest_addr --         // Copy memory block to address
```

### Incremental Saving
```r3
savememinc  | "filename" --        // Incremental save (first save/append after)
```

**Example:**
```r3
mark
"Building data..." ,s
some-data ,
123 ,d
"data.txt" savemem               // Save to file
empty
```

## Complete Application Examples

### Log System
```r3
#log-file "application.log"

:log-message | "message" --
    mark
    | Timestamp
    msec .d ,s ": " ,s
    | Message
    ,s ,nl
    | Save to file
    log-file savememinc
    empty ;

:log-error | error-code "context" --
    swap "ERROR %d in %s" sprint log-message ;

| Usage:
"Application started" log-message
404 "HTTP Handler" log-error
```

### Configuration Builder
```r3
:build-config | name value --
    mark
    "[Settings]" ,s ,nl
    over "WindowTitle=%s" ,print ,nl
    "Resolution=%dx%d" ,print ,nl  
    "Fullscreen=%s" ,print ,nl
    "config.ini" savemem
    empty ;

| Usage:
"My Game" 800 600 0? ( "false" ; "true" ) build-config
```

### Data Serialization
```r3
#objects 'player 'enemies 'items 0

:serialize-object | object --
    mark
    dup @ ,d ,sp           // ID
    dup 8 + @ ,d ,sp       // X position  
    dup 16 + @ ,d ,sp      // Y position
    24 + @ ,d ,nl          // Health
    empty ;

:save-game-state | "filename" --
    mark
    "# Game Save File" ,s ,nl
    "Version=1.0" ,s ,nl
    objects ( @+ 1? serialize-object ) drop
    savemem
    empty ;

| Usage:
"savegame.dat" save-game-state
```

## Advanced Memory Patterns

### Temporary String Building
```r3
:temp-string | ... "format" -- "result"
    mark swap sprint dup ,s empty ;

:format-coordinates | x y -- "formatted"
    "(%d,%d)" temp-string ;

| Usage:  
100 200 format-coordinates print  // Prints "(100,200)"
```

### Memory Pool Management
```r3
#pool-start
#pool-size 1000000

:init-pool
    here 'pool-start !
    pool-size 'here +! ;

:reset-pool
    pool-start 'here ! ;

:pool-alloc | size -- addr
    here swap dup 'here +! ;

| Usage:
init-pool
1000 pool-alloc 'buffer !    // Allocate from pool
reset-pool                   // Reset entire pool
```

### Structured Data Building
```r3
:begin-struct mark ;
:end-struct | -- addr size
    here memmap> 8 - @ over - ;

:add-field | value --
    , ;

:add-string | "text" --
    dup count ,w ,s ;        // Length + string

| Usage:
begin-struct
    1001 add-field           // ID
    "Player Name" add-string // Name
    100 add-field           // Health
end-struct 'player-data ! 'player-size !
```

## Performance Characteristics

### Advantages
- **O(1) Allocation**: Bump allocator is extremely fast
- **Stack-based Cleanup**: Automatic memory management
- **No Fragmentation**: Sequential allocation prevents fragmentation
- **Cache Friendly**: Linear allocation pattern

### Limitations  
- **No Individual Free**: Can't free specific allocations
- **Memory Growth**: Memory usage only grows until empty
- **Limited Nesting**: Fixed-size mark stack (64 levels)

## Best Practices

1. **Use Mark/Empty**: Always pair mark with empty for automatic cleanup
2. **Size Estimation**: Pre-calculate sizes for large allocations when possible
3. **Alignment Planning**: Use alignment functions for performance-critical data
4. **String Building**: Use sprint functions for complex string formatting
5. **Incremental Saves**: Use savememinc for log files and streaming data

## Memory Safety

The library provides basic safety through:
- **Bounds Awareness**: Functions don't automatically check bounds
- **Null Handling**: String functions handle null pointers gracefully
- **Stack Management**: Mark/empty system prevents most memory leaks

**Important**: This is a manual memory management system. Proper use of mark/empty is essential to prevent memory exhaustion.

This memory management system provides a foundation for efficient, deterministic memory operations in R3 applications, particularly suitable for real-time systems where garbage collection pauses are unacceptable.