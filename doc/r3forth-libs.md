# r3forth Library Reference

Complete API reference for the r3forth library ecosystem.

**Conventions:**
- `::word` — exported word (public API)
- `##var` — exported mutable global variable
- Stack notation: `( inputs -- outputs )` — `.` suffix = 16.16 fixed-point, `.d` = 32.32 fixed-point
- Binary angle (`bangle`): `$0000`=0° `$4000`=90° `$8000`=180°
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

38. [clipboard.r3](#clipboardr3) — Clipboard (platform-provided)

### lib/win/ — Windows System Bindings
39. [win/core.r3](#wincorerr3) — File I/O, processes, file search
40. [win/kernel32.r3](#winkernel32r3) — Win32 API bindings
41. [win/clipboard.r3](#winclipboardr3) — Win32 clipboard
42. [win/win-term.r3](#wintermr3) — Windows console terminal
43. [win/inet.r3](#wineinetr3) — WinInet HTTP download
44. [win/winhttp.r3](#winhttpr3) — WinHTTP HTTP client
45. [win/winsock.r3](#winsockr3) — Winsock2 raw bindings
46. [win/ws2.r3](#ws2r3) — Winsock2 with ws2- prefix
47. [win/urlmon.r3](#urlmonr3) — URL download helper
48. [win/ffmpeg.r3](#ffmpegr3) — FFmpeg video playback |WIN|
49. [win/debugapi.r3](#debugapir3) — Windows debug API

### lib/posix/ — Linux System Bindings
50. [posix/core.r3](#posixcorerr3) — File I/O, filesystem
51. [posix/posix.r3](#posixposixr3) — POSIX syscall bindings
52. [posix/lin-term.r3](#lintermr3) — Linux terminal
53. [posix/clipboard.r3](#posixclipboardr3) — Linux clipboard stub

### util/ — High-Level Utilities
54. [arr8.r3](#arr8r3) — Fixed 8-value object pool
55. [arr16.r3](#arr16r3) — Fixed 16-value object pool with sort/map
56. [blist.r3](#blistr3) — Sorted byte list
57. [dlist.r3](#dlistr3) — FIFO deque
58. [heap.r3](#heapr3) — Min-heap priority queue
59. [hash2d.r3](#hash2dr3) — 2D spatial hash for collision
60. [sort.r3](#sortr3) — ShellSort variants
61. [sortradix.r3](#sortradixr3) — RadixSort 16/32/64-bit
62. [sortradixm.r3](#sortradixmr3) — RadixSort with offset keys
63. [penner.r3](#pennerr3) — 30 Penner easing functions
64. [varanim.r3](#varanimr3) — Timeline-based variable animator
65. [utfg.r3](#utfgr3) — 8×8 bitmap font terminal output
66. [bfont.r3](#bfontr3) — Fixed-width bitmap font (SDL2)
67. [pcfont.r3](#pcfontr3) — PC/DOS-style 16×32 font (SDL2)
68. [ttfont.r3](#ttfontr3) — TrueType font rendering (SDL2_ttf)
69. [txfont.r3](#txfontr3) — TrueType atlas font with pseudo-UTF8
70. [ttext.r3](#ttextr3) — Tilesheet-based terminal text (SDL2)
71. [textb.r3](#textbr3) — Wrapped text box renderer (SDL2+TTF)
72. [sdlgui.r3](#sdlguir3) — Immediate-mode GUI with TTF (SDL2)
73. [sdlbgui.r3](#sdlbguir3) — Immediate-mode GUI with bitmap font (SDL2)
74. [sdlfiledlg.r3](#sdlfiledlgr3) — File dialog (sdlgui-based)
75. [dlgcol.r3](#dlgcolr3) — Color picker dialog (SDL2)
76. [dlgfile.r3](#dlgfiler3) — File browser dialog (SDL2)
77. [immi.r3](#immir3) — Modern grid-based immediate-mode GUI (SDL2, v3)
78. [imcolor.r3](#imcolorr3) — Color selector widget for immi
79. [imedit.r3](#imeditr3) — Code editor with syntax highlight for immi
80. [imfiledlg.r3](#imfiledlgr3) — File dialog for immi
81. [immdatetime.r3](#immdatetimer3) — Calendar/datetime widget for immi
82. [tui.r3](#tuir3) — Text UI framework (terminal)
83. [tuiedit.r3](#tuieditr3) — Full text editor widget (terminal)
84. [vscreen.r3](#vscreenr3) — Virtual resolution with auto-scaling
85. [tilesheet.r3](#tilesheetr3) — Tile map with scrolling
86. [bmap.r3](#bmapr3) — Multi-layer tile map for games
87. [loadobj.r3](#loadobjr3) — Wavefront OBJ/MTL 3D model loader
88. [datetime.r3](#datetimer3) — Date/time formatting
89. [db2.r3](#db2r3) — Text database v2 (ASCII 29/30/31 separators)
90. [dbtxt.r3](#dbtxtr3) — Text database v1 (pipe/caret separators)
91. [filedirs.r3](#filedirsrr3) — Filesystem scanner for UI trees

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
All values with `.` suffix are 16.16 fixed-point (integer × 65536).
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
Binary angle: `$0000`=0°, `$4000`=90°, `$8000`=180°, `$ffff`≈360°. Results are 16.16 fixed-point in range -1.0..1.0.
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
::f2fp          ( f. -- fp )        16.16 fixed → float32
::fp2f          ( fp -- f. )        float32 → 16.16 fixed
::fp2i          ( fp -- i )         float32 → integer
::fp16f         ( fp16 -- f. )      float16 → fixed-point
::f2fp24        ( f. -- fp )        16.16 fixed → float32 (40.24)
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
::f>.d   ( f. -- a.d )          16.16 fixed → 32.32
::.d>f   ( a.d -- f. )          32.32 → 16.16

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

-- String parsing/formatting --
::str>f.d ( adr -- 'adr fnro )  parse float string → 32.32 fixed
::f32!    ( 'cell -- )          store float32 from string at address
::.fd     ( fix.d -- str )      format 32.32 to decimal string
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
::.f  ( fix. -- str )  format 16.16 fixed-point as decimal
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

2D vector math. Vectors are 2-cell structures `{x y}` (16.16 fixed-point).

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
::spriteZ  ( x y zoom img -- )         draw texture centered, scaled by zoom (16.16)
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
::sspritez   ( x y zoom n ssprite -- )      draw frame n centered, scaled by zoom (16.16)
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

#### Timer and Delta-time
```
::timer<  ( msec -- )     reset timer to msec value
::timer.  ( -- )          advance timer (call each frame); updates ##deltatime
::timer+  ( n -- n+dt )   add deltatime to n
::timer-  ( n -- n-dt )   subtract deltatime from n
##deltatime               milliseconds since last timer. call
```

#### Frame Animation System
Pack animation state into a single 64-bit value: start frame, frame count, fps, accumulator.
```
::aniInit    ( ini cnt fps -- V )   create animation value: ini=start frame, cnt=count, fps
::ani+!      ( dt 'v -- )          advance animation by dt milliseconds
::aniFrame   ( V -- f )            get current absolute frame (ini + current offset)
::aniCnt     ( V -- c )            get current frame offset within the animation
::ani+timer! ( 'V -- )             advance animation by ##deltatime (shortcut for timer.)
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

AVX-accelerated buffer conversions between float32, fixed-point 16.16, and packed RGB. |WIN| only.

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
::date.ms   ( -- ms )          milliseconds
::time.ms   ::time.s   ::time.m   ::time.h

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

## util/ — High-Level Utilities

---

### arr8.r3

Fixed object pool for 8-value (64-byte) objects. Object index 0 is reserved as "null".

**Dependencies:** `^r3/lib/mem.r3`

```
::p8.ini   ( cantidad list -- )   initialize pool with `cantidad` slots
::p8.clear ( list -- )            reset pool (keep allocation)

-- Allocation --
::p8!+   ( 'act list -- adr )   allocate next; 'act = optional init callback
::p8!    ( list -- adr )        allocate next (no callback)

-- Access --
::p8.nro  ( nro list -- adr )    get object address by index (from start)
::p8.last ( nro list -- adr )    get from end (reverse index)
::p8.cnt  ( list -- cnt )        current count of active objects

-- Operations --
::p8.cpy    ( adr 'list -- )      copy object adr into list
::p8.del    ( adr list -- )       delete object (swap with last)
::p8.draw   ( list -- )           call default draw for all
::p8.drawo  ( list -- )           call default draw (ordered)
::p8.mapv   ( 'vector list -- )   call vector for each object
::p8.mapd   ( 'vector list -- )   call vector for each (reverse)
::p8.mapi   ( 'vector fin ini list -- )  map over range [ini..fin]
::p8.deli   ( fin ini list -- )   delete range
```

---

### arr16.r3

Fixed object pool for 16-value (128-byte) objects. Like arr8 but larger objects with sorting and mapping.

**Dependencies:** `^r3/lib/mem.r3`

```
::p.ini    ( cantidad list -- )   initialize pool
::p.clear  ( list -- )            reset pool

-- Allocation --
::p!+  ( 'act list -- adr )   allocate with init callback
::p!   ( list -- adr )        allocate without callback

-- Access --
::p.adr  ( nro list -- adr )   get object address by index
::p.nro  ( adr list -- nro )   get index from address
::p.cnt  ( list -- cnt )       active object count

-- Operations --
::p.del    ( adr list -- )      delete object (swap with last)
::p.draw   ( list -- )          call draw for all objects
::p.drawo  ( list -- )          call draw (ordered)
::p.mapv   ( 'vector list -- )  call vector for each
::p.mapd   ( 'vector list -- )  call vector for each (desc)
::p.map2   ( 'vec 'list --- )   call 'vec with list

-- Sorting --
::p.sort   ( col 'list -- )     sort by column `col` ascending
::p.isort  ( col 'list -- )     sort by column `col` descending
```

---

### blist.r3

Ordered byte list (sorted insertion/lookup).

**Dependencies:** `^r3/lib/console.r3`

```
::blistdel  ( 'list 'from -- )   delete item 'from from list
::blist!    ( f 'list -- )       insert f into list (sorted)
::blist-    ( f 'list -- )       remove f from list
::blist@    ( 'list -- f/0 )     get first item (or 0)
::blist?    ( f 'list -- f/0 )   find f in list (0 if not found)
```

---

### dlist.r3

Double-ended deque / FIFO queue.

**Dependencies:** `^r3/lib/mem.r3`

```
::dc.ini   ( max 'dc -- )    initialize deque with max capacity
::dc.clear ( list -- )       clear deque
::dc?      ( list -- cnt )   current item count
::dcn@     ( n l -- v )      get item at index n
::dc@      ( list -- val )   peek front item
::dc!      ( val list -- )   enqueue (add to back)
::dc@-     ( list -- val )   dequeue (remove from front)
```

---

### heap.r3

Min-heap priority queue.

**Dependencies:** `^r3/lib/mem.r3`

```
::heapini  ( max 'h -- )    initialize heap with max capacity
::heap!    ( nodo 'h -- )   insert node (smaller value = higher priority)
::heap@    ( 'h -- nodo )   remove and return min-priority node
```

---

### hash2d.r3

2D spatial hash for fast proximity/collision queries.

**Dependencies:** `^r3/lib/mem.r3`

```
##checkmax 32   maximum check radius in pixels

::H2d.ini   ( maxobj -- )    initialize for maxobj objects
::H2d.clear ( -- )           clear all entries
::H2d.list  ( -- 'adr cnt )  get all active entries

::h2d+!  ( nro r x y -- )              insert object nro at (x,y) with radius r
::h2d!   ( x y zoom nro sizepixel/2 -- x y zoom )   draw + collision update
```

---

### sort.r3

ShellSort with optimal gaps. Input arrays are key-value pairs.

**Dependencies:** `^r3/lib/math.r3`

```
::shellsort   ( len lista -- )   sort by key ascending (array: key value key value...)
::shellsort2  ( len lista -- )   sort by value ascending (array: value key value key...)
::shellsort1  ( len lista -- )   sort interleaved key|value
::sortstr     ( len lista -- )   sort by string pointer (pstr-value pairs)
```

---

### sortradix.r3

O(n) RadixSort for fixed-width integer keys. Sorts key-value pair arrays.

**Dependencies:** `^r3/lib/mem.r3`

```
::radixsort32  ( cnt '2array -- )   sort by 32-bit key
::radixsort16  ( cnt '2array -- )   sort by 16-bit key
::radixsort64  ( cnt '2array -- )   sort by 64-bit key
```

The `'2array` points to an array of (key, value) pairs, each 2 cells.

---

### sortradixm.r3

RadixSort variant with offset keys.

**Dependencies:** `^r3/lib/mem.r3`

```
::radixsort   ( cnt 'array -- )    sort with default offset
::radixsortm  ( cnt 'array -- )    sort with modified offset keys
```

---

### penner.r3

30 Penner easing functions in 16.16 fixed-point. Input `t` is in range `[0.0 .. 1.0]` (fixed-point), output is in `[0.0 .. 1.0]`.

**Dependencies:** `^r3/lib/math.r3`

```
-- Linear --
::Lineal         ( t. -- t. )

-- Quadratic --
::Quad_In        ::Quad_Out        ::Quad_InOut

-- Cubic --
::Cub_In         ::Cub_Out         ::Cub_InOut

-- Quartic --
::Quar_In        ::Quar_Out        ::Quar_InOut

-- Quintic --
::Quin_In        ::Quin_Out        ::Quin_InOut

-- Sinusoidal --
::Sin_In         ::Sin_Out         ::Sin_InOut

-- Exponential --
::Exp_In         ::Exp_Out         ::Exp_InOut

-- Circular --
::Cir_In         ::Cir_Out         ::Cir_InOut

-- Elastic --
::Ela_In         ::Ela_Out         ::Ela_InOut

-- Back (overshoot) --
::Bac_In         ::Bac_Out         ::Bac_InOut

-- Bounce --
::Bou_In         ::Bou_Out         ::Bou_InOut

-- Dispatch table --
##easet 0        pointer to ease function table
::ease   ( t. nro -- t'. )   apply ease function by index
::easem  ( t. nro -- t'. )   apply ease (mirror/inverse variant)

-- Interpolation --
::catmullRom  ( p0 p1 p2 p3 t. -- v. )   Catmull-Rom spline interpolation
```

---

### varanim.r3

Timeline-based variable animator. Drives values from `ini` to `fin` over time using a Penner ease.

**Dependencies:** `^r3/lib/mem.r3`, `^r3/lib/color.r3`, `^r3/util/penner.r3`

```
-- Global State --
##deltatime     time delta for current frame (ms)
##timeline      current timeline position
##timeline<     timeline start
##timeline>     timeline end
##exevar        active animation count

-- Setup --
::vareset   ( -- )           reset all animations
::vaini     ( max -- )       initialize with max simultaneous animations
::vaempty   ( -- )           clear all active animations

-- Update --
::vupdate   ( -- )           advance all animations (call each frame)

-- Add Animations --
::+vanim    ( 'var ini fin ease dur. start -- )   animate scalar variable
::+vboxanim ( 'var fin ini ease dur. start -- )   animate scalar (reversed params)
::+vxyanim  ( 'var ini fin ease dur. start -- )   animate packed XY value
::+vcolanim ( 'var ini fin ease dur. start -- )   animate packed color
::+vexe     ( 'vector start -- )                  execute vector at time start
::+vvexe    ( v 'vector start -- )                execute with value
::+vvvexe   ( v v 'vector start -- )              execute with two values

-- Packed Value Helpers --
::64xy      ( b -- x y )         unpack XY from 64-bit value
::64wh      ( b -- w h )         unpack WH
::64xywh    ( b -- x y w h )     unpack X Y W H
::xywh64    ( x y w h -- b )     pack X Y W H
::64xyrz    ( b -- x y r z )     unpack X Y Rotation Z
::xyrz64    ( x y r z -- b )     pack X Y Rotation Z
::64box     ( b adr -- )         unpack box to address
::32xy      ( b -- x y )         unpack XY from 32-bit value
::xy32      ( x y -- b )         pack XY into 32-bit value
```

---

### utfg.r3

8×8 bitmap Unicode font for terminal output. Outputs to console buffer via `.write`.

**Dependencies:** `^r3/lib/console.r3`

```
-- Character Output --
::.xwrite ( str -- )    write string to terminal using bitmap font
::.awrite ( str -- )    write string (alternate mode)

-- Line Drawing --
::.vline  ( h -- )      draw vertical line h chars tall
::.hline  ( w -- )      draw horizontal line w chars wide
::.vlined ( h -- )      draw double vertical line
::.hlined ( w -- )      draw double horizontal line

-- Box Drawing --
::.boxl   ( x y w h -- )   draw box (single line)
::.boxc   ( x y w h -- )   draw box (corner style)
::.boxd   ( x y w h -- )   draw box (double line)
::.boxf   ( -- )            fill current box area

-- Text Alignment --
::lalign  ( cnt str -- )   left-align string in cnt columns
::calign  ( cnt str -- )   center-align
::ralign  ( cnt str -- )   right-align
::lwrite  ( w "str" -- )   left-aligned write in width w
::cwrite  ( w "str" -- )   centered write
::rwrite  ( w "str" -- )   right-aligned write
::xalign  ( $VH -- )       set alignment ($V=vertical bits, $H=horizontal bits)
::xwrite  ( w "str" -- )   write with current alignment
::xText   ( w h x y "" -- )  draw aligned text in box
```

---

### bfont.r3

Fixed-width bitmap font rendered to SDL2 from an image file.

**Dependencies:** `^r3/lib/sdl2gfx.r3`, `^r3/lib/sdl2image.r3`

```
##wp ##hp   glyph width, height (pixels)

-- Setup --
::bmfont  ( w h "filename" -- )   load font image (w×h pixels per glyph)
::bfont1  ( -- )                   activate font 1
::bfont2  ( -- )                   activate font 2

-- Colors --
::bcolor  ( rrggbb -- )    set font render color
::bfbox   ( -- )           fill background box
::bbox    ( -- )           draw background box
::bbox2   ( -- )           alternate background box

-- Cursor Positioning --
::bat    ( x y -- )        set pixel position
::ccx    ( -- x )          current cursor x (pixel)
::ccy    ( -- y )          current cursor y (pixel)
::gotoxy ( x y -- )        move cursor in character cells
::gotox  ( x -- )          move cursor to column (char cells)

-- Rendering --
::bemit       ( ascii -- )    draw single character
::bprint      ( -- )          print using format string from stack (like printf)
::bprintd     ( -- )          print double-size
::bprint2     ( -- )          alternate print
::bemits      ( "" -- )       print string
::bemitsd     ( "" -- )       print string double-size
::bemits2     ( "" -- )       alternate string print
::bprintz     ( .. "" size -- ) print at pixel size
::bemitsz     ( "" size -- )  print string at size
::bfillemit   ( "" -- "" )    print with fill
::bfcemit     ( cnt -- )      fill + emit count chars
::bcr         ( -- )           carriage return
::bcr2        ( -- )           double carriage return
::bcrz        ( size -- )      CR for given size
::bsp         ( -- )           space
::bnsp        ( n -- )         n spaces

-- Measurement --
::bsize  ( "" -- "" w h )    get string pixel dimensions
::bpos   ( -- x y )          get cursor position
::brect  ( "" -- "" x y w h ) get bounding rect
::bsrcsize ( x y w h -- x y w h )  source size clamp

-- Cursor Display --
::bcursor    ( n -- )    draw cursor of style n
::bcursori   ( n -- )    draw inverted cursor
::bcursor2   ( n -- )    draw alternate cursor
::bcursori2  ( n -- )    draw alternate inverted cursor
```

---

### pcfont.r3

PC/DOS-style font (16×32 grid per image) for SDL2.

**Dependencies:** `^r3/lib/sdl2gfx.r3`, `^r3/lib/sdl2image.r3`

Similar API to bfont.r3 but for PC-font-style rendering. Key words:

```
::pcfont  ( -- )           activate PC font
::pccolor ( rrggbb -- )    set color
::pcemit  ( ascii -- )     draw character
::pcprint ( -- )           print formatted
::pcemits ( "" -- )        print string
::pcat    ( x y -- )       set position
::gotoxy  ( x y -- )       move cursor
::gotox   ( x -- )         move to column
::pccr    ( -- )           carriage return
::pcsp    ( -- )           space
::pcnsp   ( n -- )         n spaces
::pcsize  ( "" -- "" w h ) measure string
::pcrect  ( "" -- "" x y w h )  bounding rect
::pcpos   ( -- x y )       cursor position
::pccursor   ( n -- )      draw cursor
::pccursori  ( n -- )      inverted cursor
::pcfbox  ( -- )           fill box
::pcbox   ( -- )           outline box
::pcbox2  ( -- )           alternate box
::pcfillline ( x y w h -- ) fill horizontal band
::pcprintz   ( .. "" size -- )  print at size
::pcemitsz   ( "" size -- )  print string at size
```

---

### ttfont.r3

TrueType font rendering for SDL2 using SDL2_ttf.

**Dependencies:** `^r3/lib/sdl2gfx.r3`, `^r3/lib/sdl2ttf.r3`

```
##ttx ##tty   current text cursor position

::ttcolor    ( rrggbb -- )        set text color
::ttfont!    ( font -- )          set active TTF font handle
::ttprint    ( "" -- )            print formatted text at (ttx,tty)
::ttemits    ( "" -- )            print string
::ttat       ( x y -- )           set cursor position
::+ttat      ( dx dy -- )         move cursor by delta
::ttsize     ( "" -- "" w h )     measure string dimensions
::ttcursor   ( str strcur -- str ) draw cursor at character position
::ttcursori  ( str strcur -- str ) draw inverted cursor
::ttrect     ( "" -- "" x y w h ) get bounding rect
```

---

### txfont.r3

TrueType font atlas renderer with pseudo-UTF8 support and glyph caching.

**Dependencies:** `^r3/lib/sdl2gfx.r3`, `^r3/lib/sdl2ttf.r3`

```
-- Font Loading --
::txloadwicon ( "font" size -- nfont )   load font including icon glyphs
::txload      ( "font" size -- nfont )   load font
::txfont      ( font -- )                set active font
::txfont@     ( -- font )                get current font

-- Color --
::txrgb  ( c -- )    set text color

-- Measurement --
::txcw   ( car -- width )    width of single character
::txw    ( "" -- "" width )  width of string
::txch   ( car -- height )   height of character
::txh    ( -- height )       current line height

-- Positioning --
::txat   ( x y -- )     set cursor
::tx+at  ( x y -- )     move cursor by delta
::txpos  ( -- x y )     get cursor

-- Rendering --
::txemit   ( utf8' -- )       draw single UTF-8 character
::txwrite  ( "" -- )          draw string
::txemitr  ( "" -- )          draw string (right-to-left)
::txprint  ( .. "" -- )       draw formatted string
::txprintr ( .. "" -- )       draw formatted (right-to-left)
::txcur    ( str cur -- )     draw cursor at position
::txcuri   ( str cur -- )     draw inverted cursor
::lwrite   ( w "str" -- )     left-aligned in width
::cwrite   ( w "str" -- )     centered in width
::rwrite   ( w "str" -- )     right-aligned in width
::txalign  ( $VH -- )         set alignment flags
::txText   ( w h x y "" -- )  draw aligned text in box
```

---

### ttext.r3

Tilesheet-based terminal text renderer for SDL2. Uses a sprite sheet for characters.

**Dependencies:** `^r3/lib/sdl2gfx.r3`, `^r3/lib/sdl2image.r3`

```
##advx ##advy   character advance width/height

-- Font Setup --
::tfnt  ( size w h "filename" -- )  load tilesheet font
::tini  ( -- )                       initialize/reset state
::tsize ( zoom -- )                  set display zoom

-- Colors / Palette --
::trgb  ( c -- )     set color from 24-bit RGB
::tpal  ( c -- rgb ) get palette entry c
::tcol  ( c -- )     set color from palette index
::tfbox ( -- )       fill background box
::tbox  ( -- )       draw background box

-- Positioning --
::tat   ( x y -- )    set cursor (pixel)
::tatx  ( x -- )      set x only
::txy   ( x y -- )    set cursor (tile grid)
::tx    ( x -- )      set x (tile grid)
::tcx   ( -- x )      cursor x (pixel)
::tcy   ( -- y )      cursor y (pixel)
::tpos  ( -- x y )    get cursor position
::tcr   ( -- )        carriage return
::tsp   ( -- )        space
::tnsp  ( n -- )      n spaces

-- Rendering --
::temit  ( ascii -- )    draw single character
::tprint ( -- )          print formatted (uses stack)
::temits ( "" -- )       print string

-- Measurement --
::tsbox  ( "" -- "" w h )       string dimensions
::trect  ( "" -- "" x y w h )   bounding rect
::tsrcsize ( x y w h -- x y w h ) source size for tilemap

-- Cursor Rendering --
::tcursor   ( n -- )    draw cursor style n
::tcursori  ( n -- )    inverted cursor
```

---

### textb.r3

Renders text into a box with word wrapping, color, and offset parameters.

**Dependencies:** `^r3/lib/math.r3`, `^r3/lib/color.r3`, `^r3/lib/sdl2gfx.r3`, `^r3/lib/sdl2ttf.r3`

```
::textbox ( str $colb-colo-ofvh-colf w h font -- texture )
```

Parameters: `str`=text string, `$colb`=background color, `$colo`=text outline color, `$ofvh`=packed vertical/horizontal offset, `$colf`=foreground color, `w h`=box dimensions, `font`=TTF font handle. Returns SDL texture.

---

### sdlgui.r3

Immediate-mode GUI framework with TrueType font rendering for SDL2.

**Dependencies:** `^r3/lib/gui.r3`, `^r3/lib/sdl2gfx.r3`, `^r3/util/ttfont.r3`

#### Theme Variables
```
##padx 2  ##pady 2         padding between widgets
##curx 10  ##cury 10        current cursor position
##boxw 100  ##boxh 20       default widget size
##immcolorwin  $666666      window background color
##immcolortwin $444444      title bar background color
##immcolortex  $ffffff      text color
##immcolorbtn  $0000ff      button color
```

#### Setup and Layout
```
::immgui    ( -- )            initialize GUI state each frame
::immSDL    ( font -- )       initialize with TTF font
::immat     ( x y -- )        set cursor position
::immat+    ( dx dy -- )      move cursor by delta
::immbox    ( w h -- )        set widget size
::immfont!  ( font -- )       change active font
::immpad!   ( px py -- )      set padding
::immwinxy  ( x y -- )        set window origin + update cursor
::imm>>     ( -- )            indent right by box width
::imm<<     ( -- )            unindent
::immdn     ( -- )            move cursor down one row
::immcr     ( -- )            carriage return (new row)
::immln     ( -- )            new line
::plgui     ( -- )            placeholder layout
::plxywh    ( -- )            placeholder x y w h

-- Cursor Save/Restore --
::immcur    ( x y w h -- )   set cursor state
::immcur>   ( -- cur )       save cursor
::imm>cur   ( cur -- )       restore cursor

::immwidth  ( w -- )          override widget width
```

#### Widget Words
```
::immlabel   ( "" -- )      display text label
::immlabelc  ( "" -- )      centered label
::immlabelr  ( "" -- )      right-aligned label
::imm.       ( "" -- )      print text inline
::immStrC    ( "" -- )      centered string
::immListBox ( lines -- )   scrollable list box
::immback    ( color -- )   filled color background
::immblabel  ( "" -- )      bold label
::immicon    ( nro x y -- ) draw icon by number at offset
::immiconb   ( nro -- )     draw icon (block style)
::immbtn     ( 'click "" -- )   button; executes 'click on click
::immibtn    ( 'click nro -- )  icon button
::immtbtn    ( 'click "" -- )   toggle button
::immebtn    ( 'click "" -- )   edit-style button
::immzone    ( 'click -- )      clickable zone (no visual)
::immSliderf ( 0.0 1.0 'value -- )  float slider [min..max]
::immSlideri ( 0 255 'value -- )    integer slider
::immCheck   ( 'val "opt1|opt2" -- ) checkbox group
::immScrollv ( 0 max 'value -- )    vertical scroll bar
::immRadio   ( 'val "opt1|opt2|opt3" -- ) radio button group
::immCombo   ( 'val "opt1|opt2|opt3" -- ) combo/dropdown
::immInputLine  ( 'buff max -- )    single-line text input
::immInputInt   ( 'var -- )         integer input
```

#### Window Management
```
::immwin!   ( win -- )        set window pointer
::immwin$   ( win -- )        set window from stack
::immwin    ( 'win -- 0/1 )   begin window (returns 1 if visible)
::immnowin  ( xini yini w h -- )  window without title bar
::immwinbottom ( ywin -- )    pin window to bottom
::winexit   ( -- )            close current window
::immRedraw ( -- )            force redraw
::immwins   ( -- )            end of window frame
```

---

### sdlbgui.r3

Immediate-mode GUI framework using bitmap font instead of TTF.

**Dependencies:** `^r3/lib/gui.r3`, `^r3/lib/sdl2gfx.r3`, `^r3/lib/input.r3`

Same widget API as sdlgui.r3 but renders with bfont. Key differences: no `immfont!`, no `immSDL` — uses preloaded bitmap font. Has `immInputLine2` (two-line input variant).

---

### sdlfiledlg.r3

File open/save dialog using sdlgui.r3.

**Dependencies:** `^r3/util/sdlgui.r3`

```
::immlist       ( cnt -- )           render file list (cnt visible lines)
::filedlgini    ( -- )               initialize file dialog state
::immfileload   ( 'vecload 'file -- ) show load dialog; calls 'vecload on confirm
::immfilesave   ( 'vecload 'file -- ) show save dialog; calls 'vecload on confirm
::fullfilename  ( -- )               push full path to stack
```

---

### dlgcol.r3

Interactive color picker dialog for SDL2.

**Dependencies:** `^r3/lib/sdl2gfx.r3`, `^r3/lib/color.r3`, `^r3/lib/gui.r3`, `^r3/util/bfont.r3`

```
##colord 0        currently selected color

::color!        ( color -- )       set current color
::dlgColor      ( x y -- )         render color picker at x,y
::dlgColorIni   ( -- )             initialize picker state
::xydlgColor!   ( x y -- )         set picker position
```

---

### dlgfile.r3

File browser dialog for SDL2 (uses gui.r3 input system).

**Dependencies:** `^r3/lib/sdl2gfx.r3`, `^r3/lib/gui.r3`, `^r3/lib/input.r3`

```
::dlgFileLoad  ( -- fn/0 )          show file open dialog; returns filename or 0
::dlgFileSave  ( -- fn/0 )          show file save dialog
::dlgSetPath   ( "path" -- )        set initial directory
```

---

### immi.r3

Modern grid-layout immediate-mode GUI for SDL2 (version 3, 2025). Uses txfont for rendering.

**Dependencies:** `^r3/lib/sdl2gfx.r3`, `^r3/util/txfont.r3`

#### Layout System
The layout cursor `(cx, cy, cw, ch)` tracks current widget position. The frame stack allows push/pop for nested layouts.

```
##cx ##cy ##cw ##ch    current widget cursor (position + size)
::%cw  ( -- w )        percent of frame width
::%ch  ( -- h )        percent of frame height

-- Frame Management --
::uiBox     ( x y w h -- )   set frame
::uiFull    ( -- )            fill entire window
::uiPush    ( -- )            push frame state
::uiPop     ( -- )            pop frame state
::uiRest    ( -- )            restore frame
::uiPading  ( x y -- )       set padding
::uiAt      ( x y -- )       absolute position within frame
::uiTo      ( w h -- )       set widget size

-- Splits (divide current frame) --
::uiN  ( lines -- )    take N lines from top
::uiS  ( lines -- )    take N lines from bottom
::uiE  ( cols -- )     take N columns from right
::uiO  ( cols -- )     take N columns from left
::uiGrid ( c r -- )    divide into grid (c columns, r rows)
::uiNext   ( -- )      advance to next grid cell
::uiNextV  ( -- )      advance vertically

-- Input State Queries --
::uiEx?    ( -- 0/1 )   mouse over?
::uiOvr    ( 'v -- )    execute if mouse over
::uiDwn    ( 'v -- )    execute if mouse down in widget
::uiSel    ( 'v -- )    execute if selected
::uiClk    ( 'v -- )    execute if clicked
::uiUp     ( 'v -- )    execute on mouse release
::uiFocusIn ( 'v -- )   execute when focus enters
::uiFocus   ( 'v -- )   execute while focused

-- Frame Lifecycle --
::uiStart      ( -- )    begin UI frame
::uiEnd        ( -- )    end UI frame
::uiZone       ( -- )    create interaction zone (cx cy cw th)
::uiZoneL      ( n -- )  zone spanning n lines
::uiZoneW      ( -- )    zone filling cw×ch
::uiZoneBox    ( x y w h -- )  explicit zone rect
::uiSaveLast   ( x y w h 'v -- ) save last zone dimensions
::uiBackBox    ( -- )    draw background box
::uiExitWidget ( -- )    early exit from widget
::uiPlace      ( n -- )  place widget at grid position n
```

#### Focus
```
::uiRefocus     ( -- )    reset focus
::uiFocus>>     ( -- )    move to next focusable
::uiFocus<<     ( -- )    move to previous
::tabfocus      ( -- )    advance focus on Tab key
```

#### Drawing Helpers
```
::uiFill     ( -- )     fill cx cy cw ch
::uiRect     ( -- )     outline cx cy cw ch
::uiRFill    ( -- )     rounded filled
::uiRRect    ( -- )     rounded outline
::uiCRect    ( -- )     circle outline (uses min of w,h)
::uiCFill    ( -- )     circle filled
::uiTex      ( tex -- ) draw texture in widget area
::uiWinBox   ( -- x y w h )  window bounds
::uiLineGridV ( -- )    draw vertical grid lines
::uiLineGridH ( -- )    draw horizontal grid lines
::uiLineGrid  ( -- )    draw both grid lines
```

#### Status Styles
```
::stDang ( -- )   danger style (red)
::stWarn ( -- )   warning style (amber)
::stSucc ( -- )   success style (green)
::stInfo ( -- )   info style (blue)
::stLink ( -- )   link style
::stDark ( -- )   dark style
::stLigt ( -- )   light/white style
```

#### Widgets
```
-- Labels and Text --
::uiTlabel   ( -- )            text label from stack
::uiLabel    ( -- )            centered label
::uiLabelC   ( -- )            explicitly centered
::uiLabelR   ( -- )            right-aligned
::uiText     ( "" align -- )   text with alignment
::ttwrite    ( "text" -- )     write text (left)
::ttwritec   ( "text" -- )     write centered
::ttwriter   ( "text" -- )     write right

-- Buttons --
::uiBtn   ( 'click "" -- )    standard button
::uiRBtn  ( 'click "" -- )    rounded button
::uiCBtn  ( 'click "" -- )    circular button
::uiTBtn  ( 'click "" align -- )  text button with alignment
::uiNBtn  ( v "" -- )         button width from text

-- Input --
::uiInputLine  ( 'buff max -- )   single-line text input
::uiCheck      ( 'var 'list -- )  checkbox (list = option strings)
::uiRadio      ( 'var 'list -- )  radio group
::uiCombo      ( 'var 'list -- )  combo box / dropdown
::uiList       ( 'var cntl 'list -- ) scrollable list
::uiTree       ( 'var cntl list -- ) collapsible tree
::uiNindx      ( n -- str )        get list item string n

-- Sliders and Progress --
::uiSliderf    ( 0.0 1.0 'value -- )   horizontal float slider
::uiSlideri    ( 0 255 'value -- )     horizontal integer slider
::uiVSliderf   ( 0.0 1.0 'value -- )  vertical float slider
::uiVSlideri   ( 0 255 'value -- )    vertical integer slider
::uiProgressf  ( 0.0 1.0 'value -- )  float progress bar
::uiProgressi  ( 0 255 'value -- )    integer progress bar
```

#### Window Management (immi)
```
::immwin!       ( win -- )
::immwin$       ( win -- )
::immwin        ( 'win -- 0/1 )
::immnowin      ( x y w h -- )
::immwinbottom  ( ywin -- )
::winexit       ( -- )
::immRedraw     ( -- )
::immwins       ( -- )
::immSDL        ( font -- )
::immblabel     ( "" -- )
::immicon       ( nro x y -- )
::immiconb      ( nro -- )
::immwidth      ( w -- )
```

---

### imcolor.r3

Color selector widget for immi.

**Dependencies:** `^r3/lib/color.r3`, `^r3/util/immi.r3`

```
::color!     ( color -- )    set current color
::uiColor    ( 'var -- )     full color selector widget (HSV + RGB sliders)
::uiColorH   ( 'var -- )     compact horizontal color selector
```

---

### imedit.r3

Code editor widget for immi with syntax highlighting and marks.

**Dependencies:** `^r3/lib/parse.r3`, `^r3/lib/color.r3`, `^r3/util/immi.r3`

```
##ycursor ##xcursor    cursor row, column
##edfilename * 1024    current file path
##inisel               selection start
##finsel               selection end
##fuente               editable text buffer
##fuente>              cursor pointer into buffer

-- Syntax Marks --
::clearmark   ( -- )               clear all syntax marks
::addmark     ( -- )               add mark at current position
::addsrcmark  ( src color -- )     add colored mark
::showmark    ( -- )               render marks

-- Editor Display --
::edcodedraw  ( -- )    draw code with syntax highlighting
::edfill      ( -- )    fill editor background
::edtoolbar   ( -- )    render editor toolbar

-- Focus --
::edfocus     ( -- )    interactive code editor (focused)
::edfocusro   ( -- )    read-only editor

-- Editor RAM Management --
::edram       ( -- )    allocate editor RAM

-- Widget Setup --
::edwin      ( x y w h -- )  set editor window position/size
::edloadmem  ( "" -- )       load text from string into editor
::edload     ( "" -- )       load file into editor
::edsave     ( -- )          save editor contents to file
```

---

### imfiledlg.r3

File open/save dialog for immi.

**Dependencies:** `^r3/util/immi.r3`

```
::immfileload  ( 'vecload 'file -- )  show load dialog
::immfilesave  ( 'vecload 'file -- )  show save dialog
::fullfilename ( -- )                 push current full path
::uiFileName   ( 'var -- )            file name input widget
```

---

### immdatetime.r3

Calendar and time picker widgets for immi.

**Dependencies:** `^r3/lib/jul.r3`, `^r3/util/immi.r3`, `^r3/util/datetime.r3`

```
::uiDateTime  ( 'var -- )   full date+time picker widget
::uiDate      ( 'var -- )   date-only calendar widget
::uiTime      ( 'var -- )   time-only picker widget
```

The variable stores packed date/time as a 64-bit value; use `datetime.r3` words to interpret it.

---

### tui.r3

Text UI layout framework for terminal interfaces.

**Dependencies:** `^r3/lib/console.r3`, `^r3/util/utfg.r3`

#### Frame Layout
A "frame" defines a rectangular region of the terminal. Frames can be split and nested.

```
##fx ##fy ##fw ##fh   current frame (x y width height)

-- Frame Setup --
::flx!     ( x y w h -- )   set frame
::flx      ( -- )            restore frame from stack
::flxpush  ( -- )            push current frame
::flxpop   ( -- )            pop frame
::flxRest  ( -- )            restore last
::flxvalid? ( -- 0 )         0 = frame is not valid

-- Frame Splits --
::flxN  ( lines -- )   take from top
::flxS  ( lines -- )   take from bottom
::flxE  ( cols -- )    take from right
::flxO  ( cols -- )    take from left
::fw%   ( -- w. )      percent of frame width (16.16)
::fh%   ( -- h. )      percent of frame height

-- Utilities --
::flpad  ( x y -- )    add padding to frame
::flcr   ( -- )        carriage return within frame
::flin?  ( x y -- f )  is x,y inside current frame?
::flin?1 ( x y -- f )  inside? (alternate)
```

#### Event Flags
```
##uikey            current key code

::exit    ( -- )   request application exit
::tuX?    ( -- f ) check for pending action (local flag)
::tuR!    ( -- )   request redraw
::tuC!    ( -- )   enable cursor
```

#### Main Loop
```
::tui         ( -- )           run TUI event loop
::onTui       ( 'vector -- )   set main TUI handler
::onTuia      ( 'vector -- )   set TUI handler (alternate, no clear)
::tuiw        ( -- flag )      is current widget active? (interactive zone)
::tuiw1       ( -- flag )      single-line interactive zone
::tuif        ( -- flag )      is focused?
::tuRefocus   ( -- )           reset focus
```

#### Window Drawing
```
::.wfill    ( -- )             fill current frame
::.wborde   ( -- )             single-line border
::.wborded  ( -- )             double-line border
::.wbordec  ( -- )             corner-style border
::.wtitle   ( place "" -- )    draw title in frame
::tuWin     ( -- )             draw window (border+fill)
::tuWina    ( -- )             draw window (no fill)
::.tdebug   ( -- )             show debug info
```

#### Widgets
```
-- Buttons and Labels --
::tuTBtn   ( 'ev "" -- )      toggle button
::tuBtn    ( -- )             standard button
::tuLabel  ( "" -- )          left-aligned label
::tuLabelC ( "" -- )          centered label
::tuLabelR ( "" -- )          right-aligned label
::tuText   ( "" align -- )    text with alignment

-- Lists --
::tuList      ( 'var list -- )    scrollable list
::tuTree      ( 'var list -- )    collapsible tree
::uiNindx     ( n -- str )        get list item n

-- Input --
::tuInputLine ( 'buff max -- )   single-line text input
::tuCheck     ( 'var "label" -- ) checkbox
::tuRadio     ( n 'var "label" -- ) radio button (option n)
::tuSlider    ( 'var min max -- )  slider
::tuProgress  ( percent -- )      progress bar (0..100)

-- Write helpers --
::xwrite!       ( -- )    reset write state
::xwrite.reset  ( -- )    reset accumulated write
##padi>                   write start offset

```

---

### tuiedit.r3

Full-featured text editor widget for TUI framework. Supports selection, clipboard, and undo.

**Dependencies:** `^r3/util/tui.r3`, `^r3/lib/clipboard.r3`

```
##filename * 1024     current file path
##fuente              text buffer pointer
##fuente>             cursor pointer
##$fuente             end of text pointer

-- Cursor Control --
::tuiecursor! ( cursor -- )   set cursor to pointer
::tuipos!     ( pos -- )      set cursor to integer position

-- Hash / Change Detection --
::editfasthash ( -- fh )      compute fast hash of text (change detection)

-- Key Handlers --
::tueKeyMove  ( -- )    process cursor movement keys

-- Display --
::tuEditShowCursor ( -- )   display cursor
::tuecursor.       ( -- )   render cursor indicator

-- Editor Modes --
::tuEditCode     ( -- )    interactive code editor (normal fonts)
::tuReadCode     ( -- )    read-only code display
::tuEditCodeMono ( -- )    interactive code editor (monospace)
::tuReadCodeMono ( -- )    read-only monospace display

-- File Operations --
::TuLoadMem    ( "" -- )    load text from string
::TuLoadMemC   ( "" -- )    load text (already sanitized)
::TuLoadCode   ( "" -- )    load from file
::TuNewCode    ( -- )       new/empty file
::TuSaveCode   ( -- )       save to current ##filename

-- Marks (Syntax / Search) --
::tokenCursor  ( 'mark -- )   set cursor to mark
```

---

### vscreen.r3

Virtual resolution rendering. Renders to an internal texture at logical size, then scales to the actual window.

**Dependencies:** `^r3/lib/sdl2.r3`

```
::vscreen ( w h -- )   set virtual resolution (w×h logical pixels)
::vini    ( -- )       initialize virtual screen (call after SDLinit)
::vredraw ( -- )       copy virtual texture to window (call at end of frame)
::vfree   ( -- )       free virtual screen resources

::sdlx    ( -- x )     convert screen x to virtual x
::sdly    ( -- y )     convert screen y to virtual y
::%w      ( -- w. )    virtual width as fixed-point fraction
::%h      ( -- h. )    virtual height as fixed-point fraction
```

---

### tilesheet.r3

Tile map system with scrolling view.

**Dependencies:** `^r3/lib/mem.r3`, `^r3/lib/math.r3`, `^r3/lib/sdl2image.r3`, `^r3/lib/sdl2gfx.r3`

```
::[map]      ( x y -- adr )         address of tile at x,y in map
::loadtilemap ( "" -- amap )         load tile map from file

-- Rendering --
::drawtile   ( y x tile -- y x )    draw single tile
::tiledraw   ( w h x y sx sy 'amap -- )        draw tilemap (sx/sy = scroll offset)
::tiledrawv  ( w h x y sx sy 'amap 'vec -- )   draw + call 'vec for each tile
::tiledraws  ( w h x y sx sy sw sh 'amap -- )  draw subregion of map
::tiledrawvs ( w h x y sx sy sw sh 'amap 'v -- ) draw subregion + callback

-- Coordinate Conversion --
::scr2view  ( xs ys -- xv yv )    screen to view coordinates
::scr2tile  ( x y -- adr )        screen to tile address (valid after tiledraw)
```

---

### bmap.r3

Multi-layer tile map for 2D games with isometric and z-sorted sprite rendering.

**Dependencies:** `^r3/lib/console.r3`, `^r3/lib/sdl2gfx.r3`, `^r3/util/sdlgui.r3`, `^r3/util/arr16.r3`, `^r3/lib/rand.r3`

```
##bsprdraw  draw sprite function pointer (redefine for custom sprite drawing)

::inisprite ( -- )             initialize sprite system
::+sprite   ( N x y -- )       add sprite N at position (x,y) to draw list
::drawmaps  ( xvp yvp -- )     draw all map layers at viewport position
::loadmap   ( filename -- )    load tile map from file
::bmap2xy   ( x y -- x' y' )  convert map coords to screen coords
::whbmap    ( -- w h )         get map dimensions in tiles
::xyinmap@  ( x y -- map )     read map value at tile (x,y)
::xytrigger ( x y -- x y )     check trigger at tile position
```

---

### loadobj.r3

Wavefront OBJ/MTL 3D model loader.

**Dependencies:** `^r3/lib/mem.r3`, `^r3/lib/parse.r3`, `^r3/lib/sdl2image.r3`

```
-- Vertex Data (after loadobj) --
##verl  ##nver        vertex list, count
##facel ##nface       face list, count (triangles or quads)
##norml ##nnorm       normal list, count
##texl  ##ntex        UV coordinate list, count
##paral ##npara       parameter list, count
##colorl ##ncolor     color list, count

-- Accessors --
::]face  ( nro -- adr )   address of face nro (fields: p1 p2 p3 color)
::]vert  ( nro -- adr )   address of vertex nro
::]norm  ( nro -- adr )   address of normal nro
::]uv    ( nro -- adr )   address of UV coord nro

-- Material (MTL) Accessors --
::]Ka@  ::]Kd@  ::]Ks@  ::]Ke@   ambient/diffuse/specular/emission
::]Ns@  ::]Ni@  ::]d@   ::]i@    shininess/refraction/dissolve/illumination
::]Mkd@ ::]MNs@ ::]Mbp@           texture map filenames

-- Loading --
::loadobj  ( "" -- mem )    load OBJ file, return memory base

-- Geometry Operations --
##xmin ##ymin ##zmin ##xmax ##ymax ##zmax   bounding box (after objminmax)
::objminmax    ( -- )           compute bounding box of all vertices
::objmove      ( x y z -- )    translate all vertices
::objcentra    ( -- )           center model at origin
::objescala    ( por div -- )  scale all vertices by por/div
::objescalax   ( por div -- )  scale X only
::objescalay   ( por div -- )  scale Y only
::objescalaz   ( por div -- )  scale Z only
::objcube      ( lado -- )     generate a unit cube of side `lado`
::getpath      ( str -- str )  extract directory path from filepath
::>>cr         ( adr -- adr'/0 ) advance to next line in text
::cnt/         ( -- )          count faces
```

---

### datetime.r3

Date and time formatting in Spanish. Provides string output words.

**Dependencies:** `^r3/lib/mem.r3`

```
-- Append to Heap (,time / ,date style) --
::,time       ( -- )    append current time HH:MM:SS
::,ti:me      ( -- )    append time with colon separators
::,date       ( -- )    append current date DD/MM/YYYY
::,date-      ( -- )    append date with dash separators

-- Raw String Generation --
::str_DMA     ( -- str )  "D/M/A" formatted date
::str_HMS     ( -- str )  "H:M:S" formatted time
::str_HM      ( -- str )  "H:M" time
::str_fullday ( -- str )  full day name (e.g. "Lunes")
::str_hhmmss  ( -- str )  "HH:MM:SS"

-- Day and Month Names --
::>dianame    ( n -- str )  day name by number (0=Domingo..6=Sábado)
::>mesname    ( n -- str )  month name by number (1..12)

-- SQL / Database Formats --
::dt2timesql  ( 'sysdate -- )   format as SQL datetime string

-- 64-bit Packed DateTime --
::dt>64     ( datetime -- dt64 )   pack system datetime to 64-bit
::,64>dtf   ( dt64 -- "d/m/y h:m" )  format packed to display string
::,64>dtd   ( dt64 -- "d/m/y" )       date only
::,64>dtt   ( dt64 -- "h:m:s" )       time only
::64>dtc    ( dt64 -- "y-m-d h:m:s" ) ISO format (for databases)
```

---

### db2.r3

Text database version 2. Records separated by ASCII 30 (RS), fields by ASCII 31 (US), rows by ASCII 29 (GS).

**Dependencies:** `^r3/lib/console.r3`

```
##rowdb    current row pointer after search

-- File Loading --
::getnfilename ( n "path" -- filename/0 )   get nth file in path
::loadnfile    ( "" -- filename )            load next file in series
::loaddb-i     ( "filename" -- )             load DB into global (indexed)
::prevdb-i     ( "filename" -- )             load previous version
::loaddb       ( "filename" -- 'db )         load DB, return pointer

-- Record Iteration --
::>>line  ( adr -- adr'/0 )   advance to next record (0 = end)

-- Field Access --
::dbfld     ( nro -- string )           get field nro from current row
::getdbrow  ( id 'db -- 'row )          find row by ID
::findbrow  ( hash 'db -- 'row/0 )      find row by hash key (0=not found)
::cntdbrow  ( 'db -- cnt )              count records in database
::>>fld     ( adr -- adr' )             advance to next field
::getdbfld  ( nro 'row -- 'fld )        get field nro from row
::cpydbfld  ( 'fld 'str -- )            copy field to string buffer
::cpydbfldn ( max 'fld 'str -- )        copy field with max length
```

---

### dbtxt.r3

Text database version 1. Records separated by newline, fields by `|`, rows by `^`.

**Dependencies:** `^r3/lib/console.r3`

Same API as db2.r3. Same word names:
`getnfilename`, `loadnfile`, `>>line`, `loaddb-i`, `prevdb-i`, `dbfld`, `loaddb`, `getdbrow`, `findbrow`, `cntdbrow`, `>>fld`, `getdbfld`, `cpydbfld`, `cpydbfldn`.

Use `dbtxt.r3` for pipe-delimited flat text, `db2.r3` for binary-delimited packed format.

---

### filedirs.r3

Filesystem scanner providing file/directory trees for UI list and tree widgets.

**Dependencies:** `^r3/lib/mem.r3`, `^r3/util/datetime.r3`, `^r3/util/tui.r3`

```
##uiDirs     pointer to directory list
##uiFiles    pointer to file list

-- File Path Operations --
::flcpy       ( 'file 'str -- )        copy file entry to string
::flTreePath  ( n -- str )             get path of tree item n

-- Scanning --
::FlGetFiles   ( filename -- )         populate file list for given path
::flScanDir    ( "" -- )               scan directory into uiDirs/uiFiles
::flScanFullDir ( "" -- )              full recursive scan
::flOpenFullPath ( str -- place )      open/expand to given path in tree
```

---

*End of r3forth Library Reference*
