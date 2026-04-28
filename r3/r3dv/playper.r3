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
#camEye -4.0 1.0 0.0
#camTo  0.0 0.0  0.0
#camUp  0.0 1.0  0.0

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
#pxp #pyp #pzp
#prot

#walk ( 7 8 7 9 ) 
#face ( 3 4 5 3 )

:jugador
	prot neg sincos 
	vd *. 'pxp +! 
	vd *. 'pyp +!
	vr prot + $ffff and 'prot !

	prot 0.25 + 2/
	$ffff and 16 << rxyz>q16 >r
	
	pxp pzp 0.5 + pyp
	r@
	4.0	$ffffff00 
	msec 8 >> $3 and 'walk + c@
	0 ss3dset

	pxp pzp 1.05 + pyp
	r>
	3.0 $ffffff00 
	msec 9 >> $3 and 'face + c@
	1 ss3dset
	
	1.4 
	1.0 1.0 1.0 
	pxp pzp 2.0 + pyp 1.0 +
	rl_point_light | int cr cg cb x y z --
	
	pyp pzp pxp 'camTo !+ !+ !

	prot 0.5 + neg sincos 
	3 << pxp + 
	swap 3 << pyp +
	4.0 rot
	'camEye !+ !+ !
	
	'camEye 'camTo 'camUp rl_camera | 'eye 'to 'up --	
	;

|-------------------------------
:juego
	vupdate

	rl_frame_begin
	
	draw_grid
	objupdate
	
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
	|<f2> =? ( 50 ( 1? 1 - objrand +objr2 ) drop ) 
	
	<up> =? ( 0.02 'vd ! ) >up< =? ( 0 'vd ! )
	<dn> =? ( -0.02 'vd ! ) >dn< =? ( 0 'vd ! )
	<le> =? ( 0.005 'vr ! ) >le< =? ( 0 'vr ! )
	<ri> =? ( -0.005 'vr ! ) >ri< =? ( 0 'vr ! )
	<esp> =? ( vpz 0? ( 0.4 'vpz ! ) drop )
|	<w> =? ( 0.1 'zz +! )
|	<s> =? ( -0.1 'zz +! )
	
	drop
	;		

	
:jugar 
	ss3dreset
	0 'objcnt !
	2 'objnro !
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