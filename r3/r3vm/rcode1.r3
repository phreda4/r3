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

#words "123" """str""" "( )" " ?? " "STK" "+-*/" "@!" ":Word" "#Var" "|comm" 0
#worde iup idn ile iri ijm ipu

:tok>str | tok -- ""
	'words swap ( 1? 1- swap >>0 swap ) drop ;
	
|:tokexe	| tok --
|	3 << 'worde + @ 0? ( drop ; ) ex ;

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
	xi yi 128 22 sdlfrect
	$ffffff ttcolor
	xi 8 + yi ttat 
	'stri ttprint
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
	vmtokstr 'stri strcpy
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
	
:cprint2 | "" --
	curx padx + cury pady + ttat ttprint ;
	
:codeprint
	nowins =? ( ; )
	cdcnt =? ( nowins -? ( drop ; ) drop )
	a@+ vmtokstr cprint2 ;
	
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

|------ INST
:orden | "" -- ""
	plgui
	$444444 SDLColor
	plxywh SDLFRect
	dup immlabel
	'dnIns 'moveIns 'upIns onMapA ;	
	
:mpaleta
	300 64 immat
	128 22 immbox
	0 'words 
	( dup c@ 1? drop
		orden immdn
		>>0 swap 1+ swap ) 3drop ;

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
		@+ " %d" ttprint
		) 2drop 
	TOS " %d" ttprint
	;

|-----------------------------
:editando
	450 64 mapdraw
	player
	
	mpaleta
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
	
	vmcalc
	$ff vmcpu 'cpu !
	
	|------- test
	5 'cdcnt !
	'cdtok >a
	$ff00000000 a!+
	$7f00000001 a!+
	$f00000002 a!+
	75 a!+
	76 a!+
	
	resetplayer
	
	modmenu
	SDLquit 
	;
