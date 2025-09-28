# R3 SDL2 OpenGL Integration Library Documentation

## Overview

`sdl2gl.r3` provides comprehensive OpenGL integration with SDL2, enabling hardware-accelerated 3D graphics in R3 applications. It dynamically loads OpenGL functions through SDL2's extension mechanism and provides complete access to modern OpenGL features including shaders, vertex buffer objects, and advanced rendering techniques.

## Dependencies
- `r3/lib/sdl2.r3` - SDL2 windowing and context management

## Core Concepts

### OpenGL Context Management
The library handles OpenGL context creation and management through SDL2, providing:
- **Hardware acceleration** through native OpenGL drivers
- **Cross-platform compatibility** via SDL2's abstraction layer
- **Modern OpenGL support** (OpenGL 4.6 core profile)
- **Dynamic function loading** for maximum compatibility

### Function Categories
- **Core OpenGL**: Basic rendering, state management, error handling
- **Shader Pipeline**: Modern programmable shaders (vertex/fragment)
- **Buffer Objects**: Vertex Buffer Objects (VBO), Vertex Array Objects (VAO)
- **Texturing**: 2D textures, texture units, sampling
- **Legacy Support**: Immediate mode rendering for simple cases

## Initialization Functions

### Context Creation
```r3
SDLinitGL    | "title" width height --   // Initialize OpenGL window
SDLinitSGL   | "title" width height --   // Initialize with SDL renderer fallback
InitGLAPI    | --                        // Load OpenGL function pointers
```

### Window Management
```r3
SDLGLcls     | --                        // Clear color and depth buffers
SDLGLupdate  | --                        // Swap buffers (present frame)
SDLglquit    | --                        // Clean up OpenGL context
```

**Example Initialization:**
```r3
"My 3D Game" 800 600 SDLinitGL          // Create OpenGL window
glInfo                                   // Display GPU information
```

## Shader Management

### Shader Creation
```r3
glCreateShader    | type -- shader_id        // Create shader object
glShaderSource    | shader count sources lengths -- // Set shader source code
glCompileShader   | shader --                 // Compile shader
glDeleteShader    | shader --                 // Delete shader object
```

### Program Management
```r3
glCreateProgram   | -- program_id             // Create shader program
glAttachShader    | program shader --         // Attach shader to program
glDetachShader    | program shader --         // Detach shader
glLinkProgram     | program --                // Link shader program
glUseProgram      | program --                // Activate shader program
glDeleteProgram   | program --                // Delete program
```

### Shader Information
```r3
glGetShaderiv     | shader pname result --   // Get shader parameter
glGetProgramiv    | program pname result --  // Get program parameter
glGetShaderInfoLog| shader maxlen length log -- // Get compilation errors
glGetProgramInfoLog| program maxlen length log -- // Get linking errors
```

## Buffer Management

### Buffer Objects
```r3
glGenBuffers      | count buffers --          // Generate buffer objects
glBindBuffer      | target buffer --          // Bind buffer for operations
glBufferData      | target size data usage -- // Upload data to buffer
glBufferSubData   | target offset size data -- // Update buffer data
glDeleteBuffers   | count buffers --          // Delete buffer objects
```

### Vertex Array Objects
```r3
glGenVertexArrays | count arrays --           // Generate VAOs
glBindVertexArray | array --                  // Bind VAO
glDeleteVertexArrays| count arrays --         // Delete VAOs
```

### Vertex Attributes
```r3
glEnableVertexAttribArray | index --          // Enable vertex attribute
glDisableVertexAttribArray| index --          // Disable vertex attribute
glVertexAttribPointer| index size type normalized stride pointer -- // Set attribute format
glGetAttribLocation| program name -- location // Get attribute location
```

## Texture Management

### Texture Objects
```r3
glGenTextures     | count textures --         // Generate texture objects
glBindTexture     | target texture --         // Bind texture
glTexImage2D      | target level format width height border format type data --
glTexSubImage2D   | target level xoff yoff width height format type data --
glDeleteTextures  | count textures --         // Delete textures
```

### Texture Parameters
```r3
glTexParameteri   | target pname param --     // Set integer parameter
glTexParameterfv  | target pname params --    // Set float parameters
glActiveTexture   | texture_unit --           // Select active texture unit
```

