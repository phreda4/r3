| demo2 r3dv
| PHREDA 2026
^./renderlib.r3
^./glfixfont.r3
^./geom.r3
^./ss3d_q.r3

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

:drawscene
	rl_ProgGeom
	matini 10.0 .1 10.0 matscale 0 -0.6 0 matpos $5a5a5a00 rl_setcolor draw_cube 
	
	|drawsprites	
	msec 4 << sin 2.0 + 0 $ffffff00 0 ss3dcs
	|::ss3dcs | scale spr color i --
	SS3Ddraw
	;
	
:viewresize
    |0 0 vp_w vp_h glViewport vp_h vp_w /. 'vp_asp ! 
	;

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
|	3 'pEye 'fpEye mem2float
	|'camEye @+ swap @+ swap @ "%f %f %f" .println
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

:load3d
	"media/ss/iti" 10 ss3dload
	
	0 0 0 
	$0 rxyz>q16
	4.0 $ffffff00 0 0
	ss3dset | x y z qxyzw scale color spr i --
	
	|0 0   0   0   1.0 8 >> 48 << or $ff00ff00 0 0 ss3dset | x y z rxyz color spr i --
	|1.0 0 0.5   0   8.0 8 >> 48 << or $ffffff10 1 1 ss3dset | x y z rxyz color spr i --
	|1.0 0 0.2   0   7.0 8 >> 48 << or $ffffff20 2 2 ss3dset | x y z rxyz color spr i --
	|-1.4 0.4 -1.0 $7ff0 7.0 8 >> 48 << or $ffff00ff 3 3 ss3dset | x y z rxyz color spr i --
	;
	
:viewresize 
	sh sw rl_resizewin fixFontResize ;
	

: | <<<<< Boot
	"demo2q r3dv" 1024 768 GLini GLInfo
	glFixFont
	rl_init
	build_cube

	load3d
	
	8 'fsun memfloat
	'fsun rl_set_sun
	'viewresize SDLeventR
	'main SDLshow
	
	SS3Dshutdown
	rl_shutdown
    GLend
	free_cube
	;