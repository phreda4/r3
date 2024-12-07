| rcode nivel 1
| PHREDA 2024
|-------------------------

^r3/lib/rand.r3
^r3/lib/sdl2gfx.r3
^r3/util/sdlgui.r3
^r3/util/varanim.r3

^r3/r3vm/rcodevm.r3

#cpu
#imgspr

|-------------------------------------	
| scrjr:	eventos/movimiento/apariencia/sonido/control/fin
| scratch:	movimiento/apariencia/sonido/eventos/control/sensor/operadores/variables/bloques
|
| LIT/()/??/STK/OPER/VAR/WORD MOV-DRAW-SOUND SENSOR-KEY-MOUSE

#cdx 64 #cdy 64
#cdcnt 0
#cdmax 128 
#cdtok * 1024
#cdtok> 'cdtok

#cdspeed 0.2

	
|------ INSTRUCC
#xi #yi	#si -1 #stri * 32

#nowins -1

:showins
	si -1 =? ( drop ; ) drop
	$555555 sdlcolor
	xi yi 64 22 sdlfrect
	$ffffff ttcolor
	xi 8 + yi ttat 
	'stri tt.
	;

|------ CODE
| cdtok....(cdcnt)
#lev
#while
#terror

:error
	1 'terror !
	;
	
:is?? | adr token -- adr token
	a> pick2 - 8 - 32 << 	| adr tok dist
	pick2 @ $ffff and or 
	pick2 !
	1 'while !
	;
	
:patch?? | now -- now
	0 'while !
	a> 8 - 		| adr
	( dup @ lev 8 << 10 or <>?		| adr token
		$ffff <? ( $ff and 15 27 in? ( is?? ) )
		drop 8 - 
		) drop | now adr(10)
	while 1? ( drop a> - 8 + 32 << lev 8 << or 11 or a> 8 - ! ; ) drop
	8 - 
	dup @ $ff and 15 <? ( error ; ) 27 >? ( error ; ) drop
	dup @ $ffff and a> pick2 - 8 - 32 << or swap !
	;
	
:clearlev
	9 <? ( swap $ff00 nand ; )
	swap $ff and ;
	
#usod
#deld
	
