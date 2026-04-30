| 3dworld 
| PHREDA 2026
|-----
^r3/lib/rand.r3
^r3/util/varanim.r3

^./renderlib.r3
^./glfixfont.r3
^./ss3d.r3
^./glimm.r3
^./rlgrid.r3
|^./rllunar.r3

| Camera controls
#camEye -4.0 1.0 0.0
#camTo  0.0 0.0  0.0
#camUp  0.0 1.0  0.0

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
	
:+obj
	objcnt ]objs >a | 8 cells
	|-15.0 15.0 randminmax 
	0
	a!+ | X
	|-5.0 5.0 randminmax 
	2.0 
	a!+ | Y
	|-15.0 15.0 randminmax 
	0
	a!+ | Z
	|1.0 randmax 1.0 randmax 1.0 randmax	1.0 packq 
	0 rxyz>q16
	a!+ | Q
	objnro a!+
	|a!+
	-0.1 0.1 randminmax
	-0.1 0.1 randminmax
	-0.1 0.1 randminmax
	packv21 a!+
	
	4.0 
	|$ff randmax or
	|n3dsprites randmax
	114
	$ffffff00 
	objnro
	ss3dcs | scale spr color i --

	1 'objnro +!
	1 'objcnt +!
	;

||X    |Y   |Z
|           $1
|      $200000
| $40000000000
#hitbit
:hitwall | x y z -- x y z
	hitbit 0? ( drop ; ) | add
	dup $1fffff * | mask
	
	.vp @	| add mask val
	
	over xor	| add mask pack
	rot over	| mask pack add pack
	+ pick2 and | mask pack p2
	rot not and or
	
	.vp !
	;
	
:upobjlst
	objlst >a
	0 ( objcnt <?
		.vp @ unpackv21
	
		0 'hitbit !	
		
		rot .x @ +
		dup abs 15.0 >? (  $40000000000 'hitbit +! ) drop
		.x !
		
		swap .y @ +
		dup 
		0.2 <? ( $200000 'hitbit +! ) 
		8.0 >? ( $200000 'hitbit +! ) 
		drop
		.y !
		
		.z @ + 
		dup abs 15.0 >? ( $1 'hitbit +! ) drop
		.z !

		hitwall
		
		|.vr
		msec 4 << $ffff and 16 << over $10000000 * + rxyz>q16 
		.q ! | ROT
		
		64 a+ 1+ ) drop ;
	
:drawobjlst 
	upobjlst
	
	objlst >a
	0 ( objcnt <? 
		a@+ a@+ a@+ a@+ a@+ $ffff and ss3dxyzq | x y z q i --
		3 3 << a+
		1+ ) drop ;
		
|----- player
#vd #vr #vpz
#pxp #pyp #pzp
#prot

:jugador
	prot neg sincos 
	vd *. 'pxp +! 
	vd *. 'pyp +!
	vr prot + $ffff and 'prot !

	pxp pzp 0.5 + pyp
	prot 0.25 + 2/ $ffff and 16 << rxyz>q16 
	4.0	$ffffff00 
	|msec 8 >> $3 and 'walk + c@
	96
	0 ss3dset

	1.4 
	1.0 1.0 1.0 
	pxp pzp 2.0 + pyp
	rl_point_light | int cr cg cb x y z --
	
	|---- cam
	pyp 
	|0
	pzp
	pxp 'camTo !+ !+ !

	prot 0.5 + neg sincos 
	3 << pxp + 
	swap 3 << pyp +
	3.0 rot
	'camEye !+ !+ !
	
	'camEye 'camTo 'camUp rl_camera | 'eye 'to 'up --	
	
	|--- jump
	pzp vpz +
	0 <=? ( drop 0 'pzp ! 0 'vpz ! ; )
	'pzp !
	-0.01 'vpz +!	
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
	
	fini
	2 'fscale !
	$ffffffff 'fcolor !
	16 16  fat
	prot "r:%f " sprint ftext
	fend
	
	GLUpdate
	
	SDLkey
	>esc< =? ( exit ) 	
	<f1> =? ( +obj ) 
	
	<up> =? ( 0.02 'vd ! ) >up< =? ( 0 'vd ! )
	<dn> =? ( -0.02 'vd ! ) >dn< =? ( 0 'vd ! )
	<le> =? ( 0.005 'vr ! ) >le< =? ( 0 'vr ! )
	<ri> =? ( -0.005 'vr ! ) >ri< =? ( 0 'vr ! )
	<esp> =? ( vpz 0? ( 0.18 'vpz ! ) drop )
	
	drop
	;		

	
:jugar 
	ss3dreset
	0 'objcnt !
	1 'objnro !
	20 ( 1? 1- +obj ) drop
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
	
	glFixFont
	load3d
	rl_init 
	rl_grid_init
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