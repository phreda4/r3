| demo1 r3dv
| PHREDA 2026
^./renderlib.r3
^./rlhud.r3
^./rlshapes.r3
^./rl3dtile.r3
^./rlgridp.r3
^r3/lib/rand.r3
^./glimm.r3

| Camera controls
#cam_yaw  0  
#cam_pit  0
#camEye -10.0 2.0 2.0
#camTo  0.0 0.0  0.0
#camUp  0.0 1.0  0.0
#camFor 0 0 0 | forward
#camRig 0 0 0 | right

#cp #sp #cy #sy 

:makecam
	cam_yaw sincos 'cy ! 'sy !
	cam_pit -0.24 max 0.24 min 
	sincos 'cp ! 'sp !
	'camTo >a 'camEye >b
	b@+ cy cp *. + a!+
	b@+ sp + a!+
	b@+ sy cp *. + a!
	'camFor >a
	cy neg cp *. a!+
	sp neg a!+
	sy neg cp *. a!
	'camFor v3Nor
	'camRig >a
	sy a!+
	0 a!+
	cy neg a!+
	'camRig v3Nor
	'camEye 'camTo 'camUp rl_camera | 'eye 'to 'up --	
	;

#glevel 0
#gaxis 0

#camForMouse 0 0 0
#v3hit 0 0 0
#v3cursor 0 0 0

#xdir 
#ydir

:AdvMouse
	sdlx 2* fix. sw / 1.0 -
	camAsp *. camFov *. 'xdir !
	
	sdly 2* fix. sh / 1.0 -
	camFov *. 'ydir !
	
	'camForMouse >a
	'camFor @      'camRig @      xdir *. + 'camUp @      ydir *. + a!+
	'camFor 8 + @  'camRig 8 + @  xdir *. + 'camUp 8 + @  ydir *. + a!+
	'camFor 16 + @ 'camRig 16 + @ xdir *. + 'camUp 16 + @ ydir *. + a!+

	'camForMouse v3Nor
	;

:hiteye
	AdvMouse
	'camForMouse gaxis 3 << + @ 0? ( ; ) 
	'camEye gaxis 3 << + @ glevel - swap /. | t
	-? ( drop 0 ; ) neg
	'v3hit 'camEye v3=
	'v3hit 'camForMouse rot v3+*
	1 ;
	
:camVelMove | ve 'v3 -- ve
	over 2dup 
	'camEye -rot v3+*
	'camTo  -rot v3+*
	makecam ;
	
:blink
	msec $100 and? ( drop $0000ff00 ; ) 
	drop $ffffff00 ; 

:scursor
	gaxis
	0? ( drop 0.1 1.0 1.0 ; )
	1 =? ( drop 1.0 0.1 1.0 ; )
	drop 1.0 1.0 0.1 ;
	
:draw_cursor
	matini
	0 0 0 matrot
	|scursor
	1.0 dup dup 
	matscale
	'v3cursor >a 
	a@+ $ffff nand $7fff +
	a@+ $ffff nand $7fff +
	a@+ $ffff nand $7fff +
	matpos
	blink
	|$ffffff00
	draw_cube 	
	;

#xp #yp 
:movecam
	sdlx dup xp - 0.001 * 
	'cam_yaw +! 'xp !
	sdly dup yp - -0.001 * 
	cam_pit + |0.24 min -0.24 max 
	'cam_pit ! 'yp !
	makecam ;
	
:wheelcam
	SDLw 0? ( drop ; ) -0.4 *
	'camFor camVelMove drop ;

:moveobj
	hiteye 0? ( drop ; ) drop
	'v3cursor 'v3hit 3 move
	;
	
:movemouse
	sdlb 4 =? ( drop movecam ; ) drop
	moveobj 
	;
	
|--------------
	
#laxist "-X-" "-Y-" "-Z-" ( 0 )

| 0 = none
| 1 = over
| 2 = in (btn dwn)
| 3 = active
| 4 = active(outside)
| 5 = out
| 6 = click (btn up)
:UsoMouse
	immIni
	immMouse 0? ( drop ; ) 
	1 =? ( wheelcam )				| over
	2 =? ( sdlx 'xp ! sdly 'yp ! )	| in
	3 =? ( movemouse )				| active
	drop
	;
|----------------------------------------
#fsun [ 
-2.0 2.0 -2.0 0	| normal
 1.0 1.0 1.0 1.2  ] | color,intensidad

:luces
	'fsun rl_set_sun
	
	2.0 1.0 1.0 1.0
	'camEye @+ swap @+ swap @
	rl_point_light | int cr cg cb x y z --
	;
	
	
#va #vl #vu

#gsx 1.0

:changeaxis
	gaxis 1+ 3 mod 'gaxis ! 
	gaxis gridpAxis! ;
	
:valax | d --
	'glevel +! 
	glevel gridplevel! ;
	
:cgsx | d --
	'gsx +!
	gsx gridpsx! ;

#modedit 0

#imgatlas

|---------------------------------------------
#arena
#arena>

#tile 0
#tilesize $03f03f

#x1 #y1 #z1
#x2 #y2 #z2
#x4 #y4 #z4

:arenareset
	arena 'arena> ! ;
	
:searchtile | v -- i/-1
	arena> arena dup >b - 5 >> | 32
	( 1? 1- 
		db@ over =? ( drop b> arena - 5 >> ; ) 
		drop
		32 b+ ) drop
	-1 ;
	
