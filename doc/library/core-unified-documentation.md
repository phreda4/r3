# core.r3 Library Documentation

**Cross-Platform Operating System Interface Library for R3forth**

*Author: PHREDA 2021*

---

## Overview

The `core.r3` library provides essential operating system interface functions for R3forth. It offers a unified API across platforms while wrapping platform-specific system calls for time management, memory allocation, file operations, and process control.

**Supported Platforms:**
- Windows (via kernel32.dll)
- Linux (via POSIX C library)
- Raspberry Pi (RPI)
- macOS (MAC)

---

## Platform Detection

The library automatically loads the appropriate platform-specific implementation:

```forth
| Windows
^r3/lib/win/kernel32.r3

| Linux/RPI/MAC
^r3/lib/posix/posix.r3
```

---

## Time Management

### ::ms
```forth
::ms | ms --
```
Sleep for specified milliseconds.

**Parameters:**
- `ms` - Duration in milliseconds to sleep

**Platform Implementation:**
- **Windows**: Uses `Sleep` (Win32 API)
- **Linux**: Uses `usleep` (converts ms to microseconds)

**Example:**
```forth
1000 ms  | Sleep for 1 second
500 ms   | Sleep for half a second
```

---

### ::msec
```forth
::msec | -- msec
```
Get elapsed time in milliseconds.

**Returns:**
- `msec` - Milliseconds elapsed

**Platform Implementation:**
- **Windows**: Uses `GetTickCount` (system uptime)
- **Linux**: Uses `clock_gettime` with `CLOCK_MONOTONIC_RAW` (high precision)

**Example:**
```forth
msec 'start-time !
| ... do work ...
msec start-time @ - "Elapsed: %d ms" .print
```

**Note:** On Windows, wraps after ~49 days. On Linux, monotonic and more precise.

---

### ::time
```forth
::time | -- hms
```
Get current local time packed into a single value.

**Returns:**
- `hms` - Packed time value

**Format:** `$00HHMMSS`
- Bits 16-23: Hours (0-23)
- Bits 8-15: Minutes (0-59)
- Bits 0-7: Seconds (0-59)

**Example:**
```forth
time
dup 16 >> $ff and "Hour: %d" .print
dup 8 >> $ff and "Minute: %d" .print
$ff and "Second: %d" .print
```

**Cross-Platform:** ✓ Identical behavior on all platforms

---

### ::date
```forth
::date | -- ymd
```
Get current local date packed into a single value.

**Returns:**
- `ymd` - Packed date value

**Format:** `$YYYYMMDD`
- Bits 16-31: Year (e.g., 2025)
- Bits 8-15: Month (1-12)
- Bits 0-7: Day (1-31)

**Example:**
```forth
date
dup 16 >> $ffff and "Year: %d" .print
dup 8 >> $ff and "Month: %d" .print
$ff and "Day: %d" .print
```

**Cross-Platform:** ✓ Identical behavior on all platforms

---

### ::sysdate
```forth
::sysdate | -- 'timedate
```
Get pointer to system time structure.

**Returns:**
- `'timedate` - Address of time/date structure

**Platform Differences:**
- **Windows**: Returns pointer to `SYSTEMTIME` structure (16 bytes)
- **Linux**: Returns pointer to `struct tm` (36+ bytes)

**Structure Layouts:**

**Windows (SYSTEMTIME):**
- +0: wYear (word)
- +2: wMonth (word, 1-12)
- +4: wDayOfWeek (word, 0-6)
- +6: wDay (word, 1-31)
- +8: wHour (word, 0-23)
- +10: wMinute (word, 0-59)
- +12: wSecond (word, 0-59)
- +14: wMilliseconds (word, 0-999)

**Linux (struct tm):**
- +0: tm_sec (int, 0-59)
- +4: tm_min (int, 0-59)
- +8: tm_hour (int, 0-23)
- +12: tm_mday (int, 1-31)
- +16: tm_mon (int, 0-11)
- +20: tm_year (int, years since 1900)
- +24: tm_wday (int, 0-6)
- +28: tm_yday (int, 0-365)
- +32: tm_isdst (int)

---

### Time/Date Component Extractors

