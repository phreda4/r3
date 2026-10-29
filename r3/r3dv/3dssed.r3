| Ss scene editor
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
#camViewUp 0 0 0
#camFor 0 0 0 | forward
#camRig 0 0 0 | right

|----------------------
#cp #sp #cy #sy 

:makecam
	cam_yaw sincos 'cy ! 'sy !
	cam_pit -0.24 max 0.24 min 
	sincos 'cp ! 'sp !
	'camTo >a 'camEye >b
	b@+ cy cp *. + a!+
	b@+ sp + a!+
	b@+ sy cp *. + a!
	'camFor >a
	cy neg cp *. a!+
	sp neg a!+
	sy neg cp *. a!
	'camFor v3Nor
	'camRig >a
	sy a!+
	0 a!+
	cy neg a!+
	'camRig v3Nor
    'camViewUp >a
    cy sp *. neg a!+    | x = -cy*sp
    cp a!+              | y = cp
    sy sp *. neg a!     | z = -sy*sp
	'camEye 'camTo 'camUp rl_camera | 'eye 'to 'up --	
	;

#glevel 0
#gaxis 1

#camForMouse 0 0 0
#v3hit 0 0 0

#xdir 
#ydir

:AdvMouse
	sdlx 2* fix. sw / 1.0 -
	camAsp *. camFov *. 'xdir !
	
	sdly 2* fix. sh / 1.0 -
	camFov *. 'ydir !
	
	'camForMouse >a
	'camFor @      'camRig @      xdir *. + 'camViewUp @      ydir *. + a!+
	'camFor 8 + @  'camRig 8 + @  xdir *. + 'camViewUp 8 + @  ydir *. + a!+
	'camFor 16 + @ 'camRig 16 + @ xdir *. + 'camViewUp 16 + @ ydir *. + a!+

	'camForMouse v3Nor
	;

:hiteye
	AdvMouse
	'camForMouse gaxis 3 << + @ 0? ( ; ) 
	'camEye gaxis 3 << + @ glevel - 
	swap /. | t
	-? ( drop 0 ; ) neg
	'v3hit 'camEye v3=
	'v3hit 'camForMouse rot v3+*
	|-- adjust for 1 plane, not the cube
	'camEye gaxis 3 << + @ glevel - +? ( drop 1 ; ) drop 
	1.0 'v3hit gaxis 3 << + +!
	1 ;
	
:camVelMove | ve 'v3 -- ve
	over 2dup 
	'camEye -rot v3+*
	'camTo  -rot v3+*
	makecam ;
	
	
|----------------
#xp #yp 
:movecam
	sdlb 4 <>? ( drop ; ) drop
	sdlx dup xp - 0.001 * 
	'cam_yaw +! 'xp !
	sdly dup yp - -0.001 * 
	cam_pit + |0.24 min -0.24 max 
	'cam_pit ! 'yp !
	makecam ;
	
:wheelcam
	SDLw 0? ( drop ; ) -0.4 *
	'camFor camVelMove drop ;

#va #vl #vu

