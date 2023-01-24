
|-----------------------------------------------	
#ss | error compile
#log * 512
:shCheckErr | ss --
	dup GL_COMPILE_STATUS 'ss glGetShaderiv
	ss 1? ( 2drop ; ) drop
	512 0 'log glGetShaderInfoLog
	'log .println ;

:prCheckErr | ss --
	dup GL_LINK_STATUS 'ss glGetProgramiv
	ss 1? ( 2drop ; ) drop
	512 'ss 'log glGetProgramInfoLog
	'log .println ;
	
:glError
	glGetError 0? ( drop ; ) "Error %d:" .println ;

#vertex_shader_text "#version 330 core
layout(location = 0) in vec3 vertexPosition;
layout(location = 1) in vec2 vertexUV;
out vec2 UV; 		// Output data ; will be interpolated for each fragment.
uniform mat4 MVP; 
void main(){
	gl_Position =  MVP * vec4(vertexPosition,1) ; 
	UV = vertexUV; 
}"
#vht 'vertex_shader_text
 
#fragment_shader_text "#version 330 core
in vec2 UV;
out vec3 color; 
uniform sampler2D myTextureSampler;
void main(){
	color = texture( myTextureSampler, UV ).rgb; 	// Output color = color of the texture at the specified UV
}"
#fst 'fragment_shader_text 

#vs #fs

|-----------------------------------------------	
#ss | error compile
#log * 512
:shCheckErr | ss --
	dup GL_COMPILE_STATUS 'ss glGetShaderiv
	ss 1? ( 2drop ; ) drop
	512 0 'log glGetShaderInfoLog
	'log .println ;

:prCheckErr | ss --
	dup GL_LINK_STATUS 'ss glGetProgramiv
	ss 1? ( 2drop ; ) drop
	512 'ss 'log glGetProgramInfoLog
	'log .println ;
	
:glError
	glGetError 0? ( drop ; ) "Error %d:" .println ;

:loadshaders2
|	"Vertex" .println
	GL_VERTEX_SHADER glCreateShader 'vs !
	vs 1 'vht 0 glShaderSource
	vs glCompileShader 
	vs shCheckErr glError
	
|	"Fragment" .println
	GL_FRAGMENT_SHADER glCreateShader 'fs !
	fs 1 'fst 0 glShaderSource
	fs glCompileShader
	fs shCheckErr glError

|	"Program:" .println
	glCreateProgram 'programID !
	programID vs glAttachShader
	programID fs glAttachShader
	programID glLinkProgram 
	programID glValidateProgram
	programID prCheckErr glError
	
	vs glDeleteShader
	fs glDeleteShader
	;


|----------------------------------------------------------------------------
#define FOURCC_DXT1 0x31545844 // Equivalent to "DXT1" in ASCII
#define FOURCC_DXT3 0x33545844 // Equivalent to "DXT3" in ASCII
#define FOURCC_DXT5 0x35545844 // Equivalent to "DXT5" in ASCII

GLuint loadDDS(const char * imagepath){
	unsigned char header[124];
	FILE *fp; 
	/* try to open the file */ 
	fp = fopen(imagepath, "rb"); 
	if (fp == NULL){ printf("%s could not be opened. Are you in the right directory ? Don't forget to read the FAQ !\n", imagepath); getchar(); return 0;}
   
	/* verify the type of file */ 
	char filecode[4]; 
	fread(filecode, 1, 4, fp); 
	if (strncmp(filecode, "DDS ", 4) != 0) { fclose(fp);return 0; }
	
	/* get the surface desc */ 
	fread(&header, 124, 1, fp); 

	unsigned int height      = *(unsigned int*)&(header[8 ]);
	unsigned int width	     = *(unsigned int*)&(header[12]);
	unsigned int linearSize	 = *(unsigned int*)&(header[16]);
	unsigned int mipMapCount = *(unsigned int*)&(header[24]);
	unsigned int fourCC      = *(unsigned int*)&(header[80]);
 
	unsigned char * buffer;
	unsigned int bufsize;
	/* how big is it going to be including all mipmaps? */ 
	bufsize = mipMapCount > 1 ? linearSize * 2 : linearSize; 
	buffer = (unsigned char*)malloc(bufsize * sizeof(unsigned char)); 
	fread(buffer, 1, bufsize, fp); 
	/* close the file pointer */ 
	fclose(fp);

	unsigned int components  = (fourCC == FOURCC_DXT1) ? 3 : 4; 
	unsigned int format;
	switch(fourCC) 	{ 
		case FOURCC_DXT1: format = GL_COMPRESSED_RGBA_S3TC_DXT1_EXT; break; 
		case FOURCC_DXT3: format = GL_COMPRESSED_RGBA_S3TC_DXT3_EXT; break; 
		case FOURCC_DXT5: format = GL_COMPRESSED_RGBA_S3TC_DXT5_EXT; break; 
		default: free(buffer);return 0; 
		}

	// Create one OpenGL texture
	GLuint textureID;
	glGenTextures(1, &textureID);

	// "Bind" the newly created texture : all future texture functions will modify this texture
	glBindTexture(GL_TEXTURE_2D, textureID);
	glPixelStorei(GL_UNPACK_ALIGNMENT,1);	
	
	unsigned int blockSize = (format == GL_COMPRESSED_RGBA_S3TC_DXT1_EXT) ? 8 : 16; 
	unsigned int offset = 0;

	/* load the mipmaps */ 
	for (unsigned int level = 0; level < mipMapCount && (width || height); ++level) 
	{ 
		unsigned int size = ((width+3)/4)*((height+3)/4)*blockSize; 
		glCompressedTexImage2D(GL_TEXTURE_2D, level, format, width, height, 0, size, buffer + offset); 
	 
		offset += size; 
		width  /= 2; 
		height /= 2; 

		// Deal with Non-Power-Of-Two textures. This code is not included in the webpage to reduce clutter.
		if(width < 1) width = 1;
		if(height < 1) height = 1;

	} 
	free(buffer); 
	return textureID;
}