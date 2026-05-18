| block editor en 3d
| PHREDA 2026
|-----
^r3/lib/rand.r3
^r3/util/varanim.r3

^./renderlib.r3
^./rlhud.r3
^./ss3d.r3

#xi -4.5 #yi 3.4 #zi 5.0
#dx 0.21 #dy -0.22

#conw 44
#conh 32
#conmem
#curx #cury #curatr

#iniobj 0
#charq
#xc #yc

:drawcar | color char -- color char
	3.0 over 33 - pick3 $ffffff00 and iniobj ss3dcs
	zi yc xc charq iniobj ss3dxyzq
	1 'iniobj +!
	;
	
:drawconsole
	conmem >a
	xi 'xc ! yi 'yc ! 
	1 'iniobj !
	0 ( conh <?
		0 ( conw <?
			da@+ dup $ff and 
			$21 $7d in? ( drawcar ) 2drop
			dx 'xc +!
			1+ ) drop
		xi 'xc !
		dy 'yc +!
		1+ ) drop ;
		
:drawcursor
	msec 6 << $f000 and $fff or 111 $ffffff01 0 ss3dcs
	zi yi cury dy * + xi curx dx * +
	charq 0 ss3dxyzq
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

:3dcr
	0 'curx ! 
	cury 1+
	conh >=? ( 0 nip ) 
	'cury ! ;
	
:cur++
	curx 1+ 
	conw >=? ( drop 3dcr ; ) 
	'curx ! ;
	
:3demit | nro --
	$ff and curatr or curx cury 3dpos d! 
	cur++ ;
	
:3dwrite | "" --
	curx cury 3dpos >a
	( c@+ 1? $ff and curatr or da!+ cur++ ) 2drop ;
		
	
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

:hud
	fini
	2 'fscale !
	$ffffffff 'fcolor !
|	16 16  fat
|	prot "r:%f " sprint ftext
	immIni
	immMouse
	1 =? ( wheelcam )				| over
	2 =? ( sdlx 'xp ! sdly 'yp ! )	| in
	3 =? ( movecam )				| active
	drop
	fend
	;
	
|-------------------------------
:juego
	vupdate
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
	
	hud
	GLUpdate
	
	SDLkey
	>esc< =? ( exit )
	<ret> =? ( 3dcr )
	<up> =? ( -1 'cury +! )
	<dn> =? ( 1 'cury +! )
	<le> =? ( -1 'curx +! )
	<ri> =? ( 1 'curx +! )
	<back> =? ( -1 'curx +! 32 3demit -1 'curx +! )
	drop
	SDLchar 1? ( dup 3demit ) drop
	;		

	
:jugar 
	ss3dreset
	'juego SDLShow 
	;
	
|-------------------------------------
:viewresize 
	sh sw rl_resizewin 
	fixFontResize ;

#fsun [ 
-0.5 1.0 -0.5 0
 1.0 1.0 1.0 2.0
 ]

:lightsun
	8 'fsun memfloat
	'fsun rl_set_sun
	;


:load3d
	"media/ss/sprites"
	dup 2048 ss3dload
	ss3loadnames	
	|"point" ss3idname 'ballid !
	
	0.5 -0.5 0 0 packq rxyz>q16 'charq !
	
	here 'conmem !
	conw conh * 2 << 'here +!
	
	3dcls
	$ffffff 3dcolor
	"r3Forth" 3dwrite
	$ffff00 3dcolor
	3dcr
	;
	
|-------------------------------------
: | <<<<<<<< Boot
	"3dtext" 1024 768 GLini GLInfo

	rlhud
	load3d
	rl_init 
	$fff vaini
	'viewresize SDLeventR
	lightsun
	
	jugar
	
	rl_shutdown
	SS3Dshutdown
	GLend
	;