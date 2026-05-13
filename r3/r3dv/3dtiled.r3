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
	
|----------------
	
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
	cam_pit + 0.24 min -0.24 max 
	'cam_pit ! 'yp !
	makecam ;
	
:wheelcam
	SDLw 0? ( drop ; ) -0.4 *
	'camFor camVelMove drop ;

:movecursor
	hiteye 0? ( drop ; ) drop
	'v3cursor 'v3hit 3 move
	;
	
	
|--------------
	
#laxist "-X-" "-Y-" "-Z-" ( 0 )

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
#gsy 1.0
#gsz 1.0

:changeaxis
	gaxis 1+ 3 mod 'gaxis ! gaxis gridpAxis! ;
	
:valax | d --
	'glevel +! glevel gridplevel! ;
	
:cgsx | d --
	'gsx +! gsx gridpsx! ;

:cgsy | d --
	'gsy +! gsy gridpsy! ;
	
:cgsz | d --
	'gsz +! gsz gridpsz! ;

|---------------------------------------------
#arena
#arena>

#modedit 0

#imgatlas
#imgatlash
#imgscale
#imgw #imgh

#tilex 0 
#tiley 0
#tilesw 64
#tilesh 64

:tilep1 tilex tiley 12 << or ;
:tilep2 tilex tilesw + tiley 12 << or ;
:tilep3 tilex tilesw + tiley tilesh + 12 << or ;
:tilep4 tilex tiley tilesh + 12 << or ;

#x1 #y1 #z1
#x2 #y2 #z2
#x4 #y4 #z4

:arenareset
	arena 'arena> ! ;
	
:arena!+
	arena> >a
	
	x1 y1 z1 3dt3 gaxis 30 << or da!+
	tilep1 da!+
	
	x2 y2 z2 3dt3 da!+
	tilep2 da!+
	
	x4 x1 - x2 +
	y4 y1 - y2 +
	z4 z1 - z2 +
	3dt3 da!+
	tilep3 da!+
	
	x4 y4 z4 3dt3 da!+
	tilep4 da!+
	
	a> 'arena> !
	;
	
:searchtile | v -- i/-1
	arena> arena dup >b - 5 >> | 32
	( 1? 1- 
		db@ pick2 =? ( 3drop b> arena - 5 >> ; ) 
		drop
		32 b+ ) 2drop
	-1 ;

:checktile | -- i/-1
	x1 y1 z1 3dt3 gaxis 30 << or 
	searchtile
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
1 1 1  1 1 0  0 1 0
1 1 0  0 0 0  0 1 0
0 1 0  1 1 0  0 0 0
)

:builcursor
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
	ca@ + 'z4 ! ;

:addtile
	|builcursor
	arena!+
	genarena ;

:deltile
	builcursor
	checktile -? ( drop ; )
	5 << arena + dup 32 + arena> over - 3 >> move
	-32 'arena> +!
	genarena ;
	
|-------------
:modetile
	1 'modedit ! ;
	
:changemode
	modedit
	1+
	$1 and
	'modedit !
	;

:cursortile
	|msec $100 and? ( drop ; ) drop
	$ffffffff 'fcolor !
	gzoneall 2drop
	tiley 390 imgw */ + 32 + swap | correct aspect
	tilex 390 imgw */ + 5 + swap 
	tilesw 390 imgw */
	tilesh 390 imgw */ | correct aspect
	rect
	;
	
:quant | v q -- v
	dup -rot / * ;
	
:seltile
	sdlx wix - imgw 390 */ tilesw quant
	sdly wiy - imgw 390 */ tilesh quant
	'tiley ! 'tilex !
	;
	
:mousetile |
	uiPush
	immBox immZone
	immMouse
	2 =? ( sdlx 'xp ! sdly 'yp ! )	| in
	3 =? ( seltile )				| active
	drop	
	uiPop
	;
	
:panelatlas
	180 uiO
	$7f0f0fff 'fcolor !
	gZoneAll frect
	$ffffffff 'fcolor !
	gsz gsy gsx "%a %a %a" sprint uiLabelC
	'exit "save" uiFTBtn	

	400 uiE
	$3fffffff 'fcolor !
	gZoneAll frect
	$ffffffff 'fcolor !
	
	tiley tilex imgh imgw "%dx%d : %dx%d" sprint uiLabelC
	
	imgatlas 
	gZoneAll 2drop
	32 + swap 5 + swap 390 imgatlash | x y w h 
	2over 2over mousetile | [ ]
	imgdraw
	cursortile
	;

