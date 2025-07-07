| font atlas generator
| PHREDA 2024

^r3/lib/gui.r3
^r3/lib/sdl2gfx.r3
^r3/lib/sdl2ttf.r3

#ttfont

#tsizex 512
#tsizey 256

#recbox 0 0
#recdes 0 0 

#curx #cury

#newtex
#newtab

#utf8 "áéíóúñÁÉÍÓÚ«»¿×·" 0 

:recbox! | h w y x --
	'recbox d!+ d!+ d!+ d! ;	

:tt< | "" -- surf h w
	ttfont swap $ffffff TTF_RenderUTF8_Blended
	Surf>wh swap ;
	
:tt> | surf --
	SDLrenderer over SDL_CreateTextureFromSurface | surface texture
	SDLrenderer over 0 'recbox SDL_RenderCopy	
	SDL_DestroyTexture
	SDL_FreeSurface ;
	
#estr 0	

:adv | h w --
	curx over + tsizex <? ( drop ; ) drop
	0 'curx ! over 'cury +! ;
	
:fontemit | n --
	'estr c!+ 0 swap c!
	'estr tt< adv cury curx recbox! tt> ;

:fontemitw | n --
	'estr w!+ 0 swap c!
	'estr tt< adv cury curx recbox! tt> ;

:reccomp
	'recbox @+ swap @ 16 << or ;
	
:fontb!+ | adr -- adr'
	reccomp swap !+ ;
	
:fontw!+ | w --
	8 >> $ff and $80 or 3 << newTab +
	reccomp swap ! ;
	
::txload | "font" size -- nfont
	TTF_OpenFont 'ttfont !
	here dup 'newTex ! 8 + dup 'newTab ! 2048 + 'here !	| MEM
	newTab 0 256 fill 0 'curx ! 0 'cury !				| CLEAR
	tsizex tsizey texIni | w h --	
	newTab 32 3 << +
	32 ( 128 <? 
		dup fontemit
		swap fontb!+
		'recbox 8 + d@ 'curx +!
		swap 1+ ) 2drop 
	'utf8 ( w@+ 1?
		dup fontemitw 
		fontw!+
		'recbox 8 + d@ 'curx +!
		) 2drop
	texEndAlpha newTex !
	ttfont TTF_CloseFont 
	newTex
	;

|------------------------------
::txfont | font --
	dup @ 'newTex ! 8 + 'newTab ! ;
	
:fontemit | asci --
	$80 and? ( drop c@+ $80 or ) 
	$ff and 3 << newTab + @ 
	dup 16 >> $ffff0000ffff and 
	dup rot $ffff0000ffff and 
	'recbox !+ ! 
	cury 32 << curx or 'recdes !+ !
	SDLrenderer newTex 'recbox 'recdes SDL_RenderCopy	
	'recdes 8 + d@ 'curx +! ;

::txemits | "" --
	( c@+ 1? fontemit ) 2drop ;

::txrgb | c --
	newTex swap 
	dup 16 >> $ff and over 8 >> $ff and rot $ff and
	SDL_SetTextureColorMod ;
	
:fw
	$80 and? ( drop c@+ $80 or ) 
	$ff and 3 << newTab + w@ ; 
	
::txw | "" -- "" width
	0 over ( c@+ 1? fw rot + swap ) 2drop ;
	
::txh | -- heigth
	newTab 2 + w@ ;
	
::txat | x y --
	'cury ! 'curx ! ;
	
::txcur | n --
|	advx * tpos swap rot + swap advx advy SDLFRect 
	;

::txcuri | n --
|	advx * tpos swap rot + swap advy dup 2 >> - + advx advy 2 >> SDLFRect 
	;	
|------------------------------		
#font1 0
#font2 0
#font3 0

:game
	$0 SDLcls
	$ffffff sdlcolor
	
	font1 txfont
	$00ffff txrgb
	10 10 txat ":hola a ""coso"" todo el mundi ;" txemits
	$ff00ff txrgb
	10 50 txat ":hola i ;" txemits
	
	font2 txfont
	$ffffff txrgb
	'utf8 txemits
	10 90 txat ":hola a ""coso"" todo el mundi ;" txemits

	font3 txfont
	$ff0000 txrgb
	"djhaskdjahsf kjdash fkjdha fkjahs dkfjh asdfk" txemits

|10 10 tsizex tsizey newtex sdlimages	
	SDLredraw
	SDLkey
	>esc< =? ( exit )
	drop
	;

:main
	"ATLAS FONT GENERATOR" 1024 600 SDLinit
	
|	"media/ttf/ProggyClean.ttf" 
|	"media/ttf/roboto-bold.ttf" 
|	"media/ttf/RobotoMono.ttf" 
	"media/ttf/Roboto-bold.ttf" 32 txload 'font1 !
	"media/ttf/RobotoMono.ttf" 20 txload 'font2 !
	"media/ttf/ProggyClean.ttf" 16 txload 'font3 !
	
	'game SDLshow 
	SDLquit ;

: main ;