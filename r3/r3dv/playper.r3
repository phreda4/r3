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


| Camera controls
#cam_yaw  0  
#cam_pit  0

#camEye -4.0 1.0 0.0
#camTo  0.0 0.0  0.0
#camUp  0.0 1.0  0.0
#camAdv 0 0 0 | forward
#camLat 0 0 0 | right

|----------------------
#cp #sp #cy #sy 

:makecam
	cam_yaw sincos 'cy ! 'sy !
	cam_pit -0.24 max 0.24 min 
	sincos 'cp ! 'sp !
	'camTo >a 'camEye >b
	b@+ cy cp *. + a!+ b@+ sp + a!+ b@+ sy cp *. + a!
	'camAdv >a
	cy neg cp *. a!+ sp neg a!+ sy neg cp *. a!
	'camAdv v3Nor
	'camLat >a
	sy a!+ 0 a!+ cy neg a!+
	'camLat v3Nor
	'camEye 'camTo 'camUp rl_camera | 'eye 'to 'up --	
	;

#vadv #vlat #vup
#xp #yp 
:movecam
	|sdlb 4 <>? ( drop ; ) drop
	sdlx dup xp - 0.001 * 'cam_yaw +! 'xp !
	sdly dup yp - -0.001 * 'cam_pit +! 'yp !
	makecam ;
	
:wheelcam
	SDLw 0? ( drop ; ) -0.4 *
	'camEye 'camAdv pick2 v3+*
	'camTo 'camAdv pick2 v3+*
	drop 
	makecam ;

:rotatemouse
	immIni
	immMouse
	1 =? ( wheelcam )				| over
	2 =? ( sdlx 'xp ! sdly 'yp ! )	| in
	3 =? ( movecam )				| active
	drop ;

:movecamera
	vadv 1? ( 
		'camEye 'camAdv pick2 v3+*
		'camTo 'camAdv pick2 v3+*
		makecam
		) drop
	vlat 1? (
		'camEye 'camLat pick2 v3+*
		'camTo 'camLat pick2 v3+*
		makecam
		) drop
	vup 1? (
		'camEye 'camUp pick2 v3+*
		'camTo 'camUp pick2 v3+*
		makecam
		) drop 
	;

|---------------------------------
#objcnt 0
#objlst 0
#objnro 0

|---------------------------------
| x y z rxyz sxyz vxyz vrxyz
| 1 2 3 4    5    6    7     
:.rxyz 	1 ncell+ ;
:.x		2 ncell+ ;
:.y		3 ncell+ ;
:.z		4 ncell+ ;

:.sxyz	5 ncell+ ;
:.vxyz	6 ncell+ ;
:.vrxyz	7 ncell+ ;
:.anim	8 ncell+ ;
:.va	9 ncell+ ;

#fhit
#cntobj 

