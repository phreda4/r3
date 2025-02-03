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
#termcolor 
$0C0C0C | 0 black
$0037DA | 1 blue
$3A96DD | 2 cyan
$13A10E | 3 green
$881798 | 4 purple
$C50F1F | 5 red
$CCCCCC | 6 white
$C19C00 | 7 yellow
$767676 | 8 brightBlack
$3B78FF | 9 brightBlue
$61D6D6 | a brightCyan
$16C60C | b brightGreen
$B4009E | c brightPurple
$E74856 | d brightRed
$F2F2F2 | e brightWhite
$F9F1A5 | f brightYellow
	
:plog | "" --
	count 1+ | s c
	'term dup pick2 + swap rot 2048 swap - cmove>
	'term strcpy ;	

:dighex | c --  dig / 0
	$3A <? ( $30 - ; ) tolow $60 >? ( $57 - $f >? ( 0 nip ) ; )	0 nip ;
 
:chcolor | c --
	3 << 'termcolor + @ bcolor ;

:escape | e --
	tolow
	$63 =? ( drop c@+ dighex chcolor ; ) | %cn -- color
	drop ; |%l -- line
	
:chemit | c --
	$25 =? ( drop c@+ $25 <>? ( escape ; ) )
	bemit ;
	
:exemit |  str -- 
	$b chcolor ( c@+ 1? chemit ) 2drop ;
	
:showterm
	$7f3f3f3f sdlcolorA	| cursor
	8 32 320 112 SDLfRect	
	$00ff00 bcolor
	ab[
	'term >a 7 ( 1? 1 over 1+ gotoxy a> dup exemit >>0 >a 1- ) drop
	]ba
	;	
	
|------------	
#font
#cpu
#state

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
|	cdcnt 'cdtok vmcheckcode 
	cdcnt 'cdtok vmcheckjmp
	;

:stepvm
	cdnow> 0? ( drop ; ) 
	|vmstepck 
	vmstep
	1? ( dup vm2src 'fuente> ! )
	'cdnow> !
	;
	
:stepvma
	cdnow> 0? ( drop ; ) 
	|vmstepck 
	vmstep
	1? ( dup vm2src 'fuente> ! )
	0? ( dup 'state ! ) 
	'cdnow> !

	terror 1 >? ( 2 'state ! ) drop
	;
	
|-----------------------
:showeditor
	$7f00007f sdlcolorA	
	edfill
	edfocus
	edcodedraw
	;	
	
:showruning
	$7f00007f sdlcolorA	
	edfill
	$7f0000 sdlcolor
	edmark
	edcodedraw
	;	

:showerror
	$7f00007f sdlcolorA	
	edfill
	$7f0000 sdlcolor
	edmark
	
	showmark
	
	edfocus
	edcodedraw
	8 188 bat $ff0000 bcolor
	vmerror 0? ( drop ; ) bprint2
	
	;
|-----------------------
:editcompilar
	clearmark

	vmtokreset
	fuente 'cdtok vmtokenizer 'cdtok> ! 
	0 cdtok> !
	cdtok> 'cdtok - 3 >> 'cdcnt !
	vmboot 
	1? ( dup vm2src 'fuente> ! )
	'cdnow> !
	
|	vmdicc | ** DEBUG
|processlevel
	terror 1 >? ( drop 2 'state ! serror 'fuente> ! ; ) drop
	1 'state ! stepvma
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
	;
	
|------------- IMM
:compilar
	vmtokreset
	'pad 'cdtok vmtokenizer 'cdtok> ! 
	0 cdtok> !
	cdtok> 'cdtok - 3 >> 'cdcnt !
	'cdtok 'cdnow> !
	processlevel
	;
	
:immex	
	compilar
	0 'pad !
	refreshfoco
|	code> ( icode> <? 
	| vmcheck
|		vmstep ) drop
	;
	
:showinput
	$7f00007f sdlcolorA	| cursor
	0 500 1024 600 SDLfRect
	$ff0000 bcolor
	0 502 bat ":" bprint2
	32 500 immat 1000 32 immbox
	'pad 128 immInputLine2
	sdlkey
	<ret> =? ( immex )
	drop
	;		

|-------------------
#script
#script>
#scrstate

:dialogo
	;
	
:loadlevel | "" --
	"loading tutor..." plog
	here dup 'script ! dup 'script> !
	swap load 
	0 swap c!+ 'here ! 
	0 'scrstate	!
	;

:addline
	script> dup >>cr 0 swap c!
	dup >>0 trim 'script> ! 
|	"*w" =pre 1? ( ) 
	plog
	;
	
:runscript
	scrstate
	drop
	;
	
:draw.code
|	showcode
	
	state 
	0? ( showeditor )
	1 =? ( showruning )
	2 =? ( showerror ) 
	3 =? ( showinput )
	drop
	
	showstack
	;
	
#textitle
|-------------------
:runscr
	vupdate
	immgui
	mouseview
	0 sdlcls
	
	$ffff bcolor 8 8 bat "Ar3na Code" bprint
	
|	100 100 textitle sprite
	
|	$ffffff sdlcolor
	draw.map
	draw.player
	draw.items
	draw.code

	runscript
	showterm
	
	sdlredraw
	sdlkey
	>esc< =? ( exit )
	<f1> =? ( editcompilar )
	<f2> =? ( addline ) 
|	<f3> =? ( "test" plog )
	drop ;
	
|-------------------
: |<<< BOOT <<<
	"arena tank" 1024 600 SDLinit
	SDLblend
	
|	"media/ttf/Roboto-Medium.ttf" 30 TTF_OpenFont 'font !		
|	"Code Ar3na" $ffff0025f000 200 80 font textbox 'textitle !	
	
	bfont1
	64 vaini
	
| editor
	1 14 40 20 edwin
	edram
	
	bot.ini
	bot.reset
	'cdtok 8 vmcpu 'cpu ! | 8 variables

	"r3/r3vm/code/test.r3" edload | "" --
	
	"r3/r3vm/levels/level0.txt" loadmap
	"r3/r3vm/levels/tuto.txt" loadlevel	
	
	'runscr SDLshow
	SDLquit 
	;