```forth
::date.y | 'timedate -- year
::date.m | 'timedate -- month
::date.d | 'timedate -- day
::date.dw | 'timedate -- day_of_week
::time.h | 'timedate -- hour
::time.m | 'timedate -- minute
::time.s | 'timedate -- second
::time.ms | 'timedate -- milliseconds
```

Extract individual components from system time structure.

**Platform Notes:**
- **Windows**: All fields work as expected, months 1-12
- **Linux**: Months are 0-11 (add 1 for human-readable), milliseconds always 0

**Example:**
```forth
sysdate date.y "Year: %d" .print
sysdate date.m "Month: %d" .print  | Windows: 1-12, Linux: 0-11
```

---

## Memory Management

### ::allocate
```forth
::allocate | n -- a ior
```
Allocate memory from heap.

**Parameters:**
- `n` - Number of bytes to allocate

**Returns:**
- `a` - Address of allocated memory
- `ior` - I/O result (duplicate of address for compatibility)

**Platform Implementation:**
- **Windows**: Uses `HeapAlloc` (**DEPRECATED** - see note)
- **Linux**: Uses `malloc` (**FUNCTIONAL**)

**Example:**
```forth
1024 allocate drop 'buffer !
```

**⚠️ Important Platform Note:**
- **Linux**: Fully functional, use as primary allocation method
- **Windows**: Marked as "not used" - prefer R3's MEM/HERE/MARK/EMPTY system

---

### ::free
```forth
::free | a -- ior
```
Free previously allocated memory.

**Parameters:**
- `a` - Address of memory to free

**Returns:**
- `ior` - I/O result (0 on success)

**Platform Implementation:**
- **Windows**: Uses `HeapFree` (**DEPRECATED**)
- **Linux**: Uses `free` (**FUNCTIONAL**)

**Example:**
```forth
buffer @ free drop
```

---

### ::resize
```forth
::resize | a n -- a ior
```
Resize previously allocated memory block.

**Parameters:**
- `a` - Address of memory block to resize
- `n` - New size in bytes

**Returns:**
- `a` - Address of resized memory (may be different from input)
- `ior` - I/O result (0 on success)

**Platform Implementation:**
- **Windows**: Uses `HeapReAlloc` (**DEPRECATED**)
- **Linux**: Uses `realloc` (**FUNCTIONAL**)

**Example:**
```forth
buffer @ 2048 resize drop 'buffer !
```

---

### ::iniheap
```forth
::iniheap | --
```
Initialize process heap.

**Platform Availability:**
- **Windows**: Available (gets process heap handle)
- **Linux**: Not available

**Note:** Only needed on Windows if using heap allocation functions. Generally not required as these are deprecated.

---

## File System Operations

### ::load
```forth
::load | 'from "filename" -- 'to
```
Load file contents into memory buffer.

**Parameters:**
- `'from` - Buffer address to load into
- `"filename"` - Path to file

**Returns:**
- `'to` - Address after loaded data (original address + file size)
- Returns `'from` unchanged if file cannot be opened

**Platform Implementation:**
- **Windows**: Uses `CreateFile` + `ReadFile` + `CloseHandle`
- **Linux**: Uses `open` + `read` + `close`

**Example:**
```forth
here "data.txt" load here - "Loaded %d bytes" .print
```

**Cross-Platform:** ✓ Identical interface

---

### ::save
```forth
::save | 'from cnt "filename" --
```
Save memory buffer to file (creates or overwrites).

**Parameters:**
- `'from` - Buffer address to save from
- `cnt` - Number of bytes to save
- `"filename"` - Path to file

**Platform Implementation:**
- **Windows**: Uses `CreateFile` + `WriteFile` + `CloseHandle`
- **Linux**: Uses `open` (O_WRONLY|O_CREAT|O_TRUNC) + `write` + `close`

**Example:**
```forth
'buffer 1024 "output.dat" save
```

**Cross-Platform:** ✓ Identical interface

---

### ::append
```forth
::append | 'from cnt "filename" --
```
Append data to end of file.

**Parameters:**
- `'from` - Buffer address to append from
- `cnt` - Number of bytes to append
- `"filename"` - Path to file

**Platform Implementation:**
- **Windows**: Uses `CreateFile` + `SetFilePointer` + `WriteFile` + `CloseHandle`
- **Linux**: Uses `open` (O_WRONLY|O_CREAT|O_APPEND) + `write` + `close`

