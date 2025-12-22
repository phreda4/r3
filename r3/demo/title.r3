| title & credit
| PHREDA 2023
|
^r3/lib/console.r3
^r3/lib/sdl2gfx.r3
^r3/util/sdlgui.r3
^r3/util/varanim.r3
^r3/util/textb.r3
^r3/lib/color.r3

#font
#colm

#texto>
#texto 
"R3 Presenta"
"Una Historia sobre la lucha de una laucha en el desierto"
"Con la presentacion de Lito, la laucha matutina"
"Y Coqui, el queso provolone" 
0

:nextt texto> >>0 'texto> ! ;

:animstart
	'texto 'texto> !
	$ff 'colm !
	vareset
	'colm 0 $ff 5 1.0 1.0 +vanim
	'colm $ff 0 5 1.0 3.0 +vanim
	'nextt 4.0 +vexe
	'colm 0 $ff 5 1.0 4.0 +vanim
	'colm $ff 0 5 1.0 7.0 +vanim
	'nextt 8.0 +vexe
	'colm 0 $ff 5 1.0 8.0 +vanim
	'colm $ff 0 5 1.0 10.0 +vanim
	'nextt 11.0 +vexe
	'colm 0 $ff 5 1.0 11.0 +vanim
	'colm $ff 0 5 1.0 14.0 +vanim
	'exit 15.0 +vexe 
	;
	
:l0count | list -- cnt
	0 ( swap dup c@ 1? drop >>0 swap 1+ ) 2drop ;
	
#t	
:lines | texto --
	dup 'texto> !
	$ff 'colm !
	vareset
	1.0 't !
	l0count 
	0 ( over <? 
		'colm 0 $ff 5 1.0 t +vanim
		'colm $ff 0 5 1.0 t 2.0 + +vanim
		'nextt t 3.0 + +vexe
		4.0 't +!
		1 + ) drop 
	'exit t +vexe 		
	;
	

#rtbox [ 0 0 324 180 ] |500 200 324 180 ]

:drawtex | texture x y --
	swap
	pick2 0 0 'rtbox 8 + dup 4 + SDL_QueryTexture
	'rtbox d!+ d!
	SDLrenderer over 0 'rtbox SDL_RenderCopy	
	SDL_DestroyTexture ;
	
|'ttp $1f0f0 224 120 font1 textbox 310 50 drawtex
	
:titlestart
	vupdate
	$0 SDLcls

	texto>
	colm 4 >> $f xor dup 4 << over 8 << or or 
	$5f000 or
	424 400
	font
	textbox 300 100 drawtex
		
	SDLredraw	
	SDLkey
	>esc< =? ( exit )
	drop ;
	
|---------- title menu

#yb 100
#ta 0
:loopini
	-100 'yb !
	0 'colm !
	vareset
	'yb 100 -100 ta 2.0 0.0 +vanim
	'yb -100 100 ta 2.0 2.0 +vanim
	'loopini 4.0 +vexe 
	'colm $ff $7f 5 1.0 0.0 +vanim
	'colm $7f $ff 5 1.0 1.0 +vanim
	'colm $ff $7f 5 1.0 2.0 +vanim
	'colm $7f $ff 5 1.0 3.0 +vanim
	;
	
:titlemenu
	vupdate
	$0 SDLcls
	
	ta "animacion %d" sprint
	$5ffff 
	824 300
	font
	textbox 100 yb drawtex

	immgui
	412 400 immat
	200 immwidth
	$ffffff 'immcolortex !
	'exit "Jugar" immbtn
	immdn
	'exit "Salir" immbtn

	SDLredraw	
	SDLkey
	>esc< =? ( exit )
	<f1> =? ( ta 1- 0 max 'ta ! )
	<f2> =? ( ta 1+ 32 min 'ta ! )
	drop ;
	
|------------	
:start
	|animstart
	'texto lines
	'titlestart SDLshow
	
	loopini
	'titlemenu SDLshow 
	;
	
: 
	"test titles" 1024 600 SDLinit
	"media/ttf/Roboto-Medium.ttf" 48 TTF_OpenFont dup 'font ! immSDL 
	$ff vaini
	start
	SDLquit
	;	