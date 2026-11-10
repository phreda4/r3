| Supercubo 4x4x4 de sprites ss3d dinamicos (voxeles editables por programa)
| PHREDA 2026
|
| 64 objetos de nv x nv x nv voxeles, cada uno con SU tira de colores completa
| (sin optimizar): columna (x,z) = mascara de ocupacion (bit = capa) + base en la tira
| La copia en CPU (dcols/dpal) se modifica con vocc! y vcol!, y se sube con ss3dupcols/ss3duppal
|
| mouse: arrastrar = rotar, rueda = zoom | W S A D Q E = mover camara
| flechas / PgUp PgDn = cursor de voxel | ESPACIO = alternar voxel | ENTER = pintar
| 1..8 = color | F1 = sombras | F2 = SSAO

^r3/lib/rand.r3
^r3/lib/mem.r3

^r3/util/varanim.r3
^r3/util/glgfx.r3
^r3/util/glimm.r3

^./renderlib.r3
^./ss3d.r3
^./ss3dshadow.r3
^./rlgrid.r3

| Camera controls
#cam_yaw  0
#cam_pit  0
#camEye -4.5 4.2 0.0
#camTo  0.0 0.0  0.0
#camUp  0.0 1.0  0.0
#camAdv 0 0 0 | forward
#camLat 0 0 0 | right
#camVU  0 0 0 | up de la camara
#lift 3.0 | altura de los objetos sobre el plano (y=0)

#cp #sp #cy #sy
#va #vl #vu

:makecam
	cam_yaw sincos 'cy ! 'sy !
	cam_pit -0.24 max 0.24 min
	sincos 'cp ! 'sp !
	'camTo >a 'camEye >b
	b@+ cy cp *. + a!+
	b@+ sp + a!+
	b@+ sy cp *. + a!
	'camAdv >a
	cy neg cp *. a!+
	sp neg a!+
	sy neg cp *. a!
	'camAdv v3Nor
	'camLat >a
	sy a!+
	0 a!+
	cy neg a!+
	'camLat v3Nor
	'camVU >a
	cy sp *. neg a!+
	cp a!+
	sy sp *. neg a!
	'camEye 'camTo 'camUp rl_camera | 'eye 'to 'up --
	;

#xp #yp
:movecam
	sdlx dup xp - 0.001 *
	'cam_yaw +! 'xp !
	sdly dup yp - -0.001 *
	cam_pit + 'cam_pit ! 'yp !
	makecam ;

:wheelcam
	SDLw 0? ( drop ; ) -0.4 *
	'camEye 'camAdv pick2 v3+*
	'camTo 'camAdv pick2 v3+*
	drop ;

:keycam
	va 1? ( 'camEye 'camAdv pick2 v3+* 'camTo 'camAdv pick2 v3+* ) drop
	vl 1? ( 'camEye 'camLat pick2 v3+* 'camTo 'camLat pick2 v3+* ) drop
	vu 1? ( 'camEye 'camUp  pick2 v3+* 'camTo 'camUp  pick2 v3+* ) drop ;

:totop
	'cam_yaw 0 cam_yaw 21 1.0 0 +vanim
	'cam_pit -0.25 cam_pit 21 1.0 0 +vanim
	'camEye >a
	a> 0.0 a@+ 21 1.0 0 +vanim
	a> lift 7.0 + a@+ 21 1.0 0 +vanim
	a> 0.0 a@+ 21 1.0 0 +vanim ;

:tofront
	'cam_yaw 0 cam_yaw 21 1.0 0 +vanim
	'cam_pit 0 cam_pit 21 1.0 0 +vanim
	'camEye >a
	a> -4.5 a@+ 21 1.0 0 +vanim
	a> lift 1.2 + a@+ 21 1.0 0 +vanim
	a> 0.0 a@+ 21 1.0 0 +vanim ;

:toside
	'cam_yaw -0.25 cam_yaw 21 1.0 0 +vanim
	'cam_pit 0 cam_pit 21 1.0 0 +vanim
	'camEye >a
	a> 0.0 a@+ 21 1.0 0 +vanim
	a> lift 1.2 + a@+ 21 1.0 0 +vanim
	a> 4.5 a@+ 21 1.0 0 +vanim ;

