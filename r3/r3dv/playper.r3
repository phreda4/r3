| 3dworld 
| PHREDA 2026
|-----
^r3/lib/rand.r3
^r3/util/varanim.r3
^r3/util/arr16.r3

^./renderlib.r3
^./glfixfont.r3
^./ss3d.r3
^./glimm.r3
^./rlgrid.r3


| Camera controls
#cam_yaw  0  
#cam_pit  0
#camEye -10.0 2.0 0.0
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
	'camEye 'camTo 'camUp rl_camera | 'eye 'to 'up --	
	;


#listobj 0 0
#listfx 0 0

|---------------------------------
|disparo
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

#o1 * 80
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

	
:+obj | obj vz vy vx vrzyx z y x rzyx --
	'objexec 'listobj p!+ >a 
	a!+ a!+ a!+ a!+ 
	a!+ a!+ a!+ a!+ 
	a! ;
	
:objrand
	cntobj randmax 3 << 'o1 + @ ;
	
:velrot 0.01 randmax 0.005 - ;
:velpos 0.5 randmax 0.25 - ;
	
:+objr
	velpos velpos velpos |vz |vy |vx
|	velrot velrot velrot packrota |vrz |vry |vrx
	0 0 0 
	0 | 0 0 0 packrota
	+obj ;

:+objr2
	0 0 0 
	0

	0	| pos z
	20 randmax 10 - 2.0 * | pos y
	20 randmax 10 - 2.0 * | pos x	
	$ffff randmax $ffff randmax $ffff randmax
|	packrota
	+obj ;

|----- player


#zz
#vd #vr #vpz
|-------------------------------	
:juego
	vupdate
	makecam
	
	rl_frame_begin
	
	SS3Ddraw
	draw_grid
	'listobj p.draw
	
	
	rl_frame_end

	GLUpdate
	
	SDLkey
	>esc< =? ( exit ) 	
	<f1> =? ( 50 ( 1? 1 - objrand +objr ) drop ) 
	<f2> =? ( 50 ( 1? 1 - objrand +objr2 ) drop ) 
	
	<up> =? ( 0.1 'vd ! ) >up< =? ( 0 'vd ! )
	<dn> =? ( -0.1 'vd ! ) >dn< =? ( 0 'vd ! )
	<le> =? ( 0.005 'vr ! ) >le< =? ( 0 'vr ! )
	<ri> =? ( -0.005 'vr ! ) >ri< =? ( 0 'vr ! )
	<esp> =? ( vpz 0? ( 0.4 'vpz ! ) drop )
	<w> =? ( 0.1 'zz +! )
	<s> =? ( -0.1 'zz +! )
	

	drop ;		


	
:jugar 
	'listfx p.clear
	'listobj p.clear
|	20 ( 1? 1-
|		objrand +objr2
|		) drop
		0 0 0 
		0.0 0.0 0.0 1.0 packq
		4.0
		$ffffff00
		1
		0
		ss3dset
	'juego SDLShow 
	;
	
|-------------------------------------
:viewresize 
	sh sw rl_resizewin 
	fixFontResize ;

#fsun [ 
-0.5 8.0 -0.5 0
 1.0 1.0 1.0 1.0
 ]

:lightsun
	8 'fsun memfloat
	'fsun rl_set_sun
	;


:load3d
	"media/ss/iti"
|	"media/ss/vox2" 
|	"media/ss/sprites"
	dup 256 ss3dload
	ss3loadnames
	
	|"point" ss3idname 'ballid !
	;

: | <<<<<<<< Boot
	"play person" 1024 768 GLini GLInfo

	$fff vaini
	
	glFixFont
	load3d
	rl_init 
	rl_grid_init

	100 'listfx p.ini
	200 'listobj p.ini
	
	'viewresize SDLeventR
	lightsun

	jugar
	
	rl_grid_free 
	rl_shutdown
	SS3Dshutdown
	GLend
	;