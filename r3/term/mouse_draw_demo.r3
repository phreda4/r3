| terminal Mouse Drawing Demo
| Cross-platform drawing application with mouse support
| Works with both Linux and Windows terminal libraries

^r3/lib/console.r3

#running 1

:exit 0 'running ! ;

|------- Canvas State -------
#canvas * 8192  | 128x64 canvas buffer (1 byte per cell)
#canvas-width 120
#canvas-height 40

|------- Drawing State -------
#current-brush 1
#current-color 1

|------- Brush Definitions -------
#b0 "█" #b1 "▓" #b2 "▒" #b3 "░" #b4 "■" #b5 "□" #b6 "▲" #b7 "▼" #b8 "●" #b9 "○"

#brushes b0 b1 b2 b3 b4 b5 b6 b7 b8 b9

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
	dup 4 >> $f and .fc | ; TODO: same continuos color don't set color
	$f and 1- 3 << 'brushes + @ .write ;
	
:canvas-draw | -- 
    0 ( canvas-height <?
        2 over 2 + .at
		0 over canvas-at >a
        0 ( canvas-width <?
			ca@+ .canvchar
            1+ ) drop
        1+ ) drop
    .Reset ;

:hline | cnt --
	( 1? 1- "─" .write ) drop ;
	
|------- UI Functions -------
:draw-frame | --
    .home .Cyanl .Bold
    0 0 .at "┌" .write canvas-width hline "┐" .write
    2 ( canvas-height 2 + <?
        0 over .at "│" .write
        canvas-width 2 + over .at "│" .write
        1+ ) drop
    0 canvas-height 2 + .at "└" .write canvas-width hline "┘" .write
    .Reset ;

:draw-toolbar | --
    2 canvas-height 3 + .at
    .Yellow "| " .write
	current-color .fc
    current-brush 1- 3 << 'brushes + @ dup .write .write 
    .Yellow " │ " .write
    .Cyan "[1-9] Brush  [C] Color  [SPACE] Clear  [ESC] Exit" .write
    .Reset ;

:draw-help | --
    2 canvas-height 4 + .at
    .Magenta
    "Left Click: Draw  |  Right Click: Erase  |  Drag to draw continuous" .write
    .Reset ;

:draw-mouse-cursor | --
	evtmxy .at .redl "+" .write .Reset ;

:draw-screen | --
    .cls
    draw-frame
    canvas-draw
    draw-toolbar
    draw-help
    draw-mouse-cursor 
	.flush ;

|------- Mouse Handling -------
:process-mouse | --
    evtmxy | Get mouse position 
    2 - 0 max canvas-height 1- min swap
    2 - 0 max canvas-width 1- min swap
	canvas-at >a
    evtmb		| Get button state
	1 and? (	| Left button - draw
		current-color 4 << current-brush or ca!
		draw-screen 
		) 
	2 and? (	| Right button - erase
		0 ca!
		draw-screen
		) 
	drop
    draw-mouse-cursor | Redraw cursor if mouse moved
	;

|------- Keyboard Handling -------
:handle-key | --
	evtkey 0? ( drop ; ) 
	[esc] =? ( drop exit ; ) | ESC - exit
 
	$31 $39 in? ( 	| Numbers 1-9 - select brush
		$30 - 'current-brush ! 
		draw-screen ; ) 
	$20 =? ( drop	| SPACE - clear canvas
        canvas-clear
        draw-screen ; )
	$20 or | case insensitive
	$63 =? ( drop	| C/c - cycle color
		current-color 1+ $f and 'current-color !
        draw-screen ; ) 
    drop ;

|------- Event Loop -------
:main-loop | --
    ( running 1? drop
        inevt	| Check for events
        1 =? ( handle-key )  | Keyboard
        2 =? ( process-mouse )      | Mouse
        drop
        1 ms | Small delay
    ) drop ;

|------- Resize Handler -------
:on-resize-event    | Recalculate canvas dimensions if needed
    cols 4 - 'canvas-width !
    rows 5 - 'canvas-height !
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
: .alsb main .masb .free ;