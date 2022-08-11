^r3/win/sdl2gfx.r3
^r3/win/sdl2image.r3	
^r3/win/sdl2mixer.r3
^r3/util/tilesheet.r3

^r3/lib/rand.r3
 
#graficos

#xs #ys
#xss #yss #nss

#xp 355.0 #yp 500.0
#vxp #vyp

#xa #ya

:player
	|yp vyp + 10.0 max sh 100 - 16 << min 'yp !
	xp vxp + 10.0 max sw 90 - 16 << min 'xp !
	
	msec 7 >> $3 and
	graficos
	xp 16 >> yp 16 >> tsdraw 
	;

:explode
	xss 0? ( drop ; ) drop
	nss 16 >>
|	ts_explo 
	xss yss tsdraw

	-1 'xss +!
	0.2 'nss +!
	nss 15.5 >? ( 0 'xss ! ) drop
	;

:+explode
	xa 16 >> 10 - 'xss !
	ya 16 >> 10 - 'yss !
	0 'nss !
	
	;

:newovni
	500.0 randmax 50.0 + 'ya !
	sw 16 << 'xa ! ;

:hit??
	xa 16 >> 20 + xs -
	ya 16 >> 15 + ys - distfast
	20 >? ( drop ; ) drop
	0 'xs !
	+explode
	newovni
	;

:shoot
	xs 0? ( drop ; ) drop
	8 'xs +!
	xs sw >? ( 0 'xs ! drop ; ) drop
	$ffffff SDLColor
	xs ys over 10 + over SDLLine
	hit??
	;

:+shoot
	xs 1? ( drop ; ) drop
	yp 16 >> 14 + 'ys !
	xp 16 >> 30 + 'xs !
	;

:ovni | --
	3.0 randmax 1.5 - 'ya +!
	-2.0 'xa +!
	xa -10.0 <? ( newovni ) drop
	msec 6 >> $3 and 
|	ts_alien 
	xa 16 >> ya 16 >> tsdraw ;


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
	player
|	shoot
|	ovni
|	explode
	
	SDLredraw

	SDLkey
	>esc< =? ( exit )
	<le> =? ( -2.0 'vxp ! )
	<ri> =? ( 2.0 'vxp ! )
	>le< =? ( 0 'vxp ! )
	>ri< =? ( 0 'vxp ! )
	<esp> =? ( +shoot )
	drop
	;

:	
	"r3sdl" 800 600 SDLinit
	SNDInit

	90 90 "r3/j2022/shooter/nave.png" loadts 'graficos !

	fillback
	
	'game SDLshow
	
	SDLquit 
	;
