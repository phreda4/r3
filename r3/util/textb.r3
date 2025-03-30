| textbox 2
| fit text in a box, with SDL2 and SDL2ttf library
| PHREDA 2025

^r3/lib/math.r3	
^r3/lib/color.r3	
^r3/lib/sdl2gfx.r3	
^r3/lib/sdl2ttf.r3

#buffer * 4096
#buffer>
#lines * 512
#lines>
#boxlines * 512
#font
#ink
#htotal
#x #y #w #h
#bbtext [ 0 0 0 0 ]

#surface 0

:printline | "text" --
	font swap ink TTF_RenderUTF8_Blended
	dup 0 surface 'bbtext SDL_BlitSurface
	SDL_FreeSurface	;

|--- split lines
:emit
	$3b =? ( 0 nip ; ) | ;
	13 =? ( drop dup c@ 10 =? ( swap 1+ swap ) drop 0 ; )
	10 =? ( drop dup c@ 13 =? ( swap 1+ swap ) drop 0 ; )
	;
	
:marklines
	'buffer >a 
	( c@+ 1? emit ca!+ ) 
	emit ca!+ a> 'buffer> ! 
	drop ;
	
:<<sp | stro str -- str'
	swap over
	( over <? ( 2drop ; ) 
		dup c@ $ff and 32 >? 
		drop 1- ) drop nip nip ;

#rw #rc
:testw | str -- str
	font over w 'rw 'rc TTF_MeasureUTF8
	utf8count rc swap 
	>=? ( drop ; ) | str corte
	over b!+
	over + <<sp
	0 swap c!+
	testw ;
	
:splitlines
	marklines
	'lines >b
	'buffer ( buffer> <?
		testw dup b!+ >>0
		) drop
	b> 'lines> ! ;

|----------------------------------------------
:textl
	'lines ( lines> <?
		a@+ y x 'bbtext d!+ d!+ !
		@+ printline
		a> 8 - @ 32 >> 'y +!
		) drop ;
		
:textc
	w 1 >> 'x +! | x=center
	'lines ( lines> <?
		a@+ y x pick2 32 << 33 >> - 'bbtext d!+ d!+ !
		@+ printline
		a> 8 - @ 32 >> 'y +!
		) drop ;
		
:textr
	w 'x +! | x=last
	'lines ( lines> <?
		a@+ y x pick2 32 << 32 >> - 'bbtext d!+ d!+ !
		@+ printline
		a> 8 - @ 32 >> 'y +!
		) drop ;
	
| ---- 
:printtext | flags -- flags
	'boxlines >a	
	$10000 and? ( h htotal - 1 >> 'y +! )
	$20000 and? ( h htotal - 'y +! )
	$40000 and? ( textc ; )
	$80000 and? ( textr ; )
	textl ;

:.textbox | str flags --
	swap splitlines	
	0 'htotal !
	'boxlines >a
	'lines ( lines> <?
		@+ font swap a> dup 4 + TTF_SizeUTF8 drop
		a> 4 + d@ 'htotal +!
		8 a+ ) drop	
	surface 0 pick2 48 >> 4bcol SDL_FillRect
	$f00000 and? ( 
		font over 20 >> $f and TTF_SetFontOutline 
		dup 32 >> 4bicol 'ink !
		dup 24 >> $ff and over 20 >> $f and - dup 'x ! 'y !
		printtext 
		font 0 TTF_SetFontOutline 
		)
	dup 24 >> $ff and dup 'x ! 'y !
	dup 4bicol 'ink !
	printtext
	drop ;
	
| colb(4) colo(4) pad(2) flag(2) colf(4)	
::textbox | str $colb-colo-ofvh-colf w h font -- texture
	'font ! 
	0 pick2 pick2 32 
	$ff0000 $ff00 $ff $ff000000 
	SDL_CreateRGBSurface 'surface !
	pick2 24 >> $ff and 2* rot over - 'w ! - 'h !
	ab[ .textbox ]ba 
	SDLrenderer surface SDL_CreateTextureFromSurface
	surface SDL_FreeSurface
	dup 1 SDL_SetTextureScaleMode
	;
	