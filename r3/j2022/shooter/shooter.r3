^r3/win/sdl2gfx.r3
^r3/win/sdl2image.r3	
^r3/win/sdl2mixer.r3
^r3/util/bfont.r3
^r3/util/arr16.r3
^r3/util/tilesheet.r3
^r3/lib/rand.r3
^r3/lib/gui.r3


#sinicio 
#graficos

#fx 0 0
#balas 0 0
#aliens 0 0

#sbtnj1 #sbtnj2
#sbtns1 #sbtns2
	
#puntos
#vidas
	
#xp 355.0 #yp 500.0
#vxp #vyp

|----------------------------------------	
#sndfile "disparo.mp3" "explosion.mp3" 0

#sndlist * 1024

:loadsndfile
	'sndlist >a
	'sndfile ( dup c@ 1? drop
		dup "r3/j2022/shooter/%s" sprint
		Mix_LoadWAV a!+
		>>0 ) drop ;

:playsnd | n --
	3 << 'sndlist + @ SNDplay ;

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


:alien | a --
	>a 
	msec 7 >> $3 and 9 +
	graficos a@+ 16 >> a@+ 16 >> tsdraw
	-16 a+
	a@ a> 8 + @ 8 >> sin 2 <<  + 
	a!+
	a@ 1.2 + 
	600.0 >? ( drop 0 ; )
	a!
	
	-8 a+
	a@+ xp - int.  
	a@+ yp - int. distfast 
	90 >? ( drop ; ) drop

	xp yp +fx
	1 playsnd
	-1 'vidas +!
	vidas 0? ( exit ) drop
	0
	;
	
:+alien | x y --
	'alien 'aliens p!+ >a swap a!+ a! ;
	
|--------------------------------
:hitene | x y i n p -- x y p
	dup 8 + >a 
	pick4 a@+ 16 >> -
	pick4 a@+ 16 >> -
	distfast 
	40 >? ( drop ; )
	drop
	dup 'aliens p.del
	pick4 16 << pick4 16 << +fx
	1 'puntos +!
	1 playsnd
	;
	
:disp | a --
	>a 
	8 graficos
	a@+ 16 >> 
	a@ 8.0 - dup a!+ 16 >>
	-40 <? ( 4drop 0 ; )
	'hitene 'aliens p.mapv
	tsdraw
	;
	
:+disp | x y --
	'disp 'balas p!+ >a swap a!+ a! 
	0 playsnd ;

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

:reset
	0 'puntos !
	3 'vidas !
	'fx p.clear
	'balas p.clear
	'aliens p.clear
	355.0 'xp ! 500.0 'yp !
	;
	
|---------------------
#secant

:creador
	msec 10 >>
	secant =? ( drop ; )
	'secant !
	3 randmax 0? ( 800.0 randmax -90.0 +alien ) drop
	;

:game
	0 SDLcls
	
	drawback
	
	'balas p.draw
	'aliens p.draw
	player
	'fx p.draw

	$ffffff sdlcolor
	8 8 bat
	puntos "PUNTOS:%d" sprint bprint
	600 8 bat
	vidas "VIDAS:%d" sprint bprint

	SDLredraw

	creador
	
	SDLkey
	>esc< =? ( exit )
	<le> =? ( -2.0 'vxp ! )
	<ri> =? ( 2.0 'vxp ! )
	>le< =? ( 0 'vxp ! )
	>ri< =? ( 0 'vxp ! )
	<esp> =? ( xp yp +disp )
	<f1> =? ( 200.0 10.0 +alien )
	
	drop
	;

:jugar
	reset
	fillback
	'game SDLshow
	;
	
|---------------------------------------
:btni | 'vecor 'i x y -- 
	pick2 @ SDLImagewh guibox
	SDLb SDLx SDLy guiIn	
	[ 8 + ; ] guiI 
	@ xr1 yr1 rot SDLImage
	onCLick ;
	
:inicial
	gui
	0 0 sinicio SDLImage

	'jugar 'sbtnj1 300 320 btni
	'exit 'sbtns1 330 450 btni
	
	SDLRedraw
	
	SDLkey 
	<F1> =? ( jugar ) 
	>esc< =? ( exit )
	drop 
	;
	
:	
	"r3sdl" 800 600 SDLinit

	SNDInit
	loadsndfile
	
	bfont1 
	100 'fx p.ini
	100 'balas p.ini
	100 'aliens p.ini
	
	90 90 "r3/j2022/shooter/shooter.png" loadts 'graficos !
	"r3/j2022/shooter/inicio.png" loadimg 'sinicio	 !

	"r3/j2022/shooter/btnj1.png" loadimg 'sbtnj1 ! 
	"r3/j2022/shooter/btnj2.png" loadimg 'sbtnj2 ! 
	"r3/j2022/shooter/btns1.png" loadimg 'sbtns1 ! 
	"r3/j2022/shooter/btns2.png" loadimg 'sbtns2 ! 

	rerand
	
	'inicial SDLshow
	
	SDLquit 
	;
