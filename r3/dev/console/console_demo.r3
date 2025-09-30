| Cross-Platform Console Demo
| Works with both Linux and Windows console libraries
| Demonstrates resize handling, colors, and input

^./console.r3

|------- Application State -------
#boxes 0  | Number of boxes to draw
#box-color 0

#running 1

:exit | --
    0 'running ! ;
	
|------- Drawing Functions -------
:draw-border | --
    .home .Cyanl .Bold
    0 ( cols <? 
		dup 0 .at "═" .write 
		dup rows .at "═" .write 
        1+ ) drop
    
    1 ( rows <? 
        0 over .at "║" .write
        cols over .at "║" .write
        1+ ) drop
 
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

#box-colors .Whitel .Redl .Greenl .Bluel .Magental .Yellowl 
	
:draw-box | x y size --
	box-color 3 << 'box-colors + @ ex
	-rot
	0 ( pick3 <?
		0 ( pick4 <?
			pick3 pick2 +
			pick3 pick2 + .at
			"█" .write
			1+ ) drop
		1+ ) drop 
	3drop
    .Reset ;

:draw-boxes | --
    0 ( boxes <? 
        dup 1+ 2 << over 8 + 3 draw-box
        1+ ) drop ;

:draw-screen | --
    .cls
    draw-border
    draw-title
    draw-info
    draw-boxes 
	.flush
	;

|------- Input Handler -------
:handle-input | key --
    ]esc[ =? ( exit )	| ESC - exit program
	$1000 and? ( ; ) 	| up key
	16 >> | ascii
    $2B =? ( boxes 1 + 20 min 'boxes ! draw-screen ; ) | + key
    $2D =? ( boxes 1 - 0 max 'boxes ! draw-screen ; )  | - key
    $2b =? ( boxes 1 + 20 min 'boxes ! draw-screen ; ) | + key (num)
    $2d =? ( boxes 1 - 0 max 'boxes ! draw-screen ; )  | - key (num)
    
	$20 or | case
    | Handle 'c' or 'C' for color change    
    $63 =? ( box-color 1+ 6 mod 'box-color ! draw-screen ; )
    ;

|------- Animation Loop -------
:main-loop | --
    ( running 1? drop
        | Check for keyboard input
        inkey 1? ( handle-input )  drop
        | Small delay to reduce CPU usage
        10 ms
		) drop ;

|------- Main Program -------
:main | --
    | Set resize callback
    [ draw-screen ; ] .onresize
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
    .showc .cls .home .Reset
    "Goodbye!" .println ;

| Program entry point
: main ;
