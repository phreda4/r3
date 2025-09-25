# R3 SDL2 Extensions Library Documentation

## Overview

This document covers the complete R3 SDL2 ecosystem including the core SDL2 library and its extensions: SDL2_mixer (audio), SDL2_image (image loading), SDL2_net (networking), and SDL2_ttf (font rendering). These libraries provide comprehensive multimedia capabilities for R3 applications.

## Core SDL2 Library (`sdl2.r3`)

### Initialization and Window Management

#### Window Creation
```r3
SDLinit   | "title" w h --        // Standard window
SDLmini   | "title" w h --        // Minimal window setup
sdlinitR  | "title" w h --        // Resizable window
SDLinitScr| "title" display w h -- // Fullscreen on specific display
SDLfullw  | "title" display --    // Fullscreen with display resolution
```

**Examples:**
```r3
"My Game" 800 600 SDLinit         // Create 800x600 window
"Full Game" 0 SDLfullw           // Fullscreen on primary display
```

#### Window Management
```r3
SDLfull   | --                    // Switch to fullscreen
SDLquit   | --                    // Cleanup and exit
SDLblend  | --                    // Enable alpha blending
```

### Event System

#### Global Event Variables
```r3
#SDLkey    // Last key pressed (with modifiers)
#SDLchar   // Text input character  
#SDLx #SDLy // Mouse position
#SDLb       // Mouse button state (bitfield)
#SDLw       // Mouse wheel delta
```

#### Event Processing
```r3
SDLupdate | --                    // Process all pending events
SDLshow   | 'word --             // Run main loop with event processing
exit      | --                   // Exit main loop
```

**Example:**
```r3
:game-loop
    cls
    | Game logic here
    SDLredraw ;

'game-loop SDLshow               // Run until exit called
```

### Rendering Functions

#### Basic Drawing
```r3
SDLredraw             | --        // Present rendered frame
SDL_SetRenderDrawColor| r g b a -- // Set drawing color
SDL_RenderClear       | --        // Clear screen
SDL_RenderFillRect    | rect --   // Fill rectangle
SDL_RenderDrawLine    | x1 y1 x2 y2 -- // Draw line
```

#### Texture Operations
```r3
SDL_CreateTexture     | format access w h -- tex
SDL_DestroyTexture    | tex --
SDL_RenderCopy        | tex src dst --
SDL_RenderCopyEx      | tex src dst angle center flip --
SDL_SetTextureColorMod| tex r g b --
SDL_SetTextureAlphaMod| tex alpha --
```

### Audio System

#### Basic Audio
```r3
SDL_OpenAudioDevice   | device spec callback userdata changes -- dev
SDL_QueueAudio        | device data len --
SDL_PauseAudioDevice  | device pause --
SDL_CloseAudioDevice  | device --
```

## SDL2_mixer - Audio Library (`sdl2mixer.r3`)

### Initialization
```r3
SNDInit   | --                    // Initialize audio system (44.1kHz, stereo)
SNDQuit   | --                    // Cleanup audio system
```

### Sound Effects
```r3
Mix_LoadWAV    | "file" -- chunk  // Load WAV file
Mix_FreeChunk  | chunk --         // Free sound chunk
SNDplay        | chunk --         // Play sound on any channel
SNDplayn       | channel chunk -- // Play sound on specific channel
```

### Music Playback
```r3
Mix_LoadMUS       | "file" -- music    // Load music file
Mix_PlayMusic     | music loops --     // Play music
Mix_HaltMusic     | --                 // Stop music
Mix_FadeOutMusic  | ms --              // Fade out over time
Mix_VolumeMusic   | volume --          // Set music volume (0-128)
Mix_FreeMusic     | music --           // Free music
```

**Example:**
```r3
#bgmusic #explosion-sound

:load-audio
    "audio/music.ogg" Mix_LoadMUS 'bgmusic !
    "audio/explosion.wav" Mix_LoadWAV 'explosion-sound ! ;

:play-background
    bgmusic -1 Mix_PlayMusic ;         // Loop forever

:explode
    explosion-sound SNDplay ;
```

