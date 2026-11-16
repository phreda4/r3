| RIMM demo over OpenGL (glgfx):   ./r3lin r3/rimm/demo-gl.r3
| The demo body is rimmdemo.r3; only the backend and the frame change.
| GL needs glgfx after GLini (rimmGLini) and the gui between fini and fend.
| Fonts: the same TTF files and sizes as demo-sdl.r3 (txload from gltxfont).
^r3/rimm/rimmgl.r3
^r3/rimm/demo-rimm.r3

:main
	GLcls
	fini
	demoFrame
	fend
	GLUpdate
	sdlkey
	>esc< =? ( exit )
	demoKey ;

:
	"RIMM demo GL" 1024 700 rimmGLini
	$101010 GLpaper
	"media/ttf/RobotoMono.ttf" 16 txload
	"media/ttf/Roboto-Medium.ttf" 18 txload dup txfont
	demoFonts!
	"OpenGL" demoBack!
	'main SDLshow
	GLend ;
