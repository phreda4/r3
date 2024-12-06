| demo program
| PHREDA
|--
^r3/lib/sdl2gfx.r3
^r3/lib/sdl2mixer.r3
^r3/lib/rand.r3
 
#imgspr

#snd_shoot 0 
#snd_explosion 0 

#xp 40.0 #yp 100.0
#vxp #vyp

#xs #ys

#xa 500.0 #ya 130.0

#xss #yss #nss

:player
	yp vyp + 10.0 max sh 40 - 16 << min 'yp !
	xp vxp + 40.0 max sw 400 - 16 << min 'xp !
	xp 16 >> yp 16 >> 
	4.0 12 imgspr sspritez
	;

:explode
	xss 0? ( drop ; ) drop
	xss yss 
	4.0
	nss 16 >> 6 +
	imgspr sspritez

	-1 'xss +!
	0.2 'nss +!
	nss 3.5 >? ( 0 'xss ! ) drop
	;

:+explode
	xa 16 >> 10 - 'xss !
	ya 16 >> 10 - 'yss !
	0 'nss !
	snd_explosion SNDplay
	;

:newovni
	500.0 randmax 50.0 + 'ya !
	sw 16 << 'xa ! ;

:hit??
	xa 16 >> xs -
	ya 16 >> ys - distfast
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
	xs ys 10 4 SDLFRect
	hit??
	;

:+shoot
	xs 1? ( drop ; ) drop
	yp 16 >> 'ys !
	xp 16 >> 30 + 'xs !
	snd_shoot SNDplay ;

:ovni | --
	3.0 randmax 1.5 - 'ya +!
	-2.0 'xa +!
	xa -10.0 <? ( newovni ) drop
	xa 16 >> ya 16 >> 
	4.0 
	2 msec 7 >> $3 and +
	imgspr sspritez ;


#ss * 8192 
#ss> 'ss

:drawback
	$ffffff SDLColor 
	'ss ( ss> <?
		d@+ -? ( 800 nip )
		dup 1 - pick2 4 - d!
		swap d@+ rot swap SDLPoint
		) drop ;

:fillback
	'ss >a
	1024 ( 1? 1 -
		sw randmax da!+
		sh randmax da!+
		) drop
	a> 'ss> ! ;

:game
	0 SDLcls
	
	drawback
	player
	shoot
	ovni
	explode
	
	SDLredraw

	SDLkey
	>esc< =? ( exit )
	<up> =? ( -2.0 'vyp ! ) >up< =? ( 0 'vyp ! )
	<dn> =? ( 2.0 'vyp ! ) >dn< =? ( 0 'vyp ! )
	<le> =? ( -2.0 'vxp ! ) >le< =? ( 0 'vxp ! )
	<ri> =? ( 2.0 'vxp ! ) >ri< =? ( 0 'vxp ! )
	<esp> =? ( +shoot )
	drop
	;

:	
	msec time rerand
	"r3sdl" 800 600 SDLinit

	16 16 "media/img/manual.png" ssload 'imgspr !

|	"media/snd/shoot.mp3" Mix_LoadWAV 'snd_shoot !
|	"media/snd/explode.mp3" Mix_LoadWAV 'snd_explosion !

	fillback
	
	'game SDLshow
	
	SNDQuit	
	SDLquit 
	;
