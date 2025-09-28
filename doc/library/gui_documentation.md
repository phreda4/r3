# R3 Immediate Mode GUI Library Documentation

## Overview

`gui.r3` provides an immediate mode GUI system for R3 applications. Unlike retained mode GUIs, immediate mode GUIs redraw all elements each frame and handle state internally, making them ideal for games and real-time applications where the GUI needs to respond dynamically to changing data.

## Dependencies
- `r3/lib/sdl2.r3` - SDL2 graphics and input system

## Core Concepts

### Immediate Mode Philosophy
- **Stateless Widgets**: UI elements don't persist between frames
- **Frame-Based**: GUI is rebuilt every frame
- **Direct Coupling**: UI elements directly reflect application state
- **Simple Event Handling**: Events processed immediately when widgets are drawn

### ID-Based System
Each GUI element gets a unique ID during each frame to track state and interactions.

## Global State Variables

### Region Definition
```r3
#xr1 #yr1    // Region top-left coordinates
#xr2 #yr2    // Region bottom-right coordinates
```

### Interaction State
```r3
#hot         // Currently active element ID
#hotnow      // Previously active element ID
#hotc        // Element with mouse capture
#foco        // Element with keyboard focus
#foconow     // Previous keyboard focus
#clkbtn      // Button state at click time
```

### ID Management
```r3
#id          // Current element ID counter
#idf         // Focus ID counter
#idl         // Last focus ID
#guin?       // Mouse inside current region flag
```

## Core GUI Functions

### Frame Management
```r3
gui          | --                    // Initialize GUI frame
```
Call this at the start of each frame to reset GUI state.

### Region Definition
```r3
guiBox       | x y w h --            // Define rectangular region
guiRect      | x1 y1 x2 y2 --        // Define region by corners
guiPrev      | --                    // Use previous element's ID
```

**Examples:**
```r3
gui                                  // Start GUI frame
100 100 200 50 guiBox              // Define button region
'my-button onClick                   // Handle button click
```

## Event Handling System

### Click Events
```r3
onClick      | 'callback --          // Handle mouse click
onClickFoco  | 'callback --          // Handle click + set keyboard focus
```

**Click Behavior:**
- Callback executed on mouse button release
- Only triggers if mouse was pressed and released within the same element
- Provides basic click/tap functionality

### Mouse Movement
```r3
onMove       | 'callback --          // Handle mouse movement over element
onMoveA      | 'callback --          // Handle movement with mouse capture
```

### Drag Operations
```r3
onDnMove     | 'down 'move --        // Handle press-drag-release
onDnMoveA    | 'down 'move --        // Handle drag with capture
```

**Drag Behavior:**
- `'down` callback on initial press
- `'move` callback during drag
- Automatic capture ensures dragging continues outside element

### Complete Mouse Mapping
```r3
onMap        | 'down 'move 'up --    // Complete mouse interaction
onMapA       | 'down 'move 'up --    // Complete interaction with capture
```

**Complete Interaction:**
- `'down` on mouse press
- `'move` during drag
- `'up` on mouse release

## Conditional Execution

### Region Testing
```r3
guiI         | 'callback --          // Execute if mouse inside region
guiO         | 'callback --          // Execute if mouse outside region  
guiIO        | 'inside 'outside --   // Execute based on mouse position
```

**Examples:**
```r3
:highlight-button
    $ffff00 'button-color ! ;

:normal-button  
    $ffffff 'button-color ! ;

'highlight-button 'normal-button guiIO
```

## Keyboard Focus System

### Focus Management
```r3
nextfoco     | --                    // Move to next focusable element
prevfoco     | --                    // Move to previous focusable element
setfoco      | id --                 // Set focus to specific element
clickfoco    | --                    // Set focus to current element
refreshfoco  | --                    // Reset focus system
```

### Focus-Aware Widgets
```r3
w/foco       | 'focused 'normal --   // Execute based on focus state
focovoid     | --                    // Placeholder focusable element
esfoco?      | -- flag               // Test if current element has focus
in/foco      | 'callback --          // Execute if element has focus
lostfoco     | 'callback --          // Handle losing focus
```

**Examples:**
```r3
:focused-input
    $ffff00 'input-bg ! ;           // Yellow background

:normal-input
    $ffffff 'input-bg ! ;           // White background

'focused-input 'normal-input w/foco
```

## Complete GUI Examples

### Simple Button
```r3
:draw-button | x y w h "text" --
    pick3 pick3 pick3 pick3 guiBox  // Define clickable region
    
    | Visual feedback
    guin? ? ( $c0c0c0 ; $ffffff ) 'button-color !
    
    | Draw button background
    button-color SDLrenderer SDL_SetRenderDrawColor
    here !+ !+ !+ !+                // Store rectangle
    SDLrenderer 'here SDL_RenderFillRect
    
    | Draw button text
    button-font swap $000000 TTF_RenderUTF8_Blended
    | ... text rendering code ...
    ;

:button-clicked
    "Button was clicked!" print ;

| Usage:
100 100 120 30 "Click Me" draw-button
'button-clicked onClick
```

