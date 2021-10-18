| Demo Flapybird
| PHRED 2021

^r3/win/console.r3
^r3/win/sdl2.r3
^r3/win/sdl2image.r3
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
	msec 8 >> $3 and sprbird px 16 >> py 16 >> tsdraw

	py 16 >> sh >? ( -10.0 'vy ! ) drop
	vy 'py +!
	0.1 'vy +! 
	;
	
#pxp 400.0
#pyp 300
#pxp2 800.0
#pyp2 300
	
:drawpipe | x y --
	over 0 60 pick3 80 - sprpipe SDLimages
	over 5 - over 80 - 70 40 sprpipe SDLimages
	over 5 - over 80 + 70 40 sprpipe SDLimages
	over over 120 + 60 sh over - sprpipe SDLimages
	2drop ;

:newpipe
	pxp2 'pxp ! pyp2 'pyp !
	800.0 'pxp2 ! 500 randmax 'pyp2 ! ;
	
:fondo	
	pxp2 16 >> pyp2 drawpipe 
	pxp 16 >> pyp drawpipe 
	-2.4 'pxp +!
	-2.4 'pxp2 +!
	pxp -80.0 <? ( newpipe ) drop
	;
	
:juego
	0 SDLclear
	fondo
	jugador
	SDLRedraw
	
	SDLkey
	>esc< =? ( exit )
	<esp> =? ( -4.0 'vy ! )	
	drop
	;

:main
	"r3sdl" 800 600 SDLinit

	"media/img/pileline.png" loadimg 'sprpipe !
	36 25 "media/img/bird.png" loadts 'sprbird !

	'juego SDLshow
	
	SDLquit
	;
		

: main ;
