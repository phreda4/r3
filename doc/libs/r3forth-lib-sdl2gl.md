# R3Forth SDL2 OpenGL Library (sdl2gl.r3)

A comprehensive OpenGL wrapper for R3Forth providing access to modern OpenGL functions through SDL2, including shaders, VBOs, VAOs, textures, and framebuffers.

## Overview

This library provides:
- **Modern OpenGL** (4.6 Core Profile)
- **Shader compilation** and linking
- **Vertex Buffer Objects** (VBOs)
- **Vertex Array Objects** (VAOs)
- **Texture management** (2D, mipmaps, framebuffers)
- **Uniform blocks** and instancing
- **Legacy OpenGL** support (immediate mode)
- **Framebuffer objects** for render-to-texture
- **Complete OpenGL state management**

---

## Initialization

### OpenGL Context Creation

- **`SDLinitGL`** `( "title" w h -- )` - Create OpenGL 4.6 window
  ```r3forth
  "OpenGL App" 1024 768 SDLinitGL
  ```
  - Creates window with OpenGL context
  - OpenGL 4.6 Core Profile
  - MSAA 8x antialiasing
  - Double buffering
  - VSync enabled
  - Initializes all OpenGL function pointers

- **`SDLinitSGL`** `( "title" w h -- )` - Create hybrid SDL2+OpenGL window
  ```r3forth
  "Hybrid App" 800 600 SDLinitSGL
  ```
  - Creates both SDL2 renderer AND OpenGL context
  - Allows mixing SDL2 2D and OpenGL 3D rendering
  - Sets up both `SDLrenderer` and OpenGL context

### Cleanup

- **`SDLglquit`** - Cleanup and shutdown
  ```r3forth
  SDLglquit
  ```
  - Deletes OpenGL context
  - Destroys window
  - Shuts down SDL

---

## Frame Management

- **`SDLGLcls`** - Clear color and depth buffers
  ```r3forth
  SDLGLcls  | Clear before rendering
  ```
  - Clears both color and depth buffers
  - Uses current clear color

- **`SDLGLupdate`** - Swap buffers (present frame)
  ```r3forth
  SDLGLupdate  | Display rendered frame
  ```
  - Swaps front/back buffers
  - Call once per frame after rendering

---

## Program and Shader Management

### Program Creation

- **`glCreateProgram`** `( -- program )` - Create shader program
  ```r3forth
  glCreateProgram 'my-program !
  ```

- **`glDeleteProgram`** `( program -- )` - Delete shader program
  ```r3forth
  my-program glDeleteProgram
  ```

- **`glUseProgram`** `( program -- )` - Activate shader program
  ```r3forth
  my-program glUseProgram
  ```

- **`glValidateProgram`** `( program -- )` - Validate program
  ```r3forth
  my-program glValidateProgram
  ```

- **`glLinkProgram`** `( program -- )` - Link shader program
  ```r3forth
  my-program glLinkProgram
  ```

- **`glIsProgram`** `( program -- bool )` - Check if valid program
  ```r3forth
  my-program glIsProgram 0? ( "Invalid program" print ; )
  ```

### Shader Compilation

- **`glCreateShader`** `( type -- shader )` - Create shader object
  ```r3forth
  $8B31 glCreateShader 'vertex-shader !  | GL_VERTEX_SHADER
  $8B30 glCreateShader 'fragment-shader !  | GL_FRAGMENT_SHADER
  ```
  - Types: `$8B31` = Vertex, `$8B30` = Fragment

- **`glShaderSource`** `( shader count 'strings 'lengths -- )` - Set shader source
  ```r3forth
  vertex-shader 1 'source-ptr 0 glShaderSource
  ```

- **`glCompileShader`** `( shader -- )` - Compile shader
  ```r3forth
  vertex-shader glCompileShader
  ```

- **`glGetShaderiv`** `( shader pname 'params -- )` - Get shader parameter
  ```r3forth
  shader $8B81 'status glGetShaderiv  | GL_COMPILE_STATUS
  ```

- **`glGetShaderInfoLog`** `( shader maxlen 'length 'infolog -- )` - Get compilation log
  ```r3forth
  shader 512 0 'log-buffer glGetShaderInfoLog
  ```

