| move sprite

^r3/lib/sdl2gfx.r3
^r3/util/txfont.r3

#sprPelota	| sprite
#xp 400.0 #yp 300.0		| pos
#xv #yv		| speed

:hitx xv neg 'xv ! ;
:hity yv neg 'yv ! ;

:main
	0 SDLcls
	xp int. yp int. sprPelota sprite
	
	$ffff4c txrgb
	10 10 txat
	"awsd - move sprite" txprint
	790 10 txat
	yv xv "%f %f" txprintr
	
	SDLredraw

	xv 'xp +!
	yv 'yp +!
	
	xp 100.0 <? ( hitx ) 700.0 >? ( hitx ) drop
	yp 100.0 <? ( hity ) 500.0 >? ( hity ) drop
	
	SDLkey
	>esc< =? ( exit )
	<w> =? ( -0.1 'yv +! )
	<s> =? ( 0.1 'yv +! )
	<a> =? ( -0.1 'xv +! )
	<d> =? ( 0.1 'xv +! )
	drop ;

:
	"r3 sprite" 800 600 SDLinit
	"media/ttf/VictorMono-Bold.ttf" 32 txload txfont
	"media/img/ball.png" loadimg 'sprpelota !
	'main SDLshow
	SDLquit 
	;
