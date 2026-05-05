| demo1 r3dv
| PHREDA 2026
^./renderlib.r3
^./glfixfont.r3
^./rlgeom.r3

| Camera controls
#cam_yaw  -0.785398   | -PI/4
#cam_pit   0.45
#cam_dist  4.5
#cam_drag  0

#camEye -10.0 2.0 0.0
#camTo  0.0 0.0  0.0
#camUp  0.0 1.0  0.0

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
	cube_rot cube_rot 2/ 0 matrot
	0.8 dup dup matscale
	msec 2 << sin 2 * msec 3 << cos 0.3 + 0 matpos
	$fffffff0 rl_setcolor
	draw_cube 
	
	
	draw_planes
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
	'camEye 'camTo 'camUp rl_camera | 'eye 'to 'up --		
	;
:wheelcam
	SDLw 0? ( drop ; ) neg
	0.2 * 'cam_dist +!
	calcam
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
	spinning 1? ( 0.004 'cube_rot +! ) drop
	;
	
:main
	render
	
	fini
	2 'fscale !
	$7f000000 'fcolor !
	8 sh 48 - 400 40 frect
	$ffffffff 'fcolor !
	16 sh 40 - fat
	"r3forth - DEMO ESC " ftext
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
	<esp> =? ( spinning not 'spinning ! )
    drop
	;

:viewresize sh sw rl_resizewin fixFontResize ;


: | <<<<<< Boot
	"demo escena" 1024 768 GLini GLInfo
	glFixFont
	rl_init
	IniGeom
	
	8 'fsun memfloat
	
	'viewresize SDLeventR
	calcam
	
	IniPlanes
	"media/img/atlaspl.png" rl_load_atlas	
	
	'main SDLshow
	
	rl_shutdown
    GLend
	endGeom
	;