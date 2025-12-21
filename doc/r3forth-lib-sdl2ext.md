# R3Forth SDL2 Extensions Libraries

Comprehensive bindings for SDL2 extension libraries providing audio, image, networking, and font capabilities for R3Forth applications.

## Overview

These libraries extend SDL2's core functionality with specialized features:
- **SDL2_mixer**: Audio playback (sound effects and music)
- **SDL2_image**: Image loading (PNG, JPG, BMP, GIF, SVG, etc.)
- **SDL2_net**: Network communication (TCP/UDP sockets)
- **SDL2_ttf**: TrueType font rendering

All libraries follow the same pattern: platform-agnostic interface with automatic Windows/Linux library loading.

**Dependencies:**
- `r3/lib/sdl2.r3` - Core SDL2 library
- Platform core libraries for system calls

---

# SDL2_mixer - Audio Library

Audio playback system supporting multiple channels, music, and sound effects.

## Initialization

### System Setup

- **`Mix_Init`** `( flags -- result )` - Initialize SDL_mixer subsystems
  - Flags: $01=FLAC, $02=MOD, $04=MP3, $08=OGG, $10=MID, $20=OPUS
  - Returns: Flags of initialized subsystems
  ```
  $0C Mix_Init  | Initialize MP3 and OGG support
  ```

- **`Mix_Quit`** `( -- )` - Shutdown SDL_mixer
  - Cleanup all audio resources
  - Call before program exit

- **`SNDInit`** `( -- )` - Quick audio initialization
  - Opens audio at 44100Hz, stereo, 4096 buffer
  - Ready-to-use default setup
  ```
  SNDInit  | Initialize with defaults
  ```

- **`SNDQuit`** `( -- )` - Shutdown audio system
  - Closes audio device
  - Cleanup helper

---

## Sound Effects (Chunks)

### Loading and Freeing

- **`Mix_LoadWAV`** `( "file" -- chunk )` - Load WAV/audio file
  - Returns sound chunk handle
  - Supports WAV, OGG (if initialized)
  ```
  "sounds/laser.wav" Mix_LoadWAV 'laserSound !
  ```

- **`Mix_FreeChunk`** `( chunk -- )` - Free sound chunk
  - Release memory for sound effect
  ```
  laserSound Mix_FreeChunk
  ```

### Playback

- **`SNDplay`** `( chunk -- )` - Play sound on any free channel
  - Auto-selects available channel
  - Plays once, no looping
  ```
  laserSound SNDplay
  ```

- **`SNDplayn`** `( chunk channel -- )` - Play on specific channel
  - Channel: 0-based index
  - Allows channel management
  ```
  explosionSound 2 SNDplayn  | Play on channel 2
  ```

- **`Mix_PlayChannelTimed`** `( channel chunk loops ticks -- channel )` - Full control playback
  - `channel`: -1 for any free, or specific channel
  - `chunk`: Sound to play
  - `loops`: -1 for infinite, 0 for once, N for N+1 times
  - `ticks`: Duration in milliseconds (-1 for complete)
  ```
  -1 ambientSound -1 -1 Mix_PlayChannelTimed  | Loop forever
  0 shortSound 2 5000 Mix_PlayChannelTimed    | Play 3 times for 5 seconds
  ```

### Channel Control

- **`Mix_HaltChannel`** `( channel -- )` - Stop channel immediately
  - -1 stops all channels
  ```
  2 Mix_HaltChannel  | Stop channel 2
  -1 Mix_HaltChannel | Stop all channels
  ```

- **`Mix_FadeOutChannel`** `( channel ms -- )` - Fade out channel
  - `ms`: Fade duration in milliseconds
  ```
  2 1000 Mix_FadeOutChannel  | Fade out channel 2 over 1 second
  ```

- **`Mix_Playing`** `( channel -- flag )` - Check if channel is playing
  - Returns 1 if playing, 0 if stopped
  ```
  2 Mix_Playing ( "Channel 2 active" print ; ) drop
  ```

---

## Music

Music is for long audio (background music), only one music track plays at a time.

### Loading and Freeing

- **`Mix_LoadMUS`** `( "file" -- music )` - Load music file
  - Supports MP3, OGG, FLAC, MOD, MID, etc.
  ```
  "music/theme.mp3" Mix_LoadMUS 'bgMusic !
  ```

- **`Mix_FreeMusic`** `( music -- )` - Free music resource
  ```
  bgMusic Mix_FreeMusic
  ```