- **`glDeleteShader`** `( shader -- )` - Delete shader
  ```r3forth
  vertex-shader glDeleteShader
  ```

- **`glIsShader`** `( shader -- bool )` - Check if valid shader
  ```r3forth
  shader glIsShader 0? ( "Invalid shader" print ; )
  ```

### Shader Attachment

- **`glAttachShader`** `( program shader -- )` - Attach shader to program
  ```r3forth
  my-program vertex-shader glAttachShader
  my-program fragment-shader glAttachShader
  ```

- **`glDetachShader`** `( program shader -- )` - Detach shader
  ```r3forth
  my-program vertex-shader glDetachShader
  ```

### Program Info

- **`glGetProgramiv`** `( program pname 'params -- )` - Get program parameter
  ```r3forth
  program $8B82 'status glGetProgramiv  | GL_LINK_STATUS
  ```

- **`glGetProgramInfoLog`** `( program maxlen 'length 'infolog -- )` - Get link log
  ```r3forth
  program 512 0 'log-buffer glGetProgramInfoLog
  ```

---

## Vertex Attributes

### Attribute Locations

- **`glGetAttribLocation`** `( program name -- location )` - Get attribute location
  ```r3forth
  program "position" glGetAttribLocation 'pos-loc !
  ```

- **`glBindAttribLocation`** `( program index name -- )` - Bind attribute location
  ```r3forth
  program 0 "position" glBindAttribLocation
  ```

### Attribute Configuration

- **`glEnableVertexAttribArray`** `( index -- )` - Enable attribute
  ```r3forth
  0 glEnableVertexAttribArray  | Enable attribute 0
  ```

- **`glDisableVertexAttribArray`** `( index -- )` - Disable attribute
  ```r3forth
  0 glDisableVertexAttribArray
  ```

- **`glVertexAttribPointer`** `( index size type normalized stride offset -- )` - Set attribute pointer
  ```r3forth
  0 3 $1406 0 32 0 glVertexAttribPointer
  | index=0, size=3, type=FLOAT, stride=32, offset=0
  ```
  - Types: `$1406` = GL_FLOAT, `$1401` = GL_UNSIGNED_BYTE

- **`glVertexAttribIPointer`** `( index size type stride offset -- )` - Set integer attribute
  ```r3forth
  1 4 $1405 32 12 glVertexAttribIPointer  | GL_INT
  ```

- **`glVertexAttribDivisor`** `( index divisor -- )` - Set instancing divisor
  ```r3forth
  2 1 glVertexAttribDivisor  | Instance per object
  ```

### Attribute Values

- **`glVertexAttrib1fv`** `( index 'values -- )` - Set 1-float attribute
- **`glVertexAttrib2fv`** `( index 'values -- )` - Set 2-float attribute
- **`glVertexAttrib3fv`** `( index 'values -- )` - Set 3-float attribute
- **`glVertexAttrib4fv`** `( index 'values -- )` - Set 4-float attribute

---

## Uniforms

### Uniform Locations

- **`glGetUniformLocation`** `( program name -- location )` - Get uniform location
  ```r3forth
  program "mvpMatrix" glGetUniformLocation 'mvp-loc !
  ```

### Setting Uniforms

- **`glUniform1i`** `( location value -- )` - Set integer uniform
  ```r3forth
  texture-loc 0 glUniform1i  | Bind to texture unit 0
  ```

- **`glUniform1iv`** `( location count 'values -- )` - Set integer array
- **`glUniform2iv`** `( location count 'values -- )` - Set ivec2 array
- **`glUniform3iv`** `( location count 'values -- )` - Set ivec3 array
- **`glUniform4iv`** `( location count 'values -- )` - Set ivec4 array

- **`glUniform1fv`** `( location count 'values -- )` - Set float array
- **`glUniform2fv`** `( location count 'values -- )` - Set vec2 array
- **`glUniform3fv`** `( location count 'values -- )` - Set vec3 array
- **`glUniform4fv`** `( location count 'values -- )` - Set vec4 array

- **`glUniformMatrix4fv`** `( location count transpose 'values -- )` - Set mat4 uniform
  ```r3forth
  mvp-loc 1 0 'matrix glUniformMatrix4fv
  ```

### Uniform Blocks

