| test demo animation
| PHREDA 2026
^r3/lib/rand.r3
^r3/util/varanim.r3

^./renderlib.r3
^./rlhud.r3
^./ss3d.r3
^./glimm.r3
^./rlgrid.r3

#objlist 0 0 

| Camera controls
#cam_yaw  0  
#cam_pit  0
#camEye -10.0 2.0 0.0
#camTo  0.0 0.0  0.0
#camUp  0.0 1.0  0.0
#camAdv 0 0 0 | forward
#camLat 0 0 0 | right

|----------------------
#cp #sp #cy #sy 

#raydir 0 0 0

:makeraydir  
	'raydir 'camAdv v3=
	'raydir 'camlat 
	sdlx sw 2/ - 16 << sw 2/ / |camFov *. camAsp *.
	v3+*
	'raydir 'camup 
	sdly sh 2/ - 16 << sh 2/ / |camFov *.
	v3+*
	'raydir v3Nor
	;

#hit 0
#v3hit 0 0 0

:hitground
	'raydir 8 + @ 0? ( 'hit ! ; ) 
	'camEye 8 + @ swap /. | t
	-? ( drop 0 'hit ! ; ) neg
	'v3hit 'camEye v3=
	'v3hit 'raydir rot v3+*	
	1 'hit !
	;

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
	'camEye 'camTo 'camUp rl_camera | 'eye 'to 'up --
	;

#xp #yp 
:movecam
	|sdlb 4 <>? ( drop ; ) drop
	sdlx dup xp - 0.001 * 
	'cam_yaw +! 'xp !
	sdly dup yp - -0.001 * 
	cam_pit + |0.24 min -0.24 max 
	'cam_pit ! 'yp !
	makecam ;
	
:wheelcam
	SDLw 0? ( drop ; ) -0.4 *
	'camEye 'camAdv pick2 v3+*
	'camTo 'camAdv pick2 v3+*
	drop
	;

:rotatemouse
	immMouse
	1 =? ( wheelcam )				| over
	2 =? ( sdlx 'xp ! sdly 'yp ! )	| in
	3 =? ( movecam )				| active
	drop	
	;
	
#fsun [ 
-0.5 8.0 -0.5 0
 1.0 1.0 1.0 1.0
 ]

:lightsun
	8 'fsun memfloat
	'fsun rl_set_sun
	;
	   
:light2
	2.4 
	0.0 0.0 1.0
	msec 3 << 
	dup cos -5 * 
	over sin -3 * 1.0 +
	rot sin 4.5 *.
	rl_point_light | int cr cg cb x y z --

	2.2 
	1.0 0.0 0.0
	msec 3 << 
	dup cos 7 * 
	over sin 3 * 1.0 +
	rot 0.5 + sin 4.5 *.
	rl_point_light | int cr cg cb x y z --
	;
	
:light
	0.2
	1.0 1.0 1.0
	'camEye >a
	a@+ a@+ 1.0 + a@
	rl_point_light | int cr cg cb x y z --
	;

#va #vl #vu


|----------------------------
	
