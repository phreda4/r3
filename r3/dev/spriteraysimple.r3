| Ray casting + sprites
| PHREDA 2024
^r3/win/sdl2gfx.r3
^r3/lib/rand.r3
^r3/lib/vec2.r3
^r3/util/arr16.r3
^r3/util/pcfont.r3
^r3/util/sort.r3

#worldMap (
  4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 7 7 7 7 7 7 7 7
  4 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 7 0 0 0 0 0 0 7
  4 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 7
  4 0 2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 7
  4 0 3 0 0 0 0 0 0 0 0 0 0 0 0 0 7 0 0 0 0 0 0 7
  4 0 4 0 0 0 0 5 5 5 5 5 5 5 5 5 7 7 0 7 7 7 7 7
  4 0 5 0 0 0 0 5 0 5 0 5 0 5 0 5 7 0 0 0 7 7 7 1
  4 0 6 0 0 0 0 5 0 0 0 0 0 0 0 5 7 0 0 0 0 0 0 8
  4 0 7 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 7 7 7 1
  4 0 8 0 0 0 0 5 0 0 0 0 0 0 0 5 7 0 0 0 0 0 0 8
  4 0 0 0 0 0 0 5 0 0 0 0 0 0 0 5 7 0 0 0 7 7 7 1
  4 0 0 0 0 0 0 5 5 5 5 0 5 5 5 5 7 7 7 7 7 7 7 1
  6 6 6 6 6 6 6 6 6 6 6 0 6 6 6 6 6 6 6 6 6 6 6 6
  8 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 4
  6 6 6 6 6 6 0 6 6 6 6 0 6 6 6 6 6 6 6 6 6 6 6 6
  4 4 4 4 4 4 0 4 4 4 6 0 6 2 2 2 2 2 2 2 3 3 3 3
  4 0 0 0 0 0 0 0 0 4 6 0 6 2 0 0 0 0 0 2 0 0 0 2
  4 0 0 0 0 0 0 0 0 0 0 0 6 2 0 0 5 0 0 2 0 0 0 2
  4 0 0 0 0 0 0 0 0 4 6 0 6 2 0 0 0 0 0 2 2 0 2 2
  4 0 6 0 6 0 0 0 0 4 6 0 0 0 0 0 5 0 0 0 0 0 0 2
  4 0 0 5 0 0 0 0 0 4 6 0 6 2 0 0 0 0 0 2 2 0 2 2
  4 0 6 0 6 0 0 0 0 4 6 0 6 2 0 0 5 0 0 2 0 0 0 2
  4 0 0 0 0 0 0 0 0 4 6 0 6 2 0 0 0 0 0 2 0 0 0 2
  4 4 4 4 4 4 4 4 4 4 1 1 1 2 2 2 2 2 2 3 3 3 3 3
)

#colores 0 $ff0000 $ff00 $ff $ffff00 $ffff $ff00ff $ffffffff $888888

#angP
#posX #posY

#dirX #dirY
#planeX #planeY

#invdet

#mm 0

|-------------- sprites
#sprimg
#spr 0 0

|-------------- raycasting

#texs
#ntex
#rayDirX #rayDirY
#sideDistX #sideDistY
#deltaDistX #deltaDistY
#perpWallDist
#stepX #stepY
#side

#yhorizon