:keycam
	va 1? ( 'camFor camVelMove ) drop
	vl 1? ( 'camRig camVelMove ) drop
	vu 1? ( 'camUp camVelMove ) drop
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


|----------------------------
#cntobjs 0

#vrx #vry #vrz
#sx 2.0 #sy 2.0 #sz 2.0	| escala por eje (punto fijo 5.5 en ss3d: paso 1/32)
#slock 1			| 1 = escala uniforme
#nrosprite 0

|--------------------------------------
#ballid

:getrot
	vrx $ffff and 16 << vry $ffff and or 16 << vrz $ffff and or ;
	
:snap32 | v -- v'	; redondea a 1/32 (lo que guarda ss3d)
	1024 + 11 >> 1 max 11 << ;

:applyscale | i --	; escala xyz de la instancia i
	sx snap32 'sx ! sy snap32 'sy ! sz snap32 'sz !
	sx sy sz pick3 ss3dscl3 drop ;

|--- snap a grilla (posicion) y a 15 grados (rotacion)
#snap 0			| 1 = snap activo
#gstep 0.25		| paso de grilla (multiplo de 1/16)

:snapg+ | v>=0 -- v'
	gstep 2/ + gstep / gstep * ;

:snapg | v -- v'		; redondea al paso de grilla si snap esta activo
	snap 0? ( drop ; ) drop
	-? ( neg snapg+ neg ; )
	snapg+ ;

:snaprot | v -- v'		; turnos 16.16 al multiplo de 1/24 de vuelta (15 grados)
	snap 0? ( drop ; ) drop
	$ffff and 24 * 32768 + 16 >> 65536 * 24 / ;

:chgstep gstep 2048 + 12 >> 1 max 12 << 'gstep ! ;

|--- objetos y seleccion
#sel -1			| objeto seleccionado (-1 = ninguno: los valores del panel son el "pincel")
#oldsel
#opos 0 0 0		| posicion del seleccionado (x y z)
#doff 0 0 0		| offset de agarre al arrastrar
#dhit 0 0 0
#drag 0			| 1 = arrastrando el seleccionado
#obrot * 8192		| rotacion de cada objeto (3 x 16 bits, igual que getrot)

:objcolor | i -- color	; seleccionado: tinte calido + glow
	sel =? ( drop $ffa04001 ; ) drop $ffffff00 ;

:objstyle | i --	; sprite, color y escala del panel en la instancia i
	sx nrosprite pick2 objcolor pick3 ss3dcs
	applyscale ;

:objrot | i --		; rotacion del panel en la instancia i
	getrot dup pick2 3 << 'obrot + !
	rxyz>q16 swap ss3dqua ;

:paintsel | i --	; color segun este seleccionada o no
	-? ( drop ; )
	dup objcolor over ss3dcol drop ;

:loadsel | i --		; carga los valores del objeto i en el panel
	dup ss3dxyz@ 'opos 16 + ! 'opos 8 + ! 'opos !
	dup ss3dspr@ 'nrosprite !
	dup ss3dscl@ 'sz ! 'sy ! 'sx !
	3 << 'obrot + @
	dup 32 >> $ffff and 'vrx !
	dup 16 >> $ffff and 'vry !
	$ffff and 'vrz ! ;

:selobj | i --		; selecciona la instancia i (-1 = ninguna)
	sel 'oldsel !
	'sel !
	oldsel paintsel
	sel paintsel
	sel -? ( drop ; ) loadsel ;

:selnext
	cntobjs 0? ( drop ; ) drop
	sel 1+ cntobjs mod selobj ;

|--- guardar / cargar escena: archivo SSC1 por slot (scene<n>.ssc)
| cabecera: 4 qwords (magic "SSC1", cantidad, n3dsprites, 0)
| objeto:   8 qwords (spr sx sy sz x y z rot) = 64 bytes
#slot 0
#status 0		| 0 nada, 1 guardado, 2 cargado, 3 sin archivo valido, 4 cargado con otro set de sprites
#stobjs 0
#t1 #t2 #t3

:scenefile | -- "filename"
	slot "scene%d.ssc" sprint ;

:rec3 | a b c --	; escribe 3 qwords en orden
	't3 ! 't2 ! 't1 ! t1 a!+ t2 a!+ t3 a!+ ;

:savescene
	here >a
	$31435353 a!+ cntobjs a!+ n3dsprites a!+ 0 a!+
	0 ( cntobjs <?
		dup ss3dspr@ a!+
		dup ss3dscl@ rec3
		dup ss3dxyz@ rec3
		dup 3 << 'obrot + @ a!+
		1+ ) drop
	here cntobjs 6 << 32 + scenefile save
	cntobjs 'stobjs ! 1 'status ! ;

#ldsz #ldn #ls0 #ls1 #ls2 #ls3 #lp1 #lp2 #lp3 #lr
:loadscene
	scenefile filexist 0? ( drop 3 'status ! ; ) drop
	here scenefile load here - 'ldsz !
	ldsz 32 <? ( drop 3 'status ! ; ) drop
	here @ $31435353 <>? ( drop 3 'status ! ; ) drop
	here 8 + @ ss3dmax min ldsz 32 - 6 >> min 'ldn !	| no mas que lo que hay en el archivo
	-1 'sel !
	here 32 + >a
	0 ( ldn <?
		a@+ n3dsprites 1- min 0 max 'ls0 !
		a@+ 'ls1 ! a@+ 'ls2 ! a@+ 'ls3 !
		a@+ 'lp1 ! a@+ 'lp2 ! a@+ 'lp3 !
		a@+ 'lr !
		ls1 ls0 $ffffff00 pick3 ss3dcs
		ls1 ls2 ls3 pick3 ss3dscl3
		lp1 lp2 lp3 pick3 ss3dxyz
		lr over 3 << 'obrot + !
		lr rxyz>q16 over ss3dqua
		dup dup ss3dobj
		1+ ) drop
	ldn 'cntobjs !
	ldn ss3dlen!
	ldn 'stobjs !
	2 'status !
	here 16 + @ n3dsprites <>? ( 4 'status ! ) drop ;

:slot- slot 1- 0 max 'slot ! ;
:slot+ slot 1+ 9 min 'slot ! ;

:sceneui
	slot "escena  slot %d" sprint uiLabelC
	'slot- "-" uiTBtn 'slot+ "+" uiTBtn 'savescene "save" uiTBtn 'loadscene "load" uiTBtn
	uiLn
	status 1 =? ( stobjs slot "guardado slot %d: %d obj" sprint uiLabelC )
	2 =? ( stobjs slot "cargado slot %d: %d obj" sprint uiLabelC )
	3 =? ( slot "slot %d: sin archivo valido" sprint uiLabelC )
	4 =? ( stobjs slot "cargado slot %d: %d obj (otros sprites)" sprint uiLabelC )
	drop ;

#deli
:dupobj | duplica el seleccionado, desplazado un ancho en x
	sel -? ( drop ; ) drop
	cntobjs ss3dmax >=? ( drop ; ) drop
	sel cntobjs ss3dcopy
	sel 3 << 'obrot + @ cntobjs 3 << 'obrot + !
	cntobjs dup ss3dobj
	cntobjs ss3dxyz@
	rot sx sel ss3dspr@ ss3dLX * 0.01 *. + snapg -rot
	cntobjs ss3dxyz
	1 'cntobjs +!
	cntobjs 1- selobj ;

:delobj | borra el seleccionado (conserva el orden de los demas)
	sel -? ( drop ; )
	'deli !
	deli ( cntobjs 1- <?
		dup 1+ over ss3dcopy
		dup 1+ 3 << 'obrot + @ over 3 << 'obrot + !
		1+ ) drop
	-1 'cntobjs +!
	deli ( cntobjs <? dup dup ss3dobj 1+ ) drop	| obj_id = indice
	cntobjs ss3dlen!
	-1 'sel !				| evita repintar el indice que ya no existe
	cntobjs 0? ( drop ; ) drop
	deli cntobjs <? ( selobj ; ) drop	| el siguiente ocupa el indice
	cntobjs 1- selobj ;

:addobj
	cntobjs ss3dmax >=? ( drop ; ) drop
	AdvMouse
	hiteye 0? ( drop ; ) drop
	cntobjs dup ss3dobj
	vrx snaprot 'vrx ! vry snaprot 'vry ! vrz snaprot 'vrz !
	cntobjs objstyle
	'v3hit >a 
	a@+ snapg
	a@+ cntobjs ss3difloor +
	a@+ snapg | x y z
	getrot dup cntobjs 3 << 'obrot + !
	rxyz>q16
	cntobjs ss3dxyzq
	1 'cntobjs +!
	cntobjs 1- selobj
	;
	
:modobj
	sel -? ( drop ; )		| sin seleccion solo cambia el pincel
	vrx snaprot 'vrx ! vry snaprot 'vry ! vrz snaprot 'vrz !
	dup objrot
	objstyle ;

|--- escala
:clampv | v -- v'
	0.125 max 16.0 min ;

:chgx slock 1? ( sx dup 'sy ! 'sz ! ) drop modobj ;
:chgy slock 1? ( sy dup 'sx ! 'sz ! ) drop modobj ;
:chgz slock 1? ( sz dup 'sx ! 'sy ! ) drop modobj ;

:scalestep | d --	; suma d a cada eje
	dup sx + clampv 'sx !
	dup sy + clampv 'sy !
	sz + clampv 'sz !
	modobj ;

:scalex2 sx 2* clampv 'sx ! sy 2* clampv 'sy ! sz 2* clampv 'sz ! modobj ;
:scalehalf sx 2/ clampv 'sx ! sy 2/ clampv 'sy ! sz 2/ clampv 'sz ! modobj ;
:scale1 1.0 dup dup 'sz ! 'sy ! 'sx ! modobj ;

|----------------------------------	
| scene
:makescene
|	ss3dset | x y z qxyzw scale color spr i --	
	;
	
|----------------------------------	
:totop
	'cam_yaw 0 cam_yaw 21 1.0 0 +vanim
	'cam_pit -0.25 cam_pit 21 1.0 0 +vanim
	'camEye >a
	a> 0.0 a@+ 21 1.0 0 +vanim | 'var ini fin ease dur. start --
	a> 12.0 a@+ 21 1.0 0 +vanim | 'var ini fin ease dur. start --
	a> 0.0 a@+ 21 1.0 0 +vanim | 'var ini fin ease dur. start --
	;
	
:tofront
	'cam_yaw 0 cam_yaw 21 1.0 0 +vanim
	'cam_pit 0 cam_pit 21 1.0 0 +vanim
	'camEye >a
	a> -10.0 a@+ 21 1.0 0 +vanim | 'var ini fin ease dur. start --
	a> 2.0 a@+ 21 1.0 0 +vanim | 'var ini fin ease dur. start --
	a> 0.0 a@+ 21 1.0 0 +vanim | 'var ini fin ease dur. start --
	;
	
:toside
	'cam_yaw -0.25 cam_yaw 21 1.0 0 +vanim
	'cam_pit 0 cam_pit 21 1.0 0 +vanim
	'camEye >a
	a> 0.0 a@+ 21 1.0 0 +vanim | 'var ini fin ease dur. start --
	a> 2.0 a@+ 21 1.0 0 +vanim | 'var ini fin ease dur. start --
	a> 10.0 a@+ 21 1.0 0 +vanim | 'var ini fin ease dur. start --
	;



#raydir 0 0 0

:raymouse | rayo del mouse (camForMouse apunta hacia la camara: se invierte)
	AdvMouse
	'raydir >a
	'camForMouse @ neg a!+
	'camForMouse 8 + @ neg a!+
	'camForMouse 16 + @ neg a! ;

|--- mover el seleccionado
#mvi
:movobj
	sel -? ( drop ; )
	'mvi !
	'opos @ 'opos 8 + @ 'opos 16 + @ mvi ss3dxyz ;

#nx #ny #nz
:nudge | dx dy dz --
	'nz ! 'ny ! 'nx !
	sel -? ( drop ; ) drop
	nx 1? ( 'opos @ nx + snapg 'opos ! ) drop
	ny 1? ( 'opos 8 + @ ny + snapg 'opos 8 + ! ) drop
	nz 1? ( 'opos 16 + @ nz + snapg 'opos 16 + ! ) drop
	movobj ;

#rg #keepg
:planehit | -- flag	; rayo del mouse contra el plano de trabajo por el objeto
	'raydir gaxis 3 << + @ 'rg !
	rg abs 655 <? ( drop 0 ; ) drop		| casi paralelo
	'opos gaxis 3 << + @ 'camEye gaxis 3 << + @ - rg /.
	-? ( drop 0 ; )				| el plano esta detras de la camara
	dup 'raydir @ *. 'camEye @ + 'dhit !
	dup 'raydir 8 + @ *. 'camEye 8 + @ + 'dhit 8 + !
	'raydir 16 + @ *. 'camEye 16 + @ + 'dhit 16 + !
	1 ;

:dragbegin | arranca el arrastre del seleccionado (si hay)
	0 'drag !
	sel -? ( drop ; ) drop
	planehit 0? ( drop ; ) drop
	'opos @ 'dhit @ - 'doff !
	'opos 8 + @ 'dhit 8 + @ - 'doff 8 + !
	'opos 16 + @ 'dhit 16 + @ - 'doff 16 + !
	1 'drag ! ;

:dragmouse
	drag 0? ( drop ; ) drop
	sdlb 1 nand? ( drop 0 'drag ! ; ) drop
	raymouse
	'opos gaxis 3 << + @ 'keepg !
	planehit 0? ( drop ; ) drop
	'dhit @ 'doff @ + 'opos !
	'dhit 8 + @ 'doff 8 + @ + 'opos 8 + !
	'dhit 16 + @ 'doff 16 + @ + 'opos 16 + !
	'opos @ snapg 'opos !
	'opos 8 + @ snapg 'opos 8 + !
	'opos 16 + @ snapg 'opos 16 + !
	keepg 'opos gaxis 3 << + !		| el eje del plano no cambia
	movobj ;

:pickmouse
	raymouse
	'camEye 'raydir cntobjs ss3dpick selobj
	dragbegin ;

:dnmouse
	sdlx 'xp ! sdly 'yp !
	sdlb 4 =? ( drop ; ) drop	| boton derecho: orbita
	pickmouse ;

:viewmouse
	uiFill
	sdlb 1 nand? ( 0 'drag ! ) drop	| boton izquierdo soltado
	immMouse
	1 =? ( wheelcam )		| over
	2 =? ( dnmouse )		| in
	3 =? ( dragmouse movecam )	| active
	drop ;

:movx 'opos @ snapg 'opos ! movobj ;
:movy 'opos 8 + @ snapg 'opos 8 + ! movobj ;
:movz 'opos 16 + @ snapg 'opos 16 + ! movobj ;

:posui
	"pos x" -30.0 30.0 'opos uiSliderfL uiEx? 1? ( movx ) drop
	"pos y" -30.0 30.0 'opos 8 + uiSliderfL uiEx? 1? ( movy ) drop
	"pos z" -30.0 30.0 'opos 16 + uiSliderfL uiEx? 1? ( movz ) drop ;

:prevobj
	nrosprite 1- 0 max 'nrosprite ! modobj ;
:nextobj
	nrosprite 1+ n3dsprites 1- min 'nrosprite ! modobj ;
	
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
	
	nrosprite ssnameid "%s" sprint uiLabelC
	
|	n3dsprites "ant:%h" sprint uiLabelC
	cntobjs sel "sel:%d  objs:%d" sprint uiLabelC
|	nrosprite "spr:%d" sprint uiLabelC

|	'raydir @+ swap @+ swap @ "%a %a %a" sprint uiLabelC
	
	"rot x" 0.0 1.0 'vrx uiSliderfL uiEx? 1? ( modobj ) drop
	"rot y" 0.0 1.0 'vry uiSliderfL uiEx? 1? ( modobj ) drop
	"rot z" 0.0 1.0 'vrz uiSliderfL uiEx? 1? ( modobj ) drop
	"escala" uiLabelC
	"X" 0.125 16.0 'sx uiSliderfL uiEx? 1? ( chgx ) drop
	"Y" 0.125 16.0 'sy uiSliderfL uiEx? 1? ( chgy ) drop
	"Z" 0.125 16.0 'sz uiSliderfL uiEx? 1? ( chgz ) drop
	'slock "uniforme" uiFToggle
	'scalex2 "x2" uiTBtn
	'scalehalf "/2" uiTBtn
	'scale1 "1:1" uiTBtn
	uiLn
	'snap "snap pos/rot 15" uiFToggle
	"grilla" 0.0625 2.0 'gstep uiSliderfL uiEx? 1? ( chgstep ) drop
	sel 0 >=? ( posui ) drop
	'prevobj "<<" uiTBtn	
	'nextobj ">>" uiTBtn	
	'dupobj "dup" uiTBtn
	'delobj "del" uiTBtn
	uiLn
	sceneui
	viewmouse
	|-1.0 1.0 'vrx uiprogressf
|	'vrl 8 ss3names uiList
|	uiEx? 1? ( vrl 'nrosprite ! ) drop
	;
	
:hud
	fini
	immIni
	keycam
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

	<up> =? ( nextobj )
	<dn> =? ( prevobj )
	<spc> =? ( addobj )
	<tab> =? ( selnext )
	<ins> =? ( dupobj ) <del> =? ( delobj )
	<f5> =? ( savescene ) <f9> =? ( loadscene )
	<le> =? ( gstep neg 0 0 nudge ) <ri> =? ( gstep 0 0 nudge )
	<home> =? ( 0 0 gstep neg nudge ) <end> =? ( 0 0 gstep nudge )
	<pgup> =? ( 0.25 scalestep ) <pgdn> =? ( -0.25 scalestep )
	drop
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
	|"media/ss/city" 
|	"media/ss/sprites"
	"media/ss/dino" 
	dup 1024 ss3dload
	ss3loadnames
	
	"ball" ss3idname 
	|dup .d .println
	'ballid !
	;
	
:viewresize 
	sh sw rl_resizewin 
	fixFontResize ;

: | <<<<<<<< Boot

	"Scene r3dv" 
	|1024 768 GLini GLInfo
	GlInifull
	
	$fff vaini
	
	rlhud
	load3d
	rl_init 
	1 rl_grid_init
	
	'viewresize SDLeventR
	lightsun
	makeCam
	
	tofront
	|$020902 GLpaper
	'main SDLshow
	
	rl_grid_free 
	rl_shutdown
	SS3Dshutdown
	GLend
	;