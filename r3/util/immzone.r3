| immzone: mouse state of a zone, without widgets (camera control and the like)
| PHREDA 2026
|
| immIni at the start of the frame, then immMouse gives the state of the zone
| (the whole screen, or the one set with immBox):
| 0 none, 1 over, 2 in (button down), 3 active, 4 active (outside), 5 out, 6 click
| For widgets use immi.r3 / glimm.r3 (immcore.r3), which have the same words.
|
^r3/lib/sdl2.r3

#id #idh #ida
##wix ##wiy ##wiw ##wih

::immBox | x y w h -- ; zone of immMouse
	'wih ! 'wiw ! 'wiy ! 'wix ! ;

::immFull | -- ; the zone is the whole screen
	0 0 sw sh immBox ;

::immIni | -- ; start of the frame, the zone is the whole screen
	immFull
	idh 'ida ! -1 'id ! ;

:immIn? | -- 0/-1
	sdlx wix - $ffff and wiw >? ( drop 0 ; ) drop
	sdly wiy - $ffff and wih >? ( drop 0 ; ) drop
	-1 ;

::immMouse | -- state
	1 'id +!
	ida -? ( drop 			| no active
		immIn? 0? ( ; ) drop		| out->0
		sdlb 0? ( drop 1 ; ) drop	| over->1
		id dup 'idh ! drop 2 ; )	| in->2(prev)
	id <>? ( drop 0 ; )		| active no this->0
	drop
	immIn? 0? ( drop
		sdlb 1? ( drop 4 ; ) drop	| active out->4
		-1 'idh ! 5 ; ) drop		| out up->5
	sdlb 1? ( drop 3 ; ) drop 		| active->3
	-1 'idh ! 6 ; 			| click->6