:calcDistX
	rayDirX sign 16 << 'stepX !
	-? ( drop posX $ffff and deltaDistX *. 'sideDistX ! ; ) drop
	1.0 posX $ffff and - deltaDistX *. 'sideDistX ! ;

:calcDistY
	rayDirY sign 16 << 'stepY !
	-? ( drop posY $ffff and deltaDistY *. 'sideDistY ! ; ) drop
	1.0 posY $ffff and - deltaDistY *. 'sideDistY ! ;

:mapadr | mx my -- adr
	16 >> 24 * swap 16 >> +
	'worldMap + ;

:maphit | mx my -- hit
	mapadr c@ ;

:step | mx my -- mx' my'
	sideDistX sideDistY <? ( drop
		deltaDistX 'sideDistX +!
		swap stepX + swap 0 'side ! ;
		) drop
	deltaDistY 'sideDistY +!
	stepY + 1 'side ! ;

:dda | -- mapx mapy
	posX $ffff nand posY $ffff nand
	( 2dup maphit 0?
		drop step )
	$7 and 'ntex !
	; 

:perpWall | mapx mapy --
    side 0? ( 2drop posX - 1.0 stepX - 2/ + rayDirX 0? ( 1.0 + ) /. ; ) drop nip
	posY - 1.0 stepY - 2/ + rayDirY 0? ( 1.0 + ) /.
	;

:deltaX
	rayDirY 0? ( ; ) drop
	rayDirX 0? ( drop 1.0 ; )
	1.0 swap /. abs ;

:deltaY
	rayDirX 0? ( ; ) drop
	rayDirY 0? ( drop 1.0 ; )
	1.0 swap /. abs ;

:calcWallX
	side 0? ( drop rayDirY perpWallDist *. posY + ; ) drop
	rayDirX perpWallDist *. posX +
	;

#altura
#linea * 8192 | 800 * 8 = 6400

#srcrec [ 0 0 1 64 ]
#desrec [ 0 0 1 600 ]

:drawline | x -- x
	dup 17 << sw / 1.0 -
	dup
	planeX *. dirX + 'rayDirX !
	planeY *. dirY + 'rayDirY !
	deltaX 'deltaDistX !
	deltaY 'deltaDistY !
	calcDistX
	calcDistY
	dda | mapx mapy
	perpWall 'perpWallDist !
	sh 16 << perpWallDist 0? ( 1 + ) / 'altura !

	altura 48 <<
	side 47 << or 
	ntex 6 << calcWallX 10 >> $3f and + 12 << or
	over or | x
	'linea pick2 3 << + !
	;

:face
	altura 2 << $ff clampmax 
	side 1? ( drop 2/ ; ) drop ;
	
:shadowface
	texs face dup dup SDL_SetTextureColorMod ;

:drawlv | l --
	'desrec >a 
	dup $fff and da!+ 
	dup 48 >>
	dup 'altura !
	yhorizon over 2/ - da!+ 
	4 a+ da!
		
	dup 12 >> $ffffff and  'srcrec d! | xs
	47 >> $1 and 'side !
	shadowface
	SDLrenderer texs 'srcrec 'desrec SDL_RenderCopy
	;

|---------- struct sprite
| 1 2  3    4   5   6  7  8  9
| x y ang zoom img rad vx vy va
:.x 1 ncell+ ;
:.y 2 ncell+ ;
:.a 3 ncell+ ;
:.zoom 4 ncell+ ;
:.image 5 ncell+ ;
:.radio 6 ncell+ ;
:.vx 7 ncell+ ;
:.vy 8 ncell+ ;
:.va 9 ncell+ ;

#v2dx 0 
#v2dy 0

#sprx
#spry

#trax 
#traY
#sprSX
#sprH

#listaspr * 8000
#listaspr>

:drawsprite | a x y --
	posy - 'spry ! posx - 'sprx !
	dirY sprX *. dirX sprY *. - invdet *. 'trax !
	planeY neg sprX *. planeX sprY *. + invdet *. 'tray !

	trax tray 0? ( 1+ ) /. 1.0 + sw 2/ * 16 >> 'sprSX !
	sh 15 << traY 0? ( 1+ ) /. 16 >> -? ( 2drop ; ) 'sprH !
	
	angP - $ff00 and 24 <<
	sprH 40 << or
	sprSX $ffffffff and or
	listaspr> !+ 'listaspr> !
	;

:drawlistspr
	'listaspr ( listaspr> <? @+ 
		dup 40 >> swap 32 << 32 >> | sprh sprx
		yhorizon rot 0 sprimg sspritez
		) drop ; 

#fromlinea
:drawtolinea | altura -- 
	49 << | 2*
	fromlinea
	( @+ pick2 <? drawlv ) drop
	8 - 'fromlinea ! 
	drop ;
	
:8to24
	$ff clampmax dup 8 << or dup 8 << or ;
	
:oscurece | alt -- alt
	dup 3 << 8to24 $ff000000 or sstint ;
	
:drawmix
	'linea 'fromlinea !
	'listaspr ( listaspr> <? @+ 
		dup 40 >> | v sprh
		dup drawtolinea
		swap dup 32 << 32 >> -rot | sprx sprh v 
		yhorizon -rot 	| sprx yhor ssprh v
		swap oscurece 
		dup 11 << swap 10 << + | 11 =16-5 (32pixels) 48=32+16
		|swap 38 >> $3 and	| 4 sides ; 
		swap 37 >> $7 and | 8 sides
		sprimg sspritez 
		) drop 
	'linea 800 3 << + | ultima
	fromlinea ( over <? @+ drawlv ) 2drop
	; 
	
:pantalla
	|....... walls
	0 ( sw <? drawline 1+ ) drop 
	sw 'linea shellsort1	
	|....... sprites
	'listaspr 'listaspr> !
	'spr p.draw
	'listaspr listaspr> over - 3 >> swap shellsort1 
	|....... floor
	yhorizon ( sh <? 	
		dup 3 >> 8to24 sdlcolor
		0 over 800 2 sdlrect
		2 + ) drop
	drawmix
	;

