^r3/win/sdl2gfx.r3
^r3/win/sdl2image.r3
^r3/util/tilesheet.r3
^r3/util/arr16.r3


#disparos 0 0

#tsguy	| dibujo
#animacion
#xp 100.0 #yp 400.0		| posicion
#xv #yv		| velocidad
#angulo

|.... time control
#prevt
#dtime

:timeI msec 'prevt ! 0 'dtime ! ;
:time. msec dup prevt - 'dtime ! 'prevt ! ;
:time+ dtime + $ffffff7fffffffff and  ;

| anima
| $fff ( 4k sprites) $ff (256 movs) $f (vel) ffffffffff (time)

:nanim | nanim -- n
	dup $ffffffffff and 
	over 40 >> $f and 48 + << 1 >>>
	over 44 >> $ff and 63 *>>
	swap 52 >>> + | ini
	;
	
:vni>anim | vel cnt ini -- nanim 
	$fff and 52 << swap
	$ff and 44 << or swap
	$f and 40 << or 
	;

:objsprite | adr -- adr
	dup >a
	a@+ int. a@+ int.	| x y
	a@+ dup 32 >> swap $ffffffff and | rot zoom
	a@ time+ dup a!+ nanim 			| n
	a@+ sspriterz
	dup 40 + @ over +!
	dup 48 + @ over 8 + +!
	dup 56 + @ over 16 + +!
	;
	

| 22 = bala	
|disparo
| x y ang anim ss vx vy ar
| 0 8 16  24   32 40 48 56
	
:bala | v -- 
	objsprite
	|..... remove when outside screen
	dup @ -17.0 817.0 between -? ( 2drop 0 ; ) drop
	dup 8 + @ 0 616.0 between -? ( 2drop 0 ; ) drop
	drop
	;

:haciadonde
	angulo
	0 =? ( 0 a!+ -3.0 a!+ drop ; )
	0.25 =? ( 3.0 a!+ 0 a!+ drop ; )
	0.5 =? ( 0 a!+ 3.0 a!+ drop ; )
	0.75 =? ( -3.0 a!+ 0.0 a!+ drop ; )
	drop ;
	
:+disparo
	'bala 'disparos p!+ >a 
	xp a!+ yp a!+	| x y 
	1.0 a!+	| ang zoom
	7 0 22 vni>anim | vel cnt ini 
	a!+ tsguy a!+			| anim sheet
	haciadonde
	0 a!			| vrz
	;


:teclado
	SDLkey
	>esc< =? ( exit )
	
	<a> =? ( -1.0 'xv ! 0.75 'angulo ! )
	>a< =? ( 0 'xv ! )
	
	<d> =? ( 1.0 'xv ! 0.25 'angulo ! )
	>d< =? ( 0 'xv ! )	
	
	<w> =? ( -1.0 'yv ! 0 'angulo ! )
	>w< =? ( 0 'yv ! )
	
	<s> =? ( 1.0 'yv ! 0.5 'angulo ! )
	>s< =? ( 0 'yv ! )
	
	<esp> =? ( +disparo )
	drop ;

	
:demo
	0 SDLcls

	time.
	'disparos p.draw	
	
	xp int. yp int.
	angulo 4.0
	animacion time+ dup 'animacion ! nanim 
	tsguy
	sspriterz 
	
	SDLredraw
	
	xv 'xp +!
	yv 'yp +!
	
	teclado
	;
	
:main
	"r3sdl" 800 600 SDLinit
	32 32 "r3/itinerario/enzo/sprite 1.png" ssload 'tsguy !
	1000 'disparos p.ini
	timeI
	0 0 0 vni>anim 'animacion !
	'demo SDLshow
	SDLquit ;	
	
: main ;