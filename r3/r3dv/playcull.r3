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
|  F5: ocultar los objetos que tapan al jugador (entre la camara y el jugador) si/no
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
#occon 1			| 1 = no dibuja lo que tapa al jugador
#drawdist 90.0		| distancia maxima de dibujo (en z de camara)

| registro de objeto: 16 celdas de 8 bytes (128 bytes)
|  0 x  1 y  2 z  3 q  4 scale  5 spr  6 color  7 radio    <- orden de ss3dset
|  8 vx 9 vy 10 vz 11 movil(1/0) 12 angulo
:]obj | n -- adr
	7 << objlst + ;

|---------------------------------
|--- crear objetos
| radio de la esfera que envuelve la caja del sprite (16.16)
:objrad | scale spr -- r
	>b
	b> ss3dLX dup *
	b> ss3dLY dup * +
	b> ss3dLZ dup * +
	32 << sqrt		| sqrt(suma)<<16 = raiz en 16.16
	*. 0.005 *. ;

:+static
	objcnt OBJMAX >=? ( drop ; ) drop
	8.0 16.0 randminmax 23 32 randminmax	| scale spr
	objcnt ]obj >a
	WORLD neg WORLD randminmax a!+			| x
	2dup ss3dfloor a!+						| y (apoyado en el piso)
	WORLD neg WORLD randminmax a!+			| z
	$ffff randmax 16 << rxyz>q16 a!+		| q (giro en y)
	over a!+ dup a!+						| scale spr
	$ffffff00 a!+							| color
	objrad a!+								| radio
	0 a!+ 0 a!+ 0 a!+						| vx vy vz
	0 a!+ 0 a!+								| estatico, angulo
	1 'objcnt +! ;

:+obj
	objcnt OBJMAX >=? ( drop ; ) drop
	1.0 4.0 randminmax n3dsprites randmax	| scale spr
	objcnt ]obj >a
	-30.0 30.0 randminmax a!+				| x
	1.0 8.0 randminmax a!+					| y
	-30.0 30.0 randminmax a!+				| z
	0 a!+									| q (se calcula con el angulo)
	over a!+ dup a!+						| scale spr
	$ffffff00 $ff randmax $fc and or a!+	| color (sin glow)
	objrad a!+								| radio
	-0.1 0.1 randminmax a!+					| vx
	0 a!+									| vy
	-0.1 0.1 randminmax a!+					| vz
	1 a!+									| movil
	$ffff randmax a!+						| angulo
	1 'objcnt +! ;

|---------------------------------
|--- mover los objetos moviles
| avanza en x o z y rebota en +-LIM
:movax | 'pos 'vel --
	>b >a
	a@ b@ +
	dup abs LIM >? ( 2drop b@ neg b! ; )
	drop a! ;

| avanza en y con gravedad y rebota en el piso
:movay | 'pos 'vel --
	>b >a
	a@ b@ +
	0.5 <? ( drop b@ abs b! a@ )
	a!
	-0.001 b@ + b! ;

:upobj | adr -- adr
	dup 88 + @ 0? ( drop ; ) drop
	dup dup 64 + movax
	dup 8 + over 72 + movay
	dup 16 + over 80 + movax
	dup 96 + >a
	a@ 300 + $ffff and dup a!			| angulo += 300
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
#tanV #tanH #secV #secH

| base de la camara y pendientes del frustum
:camvec
	'cF 'camTo v3= 'cF 'camEye v3-
	'cF v3nor
	'cR 'cF v3= 'cR 'camUp v3vec
	'cR v3nor
	'cU 'cR v3= 'cU 'cF v3vec
	camFov 'tanV !
	camFov rl_w rl_h 16 <</ *. 'tanH !
	1.0 tanV dup *. + sqrt. 'secV !
	1.0 tanH dup *. + sqrt. 'secH ! ;

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
#rel 0 0 0			| objeto - camara
#zz #rr

| esfera contra frustum: near, distancia y los 4 planos laterales
:objvis? | adr -- adr flag
	zz rr + camNear <? ( drop 0 ; ) drop
	zz rr - drawdist >? ( drop 0 ; ) drop
	'cR 'rel v3ddot abs | xx
	zz tanH *. rr secH *. + >? ( drop 0 ; ) drop
	'cU 'rel v3ddot abs | yy
	zz tanV *. rr secV *. + >? ( drop 0 ; ) drop
	1 ;

|--- oclusion: objetos entre la camara y el jugador
| fase ancha: esfera contra segmento camara -> centro del jugador
| fase fina:  caja orientada del objeto (ss3dhit), ya escrito en la instancia nvis
:OCCM 0.6 ;				| margen junto al jugador que no se oculta
#occd 0 0 0				| jugador - camara
#ocF 0 0 0				| idem, normalizado
#occlen					| largo del segmento
#occt					| parametro (0..1) hasta donde un impacto oculta
#occc					| 1 = la esfera del objeto actual corta el segmento

:occsetup
	'occd >a pxp a!+ pzp 0.5 + a!+ pyp a!
	'occd 'camEye v3-
	'ocF 'occd v3= 'ocF v3nor
	'occd v3len 1 max 'occlen !
	1.0 OCCM occlen /. - 'occt ! ;

:occl? | -- flag
	'ocF 'rel v3ddot				| z sobre el segmento
	dup rr + 0 <=? ( 2drop 0 ; ) drop		| el objeto queda detras de la camara
	dup rr - occlen >=? ( 2drop 0 ; ) drop	| pasado el jugador
	dup *.							| z^2
	'rel dup v3ddot swap -			| distancia^2 al segmento
	rr dup *.
	<? ( drop 1 ; ) drop 0 ;

:vis? | adr -- adr flag
	0 'occc !
	cullon occon or 0? ( drop 1 ; ) drop
	'rel over v3= 'rel 'camEye v3-
	dup 56 + @ 'rr !
	occon 1? ( occl? 'occc ! ) drop
	cullon 0? ( drop 1 ; ) drop
	'cF 'rel v3ddot 'zz !
	objvis? ;

| escribe el objeto en la siguiente instancia libre
:drawobj | adr --
	>b b@+ b@+ b@+ b@+ b@+ b@+ b@+ nvis ss3dset ;

| la caja de la instancia nvis (recien escrita) corta el segmento antes del margen
:occ? | -- flag
	occc 0? ( ; ) drop
	'camEye 'occd nvis ss3dhit
	0 >=? ( occt <? ( drop 1 ; ) ) drop 0 ;

:addvis | adr --
	vis? 0? ( 2drop ; ) drop
	nvis ss3dmax <? ( drop drawobj occ? 0? ( 1 'nvis +! ) drop ; ) 2drop ;

| rehace la lista de instancias: jugador (0) + objetos visibles
:cullobjs
	1 'nvis !
	occsetup
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
	16 80 fat
	occon "tapan:%d" sprint ftext
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
	<f5> =? ( 1 occon - 'occon ! )

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