### Music Control

- **`Mix_PlayMusic`** `( music loops -- )` - Play music
  - `loops`: -1 for infinite, 0 for once
  ```
  bgMusic -1 Mix_PlayMusic  | Loop forever
  ```

- **`Mix_HaltMusic`** `( -- )` - Stop music immediately

- **`Mix_FadeOutMusic`** `( ms -- )` - Fade out music
  - `ms`: Fade duration in milliseconds
  ```
  2000 Mix_FadeOutMusic  | Fade out over 2 seconds
  ```

- **`Mix_PlayingMusic`** `( -- flag )` - Check if music is playing
  - Returns 1 if playing, 0 if stopped

### Volume Control

- **`Mix_VolumeMusic`** `( volume -- )` - Set music volume
  - `volume`: 0 (silent) to 128 (max)
  ```
  64 Mix_VolumeMusic  | Half volume
  ```

- **`Mix_MasterVolume`** `( volume -- )` - Set master volume
  - Affects all audio (chunks and music)
  - `volume`: 0-128
  ```
  100 Mix_MasterVolume  | ~78% volume
  ```

---

## Audio Configuration

- **`Mix_OpenAudio`** `( freq format channels chunksize -- )` - Open audio device
  - `freq`: Sample rate (22050, 44100, 48000)
  - `format`: Audio format ($8010 = 16-bit signed, $8008 = 8-bit unsigned)
  - `channels`: 1=mono, 2=stereo
  - `chunksize`: Buffer size (1024, 2048, 4096)
  ```
  44100 $8010 2 4096 Mix_OpenAudio  | CD-quality stereo
  ```

- **`Mix_CloseAudio`** `( -- )` - Close audio device

---

## Audio Examples

### Basic Sound Effect

```r3forth
^r3/lib/sdl2mixer.r3

#jumpSound #landSound

:loadSounds
    "sfx/jump.wav" Mix_LoadWAV 'jumpSound !
    "sfx/land.wav" Mix_LoadWAV 'landSound ! ;

:playJump
    jumpSound SNDplay ;

:playLand
    landSound SNDplay ;

loadSounds
```

### Background Music

```r3forth
#bgMusic

:startMusic
    "music/level1.mp3" Mix_LoadMUS 'bgMusic !
    bgMusic -1 Mix_PlayMusic  | Loop forever
    64 Mix_VolumeMusic ;      | Half volume

:stopMusic
    2000 Mix_FadeOutMusic     | Fade out over 2 seconds
    bgMusic Mix_FreeMusic ;

startMusic
```

### Multi-Channel Management

```r3forth
#weaponChannel 0
#ambientChannel 1

:fireWeapon
    weaponSound weaponChannel SNDplayn ;

:startAmbient
    ambientSound ambientChannel 
    -1 -1 Mix_PlayChannelTimed drop  | Loop forever ;

:stopAmbient
    ambientChannel 1000 Mix_FadeOutChannel ;
```

---

# SDL2_image - Image Loading Library

Load images in various formats and convert to SDL textures.

## Core Functions

### Image Loading

- **`IMG_Load`** `( "file" -- surface )` - Load image to surface
  - Returns SDL_Surface
  - Must be converted to texture for rendering
  ```
  "images/player.png" IMG_Load 'playerSurface !
  ```

- **`IMG_LoadTexture`** `( renderer "file" -- texture )` - Load directly to texture
  - One-step loading and conversion
  - Ready for rendering
  ```
  SDLrenderer "images/player.png" IMG_LoadTexture 'playerTex !
  ```

### Helper Functions

- **`loadimg`** `( "file" -- texture )` - Simplified texture loading
  - Uses current renderer
  - Returns texture ready to render
  ```
  "sprites/enemy.png" loadimg 'enemyTex !
  ```

- **`unloadimg`** `( texture -- )` - Free texture
  - Wrapper for SDL_DestroyTexture
  ```
  enemyTex unloadimg
  ```

---

## SVG Support

- **`IMG_LoadSizedSVG_RW`** `( rwops w h -- surface )` - Load SVG at specific size
  - Rasterizes vector graphics
  - `w`, `h`: Output dimensions
  ```
  svgFile 256 256 IMG_LoadSizedSVG_RW
  ```

- **`loadsvg`** `( w h "file" -- texture )` - Load SVG as texture
  - Scales SVG to specified dimensions
  - Returns texture ready to render
  ```
  128 128 "icons/star.svg" loadsvg 'starIcon !
  ```