**Example:**
```forth
"Log entry\n" count "app.log" append
```

**Cross-Platform:** ✓ Identical interface

---

### ::delete
```forth
::delete | "filename" --
```
Delete file from filesystem.

**Parameters:**
- `"filename"` - Path to file to delete

**Platform Implementation:**
- **Windows**: Uses `DeleteFile`
- **Linux**: Uses `unlink`

**Example:**
```forth
"temp.dat" delete
```

**Cross-Platform:** ✓ Identical interface

---

### ::filexist
```forth
::filexist | "file" -- flag
```
Check if file exists and is accessible.

**Parameters:**
- `"file"` - Path to file

**Returns:**
- `flag` - Non-zero if file exists, 0 if not

**Platform Implementation:**
- **Windows**: Uses `GetFileAttributes`
- **Linux**: Uses `access`

**Example:**
```forth
"config.r3" filexist 0? ( "File not found!" .print )
```

**Cross-Platform:** ✓ Identical interface

---

### ::fileinfo
```forth
::fileinfo | "file" -- flag
```
Get file attributes and metadata.

**Parameters:**
- `"file"` - Path to file

**Returns:**
- `flag` - Non-zero if successful, 0 if file not found (Windows) or 0/-1 (Linux)

**Side Effects:**
Populates internal `fileatrib` structure with file metadata

**Platform Implementation:**
- **Windows**: Uses `GetFileAttributesEx`
- **Linux**: Uses `stat`

**Example:**
```forth
"document.txt" fileinfo 1? ( fileisize "Size: %d bytes" .print )
```

**Cross-Platform:** ✓ Identical interface (different internal structure)

---

### ::fileisize
```forth
::fileisize | -- size
```
Get file size from last `fileinfo` call.

**Returns:**
- `size` - File size in bytes (64-bit)

**Prerequisite:** Must call `fileinfo` first

**Example:**
```forth
"large.dat" fileinfo drop
fileisize "File size: %d bytes" .print
```

**Cross-Platform:** ✓ Identical interface

---

### ::fileijul
```forth
::fileijul | -- julian
```
Get file modification time as Julian date from last `fileinfo` call.

**Returns:**
- `julian` - Julian day number

**Prerequisite:** Must call `fileinfo` first

**Implementation:** Converts file timestamp to Julian date (base: 1601-01-01)

**Cross-Platform:** ✓ Identical interface

---

### File Time Accessors (Windows Only)

```forth
::filecreatetime | -- 'FILETIME
::filelastactime | -- 'FILETIME
::filelastwrtime | -- 'FILETIME
```

Get pointers to FILETIME structures from last `fileinfo` call.

**Platform Availability:**
- **Windows**: ✓ Available
- **Linux**: ✗ Not available

**Example (Windows only):**
```forth
"file.txt" fileinfo drop
filecreatetime | Get creation time pointer
```

---

## Directory Enumeration

### ::ffirst
```forth
::ffirst | "path//*" -- fdd/0
```
Find first file/directory entry.

**Parameters:**
- `"path//*"` - Search pattern

**Returns:**
- `fdd` - Pointer to find data structure, or 0 if error/no match

**Platform Differences:**
- **Windows**: Supports wildcards (e.g., `"*.txt"`, `"data/*.r3"`)
- **Linux**: No wildcard support - provide directory path only

**Platform Implementation:**
- **Windows**: Uses `FindFirstFile` → returns `WIN32_FIND_DATA`
- **Linux**: Uses `opendir` + `readdir` → returns `struct dirent`

**Examples:**
```forth
| Windows - with wildcards
"*.txt" ffirst 
( 1? 
    dup FNAME .print .cr
    fnext 
) drop

| Linux - directory only
"/home/user/data" ffirst 
( 1? 
    dup FNAME .print .cr
    fnext 
) drop
```

---

### ::fnext
```forth
::fnext | -- fdd/0
```
Get next directory entry.

**Returns:**
- `fdd` - Pointer to find data structure, or 0 if no more entries

**Platform Implementation:**
- **Windows**: Uses `FindNextFile` + `FindClose` (on completion)
- **Linux**: Uses `readdir` + `closedir` (on completion)

**Example:**
```forth
"*.r3" ffirst 
( 1?
    dup FNAME .print .cr
    fnext
) drop
```

