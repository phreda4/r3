| Cross-Platform Console Demo
| Works with both Linux and Windows console libraries
| Demonstrates resize handling, colors, and input

| Uncomment the appropriate library for your platform:

|LIN| ^./lin-console.r3
|WIN| ^./win-console.r3

|------- Application State -------
#boxes 0  | Number of boxes to draw
#box-color 0

#running 1

:exit | --
    0 'running ! ;
	
| Caracteres de línea compatibles (CP437/ANSI)
:draw-frame
    .home .Cyanl .Bold
    0 0 .at $C9 .emit  | ╔
    1 ( cols 1 - <? $CD .emit 1 + ) drop  | ═
    $BB .emit  | ╗
    
    1 ( rows 1 - <?
        dup 0 .at $BA .emit  | ║
        dup cols 1 - .at $BA .emit
        1 + ) drop
    
    0 rows 1 - .at $C8 .emit  | ╚
    1 ( cols 1 - <? $CD .emit 1 + ) drop
    $BC .emit  | ╝
    .Reset ;
	
|------- Drawing Functions -------
:draw-border | --
    .home
    .Cyanl .Bold
    0 ( cols <? 
        "═" .write 
        1 + ) drop
    
    1 ( rows <? 
        dup 0 .at "║" .write
        dup cols .at "║" .write
        1 + ) drop
    
    rows cols .at "═" .write
    
    0 0 .at "╔" .write
    cols 0 .at "╗" .write
    0 rows .at "╚" .write
    cols rows .at "╝" .write
    .Reset ;

:draw-title | --
    2 0 .at
    .Whitel .Bold
    " R3forth Console Demo " .write
    .Reset ;

:draw-info | --
    2 2 .at .Yellow
    "Terminal Size: " .write
    .Yellowl .Bold
    cols "%d" .print
    " x " .write
    rows "%d" .print
    .Reset
    
    2 3 .at .Cyan
    "Boxes to draw: " .write
    .Cyanl .Bold
    boxes "%d" .print
    .Reset
    
    2 4 .at .Magenta
    "Press +/- to change boxes" .write
    2 5 .at "Press C to change color" .write
    2 6 .at "Press ESC to exit" .write
    .Reset ;

:draw-box | x y size --
    >r >r >r
    box-color
    1 =? ( drop .Redl )
    2 =? ( drop .Greenl )
    3 =? ( drop .Bluel )
    4 =? ( drop .Magental )
    5 =? ( drop .Yellowl )
    drop .Whitel
    
    r> r> r>
    2dup .at
    0 ( pick2 <? 
        "█" .write
        1 + ) drop
    
    1 ( pick2 <? 
        2dup + swap .at
        0 ( pick3 <? 
            "█" .write
            1 + ) drop
        1 + ) 3drop
    .Reset ;

:draw-boxes | --
    boxes 0? ( drop ; )
    
    8 8 ( boxes <? 
        dup 3 << dup 3 draw-box
        1 + ) drop ;

:draw-screen | --
    .cls
    draw-border
    draw-title
    draw-info
    draw-boxes ;

|------- Resize Handler -------
:on-resize-event | --
    | This gets called automatically when terminal is resized
    draw-screen ;

|------- Input Handler -------
:handle-input | key --
    $1B =? ( exit )           | ESC - exit program
    $2B =? ( boxes 1 + 20 min 'boxes ! draw-screen ; ) | + key
    $2D =? ( boxes 1 - 0 max 'boxes ! draw-screen ; )  | - key
    $2b =? ( boxes 1 + 20 min 'boxes ! draw-screen ; ) | + key (num)
    $2d =? ( boxes 1 - 0 max 'boxes ! draw-screen ; )  | - key (num)
    
    | Handle 'c' or 'C' for color change
    $43 =? ( box-color 1 + 6 mod 'box-color ! draw-screen ; )
    $63 =? ( box-color 1 + 6 mod 'box-color ! draw-screen ; )
    
    drop ;

|------- Animation Loop -------

:main-loop | --
    ( running 1?
        | Check for resize
        .checksize 1? ( drop draw-screen )
        
        | Check for keyboard input
        inkey dup 1? ( handle-input )
        drop
        
        | Small delay to reduce CPU usage
        10 ms
    ) drop ;

|------- Main Program -------
:main | --
    | Initialize console
    init-console
    
    | Set resize callback
    'on-resize-event .onresize
    
    | Initial state
    3 'boxes !
    1 'box-color !
    
    | Hide cursor for cleaner display
    .hidec
    
    | Initial draw
    draw-screen
    
    | Run main loop
    main-loop
    
    | Cleanup
    .showc
    .cls
    .home
    .Reset
    "Goodbye!" .println ;

| Program entry point
: main ;