#cachexyza

:hitnew?
	'v3cursor @+ 16 >> swap @+ 16 >> swap @ 16 >>  
	3dt3 gaxis 30 << or 
	cachexyza =? ( drop 0 ; ) 'cachexyza ! 1 ;

#moded 0

:setp 0 'moded ! ;
:sete 1 'moded ! ;
:sets 2 'moded ! ;
	
:paintile 
	hiteye 0? ( drop ; ) drop
	hitnew? 0? ( drop ; ) drop
	builcursor
	checktile +? ( drop ; ) drop
	addtile ;
	
:erasetile 
	hiteye 0? ( drop ; ) drop
	hitnew? 0? ( drop ; ) drop
	deltile ;
	
:selectile
	;
	
#modedlist 'paintile 'erasetile 'selectile

:movemouse
	sdlb 4 =? ( drop movecam ; ) drop
	movecursor
	moded 3 << 'modedlist + @ ex
	;
	
:clickmouse
	;

#grids 1
:gridc
	grids 1 xor 'grids ! ;
	
:btncolor
	moded =? ( drop stWarn ; ) drop stLigt ;

:interface
	fini
	immIni
	1 'fscale !
	$ffffffff 'fcolor !
	
	uiFull
	32 uiN
	$7fffffff 'fcolor !
	gZoneAll frect
	stDang
	'exit "Exit" uiTBtn
	stDark
	'changemode "Tiles" uiTBtn
	'gridc "G" uiTBtn
	
	0 btncolor 'setp "PAINT" uiTBtn
	1 btncolor 'sete "ERASE" uiTBtn
	2 btncolor 'sets "SELECT" uiTBtn

	gaxis 2 << 'laxist + uiWrite
	arena> arena - 5 >> " %d " sprint uiWrite


	modedit 
	1 =? ( panelatlas ) 
	drop
	
	uiFill
	immMouse
	1 =? ( wheelcam )				| over
	2 =? ( sdlx 'xp ! sdly 'yp ! )	| in
	3 =? ( movemouse )				| active
	6 =? ( clickmouse )				| release
	drop
	
	fend
	;
	
	
:main
	|--------- render
	rl_frame_begin
	|draw_cursor
	draw3dtiles
	grids 1? ( draw_gridp ) drop
	|matini 0.05 $fffffff1 draw_sphere 
	luces
	rl_frame_end
	|--------- HUD
	interface
	GLUpdate
	|---------
	
    sdlkey
	>esc< =? ( exit )
	<w> =? ( -0.1 'va ! ) >w< =? ( 0 'va ! )
	<s> =? ( 0.1 'va ! ) >s< =? ( 0 'va ! )
	<a> =? ( 0.1 'vl ! ) >a< =? ( 0 'vl ! )
	<d> =? ( -0.1 'vl ! ) >d< =? ( 0 'vl ! )
	<q> =? ( 0.1 'vu ! ) >q< =? ( 0 'vu ! )
	<e> =? ( -0.1 'vu ! ) >e< =? ( 0 'vu ! )
	
	<g> =? ( gridc )
	
	<ctrl> =? ( changemode )
	
	<tab> =? ( changeaxis )
	<up> =? ( 1.0 valax )
	<dn> =? ( -1.0 valax )
	
		
    drop
	va 1? ( 'camFor camVelMove ) drop
	vl 1? ( 'camRig camVelMove ) drop
	vu 1? ( 'camUp camVelMove ) drop
	;

|---------------------------------------------
:tileinfo | tx -- 
	pl_atlas_tex fimgtex 'imgatlas !
	imgatlas fimgwh
	2dup 'imgh ! 'imgw !
	390 pick2 */ 'imgatlash !
	390 fix. swap / 'imgscale !
	;
	
|---------------------------------------------
:viewresize 
	sh sw rl_resizewin fixFontResize ;

: | <<<<<< Boot
	"3dtile Editor" 1024 768 GLini GLInfo
	rlhud

	rl_init
	IniShapes
	
	rl_gridp_init
	gaxis gridpAxis!
	glevel gridplevel!
	
	8 'fsun memfloat
	
	'viewresize SDLeventR
	makecam
	
	ini3dtile
	|-----
	"media/img/tileskenney.png" rl_3datlas
	tileinfo
	
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