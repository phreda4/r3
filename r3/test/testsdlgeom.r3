| sdl2 test program
| PHREDA 2022
^r3/win/sdl2.r3
^r3/win/sdl2gfx.r3
^r3/win/sdl2image.r3	

|VErtex
| 4  4   4    4   4
| xf yf rgba xtf ytf

#vert [
$43c80000 $43160000 $ff0000 0 0 | 400 150
$43480000 $43e10000 $0000ff 0 0 | 200 450
$44160000 $43e10000 $00ff00 0 0 | 600 450
]

:gira
	'vert >a
	400 300 msec 4 << 200 xy+polar swap i2fp da!+ i2fp da!+ 12 a+
	400 300 msec 4 << 0.33 + 200 xy+polar swap i2fp da!+ i2fp da!+ 12 a+	
	400 300 msec 4 << 0.66 + 200 xy+polar swap i2fp da!+ i2fp da!+ |12 a+
	;
	
:main
	$0 SDLcls
	gira

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