- **`glGetUniformBlockIndex`** `( program name -- index )` - Get uniform block index
  ```r3forth
  program "Matrices" glGetUniformBlockIndex 'block-idx !
  ```

- **`glUniformBlockBinding`** `( program blockindex binding -- )` - Bind uniform block
  ```r3forth
  program block-idx 0 glUniformBlockBinding
  ```

---

## Buffers (VBO)

### Buffer Creation

- **`glGenBuffers`** `( n 'buffers -- )` - Generate buffer objects
  ```r3forth
  1 'vbo glGenBuffers
  ```

- **`glBindBuffer`** `( target buffer -- )` - Bind buffer
  ```r3forth
  $8892 vbo glBindBuffer  | GL_ARRAY_BUFFER
  ```
  - Targets: `$8892` = ARRAY_BUFFER, `$8893` = ELEMENT_ARRAY_BUFFER

- **`glBufferData`** `( target size 'data usage -- )` - Upload buffer data
  ```r3forth
  $8892 1024 'vertex-data $88E4 glBufferData
  ```
  - Usage: `$88E4` = STATIC_DRAW, `$88E8` = DYNAMIC_DRAW

- **`glBufferSubData`** `( target offset size 'data -- )` - Update buffer data
  ```r3forth
  $8892 0 512 'new-data glBufferSubData
  ```

- **`glDeleteBuffers`** `( n 'buffers -- )` - Delete buffers
  ```r3forth
  1 'vbo glDeleteBuffers
  ```

### Buffer Mapping

- **`glMapBuffer`** `( target access -- pointer )` - Map buffer to CPU memory
  ```r3forth
  $8892 $88BA glMapBuffer  | READ_WRITE
  ```
  - Access: `$88B8` = READ_ONLY, `$88B9` = WRITE_ONLY, `$88BA` = READ_WRITE

- **`glUnmapBuffer`** `( target -- )` - Unmap buffer
  ```r3forth
  $8892 glUnmapBuffer
  ```

### Uniform Buffer Objects

- **`glBindBufferBase`** `( target index buffer -- )` - Bind to indexed target
  ```r3forth
  $8A11 0 ubo glBindBufferBase  | GL_UNIFORM_BUFFER
  ```

---

## Vertex Array Objects (VAO)

- **`glGenVertexArrays`** `( n 'arrays -- )` - Generate VAOs
  ```r3forth
  1 'vao glGenVertexArrays
  ```

- **`glBindVertexArray`** `( array -- )` - Bind VAO
  ```r3forth
  vao glBindVertexArray
  ```

- **`glDeleteVertexArrays`** `( n 'arrays -- )` - Delete VAOs
  ```r3forth
  1 'vao glDeleteVertexArrays
  ```

---

## Drawing

### Draw Commands

- **`glDrawArrays`** `( mode first count -- )` - Draw primitives
  ```r3forth
  $0004 0 36 glDrawArrays  | GL_TRIANGLES
  ```
  - Modes: `$0000` = POINTS, `$0001` = LINES, `$0004` = TRIANGLES

- **`glDrawElements`** `( mode count type offset -- )` - Draw indexed primitives
  ```r3forth
  $0004 36 $1405 0 glDrawElements  | TRIANGLES, INT
  ```
  - Types: `$1405` = UNSIGNED_INT, `$1403` = UNSIGNED_SHORT

- **`glDrawArraysInstanced`** `( mode first count instancecount -- )` - Draw instanced
  ```r3forth
  $0004 0 36 100 glDrawArraysInstanced  | 100 instances
  ```

- **`glDrawElementsInstanced`** `( mode count type offset instancecount -- )` - Draw indexed instanced
  ```r3forth
  $0004 36 $1405 0 100 glDrawElementsInstanced
  ```

---

## Textures

### Texture Creation

- **`glGenTextures`** `( n 'textures -- )` - Generate texture objects
  ```r3forth
  1 'texture glGenTextures
  ```

- **`glBindTexture`** `( target texture -- )` - Bind texture
  ```r3forth
  $0DE1 texture glBindTexture  | GL_TEXTURE_2D
  ```

