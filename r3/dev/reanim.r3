| reanimator
| PHREDA 2024
|-------------------------
^r3/lib/rand.r3
^r3/util/arr16.r3
^r3/win/sdl2gfx.r3
^r3/util/sdlbgui.r3


| sprite
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

:drawspr | arr -- arr
	dup 8 + >a
	a@+ int. a@+ int. | x y
	a@+ dup 32 >> swap $ffffffff and | rot zoom
	a@ timer+ dup a!+ anim>n 			| n
	a@+ sspriterz
	;
	
	
|-------------------
:main
	timer.
	immgui 
	0 sdlcls

	$696969 sdlcolor
	0 0 sw 32 sdlfrect
	$ffffff sdlcolor
	0 32 64 sh 32 - sdlrect
	sw 64 - 32 64 sh 32 - sdlrect
	0 sh 128 - sw 128 sdlrect
	
	$ffff bcolor
	0 0 bat " ReAnimator" bprint2 
	
	64 64 bat
	sdlw "%d" bprint
	
	sdlredraw
	sdlkey
	>esc< =? ( exit )
	drop ;
	
:reset
	timer<
	;
	
|-------------------
: |<<< BOOT <<<
	"reAnimator" 1024 600 SDLinit
	bfont1
	reset
	'main SDLshow
	SDLquit 
	;