 | About timeline
| framerate independient event animation system
| PHREDA 2020
|------------------
|MEM $fff
^r3/win/console.r3
^r3/win/sdl2.r3
^r3/win/sdl2ttf.r3
^r3/win/sdl2image.r3	

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

	|son 4.0 +sound

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
|	son 6.0 +sound
|	son 12.0 +sound
	12.1 +restart

|	'exit 12.1 +event
	timeline.start
	;

|-----------------------------
:loadtexture | render "" -- text
	IMG_Load | ren surf
	swap over SDL_CreateTextureFromSurface
	swap SDL_FreeSurface ;
	
|-----------------------------
#pfont 
#wp #hp
#op 0 0
#dp 0 0

:bmfont | w h "" --
	SDLrenderer swap loadtexture 'pfont !
	2dup 32 << or dup
	'dp 8 + ! 'op 8 + !
	'hp ! 'wp ! 
	;
	
:bcolor	| rrggbb --
	pfont swap
	dup 16 >> $ff and over 8 >> $ff and rot $ff and
	SDL_SetTextureColorMod
	;
	
:bemit | ascii --
	dup $f and wp * swap 4 >> $f and hp * 32 << or 'op !
	SDLrenderer pfont 'op 'dp SDL_RenderCopy
	wp 'dp d+!
	;
	
:bmprint | "" --
	( c@+ 1? bemit ) 2drop ;
	
:bmat | x y --
	32 << or 'dp ! ;
	
|-----------------------------
#imagen

:sdlcolor | col --
	SDLrenderer swap
	dup 16 >> $ff and swap dup 8 >> $ff and swap $ff and 
	$ff SDL_SetRenderDrawColor ;

:demo
	0 sdlcolor
	SDLrenderer SDL_RenderClear
	
	timeline.draw
	
	SDLrenderer imagen 0 0 SDL_RenderCopy
	
	$ffffff bcolor 
	0 0 bmat "<f1> example 1" bmprint
	0 16 bmat "<f2> example 2" bmprint

	SDLrenderer SDL_RenderPresent
	SDLkey
	<f1> =? ( example1 )
	<f2> =? ( example2 )
	>esc< =? ( exit )
	drop
	|debugtimeline
	;
	
:main
	"r3sdl" 640 480 SDLinit
	SDL_windows -1 0 SDL_CreateRenderer 'SDLrenderer !
	SDLrenderer $ff $ff $ff $ff SDL_SetRenderDrawColor
	$3 IMG_Init

	SDLrenderer "media/img/lolomario.png" loadtexture 'imagen !
	
	|16 24 "media/img/font16x24.png" bmfont
	8 16 "media/img/VGA8x16.png" bmfont
	
	'demo SDLshow
	
	SDLquit
	;

:memory
	windows
	sdl2
	sdl2image
	mark
	timeline.inimem
	;

: memory main  ;


