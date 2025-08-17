| Demo Flapybird
| PHREDA 2021

^r3/lib/console.r3
^r3/lib/sdl2gfx.r3
^r3/lib/sdl2image.r3
^r3/util/tilesheet.r3
^r3/lib/rand.r3

| dibujos del juegos

#sprbird
#sprpipe

|--------------------------------	
| posicion y velocidad 
#px 200.0 #py 10.0
#vx 0.0 #vy 0.0

:jugador
	px int. py int. 2.0 msec 8 >> $3 and sprbird sspritez

	py int. sh >? ( -10.0 'vy ! ) drop
	vy 'py +!
	0.1 'vy +! 
	;
	
#pxp 400.0
#pyp 300
#pxp2 800.0
#pyp2 300
	
:drawpipe | x y --
	over 0 60 pick3 80 - sprpipe SDLImages
	over 5 - over 80 - 70 40 sprpipe SDLImages
	over 5 - over 80 + 70 40 sprpipe SDLImages
	over over 120 + 60 sh over - sprpipe SDLImages
	2drop ;

:newpipe
	pxp2 'pxp ! pyp2 'pyp !
	800.0 'pxp2 ! 500 randmax 'pyp2 ! ;
	
:fondo	
	pxp2 int. pyp2 drawpipe 
	pxp int. pyp drawpipe 
	-2.4 'pxp +!
	-2.4 'pxp2 +!
	pxp -80.0 <? ( newpipe ) drop
	;
	
:juego
	0 SDLcls
	fondo
	jugador
	SDLredraw
	
	SDLkey
	>esc< =? ( exit )
	<esp> =? ( -4.0 'vy ! )	
	drop
	;

:main
	"r3sdl" 800 600 SDLinit

	"media/img/pileline.png" loadimg 'sprpipe !
	36 25 "media/img/bird.png" ssload 'sprbird !

	'juego SDLshow
	
	SDLquit
	;
		

: main ;
