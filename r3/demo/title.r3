| title & credit
| PHREDA 2023
|
^r3/lib/console.r3
^r3/lib/sdl2gfx.r3
^r3/util/immi.r3
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
	
:titlestart
	vupdate
	$0 cls
	font txfont
	
	colm $ff xor dup 8 << or dup 8 << or txrgb
	sw 200 - sh 100 0 texto> txText
			
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
	$0 cls

	uiStart

	0.3 %h uiS
	|0.3 %w uiO 0.3 %w uiE uiRest
	'exit "Jugar" uiBtn
	'exit "Salir" uiBtn
	uiEnd

	$ffffff txrgb
	sw 0.7 %h 0 yb 
	ta "animacion %d" sprint
	txText

	SDLredraw	
	SDLkey
	>esc< =? ( exit )
	<f1> =? ( ta 1- 0 max 'ta ! )
	<f2> =? ( ta 1+ 32 min 'ta ! )
	drop ;
	
|------------	
:start
	animstart
	'titlestart SDLshow
	
	loopini
	'titlemenu SDLshow 
	;
	
: 
	"test titles" 1024 600 SDLinitR
	"media/ttf/Roboto-Medium.ttf" 48 txload 'font !
	$ff vaini
	start
	SDLquit
	;	