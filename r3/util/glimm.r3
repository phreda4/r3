| immi over OpenGL: same widgets as immi.r3 with the glgfx drawing
| PHREDA 2026
|
^r3/util/immgl.r3
^r3/util/immcore.r3
^r3/util/immwid.r3

|--- mouse zone (camera and the like), same words as immzone.r3 but over the
|--- immcore state, so it lives together with the widgets
##wix ##wiy ##wiw ##wih

::immBox | x y w h -- ; zone of immMouse and immZone
	'wih ! 'wiw ! 'wiy ! 'wix ! ;

::immFull | -- ; the zone is the whole screen
	0 0 sw sh immBox ;

::immIni | -- ; start of the frame: ids, padding, and the whole screen as zone
	uiStart 4 4 uiPad immFull ;

::immMouse | -- state ; mouse state (0-6) of the zone, the cursor box is not changed
	wix wiy wiw wih uiZoneBox uistate $f and uiBackBox ;

::immZone | -- ; the zone as interaction area (read it with uiClk uiFocus...), the cursor box is not changed
	wix wiy wiw wih uiZoneBox uiBackBox ;
