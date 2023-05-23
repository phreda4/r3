| Animation example
| with multiple objects
^r3/lib/rand.r3
^r3/util/arr16.r3
^r3/win/sdl2gfx.r3

#spritesheet 0 0 0 | sprites
#people 0 0 | array

|.... time control
#prevt
#dtime

:timeI msec 'prevt ! 0 'dtime ! ;
:time. msec dup prevt - 'dtime ! 'prevt ! ;
:time+ dtime + $ffffff7fffffffff and  ;

| anima
| $fff ( 4k sprites) $ff (256 movs) $f (vel) ffffffffff (time)

:nanim | nanim -- n
	dup $ffffffffff and 
	over 40 >> $f and 48 + << 1 >>>
	over 44 >> $ff and 63 *>>
	swap 52 >>> + | ini
	;
	
:vni>anim | vel cnt ini -- nanim 
	$fff and 52 << swap
	$ff and 44 << or swap
	$f and 40 << or 
	;

|person
| x y ang anim ss vx vy ar
| 0 8 16  24   32 40 48 56
	
:person | v -- 
	dup >a
	a@+ int. a@+ int.	| x y
	a@+ dup 32 >> swap $ffffffff and | rot zoom
	a@ time+ dup a!+ nanim 			| n
	a@+ sspriterz
	
	|..... remove when outside screen
	dup @ -17.0 817.0 between -? ( 2drop 0 ; ) drop
	dup 8 + @ 0 616.0 between -? ( 2drop 0 ; ) drop
	
	|..... add velocity to position
	dup 40 + @ over +!
	dup 48 + @ over 8 + +!
	dup 56 + @ over 16 + +!
	drop
	;

|----------------------------
:+people | vx vy sheet anim zoom ang x y --
	'person 'people p!+ >a 
	swap a!+ a!+	| x y 
	32 << or a!+	| ang zoom
	a!+	a!+			| anim sheet
	swap a!+ a!+ 	| vx vy
	0 a!			| vrz
	;

#vx #x #a

:toright 
	0.8 'vx ! -8.0 'x ! 7 8 10 vni>anim 'a ! ;

:toleft
	-0.8 'vx ! 808.0 'x ! 7 8 1 vni>anim 'a ! ;

:+randpeople
	toright rand $1000 and? ( toleft ) drop
	vx 0.2 randmax 0.1 - + 0.2 randmax 0.1 -
	'spritesheet 3 randmax 3 << + @
	a 2.0 0 
	x 400.0 randmax 150.0 + 
	+people ;
	
:demo
	0 SDLcls
	time.
	'people p.drawo		| draw sprites
	2 'people p.sort	| sort for draw (y coord)
	SDLredraw 
	+randpeople
	SDLkey
	>esc< =? ( exit )
	<f1> =? ( +randpeople )
	drop ;
	
:main
	"r3sdl" 800 600 SDLinit
	'spritesheet 
	16 32 "media/img/p1.png" ssload swap !+
	16 32 "media/img/p2.png" ssload swap !+
	16 32 "media/img/p3.png" ssload swap !
	2000 'people p.ini
	timeI
	'demo SDLshow
	SDLquit ;	
	
: main ;