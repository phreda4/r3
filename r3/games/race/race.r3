| race, from code from MCORNES in :r4
| PHREDA 2022

^r3/win/sdl2gfx.r3
^r3/win/sdl2image.r3

^r3/lib/rand.r3
^r3/util/arr16.r3
^r3/util/tilesheet.r3
|^r3/util/bfont.r3

#spr_car
#spr_trail

#track

#arr 0 0	| array

|------------------------------
#control

#px #py | positionX, positionY - where the car is
#vx #vy | velocityX, velocityY - speed on each axis
#drag   | drag - how fast the car slows down
#angle  | angle - the rotation of the car
#av     | angularVelocity - speed the car is spinning
#ad     | angularDrag - how fast the car stops spinning
#power  | power - how fast car can accelerate

:simulate 
	px vx + 'px !
	py vy + 'py !
	vx drag *. 'vx !
	vy drag *. 'vy !
	angle av + 'angle !
	av ad *. 'av !
	power 0? ( dup 'av ! ) drop
	;
	  
#maxpower 16.0

:accelerate 
	power 0.2 + maxpower min 'power ! ;

:slower 
	power swap - 0 max 'power ! ;

:turn | ( amount - )
	power 1 >> *. 'av +! ;

:carcontrol 
	control
	%1 and? ( accelerate )  
    %10 and? ( 0.2 slower ) 
	%100 and? ( 0.0002 turn ) 
	%1000 and? ( -0.0002 turn )
	drop
	0.1 slower 
	angle dup 
	cos power *. 'vx ! 
	sin power *. 'vy ! 
	simulate
	;	  
	
:drawcar	
	px int. py int. angle spr_car SDLspriteR | x y ang img --
	;
	
:resetcar
	270.0 'px ! 90.0 'py !
    0.0 'vx ! 0.0 'vy !
    0.9 'drag !
    0.0 'angle !
    0.0 'av !
    0.95 'ad !
    4.0 'power !
	;
|------------------------------
:drawtrack
	26 20
	0 0 
	0 0
	180 180
	track tiledraws ;
	
|------------------------------
:main
	$0 SDLcls
	drawtrack
	'arr p.draw
	carcontrol
	drawcar
	SDLredraw
	
	SDLkey
	>esc< =? ( exit )
	<d> =? ( control %100 or 'control ! )
	<a> =? ( control %1000 or 'control ! )
	<w> =? ( control %1 or 'control ! )
	<s> =? ( control %10 or 'control ! )
	>d< =? ( control %100 not and 'control ! )
	>a< =? ( control %1000 not and 'control ! )
	>w< =? ( control %1 not and 'control ! )
	>s< =? ( control %10 not and 'control ! )
	drop
	;

:inicio
	"r3sdl" 800 600 SDLinit
|	bfont1	
	"r3/games/race/car.png" loadimg 'spr_car !
	"r3/game/race/cartrail.png" loadimg 'spr_trail !
	"r3/games/race/track.map" loadtilemap 'track !
	100 'arr p.ini
	'arr p.clear
	resetcar
	'main SDLshow
	
	SDLquit ;
	
: inicio ;