**Cross-Platform:** ✓ Identical interface (but Windows needs wildcard pattern)

---

### ::findata
```forth
::findata | -- 'fdd
```
Get pointer to current find data buffer.

**Returns:**
- `'fdd` - Address of find data structure
  - **Windows**: 512-byte `WIN32_FIND_DATA` buffer
  - **Linux**: Pointer to `DIR*` handle

**Cross-Platform:** ✓ Available on both (different structures)

---

### File Data Accessors

#### ::FNAME
```forth
::FNAME | adr -- adrname
```
Get pointer to filename string from find data.

**Parameters:**
- `adr` - Address of find data structure

**Returns:**
- `adrname` - Address of null-terminated filename string

**Platform Offsets:**
- **Windows**: +44
- **Linux**: +19
- **RPI**: +11
- **MAC**: +21

**Example:**
```forth
ffirst ( 1?
    dup FNAME .print .cr
    fnext
) drop
```

**Cross-Platform:** ✓ Identical interface (automatic offset)

---

#### ::FDIR
```forth
::FDIR | adr -- flag
```
Check if entry is a directory.

**Parameters:**
- `adr` - Address of find data structure

**Returns:**
- `flag` - 1 if directory, 0 if file

**Platform Implementation:**
- **Windows**: Reads dwFileAttributes (offset +0), checks bit 4
- **Linux**: Reads d_type (offset +18), checks bit 2

**Example:**
```forth
ffirst ( 1?
    dup FDIR 1? ( "DIR:  " ) ( "FILE: " ) .print
    dup FNAME .print .cr
    fnext
) drop
```

**Cross-Platform:** ✓ Identical interface

---

#### ::FSIZE
```forth
::FSIZE | adr -- sizekb
```
Get file size in kilobytes.

**Parameters:**
- `adr` - Address of find data structure

**Returns:**
- `sizekb` - File size in kilobytes (rounded down)

**Platform Implementation:**
- **Windows**: Reads nFileSizeLow (offset +32), divides by 1024
- **Linux**: Reads from offset +32, divides by 1024

**Example:**
```forth
ffirst ( 1?
    dup FNAME .print "  " .print
    dup FSIZE "%d KB" .print .cr
    fnext
) drop
```

**Platform Note:**
- **Linux**: May be unreliable as `struct dirent` doesn't always contain size

**Cross-Platform:** ✓ Identical interface (but reliability differs)

---

#### ::FSIZEF (Windows Only)
```forth
::FSIZEF | adr -- sizebytes
```
Get exact file size in bytes.

**Parameters:**
- `adr` - Address of WIN32_FIND_DATA structure

**Returns:**
- `sizebytes` - Exact file size in bytes (64-bit)

**Platform Availability:**
- **Windows**: ✓ Available
- **Linux**: ✗ Not available

**Example (Windows only):**
```forth
ffirst ( 1?
    dup FNAME .print "  " .print
    dup FSIZEF "%d bytes" .print .cr
    fnext
) drop
```

---

#### File Timestamp Accessors (Windows Only)

```forth
::FCREADT | adr -- 'timedate
::FLASTDT | adr -- 'timedate
::FWRITEDT | adr -- 'timedate
```

Get creation time, last access time, and last write time from find data.

**Parameters:**
- `adr` - Address of WIN32_FIND_DATA structure

**Returns:**
- `'timedate` - Address of SYSTEMTIME structure (converted from FILETIME)

**Platform Availability:**
- **Windows**: ✓ Available
- **Linux**: ✗ Not available

**Example (Windows only):**
```forth
ffirst ( 1?
    dup FNAME .print .cr
    dup FWRITEDT date.y "Last modified: %d" .print
    fnext
) drop
```

---

## Process Management

### ::sys
```forth
::sys | "command" --
```
Execute system command and wait for completion.

**Parameters:**
- `"command"` - Command line to execute

**Platform Implementation:**
- **Windows**: Uses `CreateProcess` + `WaitForSingleObject`
- **Linux**: Uses `system`

**Examples:**
```forth
| Windows
"notepad.exe test.txt" sys
"dir" sys

| Linux
"vim test.txt" sys
"ls -la" sys
```

**Cross-Platform:** ✓ Identical interface (different command syntax)

---

