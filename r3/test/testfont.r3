| sdl2 test program
| PHREDA 2021
^r3/win/console.r3
^r3/win/sdl2.r3	
^r3/win/sdl2ttf.r3
^r3/lib/sys.r3
^r3/lib/gr.r3

#vx 0

#texto "para bebés y niños
Yogures naturales
Budines 
Tartas ñ¿⌐óúº╕
Hamburguesas proteicas
"

#t2 "esto es un texto demasiado largo para que entre en la caja"

#bbtext [ 0 0 0 0 ]

:RenderText | SDLrender color font "texto" x y --
	swap 'bbtext d!+ d!
	2dup 'bbtext dup 8 + swap 12 + TTF_SizeUTF8 drop
	rot 
	|TTF_RenderUTF8_Solid
	TTF_RenderUTF8_Blended | sdlr surface	
	2dup SDL_CreateTextureFromSurface | sd surface texture
	rot over 0 'bbtext SDL_RenderCopy	
	SDL_DestroyTexture 
	SDL_FreeSurface ;

#boxt 0 0 

#buffer * 8192
#lines * 512
#lines>
#boxlines * 512
#clines

#font
#color
#htotal
#x #y

:bbtextb | "text" ---
	font swap color TTF_RenderUTF8_Blended | surface
	SDLrenderer over SDL_CreateTextureFromSurface | surface texture
	SDLrenderer over 0 'bbtext SDL_RenderCopy	
	SDL_DestroyTexture
	SDL_FreeSurface ;
	
:bbrect
	SDLrenderer 'boxt SDL_RenderDrawRect ;

:bbfill
	SDLrenderer 'boxt SDL_RenderFillRect ;

::w% sw 16 *>> ;
::h% sh 16 *>> ;

::xywh%64 | x y w h -- 64b
	h% $ffff and swap
	w% $ffff and 16 << or swap
	h% $ffff and 32 << or swap
	w% $ffff and 48 << or ;

::64box | b adr --
	swap
	dup 48 >> rot d!+
	swap dup 16 << 48 >> rot d!+
	swap dup 32 << 48 >> rot d!+
	swap 48 << 48 >> swap d! ;	
	


:textl
	'boxt d@+ 'x ! d@+ 'y +! drop 
	'boxlines >a	
	'lines ( lines> <?
		a@+ y x 'bbtext d!+ d!+ !
		@+ bbtextb
		a> 8 - @ 32 >> 'y +!
		) drop ;
		
:textc
	'boxt d@+ 'x ! d@+ 'y +! d@+ 1 >> 'x +! drop | x=center
	'boxlines >a	
	'lines ( lines> <?
		a@+ y x pick2 32 << 33 >> - 'bbtext d!+ d!+ !
		@+ bbtextb
		a> 8 - @ 32 >> 'y +!
		) drop ;
		
:textr
	'boxt d@+ 'x ! d@+ 'y +! d@+ 'x +! drop | x=last
	'boxlines >a	
	'lines ( lines> <?
		a@+ y x pick2 32 << 32 >> - 'bbtext d!+ d!+ !
		@+ bbtextb
		a> 8 - @ 32 >> 'y +!
		) drop ;

#lastsp

:inwbox | c -- c
	0 ca!
	font b> 8 - @ 'x 'y TTF_SizeUTF8 drop
	x 'boxt 8 + d@ | wsize wbox
	<=? ( drop a> 'lastsp ! ; ) drop
	0 lastsp c!+ b!+
	;
	
:emit
	13 =? ( 0 ca!+ a> b!+ drop ; )
	10 =? ( drop ; )
	32 =? ( inwbox )
	ca!+ ;
		
:splitlines | "" --
	'lines >b
	'buffer dup b!+ >a
	( c@+ 1? emit ) ca!+ a> b!+
	drop 
	b> 8 - 'lines> ! ;
		
:textbox | $vh str box color --
	'color !
	'boxt 64box
	
|	SDLrenderer 0 55 0 255 SDL_SetRenderDrawColor bbfill
	
	splitlines	
	
	0 'htotal !
	'boxlines >a
	'lines ( lines> <?
		@+ font swap a> dup 4 + TTF_SizeUTF8 drop
		a> 4 + d@ 'htotal +!
		8 a+ ) drop
	
	0 'y !
	%01 and? ( 'boxt 12 + d@ htotal - 1 >> 'y ! )
	%10 and? ( 'boxt 12 + d@ htotal - 'y ! )
	%010000 and? ( drop textc ; )
	%100000 and? ( drop textr ; )
	drop textl ;

	
:drawl
	0 SDLclear

	vx 'texto 0.1 0.1 0.8 0.8 xywh%64 $ff0000 textbox
	
	vx 't2 0.3 0.3 0.3 0.3 xywh%64 $ff00 textbox
	
	
	SDLrenderer $ff00 font vx "x:%d" sprint 50 350 RenderText
	SDLRedraw
	
	SDLkey
	>esc< =? ( exit )
	<le> =? ( -1 'vx +! )
	<ri> =? ( 1 'vx +! )	
	drop ;
		
:draw
	'drawl SDLshow ;

:main
	"r3sdl" 640 480 SDLinitgl
	ttf_init
	"media/ttf/roboto-bold.ttf" 24 TTF_OpenFont 'font !

	draw

	SDLquit
	;

: main ;

