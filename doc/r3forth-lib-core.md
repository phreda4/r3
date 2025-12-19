# R3Forth Core Library (core.r3)

A cross-platform core library for R3Forth providing system-level operations including timing, file I/O, directory traversal, and process management.

## Overview

This library provides essential OS interaction functionality with **cross-platform support** for Windows and Linux. Platform-specific differences are noted throughout.

---

## Time Functions

### Sleep and Timing

- **`ms`** `( ms -- )` - Sleep for specified milliseconds
  ```r3forth
  1000 ms  | Sleep for 1 second
  ```
  - **Windows:** Uses `Sleep` API
  - **Linux:** Uses `usleep` (converts ms to microseconds)

- **`msec`** `( -- msec )` - Get current time in milliseconds
  ```r3forth
  msec  | Returns milliseconds since system start
  ```
  - **Windows:** Returns `GetTickCount` (milliseconds since boot)
  - **Linux:** Uses `clock_gettime` with `CLOCK_MONOTONIC_RAW`

### Date and Time

- **`time`** `( -- hms )` - Get current time as packed integer
  ```r3forth
  time  | Returns HHMMSS as integer
  ```
  - Format: `HH << 16 | MM << 8 | SS`
  - Example: `153045` = 15:30:45

- **`date`** `( -- ymd )` - Get current date as packed integer
  ```r3forth
  date  | Returns YYYYMMDD as integer
  ```
  - Format: `YYYY << 16 | MM << 8 | DD`
  - Example: `20241219` = December 19, 2024

- **`sysdate`** `( -- 'dt )` - Get pointer to system date/time structure
  - Returns pointer to platform-specific time structure
  - **Windows:** `SYSTEMTIME` structure
  - **Linux:** `struct tm` pointer

### Date/Time Component Access

These extract individual components from the `sysdate` pointer:

- **`date.d`** `( 'dt -- day )` - Get day of month (1-31)
- **`date.dw`** `( 'dt -- dow )` - Get day of week (0-6)
- **`date.m`** `( 'dt -- month )` - Get month (1-12)
  - **Linux:** Adds 1 to `tm_mon` (which is 0-11)
- **`date.y`** `( 'dt -- year )` - Get full year
  - **Linux:** Adds 1900 to `tm_year`

- **`time.ms`** `( 'dt -- ms )` - Get milliseconds
  - **Windows:** Returns milliseconds (0-999)
  - **Linux:** Always returns 0 (not available in `struct tm`)
- **`time.s`** `( 'dt -- sec )` - Get seconds (0-59)
- **`time.m`** `( 'dt -- min )` - Get minutes (0-59)
- **`time.h`** `( 'dt -- hour )` - Get hours (0-23)

---

## Directory Traversal

### Directory Iteration

- **`ffirst`** `( "pattern" -- fdd/0 )` - Find first file matching pattern
  ```r3forth
  "*.txt" ffirst  | Find first .txt file
  0? ( "No files found" print ; )
  ```
  - **Windows:** Pattern uses wildcards (e.g., `"*.txt"`, `"dir//*"`)
  - **Linux:** Opens directory (pattern should be directory path)
  - Returns pointer to file data or 0 if no match

- **`fnext`** `( -- fdd/0 )` - Get next file in directory
  ```r3forth
  ( fnext 1?  | While files remain
    dup FNAME print cr  | Print filename
  ) drop
  ```
  - Returns pointer to next file or 0 when done
  - Automatically closes directory handle when finished

- **`findata`** `( -- 'fdd )` - Get pointer to current file data buffer

### File Information Access

- **`FNAME`** `( adr -- adrname )` - Get pointer to filename string
  ```r3forth
  fdd FNAME print  | Print filename
  ```
  - **Windows:** Offset +44 in `WIN32_FIND_DATA`
  - **Linux:** Offset +19 in `struct dirent`

- **`FDIR`** `( adr -- 1/0 )` - Check if entry is a directory
  ```r3forth
  fdd FDIR 1? ( "Directory" print ; )
  ```
  - Returns 1 for directory, 0 for file