- **`glTexImage2D`** `( target level internalformat w h border format type 'pixels -- )` - Upload texture
  ```r3forth
  $0DE1 0 $1908 512 512 0 $1908 $1401 'pixels glTexImage2D
  ```
  - Target: `$0DE1` = TEXTURE_2D
  - Format: `$1908` = RGBA, `$1907` = RGB
  - Type: `$1401` = UNSIGNED_BYTE

- **`glTexSubImage2D`** `( target level xoff yoff w h format type 'pixels -- )` - Update texture
  ```r3forth
  $0DE1 0 0 0 256 256 $1908 $1401 'pixels glTexSubImage2D
  ```

- **`glDeleteTextures`** `( n 'textures -- )` - Delete textures
  ```r3forth
  1 'texture glDeleteTextures
  ```

### Texture Parameters

- **`glTexParameteri`** `( target pname param -- )` - Set integer parameter
  ```r3forth
  $0DE1 $2801 $2601 glTexParameteri  | MIN_FILTER = LINEAR
  ```
  - MIN_FILTER ($2801): `$2600` = NEAREST, `$2601` = LINEAR
  - MAG_FILTER ($2800): `$2600` = NEAREST, `$2601` = LINEAR
  - WRAP_S ($2802), WRAP_T ($2803): `$2901` = REPEAT, `$812F` = CLAMP_TO_EDGE

- **`glTexParameterfv`** `( target pname 'params -- )` - Set float parameter array

### Texture Units

- **`glActiveTexture`** `( texture -- )` - Select active texture unit
  ```r3forth
  $84C0 glActiveTexture  | GL_TEXTURE0
  $84C1 glActiveTexture  | GL_TEXTURE1
  ```

- **`glGetTexImage`** `( target level format type 'pixels -- )` - Read texture data
  ```r3forth
  $0DE1 0 $1908 $1401 'buffer glGetTexImage
  ```

---

## Framebuffers (FBO)

### Framebuffer Creation

- **`glGenFramebuffers`** `( n 'framebuffers -- )` - Generate FBOs
  ```r3forth
  1 'fbo glGenFramebuffers
  ```

- **`glBindFramebuffer`** `( target framebuffer -- )` - Bind framebuffer
  ```r3forth
  $8D40 fbo glBindFramebuffer  | GL_FRAMEBUFFER
  ```

- **`glFramebufferTexture2D`** `( target attachment textarget texture level -- )` - Attach texture
  ```r3forth
  $8D40 $8CE0 $0DE1 color-tex 0 glFramebufferTexture2D
  ```
  - Attachments: `$8CE0` = COLOR_ATTACHMENT0, `$8D00` = DEPTH_ATTACHMENT

### Renderbuffers

- **`glGenRenderbuffers`** `( n 'renderbuffers -- )` - Generate renderbuffers
  ```r3forth
  1 'rbo glGenRenderbuffers
  ```

- **`glBindRenderbuffer`** `( target renderbuffer -- )` - Bind renderbuffer
  ```r3forth
  $8D41 rbo glBindRenderbuffer  | GL_RENDERBUFFER
  ```

- **`glRenderbufferStorage`** `( target internalformat w h -- )` - Allocate storage
  ```r3forth
  $8D41 $81A5 1024 768 glRenderbufferStorage  | DEPTH_COMPONENT24
  ```

- **`glFramebufferRenderbuffer`** `( target attachment rendertarget renderbuffer -- )` - Attach renderbuffer
  ```r3forth
  $8D40 $8D00 $8D41 depth-rbo glFramebufferRenderbuffer
  ```

### Framebuffer Operations

- **`glDrawBuffer`** `( mode -- )` - Specify draw buffer
  ```r3forth
  $8CE0 glDrawBuffer  | COLOR_ATTACHMENT0
  ```

- **`glReadBuffer`** `( mode -- )` - Specify read buffer
  ```r3forth
  $8CE0 glReadBuffer
  ```

---

## State Management

### OpenGL State

- **`glEnable`** `( cap -- )` - Enable capability
  ```r3forth
  $0B71 glEnable  | GL_DEPTH_TEST
  $0BE2 glEnable  | GL_BLEND
  ```

- **`glDisable`** `( cap -- )` - Disable capability
  ```r3forth
  $0B71 glDisable  | Disable depth test
  ```

