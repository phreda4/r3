| demo2 r3dv
| PHREDA 2026
^./renderlib.r3
^./glfixfont.r3
^./geom.r3
^./ss3d.r3

| Camera controls
#cam_yaw  -0.785398   | -PI/4
#cam_pit   0.45
#cam_dist  4.5
#cam_drag  0

| Mouse state
#mouse_x   0
#mouse_y   0
#mouse_btn 0

:drawsprites
	msec 4 << sin 0.5 +  0  over neg
	msec 5 << $ffff and 16 << 
	4.0 8 >> 48 << or
	$ffffff00 
	msec 11 >> $f and
	0 ss3dset
	
	0 msec 3 << sin dup
	4.0 8 >> 48 << 
	$ffffff00
	msec 18 >> $1f and 
	1 ss3dset | x y z rxyz scale color spr i --	
	
	
	;

#col
:drawscene
	rl_ProgGeom
	matini 10.0 .1 10.0 matscale 0 -0.6 0 matpos $5a5a5a20 rl_setcolor draw_cube 
	
	1 'col +!
	
	|drawsprites	
	msec 4 << sin 2.0 + 97 $ffffff00 0 ss3dcs
	|::ss3dcs | scale spr color i --
	|msec 4 << sin 2.0 + 0 $ffffff00 
	0.125 rxyz>q16 1 ss3dqua
	
	msec 3 << $ffff and 16 << 
	msec 2 << $ffff and or
	rxyz>q16 2 ss3dqua
	
	SS3Ddraw
	;

#camEye -10.0 2.0 0.0
#camTo  0.0 0.0  0.0
#camUp  0.0 1.0  0.0	
	
#xp #yp 
:movecam
	sdlx dup xp - 0.002 * 'cam_yaw +! 'xp !
	sdly dup yp - neg 0.002 * 
	cam_pit + 0.2 min -0.2 max 'cam_pit ! 
	'yp ! |...
:calcam
	'camEye >a
	cam_yaw cos cam_pit cos *. cam_dist *. a!+ | ex
	cam_pit sin cam_dist *. a!+
	cam_yaw sin cam_pit cos *. cam_dist *. a!
	'camEye 'camTo 'camUp rl_camera | 'eye 'to 'up --	
	;
:wheelcam
	SDLw 0? ( drop ; ) neg
	0.6 * 'cam_dist +!
	calcam
	;
	

#fsun [ 
-0.5 -1.0 -0.5 0
 1.0 0.9 0.8 0.2
 ]
	   
:luz
	1.4 
	0.2 0.2 1.0
	msec 3 << 
	dup cos -3 * 
	over sin -3 * 1.0 +
	|0
	rot sin 2.5 *.
	rl_point_light | int cr cg cb x y z --

	1.2 
	1.0 0.2 0.2
	msec 3 << 
	dup cos 3 * 
	over sin 3 * 1.0 +
	|0
	rot 0.5 + sin 2.5 *.
	rl_point_light | int cr cg cb x y z --
	;
	
:render
	rl_frame_begin |rl_set_camera

	drawscene
	|'fsun rl_set_sun
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
	16 sh 40 -  fat
	"r3forth - DEMO 2q " ftext
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
    drop
	;

#ns 0
:load3d
	
	-2.0 ( 2.0 <?
		-2.0 ( 2.0 <?
		
		over 0 pick2
		$0 rxyz>q16
		4.0 $ffffff00 ns 97 + ns 
		ss3dset | x y z qxyzw scale color spr i --
		1 'ns +!
		
			1.0 + ) drop
		1.0 + ) drop
	;
	
:viewresize 
	sh sw rl_resizewin fixFontResize ;
	

: | <<<<< Boot
	"demo2q r3dv" 1024 768 GLini GLInfo
	glFixFont
	rl_init
	build_cube

	"media/ss/sprites" 512 ss3dload
	
	load3d
	
	'camEye 'camTo 'camUp rl_camera | 'eye 'to 'up --	
	
	8 'fsun memfloat
	'fsun rl_set_sun
	'viewresize SDLeventR
	calcam
	'main SDLshow
	
	SS3Dshutdown
	rl_shutdown
    GLend
	free_cube
	;