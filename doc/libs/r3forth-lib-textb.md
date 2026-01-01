# R3Forth Textb Library (textb.r3)

A text rendering library for R3Forth that fits multi-line text into boxes with word wrapping, alignment options, outline effects, and automatic texture generation using SDL2 TTF.

## Overview

Textb (TextBox) provides advanced text layout capabilities for creating text-filled boxes with precise control over formatting, alignment, colors, padding, and text outline effects. Perfect for UI elements, speech bubbles, and text displays.

**Key Features:**
- Automatic word wrapping to fit box width
- Multiple text alignment options (left, center, right)
- Vertical alignment (top, center, bottom)
- Text outline/stroke effects
- Configurable padding
- Direct texture generation
- Handles newlines and semicolons as line breaks

**Dependencies:**
- `r3/lib/math.r3` - Fixed-point arithmetic
- `r3/lib/color.r3` - Color utilities
- `r3/lib/sdl2gfx.r3` - SDL2 graphics
- `r3/lib/sdl2ttf.r3` - TrueType font rendering

---

## Main Function

### Text Box Creation

- **`textbox`** `( str $flags w h font -- texture )` - Create text box texture
  - `str`: Text string to render (use `;` or newlines for line breaks)
  - `$flags`: Packed formatting flags (see Flag Format below)
  - `w`: Box width in pixels
  - `h`: Box height in pixels
  - `font`: TTF font handle (from TTF_OpenFont)
  - Returns: SDL texture handle ready for rendering
  
  **Example:**
  ```
  "Hello World;This is a test" 
  $ff_00_10_ffffff  | Black bg, no outline, top-left, white text
  400 200
  myFont
  textbox
  'textTexture !
  ```

---

## Flag Format

The flags parameter is a 32-bit packed value: `$BBBBOOOOFFFFCCCC`

### Flag Breakdown

```
Bits 0-15  (CCCC): Text Color (16-bit color → expanded to 32-bit)
Bits 16-19 (F): Alignment flags
  - Bit 18 (0x40000): Center horizontal
  - Bit 19 (0x80000): Right align
  - Bit 16 (0x10000): Center vertical
  - Bit 17 (0x20000): Bottom align
Bits 20-27 (FFFF): Padding (8 bits) + Outline width (4 bits)
  - Bits 20-23: Outline width (0-15 pixels)
  - Bits 24-27: Padding (0-255 pixels on all sides)
Bits 28-31 (OOOO): Outline color (16-bit → 32-bit)
Bits 32-47 (not used in low 32): Background color (16-bit → 32-bit)
Bits 48-63 (BBBB): Background color (high bits)
```

### Alignment Values

| Horizontal | Vertical | Combined | Description |
|------------|----------|----------|-------------|
| 0x00000 | 0x00000 | 0x00000 | Top-left |
| 0x40000 | 0x00000 | 0x40000 | Top-center |
| 0x80000 | 0x00000 | 0x80000 | Top-right |
| 0x00000 | 0x10000 | 0x10000 | Middle-left |
| 0x40000 | 0x10000 | 0x50000 | Middle-center |
| 0x80000 | 0x10000 | 0x90000 | Middle-right |
| 0x00000 | 0x20000 | 0x20000 | Bottom-left |
| 0x40000 | 0x20000 | 0x60000 | Bottom-center |
| 0x80000 | 0x20000 | 0xa0000 | Bottom-right |

---

## Flag Construction Helpers

### Manual Flag Building

```r3forth
| Build flags step by step
#bgColor $000f      | Black background (16-bit)
#txtColor $ffff     | White text (16-bit)
#outColor $00ff     | Blue outline (16-bit)
#padding 20         | 20 pixels padding
#outline 2          | 2 pixel outline width
#align $50000       | Center horizontal + center vertical

| Combine flags
bgColor 48 <<       | Background to bits 48-63
outColor 28 << or   | Outline to bits 28-31
outline 20 << or    | Outline width to bits 20-23
padding 24 << or    | Padding to bits 24-27
align or            | Alignment flags
txtColor or         | Text color to bits 0-15
'flags !
```

### Quick Flag Formulas

```r3forth
| Format: $BBBB-OOOO-PO-FF-CCCC
| Where: B=bg O=outline P=pad O=outwidth F=flags C=color

| Black bg, white text, no outline, top-left
$000f00000000ffff

| White bg, black text, 10px padding, centered
$ffff00000a50000f

| Transparent bg, white text with black outline, bottom-right
$000000ff02a0ffff
```

---

## Text Formatting

### Line Breaks

Text is automatically broken at:
- **Semicolon** (`;`): Explicit line break
- **Newline** (`\n` or character 10): Line break
- **Carriage return** (`\r` or character 13): Line break
- **Word wrap**: When line exceeds box width

**Example:**
```
"Line 1;Line 2;Line 3"  | Three lines
"First\nSecond\nThird"  | Three lines
"Auto wrap happens when text is too long"  | Wraps automatically
```

