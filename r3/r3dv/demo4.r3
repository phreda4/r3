| demo4 - Small scene editor
| PHREDA 2026
^r3/lib/rand.r3
^r3/util/arr8.r3

^./renderlib.r3
^./glfixfont.r3
^./ss3d.r3
^./glimm.r3
^./rlgrid.r3


#objlist 0 0 

| Camera controls
#cam_drag  0

| Mouse state
#mouse_x   0
#mouse_y   0
#mouse_btn 0

#xp #yp 

#cam_yaw  0   | -PI/4
#cam_pit  0

#camAdv 0 0 0 | forward
#camLat 0 0 0 | right
#camAux 0 0 0 

:calCamera
	'camAdv 'camTO v3=
	'camAdv 'camEYE v3-
	'camAdv v3Nor | forward = normalize(TO - EYE);
	
	'camLat 'camAdv v3=
	'camLat 'camUp v3vec
	'camLat v3Nor | right = normalize(cross(forward, UP));
	
|	'camAux 'camAdv
	| Yaw alrededor de up
	'camAux 'camAdv cam_yaw v3rotY
	| Pitch alrededor de right
	'camAdv 'camAux 'camLat cam_pit v3rotAxis
    | Limitar pitch
    |forward.y = clamp(forward.y, -0.99f, 0.99f);
	'camAdv 8 + dup @ -0.99 max 0.99 min swap !
    |forward = normalize(forward);
	'camAdv v3Nor
	
    |to = eye + forward;	
	'camTo 'camEye v3=
	'camTo 'camAdv v3+
	rl_set_camera
	;
	
:movecam
	sdlb 4 <>? ( drop ; ) drop
	sdlx dup xp - -0.001 * 'cam_yaw ! 'xp !
	sdly dup yp - -0.001 * 'cam_pit ! 'yp !
	cam_yaw cam_pit or 0? ( drop ; ) drop
	calcamera ;
	
:wheelcam
	SDLw 0? ( drop ; ) 0.6 *
	'camEye 'camAdv pick2 v3+*
	'camTo 'camAdv pick2 v3+*
	drop
	rl_set_camera
	;	

:rotatemouse
	immMouse
	1 =? ( wheelcam )				| over
	2 =? ( sdlx 'xp ! sdly 'yp ! )	| in
	3 =? ( movecam )				| active
	drop	
	;
	
#sun 
-0.5 8.0 -0.5 0
-0.5 8.0 -0.5 0

#fsun [ 
-0.5 8.0 -0.5 0
 1.0 1.0 1.0 1.0
 ]

:lightsun
	8 'fsun memfloat
	'fsun rl_set_sun
	;
	   
:light
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

:render
	rl_frame_begin |rl_set_camera
	|movespr
	SS3Ddraw
	draw_grid
	
	light
	rl_frame_end
	;

#va
#vl

|----------------------------
#cntobjs 0
#scale 2.0
#nrosprite 0

:makescene
	;
	
:+obj | --
	;	
	
:addobj
	'camTo >a a@+ a@+ a@+ | x y z
	scale 8 >> 40 <<
	$ffffff00
	nrosprite
	cntobjs
	ss3dset | x y z srxyz color spr i --
	1 'cntobjs +!
	;
	
:interface
	1 'fscale !
	$ffffffff 'fcolor !

	uiFull
	0.05 %ch uiN
	$1f0000ff 'fcolor !
	gZoneAll frect
	$ffffffff 'fcolor !
	'exit "Exit" uiTBtn
	'exit "eventos" uiTBtn
	'exit "seleccion" uiTBtn
	
	0.2 %cw uiO
	$1f00ff00 'fcolor !
	gZoneAll frect
	
	$ffffffff 'fcolor !
	"EDIT" uiLabelC
	n3dsprites "cnt:%h" sprint uiLabelC
	cntobjs "objs:%d" sprint uiLabelC
	nrosprite "spr:%d" sprint uiLabelC
	'addobj "add" uiFTBtn	
	sdlb ">.%d.<" sprint uiLabelC
|	uiFill
|	$1fff0000 'fcolor !
|	gZoneAll frect
	
	|10 10 180 46 immBox "Exit" immBtn 'exit uiClk
	;
	
:hud
	fini
	immIni
	rotatemouse
	interface
	fend
	
	sdlkey
	>esc< =? ( exit )
	<w> =? ( 0.1 'va ! ) >w< =? ( 0 'va ! )
	<s> =? ( -0.1 'va ! ) >s< =? ( 0 'va ! )
	<a> =? ( -0.1 'vl ! ) >a< =? ( 0 'vl ! )
	<d> =? ( 0.1 'vl ! ) >d< =? ( 0 'vl ! )
	
	<pgup> =? ( nrosprite 1+ n3dsprites min 'nrosprite ! )
	<pgdn> =? ( nrosprite 1- 0 max 'nrosprite ! )
	
	<esp> =? ( addobj )
	drop
	;
	

:main
	render
	hud
	GLUpdate
	va 1? ( 
		'camEye 'camAdv pick2 v3+*
		'camTo 'camAdv pick2 v3+*
		rl_set_camera
		) drop
	vl 1? (
		'camEye 'camLat pick2 v3+*
		'camTo 'camLat pick2 v3+*
		rl_set_camera
		) drop	
	;

#names 

:load3d
|	"media/ss/sprites" 256 ss3dload
|	"media/ss/vox2" 512 ss3dload
|	"media/ss/mezcla" 512 ss3dload
|	"media/ss/voxi" 256 ss3dload
|	"media/ss/cars" 256 ss3dload
	"media/ss/test" 
	dup 256 ss3dload
	here dup 'names !
	swap sprint "%s.txt" load 0 swap c!+ 'here !
	n3dsprites sqrt 'nbox !

;
:a
	
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
	
	
:viewresize 
	sh sw rl_resizewin 
	fixFontResize ;

: | <<<<<<<< Boot

	"Scene r3dv" 1024 768 GLini GLInfo
	glFixFont
	rl_init 
	rl_grid_init
|	build_cube
	load3d
	'viewresize SDLeventR
	lightsun
	calCamera
	|1024 'objlist p8.ini
	
	'main SDLshow
	
	SS3Dshutdown
	rl_grid_free 
	rl_shutdown
    GLend
|	free_cube
	;