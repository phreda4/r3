| rcode nivel 1
| PHREDA 2024
|-------------------------

^r3/lib/rand.r3
^r3/lib/sdl2gfx.r3
^r3/util/sdlgui.r3
^r3/util/varanim.r3

^r3/r3vm/rcodevm.r3

#cpu

#level0 (
17 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17
17  0  0  0  0  0  0  0  0  0  0  0  0  0  0 17
17  0  0  0  0  0  0  0  0  0  0  0  0  0  0 17
17  0  0  0  0  0  0  5  0  0  6  0  0  7  0 17
17  0  0  0  0  0  0  0  0  0  0  0  0  0  0 17
17  0  0  0  0  0  0  0  0  0  0  0  0  0  0 17
17  0  0  0  0  0  0  0  0  0  0  0  0  0  0 17
17  0  0  0  0  0  0  0  0  0  0  0  0  0  0 17
17  0  0  0  0  4  0  0  0  0  0  0  0  0  0 17
17  0  0  0  0  0  0  0  0  0  0  0  0  0  0 17
17  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0
03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03
)

#imgspr

#mrot 0.0
#tzoom 2.0
#tsize 16 
#tmul

#mvx 8 #mvy 64
#mw 16 #mh 12
#marena * 8192

:calc tsize tzoom *. 'tmul ! ;

:posspr | x y -- xs ys
	swap tmul * mvx + tmul 2/ +
	swap tmul * mvy + tmul 2/ +
	;
	
:drawtile
	|$ffffff sdlcolor postile tmul dup sdlRect
	a@+ $ff and 0? ( drop ; ) >r
	2dup swap posspr tzoom r> 1- imgspr sspritez
	;
	
:mapdraw | x y --
	'mvy ! 'mvx !
	'marena >a
	0 ( mh <? 
		0 ( mw <? 
			drawtile
			1+ ) drop
		1+ ) drop ;

:cpylevel | 'l --
	>b
	'marena >a
	mw mh * ( 1?
		cb@+ a!+
		1- ) drop ;

#xp 1 #yp 1 | position
#dp 0	| direction
#ap 0	| anima
#penergy
#pcarry

:resetplayer
	100 'penergy !
	0 'pcarry ! 
	1 'xp ! 1 'yp !
	'level0 cpylevel
	;

:player
	xp yp posspr
	tzoom
	dp 2* 7 +
	msec 7 >> $1 and +
	imgspr sspritez
	;

:iup 2 'dp ! -1 'yp +! ;
:idn 3 'dp ! 1 'yp +! ;
:ile 1 'dp ! -1 'xp +! ;
:iri 0 'dp ! 1 'xp +!  ;
:ijm 
:ipu
	;

|-------------------------------------	
| scrjr:	eventos/movimiento/apariencia/sonido/control/fin
| scratch:	movimiento/apariencia/sonido/eventos/control/sensor/operadores/variables/bloques
|
| LIT/()/??/STK/OPER/VAR/WORD MOV-DRAW-SOUND SENSOR-KEY-MOUSE

|#grupos ":" "#" "ABC" "123" """str""" "oper" "mem" "stack" "contr" "comm" 
|#words "0" "+" "DUP" "(??"  "??(" "STEP" "TURN" 0

|iLITd iLITh iLITb iLITs 
|iCOM iWORD iAWORD iVAR iAVAR |0-8
|i; 
|i( i) i[ i] 
|iEX 
|i0? i1? i+? i-? 
|i<? i>? i=? i>=? i<=? i<>? iAND? iNAND? 
|iIN? 	|9-27

|iDUP iDROP iOVER iPICK2 iPICK3 iPICK4 iSWAP iNIP 	|28-35
|iROT i2DUP i2DROP i3DROP i4DROP i2OVER i2SWAP 	|36-42

|i@ iC@ i@+ iC@+ i! iC! i!+ iC!+ i+! iC+! 		|43-52

|i>A iA> iA@ iA! iA+ iA@+ iA!+ 					|53-59
|i>B iB> iB@ iB! iB+ iB@+ iB!+ 					|60-66

