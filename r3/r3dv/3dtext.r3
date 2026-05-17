| 3dworld 
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
#iniobj 0
#charq
#xc #yc

:drawcar | color char -- color char
	3.0 
	over 33 -
	pick3 $ffffff00 and
	iniobj ss3dcs
	
	zi yc xc charq 
	iniobj ss3dxyzq
	
	1 'iniobj +!
	;
	
:drawconsole
	conmem >a
	xi 'xc ! yi 'yc ! 
	0 'iniobj !
	0 ( conh <?
		0 ( conw <?
			da@+ dup $ff and 33 96 in? ( drawcar ) 2drop
			dx 'xc +!
			1+ ) drop
		xi 'xc !
		dy 'yc +!
		1+ ) drop ;
	
|---------------------------------
#objcnt 0
#objlst 0
#objnro 0

|------ Camera controls
#cam_yaw  0  
#cam_pit  0
#camEye -4.0 0.0 0.0
#camTo  0.0 0.0  0.0
#camUp  0.0 1.0  0.0
#camFor 0 0 0 | forward
#camRig 0 0 0 | right

#va #vl #vu

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
	<up> =? ( -0.1 'va ! ) >up< =? ( 0 'va ! )
	<dn> =? ( 0.1 'va ! ) >dn< =? ( 0 'va ! )
	<le> =? ( 0.1 'vl ! ) >le< =? ( 0 'vl ! )
	<ri> =? ( -0.1 'vl ! ) >ri< =? ( 0 'vl ! )
	drop
	va 1? ( 'camFor camVelMove ) drop
	vl 1? ( 'camRig camVelMove ) drop
	vu 1? ( 'camUp camVelMove ) drop
	
	;		

	
:jugar 
	ss3dreset
	0 'objcnt !
	1 'objnro !
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
	
	here 'conmem !
	conw conh * 2 << 'here +!
	conmem 0 conw conh * dfill |dvc
	
	conmem >a
	conw conh * ( 1?
		32 80 randminmax
		$ffffff00 or
		da!+
		1- ) drop
	conmem >a
	$ffff0030 da!+
	$ffff0031 da!+
	$ffff0032 da!+
	$ffff0033 da!+
	$ffff0034 da!+
	
	0.5 -0.5 0 1.0 packq rxyz>q16 'charq !
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