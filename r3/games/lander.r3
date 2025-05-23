| lunar lander
| PHREDA 2021

^r3/lib/sdl2gfx.r3
^r3/lib/sdl2image.r3	
^r3/lib/sdl2mixer.r3

^r3/lib/rand.r3

#imgspr
#snd_explosion

#grd * 1024
#fuel
#px #py
#pdx #pdy
#pthrust
#g

#adx #ady

#astars * 1024

#xo #yo	
:op 'yo ! 'xo ! ;
:lineo 2dup xo yo SDLLine 'yo ! 'xo ! ;

:makeGround
	'grd >a
	rand sh 2 >> mod sh 1 >> +
	sh 1 >>
	256 ( 1? 1 - swap
		rand sh 4 >> mod +
		60 max
		dup da!+
		swap ) 3drop ;

:makeStars
	'astars >a
	256 ( 1? 1 -
		sw randmax
		dup 256 sw */ 2 << 'grd + d@ randmax
		16 << or da!+
		) drop ;

:reset
	sw 1 >> 16 << 'px ! 10.0 'py !
	0 'pdx ! 0 'pdy !
	1000 'fuel !
	0.075 'pthrust !
	0.025 'g !
	makeGround
	makeStars
	;

:stars
	$ffffff SDLColor 
	'astars >b
	100 ( 1? 1 -
		db@+
		dup $ffff and swap 16 >>
		SDLPoint
		) drop ;

:keyboard
	SDLkey
	<up> =? ( pthrust neg 'ady ! )
	<le> =? ( pthrust neg 'adx ! )
	<ri> =? ( pthrust 'adx ! )
	>up< =? ( 0 'ady ! )
	>le< =? ( 0 'adx ! )
	>ri< =? ( 0 'adx ! )
	>esc< =? ( exit )
	drop ;

:player
	fuel 0? (
		0 'adx ! 0 'ady !
		) drop

	ady g + 'pdy +!
	adx 'pdx +!
	pdx 'px +!
	pdy 'py +!
	px
	0 <? ( 0 'px ! 0 'pdx ! )
	sw 22 - 16 << >? ( sw 22 - 16 << 'px ! 0 'pdx ! )
	drop
	py
	-3 <? ( -3 'py ! 0 'pdy ! )
	drop

	px 16 >> py 16 >> 
	1.0
	adx ady or 1? ( -1 'fuel +! msec 3 >> $3 and nip ) 
	imgspr
	sspritez
	;

:ground
	'grd >a
	0 da@+ op
	0 ( 255 <? 1 +
		dup sw 255 */ da@+ lineo
		) drop ;

:hitground? | -- +/-
	px sw / 8 >>
	2 << 'grd + d@
	py 16 >> -
	;


#timee

:crash
	0 SDLcls
	stars
	ground

	px 16 >>  py 16 >> 
	1.0
	timee 16 >>	4 +
	imgspr
	sspritez
	
	SDLredraw
	timee 0.2 + 
	8.5 >? ( exit ) 
	'timee ! 
	;
	
:game
	0 SDLcls
	
	stars
	ground
	player
	hitground? -? ( 0 'timee ! 'crash SDLshow reset ) drop
	
	SDLredraw
	
	keyboard
	;

: 
	msec time rerand
	"r3sdl" 800 600 SDLinit

	20 23 "media/img/lander.png" ssload 'imgspr !

|	"media/snd/explode.mp3" Mix_LoadWAV 'snd_explosion !

	reset
	'game SDLshow
	
	SNDQuit	
	SDLquit 
	;