### Word Wrapping

- Breaks at word boundaries (spaces)
- Never breaks mid-word
- Backtracking algorithm finds optimal break point
- Removes trailing spaces after wrap

---

## Complete Examples

### Basic Text Box

```r3forth
| Load font
"media/fonts/arial.ttf" 24 TTF_OpenFont 'myFont !

| Simple white text on black background
"Hello World" 
$000f00000000ffff  | Black bg, white text, top-left
400 100
myFont
textbox
'helloTexture !

| Render texture
SDLrenderer helloTexture 0 100 100 400 100 SDL_RenderCopy
```

### Centered Dialog Box

```r3forth
"Welcome to the game!;Press any key to start"
$333f00001050ffff  | Dark gray bg, white text, 16px pad, centered
600 200
dialogFont
textbox
'dialogTexture !

| Display centered on screen
sw 2/ 300 - sh 2/ 100 - 600 200 'destRect !
SDLrenderer dialogTexture 0 'destRect SDL_RenderCopy
```

### Text with Outline

```r3forth
"GAME OVER"
$ff0f000f020affff  | Red bg, black outline (2px), 10px pad, centered, white text
800 200
titleFont
textbox
'gameOverTex !
```

### Multi-line Paragraph

```r3forth
"This is a long paragraph of text that will automatically wrap to fit within the specified box width. The library handles all the word breaking and line layout for you."
$ffff00001400000f  | White bg, black text, 20px pad, top-left
500 300
bodyFont
textbox
'paragraphTex !
```

### Speech Bubble

```r3forth
| Character speech with outline for readability
"I have a quest for you!;Will you help me?"
$0fff0fff03140fff  | Cyan bg, white outline (3px), 20px pad, top-left, white text
300 150
speechFont
textbox
'speechTex !
```

### Status Message

```r3forth
score "Score: %d" sprint
$00ff00000050ffff  | Green bg, white text, centered
200 60
smallFont
textbox
'scoreTex !
```

---

## Advanced Usage

### Dynamic Text Updates

```r3forth
#scoreTexture

:updateScore | score --
    "Score: %d" sprint
    $000f00000a50ffff
    300 80
    uiFont
    textbox
    
    | Destroy old texture
    scoreTexture SDL_DestroyTexture
    'scoreTexture ! ;

150 updateScore  | Create new score texture
```

### Text Button with Hover

```r3forth
#buttonNormal #buttonHover

:createButton | "text" --
    | Normal state
    dup
    $555f00000800ffff  | Gray bg, white text, 8px pad, centered
    200 60 buttonFont textbox
    'buttonNormal !
    
    | Hover state
    $777f00000800ffff  | Lighter gray, centered
    200 60 buttonFont textbox
    'buttonHover ! ;

"Click Me" createButton
```

### Styled List

```r3forth
:createListItem | "text" index --
    swap
    pick2 2 mod 0? (
        $eeff00000400000f  | Light bg
    ) (
        $dddf00000400000f  | Darker bg
    ) 
    400 40 listFont textbox
    swap 40 * listY + listX swap 400 40 'itemRect !
    SDLrenderer swap 0 'itemRect SDL_RenderCopy ;

"Item 1" 0 createListItem
"Item 2" 1 createListItem
"Item 3" 2 createListItem
```

### Color-Coded Messages

```r3forth
:showMessage | "text" type --
    0? ( $ff0f00000a50ffff ; )  | Error: red
    1 =? ( $0fff00000a50ffff ; )  | Warning: yellow
    2 =? ( $0f0f00000a50ffff ; )  | Success: green
    $ffff00000a50000f  | Info: white bg, black text
    swap 600 100 msgFont textbox
    'messageTex ! ;

"File not found!" 0 showMessage  | Error
"Low memory" 1 showMessage       | Warning
"Saved successfully" 2 showMessage  | Success
```

---

## Flag Helper Functions

```r3forth
| Helper to build flags programmatically

:makeFlags | bgCol outCol pad outWidth align txtCol -- flags
    swap               | bgCol outCol pad outWidth txtCol align
    pick4 24 << or     | Add padding
    pick3 20 << or     | Add outline width
    pick5 28 << or     | Add outline color
    pick6 48 << or     | Add background color
    or ;               | Add text color + align

| Usage:
$000f  | bg: black
$0fff  | out: white
20     | pad: 20px
2      | outwidth: 2px
$50000 | align: centered
$ffff  | txt: white
makeFlags
```

---

## Rendering Text Boxes

### Basic Rendering

```r3forth
:renderTextBox | texture x y w h --
    'destRect >a da!+ da!+ da!+ da!
    SDLrenderer swap 0 'destRect SDL_RenderCopy ;

textTexture 100 100 400 200 renderTextBox
```

### With Color Modulation

