| demo program for forth2020
| graphics and sound from the game DELTA made by MC
|--
|Ship sprites from Jacob Zinman-Jeanes:
|  http://gamedev.tutsplus.com/articles/news/enjoy-these-totally-free-space-based-shoot-em-up-sprites/
|--
|Explosion sprite from:
|  http://www.nordenfelt-thegame.com/blog/category/dev-log/page/3/
|--
|mp3 files from:
|  https://github.com/jakesgordon/javascript-delta
|--
^r3/win/sdl2.r3
^r3/win/sdl2image.r3	
^r3/win/sdl2mixer.r3
^r3/util/tilesheet.r3

^r3/lib/sys.r3
^r3/lib/gr.r3
^r3/lib/rand.r3
 
#ts_alien 
#ts_ship
#ts_explo

#snd_shoot 0 0
#snd_explosion 0 0

#xp 40.0 #yp 100.0
#vxp #vyp

#xs #ys

#xa 500.0 #ya 130.0

#xss #yss #nss

:player
	yp vyp + 10.0 max sh 40 - 16 << min 'yp !
	msec 7 >> $3 and
	ts_ship xp 16 >> yp 16 >> tsdraw 
	;

:explode
	xss 0? ( drop ; ) drop
	nss 16 >>
	ts_explo xss yss tsdraw

	-1 'xss +!
	0.2 'nss +!
	nss 15.5 >? ( 0 'xss ! ) drop
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
	snd_shoot SNDplay

:ovni | --
	3.0 randmax 1.5 - 'ya +!
	-2.0 'xa +!
	xa -10.0 <? ( newovni ) drop
	msec 6 >> $3 and 
	ts_alien xa 16 >> ya 16 >> tsdraw ;


#ss * 8192 |
#ss> 'ss

:drawback
	$ffffff sdlcolor 
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
	0 SDLclear
	
	drawback
	player
	shoot
	ovni
	explode
	
	SDLRedraw

	SDLkey
	>esc< =? ( exit )
	<up> =? ( -2.0 'vyp ! )
	<dn> =? ( 2.0 'vyp ! )
	>up< =? ( 0 'vyp ! )
	>dn< =? ( 0 'vyp ! )
	<esp> =? ( +shoot )
	drop
	;

:	
	rerand
	"r3sdl" 800 600 SDLinit
	SNDInit

	40 30 "media/img/alien_40x30.png" loadts 'ts_alien !
	64 29 "media/img/ship_64x29.png" loadts 'ts_ship !
	64 64 "media/img/explo_64x64.png" loadts 'ts_explo !

	"media/snd/shoot.mp3" Mix_LoadWAV 'snd_shoot !
	"media/snd/explode.mp3" Mix_LoadWAV 'snd_explosion !

	fillback
	
	'game SDLshow
	
	SNDQuit	
	SDLquit 
	;
