| sprites stack inv
| PHREDA 2024
^r3/win/sdl2gfx.r3
^r3/util/pcfont.r3

#mm
#d1 0 
#d2 0
#d3
#d4

|------------- ISO
##isx 0.9 | 0.87
##isy 0.2 | 0.5
##isz -1.0
##isxo 512
##isyo 300

::xyz2iso | x y z -- x y
	-rot
	over isx *. over isx *. + | z x y x'
	rot isy neg *. rot isy *. + | x' y'
	rot + ;

:2iso
	xyz2iso 
	swap 12 >> isxo + 
	swap 12 >> isyo + ;

|------- SSPRITE
#ym #xm
#dx #dy

#vert [
0 0 0 0 0
0 0 0 0 0
0 0 0 0 0
0 0 0 0 0
]

#index [ 0 1 2 2 3 0 ]

:fillfull
	'vert >a 
	$ffffffff 0 $3f800000 |1.0 f2fp 
	8 a+ pick2 da!+ over da!+ over da!+
	8 a+ pick2 da!+ dup da!+ over da!+
	8 a+ pick2 da!+ dup da!+ dup da!+
	8 a+ pick2 da!+ over da!+ dup da!
	3drop ;

:rotxyiso! | x y x1 y1 -- x y
	over dx * over dy * - | x y x1 y1 x'
	rot dy * rot dx * +	| x y x' y'
	over isx *. over isx *. +   | x y x' y' x''
	17 >> pick4 + i2fp da!+
	swap isy neg *. swap isy *. +   | x y 
	17 >> over + i2fp da!+ 
	;	

:fillvertiso | x y ang --
	sincos 'dx ! 'dy !
	'vert >a
	xm neg ym neg rotxyiso! 12 a+
	xm ym neg rotxyiso! 12 a+
	xm ym rotxyiso! 12 a+
	xm neg ym rotxyiso!
	2drop ;

:fillvertisoy | dy --
	'vert 4 + >a | y
	da@ fp2f over + 16 >> i2fp da!+ 16 a+
	da@ fp2f over + 16 >> i2fp da!+ 16 a+
	da@ fp2f over + 16 >> i2fp da!+ 16 a+
	da@ fp2f over + 16 >> i2fp da!+
	drop ;


:settile | n adr -- adr
	swap 3 << 16 + over +
	@ dup 1 << $1fffe and f2fp | x1
	swap dup 15 >> $1fffe and f2fp 
	swap dup 31 >> $1fffe and f2fp 
	swap 47 >> $1fffe and f2fp 
	'vert >a
	12 a+ pick3 da!+ pick2 da!+
	12 a+ over da!+ pick2 da!+
	12 a+ over da!+ dup da!+
	12 a+ pick3 da!+ dup da!+
	4drop ;

	
::sspriteiso | x y ang zoom n ssprite --
	rot over sspritewh pick2 16 *>> 'ym ! 16 *>> 'xm !
	settile >r fillvertiso
	SDLrenderer r> @ 'vert 4 'index 6 
	SDL_RenderGeometry ;

::sspriteniso | dy n ssprite --
	settile >r fillvertisoy
	SDLrenderer r> @ 'vert 4 'index 6 
	SDL_RenderGeometry ;
	
|..............
|--- v1
:isospr | x y a z lev 'ss --
	pick2 neg pick2 pick2 
	>r >r >r
	sspriteiso | a lev 'ss
	r> r> r>
	swap ( 1-   | a 'ss lev 
		pick2 over pick3 sspriteniso | dy n ssprite --
		1? ) 3drop ;

|--- v2


:rotxyiso | x y x1 y1 -- x y xd yd
	over dx * over dy * -				| x y x1 y1 x'
	rot dy * rot dx * +					| x y x' y'
	over isx *. over isx *. + 17 >>		| x y x' y' x''
	rot isy neg *. rot isy *. + 17 >>	| x y 
	;	

:fillvertiso | x y ang --
	sincos 'dx ! 'dy !
	xm neg ym neg rotxyiso 
	$ffff and 16 << swap $ffff and or 'd1 ! 
	xm ym neg rotxyiso 
	$ffff and 16 << swap $ffff and or 'd2 !
	xm ym rotxyiso 
	$ffff and 16 << swap $ffff and or 'd3 !
	xm neg ym rotxyiso 
	$ffff and 16 << swap $ffff and or 'd4 !
	2drop ;

:isospr2 | x y a z 'ss --
	sspritewh | x y a z w h
	pick2 16 *>> 'ym ! 16 *>> 'xm ! | x y a
	fillvertiso | x y ang --
	xm 32 << ym $ffffffff and or 'mm !
	;
	
:gx+ 48 << 48 >> + ;
:gy+ 32 << 48 >> + ;

:drawbase | x y -
	over d1 gx+ over d1 gy+
	pick3 d2 gx+ pick3 d2 gy+
	sdlline
	over d2 gx+ over d2 gy+
	pick3 d3 gx+ pick3 d3 gy+
	sdlline
	over d4 gx+ over d4 gy+
	pick3 d3 gx+ pick3 d3 gy+
	sdlline
	over d1 gx+ over d1 gy+
	pick3 d4 gx+ pick3 d4 gy+
	sdlline
	2drop
	;
	
:debug	
	mm dup 32 << 32 >> swap 32 >> "%d %d" pcprint pccr
	d1 dup 48 << 48 >> swap 32 << 48 >> "%d %d" pcprint pccr
	d2 dup 48 << 48 >> swap 32 << 48 >> "%d %d" pcprint pccr
	d3 dup 48 << 48 >> swap 32 << 48 >> "%d %d" pcprint pccr
	d4 dup 48 << 48 >> swap 32 << 48 >> "%d %d" pcprint pccr
	;
	

|--------------
:floor
	$ffffff sdlcolor
	-5.0 ( 5.0 <?
		-5.0 ( 5.0 <?
			2dup 0 2iso sdlpoint
			0.5 + ) drop
		0.5 + ) drop ;

#spcar
#spcara

#spk
#spka

#a	
	
:game
	$3a3a3a SDLcls
	$ffffff pccolor
	0 0 pcat "Sprite stack" pcprint pccr
	spcara "%d" pcprint pccr
	spka "%d" pcprint pccr
	debug
	
	floor	
	
	| v1
	100 300 a 6.0 spcara spcar isospr
	350 300 a 6.0 spka spk isospr

	| v2
	500 500 a 6.0 spcara spcar isospr
	750 500 a 6.0 spka spk isospr
	
	0.002 'a +! 

	500 500 a 6.0 spcar isospr2
	200 500 drawbase 
	
	SDLredraw
	SDLkey
	>esc< =? ( exit )
	drop
	;

:main
	"WORD SS" 1024 600 SDLinit
	pcfont
	here
	16 16 "media/stackspr/car.png" ssload 'spcar !
	here swap - 3 >> 2 - 'spcara !
	
	here
	14 37 "media/stackspr/van.png" ssload 'spk !
	here swap - 3 >> 2 - 'spka !

	fillfull
	
	
	'game SDLshow 
	SDLquit ;

: main ;