| SDL2.dll
|
^r3/win/kernel32.r3
^r3/win/core.r3
^r3/win/console.r3

#sys-glClear

::glClear sys-glClear sys1 drop ;
	
|------- BOOT
:
	drop
	"SDL.dll" loadlib
	dup "glClear" getproc dup "%d" .println
	'sys-glClear !
	drop
|	"glew32.dll" loadlib

|	dup "__glewGenBuffers" getproc dup "%d" .println 'sys-glGenBuffers !
|	dup "__glewBindBuffer" getproc dup "%d" .println 'sys-glBindBuffer !
|	drop
	;