| SDL2_image.dll
|
^r3/win/sdl2.r3

#sys-IMG_Init
#sys-IMG_Load
#sys-IMG_LoadTexture
#sys-IMG_LoadSizedSVG_RW

#sys-IMG_LoadAnimation
#sys-IMG_FreeAnimation

#sys-IMG_SavePNG 
#sys-IMG_SavePNG_RW 
#sys-IMG_SaveJPG 
#sys-IMG_SaveJPG_RW

::IMG_Load sys-IMG_Load sys1 ;
::IMG_Init sys-IMG_Init sys1 drop ;	
::IMG_LoadTexture sys-IMG_LoadTexture sys2 ; | rend file -- texture
::IMG_LoadSizedSVG_RW sys-IMG_LoadSizedSVG_RW sys3 ; | src w h -- surface

::IMG_LoadAnimation sys-IMG_LoadAnimation sys1 ; | file -- anim
::IMG_FreeAnimation sys-IMG_FreeAnimation sys1 drop ; | anim --

::IMG_SavePNG sys-IMG_SavePNG sys2 drop ; |(SDL_Surface *surface, const char *file);
::IMG_SavePNG_RW sys-IMG_SavePNG_RW sys3 drop ; |(SDL_Surface *surface, SDL_RWops *dst, int freedst);
::IMG_SaveJPG sys-IMG_SaveJPG sys3 drop ; |(SDL_Surface *surface, const char *file, int quality);
::IMG_SaveJPG_RW sys-IMG_SaveJPG_RW sys4 drop ; |(SDL_Surface *surface, SDL_RWops *dst, int freedst, int quality);

::loadimg | "" -- texture
	IMG_Load 0? ( ; )
|	SDLrenderer swap IMG_LoadTexture ;
	SDLrenderer over SDL_CreateTextureFromSurface swap SDL_FreeSurface ;
	
::unloadimg | adr --
	0? ( drop ; ) 
	SDL_DestroyTexture ;	

|----- BOOT	
:
	"SDL2_image.DLL" loadlib
	dup "IMG_Load" getproc 'sys-IMG_Load !
	dup "IMG_Init" getproc 'sys-IMG_Init !
	dup "IMG_LoadTexture" getproc 'sys-IMG_LoadTexture !
	dup "IMG_LoadSizedSVG_RW" getproc 'sys-IMG_LoadSizedSVG_RW !

	dup "IMG_LoadAnimation" getproc 'sys-IMG_LoadAnimation !
	dup "IMG_FreeAnimation" getproc 'sys-IMG_FreeAnimation !

	dup "IMG_SavePNG" getproc 'sys-IMG_SavePNG !
	dup "IMG_SavePNG_RW" getproc 'sys-IMG_SavePNG_RW !
	dup "IMG_SaveJPG" getproc 'sys-IMG_SaveJPG !
	dup "IMG_SaveJPG_RW" getproc 'sys-IMG_SaveJPG_RW !
	drop
	
	$3 IMG_Init
	;

