| ar3na bot 
| PHREDA 2025
|-------------------------
^r3/lib/gui.r3
^r3/util/varanim.r3
^r3/util/ttext.r3

^./arena-map.r3

^./tedit.r3
^./rcodevm.r3

|---------
:btnt | x y v "" col --
	pick4 pick4 128 24 guiBox
	[ dup 2* or ; ] guiI sdlcolor
	[ 2swap 2 + swap 2 + swap 2swap ; ] guiI
	2over 128 24 sdlfrect
	2swap 4 + swap 4 + swap tat
	$e tcol temits	
	onClick ;

:btnt2 | x y v "" col --
	pick4 pick4 256 48 guiBox
	[ dup 2* or ; ] guiI sdlcolor
	[ 2swap 2 + swap 2 + swap 2swap ; ] guiI
	2over 256 48 sdlfrect
	2swap 8 + swap 8 + swap tat
	$e tcol temits	
	onClick ;

|------------	
#cpu
#state | 0 - view | 1 - edit | 2 - run | 3 - error
	
|----- code
#cdtok * 1024
#cdtok> 'cdtok
#cdnow>
#cdcnt

#lev
#cdspeed 0.2

:linecode | adr -- adr
	cdnow> =? ( ">" temits )
	@+ dup 8 >> $ff and 'lev !
	vmtokstr temits tsp ;
	
