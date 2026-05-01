| demo3 r3dv -- show sprites
| PHREDA 2026
^r3/lib/rand.r3

^./renderlib.r3
^./glfixfont.r3
^./ss3d.r3
^./rlgrid.r3

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

#fsun [ 
-0.5 -1.0 -0.5 0
 1.0 1.0 1.0 1.0
 ]
	   
:luz
	2.4 
	0.2 0.2 1.0
	msec 3 << 
	dup cos -5 * 
	over sin -3 * 1.0 +
	|0
	rot sin 4.5 *.
	rl_point_light | int cr cg cb x y z --

	2.2 
	1.0 0.2 0.2
	msec 3 << 
	dup cos 7 * 
	over sin 3 * 1.0 +
	|0
	rot 0.5 + sin 4.5 *.
	rl_point_light | int cr cg cb x y z --
	;

#nbox	
:movespr
	0 ( n3dsprites <? 
	
		dup nbox / nbox 2/ - 1.2 *
		over 10 << msec 4 << + sin 1.0 + 2/
		pick2 nbox mod nbox 2/ - 1.2 *
	
		pick3 ss3dxyz | x y z i --		
		1+ ) drop
	;

#va #vl #vu
	
:render
	rl_frame_begin
	movespr	
	SS3Ddraw
	luz
	
	rl_frame_end
	;
	
:main
	render
	
	fini
	2 'fscale !
	$7f000000 'fcolor !
	8 sh 48 - 400 40 frect
	$ffffffff 'fcolor !
	16 sh 40 - fat
	"r3forth - DEMO 3 " ftext
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


:load3d
	"media/ss/sprites" 
	|"media/ss/iti"
	|"media/ss/vox2"
|	"media/ss/mezcla"
|	"media/ss/voxi"
|	"media/ss/cars"
|	"media/ss/test"

	dup 256 ss3dload
	ss3loadnames
	
|	"clon" ss3idname .d .println
	
	n3dsprites sqrt 'nbox !
	0 ( n3dsprites <? dup >r
	
		dup nbox / nbox 2/ - 1.1 *
		0
		pick2 nbox mod nbox 2/ - 1.1 *
		
		$0 rxyz>q16
		4.0 $ffffff00 r> dup |ns 97 + ns 
		ss3dset | x y z qxyzw scale color spr i --
		
		1+ ) drop

	;
	
:viewresize 
	sh sw rl_resizewin 
	fixFontResize ;

: | <<<<<<<< Boot
	"demo3 r3dv" 1024 768 GLini GLInfo
	glFixFont
	rl_init
	
	load3d
	8 'fsun memfloat
	'fsun rl_set_sun
	'viewresize SDLeventR
	makecam
	'main SDLshow
	
	SS3Dshutdown
	rl_shutdown
	GLend
	;