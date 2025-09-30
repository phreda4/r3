| Console Mouse Drawing Demo
| Cross-platform drawing application with mouse support
| Works with both Linux and Windows console libraries

| Uncomment the appropriate library for your platform:
^./console.r3

#running 1

:exit 0 'running ! ;

|------- Canvas State -------
#canvas * 8192  | 128x64 canvas buffer (1 byte per cell)
#canvas-width 120
#canvas-height 40

|------- Drawing State -------
#mouse-x 0
#mouse-y 0
#mouse-btn 0
#prev-btn 0
#current-brush 1
#current-color 1
#drawing-mode 0  | 0=draw, 1=erase

|------- Brush Definitions -------
| Brush characters
#brushes " OoXx.*+-=@$"
#brush-count 11

|------- Color Palette -------
:set-draw-color | color --
    1 =? ( .Redl ; )
    2 =? ( .Greenl ; )
    3 =? ( .Bluel ; )
    4 =? ( .Yellowl ; )
    5 =? ( .Magental ; )
    6 =? ( .Cyanl ; )
    7 =? ( .Whitel ; )
    drop .Whitel ;

|------- Canvas Functions -------
:canvas-clear | --
    'canvas 0 canvas-width canvas-height * cfill ;

:canvas-at | x y -- addr
    canvas-width * + 'canvas + ;

:canvas-get | x y -- char
    canvas-at c@ ;

:canvas-set | char x y --
    canvas-at c! ;

:.canvchar
	0? ( drop .sp ; ) 
	dup 4 >> set-draw-color
	$f and 'brushes + c@ .emit
	;
	
:canvas-draw | --
    0 ( rows 4 - <?
        2 over 2 + .at
		0 over canvas-at >a
        0 ( cols 4 - <?
			ca@+ .canvchar
            1+ ) drop
        1+ ) drop
    .Reset ;

|------- UI Functions -------
:draw-frame | --
    .home .Cyanl .Bold
    0 0 .at "┌" .write
    cols 2 - ( 1? "─" .write 1- ) drop
    "┐" .write
    
    2 ( rows 1- <?
        0 over .at "│" .write
        cols over .at "│" .write
        1+ ) drop
    
    0 rows 1- .at "└" .write
    cols 2 - ( 1? "─" .write 1- ) drop
    "┘" .write
    .Reset ;

:draw-toolbar | --
    2 canvas-height 3 + .at
    .Yellow "┤ " .write
    .Yellowl .Bold "Brush: " .write
    .Whitel current-brush "%d " .print
    
    .Yellow "│ " .write
    .Yellowl .Bold "Color: " .write
    current-color set-draw-color "█ " .write
    
    .Yellow "│ " .write
    .Yellowl .Bold "Mode: " .write
    .Whitel "ERASE" drawing-mode 0? ( 2drop "DRAW" dup ) drop 
    .write
    
    .Yellow " │" .write
    .Reset
    
    2 canvas-height 4 + .at
    .Cyan
    "[1-9] Brush  [C] Color  [M] Mode  [SPACE] Clear  [ESC] Exit" .write
    .Reset ;

:draw-help | --
    2 canvas-height 5 + .at
    .Magenta
    "Left Click: Draw  |  Right Click: Erase  |  Drag to draw continuous" .write
    .Reset ;

:charmm
    mouse-btn 
	1 and? ( drop .Redl "+" ; ) 
    2 and? ( drop .Bluel "×" ; ) 
	drop
    .Greenl "◆" ;	

:draw-mouse-cursor | --
    mouse-x mouse-y .at
    charmm .write .Reset ;

:draw-screen | --
    .cls
    draw-frame
    canvas-draw
    draw-toolbar
    draw-help
    draw-mouse-cursor 
	.flush
	;

|------- Mouse Handling -------
:process-mouse | --
    | Get mouse position (adjust for canvas offset)
    evtmxy |2 - swap 2 - swap
    
    | Clamp to canvas bounds
    0 max canvas-height 1 - min 'mouse-y !
    0 max canvas-width 1 - min 'mouse-x !
    
    | Get button state
    evtmb 'mouse-btn !
    
    | Left button - draw
    mouse-btn 1 and? (
        drawing-mode 0? (
            | Draw mode
            current-color 4 << current-brush or
            mouse-x mouse-y canvas-set
            draw-screen
        ) drop
        
        | Check if entering draw mode
        prev-btn 1 and? ( draw-screen ) drop
    ) drop
    
    | Right button - erase
    mouse-btn 2 and? (
        0 mouse-x mouse-y canvas-set
        draw-screen
        
        | Check if entering erase mode
        prev-btn 2 and? ( draw-screen ) drop
    ) drop
    
    | Update previous button state
    mouse-btn 'prev-btn !
    
    | Redraw cursor if mouse moved
    draw-mouse-cursor ;

|------- Keyboard Handling -------
:handle-key | key --
    
	$1000 and? ( drop ; )
	16 >>
    $1B =? ( drop exit ; ) | ESC - exit
    
    | Numbers 1-9 - select brush
    $31 >=? ( 
		$39 <=? (
            $30 - 1- 
            0 >=? (
                brush-count <? (
                    'current-brush ! 
                    draw-screen 
                ) 
			drop ;
            )		
        ) 
    ) 
    
	$20 or | case insensitive
    | C/c - cycle color
	$63 =? ( drop
        current-color 1+ 8 mod 
        0? ( drop 1 )
        'current-color !
        draw-screen ;
		) 
    | M/m - toggle mode
    $6D =? ( drop
        drawing-mode 1 xor 'drawing-mode !
        draw-screen ;
		)     
    | SPACE - clear canvas
    $20 =? ( drop
        canvas-clear
        draw-screen ;
		)
    drop ;

|------- Event Loop -------
:main-loop | --
    ( running 1? drop
        | Check for resize
        .checksize 1? ( draw-screen ) drop
        
        | Check for events
        inevt
        1 =? ( evtkey handle-key )  | Keyboard
        2 =? ( process-mouse )      | Mouse
        4 =? ( draw-screen )        | Resize
        drop
        
        | Small delay
        10 ms
    ) drop ;

|------- Resize Handler -------
:on-resize-event
    | Recalculate canvas dimensions if needed
    cols 4 - 'canvas-width !
    rows 8 - 'canvas-height !
    canvas-width 0 max 120 min 'canvas-width !
    canvas-height 0 max 40 min 'canvas-height !
    draw-screen ;

|------- Main Program -------
:main
    .enable-mouse
    'on-resize-event .onresize
	on-resize-event
    canvas-clear
    | Initial state
    1 'current-brush !
    1 'current-color !
    0 'drawing-mode !
    | Hide cursor for cleaner display
    .hidec
    | Initial draw
    draw-screen
    | Welcome message
    2 canvas-height 6 + .at
    .Greenl .Bold
    "Welcome! Use your mouse to draw. Try different brushes and colors!" .write
    .Reset
    | Run main loop
    main-loop
    | Cleanup
    .disable-mouse
    .showc .cls .home .Reset
    "Thanks for drawing!" .println ;

| Program entry point
: main ;