:hiteye
	'camAdv 8 + @ 0? ( 'hit ! ; ) 
	'camEye 8 + @ swap /. | t
	-? ( drop 0 'hit ! ; ) neg
	'v3hit 'camEye v3=
	'v3hit 'camAdv rot v3+*	
	1 'hit !
	;
	
#cntobjs
#nrosprite
	
:addobj
	hiteye hit 0? ( drop ; ) drop
	'v3hit >a a@+ a@+ a@+ | x y z
	$000000000000 rxyz>q16 
	3.0
	nrosprite
	$ffffff00
	cntobjs
	ss3dset | x y z qxyzw scale spr color i --	
		
	1 'cntobjs +!
	;

#fileanim 
#cntbones
#cntanim
#anims
#skel 

#nstep
#nvel

:debugr3a |---debug
	cntbones "bones:%d" .println
	cntanim "anims:%d" .println
	anims
	cntanim ( 1? 1- swap 
		d@+ "anim %h " .println 
		swap ) 2drop
	"" .println
	skel 
	cntbones ( 1? 1- swap
		c@+ "%d " .print 
		swap ) drop
		"" .println
	dup fileanim - "%h" .println
	
	w@+ 'nstep !
	w@+ 'nvel !
	>a
	0 ( nstep <?
		a> w@+ 8 << "%f " .println
		>a
		0 ( cntbones <? 
			16 a+
			1+ ) drop
		1+ ) 2drop
	;
	
:loadr3a | "" --
	here dup 'fileanim !
	swap load 'here !
	fileanim
	d@+ "r3a" d@ <>? ( "bad file r3a" .println 2drop ; ) drop
	w@+ 'cntbones !
	w@+ 'cntanim !
	dup 'anims !
	cntanim 2 << +
	|dup 
	'skel !
	|cntbones 17 * +
	|drop
	
|	debugr3a
|	fileanim anims 3 2 << + d@ + 
|	w@+ "cntframes %d" .println 

|	; :a
	 
	fileanim anims 0 2 << + d@ + 
	4 + | frames/vel
	2 + | duracion
	>a
	skel
	0 ( cntbones <? swap 
		c@+ drop
		a@+ unpack21 a@+ 1.0 nrosprite $ffffff00 cntobjs
		ss3dset | x y z qxyzw scale spr color i --			
		1 'cntobjs +!
		swap 1+ ) 2drop
	;


#qx #qy #qz #qw | still in calcrot
#px #py #pz
#tx #ty #tz

:calcpos | ppos prot pos -- npos
	unpack21r 'px ! 'py ! 'pz !
	unpackq 'qx ! 'qy ! 'qz ! 'qw !
	qy pz *. qz py *. - 2* 'tx !
	qz px *. qx pz *. - 2* 'ty !
	qx py *. qy px *. - 2* 'tz !
	unpack21r	qw tx *. + qy tz *. qz ty *. - + px + | x
	swap		qw ty *. + qz tx *. qx tz *. - + py + | y 
	rot 		qw tz *. + qx ty *. qy tx *. - + pz + | z
	pack21
	;
	
:calcrot | rot -- nrot
	unpackq 'px ! 'py ! 'pz ! 'tz ! | pw=tz
	qw px *. qx tz *. + qy pz *. + qz py *. - | x
	qw py *. qx pz *. - qy tz *. + qz px *. + | y 
    qw pz *. qx py *. + qy px *. - qz tz *. + | z
    qw tz *. qx px *. - qy py *. - qz pz *. - | w
	pick3 dup *. pick3 dup *. + pick2 dup *. + over dup *. +
	sqrt. 1.0 swap /.
	packq*
	;
	
:calcw
	-? ( drop 
		a@+ b!+ | pos
		a@+ b!+ | rot
		; )
	4 << here + @+ swap @ | ppos prot 
	a@+ calcpos b!+ | keep qxyzw var
	a@+ calcrot b!+
	;

:calcpose | anim --
	2 << anims + d@ fileanim + 
	4 + | frames/vel
	| frame 0 
	2 + | duracion
	>a
	
	here >b
	skel
	0 ( cntbones <? swap
		c@+ calcw swap
		-16 b+
		b@+ unpack21 b@+ pick4 ss3dxyzq | x y z quat i --
		1+ ) 2drop ;

|----------------------------------
| DESCRIPCION
| NODOS (vertices): un sprite ss3d en cada articulacion (esfera de voxeles),
|   mismo sprite y escala para todos (nspr, nscl)
| HUESOS: un sprite ss3d por hueso, ubicado en el segmento padre(i) -> i
|   spr   : nro de sprite ss3d (-1 = oculto)
|   scale : escala del sprite
|   t     : posicion sobre el segmento (0=padre, 0.5=centro, 1.0=articulacion i)
|   rotacion = la del padre; con "alinear" el eje Y del sprite va por el hueso
#bd_spr * 2048
#bd_scl * 2048
#bd_t   * 2048
#bd_old * 2048	| sprite a restaurar al des-ocultar
#bd_arc * 2048	| quaternion: lleva el eje Y del sprite a lo largo del hueso

#tspr #tscl #tt

:bdset | bone spr scale t --
	'tt ! 'tscl ! 'tspr !
	3 <<
	tspr over 'bd_spr + !
	tspr -? ( drop nrosprite ) over 'bd_old + !
	tscl over 'bd_scl + !
	tt swap 'bd_t + ! ;

:bdname | bone "sprite" scale t --
	>r >r ss3idname r> r> bdset ;

:bdall | spr scale t --
	'tt ! 'tscl ! 'tspr !
	0 ( cntbones <?
		dup tspr tscl tt bdset
		1+ ) drop ;

#nspr #nscl 1.0	| sprite y escala de los nodos
:nodedef | spr scale --
	'nscl ! 'nspr ! ;

#shownodes 1	| 1 = se ven los nodos
#showbones 1	| 1 = se ven los sprites de hueso
#alinear 1		| 1 = el eje Y del sprite de hueso va por el hueso
#ajustar 0		| 1 = el sprite se estira en Y hasta el largo del hueso (escala = grosor)
#nch0 #locator	| locator=1: el nodo 0 es un ubicador (raiz con un solo hijo)

:calcloc | raiz con un solo hijo = ubicador del objeto (no se dibuja)
	0 'nch0 ! 0 'locator !
	1 ( cntbones <?
		dup skel + c@ 0? ( 1 'nch0 +! ) drop
		1+ ) drop
	nch0 1 =? ( 1 'locator ! ) drop ;

:bpar | i -- p ; padre efectivo (-1 = raiz o hijo del ubicador)
	skel + c@
	0? ( locator 1? ( 2drop -1 ; ) drop ) ;

#bsel 1		| hueso seleccionado (el 0 nunca se dibuja ni se elige)
#bdebug 1	| 1 = resalta seleccion (rojo) y raiz (amarillo)
#bs #bc
#bi0		| primera instancia de huesos (los nodos son 0..cntbones-1)

:bcolor | i -- color ; hueso
	bdebug 0? ( 2drop $ffffff00 ; ) drop
	bsel =? ( drop $ff202000 ; )
	drop $ffffff00 ;

:ncolor | i -- color ; nodo
	bdebug 0? ( 2drop $ffffff00 ; ) drop
	bsel =? ( drop $ff202000 ; )
	dup bpar -? ( 2drop $ffff0000 ; ) drop
	drop $ffffff00 ;

| nodo i = instancia i (el nodo 0 nunca se dibuja)
:ndone | i --
	0 'bc !
	shownodes 1? ( nscl 'bc ! ) drop
	dup 0? ( 0 'bc ! ) drop
	bc nspr pick2 ncolor pick3 ss3dcs drop ;

| hueso i = instancia bi0+i (oculto: escala 0, salvo el seleccionado:
| punto chico para poder verlo; sin segmento: no se dibuja)
:bdone | i --
	dup 3 <<
	dup 'bd_scl + @ 'bc !
	'bd_spr + @ 'bs !
	bs -? ( drop 0 'bc ! 0 'bs !
		dup bsel =? ( 0.4 'bc ! nrosprite 'bs ! ) )
	drop
	showbones 0? ( 0 'bc ! ) drop
	dup bpar -? ( 0 'bc ! ) drop
	bc bs pick2 bcolor pick3 bi0 + ss3dcs drop ;

:bdapply
	0 ( cntbones <?
		dup ndone
		dup bdone
		1+ ) drop ;

:describe
	nrosprite 1.0 nodedef		| nodos: sprite/escala
	nrosprite 1.0 0.5 bdall		| huesos: sprite/escala/t por defecto
	|1 "cylinder" 1.0 0.5 bdname
	|2 "cuboalambre" 1.0 0.5 bdname
	;

:listbones | debug: i padre spr
	0 ( cntbones <?
		dup 3 << 'bd_spr + @
		over skel + c@
		pick2
		"%d p:%d spr:%d" .println
		1+ ) drop ;

#boff
:listdesc | lineas para pegar en :describe (solo lo distinto del defecto)
	nscl nspr "%d %f nodedef" .println
	1 ( cntbones <?
		dup 3 << 'boff !
		0 'tt !
		boff 'bd_spr + @ nrosprite <>? ( 1 'tt ! ) drop
		boff 'bd_scl + @ 1.0 <>? ( 1 'tt ! ) drop
		boff 'bd_t + @ 0.5 <>? ( 1 'tt ! ) drop
		tt 1? (
			boff 'bd_t + @
			boff 'bd_scl + @
			boff 'bd_spr + @
			pick4
			"%d %d %f %f bdset" .println ) drop
		1+ ) drop ;

:bnext bsel cntbones 1- mod 1+ 'bsel ! bdapply ;
:bprev bsel 1- 1 <? ( drop cntbones 1- ) 'bsel ! bdapply ;

:btoggle | oculta / muestra el hueso seleccionado
	bsel 3 << 'boff !
	boff 'bd_spr + @ -? (
		drop boff 'bd_old + @ boff 'bd_spr + !
		bdapply ; )
	boff 'bd_old + !
	-1 boff 'bd_spr + !
	bdapply ;

| instancias de los sprites de hueso (despues de las de los nodos)
:makebones
	cntobjs 'bi0 !
	cntobjs cntbones + 256 >? ( "faltan instancias para los huesos" .println ) drop
	0 ( cntbones <?
		0 0 0  0 0 0 1.0 packq  0 nrosprite $ffffff00 cntobjs ss3dset
		1 'cntobjs +!
		1+ ) drop ;

| arco corto del eje Y (0 1 0) a la direccion (x y z), en el marco del padre
#alx #aly #alz #all
#aqx #aqy #aqz #aqw
:arcloc | x y z -- qpack
	'alz ! 'aly ! 'alx !
	alx dup *. aly dup *. + alz dup *. + sqrt. 'all !
	all 0? ( drop 0 0 0 1.0 packq ; ) drop
	alx all /. 'alx ! aly all /. 'aly ! alz all /. 'alz !
	aly 1.0 + 0.002 <? ( drop 1.0 0 0 0 packq ; ) drop	| opuesto: 180 sobre X
	alz 'aqx ! 0 'aqy ! alx neg 'aqz ! aly 1.0 + 'aqw !
	aqx dup *. aqz dup *. + aqw dup *. + sqrt. 'all !
	aqx all /. aqy all /. aqz all /. aqw all /. packq ;

| usa la pose base (anim 0, frame 0): offset local de cada hueso
:makearcs
	fileanim anims 0 2 << + d@ + 4 + 2 + >a
	0 ( cntbones <?
		a@+ unpack21 arcloc
		over 3 << 'bd_arc + !
		a@+ drop
		1+ ) drop ;

#b0x #b0y #b0z
#b1x #b1y #b1z
#bq #bt
#rqx #rqy #rqz #rqw

:blerp | a b t -- a+(b-a)*t
	>r over - r> *. + ;

| rotacion del sprite de hueso i: la del padre (bq), con arco local si alinear
:balign | i -- qpack
	alinear 0? ( 2drop bq ; ) drop
	3 << 'bd_arc + @ unpackq 'aqx ! 'aqy ! 'aqz ! 'aqw !
	bq unpackq 'rqx ! 'rqy ! 'rqz ! 'rqw !
	rqw aqx *. rqx aqw *. + rqy aqz *. + rqz aqy *. -
	rqw aqy *. rqx aqz *. - rqy aqw *. + rqz aqx *. +
	rqw aqz *. rqx aqy *. + rqy aqx *. - rqz aqw *. +
	rqw aqw *. rqx aqx *. - rqy aqy *. - rqz aqz *. -
	packq ;

:placenode | i --
	dup 4 << here + >b
	b@+ unpack21 b@+ pick4 ss3dxyzq drop ;

:bsy | i -- sy ; estiramiento en Y para que el sprite mida lo que el hueso
	ajustar 0? ( 2drop 1.0 ; ) drop
	3 <<
	dup 'bd_spr + @ -? ( 2drop 1.0 ; )
	swap 'bd_scl + @ swap
	ss3dfloor 2*
	0? ( drop 1.0 ; )
	b1x b0x - dup *. b1y b0y - dup *. + b1z b0z - dup *. + sqrt.
	swap /. ;

:placebone | i --
	dup 3 << 'bd_t + @ 'bt !
	dup bpar -? ( 2drop ; )			| sin segmento
	dup 4 << here + 8 + @ 'bq !		| rot del padre
	4 << here + @ unpack21 'b0z ! 'b0y ! 'b0x !
	dup 4 << here + @ unpack21 'b1z ! 'b1y ! 'b1x !
	b0x b1x bt blerp
	b0y b1y bt blerp
	b0z b1z bt blerp			| i x y z
	pick3 balign				| i x y z q
	pick4 bi0 + ss3dxyzq
	1.0 over bsy 1.0 pick3 bi0 + ss3dstr drop ;

:placebones
	0 ( cntbones <?
		dup placenode
		dup placebone
		1+ ) drop ;

|----------------------------------
| EDICION del hueso seleccionado (sprite / escala / t)
#vsp #vsc #vt

:ed_load
	bsel 3 << 'boff !
	boff 'bd_spr + @ 0 max 'vsp !
	boff 'bd_scl + @ 'vsc !
	boff 'bd_t + @ 'vt ! ;
:ed_spr vsp boff 'bd_spr + ! vsp boff 'bd_old + ! bdapply ;
:ed_scl vsc boff 'bd_scl + ! bdapply ;
:ed_t   vt boff 'bd_t + ! ;

:bspr+ | d --
	bsel 3 << 'boff !
	boff 'bd_spr + @ -? ( drop boff 'bd_old + @ )
	+ 0 max n3dsprites 1- min
	dup boff 'bd_spr + ! boff 'bd_old + !
	bdapply ;
:bscl+ | d --
	bsel 3 << 'boff !
	boff 'bd_scl + @ + 0.1 max
	boff 'bd_scl + ! bdapply ;

:togglenodes shownodes 1 xor 'shownodes ! bdapply ;
:togglebones showbones 1 xor 'showbones ! bdapply ;
:togglealign alinear 1 xor 'alinear ! ;
:togglefit ajustar 1 xor 'ajustar ! ;

|----------------------------------
#baseanim
#cntframe

:setanim | anim --
	2 << anims + d@ fileanim + 
	w@+ 'cntframe !
	4 + 'baseanim !
	;

:calframe | frame --
	cntframe mod
	cntbones 4 << 2 + *
	baseanim +
	>a	
	here >b
	skel
	0 ( cntbones <? swap
		c@+ calcw swap
		1+ ) 2drop
	placebones ;
	
|----------------------------------	
	
:totop
	'cam_yaw 0 cam_yaw 21 1.0 0 +vanim
	'cam_pit -0.25 cam_pit 21 1.0 0 +vanim
	'camEye >a
	a> 0.0 a@+ 21 1.0 0 +vanim | 'var end ini ease dur. start --
	a> 12.0 a@+ 21 1.0 0 +vanim | 'var end ini ease dur. start --
	a> 0.0 a@+ 21 1.0 0 +vanim | 'var end ini ease dur. start --
	;
	
:tofront
	'cam_yaw 0 cam_yaw 21 1.0 0 +vanim
	'cam_pit 0 cam_pit 21 1.0 0 +vanim
	'camEye >a
	a> -10.0 a@+ 21 1.0 0 +vanim | 'var end ini ease dur. start --
	a> 2.0 a@+ 21 1.0 0 +vanim | 'var end ini ease dur. start --
	a> 0.0 a@+ 21 1.0 0 +vanim | 'var end ini ease dur. start --
	;
	
:toside
	'cam_yaw -0.25 cam_yaw 21 1.0 0 +vanim
	'cam_pit 0 cam_pit 21 1.0 0 +vanim
	'camEye >a
	a> 0.0 a@+ 21 1.0 0 +vanim | 'var end ini ease dur. start --
	a> 2.0 a@+ 21 1.0 0 +vanim | 'var end ini ease dur. start --
	a> 10.0 a@+ 21 1.0 0 +vanim | 'var end ini ease dur. start --
	;

:interface
	1 'fscale !
	$ffffffff 'fcolor !
	
	uiFull
	0.05 %ch uiN
	$1f0000ff 'fcolor !
	gZoneAll frect
	$ffffffff 'fcolor !
	'exit "Exit" uiTBtn
|	'exit "eventos" uiTBtn
|	'exit "seleccion" uiTBtn
	'totop "T" uiTBtn
	'tofront "F" uiTBtn
	'toside "S" uiTBtn
	
	0.2 %cw uiO
	$1f00ff00 'fcolor !
	gZoneAll frect
	
	$ffffffff 'fcolor !
	"EDIT" uiLabelC
	
	'camEye @+ swap @+ swap @ "Eye: %a,%a,%a" sprint uiLabelC
	'camTo @+ swap @+ swap @ "To: %a,%a,%a" sprint uiLabelC
	'camUp @+ swap @+ swap @ "Up: %a,%a,%a" sprint uiLabelC
	'camAdv @+ swap @+ swap @ "Forw: %a,%a,%a" sprint uiLabelC
	'camLat @+ swap @+ swap @ "Right: %a,%a,%a" sprint uiLabelC

	cam_pit cam_yaw "Y:%a P:%a" sprint uiLabel

	bsel 3 << 'bd_spr + @
	bsel skel + c@
	bsel
	"bone %d padre %d spr %d" sprint uiLabelC
	'bprev "<" uiTBtn
	'bnext ">" uiTBtn
	'btoggle "hide" uiTBtn

	ed_load
	vsp ssnameid "%s" sprint uiLabelC
	0 n3dsprites 1- 'vsp uiSlideri uiEx? 1? ( ed_spr ) drop
	"escala" uiLabelC
	0.1 4.0 'vsc uiSliderf uiEx? 1? ( ed_scl ) drop
	"t (0 padre - 1 nodo)" uiLabelC
	-0.5 1.5 'vt uiSliderf uiEx? 1? ( ed_t ) drop
	nspr ssnameid "nodo: %s" sprint uiLabelC
	0 n3dsprites 1- 'nspr uiSlideri uiEx? 1? ( bdapply ) drop
	0.1 4.0 'nscl uiSliderf uiEx? 1? ( bdapply ) drop
	'togglenodes "nodos" uiTBtn
	'togglebones "huesos" uiTBtn
	'togglealign "alinear" uiTBtn
	'togglefit "ajustar largo" uiTBtn

	|nrosprite ssnameid "[%l]" sprint uiLabelC
	
|	n3dsprites "ant:%h" sprint uiLabelC
|	cntobjs "objs:%d" sprint uiLabelC
|	nrosprite "spr:%d" sprint uiLabelC

|	'raydir @+ swap @+ swap @ "%a %a %a" sprint uiLabelC
|	'addobj "+" uiFTBtn	

	;
	
:hud
	fini
	immIni
	rotatemouse
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
	
	<f1> =? ( 1 setanim )
	<f2> =? ( 2 setanim )
	<f3> =? ( 3 setanim )	
	<f4> =? ( 0 setanim )	
	<f5> =? ( listbones )
	<f6> =? ( bdebug 1 xor 'bdebug ! bdapply )
	<f7> =? ( listdesc )
	<up> =? ( 1 bspr+ ) <dn> =? ( -1 bspr+ )
	<pgup> =? ( 0.1 bscl+ ) <pgdn> =? ( -0.1 bscl+ )
	<n> =? ( togglenodes ) <b> =? ( togglebones )
	<le> =? ( bprev ) <ri> =? ( bnext ) <h> =? ( btoggle )
	
|	<f3> =? ( 2 calcpose )
|	<pgup> =? ( nrosprite 1+ n3dsprites min 'nrosprite ! )
|	<pgdn> =? ( nrosprite 1- 0 max 'nrosprite ! )
	<spc> =? ( 
		addobj
		nrosprite 1+ n3dsprites mod 'nrosprite !
		)
	drop
	
	msec 6 >> calframe
	
	va 1? ( 
		'camEye 'camAdv pick2 v3+*
		'camTo 'camAdv pick2 v3+*
		) drop
	vl 1? (
		'camEye 'camLat pick2 v3+*
		'camTo 'camLat pick2 v3+*
		) drop
	vu 1? (
		'camEye 'camUp pick2 v3+*
		'camTo 'camUp pick2 v3+*
		) drop
	;
	
:main
	vupdate
	makecam
	
	rl_frame_begin
	SS3Ddraw
	draw_grid
	light
	rl_frame_end

	hud
	GLUpdate
	;

:load3d
|	"media/ss/iti"
|	"media/ss/vox2" 
	"media/ss/sprites"
	dup 256 ss3dload
	ss3loadnames
	"point" ss3idname 'nrosprite !
	;
	

	
:viewresize 
	sh sw rl_resizewin 
	fixFontResize ;

: | <<<<<<<< Boot
	"Scene r3dv" 1024 768 GLini GLInfo

	$fff vaini
	
	rlhud
	load3d
	|"media\bvh\pajaro.r3a" 
	"media\bvh\lobo.r3a" 
	|"media\bvh\persona.r3a" 
	|"media\bvh\animations.r3a"
	loadr3a
	|makeskel	
	1 setanim
	makebones makearcs calcloc describe bdapply
	
	
	rl_init 
	0 rl_grid_init
	
	'viewresize SDLeventR
	lightsun
	makeCam
	tofront

	'main SDLshow
	
	rl_grid_free 
	rl_shutdown
	SS3Dshutdown
	GLend
	;