^r3/win/console.r3
^r3/win/sdl2gfx.r3

#prevt
#dtime

:timeI msec 'prevt ! 0 'dtime ! ;
:time. msec dup prevt - 'dtime ! 'prevt ! ;
:time+ dtime + $ffffffff7fffffff and ;

#vanim1
#vanim2

| inicio(16) cnt(8) escala(8) time(32)
|                      
:aICS | init cnt scale -- val
	32 << swap 40 << or swap 48 << or ;
	
:animaN | ani -- t
	dup |$ffffffff and
	dup 32 >> $ff and * $ffff and
	over 40 >> $ff and 16 *>>
	swap 48 >>> +
	;
	
:main
	0 SDLcls
	
	time.
	
	

	$ff sdlcolor
	vanim1 time+ dup 'vanim1 !
	animaN 
	5 << 40 40 40 sdlfrect

	$ffff sdlcolor
	vanim2 time+ dup 'vanim2 !
	animaN 
	5 << 80 40 40 sdlfrect
	
	SDLredraw
	
	SDLkey
	>esc< =? ( exit )
	drop ;
;

: 
	"r3sdl" 800 600 SDLinit
	timeI
	1 10 64 aICS 'vanim1 ! | ini cnt speed
	1 10 32 aICS 'vanim2 !
	'main SDLshow 
	SDLquit
	;