:arena!+
	arena> >a
	
	x1 y1 z1 3dt3 da!+
	tile da!+
	
	x2 y2 z2 3dt3 da!+
	tile tilesize $fff and + da!+
	
	x4 x1 - x2 +
	y4 y1 - y2 +
	z4 z1 - z2 +
	3dt3 da!+
	tile tilesize + da!+
	
	x4 y4 z4 3dt3 da!+
	tile tilesize $fff000 and + da!+
	
	a> 'arena> !
	;
	
:genarena
	t3d_ini
	arena> arena dup >a - 5 >> | 32
	( 1? 1- 
		a@+ a@+ a@+ a@+ 
		t3d4q
		) drop
	t3d_end
	;

| build patch by axis
#deltaxis (
1 1 1 0 1 0 0 0 1
1 0 1 0 0 0 0 0 1
0 1 0 0 0 1 0 0 0
)

:addpanel
	hiteye 0? ( drop ; ) drop

	'deltaxis gaxis 9 * + >a
	'v3cursor
	@+ 16 >> 
	dup ca@+ + 'x1 !
	dup ca@+ + 'x2 !
	ca@+ + 'x4 !
	@+ 16 >> 
	dup ca@+ + 'y1 ! 
	dup ca@+ + 'y2 !
	ca@+ + 'y4 !
	@ 16 >>
	dup ca@+ + 'z1 !
	dup ca@+ + 'z2 !
	ca@ + 'z4 !
	
	arena!+
	genarena
	;

|-------------
:modetile
	1 'modedit ! ;
	
:changemode
	modedit
	1+
	$1 and
	'modedit !
	;

:panelatlas
	0.4 %w uiO
	$1f0000ff 'fcolor !
	gZoneAll frect

	

	imgatlas 10 32 
	400 400 imgdraw
	;

:interface
	fini
	1 'fscale !
	$ffffffff 'fcolor !
	
	uiFull
	32 uiN
	$1f0000ff 'fcolor !
	gZoneAll frect
	$ffffffff 'fcolor !
	'exit "Exit" uiTBtn
	'changemode "Mode" uiTBtn
	gaxis 2 << 'laxist + uiWrite
	arena> arena - 5 >> " %d " sprint uiWrite
|	'exit "PAINT" uiTBtn
|	'exit "ERASE" uiTBtn
|	'exit "SELECT" uiTBtn

|	'totop "T" uiTBtn
|	'tofront "F" uiTBtn
|	'toside "S" uiTBtn

	modedit 
	1 =? ( panelatlas ) 
	drop
	
	fend
	;
	
	
:main
	|---------
	rl_frame_begin
	draw_cursor
	draw3dtiles
	draw_gridp
	luces
	rl_frame_end
	|---------
	
	interface
	GLUpdate
	|---------
	UsoMouse
	
    sdlkey
	>esc< =? ( exit )
	<w> =? ( -0.05 'va ! ) >w< =? ( 0 'va ! )
	<s> =? ( 0.05 'va ! ) >s< =? ( 0 'va ! )
	<a> =? ( 0.04 'vl ! ) >a< =? ( 0 'vl ! )
	<d> =? ( -0.04 'vl ! ) >d< =? ( 0 'vl ! )
	<q> =? ( 0.04 'vu ! ) >q< =? ( 0 'vu ! )
	<e> =? ( -0.04 'vu ! ) >e< =? ( 0 'vu ! )
	
	<tab> =? ( changeaxis )
	<ctrl> =? ( changemode )
	<f2> =? ( 1.0 valax )
	<f3> =? ( -1.0 valax )
	
	<esp> =? ( addpanel )
		
    drop
	va 1? ( 'camFor camVelMove ) drop
	vl 1? ( 'camRig camVelMove ) drop
	vu 1? ( 'camUp camVelMove ) drop
	;


	
|---------------------------------------------
:interfaceatlas
	fini
	1 'fscale !
	$ffffffff 'fcolor !
	
	uiFull
	32 uiN
	$1f0000ff 'fcolor !
	gZoneAll frect
	$ffffffff 'fcolor !
	'exit "Exit" uiTBtn
	"- Atlas -" uiWrite
	fend
	;
	
:mainatlas
	rl_frame_begin
	
	draw_cursor
	draw3dtiles
	draw_gridp
	
	'fsun rl_set_sun	
	rl_frame_end

	interfaceatlas
	GLUpdate
	
    sdlkey
	>esc< =? ( exit )
	drop
	;

|---------------------------------------------
:viewresize 
	sh sw rl_resizewin fixFontResize ;

: | <<<<<< Boot
	"demo escena" 1024 768 GLini GLInfo
	rlhud
	"media/img/tileskenney.png" fimgload 'imgatlas !
	rl_init
	
	rl_gridp_init
	gaxis gridpAxis!
	glevel gridplevel!
	
	IniShapes
	
	8 'fsun memfloat
	
	'viewresize SDLeventR
	makecam
	
	ini3dtile
	|-----
	"media/img/tileskenney.png" rl_3datlas
	
	here 'arena ! 
	$fffff 'here +! | 1MB
	arenareset
	|-----
	'main SDLshow
	
	rl_gridp_free
	rl_shutdown
    GLend
	end3dtile
	endShapes
	;