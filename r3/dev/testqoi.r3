| qoi encoder/decoder
| PHREDA 2021

^r3/lib/mem.r3
^r3/win/console.r3
^r3/win/sdl2.r3
^r3/win/sdl2image.r3
^r3/util/bfont.r3
^r3/dev/qoi.r3

#textbitmap

#imagens
#ibox [ 100 100 40 40 ]

#pixels
#wi #hi #pi

#code
#csize

:printdiffimg
	pixels here
	hi wi * ( 1? 1 -
		hi wi * over - "%d. " .print
		rot d@+ $ffffffff and "%h " .print rot d@+ $ffffffff and "=%h " .println rot
		) 3drop	;

#mpixel
#mpitch

:writetex	
	textbitmap 0 'mpixel 'mpitch SDL_LockTexture
	
	mpixel code qoi_decode | bitmap data -- 1/0
|	0? ( drop ; ) drop
	drop
	
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
	pixels wi hi here qoi_encode 
	dup 'csize ! 
	8 + 'here +! 0 , 
|	"test.qoi" savemem

	imagens SDL_UnlockSurface

	qw qh SDLframebuffer 'textbitmap !	
	writetex	
	
	cr cr
	csize "%d" .println
	code csize ( 1? 1 - swap 
		c@+ $ff and "%h " .print 
		swap ) 2drop
	cr cr
	
|	printdiffimg	
	;
		
:draw
	SDLrenderer textbitmap 0 0 SDL_RenderCopy		
	
	$ff00 bcolor
	0 0 bmat
	qh qw "%d %d" sprint bmprint
	0 12 bmat
	csize "%d" sprint bmprint
	
	SDLredraw
	
	SDLkey
	>esc< =? ( exit )
	drop ;
	
:cargar
	"media/img/lolomario.png" IMG_Load 'imagens !
	encodeimg
	;
	
|---------------------------------------
:
	"r3sdl" 800 600 SDLinit
	bfont1
	cargar
	
	'draw SDLshow 
	
	SDLquit	;
	;