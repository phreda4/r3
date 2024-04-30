^r3/lib/mem.r3
^r3/lib/math.r3
^r3/lib/rand.r3

^r3/lib/3dgl.r3
^r3/win/sdl2.r3
^r3/win/sdl2gl.r3

^r3/games/lunar/shaderobj.r3
|---------------
#GL_ARRAY_BUFFER $8892
#GL_ELEMENT_ARRAY_BUFFER $8893

#GL_STATIC_DRAW $88E4
#GL_DYNAMIC_DRAW $88E8

#GL_FLOAT $1406
#GL_UNSIGNED_SHORT $1403

#GL_TRIANGLE_FAN $0006
#GL_TRIANGLE_STRIP $0005
#GL_FALSE 0

#GL_TEXTURE $1702
#GL_TEXTURE0 $84C0
#GL_TEXTURE_2D $0DE1

#shfloor
#vafl
#vbfl 
#vifl
#vnfl
#vtfl

#IDtp 
#IDtv
#IDtm 

#IDpos
#IDnor 
#IDtex 

#IDlpos 
#IDlamb 
#IDldif 
#IDlspe 

#IDmamb 
#IDmdif 
#IDmspe 
#IDmdifM 
#IDmspeM 
#IDmshi 

#texm

#dif [ 0.7 0.7 0.7 ]
#amb [ 0.5 0.5 0.5 ]
#spe [ 0.8 0.8 0.8 ]
#sho 1.0
	
	
:shaderlightf | adr --
	IDlpos 1 pick2 glUniform3fv 12 +
	IDlamb 1 pick2 glUniform3fv 12 +
	IDldif 1 pick2 glUniform3fv 12 +
	IDlspe 1 pick2 glUniform3fv |12 +
	drop ;

:mem2float | cnt to --
	>a ( 1? 1 - da@ f2fp da!+ ) drop ;
	
::genfloor
	10 'dif mem2float | 3+3+3+1
	"r3/opengl/shader/height.fs" 
	"r3/opengl/shader/height.vs" 
	loadShaders 
	
	dup "aPos" glGetAttribLocation 'IDpos !
	dup "aNormal" glGetAttribLocation 'IDnor !
	dup "aTexCoords" glGetAttribLocation 'IDtex !

	dup "light.position" glGetUniformLocation 'IDlpos !
	dup "light.ambient" glGetUniformLocation 'IDlamb !
	dup "light.diffuse" glGetUniformLocation 'IDldif !
	dup "light.specular" glGetUniformLocation 'IDlspe !

	dup "material.ambient" glGetUniformLocation 'IDmamb !
	dup "material.diffuse" glGetUniformLocation 'IDmdif !
	dup "material.specular" glGetUniformLocation 'IDmspe !
	dup "material.diffuseMap" glGetUniformLocation 'IDmdifM !
	dup "material.specularMap" glGetUniformLocation 'IDmspeM !
	dup "material.shininess" glGetUniformLocation 'IDmshi !
	
	dup "projection" glGetUniformLocation 'IDtp !
	dup "view" glGetUniformLocation 'IDtv !
	dup "model" glGetUniformLocation 'IDtm !	
	'shfloor !
	
	1 'vafl glGenVertexArrays	| VA
	vafl glBindVertexArray 
	
	1 'vbfl glGenBuffers
	mark
	-80.0 ( 80.0 <=?
		-80.0 ( 80.0 <=?
			over f2fp , dup f2fp , 
			|2.0 randmax 3.0 -
			-5.0 randmax
			f2fp , | x y z
			4.0 + ) drop
		4.0 + ) drop
	GL_ARRAY_BUFFER vbfl glBindBuffer	| vertex
	|GL_ARRAY_BUFFER memsize swap GL_STATIC_DRAW glBufferData
	GL_ARRAY_BUFFER memsize swap GL_DYNAMIC_DRAW glBufferData
	empty


    0 3 GL_FLOAT GL_FALSE 12 0 glVertexAttribPointer
    0 glEnableVertexAttribArray

	1 'vnfl glGenBuffers
	mark
	-20.0 ( 20.0 <=?
		-20.0 ( 20.0 <=?
			1.0 randmax 1.0 over -
			0.0 f2fp , f2fp , f2fp , | x y z
			1.0 + ) drop
		1.0 + ) drop
	GL_ARRAY_BUFFER vnfl glBindBuffer | normal
	GL_ARRAY_BUFFER memsize swap GL_STATIC_DRAW glBufferData
	empty


	1 'vtfl glGenBuffers	
	mark
	-20.0 ( 20.0 <=?
		-20.0 ( 20.0 <=?
			over $10000 and f2fp , 
			dup $10000 and f2fp , 
			1.0 + ) drop
		1.0 + ) drop
	GL_ARRAY_BUFFER vtfl  glBindBuffer | uv
	GL_ARRAY_BUFFER memsize swap GL_STATIC_DRAW glBufferData	
	empty
	
	| -20 ..20 = 40
	mark	
	0 ( 40 <? 
		0 ( 41 <? 
			over 41 * over + ,w
			over 1 + 41 * over + ,w
			1 + ) drop
		1 + ) drop
	1 'vifl glGenBuffers
	GL_ELEMENT_ARRAY_BUFFER vifl glBindBuffer
	GL_ELEMENT_ARRAY_BUFFER memsize swap GL_STATIC_DRAW glBufferData	
	empty
	
	"media/img/metal.png" glImgTex 'texm !
	;

