| demo1 r3dv
| PHREDA 2026
^./renderlib.r3
^./rlhud.r3
^./rlShapes.r3
^./rl3dtile.r3

| Camera controls
#cam_yaw  0  
#cam_pit  0
#camEye -10.0 2.0 0.0
#camTo  0.0 0.0  0.0
#camUp  0.0 1.0  0.0
#camAdv 0 0 0 | forward
#camLat 0 0 0 | right

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

:rotatemouse
	immMouse
	1 =? ( wheelcam )				| over
	2 =? ( sdlx 'xp ! sdly 'yp ! )	| in
	3 =? ( movecam )				| active
	drop	
	;

:drawscene
	matini
	msec 1 << 0 msec 2 << matrot
	0.8 dup dup matscale
	msec 2 << sin 2 * msec 3 << cos 0.3 + 0 matpos
	$fffffff0 draw_cube 
	
	draw3dtiles
	;
	


#fsun [ 
-2.5 2.0 -1.5 0	| normal
 1.0 1.0 1.0 1.2  ] | color,intensidad
	   
:render
	rl_frame_begin
	drawscene
	
	'fsun rl_set_sun
	
	1.5 1.0 0.2 0.2
	msec 3 << 
	dup cos 3 * 
	over sin 3 *
	rot 0.5 + sin 2.5 *.
	rl_point_light | int cr cg cb x y z --
	
	rl_frame_end
	;
	
#va #vl #vu
	
:main
	render
	
	fini
	2 'fscale !
	$7f000000 'fcolor !
	8 sh 48 - 400 40 frect
	$ffffffff 'fcolor !
	16 sh 40 - fat
	"r3forth - DEMO ESC2 " ftext
	fend
	
    GLUpdate
	
	immIni
	immMouse
	1 =? ( wheelcam )				| over
	2 =? ( sdlx 'xp ! sdly 'yp ! )	| in
	3 =? ( movecam )				| active
	drop	
	
    sdlkey
	>esc< =? ( exit )
	<w> =? ( -0.05 'va ! ) >w< =? ( 0 'va ! )
	<s> =? ( 0.05 'va ! ) >s< =? ( 0 'va ! )
	<a> =? ( 0.04 'vl ! ) >a< =? ( 0 'vl ! )
	<d> =? ( -0.04 'vl ! ) >d< =? ( 0 'vl ! )
	<q> =? ( 0.04 'vu ! ) >q< =? ( 0 'vu ! )
	<e> =? ( -0.04 'vu ! ) >e< =? ( 0 'vu ! )	
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
	
:maket3d
	t3d_ini

	$00000 -5 -5 -10 t3dv
	$0001f -5 5 -10 t3dv
	$1f01f 5 5 -10 t3dv
	$1f000 5 -5 -10 t3dq
	
	$20020 -5 -5 10 t3dv
	$2003f -5 5 10 t3dv
	$3f03f 5 5 10 t3dv
	$3f020 5 -5 10 t3dq
	
	$20000 -5 10 -5 t3dv
	$2001f -5 10  5 t3dv
	$3f01f 5 10 5 t3dv
	$3f000 5 10 -5 t3dq

	$00020 10 0 0 t3dv
	$0003f 10 0 1 t3dv
	$1f03f 10 1 1 t3dv
	$1f020 10 1 0 t3dq
	t3d_end
	;
	
:viewresize 
	sh sw rl_resizewin fixFontResize ;

: | <<<<<< Boot
	"demo escena" 1024 768 GLini GLInfo
	rlhud
	rl_init
	IniShapes
	
	8 'fsun memfloat
	
	'viewresize SDLeventR
	makecam
	
	ini3dtile
	"media/img/atlaspl.png" rl_3datlas	
	maket3d
	
	'main SDLshow
	
	rl_shutdown
    GLend
	end3dtile
	endShapes
	;