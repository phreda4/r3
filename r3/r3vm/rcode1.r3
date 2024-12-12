| rcode nivel 1
| PHREDA 2024
|-------------------------

^r3/lib/rand.r3
^r3/lib/sdl2gfx.r3
^r3/util/sdlgui.r3
^r3/util/varanim.r3

^r3/r3vm/arena-map.r3

#cpu
#imgspr

#dicc * $fff
#dicc> 'dicc
#str * $fff
#str> 'str
|----------------------------------
| LIT/()/??/STK/OPER/VAR/WORD

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
	'stri ttemits
	;

:processlevel	
	cdcnt 'cdtok vmcheckcode 
	cdcnt 'cdtok vmcheckjmp
	;

|--------------------------
#lev

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
	
	
:definew
	;
	
:definev
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

|---------------------------------
#str * 128
#base

:dnnro
	1- 'base !
	'str str>nro nip
	32 << base or 'si !
	saseti ;

:dnstr
	'str dup 'stri strcpy
	isNro 1? ( dnnro ; ) drop
	| cpy to str
	0 32 << 4 or 'si !
	saseti ;
	;

:strins
	$7f 'immcolorbtn ! 
	256 22 immbox
	'str 127 immInputLine
	'dnstr 'moveIns 'upIns onMapA 
	immcr ;
	

|------- INSTRUCTION
#tins
( 75 ) "+" ( 76 ) "-" ( 77 ) "*" ( 78 ) "/" 
( 79 ) "mod" ( 72 ) "and" ( 73 ) "or" ( 74 ) "xor" 						
( 67 ) "not" ( 68 ) "neg" ( 69 ) "abs" ( 70 ) "sqrt"
( 80 ) "<<" ( 81 ) ">>" ( 83 ) "/mod" ( 84 ) "*/" 

( 15 ) "0?" ( 16 ) "1?" ( 17 ) "+?" ( 18 ) "-?"				
( 21 ) "=?" ( 24 ) "<>?" ( 25 ) "and?" ( 26 ) "nand?"
( 19 ) "<?" ( 23 ) "<=?" ( 20 ) ">?" ( 22 ) ">=?" 

( 28 ) "dup" ( 29 ) "drop" ( 30 ) "over" ( 34 ) "swap" 
( 35 ) "nip" ( 36 ) "rot" ( 31 ) "pick2" ( 32 ) "pick3" 
|"PICK4" "-ROT" "2DUP" "2DROP" 
|"3DROP" "4DROP" "2OVER" "2SWAP"		|36-42
( 43 ) "@" ( 45 ) "@+" ( 47 ) "!" ( 49 ) "!+"
( 44 ) "c@" ( 46 ) "c@+" ( 48 ) "c!" ( 50 ) "c!+" 
( 51 ) "+!" ( 52 ) "c+!" ( 14 ) "ex"  ( 9 ) ";"
( -1 ) 

:dragword | tok "" --
	plgui
	plxywh SDLFRect
	dup immlabelc
	'dnIns 'moveIns 'upIns onMapA 
	2drop 
	;

:nextdrag
	1+ $3 nand? ( immcr ; ) imm>> ;
	
:ipanel
	strins
	64 23 immbox
	$7f0000 'immcolorbtn !
	'definew ":" immbtn imm>>
	$7f007f 'immcolorbtn !
	'definev "#" immbtn imm>>
	$7f7f00 sdlcolor
	255 "( )" dragword immcr
	$7f00 sdlcolor
	0 'tins
	( c@+ +?
		over dragword 
		swap nextdrag
		swap >>0
		) 3drop 
	immcr 
	$7f7f sdlcolor
	0 words 
	( @+ 1?
		pick2 $80 or swap dragword 
		swap nextdrag
		swap
		) 3drop ;
	
	
|---------------------------------	
:incell
	over 'nowins ! 
	$333333 sdlcolor 
	plxywh SDLFRect 
	;
	
:cprint2 | "" --
	curx padx + lev 4 << + cury pady + ttat ttemits ;
	
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
	160 22 immbox
	plgui
	si -1 <>? ( 'incell guiI ) drop
	codeprint
	'dnCode 'moveins 'upins onMapA ;	
	
:mcode
	cdx cdy immwinxy
	160 384 immbox
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
	160 384 immbox
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

:mstack
	skx sky ttat
	vmdeep 0? ( drop ; ) 
	stack 8 +
	( swap 1 - 1? swap
		@+ vmcell ttemits " " ttemits
		) 2drop 
	TOS vmcell ttemits
	;

|-----------------------------
:editando
|	player
	
	300 64 immwinxy
	ipanel

	mcode
	showins
	;

|-----------------------------
:stepvm
	cdtok> 
	0? ( drop ; ) 
	vmstepck 'cdtok> !
	terror 1? ( drop -8 'cdtok> +! ; ) drop
	cdtok> 'cdtok - 3 >> 
	cdcnt <? ( 'stepvm cdspeed +vexe ) drop
	;
	
:ejecutando

	300 64 mapdraw
	player
	
	pcode
	mstack
	;
	
|-----------------------------	
#estado 'editando		
	
:iplay
	terror 1? ( drop ; ) drop
	'ejecutando 'estado !
	cdcnt 0? ( drop ; ) drop
	'cdtok 'cdtok> !
	vmreset
	resetplayer
	
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
	
	
	60 22 immbox
	4 4 immat
	"r3Code" immlabelc immdn
	
	$7f 'immcolorbtn !
	terror 1? ( $ff0000 'immcolorbtn ! ) drop
	'iplay "play" immbtn imm>>
	$7f00 'immcolorbtn !
	'iedit "edit" immbtn imm>>
	'iclear "clear" immbtn imm>>
	$7f0000 'immcolorbtn ! 'exit "Exit" immbtn imm>>
	usod deld "d:%d u:%d" immLabel imm>>
	
	vmerror 1? ( 
		$ff0000 'immcolortex !
		dup "error: %s" immlabel
		$ffffff 'immcolortex !
		) drop
 	
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
	|bfont1
	"media/ttf/roboto-bold.ttf" 20 TTF_OpenFont immSDL
	64 vaini
	
	arena.ini
	map-ins0
	
	'cdtok 4 vmcpu 'cpu !
	
	|------- test
	7 'cdcnt !
	'cdtok >a
	$300000000 a!+
	$10a a!+
	$110 a!+
	$100000100 a!+
	$14c a!+
	$10b a!+
	$09 a!+
	processlevel
	
	modmenu
	SDLquit 
	;