- **`glClear`** `( mask -- )` - Clear buffers
  ```r3forth
  $4100 glClear  | COLOR_BUFFER_BIT | DEPTH_BUFFER_BIT
  ```
  - Bits: `$4000` = COLOR, `$0100` = DEPTH, `$0400` = STENCIL

- **`glClearColor`** `( r g b a -- )` - Set clear color
  ```r3forth
  0.2 0.3 0.4 1.0 glClearColor
  ```

### Blending

- **`glBlendFunc`** `( sfactor dfactor -- )` - Set blend function
  ```r3forth
  $0302 $0303 glBlendFunc  | SRC_ALPHA, ONE_MINUS_SRC_ALPHA
  ```

### Depth Testing

- **`glDepthFunc`** `( func -- )` - Set depth comparison function
  ```r3forth
  $0201 glDepthFunc  | GL_LESS
  ```

### Viewport and Scissor

- **`glViewport`** `( x y w h -- )` - Set viewport
  ```r3forth
  0 0 1024 768 glViewport
  ```

- **`glScissor`** `( x y w h -- )` - Set scissor box
  ```r3forth
  100 100 400 300 glScissor
  ```

### Pixel Store

- **`glPixelStorei`** `( pname param -- )` - Set pixel storage mode
  ```r3forth
  $0CF5 1 glPixelStorei  | UNPACK_ALIGNMENT
  ```

---

## Legacy OpenGL (Immediate Mode)

### Drawing Primitives

- **`glBegin`** `( mode -- )` - Begin primitive
  ```r3forth
  $0004 glBegin  | GL_TRIANGLES
  ```

- **`glEnd`** - End primitive
  ```r3forth
  glEnd
  ```

- **`glVertex2fv`** `( 'xy -- )` - Specify 2D vertex
  ```r3forth
  'vertex2 glVertex2fv
  ```

- **`glVertex3fv`** `( 'xyz -- )` - Specify 3D vertex
  ```r3forth
  'vertex3 glVertex3fv
  ```

- **`glTexCoord2fv`** `( 'uv -- )` - Specify texture coordinate
  ```r3forth
  'texcoord glTexCoord2fv
  ```

- **`glColor4ubv`** `( 'rgba -- )` - Specify color
  ```r3forth
  'color glColor4ubv
  ```

- **`glVertexPointer`** `( size type stride 'pointer -- )` - Set vertex array
  ```r3forth
  3 $1406 0 'vertices glVertexPointer
  ```

---

## Fragment Shader Output

- **`glBindFragDataLocation`** `( program color name -- )` - Bind fragment output
  ```r3forth
  program 0 "fragColor" glBindFragDataLocation
  ```

---

## Error Handling

- **`glGetError`** `( -- error )` - Get last error
  ```r3forth
  glGetError 
  0? ( "No error" print ; )
  $0500 =? ( "Invalid enum" print ; )
  $0501 =? ( "Invalid value" print ; )
  $0502 =? ( "Invalid operation" print ; )
  drop
  ```

- **`glGetString`** `( name -- string )` - Get string value
  ```r3forth
  $1F00 glGetString  | GL_VENDOR
  $1F01 glGetString  | GL_RENDERER
  $1F02 glGetString  | GL_VERSION
  ```

---

## Utility Functions

- **`glInfo`** - Print GPU information
  ```r3forth
  glInfo
  | Vendor: NVIDIA Corporation
  | Renderer: GeForce RTX 3080
  | Version: 4.6.0
  | Shader: 4.60
  ```

- **`InitGLAPI`** - Initialize all OpenGL function pointers
  ```r3forth
  InitGLAPI  | Called automatically by SDLinitGL
  ```

---

## Usage Examples

### Basic OpenGL Setup
```r3forth
:init-gl
  "OpenGL App" 1024 768 SDLinitGL
  
  | Enable features
  $0B71 glEnable  | Depth test
  $0BE2 glEnable  | Blending
  
  | Set blend function
  $0302 $0303 glBlendFunc  | Alpha blending
  
  | Set clear color
  0.2 0.3 0.4 1.0 glClearColor
  
  glInfo  | Print GPU info
  ;
```