|----------------------------------
| luces: sol con sombra (ss3dshadow) + luz puntual en la camara
#sun_az 0.625
#sun_el 0.237
#shadowon 1

:setsun
	sun_el 0.01 max 0.25 min 'sun_el !
	sun_el cos sun_az cos *.	| dx (direccion HACIA el sol)
	sun_el sin					| dy
	sun_el cos sun_az sin *.	| dz
	1.0 1.0 1.0 1.0 ss3dsun ;

:light
	0.2
	1.0 1.0 1.0
	'camEye >a
	a@+ a@+ 1.0 + a@
	rl_point_light | int cr cg cb x y z --
	;

|----------------------------------
| VOXELES
| objeto o = oz*16 + oy*4 + ox (0..63), cada uno nv x nv x nv voxeles
| coordenadas globales del supercubo: 0..ng-1 (ng = 4*nv)
| y crece hacia arriba (capa de la tira = nv-1-y: la capa 0 es la de arriba)
#nv 8				| voxeles por lado de cada objeto (max 32: mascara de 32 bits)
:ng nv 2 << ;
:ncolsn 64 nv * nv * 1+ ;			| columnas (+1: sprite del cursor)
:npaln  64 nv * nv * nv * 1+ ;		| colores (+1: sprite del cursor)
:colsbytes ncolsn 3 << ;
:palbytes npaln 2 << ;

#dcols #dpal #img		| copias en CPU
#dirty 1

#vo #vx #vy #vz			| voxel de trabajo: objeto y coordenadas locales
#ox #oy #oz				| posicion del objeto en el supercubo (0..3)
#gx #gy #gz				| coordenada global de trabajo

:setvox | -- ; gx gy gz -> vo vx vy vz
	gx nv /mod 'vx ! 'ox !
	gy nv /mod 'vy ! 'oy !
	gz nv /mod 'vz ! 'oz !
	oz 4 * oy + 4 * ox + 'vo ! ;

:vcolidx | -- ci		; indice de columna global
	vo nv * nv * vz nv * + vx + ;
:vlayer nv 1- vy - ;
:vbit 1 vlayer << ;
:vmaskadr vcolidx 3 << dcols + ;
:vpaladr  vcolidx nv * vlayer + 2 << dpal + ;

:vget | -- 0/bit		; ocupacion del voxel
	vmaskadr d@ vbit and ;

:vocc! | 0/1 --			; bit de ocupacion
	vmaskadr dup d@				| on adr mask
	rot 1? ( drop vbit or swap d! ; ) drop
	vbit nand swap d! ;

:vcol! | color --		; color $RRGGBBuma del voxel
	vpaladr d! ;

|--- paleta
#pal8 $e0303000 $f0902000 $f0e03000 $30d05000 $30d0d000 $3060f000 $a040e000 $f0f0f000
#cnames "rojo" "naranja" "amarillo" "verde" "cian" "azul" "violeta" "blanco"
#ccolid 0

:palc | n -- color
	3 << 'pal8 + @ ;
:ccol ccolid palc ;
:cname | n -- adr
	'cnames swap ( 1? 1- swap >>0 trim swap ) drop ;

|--- memoria e imagen .ssv (nv^3 voxeles x 64 objetos + 1 sprite de cursor de 1 voxel)
:initcols | mask=0, base = columna*nv (tira completa por columna)
	dcols >a
	0 ( ncolsn <?
		0 da!+ dup nv * da!+
		1+ ) drop
	1 dcols colsbytes 8 - + d! ;		| cursor: 1 voxel

:initpal
	dpal 0 npaln dfill
	$ffffff00 dpal palbytes 4 - + d! ;	| color del cursor

:buildimg | arma la imagen en here y la deja ahi (ss3dmem la lee de here)
	here 'img !
	"SSV2" d@ ,
	65 , ncolsn , npaln ,
	0 ( 64 <?							| tabla de sprites: org | tamano
		dup nv * nv * ,
		nv dup 8 << or nv 16 << or ,
		1+ ) drop
	64 nv * nv * , 1 dup 8 << or 1 16 << or ,
	here dcols colsbytes cmove colsbytes 'here +!
	here dpal palbytes cmove palbytes 'here +!
	img 'here ! ;

