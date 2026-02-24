| varbox animator
| PHREDA 2024

^r3/lib/sdl2gfx.r3
^r3/lib/rand.r3
^r3/util/varanim.r3
^r3/util/ttfont.r3
^r3/util/textb.r3

#font1
#abox
#acol $ff00ff
#rec [ 0 0 0 0 ]
#tex
#tex2

:drawb
	acol sdlcolor
	SDLRenderer 'rec SDL_RenderFillRect 
	$ffffff sdlcolor
	SDLRenderer 'rec SDL_RenderDrawRect 
	;

:drawboxs
	abox 'rec 64box 
	drawb
	SDLrenderer tex 0 'rec SDL_RenderCopy	
	;

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

#rtbox [ 0 0 324 180 ] |500 200 324 180 ]

:drawtex | texture x y --
	swap
	pick2 0 0 'rtbox 8 + dup 4 + SDL_QueryTexture
	'rtbox d!+ d!
	$5a5a5a SDLColor SDLRenderer 'rtbox SDL_RenderDrawRect 
	SDLrenderer over 0 'rtbox SDL_RenderCopy	
	SDL_DestroyTexture ;

#ttp "texto en;caja"

#spos
#sposant

#spos3
#spos3ant
#tex3

:anima
	'spos
	sw randmax 
	sh randmax 
	2.0 randmax 1.0 -
	1.2 randmax 0.5 +
	xyrz64
	sposant
	over 'sposant !
	25 randmax
	1.0 0.5 +vboxanim 
	
	'anima 2.0 +vexe
	;

:anima2
	'spos3
	sw randmax 
	sh randmax 
	2.0 randmax 1.0 -
	1.2 randmax 0.5 +
	xyrz64
	spos3ant
	over 'spos3ant !
	25 randmax
	1.0 0.5 +vboxanim 
	;
	

:main
	vupdate
	$0 SDLcls

	drawboxs
	
	$ffffff ttcolor
	8 8 ttat
	abox "%h" ttprint
	
	'ttp $700fff000550f00f 224 120 font1 textbox 10 50 drawtex
	'ttp $1f0f0 224 120 font1 textbox 310 50 drawtex
	'ttp $2f0f0  224 120 font1 textbox 610 50 drawtex
	'ttp $4f0f0  224 120 font1 textbox 10 250 drawtex
	'ttp $5f0f0  224 120 font1 textbox 310 250 drawtex
	'ttp $6f0f0  224 120 font1 textbox 610 250 drawtex
	'ttp $8f0f0  224 120 font1 textbox 10 450 drawtex
	'ttp $9f0f0  224 120 font1 textbox 310 450 drawtex
	'ttp $af0f0  224 120 font1 textbox 610 450 drawtex
	
	spos 64xyrz tex2 spriteRZ
	spos3 64xyrz tex3 spriteRZ

	|----------------
	SDLredraw	
	SDLkey
	>esc< =? ( exit )
	<f1> =? ( anima1 )
	<f2> =? ( anima2 )
	drop ;
	
	
: |-------------------------------------
	"var anim" 1024 600 SDLinit	

	"media/ttf/Roboto-Medium.ttf" 28 TTF_OpenFont dup ttfont! 'font1 !
	$ff vaini
	|10 10 80 40 xywh64 
	600 200 380 140 xywh64 
	'abox !
	
	"Prueba de texto con un ancho largo" $f0000025f00f 224 120 font1 textbox 'tex !
	
	"Texto en;Sprite" $70f0ffff0025f000 224 120 font1 textbox 'tex2 !
	"Otro sprite;mas aca" $7f00f0000025ffff 224 120 font1 textbox 'tex3 !

	anima
	
	'main SDLShow
	
	SDLquit ;	
