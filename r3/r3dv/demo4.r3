| demo3 r3dv -- show sprites
| PHREDA 2026
^r3/lib/rand.r3

^./renderlib.r3
^./rlhud.r3
^./ss3d.r3
^./rlgrid.r3

| Camera controls
#cam_yaw  0  
#cam_pit  0

#camEye -16.0 0.0 0.0
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
	b@+ cy cp *. + a!+ b@+ sp + a!+ b@+ sy cp *. + a!
	'camAdv >a
	cy neg cp *. a!+ sp neg a!+ sy neg cp *. a!
	'camAdv v3Nor
	'camLat >a 
	sy a!+ 0 a!+ cy neg a!+
	'camLat v3Nor
	'camEye 'camTo 'camUp rl_camera | 'eye 'to 'up --	
	;

#xp #yp 
:movecam
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
	immMouse
|	1 =? ( wheelcam )				| over
	2 =? ( sdlx 'xp ! sdly 'yp ! )	| in
	3 =? ( movecam )				| active
	drop	
	;

#fsun [ 
-0.5 -1.0 -0.5 0
 1.0 1.0 1.0 0.8
 ]
	   
#nbox	
:movespr
	0 ( n3dsprites <? 
		0
		over nbox / nbox 2/ - 1.0 *
		pick2 nbox mod nbox 2/ - 1.4 *
		|pick3 ss3dxyz | x y z i --	
		$a0000000
		pick4 ss3dxyzq | x y z q i --	
		1+ ) drop
	;

:render
	rl_frame_begin
	movespr	
	SS3Ddraw
	
	rl_frame_end
	;
	
:main
	render
	
	fini
	2 'fscale !
	$7f000000 'fcolor !
	8 sh 48 - 400 40 frect
	$ffffffff 'fcolor !
	16 sh 40 - fat
	"r3forth - PICKDEMO" ftext
	fend
	
    GLUpdate
	
	immIni
	immMouse
	1 =? ( wheelcam )				| over
	2 =? ( sdlx 'xp ! sdly 'yp ! )	| in
	3 =? ( movecam )				| active
	drop	
	
    sdlkey
	>esc< =? ( exit )
    drop
	;


:load3d
	"media/ss/sprites" 
	|"media/ss/iti"
	|"media/ss/vox2"
|	"media/ss/mezcla"
|	"media/ss/voxi"
|	"media/ss/cars"
|	"media/ss/test"

	dup 1024 ss3dload
	ss3loadnames
	
|	"clon" ss3idname .d .println
	
	n3dsprites 
	sqrt 'nbox !
	
	0 ( n3dsprites <? 
		4.0 over $ffffff00 over ss3dcs | scale spr color i --		
		1+ ) drop

	;
	
:viewresize 
	sh sw rl_resizewin 
	fixFontResize ;

: | <<<<<<<< Boot
	"demo4 select" 1024 768 GLini GLInfo
	rlhud
	rl_init
	
	load3d
	8 'fsun memfloat
	'fsun rl_set_sun
	'viewresize SDLeventR
	makecam
	'main SDLshow
	
	SS3Dshutdown
	rl_shutdown
	GLend
	;