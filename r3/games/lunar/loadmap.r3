| test land
| PHREDA 2024
|-----
^r3/lib/rand.r3
^r3/lib/3d.r3
^r3/win/sdl2gfx.r3
^r3/win/sdl2image.r3

#prot
#px 0 #py 0 #pz 0
#vr
#vd
#vpz
#zz


|-------------------------------		
#xcam 0 #ycam 0 #zcam -100.0
#xr 0 #yr 0

:freelook
	sdlb 0? ( drop ; ) drop
	SDLx SDLy
	sh 1 >> - 7 << swap
	sw 1 >> - neg 7 << swap
	neg 'xr ! 'yr ! ;

|---------------------------------	
#xop #yop
:xxop 'yop ! 'xop ! ;
:xxline 2dup xop yop SDLLine 'yop ! 'xop ! ;

:3dop project3d xxop ;
:3dline project3d xxline ;

:drawboxz | z --
	-1.0 -1.0 pick2 3dop
	1.0 -1.0 pick2 3dline
	1.0 1.0 pick2 3dline
	-1.0 1.0 pick2 3dline
	-1.0 -1.0 rot 3dline ;

:drawlinez | x1 x2 --
	2dup -1.0 3dop 1.0 3dline ;

:drawcube |
	-1.0 drawboxz
	1.0 drawboxz
	-1.0 -1.0 drawlinez
	1.0 -1.0 drawlinez
	1.0 1.0 drawlinez
	-1.0 1.0 drawlinez ;	
	
	
:packscale | x y z -- s
	rot 8 >> rot 8 >> rot 8 >> pack21 ;

:unpackscale | s -- x y z 
	dup 42 >> $1fffff and 8 <<
	over 21 >> $1fffff and 8 <<
	rot $1fffff and 8 << ;

:unpackrot
	dup 32 >> $ffff and mrotxi 
	dup 16 >> $ffff and mrotyi 
	$ffff and mrotzi ;
	
:jugador
	mpush
	px py pz mtransi
	prot unpackrot
	drawcube
	mpop
	;
	
|-------------------------------	
#imgm | 1024*1024 *3
#imgmp
#imgn | 1024*1024 *3
#imgnp

:imgm@ | x y -- altura
	10 << + dup 1 << + imgmp + c@ $ff and ;

:imgn@ | x y -- rrggbb
	10 << + dup 1 << + imgnp + d@ ;
	
##supx1 ##supx2
##supy1 ##supy2
##supx3 ##supx4
##supy3 ##supy4

	
|
|      1 -------- 2
|       \        /
|        \      /
|         3----4
|
#ax #ay #dax #day
#bx #by #dbx #dby
#cx #cy #dcx #dcy

#indice	
#vertex

:altura2 | x y -- z
	swap 
|	msec 6 << + 
	0.01 *. sin 2.0 *. 
	swap 
|	msec 7 << +
	0.05 *. cos 3.0 *. 
	+ 3.0 -
	;

	
	
::genfloordyn
	supx3 6 << 'ax ! supy3 6 << 'ay ! supx1 supx3 - 'dax ! supy1 supy3 - 'day !
	supx4 6 << 'bx ! supy4 6 << 'by ! supx2 supx4 - 'dbx ! supy2 supy4 - 'dby !
	mark
	here 'vertex !
	0 ( 64 <?
		ax 'cx ! bx ax - 6 >> 'dcx !
		ay 'cy ! by ay - 6 >> 'dcy !
		0 ( 64 <?
			cx 6 >> dup |f2fp 
			,
			cy 6 >> dup |f2fp 
			,
			2dup altura2 |f2fp 
			, | x y z
			4 >> $3ff and swap 4 >> $3ff and swap 
			imgm@ 2.0 * ,
			dcx 'cx +! dcy 'cy +!			
			1 + ) drop
		dax 'ax +! day 'ay +!
		dbx 'bx +! dby 'by +!
		dax 1.1 *. 'dax ! day 1.1 *. 'day !
		dbx 1.1 *. 'dbx ! dby 1.1 *. 'dby !
		1 + ) drop
	empty
	;
	
