^r3/lib/rand.r3
^r3/lib/sdl2gfx.r3
^r3/util/txfont.r3

^r3/d4/r3token.r3

#ypad #hpad
#realpad * 8192

#prompt ":" "#" ">" "!"
#prmode 0

#place "test.r3" * 64
#nplace 

|----------------------------------------------------
#sourcecode "| coso
:cuad dup * ;
" * $fffff | 1MB code

|----------------------------------------------------	
#colback $323262
#colpad $326232

#t0 #t1 #t2 | font: big,med,small	


:main.draw
	$00 txalign
	sw 16 - ypad 16 - 8 8  
	'sourcecode
	txtext | w h x y "" --
	;
	

|----------------------------------------------------


:compile 
	;
	
:execute 
	;
	
:chgmode 
	prmode 1+ $3 and 'prmode ! ;

:demo
	colback SDLcls
	
	t1 txfont
	$ffffff txrgb
	main.draw
		
	colpad SDLcolor
	0 ypad sw hpad sdlfrect
	
	t0 txfont
	$ffffff txrgb
	10 hpad txat 
	prmode 2* 'prompt + txwrite
	
	'realpad pad.draw
	
	t2 txfont	
	sw 300 - 10 txat 
	'place txwrite
	
	SDLredraw 

	SDLkey
	>esc< =? ( exit )	
	<spc> =? ( compile ) 
	<ret> =? ( execute )
	<tab> =? ( chgmode ) 	
	drop 
	timer. ;
	
:main
	"Rim" 800 600 SDLinit
	"media/ttf/VictorMono-Bold.ttf" 64 txload 't0 !
	"media/ttf/VictorMono-Bold.ttf" 32 txload 't1 !
	"media/ttf/VictorMono-Bold.ttf" 24 txload 't2 !
	sh 2/ dup 'ypad ! 'hpad !
	'realpad 8192 pad.reset
	
	timer<
	
	'sourcecode "strtch.r3" r3loadmemd
	
	
	'demo SDLshow
	SDLquit ;	
	
: main ;