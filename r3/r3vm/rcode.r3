| rcode
| PHREDA 2024
|-------------------------

^r3/lib/rand.r3
^r3/util/arr8.r3
^r3/lib/sdl2gfx.r3
^r3/util/sdlbgui.r3

^r3/r3vm/r3ivm.r3
^r3/r3vm/r3itok.r3
^r3/r3vm/r3iprint.r3

| scratchjr
| eventos/movimiento/apariencia/sonido/control/fin
|
| scratch
| movimiento/apariencia/sonido/eventos/control/sensor/operadores/variables/bloques


#code 0 0
#inst 0 0

|--- 8arr start in 0
:.x 0 ncell+ ;
:.y 1 ncell+ ;
:.n 2 ncell+ ;
:.str 3 ncell+ ;
:.t 4 ncell+ ;
:.v 5 ncell+ ;


:guiRectS | adr -- adr
	a> .x @ a> .y @ over a> .n @ + over 32 + guiRect ;
	
#xa #ya

:mvcard
	sdlx xa - a> .x +! 
	sdly ya - a> .y +! 
:setcard	
	sdlx 'xa ! sdly 'ya ! ;
	
:dcode
	>a
	guiRectS
	'setcard 'mvcard onDnMoveA	
	$ff sdlcolor
	a> .x @ a> .y @ | x y
	2dup
	a> .n @ 32 SDLfRect
	bat
	a> .str @ 1? ( dup bprint2 ) drop
	;

:+co | s n y x --
	'dcode 'code p8!+ >a 
	swap a!+ a!+	| x y 
	a!+				| n
	a!+
	;
	
:dinst
	;
	
:+in | n y x --
	'dinst 'inst p8!+ >a 
	swap a!+ a!+	| x y 
	a!+				| n
	;



#grupos ":" "#" "ABC" "123" """str""" "oper" "mem" "stack" "contr" "comm" 
#words "0" "+" "DUP" "(??"  "??(" "STEP" "TURN" 0

#xc #yc	
#sc 0

#cdx 20 #cdy 100
#cdcnt 5
#cdtok * 1024

::cprint2 | "" --
	bsize 
	boxw rot - 2 >> curx + 
	boxh rot - 2 >> cury +
	bat bprint2 ;


:codecell | x y --
	64 pick2 - 16 pick2 -
	$7f sdlcolor
	2dup 128 64 sdlfrect
	
	;
	
	
:linecode	
	32 32 immbox
	dup 1+ "%d" immlabelc imm>>
	128 32 immbox
	"bb" immlabelc
	;

:mcodein	
	'cdtok >a
	0 ( cdcnt <?
		linecode
		immcr
		1+ ) drop ;

:linecode
	32 32 immbox
	dup 1+ "%d" immlabelc imm>>
	128 32 immbox
	'exit "bb" immbtn
	;
	
:mcode
	cdx cdy immwinxy
	128 32 immbox
	sc 1? ( drop mcodein ; ) drop
	'cdtok >a
	0 ( cdcnt <?
		linecode
		immcr
		1+ ) drop
	;
	
:movc
	sdlx xa - 'xc +! 
	sdly ya - 'yc +! 
:setc
	sdlx 'xa ! sdly 'ya ! ;

:dnCode
	dup 'sc !
	curx 'xc !
	cury 'yc !
	setc
	;
:moveCode
	movc
	;
:upCode	
	0 'sc !
	;
	
:showcode
	sc 0? ( drop ; )
	$666666 sdlcolor
	xc yc 128 32 sdlfrect
	$ffffff bcolor
	xc yc bat
	bprint2
	;
	
::cprint2 | "" --
	bsize 
	boxw rot - 2 >> curx + 
	boxh rot - 2 >> cury +
	bat bprint2 ;
	
:orden | "" -- ""
	plgui
	immcolorbtn SDLColor
	plxywh SDLRect
	dup cprint2
	'dnCode
	'moveCode
	'upCode
	onMapA ;	
	
:mpaleta
	128 32 immbox
	500 64 immat
	0 'words 
	( dup c@ 1? drop
		orden immdn
		>>0 swap 1+ swap ) 3drop ;
	
#skx 200 #sky 100
#skview 4
#skcnt 6
#sktok * 128	

:dcell
	;
	
:mstack
	8 400 bat
	vmdeep 0? ( drop ; ) 
	code 8 +
	( swap 1 - 1? swap
		@+ "%d " bprint2 
		) 2drop 
	TOS "%d " bprint2
	;
	
#cox 20 #coy 300
#copad "> " * 512
#copad> 'copad

:mconsole
|	$ffffff ttcolor
|	cox coy ttat
|	'copad tt.
	cox coy immat
	'copad 64 input
	;
	
:menu
	0 sdlcls 
	immgui
	
	$ff 'immcolorbtn !
	60 24 immbox
	4 4 immat
	"r3Code" immlabelc immdn
|	$ff0000 'immcolorbtn ! 'exit "Exit" immbtn 

	mpaleta
	mcode
	mstack
	showcode
	
|	mconsole

	'code p8.draw
	'inst p8.draw

	
	
	SDLredraw 
	sdlkey
	>esc< =? ( exit )
	<f1> =? ( " 0 ( 4 <?" 100 sdlx sdly +co )
	drop
	;

:modmenu
	'menu sdlShow ;

: |<<< BOOT <<<
	"r3code" 1024 600 SDLinit
	bfont1
	200 'code p8.ini
	50 'inst p8.ini	
	
		r3reset
	modmenu
	SDLquit 
	;