### Input Field
```r3
#input-text * 256
#input-cursor 0

:draw-input-field | x y w h --
    pick3 pick3 pick3 pick3 guiBox
    
    | Visual state
    :focused-input $ffff80 'input-bg ! ;
    :normal-input $ffffff 'input-bg ! ;
    'focused-input 'normal-input w/foco
    
    | Draw background
    input-bg SDLrenderer SDL_SetRenderDrawColor
    here !+ !+ !+ !+
    SDLrenderer 'here SDL_RenderFillRect
    
    | Handle keyboard input
    esfoco? ?
    ( sdlchar ?
        ( input-cursor 255 <? 
            ( sdlchar 'input-text input-cursor + c!
              input-cursor 1+ 'input-cursor ! )
        )
      sdlkey >backspace< =?
        ( input-cursor 0 >?
            ( input-cursor 1- 'input-cursor !
              0 'input-text input-cursor + c! )
        )
    )
    
    | Draw text
    'input-text input-font $000000 TTF_RenderUTF8_Blended
    | ... text rendering ...
    ;

| Usage:
200 200 200 25 draw-input-field
onClickFoco
```

### Slider Control
```r3
#slider-value 0.5
#slider-dragging 0

:update-slider | mouse-x slider-x slider-w --
    over - 1.0 rot */ 
    0.0 1.0 clamp 'slider-value ! ;

:draw-slider | x y w h --
    pick3 pick3 pick3 pick3 guiBox
    
    | Handle dragging
    :slider-down 1 'slider-dragging ! ;
    :slider-move 
        slider-dragging ?
        ( sdlx pick2 pick2 update-slider )
        ;
    
    'slider-down 'slider-move onDnMoveA
    
    | Draw track
    $808080 SDLrenderer SDL_SetRenderDrawColor
    pick2 pick2 4 + pick2 pick2 8 - here !+ !+ !+ !+
    SDLrenderer 'here SDL_RenderFillRect
    
    | Draw handle
    $ffffff SDLrenderer SDL_SetRenderDrawColor
    pick2 slider-value pick2 *. + 4 - pick2 2 + 8 16 here !+ !+ !+ !+
    SDLrenderer 'here SDL_RenderFillRect
    ;

| Reset dragging when not actively dragging
:reset-slider-drag
    SDLb 0? ( 0 'slider-dragging ! ) drop ;

| Usage:
300 300 150 20 draw-slider
reset-slider-drag
```

### Menu System
```r3
#current-menu 0

:menu-item | "text" action-id --
    50 current-menu 20 * + 200 20 guiBox
    
    | Visual feedback
    guin? ? ( $e0e0e0 ; $f0f0f0 ) SDLrenderer SDL_SetRenderDrawColor
    here !+ !+ !+ !+
    SDLrenderer 'here SDL_RenderFillRect
    
    | Handle selection
    rot 'selected-action ! | Store action ID
    'execute-menu-action onClick
    
    current-menu 1+ 'current-menu ! ;

:execute-menu-action
    selected-action
    1 =? ( "New File" process-new-file )
    2 =? ( "Open File" process-open-file ) 
    3 =? ( "Save File" process-save-file )
    drop ;

:draw-menu
    0 'current-menu !
    "New" 1 menu-item
    "Open" 2 menu-item  
    "Save" 3 menu-item ;
```

## Advanced Patterns

### Modal Dialogs
```r3
#dialog-active 0

:draw-dialog | --
    dialog-active 0? ( ; )
    
    | Semi-transparent overlay
    0 0 sw sh guiRect
    $000000 $80 SDL_SetRenderDrawColor  // Semi-transparent black
    SDLrenderer 'overlay-rect SDL_RenderFillRect
    
    | Dialog box
    200 150 400 200 guiBox
    $f0f0f0 SDLrenderer SDL_SetRenderDrawColor
    here !+ !+ !+ !+
    SDLrenderer 'here SDL_RenderFillRect
    
    | OK button
    450 300 80 30 guiBox  
    'close-dialog onClick ;

:close-dialog
    0 'dialog-active ! ;

:show-dialog
    1 'dialog-active ! ;
```

### Tab Interface  
```r3
#active-tab 0

:draw-tab | "title" tab-id --
    tab-id 100 * 50 100 30 guiBox
    
    | Visual state
    tab-id active-tab =? ( $ffffff ; $e0e0e0 ) 'tab-color !
    tab-color SDLrenderer SDL_SetRenderDrawColor
    here !+ !+ !+ !+
    SDLrenderer 'here SDL_RenderFillRect
    
    | Handle click
    swap 'active-tab ! 
    'set-active-tab onClick ;

:set-active-tab | tab-id --
    'active-tab ! ;

:draw-tabs
    "General" 0 draw-tab
    "Graphics" 1 draw-tab
    "Audio" 2 draw-tab ;
```

## Performance Considerations

### Advantages
- **Simple State Management**: No complex widget hierarchies
- **Predictable Performance**: Same code path every frame
- **Easy Debugging**: All state visible and modifiable
- **Dynamic UI**: Easy to show/hide elements based on data

### Limitations
- **CPU Usage**: Redraws everything each frame
- **Memory Allocation**: May allocate strings/textures repeatedly
- **Complex Animations**: Harder to implement smooth transitions

## Best Practices

1. **Frame Structure**: Always call `gui` at frame start
2. **Consistent IDs**: Elements in same order each frame for stable IDs
3. **State Management**: Keep GUI state in application variables
4. **Focus Handling**: Use Tab key navigation for accessibility
5. **Visual Feedback**: Provide clear hover and focus indicators

## Integration with SDL2

The GUI system integrates seamlessly with SDL2:
- Uses `sdlx`, `sdly` for mouse coordinates
- Uses `SDLb` for mouse button states  
- Uses `sdlkey` and `sdlchar` for keyboard input
- Renders using SDL2 drawing functions

This immediate mode GUI provides a lightweight, efficient solution for R3 applications requiring dynamic user interfaces with predictable performance characteristics.