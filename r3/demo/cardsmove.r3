| Cards
| PHREDA 2023
^r3/lib/sdl2gfx.r3
^r3/util/arr16.r3
^r3/lib/gui.r3
^r3/lib/rand.r3

#sprites
#cards 0 0

|--- card list
:.x 1 ncell+ ;
:.y 2 ncell+ ;
:.rz 3 ncell+ ;
:.n 4 ncell+ ;
:.ss 5 ncell+ ;
:.vx 6 ncell+ ;
:.vy 7 ncell+ ;
:.vr 8 ncell+ ;

:objsprite | adr -- adr
	dup 8 + >a
	a@+ int. a@+ int.	| x y
	a@+ dup 32 >> swap $ffffffff and | rot zoom
	a@+ a@+ sspriterz
	dup .vx @ over .x +!
	dup .vy @ over .y +!
	dup .vr @ over .rz +!
	;

	
:guiRectS | adr -- adr
	dup .x @ int. 25 -
	over .y @ int. 40 - | x y
	over 50 + over 80 +
	guiRect
	;
	
:hitx | adr x -- adr x
	over .vx dup @ neg swap ! ;
	
:hity | adr x -- adr x
	over .vy dup @ neg swap ! ;
		
#xa #ya

:mvcard
	sdlx xa - 16 << over .x +! 
	sdly ya - 16 << over .y +! 
:setcard	
	sdlx 'xa ! sdly 'ya ! ;
	
:carta
	objsprite
	guiRectS
	'setcard 'mvcard onDnMoveA
	
	dup .x @ 80.0 <? ( hitx ) 720.0 >? ( hitx ) drop
	dup .y @ 80.0 <? ( hity ) 520.0 >? ( hity ) drop	
	
	drop
	;

:+card	| n y x --
	'carta 'cards p!+ >a 
	swap a!+ a!+	| x y 
	1.0 a!+			| zoom|ang 
	a!+				| n
	sprites a!+ 	| sprite
	1.0 randmax 0.5 - a!+ 	| vx
	1.0 randmax 0.5 - a!+ 	| vy
|	0.002 randmax 0.001 - 32 <<  a!			| vrz
	;

|--------------------	
:fillcards
	0 ( 40 <? 
		dup 
		600.0 randmax 100.0 + 
		400.0 randmax 100.0 +
		+card
		1 + ) drop ;
	
:game
	gui
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