:showcode
	2 64 tat
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
	vmstepck 
	|vmstep
	terror 1 >? ( 2drop 
		3 'state ! 
		clearmark
		fuente> $f00ffff addsrcmark 
		; ) drop
	
	1? ( dup vm2src 'fuente> ! 'stepvma cdspeed +vexe )
	cdtok> >=? ( drop 0 ) | fuera de codigo
	0? ( 1 'state ! ) 
	'cdnow> !
	;

:stepvmas
	cdnow> 0? ( drop ; ) 
	vmstepck 
	|vmstep
	terror 1 >? ( 2drop 
		3 'state ! 
		clearmark
		fuente> $f00ffff addsrcmark 
		; ) drop
	
	1? ( dup vm2src 'fuente> ! )
	cdtok> >=? ( drop 0 ) | fuera de codigo
	0? ( 1 'state ! ) 
	'cdnow> !
	;
	
|-----------------------
:showread
	$003f00 sdlcolor xedit yedit 16 - wedit 16 SDLFrect
	$ffffff trgb xedit 64 + yedit 16 - tat "CODE:" tprint
	$7f00003f sdlcolorA	xedit yedit wedit hedit sdlFRect
	
|	edfocus
	edcodedraw
	edtoolbar
	;

:showeditor
	$003f00 sdlcolor xedit yedit 16 - wedit 16 SDLFrect
	$ffffff trgb xedit 64 + yedit 16 - tat "CODE: EDIT" tprint
	$7f00007f sdlcolorA	xedit yedit wedit hedit sdlFRect
	
	edfocus
	edcodedraw
	edtoolbar
	;	
	
:showruning
	$003f3f sdlcolor xedit yedit 16 - wedit 16 SDLFrect
	$ffffff trgb xedit 64 + yedit 16 - tat "CODE: RUN" tprint
	$7f00003f sdlcolorA	xedit yedit wedit hedit sdlFRect
	
	clearmark
	fuente> $007ffff addsrcmark
	RTOS ( @+ 1?
		8 - @ vmcode2src $0070000 addsrcmark
		) 2drop
	showmark
	
	edcodedraw
	edtoolbar
	;	

:showerror
	$3f0000 sdlcolor xedit yedit 16 - wedit 16 SDLFrect
	$ffffff trgb xedit 64 + yedit 16 - tat "CODE: " tprint vmerror tprint
	$7f00007f sdlcolorA xedit yedit wedit hedit sdlFRect

	showmark
	
	edfocus
	edcodedraw
	edtoolbar
	;
	
|-----------------------
:compilar
	vmtokreset
	fuente 'cdtok vmtokenizer 'cdtok> ! 
	0 cdtok> !
	cdtok> 'cdtok - 3 >> 'cdcnt !
	
|	vmdicc | ** DEBUG
|processlevel

	terror 1 >? ( drop 
		3 'state ! 
		serror 'fuente> ! 
		clearmark
		fuente> $700ffff addsrcmark 
		; ) drop
	2 'state ! 
	;
	
:play
	state 2 =? ( drop ; ) drop
	compilar
	state 2 <>? ( drop ; ) drop
	
	vmboot 
	dup vm2src 'fuente> ! 
	'cdnow> !
	vmreset
	resetplayer
	'stepvma cdspeed +vexe
	;
	
	
:step
	state 2 =? ( drop stepvmas ; ) drop | stop?
	resetplayer compilar
	vmboot 
	dup vm2src 'fuente> ! 
	'cdnow> !
	vmreset
	resetplayer
	 ;
	
:help
	;
	
|------------ STACK
#sty 

:cellstack | cell --
	512 sty 2 - 80 28 sdlfrect
	520 sty tat vmcell temits
	-30 'sty +!
	;
	
#statevec 'showread 'showeditor 'showruning 'showerror 

:draw.code
	2.0 tsize
|-- showcode
	state 3 << 'statevec + @ ex
|-- show stack
	xedit -? ( drop ; ) | not show without editor
	wedit + 2 + 
	yedit hedit + 
	110 16 sdlfrect
	6 tcol
	xedit wedit + 2 +
	yedit hedit + 
	tat " Stack" temits
	vmdeep 0? ( drop ; ) 
	3.0 tsize $3f3f00 sdlcolor
	yedit hedit + 27 - 'sty ! 
	stack 8 +
	( swap 1- 1? swap
		@+ cellstack
		) 2drop 
	TOS cellstack ;

|---- VIEW script
#xterm #yterm #wterm #hterm

:termwin
	'hterm ! 'wterm ! 'yterm ! 'xterm ! ;
	
#inv 0

:te
	11 =? ( drop $80 inv xor 'inv ! ; )
	12 =? ( drop c@+ tcol ; ) 
	13 =? ( drop tcr tsp tsp ; )
	inv or temit ;
	
:cursor	
	msec $100 nand? ( drop ; ) drop $a0 temit ;
	
:nextlesson
	1200 200 'nextchapter " Next" $3f3f00 btnt ;
		
:draw.script
	sstate -? ( drop ; ) drop
	$7f3f3f3f sdlcolorA	
	xterm yterm wterm hterm 
	|8 32 sw 16 - 14 16 * 
	sdlFRect
	2.0 tsize 3 tcol 0 'inv !
	2 3 txy 'term ( term> <? c@+ te ) drop
	sstate 1? ( drop nextlesson ; ) drop
	cursor
	1100 200 'completechapter "   >>" $3f00 btnt
	;
	

|-------------------	
:botones
	4 tcol 2.0 tsize
	SH 32 -
	8 over 'play "F1:Play" $3f00 btnt
	148 over 'step "F2:Step" $3f00 btnt
	288 over 'help "F3:Help" $3f3f btnt
	428 over 'exit "ESC:Bye" $3f0000 btnt	
|	600 over tat state "%d" tprint
	drop
	;
	
:jugar
	vupdate
	gui
	0 sdlcls

	3.0 tsize
	12 4 tat $5 tcol "Ar3na" temits $3 tcol "Code" temits tcr

	draw.map
	draw.items
	draw.player
	map.step	

	draw.code
	draw.script
	
	botones
	sdlredraw
	sdlkey
	>esc< =? ( exit )
	<f1> =? ( play )
	<f2> =? ( step ) 
	<f3> =? ( help ) 
	drop ;
	
:freeplay
	mark
	500 32 500 200 termwin
	16 48 480 654 edwin	
	
	"r3/r3vm/levels/level1.txt" loadlevel	
	500 262 500 200 mapwin
		
	"r3/r3vm/code/test0.r3" edload 
	resetplayer
	1 'state !
	'jugar SDLshow
	vareset
	empty
	;

:tutor1
	mark
	16 32 1334 200 termwin
	16 262 480 440 edwin	
	
	"r3/r3vm/levels/tutor0.txt" loadlevel
	500 262 500 200 mapwin	
	
	|cleartext
	resetplayer
	1 'state !
	'jugar SDLshow
	vareset
	empty
	;
		
|-------------------
:options	
	;
	
:menu
	vupdate gui 0 sdlcls
	
	|$7f3f3f3f sdlcolorA	200 200 200 600 sdlFRect
	
	6.0 tsize
	12 4 tat $5 tcol "Ar3na" temits $3 tcol "Code" temits tcr
	
	3.0 tsize	
	32 100 'tutor1 "Tutorial"  $3f00 btnt2
	32 200 'freeplay "Free Play"  $3f00 btnt2
	32 500 'options "Options" $3f btnt2
	32 600 'exit "Exit" $3f0000 btnt2
	
	sdlredraw
	sdlkey
	>esc< =? ( exit )
	<f1> =? ( freeplay )
	<f2> =? ( options ) 
	drop ;
	
|-------------------
: |<<< BOOT <<<
	"Ar3na:Code" 1366 768 SDLinit
	SDLblend
	2.0 8 8 "media/img/atascii.png" tfnt 
	64 vaini
	edram	| editor
	bot.ini
	'cdtok 8 vmcpu 'cpu ! | 8 variables

	'menu sdlshow
	
	SDLquit 
	;
