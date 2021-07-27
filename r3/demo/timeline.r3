| About timeline
| framerate independient event animation system
| PHREDA 2020
|------------------
|MEM $fff
^r3/win/console.r3
^r3/win/SDL2.r3
^r3/win/SDL2ttf.r3
^r3/lib/mem.r3
^r3/lib/key.r3
^r3/util/timeline.r3

#SDLrenderer

#mario	| a sprite

|-------------------- asorted animations
:example1 | --
	timeline.clear

	40 40 140 70 $ff00 +box
	1.0 +fx.on
	10 10 2xy 40 40 2xy 100 100 2xy 400 400 2xy 3.0 1.0 +fx.lin
	100 100 2xy 200 200 2xy 10 10 2xy 40 40 2xy 1.2 3.0 +fx.QuaIn
	4.0 +fx.off

	mario 50 50 60 60 +sprite
	0.0 +fx.on
	10 10 2xy 60 60 2xy 100 200 2xy 290 590 2xy 4.0 0.0 +fx.QuaIO
	9.0 +fx.off

	$00 "Hola_a todos" $10d003f $0 100 100 300 300 $ff00ff +textbox
	0.0 +fx.on
	100 100 2xy 300 300 2xy 200 200 2xy 500 500 2xy 3.0 2.0 +fx.QuaOut
	9.0 +fx.off

	son 4.0 +sound

	9.5 +restart

	timeline.start
	;

|-------------------- animation ease
#listPenner
+fx.lin +fx.QuaIn +fx.QuaOut +fx.QuaIO +fx.SinI +fx.SinO +fx.SinIO
+fx.ExpIn +fx.ExpOut +fx.ExpIO +fx.ElaIn +fx.ElaOut +fx.ElaIO +fx.BacIn
+fx.BacOut +fx.BacIO +fx.BouOut +fx.BouIn +fx.BouIO

#listPennerName
"+fx.lin" "+fx.QuaIn" "+fx.QuaOut" "+fx.QuaIO" "+fx.SinI" "+fx.SinO" "+fx.SinIO"
"+fx.ExpIn" "+fx.ExpOut" "+fx.ExpIO" "+fx.ElaIn" "+fx.ElaOut" "+fx.ElaIO" "+fx.BacIn"
"+fx.BacOut" "+fx.BacIO" "+fx.BouOut" "+fx.BouIn" "+fx.BouIO"

#nowy
#stepy

:possprite | y -- xy1f xy1t xy2f xy2t
	>r 20 r@ 2xy 20 stepy + r@ stepy + 2xy 770 r@ 2xy 770 stepy + r> stepy + 2xy ;

:makelist | name vec nro -- name' vec' nro
	rot >r
	$11 r@ $000001f $0 10 nowy 790 nowy stepy + $ff00 +textbox
	0.0 +fx.on
    r> >>0 rot >r
	mario 20 nowy 20 stepy + nowy stepy + +sprite
	0.0 +fx.on
	nowy possprite 5.0 1.0 r@ @ ex
	nowy possprite 2swap 5.0 7.0 r@ @ ex
	r> 4 + rot
	;

:example2
	timeline.clear

	sh 19 / 'stepy !
	1 'nowy !

	'listPennerName
	'listPenner
	19 ( 1? makelist
		stepy 'nowy +! 1 - ) 3drop
	son 6.0 +sound
	son 12.0 +sound
	12.1 +restart

|	'exit 12.1 +event
	timeline.start
	;

|-----------------------------
:main
	cls
	timeline.draw

	home fonti
	$ffffff 'ink !
	"timenow:" print timenow "%d" print cr
	"<f1> example 1" print cr
	"<f2> Penner animations" print cr

	key
	<f1> =? ( example1 )
	<f2> =? ( example2 )
	>esc< =? ( exit )
	drop
	;

:memory
	mark
	timeline.inimem

	"media/img/lolomario.png" loadimg 'mario !
	;

: memory 'main onShow ;


