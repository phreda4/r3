| Curve2 - puerto de fórmula paramétrica JS/p5 a r3forth
| Original (minified, estilo tixy/dwitter):
| a=(m,d=mag(k=9*cos(i*5)*sin(i),e=cos(i*3)*cos(i*2)*9))
|   **3/1999+1.5-sin(t/2+m)**3/3
|   =>point(99*sin(c=d/16-t/48+m)+k*(p=d**sin(d*d-t+m))+200,
|            99*sin(c*4)+e*p+200)
| t=0
| draw=()=>{ t||createCanvas(400,400); background(9).stroke(w,96);
|   for(t+=PI/20,i=1e4;i--;) a(i, i%16*13) }
| @yuruyurau

^r3/lib/sdl2gfx.r3
^r3/lib/math.r3

#t #m #k #e #d #p #c #xp #yp #dexp
#SCALEX #SCALEY

| SIN/COS de argumentos en radianes (sin/cos nativos toman turns)
:rsin | rad -- s
	0.1591549 *. sin ;
:rcos | rad -- s
	0.1591549 *. cos ;

:qpoint | i --
	dup int. $f and 13.0 * 'm !
	dup 5.0 *. rcos 9.0 *. over rsin *. 'k !
	dup 3.0 *. rcos 9.0 *. over 2* rcos *. 'e !

	k dup *. e dup *. + sqrt.
	dup dup *. *. 1999.0 /. 1.5 +
	t 2/ m + rsin dup dup *. *. 3.0 /. -
	'd !

	d 4 >> t 48.0 /. - m + 'c !

	d dup *. t - m + rsin
	d swap pow. 'p !

	c rsin 99.0 *. k p *. + 200.0 + 'xp !
	c 2 << rsin 99.0 *. e p *. + 200.0 + 'yp !

	k $ff0000 and e $ff00 and or m $ff and or |$ffffff 
	Color

	xp SCALEX *. int.
	yp SCALEY *. int.
	Point ;

:curve | --
	0.0 ( 10000.0 <?
		qpoint 0.25 +
		) drop ;

:advance-t | --
	t 0.25 + 't ! ;

:draw
	0 cls
	curve
	SDLredraw
	advance-t

	SDLkey
	>esc< =? ( exit )
	drop ;

:main
	"Curve2" 800 600 SDLinit
	800.0 400.0 /. 'SCALEX !
	600.0 400.0 /. 'SCALEY !
	0.0 't !
	'draw SDLshow
	SDLquit ;

: main ;
