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


#cdx 20 #cdy 100
#cdcnt 0
#cdtok * 1024

:cprint2 | "" --
	bsize 
	boxw rot - 2 >> curx + 
	boxh rot - 2 >> cury +
	bat bprint2 ;

|-------
#tokstr
	
:ilitd 8 >> "%d" sprint ;
:ilith 8 >> "$%h" sprint ;
:ilitb 8 >> "%%%b" sprint ;
:iprim 8 >> $7f and 3 << 'tokstr + @ ;
:isys 8 >> $7f and 3 << 'tokstr + @ ;
:idic 8 >> $7f and 3 << 'tokstr + @ ;
:iddic 8 >> $7f and 3 << 'tokstr + @ ;
	
#tokbig 0 ilitd ilith ilitb iprim isys idic iddic

:tok>str | tok -- ""
	dup $7 and 3 << 'tokbig + @ 0? ( 2drop "" ; )
	ex ;
	
|------ CODE
#xi #yi	
#si 0
#stri * 32
#nowins -1

:showins
	si 0? ( drop ; ) drop
	$666666 sdlcolor
	xi yi 128 32 sdlfrect
	$ffffff bcolor
	xi 8 + yi bat 
	'stri bprint2
	;

|------ CODE
:saseti
	curx 'xi ! cury 'yi ! 
:seti
	sdlx 'xa ! sdly 'ya ! ;

:dnins
	dup 'stri strcpy
	over 'si !
	saseti ;
	
:dnCode
	cdcnt 0? ( drop ; ) drop
	a> 8 - @ dup 'si !
	0? ( drop ; )
	tok>str 'stri strcpy
	a> dup 8 - swap cdcnt move
	-1 'cdcnt +!
	saseti ;

:moveins
	sdlx xa - 'xi +! 
	sdly ya - 'yi +! 
	seti ;

:insertins
	si 0? ( drop ; ) drop
	nowins -? ( drop ; ) 
	3 << 'cdtok + 
	dup dup 8 + swap cdcnt move> |dsc
	si 8 << 1 or swap !	
	0 'si !
	1 'cdcnt +!
	;
	
:upins
	insertins 0 'si ! ;

:linecode
	32 32 immbox
	dup 1+ "%d" cprint2 imm>>
	180 32 immbox
	plgui
	[ dup 'nowins ! $222222 sdlcolor plxywh SDLFRect ; ] guiI
	a@+ tok>str cprint2
	
	
	'dnCode
	'moveins
	'upins
	onMapA ;	
	
:mcode
	cdx cdy immwinxy
	192 320 immbox
	plgui 
	$444444 sdlcolor plxywh SDLFRect	
	[ -1 'nowins ! ; ] guiO
	$ffffff bcolor
	'cdtok >a
	0 ( cdcnt <=?
		linecode
		immcr
		1+ ) drop ;
	
|------ INST
:orden | "" -- ""
	plgui
	immcolorbtn SDLColor
	plxywh SDLRect
	dup cprint2
	'dnIns
	'moveIns
	'upIns
	onMapA ;	
	
:mpaleta
	128 32 immbox
	500 64 immat
	0 'words 
	( dup c@ 1? drop
		orden immdn
		>>0 swap 1+ swap ) 3drop ;
		
|------------------------------------
	
#skx 200 #sky 100
#skview 4
#skcnt 6
#sktok * 128	

:dcell
	;
	
:mstack
	16 500 bat
	vmdeep 0? ( drop ; ) 
	code 8 +
	( swap 1 - 1? swap
		@+ "%d " bprint2 
		) 2drop 
	TOS "%d " bprint2
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
	showins
		
|	mconsole

	'code p8.draw
	'inst p8.draw

	SDLredraw 
	sdlkey
	>esc< =? ( exit )
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
