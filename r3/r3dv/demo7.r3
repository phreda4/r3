| demo7 r3dv - sombras del sol (ss3dshadow)
| PHREDA 2026
| flechas: direccion del sol   ESPACIO: sombras on/off   mouse: camara (arrastrar) y rueda
^./renderlib.r3
^r3/util/glgfx.r3
^./rlshapes.r3
^./ss3d.r3
^./ss3dshadow.r3

| Camara
#cam_yaw  -0.785398
#cam_pit   0.10
#cam_dist  5.5

| Sol: azimut y elevacion (1.0 = vuelta completa)
#sun_az 0.12
#sun_el 0.16

#camEye -10.0 2.0 0.0
#camTo  0.0 0.5 0.0
#camUp  0.0 1.0 0.0

:setsun | --
	sun_el cos sun_az cos *.	| dx
	sun_el sin					| dy
	sun_el cos sun_az sin *.	| dz
	1.0 0.95 0.85 1.4 ss3dsun ;

:drawscene
	matini 10.0 .1 10.0 matscale 0 -0.1 0 matpos
	$5a5a5a20 draw_cube
	SS3Ddraw ;

#xp #yp
#ns 0
:calcam
	'camEye >a
	cam_yaw cos cam_pit cos *. cam_dist *. a!+
	cam_pit sin cam_dist *. a!+
	cam_yaw sin cam_pit cos *. cam_dist *. a!
	'camEye 'camTo 'camUp rl_camera ;
:movecam
	sdlx dup xp - 0.002 * 'cam_yaw +! 'xp !
	sdly dup yp - neg 0.002 *
	cam_pit + 0.24 min 0.02 max 'cam_pit !
	'yp !
	calcam ;
:wheelcam
	SDLw 0? ( drop ; ) neg
	0.6 * 'cam_dist +!
	calcam ;

:render
	rl_frame_begin
	drawscene
	rl_frame_end ;

:shtxt | -- str
	ss3dshadow@ 1? ( drop "SPACE: shadows ON   arrows: sun" ; ) drop
	"SPACE: shadows OFF  arrows: sun" ;

:txt
	fini
	2 'fscale !
	$7f000000 'fcolor !
	8 sh 48 - 620 40 frect
	$ffffffff 'fcolor !
	16 sh 40 - fat
	shtxt ftext
	fend ;

:main
	render
	txt
	GLUpdate
	immIni
	immMouse
	1 =? ( wheelcam )
	2 =? ( sdlx 'xp ! sdly 'yp ! )
	3 =? ( movecam )
	drop
	sdlkey
	<le> =? ( -0.004 'sun_az +! setsun )
	<ri> =? ( 0.004 'sun_az +! setsun )
	<up> =? ( 0.003 'sun_el +! sun_el 0.24 min 0.02 max 'sun_el ! setsun )
	<dn> =? ( -0.003 'sun_el +! sun_el 0.24 min 0.02 max 'sun_el ! setsun )
	<spc> =? ( ss3dshadow@ 1 xor ss3dshadow! )
	>esc< =? ( exit )
	drop ;

:sp | -- n	; sprite a mostrar (cicla por los del archivo)
	ns n3dsprites mod ;
	
:load3d
	"media/ssv/dino" 512 ss3dload
	-2.0 ( 2.0 <?
		-2.0 ( 2.0 <?
			over 0.5 +
			4.0 ns 100 + ss3dfloor
			pick2 0.5 +
			$0 rxyz>q16
			|4.0 ns 100 + $ffffff00
			3.5 sp $ffffff00
			ns
			ss3dset
			1 'ns +!
			1.0 + ) drop
		1.0 + ) drop ;

:viewresize
	sh sw rl_resizewin fixFontResize ;

: | <<<<< Boot
	"demo7 r3dv" 1024 768 GLini GLInfo
	glgfx
	rl_init
	IniShapes
	load3d
	'camEye 'camTo 'camUp rl_camera
	2048 ss3dshadowini
	1 ss3dshadowauto
	setsun
	1 ss3dshadow!
	'viewresize SDLeventR
	calcam
	'main SDLshow
	ss3dshadowend
	SS3Dshutdown
	endShapes
	rl_shutdown
	GLend ;