:initmem
	here dup 'dcols ! colsbytes +
	dup 'dpal ! palbytes +
	'here ! ;

:upvox | sube a la GPU si hubo cambios
	dirty 0? ( drop ; ) drop
	0 'dirty !
	0 colsbytes dcols ss3dupcols
	0 palbytes dpal ss3duppal ;

|--- operaciones sobre voxeles
#scope 0		| 0 = objeto del cursor, 1 = supercubo completo
#kx 14 #ky 14 #kz 14	| cursor (coordenada global)
#opex
#x0 #x1 #y0 #y1 #z0 #z1

:cursorvox kx 'gx ! ky 'gy ! kz 'gz ! setvox ;

:lohi | c -- lo hi
	scope 1? ( 2drop 0 ng ; ) drop
	nv / nv * dup nv + ;

:eachg | 'op --		; ejecuta op en cada voxel del alcance (usa vo vx vy vz gx gy gz)
	'opex !
	kz lohi 'z1 ! 'z0 !
	ky lohi 'y1 ! 'y0 !
	kx lohi 'x1 ! 'x0 !
	z0 ( z1 <? dup 'gz !
		y0 ( y1 <? dup 'gy !
			x0 ( x1 <? dup 'gx !
				setvox opex ex
				1+ ) drop
			1+ ) drop
		1+ ) drop
	1 'dirty ! ;

| coordenadas dentro del alcance (local al objeto o global)
:ud scope 1? ( drop ng ; ) drop nv ;
:ux scope 1? ( drop gx ; ) drop vx ;
:uy scope 1? ( drop gy ; ) drop vy ;
:uz scope 1? ( drop gz ; ) drop vz ;
:sq dup * ;
:bord | v -- 0/1
	0 =? ( drop 1 ; ) ud 1- =? ( drop 1 ; ) drop 0 ;

:o_fill   1 vocc! ccol vcol! ;
:o_clear  0 vocc! ;
:o_inv    vget 0? ( drop 1 vocc! ccol vcol! ; ) drop 0 vocc! ;
:o_sphere
	ux 2* ud 1- - sq
	uy 2* ud 1- - sq +
	uz 2* ud 1- - sq +
	ud sq <=? ( drop 1 vocc! ccol vcol! ; ) drop
	0 vocc! ;
:o_shell
	ux bord uy bord or uz bord or
	0? ( drop 0 vocc! ; ) drop ;
:o_rand
	3 randmax 0? ( drop 1 vocc! 8 randmax palc vcol! ; ) drop
	0 vocc! ;
:o_grad   uy 8 * ud / palc vcol! ;
:o_recol  ccol vcol! ;
:o_noise  8 randmax palc vcol! ;

:a_fill   'o_fill eachg ;
:a_clear  'o_clear eachg ;
:a_inv    'o_inv eachg ;
:a_sphere 'o_sphere eachg ;
:a_shell  'o_shell eachg ;
:a_rand   'o_rand eachg ;
:a_grad   'o_grad eachg ;
:a_recol  'o_recol eachg ;
:a_noise  'o_noise eachg ;

:b_toggle cursorvox o_inv 1 'dirty ! ;
:b_paint  cursorvox ccol vcol! 1 'dirty ! ;

#anim 0
:rndflip
	ng randmax 'gx ! ng randmax 'gy ! ng randmax 'gz ! setvox
	vget 0? ( drop 1 vocc! 8 randmax palc vcol! ; ) drop
	0 vocc! ;
:animvox
	anim 0? ( drop ; ) drop
	12 ( 1? 1- rndflip ) drop
	1 'dirty ! ;

|----------------------------------
| objetos en el espacio
|----------------------------------
| rotacion del supercubo: quaternion unitario (16.16)
#rqx 0 #rqy 0 #rqz 0 #rqw 1.0
#rtx #rty #rtz #rux #ruy #ruz
#dqx #dqy #dqz #dqw
#qhs #qhc #rdx #rdy

