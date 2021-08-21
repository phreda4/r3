| textbox
| fit text in a box, with SDL2 and SDL2ttf library
| PHREDA 2021

^r3/win/sdl2.r3	
^r3/win/sdl2ttf.r3

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
#bbtext [ 0 0 0 0 ]

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
		
::textbox | $vh str box color font --
	'font ! 'color !
	'boxt 64box
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
	%01000 and? ( drop textc ; )
	%10000 and? ( drop textr ; )
	drop textl ;