|iNOT iNEG iABS iSQRT iCLZ						|67-71
|iAND iOR iXOR i+ i- i* i/ iMOD					|72-79
|i<< i>> i>>> i/MOD i*/ i*>> i<</				|80-86

|iMOVE iMOVE> iFILL iCMOVE iCMOVE> iCFILL			|87-92

#cdx 64 #cdy 64
#cdcnt 0
#cdmax 128 
#cdtok * 1024

#cdcur 0
#cdspeed 0.5

	
|------ INSTRUCC
#xi #yi	#si -1 #stri * 32

#nowins -1

:showins
	si -? ( drop ; ) drop
	$555555 sdlcolor
	xi yi 64 22 sdlfrect
	$ffffff ttcolor
	xi 8 + yi ttat 
	'stri tt.
	;

|------ CODE
#lev
:processlevel
	0 'lev ! 
	'cdtok >a
	0 ( cdcnt <?
		a@ dup $7f and 
		10 =? ( 1 'lev +! )
		swap $ff00 nand lev 8 << or a!+
		11 =? ( -1 'lev +! )
		drop
		1+ ) drop ;

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

:dnins
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
	si -? ( drop ; ) 
	255 =? ( drop ins() ; ) 
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

#value
#base 0
#bases " %d" " %h" " %b"
#basep " $%"
:dnNro
	value 
	base 2 << 'bases +
	sprint 'stri strcpy
	base 'basep + c@ 'stri c!
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
	300 64 immwinxy
	128 22 immbox
	'value immInputInt
	'dnNro 'moveIns 'upIns onMapA 
	immcr immcr
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
( 51 ) "+!" ( 14 ) "ex" ( 9 ) ";" 
( -1 ) 

:nextdrag
	1+ $3 nand? ( immcr ; ) imm>> ;
	
:word
	immcr
	$7f00 'immcolorbtn ! 
	64 23 immbox
	255 "( )" dragword imm>>
	9 ";" dragword imm>>
	1 "W" dragword imm>>
	2 "V" dragword immcr
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
	
#pag
:panelword
	300 32 immat
	128 22 immbox	
	'pag "123|""str""|( )| ?? |STK| +-*/ | @! |comm" immCombo | 'val "op1|op2|op3" -- ; [op1  v]
	imm>>
	
	
	nroins
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
	a@+ dup 8 >> $ff and 'lev !
	vmtokstr cprint2 ;
	
:linecode
	$333333 ttcolor
	curx 32 - cury pady + ttat
	dup 1+ "%d" ttprint
	$ffffff ttcolor
	224 22 immbox
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
	$ffffff ttcolor
	'cdtok >a
	0 ( cdcnt <=?
		linecode
		immcr
		1+ ) drop ;


|------ PLAYCODE
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
	plgui
	a@+ vmtokstr immlabel ;	
	
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

:dcell
	;
	
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
	500 64 mapdraw
	player
	
	
	panelword
	mcode
	showins
	;

|-----------------------------
	
:stepvm
	cdcur 
	dup 3 << 'cdtok + vmstep | ****
	drop
	1+ dup 'cdcur !
	cdcnt <? ( 'stepvm cdspeed +vexe ) drop
	;
	
:ejecutando
	400 64 mapdraw
	player
	
	pcode
	mstack
	;
	
|-----------------------------	
#estado 'editando		
	
:iplay
	resetplayer
	0 'cdcur !
	'ejecutando 'estado !
	cdcnt 0? ( drop ; ) drop
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
	|bfont1
	"media/ttf/roboto-bold.ttf" 20 TTF_OpenFont immSDL
	64 vaini
	
	tsize dup "r3/r3vm/img/rcode.png" ssload 'imgspr !
	calc
	
	$ff vmcpu 'cpu !
	
	|------- test
	5 'cdcnt !
	'cdtok >a
	$100000002 a!+
	$200000001 a!+
	$300000000 a!+
	75 a!+
	76 a!+
	
	resetplayer
	
	modmenu
	SDLquit 
	;
