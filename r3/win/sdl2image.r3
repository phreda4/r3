| SDL2_image.dll
|

#sys-IMG_Init
#sys-IMG_Load

::IMG_Load sys-IMG_Load sys1 ;
::IMG_Init sys-IMG_Init sys1 drop ;	


::loadimg | "" -- texture
	IMG_Load SDLrenderer over SDL_CreateTextureFromSurface swap SDL_FreeSurface ;
	
|----- BOOT	
:
	"SDL2_image.DLL" loadlib
	dup "IMG_Load" getproc 'sys-IMG_Load !
	dup "IMG_Init" getproc 'sys-IMG_Init ! 
	drop
	
	$3 IMG_Init
	;

