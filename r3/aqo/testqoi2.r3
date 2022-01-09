
| qoi encoder/decoder
| PHREDA 2021
^r3/lib/mem.r3
^r3/win/console.r3
^r3/win/sdl2.r3
^r3/win/sdl2image.r3
^r3/util/bfont.r3
|^r3/aqo/qoi2.r3
^r3/aqo/aqoi.r3

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
$80 $6 | 1 2 3 4 | 0 = 4 menos de 4 no
$0 3
$84 $9 | 3 4 5 5 6 1 2 3
$9 1 3 6 6 6 5 4 1 2 3
)
|---------- 2do pass

	
:lit2 | adr --
	1 + ( 1? 1 - cb@+ ca!+ ) drop ;
	
:dec2pass
	cb@+ $80 nand? ( lit2 ; )
	$7f and 4 +
	a> cb@+ 1 + -
	swap ( 1? 1 -
		swap c@+ ca!+ swap ) 2drop ;

:pass2decode | 'adre adr dst --
	>a >b
	( b> <? 
		dec2pass
		) drop ;
	
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
	c! ;				| store first

:unset | byte --
	-1 swap 'bcnt + c+! ;
	
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
	dup "%h? " .print
	dup 'bcnt + c@ 0? ( drop ; ) | no hay
	over 'bfirst + c@ $ff and | byte cnt first
	( 
|		dup "%h-" .print
		testoff maxcnt >? ( over 'maxoff ! dup 'maxcnt ! ) drop
		swap 1 - 1? swap 
		'bnext + c@ $ff and  | byte cnt first
		) 2drop ;
	
:debug
|	'bcnt 32 .pmem cr
|	'bfirst 32 .pmem cr	
|	'bnext 32 .pmem cr	

	.input
	;

:enclit | nro --
	dup 1 - cb!+ 
	( 1? 1 - ca@+ cb!+ ) drop ;
	
:endcpy	| off nro --
	dup a+
	4 - $80 or cb!+ 1 - cb!+ ;

#lenlit #adrlit
#lencpy #adrcpy

:enlit | len
	"lit %d " .println
	0 'lenlit !
	;
	
:runencode
	maxcnt 4 <? ( drop 1 'lenlit +! ; )
	lenlit 1? ( enlit ) drop
	lencpy "run %d " .println
	lencpy a+
	0 'lencpy !
	;
	
:encode | dest src cnt -- cdest
	0 'lenlit ! over 'adrlit !
	0 'lencpy ! over 'adrcpy !
	over 'startmem !
	swap >a swap >b | a=src b=dst
	( 1? 1 -
		a> startmem - $ff and 'posnow !
		ca@+ $ff and 
		traverse 
|		maxcnt " c:%d" .print
		runencode
		setmap
		debug
		) drop
	b> ;

|---- encode
	
#res
#cres	
:test
	.cls
	"test" .println
	'testbytes 29 .pmem cr


	here 'res !	
	res 'testbytes 29 encode 'cres !
	
|	res cres .pmem cr
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