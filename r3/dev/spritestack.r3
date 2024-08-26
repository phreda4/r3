| sprites stack test
| PHREDA 2024
^r3/win/sdl2gfx.r3
^r3/util/pcfont.r3

#sptree
#spcar

#x 500
#y 300
#dx 1
#dy 1

:drawsp |
	x y 0 ( 43 <?
		pick2 pick2 pick2 sptree ssprite
		rot dx + rot dy + rot 1+ ) 3drop
	;
:game
	$0 SDLcls
	$ffffff pccolor
	0 0 pcat "Sprite stack" pcprint
	
	drawsp
	
	SDLredraw
	SDLkey
	>esc< =? ( exit )
	drop
	;

:main
	"Sprite Rotation" 1024 600 SDLinit
	pcfont
	36 36 "media/stackspr/blue_tree.png" ssload 'sptree !
	16 16 "media/stackspr/car.png" ssload 'spcar !
	
	'game SDLshow 
	SDLquit ;

: main ;