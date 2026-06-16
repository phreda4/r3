| block editor in 3d
| PHREDA 2026
|-----
^./renderlib.r3
^./ss3d.r3

#xi -4.5 #yi 3.4 #zi 5.0
#dx 0.25 #dy -0.4

#conw 44
#conh 32
#conmem
#curx #cury #curatr

#iniobj 0
#charq
#xc #yc

:drawcar | colorchar --
	3.0 swap
	dup $ff and 
	32 =? ( 3drop ; )
	2 - 
	swap $ffffff00 and 
	iniobj ss3dcs
	
	zi yc xc charq 
	iniobj ss3dxyzq
	
	1 'iniobj +!
	;
	
:drawconsole
	conmem >a
	1 'iniobj !
	yi 'yc ! 
	0 ( conh <?
		xi 'xc !
		0 ( conw <?
			da@+ drawcar
			dx 'xc +!
			1+ ) drop
		dy 'yc +!
		1+ ) drop ;
		
:drawcursor
	|msec 7 << $10000 and $ffff or 
	2.0
	21
	$ffffff01 
	0 ss3dcs
	
	zi yi cury dy * + xi curx dx * +
	charq 
	0 ss3dxyzq
	;
		
:3dpos | x y -- adr
	conw * + 2 << conmem + ;
	
:3dcls | --
	conmem 0 conw conh * dfill |dvc		
:3dhome | -- 
	0 'curx ! 0 'cury ! ;

:3dcolor | rgb --
	8 << 'curatr ! ;
	
:3dat | x y --
	'cury ! 'curx ! ;

:3dup
	cury 1-
	0 <? ( drop conh 1- )
	'cury !	;
:3ddn
	cury 1+
	conh >=? ( 0 nip ) 
	'cury ! ;
	
:3dle
	curx 1- 
	0 <? ( drop conw 1- )
	'curx ! ;
	
:3dri
	curx 1+ 
	conw >=? ( 0 nip ) 
	'curx ! ;

:3dcr
	0 'curx ! 3ddn ;
		
:3demit | nro --
	$ff and curatr or curx cury 3dpos d! 
	3dri ;
	
:3dwrite | "" --
	curx cury 3dpos >a
	( c@+ 1? $ff and curatr or da!+ 3dri ) 2drop ;
		
	
|------ Camera controls
#cam_yaw  0  
#cam_pit  0
#camEye -4.0 0.0 0.0
#camTo  0.0 0.0  0.0
#camUp  0.0 1.0  0.0
#camFor 0 0 0 | forward
#camRig 0 0 0 | right

#cp #sp #cy #sy 
#xp #yp 

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
	
:camVelMove | ve 'v3 -- ve
	over 2dup 
	'camEye -rot v3+*
	'camTo  -rot v3+*
	makecam ;

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

:mouse
	immIni
	immMouse
	1 =? ( wheelcam )				| over
	2 =? ( sdlx 'xp ! sdly 'yp ! )	| in
	3 =? ( movecam )				| active
	drop
	;
	
|-------------------------------
:3deditor
	rl_frame_begin
	
	ss3dreset
	drawcursor
	drawconsole
	SS3Ddraw

	1.4 
	1.0 1.0 1.0 
	1.0 1.0 1.0
	rl_point_light | int cr cg cb x y z --
	'camEye 'camTo 'camUp rl_camera | 'eye 'to 'up --		
	
	rl_frame_end
	
	mouse
	GLUpdate
	
	SDLkey
	>esc< =? ( exit )
	<ret> =? ( 3dcr )
	<up> =? ( 3dup ) <dn> =? ( 3ddn )
	<le> =? ( 3dle ) <ri> =? ( 3dri )
	<back> =? ( 3dle 32 3demit 3dle )
	drop
	SDLchar 1? ( dup 3demit ) drop
	;		
	
|-------------------------------------
:viewresize 
	sh sw rl_resizewin ;

#fsun [ 
-0.5 1.0 -0.5 0
 1.0 1.0 1.0 2.0
 ]

:lightsun
	8 'fsun memfloat
	'fsun rl_set_sun
	;

:load3d
	"media/ss/d4"
	dup 8192 ss3dload
	ss3loadnames	
	0.5 -0.5 0 0 packq rxyz>q16 'charq !
	
	here 'conmem !
	conw conh * 2 << 'here +!
	
	3dcls
	$ffffff 3dcolor
	": " 3dwrite
	|$ffff00 3dcolor
	|3dcr
	;
	
|-------------------------------------
: | <<<<<<<< Boot
	"3dtext" 1024 768 GLini GLInfo
	load3d
	rl_init 
	'viewresize SDLeventR
	lightsun
	ss3dreset
	'3deditor SDLShow 
	
	rl_shutdown
	SS3Dshutdown
	GLend
	;