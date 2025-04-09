| ar3na tank 
| PHREDA 2025
|-------------------------
^r3/lib/gui.r3
^r3/lib/3d.r3
^r3/lib/rand.r3

^r3/util/varanim.r3
^r3/util/ttext.r3


^./arena-edit.r3
^./tedit.r3
^./rcodevm.r3

#codepath "r3/r3vm/codecube/"

|---------------------------------------------

#xcam 0 #ycam 0 #zcam -40.0
#xr 0 #yr 0

:freelook
	sdlb 0? ( drop ; ) drop
	SDLx SDLy
	sh 1 >> - 7 << swap
	sw 1 >> - neg 7 << swap
	neg 'xr ! 'yr ! ;


#paleta [ | uchu
$080a0d $0949ac $b56227 $2e943a
$542690 $a30d30 $fdfdfd $b59944
$878a8b $3984f2 $ff9f5b $64d970
$915ad3 $ea3c65 $cbcdcd $fedf7b ]

#goal * 1024 | 9 * 9 * 9 = 729
#prog * 1024

#desx
#desy

:drawv | x y z --
	cb@+ $f and 
	0? ( drop ; )
	2 << 'paleta + d@ sdlcolor
	pick2 pick2 pick2 project3d 
	swap desx + swap desy +
	5 5 SDLFrect
	;

:drawcube | desx desy mem --
	>b
	'desy ! 'desx !
	-4.0 ( 4.0 <=?
		-4.0 ( 4.0 <=?
			-4.0 ( 4.0 <=?
				drawv
			1.0 + ) drop
		1.0 + ) drop
	1.0 + ) drop	
	;
	
:drawvox
	freelook
	
	|... voxels
	1.0 3dmode
	xr mrotx yr mroty 
	xcam ycam zcam mtrans

	200 -140 'goal drawcube
	200 100 'prog drawcube
	
	|... paleta
	0 ( 15 <?
		dup 2 << 'paleta + d@ sdlcolor
		dup 5 << 500 + 560 32 32 sdlfrect
		1+ ) drop	
	;
	

:fillgoal
	'goal >a 729 ( 1? rand 8 >> ca!+ 1- ) drop 
	'prog >a 729 ( 1? rand 8 >> ca!+ 1- ) drop 
	;
	
|---------------------------------------------
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
	
|--------------------------------------------
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
	state 2 =? ( drop vareset ; ) drop
	compilar
	state 2 <>? ( drop ; ) drop
	ip vm2src 'fuente> ! 
|	reset.map
	'stepvma 0.1 +vexe
	;	
	
:step
	state 2 =? ( drop stepvmas ; ) drop | stop?
	compilar	
	ip vm2src 'fuente> ! 
|	reset.map
	;
	
|-------------------
:runscr
	vupdate gui	0 sdlcls
	
	|terreno
	|viewmap
	
	0 0 tat $5 tcol "Cube" temits $3 tcol " Code" temits 
	|$ffffff bcolor viewpz viewpy viewpx "%d %d %f" bprint2

	draw.code	

	drawvox
	
	sdlredraw
	sdlkey
	>esc< =? ( exit )

	|----
	<f1> =? ( play )
	<f2> =? ( step ) 
	<f3> =? ( fillgoal )
	drop ;

:game
	mark
	0 32 440 540 edwin	
	
|	"r3/r3vm/levels/level0.txt" loadlevel	
|	0.4 %w 0.24 %h 0.58 %w 0.74 %h mapwin
		
|	reset.map
	1 'state ! 0 'code1 ! 0 'cpu1 !

	|"-- go --" infoshow
	mark
	'runscr SDLshow
	empty
	
	vareset
	empty
	
	;
	
|-------------------
: |<<< BOOT <<<
	"arena tank" 1024 600 SDLinit
	SDLblend
	2.0 8 8 "media/img/atascii.png" tfnt 
	64 vaini
	edram	| editor
	|"media/ttf/roboto-bold.ttf" 20 TTF_OpenFont immSDL
	
	|'menu sdlshow
	game
		
	SDLquit 
	;
