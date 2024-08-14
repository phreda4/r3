| RAYCASTING
| From Lode's Computer Graphics Tutorial
| https://lodev.org/cgtutor/raycasting.html
| PHREDA 2020 (r3d4) translate to r3
^r3/win/sdl2gfx.r3
^r3/util/pcfont.r3

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

#posX #posY
#dirX #dirY
#planeX #planeY

#texs
#ntex

#rayDirX
#rayDirY
#sideDistX
#sideDistY
#deltaDistX
#deltaDistY
#perpWallDist
#stepX
#stepY
#side

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
	posX $ffff not and posY $ffff not and
	( 2dup maphit 0?
		drop step )
	$7 and 'ntex !
|	8 << texs + 'texn !
|	2 << 'colores + @ 'ink !
|	drop
	;

:perpWall | mapx mapy --
    side 0? ( 2drop posX - 1.0 stepX - 1 >> + rayDirX 0? ( 1.0 + ) /. ; ) drop nip
	posY - 1.0 stepY - 1 >> + rayDirY 0? ( 1.0 + ) /.
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

#y1
#altura

#srcrec [ 0 0 1 64 ]
#desrec [ 0 0 1 600 ]

:face
	side 1? ( drop $7f $7f $7f ; ) drop 
	$ff $ff $ff ;
	
:shadowface
	texs face SDL_SetTextureColorMod ;
	
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
	sh 16 << perpWallDist
	0? ( 1 + ) / 'altura !

	sh 1 >> altura 1 >> - 'y1 !

	'desrec >a
	dup da!+ | xd
	y1 da!+ 4 a+ altura da!
	
	ntex 6 << 
	calcWallX 10 >> $3f and 	
	+ 'srcrec d! | xs
	
	shadowface
	
	SDLrenderer texs 'srcrec 'desrec SDL_RenderCopy
	;

 :render
	0 ( sw <? 
		drawline
		1 + ) drop ;

|---------------------------------
:drawcell | map y x --
	rot c@+ 3 << 'colores + @ sdlcolor
	rot rot
	over 4 << over 4 << swap
	15 15 sdlFRect
	;

:drawmap
	'worldMap
	0 ( 24 <?
		0 ( 24 <?
			drawcell
			1 + ) drop
		1 + ) 2drop
	$ffffff sdlcolor
	posX 12 >> posY 12 >>
	over dirX 12 >> + over dirY 12 >> + 2over sdlline
	2dup swap planeX 12 >> + swap planeY 12 >> + sdlline
	;

|---------------------------------
:mover | speed --
	dirX over *. posX + posy maphit 0? ( over dirX *. 'posX +! ) drop
	posX over dirY *. posY + maphit 0? ( over dirY *. 'posY +! ) drop
	drop
	;

#angr

:rota
	angr + dup 'angr !
	1.0 polar | bangle largo -- dx dy
	2dup 'dirY ! 'dirX !
	0.66 *. 'planeX !
	neg 0.66 *. 'planeY !
	;

#vrot
#vmov
#mm

:game
	$0 SDLcls
	render
	mm 1? ( drawmap ) drop

	$ffffff pccolor
	0 0 pcat
	"<f1> mapa" pcprint
|	posx posy "%f %f " print dirX dirY "%f %f " print cr
|	xypen texs sprite

	SDLredraw
	SDLkey
	<f1> =? ( mm 1 xor 'mm ! )

	<le> =? ( -0.01 'vrot ! )
	<ri> =? ( 0.01 'vrot ! )
	>le< =? ( 0 'vrot ! ) >ri< =? ( 0 'vrot ! )
	<up> =? ( 0.1 'vmov ! )
	<dn> =? ( -0.1 'vmov ! )
	>up< =? ( 0 'vmov ! ) >dn< =? ( 0 'vmov ! )
	>esc< =? ( exit )
	drop

	vrot 1? ( dup rota ) drop
	vmov 1? ( dup mover ) drop
	;

:main
	"Raycaster" 800 600 SDLinit
	
	
	"media/img/wolftexturesobj.png" loadimg 'texs ! | 64x64x8

	5.5 'posX ! 5.5 'posY ! 0 rota
	'game SDLshow 
	SDLquit ;

: main ;