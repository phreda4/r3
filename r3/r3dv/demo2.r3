| demo2 r3dv
| PHREDA 2026
^./renderlib.r3
^./rlhud.r3
^./rlshapes.r3
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


:drawscene
	matini 10.0 .1 10.0 matscale 0 -0.1 0 matpos 
	$5a5a5a20 draw_cube 
	
	msec 4 << sin 3.0 + | scale >
	
	dup | < scale
	97 
	$ffffff00 
	0 ss3dcs | scale spr color i --
	
	-2.5
	swap 97 ss3dfloor | < scale
	-2.5
	0 ss3dxyz | x y z i
	
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
 1.0 0.9 0.8 1.2
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

:ss3dh | n -- s
	;
	
#ns 0
:load3d
	"media/ss/sprites" 512 ss3dload
	-3.0 ( 3.0 <?
		-3.0 ( 3.0 <?
		
		over 0.5 +
		4.0 ns 80 + ss3dfloor | apoyado en el piso
		
		pick2 0.5 +
		$0 rxyz>q16
		4.0 ns 80 + $ffffff00 
		ns 
		ss3dset | x y z qxyzw scale spr color i --
		1 'ns +!
		
			1.0 + ) drop
		1.0 + ) drop		
	;
	
:viewresize 
	sh sw rl_resizewin fixFontResize ;
	

: | <<<<< Boot
	"demo2q r3dv" 1024 768 GLini GLInfo
	rlhud
	rl_init
	IniShapes

	load3d
	
	'camEye 'camTo 'camUp rl_camera | 'eye 'to 'up --	
	
	8 'fsun memfloat
	'fsun rl_set_sun
	'viewresize SDLeventR
	calcam
	'main SDLshow
	
	SS3Dshutdown
	endShapes
	rl_shutdown
    GLend
	;