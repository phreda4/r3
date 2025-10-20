| gui v.3
| 
| PHREDA 2025
|
^r3/util/immi.r3

|--------------------------------	
:uiTest
	uiUser
	8 cx cy cw ch SDLFRound 
	ch cw cy cx "x:%d y:%d;w:%d h:%d"
	sprint $11 uiText
	[ $ffffff sdlcolor 10 uiRrect ; ] uiFocus
	;

:uit2
	|8 uiRRect
	ch cw cy cx "x:%d y:%d;w:%d h:%d"
	sprint $11 uiText
	;

#font1
#ali

:tt
"Texto muy largo
y con varias lineas
para ver como se comporta
cuando cambia de tamanio"
	ali uiText	
	;

:grillain
	4 5 uiGrid
	uiLineGrid
	
	4 5 * ( 1? 1-
		uit2 dup "%d" sprint $11 uiText
		uiNext ) drop
	;

:test1
	|0.1 %w 0.1 %h 0.5 %w 0.8 %h uiBox
	4 4 uiPading
	$7f00 sdlcolor
	0.1 %h uiN 
		uiTest
	$3f00 sdlcolor	
	0.1 %h uiN 
		uiTest
	$7f0000 sdlcolor		
	0.1 %h uiS 
		uiTest
	$3f0000 sdlcolor				
	0.15 %w uiO 
		uiTest
	$7f sdlcolor				
	0.2 %w uiE 
	uiPush
		0.2 %h uiN 	
		'exit "Salir" $11 uiBtn
		
		$3f sdlcolor							
		uiRest
		uiTest
	uiPop
	$7f7f sdlcolor					
	uiRest
	grillain
	;

#vsl
#vsl2

:test3
	100 100 900 500 uiBox
	4 4 uiPading
	$7f00 sdlcolor
|	0.1 %h uiN 
	0.3 %w uiO
	2 20 uiGrid
	"boto" uiLabelC uiNext 'exit "Salir" uiBtn uiNext
	"Slider" uiLabelC uiNext -1.0 1.0 'vsl uiSliderf uiNext
	"Slideri" uiLabelC uiNext 0 500 'vsl2 uiSlideri uiNext
	
	uiRest
	18 2 uiGrid
	-1.0 1.0 'vsl uiVSliderf uiNext
	500 0 'vsl2 uiVSlideri uiNext
	;
|---------------
#cart "normal" "over" "in" "active" "active(outside)" "out" "click"

#pad * 64
:bbt
	uiUser
	8 uiRFill
|	'cart uistate $f and n>>0 $11 uiText
	0 'pad !
	[ "dn " 'pad strcat ; ] uiDwn
	[ "sel " 'pad strcat ; ] uiSel
	[ "clk " 'pad strcat ; ] uiClk
	[ "up " 'pad strcat ; ] uiUp	
	'pad $00 uiText
	;
	
	
:test2
	$7f0000 sdlcolor
	50 50 200 100 uiBox
	bbt
	
	$7f00 sdlcolor
	100 120 200 100 uibox
	bbt
	
	$7f sdlcolor
	300 50 200 100 uiBox
	bbt
	;
	
|-----------------------------
:main
	0 SDLcls
	font1 txfont
	
	uiStart
	
	|test1
	|test2
	test3
	
	SDLredraw
	sdlkey
	>esc< =? ( exit )
	<f1> =? ( ali $1 + $33 and 'ali ! )
	<f2> =? ( ali $10 + $33 and 'ali ! )
	<tab> =? ( keymd 
		1 and? ( uiFocus<< )
		1 nand? ( uiFocus>> )
		drop )	
	drop
	;
	
|-----------------------------
|-----------------------------	
:	
	|"R3d4" 0 SDLfullw | full windows | 
	"R3d4" 1280 720 SDLinitR
	
	"media/ttf/Roboto-bold.ttf" 20 txloadwicon 'font1 !
	
	'main SDLshow
	SDLquit 
	;
