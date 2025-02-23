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

|----------- marcas
| y|x|ini|cnt|colorf|colorb
| ttco1co2wwhhxxyy
| 8(t)12(col1)12(col2)8(w)8(h)8(x)8(y)
#marcas * $ff | 32 marcadores
#marcas> 'marcas

#vard * 1024

::clearmark	'marcas 'marcas> ! ;

::addmark	marcas> !+ 'marcas> ! ;

::addsrcmark | src color --
	32 << swap
	dup >>sp over - 24 << 
	swap src2pos
	ycursor or 
	xcursor 8 << or 
	$010000 or	| h
	or addmark ;

:linemark | mark --
	dup $ff and ylinea -
	-? ( 2drop ; ) hcode >=? ( 2drop ; ) | fuera de pantalla
	over >a
	advy * yedit +   | y real
	over 8 >> $ff and 
	lnsize + advx * xedit +  | x real
	swap rot | x y vv
	dup 24 >> $ff and advx * | w
	swap 16 >> $ff and advy * | h
	pick3 1- pick3 1- pick3 2 + pick3 2 +
	a> 32 >> 4bcol sdlcolor sdlRect
	a> 48 >> 4bcol sdlcolor sdlFRect
	;

:showmark
	ab[ 'marcas ( marcas> <? @+ linemark ) drop ]ba ;

|------------------
::varplace | src -- val
	src2pos
	ycursor  
	xcursor 8 << or 
	;

	
:buildvars
	ab[
	'vard >a
	data >b
	code 8 - @ 32 >> 3 >>
	( 1? 1-
		b@+ varplace 
		dup "%h" .println
		a!+ 
		) a!		 
	]ba ;

:linevar
	dup $ff and ylinea -
	-? ( 2drop ; ) hcode >=? ( 2drop ; ) | fuera de pantalla
	over >a
	advy * yedit +   | y real
	over 8 >> $ff and 
	lnsize + advx * xedit +  | x real
	
	swap rot tat 
	"tt" tprint
	2drop
	;
	
:showvars
	data >a 'vard ( @+ 1? linevar ) 2drop 
	;

		
|------------	
#cpu
#state | 0 - view | 1 - edit | 2 - run | 3 - error
#cdspeed 0.2

:stepvm
	ip 0? ( drop ; ) 
	|vmstepck 
	vmstep
	1? ( dup vm2src 'fuente> ! )
	'ip !
	;
	
:stepvma
	ip 0? ( drop ; ) 
	vmstepck 
	|vmstep
	terror 1 >? ( 2drop 
		3 'state ! 
		clearmark
		fuente> $f00ffff addsrcmark 
		; ) drop
	|cdtok> >=? ( drop 0 ) | fuera de codigo
	0? ( 'ip ! 1 'state ! ; ) | fin
	dup vm2src 'fuente> ! 
	'ip !
	'stepvma cdspeed +vexe 
	;

:stepvmas
	ip 0? ( drop ; ) 
	vmstepck 
	|vmstep
	terror 1 >? ( 2drop 
		3 'state ! 
		clearmark
		fuente> $f00ffff addsrcmark 
		; ) drop
|	cdtok> >=? ( drop 0 ) | fuera de codigo
	0? ( 'ip ! 1 'state ! ; ) | fin
	dup vm2src 'fuente> ! 
	'ip !
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
	
	fuente> $007ffff addsrcmark | ip
	RTOS ( @+ 1? 				| rstack
		8 - @ vmcode2src $0070000 addsrcmark 
		) 2drop
	showmark
	showvars	
	
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
	
#serror
#code1
#cpu1
	
|-----------------------
:compilar
	empty mark 
	fuente vmcompile | serror terror
	
|	vmdicc | ** DEBUG
|	cdcnt 'cdtok vmcheckjmp

	 1 >? ( 'terror !
		'fuente> ! | serror
		3 'state !
		clearmark
		fuente> $700ffff addsrcmark 
		0 'cpu1 !
		; ) 2drop

	2 'state ! 
	vmcpu 'cpu1 !
	
	buildvars
	
	;

:play
	state 2 =? ( drop ; ) drop
	compilar
	state 2 <>? ( drop ; ) drop
	ip vm2src 'fuente> ! 
	resetplayer
	'stepvma cdspeed +vexe
	;	
	
:step
	state 2 =? ( drop stepvmas ; ) drop | stop?
	resetplayer 
	compilar	
	ip vm2src 'fuente> ! 
	resetplayer
	;
	
:help
	;
	
|------------ STACK
#sty 

:cellstack | cell --
	vmcellcol 
	tpal $00000 col50% | obscure
	sdlcolor 
	xedit wedit + 2 +
	sty 2 - 
	112 28 sdlfrect
	xedit wedit + 2 +
	sty tat vmcell temits
	-30 'sty +!
	;
	
#statevec 'showread 'showeditor 'showruning 'showerror 

:draw.code
	2.0 tsize
	state 3 << 'statevec + @ ex
|-- show stack
	cpu1 0? ( drop ; ) drop
	xedit -? ( drop ; ) | not show without editor
	wedit + 2 + 
	yedit hedit + 
	110 16 sdlfrect
	6 tcol
	xedit wedit + 2 +
	yedit hedit + 
	tat " Stack" temits
	vmdeep 0? ( drop ; ) 
	yedit hedit + 27 - 'sty ! 
	stack 16 +
	( swap 1- 1? swap
		@+ cellstack
		) 2drop 
	TOS cellstack ;

|---- VIEW script
#xterm #yterm #wterm #hterm

:termwin
	'hterm ! 'wterm ! 'yterm ! 'xterm ! ;
	
#inv 0
#tcx
#tcy

:te
	11 =? ( drop $80 inv xor 'inv ! ; )
	12 =? ( drop c@+ tcol ; ) 
	13 =? ( drop 16 'tcy +! tcx tcy tat ; )
	inv or temit ;
	
:cursor	
	msec $100 nand? ( drop ; ) drop $a0 temit ;
	
:nextlesson
	1200 160 'nextchapter " Next" $3f3f00 btnt ;
		
:draw.script
	sstate -? ( drop ; ) drop
	$7f3f3f3f sdlcolorA	
	xterm yterm wterm hterm 
	|8 32 sw 16 - 14 16 * 
	sdlFRect
	2.0 tsize 3 tcol 0 'inv !
	xterm 8 + 'tcx ! yterm 8 + 'tcy !
	|2 1 txy 
	tcx tcy tat
	
	'term ( term> <? c@+ te ) drop
	sstate 1? ( drop nextlesson ; ) drop
	cursor
	1100 160 'completechapter "   >>" $3f00 btnt
	;
	

|-------------------	
:botones
	4 tcol 
	3.0 tsize
	SH 32 -
	12 over tat $5 tcol "Ar3na" temits 
	$3 tcol "Code" temits 
	2.0 tsize
	308 over 'play "F1:Play" $3f00 btnt
	448 over 'step "F2:Step" $3f00 btnt
	588 over 'help "F3:Help" $3f3f btnt
	728 over 'exit "ESC:Exit" $3f0000 btnt	
|	600 over tat state "%d" tprint
	drop
	;
	
:jugar
	vupdate
	gui 0 sdlcls

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
	drop 
	;
	
:freeplay
	mark
	0.4 %w 0.02 %h 0.58 %w 0.25 %h termwin
	16 48 480 654 edwin	
	
	"r3/r3vm/levels/level1.txt" loadlevel	
	0.4 %w 0.24 %h 0.58 %w 0.74 %h mapwin
		
	"r3/r3vm/code/test0.r3" edload 
	resetplayer
	map.step
	1 'state ! 0 'code1 ! 0 'cpu1 !
	
	mark
	'jugar SDLshow
	empty
	
	vareset
	empty
	;

:tutor1
	mark
	0.01 %w 0.02 %h 0.98 %w 0.25 %h termwin
	16 262 480 440 edwin	
	
	"r3/r3vm/levels/tutor0.txt" loadlevel
	0.4 %w 0.24 %h 0.58 %w 0.74 %h mapwin
	
	resetplayer
	map.step
	1 'state ! 0 'code1 ! 0 'cpu1 !
	
	mark	
	'jugar SDLshow
	empty
	
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

	'menu sdlshow
	
	SDLquit 
	;
