| ar3na tank
| PHREDA 2025
|
| varios tanques, cada uno con su cpu, ejecutan el mismo script
|  F1 play/stop   F2 step (1 tick)   F5 agrega un tanque   ESC salir
|-------------------------
^r3/lib/gui.r3
^r3/util/varanim.r3
^r3/util/ttext.r3

^./arena-tank.r3
^./arena-edit.r3

^./tedit.r3
^./rcodevm.r3

#codefile "r3/r3vm/codetank/tank1.r3"

|---------
:btnt2 | x y v "" col --
	pick4 pick4 256 48 guiBox
	[ dup 2* or ; ] guiI color
	[ 2swap 2 + swap 2 + swap 2swap ; ] guiI
	2over 256 48 frect
	2swap 8 + swap 8 + swap tat
	$e tcol temits
	onClick ;

|-----------------------
#paused

:newtanks | --		; mismo script, distintas posiciones
	tk.reset
	0.25 -170.0 -60.0 tk.+tank
	0.75 150.0 80.0 tk.+tank ;

:compilar
	0 'tkrun !
	empty mark
	fuente vmcompile | serror terror
	1 >? ( 'terror !
		'fuente> !
		3 'state !
		clearmark
		fuente> $700ffff addsrcmark
		; ) 2drop
	0 'terror !
	buildvars
	newtanks
	2 'state ! ;

:showsel | --		; el editor muestra el cpu del tanque 0
	0 tk.sel
	ip 0? ( drop ; ) vm2src 'fuente> ! ;

:tkcheck | --		; error en el script de un tanque?
	tkrun 3 <>? ( drop ; ) drop
	3 'state !
	clearmark
	tkerr $f00ffff addsrcmark ;

:stop
	1 'state ! 0 'tkrun ! ;

:play
	state 2 =? ( drop stop ; ) drop
	compilar
	state 2 =? ( 0 'paused ! ) drop ;

:step
	state 2 =? ( drop 1 'paused ! tk.tick tkcheck ; ) drop
	compilar
	state 2 =? ( 1 'paused ! ) drop ;

:addtank | --
	state 2 <>? ( drop ; ) drop
	1.0 randmax 400.0 randmax 200.0 - 400.0 randmax 200.0 - tk.+tank ;

|-------------------
:hud
	8 584 tat 1.0 tsize 6 tcol "F1:Play/Stop  F2:Step  F5:+Tank  ESC:Exit" temits
	tkrun 2 <>? ( drop ; ) drop
	4.0 tsize 7 tcol
	tkpx 140 - tkpy 16 - tat
	tkwin -? ( drop "DRAW" temits ; )
	1+ "TANK %d WINS" tprint ;

:runscr
	vupdate gui 0 cls

	0 0 tat 2.0 tsize $5 tcol "Ar3na" temits $3 tcol "Tank" temits

	state 2 =? ( paused 0? ( tk.update ) drop tkcheck ) drop
	tk.draw
	state 2 =? ( showsel ) drop
	draw.code
	hud

	sdlredraw
	sdlkey
	>esc< =? ( exit )
	<f1> =? ( play )
	<f2> =? ( step )
	<f5> =? ( addtank )
	drop ;

:game
	mark
	0 32 440 540 edwin
	'codefile edload
	1 'state !
	mark
	'runscr SDLshow
	empty
	vareset
	empty ;

|-------------------------------------
:menu
	vupdate gui 0 0 sw sh guiRect 0 cls

	6.0 tsize
	12 4 tat $5 tcol "Ar3na" temits $3 tcol "Tank" temits tcr

	3.0 tsize
	32 200 'game "Game"  $3f00 btnt2
	32 600 'exit "Exit" $3f0000 btnt2

	sdlredraw
	sdlkey
	>esc< =? ( exit )
	<f1> =? ( game )
	drop ;

|-------------------
: |<<< BOOT <<<
	"arena tank" 1024 600 SDLinit
	SDLblend
	2.0 8 8 "media/img/atascii.png" tfnt
	64 vaini
	edram	| editor
	tk.ini
	730 'tkpx ! 300 'tkpy !
	game
	SDLquit
	;
