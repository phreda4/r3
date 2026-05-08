| demo1 r3dv
| PHREDA 2026
^./renderlib.r3
^./glfixfont.r3
^./rlgeom.r3
^./rl3dtile.r3
^./rlgridp.r3
^r3/lib/rand.r3
^./glimm.r3

| Camera controls
#cam_yaw  0  
#cam_pit  0
#camEye -10.0 2.0 0.0
#camTo  0.0 0.0  0.0
#camUp  0.0 1.0  0.0
#camAdv 0 0 0 | forward
#camLat 0 0 0 | right

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
	makecam ;


:mcam
	immMouse
	1 =? ( wheelcam )				| over
	2 =? ( sdlx 'xp ! sdly 'yp ! )	| in
	3 =? ( movecam )				| active
	drop
	;

#glevel 0
#gaxis 0

#camAdvMouse 0 0 0
#v3hit 0 0 0
#v3cursor 0 0 0

:hiteye
	'camAdvMouse gaxis 3 << + @ 0? ( ; ) 
	'camEye gaxis 3 << + @ glevel - swap /. | t
	-? ( drop 0 ; ) neg
	'v3hit 'camEye v3=
	'v3hit 'camAdvMouse rot v3+*
	1 ;
	
	
#xdir 
#ydir

:AdvMouse
	sdlx 2* fix. sw / 1.0 -
	camAsp *. camFov *. 'xdir !
	
	sdly 2* fix. sh / 1.0 -
	camFov *. 'ydir !
	
	'camAdvMouse >a
	'camAdv @      'camLat @      xdir *. + 'camUp @      ydir *. + a!+
	'camAdv 8 + @  'camLat 8 + @  xdir *. + 'camUp 8 + @  ydir *. + a!+
	'camAdv 16 + @ 'camLat 16 + @ xdir *. + 'camUp 16 + @ ydir *. + a!+

	'camAdvMouse v3Nor
	;
	
:draw_cursor
	matini
	0 0 0 matrot
	1.0 dup dup matscale
	'v3cursor >a 
	a@+ $ffff nand $7fff +
	a@+ $ffff nand $7fff +
	a@+ $ffff nand $7fff +
	matpos
	$0000ff00 rl_setcolor
	draw_cube 	
	;

:moveobj
	AdvMouse
	hiteye 0? ( drop ; ) drop
	'v3cursor 'v3hit 3 move
	;
	
:mobj
	immMouse
	1 =? ( wheelcam )				| over
	2 =? ( sdlx 'xp ! sdly 'yp ! moveobj )	| in
	3 =? ( moveobj )				| active
	drop
	;
	
#modem 0
#lmodem 'mcam 'mobj
#lmodet "CAM" "OBJ" ( 0 )
#laxist "X" "Y" "Z" ( 0 )

:UsoMouse
	immIni
	'lmodem modem ncell+ @ ex
	;
|----------------------------------------
#fsun [ 
-2.5 2.0 -1.5 0	| normal
 1.0 1.0 1.0 1.2  ] | color,intensidad

:drawscene
	rl_ProgGeom
	
	matini
	msec 1 << 0 msec 2 << matrot
	0.8 dup dup matscale
	msec 2 << sin 2 * msec 3 << cos 0.3 + 0 matpos
	$ffffff00 rl_setcolor
	draw_cube 

	draw_cursor
	
	draw3dtiles

	draw_gridp
	;
	   
:render
	rl_frame_begin
	drawscene
	
	'fsun rl_set_sun
	
	1.5 1.0 0.2 0.2
	msec 3 << 
	dup cos 3 * 
	over sin 3 *
	rot 0.5 + sin 2.5 *.
	rl_point_light | int cr cg cb x y z --
	
	rl_frame_end
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
|	'exit "eventos" uiTBtn
|	'exit "seleccion" uiTBtn
|	'totop "T" uiTBtn
|	'tofront "F" uiTBtn
|	'toside "S" uiTBtn
	modem 2 << 'lmodet + uiWrite
	" " uiWrite
	gaxis 2* 'laxist + uiWrite
	glevel " Level:%a " sprint uiWrite
	
	'camAdvMouse >a a@+ a@+ a@
	" %f %f %f " sprint uiWrite
	
	
	fend
	;
	
:main
	render
	interface
	GLUpdate
	UsoMouse
	
    sdlkey
	>esc< =? ( exit )
	<w> =? ( -0.05 'va ! ) >w< =? ( 0 'va ! )
	<s> =? ( 0.05 'va ! ) >s< =? ( 0 'va ! )
	<a> =? ( 0.04 'vl ! ) >a< =? ( 0 'vl ! )
	<d> =? ( -0.04 'vl ! ) >d< =? ( 0 'vl ! )
	<q> =? ( 0.04 'vu ! ) >q< =? ( 0 'vu ! )
	<e> =? ( -0.04 'vu ! ) >e< =? ( 0 'vu ! )	
	<f1> =? ( changeaxis )
	<f2> =? ( 1.0 valax )
	<f3> =? ( -1.0 valax )
	<f4> =? ( 0.1 cgsx )
	<f5> =? ( -0.1 cgsx )
	<tab> =? ( modem 1 xor 'modem ! )
    drop
	va 1? ( 
		'camEye 'camAdv pick2 v3+*
		'camTo 'camAdv pick2 v3+*
		makecam
		) drop
	vl 1? (
		'camEye 'camLat pick2 v3+*
		'camTo 'camLat pick2 v3+*
		makecam
		) drop
	vu 1? (
		'camEye 'camUp pick2 v3+*
		'camTo 'camUp pick2 v3+*
		makecam
		) drop	
	;

#tile
:maket3d
	t3d_ini
	-20 ( 20 <? 
		-20 ( 20 <? 
		
			5 8 randminmax 64 * 12 << 
			16 randmax 64 * or
			'tile !
			
			$000000 tile +
			pick2 pick2 -8 t3dv
			$00003f tile +
			pick2 pick2 1+ -8 t3dv
			$03f03f tile +
			pick2 1+ pick2 1+ -8 t3dv
			$03f000 tile +
			pick2 1+ pick2 -8
			t3dq
		
			1+ ) drop
		1+ ) drop

	t3d_end
	;


:viewresize 
	sh sw rl_resizewin fixFontResize ;

: | <<<<<< Boot
	"demo escena" 1024 768 GLini GLInfo
	glFixFont
	rl_init
	
	
	
	
	rl_gridp_init
	gaxis gridpAxis!
	glevel gridplevel!
	
	IniGeom
	
	8 'fsun memfloat
	
	'viewresize SDLeventR
	makecam
	
	ini3dtile
	"media/img/tileskenney.png" rl_3datlas	
	maket3d
	
	'main SDLshow
	
	rl_gridp_free
	rl_shutdown
    GLend
	end3dtile
	endGeom
	;