## Uniform Management

### Uniform Locations and Values
```r3
glGetUniformLocation | program name -- location // Get uniform location
glUniform1i       | location value --         // Set single integer
glUniform1fv      | location count values --  // Set float array
glUniform2fv      | location count values --  // Set vec2 array
glUniform3fv      | location count values --  // Set vec3 array
glUniform4fv      | location count values --  // Set vec4 array
glUniformMatrix4fv| location count transpose values -- // Set 4x4 matrix
```

## Rendering Commands

### Drawing Operations
```r3
glClear           | mask --                   // Clear buffers
glDrawArrays      | mode first count --       // Draw vertex arrays
glDrawElements    | mode count type indices -- // Draw indexed geometry
glDrawArraysInstanced| mode first count instances -- // Instanced drawing
glDrawElementsInstanced| mode count type indices instances -- // Instanced indexed
```

### Render State
```r3
glViewport        | x y width height --      // Set viewport
glScissor         | x y width height --      // Set scissor rectangle
glEnable          | capability --            // Enable OpenGL feature
glDisable         | capability --            // Disable OpenGL feature
glBlendFunc       | sfactor dfactor --       // Set blend function
glDepthFunc       | func --                  // Set depth test function
```

## Complete OpenGL Application Example

### Basic 3D Renderer
```r3
| Vertex shader source
#vertex-shader-source 
"#version 330 core
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aColor;
out vec3 vertexColor;
uniform mat4 mvp;

void main() {
    gl_Position = mvp * vec4(aPos, 1.0);
    vertexColor = aColor;
}" 0

| Fragment shader source  
#fragment-shader-source
"#version 330 core
in vec3 vertexColor;
out vec4 FragColor;

void main() {
    FragColor = vec4(vertexColor, 1.0);
}" 0

#shader-program
#vertex-buffer
#vertex-array
#mvp-location

| Triangle vertex data (position + color)
#triangle-vertices
-0.5 -0.5 0.0  1.0 0.0 0.0
 0.5 -0.5 0.0  0.0 1.0 0.0  
 0.0  0.5 0.0  0.0 0.0 1.0

:load-shader | source type -- shader
    glCreateShader >r
    r@ 1 rot 0 glShaderSource
    r@ glCompileShader
    r> ;

:create-shader-program
    vertex-shader-source $8B31 load-shader >r      // GL_VERTEX_SHADER
    fragment-shader-source $8B30 load-shader >r    // GL_FRAGMENT_SHADER
    
    glCreateProgram 'shader-program !
    shader-program r@ glAttachShader
    shader-program r> glAttachShader  
    shader-program glLinkProgram
    
    | Clean up individual shaders
    shader-program over glDetachShader glDeleteShader
    shader-program over glDetachShader glDeleteShader
    
    | Get uniform location
    shader-program "mvp" glGetUniformLocation 'mvp-location ! ;

:setup-geometry
    1 'vertex-array glGenVertexArrays
    vertex-array glBindVertexArray
    
    1 'vertex-buffer glGenBuffers  
    $8892 vertex-buffer glBindBuffer           // GL_ARRAY_BUFFER
    $8892 144 'triangle-vertices $88E4 glBufferData  // GL_STATIC_DRAW
    
    | Position attribute (location 0)
    0 glEnableVertexAttribArray
    0 3 $1406 0 24 0 glVertexAttribPointer     // 3 floats, stride 24, offset 0
    
    | Color attribute (location 1)  
    1 glEnableVertexAttribArray
    1 3 $1406 0 24 12 glVertexAttribPointer    // 3 floats, stride 24, offset 12
    
    0 glBindVertexArray ;                       // Unbind VAO

:render-frame | rotation-angle --
    | Clear screen
    0.2 0.3 0.3 1.0 glClearColor
    $4100 glClear                              // GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT
    
    | Use shader program
    shader-program glUseProgram
    
    | Create model-view-projection matrix
    | ... matrix calculations ...
    | mvp-location 1 0 'mvp-matrix glUniformMatrix4fv
    
    | Draw triangle
    vertex-array glBindVertexArray
    $0004 0 3 glDrawArrays                     // GL_TRIANGLES, 0, 3
    
    SDLGLupdate ;

:main-loop | --
    msec 1000.0 /. 'rotation !                // Rotation based on time
    rotation render-frame
    
    | Handle events...
    'main-loop onkey ;

:init-graphics
    "OpenGL Triangle" 800 600 SDLinitGL
    create-shader-program
    setup-geometry ;

:cleanup
    1 'vertex-buffer glDeleteBuffers
    1 'vertex-array glDeleteVertexArrays
    shader-program glDeleteProgram
    SDLglquit ;

| Main program
init-graphics
main-loop  
cleanup
```

