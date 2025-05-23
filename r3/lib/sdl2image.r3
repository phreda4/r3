| SDL2_image.dll
|
^r3/lib/sdl2.r3

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
	SDLrenderer swap IMG_LoadTexture ;
	
::unloadimg | adr --
	SDL_DestroyTexture ;	
	
::loadsvg | w h "" -- tex
	"r" SDL_RWFromFile | w h rw
	dup 2swap IMG_LoadSizedSVG_RW | rw surface
	swap SDL_RWclose
	SDLrenderer over SDL_CreateTextureFromSurface 
	swap SDL_FreeSurface 
	;	

|----- BOOT	
: 

|WIN|	".\\dll" SetDllDirectory
|WIN|	"SDL2_image.DLL" loadlib
|LIN|	"libSDL2_image-2.0.so.0" loadlib	
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
|WIN|	"" SetDllDirectory	
	$3 IMG_Init
	;

