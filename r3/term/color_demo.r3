| Console Color Palette Demo
| Comprehensive demonstration of console color capabilities
| Works with both Linux and Windows console libraries

^r3/lib/console.r3

|------- Display State -------
#current-page 0
#anim-frame 0

|------- Helper Functions -------
:center-text | "text" y --
    swap count cols swap - 2/ rot .at .write ;

:title-bar | "text" --
    .home 
	.BBlue .Whitel .Bold .eline 
	1 center-text
    .Reset ;

:footer | --
    0 rows .at
    .BCyan .Black .eline
    " [SPACE] Next Page  [ESC] Exit " rows center-text
    .Reset 
	.flush ;

|------- Page 1: Basic 8 Colors -------
:show-basic-colors | --
    .cls
    "Basic ANSI Colors (8 colors)" title-bar
    
    3 5 .at .Bold "Foreground Colors:" .write .Reset
    
    5 7 .at .Black .BWhite "Black" .write .Reset
    5 8 .at .Red "Red" .write
    5 9 .at .Green "Green" .write
    5 10 .at .Yellow "Yellow" .write
    5 11 .at .Blue "Blue" .write
    5 12 .at .Magenta "Magenta" .write
    5 13 .at .Cyan "Cyan" .write
    5 14 .at .White "White" .write
    
    25 5 .at .Bold "Bold/Light Variants:" .write .Reset
    
    27 7 .at .Blackl .BWhite "Black Light" .write .Reset
    27 8 .at .Redl "Red Light" .write
    27 9 .at .Greenl "Green Light" .write
    27 10 .at .Yellowl "Yellow Light" .write
    27 11 .at .Bluel "Blue Light" .write
    27 12 .at .Magental "Magenta Light" .write
    27 13 .at .Cyanl "Cyan Light" .write
    27 14 .at .Whitel "White Light" .write
    
    50 5 .at .Bold "Background Colors:" .write .Reset
    
    52 7 .at .BBlack .White " Black BG " .write .Reset
    52 8 .at .BRed .White " Red BG " .write .Reset
    52 9 .at .BGreen .Black " Green BG " .write .Reset
    52 10 .at .BYellow .Black " Yellow BG " .write .Reset
    52 11 .at .BBlue .White " Blue BG " .write .Reset
    52 12 .at .BMagenta .White " Magenta BG " .write .Reset
    52 13 .at .BCyan .Black " Cyan BG " .write .Reset
    52 14 .at .BWhite .Black " White BG " .write .Reset
    
    footer ;

|------- Page 2: Text Attributes -------
:show-attributes | --
    .cls
    "Text Attributes and Styles" title-bar
    
    3 5 .at .Bold "Text Attributes:" .write .Reset
    
    5 7 .at .Reset "Normal text" .write
    5 8 .at .Bold "Bold text" .write .Reset
    5 9 .at .Dim "Dim text" .write .Reset
    5 10 .at .Italic "Italic text" .write .Reset
    5 11 .at .Under "Underlined text" .write .Reset
    5 12 .at .Blink "Blinking text" .write .Reset
    5 13 .at .Rever "Reversed text" .write .Reset
    5 14 .at .Strike "Strikethrough text" .write .Reset
    
    35 5 .at .Bold "Combined Attributes:" .write .Reset
    
    37 7 .at .Bold .Red "Bold Red" .write .Reset
    37 8 .at .Under .Green "Underlined Green" .write .Reset
    37 9 .at .Bold .Under .Blue "Bold Underlined Blue" .write .Reset
    37 10 .at .Italic .Magenta "Italic Magenta" .write .Reset
    37 11 .at .Rever .Cyan "Reversed Cyan" .write .Reset
    
    3 17 .at .Bold "Color + Background:" .write .Reset
    
    5 19 .at .BRed .Whitel " White on Red " .write .Reset
    5 20 .at .BGreen .Black " Black on Green " .write .Reset
    5 21 .at .BBlue .Yellowl " Yellow on Blue " .write .Reset
    5 22 .at .BMagenta .Whitel " White on Magenta " .write .Reset
    
    footer ;

:.cubeat | n -- n
	dup 16 - 36 mod
	1? ( drop ; ) drop
	5 over 16 - 36 / 10 + .at ;
	
