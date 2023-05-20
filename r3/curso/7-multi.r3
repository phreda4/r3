| Animation example
| with multiple objects
^r3/lib/rand.r3
^r3/util/arr16.r3
^r3/win/sdl2gfx.r3

#spritesheet | dibujo
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
	
:aa |  vel cnt ini -- nanim 
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
	dup @ 0 800.0 between -? ( 2drop 0 ; ) drop
	dup 8 + @ 0 600.0 between -? ( 2drop 0 ; ) drop
	
	|..... add velocity to position
	dup 40 + @ over +!
	dup 48 + @ over 8 + +!
	dup 56 + @ over 16 + +!
	drop
	;

|----------------------------
:+people1
	'person 'people p!+ >a 
	0.0 a!+ 500.0 randmax 50.0 + a!+	| x y 
	0 32 << 2.0 or a!+ | ang zoom
	7 8 10 aa a!+	| velocidad frames iniframe
	spritesheet a!+
	0.8 a!+ 0.0 a!+			| vx vy
	0.0 a!
	;

:+people2	
	'person 'people p!+ >a 
	800.0 a!+ 500.0 randmax 50.0 + a!+	| x y 
	0 32 << 2.0 or a!+ | ang zoom
	7 8 1 aa a!+	| velocidad frames iniframe
	spritesheet a!+
	-0.8 a!+ 0.0 a!+			| vx vy
	0.01 32 << 0.0 or a!
	;

:demo
	0 SDLcls
	time.
	'people p.drawo		| draw sprites
	2 'people p.sort	| sort for draw (y coord)
	SDLredraw
	SDLkey
	>esc< =? ( exit )
	<f1> =? ( +people1 )
	<f2> =? ( +people2 )
	drop ;
	
:main
	"r3sdl" 800 600 SDLinit
	16 32 "media/img/p1.png" ssload 'spritesheet !
	100 'people p.ini
	timeI
	'demo SDLshow
	SDLquit ;	
	
: main ;