:qconj rqx neg 'rqx ! rqy neg 'rqy ! rqz neg 'rqz ! ;

:qrot | x y z -- x y z	; v + w*t + q x t  (t = 2 q x v)
	'rtz ! 'rty ! 'rtx !
	rqy rtz *. rqz rty *. - 2* 'rux !
	rqz rtx *. rqx rtz *. - 2* 'ruy !
	rqx rty *. rqy rtx *. - 2* 'ruz !
	rtx rqw rux *. + rqy ruz *. + rqz ruy *. -
	rty rqw ruy *. + rqz rux *. + rqx ruz *. -
	rtz rqw ruz *. + rqx ruy *. + rqy rux *. - ;

:qnorm
	rqx dup *. rqy dup *. + rqz dup *. + rqw dup *. + sqrt.
	>r rqx r@ /. 'rqx ! rqy r@ /. 'rqy ! rqz r@ /. 'rqz ! rqw r> /. 'rqw ! ;

:qapply | dx dy dz dw --	; q = d * q
	'dqw ! 'dqz ! 'dqy ! 'dqx !
	dqw rqx *. rqw dqx *. + dqy rqz *. + dqz rqy *. -
	dqw rqy *. rqw dqy *. + dqz rqx *. + dqx rqz *. -
	dqw rqz *. rqw dqz *. + dqx rqy *. + dqy rqx *. -
	dqw rqw *. dqx rqx *. - dqy rqy *. - dqz rqz *. -
	'rqw ! 'rqz ! 'rqy ! 'rqx !
	qnorm ;

:rotreset 0 'rqx ! 0 'rqy ! 0 'rqz ! 1.0 'rqw ! ;

:rotmouse | arrastre: yaw sobre Y del mundo, pitch sobre el eje derecho de la camara
	sdlx dup xp - 0.002 * 'rdx ! 'xp !
	sdly dup yp - 0.002 * 'rdy ! 'yp !
	rdy 2/ sincos 'qhc ! 'qhs !
	sy neg qhs *. 0 cy qhs *. qhc qapply
	rdx 2/ sincos 'qhc ! 'qhs !
	0 qhs 0 qhc qapply ;

#oscl 6.0		| escala de cada objeto (voxel = 0.01 * escala)
#gap 1.05		| separacion entre objetos
#objsz #vox #pitch #pivy #qpk
#hilite 1
#curshow 1
#selobj #ti

:calcgeo
	nv 0.01 * oscl *. 'objsz !
	0.01 oscl *. 'vox !
	objsz gap *. 'pitch !
	lift objsz 2/ + pitch 3 * 2/ + 'pivy !		| pivote de rotacion: centro del supercubo
	rqx rqy rqz rqw packq 'qpk ! ;

:objpos | o -- x y z	; centro del objeto, relativo al pivote
	dup 3 and 2* 3 - pitch * 2/ swap
	dup 2 >> 3 and 2* 3 - pitch * 2/ swap
	4 >> 2* 3 - pitch * 2/ ;

:toworld | x y z -- x y z	; rota por q y suma el pivote
	qrot swap pivy + swap ;

:objcolor | o -- color
	hilite 0? ( 2drop $ffffff00 ; ) drop
	selobj =? ( drop $ffd09000 ; )
	drop $ffffff00 ;

:setobj | o --
	'ti !
	ti objpos toworld qpk oscl ti ti objcolor ti ss3dset ;

:vpos | o v -- p	; centro del voxel v del objeto o, en un eje
	2* 1+ nv - vox * 2/ swap 2* 3 - pitch * 2/ + ;

:curscale | -- s	; parpadeo del cursor
	curshow 0? ( ; ) drop
	msec 8 >> 1 and 0? ( ; ) drop
	oscl 1.2 *. ;

:setcursor
	ox vx vpos oy vy vpos oz vz vpos toworld
	qpk curscale 64 $ffff4003 64 ss3dset ;

:placeobjs
	calcgeo
	cursorvox vo 'selobj !
	0 ( 64 <? dup setobj 1+ ) drop
	setcursor ;

