| ar3na bot 
| PHREDA 2025
|-------------------------
^r3/util/sdlgui.r3
^r3/util/sdlbgui.r3
^r3/util/varanim.r3
^r3/util/textb.r3
^r3/util/sdledit.r3

^./arena-map.r3
^./rcodevm.r3

|----------- color terminal

#term * 2048
	
:plog | "" --
	count 1+ | s c
	'term dup pick2 + swap rot 2048 swap - cmove>
	'term strcpy 
	;	

:chemit
	;
	
:exemit |  str -- 
	( c@+ 1?
		bemit
		) 2drop ;
	
:showterm
	$7f00007f sdlcolorA	| cursor
	8 32 320 112 SDLfRect	
	$00ff00 bcolor
	ab[
	'term >a 7 ( 1? 1 over 1+ gotoxy a> dup exemit >>0 >a 1- ) drop
	]ba
	;	
	
|------------	
#font
#cpu

|----- code
#cdtok * 1024
#cdtok> 'cdtok
#cdnow>
#cdcnt

#lev
#cdspeed 0.2

:linecode | adr -- adr
	cdnow> =? ( ">" bemits )
	@+ dup 8 >> $ff and 'lev !
	vmtokstr bemits bsp ;
	
:showcode
	2 64 bat
	'cdtok
	0 ( cdcnt <? swap 
		linecode
		swap 1+ ) 
	2drop  ;

:processlevel	
	cdcnt 'cdtok vmcheckcode 
	cdcnt 'cdtok vmcheckjmp
	;

:stepvm
	cdnow> 0? ( drop ; ) 
	|vmstepck 
	vmstep
	'cdnow> !
|	terror 1 >? ( drop -8 'cdnow> +! ; ) drop
	;
	
:stepvma
	stepvm
	cdnow> cdtok> <? ( 'stepvma cdspeed +vexe ) drop
	|cdnow> 'cdtok - 3 >> cdcnt <? ( 'stepvma cdspeed +vexe ) drop
	;
	
|-----------------------
	
:showeditor
	$7f00007f sdlcolorA	| cursor
	edfill
	$ffffff sdlcolor
	edfocus 		
	edcodedraw
	;	

|-----------------------

:compilar
	vmtokreset
	'pad 'cdtok vmtokenizer 'cdtok> ! 
	0 cdtok> !
	cdtok> 'cdtok - 3 >> 'cdcnt !
	'cdtok 'cdnow> !
	processlevel
	;

:compilaredit
	vmtokreset
	fuente 'cdtok vmtokenizer 'cdtok> ! 
	0 cdtok> !
	cdtok> 'cdtok - 3 >> 'cdcnt !
	vmboot 'cdnow> !
|	vmdicc
|processlevel
|vmdicc
	;
	
:immex	
	compilar
	0 'pad !
	refreshfoco
|	code> ( icode> <? 
	| vmcheck
|		vmstep ) drop
	;
	
:showstack
	8 532 bat
	" " bprint2
	vmdeep 0? ( drop ; ) 
	stack 8 +
	( swap 1 - 1? swap
		@+ vmcell "%s " bprint2 
		) 2drop 
	TOS vmcell "%s " bprint2
	8 564 bat $ff0000 bcolor
	vmerror 0? ( drop ; ) bprint2
	;
	
	
:showinput
	$7f00007f sdlcolorA	| cursor
	0 500 1024 600 SDLfRect
	$ff0000 bcolor
	0 502 bat ":" bprint2
	32 500 immat 1000 32 immbox
	'pad 128 immInputLine2	
	;		

|-------------------
#script
#script>
#scrstate

:dialogo
	;
	
	
:loadlevel | "" --
	"loading tutor..." plog
	here dup 'script ! 'script> !
	here "r3/r3vm/levels/tuto.txt" load 0 swap c!
	
	;


|-------------------
:runscr
	vupdate
	immgui
	mouseview
	0 sdlcls
	
	$ffff bcolor 8 8 bat "Ar3na Code" bprint

	showcode
	showstack
	
	$ffffff sdlcolor
	draw.map
	draw.player
	draw.items
	
	showeditor
	|showinput
	
	showterm
	
	sdlredraw
	sdlkey
	>esc< =? ( exit )
|	<ret> =? ( immex )
	
	|----
	<f1> =? ( compilaredit )
	<f2> =? ( stepvm ) | a
	<f3> =? ( "test" plog )
	drop ;

	
|-------------------
: |<<< BOOT <<<
	"arena tank" 1024 600 SDLinit
	SDLblend
	"media/ttf/seguiemj.ttf" 20 TTF_OpenFont 'font !		
	bfont1
	64 vaini
	
| editor
	1 10 40 24 edwin
	edram
	
	bot.ini
	bot.reset
	'cdtok 8 vmcpu 'cpu ! | 8 variables
		
	"loading level..." plog
	"r3/r3vm/levels/level0.txt" loadmap
	
	'runscr SDLshow
	SDLquit 
	;