:hit | mask pos -- pos
	-50.0 <? ( over 'fhit +! )
	50.0 >? ( over 'fhit +! )
	nip ;

:hitz | mask pos -- pos
	0.0 <? ( over 'fhit +! )
	90.0 >? ( over 'fhit +! )
	nip ;
	
:rhit	
	fhit 
	%1 and? ( b> 8 + dup @ neg swap ! )
	%10 and? ( b> 16 + dup @ neg swap ! )
	%100 and? ( b> 24 + dup @ neg swap !  )
	drop ;
	
:objexec | adr -- 
	dup 8 + >b
	|------- rot+pos obj
	0 'fhit ! 
	matini 
	b@+ %1 b@+ hit %10 b@+ hit %100 b@+ hitz | x y z
	

	|------- refresh & hit
	5 3 << + >b rhit
|	b@+ b> 5 3 << - dup @ rot +rota swap !
	b@+ b> 5 3 << - +! | +x
	b@+ b> 5 3 << - +! | +y
	b@+ b> 5 3 << - +! | +z
	
	|b@+ drawobjm
	
	ss3dxyzq | x y z quat i --
	;

	
:+obj
	objcnt 5 << objlst + >a

	-0.1 0.1 randminmax
	-0.1 0.1 randminmax
	-0.1 0.1 randminmax	
	pack21 a!+
	-5.0 5.0 randminmax
	-5.0 5.0 randminmax
	-5.0 5.0 randminmax
	pack21 a!+
	0 a!+
	objnro 
	a!+
	
|	-5.0 5.0 randminmax 
|	-5.0 5.0 randminmax
|	-5.0 5.0 randminmax	
	0 0 0 
	1.0 randmax 1.0 randmax 1.0 randmax	1.0 packq
	1.0 
	$ffffff00 
	$ff randmax or
|	12 
	n3dsprites randmax
	objnro ss3dset

	1 'objnro +!
	1 'objcnt +!
	;
||X    |Y   |Z
|           $1
|      $200000
| $40000000000
#hitbit
:checkhit | x y z -- x y z
	0 'hitbit !
	pick2 abs 6.0 >? ( $40000000000 'hitbit +! ) drop
	over abs 6.0 >? ( $200000 'hitbit +! ) drop
	dup abs 6.0 >? ( $1 'hitbit +! ) drop
	hitbit 0? ( drop ; ) | add
	dup $1fffff * | mask
	a> 16 - @	| add mask val
	over xor	| add mask pack
	rot over	| mask pack add pack
	+ pick2 and | mask pack p2
	rot not and or
	a> 16 - !
	;

::+w4 | ra rb -- rr
	+ $1000100010001 nand ;

::+p3 | va vb -- vr
	+ $40000200001 nand ;

:objupdate
	objlst >a
	objcnt ( 1? 1-
		|$200000 a> +!
		a@+ a@ +p3 dup a!+ | pos+
		unpack21
		checkhit
		8 a+			| rot+
		a@+
		ss3dxyz | x y z i --
		
		) drop ;
		
|----- player

#zz
#vd #vr #vpz
|-------------------------------
:juego
	vupdate
	rotatemouse
	movecamera

	rl_frame_begin
	
	draw_grid
	objupdate
	SS3Ddraw
	
	rl_frame_end
	GLUpdate
	
	SDLkey
	>esc< =? ( exit ) 	
	<f1> =? ( +obj ) 
	|<f2> =? ( 50 ( 1? 1 - objrand +objr2 ) drop ) 
	
	<up> =? ( 0.1 'vd ! ) >up< =? ( 0 'vd ! )
	<dn> =? ( -0.1 'vd ! ) >dn< =? ( 0 'vd ! )
	<le> =? ( 0.005 'vr ! ) >le< =? ( 0 'vr ! )
	<ri> =? ( -0.005 'vr ! ) >ri< =? ( 0 'vr ! )
	<esp> =? ( vpz 0? ( 0.4 'vpz ! ) drop )
|	<w> =? ( 0.1 'zz +! )
|	<s> =? ( -0.1 'zz +! )
	
	<w> =? ( -0.05 'vadv ! ) >w< =? ( 0 'vadv ! )
	<s> =? ( 0.05 'vadv ! ) >s< =? ( 0 'vadv ! )
	<a> =? ( 0.04 'vlat ! ) >a< =? ( 0 'vlat ! )
	<d> =? ( -0.04 'vlat ! ) >d< =? ( 0 'vlat ! )
	<q> =? ( 0.04 'vup ! ) >q< =? ( 0 'vup ! )
	<e> =? ( -0.04 'vup ! ) >e< =? ( 0 'vup ! )
	
	drop
	;		

:jugar 
	ss3dreset
	0 'objcnt !

	0 0.5 0 
	0.0 0.0 0.0 1.0 packq | $4000000000000000
	4.0
	$ffffff00 7 0 ss3dset

	0 1.05 0 
	0.0 0.0 0.0 1.0 packq
	3.0
	$ffffff00 3 1 ss3dset
	
	2 'objnro !
	makecam
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
	"media/ss/iti"
|	"media/ss/vox2" 
|	"media/ss/sprites"
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
	'viewresize SDLeventR
	lightsun

	0 'objcnt !
	here 'objlst !
	
	$ffff 'here +!
	
	jugar
	
	rl_grid_free 
	rl_shutdown
	SS3Dshutdown
	GLend
	;