|------- Page 3: 256 Color Palette -------
:show-256-colors | --
    .cls
    "256 Color Palette (Extended ANSI)" title-bar
    
    3 3 .at .Bold "Standard Colors (0-15):" .write .Reset    
    5 5 .at
    0 ( 16 <?
        dup .fc "███" .write
        1+ ) drop 
	.Reset
    
    3 8 .at .Bold "216 Color Cube (16-231):" .write .Reset
    
    5 10 .at
    16 ( 232 <?
		.cubeat
        dup .fc "██" .write
        1+ ) drop 
	.Reset
    
    3 22 .at .Bold "Grayscale (232-255):" .write .Reset    
    5 24 .at
    232 ( 256 <?
        dup .fc "███" .write
        1+ ) drop 
	.Reset
    footer ;

|------- Page 4: RGB True Color -------
:show-rgb-gradient | --
    .cls
    "24-bit True Color (RGB)" title-bar
    
    3 3 .at .Bold "Red Gradient:" .write .Reset
    5 5 .at
    0 ( 32 <?
        dup 8 * 0 0 .fgrgb "█" .write
        1+ ) drop 
	.Reset
    
    3 7 .at .Bold "Green Gradient:" .write .Reset
    5 9 .at
    0 ( 32 <?
        0 over 8 * 0 .fgrgb "█" .write
        1+ ) drop 
	.Reset
    
    3 11 .at .Bold "Blue Gradient:" .write .Reset
    5 13 .at
    0 ( 32 <?
        0 0 pick2 8 * .fgrgb "█" .write
        1+ ) drop 
	.Reset
    
    3 15 .at .Bold "Rainbow Gradient:" .write .Reset
    5 17 .at
    0 ( 64 <?
        dup 4 *
        dup 128 <? ( 255 swap - )
        dup 128 >=? ( 255 swap - )
        .fgrgb "█" .write
        1+ ) drop 
	.Reset
    
    3 19 .at .Bold "Background Colors:" .write .Reset
    5 21 .at
    0 ( 16 <?
        dup 16 * dup dup .bgrgb "  " .write
        1+ ) drop 
	.Reset
    
    footer ;

|------- Page 5: Animated Demo -------
:rainbow-char | n --
    anim-frame + 36 mod
    6 <? ( drop 255 0 0 ; )
    12 <? ( drop 255 255 0 ; )
    18 <? ( drop 0 255 0 ; )
    24 <? ( drop 0 255 255 ; )
    30 <? ( drop 0 0 255 ; )
	drop 255 0 255 ;

#cframe  .Red .Yellow .Green .Cyan .Blue .Magenta .Redl .bluel

:acframe
	anim-frame $e and 2 << 'cframe + @ ex ;

:show-animated | --
    .cls
    "Animated Color Effects" title-bar
    
    3 5 .at .Bold "Rainbow Wave:" .write .Reset
  
    5 7 .at
    0 ( 60 <?
        dup rainbow-char .fgrgb "█" .write
        6 + ) drop 

	.Reset
    3 10 .at .Bold "Pulsing Text:" .write .Reset    
    5 12 .at acframe 
	anim-frame $1 and? ( "●●●●●●●●" .write ) drop
	
    .Reset
    3 15 .at .Bold "Color Cycle:" .write .Reset
    5 17 .at acframe "████████████████████████████" .write .Reset
    
    footer ;

|------- Page Control -------
:draw-page | --
    current-page
    0 =? ( drop show-basic-colors ; )
    1 =? ( drop show-attributes ; )
    2 =? ( drop show-256-colors ; )
    3 =? ( drop show-rgb-gradient ; )
    drop show-animated ;

:next-page | --
    current-page 1+ 5 mod 'current-page !
    draw-page ;

|------- Event Handling -------
#running 1

:exit
    0 'running ! ;

:handle-key | key --
	[esc] =? ( exit ; )      | ESC
	$20 =? ( next-page ; ) | SPACE
    ;

:main-loop | --
    ( running 1? drop
        | Check for input
        inkey 1? ( handle-key ) drop
        | Animation update (only on page 4)
        current-page 4 =? (
            anim-frame 1 + 360 mod 'anim-frame !
            show-animated
        ) drop
        | Delay
        50 ms
    ) drop ;

|------- Resize Handler -------
:on-resize-event
    draw-page ;

|------- Main Program -------
:main
    'on-resize-event .onresize
    .hidec
    draw-page
    main-loop
    .showc .Reset
    "Color demo finished!" .println ;

| Program entry point
: main .free ;
