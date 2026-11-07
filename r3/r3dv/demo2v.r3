|MEM 64
| demo2v r3dv - igual que demo2 pero con ss3d2 (formato .ssv)
| PHREDA 2026
^./renderlib.r3
^./rlshapes.r3
^./ss3d2.r3

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
	0 
	$ffffff00 
	0 ss3dcs | scale spr color i --
	
	-2.5
	swap 0 ss3dfloor | < scale
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
:sp | -- n	; sprite a mostrar (cicla por los del archivo)
	ns n3dsprites mod ;

:load3d
	"r3/r3dv/ss3d2/mexcla" 512 ss3dload
	-3.0 ( 3.0 <?
		-3.0 ( 3.0 <?

		over 0.5 +
		2.5 sp ss3dfloor | apoyado en el piso
		pick2 0.5 +
		$0 rxyz>q16
		2.5 sp $ffffff00
		ns
		ss3dset | x y z qxyzw scale spr color i --
		1 'ns +!

			1.0 + ) drop
		1.0 + ) drop
	;

:viewresize 
	sh sw rl_resizewin ;
	

: | <<<<< Boot
	"demo2q r3dv" 1024 768 GLini GLInfo
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