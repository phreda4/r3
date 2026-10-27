| playcull -- igual que playper, pero con culling de camara
| PHREDA 2026
|
| La lista de instancias de ss3d se rehace en cada frame:
|  - todos los objetos viven en una lista maestra (estaticos y moviles)
|  - se actualizan los moviles
|  - se descartan los que quedan fuera del frustum de la camara
|    (esfera englobante) o mas lejos que 'drawdist'
|  - los visibles se escriben en las instancias 1..n (la 0 es el jugador)
|    y ss3dlen! indica cuantas se dibujan
|
|  flechas: mover   espacio: saltar
|  F1: +1 objeto movil   F2: +50   F3: culling si/no   F4: distancia de dibujo
|-----
^r3/lib/rand.r3

^./renderlib.r3
^./rlhud.r3
^./ss3d.r3
^./glimm.r3
^./rlgrid.r3

|---------------------------------
:WORLD  120.0 ;		| los estaticos se reparten en +-WORLD (x z)
:LIM     40.0 ;		| los moviles rebotan en +-LIM (x z)
:OBJMAX  60000 ;		| objetos en la lista maestra

#objcnt 0
#objlst 0
#nvis 0				| instancias escritas este frame (incluye al jugador)
#cullon 1			| 1 = culling activo
#drawdist 90.0		| distancia maxima de dibujo (en z de camara)

| registro de objeto: 16 celdas de 8 bytes (128 bytes)
|  0 x  1 y  2 z  3 q  4 scale  5 spr  6 color  7 radio    <- orden de ss3dset
|  8 vx 9 vy 10 vz 11 movil(1/0) 12 angulo
:]obj | n -- adr
	7 << objlst + ;

|---------------------------------
|--- crear objetos
#nsc #nsp

| radio de la esfera que envuelve la caja del sprite (16.16)
:objrad | scale spr -- r
	>r
	r@ ss3dLX dup *
	r@ ss3dLY dup * +
	r> ss3dLZ dup * +
	32 << sqrt		| sqrt(suma)<<16 = raiz en 16.16
	*. 0.005 *. ;

:+static
	objcnt OBJMAX >=? ( drop ; ) drop
	8.0 16.0 randminmax 'nsc !
	23 32 randminmax 'nsp !
	objcnt ]obj >a
	WORLD neg WORLD randminmax a!+			| x
	nsc nsp ss3dfloor a!+					| y (apoyado en el piso)
	WORLD neg WORLD randminmax a!+			| z
	$ffff randmax 16 << rxyz>q16 a!+		| q (giro en y)
	nsc a!+ nsp a!+
	$ffffff00 a!+							| color
	nsc nsp objrad a!+						| radio
	0 a!+ 0 a!+ 0 a!+						| vx vy vz
	0 a!+ 0 a!+								| estatico, angulo
	1 'objcnt +! ;

:+obj
	objcnt OBJMAX >=? ( drop ; ) drop
	1.0 4.0 randminmax 'nsc !
	n3dsprites randmax 'nsp !
	objcnt ]obj >a
	-30.0 30.0 randminmax a!+				| x
	1.0 8.0 randminmax a!+					| y
	-30.0 30.0 randminmax a!+				| z
	0 a!+									| q (se calcula con el angulo)
	nsc a!+ nsp a!+
	$ffffff00 $ff randmax $fc and or a!+	| color (sin glow)
	nsc nsp objrad a!+						| radio
	-0.1 0.1 randminmax a!+					| vx
	0 a!+									| vy
	-0.1 0.1 randminmax a!+					| vz
	1 a!+									| movil
	$ffff randmax a!+						| angulo
	1 'objcnt +! ;

|---------------------------------
|--- mover los objetos moviles
#pp #vv

| avanza en x o z y rebota en +-LIM
:movax | 'pos 'vel --
	over @ over @ +
	dup abs LIM >? ( 2drop dup @ neg swap ! drop ; )
	drop pick2 ! 2drop ;

| avanza en y con gravedad y rebota en el piso
:movay | 'pos 'vel --
	'vv ! 'pp !
	pp @ vv @ +
	0.5 <? ( drop vv @ abs vv ! pp @ )
	pp !
	-0.001 vv +! ;

:upobj | adr -- adr
	dup 88 + @ 0? ( drop ; ) drop
	dup dup 64 + movax
	dup 8 + over 72 + movay
	dup 16 + over 80 + movax
	dup 96 + dup @ 300 + $ffff and dup rot !
	16 << rxyz>q16 over 24 + ! ;

|---------------------------------
|--- jugador y camara
#vd #vr #vpz
#pxp #pyp #pzp
#prot

#camEye -4.0 1.0 0.0
#camTo  0.0 0.0  0.0
#camUp  0.0 1.0  0.0

#camEyeD 0 0 0
#camDist 4.0
#camRot

#cF 0 0 0		| adelante
#cR 0 0 0		| derecha
#cU 0 0 0		| arriba

| base de la camara y pendientes del frustum
:camvec
	'cF 'camTo v3= 'cF 'camEye v3-
	'cF v3nor
	'cR 'cF v3= 'cR 'camUp v3vec
	'cR v3nor
	'cU 'cR v3= 'cU 'cF v3vec
	;

