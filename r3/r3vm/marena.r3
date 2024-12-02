| matrix arena
| PHREDA 2021-2024 (r3)
|-------------------------

^r3/lib/rand.r3
^r3/util/arr16.r3
^r3/lib/sdl2gfx.r3
^r3/util/sdlbgui.r3

^r3/r3vm/r3ivm.r3
^r3/r3vm/r3itok.r3
^r3/r3vm/r3iprint.r3

#cpuplayer

#imgspr
#fx 0 0 

#level0 (
17 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17
17  0  0  0  0  0  0  0  0  0  0  0  0  0  0 17
17  0  0  0  0  0  0  0  0  0  0  0  0  0  0 17
17  0  0  0  0  0  0  5  0  0  6  0  0  7  0 17
17  0  0  0  0  0  0  0  0  0  0  0  0  0  0 17
17  0  0  0  0  0  0  0  0  0  0  0  0  0  0 17
17  0  0  0  0  0  0  0  0  0  0  0  0  0  0 17
17  0  0  0  0  0  0  0  0  0  0  0  0  0  0 17
17  0  0  0  0  4  0  0  0  0  0  0  0  0  0 17
17  0  0  0  0  0  0  0  0  0  0  0  0  0  0 17
17  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0
03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03
)

#mrot 0.0
#tzoom 2.0
#tsize 16 
#tmul

#mvx 8 #mvy 64
#mw 16 #mh 12
#marena * 8192

:calc tsize tzoom *. 'tmul ! ;

:postile | y x -- y x xs ys
	dup tmul * mvx +
	pick2 tmul * mvy +
	;
	
:posspr | x y -- xs ys
	swap tmul * mvx + tmul 2/ +
	swap tmul * mvy + tmul 2/ +
	;
	
:drawtile
	|$ffffff sdlcolor postile tmul dup sdlRect
	a@+ $ff and 0? ( drop ; ) >r
	2dup swap posspr tzoom r> 1- imgspr sspritez
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
	
:cpylevel | 'l --
	>b
	'marena >a
	mw mh * ( 1?
		cb@+ a!+
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

|----------	
#xp 1 #yp 1 | position
#dp 0	| direction
#ap 0 	| anima
#penergy
#pcarry

:player
	xp yp posspr
	tzoom
	dp 2* 7 +
	msec 7 >> $1 and +
	imgspr sspritez
	;
	
:istep | step --
	;
:iturn | a --
	;
:iscan | -- n
	;
:iget | --
	4 vmpush ;
:iput | --
	3 vmpush
	;
:ibye
	exit ;
	
|#wsys "BYE" "shoot" "turn" "adv" "stop"
#wsysdic $23EA6 $34A70C35 $D76CEF $22977 $D35C31 0
#xsys 'ibye 'istep 'iturn 'iscan 'iget 'iput 0	

:inicpu
	'wsysdic syswor!
	'xsys vecsys!
	$fff vmcpu 'cpuplayer !
	;

|-------------------------------	
#pad * 256

#lerror

:immex	
	r3reset
	'pad r3i2token drop 'lerror !
	0 'pad !
	refreshfoco
	code> ( icode> <? 
	| vmcheck
		vmstep ) drop
	;

	
:mconsole	
	8 500 immat
	1000 32 immbox
	'pad 128 immInputLine2
	
	||$ffffff ttcolor
	8 532 bat
	"< " bprint2
	vmdeep 0? ( drop ; ) 
	code 8 +
	( swap 1 - 1? swap
		@+ "%d " bprint2 
		) 2drop 
	TOS "%d " bprint2
	;
	
	
:debug	
	10 560 bat
	lerror 1? ( dup bprint ) drop
	|"err: %d" bprint
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
	debug

	sdlredraw
	sdlkey
	>esc< =? ( exit )
	<ret> =? ( immex )
	| ---- player control	
	<up> =? ( btnpad %1000 or 'btnpad ! 2 'dp ! -1 'yp +! )
	<dn> =? ( btnpad %100 or 'btnpad ! 3 'dp ! 1 'yp +! )
	<le> =? ( btnpad %10 or 'btnpad ! 1 'dp ! -1 'xp +! )
	<ri> =? ( btnpad %1 or 'btnpad ! 0 'dp ! 1 'xp +! )
	>up< =? ( btnpad %1000 nand 'btnpad ! )
	>dn< =? ( btnpad %100 nand 'btnpad ! )
	>le< =? ( btnpad %10 nand 'btnpad ! )
	>ri< =? ( btnpad %1 nand 'btnpad ! )
	<esp> =? ( btnpad $10 or 'btnpad ! )
	drop ;

:reset
	'fx p.clear
	;
	
	
|-------------------
: |<<< BOOT <<<
	"r3 marena" 1024 600 SDLinit
	bfont1
	
	tsize dup "r3/r3vm/img/rcode.png" ssload 'imgspr !
	calc
	400 'fx p.ini
	reset
	
	inicpu
	
	|buildmap
	'level0 cpylevel
	
	'runscr SDLshow
	SDLquit 
	;
