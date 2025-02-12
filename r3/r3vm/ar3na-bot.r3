| ar3na bot 
| PHREDA 2025
|-------------------------
^r3/lib/gui.r3
^r3/util/varanim.r3
^r3/util/ttext.r3

^./tedit.r3
^./arena-map.r3
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
	
#script
#script>
#scrstate
#term * 8192
#term> 'term 

:teclr	'term 'term> ! ;
:,te 	term> c!+ 'term> ! ;

:loadlevel | "" --
	here dup 'script ! dup 'script> !
	swap load 
	0 swap c!+ 'here ! 
	0 'scrstate	!
	teclr
	;

|----
#speed 
#inwait

:dighex | c --  dig / -1 | :;<=>?@ ... Z[\]^_' ... 3456789
	$3A <? ( $30 - ; ) tolow $57 - ;

:copysrc
	>>cr 2 +
	fuente >a
	( c@+ $25 <>?
		10 <>? ( dup ca!+ ) drop
		) drop
	0 ca!+
	edset
	>>cr ;
	
:incode
	'xedit 16 -500 26 0.5 0.0 +vanim
	;
	
:outcode
	'xedit -500 16 25 0.5 0.0 +vanim
	;
	
:inmap
|	'viewpz 2.0 0.0 26 0.5 0.0 +vanim 
	'viewpx 
	SW viewpz mapw 16 * *. - 32 -
	1400 26 0.5 0.0 +vanim 
	;
	
:outmap
|	'viewpz 0.0 2.0 25 0.5 0.0 +vanim 
	'viewpx 1400 
	SW viewpz mapw 16 * *. - 32 -
	25 0.5 0.0 +vanim 
	;
	
:endless	
	outcode
	outmap
	'exit 2.0 +vexe
	;
	
#anilist 'incode 'outcode 'inmap 'outmap
	
:anima
	c@+ dighex
	$3 and 3 << 'anilist + @ ex
	>>cr
	;
	
:waitn	
	1 'inwait ! 1 'state ! ;
	
:cntr | script -- 'script
	c@+
|	$25 =? ( ,te ; ) | %%
	$63 =? ( drop 12 ,te c@+ dighex ,te ; )	| %c1 color
	$2e =? ( drop teclr trim ; )	| %. clear
	$61 =? ( drop anima ; )			| %a1 animacion	
	$65 =? ( drop endless ; ) 		| %e end
	$69 =? ( drop 11 ,te ; )		| %i invert
	$73 =? ( drop copysrc trim ; ) 	| %s..%s source
	$77 =? ( drop >>sp waitn ; )	| %w1 espera
	
	,te
	;
	
:+t
	$2c =? ( 0.4 'speed ! )	|,
	$2e =? ( 0.8 'speed ! ) |.
	$25 =? ( drop cntr ; )	|%
	13 <? ( drop ; ) 
	,te 
	;
	
:addscript
	0.05 'speed !
	script> c@+ +t 'script> !
	
	inwait 1? ( drop ; ) drop
	'addscript speed +vexe
	;

:nextn
	0 'inwait ! 0 'state ! teclr addscript ;
	
:complete
	( inwait 0? drop
		script> c@+ +t 'script> ! ) drop ;
	
|----	
#inv 0
:te
	11 =? ( drop $80 inv xor 'inv ! ; )
	12 =? ( drop c@+ tcol ; ) 
	13 =? ( drop tcr tsp tsp ; )
	inv or
	temit ;
	
:cursor	
	msec $100 nand? ( drop ; ) drop $a0 temit ;
	
:nextlesson
	1200 200 'nextn " Next" $3f3f00 btnt
	;
		
:runscript
	2.0 tsize
	scrstate 
	|0 =? ( drop scrterm ; ) | terminal
	|1 =? ( waitexec )
	| espera por run
	| espera por resultado
	drop
	
	$7f3f3f3f sdlcolorA	
	8 32 sw 16 - 14 16 * sdlFRect
	3 tcol 0 'inv !
	2 3 txy 'term ( term> <? c@+ te ) drop
	inwait 1? ( drop nextlesson ; ) drop
	cursor
	1100 200 'complete "   >>" $3f00 btnt
	;

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
	$7f00007f sdlcolorA	xedit yedit wedit hedit sdlFRect
	
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
	clearmark
	resetplayer

	vmtokreset
	fuente 'cdtok vmtokenizer 'cdtok> ! 
	0 cdtok> !
	cdtok> 'cdtok - 3 >> 'cdcnt !
	
	|vmdicc | ** DEBUG
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
	|1? ( dup vm2src 'fuente> ! )
	dup vm2src 'fuente> ! 
	'cdnow> !
	vmreset
	'stepvma cdspeed +vexe
	;
	
	
:step
	state 2 =? ( drop ; ) drop | stop?
	state 1 =? ( compilar ) drop | **
	state 2 <>? ( drop ; ) drop	
	stepvma ;
	
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
	660 110 16 sdlfrect
	6 tcol
	xedit wedit + 2 +
	660 tat " Stack" temits
	vmdeep 0? ( drop ; ) 
	3.0 tsize 633 'sty ! $3f3f00 sdlcolor
	stack 8 +
	( swap 1- 1? swap
		@+ cellstack
		) 2drop 
	TOS cellstack ;
	
:botones
	4 tcol
	SH 32 -
	8 over 'play "F1:Play" $3f00 btnt
	148 over 'step "F2:Step" $3f00 btnt
	288 over 'help "F3:Help" $3f3f btnt
	428 over 'exit "ESC:Bye" $3f0000 btnt	
|	600 over tat state "%d" tprint
	drop
	;
	
|-------------------
:jugar
	vupdate
	gui
	mouseview
	0 sdlcls

	3.0 tsize
	12 4 tat $5 tcol "Ar3na" temits $3 tcol "Code" temits tcr
	
	draw.map
	draw.player
	draw.items
	
	draw.code

	runscript
	
	botones
	sdlredraw
	sdlkey
	>esc< =? ( exit )
	<f1> =? ( play )
	<f2> =? ( step ) 
	<f3> =? ( help ) 
	drop ;
	
:juega
	mark
	"r3/r3vm/levels/level0.txt" loadmap
	clearmark
	resetplayer
	
	1 'state !
	inmap incode
	'jugar SDLshow
	empty
	;

:tutor1
	mark
	"r3/r3vm/levels/level0.txt" loadmap
	"r3/r3vm/levels/tuto.txt" loadlevel	
	clearmark
	resetplayer
	0 'state !
	inmap -500 'xedit !
	'addscript 2.0 +vexe
	'jugar SDLshow
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
	32 200 'juega "Free Play"  $3f00 btnt2
	32 500 'options "Options" $3f btnt2
	32 600 'exit "Exit" $3f0000 btnt2
	
	sdlredraw
	sdlkey
	>esc< =? ( exit )
	<f1> =? ( juega )
	<f2> =? ( options ) 
	drop ;
	
|-------------------
: |<<< BOOT <<<
	"Ar3na:Code" 1366 768 SDLinit
	SDLblend
	2.0 8 8 "media/img/atascii.png" tfnt 
	64 vaini
	
| editor
	16 300 480 360 edwin
	edram

	
	bot.ini
	bot.reset
	'cdtok 8 vmcpu 'cpu ! | 8 variables

	|"r3/r3vm/code/test.r3" edload | "" --

	|juega
	|tutor1
	'menu sdlshow
	
	SDLquit 
	;