---

## Animated Images

- **`IMG_LoadAnimation`** `( "file" -- anim )` - Load animated image
  - Supports animated GIF, APNG
  - Returns animation structure

- **`IMG_FreeAnimation`** `( anim -- )` - Free animation resource

---

## Image Saving

### PNG Format

- **`IMG_SavePNG`** `( surface "file" -- )` - Save surface as PNG
  ```
  screenshot "output.png" IMG_SavePNG
  ```

- **`IMG_SavePNG_RW`** `( surface rwops freedst -- )` - Save PNG to RWops

### JPG Format

- **`IMG_SaveJPG`** `( surface "file" quality -- )` - Save as JPEG
  - `quality`: 0-100 (100 = best quality)
  ```
  photo "photo.jpg" 90 IMG_SaveJPG
  ```

- **`IMG_SaveJPG_RW`** `( surface rwops freedst quality -- )` - Save JPEG to RWops

---

## Image Examples

### Load and Display Sprite

```r3forth
^r3/lib/sdl2image.r3

#playerSprite

:loadAssets
    "sprites/player.png" loadimg 'playerSprite ! ;

:drawPlayer
    SDLrenderer playerSprite 0 100 100 64 64 SDL_RenderCopy ;

loadAssets
```

### Screenshot System

```r3forth
:takeScreenshot
    SDLrenderer SDL_GetRenderTarget 
    dup "screenshot.png" IMG_SavePNG
    SDL_FreeSurface ;
```

### SVG Icon Loading

```r3forth
#playIcon #pauseIcon

:loadIcons
    64 64 "icons/play.svg" loadsvg 'playIcon !
    64 64 "icons/pause.svg" loadsvg 'pauseIcon ! ;
```

---

# SDL2_net - Network Library

TCP and UDP networking for multiplayer and online features.

## Initialization

- **`SDLNet_Init`** `( -- )` - Initialize networking
- **`SDLNet_Quit`** `( -- )` - Shutdown networking

---

## Address Resolution

### IPaddress Structure

```
Uint32 host;  | 32-bit IPv4 address
Uint16 port;  | 16-bit port number
```

- **`SDLNet_ResolveHost`** `( ipaddr "host" port -- result )` - Resolve hostname
  - `ipaddr`: Pointer to IPaddress structure
  - `host`: Hostname or IP string (0 for INADDR_ANY)
  - `port`: Port number
  - Returns: 0 on success, -1 on error
  ```
  'serverIP 0 1234 SDLNet_ResolveHost  | Listen on port 1234
  'clientIP "game.server.com" 1234 SDLNet_ResolveHost  | Connect
  ```

- **`SDLNet_ResolveIP`** `( ipaddr -- "host" )` - Get hostname from IP
  - Returns hostname string

- **`SDLNet_GetLocalAddresses`** `( addrArray maxCount -- count )` - Get local IPs
  - Returns number of local addresses

---

## TCP Networking

### Server Functions

- **`SDLNet_TCP_OpenServer`** `( ipaddr -- socket )` - Open TCP server
  - Listen for incoming connections
  ```
  'serverIP SDLNet_TCP_OpenServer 'serverSocket !
  ```

- **`SDLNet_TCP_Accept`** `( serverSocket -- clientSocket )` - Accept connection
  - Non-blocking: returns 0 if no connection
  - Returns client socket if connection available
  ```
  serverSocket SDLNet_TCP_Accept 
  dup ( handleNewClient ; ) drop
  ```

### Client Functions

- **`SDLNet_TCP_Open`** `( ipaddr -- socket )` - Connect to server
  ```
  'serverIP SDLNet_TCP_Open 'connection !
  ```

### Data Transfer

- **`SDLNet_TCP_Send`** `( socket data len -- sent )` - Send data
  - Returns bytes sent (should equal len)
  ```
  clientSocket messageBuffer 256 SDLNet_TCP_Send
  ```

- **`SDLNet_TCP_Recv`** `( socket buffer maxlen -- received )` - Receive data
  - Returns bytes received (0 = disconnected)
  ```
  clientSocket recvBuffer 1024 SDLNet_TCP_Recv
  ```

### Connection Management

- **`SDLNet_TCP_Close`** `( socket -- )` - Close TCP socket

- **`SDLNet_TCP_GetPeerAddress`** `( socket -- ipaddr )` - Get remote address

---

## UDP Networking

