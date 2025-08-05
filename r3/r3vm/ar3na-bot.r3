| ar3na bot 
| PHREDA 2025
|-------------------------
^r3/lib/gui.r3
^r3/util/varanim.r3
^r3/util/ttext.r3

^./arena-map.r3
^./arena-edit.r3
^./arena-term.r3

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
	0 'terror !
	buildvars
	;

:play
	state 2 =? ( drop vareset ; ) drop
	compilar
	state 2 <>? ( drop ; ) drop
	ip vm2src 'fuente> ! 
	reset.map
	'stepvma 0.1 +vexe
	;	
	
:step
	state 2 =? ( drop stepvmas ; ) drop | stop?
	compilar	
	ip vm2src 'fuente> ! 
	reset.map
	;
	
:help
	;
	


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
#infx 100
#infy 100
#padx 0
#infs 0

:cartelinfo
	state $f0 nand? ( drop ; ) drop
	4.0 tsize 
	$c tcol
	infx infy 500 100 sdlfrect
	infx padx + infy 36 + tat
	infs temits
	;

:infoshow | sec "" --
	$10 'state !
	count 8 4 * * 500 swap - 2/ 'padx !
	'infs !
	sw 500 - 2/ 'infx !
	
	'infy 
	sh 2/ 50 -
	-100
	20 0.4 0 +vanim
	
	'infy
	-100	
	sh 2/ 50 -
	21 0.4 1.7 +vanim

	[ 1 'state ! ; ] 2.1 +vexe
	;
	
|---------- jugar
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
	gui 0 0 sw sh guiRect 0 sdlcls

	draw.map
	draw.code
	draw.script
	
	botones
	cartelinfo
	
	sdlredraw
	sdlkey
	>esc< =? ( exit )
	<f1> =? ( play )
	<f2> =? ( step ) 
	<f3> =? ( help ) 
	
	<f4> =? ( 2.0 700 300 "hola" +label ) 
	drop 
	;
	
|-----------------------
:freeplay
	mark
	0.4 %w 0.02 %h 0.58 %w 0.25 %h termwin
	16 48 480 654 edwin	
	
	"r3/r3vm/levels/level1.txt" loadlevel	
	0.4 %w 0.24 %h 0.58 %w 0.74 %h mapwin
		
	"r3/r3vm/code/test0.r3" edload 
	reset.map
	1 'state ! 0 'code1 ! 0 'cpu1 !

|	"-- go --" infoshow
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
	
	reset.map
	1 'state ! 0 'code1 ! 0 'cpu1 !
	
	mark	
	'jugar SDLshow
	empty
	
	vareset
	empty
	;


:game
	mark
	0.4 %w 0.02 %h 0.58 %w 0.25 %h termwin
	16 48 480 654 edwin	
	
	"r3/r3vm/levels/level0.txt" loadlevel	
	0.4 %w 0.24 %h 0.58 %w 0.74 %h mapwin
		
	|"r3/r3vm/code/test0.r3" edload 
	reset.map
	1 'state ! 0 'code1 ! 0 'cpu1 !

	|"-- go --" infoshow
	mark
	'jugar SDLshow
	empty
	
	vareset
	empty

	;
	
|------------------- MENU PRINCIPAL
:options	
	;
	
#cntmenu
#menu * 1024	
:levelmenu
	;
	
:menu
	vupdate gui 0 sdlcls
	
	|$7f3f3f3f sdlcolorA	200 200 200 600 sdlFRect
	
	6.0 tsize
	12 4 tat $5 tcol "Ar3na" temits $3 tcol "Code" temits tcr
	
	3.0 tsize	
	32 100 'tutor1 "Tutorial"  $3f00 btnt2
	32 200 'game "Game"  $3f00 btnt2
	32 300 'freeplay "Free Play"  $3f00 btnt2
	32 500 'options "Options" $3f btnt2
	32 600 'exit "Exit" $3f0000 btnt2
	
	sdlredraw
	sdlkey
	>esc< =? ( exit )
	<f1> =? ( freeplay )
	<f2> =? ( options ) 
	drop ;
	
|------------------- <<< BOOT <<<
: 
	"Ar3na:Code" 1366 768 SDLinit
	SDLblend
	2.0 8 8 "media/img/atascii.png" tfnt 
	64 vaini
	edram	| editor
	ini.map

	'menu sdlshow
	
	SDLquit 
	;
