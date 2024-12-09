| rcode nivel 2
| PHREDA 2024
|-------------------------

^r3/lib/rand.r3
^r3/lib/sdl2gfx.r3
^r3/util/sdlbgui.r3
^r3/util/varanim.r3

^r3/r3vm/rcodevm.r3

#cpu
#imgspr

|----------------------------------
| LIT/()/??/STK/OPER/VAR/WORD

#cdx 64 #cdy 64
#cdcnt 0
#cdmax 128 

#cdtok * 1024
#cdtok> 'cdtok

#cdspeed 0.2

|-----------------------------
:stepvm
	cdtok> 
	0? ( drop ; ) 
	vmstep 'cdtok> !
	cdtok> 'cdtok - 3 >> 
	cdcnt <? ( 'stepvm cdspeed +vexe ) drop
	;
	

|-----------------------------	
	
:iplay
	terror 1? ( drop ; ) drop
	cdcnt 0? ( drop ; ) drop
	'cdtok 'cdtok> !
	vmreset
	'stepvm cdspeed +vexe | 'exe 3.0 --
	;


:iclear
	0 'cdcnt !
	;
	
#lev
	
:cprint2 | "" --
	curx padx + lev 4 << + cury pady + bat bemits2 ;
	
:linecode
	curx 32 - cury pady + bat
	dup 1+ "%d" bprint2
	$ffffff bcolor
	224 22 immbox
	a@+ dup 8 >> $ff and 'lev !
	vmtokstr cprint2 ;
	
:showcode
	cdx cdy immwinxy
	160 384 immbox
	plgui 
	$444444 sdlcolor plxywh SDLFRect	
	$ffffff bcolor
	'cdtok >a
	0 ( cdcnt <?
		linecode
		immcr
		1+ ) drop ;
		
#pad * 1024	
#lerror

:immex	
|	r3reset
|	'pad r3i2token drop 'lerror !
	0 'pad !
	refreshfoco
|	code> ( icode> <? 
	| vmcheck
|		vmstep ) drop
	;

:input
	8 500 immat
	1000 32 immbox
	'pad 128 immInputLine2	
	
	8 532 bat
	" " bprint2
	vmdeep 0? ( drop ; ) 
	stack 8 +
	( swap 1 - 1? swap
		@+ "%d " bprint2 
		) 2drop 
	TOS "%d " bprint2
	;	

:main
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
	$7f0000 'immcolorbtn ! 'exit "Exit" immbtn imm>>
	usod deld "d:%d u:%d" immLabel imm>>
	terror "error:%d" immlabel
 
	showcode 
	input

	SDLredraw 
	sdlkey
	>esc< =? ( exit )
	<ret> =? ( immex )
	<esp> =? ( immex )	
	drop
	;

: |<<< BOOT <<<
	"r3code" 1024 600 SDLinit
	bfont1
	64 vaini
	
	'cdtok 32 vmcpu 'cpu !

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
	
	'main sdlShow 

	SDLquit 
	;
