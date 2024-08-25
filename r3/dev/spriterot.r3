| sprites rotation
| PHREDA 2024
^r3/win/sdl2gfx.r3
^r3/lib/rand.r3
^r3/lib/vec2.r3
^r3/util/arr16.r3
^r3/util/pcfont.r3
^r3/util/sort.r3

#angP #posX #posY

#surimg
#teximg

#pitch
#pixels

#wss 16
#hss 16

#face 1

#vrot
#vmov
#vesq

:colorswap
	dup $ff and 16 <<
	over 16 >> $ff and or
	swap $ff00 and or ;

:getp | x y
	pitch * swap face wss * + 2 << + pixels + d@ ;

:getp2 | x y
	pitch * swap face 1+ $3 and wss * + 2 << + pixels + d@ ;
	
:setp | z x y 
	pick2 over getp2
	0? ( drop ; ) drop
	2dup getp 
	0? ( drop ; )
	colorswap sdlcolor
	pick2 1 << pick2 2 << + posx + 
	pick3 1 << pick2 2 << + posy + 
	4 4 sdlFrect
	;
	
:generateimg | imgb --
	0 ( wss <?
		0 ( wss <?
			0 ( hss <? 
				setp
				1+ ) drop
			1+ ) drop
		1+ ) drop
	drop ;
	
#p0 0 0 

#px 64 0 
#py -4 60
#pz 4 -60

:drawarrow

	;
	
:game
	$0 SDLcls

	0 0 teximg sdlimage
	$ffffff pccolor
	0 128 pcat |"<f1> mapa" pcprint
|	posx posy "%f %f " print dirX dirY "%f %f " print cr
|	xypen texs sprite

	surimg 16 + d@ "x:%d " pcprint pccr
	surimg 20 + d@ "y:%d " pcprint
	surimg 24 + @ "pitch:%d " pcprint
	0 generateimg
	
	SDLredraw
	SDLkey

	<le> =? ( -0.01 'vrot ! ) >le< =? ( 0 'vrot ! ) 
	<ri> =? ( 0.01 'vrot ! ) >ri< =? ( 0 'vrot ! )
	<up> =? ( 0.1 'vmov ! ) >up< =? ( 0 'vmov ! ) 
	<dn> =? ( -0.1 'vmov ! ) >dn< =? ( 0 'vmov ! )
	<a> =? ( 0.1 'vesq ! ) >a< =? ( 0 'vesq ! )
	<d> =? ( -0.1 'vesq ! ) >d< =? ( 0 'vesq ! )

<f1> =? ( face 1+ $3 and 'face ! )
	>esc< =? ( exit )
	drop

	;

:main
	"Sprite Rotation" 1024 600 SDLinit
	pcfont
	|32 64 
	"media/img/house25d.png" IMG_Load dup 'surimg !
	SDLrenderer over SDL_CreateTextureFromSurface 'teximg !
	surimg 24 + @ 'pitch !
	surimg 32 + @ 'pixels !
	
	sw 2/ wss 2 << - 'posx !
	sh 2/ hss 2 << - 'posy !

	'game SDLshow 
	SDLquit ;

: main ;