| PHREDA 2017 idea
| dibujo de triangulo por punto medio
| para voxelizar triangulos texturados
|--------------------------
^r3/lib/sdl2gfx.r3

#textbitmap #mpixel #mpitch

:px! | col x y 
	mpitch * swap 2 << + mpixel + d! ;
:xyp | x y -- a	
	mpitch * swap 2 << + mpixel + ;
	
#verlist * $ffff
#cache

:colavg | a b -- c
	2dup or -rot xor $fefefefe and 1 >> - ;

| rrggbbxzzzyyyxxx
:xyzavg
	2dup or -rot xor $fefefefffeffeffe and 1 >> - ;
	
:xyz>v | rgb x y z -- v
	$fff and 24 << 
	swap $fff and 12 << or
	swap $fff and or 
	swap 36 << or ;
	
:set! | v --
	dup 36 >> swap
	dup 12 >> $fff and mpitch * 
	swap $fff and 2 << + mpixel + 
	d! ;
	
:v1@
	a> 3 3 << - @ ;
:v2@
	a> 2 3 << - @ ;
:v3@
	a> 1 3 << - @ ;
	
:rectri | --
	v1@ v2@ - v3@ - 0? ( v1@ set! -3 3 << a+ ; ) drop
	v1@ v2@ v3@
	pick2 a!+
	pick2 pick2 xyzavg a!+
	pick2 over xyzavg a!+
	rectri
	over a!+
	over pick3 xyzavg a!+
	over over xyzavg a!+
	rectri
	dup a!+
	dup pick3 xyzavg a!+
	dup pick2 xyzavg a!+
	rectri
	2dup xyzavg a!+ | 2 3
	pick2 xyzavg a!+ | 3 1
	xyzavg a!+ | 1 2
	rectri
	-3 3 << a+ 
	;
	
:drawtri2 | v1 v2 v3 --
	mark
	here >a 
	a!+ a!+ a!+ 
	rectri
	empty
	;

|	$ffffff 100 100 10 xyz>v set!
|	$ffffff 101 100 10 xyz>v set!
|	$ffffff 102 100 10 xyz>v set!
	
	
|--------------------------	
	
:draw1p
	d@+ swap d@+ swap 4 + d@
	-rot 
	xyp d!
	;

:endtri
	dup draw1p 48 - ;

| x y z uv
:samep | adr --
	dup d@
	over 16 + d@ <>? ( drop 0 ; )
	over 32 + d@ <>? ( drop 0 ; )
	drop

	dup 4 + d@
	over 20 + d@ <>? ( drop 0 ; )
	over 36 + d@ <>? ( drop 0 ; )
	drop 1 ;

| siempre converge a o2
:2/1 | o2 o1 -- om ;
	over - dup 31 >> - 2/ + ;

:maketri | adr --		b:src a:des
	dup d@+ db@+ 2/1 da!+ d@+ db@+ 2/1 da!+ d@+ db@+ 2/1 da!+ d@ db@+ colavg da!+
	dup d@+ db@+ 2/1 da!+ d@+ db@+ 2/1 da!+ d@+ db@+ 2/1 da!+ d@ db@+ colavg da!+
	d@+ db@+ 2/1 da!+ d@+ db@+ 2/1 da!+ d@+ db@+ 2/1 da!+ d@ db@+ colavg da!+ ;

:rectri | adr -- adr
	samep 1? ( drop endtri ; ) drop

	dup 48 + >a dup >b dup maketri
    48 + rectri

	dup 48 + >a dup >b dup 16 + maketri
    48 + rectri

	dup 48 + >a dup >b dup 32 + maketri
    48 + rectri

	dup 48 + >a dup >b
	b> 32 + d@ db@+ + 2/ da!+
	b> 32 + d@ db@+ + 2/ da!+
	b> 32 + d@ db@+ + 2/ da!+
	b> 32 + d@ db@+ colavg da!+
	b> 16 - d@ db@+ + 2/ da!+
	b> 16 - d@ db@+ + 2/ da!+
	b> 16 - d@ db@+ + 2/ da!+
	b> 16 - d@ db@+ colavg da!+
	b> 16 - d@ db@+ + 2/ da!+
	b> 16 - d@ db@+ + 2/ da!+
	b> 16 - d@ db@+ + 2/ da!+
	b> 16 - d@ db@+ colavg da!+
    48 + rectri

    48 -
	;

:tritest | 'vertez --
	-1 'cache !
	>a 'verlist >b
	a@+ b!+ a@+ b!+
	a@+ b!+ a@+ b!+
	a@+ b!+ a@+ b!+
	'verlist rectri drop
	;

|-------------------------
| x y z uv
#vertex [
189 183 0 $ff0000
200 100 0 $ff
60 160 0 $ff00
]

:drawtri
	sdly sdlx 'vertex d!+ d!
	
	textbitmap 0 'mpixel 'mpitch SDL_LockTexture
	mpixel 0 600 600 * dfill |dvc 
	'vertex tritest

	textbitmap SDL_UnlockTexture
	;

		
:draw
	drawtri
	SDLrenderer textbitmap 0 0 SDL_RenderCopy		
	SDLredraw
	SDLkey
	>esc< =? ( exit )
	drop ;

:main
	"r3sdl" 600 600 SDLinit
	600 600 SDLframebuffer 'textbitmap !
	drawtri
	'draw SDLshow 
	SDLquit	;

: main ;