:altura | x y -- z
	over 
	|msec 6 << + 
	0.01 *. sin 1.4 *. 
	over 
	|msec 5 << +
	0.05 *. cos 1.1 *. + 
	;
	
::genfloordyn
	1 'vbfl glGenBuffers
	mark
	-80.0 ( 80.0 <=?
		-80.0 ( 80.0 <=?
			over f2fp , dup f2fp ,  | px + py +
			|2.0 randmax 3.0 -
			|-3.0 randmax
			altura
			f2fp , | x y z
			4.0 + ) drop
		4.0 + ) drop
	GL_ARRAY_BUFFER vbfl glBindBuffer	| vertex
	|GL_ARRAY_BUFFER memsize swap GL_STATIC_DRAW glBufferData
	GL_ARRAY_BUFFER memsize swap GL_DYNAMIC_DRAW glBufferData
	empty
	;
	
:floorcam | fmodel fproj --
	IDtp 1 0 pick3 glUniformMatrix4fv 64 +
	IDtv 1 0 pick3 glUniformMatrix4fv 64 +
|	IDtm 1 0 pick3 glUniformMatrix4fv |64 +
	drop

	dup midf
	IDtm 1 0 pick3 glUniformMatrix4fv |64 +
	drop
	;
	
::drawfloor | fmodel fproj flpos
	shfloor glUseProgram	

	|'flpos shaderlightf	
	shaderlightf	
	|'fmodel 'fprojection 
	floorcam

	IDmdif 1 'dif glUniform3fv  | vec3 Material.diffuse;
	IDmamb 1 'amb glUniform3fv  | vec3 Material.ambient;
	IDmspe 1 'spe glUniform3fv  | vec3 Material.specular;    
	IDmshi 1 'sho glUniform1fv  | float Material.shininess;
	
	vafl glBindVertexArray
	0 glEnableVertexAttribArray	
	GL_ARRAY_BUFFER vbfl glBindBuffer | vertex>
	0 3 GL_FLOAT GL_FALSE 0 0 glVertexAttribPointer
	
	1 glEnableVertexAttribArray	
	GL_ARRAY_BUFFER vnfl glBindBuffer | normal>
	1 3 GL_FLOAT GL_FALSE 0 0 glVertexAttribPointer
	
	2 glEnableVertexAttribArray
	GL_ARRAY_BUFFER vtfl glBindBuffer | uv>
	2 2 GL_FLOAT GL_FALSE 0 0 glVertexAttribPointer
	
	GL_ELEMENT_ARRAY_BUFFER vifl glBindBuffer | index>	
	
	IDmdifM 0 glUniform1i
	GL_TEXTURE0 glActiveTexture | sampler2D Material.diffuseMap;
	GL_TEXTURE_2D texm glBindTexture 
	
	0 ( 40 <?
		GL_TRIANGLE_STRIP 
		40 1 <<
		GL_UNSIGNED_SHORT
		41 1 << pick4 * 1 <<
		glDrawElements
		1 + ) drop
	;
