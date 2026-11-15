| RIMM demo over SDL2:   ./r3lin r3/rimm/demo-sdl.r3
| The demo body is rimmdemo.r3; only the backend and the frame change.
^r3/rimm/rimm.r3
^r3/rimm/rimmdemo.r3

:main
	$101010 cls
	demoFrame
	SDLredraw
	sdlkey
	>esc< =? ( exit )
	demoKey ;

:
	"RIMM demo SDL" 1024 700 SDLinitR
	| after loading several fonts select one with txfont (the last loaded is not usable)
	"media/ttf/RobotoMono.ttf" 16 txload
	"media/ttf/Roboto-Medium.ttf" 18 txload dup txfont
	demoFonts!
	"SDL2" demoBack!
	'main SDLshow
	SDLquit ;