### Advanced Audio
```r3
Mix_HaltChannel      | channel --      // Stop specific channel
Mix_FadeOutChannel   | channel ms --   // Fade out channel
Mix_PlayChannelTimed | chan chunk loops ms -- // Timed playback
Mix_Playing          | channel -- flag // Check if channel playing
Mix_MasterVolume     | volume --       // Master volume control
```

## SDL2_image - Image Loading Library (`sdl2image.r3`)

### Image Loading
```r3
loadimg     | "file" -- texture       // Load image as texture
IMG_Load    | "file" -- surface       // Load as surface
unloadimg   | texture --               // Destroy texture
```

### SVG Support
```r3
loadsvg     | w h "file" -- texture   // Load SVG at specific size
IMG_LoadSizedSVG_RW | rw w h -- surface // Load SVG from RW stream
```

### Image Saving
```r3
IMG_SavePNG | surface "file" --       // Save surface as PNG
IMG_SaveJPG | surface "file" quality -- // Save as JPEG
```

**Example:**
```r3
#player-sprite #background

:load-graphics
    "gfx/player.png" loadimg 'player-sprite !
    "gfx/background.jpg" loadimg 'background !
    64 64 "gfx/icon.svg" loadsvg 'icon ! ;

:draw-scene
    background 0 0 'screen-rect SDL_RenderCopy
    player-sprite 0 'player-rect SDL_RenderCopy ;
```

### Animation Support
```r3
IMG_LoadAnimation  | "file" -- anim   // Load animated image
IMG_FreeAnimation  | anim --          // Free animation
```

## SDL2_net - Networking Library (`sdl2net.r3`)

### Initialization
```r3
SDLNet_Init     | --                  // Initialize networking
SDLNet_Quit     | --                  // Cleanup networking
```

### TCP Networking
```r3
SDLNet_TCP_OpenServer  | ip -- socket     // Create server socket
SDLNet_TCP_OpenClient  | ip -- socket     // Connect to server
SDLNet_TCP_Accept      | server -- client // Accept connection
SDLNet_TCP_Send        | socket data len -- sent
SDLNet_TCP_Recv        | socket data len -- received
SDLNet_TCP_Close       | socket --        // Close connection
```

### UDP Networking
```r3
SDLNet_UDP_Open        | port -- socket   // Open UDP socket
SDLNet_UDP_Send        | socket packet -- // Send UDP packet
SDLNet_UDP_Recv        | socket packet -- // Receive UDP packet
SDLNet_UDP_Close       | socket --        // Close UDP socket
```

### Address Resolution
```r3
SDLNet_ResolveHost     | ip "host" port -- // Resolve hostname
SDLNet_ResolveIP       | ip -- "hostname"  // Reverse lookup
```

**Example:**
```r3
#server-socket #client-data

:start-server
    here 0 0 !+ 8080 !         // Create IPaddress for port 8080
    SDLNet_ResolveHost
    dup SDLNet_TCP_OpenServer 'server-socket ! ;

:handle-client | client --
    dup 'client-data 1024 SDLNet_TCP_Recv
    0 >? ( process-message ) drop
    SDLNet_TCP_Close ;

:server-loop
    server-socket SDLNet_TCP_Accept
    dup 0 >? ( handle-client ) drop ;
```

## SDL2_ttf - Font Rendering Library (`sdl2ttf.r3`)

### Font Management
```r3
TTF_OpenFont    | "file" size -- font    // Load font at size
TTF_CloseFont   | font --                // Close font
TTF_SetFontStyle| font style --          // Set style (bold, italic)
```

### Text Rendering
```r3
TTF_RenderUTF8_Solid   | font "text" color -- surface
TTF_RenderUTF8_Shaded  | font "text" fg bg -- surface
TTF_RenderUTF8_Blended | font "text" color -- surface
TTF_RenderUTF8_Blended_Wrapped | font "text" color width -- surface
```

### Text Measurement
```r3
TTF_SizeUTF8    | font "text" &w &h --   // Get text dimensions
TTF_MeasureUTF8 | font "text" width &extent &count -- // Measure wrapping
```

