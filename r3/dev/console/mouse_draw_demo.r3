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
#current-brush 1
#current-color 1

|------- Brush Definitions -------
| Brush characters
#brushes " @oXx.*+-=@$"
#brush-count 11

|------- Color Palette -------
#dcolors .Whitel .Redl .Greenl .Bluel .Yellowl .Magental .Cyanl .Whitel

:set-draw-color | color --
	$7 and 3 << 'dcolors + @ ex ;

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
	$f and 'brushes + c@ .emit ;
	
:canvas-draw | --
    0 ( canvas-height <?
        2 over 2 + .at
		0 over canvas-at >a
        0 ( canvas-width <?
			ca@+ .canvchar
            1+ ) drop
        1+ ) drop
    .Reset ;

|------- UI Functions -------
:draw-frame | --
    .home .Cyanl .Bold
    0 0 .at "┌" .write
    canvas-width ( 1? "─" .write 1- ) drop
    "┐" .write
    
    2 ( canvas-height 2 + <?
        0 over .at "│" .write
        canvas-width 2 + over .at "│" .write
        1+ ) drop
    
    0 canvas-height 2 + .at "└" .write
    canvas-width ( 1? "─" .write 1- ) drop
    "┘" .write
    .Reset ;

:draw-toolbar | --
    2 canvas-height 3 + .at
    .Yellow " " .write
    .Yellowl .Bold "Brush: " .write
    .Whitel current-brush "%d " .print
    
    .Yellow "│ " .write
    .Yellowl .Bold "Color: " .write
    current-color set-draw-color "█ " .write
    
    .Yellow " │" .write
    .Reset
    
    2 canvas-height 4 + .at
    .Cyan
    "[1-9] Brush  [C] Color  [SPACE] Clear  [ESC] Exit" .write
    .Reset ;

:draw-help | --
    2 canvas-height 5 + .at
    .Magenta
    "Left Click: Draw  |  Right Click: Erase  |  Drag to draw continuous" .write
    .Reset ;

:draw-mouse-cursor | --
    mouse-x 2 + mouse-y 2 +
	.at .redl "+" .write .Reset ;

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
    evtmxy | Get mouse position 
    2 - 0 max canvas-height 1- min 'mouse-y !
    2 - 0 max canvas-width 1- min 'mouse-x ! | adjust and clamp to canvas bounds
    evtmb		| Get button state
    1 and? (	| Left button - draw
	current-color 4 << current-brush or
	mouse-x mouse-y canvas-set
	draw-screen
	) 
    2 and? (	| Right button - erase
        0 mouse-x mouse-y canvas-set
        draw-screen
  	) 
	drop
    draw-mouse-cursor | Redraw cursor if mouse moved
	;

|------- Keyboard Handling -------
:handle-key | key --
	]esc[ =? ( drop exit ; ) | ESC - exit
|WIN|	$1000 and? ( drop ; ) 16 >>    
| Numbers 1-9 - select brush
    $31 $39 in? ( 
		$30 - 'current-brush ! 
		draw-screen ; ) 
    
	$20 or | case insensitive
| C/c - cycle color
	$63 =? ( drop
        current-color 1+ 8 mod 
        0? ( drop 1 )
        'current-color !
        draw-screen ; ) 
| SPACE - clear canvas
	$20 =? ( drop
        canvas-clear
        draw-screen ; )
    drop ;

|------- Event Loop -------
:main-loop | --
    ( running 1? drop
        inevt	| Check for events
        1 =? ( evtkey handle-key )  | Keyboard
        2 =? ( process-mouse )      | Mouse
        drop
        1 ms | Small delay
    ) drop ;

|------- Resize Handler -------
:on-resize-event    | Recalculate canvas dimensions if needed
    cols 4 - 'canvas-width !
    rows 8 - 'canvas-height !
    canvas-width 0 max 120 min 'canvas-width !
    canvas-height 0 max 40 min 'canvas-height !
    draw-screen ;

|------- Main Program -------
:main
    'on-resize-event .onresize
	on-resize-event
    canvas-clear
    1 'current-brush !
    1 'current-color !
    .hidec
    draw-screen
    main-loop
    .showc .Reset ;

| Program entry point
: .console .enable-mouse main .disable-mouse .free ;