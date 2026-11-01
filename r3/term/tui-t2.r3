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

|-------------------------
#imgsurf
#spitch
#wsurf #hsurf

:Surf>wh | surface -- surface w h ; also leave the width and the height
	dup 16 + d@+ swap d@ ;

:Surf>pixpi | surface -- pixels pitch 
	dup 32 + @ swap 24 + d@ ;

:xypixel | x y -- pixel
	spitch * swap 2 << + a> + d@ ;

#lfg #lbg

:setfg | c --
	lfg =? ( drop ; ) dup 'lfg ! .fg32 ;
:setbg | c --
	lbg =? ( drop ; ) dup 'lbg ! .bg32 ;

:cell | y x -- y x 
	2dup swap 2dup 1+ 
	xypixel setbg xypixel setfg "▀" .write ;
	
:drawimg
	imgsurf 0? ( drop ; ) 
	fhome
	Surf>wh 'hsurf ! 'wsurf  !
	Surf>pixpi 'spitch ! >a
	-1 'lfg ! -1 'lbg !
	0 ( fh 2* <? hsurf <?
		0 ( fw <? wsurf <?
			cell
			1+ ) drop
		fcr
		2 + ) drop ;
	
:loadtimg | "" --
	imgsurf 1? ( dup SDL_FreeSurface ) drop
	IMG_Load 'imgsurf ! ;
	
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
	[f1] =? ( |imgsurf 
		"media/img/arena-map.png" loadtimg
		)
	drop
	;

|-----------------------------------
:
	3 IMG_Init
	"media/img/manual.png" 	loadtimg
	.alsb
|	'changeres onTuiResize
	'demo onTui
	.masb .free ;
