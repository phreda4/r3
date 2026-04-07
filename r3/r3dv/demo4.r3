| demo3 r3dv -- show sprites
| PHREDA 2026
^r3/lib/rand.r3

^./renderlib.r3
^./glfixfont.r3
^./geom.r3
^./ss3d.r3
^./glimm.r3


| Camera controls
#cam_yaw  -0.785398   | -PI/4
#cam_pit   0.45
#cam_dist  4.5
#cam_drag  0

| Mouse state
#mouse_x   0
#mouse_y   0
#mouse_btn 0

:drawgeom
	rl_ProgGeom
	matini 
	10.0 0.1 10.0 matscale 
	0 -0.55 0 matpos 
	$5a5a5a00 rl_setcolor 
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
	0.6 * 'cam_dist +!
	calcam
	;
	

#fsun [ 
-0.5 8.0 -0.5 0
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
	0 ( n3dsprites <? dup >r
	
		dup nbox / nbox 2/ - 1.2 *
|		10.0 randmax 5.0 -
		|1.0 randmax
		|dup 4 >> 8 - 1.0 *
		over 10 << msec 4 << + sin 1.0 + 2/
		pick2 nbox mod nbox 2/ - 1.2 *
|		pick2 $f and 8 - 1.0 *
		|10.0 randmax 5.0 -
		|$ffffffffffff randmax
		0
		4.0 8 >> 40 << or
		$ffffff00
		r> dup
		ss3dset
		1+ ) drop
	;
:render
	rl_frame_begin |rl_set_camera
| drawgeom
movespr	
	SS3Ddraw
	luz
	
	rl_frame_end
	;
	
:hud
	fini
	2 'fscale !
	$7f000000 'fcolor !
	8 sh 48 - 400 40 frect
	$ffffffff 'fcolor !
	16 sh 40 - fat
	"r3forth - DEMO 4 - GUI " ftext
	
	immIni
	immMouse
	1 =? ( wheelcam )				| over
	2 =? ( sdlx 'xp ! sdly 'yp ! )	| in
	3 =? ( movecam )				| active
	drop	
	
	|'fscale !
	10 10 180 46 immBox
	"Exit" immBtn
	'exit uiClk
	

	fend
	;
	
:main
	render
	hud
	
    GLUpdate
	
    sdlkey
	>esc< =? ( exit )
    drop
	;


:load3d
	"media/ss/sprites" 256 ss3dload
	|"media/ss/vox2" 512 ss3dload
|	"media/ss/mezcla" 512 ss3dload
|	"media/ss/voxi" 256 ss3dload
|	"media/ss/cars" 256 ss3dload
|	"media/ss/test" 256 ss3dload

	n3dsprites sqrt 'nbox !
	0 ( n3dsprites <? dup >r
	
		dup nbox / nbox 2/ - 1.1 *
|		10.0 randmax 5.0 -
		|1.0 randmax
		|dup 4 >> 8 - 1.0 *
		0
		pick2 nbox mod nbox 2/ - 1.1 *
|		pick2 $f and 8 - 1.0 *
		|10.0 randmax 5.0 -
		|$ffffffffffff randmax
		0
		4.0 8 >> 40 << or
		$ffffff00
		r> dup
		ss3dset
		1+ ) drop

	;
	
:viewresize sh sw rl_resizewin fixFontResize ;

: | <<<<<<<< Boot

	"demo3 r3dv" 1024 768 GLini GLInfo
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