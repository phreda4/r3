| sdl2 rotate render texture triangle
| PHREDA 2022
^r3/win/sdl2.r3
^r3/win/sdl2gfx.r3
^r3/win/sdl2image.r3	

#textura

|VErtex
| 4  4   4    4   4
| xf yf rgba xtf ytf
#vert [
$43c80000 $43160000 $ffffffff 0 0 | 400 150
$43480000 $43e10000 $ffffffff 0 0 | 200 450
$44160000 $43e10000 $ffffffff 0 0 | 600 450
$44160000 $43e10000 $ffffffff 0 0 | 600 450
]

#index [ 0 1 2 0 2 3 ] 

:fillt
	'vert >a
	12 a+ 0.0 f2fp da!+ 0.0 f2fp da!+
	12 a+ 0.0 f2fp da!+ 1.0 f2fp da!+
	12 a+ 1.0 f2fp da!+ 1.0 f2fp da!+
	12 a+ 1.0 f2fp da!+ 0.0 f2fp da!+
	;
	
:gira
	'vert >a
	400 300 msec 4 <<
	100 xy+polar swap i2fp da!+ i2fp da!+ 12 a+
	400 300 msec 4 << 
	0.25 + 100 xy+polar swap i2fp da!+ i2fp da!+ 12 a+	
	400 300 msec 4 << 
	0.5 + 100 xy+polar swap i2fp da!+ i2fp da!+ 12 a+
	400 300 msec 4 << 
	0.75 + 100 xy+polar swap i2fp da!+ i2fp da!+ |12 a+
	;
	
:main
	$0 SDLcls
	gira
	|SDLrenderer 0 SDL_RenderSetClipRect
	SDLrenderer textura 'vert 4 'index 6 SDL_RenderGeometry
	10 10 textura SDLImage
	SDLredraw
	
	SDLkey
	>esc< =? ( exit )
	drop ;

:
	"r3sdl" 800 600 SDLinit
	"media/img/lolomario.png" loadimg 'textura !
	fillt
	'main SDLshow 
	SDLquit
	;