- **`FSIZEF`** `( adr -- bytes )` - Get file size in bytes
  ```r3forth
  fdd FSIZEF "Size: %d" print
  ```
  - **Windows:** Combines `nFileSizeHigh` and `nFileSizeLow`
  - **Linux:** Uses `stat` structure

### File Timestamps

These functions return pointers to time/date structures:

- **`FCREADT`** `( adr -- 'timedate )` - Get creation time
- **`FLASTDT`** `( adr -- 'timedate )` - Get last access time
- **`FWRITEDT`** `( adr -- 'timedate )` - Get last write/modification time

**Windows:** Converts `FILETIME` to local `SYSTEMTIME`
**Linux:** Converts from `stat` structure to `struct tm` using `localtime`

---

## File Operations

### Load and Save

- **`load`** `( 'buffer "filename" -- 'end )` - Load entire file into buffer
  ```r3forth
  here "data.txt" load  | Load file at 'here'
  here -  | Calculate bytes loaded
  ```
  - Reads entire file into memory
  - Returns pointer to end of loaded data
  - Returns original pointer if file doesn't exist

- **`save`** `( 'from cnt "filename" -- )` - Save data to file
  ```r3forth
  'mybuffer 1024 "output.bin" save
  ```
  - Creates new file or overwrites existing
  - **Windows:** Uses `CreateFile` with `GENERIC_WRITE`
  - **Linux:** Uses `open` with `O_CREAT | O_WRONLY | O_TRUNC`

- **`append`** `( 'from cnt "filename" -- )` - Append data to file
  ```r3forth
  "New line" count "log.txt" append
  ```
  - Creates file if doesn't exist
  - Appends to end of existing file
  - **Windows:** Seeks to end before writing
  - **Linux:** Uses `O_APPEND` flag

### File Management

- **`delete`** `( "filename" -- )` - Delete file
  ```r3forth
  "temp.dat" delete
  ```
  - **Windows:** Uses `DeleteFile`
  - **Linux:** Uses `unlink`

- **`filexist`** `( "file" -- 0=no )` - Check if file exists
  ```r3forth
  "config.ini" filexist 0? ( "File not found" print ; )
  ```
  - Returns non-zero if file exists, 0 if not
  - **Windows:** Uses `GetFileAttributes`
  - **Linux:** Uses `access`

### File Information

- **`fileinfo`** `( "file" -- 0=not exist )` - Get detailed file information
  ```r3forth
  "data.bin" fileinfo 0? ( "Not found" ; )
  fileisize "Size: %d bytes" print
  ```
  - Fills internal `fileatrib` structure
  - Returns 0 if file doesn't exist
  - **Windows:** Uses `GetFileAttributesEx`
  - **Linux:** Uses `stat`

- **`fileisize`** `( -- size )` - Get file size from last `fileinfo` call
  ```r3forth
  "bigfile.dat" fileinfo drop
  fileisize 1000000 > ( "File over 1MB" print ; )
  ```

- **`fileijul`** `( -- julian )` - Get Julian date from last `fileinfo` call
  - Returns Julian day number of last write time
  - Used for date calculations

### File Time Access

After calling `fileinfo`, these return pointers to time structures:

- **`filecreatetime`** `( -- 'time )` - Creation time
- **`filelastactime`** `( -- 'time )` - Last access time  
- **`filelastwrtime`** `( -- 'time )` - Last write time

---

## Process Management

### Execute Commands

- **`sys`** `( "command" -- )` - Execute system command and wait
  ```r3forth
  "dir" sys  | Windows: list directory
  "ls -la" sys  | Linux: list directory
  ```
  - Blocks until command completes
  - **Windows:** Uses `CreateProcess` with wait
  - **Linux:** Uses `system` call

- **`sysnew`** `( "command" -- )` - Execute command in new console
  ```r3forth
  "notepad.exe" sysnew  | Windows: launch Notepad
  "./myapp" sysnew  | Linux: launch application
  ```
  - **Windows:** Creates new console window, doesn't wait
  - **Linux:** Uses `gnome-terminal` or similar (implementation varies)
  - Parent process continues immediately

- **`sysdebug`** `( "command" -- )` - Execute command in debug mode
  - **Windows only:** Launches process with `DEBUG_ONLY_THIS_PROCESS` flag
  - Used for debugger development
  - **Linux:** Not implemented