### ::sysnew
```forth
::sysnew | "command" --
```
Execute system command in new console/terminal window.

**Parameters:**
- `"command"` - Command line to execute

**Platform Implementation:**
- **Windows**: Uses `CreateProcess` with CREATE_NEW_CONSOLE flag
- **Linux**: Uses `gnome-terminal` wrapper (requires GNOME)

**Examples:**
```forth
| Windows - opens new console
"cmd.exe /c dir" sysnew

| Linux - opens new terminal (GNOME only)
"ls -la" sysnew
```

**Platform Notes:**
- **Windows**: Fully functional, waits for process completion
- **Linux**: Requires GNOME desktop environment, may not work on all systems

---

### ::sysdebug (Windows Only)
```forth
::sysdebug | "command" --
```
Execute system command with debug flag enabled.

**Parameters:**
- `"command"` - Command line to execute

**Platform Availability:**
- **Windows**: ✓ Available (experimental)
- **Linux**: ✗ Not available

**Implementation:** Creates process with `DEBUG_ONLY_THIS_PROCESS` flag

**Note:** Experimental debugging support. Does not wait for process completion.

---

## Internal Variables

### Windows
- `#process-heap` - Process heap handle (for deprecated heap functions)
- `#sistime` - 16-byte SYSTEMTIME buffer
- `#fdd` - 512-byte WIN32_FIND_DATA buffer
- `#hfind` - Find file handle
- `#fileatrib` - WIN32_FILE_ATTRIBUTE_DATA buffer
- `#sinfo` - 104-byte STARTUPINFO buffer
- `#pinfo` - 24-byte PROCESS_INFORMATION buffer
- `#aux` - 16-byte auxiliary buffer for file operations

### Linux
- `#process-heap` - Unused placeholder (for compatibility)
- `#te` - 16-byte timespec buffer (for msec)
- `#sit` - Single qword for Unix timestamp
- `#dirp` - Directory stream handle (DIR*)
- `#fileatrib` - stat structure buffer

---

## Cross-Platform Compatibility Guide

### ✓ Fully Compatible Functions

These functions work identically across platforms:

```forth
::ms          | Sleep
::time        | Get packed time
::date        | Get packed date
::load        | Load file
::save        | Save file
::append      | Append to file
::delete      | Delete file
::filexist    | Check file existence
::fileinfo    | Get file info
::fileisize   | Get file size
::fileijul    | Get Julian date
::sys         | Execute command
::FNAME       | Get filename
::FDIR        | Check if directory
```

### ⚠️ Platform Differences

These functions have behavioral differences:

| Function | Windows | Linux | Notes |
|----------|---------|-------|-------|
| `::msec` | GetTickCount (wraps) | Monotonic clock | Linux more precise |
| `::sysdate` | SYSTEMTIME | struct tm | Different structures |
| `::ffirst` | Supports wildcards | Directory only | Major difference |
| `::FSIZE` | Reliable | May be unreliable | Linux dirent limitation |
| `::sysnew` | New console | GNOME terminal | Linux needs GNOME |
| `date.m` extractors | 1-12 | 0-11 | Add 1 on Linux |

### ✗ Windows-Only Functions

```forth
::iniheap         | Initialize heap
::FSIZEF          | Exact file size in bytes
::FCREADT         | Creation timestamp
::FLASTDT         | Last access timestamp
::FWRITEDT        | Last write timestamp
::filecreatetime  | Creation time pointer
::filelastactime  | Last access time pointer
::filelastwrtime  | Last write time pointer
::sysdebug        | Debug process launch
```

### ✗ Linux-Only Behavior

- `::allocate`, `::free`, `::resize` are fully functional (deprecated on Windows)

---

## Best Practices

### For Cross-Platform Code

1. **Use compatible functions only**
   ```forth
   | Good - works everywhere
   "data.txt" load
   
   | Bad - Windows only
   ffirst FSIZEF
   ```

2. **Abstract platform differences**
   ```forth
   | Create wrappers for different behaviors
   :get-month | 'timedate -- month
       date.m
       |#LIN 1+  | Add 1 on Linux
       ;
   ```

