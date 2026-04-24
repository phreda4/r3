| test demo animation
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
	rl_set_camera
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

#va #vl #vu


|----------------------------
	
:hiteye
	'camAdv 8 + @ 0? ( 'hit ! ; ) 
	'camEye 8 + @ swap /. | t
	-? ( drop 0 'hit ! ; ) neg
	'v3hit 'camEye v3=
	'v3hit 'camAdv rot v3+*	
	1 'hit !
	;
	
#cntobjs
#nrosprite
	
:addobj
	hiteye hit 0? ( drop ; ) drop
	'v3hit >a a@+ a@+ a@+ | x y z
	$000000000000 rxyz>q16 
	3.0
	$ffffff00
	nrosprite
	cntobjs
	ss3dset | x y z qxyzw scale color spr i --	
		
	1 'cntobjs +!
	;

#fileanim 
#cntbones
#cntanim
#anims
#skel 

#nstep
#nvel

:debugr3a |---debug
	cntbones "bones:%d" .println
	cntanim "anims:%d" .println
	anims
	cntanim ( 1? 1- swap 
		d@+ "anim %h " .println 
		swap ) 2drop
	"" .println
	skel 
	cntbones ( 1? 1- swap
		c@+ "%d " .print 
		swap ) drop
		"" .println
	dup fileanim - "%h" .println
	
	w@+ 'nstep !
	w@+ 'nvel !
	>a
	0 ( nstep <?
		a> w@+ 8 << "%f " .println
		>a
		0 ( cntbones <? 
			16 a+
			1+ ) drop
		1+ ) 2drop
	;
	
:loadr3a | "" --
	here dup 'fileanim !
	swap load 'here !
	fileanim
	d@+ "r3a" d@ <>? ( "bad file r3a" .println 2drop ; ) drop
	w@+ 'cntbones !
	w@+ 'cntanim !
	dup 'anims !
	cntanim 2 << +
	|dup 
	'skel !
	|cntbones 17 * +
	|drop
	
|	debugr3a
|	fileanim anims 3 2 << + d@ + 
|	w@+ "cntframes %d" .println 

|	; :a
	 
	fileanim anims 0 2 << + d@ + 
	4 + | frames/vel
	2 + | duracion
	>a
	skel
	0 ( cntbones <? swap 
		c@+ drop
		a@+ unpack21 a@+ 1.0 $ffffff00 nrosprite cntobjs
		ss3dset | x y z qxyzw scale color spr i --			
		1 'cntobjs +!
		swap 1+ ) 2drop
	;


#qx #qy #qz #qw | still in calcrot
#px #py #pz
#tx #ty #tz

:calcpos | ppos prot pos -- npos
	unpack21r 'px ! 'py ! 'pz !
	unpackq 'qx ! 'qy ! 'qz ! 'qw !
	qy pz *. qz py *. - 2* 'tx !
	qz px *. qx pz *. - 2* 'ty !
	qx py *. qy px *. - 2* 'tz !
	unpack21r	qw tx *. + qy tz *. qz ty *. - + px + | x
	swap		qw ty *. + qz tx *. qx tz *. - + py + | y 
	rot 		qw tz *. + qx ty *. qy tx *. - + pz + | z
	pack21
	;
	
:calcrot | rot -- nrot
	unpackq 'px ! 'py ! 'pz ! 'tz ! | pw=tz
	qw px *. qx tz *. + qy pz *. + qz py *. - | x
	qw py *. qx pz *. - qy tz *. + qz px *. + | y 
    qw pz *. qx py *. + qy px *. - qz tz *. + | z
    qw tz *. qx px *. - qy py *. - qz pz *. - | w
	pick3 dup *. pick3 dup *. + pick2 dup *. + over dup *. +
	sqrt. 1.0 swap /.
	packq*
	;
	
:calcw
	-? ( drop 
		a@+ b!+ | pos
		a@+ b!+ | rot
		; )
	4 << here + @+ swap @ | ppos prot 
	a@+ calcpos b!+ | keep qxyzw var
	a@+ calcrot b!+
	;

:calcpose | anim --
	2 << anims + d@ fileanim + 
	4 + | frames/vel
	| frame 0 
	2 + | duracion
	>a
	
	here >b
	skel
	0 ( cntbones <? swap
		c@+ calcw swap
		-16 b+
		b@+ unpack21 b@+ pick4 ss3dxyzq | x y z quat i --
		1+ ) 2drop ;

#baseanim
#cntframe

:setanim | anim --
	2 << anims + d@ fileanim + 
	w@+ 'cntframe !
	4 + 'baseanim !
	;

:calframe | frame --
	cntframe mod
	cntbones 4 << 2 + *
	baseanim +
	>a	
	here >b
	skel
	0 ( cntbones <? swap
		c@+ calcw swap
		-16 b+
		b@+ unpack21 b@+ pick4 ss3dxyzq | x y z quat i --
		1+ ) 2drop ;
	
|----------------------------------	
	
:totop
	'cam_yaw 0 cam_yaw 21 1.0 0 +vanim
	'cam_pit -0.25 cam_pit 21 1.0 0 +vanim
	'camEye >a
	a> 0.0 a@+ 21 1.0 0 +vanim | 'var end ini ease dur. start --
	a> 12.0 a@+ 21 1.0 0 +vanim | 'var end ini ease dur. start --
	a> 0.0 a@+ 21 1.0 0 +vanim | 'var end ini ease dur. start --
	;
	
:tofront
	'cam_yaw 0 cam_yaw 21 1.0 0 +vanim
	'cam_pit 0 cam_pit 21 1.0 0 +vanim
	'camEye >a
	a> -10.0 a@+ 21 1.0 0 +vanim | 'var end ini ease dur. start --
	a> 2.0 a@+ 21 1.0 0 +vanim | 'var end ini ease dur. start --
	a> 0.0 a@+ 21 1.0 0 +vanim | 'var end ini ease dur. start --
	;
	
:toside
	'cam_yaw -0.25 cam_yaw 21 1.0 0 +vanim
	'cam_pit 0 cam_pit 21 1.0 0 +vanim
	'camEye >a
	a> 0.0 a@+ 21 1.0 0 +vanim | 'var end ini ease dur. start --
	a> 2.0 a@+ 21 1.0 0 +vanim | 'var end ini ease dur. start --
	a> 10.0 a@+ 21 1.0 0 +vanim | 'var end ini ease dur. start --
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
|	'exit "eventos" uiTBtn
|	'exit "seleccion" uiTBtn
	'totop "T" uiTBtn
	'tofront "F" uiTBtn
	'toside "S" uiTBtn
	
	0.2 %cw uiO
	$1f00ff00 'fcolor !
	gZoneAll frect
	
	$ffffffff 'fcolor !
	"EDIT" uiLabelC
	
	'camEye @+ swap @+ swap @ "Eye: %a,%a,%a" sprint uiLabelC
	'camTo @+ swap @+ swap @ "To: %a,%a,%a" sprint uiLabelC
	'camUp @+ swap @+ swap @ "Up: %a,%a,%a" sprint uiLabelC
	'camAdv @+ swap @+ swap @ "Forw: %a,%a,%a" sprint uiLabelC
	'camLat @+ swap @+ swap @ "Right: %a,%a,%a" sprint uiLabelC

	cam_pit cam_yaw "Y:%a P:%a" sprint uiLabel

	|nrosprite ssnameid "[%l]" sprint uiLabelC
	
|	n3dsprites "ant:%h" sprint uiLabelC
|	cntobjs "objs:%d" sprint uiLabelC
|	nrosprite "spr:%d" sprint uiLabelC

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
	
	<f1> =? ( 1 setanim )
	<f2> =? ( 2 setanim )
	<f3> =? ( 3 setanim )	
	<f4> =? ( 0 setanim )	
	
|	<f3> =? ( 2 calcpose )
|	<pgup> =? ( nrosprite 1+ n3dsprites min 'nrosprite ! )
|	<pgdn> =? ( nrosprite 1- 0 max 'nrosprite ! )
	<esp> =? ( 
		addobj
		nrosprite 1+ n3dsprites mod 'nrosprite !
		)
	drop
	
	msec 6 >> calframe
	
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
	SS3Ddraw
	draw_grid
	light
	rl_frame_end

	hud
	GLUpdate
	;

:load3d
|	"media/ss/iti"
|	"media/ss/vox2" 
	"media/ss/sprites"
	dup 256 ss3dload
	ss3loadnames
	"point" ss3idname 'nrosprite !
	;
	

	
:viewresize 
	sh sw rl_resizewin 
	fixFontResize ;

: | <<<<<<<< Boot
	"Scene r3dv" 1024 768 GLini GLInfo

	$fff vaini
	
	glFixFont
	load3d
	|"media\bvh\pajaro.r3a" 
	"media\bvh\lobo.r3a" 
	|"media\bvh\persona.r3a" 
	|"media\bvh\animations.r3a"
	loadr3a
	|makeskel	
	1 setanim
	
	
	rl_init 
	rl_grid_init
	
	'viewresize SDLeventR
	lightsun
	makeCam
	tofront

	'main SDLshow
	
	rl_grid_free 
	rl_shutdown
	SS3Dshutdown
	GLend
	;