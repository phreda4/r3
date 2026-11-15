| RIMM demo over OpenGL (glgfx):   ./r3lin r3/rimm/demo-gl.r3
| The demo body is rimmdemo.r3; only the backend and the frame change.
| GL needs glgfx after GLini (rimmGLini) and the gui between fini and fend.
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
	"OpenGL" demoBack!
	'main SDLshow
	GLend ;
