| immi over OpenGL: same widgets as immi.r3 with the glgfx drawing
| PHREDA 2026
|
^r3/util/immgl.r3
^r3/util/immcore.r3
^r3/util/immwid.r3

|--- init of the frame: the old engine (immMouse...) and the new one
::immIni | --
	immIniOld uiStart 4 4 uiPad ;

|--- old glimm names
::uiFTBtn | 'v "" -- ; full width button
	uiBtn ;
::uiTBtn | 'v "" -- ; button as wide as its text, next one at the right (uiLn to end the row)
	uiNBtn ;
::uiFToggle | 'var "text" --
	uiToggle ;
::uiWrite | "" -- ; text at the cursor, the next widget goes at the right
	uiTlabel ;
::gZoneAll | -- x y w h ; the current frame
	uiWinBox ;
::gZoneEle | -- x y w h ; the cursor box
	cx cy cw ch ;
::uiFill | -- ; the rest of the frame is the current one and the zone of the old engine (immMouse)
	uiRest uiWinBox immBox ;
