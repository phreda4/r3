| qoi encoder/decoder
| PHREDA 2021
^r3/lib/mem.r3
^r3/win/console.r3
^r3/win/sdl2gfx.r3
^r3/win/sdl2image.r3
^r3/util/bfont.r3

|^r3/dev/aqoi/qoi2.r3

^r3/dev/aqoi/aqoi.r3
^r3/dev/aqoi/minic.r3

^r3/lib/rand.r3


#textbitmap

#imagen
#imagens

#pixels
#wi #hi #pi

#code
#csize

#code2
#csize2

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
	csize "size:%d" .println
	
	8 + 'here +! 0 , 
	
	"encode 2" .println
	
	here 'code2 !
	
	here 
	code csize minicencode | dest src cnt -- cdest
	here - 'csize2 !
	
	"encode end" .println
	
	
|	"test.qoi" savemem
	
	
	qw qh SDLframebuffer 'textbitmap !	
	textbitmap 1 SDL_SetTextureBlendMode | 1 = blend
	writetex	

	;
		
#box [ 100 0 500 500 ]

:draw
	$222222 clrscr
	SDLrenderer textbitmap 0 'box SDL_RenderCopy		
	
	$ffffff bcolor
	0 0 bat qh qw "%d %d" sprint bprint
	0 12 bat csize "%d" sprint bprint
	0 24 bat csize2 "%d" sprint bprint
	
	redraw
	
	SDLkey
	>esc< =? ( exit )
	drop ;
	
:cargar
|	"r3/aqo/dice.png" | ok
|	"r3/aqo/kodim10.png"
|	"r3/aqo/kodim23.png"
|	"r3/aqo/qoi_logo.png" |ok
	"r3/dev/aqoi/testcard.png" |ok
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
	testimg
	;