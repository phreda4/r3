| Demo Flapybird
| PHREDA 2021

^r3/lib/console.r3
^r3/lib/sdl2gfx.r3
^r3/lib/sdl2image.r3
|^r3/util/tilesheet.r3
^r3/util/txfont.r3
^r3/lib/rand.r3

| dibujos del juegos

#sprbird
#sprpipe

|--------------------------------	
| posicion y velocidad 
#px 200.0 #py 10.0
#vx 0.0 #vy 0.0

#score 0
#bscore 0

:jugador
	px int. py int. 2.0 msec 8 >> $3 and sprbird sspritez

	py int. sh >? ( -10.0 'vy ! ) drop
	vy 'py +!
	0.1 'vy +! 
	;
	
:colisionpipe | x y -- 0/1
	py int. - abs 60 <? ( 2drop 0 ; ) drop
	px int. - abs 40 >? ( drop 0 ; ) drop
	1 ;
	
#pxp 800.0
#pyp 300
#pxp2 1200.0
#pyp2 300

:reset
	score bscore >? ( dup 'bscore ! ) drop
	0 'score !
	200.0 'px ! 10.0 'py !
	0.0 'vx ! 0.0 'vy !
	800.0 'pxp ! 300 'pyp !
	1200.0 'pxp2 ! 300 'pyp2 !
	;
	
:drawpipe | x y --
	over 0 60 pick3 80 - sprpipe images
	over 5 - over 80 - 70 40 sprpipe images
	over 5 - over 80 + 70 40 sprpipe images
	over over 120 + 60 sh over - sprpipe images
	2drop ;

:newpipe
	pxp2 'pxp ! pyp2 'pyp !
	800.0 'pxp2 ! 500 randmax 'pyp2 ! 
	1 'score +!
	;
	
:choco 
	reset
	;
	
:fondo	
	pxp int. pyp colisionpipe 
	1? ( choco ) drop
	
	pxp2 int. pyp2 drawpipe 
	pxp int. pyp drawpipe 
	-2.4 'pxp +!
	-2.4 'pxp2 +!
	pxp 
	-80.0 <? ( newpipe ) 
	drop
	;
	
:juego
	0 cls
	fondo
	jugador

	$ffff4c txrgb
	10 10 txat
	score "score: %d" txprint
	sw 10 - 10 txat
	bscore	"best score: %d" txprintr

	SDLredraw
	
	SDLkey
	>esc< =? ( exit )
	<spc> =? ( -4.0 'vy ! )	
	drop
	;

:main
	"r3sdl" 800 600 SDLinit

	"media/img/pileline.png" loadimg 'sprpipe !
	24 20 "media/img/bird.png" ssload 'sprbird !
	"media/ttf/VictorMono-Bold.ttf" 24 txload txfont

	'juego SDLshow
	
	SDLquit
	;
		

: main ;