3. **Handle directory enumeration differences**
   ```forth
   | Windows
   :list-r3-files
       "*.r3" ffirst ( 1? dup FNAME .print fnext ) drop ;
   
   | Linux - requires filtering
   :list-r3-files
       "." ffirst ( 1?
           dup FNAME
           dup ".r3" endsWith? ( .print .cr ) ( drop )
           fnext
       ) drop ;
   ```

4. **Use R3 memory management on Windows**
   ```forth
   | Windows - use MEM/HERE/MARK/EMPTY
   MARK
   HERE 1024 + 'HERE !
   | ... use memory ...
   EMPTY
   
   | Linux - can use allocate/free
   1024 allocate drop 'buffer !
   | ... use buffer ...
   buffer @ free drop
   ```

5. **Check file timestamps carefully**
   ```forth
   | Safe - works everywhere
   "file.txt" fileinfo drop
   fileijul "Modified: %d" .print
   
   | Unsafe - Windows only
   |#WIN ffirst FWRITEDT date.y .print
   ```

### Memory Management Choice

**Windows:**
- Prefer: `MEM`, `HERE`, `MARK`, `EMPTY`
- Avoid: `allocate`, `free`, `resize` (marked as deprecated)

**Linux:**
- Both work: Use either R3's memory system or libc allocation
- `allocate`/`free` fully supported and functional

### File Path Conventions

- **Windows**: Accepts both `/` and `\`
- **Linux**: Use `/` only
- **Recommendation**: Always use `/` for better cross-platform compatibility

---

## Usage Examples

### Cross-Platform File Logger

```forth
:timestamp | -- "YYYYMMDDHHmmss"
    here
    date dup 16 >> $ffff and "%04d" sprint
    dup 8 >> $ff and "%02d" sprint
    $ff and "%02d" sprint
    time dup 16 >> $ff and "%02d" sprint
    dup 8 >> $ff and "%02d" sprint
    $ff and "%02d" sprint
    0 ,c here ;

:log | "message" --
    timestamp " " ,s ,s "\n" ,s
    here count "app.log" append ;

"Application started" log
```

### Cross-Platform Directory Listing

```forth
:show-directory | "path" --
    |#WIN "*" ,s  | Add wildcard for Windows
    ffirst 
    ( 1?
        dup FDIR 1? ( "[DIR]  " ) ( "[FILE] " ) .print
        dup FNAME .print "  " .print
        dup FSIZE "%d KB" .print .cr
        fnext
    ) drop ;

|#WIN "C:\Users\*" show-directory
|#LIN "/home/user" show-directory
```

### Performance Timer (Cross-Platform)

```forth
#start-time 0

:timer-start | --
    msec 'start-time ! ;

:timer-stop | -- elapsed-ms
    msec start-time @ - ;

| Usage:
timer-start
| ... do work ...
timer-stop "Elapsed: %d ms" .print
```

### Safe File Loading with Error Checking

```forth
:safe-load | "filename" -- success?
    dup filexist 0? ( 
        drop "File not found!" .print 0 ; 
    )
    dup fileinfo 0? (
        drop "Cannot read file info!" .print 0 ;
    )
    fileisize 0? (
        drop "Empty file!" .print 0 ;
    )
    here swap load
    here - "Loaded %d bytes" .print 1 ;

"data.txt" safe-load drop
```

---

## Platform-Specific Code Blocks

Use conditional compilation comments for platform-specific code:

```forth
| Cross-platform common code
:common-func
    "Hello" .print ;

| Windows-specific
|#WIN :win-only
|#WIN     "Windows version" .print ;

| Linux-specific
|#LIN :lin-only
|#LIN     "Linux version" .print ;

| Use appropriate function
|#WIN win-only
|#LIN lin-only
```

---

## See Also

### Windows
- **r3/lib/win/kernel32.r3** - Windows API bindings
- Windows API Documentation: https://learn.microsoft.com/en-us/windows/win32/api/

### Linux
- **r3/lib/posix/posix.r3** - POSIX C library bindings
- POSIX Documentation: https://pubs.opengroup.org/onlinepubs/9699919799/
- Linux man pages: https://man7.org/linux/man-pages/

### General
- **r3/lib/str.r3** - String manipulation utilities
- **R3forth Manual** - Memory management section (MEM/HERE/MARK/EMPTY)
- R3forth Repository: https://github.com/phreda4/r3

---

*Generated from core.r3 source code (Windows and Linux versions)*
*Last updated: 2025*