|----------------------------------
| picking: rayo del mouse contra el supercubo, en su espacio local (sin rotar)
#camForMouse 0 0 0
#xdir #ydir
#ro 0 0 0
#rd 0 0 0
#tn #tf #tt #dtt #miss #so #sd
#hitok #hx #hy #hz		| voxel apuntado
#pok #px #py #pz		| ultima celda vacia antes del voxel
#fok #fx #fy #fz		| primera celda valida que cruza el rayo

:AdvMouse
	sdlx 2* fix. sw / 1.0 -
	camAsp *. camFov *. 'xdir !
	sdly 2* fix. sh / 1.0 -
	camFov *. 'ydir !
	'camForMouse >a
	'camAdv @      'camLat @      xdir *. + 'camVU @      ydir *. + a!+
	'camAdv 8 + @  'camLat 8 + @  xdir *. + 'camVU 8 + @  ydir *. + a!+
	'camAdv 16 + @ 'camLat 16 + @ xdir *. + 'camVU 16 + @ ydir *. + a!+
	'camForMouse v3Nor ;

:raylocal | rayo del mouse -> 'ro 'rd (relativos al pivote, sin la rotacion)
	AdvMouse
	'camForMouse @ neg 'camForMouse 8 + @ neg 'camForMouse 16 + @ neg
	qconj qrot qconj
	'rd 16 + ! 'rd 8 + ! 'rd !
	'camEye @ 'camEye 8 + @ pivy - 'camEye 16 + @
	qconj qrot qconj
	'ro 16 + ! 'ro 8 + ! 'ro ! ;

:bigH pitch 3 * 2/ objsz 2/ + ;		| semi-lado del supercubo

