| 3dworld 
| PHREDA 2026
|-----
^r3/lib/rand.r3
^r3/util/varanim.r3

^./renderlib.r3
^./rlhud.r3
^./ss3d.r3
^./glimm.r3
^./rlgrid.r3
|^./rllunar.r3

|---------------------------------
#objcnt 0
#objlst 0
#objnro 0

:.x		a> ;
:.y		a> 1 3 << + ;
:.z		a> 2 3 << + ;
:.q		a> 3 3 << + ;
:.info	a> 4 3 << + ;
:.vp	a> 5 3 << + ;
:.vr	a> 6 3 << + ;
|:.v	a> 7 3 << + ;

:]objs | n
	6 << objlst + ; | 8 cells
	
#randobj ( 95 117 112 111 )
:+obj
	objcnt ]objs >a | 8 cells
	|-15.0 15.0 randminmax 
	0 32 <<
	-0.1 0.1 randminmax
	$ffffffff and or
	a!+ | X
	
	|-5.0 5.0 randminmax 
	2.0 32 <<
	-0.1 0.1 randminmax
	$ffffffff and or
	a!+ | Y
	
	|-15.0 15.0 randminmax 
	0 32 <<
	-0.1 0.1 randminmax
	$ffffffff and or
	a!+ | Z
	
	|1.0 randmax 1.0 randmax 1.0 randmax	1.0 packq 
	0 rxyz>q16
	a!+ | Q
	objnro a!+
	
	4.0 
	4 randmax 'randobj + c@ 
	|$ffffff00 
	rand
	objnro
	ss3dcs | scale spr color i --

	1 'objnro +!
	1 'objcnt +!
	;

:upobj
	.x dup 
	@ dup 32 >> swap 32 << 32 >> + | .x v+pos
	dup abs 15.0 >? ( pick2 d@ neg pick3 d! ) drop
	swap 4 + d!

	.y dup 
	@ dup 32 >> swap 32 << 32 >> + | .x v+pos
	0.0 <? ( over d@ abs pick2 d! ) 
	8.0 >? ( over d@ neg pick2 d! ) 
	over d@ 0.001 - pick2 d!
	swap 4 + d!

	.z dup 
	@ dup 32 >> swap 32 << 32 >> + | .x v+pos
	dup abs 15.0 >? ( pick2 d@ neg pick3 d! ) drop
	swap 4 + d!
	
	|.vr
	msec 4 << $ffff and 16 << over $100020000400 * + rxyz>q16 
	.q ! | ROT
	;
	
:drawobjlst 
	objlst >a
	0 ( objcnt <? 
		upobj
		a@+ 32 >> 
		a@+ 32 >> 
		a> 3 3 << + @ $ffff and ss3difloor + 
		a@+ 32 >> 
		a@+ a@+ $ffff and ss3dxyzq | x y z q i --
		3 3 << a+
		1+ ) drop ;
		
|----- player
#vd #vr #vpz
#pxp #pyp #pzp
#prot

|------ Camera controls
#camEye -4.0 1.0 0.0
#camTo  0.0 0.0  0.0
#camUp  0.0 1.0  0.0

#camEyeD 0 0 0
#camDist 4.0
#camRot


:camera
	pyp pzp 0.6 + pxp 'camTo !+ !+ !

	prot 0.5 + neg camrot - 0.02 *. 'camrot +!
	
	'camEyeD >a
	camrot sincos 
	camDist *. pxp + a!+
	2.0 a!+
	camDist *. pyp + a!+
	
	'camEye >a 'camEyeD >b
	a@ b@+ over - 0.05 *. + a!+
	a@ b@+ over - 0.05 *. + a!+
	a@ b@+ over - 0.05 *. + a!+
	
	'camEye 'camTo 'camUp rl_camera | 'eye 'to 'up --	
	;
	
#estado 
#anima
#aniref ( 96 97 96 98 110 )

:correr | --
	1 estado =? ( drop ; ) 'estado !
	0 4 7.0 aniInit 'anima !
	1 'estado ! ;
	
:girar
	2 estado =? ( drop ; ) 'estado !
	0 2 7.0 aniInit 'anima !
	2 'estado ! ;

:parar
	0 0 0 aniInit 'anima !
	0 'estado !
	;
	
:saltar
	4 0 0 aniInit 'anima !
	3 'estado !
	;
	
:jugador
	'anima ani+timer!
	
	prot neg sincos 
	vd *. 'pxp +! 
	vd *. 'pyp +!
	vr prot + 'prot !

	pxp pzp 0.5 + pyp
	prot 0.25 + 2/ $ffff and 16 << rxyz>q16 
	4.0	
	anima aniFrame 'aniref + c@
	$ffffff00 
	0 ss3dset

	1.4 
	1.0 1.0 1.0 
	pxp pzp 2.0 + pyp
	rl_point_light | int cr cg cb x y z --
	
	camera
	
	|--- jump
	pzp vpz +
	0 <=? ( drop 0 'pzp ! 0 'vpz ! ; )
	'pzp !
	-0.001 'vpz +!	
	;

:hud
	fini
	2 'fscale !
	$ffffffff 'fcolor !
	16 16  fat "f1 +obj" ftext
	fend

	;
	
|-------------------------------
:juego
	vupdate
	rl_frame_begin
	|draw_lunar
	draw_grid
	|objupdate
	drawobjlst 
	jugador
	SS3Ddraw
	rl_frame_end
	
	hud
	GLUpdate
	
	SDLkey
	>esc< =? ( exit ) 	
	<f1> =? ( +obj ) 
	
	<w> =? ( 0.02 'vd ! correr ) >w< =? ( 0 'vd ! parar )
	<s> =? ( -0.02 'vd ! correr ) >s< =? ( 0 'vd ! parar )
	<a> =? ( 0.005 'vr ! girar ) >a< =? ( 0 'vr ! parar )
	<d> =? ( -0.005 'vr ! girar ) >d< =? ( 0 'vr ! parar )
	<esp> =? ( saltar vpz 0? ( 0.05 'vpz ! ) drop )
	
	drop
	;		

	
:jugar 
	ss3dreset
	0 'objcnt !
	1 'objnro !
	20 ( 1? 1- +obj ) drop
	|correr
	parar
	|0 sdl_ShowCursor
	'juego SDLShow 
	;
	
|-------------------------------------
:viewresize 
	sh sw rl_resizewin 
	fixFontResize ;

#fsun [ 
-0.5 8.0 -0.5 0
 1.0 1.0 1.0 2.0
 ]

:lightsun
	8 'fsun memfloat
	'fsun rl_set_sun
	;

:load3d
|	"media/ss/vox2" 
	"media/ss/sprites"
	dup 1024 ss3dload
	ss3loadnames
	
	|"point" ss3idname 'ballid !
	;
	
|-------------------------------------
: | <<<<<<<< Boot
	"play person" 1024 768 GLini GLInfo

	$fff vaini
	
	rlhud
	load3d
	rl_init 
	1 rl_grid_init
	|rl_lunar_init
	'viewresize SDLeventR
	lightsun

	0 'objcnt !
	here 'objlst !
	$ffff 'here +!
	
	jugar
	
	rl_grid_free 
	|rl_lunar_free
	rl_shutdown
	SS3Dshutdown
	GLend
	;