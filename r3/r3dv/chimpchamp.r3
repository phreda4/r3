| chimpchamp
| PHREDA 2026
^./renderlib.r3
^./ss3d.r3
^./rl3dtile.r3
^./rlshapes.r3
^./rlhud.r3

^./glimm.r3

^r3/lib/rand.r3

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
#arena
#arena>

:genarena
	arena arena> over - 5 >> swap t3dstatic ;

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

:camera
	pyp pzp pxp 'camTo !+ !+ !

	prot 0.5 + neg camrot - 0.02 *. 'camrot +!
	
	'camEyeD >a
	camrot sincos 
	camDist *. pxp + a!+
	1.0 a!+
	camDist *. pyp + a!+
	
	'camEye >a 'camEyeD >b
	a@ b@+ over - 0.05 *. + a!+
	a@ b@+ over - 0.05 *. + a!+
	a@ b@+ over - 0.05 *. + a!+
	
	'camEye 'camTo 'camUp rl_camera | 'eye 'to 'up --	
	;


:luces
	'fsun rl_set_sun
	
	2.0 1.0 1.0 1.0
	'camEye @+ swap @+ swap @
	rl_point_light | int cr cg cb x y z --
	;

#walk ( 16 17 16 18 ) 
	
:jugador
	pxp pzp 0.5 + pyp
	
	prot 0.25 + 2/
	$ffff and 16 << rxyz>q16 
	
	5.0	
	msec 8 >> $3 and 'walk + c@ 
	$ffffff00 
	0 ss3dset
	
	1.4 
	1.0 1.0 1.0 
	pxp pzp 2.0 + pyp 1.0 +
	rl_point_light | int cr cg cb x y z --
	
	camera

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
	
:main
	|--------- render
	rl_frame_begin

	
	matini 0.1 $fffffff1 draw_sphere 
	jugador
	SS3Ddraw
	draw3dtiles
	
	rl_frame_end

	GLUpdate
	
    sdlkey
	>esc< =? ( exit )

	<up> =? ( 0.02 'vd ! ) >up< =? ( 0 'vd ! )
	<dn> =? ( -0.02 'vd ! ) >dn< =? ( 0 'vd ! )
	<le> =? ( 0.005 'vr ! ) >le< =? ( 0 'vr ! )
	<ri> =? ( -0.005 'vr ! ) >ri< =? ( 0 'vr ! )
	<esp> =? ( vpz 0? ( 0.18 'vpz ! ) drop )

    drop
	;

|---------------------------------------------
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
	'here !
	genarena 
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

	'viewresize SDLeventR	
	'main SDLshow

	rl_shutdown
    GLend
	end3dtile
	endShapes
	;