| box animator
| PHREDA 2024

^r3/lib/sdl2gfx.r3
^r3/util/varanim.r3
^r3/util/ttfont.r3
|^r3/util/boxtext.r3
^r3/util/textb.r3

|--------------------------------------
::64xy | b -- x y 
	dup 48 >> swap 16 << 48 >> ;
	
::64wh | b -- w h
	dup 32 << 48 >> swap 48 << 48 >> ;
	
::64xywh | b -- x y w h
	dup 48 >> swap dup 16 << 48 >> swap
	dup 32 << 48 >> swap 48 << 48 >> ;
	
::xywh64 | x y w h -- b
	$ffff and swap
	$ffff and 16 << or swap
	$ffff and 32 << or swap
	$ffff and 48 << or ;

::64box | b adr --
	swap
	dup 48 >> rot d!+
	swap dup 16 << 48 >> rot d!+
	swap dup 32 << 48 >> rot d!+
	swap 48 << 48 >> swap d! ;		
|--------------------------------------


#font1

#boxlist

#abox
#acol $ff00ff

#rec [ 0 0 0 0 ]

:drawb
	SDLRenderer 'rec SDL_RenderFillRect ;


:drawboxs
	acol sdlcolor
	
	abox 'rec 64box drawb
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

:main
	vupdate
	$0 SDLcls

	drawboxs
	
	$ffffff ttcolor
	8 8 ttat
	abox "%h" ttprint
	
	"Playa de;las toninas" 224 120 $0000000000ff0000 font1 
	textbox | str w h $vh-col1-col2 font -- texture
	10 50 drawtex

	"Playa de;las toninas" 224 120 $010000000000ff00 font1 
	textbox | str w h $vh-col1-col2 font -- texture
	310 50 drawtex

	"Playa de;las toninas" 224 120 $02000000000000ff font1 
	textbox | str w h $vh-col1-col2 font -- texture
	610 50 drawtex

	"Playa de;las toninas" 224 120 $1000000000ff00ff font1 
	textbox | str w h $vh-col1-col2 font -- texture
	10 250 drawtex

	"Playa de;las toninas" 224 120 $110000000000ffff font1 
	textbox | str w h $vh-col1-col2 font -- texture
	310 250 drawtex

	"Playa de;las toninas" 224 120 $12000000000000ff font1 
	textbox | str w h $vh-col1-col2 font -- texture
	610 250 drawtex
	
	"Playa de;las toninas" 224 120 $2000000000ffff00 font1 
	textbox | str w h $vh-col1-col2 font -- texture
	10 450 drawtex

	"Playa de;las toninas" 224 120 $210000000000ff00 font1 
	textbox | str w h $vh-col1-col2 font -- texture
	310 450 drawtex

	"Playa de;las toninas" 224 120 $220000000000ffff font1 
	textbox | str w h $vh-col1-col2 font -- texture
	610 450 drawtex
	
	|----------------

	SDLredraw	
	SDLkey
	>esc< =? ( exit )
	<f1> =? ( anima1 )
	drop ;
	
	
: |-------------------------------------
	"var anim" 1024 600 SDLinit	

	"media/ttf/Roboto-Medium.ttf" 28 TTF_OpenFont dup ttfont! 'font1 !
	$ff vaini
	|10 10 80 40 xywh64 
	600 200 380 140 xywh64 
	'abox !
	'main SDLShow
	
	SDLquit ;	
