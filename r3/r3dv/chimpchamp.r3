| chimpchamp
| PHREDA 2026
^./renderlib.r3
^./ss3d.r3
^./rl3dtile.r3
^./rlshapes.r3
^./rlhud.r3

^./glimm.r3

^r3/lib/rand.r3
^r3/util/varanim.r3

|----------------------------------------
#fsun [ 
-2.0 2.0 -2.0 0	| normal
 1.0 1.0 1.0 1.2  ] | color,intensidad
	
|---------------------------------------------
#filename "mem/scratch.3dm"

#inifile | adr in here

|-- head 1024
#filepng * 512
#maxtile 8192
#tilex 0 #tiley 0
#tilesw 32 #tilesh 32

#__pad * 472 | 512-5*8

|---------------------------------------------

|------ Camera controls
#camEye -4.0 1.0 0.0
#camTo  0.0 0.0  0.0
#camUp  0.0 1.0  0.0

#camEyeD 0 0 0
#camDist 4.0
#camRot

|----- player
#vd #vr #vpz
#pxp #pyp #pzp
#prot
#anima

:camera
	pyp pzp pxp 'camTo !+ !+ !

	prot 0.5 + neg camrot - 0.02 *. 'camrot +!
	
	'camEyeD >a
	camrot sincos 
	camDist *. pxp + a!+
	3.0 a!+
	camDist *. pyp + a!+
	
	'camEye >a 'camEyeD >b
	a@ b@+ over - 0.05 *. + a!+
	a@ b@+ over - 0.05 *. + a!+
	a@ b@+ over - 0.05 *. + a!+
	
	'camEye 'camTo 'camUp rl_camera | 'eye 'to 'up --	
	;

:luces
	'fsun rl_set_sun

	1.4 
	1.0 1.0 1.0 
	pxp pzp 2.0 + pyp 1.0 +
	rl_point_light | int cr cg cb x y z --
	
|	2.0 1.0 1.0 1.0
|	'camEye @+ swap @+ swap @
|	rl_point_light | int cr cg cb x y z --
	;

|---------------------------------------------
#walk ( 16 17 16 18 ) 
	
:getframe
	anima aniFrame 	
	'walk + c@ ;
	
:jugador
	'anima ani+timer! 
	
	pxp pzp 0 ss3difloor + pyp
	prot 0.25 + 2/
	$ffff and 16 << rxyz>q16 
	5.0	
	|msec 8 >> $3 and 'walk + c@ 
	getframe
	$ffffff00 
	0 ss3dset
	
	|--- update
	prot neg sincos 
	vd *. 'pxp +! 
	vd *. 'pyp +!
	vr prot + 'prot !

	pzp vpz +
	0 <=? ( drop 0 'pzp ! 0 'vpz ! ; )
	'pzp !
	-0.01 'vpz +!		
	;
	
:quieto
	vd 0? ( drop ; ) drop
	0 'vd ! 
	0 0 7.0 aniInit 'anima ! ;
	
:camina | vd --
	vd =? ( drop ; ) 'vd !
	0 4 7.0 aniInit 'anima ! ;
	
|---------------------------------------------
#pelx #pely #pelz
#pelvx #pelvy #pelvz
#pelpot 0.08

:kick
	prot neg sincos 
	pelpot *. 'pelvx +!
	pelpot *. 'pelvy +!
	0.1 'pelvz +!
	;
	
:pelota
	pelx pelz 1 ss3difloor + pely
	pelx 2 >> $ffff and 16 << pely 3 >> $ffff and or rxyz>q16 
	2.0	
	32
	$ffffff00 
	1 ss3dset
	
	pelvx 1? ( dup 0.99 *.f 'pelvx ! )
	'pelx +! 
	pelvy 1? ( dup 0.99 *.f 'pelvy ! )
	'pely +! 
	
	pelz pelvz + 
	-? ( pelvz abs 0.8 *.f 'pelvz ! 
		0 nip ) 
	+? ( -0.01 'pelvz +! )
	'pelz ! 
	;
	
|---------------------------------------------
:main
	vupdate
	|--------- render
	rl_frame_begin

	draw3dtiles
	|matini 0.1 $fffffff1 draw_sphere 
	jugador
	pelota
	
	SS3Ddraw

	luces
	camera
		
	rl_frame_end

	GLUpdate
	
    sdlkey
	>esc< =? ( exit )

	<up> =? ( 0.03 camina ) >up< =? ( quieto )
	<dn> =? ( -0.03 camina ) >dn< =? ( quieto )
	<le> =? ( 0.005 'vr ! 0.02 camina ) >le< =? ( 0 'vr ! quieto )
	<ri> =? ( -0.005 'vr ! 0.02 camina ) >ri< =? ( 0 'vr ! quieto )
	<spc> =? ( vpz 0? ( 0.18 'vpz ! ) drop )

	<q> =? ( kick )
    drop
	;

|---------------------------------------------
#arena
#arena>

:load3dtile | -- 
	'filename filexist 0? ( drop ; ) drop
	here dup 'inifile !
	'filename load drop | here 'last
	'filepng inifile 1024 cmove
	'filepng maxtile ini3dtile | use here but not need
	|-- reload (ini3dtile trash it)
	inifile 'filename load | here 'last
	inifile 1024 + 'arena !
	dup 'arena> !
|	'here !
	arena arena> over - 5 >> swap 
	t3dstatic
	;
	
	
|---------------------------------------------
:viewresize 
	sh sw rl_resizewin fixFontResize ;

:load3d
	"media/ss/iti"
	dup 4096 ss3dload
	ss3loadnames
	
	|"point" ss3idname 'ballid !
	;

: | <<<<<< Boot
	"Chimp Champ" 1024 768 GLini GLInfo
	rlhud

	rl_init
	IniShapes
	8 'fsun memfloat
	
	load3dtile
	load3d	
	$ff vaini
	
	'viewresize SDLeventR	
	'main SDLshow

	rl_shutdown
    GLend
	end3dtile
	endShapes
	;