:slab | o d --		; recorta tn tf con la placa +-bigH
	'sd ! 'so !
	sd abs 32 <? ( drop so abs bigH >? ( 1 'miss ! ) drop ; ) drop
	bigH neg so - sd /.
	bigH so - sd /.
	2dup min tn max 'tn !
	max tf min 'tf ! ;

:axcell | p -- g/-1	; coordenada global de voxel en un eje (-1 = hueco o fuera)
	dup pitch /. 2.0 + 16 >>
	-? ( 2drop -1 ; ) 3 >? ( 2drop -1 ; )
	swap over 2* 3 - pitch * 2/ -
	objsz 2/ +
	-? ( 2drop -1 ; ) objsz >=? ( 2drop -1 ; )
	vox / nv 1- min swap nv * + ;

:cell | x y z -- r	; -1 fuera, 0 vacio, 1 ocupado (celda en gx gy gz, vo vx vy vz)
	axcell -? ( drop 2drop -1 ; ) 'gz !
	axcell -? ( 2drop -1 ; ) 'gy !
	axcell -? ( drop -1 ; ) 'gx !
	setvox
	vget 1? ( drop 1 ; ) drop 0 ;

:marchstep
	'ro @ 'rd @ tt *. +
	'ro 8 + @ 'rd 8 + @ tt *. +
	'ro 16 + @ 'rd 16 + @ tt *. +
	cell
	-? ( drop ; )
	1? ( drop gx 'hx ! gy 'hy ! gz 'hz ! 1 'hitok ! tt 'tf ! ; ) drop
	fok 0? ( gx 'fx ! gy 'fy ! gz 'fz ! 1 'fok ! ) drop
	gx 'px ! gy 'py ! gz 'pz ! 1 'pok ! ;

:rayhit | marcha el rayo por el supercubo: hitok hx hy hz / pok px py pz / fok fx fy fz
	0 'hitok ! 0 'pok ! 0 'fok ! 0 'miss !
	raylocal
	0 'tn ! 1000.0 'tf !
	'ro @ 'rd @ slab
	'ro 8 + @ 'rd 8 + @ slab
	'ro 16 + @ 'rd 16 + @ slab
	miss 1? ( drop ; ) drop
	tn tf >=? ( drop ; ) drop
	vox 3 / 1 max 'dtt !
	tn ( tf <? dup 'tt ! marchstep dtt + ) drop ;

:pickat | el cursor de voxel sigue al mouse
	rayhit
	hitok 1? ( drop hx 'kx ! hy 'ky ! hz 'kz ! ; ) drop
	fok 1? ( drop fx 'kx ! fy 'ky ! fz 'kz ! ; ) drop ;

:placetarget | -- 0/1	; celda donde se agrega (gx gy gz)
	hitok 1? ( drop pok 0? ( ; ) drop px 'gx ! py 'gy ! pz 'gz ! 1 ; ) drop
	fok 0? ( ; ) drop
	fx 'gx ! fy 'gy ! fz 'gz ! 1 ;

:mplace | poner voxel (ocupado + color actual)
	rayhit placetarget 0? ( drop ; ) drop
	setvox 1 vocc! ccol vcol! 1 'dirty !
	gx 'kx ! gy 'ky ! gz 'kz ! ;

:mremove | quitar el voxel apuntado
	rayhit hitok 0? ( drop ; ) drop
	hx 'gx ! hy 'gy ! hz 'gz ! setvox
	0 vocc! 1 'dirty ! ;

|----------------------------------
| mouse: 0 = navegar, 1 = rotar el objeto, 2 = editar voxeles (izq poner, der quitar)
#mmode 0
#mnames "navegar" "rotar objeto" "editar voxeles"
:mname | n -- adr
	'mnames swap ( 1? 1- swap >>0 trim swap ) drop ;
:m_nav 0 'mmode ! ;
:m_rot 1 'mmode ! ;
:m_edit 2 'mmode ! ;

:dnmouse sdlx 'xp ! sdly 'yp ! ;

:editclick
	sdlb 4 =? ( drop mremove ; ) drop mplace ;

:viewmouse
	immMouse
	1 =? ( wheelcam mmode 2 =? ( pickat ) drop )	| over
	2 =? ( dnmouse mmode 2 =? ( editclick ) drop )	| in
	3 =? ( mmode 0? ( movecam ) 1 =? ( rotmouse ) drop )	| active
	drop ;

|----------------------------------
:cadd | d 'var --
	dup @ rot + 0 max ng 1- min swap ! ;

:ocolid | o -- n		; color segun la posicion del objeto
	dup 3 and swap dup 2 >> 3 and swap 4 >> + + 7 and ;

:initobjs | cada objeto: esfera de un color segun su posicion
	0 'scope !
	0 ( 64 <? dup 'vo ! dup ocolid 'ccolid !
		0 ( nv <? dup 'vz !
			0 ( nv <? dup 'vy !
				0 ( nv <? dup 'vx !
					o_sphere
					1+ ) drop
				1+ ) drop
			1+ ) drop
		1+ ) drop
	0 'ccolid !
	1 'dirty ! ;

|----------------------------------
:vui
	mmode mname "mouse: %s" sprint uiLabelC
	"VOXELES" uiLabelC
	ccolid cname "color: %s" sprint uiLabelC
	0 7 'ccolid uiSlideri
	kz ky kx "cursor %d %d %d" sprint uiLabelC
	"x" 0 ng 1- 'kx uiSlideriL
	"y" 0 ng 1- 'ky uiSlideriL
	"z" 0 ng 1- 'kz uiSlideriL
	'b_toggle "alternar" uiNBtn
	'b_paint "pintar" uiNBtn
	uiLn
	"APLICAR A" uiLabelC
	'scope "todo el supercubo" uiToggle
	'a_fill "llenar" uiNBtn
	'a_clear "vaciar" uiNBtn
	'a_inv "invertir" uiNBtn
	uiLn
	'a_sphere "esfera" uiNBtn
	'a_shell "carcasa" uiNBtn
	'a_rand "azar" uiNBtn
	uiLn
	'a_grad "gradiente" uiNBtn
	'a_recol "color" uiNBtn
	'a_noise "ruido" uiNBtn
	uiLn
	'anim "animar al azar" uiToggle ;

:renderui
	"RENDER" uiLabelC
	'shadowon "sombras" uiToggle uiEx? 1? ( shadowon ss3dshadow! ) drop
	'rl_ao_on "SSAO" uiToggle
	'rl_aa_on "FXAA" uiToggle
	"azimut" 0.0 1.0 'sun_az uiSliderfL uiEx? 1? ( setsun ) drop
	"altura" 0.0 0.25 'sun_el uiSliderfL uiEx? 1? ( setsun ) drop
	"escala" 1.0 12.0 'oscl uiSliderfL
	"alt. objeto" 0.0 6.0 'lift uiSliderfL
	"separacion" 1.0 2.0 'gap uiSliderfL
	'hilite "resaltar objeto" uiToggle
	'curshow "cursor" uiToggle ;

:interface
	1 'fscale !
	$ffffffff 'fcolor !

	uiFull
	0.05 %ch uiN
	$1f0000ff 'fcolor !
	uiWinBox frect
	$ffffffff 'fcolor !
	'exit "Exit" uiNBtn
	'totop "T" uiNBtn
	'tofront "F" uiNBtn
	'toside "S" uiNBtn
	'm_nav "nav" uiNBtn
	'm_rot "rotar" uiNBtn
	'm_edit "editar" uiNBtn
	'rotreset "reset rot" uiNBtn

	0.2 %cw uiO
	$1f00ff00 'fcolor !
	uiWinBox frect
	$ffffffff 'fcolor !
	vui
	renderui

	uiRest uiWinBox immBox
	viewmouse
	;

:hud
	fini
	immIni
	interface
	fend

	sdlkey
	>esc< =? ( exit )
	<w> =? ( -0.05 'va ! ) >w< =? ( 0 'va ! )
	<s> =? ( 0.05 'va ! ) >s< =? ( 0 'va ! )
	<a> =? ( 0.04 'vl ! ) >a< =? ( 0 'vl ! )
	<d> =? ( -0.04 'vl ! ) >d< =? ( 0 'vl ! )
	<q> =? ( 0.04 'vu ! ) >q< =? ( 0 'vu ! )
	<e> =? ( -0.04 'vu ! ) >e< =? ( 0 'vu ! )

	<up> =? ( 1 'kx cadd ) <dn> =? ( -1 'kx cadd )
	<le> =? ( 1 'kz cadd ) <ri> =? ( -1 'kz cadd )
	<pgup> =? ( 1 'ky cadd ) <pgdn> =? ( -1 'ky cadd )
	<tab> =? ( mmode 1+ 3 =? ( drop 0 ) 'mmode ! )
	<spc> =? ( b_toggle )
	<ret> =? ( b_paint )
	<1> =? ( 0 'ccolid ! ) <2> =? ( 1 'ccolid ! ) <3> =? ( 2 'ccolid ! ) <4> =? ( 3 'ccolid ! )
	<5> =? ( 4 'ccolid ! ) <6> =? ( 5 'ccolid ! ) <7> =? ( 6 'ccolid ! ) <8> =? ( 7 'ccolid ! )
	<f1> =? ( shadowon 1 xor 'shadowon ! shadowon ss3dshadow! )
	<f2> =? ( rl_ao_on 1 xor 'rl_ao_on ! )
	drop

	keycam
	;

:main
	vupdate
	makecam
	animvox
	upvox
	placeobjs

	rl_frame_begin
	SS3Ddraw
	draw_grid
	light
	rl_frame_end

	hud
	GLUpdate
	;

:viewresize
	sh sw rl_resizewin
	fixFontResize ;

:initvox
	time msec rerand
	initmem
	initcols initpal
	buildimg
	128 ss3dmem				| 64 objetos + cursor
	initobjs ;

: | <<<<<<<< Boot
	"Supercubo voxel r3dv" 1024 768 GLini GLInfo
	$fff vaini
	glgfx
	initvox
	rl_init
	1 rl_grid_init
	2048 ss3dshadowini
	1 ss3dshadowauto
	'viewresize SDLeventR
	setsun
	shadowon ss3dshadow!
	makecam
	tofront

	'main SDLshow

	rl_grid_free
	ss3dshadowend
	rl_shutdown
	SS3Dshutdown
	GLend
	;
