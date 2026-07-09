# r3forth Library Reference

Complete API reference for the r3forth library ecosystem.

**Conventions:**
- `::word` — exported word (public API)
- `##var` — exported mutable global variable
- Stack notation: `( inputs -- outputs )` — `.` suffix = 48.16 fixed-point, `.d` = 32.32 fixed-point
- Binary angle (`bangle`): `0`=0° `0.25`=90° `0.5`=180°
- `|WIN|` — Windows only, `|LIN|` — Linux only; unmarked = cross-platform
- `^path` — dependency (include before this file)

---

## Table of Contents

### lib/ — Core Libraries
1. [math.r3](#mathr3) — Fixed-point math, trig, float conversion
2. [dmath.r3](#dmathr3) — Double-precision (32.32) math
3. [str.r3](#strr3) — String operations
4. [mem.r3](#memr3) — Heap memory and formatted output
5. [parse.r3](#parser3) — String parsing and number parsing
6. [rand.r3](#randr3) — Random number generators
7. [vec2.r3](#vec2r3) — 2D vector operations
8. [vec3.r3](#vec3r3) — 3D vector and quaternion operations
9. [color.r3](#colorr3) — Color space conversions and blending
10. [jul.r3](#julr3) — Julian date calculations
11. [console.r3](#consoler3) — Terminal I/O with ANSI colors
12. [trace.r3](#tracer3) — Debug tracing tools
13. [crc32.r3](#crc32r3) — Checksums (CRC32, Adler32)
14. [base64.r3](#base64r3) — Base64 encode/decode
15. [sdl2.r3](#sdl2r3) — SDL2 window, renderer, events (cross-platform base)
16. [sdl2gfx.r3](#sdl2gfxr3) — SDL2 drawing primitives and sprites
17. [sdl2image.r3](#sdl2imager3) — SDL2_image: PNG/JPG/SVG loading
18. [sdl2ttf.r3](#sdl2ttfr3) — SDL2_ttf: TrueType font rendering
19. [sdl2mixer.r3](#sdl2mixerr3) — SDL2_mixer: audio playback
20. [sdl2net.r3](#sdl2netr3) — SDL2_net: TCP/UDP networking
21. [sdl2poly.r3](#sdl2polyr3) — Polygon and thick-line drawing
22. [sdl2gl.r3](#sdl2glr3) — OpenGL access via SDL2
23. [sdlkeys.r3](#sdlkeysr3) — SDL2 keyboard constants
24. [gui.r3](#guir3) — Base immediate-mode GUI (SDL2)
25. [input.r3](#inputr3) — Text input widget
26. [3d.r3](#3dr3) — 3D camera and projection
27. [3dgl.r3](#3dglr3) — 4×4 matrix stack for OpenGL
28. [isospr.r3](#isosprite3) — Isometric sprite rendering
29. [vdraw.r3](#vdrawr3) — Virtual (pixel-callback) drawing
30. [memshare.r3](#memsharepre3) — Cross-process shared memory
31. [memavx.r3](#memavxr3) — AVX-accelerated buffer conversion |WIN|
32. [netsock.r3](#netsockr3) — High-level socket wrapper
33. [webcam.r3](#webcamr3) — Webcam capture (cross-platform)
34. [escapi.r3](#escapir3) — Windows webcam capture (ESCAPI) |WIN|
35. [espeak-ng.r3](#espeaknr3) — Text-to-speech via libespeak-ng |WIN|
36. [glutil.r3](#glutilr3) — OpenGL utility helpers
37. [onnx.r3](#onnxr3) — ONNX runtime bindings |WIN|
38. [tflite.r3](#tfliter3) — TensorFlow Lite bindings |WIN|
39. [sdl2gl-const.r3](#sdl2glconstr3) — OpenGL constants (included by sdl2gl.r3)
40. [sdl2gl-constv.r3](#sdl2glconstvr3) — OpenGL constants, extended set

41. [clipboard.r3](#clipboardr3) — Clipboard (platform-provided)

### lib/win/ — Windows System Bindings
42. [win/core.r3](#wincorerr3) — File I/O, processes, file search
43. [win/kernel32.r3](#winkernel32r3) — Win32 API bindings
44. [win/clipboard.r3](#winclipboardr3) — Win32 clipboard
45. [win/win-term.r3](#wintermr3) — Windows console terminal
46. [win/inet.r3](#wineinetr3) — WinInet HTTP download
47. [win/winhttp.r3](#winhttpr3) — WinHTTP HTTP client
48. [win/winsock.r3](#winsockr3) — Winsock2 raw bindings
49. [win/ws2.r3](#ws2r3) — Winsock2 with ws2- prefix
50. [win/urlmon.r3](#urlmonr3) — URL download helper
51. [win/ffmpeg.r3](#ffmpegr3) — FFmpeg video playback |WIN|
52. [win/debugapi.r3](#debugapir3) — Windows debug API

### lib/posix/ — Linux System Bindings
53. [posix/core.r3](#posixcorerr3) — File I/O, filesystem
54. [posix/posix.r3](#posixposixr3) — POSIX syscall bindings
55. [posix/lin-term.r3](#lintermr3) — Linux terminal
56. [posix/clipboard.r3](#posixclipboardr3) — Linux clipboard stub

> **util/ libraries** (object pools, sorting, fonts, GUI, tile maps, etc.) are documented separately in `r3forth-util.md`.

---

## lib/ — Core Libraries

---

### math.r3

Fixed-point (48.16) arithmetic, trigonometry, statistics, and float32 conversion. Foundation library included by almost everything.

**No dependencies.**

#### Size Constants
```
##cell 8              -- cell size in bytes
```

#### Integer Helpers
```
::cell+   ( n -- n+8 )           add one cell
::ncell+  ( n -- n+(n*8) )       multiply by cell and add
::1+      ( n -- n+1 )
::1-      ( n -- n-1 )
::2/      ( n -- n/2 )           arithmetic shift right
::2*      ( n -- n*2 )           shift left
```

#### 48.16 Fixed-Point Arithmetic
All values with `.` suffix are 48.16 fixed-point (integer × 65536).
```
::*.s   ( a. b. -- c. )     fixed multiply, small numbers only
::*.    ( a. b. -- c. )     fixed multiply (standard)
::*.f   ( a. b. -- c. )     fixed multiply, full adjust (signed)
::/.    ( a. b. -- c. )     fixed divide
::2/.   ( a. -- a/2. )      fixed divide by 2, sign-corrected
::ceil  ( a. -- a )         ceiling to integer
::int.  ( a. -- a )         truncate fixed to integer (16>>)
::fix.  ( n -- n. )         integer to fixed-point (16<<)
::sign  ( v -- v s )        push sign: +1 or -1
```

#### Trigonometry (binary angles)
Binary angle: `0`=0°, `0.25`=90°, `0.5`=180°, `1.0`≈360°. Results are 48.16 fixed-point in range -1.0..1.0.
```
::sin       ( bangle -- r. )
::cos       ( bangle -- r. )
::tan       ( bangle -- r. )
::sincos    ( bangle -- sin. cos. )
::atan2     ( x y -- bangle )
::polar     ( bangle dist -- dx dy )      angle+distance → delta
::polar2    ( dist bangle -- dx dy )
::xy+polar  ( x y bangle r -- x' y' )    move point along angle
::xy+polar2 ( x y r ang -- x' y' )
::ar>xy     ( xc yc bangle r -- xc yc x y )   center + angle + radius → point
```

#### Distance and Geometry
```
::distfast  ( dx dy -- dist )    fast approximate 2D distance
::average   ( x y -- v )         bitwise average without overflow
```

#### Min/Max/Clamp
```
::min         ( a b -- m )
::max         ( a b -- m )
::clampmax    ( v max -- v )      clamp to maximum
::clampmin    ( v min -- v )      clamp to minimum
::clamp0      ( v -- v )          clamp to >= 0
::clamp0max   ( v max -- v )      clamp to 0..max
::clamps16    ( v -- v )          clamp to signed 16-bit range
::between     ( v min max -- f )  negative if outside, positive if inside
```

#### Advanced Math
```
::msb         ( n -- pos )       position of most significant bit
::sqrt.       ( x. -- r. )       square root (fixed-point)
::log2.       ( y. -- r. )       log base 2 (fixed-point)
::pow2.       ( y. -- r. )       2^y (fixed-point)
::pow.        ( x. y. -- r. )    x^y (fixed-point)
::root.       ( x. n -- r. )     nth root
::ln.         ( x. -- r. )       natural log
::exp.        ( x. -- r. )       e^x
::tanh.       ( x. -- r. )       hyperbolic tangent
::fastanh.    ( x. -- r. )       fast approximate tanh
::gamma.      ( x. -- r. )       gamma function
::beta.       ( x. y. -- r. )    beta function
::cubicpulse  ( c. w. x. -- v. ) Quilez cubic pulse
::pow         ( base exp -- r )  integer power
```

#### Bit Utilities
```
::bswap32   ( v -- vs )     byte-swap 32 bits
::bswap64   ( v -- vs )     byte-swap 64 bits
::nextpow2  ( v -- p2 )     next power of 2
```

#### Integer Multiply/Divide Shortcuts
```
::6*  ::6/  ::6mod
::10*   ::100*   ::1000*   ::10000*   ::100000*   ::1000000*
::10/   ::10/mod ( n -- q r )   ::1000000/
```

#### Float32 Conversions
```
::i2fp          ( i -- fp )         integer → float32
::f2fp          ( f. -- fp )        48.16 fixed → float32
::fp2f          ( fp -- f. )        float32 → 48.16 fixed
::fp2i          ( fp -- i )         float32 → integer
::fp16f         ( fp16 -- f. )      float16 → fixed-point
::f2fp24        ( f. -- fp )        48.16 fixed → float32 (40.24)
::fp2f24        ( fp -- f. )        float32 (40.24) → fixed
::byte>float32N ( byte -- float )   0..255 → 0.0..1.0 float32
::float32N>byte ( f32 -- byte )     0.0..1.0 float32 → 0..255
```

---

### dmath.r3

Double-precision 32.32 fixed-point math. Higher precision version of math.r3.

**Dependencies:** `^r3/lib/math.r3`, `^r3/lib/str.r3`

All `.d` words operate on 32.32 fixed-point values (integer × 2^32).

```
::*.d    ( a.d b.d -- c.d )     multiply
::*.df   ( a.d b.d -- c.d )     multiply, full sign adjust
::/.d    ( a.d b.d -- c.d )     divide
::ceil.d ( a.d -- a.d )         ceiling

-- Conversions --
::.d>i   ( a.d -- i )           to integer (32>>)
::i>.d   ( i -- a.d )           integer to 32.32 (32<<)
::f>.d   ( f. -- a.d )          48.16 fixed → 32.32
::.d>f   ( a.d -- f. )          32.32 → 48.16

-- Trig --
::sin.d  ( bangle -- r.d )
::cos.d  ( bangle -- r.d )
::tan.d  ( bangle -- r.d )
::tan.dc ( bangle -- r.d )      clamped tan

-- Higher math --
::sqrt.d  ( x.d -- r.d )
::log2.d  ( x.d -- r.d )
::pow2.d  ( y.d -- r.d )
::pow.d   ( x.d y.d -- r.d )
::root.d  ( x.d n -- r.d )
::ln.d    ( x.d -- ln(x).d )
::exp.d   ( x.d -- e^x.d )
::tanh.d  ( x.d -- r.d )
::gamma.d ( x.d -- r.d )
::beta.d  ( x.d y.d -- r.d )

```

---

### str.r3

String manipulation words. Strings are zero-terminated (C style).

**Dependencies:** `^r3/lib/math.r3`

```
-- Copy and Concatenate --
::strcpyl    ( src dst -- dst' )    copy string, return end pointer
::strcpy     ( src dst -- )         copy string
::strcat     ( src dst -- )         concatenate src onto dst
::strcpylnl  ( src dst -- dst' )    copy, strip newlines
::strcpyln   ( src dst -- )         copy, strip newlines
::copynom    ( src dst -- )         copy until space
::copystr    ( src dst -- )         copy until quote char
::strpath    ( src dst -- )         copy path component only (up to /)

-- Case --
::toupp  ( c -- C )   lowercase to uppercase
::tolow  ( C -- c )   uppercase to lowercase

-- Length / Count --
::count      ( str -- str cnt )       count bytes, leave str
::utf8count  ( str -- str count )     count UTF-8 characters
::utf8ncpy   ( str 'dst cnt -- 'dst ) copy n UTF-8 chars
::utf8bytes  ( str cnt -- str bytes ) byte count for n UTF-8 chars

-- Comparison --
::=     ( s1 s2 -- 0/1 )         equal? (case-sensitive)
::=s    ( s1 s2 -- 0/1 )         equal? (alias)
::=w    ( s1 s2 -- 0/1 )         equal? (word compare)
::cmpstr ( a b -- n )            compare: negative/0/positive
::=pre  ( adr "str" -- adr 0/1 ) starts with prefix?
::=pos  ( s1 ".pos" -- s1 0/1 ) ends with suffix?
::=lpos ( lstr ".pos" -- str 0/1) ends-with, lstr is end pointer

-- Search --
::findchar ( adr char -- adr'/0 ) find character, return pointer or 0
::findstr  ( adr "txt" -- adr'/0 ) find substring
::findstri ( adr "txt" -- adr'/0 ) find substring (case-insensitive)

-- Number Formatting --
::.d  ( val -- str )   format decimal integer to string
::.b  ( n -- str )     format binary to string
::.h  ( n -- str )     format hex to string
::.o  ( n -- str )     format octal to string
::.f  ( fix. -- str )  format 48.16 fixed-point as decimal
::.fd ( fix.d -- str ) format 32.32 to decimal string
```

---

### mem.r3

Heap memory management and formatted print words. Provides `here` as a bump-pointer allocator with mark/empty for temporary use.

**Dependencies:** `^r3/lib/str.r3`

```
##here  ( 'addr )  current heap top pointer

-- Store to Heap --
::,     ( v -- )     store 64-bit cell, advance here
::,c    ( c -- )     store byte
::,w    ( w -- )     store 16-bit word
::,q    ( q -- )     store 32-bit dword
::,s    ( str -- )   copy string to heap
::,word ( str -- )   copy string word to heap

-- Formatted Append to Heap --
::,2d   ( n -- )    append 2-digit decimal (zero-padded)
::,d    ( n -- )    append decimal integer
::,h    ( n -- )    append hex number
::,b    ( n -- )    append binary number
::,f    ( f. -- )   append fixed-point as decimal
::,ifp  ( i -- )    append integer as float32
::,ffp  ( f. -- )   append fixed-point as float32
::,cr   ( -- )      append CR (0x0d)
::,eol  ( -- )      append NUL
::,sp   ( -- )      append space
::,nl   ( -- )      append CR+LF
::,nsp  ( n -- )    append n spaces

-- Alignment --
::align32  ( mem -- mem' )   align to 32-byte boundary
::align16  ( mem -- mem' )   align to 16-byte boundary
::align8   ( mem -- mem' )   align to 8-byte boundary

-- Heap Management --
::mark      ( -- )          save current heap position
::empty     ( -- )          restore heap to last mark (free temporaries)
::savemem   ( "filename" -- )  save heap contents to file
::sizemem   ( -- size )      size of heap used
::memsize   ( -- mem size )  base address and size
::savememinc ( "filename" -- ) save heap incrementally
::cpymem    ( 'dest -- )     copy heap to destination
```

---

### parse.r3

Parse numbers and tokens from strings.

**Dependencies:** `^r3/lib/math.r3`, `^r3/lib/str.r3`

```
::str$>nro  ( adr -- adr' n )   parse hex number ($...)
::str%>nro  ( adr -- adr' n )   parse binary number (%..)
::str>nro   ( adr -- adr' n )   parse number (decimal, hex $, binary %)
::?sint     ( adr -- adr' n )   parse signed integer
::?numero   ( str -- 0 / str' n 1 )   parse number or fail
::?fnumero  ( str -- 0 / str' f. 1 )  parse fixed-point or fail
::str>fix   ( adr -- adr' f. )  parse fixed-point decimal
::getnro    ( adr -- adr' n )   get next number from string
::str>fnro  ( adr -- adr fnro ) parse float from string
::str>anro  ( adr -- adr anro ) parse alternate number
::getfenro  ( adr -- adr fnro ) get float or number
::isHex     ( adr -- 3/0 )      is hex number? (returns 3 or 0)
::isBin     ( adr -- 2/0 )      is binary number?
::isNro     ( adr -- t/0 )      is number? (1=dec 2=bin 3=hex 4=fix)
::scanp     ( adr "str" -- adr'/0 )  scan to pattern
::scanstr   ( adr 'str -- adr' )     scan matching string
::scannro   ( adr 'nro -- adr' )     scan and store number
::scanc     ( c adr -- adr'/0 )      scan to character
::scann     ( adr "str" -- adr' )    scan past delimiter string
```

---

### rand.r3

Random number generators. Two independent generators: a fast 8-bit one and a full 64-bit one.

**No dependencies.**

```
##seed8  ( initial seed )   seed for 8-bit generator
##seed   ( initial seed )   seed for 64-bit generator

::rand8       ( -- r8 )          fast 8-bit random [0..255]
::rerand      ( s1 s2 -- )       re-seed with two values
::rand        ( -- rand )        64-bit random
::randmax     ( max -- rand )    random [0..max)
::randminmax  ( min max -- rand ) random [min..max)
::rnd         ( -- rand )        alias for rand
::rndmax      ( max -- rand )    alias for randmax
::rndminmax   ( min max -- rand )
::rnd128      ( -- n )           128-bit style random
::loopMix128  ( -- rand )        loop-mix based random
```

---

### vec2.r3

2D vector math. Vectors are 2-cell structures `{x y}` (48.16 fixed-point).

**Dependencies:** `^r3/lib/math.r3`

```
::v2=   ( 'v1 'v2 -- )       v1 = v2
::v2+   ( 'v1 'v2 -- )       v1 = v1 + v2
::v2-   ( 'v1 'v2 -- )       v1 = v1 - v2
::v2+*  ( m 'v1 'v2 -- )     v1 = v1 + v2*m
::v2-*  ( m 'v1 'v2 -- )     v1 = v1 - v2*m
::v2*   ( 'v1 n -- )         v1 = v1 * n
::v2/   ( 'v1 n -- )         v1 = v1 / n
::v2len ( 'v -- m )          vector length
::v2nor ( 'v -- )            normalize to unit vector
::v2lim ( 'v lim -- )        limit vector length to lim
::v2rot ( 'v bangle -- )     rotate vector by binary angle
::v2dot ( 'v1 'v2 -- dot )   dot product
::v2perp ( 'v1 'v2 -- )      v2 = perpendicular of v1
```

---

### vec3.r3

3D vector math and quaternion operations. Vectors are 3-cell structures `{x y z}`.

**Dependencies:** `^r3/lib/math.r3`

```
-- 3D Vectors --
::v3len  ( v1 -- l )          vector length
::v3nor  ( v1 -- )            normalize in-place
::v3ddot ( v1 v2 -- r )       dot product
::v3vec  ( v1 v2 -- )         v1 = v1 × v2 (cross product)
::v3-    ( v1 v2 -- )         v1 = v1 - v2
::v3+    ( v1 v2 -- )         v1 = v1 + v2
::v3*    ( v1 s -- )          v1 = v1 * scalar
::v3=    ( v1 v2 -- )         v1 = v2

::normInt2Fix  ( x y z -- xf yf zf )  normalize integers to fixed-point
::normFix      ( x y z -- x y z )     normalize fixed-point vector

-- Quaternions (4-cell: x y z w) --
::q4=    ( q1 q2 -- )         q1 = q2
::q4W    ( q dest -- )         extract W component
::q4dot  ( q1 q2 -- dot )     dot product
::q4inv  ( q1 q2d -- )        q2d = inverse of q1
::q4conj ( q1 q2d -- )        q2d = conjugate of q1
::q4len  ( q -- len )          length
::q4nor  ( q -- )              normalize quaternion
```

---

### color.r3

Color space conversions, blending, and manipulation. Colors are packed 32-bit ARGB.

**Dependencies:** `^r3/lib/math.r3`

```
-- Byte Order --
::swapcolor  ( color -- color' )     swap R and B channels
::bgr2rgb    ( BGR -- RGB )          BGR to RGB

-- Mixing --
::colavg   ( a b -- c )             average two colors
::col50%   ( c1 c2 -- c )           50% blend
::col25%   ( c1 c2 -- c )           25% c1, 75% c2
::col33%   ( c1 c2 -- c )           33% c1, 66% c2
::colmix   ( c1 c2 a -- c )         blend by alpha a (0..255)
::colmix4  ( c1 c2 a -- c )         blend (channel-wise)
::blend2   ( c1 c2 i -- c )         blend (i=0..255)
::diffrgb2 ( a b -- v )             RGB squared difference

-- Color Shading --
::shadow4  ( color shadow -- color )  darken by shadow amount (4-bit)
::light4   ( color light -- color )   lighten (4-bit)
::shadow8  ( color shadow -- color )  darken (8-bit)
::light8   ( color light -- color )   lighten (8-bit)

-- Color Space Conversions --
::rgb2yuv   ( rgb -- yuv )
::yuv2rgb   ( yuv -- rgb )
::yuv32     ( yuv -- col )           YUV to 32-bit color
::hsv2rgb   ( h s v -- rgb32 )       HSV to 32-bit RGB
::rgb2hsv   ( argb -- h s v )        RGB to HSV
::rgb2ycocg ( r g b -- y co cg )     RGB to YCoCg
::ycocg2rgb ( y co cg -- r g b )
::rgb2ycc   ( RGB -- y co cg )       packed RGB to YCoCg
::rgb2yuv2  ( g b r -- y u v )
::yuv2rgb2  ( y u v -- g b r )
::RGB>Gbr   ( R G B -- G b r )
::Gbr>RGB   ( G b r -- R G B )
::RGB2YCoCg24 ( r g b -- Y co cg )  24-bit version
::YCoCg242RGB ( Y co cg -- r g b )

-- Packed Color Helpers --
::b2color   ( col -- color )         byte to 32-bit color
::4bcol     ( col -- color )         4-byte packed to color
::4bicol    ( col -- color )         4-byte packed (interleaved) to color
```

---

### jul.r3

Julian day number calculations for date arithmetic.

**No dependencies.**

```
::date2jul     ( d m y -- jul )       calendar date to Julian day
::jul2date     ( jul -- d m y )       Julian day to calendar date
::date2day     ( d m y -- num )       day of week number
::jul2day      ( jul -- num )         Julian day to day of week
::date2daystr  ( d m y -- )           print day name
::jul2daystr   ( jul -- )             print day name from Julian
```

---

### console.r3

Terminal I/O with ANSI escape sequences. Uses buffered output for performance. All `.` prefix words output to the console buffer.

**Dependencies:** `^r3/lib/mem.r3`, `^r3/lib/parse.r3`

#### Key Code Constants
Named constants for ANSI/VT key sequences: `[ESC]`, `[ENTER]`, `[BACK]`, `[TAB]`, `[DEL]`, `[INS]`, `[UP]`, `[DN]`, `[RI]`, `[LE]`, `[PGUP]`, `[PGDN]`, `[HOME]`, `[END]`, `[F1]`..`[F12]`, `[SHIFT+*]` variants.

#### Output Buffer
```
::.cl      ( -- )              clear output buffer
::.flush   ( -- )              flush buffer to stdout
::.type    ( str cnt -- )      add bytes to buffer
::.emit    ( char -- )         emit single character
::.cr      ( -- )              carriage return + newline
::.sp      ( -- )              space
::.nch     ( char n -- )       emit character n times
::.write   ( str -- )          write counted string
::.print   ( str -- )          print string (zero-terminated)
::.println ( str -- )          print + CR + flush
::.fwrite  ( str -- )          write + flush
::.fprint  ( str -- )          print + flush
::.rep     ( cnt "char" -- )   repeat character
```

#### Cursor Movement
```
::.home     ( -- )             cursor to home (1,1)
::.cls      ( -- )             clear screen
::.at       ( x y -- )         move cursor to column x, row y
::.col      ( x -- )           move cursor to column x
::.savec    ( -- )             save cursor position
::.restorec ( -- )             restore cursor position
::.eline    ( -- )             erase from cursor to end of line
::.ealine   ( -- )             erase entire line
::.escreen  ( -- )             erase from cursor to end of screen
::.escreenup ( -- )            erase from cursor to screen top
::.nsp      ( n -- )           erase n characters forward
```

#### Cursor Style
```
::.showc    ( -- )    show cursor
::.hidec    ( -- )    hide cursor
::.blc      ( -- )    blinking cursor
::.unblc    ( -- )    non-blinking
::.ovec     ( -- )    default cursor shape
::.insc     ( -- )    blinking bar (insert mode)
::.blockc   ( -- )    steady block
::.underc   ( -- )    steady underscore
```

#### Screen Buffers and Scrolling
```
::.alsb      ( -- )           switch to alternate screen buffer
::.masb      ( -- )           return to main screen buffer
::.scrolloff ( rows -- )      set scroll region
::.scrollon  ( -- )           reset scroll region
```

#### ANSI Colors
Standard foreground: `.Black` `.Red` `.Green` `.Yellow` `.Blue` `.Magenta` `.Cyan` `.White` (and bright variants with `l` suffix).
Standard background: `.BBlack` `.BRed` `.BGreen` `.BYellow` `.BBlue` `.BMagenta` `.BCyan` `.BWhite`.
```
::.fc   ( n -- )           256-color foreground (0..255)
::.bc   ( n -- )           256-color background
::.fgrgb ( r g b -- )      24-bit RGB foreground
::.bgrgb ( r g b -- )      24-bit RGB background
```

#### Text Attributes
`.Bold` `.Dim` `.Italic` `.Under` `.Blink` `.Rever` `.Hidden` `.Strike` `.Reset`

#### Input
```
::getch      ( -- key )     wait for a keypress
::waitesc    ( -- )         wait for ESC key
::waitkey    ( -- )         wait for any key
##pad                       128-byte input scratch buffer
::.input     ( -- )         read line of input into pad
::.printe    ( "" -- )      print with escape processing
::strcpybuf  ( 'mem -- )    copy pad to memory
```

---

### trace.r3

Debug tracing and memory dump utilities. Outputs to console.

**Dependencies:** `^r3/lib/console.r3`

```
::<<trace    ( -- )            print stack contents
::<<traceh   ( -- )            print stack in hex
::<<memdump  ( adr cnt -- )    hex dump of memory region
::<<memdumpc ( adr cnt -- )    hex dump with ASCII
::clearlog   ( -- )            clear log
::filelog    ( .. str -- )     write formatted data to log file
::<<memmap   ( inimem -- )     display memory map from base
```

---

### crc32.r3

Checksum algorithms.

**No dependencies.**

```
::crc32   ( a n -- u )       CRC32 of n bytes at address a
::crc32n  ( a n p -- u )     CRC32 with initial polynomial p
::adler32 ( a n -- u )       Adler-32 checksum
```

---

### base64.r3

Base64 encoding and decoding.

**Dependencies:** `^r3/lib/math.r3`

```
::base64decode  ( src dest -- 'dest )    decode base64 string to binary
::base64encode  ( len src dest -- 'dest ) encode binary to base64 string
```

---

### sdl2.r3

SDL2 window creation, renderer, textures, events, and audio. Core SDL2 binding — all graphics libraries depend on this.

**Dependencies:** `|WIN|^r3/lib/win/core.r3` or `|LIN|^r3/lib/posix/core.r3`, `^r3/lib/console.r3`, `^r3/lib/sdlkeys.r3`

#### Global State
```
##SDL_windows      window handle
##SDLrenderer      renderer handle
##sw ##sh          screen width and height (fixed-point friendly)
##SDLevent * 56    event buffer
##SDLkey           last key from event
##SDLchar          last character from event
##SDLx ##SDLy      mouse x, y
##SDLb             mouse button state
##SDLw             mouse wheel
##.exit 0          set non-zero to quit
```

#### Initialization
```
::SDLinit    ( "title" w h -- )           create window and renderer
::SDLmini    ( "title" w h -- )           create without fullscreen option
::SDLinitScr ( "title" display w h -- )   multi-monitor init
::sdlinitR   ( "title" w h -- )           resizable window
::SDLfullw   ( "title" display -- )       fullscreen on display
::SDLfull    ( -- )                       toggle fullscreen
::SDLquit    ( -- )                       destroy renderer and window
```

#### Main Loop
```
::SDLshow    ( 'word -- )    run main loop calling 'word each frame
::SDLeventR  ( 'vec -- )     set event handler vector
::SDLupdate  ( -- )          present renderer, poll events
::SDLredraw  ( -- )          mark screen dirty / force redraw
::SDLClick   ( 'event -- )   register click handler
::exit       ( -- )          request application exit
::sdlbreak   ( -- )          break on F12, exit on ESC
::%w  ( -- w. )              screen width as fixed-point fraction
::%h  ( -- h. )              screen height as fixed-point fraction
```

#### Texture and Surface Management
```
::SDLframebuffer  ( w h -- texture )    create framebuffer texture
::SDLblend        ( -- )                enable alpha blending
::SDLTexwh        ( tex -- w h )        get texture dimensions
```

#### Raw SDL2 Bindings
Direct wrappers for: `SDL_Init`, `SDL_Quit`, `SDL_CreateWindow`, `SDL_CreateRenderer`, `SDL_CreateTexture`, `SDL_DestroyTexture`, `SDL_DestroyRenderer`, `SDL_UpdateTexture`, `SDL_RenderClear`, `SDL_RenderCopy`, `SDL_RenderCopyEx`, `SDL_RenderPresent`, `SDL_SetRenderDrawColor`, `SDL_PollEvent`, `SDL_GetTicks`, `SDL_Delay`, `SDL_GL_*`, `SDL_OpenAudioDevice`, `SDL_QueueAudio`, `SDL_GetClipboardText`, `SDL_SetClipboardText`, and many more.

---

### sdl2gfx.r3

SDL2 2D drawing primitives, sprite/tileset system.

**Dependencies:** `^r3/lib/sdl2.r3`, `^r3/lib/sdl2image.r3`

#### Color and State
```
::SDLColor   ( col -- )         set draw color (RGB packed)
::SDLColorA  ( col -- )         set draw color with alpha
::SDLcls     ( color -- )       clear screen with color
```

#### Drawing Primitives
```
::SDLPoint    ( x y -- )         draw point
::SDLGetPixel ( x y -- v )       get pixel color
::SDLLine     ( x1 y1 x2 y2 -- ) draw line
::SDLLineH    ( x y x2 -- )      horizontal line
::SDLLineV    ( x y y2 -- )      vertical line
::SDLRect     ( x y w h -- )     draw hollow rectangle
::SDLFRect    ( x y w h -- )     draw filled rectangle
::SDLEllipse  ( rx ry x y -- )   draw hollow ellipse
::SDLFEllipse ( rx ry x y -- )   draw filled ellipse
::SDLTriangle ( x1 y1 x2 y2 x3 y3 -- )  draw filled triangle
::SDLRound    ( r x y w h -- )   draw rounded rectangle (hollow)
::SDLFRound   ( r x y w h -- )   draw rounded rectangle (filled)
::SDLCircle   ( r x y -- )       draw circle
::SDLFCircle  ( r x y -- )       draw filled circle
```

#### Image and Texture Drawing
```
::SDLImage    ( x y img -- )          draw texture at x,y
::SDLImages   ( x y w h img -- )      draw texture stretched to w×h
::SDLImageb   ( box img -- )          draw texture to box rect
::SDLImagebb  ( srcbox dstbox img -- ) draw sub-region to box
```

#### Tileset System
Tileset: a single image divided into equal-sized tiles. Each tile has an index `n`.
```
::tsload   ( w h "filename" -- ts )   load image as tileset with w×h pixel tiles
::tscolor  ( rrggbb 'ts -- )          set RGB color modulation on tileset
::tsalpha  ( alpha 'ts -- )           set alpha modulation
::tsdraw   ( n 'ts x y -- )           draw tile n centered at x,y
::tsdraws  ( n 'ts x y w h -- )       draw tile n stretched to w×h at x,y
::tsbox    ( 'boxsrc n 'ts -- )       fill a destination box with the source rect of tile n
::tsfree   ( ts -- )                  free tileset texture
```

#### Single-Image Sprite Drawing
Draw textures with optional rotation and zoom, centered on the given point.
```
::sprite   ( x y img -- )              draw texture centered at x,y
::spriteZ  ( x y zoom img -- )         draw texture centered, scaled by zoom (48.16)
::spriteR  ( x y ang img -- )          draw texture centered, rotated by binary angle
::spriteRZ ( x y ang zoom img -- )     draw texture centered, rotated and scaled
```

#### Sprite-Sheet (ssload) System
Sprite-sheet: all frames packed into one image in a grid. Frames are addressed by index `n` inside the sheet. UV coordinates are pre-computed at load time for GPU efficiency.
```
::ssload     ( w h "file" -- ssprite )      load image as sprite-sheet with w×h pixel cells
::sspritewh  ( ssprite -- w h )             get cell size of a sprite-sheet
::ssprite    ( x y n ssprite -- )           draw frame n centered at x,y
::sspriter   ( x y ang n ssprite -- )       draw frame n centered, rotated by binary angle
::sspritez   ( x y zoom n ssprite -- )      draw frame n centered, scaled by zoom (48.16)
::sspriterz  ( x y ang zoom n ssprite -- )  draw frame n centered, rotated and scaled
::sstint     ( AARRGGBB -- )                set tint color (with alpha) for next ssprite draw
::ssnotint   ( -- )                         reset tint to white ($ffffffff)
```

#### Surface and Texture Composition
```
::createSurf  ( w h -- surface )       create an ARGB software surface
::Surf>pix    ( surface -- surf px )   get pixel data pointer
::Surf>wha    ( surface -- surf 'wh )  get pointer to w/h fields
::Surf>wh     ( surface -- surf w h )  get surface dimensions
::Surf>pixpi  ( surface -- 'px pitch ) get pixel pointer and row pitch
::texIni      ( w h -- )               begin render-to-texture of size w×h
::texEnd      ( -- texture )           end render-to-texture, return texture
::texEndAlpha ( -- texture )           end render-to-texture with alpha blend enabled
::Tex2Surface ( tex -- tex surface )   copy GPU texture back to a software surface
::Tex2Static  ( tex -- newtex )        convert streaming texture to static
```
---

### sdl2image.r3

SDL2_image bindings: load PNG, JPG, SVG, and animated images.

**Dependencies:** `^r3/lib/sdl2.r3`

```
::IMG_Load           ( "file" -- surface )       load image as surface
::IMG_LoadTexture    ( rend "file" -- texture )  load directly as texture
::IMG_LoadSizedSVG_RW ( src w h -- surface )     load SVG at size
::IMG_LoadAnimation  ( "file" -- anim )          load animated image
::IMG_FreeAnimation  ( anim -- )
::IMG_SavePNG        ( surface "file" -- )
::IMG_SaveJPG        ( surface "file" quality -- )

-- High-level helpers --
::loadimg   ( "filename" -- texture )  load image as texture
::unloadimg ( adr -- )                 free texture
::loadsvg   ( w h "filename" -- tex )  load SVG as texture
```

---

### sdl2ttf.r3

SDL2_ttf bindings for TrueType font rendering.

**Dependencies:** `|WIN|^r3/lib/win/core.r3` or `|LIN|^r3/lib/posix/core.r3`

Direct wrappers: `TTF_Init`, `TTF_Quit`, `TTF_OpenFont`, `TTF_CloseFont`, `TTF_SetFontStyle`, `TTF_SetFontSize`, `TTF_SetFontSDF`, `TTF_SetFontOutline`, `TTF_SetFontLineSkip`, `TTF_SizeText`, `TTF_SizeUTF8`, `TTF_MeasureUTF8`, `TTF_RenderText_Solid`, `TTF_RenderUTF8_Solid`, `TTF_RenderUTF8_Blended`, `TTF_RenderUTF8_Blended_Wrapped`, `TTF_RenderUNICODE_Blended`.

---

### sdl2mixer.r3

SDL2_mixer bindings for audio playback.

**Dependencies:** `^r3/lib/sdl2.r3`

```
-- Raw bindings --
::Mix_Init          ::Mix_Quit
::Mix_OpenAudio     ( freq format channels bufsize -- )
::Mix_CloseAudio    ( -- )
::Mix_LoadWAV       ( "file" -- chunk )
::Mix_LoadMUS       ( "file" -- music )
::Mix_FreeChunk     ( chunk -- )
::Mix_FreeMusic     ( music -- )
::Mix_PlayChannelTimed ( channel chunk loops ticks -- )
::Mix_HaltChannel   ( channel -- )
::Mix_FadeOutChannel ( channel ms -- )
::Mix_PlayMusic     ( music loops -- )
::Mix_HaltMusic     ( -- )
::Mix_FadeOutMusic  ( ms -- )
::Mix_VolumeMusic   ( vol -- )
::Mix_PlayingMusic  ( -- 0/1 )
::Mix_Playing       ( channel -- 0/1 )
::Mix_MasterVolume  ( vol -- )

-- High-level helpers --
::SNDInit    ( -- )            initialize audio system
::SNDplay    ( adr -- )        play sound chunk on any channel
::SNDplayn   ( channel adr -- ) play on specific channel
::SNDQuit    ( -- )            quit audio
```

---

### sdl2net.r3

SDL2_net bindings for TCP and UDP networking.

**Dependencies:** `|WIN|^r3/lib/win/core.r3` or `|LIN|^r3/lib/posix/core.r3`

Direct wrappers: `SDLNet_Init`, `SDLNet_Quit`, `SDLNet_ResolveHost`, `SDLNet_ResolveIP`, `SDLNet_TCP_Open`, `SDLNet_TCP_OpenServer`, `SDLNet_TCP_OpenClient`, `SDLNet_TCP_Accept`, `SDLNet_TCP_Send`, `SDLNet_TCP_Recv`, `SDLNet_TCP_Close`, `SDLNet_UDP_Open`, `SDLNet_UDP_Send`, `SDLNet_UDP_Recv`, `SDLNet_UDP_Close`, `SDLNet_AllocPacket`, `SDLNet_FreePacket`.

---

### sdl2poly.r3

Polygon and thick-line drawing (on top of sdl2gfx).

**Dependencies:** `^r3/lib/sdl2gfx.r3`

```
::SDLop    ( x y -- )        begin polygon / set origin
::SDLop2   ( x y -- )        set second point
::SDLpline ( x y -- )        polygon: move to next vertex
::SDLpoly  ( -- )            close and draw polygon
::SDLFngon ( ang n r x y -- ) draw filled regular n-gon
::SDLngon  ( ang n r x y -- ) draw hollow regular n-gon

-- Thick lines --
::linegr!  ( grosor -- )     set line thickness (in pixels)
::linegr   ( -- grosor )     get line thickness
::gop      ( x y -- )        start thick polyline
::gline    ( x y -- )        extend thick polyline
```

---

### sdl2gl.r3

OpenGL bindings accessed via SDL2's GL context.

**Dependencies:** `^r3/lib/sdl2.r3`

Direct wrappers for: `glCreateProgram`, `glCreateShader`, `glShaderSource`, `glCompileShader`, `glGetShaderiv`, `glAttachShader`, `glGetAttribLocation`, `glGenBuffers`, `glBindBuffer`, `glBufferData`, `glBufferSubData`, `glClearColor`, `glClear`, `glUseProgram`, `glValidateProgram`, `glEnableVertexAttribArray`, `glVertexAttribPointer`, `glDrawElements`, `glDrawArrays`, `glDrawArraysInstanced`, `glMapBuffer`, `glUnmapBuffer`, `glGetUniformBlockIndex`, `glUniformBlockBinding`, `glBindBufferBase`, `glGetTexImage`, and more.

---

### sdlkeys.r3

SDL2 keyboard scancode constants.

**No dependencies.**

⚠️ Runtime binding — constants defined via SDL2 event system. Used by `sdl2.r3` and `input.r3`. Provides named constants for all SDL_Scancode values.

---

### gui.r3

Base immediate-mode GUI framework for SDL2. Handles hot/focused state and input routing.

**Dependencies:** `^r3/lib/sdl2.r3`

```
##xr1 ##yr1 ##xr2 ##yr2   current widget rect (set by guiBox/guiRect)
##foco                     keyboard-focused widget ID
##clkbtn                   last clicked button
##idf                      current keyboard focus ID
##idl                      last focus ID
##guin?                    mouse-in-rect predicate (for custom checks)

-- Widget Region Setup --
::gui         ( -- )               call each frame; updates internal state
::guiBox      ( x1 y1 w h -- )    set widget region by position+size
::guiRect     ( x1 y1 x2 y2 -- )  set widget region by coords
::guiPrev     ( -- )               reuse previous widget ID

-- Event Handlers (call after guiBox/guiRect) --
::onClick      ( 'click -- )       execute 'click on mouse click
::onClickFoco  ( -- )              click = give focus
::onMove       ( 'move -- )        execute while mouse hovers
::onMoveA      ( 'move -- )        execute while mouse hovers (any position)
::onDnMove     ( 'dn 'move -- )    down callback + drag callback
::onDnMoveA    ( 'dn 'move -- )    drag always (even outside widget)
::onMap        ( 'dn 'move 'up -- ) full press/drag/release
::onMapA       ( 'dn 'move 'up -- ) drag always

-- Input/Output Vectors --
::guiI   ( 'vector -- )    read from vector on keyboard focus
::guiO   ( 'vector -- )    write to vector on keyboard focus
::guiIO  ( 'vi 'vo -- )    combined read+write

-- Focus Management --
::nextfoco      ( -- )        move focus to next widget
::prevfoco      ( -- )        move focus to previous widget
::setfoco       ( n -- )      set focus to widget n
::clickfoco     ( -- )        click = set focus
::refreshfoco   ( -- )        refresh focus state
::focovoid      ( -- )        clear focus
::esfoco?       ( -- 0/1 )    is current widget focused?
::w/foco        ( 'in 'start -- )  execute with focus
::in/foco       ( 'in -- )    execute only when focused
::lostfoco      ( 'acc -- )   execute when focus lost
```

---

### input.r3

Text input line editor widget (uses bfont for display).

**Dependencies:** `^r3/util/bfont.r3`, `^r3/lib/sdlkeys.r3`, `^r3/lib/gui.r3`

```
::input      ( 'var max -- )            single-line text input
::inputex    ( 'vector 'var max -- )    input with external event handler
::inputdump  ( -- )                     print current input state
::inputint   ( 'var -- )                integer input field
::tbtn       ( 'ev "text" -- )          text button with keyboard activation
```

---

### 3d.r3

3D camera projection system. Works with 3dgl.r3 matrix stack.

**Dependencies:** `^r3/lib/sdl2.r3`, `^r3/lib/3dgl.r3`

```
##xf ##yf     focal distances (x, y)
##ox ##oy     screen offset (center)

-- Camera Modes --
::2dmode    ( -- )             disable projection (pass-through)
::3dmode    ( fov -- )         perspective projection with FOV
::Omode     ( -- )             orthographic projection
::whmode    ( w h -- )         set by viewport size
::o3dmode   ( w h -- )         orthographic from width×height

-- Projection Words --
::p3d     ( x y z -- x' y' )          perspective project
::p3dz    ( x y z -- x' y' z )        project + keep z
::p3di    ( x y z -- z y' x' )        inverse order output
::p3d1    ( x y z -- x' y' )          alternative projection
::project  ( x y z -- u v )           apply matrix then project
::projectv ( x y z -- u v )           project with view matrix
::invproject3d ( x y z -- x' y' )     inverse projection
::project3d   ( x y z -- u v )        full 3D projection
::project3dz  ( x y z -- z x' y' )   project with depth
::projectdim  ( x y z -- u v )        dimensioned projection
::proyect2d   ( x y z -- x' y' )      2D-equivalent projection
::inscreen    ( -- x y )              get current screen position
::aspect      ( -- a )                screen aspect ratio

-- Transform Matrix Helpers --
::mtrans  ( x y z -- )     post-multiply translation
::mtransi ( x y z -- )     pre-multiply translation
::mrotxi  ( x -- )         pre-multiply X rotation
::mrotyi  ( y -- )         pre-multiply Y rotation
::mrotzi  ( z -- )         pre-multiply Z rotation
```

---

### 3dgl.r3

4×4 matrix stack for OpenGL transformations. Stack depth: 20 matrices.

**Dependencies:** `^r3/lib/vec3.r3`

```
##mat>    current matrix pointer (into matrix stack 'mats)

-- Stack Management --
::matini      ( -- )           initialize identity matrix
::matinim     ( 'mat -- )      initialize from matrix
::mpush       ( -- )           push new identity matrix
::mpushi      ( -- )           push preserving current
::mpop        ( -- )           pop matrix
::nmpop       ( n -- )         pop n matrices

-- Float Export --
::getfmat     ( -- fmat )      get current matrix as float32 array
::gettfmat    ( -- fmat )      get transposed float32 matrix
::mcpyf       ( fmat -- )      copy float32 matrix to memory
::mcpyft      ( fmat -- )      copy transposed
::midf        ( fmat -- )      set identity matrix in float buffer

-- Projection Setup --
::mperspective ( near far cotang aspect -- )  perspective matrix
::mortho       ( r l t b f n -- )             orthographic matrix
::mlookat      ( eye to up -- )               look-at matrix

-- Translations --
::mtran   ( x y z -- )    translate (post-multiply)
::mtranx  ( x -- )        translate X only
::mtrany  ( y -- )
::mtranz  ( z -- )

-- Rotations --
::mrotx   ( rx -- )       rotate around X
::mroty   ( ry -- )
::mrotz   ( rz -- )
::mrotxyz ( x y z -- )    rotate XYZ Euler
::mrotxyzi ( x y z -- )   rotate XYZ (pre-multiply)
::calcrot  ( rx ry rz -- )
::calcvrot ( rx ry rz -- )
::makerot  ( x y z -- x' y' z' )  apply rotation
::matqua   ( 'quat -- )   set rotation from quaternion

-- Scale --
::mscale   ( x y z -- )   scale (post)
::mscalei  ( x y z -- )   scale (pre)
::muscalei ( s -- )        uniform scale (pre)

-- Transform Points --
::transform    ( x y z -- x' y' z' )  apply current matrix
::transformr   ( x y z -- x' y' z' )  apply rotation only
::ztransform   ( x y z -- z )          Z component only
::oztransform  ( -- z )                Z without input
::oxyztransform ( -- x y z )           output only

-- Matrix Operations --
::matinv       ( -- )           invert current matrix
::mcpy         ( 'mat -- )      copy 'mat into current
::m*           ( -- )           multiply top two matrices → new
::mm*          ( 'mat -- )      multiply by 'mat
::mmi*         ( 'mat -- )      pre-multiply by 'mat

-- Convenience Aliases --
::mtra  ( x y z -- )    translate
::mrot  ( rx ry rz -- ) rotate Euler
::mpos  ( x y z -- )    set position
::mrpos ( r16 x y z -- ) packed rotation + position

-- Packed Rotation/Position --
::packrota  ( rx ry rz -- rp )     pack 3 rotations into one value
::+rota     ( ra rb -- rr )        add packed rotations
::pack21    ( vx vy vz -- vp )     pack 3 vectors into one
::+p21      ( va vb -- vr )        add packed vectors
```

---

### isospr.r3

Isometric sprite rendering system with z-sort.

**Dependencies:** `^r3/lib/sdl2gfx.r3`

```
##isang 0.22     isometric x-angle
##isalt 0.28     isometric y-angle (altitude factor)
##isxo           screen x offset for isometric origin
##isyo           screen y offset for isometric origin

::xyz2iso  ( x y z -- x' y' )    3D iso coords → screen coords
::2iso     ( x y z -- x' y' )    alias
::isocam   ( -- )                 set camera to isometric defaults
::resetcam ( -- )                 reset camera
::loadss   ( w h "file" -- ss )   load sprite sheet
::isospr   ( x y a z 'ss -- )     draw isometric sprite (angle a, z-depth z)
```

---

### vdraw.r3

Virtual drawing surface with pluggable set/get pixel callbacks. Used for off-screen rendering into arbitrary buffers.

**Dependencies:** `^r3/lib/mem.r3`, `^r3/lib/math.r3`

```
::vset! ( 'set -- )          set pixel callback: ( x y color -- )
::vget! ( 'get -- )          get pixel callback: ( x y -- color )
::vsize! ( w h -- )          set virtual canvas dimensions

::vop      ( x y -- )        set current pen position
::vline    ( x y -- )        draw line from pen to x,y
::vfill    ( c x y -- )      fill region with color c from x,y
::vrect    ( x1 y1 x2 y2 -- )  hollow rectangle
::vfrect   ( x1 y1 x2 y2 -- )  filled rectangle
::vellipse   ( rx ry x y -- )   hollow ellipse
::vellipseb  ( rx ry x y -- )   filled ellipse
```

---

### memshare.r3

Cross-process shared memory mapping (Windows and Linux).

**Dependencies:** `^r3/lib/mem.r3`

Structure layout: `offset 0`=map handle, `8`=file handle, `16`=size, `24`=filename.

```
::inisharev  ( 'varshare -- )   open or create shared memory mapping
::endSharev  ( 'varshare -- )   close shared memory mapping
```

---

### memavx.r3

AVX-accelerated buffer conversions between float32, fixed-point 48.16, and packed RGB. |WIN| only.

**Dependencies:** `^r3/lib/win/kernel32.r3`

⚠️ Loads `memavx.dll` at runtime. Specific exported word names depend on DLL version. Used for high-speed image data type conversion (e.g., float arrays to/from pixel buffers).

---

### netsock.r3

High-level cross-platform TCP socket wrapper.

**Dependencies:** `^r3/lib/mem.r3`, `|LIN|^r3/lib/posix/posix.r3`

```
::socket-ini          ( -- )              initialize network (WSAStartup on Win)
::socket-end          ( -- )              cleanup
::socket-create       ( family type proto -- sock )
::socket-set-nonblock ( sock -- result )
::socket-set-reuseaddr ( sock -- result )
::socket-bind         ( sock addr port -- result )
::socket-listen       ( sock backlog -- result )
::socket-accept       ( sock addr addrlen -- newsock )
::socket-connect      ( sock addr addrlen -- result )
::socket-send         ( sock data len flags -- bytes )
::socket-recv         ( sock buf len flags -- bytes )
::socket-close        ( sock -- result )
::net-addr-to-int     ( "ip-string" -- addr )
::net-htons           ( port -- network_port )
::net-get-last-error  ( -- error_code )
::server-socket       ( port -- sock )    create listening server socket
::client-socket       ( -- sock )         create client socket
::socket-final        ( sock -- )         close and cleanup
```

---

### webcam.r3

Cross-platform webcam capture via `webcam.dll`/`.so`.

**No dependencies.**

```
-- Format Constants --
##WEBCAM_FMT_RGB24  ##WEBCAM_FMT_RGB32  ##WEBCAM_FMT_YUYV
##WEBCAM_FMT_YUV420  ##WEBCAM_FMT_MJPEG

-- Parameter Constants --
##WEBCAM_PARAM_BRIGHTNESS  ##WEBCAM_PARAM_CONTRAST  ##WEBCAM_PARAM_SATURATION
##WEBCAM_PARAM_EXPOSURE  ##WEBCAM_PARAM_FOCUS  ##WEBCAM_PARAM_ZOOM
##WEBCAM_PARAM_GAIN  ##WEBCAM_PARAM_SHARPNESS

-- API --
::webcam_list_devices     ( 'count -- 'devlist )
::webcam_free_list        ( 'devlist -- )
::webcam_query_capabilities ( devname -- 'caps )
::webcam_free_capabilities  ( 'caps -- )
::webcam_find_best_format   ( 'caps w h fmt -- 'format )
::webcam_open             ( devname w h fmt -- handle )
::webcam_capture          ( handle 'frame -- 0/1 )
::webcam_release_frame    ( handle -- )
::webcam_close            ( handle -- )
::webcam_get_actual_width  ( handle -- w )
::webcam_get_actual_height ( handle -- h )
::webcam_get_format        ( handle -- fmt )
::webcam_get_parameter     ( handle param -- value )
::webcam_set_parameter     ( handle param value -- )
::webcam_set_auto          ( handle param auto -- )
::webcam_set_conversion_size ( handle w h -- )
::webcam_get_converted_frame ( handle 'buf sz -- 'frame )
```

---

### escapi.r3

Windows webcam capture via the ESCAPI library (`dll/escapi.dll`, [jarikomppa/escapi](https://github.com/jarikomppa/escapi)). |WIN|

**Dependencies:** `^r3/lib/win/kernel32.r3`

```
::setupESCAPI          ( -- ndevices )        init COM + return device count (calls initCOM + countCaptureDevices)
::countCaptureDevices  ( -- n )                number of capture devices found
::initCOM              ( -- )                  init COM (called by setupESCAPI)
::initCapture           ( devicenum 'params -- r )   start capture on device, r=0 on failure
::doCapture             ( handle -- )           request a frame capture (async)
::isCaptureDone         ( handle -- r )          poll: r=1 when the requested frame is ready
::deinitCapture         ( handle -- r )          stop capture on device
::getCaptureProperty    ( handle prop a b c d e -- )   get a capture property (see CAPTURE_* constants below)
::setCaptureProperty    ( handle prop val autoflag -- )   set a capture property

-- Capture Properties (property index for get/setCaptureProperty) --
CAPTURE_BRIGHTNESS  CAPTURE_CONTRAST   CAPTURE_HUE          CAPTURE_SATURATION
CAPTURE_SHARPNESS   CAPTURE_GAMMA      CAPTURE_COLORENABLE  CAPTURE_WHITEBALANCE
CAPTURE_BACKLIGHTCOMPENSATION  CAPTURE_GAIN  CAPTURE_PAN  CAPTURE_TILT
CAPTURE_ROLL  CAPTURE_ZOOM  CAPTURE_EXPOSURE  CAPTURE_IRIS  CAPTURE_FOCUS
```

`'params` is a `SimpleCapParams` struct: `int* mTargetBuf; int mWidth; int mHeight;` — allocate it and set the target buffer/size before calling `initCapture`.

> **Note:** `getCaptureDeviceName` is declared (`#getCaptureDeviceName_p`) and its DLL pointer is resolved at load time, but the word itself isn't actually wired up to a `sysN` call in the current source — as written it just pushes the raw function-pointer value rather than invoking it. Looks like an incomplete/unused stub in the library itself, not a doc error.

**Typical use:** `setupESCAPI` → allocate a `SimpleCapParams` → `initCapture` → loop: `doCapture`, poll `isCaptureDone`, read the target buffer → `deinitCapture` when done.

---

### espeak-ng.r3

Text-to-speech synthesis via `libespeak-ng.dll`. |WIN|

**Dependencies:** `^r3/lib/win/kernel32.r3`

```
::espeak_Initialize      ( output bufferlen path options -- rate )   init the engine
::espeak_SetVoiceByName  ( 'name -- r )                                select voice, e.g. "en", "es"
::espeak_TextToPhonemes  ( 'text a b -- 'phonemes )                    convert text to phoneme string
::espeak_Terminate       ( -- r )                                       shut down the engine
```

Loaded from `libespeak-ng.dll` in `.\dll` (sets the DLL search directory to `.\dll` for the duration of the load, then restores it). This mirrors the [espeak-ng C API](https://github.com/espeak-ng/espeak-ng) directly — `espeak_Initialize`'s real signature is `(output, buflength, path, options)`, and `espeak_TextToPhonemes` takes `(text, textmode, phonememode)`; consult the espeak-ng headers for the exact flag values.

---

### glutil.r3

OpenGL helper words layered on `sdl2gl.r3`: shader loading/compilation, uniform setters, texture loading from images, and a ready-made textured cube.

**Dependencies:** `^r3/lib/mem.r3`, `^r3/lib/sdl2.r3`, `^r3/lib/sdl2gl.r3`, `^r3/lib/sdl2image.r3`

```
-- Shader Loading --
::loadShaderv  ( "shader" -- idprogram )   compile+link a combined vertex/fragment/geometry
                                              shader source (marked with @V/@F/@G section tags);
                                              0 on failure
::loadShader   ( "filename" -- idprogram )  load a shader file by name and call loadShaderv

-- Uniforms --
::shadera!i   ( int shader "name" -- )     set an attribute location to an int (via glUniform1i)
::shader!i    ( int shader "name" -- )     set a uniform int
::shader!v3   ( 'v3 shader "name" -- )     set a uniform vec3
::shader!v4   ( 'v4 shader "name" -- )     set a uniform vec4
::shader!m4   ( 'm4 shader "name" -- )     set a uniform mat4
::shader!f1   ( 'f shader "name" -- )      set a uniform float

-- Textures --
::glImgFnt    ( "filename" -- texid )      load image → GL texture, GL_NEAREST filtering (for fonts)
::glImgTex    ( "filename" -- texid )      load image → GL texture, GL_LINEAR filtering;
                                              also sets ##glimgw/##glimgh to the image size
::glColorTex  ( col -- texid )             make a 1×1 solid-color texture

-- Cube Primitive --
::initcube    ( -- )    build the VAO/VBO for a unit textured cube (position+normal+UV)
::rendercube  ( -- )    draw the cube built by initcube
```

`##glimgw`/`##glimgh` hold the pixel size of the last texture loaded via `glImgTex`.

---

### onnx.r3

Direct bindings to the [ONNX Runtime C API](https://onnxruntime.ai/docs/api/c/) (`onnxruntime.dll`), for running neural network models. |WIN|

**Dependencies:** `^r3/lib/win/kernel32.r3`

This is a near-complete 1:1 mirror of the official `OrtApi` function table — roughly 190 functions covering environment/session setup, tensors, memory info, sparse tensors, execution providers (CUDA, TensorRT, ROCm, DirectML, Dnnl...), IO binding, and LoRA adapters. Every real ONNX Runtime C API function `OrtApi->Xxx(...)` is exposed here as `::OrtXxx`, in the same argument order, via the standard `sysN` DLL-call mechanism (`N` = argument count). A few conveniences are added on top:

```
::OrtgetVersionString  ( -- 'str )        ONNX Runtime version string
::ortSess_CPU          ( 'options threads -- 'status )   append the CPU execution provider
::ortSess_MDL          ( 'options threads -- 'status )   append the MDL execution provider
```

Given the size and 1:1 nature of the rest, function-by-function stack docs aren't reproduced here — the [official OrtApi reference](https://onnxruntime.ai/docs/api/c/struct_ort_api.html) applies directly: whatever a given `OrtXxx` takes in C, the r3 word `::OrtXxx` takes on the stack in the same left-to-right order (with the trailing output pointer(s) becoming stack outputs). Typical flow: `OrtCreateEnv` → `OrtCreateSessionOptions` (+ `ortSess_CPU`/`ortSess_MDL` or one of the `SessionOptionsAppendExecutionProvider_*` words) → `OrtCreateSession` → `OrtRun`.

---

### tflite.r3

Bindings to the [TensorFlow Lite C API](https://www.tensorflow.org/lite/api_docs/c) (`tensorflowlite_c.dll`), for running `.tflite` models. |WIN|

**Dependencies:** `^r3/lib/win/kernel32.r3`

```
-- Setup --
::TfLiteModelCreateFromFile          ( 'path -- 'model )
::TfLiteInterpreterOptionsCreate     ( -- 'options )
::TfLiteInterpreterOptionsAddDelegate ( 'options 'delegate -- )
::TfLiteXNNPackDelegateCreate        ( 'xnnopts -- 'delegate )   CPU-optimized delegate
::TfLiteInterpreterCreate            ( 'model 'options -- 'interp )
::TfLiteInterpreterAllocateTensors   ( 'interp -- r )

-- Tensors --
::TfLiteInterpreterGetInputTensor    ( 'interp idx -- 'tensor )
::TfLiteInterpreterGetOutputTensor   ( 'interp idx -- 'tensor )
::TfLiteTensorDim                    ( 'tensor idx -- n )       size of dimension idx
::TfLiteTensorByteSize               ( 'tensor -- bytes )
::TfLiteTensorData                   ( 'tensor -- 'buf )        raw data pointer
::TfLiteTensorCopyFromBuffer         ( 'tensor 'src bytes -- r )   upload input data
::TfLiteTensorCopyToBuffer           ( 'tensor 'dst bytes -- r )   read back output data

-- Run --
::TfLiteInterpreterInvoke            ( 'interp -- r )

-- Cleanup --
::TfLiteInterpreterDelete            ( 'interp -- r )
::TfLiteInterpreterOptionsDelete     ( 'options -- r )
::TfLiteModelDelete                  ( 'model -- r )
```

**Typical flow:** `TfLiteModelCreateFromFile` → `TfLiteInterpreterOptionsCreate` (+ `TfLiteXNNPackDelegateCreate`/`TfLiteInterpreterOptionsAddDelegate` if using the XNNPACK delegate) → `TfLiteInterpreterCreate` → `TfLiteInterpreterAllocateTensors` → get input tensor(s), `TfLiteTensorCopyFromBuffer` → `TfLiteInterpreterInvoke` → get output tensor(s), `TfLiteTensorCopyToBuffer`.

---

### sdl2gl-const.r3

OpenGL constant definitions, included by `sdl2gl.r3`. Not called directly — just a table of `$`-prefixed GL enum values (booleans, buffer bits, etc.).

---

### sdl2gl-constv.r3

Extended set of OpenGL constants, companion to `sdl2gl-const.r3`.

---

### clipboard.r3

Clipboard access. Platform-specific implementation in `lib/win/` or `lib/posix/`.

**No exported words in base file** — see platform sections below.

---

## lib/win/ — Windows System Bindings

---

### win/core.r3

High-level file I/O, process execution, and file iteration for Windows.

```
-- Time and Date --
::ms        ( ms -- )          sleep for milliseconds
::msec      ( -- msec )        current time in milliseconds
::time      ( -- hms )         current time packed (h<<32|m<<16|s)
::date      ( -- ymd )         current date packed
::sysdate   ( -- 'dt )         pointer to SYSTEMTIME structure
::date.d    ( -- day )         day of month
::date.dw   ( -- wday )        day of week
::date.m    ( -- month )       month (1..12)
::date.y    ( -- year )
::time.ms   ::time.s   ::time.m   ::time.h   -- milliseconds, second, minute, hour

-- File Search --
::findata   ( -- 'fdd )          file data structure pointer
::ffirst    ( "path/*" -- fdd/0 ) find first file
::fnext     ( -- fdd/0 )          find next file
::FNAME     ( adr -- adrname )    get filename from find data
::FDIR      ( adr -- 1/0 )        is directory?
::FSIZEF    ( adr -- size )       file size in bytes
::filetimeD ( 'FILETIME -- 'dt )  FILETIME to date/time
::FCREADT   ( adr -- 'dt )        file creation date/time
::FLASTDT   ( adr -- 'dt )        last access date/time
::FWRITEDT  ( adr -- 'dt )        last write date/time

-- File I/O --
::load      ( 'from "filename" -- 'to )     load file into buffer
::save      ( 'from cnt "filename" -- )     save buffer to file
::append    ( 'from cnt "filename" -- )     append to file
::delete    ( "filename" -- )               delete file
::filexist  ( "file" -- 0=no )              check file exists
::fileisize ( -- size )                     size after fileinfo
::fileijul  ( -- jul )                      modification date as Julian
::fileinfo  ( "file" -- 0=not exist )       get file info
::filecreatetime  ( -- 'dt )  creation time (after fileinfo)
::filelastactime  ( -- 'dt )  last access time
::filelastwrtime  ( -- 'dt )  last write time

-- Process Execution --
##sinfo * 104    STARTUPINFO buffer
##pinfo * 24     PROCESS_INFORMATION buffer
::sys      ( "" -- )    execute command (wait)
::sysnew   ( "" -- )    execute in new window
::sysdebug ( "" -- )    execute with debug
```

---

### win/kernel32.r3

Raw Win32 kernel32.dll bindings. Includes: Console management (`AllocConsole`, `FreeConsole`, `GetConsoleMode`, `SetConsoleMode`, `SetConsoleTitle`, `ReadConsoleInput`, `WriteConsole`), File operations (`CreateFile`, `CloseHandle`, `ReadFile`, `WriteFile`, `SetFilePointer`, `SetEndOfFile`, `DeleteFile`, `MoveFile`, `GetFileAttributes`, `GetFileSize`), Memory (`GetProcessHeap`, `HeapAlloc`, `HeapFree`, `HeapReAlloc`, `GlobalAlloc`, `GlobalLock`, `GlobalFree`), Process/Thread (`CreateProcess`, `Sleep`, `WaitForSingleObject`, `GetLastError`), File Mapping (`OpenFileMappingA`, `CreateFileMappingA`, `MapViewOfFile`, `UnmapViewOfFile`), Directory (`CreateDirectory`, `RemoveDirectory`, `SetCurrentDirectory`, `FindFirstFile`, `FindNextFile`, `FindClose`), System (`GetLocalTime`, `GetTickCount`, `FileTimeToSystemTime`, `SetConsoleOutputCP`).

---

### win/clipboard.r3

Windows clipboard raw bindings plus helpers.

```
-- Raw Win32 --
::OpenClipboard   ( hwnd -- )
::CloseClipboard  ( -- )
::EmptyClipboard  ( -- )
::IsClipboardFormatAvailable ( fmt -- 0/1 )
::GetClipboardData ( fmt -- handle )
::SetClipboardData ( fmt handle -- )

-- High-level --
::copyclipboard   ( 'mem cnt -- )   copy n bytes of text to clipboard
::pasteclipboard  ( 'mem -- )       paste from clipboard to 'mem
```

---

### win/win-term.r3

Windows terminal event handling — keyboard, mouse, resize.

```
##stdin ##stdout ##stderr    standard handle globals

::type      ( str cnt -- )   write to stdout
##rows ##cols                terminal size

::.onresize  ( 'callback -- )   set resize event callback
::evtkey     ( -- key )          read key event
::evtkey2    ( -- key )          read key (alternate)
##evtmx ##evtmy   mouse coords
##evtmb              mouse buttons
##evtmw              mouse wheel
::evtmxy     ( -- x y )    push mouse coordinates
::inevt      ( -- type )   check for event (no wait; 0=none)
::getevt     ( -- type )   wait for any event
::inkey      ( -- key )    0 if no key pressed

::.enable-mouse    ( -- )   enable mouse reporting
::.disable-mouse   ( -- )   disable mouse reporting
::.free            ( -- )   free/release console
::.reterm          ( -- )   set console modes for ANSI/VT + window events
```

---

### win/inet.r3

WinInet HTTP download.

```
::InternetOpen    ( agent flags proxy bypass ctx -- handle )
::InternetOpenUrl ( net url headers hlen flags ctx -- handle )
::InternetReadFile ( h buf len 'read -- )
::InternetCloseHandle ( h -- )
::DeleteUrlCacheEntry ( url -- )

::openurl  ( url header buff -- buff )   open URL and read to buffer
```

---

### win/winhttp.r3

WinHTTP HTTP client bindings.

```
::WinHttpOpen             ( agent proxy bypass flags -- session )
::WinHttpConnect          ( session host port flags -- conn )
::WinHttpOpenRequest      ( conn verb url ver refer accept flags -- req )
::WinHttpSendRequest      ( req headers hlen opt olen ctx -- )
::WinHttpReceiveResponse  ( req reserved -- )
::WinHttpQueryDataAvailable ( req 'num -- )
::WinHttpReadData         ( req buf len 'read -- )
::WinHttpCloseHandle      ( h -- )

::loadurl  ( buff url -- buff )   load URL content to buffer
```

---

### win/winsock.r3

Raw Winsock2 bindings (Windows-specific names).

```
::WSAStartup   ( ver 'wsadata -- )
::WSACleanup   ( -- )
::socket       ( family type proto -- sock )
::bind         ( sock 'addr addrlen -- )
::listen       ( sock backlog -- )
::accept       ( sock 'addr 'addrlen -- newsock )
::select       ( nfds 'rset 'wset 'eset 'timeout -- n )
::closesocket  ( sock -- )
::shutdown     ( sock how -- )
::send         ( sock 'buf len flags -- n )
::recv         ( sock 'buf len flags -- n )
::getaddrinfo  ( node svc 'hints 'res -- )
::ioctlsocket  ( sock cmd 'arg -- )
```

---

### win/ws2.r3

Winsock2 bindings with `ws2-` prefix to avoid collision with posix names.

All words are `ws2-*` versions: `ws2-WSAStartup`, `ws2-socket`, `ws2-bind`, `ws2-listen`, `ws2-accept`, `ws2-connect`, `ws2-send`, `ws2-recv`, `ws2-closesocket`, `ws2-setsockopt`, `ws2-ioctlsocket`, `ws2-inet_addr`, `ws2-htons`, `ws2-getaddrinfo`, `ws2-freeaddrinfo`, `ws2-gethostbyname`, `ws2-gethostbyaddr`, `ws2-gethostname`, `ws2-WSAGetLastError`, `ws2-WSASetLastError`, etc.

---

### win/urlmon.r3

URL file download via urlmon.dll.

```
::URLDownloadToFile       ( caller url file res callback -- )
::URLOpenBlockingStreamA  ( caller url 'stream flags cb -- )

::url2file   ( url file -- )    download URL to file (no cache)
::url2filec  ( url file -- )    download URL to file (with cache)
```

---

### win/ffmpeg.r3

FFmpeg video playback via FFmpeg DLL. |WIN| only.

```
-- Video Flags --
##LOADING     $20     video still loading
##VID_NO_AUDIO $10   no audio
##VID_LOOP    $8      loop video
##VID_WAIT    $4      wait for sync

-- API --
::IniVideo    ( dllpath -- )            load FFmpeg DLL
::LoadVideo   ( flags "file" -- video ) load video file
::VideoBox    ( video 'box -- )         set render target box
::VideoPoly   ( v x1 y1 x2 y2 -- )     render to polygon
::VideoFlag   ( video -- flags )        get video flags
::VideoTex    ( video -- tex )          get current frame texture
::PlayVideo   ( video -- )              start playback
::StopVideo   ( video -- )              stop playback
::VideoTime   ( video -- len )          video duration
::VideoSize   ( video -- w h )          video dimensions

-- Render Helpers --
::vshow    ( x y img -- )             show frame at position
::vshowZ   ( x y zoom img -- )        show with zoom
::vshowR   ( x y ang img -- )         show with rotation
::vshowRZ  ( x y ang zoom img -- )    show with rotation and zoom
```

---

### win/debugapi.r3

Windows Debug API bindings.

```
::IsDebuggerPresent       ( -- 0/1 )
::OutputDebugStringA      ( str -- )    send string to debugger
::OutputDebugStringW      ( str -- )    wide string version
::DebugBreak              ( -- )        trigger breakpoint
::ContinueDebugEvent      ( pid tid cont -- )
::WaitForDebugEvent       ( 'event timeout -- )
::DebugActiveProcess      ( pid -- )
::DebugActiveProcessStop  ( pid -- )
::CheckRemoteDebuggerPresent ( proc 'present -- )
```

---

## lib/posix/ — Linux System Bindings

---

### posix/core.r3

High-level file I/O and filesystem for Linux — mirrors `win/core.r3` API.

```
-- Time --
::ms     ( ms -- )      sleep for milliseconds
::msec   ( -- msec )    current time in milliseconds
::time   ( -- hms )     current time
::date   ( -- ymd )     current date
::sysdate ( -- )        populate internal date structure
::date.d  ::date.dw  ::date.m  ::date.y
::time.s  ::time.m  ::time.h

-- File Search --
::findata   ( -- 'dirp )
::ffirst    ( "path/*" -- fdd/0 )
::fnext     ( -- fdd/0 )
::FNAME     ( adr -- adrname )
::FDIR      ( adr -- 1/0 )
::FSIZEF    ( adr -- size )
::FCREADT   ::FLASTDT   ::FWRITEDT

-- File I/O (same API as win/core) --
::load    ( 'from "filename" -- 'to )
::save    ( 'from cnt "filename" -- )
::append  ( 'from cnt "filename" -- )
::delete  ( "filename" -- )
::filexist ( "file" -- 0=no )
::fileisize ::fileijul  ::fileinfo

-- Process --
::sys    ( "" -- )    execute command
::sysnew ( "" -- )    execute in background
```

---

### posix/posix.r3

Raw POSIX syscall bindings. All words are `libc-*` prefixed.

Includes: `libc-open`, `libc-close`, `libc-read`, `libc-write`, `libc-lseek`, `libc-fork`, `libc-wait`, `libc-waitpid`, `libc-mmap`, `libc-munmap`, `libc-malloc`, `libc-free`, `libc-realloc`, `libc-usleep`, `libc-ftruncate`, `libc-fsync`, `libc-mprotect`, `libc-signal`, `libc-chdir`, `libc-mkdir`, `libc-rmdir`, `libc-opendir`, `libc-closedir`, `libc-readdir`, `libc-fstatat`, `libc-clock_gettime`, `libc-fcntl`, `libc-tcgetattr`, `libc-tcsetattr`, `libc-system`, `libc-select`, `libc-stat`, `libc-access`, `libc-setlocale`, `libc-popen`, `libc-pclose`, `libc-socket`, `libc-bind`, `libc-listen`, `libc-accept`, `libc-connect`, `libc-send`, `libc-recv`, `libc-setsockopt`, `libc-inet_addr`, `libc-htons`, `libc-getaddrinfo`, `libc-gethostbyname`, plus: `shm_open`, `shm_unlink`, `msync`.

---

### posix/lin-term.r3

Linux terminal event handling.

```
::type         ( str cnt -- )   write to stdout
::.reterm      ( -- )           set terminal raw mode
::.free        ( -- )           restore terminal
::.getterminfo ( -- )           read terminal size
::.onresize    ( 'callback -- ) set resize callback
##rows ##cols                   terminal dimensions
::kbhit        ( -- 0/1 )       non-blocking key check
::inkey        ( -- key )       0 if no key pressed
##evtmx ##evtmy ##evtmb ##evtmw
::evtmxy       ( -- x y )
::inevt        ( -- type )      0 if no event
::getevt       ( -- type )      wait for event
::evtkey       ( -- key )
::.enable-mouse  ( -- )
::.disable-mouse ( -- )
```

---

### posix/clipboard.r3

Linux clipboard — stub implementation.

```
::copyclipboard  ( 'mem cnt -- )   copy text to clipboard (xclip/wl-copy)
::pasteclipboard ( 'mem -- )       paste from clipboard
```

---

*End of r3forth Library Reference (lib/, lib/win/, lib/posix/). See `r3forth-util.md` for the util/ libraries.*