### Shader Compilation
```r3forth
#vertex-src "
#version 330 core
layout(location = 0) in vec3 position;
void main() {
  gl_Position = vec4(position, 1.0);
}
"

:compile-shader | 'source type -- shader
  glCreateShader >r
  r@ 1 rot 0 glShaderSource
  r@ glCompileShader
  
  | Check status
  #status
  r@ $8B81 'status glGetShaderiv
  status 0? (
    #log * 512
    r@ 512 0 'log glGetShaderInfoLog
    log print
  )
  r>
  ;

:create-program
  vertex-src $8B31 compile-shader >r
  fragment-src $8B30 compile-shader >r
  
  glCreateProgram
  dup r> glAttachShader
  dup r> glAttachShader
  dup glLinkProgram
  ;
```

### VBO Setup
```r3forth
#vertices [
  -0.5 -0.5 0.0
   0.5 -0.5 0.0
   0.0  0.5 0.0
]

#vbo #vao

:setup-mesh
  | Generate VAO
  1 'vao glGenVertexArrays
  vao glBindVertexArray
  
  | Generate VBO
  1 'vbo glGenBuffers
  $8892 vbo glBindBuffer
  
  | Upload data
  $8892 36 'vertices $88E4 glBufferData
  
  | Configure attribute
  0 3 $1406 0 12 0 glVertexAttribPointer
  0 glEnableVertexAttribArray
  
  | Unbind
  0 glBindVertexArray
  ;
```

### Rendering Loop
```r3forth
:render
  | Clear screen
  SDLGLcls
  
  | Use shader
  my-program glUseProgram
  
  | Bind VAO
  vao glBindVertexArray
  
  | Draw triangle
  $0004 0 3 glDrawArrays
  
  | Present
  SDLGLupdate
  ;

:main-loop
  ( SDLkey >esc< <>?
    SDLupdate
    render
  )
  ;
```

### Texture Loading
```r3forth
#texture

:load-texture | 'pixels w h --
  1 'texture glGenTextures
  $0DE1 texture glBindTexture
  
  | Upload
  $0DE1 0 $1908 pick3 pick2 0 $1908 $1401 pick3
  glTexImage2D
  
  | Set parameters
  $0DE1 $2801 $2601 glTexParameteri  | Linear filter
  $0DE1 $2800 $2601 glTexParameteri
  $0DE1 $2802 $812F glTexParameteri  | Clamp to edge
  $0DE1 $2803 $812F glTexParameteri
  
  3drop
  ;

:use-texture
  $84C0 glActiveTexture  | Unit 0
  $0DE1 texture glBindTexture
  ;
```

### Framebuffer (Render to Texture)
```r3forth
#fbo #color-tex #depth-rbo

:create-fbo | w h --
  | Create FBO
  1 'fbo glGenFramebuffers
  $8D40 fbo glBindFramebuffer
  
  | Create color texture
  1 'color-tex glGenTextures
  $0DE1 color-tex glBindTexture
  $0DE1 0 $1908 pick2 over 0 $1908 $1401 0 glTexImage2D
  $0DE1 $2801 $2600 glTexParameteri  | Nearest
  $0DE1 $2800 $2600 glTexParameteri
  
  | Attach color
  $8D40 $8CE0 $0DE1 color-tex 0 glFramebufferTexture2D
  
  | Create depth renderbuffer
  1 'depth-rbo glGenRenderbuffers
  $8D41 depth-rbo glBindRenderbuffer
  $8D41 $81A5 pick2 over glRenderbufferStorage
  
  | Attach depth
  $8D40 $8D00 $8D41 depth-rbo glFramebufferRenderbuffer
  
  | Unbind
  0 glBindFramebuffer
  2drop
  ;

:render-to-fbo
  | Bind FBO
  $8D40 fbo glBindFramebuffer
  
  | Render scene
  render-scene
  
  | Unbind (back to screen)
  0 glBindFramebuffer
  ;
```

### Instanced Rendering
```r3forth
#instance-data * 400  | 100 instances × 4 floats

:setup-instances
  | Fill instance data (positions)
  100 ( 1? 1-
    dup 10 mod 2.0 * f2fp instance-data pick2 16 * + !
    dup 10 / 2.0 * f2fp instance-data pick2 16 * + 4 + !
  ) drop
  
  | Create instance VBO
  1 'instance-vbo glGenBuffers
  $8892 instance-vbo glBindBuffer
  $8892 400 'instance-data $88E4 glBufferData
  
  | Configure instance attribute
  1 2 $1406 0 8 0 glVertexAttribPointer
  1 glEnableVertexAttribArray
  1 1 glVertexAttribDivisor  | Per instance
  ;

:render-instances
  vao glBindVertexArray
  $0004 0 36 100 glDrawArraysInstanced  | 100 instances
  ;
```

