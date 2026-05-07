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

:mobj
	;
	
#modem 0
#lmodem 'mcam 'mobj
#lmodet "CAM" "OBJ" ( 0 )

#laxist "X" "Y" "Z" ( 0 )

:UsoMouse
	|sdlb
	
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
	$fffffff0 rl_setcolor
	draw_cube 
	
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

#gl 0
#ga 0
#gsx 1.0

:changeaxis
	ga 1+ 3 mod 'ga ! 
	ga gridpAxis! ;
	
:valax | d --
	'gl +! 
	gl gridplevel! ;
	
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
	ga 2* 'laxist + uiWrite
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