### Texture Rendering Example
```r3
#texture-id
#texture-program
#texture-buffer
#texture-vao

| Quad with UV coordinates
#quad-vertices
| pos(3) + uv(2)
-1.0 -1.0 0.0  0.0 0.0
 1.0 -1.0 0.0  1.0 0.0
 1.0  1.0 0.0  1.0 1.0
-1.0  1.0 0.0  0.0 1.0

#quad-indices
0 1 2  2 3 0

:create-texture | width height data --
    1 'texture-id glGenTextures
    $0DE1 texture-id glBindTexture         // GL_TEXTURE_2D
    
    $0DE1 0 $1908 pick3 pick3 0 $1908 $1401 rot glTexImage2D  // RGB, UNSIGNED_BYTE
    
    $0DE1 $2801 $812F glTexParameteri      // GL_TEXTURE_MIN_FILTER, GL_LINEAR
    $0DE1 $2800 $812F glTexParameteri      // GL_TEXTURE_MAG_FILTER, GL_LINEAR
    
    2drop ;

:render-textured-quad
    $4100 glClear
    
    texture-program glUseProgram
    $84C0 glActiveTexture                  // GL_TEXTURE0
    $0DE1 texture-id glBindTexture
    
    texture-vao glBindVertexArray
    $0004 6 $1403 'quad-indices glDrawElements  // GL_TRIANGLES, UNSIGNED_SHORT
    
    SDLGLupdate ;
```

## Error Handling and Debugging

### Error Checking
```r3
glGetError        | -- error_code            // Get OpenGL error
glGetString       | name -- string           // Get OpenGL information
```

### GPU Information
```r3
glInfo            | --                       // Print GPU information
```

**Usage:**
```r3
:check-gl-error | "operation" --
    glGetError 
    0? ( drop ; )                            // No error
    "OpenGL Error in " print print ": " print .h cr ;

"Shader compilation" check-gl-error
```

## Advanced Features

### Instanced Rendering
```r3
glDrawArraysInstanced | mode first count instances --
glDrawElementsInstanced| mode count type indices instances --
glVertexAttribDivisor | index divisor --     // Set instance divisor
```

### Framebuffer Objects
```r3
glGenFramebuffers    | count framebuffers --
glBindFramebuffer    | target framebuffer --
glFramebufferTexture2D| target attachment textarget texture level --
glGenRenderbuffers   | count renderbuffers --
glRenderbufferStorage| target format width height --
```

### Buffer Mapping
```r3
glMapBuffer          | target access -- pointer
glUnmapBuffer        | target --
```

## Performance Optimization

### Batch Operations
- **Minimize state changes**: Group similar rendering operations
- **Use VAOs**: Pre-configure vertex attribute state
- **Buffer reuse**: Reuse buffers for dynamic data
- **Texture atlasing**: Combine multiple textures

### Memory Management  
- **Static geometry**: Use GL_STATIC_DRAW for unchanging data
- **Dynamic updates**: Use GL_DYNAMIC_DRAW for frequently changing data
- **Streaming**: Use GL_STREAM_DRAW for single-use data

## Best Practices

1. **Error Checking**: Always check for OpenGL errors during development
2. **Resource Cleanup**: Delete all OpenGL objects before exit
3. **State Management**: Track OpenGL state to avoid redundant calls
4. **Shader Validation**: Check compilation and linking status
5. **Buffer Organization**: Structure vertex data for optimal access patterns

This OpenGL integration provides comprehensive access to modern GPU features while maintaining R3's performance-oriented design philosophy, enabling sophisticated 3D graphics applications with predictable resource usage.