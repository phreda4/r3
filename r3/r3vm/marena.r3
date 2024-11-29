| matrix arena
| PHREDA 2021-2024 (r3)
|-------------------------

^r3/lib/rand.r3
^r3/util/arr16.r3
^r3/lib/sdl2gfx.r3
^r3/util/sdlbgui.r3

#imgspr
#fx 0 0 


#mzoom 2.0
#mrot 0.0
#mcx 512 #mcy 300

#mvx 8 #mvy 64
#mw 16 #mh 12
#marena * 8192

:postile | y x -- y x xs ys
	dup 5 << mvx +
	pick2 5 << mvy +
	;
:posspr | y x -- y x xs ys
	dup 5 << mvx + 16 +
	pick2 5 << mvy + 16 +
	;
	
:drawtile
	|postile 64 dup sdlRect
	a@+ $ff and 0? ( drop ; ) >r
	posspr 2.0 r> 1- imgspr sspritez
	;
	
:mapdraw
	'marena >a
	0 ( mh <? 
		0 ( mw <? 
			drawtile
			1+ ) drop
		1+ ) drop ;

|--------------------------	
:buildmap
	'marena >a
	mw mh * ( 1?
		40 randmax 
		22 >? ( 0 nip )
		a!+
		1- ) drop ;
	
#btnpad

| tank
| x y ang anim ss vx vy ar io
| 1 2 3   4    5  6  7  8  9
:.x 1 ncell+ ;
:.y 2 ncell+ ;
:.a 3 ncell+ ;
:.ani 4 ncell+ ;
:.ss 5 ncell+ ;
:.vx 6 ncell+ ;
:.vy 7 ncell+ ;
:.end 8 ncell+ ;
:.io 9 ncell+ ;
:.color 10 ncell+ ;

:drawspr | arr -- arr
	dup 8 + >a
	a@+ int.
	a@+ int.
	a@+ dup 32 >> swap $ffffffff and | rot zoom
	a@ timer+ dup a!+ anim>n 			| n
	a@+ sspriterz
	;

|------------------- fx
:fxobj | adr --
	dup .ani @ anim>n 
	over .end @ 
	=? ( 2drop 0 ; ) drop 
	drawspr
	|..... add velocity to position
	dup .vx @ over .x +!
	dup .vy @ over .y +!
	drop
	;

:+fxobj | last ss anim zoom ang x y --
	'fxobj 'fx p!+ >a
	swap a!+ a!+	| x y 
	32 << or a!+	| ang zoom
	a!+ a!+			| anim sheet
	0 a!+ 0 a!+ 	| vx vy
	a!				| last
	;

#xp 600 #yp 300
#dp 0

:player
	xp yp 4.0
	dp 2* 7 +
	msec 7 >> $1 and +
	imgspr sspritez
	;
	
|----------	
#penergy
#pcarry

:istep | step --
	;
:iturn | a --
	;
:iup 
:idn
:ile
:iri
	;
:iscan | -- n
	;
:iget | --
	;
:iput | --
	;

	
|-------------------------------	
#pad * 256
	
:mconsole	
	8 500 immat
	1000 32 immbox
	'pad 128 immInputLine2
	;
	
|-------------------
:runscr
	timer.
	immgui
	$222222 sdlcls
	$ffff bcolor
	8 8 bat "MatArena" bprint2 

	mapdraw
	'fx p.draw
	player
	mconsole
	

	sdlredraw
	sdlkey
	>esc< =? ( exit )
	| ---- player control	
	<up> =? ( btnpad %1000 or 'btnpad ! 2 'dp ! )
	<dn> =? ( btnpad %100 or 'btnpad ! 3 'dp ! )
	<le> =? ( btnpad %10 or 'btnpad ! 1 'dp ! )
	<ri> =? ( btnpad %1 or 'btnpad ! 0 'dp ! )
	>up< =? ( btnpad %1000 nand 'btnpad ! )
	>dn< =? ( btnpad %100 nand 'btnpad ! )
	>le< =? ( btnpad %10 nand 'btnpad ! )
	>ri< =? ( btnpad %1 nand 'btnpad ! )
	<esp> =? ( btnpad $10 or 'btnpad ! )
	<f1> =? ( buildmap )
	drop ;

:reset
	'fx p.clear
	;
	
|-------------------
: |<<< BOOT <<<
	"r3 marena" 1024 600 SDLinit
	bfont1
	
	|"media/ttf/roboto-bold.ttf" 20 TTF_OpenFont immSDL
	16 16 "r3/r3vm/img/rcode.png" ssload 'imgspr !
	400 'fx p.ini
	reset
	buildmap
	'runscr SDLshow
	SDLquit 
	;
