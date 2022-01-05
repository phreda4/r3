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

:printdiffimg
	cr cr
	pixels here
	hi wi * ( 1? 1 -
		hi wi * over - "%d. " .print
		rot d@+ $ffffffff and "%h " .print rot d@+ $ffffffff and "=%h " .println rot
		) 3drop	;

:printout
	cr cr
	csize "%d" .println
	code csize ( 1? 1 - swap 
		c@+ $ff and "%h " .print 
		swap ) 2drop ;
		
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
	|printout	
	|printdiffimg	
	csize "size:%d" .println
	cntINDEX "INDEX:%d" .println
	cntRUN 	 "  RUN:%d" .println
	cntLUMA  " LUMA:%d" .println
	cntXOR 	 "  XOR:%d" .println
	cntARGB1 " RGB1:%d" .println
	cntARGB2 " RGB2:%d" .println
	cntARGB3 " RGB3:%d" .println
	cntARGB4 " RGB4:%d" .println
	
	qw qh SDLframebuffer 'textbitmap !	
	textbitmap 1 SDL_SetTextureBlendMode | 1 = blend
	writetex	

	;
		
#box [ 100 0 500 500 ]
#box1 [ 410 0 500 500 ]

:draw
	$222222 SDLclear
	SDLrenderer textbitmap 0 'box SDL_RenderCopy		
|	SDLrenderer imagen 0 'box1 SDL_RenderCopy		
	
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
#testimg [
0 $f1f0f 0 $1f1f1f1f 0 0 
0 0 0 0 0 0
$ff0000 $ff00 $ff $ff00 $fe00 $8000
$ff0000 $ff00 $ff $ff00 $fe00 $8000
$100 $200 $300 $400 $500 $600
$10000 $f90000 $03f80000 $70000 $60000 $50000 

]

#result * 1024
#ressize

#backimg * 1024

:printimg |adr --
	>a
	6 ( 1? 1 -
		6 ( 1? 1 -
			da@+ $ffffffff and "%h " .print
		) drop 
	cr
	) drop ;
	
	
:test
	"encoding.." .println
	
	'testimg printimg
	
	'testimg 6 6 'result qoi_encode2 'ressize !
	
	'result 
	ressize 12 +
	( 1? 1 - swap
		c@+ $ff and "%h " .print
		swap ) drop
	cr
	
	"decoding.." .println	
	'backimg 'result qoi_decode2 
	
	'backimg printimg
	;
	
:testimg
	"r3sdl" 800 600 SDLinit
	bfont1
	cargar
	'draw SDLshow 
	SDLquit	

	;
	
|------------------------------------
:
|	test
	testimg
	;