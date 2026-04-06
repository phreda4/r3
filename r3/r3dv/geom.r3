^./renderlib.r3

| 24 vertices (4 por cara x 6 caras) con pos, normal
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
 0  2  1  0  3  2   4  5  6  4  6  7   8  9 10  8 10 11 
12 14 13 12 15 14  16 17 18 16 18 19  20 22 21 20 23 22
]

#g_cube_vao #g_cube_vbo #g_cube_ebo

::build_cube
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
	
::free_cube
	1 'g_cube_vao glDeleteVertexArrays
	1 'g_cube_vbo glDeleteBuffers
	1 'g_cube_ebo glDeleteBuffers
	;
	
#fmodel * 64 | mat4x4
#fnormal * 36 | mat3x3	

::draw_cube 
	'fmodel 'mat cpymatif
	matinv
	'fnormal 'mati cpymatif3
	'fnormal 'fmodel rl_geomat	
	g_cube_vao glBindVertexArray
    GL_TRIANGLES 36 GL_UNSIGNED_INT 0 glDrawElements
	;
