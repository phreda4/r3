| qoi encoder/decoder
| PHREDA 2021

^r3/lib/mem.r3
^r3/win/console.r3
^r3/win/sdl2.r3
^r3/win/sdl2image.r3
^r3/util/bfont.r3
^r3/dev/qoi.r3
|^r3/dev/qoi2.r3

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
	"test.qoi" savemem

	imagens SDL_UnlockSurface

	|printout	
	|printdiffimg	
	
	qw qh SDLframebuffer 'textbitmap !	
	writetex	

	;
		
#box [ 100 0 300 200 ]
#box1 [ 410 0 300 200 ]

:draw
	SDLrenderer textbitmap 0 'box SDL_RenderCopy		
	SDLrenderer imagen 0 'box1 SDL_RenderCopy		
	
	$ffffff bcolor
	0 0 bmat
	qh qw "%d %d" sprint bmprint
	0 12 bmat
	csize "%d" sprint bmprint
	0 12 2 * bmat
	cntINDEX "INDEX %d" sprint bmprint
	0 12 3 * bmat
	cntRUN8 "RUN8 %d" sprint bmprint
	0 12 4 * bmat
	cntRUN16 "RUN16 %d" sprint bmprint
	0 12 5 * bmat
	cntDIFF8 "DIFF8 %d" sprint bmprint
	0 12 6 * bmat
	cntDIFF16 "DIFF16 %d" sprint bmprint
	0 12 7 * bmat
	cntDIFF24 "DIFF24 %d" sprint bmprint
	0 12 8 * bmat
	cntDIFF "DIFF %d" sprint bmprint
	
	SDLredraw
	
	SDLkey
	>esc< =? ( exit )
	drop ;
	
:cargar
	|"media/img/lolomario.png" 
	|"media/img/ship_64x29.png" | fail
	|"media/img/lander.png" |
	"media/img/bird.png" | fail
	dup
	IMG_Load 'imagens !
	loadimg 'imagen !
	encodeimg
	;
	
|---------------------------------------
#col
:
	
	"r3sdl" 800 600 SDLinit
	bfont1
	cargar
	
	'draw SDLshow 
	
	SDLquit	;
	;