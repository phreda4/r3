| TUI demo con tui.r3 
| PHREDA 2026
^r3/util/tui.r3
^r3/lib/sdl2image.r3

|--- datos 
#light 0
#pal.alt [
	$fbfbf8 $eeeee8 $e0e0d8 $cfcfc6
	$1c1c20 $5c5c68 $9a9aa4 $c2571a
	$1f5fbf $6f42c1 $1a7f37 $cf222e $9a6700 ]

|--- barras 
:head
	fhome bg3 fPr .Bold " tui " .write .NBold fTx
	rows cols "img demo  %dx%d" .print .eline ;

:foot
	fhome bg3 fTx " ESC " .write fMu "exit   " .write
	fTx "t " .write fMu "theme" .write .eline ;

#imgsurf
#spitch

::Surf>pix | surface -- surface pixels ; also leave the address of the pixels
	dup 32 + @ ;	

::Surf>wh | surface -- surface w h ; also leave the width and the height
	dup 16 + d@+ swap d@ ;

::Surf>pixpi | surface -- pixels pitch 
	dup 32 + @ swap 24 + d@ ;

:xypixel | x y -- pixel
	spitch * swap 2 << + a> + d@ ;

:cell | y x -- y x 
	2dup swap
	2dup 1+ xypixel 
	-rot xypixel >r | rgb rgb
	$ff and over 8 >> $ff and rot 16 >> $ff and 
	r>
	$ff and over 8 >> $ff and rot 16 >> $ff and 
	| rgb top
	| rgb bot
	"\033[38;2;%d;%d;%dm\033[48;2;%d;%d;%dm▀\033[0m" .print ;
	
:drawimg
	fhome
	imgsurf 0? ( drop ; ) 
	Surf>pixpi 'spitch !
	Surf>wh swap "%dx%d" .print
	Surf>pix >a
	0 ( fh <?
		0 ( fw <?
			cell
			1+ ) drop
		fcr
		2 + ) drop
	drop ;

	
	
|--- pantalla 
:theme
	light 1 xor 'light !
	light 1? ( drop 'pal.alt pal! ; ) drop
	'pal.dark pal! ;
	
:demo
	.reset bg0 fTx .cls
	1 flxN head
	1 flxS foot
	fw 3 / 22 max 30 min flxO
	fhome 
	"image" .write
	flxRest
	1 1 flpad
	drawimg
	
	uiKey 
	[esc] =? ( exitui )
	$74 =? ( theme ) 
	drop
	;

|-----------------------------------
:
	3 IMG_Init
	"media/img/manual.png" IMG_Load 'imgsurf !
	.alsb
|	'changeres onTuiResize
	'demo onTui
	.masb .free ;
