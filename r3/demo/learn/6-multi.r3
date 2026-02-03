| Animation example
| with multiple objects
^r3/lib/rand.r3
^r3/lib/sdl2gfx.r3
^r3/util/arr16.r3
^r3/util/txfont.r3

#spritesheet 0 0 0 | 3 spritessheet
#people 0 0 | dynamic array for sort

|person array
| x y ang anim ss vx vy ar
| 1 2 3   4    5  6  7  8
:.x 1 ncell+ ;
:.y 2 ncell+ ;
:.a 3 ncell+ ;
:.ani 4 ncell+ ;
:.ss 5 ncell+ ;
:.vx 6 ncell+ ;
:.vy 7 ncell+ ;
:.va 8 ncell+ ;

:person | v -- 
	dup 8 + >a
	a@+ int. a@+ int.	| x y
	a@+ dup 32 >> swap $ffffffff and | rot zoom
	a@ timer+ dup a!+ anim>n 			| n
	a@+ sspriterz
	
	|..... remove when outside screen
	dup .x @ -17.0 817.0 between -? ( 2drop 0 ; ) drop
	dup .y @ 0 616.0 between -? ( 2drop 0 ; ) drop
	
	|..... add velocity to position
	dup .vx @ over .x +!
	dup .vy @ over .y +!
	dup .va @ over .a +!
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
	0.8 'vx ! -8.0 'x ! 
	10 8 $7f ICS>anim | init cnt scale -- val
	'a ! ;

:toleft
	-0.8 'vx ! 808.0 'x ! 
	1 8 $7f ICS>anim | init cnt scale -- val
	'a ! ;

:+randpeople
	toright rand $1000 and? ( toleft ) drop
	vx 0.2 randmax 0.1 - + 0.2 randmax 0.1 -
	'spritesheet 3 randmax 3 << + @
	a 2.0 0 
	x 400.0 randmax 150.0 + 
	+people ;
	
:demo
	$323262 SDLcls
	timer.
	'people p.drawo		| draw sprites
	2 'people p.sort	| sort for draw (y coord)
	
	$4cff4c txrgb
	$11 txalign  | Center horizontally and vertically
	300 20 200 100 
"Multisprite demo
[SPC] add more people
[ESC] to exit" 
	txText
	
	SDLredraw 
	|+randpeople
	SDLkey
	>esc< =? ( exit )
	<esp> =? ( +randpeople )
	drop ;
	
:main
	"r3 multisprite" 800 600 SDLinit
	"media/ttf/VictorMono-Bold.ttf" 32 txload txfont
	'spritesheet 
	16 32 "media/img/p1.png" ssload swap !+ | spritesheet[0]
	16 32 "media/img/p2.png" ssload swap !+ | spritesheet[1]
	16 32 "media/img/p3.png" ssload swap !  | spritesheet[2]
	2000 'people p.ini
	timer<
	'demo SDLshow
	SDLquit ;	
	
: main ;