### Socket Management

- **`SDLNet_UDP_Open`** `( port -- socket )` - Open UDP socket
  - `port`: Local port (0 for any)
  ```
  0 SDLNet_UDP_Open 'udpSocket !  | Any port
  1234 SDLNet_UDP_Open 'gameSocket !  | Specific port
  ```

- **`SDLNet_UDP_Close`** `( socket -- )` - Close UDP socket

### Packet Management

- **`SDLNet_AllocPacket`** `( size -- packet )` - Allocate UDP packet
  - `size`: Maximum packet data size
  ```
  1024 SDLNet_AllocPacket 'packet !
  ```

- **`SDLNet_FreePacket`** `( packet -- )` - Free packet

- **`SDLNet_ResizePacket`** `( packet newsize -- result )` - Resize packet buffer

### Sending and Receiving

- **`SDLNet_UDP_Send`** `( socket channel packet -- sent )` - Send UDP packet
  - `channel`: -1 for unbound, or bound channel
  - Returns 1 on success
  ```
  udpSocket -1 packet SDLNet_UDP_Send
  ```

- **`SDLNet_UDP_Recv`** `( socket packet -- received )` - Receive packet
  - Returns 1 if packet received, 0 otherwise
  ```
  udpSocket packet SDLNet_UDP_Recv
  ```

### Channel Binding

- **`SDLNet_UDP_Bind`** `( socket channel ipaddr -- )` - Bind address to channel
  - Allows sending without specifying address

- **`SDLNet_UDP_Unbind`** `( socket channel -- )` - Unbind channel

---

## Socket Sets (Multiplexing)

- **`SDLNet_AllocSocketSet`** `( maxsockets -- socketset )` - Create socket set
  - For monitoring multiple sockets

- **`SDLNet_AddSocket`** `( socketset socket -- )` - Add socket to set

- **`SDLNet_DelSocket`** `( socketset socket -- )` - Remove socket from set

- **`SDLNet_CheckSockets`** `( socketset timeout -- ready )` - Check for activity
  - `timeout`: Milliseconds to wait (0 = poll)
  - Returns number of ready sockets

- **`SDLNet_FreeSocketSet`** `( socketset -- )` - Free socket set

---

---

# SDL2_ttf - Font Rendering Library

Render TrueType fonts to textures and surfaces.

## Initialization

- **`TTF_Init`** `( -- )` - Initialize TTF library
- **`TTF_Quit`** `( -- )` - Shutdown TTF library

---

## Font Management

### Loading and Closing

- **`TTF_OpenFont`** `( "file" ptsize -- font )` - Open font file
  - `ptsize`: Point size (height in pixels)
  ```
  "fonts/arial.ttf" 24 TTF_OpenFont 'mainFont !
  ```

- **`TTF_CloseFont`** `( font -- )` - Close font
  ```
  mainFont TTF_CloseFont
  ```

### Font Properties

- **`TTF_SetFontSize`** `( font ptsize -- )` - Change font size
  ```
  mainFont 32 TTF_SetFontSize
  ```

- **`TTF_SetFontStyle`** `( font style -- )` - Set font style
  - Style: $01=bold, $02=italic, $04=underline, $08=strikethrough
  ```
  mainFont $03 TTF_SetFontStyle  | Bold + Italic
  ```

- **`TTF_SetFontOutline`** `( font outline -- )` - Set outline width
  - `outline`: Outline thickness in pixels (0 = no outline)
  ```
  mainFont 2 TTF_SetFontOutline  | 2-pixel outline
  ```

- **`TTF_SetFontLineSkip`** `( font lineskip -- )` - Set line spacing

- **`TTF_SetFontWrappedAlign`** `( font align -- )` - Set text alignment
  - Align: 0=left, 1=center, 2=right

- **`TTF_SetFontSDF`** `( font flag -- )` - Enable signed distance field rendering

---

## Text Measurement

- **`TTF_SizeText`** `( font "text" 'w 'h -- )` - Get text dimensions
  - Stores width in `'w`, height in `'h`
  ```
  mainFont "Hello" 'textW 'textH TTF_SizeText
  ```

- **`TTF_SizeUTF8`** `( font "text" 'w 'h -- )` - UTF-8 text dimensions

- **`TTF_MeasureUTF8`** `( font "text" width 'extent 'count -- )` - Measure with wrapping
  - `width`: Maximum width
  - `'extent`: Actual width used
  - `'count`: Number of characters that fit

