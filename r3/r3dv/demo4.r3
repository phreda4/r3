| demo4 - Small scene editor
| PHREDA 2026
^r3/lib/rand.r3
^r3/util/varanim.r3

^./renderlib.r3
^./glfixfont.r3
^./ss3d.r3
^./glimm.r3
^./rlgrid.r3

#objlist 0 0 

| Camera controls
#cam_yaw  0  
#cam_pit  0
#camAdv 0 0 0 | forward
#camLat 0 0 0 | right

|----------------------
#cp #sp #cy #sy 

#raydir 0 0 0

:makeraydir  
	'raydir 'camAdv v3=
	'raydir 'camlat 
	sdlx sw 2/ - 16 << sw 2/ / |camFov *. camAsp *.
	v3+*
	'raydir 'camup 
	sdly sh 2/ - 16 << sh 2/ / |camFov *.
	v3+*
	'raydir v3Nor
	;

#hit 0
#v3hit 0 0 0

:hitground
	'raydir 8 + @ 0? ( 'hit ! ; ) 
	'camEye 8 + @ swap /. | t
	-? ( drop 0 'hit ! ; ) neg
	'v3hit 'camEye v3=
	'v3hit 'raydir rot v3+*	
	1 'hit !
	;

:makecam
	cam_yaw sincos 'cy ! 'sy !
	cam_pit |-0.24 max 0.24 min 
	sincos 'cp ! 'sp !
	'camTo >a 'camEye >b
	b@+ cy cp *. + a!+
	b@+ sp + a!+
	b@+ sy cp *. + a!
	'camTo v3Nor
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
	rl_set_camera
	
	;

#xp #yp 
:movecam
	sdlb 4 <>? ( drop ; ) drop
	
	sdlx dup xp - 0.001 * 
	'cam_yaw +! 'xp !
	sdly dup yp - neg 0.001 * 
	cam_pit + |0.2 min -0.2 max 
	'cam_pit ! 'yp !
	makecam ;
	
:wheelcam
	SDLw 0? ( drop ; ) -0.4 *
	'camEye 'camAdv pick2 v3+*
	'camTo 'camAdv pick2 v3+*
	drop
	rl_set_camera ;

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
	   
:light2
	2.4 
	0.0 0.0 1.0
	msec 3 << 
	dup cos -5 * 
	over sin -3 * 1.0 +
	rot sin 4.5 *.
	rl_point_light | int cr cg cb x y z --

	2.2 
	1.0 0.0 0.0
	msec 3 << 
	dup cos 7 * 
	over sin 3 * 1.0 +
	rot 0.5 + sin 4.5 *.
	rl_point_light | int cr cg cb x y z --
	;
	
:light
	0.2
	1.0 1.0 1.0
	'camEye >a
	a@+ a@+ 1.0 + a@
	rl_point_light | int cr cg cb x y z --
	;

#nbox

#va #vl #vu

|----------------------------
#cntobjs 0
#scale 2.0
#nrosprite 0

:makescene
	;
	
:+obj | --
	;	
	
:hiteye
	'camAdv 8 + @ 0? ( 'hit ! ; ) 
	'camEye 8 + @ swap /. | t
	-? ( drop 0 'hit ! ; ) neg
	'v3hit 'camEye v3=
	'v3hit 'camAdv rot v3+*	
	1 'hit !
	;
	
:addobj
	hiteye hit 0? ( drop ; ) drop
	'v3hit >a a@+ a@+ a@+ | x y z
	scale 8 >> 40 <<
	$ffffff00
	nrosprite
	cntobjs
	ss3dset | x y z srxyz color spr i --
	1 'cntobjs +!
	;

	
:totop
	'cam_yaw 0 cam_yaw 21 1.0 0 +vanim
	'cam_pit -0.24 cam_pit 21 1.0 0 +vanim
	'camEye >a
	a> 0.0 a@+ 21 1.0 0 +vanim | 'var ini fin ease dur. start --
	a> 10.0 a@+ 21 1.0 0 +vanim | 'var ini fin ease dur. start --
	a> 2.0 a@+ 21 1.0 0 +vanim | 'var ini fin ease dur. start --
	'makecam  1.0 +vexe
	;
	
:tofront
	'cam_yaw 0 cam_yaw 21 1.0 0 +vanim
	'cam_pit 0 cam_pit 21 1.0 0 +vanim
	'camEye >a
	a> 0.0 a@+ 21 1.0 0 +vanim | 'var ini fin ease dur. start --
	a> 2.0 a@+ 21 1.0 0 +vanim | 'var ini fin ease dur. start --
	a> 10.0 a@+ 21 1.0 0 +vanim | 'var ini fin ease dur. start --
	'makecam  1.0 +vexe
	;
	
:toside
	'cam_yaw -0.24 cam_yaw 21 1.0 0 +vanim
	'cam_pit 0 cam_pit 21 1.0 0 +vanim
	'camEye >a
	a> 10.0 a@+ 21 1.0 0 +vanim | 'var ini fin ease dur. start --
	a> 1.0 a@+ 21 1.0 0 +vanim | 'var ini fin ease dur. start --
	a> 0.0 a@+ 21 1.0 0 +vanim | 'var ini fin ease dur. start --
	'makecam  1.0 +vexe
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
	'totop "View TOP" uiFTBtn
	'tofront "View FRONT" uiFTBtn
	'toside "View SIDE" uiFTBtn
	
	'camEye @+ swap @+ swap @ "Eye: %a,%a,%a" sprint uiLabelC
	'camTo @+ swap @+ swap @ "To: %a,%a,%a" sprint uiLabelC
	|'camUp @+ swap @+ swap @ "Up: %a,%a,%a" sprint uiLabelC
	
	n3dsprites "ant:%h" sprint uiLabelC
	cntobjs "objs:%d" sprint uiLabelC
	nrosprite "spr:%d" sprint uiLabelC
|	'raydir @+ swap @+ swap @ "%a %a %a" sprint uiLabelC
|	'addobj "+" uiFTBtn	

	;
	
:hud
	fini
	immIni
	rotatemouse
	interface
	fend
	
	sdlkey
	>esc< =? ( exit )
	<w> =? ( -0.05 'va ! ) >w< =? ( 0 'va ! )
	<s> =? ( 0.05 'va ! ) >s< =? ( 0 'va ! )
	<a> =? ( 0.04 'vl ! ) >a< =? ( 0 'vl ! )
	<d> =? ( -0.04 'vl ! ) >d< =? ( 0 'vl ! )
	<q> =? ( 0.04 'vu ! ) >q< =? ( 0 'vu ! )
	<e> =? ( -0.04 'vu ! ) >e< =? ( 0 'vu ! )
	
	<f1> =? ( 
		makeraydir hitground
		hit 1? (
			'raydir >a a@+ a@+ a@+ | x y z
			scale 8 >> 40 <<
			$ffffff00
			nrosprite
			cntobjs
			ss3dset | x y z srxyz color spr i --
			|1 'cntobjs +!
			) drop
		)
	
	<pgup> =? ( nrosprite 1+ n3dsprites min 'nrosprite ! )
	<pgdn> =? ( nrosprite 1- 0 max 'nrosprite ! )
	<esp> =? ( 
		addobj 
		nrosprite 1+ n3dsprites mod 'nrosprite !
		)
	drop
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
	vu 1? (
		'camEye 'camUp pick2 v3+*
		'camTo 'camUp pick2 v3+*
		rl_set_camera
		) drop
	;
	
:main
	vupdate
	makecam
	
	rl_frame_begin |rl_set_camera
	|movespr
	SS3Ddraw
	draw_grid
	light
	rl_frame_end

	hud
	GLUpdate
	;

#names 

:load3d
	"media/ss/iti"
|	"media/ss/vox2" 
|	"media/ss/sprites"	
	dup 256 ss3dload
	here dup 'names !
	swap "%s.txt" sprint 
	load 0 swap c!+ 'here !
|	n3dsprites sqrt 'nbox !
	;
	
:viewresize 
	sh sw rl_resizewin 
	fixFontResize ;

: | <<<<<<<< Boot

	"Scene r3dv" 1024 768 GLini GLInfo
	
	$fff vaini
	
	glFixFont
	load3d
	rl_init 
	rl_grid_init
|	build_cube
	
	'viewresize SDLeventR
	lightsun
	makeCam
	
	|1024 'objlist p8.ini
	
	'main SDLshow
	
	
|	free_cube	
	rl_grid_free 
	rl_shutdown
	SS3Dshutdown
	GLend
	;