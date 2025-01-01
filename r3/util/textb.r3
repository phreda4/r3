| textbox
| fit text in a box, with SDL2 and SDL2ttf library
| PHREDA 2021

^r3/lib/math.r3	

^r3/lib/sdl2gfx.r3	
^r3/lib/sdl2ttf.r3

#boxt 0 0 

#buffer * 4096
#lines * 512
#lines>
#boxlines * 512
#clines

#font
#ink
#htotal
#x #y
#bbtext [ 0 0 0 0 ]
#outline 2
#dddest [ 2 2 1 1 ]

#surface

#rectt [ 0 0 100 40 ] 	


:bbtextb | "text" --
	font swap ink TTF_RenderUTF8_Blended
	dup 0 surface 'bbtext SDL_BlitSurface
	SDL_FreeSurface	;

:bbrect
	SDLrenderer 'boxt SDL_RenderDrawRect ;

:bbfill
	SDLrenderer 'boxt SDL_RenderFillRect ;

::textline | str x y color font --
	'font ! 'ink !
	swap 'bbtext d!+ d!+
	font pick2 rot dup 4 + TTF_SizeUTF8 drop
	bbtextb ;
	
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
	
| color OOc1c1c1c2c2c2	
::textbox. | $vh str box color font --
	'font ! 
	$ffffff and 'ink !
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
|	'bbtextb 'vbbtext !
	textbox. ;

|--- text in box
::textboxb | $vh str box aacol1col2 font --
|	'bbtexts 'vbbtext !
	textbox. ;
	
|--- text outline
::textboxo | $vh str box oocol1col2 font --
	over 48 >> 
	dup dup 32 << or 'dddest !
	'outline !
	swap $ff000000000000 or swap
|	'bbtextbo 'vbbtext !
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
	
|||||||||||||||||||||||||||||||||||||||||||||||||||||
:boxprint | x y "" color --- 
	font -rot TTF_RenderUTF8_Blended
	|dup 1 SDL_SetSurfaceBlendMode 
	-rot swap 'rectt d!+ d!
	dup 0 surface 'rectt SDL_BlitSurface
	SDL_FreeSurface	
	;


::txbox | "str" vhcol 'box font -- texture
	'font !
	0 over 8 + d@+ swap d@ 32 
	$ff0000 $ff00 $ff $ff000000
	SDL_CreateRGBSurface
	|dup $ff SDL_SetSurfaceAlphaMod
	|dup 1 SDL_SetSurfaceBlendMode 
	dup 0 $447f0000 SDL_FillRect
	'surface !
	
	-rot | 'box "" col
	
|	font -rot TTF_RenderUTF8_Blended | font "" color -- surface
	
|	surf 1 SDL_SetSurfaceBlendMode 
|	'bbtext 8 + @ 'dddest 8 + !

|	dup 0 surf 0 |'dddest 
|	SDL_BlitSurface
|	SDL_FreeSurface	
	0 0 2over $FFFFFF and $ff000000 or boxprint
	10 10 "hola" $FF00ffff boxprint
	2drop
	
	drop
	SDLrenderer 1 SDL_SetRenderDrawBlendMode |(renderer, SDL_BLENDMODE_BLEND);
	SDLrenderer surface SDL_CreateTextureFromSurface
	surface SDL_FreeSurface
	;