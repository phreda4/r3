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

:main
	vupdate
	$0 SDLcls

	drawboxs
	
	$ffffff ttcolor
	8 8 ttat
	abox "%h" ttprint
	
|	$11 "Playa de;las toninas"
|	10 200 324 180 xywh64 
|	$ffffff
|	font1 
|	textbox | $vh str box color font --

|	$11 "Playa de;las toninas"
|	210 200 324 180 xywh64 
|	$2ffffff000000 
|	font1 
|	textboxo | $vh str box color font --
	
	|-----------------
	"Playa de;las toninas" $1100ffffff0000ff 
	'rtbox 
	font1 txbox 

	200 500 'rtbox d!+ d!
	SDLrenderer over 0 'rtbox SDL_RenderCopy	
	SDL_DestroyTexture
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
