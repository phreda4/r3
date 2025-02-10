| ar3na bot 
| PHREDA 2025
|-------------------------
^r3/lib/gui.r3
^r3/util/varanim.r3
^r3/util/ttext.r3

^./tedit.r3
^./arena-map.r3
^./rcodevm.r3

#script
#script>
#scrstate
#term * 8192
#term> 'term 

:teclr	'term 'term> ! ;
:,te 	term> c!+ 'term> ! ;

:dialogo
	;
	
:loadlevel | "" --
|	"loading tutor..." plog
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
		12 >? ( dup ca!+ ) drop
		) drop
	0 ca!+
	fuente 'fuente> !
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
	
:waitn	
	1 'inwait !
	;

:cntr | script -- 'script
	c@+
|	$25 =? ( ,te ; ) | %%
	$63 =? ( drop 12 ,te c@+ dighex ,te ; )	| %c1 color
	$2e =? ( drop teclr trim ; )			| %. clear
	$69 =? ( drop 11 ,te ; )				| %i invert
	$73 =? ( drop copysrc trim ; ) 		| %s..%s source
	$77 =? ( drop >>sp waitn ; ) | %w1 espera
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
	
|----	
#inv 0
:te
	11 =? ( drop $80 inv xor 'inv ! ; )
	12 =? ( drop c@+ tcol ; ) 
	13 =? ( drop tcr tsp tsp ; )
	inv or
	temit ;
	
:runscript
	
	scrstate 
	|0 =? ( drop scrterm ; ) | terminal
	|1 =? ( waitexec )
	| espera por run
	| espera por resultado
	drop
	
	$7f3f3f3f sdlcolorA	
	8 32 sw 16 - 14 16 * sdlFRect
	3 tcol 0 'inv !
	2 2 txy 
	'term ( term> <? c@+ te ) drop
	msec $100 nand? ( drop ; ) drop
	$a0 temit
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
		2 'state ! 
		clearmark
		fuente> $f00ffff addsrcmark 
		; ) drop
	
	1? ( dup vm2src 'fuente> ! 'stepvma cdspeed +vexe )
	0? ( dup 'state ! ) 
	'cdnow> !
	;
	
|-----------------------
:showread
	$003f00 sdlcolor xedit yedit 16 - wedit 16 SDLFrect
	$ffffff trgb xedit yedit 16 - tat "    CODE:" tprint
	$7f00003f sdlcolorA	
	xedit yedit wedit hedit sdlFRect
|	edfocus
	edcodedraw
	;

:showeditor
	$003f00 sdlcolor xedit yedit 16 - wedit 16 SDLFrect
	$ffffff trgb xedit yedit 16 - tat "    CODE: EDIT" tprint
	$7f00007f sdlcolorA	
	xedit yedit wedit hedit sdlFRect
	edfocus
	edcodedraw
	;	
	
:showruning
	$003f3f sdlcolor xedit yedit 16 - wedit 16 SDLFrect
	$ffffff trgb xedit yedit 16 - tat "    CODE: RUN" tprint
	$7f00007f sdlcolorA
	xedit yedit wedit hedit sdlFRect
	
	clearmark
	fuente> $00fffff addsrcmark
	RTOS ( @+ 1?
		8 - @ vmcode2src $00f0000 addsrcmark
		) 2drop
	showmark
	edcodedraw
	;	

:showerror
	$3f0000 sdlcolor xedit yedit 16 - wedit 16 SDLFrect
	$ffffff trgb xedit yedit 16 - tat "    CODE: " tprint vmerror tprint
	$7f00007f sdlcolorA
	xedit yedit wedit hedit sdlFRect

	showmark
	
	edfocus
	edcodedraw
	;
	
|-----------------------
:editcompilar
	clearmark
	resetplayer

	vmtokreset
	fuente 'cdtok vmtokenizer 'cdtok> ! 
	0 cdtok> !
	cdtok> 'cdtok - 3 >> 'cdcnt !
	
|	vmdicc | ** DEBUG
|processlevel
	terror 1 >? ( drop 
		2 'state ! 
		serror 'fuente> ! 
		clearmark
		fuente> $f00ffff addsrcmark 
		; ) drop

	1 'state ! 
	vmboot 
	1? ( dup vm2src 'fuente> ! )
	dup vm2src 'fuente> ! 
	'cdnow> !
	'stepvma cdspeed +vexe
	;

:showstack
	8 532 tat
	" " tprint
	vmdeep 0? ( drop ; ) 
	stack 8 +
	( swap 1 - 1? swap
		@+ vmcell temits tsp
		) 2drop 
	TOS vmcell temits tsp
	;
	
	
:draw.code
|	showcode
	
	
	state 
	0? ( showread )
	1 =? ( showeditor )
	2 =? ( showruning )
	3 =? ( showerror ) 
	drop
	
	showstack
	;
	

:btnimg | x y n "" --
	2over 128 24 guiBox
	$7f00 [ $7f007f or ; ] guiI sdlcolor
	2over 128 24 sdlfrect
	2swap 4 + swap 4 + swap tat
	$e tcol
	temits
	|2.0 swap |'1+ guiI 
	onClick 
	;
	
:botones
	4 tcol
	SH 32 -
	8 over 'exit "F1:Play" btnimg
	148 over 'exit "F2:Step" btnimg
	288 over 'exit "F3:Help" btnimg
	428 over 'exit "ESC:Bye" btnimg	
	drop
	;
	
|-------------------
:jugar
	vupdate
	gui
	mouseview
	0 sdlcls

	3.0 tsize
	$5 tcol 4 4 tat " Ar3na" temits $3 tcol "Code" temits tcr
	
	draw.map
	draw.player
	draw.items
	
	2.0 tsize	
	|edtoolbar
	draw.code

	runscript
	|showterm
	
	botones
	sdlredraw
	sdlkey
	>esc< =? ( exit )
	<f1> =? ( editcompilar )
	<f2> =? ( addscript ) 
|	<f3> =? ( "test" plog )
	<f4> =? ( incode inmap )
	<f5> =? ( outcode outmap )
	drop ;
	
:juega
	0 'state !
	'jugar SDLshow
	;
		
|-------------------
:configura	
	;
	
:menu
	vupdate
	gui
	0 sdlcls
	
	sdlredraw
	sdlkey
	>esc< =? ( exit )
	<f1> =? ( juega )
	<f2> =? ( configura ) 
	drop ;
	
|-------------------
: |<<< BOOT <<<
	"arena tank" 1366 768 SDLinit
	SDLblend
	2.0 8 8 "media/img/atascii.png" tfnt 

|	"media/ttf/Roboto-Medium.ttf" 30 TTF_OpenFont 'font !		
		
	64 vaini
	
| editor
	16 300 480 360 edwin
	edram
	
	bot.ini
	bot.reset
	'cdtok 8 vmcpu 'cpu ! | 8 variables

	|"r3/r3vm/code/test.r3" edload | "" --
	
	"r3/r3vm/levels/level0.txt" loadmap
	
	"r3/r3vm/levels/tuto.txt" loadlevel	

	juega
	SDLquit 
	;