```r3forth
:renderTintedText | texture x y w h color --
    >r 'destRect >a da!+ da!+ da!+ da!
    SDLrenderer pick2 r> 
    dup 16 >> $ff and 
    over 8 >> $ff and 
    rot $ff and
    SDL_SetTextureColorMod
    0 'destRect SDL_RenderCopy ;

textTexture 100 100 400 200 $ff8080 renderTintedText  | Red tint
```

### Animated Text

```r3forth
#textAlpha 255

:fadeText
    textAlpha 5 - 0 max 'textAlpha !
    SDLrenderer textTexture textAlpha SDL_SetTextureAlphaMod
    100 100 400 200 renderTextBox ;
```

---

## Best Practices

### 1. Font Management

```r3forth
| Load fonts at startup
:loadFonts
    "fonts/title.ttf" 48 TTF_OpenFont 'titleFont !
    "fonts/body.ttf" 16 TTF_OpenFont 'bodyFont !
    "fonts/small.ttf" 12 TTF_OpenFont 'smallFont ! ;

| Close fonts at exit
:freeFonts
    titleFont TTF_CloseFont
    bodyFont TTF_CloseFont
    smallFont TTF_CloseFont ;
```

### 2. Texture Lifecycle

```r3forth
| CORRECT - destroy before recreating
oldTexture SDL_DestroyTexture
newText newFlags w h font textbox 'oldTexture !

| WRONG - memory leak
newText newFlags w h font textbox 'oldTexture !
```

### 3. Pre-generate Static Text

```r3forth
| Generate once at startup
:initUI
    "Player Health" $flags1 w h font textbox 'healthLabel !
    "Score" $flags2 w h font textbox 'scoreLabel !
    | ... etc
    ;
```

### 4. Use Appropriate Box Sizes

```r3forth
| Measure text first for tight fit
font "Sample Text" 0 0 TTF_SizeUTF8  | -- w h
20 + swap 10 + swap  | Add padding
font textbox  | Use measured size
```

---

## Performance Tips

1. **Pre-generate**: Create textures once for static text
2. **Reuse textures**: Don't recreate every frame
3. **Batch rendering**: Group text renders together
4. **Font caching**: Load fonts once, reuse
5. **Appropriate sizes**: Don't over-allocate texture size
6. **Destroy old textures**: Prevent memory leaks

---

## Common Patterns

### Title Screen Text

```r3forth
"SUPER GAME"
$000f0fff051affff  | Black bg, white outline (5px), 26px pad, centered
800 150
titleFont
textbox
```

### Tooltip

```r3forth
"Health: Restores 50 HP"
$fff00fff01050fff  | Yellow bg, black outline (1px), 5px pad, left
250 50
tooltipFont
textbox
```

### Subtitle

```r3forth
"Chapter 1: The Beginning"
$00000fff020affff  | Transparent bg, white outline (2px), centered
sw 300
subtitleFont
textbox
```

---

## Troubleshooting

### Text Cut Off

**Problem**: Text doesn't fit in box
**Solution**: 
- Increase box dimensions
- Reduce font size
- Decrease padding
- Shorten text

### Outline Not Showing

**Problem**: Outline width is 0
**Solution**: Set outline width in bits 20-23
```
flags $f00000 or  | Add outline
```

### Wrong Alignment

**Problem**: Text in wrong position
**Solution**: Check alignment flags
```
$00000  | Top-left
$50000  | Centered
$a0000  | Bottom-right
```

### Garbled Colors

**Problem**: Colors look wrong
**Solution**: Use 4-bit color helpers
```
$f00f  | Red text (expand to $ff0000ff)
$0f0f  | Green
$00ff  | Blue
```

---

## Notes

- **Color format**: Uses 4-bit color ($ARGB) expanded to 8-bit ($AARRGGBB)
- **Font scaling**: Use SDL texture scaling (linear/nearest neighbor)
- **UTF-8 support**: Full UTF-8 text rendering via SDL_TTF
- **Memory**: Creates surface and texture, surface freed automatically
- **Line height**: Determined by font metrics
- **Max text**: Limited by buffer size (4096 bytes)
- **Max lines**: Up to 512 lines
- **Padding**: Applied to all four sides equally
- **Outline**: Applied around entire text

## Limitations

- Single font per text box
- Single color for entire text (except outline)
- No inline formatting (bold, italic within text)
- Padding is uniform (same on all sides)
- Outline width maximum 15 pixels
- Background is solid color only
- No shadow effects built-in

## Color Format Reference

```
4-bit to 8-bit expansion:
$0 -> $00  $1 -> $11  $2 -> $22  ...  $f -> $ff

Examples:
$f00f -> $ff0000ff (opaque blue)
$0f0f -> $00ff00ff (opaque green)
$00ff -> $0000ffff (opaque red)
$ffff -> $ffffffff (opaque white)
$000f -> $000000ff (opaque black)
```