---

## Platform-Specific Notes

### Windows vs Linux Differences

| Feature | Windows | Linux |
|---------|---------|-------|
| **Time precision** | Milliseconds | Milliseconds (derived) |
| **File patterns** | Wildcards (`*.txt`) | Directory paths |
| **Directory iteration** | `FindFirstFile`/`FindNextFile` | `opendir`/`readdir` |
| **File timestamps** | `FILETIME` → `SYSTEMTIME` | `time_t` → `struct tm` |
| **Process creation** | `CreateProcess` (full control) | `system` (shell) |
| **New console** | Native support | Uses terminal emulator |
| **Milliseconds in time** | Available | Not available |

### Structure Differences

**Windows `SYSTEMTIME`:**
```
wYear, wMonth, wDayOfWeek, wDay
wHour, wMinute, wSecond, wMilliseconds
```

**Linux `struct tm`:**
```
tm_sec, tm_min, tm_hour, tm_mday
tm_mon (0-11), tm_year (since 1900)
tm_wday, tm_yday, tm_isdst
```

---

## Usage Examples

### Directory Listing
```r3forth
:listfiles | "pattern" --
  ffirst
  ( 1?
    dup FDIR 1? ( drop "DIR  " print ) drop
    dup FNAME print cr
    fnext
  ) drop ;

"*.r3" listfiles
```

### File Copy
```r3forth
:copyfile | "src" "dst" --
  swap
  $10000 'here + over load  | Load source
  over - >r  | Calculate size
  'here + r> rot save ;  | Save to destination

"original.txt" "backup.txt" copyfile
```

### Batch Processing
```r3forth
:processdir | "pattern" --
  ffirst
  ( 1?
    dup FDIR 0? (  | Skip directories
      dup FNAME 
      dup "Processing: " print print cr
      | ... process file ...
    ) drop
    fnext
  ) drop ;

"data//*.csv" processdir
```

### Timestamp Check
```r3forth
:checkmodified | "file" --
  fileinfo 0? ( "File not found" print ; )
  filelastwrtime
  date.y "Year: %d" print cr
  date.m "Month: %d" print cr
  date.d "Day: %d" print cr ;

"document.txt" checkmodified
```

### Timed Operation
```r3forth
:benchmark | 'code --
  msec >r  | Save start time
  ex  | Execute code
  msec r> - "Time: %d ms" print ;

:mycode 1000 ( 1? 1- ) drop ;
'mycode benchmark
```

### Process Launch
```r3forth
| Simple command execution
"echo Hello World" sys

| Launch in new window (Windows)
"cmd.exe /c dir /w" sysnew

| Launch application (Linux)
"./myprogram args" sys
```

---

## Best Practices

1. **Always check return values** for file operations
   ```r3forth
   "file.txt" load 0? ( "Load failed" print ; )
   ```

2. **Close directory handles** by iterating to completion
   ```r3forth
   ( fnext 1? ... ) drop  | Properly closes at end
   ```

3. **Use `fileinfo` before size/time queries**
   ```r3forth
   "data.bin" fileinfo drop
   fileisize  | Now valid
   ```

4. **Handle platform differences** for patterns
   ```r3forth
   |WIN| "dir//*.txt" ffirst
   |LIN| "dir" ffirst
   ```

5. **Buffer management** for `load`
   - Ensure sufficient buffer space
   - `load` returns end pointer for size calculation

---

## Error Handling

Most functions return 0 or -1 on failure:

```r3forth
"file.txt" load
0? ( "Cannot load file" print ; )  | Check for failure

"output.dat" filexist
0? ( "File does not exist" print ; )

"*.txt" ffirst
0? ( "No files found" print ; )
```

---

## Notes

- **File paths:** Use forward slashes on Linux, backslashes or forward slashes on Windows
- **Wildcards:** Windows supports `*` and `?`, Linux requires directory-only patterns
- **Buffer size:** File operations may require large buffers (check file size first)
- **Thread safety:** Functions are not thread-safe
- **UTF-8:** File operations support UTF-8 on both platforms (Windows uses UTF-8 code page)
- **Julian dates:** Used for calendar calculations, base date is 1601-01-01