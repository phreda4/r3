| textbox
| fit text in a box, with SDL2 and SDL2ttf library
| PHREDA 2021

^r3/win/sdl2gfx.r3	
^r3/win/sdl2ttf.r3

#boxt 0 0 

::64box | b adr --
	swap
	dup 48 >> rot d!+
	swap dup 16 << 48 >> rot d!+
	swap dup 32 << 48 >> rot d!+
	swap 48 << 48 >> swap d! ;	
	
#buffer * 4096
#lines * 256
#lines>
#boxlines * 256
#clines

#font
#ink
#htotal
#x #y
#bbtext [ 0 0 0 0 ]

:bbtextb | "text" ---
	font swap ink TTF_RenderUTF8_Blended | surface
	SDLrenderer over SDL_CreateTextureFromSurface | surface texture
	SDLrenderer over 0 'bbtext SDL_RenderCopy	
	SDL_DestroyTexture
	SDL_FreeSurface ;
	
:bbrect
	SDLrenderer 'boxt SDL_RenderDrawRect ;

:bbfill
	SDLrenderer 'boxt SDL_RenderFillRect ;

#lastsp

:inwbox | c -- c
	0 ca!
	0 'x ! 0 'y ! | store 32, clear sign
	font b> 8 - @ 'x 'y TTF_SizeUTF8 drop
	x 'boxt 8 + d@ | wsize wbox
	<=? ( drop a> 'lastsp ! ; ) drop
	0 lastsp c!+ b!+ 
	a> 'lastsp !
	;
	
:emit
	13 =? ( over c@ 10 =? ( 2drop ; ) inwbox 0 ca!+ a> b!+ 2drop ; )
	10 =? ( inwbox 0 ca!+ a> b!+ drop ; )
	$3b =? ( inwbox 0 ca!+ a> b!+ drop ; ) | ;
	32 =? ( inwbox )
	ca!+ ;
	
:lastline
	a> 2 - c@ 0? ( drop b> 16 - ; ) drop
	b> 8 - ;
	
:splitlines | "" --
	'lines >b
	'buffer dup >a b!+ 
	( c@+ 1? emit ) 
	inwbox ca!+ 0 ca! a> b!+
	drop 
	lastline 'lines> ! ;

|----------------------------------------------
:textl
	'boxt d@+ 'x ! d@ 'y +! 
	'boxlines >a	
	'lines ( lines> <?
		a@+ y x 'bbtext d!+ d!+ !
		@+ bbtextb
		a> 8 - @ 32 >> 'y +!
		) drop ;
		
:textc
	'boxt d@+ 'x ! d@+ 'y +! d@ 1 >> 'x +! | x=center
	'boxlines >a	
	'lines ( lines> <?
		a@+ y x pick2 32 << 33 >> - 'bbtext d!+ d!+ !
		@+ bbtextb
		a> 8 - @ 32 >> 'y +!
		) drop ;
		
:textr
	'boxt d@+ 'x ! d@+ 'y +! d@ 'x +! | x=last
	'boxlines >a	
	'lines ( lines> <?
		a@+ y x pick2 32 << 32 >> - 'bbtext d!+ d!+ !
		@+ bbtextb
		a> 8 - @ 32 >> 'y +!
		) drop ;
		
::textbox | $vh str box color font --
	'font ! 'ink !
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
	%010000 and? ( drop textc ; )
	%100000 and? ( drop textr ; )
	drop textl ;
	
|------------------------------------------------
:bbtexts | "text" ---
	font swap ink dup $ffffffff and swap 32 >> TTF_RenderUTF8_shaded | surface
	SDLrenderer over SDL_CreateTextureFromSurface | surface texture
	SDLrenderer over 0 'bbtext SDL_RenderCopy	
	SDL_DestroyTexture
	SDL_FreeSurface ;


:textls
	'boxt d@+ 'x ! d@ 'y +! 
	'boxlines >a	
	'lines ( lines> <?
		a@+ y x 'bbtext d!+ d!+ !
		@+ bbtexts
		a> 8 - @ 32 >> 'y +!
		) drop ;
		
:textcs
	'boxt d@+ 'x ! d@+ 'y +! d@ 1 >> 'x +! | x=center
	'boxlines >a	
	'lines ( lines> <?
		a@+ y x pick2 32 << 33 >> - 'bbtext d!+ d!+ !
		@+ bbtexts
		a> 8 - @ 32 >> 'y +!
		) drop ;
		
:textrs
	'boxt d@+ 'x ! d@+ 'y +! d@ 'x +! | x=last
	'boxlines >a	
	'lines ( lines> <?
		a@+ y x pick2 32 << 32 >> - 'bbtext d!+ d!+ !
		@+ bbtexts
		a> 8 - @ 32 >> 'y +!
		) drop ;

::textboxs | $vh str box color font --

	'font ! 'ink !
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
	%010000 and? ( drop textcs ; )
	%100000 and? ( drop textrs ; )
	drop textls ;
