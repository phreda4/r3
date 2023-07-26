| Cards
| PHREDA 2023
^r3/win/sdl2gfx.r3
^r3/util/arr16.r3
^r3/lib/rand.r3

#sprites
#cards 0 0

:objsprite | adr -- adr
	dup >a
	a@+ int. a@+ int.	| x y
	a@+ dup 32 >> swap $ffffffff and | rot zoom
	a@+ a@+ sspriterz
	dup 40 + @ over +!
	dup 48 + @ over 8 + +!
	dup 56 + @ over 16 + +!
	;
	
:hitx | adr x -- adr x
	over 40 + dup @ neg swap ! ;
	
:hity | adr x -- adr x
	over 48 + dup @ neg swap ! ;
	
:carta
	objsprite
	dup @ 80.0 <? ( hitx ) 720.0 >? ( hitx ) drop
	dup 8 + @ 80.0 <? ( hity ) 520.0 >? ( hity ) drop
	drop
	;

:+card	| n y x --
	'carta 'cards p!+ >a 
	swap a!+ a!+	| x y 
	1.0 a!+			| zoom|ang 
	a!+				| n
	sprites a!+ 	| sprite
	2.0 randmax 1.0 - a!+ 	| vx
	2.0 randmax 1.0 - a!+ 	| vy
	0.002 randmax 0.001 - 32 <<  a!			| vrz
	;
	
:fillcards
	0 ( 40 <? 
		dup 
		600.0 randmax 100.0 + 
		400.0 randmax 100.0 +
		+card
		1 + ) drop ;
	
:game
	$6600 SDLcls
	'cards p.draw
	SDLredraw
	SDLkey 
	>esc< =? ( exit )
	drop ;
	
:	
	"Cards" 800 600 SDLinit
	50 80 "media/img/cards.png" ssload 'sprites !
	40 'cards p.ini
	fillcards
	'game SDLshow
	SDLquit 
	;
