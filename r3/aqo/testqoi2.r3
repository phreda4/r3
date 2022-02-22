| qoi encoder/decoder
| PHREDA 2021
^r3/lib/mem.r3
^r3/win/console.r3
^r3/win/sdl2gfx.r3
^r3/win/sdl2image.r3
^r3/util/bfont.r3
|^r3/aqo/qoi2.r3
^r3/aqo/aqoi.r3

^r3/lib/rand.r3


#textbitmap

#imagen
#imagens

#pixels
#wi #hi #pi

#code
#csize

#mpixel
#mpitch

:writetex	
	textbitmap 0 'mpixel 'mpitch SDL_LockTexture
	"decode" .println
	mpixel code qoi_decode2 | bitmap data -- 1/0
|	0? ( drop ; ) drop
	drop
	"decode end" .println
	textbitmap SDL_UnlockTexture
	;
	
	
:encodeimg
	.cls
	imagens SDL_LockSurface
	imagens 
	16 + 
	d@+ 'wi !
	d@+ 'hi !
	d@+ 'pi !
	4 + @ 'pixels !
	pi hi wi "w:%d h:%d p:%d" .println
	wi hi * 2 << "%h bytes" .println
	mark
	here 'code !
	
	"encode" .println
	pixels wi hi here qoi_encode2
	imagens SDL_UnlockSurface
	dup 'csize ! 
	"encode end" .println
	8 + 'here +! 0 , 
	
|	"test.qoi" savemem
	csize "size:%d" .println
	
	qw qh SDLframebuffer 'textbitmap !	
	textbitmap 1 SDL_SetTextureBlendMode | 1 = blend
	writetex	

	;
		
#box [ 100 0 500 500 ]

:draw
	$222222 SDLclear
	SDLrenderer textbitmap 0 'box SDL_RenderCopy		
	
	$ffffff bcolor
	0 0 bmat qh qw "%d %d" sprint bmprint
	0 12 bmat csize "%d" sprint bmprint
	
	SDLredraw
	
	SDLkey
	>esc< =? ( exit )
	drop ;
	
:cargar
|	"r3/aqo/dice.png" | ok
|	"r3/aqo/kodim10.png"
|	"r3/aqo/kodim23.png"
|	"r3/aqo/qoi_logo.png" |ok
	"r3/aqo/testcard.png" |ok
|	"r3/aqo/testcard_rgba.png" |OK
|	"r3/aqo/wikipedia_008.png"
	
	IMG_Load 
	dup
	$16362004 0 | format ARGB
	SDL_ConvertSurfaceFormat
	'imagens !
	SDL_DestroyTexture
	encodeimg
	;
	
|---------------------------------------
| 0nnnnnnn - n literal number 
| n=1..128
| 1nnnnnnn oooooooo - n copy from o ofsset
| n=4..131
| o=1..256
#testbytes (
1 2 3 4 5 5 6 1 2 3 4 3 3 4 5 5 6 1 2 3 3 6 6 6 5 4 1 2 3 
)

#testcomp (
$6 1 2 3 4 5 5 6 
$83 $6			| 1 2 3 4 
$0 3
$87 9			| 3 4 5 5 6 1 2 3
$8 3 6 6 6 5 4 1 2 3
)
|---------- 2do pass

	
:lit2 | adr --
	1 + ( 1? 1 - cb@+ ca!+ ) drop ;
	
:dec2pass
	cb@+ $80 nand? ( lit2 ; )
	$7f and 1 +
	a> cb@+ 1 + -
	swap ( 1? 1 -
		swap c@+ ca!+ swap ) 2drop ;

:pass2decode | 'adre adr dst -- dste
	>a >b
	( b> >? 
		dec2pass
		) drop
	a> ;
	
:.pmem | 'adr cnt --
	( 1? 1 - swap
		c@+ $ff and "%h " .print 
		swap ) 2drop ;
		
|-----------------------
| new idea
| bcnt [byte] cnt of this byte in windows
| bfisrt [byte] last position of this byte
| bnext [position] next position of the byte in this position

#startmem
#posnow
#maxcnt
#maxoff

#bcnt * 256
#bfirst * 256
#bnext * 256

