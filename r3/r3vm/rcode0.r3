| rcode - nivel 0
| basicos
| PHREDA 2024
|-------------------------

^r3/lib/rand.r3
^r3/lib/sdl2gfx.r3
^r3/util/sdlbgui.r3
^r3/util/varanim.r3
^r3/r3vm/arena-map.r3

:iup 0 botstep ;
:idn 4 botstep ;
:ile 6 botstep ;
:iri 2 botstep ;
:ijm 
:ipu
	;

|-------------------------------------	
#words "Up" "Down" "Left" "Right"  "Jump" "Push" 0
#worde iup idn ile iri ijm ipu

#cdx 64 #cdy 64
#cdcnt 0
#cdmax 128 
#cdtok * 1024

#cdcur 0
#cdspeed 0.5

:cprint2 | "" --
	curx padx + cury pady + bat bprint2 ;

:tok>str | tok -- ""
	'words swap ( 1? 1- swap >>0 swap ) drop ;
	
:tokexe	| tok --
	3 << 'worde + @ 0? ( drop ; ) ex ;
	
|------ INSTRUCC
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

|-----------------------------
:editando
	|450 64 mapdraw
	draw.map
	player
	
	mpaleta
	mcode
	showins
	;

|-----------------------------
:vmstep
	cdcur 
	dup 3 << 'cdtok + @ tokexe
	1+ dup 'cdcur !
	cdcnt <? ( 'vmstep cdspeed +vexe ) drop
	;
	
:ejecutando
	|400 64 mapdraw
	draw.map
	player
	
	pcode
	;
	
|-----------------------------	
#estado 'editando		
	
:iplay
	resetplayer
	0 'cdcur !
	'ejecutando 'estado !
	cdcnt 0? ( drop ; ) drop
	'vmstep cdspeed +vexe | 'exe 3.0 --
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
	60 24 immbox
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

: |<<< BOOT <<<
	"r3code" 1024 600 SDLinit
	bfont1
	64 vaini
	
	bot.ini
	resetplayer
	
	'menu sdlShow 
	SDLquit 
	;
