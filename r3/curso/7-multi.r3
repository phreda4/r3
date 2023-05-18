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

:time.start		msec 'prevt ! 0 'dtime ! ;
:time.delta		msec dup prevt - 'dtime ! 'prevt ! ;

|person
| x y ang anim ss vx vy ar
| 0 8 16  24   32 40 48 56
:nanim | namin -- n
|	dup 16 >> $ffff and swap $ffff and rot |  add cnt msec
|	55 << 1 >>> 63 *>> swap 32 >>> + 
	dup $ffffffffff and 
	over 40 >> $f and 48 + << 1 >>>
	over 44 >> $ff and 63 *>>
	swap 52 >>> + | ini
	;
	
:aa |  vel cnt ini -- val | $fff ( 4k sprites) $ff (256 movs) $f (vel) ffffffffff (time)
	$fff and 52 << swap
	$ff and 44 << or swap
	$f and 40 << or 
	;
	
:person | v -- 
	dup >a
	a@+ int. a@+ int.	| x y
	a@+ dup 32 >> swap $ffffffff and 
	a@ dtime + $ffffff7fffffffff and dup a!+ nanim 
	a@+ sspriterz
	dup 40 + @ over +!
	dup 48 + @ over 8 + +!
	dup 56 + @ over 16 + +!
	drop
	;
	
:+people	
	'person 'people p!+ >a 
	400.0 a!+ 300.0 a!+	| x y 
	0.5 32 << 3.0 or a!+ | ang rot
	8 8 10 aa a!+	| animacion+ tiempo
	spritesheet a!+
	0.1 a!+ 0.0 a!+			| vx vy
	0.0 a!
	;

:demo
	0 SDLcls
	time.delta	
	
	'people p.drawo	| draw sprites
	1 'people p.sort	| sort for draw

	SDLredraw
	
	SDLkey
	>esc< =? ( exit )
	<f1> =? ( +people )
	drop ;
	
:main
	"r3sdl" 800 600 SDLinit
	16 32 "media/img/p2.png" ssload 'spritesheet !
	100 'people p.ini
	time.start
	'demo SDLshow
	SDLquit ;	
	
: main ;