:camera
	pyp pzp 1.5 + pxp 'camTo !+ !+ !

	prot 0.5 + neg camrot - 0.02 *. 'camrot +!

	'camEyeD >a
	camrot sincos
	camDist *. pxp + a!+
	3.0 a!+
	camDist *. pyp + a!+

	'camEye >a 'camEyeD >b
	a@ b@+ over - 0.05 *. + a!+
	a@ b@+ over - 0.05 *. + a!+
	a@ b@+ over - 0.05 *. + a!+

	'camEye 'camTo 'camUp rl_camera | 'eye 'to 'up --
	camvec
	;

|---------------------------------
|--- culling
#rx #ry #rz			| objeto - camara
#zz #rr

:rel | adr -- adr
	dup @ camEye - 'rx !
	dup 8 + @ 'camEye 8 + @ - 'ry !
	dup 16 + @ 'camEye 16 + @ - 'rz ! ;

:dotc | 'v -- d	; (rx,ry,rz) . v
	>a a@+ rx *. a@+ ry *. + a@ rz *. + ;

| esfera contra frustum: near, distancia y los 4 planos laterales
:objvis? | adr -- adr flag
	rel
	dup 56 + @ 'rr !
	'cF dotc 'zz !
	zz rr + camNear <? ( drop 0 ; ) drop
	zz rr - drawdist >? ( drop 0 ; ) drop
	'cR dotc abs | xx
	zz tanH *. rr secH *. + >? ( drop 0 ; ) drop
	'cU dotc abs | yy
	zz tanV *. rr secV *. + >? ( drop 0 ; ) drop
	1 ;

:vis? | adr -- adr flag
	cullon 0? ( drop 1 ; ) drop
	objvis? ;

| escribe el objeto en la siguiente instancia libre
:drawobj | adr --
	>b b@+ b@+ b@+ b@+ b@+ b@+ b@+ nvis ss3dset ;

:addvis | adr --
	vis? 0? ( 2drop ; ) drop
	nvis ss3dmax <? ( drop drawobj 1 'nvis +! ; ) 2drop ;

| rehace la lista de instancias: jugador (0) + objetos visibles
:cullobjs
	1 'nvis !
	0 ( objcnt <?
		dup ]obj upobj addvis
		1+ ) drop
	nvis ss3dlen! ;

|---------------------------------
|----- player
#walk ( 16 17 16 18 )

:jugador
	pxp pzp 0.5 + pyp

	prot 0.25 + 2/
	$ffff and 16 << rxyz>q16

	5.0
	msec 8 >> $3 and 'walk + c@
	$ffffff00
	0 ss3dset

	1.4
	1.0 1.0 1.0
	pxp pzp 2.0 + pyp 1.0 +
	rl_point_light | int cr cg cb x y z --

	camera

	|--- update
	prot neg sincos
	vd *. 'pxp +!
	vd *. 'pyp +!
	vr prot + 'prot !

	pzp vpz +
	0 <=? ( drop 0 'pzp ! 0 'vpz ! ; )
	'pzp !
	-0.005 'vpz +!
	;

|-------------------------------
#ddi 2
#ddl 30.0 60.0 90.0 150.0 400.0

:nextdd
	ddi 1+ 5 mod 'ddi !
	ddi 3 << 'ddl + @ 'drawdist ! ;

:hud
	fini
	2 'fscale !
	$ffffffff 'fcolor !
	16 16 fat
	objcnt nvis 1 - "visibles:%d  total:%d" sprint ftext
	16 48 fat
	cullon drawdist 16 >> "dist:%d  cull:%d" sprint ftext
	fend ;

:juego
	rl_frame_begin

	draw_grid

	jugador
	cullobjs
	SS3Ddraw

	rl_frame_end

	hud

	GLUpdate

	SDLkey
	>esc< =? ( exit )
	<f1> =? ( +obj )
	<f2> =? ( 50 ( 1? 1- +obj ) drop )
	<f3> =? ( 1 cullon - 'cullon ! )
	<f4> =? ( nextdd )

	<up> =? ( 0.1 'vd ! ) >up< =? ( 0 'vd ! )
	<dn> =? ( -0.1 'vd ! ) >dn< =? ( 0 'vd ! )
	<le> =? ( 0.01 'vr ! ) >le< =? ( 0 'vr ! )
	<ri> =? ( -0.01 'vr ! ) >ri< =? ( 0 'vr ! )
	<spc> =? ( vpz 0? ( 0.18 'vpz ! ) drop )

	drop
	;

:jugar
	ss3dreset
	0 'objcnt !
	3000 ( 1? 1- +static ) drop
	200 ( 1? 1- +obj ) drop
	'juego SDLShow
	;

|-------------------------------------
:viewresize
	sh sw rl_resizewin
	fixFontResize ;

#fsun [
-0.5 8.0 -0.5 0
 1.0 1.0 1.0 2.0
 ]

:lightsun
	8 'fsun memfloat
	'fsun rl_set_sun
	;

:load3d
	"media/ss/iti"
|	"media/ss/vox2"
|	"media/ss/sprites"
	dup 4096 ss3dload
	ss3loadnames
	;

|-------------------------------------
: | <<<<<<<< Boot
	"play cull" 1024 768 GLini GLInfo

	rlhud
	load3d
	rl_init
	1 rl_grid_init
	'viewresize SDLeventR
	lightsun

	here 'objlst !
	OBJMAX 7 << 'here +!

	jugar

	rl_grid_free
	rl_shutdown
	SS3Dshutdown
	GLend
	;