---

## Text Rendering

All render functions return SDL_Surface that must be converted to texture.

### Solid Rendering (Fastest)

- **`TTF_RenderText_Solid`** `( font "text" color -- surface )` - Solid text
  - No antialiasing
  - Single color
  ```
  mainFont "Score" $ffffff TTF_RenderText_Solid
  ```

- **`TTF_RenderUTF8_Solid`** `( font "text" color -- surface )` - UTF-8 solid

### Shaded Rendering

- **`TTF_RenderText_Shaded`** `( font "text" fg bg -- surface )` - Shaded text
  - Antialiased
  - Foreground and background colors
  ```
  mainFont "Title" $ffffff $000000 TTF_RenderText_Shaded
  ```

- **`TTF_RenderUTF8_Shaded`** `( font "text" fg bg -- surface )` - UTF-8 shaded

### Blended Rendering (Highest Quality)

- **`TTF_RenderText_Blended`** `( font "text" color -- surface )` - Blended text
  - Highest quality antialiasing
  - Alpha blending
  ```
  mainFont "Message" $ff00ff TTF_RenderText_Blended
  ```

- **`TTF_RenderUTF8_Blended`** `( font "text" color -- surface )` - UTF-8 blended

- **`TTF_RenderUTF8_Blended_Wrapped`** `( font "text" color width -- surface )` - Wrapped text
  - Word wrapping at specified width
  ```
  mainFont longText $ffffff 400 TTF_RenderUTF8_Blended_Wrapped
  ```

- **`TTF_RenderUNICODE_Blended`** `( font "text" color -- surface )` - Unicode blended

---

## Font Examples

### Basic Text Rendering

```r3forth
^r3/lib/sdl2ttf.r3

#font
#textTexture

:initFont
    "fonts/arial.ttf" 24 TTF_OpenFont 'font ! ;

:renderText | "text" --
    font swap $ffffff TTF_RenderUTF8_Blended
    SDLrenderer over SDL_CreateTextureFromSurface
    'textTexture !
    SDL_FreeSurface ;

:drawText
    SDLrenderer textTexture 0 100 100 200 50 SDL_RenderCopy ;

initFont
"Hello World" renderText
```

### Styled Text

```r3forth
:createTitle | "text" --
    | Set bold + outline
    font $01 TTF_SetFontStyle
    font 3 TTF_SetFontOutline
    
    | Render
    font swap $ffff00 TTF_RenderUTF8_Blended
    
    | Reset style
    font 0 TTF_SetFontStyle
    font 0 TTF_SetFontOutline
    
    | Convert to texture
    SDLrenderer over SDL_CreateTextureFromSurface
    swap SDL_FreeSurface ;

"GAME TITLE" createTitle 'titleTex !
```

### Dynamic Score Display

```r3forth
#scoreFont
#scoreTex

:updateScore | score --
    | Free old texture
    scoreTex SDL_DestroyTexture
    
    | Render new score
    "Score: %d" sprint
    scoreFont swap $00ff00 TTF_RenderUTF8_Blended
    SDLrenderer over SDL_CreateTextureFromSurface
    'scoreTex !
    SDL_FreeSurface ;

150 updateScore
```

---

## Platform Support

All libraries automatically load the correct platform-specific DLL/shared library:

**Windows:**
- `dll/SDL2_mixer.DLL`
- `dll/SDL2_image.DLL`
- `dll/SDL2_net.DLL`
- `dll/SDL2_ttf.DLL`

**Linux:**
- `libSDL2_mixer-2.0.so.0`
- `libSDL2_image-2.0.so.0`
- `libSDL2_net-2.0.so.0`
- `libSDL2_ttf-2.0.so.0`

---

## Notes

- All libraries require SDL2 to be initialized first
- Audio libraries auto-initialize in boot code
- Image library supports: PNG, JPG, BMP, GIF, TGA, TIF, WEBP, SVG
- Network library uses IPv4 only
- Font rendering produces surfaces that must be converted to textures
- Always free resources (chunks, music, textures, fonts, sockets)

## Best Practices

1. **Initialize early**: Call init functions at program start
2. **Cleanup resources**: Free all loaded assets before exit
3. **Error checking**: Check return values (0 or NULL often indicates error)
4. **Volume management**: Set appropriate volumes for user experience
5. **Network timeout**: Use socket sets with timeout for non-blocking I/O
6. **Font caching**: Render text to textures once, reuse when possible