:getvertex | nro --
	4 << vertex + d@+ swap d@+ swap d@+
	swap d@ sdlcolor
	project3d ;
	
:look | dist ang -- x y
	sincos pick2 *. px + | dist sin x
	rot rot *. py + ;
	
:superficie
	400.0 prot 0.1 - look 'supy1 ! 'supx1 !
	400.0 prot 0.1 + look 'supy2 ! 'supx2 !
	-10.0 prot 0.1 + look 'supy3 ! 'supx3 !
	-10.0 prot 0.1 - look 'supy4 ! 'supx4 !
	
	genfloordyn
	
	mpush
	indice
	0 ( 10 <? swap
		over 1 << $7f0000 or sdlcolor
		w@+ getvertex xxop
		w@+ getvertex xxline
		0 ( 63 <? swap
			w@+ getvertex xxline
			w@+ getvertex xxline
			swap 1 + ) drop	
		 swap 1 + ) 2drop
	mpop
	;
	
|-------------------------------	

:getpixel |(SDL_Surface *surface, int x, int y)
|	int bpp = surface->format->BytesPerPixel;
|	Uint8 *p = (Uint8 *)surface->pixels + y * surface->pitch + x * bpp;
|switch (bpp) {
|    case 1: return *p;break;
|    case 2: return *(Uint16 *)p;break;
|    case 3: return *(Uint32 *)p;break;
|return *(Uint32 *)p;
|
	;	
	
#pitch	
:4Bpp | x y -- x y col
	2dup pitch * swap 2 << + pick3 + d@ ;

:3Bpp | x y -- x y col
	2dup pitch * swap dup 1 << + + pick3 + d@ $ffffff and ;
	
:1Bpp
	2dup pitch * + pick3 + c@ ;


:testimg	
	imgm
	|dup 8 + @ 17 + c@ "Bpp:%d " .print
	dup 24 + d@ 'pitch !
	32 + @ 
	pitch "pitch:%d " .print
|	dup "mem: %h" .println
	400 ( 500 <?
		400 ( 500 <?
			|4Bpp sdlcolor
			3Bpp sdlcolor
			|1Bpp $ff and sdlcolor
			2dup SDLPoint
			1 + ) drop
		1 + ) 2drop ;
	
|-------------------------------	
:juego
	0 sdlcls
	$ff00 sdlcolor
	|freelook
	
	1.0 3dmode
	|xr mrotx yr mroty 
	xcam ycam zcam mtrans
	
	$ff00 SDlcolor
	jugador
	$f0f0f0 SDlcolor
	superficie
	
|	testimg
	
	SDLredraw
	SDLkey
	>esc< =? ( exit )
	<up> =? ( 0.3 'vd ! ) >up< =? ( 0 'vd ! )
	<dn> =? ( -0.3 'vd ! ) >dn< =? ( 0 'vd ! )
	<le> =? ( 0.01 'vr ! ) >le< =? ( 0 'vr ! )
	<ri> =? ( -0.01 'vr ! ) >ri< =? ( 0 'vr ! )
	<esp> =? ( vpz 0? ( 0.4 'vpz ! ) drop )
	<w> =? ( 0.1 'zz +! )
	<s> =? ( -0.1 'zz +! )
	drop

	prot sincos vd *. 'px +! vd *. 'py +!
	vr 'prot +!
	pz vpz +
	0 <=? ( drop 0 'pz ! 0 'vpz ! ; )
	'pz !
	-0.005 'vpz +!		
	;	

|-------------------------------------
:main
	"3d world" 1024 600 SDLinit
	
	"r3/games/lunar/img/HeightMap.png" IMG_Load 'imgm !
	imgm 32 + @ 'imgmp !
	"r3/games/lunar/img/NormalMap.png" IMG_Load 'imgn !
	imgn 32 + @ 'imgnp !
 		
	mark
	here 'indice !
	0 ( 64 <? 
		0 ( 64 <? 
			over 6 << over + ,w
			over 1 + 6 << over + ,w
			1 + ) drop
		1 + ) drop
		
	'juego SDLShow 
	SDLquit ;	
	
: main ;