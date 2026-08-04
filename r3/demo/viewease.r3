^r3/lib/sdl2gfx.r3
^r3/util/varanim.r3
^r3/util/immi.r3

#nameease  "Lineal" "Quad_In" "Quad_Out" "Quad_InOut" "Cub_In" "Cub_Out" "Cub_InOut" "Quar_In" "Quar_Out" "Quar_InOut" "Quin_In" "Quin_Out" "Quin_InOut" "Sin_In" "Sin_Out" "Sin_InOut" "Exp_In" "Exp_Out" "Exp_InOut" "Cir_In" "Cir_Out" "Cir_InOut" "Ela_In" "Ela_Out" "Ela_InOut" "Bac_In" "Bac_Out" "Bac_InOut" "Bou_Out" "Bou_In" "Bou_InOut"
		
#varx * $ff
#vary * $ff

#wb 120
#hb 120

:ntoxy | n - n x y
	dup 6 /mod wb 40 + * 30 + swap hb * ;
	
:anibox | --
	vareset
	'varx >a
	'vary >b
	0 ( 30 <? 1 +
		a> wb 4 - 4 pick3 3.0 0.0 +vanim
		a> 4 wb 4 - 0 0.5 3.5 +vanim
		b> hb 4 - 4 0 3.0 0.0 +vanim
		b> 4 hb 4 - 0 0.5 3.5 +vanim
		8 a+ 8 b+ ) drop 
	'anibox 4.0 +vexe ;
	
|------------------
#xo #yo
:dline | x y yf xf -- x y yf
	wb 8 - *. pick3 4 + +
	over hb 8 - *. pick3 4 + +
	2dup xo yo line
	'yo ! 'xo !
	;
	
:linebox | n x y --
	2dup 4 + 'yo ! 4 + 'xo !
	0 ( 1.0 <? | y 
		dup pick4 1 + ease | y x
		dline		
		0.02 + ) drop ;
	
|-----------------	
:boxease | n -- n
	ntoxy 
	$ff00 color
	linebox
	2dup txat
	pick2 1 + 'nameease over n>>0 "%s %d" txprint
	
	$ffff color
	swap 'varx pick3 ncell+ @ 3 - +
	swap 'vary pick3 ncell+ @ 3 - +
	6 6 frect
	;
	
:panel
	0 ( 30 <?  
		boxease
		1 + ) drop ;	
		
:demo
	vupdate
	$0 cls
	panel
	SDLredraw	
	SDLkey
	>esc< =? ( exit )
	drop ;	

|--------------- INICIO ------------	
: 
	"View ease" 1024 600 SDLinit
	"media/ttf/Roboto-Medium.ttf" 18 txload txfont
	$ff vaini
	anibox
	'demo SDLshow
	SDLquit
	;
