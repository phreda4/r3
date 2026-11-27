| demo7 r3dv - sombras del sol (ss3dshadow)
| PHREDA 2026
| flechas: direccion del sol   ESPACIO: sombras on/off   N: dia/noche   L: luces   mouse: camara (arrastrar) y rueda
^r3/util/glgfx.r3
^r3/rimm/rimmgl.r3
^r3/rimm/rimmcore.r3

^./renderlib.r3
^./rlshapes.r3
^./ss3d.r3
^./ss3dshadow.r3

| Camara
#cam_yaw  1.0
#cam_pit   0.0

| Sol: azimut y elevacion (1.0 = vuelta completa)
#sun_az 0.12
#sun_el 0.16

#camEye -10.0 2.0 0.0
#camTo  0.0 0.0  0.0
#camUp  0.0 1.0  0.0

#camAdv 0 0 0 | forward
#camLat 0 0 0 | right

#night 1		| 1 = sol bajo (las luces de colores se notan mas)  0 = sol pleno
#lights_on 1

:sunint | -- f	; de noche casi no hay sol
	night 1? ( drop 0.04 ; ) drop 1.4 ;

:ambient | --		; de noche el ambiente es casi nulo: solo se ve lo que tocan las luces
	night 1? ( drop 0.03 'rl_ambient ! ; ) drop 1.0 'rl_ambient ! ;

:setsun | --
	ambient
	sun_el cos sun_az cos *.	| dx
	sun_el sin					| dy
	sun_el cos sun_az sin *.	| dz
	1.0 0.95 0.85 sunint ss3dsun ;

#cp #sp #cy #sy 

:makecam
	cam_yaw sincos 'cy ! 'sy !
	cam_pit -0.24 max 0.24 min 
	sincos 'cp ! 'sp !
	'camTo >a 'camEye >b
	b@+ cy cp *. + a!+
	b@+ sp + a!+
	b@+ sy cp *. + a!
	'camAdv >a
	cy neg cp *. a!+
	sp neg a!+
	sy neg cp *. a!
	'camAdv v3Nor
	'camLat >a
	sy a!+
	0 a!+
	cy neg a!+
	'camLat v3Nor
	'camEye 'camTo 'camUp rl_camera | 'eye 'to 'up --	
	;

#xp #yp 
:movecam
	|sdlb 4 <>? ( drop ; ) drop
	sdlx dup xp - 0.001 * 
	'cam_yaw +! 'xp !
	sdly dup yp - -0.001 * 
	cam_pit + |0.24 min -0.24 max 
	'cam_pit ! 'yp !
	makecam ;
	
:wheelcam
	SDLw 0? ( drop ; ) -0.4 *
	'camEye 'camAdv pick2 v3+*
	'camTo 'camAdv pick2 v3+*
	drop
	makecam ;

:shtxt | -- str
	ss3dshadow@ 1? ( drop "SPACE:shadows ON   arrows:sun  N:night  L:lights" ; ) drop
	"SPACE:shadows OFF  arrows:sun  N:night  L:lights" ;

:txt
	fini
	2 'fscale !
	$7f000000 'fcolor !
	8 sh 48 - 800 40 frect
	$ffffffff 'fcolor !
	16 sh 40 - fat
	shtxt ftext
	fend ;

#va #vl #vu

| ---- luces de colores moviles (rl_point_light: int cr cg cb x y z) ----
#nlights 6
#lcol 1.0 0.12 0.08  1.0 0.55 0.10  0.15 1.0 0.25  0.10 0.85 1.0  0.20 0.30 1.0  1.0 0.15 0.90
#lpack $ff2a1ee3 $ff8c1ae3 $26ff40e3 $1ad9ffe3 $334dffe3 $ff26e6e3	| rgb + alfa $e3 = rugosidad 7, brillo propio 3 (bloom)

#la #lr #lx #ly #lz

:lightcol | i -- r g b
	3 * 3 << 'lcol + >a a@+ a@+ a@ ;

:lightpos | i -- x y z	; orbita: radio 2.0/4.2/6.4, velocidad y sentido distintos por luz, altura oscilante
	>r
	msec 2 << r@ 2 + * 2 >> r@ 1 and 2 * 1 - * 'la !
	r@ 3 mod 2.2 * 2.0 + 'lr !
	la cos lr *.
	la 2 * r> 13 << + sin 0.4 *. 1.0 +
	la sin lr *. ;

:dolight | i --
	>r
	r@ lightpos 'lz ! 'ly ! 'lx !
	8.0 r@ lightcol lx ly lz rl_point_light
	matini lx ly lz mpos		| esfera emisiva en la posicion de la luz
	0.12 'lpack r@ 3 << + @ draw_sphere
	r> drop ;

:lights
	lights_on 0? ( drop ; ) drop
	4.5 'rl_plight_radius !
	0 ( nlights <? dup dolight 1+ ) drop ;

:main
	rl_frame_begin
	matini 10.0 .1 10.0 mscale 0 -0.1 0 mpos
	$a0a0a0e0 draw_cube	| piso mate y mas claro: con rugosidad baja solo reflejaba el cielo y tapaba el color de las luces
	SS3Ddraw 
	lights
	rl_frame_end
	txt
	GLUpdate
	uiStart immFull
	immMouse
	1 =? ( wheelcam )
	2 =? ( sdlx 'xp ! sdly 'yp ! )
	3 =? ( movecam )
	drop
	sdlkey
	<w> =? ( -0.05 'va ! ) >w< =? ( 0 'va ! )
	<s> =? ( 0.05 'va ! ) >s< =? ( 0 'va ! )
	<a> =? ( 0.04 'vl ! ) >a< =? ( 0 'vl ! )
	<d> =? ( -0.04 'vl ! ) >d< =? ( 0 'vl ! )
	<q> =? ( 0.04 'vu ! ) >q< =? ( 0 'vu ! )
	<e> =? ( -0.04 'vu ! ) >e< =? ( 0 'vu ! )	
	
	<le> =? ( -0.004 'sun_az +! setsun )
	<ri> =? ( 0.004 'sun_az +! setsun )
	<up> =? ( 0.003 'sun_el +! sun_el 0.24 min 0.02 max 'sun_el ! setsun )
	<dn> =? ( -0.003 'sun_el +! sun_el 0.24 min 0.02 max 'sun_el ! setsun )
	<spc> =? ( ss3dshadow@ 1 xor ss3dshadow! )
	<n> =? ( night 1 xor 'night ! setsun )
	<l> =? ( lights_on 1 xor 'lights_on ! )
	>esc< =? ( exit )
	drop 
	
	va 1? ( 
		'camEye 'camAdv pick2 v3+*
		'camTo 'camAdv pick2 v3+*
		makecam
		) drop
	vl 1? (
		'camEye 'camLat pick2 v3+*
		'camTo 'camLat pick2 v3+*
		makecam
		) drop
	vu 1? (
		'camEye 'camUp pick2 v3+*
		'camTo 'camUp pick2 v3+*
		makecam
		) drop	
;

#ns

:sp | -- n	; sprite a mostrar (cicla por los del archivo)
	ns n3dsprites mod ;

:load3d
	"media/ssv/dino" 512 ss3dload
	-4.0 ( 4.0 <?
		-4.0 ( 4.0 <?
		
		over 0.5 +
		2.5 sp ss3dfloor | apoyado en el piso
		pick2 0.5 +
		$0 rxyz>q16
		2.5 sp $ffffff00
		ns
		ss3dset | x y z qxyzw scale spr color i --
		1 'ns +!
		
			1.0 + ) drop
		1.0 + ) drop ;

:viewresize
	sh sw rl_resizewin fixFontResize ;

: | <<<<< Boot
	"demo7 r3dv" 1024 768 GLini GLInfo
	glgfx
	"media/img/VGA8x16.png" 8 16 fload txfont

	rl_init
	IniShapes
	load3d
	'camEye 'camTo 'camUp rl_camera
	2048 ss3dshadowini
	1 ss3dshadowauto
	setsun
	1 ss3dshadow!
	'viewresize SDLeventR
	makecam
	'main SDLshow
	ss3dshadowend
	SS3Dshutdown
	endShapes
	rl_shutdown
	GLend ;
