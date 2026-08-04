| Swimming Quiverbloom - puerto de QB64 a r3forth
| https://github.com/oonap0oo/QB64-projects/tree/main
| Original: K Moerman 2026
| from: @yuruyurau

^r3/lib/sdl2gfx.r3
^r3/lib/math.r3
^r3/lib/color.r3

#t #y #k #e #d #q #c #xp #yp
#SCALEX #SCALEY
#colormode

#colortime |#phase1 #phase2 #phase3 |#hue #sat #val #bright

| SIN/COS de argumentos en radianes (los que vienen de x, no de t)
| sin/cos nativos toman turns (fixed-point 48.16, 1.0 = 360°)
:rsin | rad -- s   
	0.1591549 *. sin ;
:rcos | rad -- s   
	0.1591549 *. cos ;

| HSV cíclico basado en xp,yp,d,t 
| el brillo (bright, 0.5..1.5) se aplica multiplicando V y clampeando a 1.0,
| ya que V es exactamente el canal de brillo en HSV
:calc-color | -- rgb32
	t 0.5 *. 'colortime !

	xp 0.01 *. colortime + rsin 0.5 *. 0.5 + |'phase1 !
	colortime 0.0555 *. + |'hue !
	
	yp 0.1 *. colortime 1.3 *. + rsin 0.5 *. 0.5 + |'phase2 !
	0.4 *. 0.6 + |'sat !
	
	d 0.5 *. colortime 0.7 *. + rsin 0.5 *. 0.5 + |'phase3 !
	0.2 *. 0.8 +
	| animBrightness = abs(sin(t*2 + xp*0.001)) + 0.5   ( 0.5 .. 1.5 )
	t 2.0 *. xp 0.001 *. + rsin abs 0.5 + |'bright ! 
	*. 1.0 min |'val !

	hsv2rgb ; 	|hue sat val 

:setcolor | --
	calc-color
	color ;

:qpoint | xin --
	dup 235.0 /. 'y !
	dup 11.0 /. 8.0 t *. + rsin 4.0 +
	over 14.0 /. rcos *. 'k !

	y 9.0 /. 19.0 - 'e !

	k dup *. e dup *. + sqrt.
	y 9.0 /. 3.0 t *. + rsin + 'd !

	k 2.0 *. rsin 2.0 *.
	y 17.0 /. rsin k *.
	y d 3.0 *. - rsin 2.0 *. 9.0 +
	*. + 'q !

	d dup *. 49.0 /. t - 'c !

	q c rcos 50.0 *. + 200.0 + 'xp !
	d 39.0 *. q c rsin *. + 440.0 - 'yp !

	setcolor

	xp SCALEX *. int. 
	yp SCALEY *. int.
	point ;

:curve | --
	0.0 ( 12000.0 <=?
		qpoint 0.5 +
		) drop ;

:advance-t | --
	t 3.14159265 240.0 /. + 't ! ;

:draw
	0 cls
	curve
	SDLredraw
	advance-t

	SDLkey
	>esc< =? ( exit )
	drop ;

:main
	"Swimming Quiverbloom" 800 600 SDLinit
	800.0 380.0 /. 'SCALEX !
	600.0 400.0 /. 'SCALEY !
	0.0 't !
	0 'colormode !
	'draw SDLshow
	SDLquit ;

: main ;