---

## Best Practices

1. **Always check shader compilation**
   ```r3forth
   shader $8B81 'status glGetShaderiv
   status 0? ( print-error ; )
   ```

2. **Bind VAO before configuring attributes**
   ```r3forth
   vao glBindVertexArray
   | ... setup attributes ...
   0 glBindVertexArray
   ```

3. **Unbind resources after use**
   ```r3forth
   0 glBindVertexArray
   0 glBindBuffer
   0 glUseProgram
   ```

4. **Check glGetError during development**
   ```r3forth
   glGetError dup 0? ( drop ; ) print-error
   ```

5. **Use appropriate buffer usage hints**
   ```r3forth
   $88E4 | STATIC_DRAW - rarely changes
   $88E8 | DYNAMIC_DRAW - changes frequently
   ```

6. **Enable features once at init**
   ```r3forth
   $0B71 glEnable  | Depth test
   $0BE2 glEnable  | Blending
   ```

---

## OpenGL Constants Reference

### Buffer Targets
- `$8892` - GL_ARRAY_BUFFER
- `$8893` - GL_ELEMENT_ARRAY_BUFFER
- `$8A11` - GL_UNIFORM_BUFFER

### Buffer Usage
- `$88E4` - GL_STATIC
- `$88E4` - GL_STATIC_DRAW
- `$88E8` - GL_DYNAMIC_DRAW
- `$88E0` - GL_STREAM_DRAW

### Shader Types
- `$8B31` - GL_VERTEX_SHADER
- `$8B30` - GL_FRAGMENT_SHADER

### Primitive Modes
- `$0000` - GL_POINTS
- `$0001` - GL_LINES
- `$0004` - GL_TRIANGLES

### Texture Targets
- `$0DE1` - GL_TEXTURE_2D

### Texture Parameters
- `$2800` - GL_TEXTURE_MAG_FILTER
- `$2801` - GL_TEXTURE_MIN_FILTER
- `$2802` - GL_TEXTURE_WRAP_S
- `$2803` - GL_TEXTURE_WRAP_T

### Filter Modes
- `$2600` - GL_NEAREST
- `$2601` - GL_LINEAR

### Wrap Modes
- `$2901` - GL_REPEAT
- `$812F` - GL_CLAMP_TO_EDGE

### Capabilities
- `$0B71` - GL_DEPTH_TEST
- `$0BE2` - GL_BLEND

### Clear Bits
- `$4000` - GL_COLOR_BUFFER_BIT
- `$0100` - GL_DEPTH_BUFFER_BIT
- `$0400` - GL_STENCIL_BUFFER_BIT

---

## Performance Tips

1. **Minimize state changes** - Batch draws by shader/texture
2. **Use VAOs** - Faster than setting attributes per draw
3. **Prefer indexed drawing** - Use `glDrawElements`
4. **Use instancing** for repeated objects
5. **Batch uniforms** - Set all uniforms before drawing
6. **Reuse FBOs** - Don't recreate every frame
7. **Use appropriate buffer usage** hints

---

## Common Patterns

### Error Checking
```r3forth
:check-gl-error | "location" --
  glGetError 0? ( 2drop ; )
  swap "%s - GL Error: %h" print
  ;

"After shader compile" check-gl-error
```

---

## Notes

- **OpenGL Version:** 4.6 Core Profile by default
- **Context Creation:** Automatic with `SDLinitGL`
- **Function Loading:** Via SDL2 `SDL_GL_GetProcAddress`
- **VSync:** Enabled by default (can disable)
- **MSAA:** 8x antialiasing enabled
- **Coordinate System:** Right-handed (default OpenGL)
- **Clip Space:** -1 to +1 on all axes
- **Thread Safety:** Not thread-safe, use from main thread
- **Resource Cleanup:** Always delete shaders, programs, buffers, textures
- **Error Codes:** 0 = no error, check after critical operations</parameter>