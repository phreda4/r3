^r3/win/console.r3
^r3/win/SDL2.r3
^r3/win/SDL2ttf.r3
^r3/lib/mem.r3
^r3/lib/key.r3

|---- colorbars
#col $fdfdfd $fdfc01 $fcfd $fe00 $fd00fb $fc0001 $0100fc

#rf [ 0 0 0 0 ]

:sajuste
	'col sw 7 /mod 1 >> | 'col w x
	( sw 8 - <?
		dup "%d" .println
		rot @+ 
		SDLrenderer swap
		dup 16 >> $ff and 
		swap dup 8 >> $ff and 
		swap $ff and 
		$ff SDL_SetRenderDrawColor 
		rot rot 
		sh pick2 0 pick3 'rf d!+ d!+ d!+ d!
		SDLrenderer 'rf SDL_RenderFillRect
		"a" .println
		over + )
	3drop ;

|----------------
:main
	sajuste 
	( SDLkey >esc< <>? drop
		SDLrenderer SDL_RenderPresent
		SDLupdate ) drop ;	

: 
	windows
	sdl2
	mark
	"r3sdl" 640 480 SDLinitgl

	main
	
	SDLquit
	;