| demo1 r3dv
| PHREDA 2026
^./renderlib.r3
^./geom.r3

| Camera controls
#cam_yaw  -0.785398   | -PI/4
#cam_pit   0.45
#cam_dist  4.5
#cam_drag  0

| Cube rotation
#cube_rot  0.0
#spinning  -1

| Mouse state
#mouse_x   0
#mouse_y   0
#mouse_btn 0

:drawscene
	rl_ProgGeom
	
	matini
	|msec 4 << 0 msec 3 << matrot
	|cube_rot cube_rot 2/ 0 matrot
	20.0 0.1 20.0 matscale
	0 -1.6 0 matpos
	$eeeeee30 rl_setcolor
	draw_cube 
	
	matini
	|msec 4 << 0 msec 3 << matrot
	cube_rot cube_rot 2/ 0 matrot
	0.8 dup dup matscale
	msec 3 << sin 2 * msec 4 << cos 0.3 + 0 matpos
	$fffffff0 rl_setcolor
	draw_cube 
	
	matini
	|msec 4 << 0 msec 3 << matrot
	cube_rot neg cube_rot 2/ 0.3 matrot
	0.8 dup dup matscale
	msec 3 << sin 2 * neg msec 4 << cos 0.3 + msec 2 << sin matpos
	$6f34fff3 rl_setcolor
	draw_cube 
	
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
	0.2 * 'cam_dist +!
	calcam
	;
	

#fsun [ 
-0.5 -1.0 -0.5 0	| normal
 1.0 1.0 1.0 0.2  ] | color,intensidad
	   
:render
	rl_frame_begin
	drawscene
	
	'fsun rl_set_sun
	
	1.5 0.2 0.2 1.0
	msec 3 << 
	dup cos -3 * 
	over sin -3 *
	rot sin 2.5 *.
	rl_point_light | int cr cg cb x y z --
	

	1.5 1.0 0.2 0.2
	msec 3 << 
	dup cos 3 * 
	over sin 3 *
	rot 0.5 + sin 2.5 *.
	rl_point_light | int cr cg cb x y z --
	
	rl_frame_end
	spinning 1? ( 0.004 'cube_rot +! ) drop
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
	<esp> =? ( spinning not 'spinning ! )
    drop
	;

:viewresize sh sw rl_resizewin ;


: | <<<<<< Boot
	"demo1 r3dv" 1024 768 GLini GLInfo
	rl_init
	build_cube
	8 'fsun memfloat
	|$1e1f53 GLpaper
	'viewresize SDLeventR
	'main SDLshow
	
	rl_shutdown
    GLend
	free_cube
	;