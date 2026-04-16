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
#cntobjs 0
#scale 2.0
#nrosprite 0

|------ pack 1 scale (8.8) + 3 rotation (0.16)
::packsrot | sx rx ry rz -- rp
	$ffff and swap 
	$ffff and 16 << or swap 
	$ffff and 32 << or swap
	8 >> $ffff and 48 << or 
	;

::+srot | ra rb -- rr
	+ $100010001 nand ;

|------ pack 3 vel in 63bits (21x3) (13.8) 
::pack21 | vx vy vz -- vp
	8 >> $1fffff and swap
	8 >> $1fffff and 21 << or swap
	8 >> $1fffff and 42 << or ;
	
::+p21 | va vb -- vr
	+ $40000200001 nand ;
	
::unpack21 | x -- px py pz
	dup 1 << 43 >> 8 << swap
	dup 22 << 43 >> 8 << swap
	43 << 43 >> 8 << ;

#cntbones 5
#bones * $fff
#mats * $ffff | dwords!!


#filer3a
#tx #ty #tz #rx #ry #rz #sc #pa
:parseline | adr -- adr'
	trim
	str>fnro 'tx ! str>fnro 'ty ! str>fnro 'tz !
	str>fnro 'rx ! str>fnro 'ry ! str>fnro 'rz !
	str>fnro 'sc ! ;
	
:loadr3a | "" --
	here dup 'filer3a !
	swap load 0 swap c!+ 'here !

	filer3a 
	"SKELETON" findstr 
	>>sp trim
	getnro 'cntbones ! |"cnt:%d" .println
	'bones >a
	0 ( cntbones <?
		|dup "%d." .print
		swap
		"JOINT" findstr 5 +
		trim getnro drop |"%d," .print
		trim 1+ >>str trim
		getnro 'pa ! | parent
		parseline
		tx ty tz pack21 a!+
		sc rx ry rz packsrot a!+
		$ff0000 32 << pa $ffff and or a!+
		0 a!+
		swap 1+ ) drop
	drop
	a> 'bones - "bones %d bytes" .println
	-1 a!+ | end
	;
	

:makeskel
	'bones >a
	0.0 0.0 0.0 pack21 a!+	| raiz
	2.0 0.0 0.0 0.0 packsrot a!+
	$ff00 32 << -1 $ffff and or a!+
	0 a!+

	0.0 2.0 0.0 pack21 a!+	| torso
	2.0 0.02 0.0 0.0 packsrot a!+
	$ff0000 32 << 0 $ffff and or a!+
	0 a!+

	1.5 0.5 0.0 pack21 a!+	| hombrol
	3.0 0.0 0.0 0.5 packsrot a!+
	$ff000000 32 << 1 $ffff and or a!+
	0 a!+

	-1.5 0.5 0.0 pack21 a!+	| hombror
	3.0 0.0 0.0 -0.5 packsrot a!+
	$ffff00 32 << 1 $ffff and or a!+
	0 a!+

	0.0 -1.0 0.0 pack21 a!+	| cadera
	4.0 0.0 0.0 0.0 packsrot a!+
	$ff00ff00 32 << 0 $ffff and or a!+
	0 a!+
	
	-1 a!+ | end
	;


|--- multiply
:mline | -- v
	da@+ db@ *. 16 b+
	da@+ db@ *. + 16 b+
	da@+ db@ *. + 16 b+
	da@+ db@ *. + ;
	
:mrow | adr -- adr'
	mline swap d!+ -44 b+ -16 a+
	mline swap d!+ -44 b+ -16 a+
	mline swap d!+ -44 b+ -16 a+
	mline swap d!+ -48 b+ -12 b+ ;
	
::dmat* | 'mat --
	ab[
	>b 'mat >a 'mati mrow mrow mrow mrow drop 
	]ba ;

	
:getmatrix | pos srot parent --
	>r 'mat >a ss3dcmat r>
	$ffff =? ( drop b> 'mat 8 move ; ) | dsc
	6 << 'mats + dmat* | fuente
	b> 'mati 8 move ;

:updatebones
	'mats >b
	'bones
	0 ( cntbones <? swap
		dup @+ swap @+ swap @ $ffff and	| pos srot parent
		getmatrix
		b> pick2 ss3dmat! | 'mat i --
		32 + 64 b+ 
		swap 1+ ) 2drop 
		
|	'mats >a | debug
|	0 ( 5 <? 0 ( 4 <? 0 ( 4 <? da@+ "%a " .print 1+ ) drop .cr 1+ ) drop .cr 1+ ) drop
|	"" .println
		
|	'mats >b | apply
|	0 ( cntbones <? 
|		b> over ss3dmat! | 'mat i --
|		64 b+ 
|		1+ ) drop 
	
		;

	
|    for (int i = 0; i < sc->njoint; i++) {
|        const JointPose *lp = &local[i];
|        Mat4 lm = local_matrix(lp->tx, lp->ty, lp->tz,
|                               lp->ex, lp->ey, lp->ez, lp->scale);
|        int par = sc->joints[i].parent;
|        wmat[i] = (par < 0) ? lm : mat4_mul(&wmat[par], &lm);


:updateobj
	'mats >b
	0 ( cntbones <?
		b> over ss3dmat! | 'mat i --
		128 b+ 1+ ) drop ;

|--------------------------------------
#ballid
	
:makeScene
	'bones >a
	( a@+ -1 <>? | pos
		unpack21
		a@+			| scale+rot
		a@+ 32 >>>	| color
		ballid
		cntobjs
		ss3dset | x y z srxyz color spr i --
		1 'cntobjs +!
		8 a+
		) drop ;
	

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
	scale 8 >> 48 <<
	$ffffff00
	nrosprite
	cntobjs
	ss3dset | x y z srxyz color spr i --
	1 'cntobjs +!
	;

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

	nrosprite ssnameid "[%l]" sprint uiLabelC
	
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
	
	
	<f1> =? ( makeScene )
	<f2> =? ( updatebones )
	<f3> =? ( 
		makeraydir hitground
		hit 1? (
			'raydir >a a@+ a@+ a@+ | x y z
			scale 8 >> 40 <<
			$ffffffff
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
	
	"point" ss3idname 
	dup .d .println
	'ballid !
	;
	
:viewresize 
	sh sw rl_resizewin 
	fixFontResize ;

: | <<<<<<<< Boot

	"Scene r3dv" 1024 768 GLini GLInfo


	"media\bvh\pajaro.r3a" 
	|"media\bvh\lobo.r3a" 
	loadr3a
|	makeskel	

	$fff vaini
	
	glFixFont
	load3d
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