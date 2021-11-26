| SDL2_image.dll
|
^r3/win/sdl2.r3

#sys-IMG_Init
#sys-IMG_Load

::IMG_Load sys-IMG_Load sys1 ;
::IMG_Init sys-IMG_Init sys1 drop ;	


::loadimg | "" -- texture
	IMG_Load 0? ( ; )
	SDLrenderer over SDL_CreateTextureFromSurface swap SDL_FreeSurface ;
	
::unloadimg | adr --
	0? ( drop ; ) 
	SDL_DestroyTexture ;	

|----- BOOT	
:
	"SDL2_image.DLL" loadlib
	dup "IMG_Load" getproc 'sys-IMG_Load !
	dup "IMG_Init" getproc 'sys-IMG_Init ! 
	drop
	
	$3 IMG_Init
	;

