| demo2 r3dv
| PHREDA 2026
^./renderlib.r3
^./glfixfont.r3
^./geom.r3
^./ss3d.r3

| Camera controls
#cam_yaw  -0.785398   | -PI/4
#cam_pit   0.45
#cam_dist  4.5
#cam_drag  0

| Mouse state
#mouse_x   0
#mouse_y   0
#mouse_btn 0

| Mini viewport
##mini_eye  3.0  2.0  3.0   | camara fija: posicion
##mini_to   0.0  0.0  0.0   | camara fija: target
##mini_up   0.0  1.0  0.0   | up vector
#mini_spr   0               | indice del sprite a previsualizar
#mini_size  256             | tamanio del viewport en px

| UBO backup para restaurar matrices principales
#mini_ubo_backup * 272

:drawsprites
	msec 4 << sin 0.5 +  0  over neg
	msec 5 << $ffff and 16 << 
	4.0 8 >> 40 << or
	$ffffff00 
	msec 11 >> $f and
	0 ss3dset
	
	0 msec 3 << sin dup
	4.0 8 >> 40 << 
	$ffffff00
	msec 18 >> $1f and 
	1 ss3dset | x y z rxyz scale color spr i --	
	
	SS3Ddraw
	;

:drawscene
	rl_ProgGeom
	matini 10.0 .1 10.0 matscale 0 -0.6 0 matpos $5a5a5a00 rl_setcolor draw_cube 
	
	drawsprites	
	
	;
	
:viewresize
    |0 0 vp_w vp_h glViewport vp_h vp_w /. 'vp_asp ! 
	;

#xp #yp 
:movecam
	sdlx dup xp - 0.002 * 'cam_yaw +! 'xp !
	sdly dup yp - neg 0.002 * 
	cam_pit + 0.2 min -0.2 max 'cam_pit ! 
	'yp ! |...
:calcam
	'camEye >a
	cam_yaw cos cam_pit cos *. cam_dist *. a!+ | ex
	cam_pit sin cam_dist *. a!+
	cam_yaw sin cam_pit cos *. cam_dist *. a!
|	3 'pEye 'fpEye mem2float
	|'camEye @+ swap @+ swap @ "%f %f %f" .println
	;
:wheelcam
	SDLw 0? ( drop ; ) neg
	0.6 * 'cam_dist +!
	calcam
	;
	

#fsun [ 
-0.5 -1.0 -0.5 0
 1.0 0.9 0.8 0.2
 ]
	   
:luz
	1.4 
	0.2 0.2 1.0
	msec 3 << 
	dup cos -3 * 
	over sin -3 * 1.0 +
	|0
	rot sin 2.5 *.
	rl_point_light | int cr cg cb x y z --

	1.2 
	1.0 0.2 0.2
	msec 3 << 
	dup cos 3 * 
	over sin 3 * 1.0 +
	|0
	rot 0.5 + sin 2.5 *.
	rl_point_light | int cr cg cb x y z --
	;
#mini_ubo_backup * $fff
#rl_ubo_matrices

#ubo_matview * 64
#ubo_matvProj * 64
#ubo_matvinvView * 64
#ubo_matvinvProj * 64
#ubo_matViewPos * 16

:draw_mini
	| --- backup UBO matrices ---
	GL_UNIFORM_BUFFER rl_ubo_matrices glBindBuffer
	GL_UNIFORM_BUFFER 0 272 'mini_ubo_backup glGetBufferSubData
	GL_UNIFORM_BUFFER 0 glBindBuffer

	| --- calcular matrices de la camara mini ---
	| view matrix
	'mini_eye 'mini_to 'mini_up mlookat
	'ubo_matView 'mat cpymatif
	matinv
	'ubo_matvinvView 'mati cpymatif

	| proj matrix: aspect 1.0 (128x128), mismos fov/near/far que camara principal
	1.0 'camParam !   | 1.0 en fixed point 16.16
	'camParam matProj
	'ubo_matvProj 'mat cpymatif
	'ubo_matvinvProj 'mati cpymatif

	| viewPos
	3 'mini_eye 'ubo_matViewPos mem2float

	| --- subir al UBO ---
	GL_UNIFORM_BUFFER rl_ubo_matrices glBindBuffer
	GL_UNIFORM_BUFFER 0 272 'ubo_matview glBufferSubData
	GL_UNIFORM_BUFFER 0 glBindBuffer

	| --- configurar viewport mini (esquina inferior izquierda) ---
	|GL_SCISSOR_TEST 
	$c11 glEnable
	0 0 mini_size mini_size glScissor
	0 0 mini_size mini_size glViewport

	| limpiar solo esa region
	GL_DEPTH_TEST glEnable
	GL_TRUE glDepthMask
	GL_GREATER glDepthFunc
	GL_COLOR_BUFFER_BIT GL_DEPTH_BUFFER_BIT or glClear

	| --- dibujar solo el sprite mini_spr en posicion 0,0,0 ---
	0.0 0.0 0.0   0   1.0 8 >> 40 << or $ffffff00   mini_spr   0   ss3dset
	SS3Ddraw

	| --- restaurar ---
	|GL_SCISSOR_TEST 
	$c11 glDisable
	0 0 rl_w rl_h glViewport

	GL_UNIFORM_BUFFER rl_ubo_matrices glBindBuffer
	GL_UNIFORM_BUFFER 0 272 'mini_ubo_backup glBufferSubData
	GL_UNIFORM_BUFFER 0 glBindBuffer
	;

:render
	rl_frame_begin |rl_set_camera

	drawscene
	|'fsun rl_set_sun
	luz
	
	rl_frame_end

	draw_mini
	;
	
:main
	render
    GLUpdate
	
	immIni
	immMouse
	1 =? ( wheelcam )				| over
	2 =? ( sdlx 'xp ! sdly 'yp ! )	| in
	3 =? ( movecam )				| active
	drop	
	
    sdlkey
	>esc<  =? ( exit )
	>pgup< =? ( mini_spr 1+ 9 min 'mini_spr ! drop ; )
	>pgdn< =? ( mini_spr 1- 0 max 'mini_spr ! drop ; )
    drop
	;

:load3d
	"media/ss/test" 10 ss3dload
	 0 0   0   0   1.0 8 >> 40 << or $ff00ff00 0 0 ss3dset | x y z rxyz scale color spr i --
	1.0 0 0.5   0   8.0 8 >> 40 << or $ffffff10 1 1 ss3dset | x y z rxyz scale color spr i --
	1.0 0 0.2   0   7.0 8 >> 40 << or $ffffff20 2 2 ss3dset | x y z rxyz scale color spr i --
	-1.4 0.4 -1.0 $7ff0 7.0 8 >> 40 << or $ff00ff3f 3 3 ss3dset | x y z rxyz scale color spr i --
	;
	
:viewresize sh sw rl_resizewin fixFontResize ;
	

: | <<<<< Boot
	"demo2 r3dv" 1024 768 GLini GLInfo
	glFixFont
	rl_init
	build_cube

	load3d
	8 'fsun memfloat
	'fsun rl_set_sun
	'viewresize SDLeventR
	'main SDLshow
	
	SS3Dshutdown
	rl_shutdown
    GLend
	free_cube
	;