**Example:**
```r3
#main-font #title-font

:load-fonts
    "fonts/arial.ttf" 16 TTF_OpenFont 'main-font !
    "fonts/arial.ttf" 32 TTF_OpenFont 'title-font ! ;

:draw-text | "text" x y font --
    $ffffff TTF_RenderUTF8_Blended      // Render to surface
    SDLrenderer over SDL_CreateTextureFromSurface // Convert to texture
    swap SDL_FreeSurface                // Free surface
    | Now blit texture at x,y
    ;
```

## Complete Application Example

```r3
| Complete multimedia application
^r3/lib/sdl2.r3
^r3/lib/sdl2mixer.r3
^r3/lib/sdl2image.r3
^r3/lib/sdl2ttf.r3

#background-music
#sound-effect
#background-image
#player-sprite
#game-font
#player-x 100
#player-y 100

:load-resources
    | Load audio
    "audio/background.ogg" Mix_LoadMUS 'background-music !
    "audio/jump.wav" Mix_LoadWAV 'sound-effect !
    
    | Load graphics  
    "gfx/background.png" loadimg 'background-image !
    "gfx/player.png" loadimg 'player-sprite !
    
    | Load font
    "fonts/game.ttf" 24 TTF_OpenFont 'game-font ! ;

:play-background
    background-music -1 Mix_PlayMusic ;

:handle-input
    SDLkey
    >left< =? ( -5 'player-x +! )
    >right< =? ( 5 'player-x +! )
    >space< =? ( sound-effect SNDplay )
    drop ;

:draw-game
    | Clear screen
    0 0 0 255 SDL_SetRenderDrawColor
    SDLrenderer SDL_RenderClear
    
    | Draw background
    background-image 0 0 here !+ !+ sw sh here !+ !+
    SDLrenderer background-image 0 'here SDL_RenderCopy
    
    | Draw player
    player-sprite 0 0 32 32 here !+ !+ !+ !+
    player-x player-y 32 32 here !+ !+ !+ !+
    SDLrenderer player-sprite 'here 'here 32 + SDL_RenderCopy
    
    | Draw score
    game-font "Score: 1000" $ffffff TTF_RenderUTF8_Blended
    SDLrenderer over SDL_CreateTextureFromSurface
    | Position and draw text texture...
    
    SDLredraw ;

:game-loop
    handle-input
    draw-game ;

:cleanup
    background-music Mix_FreeMusic
    sound-effect Mix_FreeChunk
    background-image unloadimg
    player-sprite unloadimg
    game-font TTF_CloseFont
    SNDQuit
    SDLquit ;

:main
    "My Game" 800 600 SDLinit
    load-resources
    play-background
    'game-loop SDLshow
    cleanup ;

main
```

## Performance Tips

### Graphics Optimization
- **Batch Rendering**: Group similar operations together
- **Texture Atlas**: Combine small textures into larger ones
- **Avoid Frequent Texture Creation**: Cache textures when possible
- **Use Hardware Acceleration**: Prefer textures over surfaces

### Audio Optimization  
- **Preload Sounds**: Load frequently used sounds at startup
- **Use Appropriate Formats**: OGG for music, WAV for effects
- **Limit Concurrent Sounds**: Don't play too many sounds simultaneously
- **Stream Large Files**: Use Mix_LoadMUS for background music

### Memory Management
- **Free Resources**: Always free loaded assets when done
- **Resource Pooling**: Reuse textures and sounds when possible
- **Check Return Values**: Handle loading failures gracefully

## Cross-Platform Considerations

The libraries automatically select the correct dynamic library:
- **Windows**: Uses DLL files from `dll/` directory
- **Linux**: Uses shared objects from system libraries

### File Paths
- Use forward slashes `/` in paths (works on both platforms)
- Place resources in predictable locations relative to executable
- Check file existence before loading when possible

This SDL2 ecosystem provides a complete foundation for multimedia applications in R3, supporting graphics, audio, networking, and text rendering with good performance and cross-platform compatibility.