:processlevel
	0 'lev ! 
	0 'usod ! 0 'deld !
	'cdtok >a
	0 ( cdcnt <?
		a@ 
		| calc mov stack
		dup vmtokmov dup 
		$f and deld swap - neg clamp0 usod max 'usod !
		56 << 60 >> 'deld +!
		| check level
		dup $7f and 
		10 =? ( 1 'lev +! )
		clearlev
		lev 8 << or a!+
		11 =? ( patch?? -1 'lev +! )
		drop
		1+ ) drop ;
		
:is??
	swap 32 >> 0? ( error ) | ?? sin salto
	;
	
:checkjmp
	'cdtok >a
	0 ( cdcnt <?
		a@+ dup 
		15 27 in? ( is?? )
		2drop
		1+ ) drop ;
	

|--------------------------
:checkl
	a> 8 - @ $7f and
	10 <? ( drop ; ) 11 >? ( drop ; ) drop
	a> dup 8 - swap cdcnt move> |dsc
	;
	
:removelev | --
	si dup $7f and 
	10 <? ( 2drop ; ) 11 >? ( 2drop ; ) drop
	8 >> $ff and 'lev !
	'cdtok >a
	0 ( cdcnt <?
		a@+ 8 >> $ff and 
		lev =? ( checkl )
		drop
		1+ ) drop 
	processlevel		
	;
	
|----------------------
#xa #ya
:saseti
	curx 'xi ! cury 'yi ! |...
:seti
	sdlx 'xa ! sdly 'ya ! ;

:dnIns
	dup 'stri strcpy
	over 'si !
	saseti ;
	
:dnCode
	cdcnt =? ( ; ) 
	a> 8 - @ dup 'si !
	vmtokstr 'stri strcpy
	a> dup 8 - swap cdcnt move
	-1 'cdcnt +!
	saseti ;

:moveins
	sdlx xa - 'xi +! 
	sdly ya - 'yi +! 
	seti ;

:ins()
	nowins -? ( drop -1 'si ! ; ) 
	3 << 'cdtok + 
	dup dup 16 + swap cdcnt move> |dsc
	11 10 rot !+ ! | + ( )
	2 'cdcnt +!
	-1 'nowins !
	-1 'si !
	processlevel
	;
	
:upins
	si -1 =? ( drop ; ) 
	255 =? ( drop 
		ins() ; ) 
	drop
	nowins -? ( drop 
		removelev 
		-1 'si ! ; ) 
	3 << 'cdtok + 
	dup dup 8 + swap cdcnt move> |dsc
	si swap !
	1 'cdcnt +!
	-1 'nowins !
	-1 'si !
	processlevel
	;

|------ INST

#words "123" """str""" "( )" " ?? " "STK" "+-*/" "@!" "|com" 0

:orden | "" -- ""
	plgui
	$444444 SDLColor
	plxywh SDLFRect
	dup immlabelc
	;	
	
:mpaleta
	300 64 immat
	64 22 immbox
	0 'words 
	( dup c@ 1? drop
		orden immdn
		>>0 swap 1+ swap ) 3drop ;
	
:dragword | tok "" --
	plgui
	$7f00 SDLColor
	plxywh SDLFRect
	dup immlabelc
	'dnIns 'moveIns 'upIns onMapA 
	2drop 
	;
	
|------------------
#value
#base 0
#bases " %d" "$%h" "%%%b"

:dnNro
	value 
	base 2 << 'bases +
	sprint 'stri strcpy
	value 32 << base or 'si !
	saseti ;

:kv	value 10 * + 'value ! ;
	
:kcol base =? ( $7f7f7f ; ) $7f7f ;
	
:kbase | "" n --
	kcol 'immcolorbtn ! 
	[ dup 'base ! ; ] rot immbtn 
	drop ;
	
:nroins
	$7f 'immcolorbtn ! 
	128 22 immbox
	'value immInputInt
	'dnNro 'moveIns 'upIns onMapA 
	immcr ;
:keypad	
	32 22 immbox	
	[ 7 kv ; ] "7" immbtn imm>> [ 8 kv ; ] "8" immbtn imm>> [ 9 kv ; ] "9" immbtn immcr
	[ 4 kv ; ] "4" immbtn imm>> [ 5 kv ; ] "5" immbtn imm>> [ 6 kv ; ] "6" immbtn immcr
	[ 1 kv ; ] "1" immbtn imm>> [ 2 kv ; ] "2" immbtn imm>> [ 3 kv ; ] "3" immbtn immcr
	[ 0 kv ; ] "0" immbtn imm>> 
	[ value 10 / 'value ! ; ] "<" immbtn imm>>
	[ 0 'value ! ; ] "C" immbtn 
	immcr immcr
	"d" 0 kbase imm>> "h" 1 kbase imm>> "b" 2 kbase 
	;
	

|-------------------------	
#tins
( 75 ) "+" ( 76 ) "-" ( 77 ) "*" ( 78 ) "/" 
( 79 ) "mod" ( 72 ) "and" ( 73 ) "or" ( 74 ) "xor" 						
( 67 ) "not" ( 68 ) "neg" ( 69 ) "abs" ( 70 ) "sqrt"
( 80 ) "<<" ( 81 ) ">>" ( 83 ) "/mod" ( 84 ) "*/" 

( 15 ) "0?" ( 16 ) "1?" ( 17 ) "+?" ( 18 ) "-?"				
( 21 ) "=?" ( 24 ) "<>?" ( 25 ) "and?" ( 26 ) "nand?"
( 19 ) "<?" ( 23 ) "<=?" ( 20 ) ">?" ( 22 ) ">=?" 

( 28 ) "dup" ( 29 ) "drop" ( 30 ) "over" ( 35 ) "swap" 
( 36 ) "nip" ( 37 ) "rot" ( 31 ) "pick2" ( 32 ) "pick3" 
|"PICK4" "-ROT" "2DUP" "2DROP" 
|"3DROP" "4DROP" "2OVER" "2SWAP"		|36-42
( 43 ) "@" ( 45 ) "@+" ( 77 ) "!" ( 79 ) "!+"
|"c@" "c@+" "c!" "c!+" "c+!"
( 51 ) "+!" ( 14 ) "ex" 
( -1 ) 

:nextdrag
	1+ $3 nand? ( immcr ; ) imm>> ;
	
:word
	immcr
	$7f00 'immcolorbtn ! 
	64 23 immbox
	255 "( )" dragword imm>>

	1 ":" dragword imm>>
	2 "#" dragword imm>>
	9 ";" dragword immcr
|	"123" 
|	"str"
|	"com"
	0 'tins
	( c@+ +?
		over dragword 
		swap nextdrag
		swap >>0
		) 3drop
	;


#str * 256
:strins
	$7f 'immcolorbtn ! 
	128 22 immbox
	'str 256 immInputLine
|	'dnNro 'moveIns 'upIns onMapA 
	immcr ;
	
:panelword
	300 64 immwinxy
	nroins
	strins
	word
	;
	
|---------------------------------	
	
:incell
	over 'nowins ! 
	$333333 sdlcolor 
	plxywh SDLFRect 
	;
	
:cprint2 | "" --
	curx padx + lev 4 << + cury pady + ttat tt. ;
	
:codeprint
	nowins =? ( ; )
	cdcnt =? ( nowins -? ( drop ; ) drop )
	a@+ |dup
	dup 8 >> $ff and 'lev !
	vmtokstr cprint2 
	|"     %h" ttprint
	;
	
:linecode
	$333333 ttcolor
	curx 32 - cury pady + ttat
	dup 1+ "%d" ttprint
	$ffffff ttcolor
	224 22 immbox
	plgui
	si -1 <>? ( 'incell guiI ) drop
	codeprint
	'dnCode 'moveins 'upins onMapA ;	
	
:mcode
	cdx cdy immwinxy
	224 384 immbox
	plgui 
	$444444 sdlcolor plxywh SDLFRect	
	[ -1 'nowins ! ; ] guiO
	$ffffff ttcolor
	'cdtok >a
	0 ( cdcnt <=?
		linecode
		immcr
		1+ ) drop ;


|------ PLAYCODE
:cdcur
	cdtok> 'cdtok - 3 >> ;
	
:linecursor
	cdcur <>? ( $333333 ttcolor ; ) 
	curx 48 - cury pady + ttat
	$eeeeee ttcolor ">" ttprint 
	;
	
:linecode
	linecursor
	curx 32 - cury pady + ttat
	dup 1+ "%d" ttprint
	$ffffff ttcolor
	224 22 immbox
	a@+ dup 8 >> $ff and 'lev !
	vmtokstr cprint2 ;
	
:pcode
	cdx cdy immwinxy
	224 384 immbox
	plgui 
	$444444 sdlcolor plxywh SDLFRect	
	$ffffff ttcolor
	'cdtok >a
	0 ( cdcnt <?
		linecode
		immcr
		1+ ) drop ;

|------ STACK
#skx 64 #sky 500
#skview 4
#skcnt 6
#sktok * 128	

:mstack
	skx sky ttat
	vmdeep 0? ( drop ; ) 
	code 8 +
	( swap 1 - 1? swap
		@+ vmcell "%s " ttprint
		) 2drop 
	TOS vmcell ttprint
	;

|-----------------------------
:editando
|	player
	
	panelword
	mcode
	showins
	;

|-----------------------------
	
:stepvm
	cdtok> vmstep 'cdtok> !
	cdtok> 'cdtok - 3 >> 
	cdcnt <? ( 'stepvm cdspeed +vexe ) drop
	;
	
:ejecutando
|	player
	
	pcode
	mstack
	;
	
|-----------------------------	
#estado 'editando		
	
:iplay
	|resetplayer
	'ejecutando 'estado !
	cdcnt 0? ( drop ; ) drop
	'cdtok 'cdtok> !
	'stepvm cdspeed +vexe | 'exe 3.0 --
	;

:iedit
	'editando 'estado !
	;

:iclear
	0 'cdcnt !
	;
	
:menu
	vupdate
	0 sdlcls 
	immgui
	
	$ff 'immcolorbtn !
	60 22 immbox
	4 4 immat
	"r3Code" immlabelc immdn

	'iplay "play" immbtn imm>>
	'iedit "edit" immbtn imm>>
	'iclear "clear" immbtn imm>>
	$ff0000 'immcolorbtn ! 'exit "Exit" immbtn imm>>
	usod deld "d:%d u:%d" immLabel
 	
	estado ex

	SDLredraw 
	sdlkey
	>esc< =? ( exit )
	<f1> =? ( processlevel )
	drop
	;

:modmenu
	'menu sdlShow ;

: |<<< BOOT <<<
	"r3code" 1024 600 SDLinit
	|bfont1
	"media/ttf/roboto-bold.ttf" 20 TTF_OpenFont immSDL
	64 vaini
	
|	tsize dup "r3/r3vm/img/rcode.png" ssload 'imgspr !
|	calc
	
	vmcpu 'cpu !
	
	|------- test
	6 'cdcnt !
	'cdtok >a
	$300000000 a!+
	$10a a!+
	$110 a!+
	$100000100 a!+
	$14c a!+
	$10b a!+
	processlevel
|	resetplayer
	
	modmenu
	SDLquit 
	;
