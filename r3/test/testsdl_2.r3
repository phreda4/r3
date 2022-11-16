| sdl2 test program
| PHREDA 2021
^r3/win/sdl2.r3
^r3/win/sdl2gfx.r3
^r3/win/sdl2image.r3	

|VErtex
| 4  4   4    4   4
| xf yf rgba xtf ytf

#vert [
$43c80000 $43160000 $ff0000ff 0 0 | 400 150
$43480000 $43e10000 $0000ffff 0 0 | 200 450
$44160000 $43e10000 $00ff00ff 0 0 | 600 450
]

	
:main
	$0 SDLcls
	

	SDLrenderer 0 'vert 3 0 0 SDL_RenderGeometry
	
	SDLredraw
	
	SDLkey
	>esc< =? ( exit )
	drop ;
		
:
	"r3sdl" 800 600 SDLinit
	'main SDLshow 
	SDLquit
	;

