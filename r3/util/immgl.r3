| immi backend: OpenGL (glgfx)
| PHREDA 2026
|
| The drawing words (color, fonts, text, shapes, clip, image box) are in
| glgfx.r3 with the same names as the SDL side (sdl2gfx + txfont).
| Here only what is specific of the gui: the icons.
|
^r3/lib/sdl2gl.r3
^r3/util/glgfx.r3

|--- icons (codes of the VGA font)
#icbuf 0 0

::txicon | char -- ; draw a one char icon, the cursor moves
	'icbuf c!
	'icbuf txwrite ;

::icChkOn 254 ;
::icChkOff 9 ;
::icRadOn 7 ;
::icRadOff 9 ;
::icTreeC 16 ;
::icTreeO 31 ;
::icCombo 31 ;
