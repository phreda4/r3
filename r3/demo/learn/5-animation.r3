| Animation example
| aswd for move

^r3/lib/sdl2gfx.r3
^r3/util/txfont.r3

#tsguy	| spritesheet
#nroguy 12	| frame ini
#sumguy 0	| add for animation
#maxguy 0	| frame max

#xp 100.0 #yp 400.0		| pos

#xv #yv		| speed

:animacion	| cnt nro -- 
	16 << 
	nroguy =? ( 2drop ; )
	'nroguy ! 
	'maxguy ! 
	0 'sumguy !
	;
	
:nroimagen	| -- nro
	0.09 'sumguy +!		| speed frame change
	
	nroguy sumguy + int.
	maxguy >? ( drop nroguy int. 0 'sumguy ! ) 
	;
	
:gravity
	yp 400.0 =? ( drop ; ) 
	400.0 >? ( drop 400.0 'yp ! ; ) 
	drop
	0.3 'yv +!
	;
	
:demo
	$323262 SDLcls
	
	$326232 SDLcolor
	0 400 800 200 sdlfrect
	xp int. yp int. 3.0 nroimagen tsguy sspritez	
	
	$ffff4c txrgb
	10 10 txat
	"awd - move sprite" txprint
	790 10 txat
	yp xp "%f %f" txprintr
	
	SDLredraw
	xv 'xp +!
	yv 'yp +!
	
	gravity
	
	SDLkey
	>esc< =? ( exit )
	<a> =? ( -1.0 'xv ! 8 1 animacion )
	>a< =? ( 0 'xv ! 0 0 animacion )
	<d> =? ( 1.0 'xv ! 17 10 animacion )
	>d< =? ( 0 'xv ! 0 9 animacion )
	<w> =? ( yp 400.0 =? ( -8.0 'yv ! ) drop )
	drop ;
	
:main
	"sdl animation" 800 600 SDLinit
	"media/ttf/VictorMono-Bold.ttf" 32 txload txfont	
	16 32 "media/img/p2.png" ssload 'tsguy !
	'demo SDLshow
	SDLquit ;	
	
: main ;