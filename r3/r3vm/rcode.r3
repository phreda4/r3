| rcode
| PHREDA 2024
|-------------------------

^r3/lib/rand.r3
^r3/lib/sdl2gfx.r3
^r3/util/sdlbgui.r3
^r3/util/varanim.r3

^r3/r3vm/r3ivm.r3
|^r3/r3vm/r3itok.r3
|^r3/r3vm/r3iprint.r3

| scratchjr
| eventos/movimiento/apariencia/sonido/control/fin
|
| scratch
| movimiento/apariencia/sonido/eventos/control/sensor/operadores/variables/bloques

|#grupos ":" "#" "ABC" "123" """str""" "oper" "mem" "stack" "contr" "comm" 
|#words "0" "+" "DUP" "(??"  "??(" "STEP" "TURN" 0
#words " Up" " Down" " Left" " Right"  " Jump" " Push" 0

#cdx 64 #cdy 64
#cdcnt 0
#cdmax 128 
#cdtok * 1024

#cdcur 'cdtok
#cdspeed 1.0

:cprint2 | "" --
	curx padx + cury pady + bat bprint2 ;

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
	
:tok>str | tok -- ""
	'words swap ( 1? 1- swap >>0 swap ) drop ;
	
|------ CODE
#xi #yi	#si -1 #stri * 32

#nowins -1

:showins
	si -? ( drop ; ) drop
	$555555 sdlcolor
	xi yi 128 32 sdlfrect
	$ffffff bcolor
	xi 8 + yi bat 
	'stri bprint2
	;

|------ CODE
#xa #ya
:saseti
	curx 'xi ! cury 'yi ! |...
:seti
	sdlx 'xa ! sdly 'ya ! ;

:dnins
	dup 'stri strcpy
	over 'si !
	saseti ;
	
:dnCode
	cdcnt =? ( ; ) 
	a> 8 - @ dup 'si !
	tok>str 'stri strcpy
	a> dup 8 - swap cdcnt move
	-1 'cdcnt +!
	saseti ;

:moveins
	sdlx xa - 'xi +! 
	sdly ya - 'yi +! 
	seti ;

:upins
	si -? ( drop ; ) drop
	nowins -? ( drop -1 'si ! ; ) 
	3 << 'cdtok + 
	dup dup 8 + swap cdcnt move> |dsc
	si swap !
	1 'cdcnt +!
	-1 'nowins !
	-1 'si !
	;
	
:incell
	over 'nowins ! 
	$333333 sdlcolor 
	plxywh SDLFRect 
	;
	
:codeprint
	nowins =? ( ; )
	cdcnt =? ( nowins -? ( drop ; ) drop )
	a@+ tok>str cprint2 ;
	
:linecode
	$333333 bcolor
	curx 32 - cury pady + bat
	dup 1+ "%d" bprint2
	$ffffff bcolor
	224 32 immbox
	plgui
	si +? ( 'incell guiI ) drop
	codeprint
	'dnCode 'moveins 'upins onMapA ;	
	
:mcode
	cdx cdy immwinxy
	224 384 immbox
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
	$444444 SDLColor
	plxywh SDLFRect
	dup cprint2
	'dnIns 'moveIns 'upIns onMapA ;	
	
:mpaleta
	300 64 immat
	128 32 immbox
	0 'words 
	( dup c@ 1? drop
		orden immdn
		>>0 swap 1+ swap ) 3drop ;


|------ PLAYCODE
:linecursor
	cdcur <>? ( $333333 bcolor ; ) 
	curx 48 - cury pady + bat
	$eeeeee bcolor ">" bprint2 
	;
	
:linecode
	linecursor
	curx 32 - cury pady + bat
	dup 1+ "%d" bprint2
	$ffffff bcolor
	224 32 immbox
	plgui
	a@+ tok>str cprint2 ;	
	
:pcode
	cdx cdy immwinxy
	224 384 immbox
	plgui 
	$444444 sdlcolor plxywh SDLFRect	
	$ffffff bcolor
	'cdtok >a
	0 ( cdcnt <?
		linecode
		immcr
		1+ ) drop ;

|------ STACK
#skx 300 #sky 100
#skview 4
#skcnt 6
#sktok * 128	

:dcell
	;
	
:mstack
	skx sky bat
	vmdeep 0? ( drop ; ) 
	code 8 +
	( swap 1 - 1? swap
		@+ "%d " bprint2 
		) 2drop 
	TOS "%d " bprint2
	;

|-----------------------------
:editando
	mpaleta
	mcode
	showins
	
	|200 4 bat cdcnt si nowins "now:%d si:%d cnt:%d" bprint2
	;

|-----------------------------
:vmstep
	cdcur 
	dup 3 << 'cdtok + @ "%d" .println
	1+ dup 'cdcur !
	cdcnt <? ( 'vmstep 1.0 +vexe ) drop
	;
	
:ejecutando
	pcode
	mstack
	;
	
|-----------------------------	
#estado 'editando		
	
:iplay
	0 'cdcur !
	'ejecutando 'estado !
	'vmstep 1.0 +vexe | 'exe 3.0 --
	;

:iedit
	'editando 'estado !
	;

:menu
	vupdate
	0 sdlcls 
	immgui
	
	$ff 'immcolorbtn !
	60 24 immbox
	4 4 immat
	"r3Code" immlabelc immdn

	'iplay "play" immbtn imm>>
	'iedit "edit" immbtn imm>>
	'iplay "clear" immbtn imm>>
	$ff0000 'immcolorbtn ! 'exit "Exit" immbtn
 	
	estado ex

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
	64 vaini
	
	modmenu
	SDLquit 
	;
