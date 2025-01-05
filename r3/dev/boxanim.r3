| box animator
| PHREDA 2024

^r3/lib/sdl2gfx.r3
^r3/lib/rand.r3
^r3/util/varanim.r3

#boxes * $ffff
#boxes> 'boxes

#abox
#acol $ff00ff
#rec [ 0 0 0 0 ]

:anima1
	'abox 
	10 10 80 40 xywh64 
	600 200 380 140 xywh64 
	0 1.0 0.0 +vboxanim
	'abox 
	600 200 380 140 xywh64 
	10 10 80 40 xywh64 	
	0 1.0 1.0 +vboxanim
	
	'acol $ff00ff $ff00 0 1.0 0.0 +vcolanim
	'acol $ff00 $ff00ff 0 1.0 1.0 +vcolanim
	;

:addbox | x y w h --
	swap 2swap swap
	
	8 8 createSurf
	Surf>pix >a | surface pixels
	64 ( 1? 1-
		rand da!+
		) drop
	|$ff0000ff da!+ $ffff00ff da!+
	|$ff00ffff da!+ $ffffff00 da!+
	
	SDLrenderer over SDL_CreateTextureFromSurface
	dup 0 SDL_SetTextureScaleMode |(tex1, SDL_ScaleModeLinear)
	swap SDL_FreeSurface
	boxes> !+ d!+ d!+ d!+ d!+ 0 swap !+ 'boxes> ! | texture rec2 rec1  0 
	;
	
|		SDLrenderer a@+ 0 'box SDL_RenderCopy	
|	>a a@+ 32xy a@+ 32xy a@ SDLspriteRZ | x y ang zoom img --	
:drawbox | adr --
	SDLrenderer over @ 0 pick3 1 ncell+ SDL_RenderCopy
	;
	
:drawboxs
	ab[
	'boxes ( boxes> <?
		drawbox
		4 ncell+ ) drop 
	]ba ;
	
:main
	vupdate
	$444444 SDLcls
	drawboxs
	|----------------
	SDLredraw	
	SDLkey
	>esc< =? ( exit )
	<f1> =? ( 
		1000 randmax 500 randmax 
		200 randmax 20 +
		100 randmax 20 + addbox )
	drop ;
	
	
: |-------------------------------------
	"var anim" 1024 600 SDLinit	

	$ff vaini
	'main SDLShow

	SDLquit ;	