:setmap | byte --
	1 over 'bcnt + c+! 	| add 1 to cnt
	posnow 				| position
	swap 'bfirst + 
	dup c@ 				| byte pos bfirst prev --
	pick2 'bnext + c!
	c! 					| store first
	
	a> 256 - startmem <? ( drop ; )
	c@ $ff and
	-1 swap 'bcnt + c+! 	| remove from window
	;				
	
:compare | s1 s2 -- s1'
	( c@+ rot c@+ rot 
|		2dup "%h=%h " .println 
		=? drop swap ) drop nip ;
		
:testoff | pos -- pos cnt
	a> a> posnow pick3 - 
	-? ( 256 + )
	- compare a> - 
	;
	
:traverse | byte -- byte
	0 'maxcnt !
	a> startmem - "%d " .print
	dup "%h? " .print
	dup 'bcnt + c@ 0? ( drop ; ) | no hay
	over 'bfirst + c@ $ff and | byte cnt first
	( 
|		dup "%d-" .print
		testoff maxcnt >? ( over 'maxoff ! dup 'maxcnt ! ) drop
		swap 1 - 1? swap 
		'bnext + c@ $ff and  | byte cnt first
		) 2drop 
	maxcnt " max:%d" .print cr 
	;
	
#adrfrom
#lenlit 

| encode literal
:enclit | len --
	0? ( drop ; )
	dup "lit %d " .print
	dup 1 - cb!+ |"$%h " .print
	adrfrom swap 
	( 1? 1 - swap c@+ cb!+ swap ) drop
	'adrfrom ! ;

:enlit | --
	lenlit 0? ( drop ; ) 
	( 127 >? 
		128 enclit 
		128 - ) 
	enclit 
	0 'lenlit ! ;
	
:encpy | off cnt --
	( 127 >?
		127 $80 or cb!+ over cb!+
		128 - )
	0? ( 2drop ; )
	1 - $80 or cb!+ cb!+
	;
	
:runencode | i byte -- 
	maxcnt 4 <? ( drop 1 'lenlit +! setmap ; ) drop
	enlit 
	
	posnow maxoff - 
	-? ( 256 + ) 1 - 
	maxcnt 
	encpy
	
	setmap
	maxcnt 1 - ( 1? 1 -
		a> startmem - $ff and 'posnow !	
		ca@+ $ff and 
		setmap ) drop
|	dup "{%d}" .print
	maxcnt - 1 +
	maxcnt 'adrfrom +!
	;
	
:encode | dest src cnt -- cdest
	0 'lenlit ! 
	over 'adrfrom !
	over 'startmem !
	swap >a swap >b | a=src b=dst
	( 1? 1 - 
		dup "{%d}" .print
		a> startmem - $ff and 'posnow !
		ca@+ $ff and 
|		over "1)%d=" .print
		traverse 
|		over "2)%d=" .print
|		2dup "+%h %d+" .println
		runencode
|		dup "3)%d=" .print
		) drop
|	dup "$%h " .print
	enlit
	b> ;

|---- encode
#res
#cres	

#compr
#cdst

:randmem
	swap >a ( 1? 1 - 5 randmax ca!+ ) drop ;

:randtest
	here 'res !
	res 1024 randmem
	res 1024 .pmem cr
	
	1024 'here +!
	here 'cdst !
	here res 1024 encode 'cres !

|	.input
	here 'compr !
	here cres over - .pmem cr
	cres here - "%d bytes" .println
	cres 1 + 'here !
	
	cres compr here pass2decode 'cdst !

	here cdst over - .pmem cr
	cdst here - "%d bytes" .println
	;
	
:auxtest	
"..................." .println
	
	'testbytes 29 .pmem cr
	here 'res !	
	res 'testbytes 29 encode 'cres !
	cr 
	res cres over - 
	dup "cnt:%d " .println
	.pmem cr
	cres 1 + 'here !
	
|	cres res here pass2decode 'cdst !
	
|	here cdst over - .pmem cr
	
|	res cres .pmem cr

	;
	
:test
	.cls
	"test" .println
	
	randtest

	.input
	;
	
|-------------------------
:testimg
	"r3sdl" 800 600 SDLinit
	bfont1
	cargar
	'draw SDLshow 
	SDLquit	
	;
	
|------------------------------------
:
	test
|	testimg
	;