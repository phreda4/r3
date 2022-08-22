^r3/win/sdl2gfx.r3
^r3/win/sdl2image.r3	
^r3/win/sdl2mixer.r3

^r3/util/arr16.r3
^r3/util/tilesheet.r3
^r3/lib/rand.r3
 
#graficos

#fx 0 0
#balas 0 0
#aliens 0 0
	
#xp 355.0 #yp 500.0
#vxp #vyp


:player
	|yp vyp + 10.0 max sh 100 - 16 << min 'yp !
	xp vxp + 10.0 max sw 90 - 16 << min 'xp !
	
	msec 7 >> $3 and
	graficos
	xp 16 >> yp 16 >> tsdraw 
	;

:explode
	>a
	a@ 3.0 >=? ( 0 nip ; ) 
	0.1 + dup a!+
	16 >> 14 + graficos
	a@+ 16 >> a@+ 16 >>
	tsdraw
	;

:+fx | x y
	'explode 'fx p!+ >a 0 a!+ swap a!+ a! ;

|:newovni
|	500.0 randmax 50.0 + 'ya !
|	sw 16 << 'xa ! ;

:hit??
|	xa 16 >> 20 + xs -
|	ya 16 >> 15 + ys - distfast
|	20 >? ( drop ; ) drop
|	0 'xs !
|	+fx
|	newovni
	;
	
:alien | a --
	>a 
	msec 7 >> $3 and 9 +
	graficos a@+ 16 >> a@+ 16 >> tsdraw
	-8 a+
	a@ 1.2 + 
	600.0 >? ( drop 0 ; )
	a!
	;
	
:+alien | x y --
	'alien 'aliens p!+ >a swap a!+ a! ;
	
|--------------------------------
:disp | a --
	>a 
	8 graficos
	a@+ 16 >> 
	a@ 8.0 - dup a!+ 16 >>
	-40 <? ( 4drop 0 ; )
	tsdraw
	;
	
:+disp | x y --
	'disp 'balas p!+ >a swap a!+ a! ;

|--------------------------------

#ss * 8192 | estrellas

:drawback
	$ffffff SDLColor 
	'ss >a
	1024 ( 1? 1 -
		da@+ da@
		600 >? ( 0 nip ) 1 + dup da!+
		SDLPoint		
		) drop ;

:fillback
	'ss >a
	1024 ( 1? 1 -
		sw randmax da!+
		sh randmax da!+
		) drop ;

:game
	0 SDLcls
	
	drawback
	
	'balas p.draw
	'aliens p.draw
	'fx p.draw
	player
	
	SDLredraw

	SDLkey
	>esc< =? ( exit )
	<le> =? ( -2.0 'vxp ! )
	<ri> =? ( 2.0 'vxp ! )
	>le< =? ( 0 'vxp ! )
	>ri< =? ( 0 'vxp ! )
	<esp> =? ( xp yp +disp )
	<f1> =? ( 800.0 randmax -90.0 +alien ) 
	drop
	;

:	
	"r3sdl" 800 600 SDLinit
	SNDInit

	100 'fx p.ini
	100 'balas p.ini
	100 'aliens p.ini
	
	90 90 "r3/j2022/shooter/shooter.png" loadts 'graficos !

	fillback
	
	'game SDLshow
	
	SDLquit 
	;