:personamapa
	$ff00 sdlcolor
	a> .x @ 13 >> 1 -
	a> .y @ 13 >> 1 -
	3 3 sdlrect ;
	
:personaredar
	$ff00 sdlcolor
	'v2dx a> .x v2=
	'v2dx 'posx v2- | v2s=vper	
	'v2dx angP neg 0.25 + v2rot
	v2dx 12 >> 400 + 1 -
	v2dy 12 >> 100 + 1 -
	3 3 sdlrect ;

	
:persona | a -- 
	dup .a @ over .x @ pick2 .y @ drawsprite 
|	0.01 over .a +!
|	>a mm 
|	1 and? ( personamapa )
|	2 and? ( personaradar ) 
	drop	
	;
	
:+persona | a x y --
	'persona 'spr p!+ >a
	swap a!+ a!+
	a!+
	;
	
|----------- mini mapa
:drawcell | map y x --
	rot c@+ 3 << 'colores + @ sdlcolor
	-rot over 3 << over 3 << 
	8 8 sdlFRect
	;

:drawmap
	'worldMap
	0 ( 24 <?
		0 ( 24 <?
			drawcell
			1+ ) drop
		1+ ) 2drop
	$ffffff sdlcolor
	posy 13 >> posy 13 >>
	over diry 13 >> + over dirx 13 >> + 2over sdlline
	2dup swap planey 13 >> + swap planex 13 >> + sdlline
	;

:drawradar
	$232323 sdlcolor
	300 0 200 200 sdlfrect
	$ffffff sdlcolor
	399 99 2 2 sdlfrect
	300 200 400 100 sdlline
	400 100 500 200 sdlline
	;
|---------------------------------
:mover | speed --
	dirX over 2 << *. posX + posy maphit 0? ( over dirX *. 'posX +! ) drop
	posX over 2 << dirY *. posY + maphit 0? ( over dirY *. 'posY +! ) drop
	drop
	;

:esqu | speed --
	angP 0.25 - sincos pick2 *. -rot *. | cos sin
	swap over 2* posx + over 2* posy +
	maphit 1? ( 3drop ; ) drop
	'posy +! 'posx +! ;
	
:rota | ang --
	angP + dup 'angP !
	sincos
	dup 'dirY ! 0.66 *. 'planeX !
	dup 'dirX ! neg 0.66 *. 'planeY !
	1.0 planeX dirY *. dirX planeY *. - 0? ( 1.0 + ) /. 'invdet !
	;

#vrot
#vmov
#vesq

:game
	$0 SDLcls
	pantalla
	mm 
	1 and? ( drawmap ) 
	2 and? ( drawradar ) 
	drop

|	$ffffff pccolor
|	0 0 pcat "<f1> mapa" pcprint
|	posx posy "%f %f " print dirX dirY "%f %f " print cr
|	xypen texs sprite

	SDLredraw
	SDLkey
	<f1> =? ( mm 1 xor 'mm ! )
	<f2> =? ( mm 2 xor 'mm ! )

	<le> =? ( -0.01 'vrot ! )
	<ri> =? ( 0.01 'vrot ! )
	>le< =? ( 0 'vrot ! ) >ri< =? ( 0 'vrot ! )
	<up> =? ( 0.1 'vmov ! )
	<dn> =? ( -0.1 'vmov ! )
	>up< =? ( 0 'vmov ! ) >dn< =? ( 0 'vmov ! )
	
	<a> =? ( 0.1 'vesq ! ) >a< =? ( 0 'vesq ! )
	<d> =? ( -0.1 'vesq ! ) >d< =? ( 0 'vesq ! )

	>esc< =? ( exit )
	drop

	vrot 1? ( dup rota ) drop
	vmov 1? ( dup mover ) drop
	vesq 1? ( dup esqu ) drop
	;

:main
	"Laberinto" 800 600 SDLinit
	pcfont
	"media/img/wolftexturesobj.png" loadimg 'texs ! | 64x64x8
	|32 64 "media/img/test-ray.png" ssload 'sprimg !
	32 48 "media/img/blue_8direction_standing-Sheet.png" ssload 'sprimg !
	100 'spr p.ini
	
	sh 2/ 'yhorizon !
	
	5.5 'posX ! 5.5 'posY ! 0 rota
	
	0.000 4.0 3.0 +persona
	0.250 6.0 8.0 +persona
	0.125 5.5 5.0 +persona
	0.700 4.0 5.5 +persona

	'game SDLshow 
	SDLquit ;

: main ;