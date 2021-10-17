| demo particles
| PHREDA 2021

^r3/win/console.r3
^r3/win/sdl2.r3
^r3/win/sdl2image.r3
^r3/lib/rand.r3
^r3/util/arr8.r3

#spr_ball

#list 0 0 


|--------------------------------
:choque
	a> 8 + dup @ neg swap ! ;
	

:ballexec | adr -- 
	>a
	a@+ 16 >> 0 <? ( choque ) sw 64 - >? ( choque )
	a@+ 16 >> 0 <? ( choque ) sh 64 - >? ( choque )
	a@+ a> 24 - +!
	a@+ a> 24 - +!	
	a@+ SDLImage ;
	
:+obj | 'spr vy vx y x --
	'ballexec 'list p!+ >a a!+ a!+ a!+ a!+ a! ;


|----- rotacion..float arg!!
#rbox [ 0 0 64 64 ]

:ballexecr | adr --
	>a
	a@+ 16 >> 0 <? ( choque ) sw 64 - >? ( choque )
	a@+ 16 >> 0 <? ( choque ) sh 64 - >? ( choque )
	swap 'rbox d!+ d!
	a@+ a> 24 - +!
	a@+ a> 24 - +!	
	SDLrenderer a@+ 0 'rbox a@+ 0 0 SDL_RenderCopyEx ; | don't work rot is double!

:+objr | r 'spr vy vx y x --
	'ballexecr 'list p!+ >a a!+ a!+ a!+ a!+ a!+ a! ;
	
|--------------------------------
:demo
	0 SDLClear
	'list p.draw
	SDLRedraw

	SDLkey
	<f1> =? ( 
		spr_ball 
		6.0 randmax 3 - 
		6.0 randmax 3 - 
		500.0 randmax 10.0 +
		700.0 randmax 10.0 + +obj )	
	<f2> =? ( 
		360 randmax
		spr_ball 
		6.0 randmax 3 - 
		6.0 randmax 3 - 
		500.0 randmax 10.0 +
		700.0 randmax 10.0 + +objr )	
		
	>esc< =? ( exit )
	drop ;
	
:main
	"r3sdl" 800 600 SDLinit

	"media/img/ball.png" loadimg 'spr_ball !
	1000 'list p.ini
	
	'demo SDLshow
	
	SDLquit ;
	
	
: main ;