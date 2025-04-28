| r3help
| PHREDA 20225

^r3/lib/sdl2gfx.r3
^r3/util/bfont.r3

^r3/d4/meta/mlibs.r3

#tabw 20
#inc> 'liblist

:sel
	inc> =? ( $ffffff bcolor ; ) $888888 bcolor ; 
	
:includes
	0 0 bat
	'liblist ( sel @+ 1? 
		@ bemits bcr
		) 2drop 
	0 0 bat
	inc> @ 8 + @
	( dup c@ 1? drop
		tabw gotox
		dup bemits bcr 
		>>0
		) 2drop
		;
	
|-----
:main
	0 sdlcls
	
	includes	
	
	sdlredraw
	sdlkey
	>esc< =? ( exit )
	<dn> =? ( 8 'inc> +! )
	<up> =? ( -8 'inc> +! )
	drop
	;

|-----
:
	"R3d4 Help" 1280 720 SDLinit
	bfont1
	'main SDLshow
	SDLquit 
;

