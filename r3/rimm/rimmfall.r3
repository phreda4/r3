| RIMM fallbacks: the optional drawing words written over the minimal
| primitives (color frect lineH lineV), for backends that only have those
| (glgfx today, a software bitmap or a vulkan backend tomorrow).
| A backend with its own version of any of these does not include this file.
|
|   line circle fcircle triangle frectg
|
^r3/lib/math.r3
^r3/lib/color.r3

|--- rectangle with a color in each corner (cells of gcell pixels)
#gx #gy #gw #gh #gc1 #gc2 #gc3 #gc4
#gi #gj
##gcell 4

:gcol | u v -- rgb ; u v 0..255
	>r
	gc1 gc2 pick2 colmix $ffffff and
	gc3 gc4 pick3 colmix $ffffff and
	rot drop r> colmix $ffffff and ;

::frectg | x y w h tl tr bl br -- ; fills with a color $RRGGBB in each corner
	'gc4 ! 'gc3 ! 'gc2 ! 'gc1 ! 'gh ! 'gw ! 'gy ! 'gx !
	0 ( gh <? dup 'gj !
		0 ( gw <? dup 'gi !
			gi 255 * gw gcell - 1 max / 255 min
			gj 255 * gh gcell - 1 max / 255 min
			gcol color
			gx gi + gy gj + gw gi - gcell min gh gj - gcell min frect
			gcell + ) drop
		gcell + ) drop ;
