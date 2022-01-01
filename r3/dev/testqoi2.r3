| qoi encoder/decoder
| PHREDA 2021

^r3/lib/mem.r3
^r3/win/console.r3
^r3/win/sdl2.r3
^r3/win/sdl2image.r3
^r3/util/bfont.r3
^r3/dev/qoi2.r3

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
	
	mpixel code qoi_decode2 | bitmap data -- 1/0
|	0? ( drop ; ) drop
	drop
	
	mpixel >a
	$ffff0000 da!+	
	$ff00ff00 da!+
	$ff0000ff da!+
	$7f0000ff da!+
	$ff0000ff da!+
	
	textbitmap SDL_UnlockTexture
	;
	
:encodeimg
	imagens SDL_LockSurface
	imagens 16 + 
	d@+ 'wi !
	d@+ 'hi !
	d@+ 'pi !
	4 + @ 'pixels !
	
	mark
	here 'code !
	pixels wi hi here qoi_encode2
	dup 'csize ! 
	8 + 'here +! 0 , 
|	"test.qoi" savemem

	imagens SDL_UnlockSurface

	|printout	
	|printdiffimg	
	
	qw qh SDLframebuffer 'textbitmap !	
	textbitmap 1 SDL_SetTextureBlendMode | 1 = blend
	writetex	

	;
		
#box [ 100 0 300 200 ]
#box1 [ 410 0 300 200 ]

:draw
	$222222 SDLclear
	SDLrenderer textbitmap 0 'box SDL_RenderCopy		
	SDLrenderer imagen 0 'box1 SDL_RenderCopy		
	
	$ffffff bcolor
	0 0 bmat
	qh qw "%d %d" sprint bmprint
	0 12 bmat
	csize "%d" sprint bmprint
	
	SDLredraw
	
	SDLkey
	>esc< =? ( exit )
	drop ;
	
:cargar
	"media/img/lolomario.png" 
	|"media/img/ship_64x29.png" | fail
	|"media/img/lander.png" |
	|"media/img/bird.png" | fail
	dup
	IMG_Load 'imagens !
	loadimg 'imagen !
	encodeimg
	;
	
|---------------------------------------

#testimg [
$ff0000 $ff00 $ff $ff00 $fe00 $8000
$ff0000 $ff00 $ff $ff00 $fe00 $8000
$ff0000 $ff00 $ff $ff00 $fe00 $8000
$ff0000 $ff00 $ff $ff00 $fe00 $8000
$1 $2 $3 $4 $5 $6
10 9 8 7 6 5 
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
	ressize
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

	test
	testimg
	;