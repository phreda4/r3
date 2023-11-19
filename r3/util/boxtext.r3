| textbox
| fit text in a box, with SDL2 and SDL2ttf library
| PHREDA 2021

^r3/lib/math.r3	

^r3/win/sdl2gfx.r3	
^r3/win/sdl2ttf.r3

#boxt 0 0 

::xywh64 | x y w h -- 64b
	$ffff and swap
	$ffff and 16 << or swap
	$ffff and 32 << or swap
	$ffff and 48 << or ;

::w% sw 16 *>> ;
::h% sh 16 *>> ;

::xywh%64 | x y w h -- 64b
	h% $ffff and swap
	w% $ffff and 16 << or swap
	h% $ffff and 32 << or swap
	w% $ffff and 48 << or ;
	
::xy%64 | x y -- 64b
	h% $ffff and 32 << or swap
	w% $ffff and 48 << or 
	$ffffffff or ;

::64box | b adr --
	swap
	dup 48 >> rot d!+
	swap dup 16 << 48 >> rot d!+
	swap dup 32 << 48 >> rot d!+
	swap 48 << 48 >> swap d! ;	
	
#buffer * 4096
#lines * 512
#lines>
#boxlines * 512
#clines

#font
#ink
#inko
#htotal
#x #y
#bbtext [ 0 0 0 0 ]
#outline 2
#dddest [ 2 2 1 1 ]

:bbtextb | "text" --
	font swap ink TTF_RenderUTF8_Blended | surface
	SDLrenderer over SDL_CreateTextureFromSurface | surface texture
	SDLrenderer over 0 'bbtext SDL_RenderCopy	
	SDL_DestroyTexture
	SDL_FreeSurface ;
	
:bbtexts | "text" ---
	font swap ink inko TTF_RenderUTF8_shaded | surface
	SDLrenderer over SDL_CreateTextureFromSurface | surface texture
	SDLrenderer over 0 'bbtext SDL_RenderCopy	
	SDL_DestroyTexture
	SDL_FreeSurface ;	

:bbtextbo | "text" --
	font outline TTF_SetFontOutline
	font over inko TTF_RenderUTF8_Blended >r | surface
	
	font 0 TTF_SetFontOutline
	font swap ink TTF_RenderUTF8_Blended | surface
	
	dup 1 SDL_SetSurfaceBlendMode 
|	'bbtext 8 + @ 'dddest 8 + !
	dup 0 r@ 'dddest SDL_BlitSurface
	SDL_FreeSurface
	r>
	SDLrenderer over SDL_CreateTextureFromSurface | surface texture
	dddest 1 << 'bbtext 8 + +!
	SDLrenderer over 0 'bbtext SDL_RenderCopy	
	dddest 1 << neg 'bbtext 8 + +!
	SDL_DestroyTexture
	SDL_FreeSurface ;

#vbbtext 'bbtextb
	
:bbrect
	SDLrenderer 'boxt SDL_RenderDrawRect ;

:bbfill
	SDLrenderer 'boxt SDL_RenderFillRect ;

::textline | str x y color font --
	'font ! 'ink !
	swap 'bbtext d!+ d!+
	font pick2 rot dup 4 + TTF_SizeUTF8 drop
	vbbtext ex ;
	
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
		@+ vbbtext ex
		a> 8 - @ 32 >> 'y +!
		) drop ;
		
:textc
	'boxt d@+ 'x ! d@+ 'y +! d@ 1 >> 'x +! | x=center
	'boxlines >a	
	'lines ( lines> <?
		a@+ y x pick2 32 << 33 >> - 'bbtext d!+ d!+ !
		@+ vbbtext ex
		a> 8 - @ 32 >> 'y +!
		) drop ;
		
:textr
	'boxt d@+ 'x ! d@+ 'y +! d@ 'x +! | x=last
	'boxlines >a	
	'lines ( lines> <?
		a@+ y x pick2 32 << 32 >> - 'bbtext d!+ d!+ !
		@+ vbbtext ex
		a> 8 - @ 32 >> 'y +!
		) drop ;
	
| color OOc1c1c1c2c2c2	
::textbox. | $vh str box color font --
	'font ! 
	dup $ffffff and 'ink !
	24 >> $ffffffff and 'inko !
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
	
|--- text blended with transparency	
::textbox | $vh str box color font --
	'bbtextb 'vbbtext !
	textbox. ;

|--- text in box
::textboxb | $vh str box aacol1col2 font --
	'bbtexts 'vbbtext !
	textbox. ;
	
|--- text outline
::textboxo | $vh str box oocol1col2 font --
	over 48 >> 
	dup dup 32 << or 'dddest !
	'outline !
	swap $ff000000000000 or swap
	'bbtextbo 'vbbtext !
	textbox. ;
	
|--- calculate size
::textboxh | $vh str box col... font -- htotal
	'font ! 
	drop	
	'boxt 64box
	splitlines	
	0 'htotal !
	'boxlines >a
	'lines ( lines> <?
		@+ font swap a> dup 4 + TTF_SizeUTF8 drop
		a> 4 + d@ 'htotal +!
		8 a+ ) drop
	htotal ;