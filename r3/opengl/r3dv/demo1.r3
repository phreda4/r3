| demo1 r3dv
| PHREDA 2026
^./renderlib.r3

| Camera controls
#cam_yaw  -0.785398   | -PI/4
#cam_pit   0.45
#cam_dist  4.5
#cam_drag  0

| Cube rotation
#cube_rot  0.0
#spinning  -1

| Mouse state
#mouse_x   0
#mouse_y   0
#mouse_btn 0


| 24 vertices (4 por cara x 6 caras) con pos, normal, UV */
#verts [
-0.5  -0.5  -0.5  0 0 -1.0  0.5  -0.5  -0.5  0 0 -1.0 
 0.5   0.5  -0.5  0 0 -1.0 -0.5   0.5  -0.5  0 0 -1.0 
-0.5  -0.5   0.5  0 0  1.0  0.5  -0.5   0.5  0 0  1.0 
 0.5   0.5   0.5  0 0  1.0 -0.5   0.5   0.5  0 0  1.0 
-0.5   0.5   0.5  -1.0 0 0 -0.5   0.5  -0.5  -1.0 0 0 
-0.5  -0.5  -0.5  -1.0 0 0 -0.5  -0.5   0.5  -1.0 0 0 
 0.5   0.5   0.5   1.0 0 0  0.5   0.5  -0.5   1.0 0 0 
 0.5  -0.5  -0.5   1.0 0 0  0.5  -0.5   0.5   1.0 0 0 
-0.5  -0.5  -0.5  0 -1.0 0  0.5  -0.5  -0.5  0 -1.0 0 
 0.5  -0.5   0.5  0 -1.0 0 -0.5  -0.5   0.5  0 -1.0 0 
-0.5   0.5  -0.5  0  1.0 0  0.5   0.5  -0.5  0  1.0 0 
 0.5   0.5   0.5  0  1.0 0 -0.5   0.5   0.5  0  1.0 0 
]

#idx [
0 2 1 0 3 2  4 5 6 4 6 7  8 9 10 8 10 11 12 14 13 12 15 14  16 17 18 16 18 19  20 22 21 20 23 22
]

#g_cube_vao #g_cube_vbo #g_cube_ebo

:build_cube
	24 6 * 'verts memfloat

    1 'g_cube_vao glGenVertexArrays
    1 'g_cube_vbo glGenBuffers
    1 'g_cube_ebo glGenBuffers
    g_cube_vao glBindVertexArray
    GL_ARRAY_BUFFER g_cube_vbo glBindBuffer
    GL_ARRAY_BUFFER 24 6 * 4 * 'verts GL_STATIC_DRAW glBufferData
    GL_ELEMENT_ARRAY_BUFFER g_cube_ebo glBindBuffer
    GL_ELEMENT_ARRAY_BUFFER 36 4 * 'idx GL_STATIC_DRAW glBufferData
    0 glEnableVertexAttribArray
    0 3 GL_FLOAT GL_FALSE 6 4 * 0 glVertexAttribPointer
    1 glEnableVertexAttribArray
    1 3 GL_FLOAT GL_FALSE 6 4 * 3 4 * glVertexAttribPointer
    0 glBindVertexArray
	;
	
:free_cube
	1 'g_cube_vao glDeleteVertexArrays
	1 'g_cube_vbo glDeleteBuffers
	1 'g_cube_ebo glDeleteBuffers
	;
	
#fmodel * 64 | mat4x4
#fnormal * 36 | mat3x3	

:draw_cube 
	'fmodel 'mat cpymatif
	matinv
	'fnormal 'mati cpymatif3

|	'fmodel .printfm <<trace
|	'fnormal .printfm3 <<trace	
	
	'fnormal 'fmodel rl_geomat	
	g_cube_vao glBindVertexArray
    GL_TRIANGLES 36 GL_UNSIGNED_INT 0 glDrawElements
	;

:drawscene
	rl_ProgGeom
	
	matini
	|msec 4 << 0 msec 3 << matrot
	|cube_rot cube_rot 2/ 0 matrot
	20.0 0.1 20.0 matscale
	0 -1.6 0 matpos
	$eeeeee30 rl_setcolor
	draw_cube 
	
	matini
	|msec 4 << 0 msec 3 << matrot
	cube_rot cube_rot 2/ 0 matrot
	0.8 dup dup matscale
	msec 3 << sin 2 * msec 4 << cos 0.3 + 0 matpos
	$fffffff0 rl_setcolor
	draw_cube 
	
	matini
	|msec 4 << 0 msec 3 << matrot
	cube_rot neg cube_rot 2/ 0.3 matrot
	0.8 dup dup matscale
	msec 3 << sin 2 * neg msec 4 << cos 0.3 + msec 2 << sin matpos
	$6f34fff3 rl_setcolor
	draw_cube 
	
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
	0.2 * 'cam_dist +!
	calcam
	;
	

#fsun [ 
-0.5 -1.0 -0.5 0
 1.0 0.9 0.8 0.8  
 1 0 0 0 ]
	   
:render
	rl_frame_begin |rl_set_camera
	|draw_cube
	drawscene
	'fsun rl_set_sun
	
	2.5 0.2 0.2 1.0
	msec 3 << 
	dup cos -3 * 
	over sin -3 *
	rot sin 2.5 *.
	rl_point_light | int cr cg cb x y z --
	

	2.5 1.0 0.2 0.2
	msec 3 << 
	dup cos 3 * 
	over sin 3 *
	rot 0.5 + sin 2.5 *.
	rl_point_light | int cr cg cb x y z --
	
	
	
	rl_frame_end
	spinning 1? ( 0.004 'cube_rot +! ) drop
	;
	
:main
	render
    GLUpdate
	
	immIni
	immMouse
	1 =? ( wheelcam ) | over
	3 =? ( movecam ) | active
	drop	
	
    sdlkey
	>esc< =? ( exit )
	<esp> =? ( spinning not 'spinning ! )
    drop
	;

| Boot
:
	"demo1 r3dv" 1024 768 GLini GLInfo
	rl_init
	build_cube
	8 'fsun memfloat
	|$1e1f53 GLpaper
	'main SDLshow
	
	rl_shutdown
    GLend
	free_cube
	;