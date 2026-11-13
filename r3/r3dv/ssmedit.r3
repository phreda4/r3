|MEM 64
| ssmedit r3dv - editor de multi3dsprite (.ssm): nodos, huesos, poses y clips
| PHREDA 2026
|
| Organizado como 3dssed.r3. Carga un .ssv (sprites) y el .ssm del slot elegido (edit<n>.ssm).
| Cada nodo = un sprite del .ssv (o un hueso sin voxeles) con padre, posicion (voxeles), rotacion y
| escala LOCALES al padre. Marcadores en el origen de cada nodo (celeste; rojo = seleccionado).
|
| MOUSE   boton derecho (arrastrar) = mirar | rueda = zoom
|         clic izquierdo = seleccionar nodo (sprite o marcador) | arrastrar = mover el nodo en el plano
|         de trabajo (X / Y / Z); con snap se redondea a la grilla
| TECLAS  W S A D Q E camara | TAB nodo siguiente | ESPACIO agregar nodo bajo el mouse
|         INS duplicar | SUPR borrar hoja | flechas / INICIO FIN = empujar x y z | RE PAG AV PAG = escala
|         F5 guardar slot | F9 cargar slot
| POSES Y CLIPS  "editar pose": los valores editan la pose actual en vez del armado del nodo.
|         clip = keys (pose, ms) con loop; "ver clip" / "reproducir" previsualizan.

^r3/lib/rand.r3
^r3/lib/mem.r3

^r3/util/varanim.r3
^r3/util/glgfx.r3
^r3/util/glimm.r3

^./renderlib.r3
^./rlshapes.r3
^./ss3d.r3
^./ss3dshadow.r3
^./ssmodel.r3
^./rlgrid.r3

#SSVFILE "media/ssv/vox"

|----------------------
| Camera controls
#cam_yaw  0
#cam_pit  0
#camEye -4.5 1.5 0.0
#camTo  0.0 1.5  0.0
#camUp  0.0 1.0  0.0
#camFor 0 0 0
#camRig 0 0 0
#camViewUp 0 0 0

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
	cy sp *. neg a!+
	cp a!+
	sy sp *. neg a!
	'camEye 'camTo 'camUp rl_camera ;

:camVelMove | ve 'v3 -- ve
	over 2dup
	'camEye -rot v3+*
	'camTo  -rot v3+*
	makecam ;

#xp #yp
:movecam
	sdlb 4 <>? ( drop ; ) drop
	sdlx dup xp - 0.001 *
	'cam_yaw +! 'xp !
	sdly dup yp - -0.001 *
	cam_pit + 'cam_pit ! 'yp !
	makecam ;

:wheelcam
	SDLw 0? ( drop ; ) -0.4 *
	'camFor camVelMove drop ;

#va #vl #vu
:keycam
	va 1? ( 'camFor camVelMove ) drop
	vl 1? ( 'camRig camVelMove ) drop
	vu 1? ( 'camUp camVelMove ) drop ;

| vistas animadas
:totop
	'cam_yaw 0 cam_yaw 21 1.0 0 +vanim
	'cam_pit -0.25 cam_pit 21 1.0 0 +vanim
	'camEye >a
	a> 0.0 a@+ 21 1.0 0 +vanim
	a> 6.0 a@+ 21 1.0 0 +vanim
	a> 0.0 a@+ 21 1.0 0 +vanim ;
:tofront
	'cam_yaw 0 cam_yaw 21 1.0 0 +vanim
	'cam_pit 0 cam_pit 21 1.0 0 +vanim
	'camEye >a
	a> -4.5 a@+ 21 1.0 0 +vanim
	a> 1.5 a@+ 21 1.0 0 +vanim
	a> 0.0 a@+ 21 1.0 0 +vanim ;
:toside
	'cam_yaw -0.25 cam_yaw 21 1.0 0 +vanim
	'cam_pit 0 cam_pit 21 1.0 0 +vanim
	'camEye >a
	a> 0.0 a@+ 21 1.0 0 +vanim
	a> 1.5 a@+ 21 1.0 0 +vanim
	a> 4.5 a@+ 21 1.0 0 +vanim ;

|----------------------
| sol (azimut y altura en vueltas) y luces
#sun_az 0.625
#sun_el 0.237
#shadowon 1

:setsun
	sun_el 0.01 max 0.25 min 'sun_el !
	sun_el cos sun_az cos *.
	sun_el sin
	sun_el cos sun_az sin *.
	1.0 1.0 1.0 1.0 ss3dsun ;

:light
	0.3
	1.0 1.0 1.0
	'camEye >a
	a@+ a@+ 1.0 + a@
	rl_point_light ;

|----------------------
| snap a grilla (posicion, en voxeles) y a 15 grados (rotacion)
#snap 0
#gstep 1.0

:snapg+ | v>=0 -- v'
	gstep 2/ + gstep / gstep * ;
:snapg | v -- v'		; redondea al paso de grilla si snap esta activo
	snap 0? ( drop ; ) drop
	-? ( neg snapg+ neg ; )
	snapg+ ;
:chgstep gstep 2048 + 12 >> 1 max 12 << 'gstep ! ;

#rstep 0.0417			| paso de rotacion en vueltas (1/24 = 15 grados)
:rotstep | -- vueltas
	snap 1? ( drop 2731 ; ) drop rstep ;

|----------------------
| modelo y seleccion
#dd #mi				| descripcion e instancia
#sel -1				| nodo seleccionado
#cnt #ccnt			| contadores para nombres nuevos
#ni #pp #na
#px #py #pz #sc			| transformacion que se edita (voxeles 16.16)
#ssel 0				| sprite elegido para agregar / asignar (-1 = hueso)
#psel -1			| padre elegido
#hlcol $ffd09000
#mx #my #mz #mk
#rpx 0 #rpy 1.5 #rpz 0		| posicion y escala de la raiz del modelo en el mundo
#rsc 3.0

#editpose 0 #pcur 0		| editar la pose pcur en vez del armado
#ccur 0 #kms 0 #ksel 0 #cloop 1 #ksl
#showclip 0 #playing 0 #tm 0	| vista previa del clip

:name@ | i -- adr
	ssmo_nadr 44 + d@ ssmo_name ;
:sprname | spr -- "nombre"
	-? ( drop "hueso" ; ) ssnameid ;

:nsel? | -- 1/0
	sel -? ( drop 0 ; )
	ssmo_nodes <? ( drop 1 ; ) drop 0 ;
:pose? | -- 1/0
	pcur -? ( drop 0 ; )
	ssmo_poses <? ( drop 1 ; ) drop 0 ;
:clip? | -- 1/0
	ccur -? ( drop 0 ; )
	ssmo_clips <? ( drop 1 ; ) drop 0 ;
:posemode? | -- 1/0
	editpose 0? ( ; ) drop pose? ;

:clampsel
	sel ssmo_nodes 1- min -1 max 'sel !
	psel ssmo_nodes 1- min -1 max 'psel !
	ssel n3dsprites 1- min -1 max 'ssel !
	pcur ssmo_poses 1- min 0 max 'pcur !
	ccur ssmo_clips 1- min 0 max 'ccur !
	clip? 0? ( drop 0 'ksel ! ; ) drop
	ksel ccur ssmo_ckeys 1- min 0 max 'ksel ! ;

:curentry | -- adr		; transformacion editada: x y z qx qy qz qw s (pose actual o armado del nodo)
	posemode? 1? ( drop pcur sel ssmo_pnode ; ) drop
	sel ssmo_nadr 8 + ;

:syncvars
	nsel? 0? ( drop ; ) drop
	curentry 'na !
	na d@ 'px ! na 4 + d@ 'py ! na 8 + d@ 'pz ! na 28 + d@ 'sc ! ;
:applypos
	nsel? 0? ( drop ; ) drop
	curentry 'na !
	px na d! py na 4 + d! pz na 8 + d! ;
:applysc
	nsel? 0? ( drop ; ) drop
	sc 0.05 max curentry 28 + d! ;

#nx #ny #nz
:nudge | dx dy dz --		; empuja el nodo (con snap)
	'nz ! 'ny ! 'nx !
	nsel? 0? ( drop ; ) drop
	syncvars
	px nx + snapg 'px ! py ny + snapg 'py ! pz nz + snapg 'pz !
	applypos ;
:scalestep | d --
	nsel? 0? ( drop ; ) drop
	syncvars sc + 0.1 max 'sc ! applysc ;

:selprev sel 1- ssmo_nodes 1- min -1 max 'sel ! ;
:selnext
	ssmo_nodes 0? ( drop ; ) drop
	sel 1+ ssmo_nodes mod 'sel ! ;

|----------------------
| escena por slot: media/ssv/edit<n>.ssm
#slot 0
#status 0		| 0 nada, 1 guardado, 2 cargado, 3 sin archivo valido
:slotfile | -- "filename"
	slot "media/ssv/edit%d.ssm" sprint ;

:newinst
	dd ssmo_inst 'mi !
	rsc mi ssmo_rscale
	rpx rpy rpz mi ssmo_rpos ;

:savescene
	slotfile ssmo_save 1 'status ! ;

:loadscene
	slotfile ssmo_load 0? ( drop 3 'status ! ; )
	'dd !
	ssmo_nodes 'cnt ! ssmo_clips 'ccnt !
	newinst
	-1 'sel ! 0 'pcur ! 0 'ccur ! 0 'editpose !
	2 'status ! ;

:slot- slot 1- 0 max 'slot ! ;
:slot+ slot 1+ 9 min 'slot ! ;

:initmodel
	slotfile ssmo_load 0? ( drop
		512 8 8 64 ssmo_new
		"vox.ssv" ssmo_ssv! )
	'dd !
	ssmo_nodes 'cnt ! ssmo_clips 'ccnt !
	newinst
	0 'sel !
	ssmo_nodes 0? ( -1 'sel ! ) drop ;

|----------------------
| operaciones sobre nodos
:addn | padre -- nodo/-1
	ssel swap ssmo_node 'ni !
	ni -? ( drop -1 ; ) drop
	1 'cnt +! cnt "nodo%d" sprint ni ssmo_nname
	ni 'sel !
	ni ;

:b_addchild sel addn drop ;
:b_addroot -1 addn drop ;

:dupw | -- voxeles		; desplazamiento en x del duplicado: un ancho del sprite
	sel ssmo_nadr d@ -? ( drop 4.0 ; ) ss3dLX 16 << ;

:b_dup
	nsel? 0? ( drop ; ) drop
	sel ssmo_ndup -? ( drop ; ) 'ni !
	1 'cnt +! cnt "nodo%d" sprint ni ssmo_nname
	dupw 'nx !
	ni ssmo_nadr 8 + 'na ! na d@ nx + snapg na d!
	0 ( ssmo_poses <? dup ni ssmo_pnode dup d@ nx + swap d! 1+ ) drop
	ni 'sel ! ;

:b_del
	nsel? 0? ( drop ; ) drop
	sel ssmo_nadr 4 + d@ 'pp !
	sel ssmo_ndel 1? ( drop pp 'sel ! ; ) drop ;

:b_setpar
	nsel? 0? ( drop ; ) drop
	psel sel ssmo_npar! 1? ( drop sel ssmo_moved 'sel ! ; ) drop ;

:b_setspr
	nsel? 0? ( drop ; ) drop
	ssel sel ssmo_nspr! ;

:b_rrot
	nsel? 0? ( drop ; ) drop
	curentry 'na !
	0 na 12 + d! 0 na 16 + d! 0 na 20 + d! 1.0 na 24 + d! ;
:b_rx+ nsel? 0? ( drop ; ) drop 1.0 0 0 rotstep curentry ssmo_trotate ;
:b_rx- nsel? 0? ( drop ; ) drop 1.0 0 0 rotstep neg curentry ssmo_trotate ;
:b_ry+ nsel? 0? ( drop ; ) drop 0 1.0 0 rotstep curentry ssmo_trotate ;
:b_ry- nsel? 0? ( drop ; ) drop 0 1.0 0 rotstep neg curentry ssmo_trotate ;
:b_rz+ nsel? 0? ( drop ; ) drop 0 0 1.0 rotstep curentry ssmo_trotate ;
:b_rz- nsel? 0? ( drop ; ) drop 0 0 1.0 rotstep neg curentry ssmo_trotate ;

| poses y clips
:b_newpose
	ssmo_pose -? ( drop ; ) 'pcur ! 1 'editpose ! ;
:b_delpose
	pose? 0? ( drop ; ) drop
	pcur ssmo_pdel drop ;
:b_newclip
	1 'ccnt +! ccnt "clip%d" sprint 1 ssmo_clip -? ( drop ; ) 'ccur ! ;
:b_delclip
	clip? 0? ( drop ; ) drop
	ccur ssmo_cdel ;
:b_addkey
	clip? 0? ( drop ; ) drop
	pose? 0? ( drop ; ) drop
	pcur kms ccur ssmo_kadd 'ksel ! ;
:b_delkey
	clip? 0? ( drop ; ) drop
	ksel ccur ssmo_kdel ;

|----------------------
| vista: armado / pose / clip
:viewplay | -- 1/0		; vista previa del clip actual
	showclip 0? ( ; ) drop
	clip? 0? ( ; ) drop
	playing 1? ( 16 'tm +! ) drop
	ccur tm mi ssmo_play 1 ;

:updview
	viewplay 1? ( drop ; ) drop
	posemode? 1? ( drop pcur mi ssmo_pose! ; ) drop
	mi ssmo_bind ;

|----------------------
| rayo del mouse, seleccion y plano de trabajo
#raydir 0 0 0
#xdir #ydir
#bt #bi #pk #nh #dx #dy #dz #tt #ex2 #ey2 #ez2
#i2n * 4096
#ik #ninst

:raymouse | x y --		; rayo (origen camEye) hacia el pixel x y, en raydir
	2* fix. sh / 1.0 - camFov *. 'ydir !
	2* fix. sw / 1.0 - camAsp *. camFov *. 'xdir !
	'raydir >a
	'camFor @ 'camRig @ xdir *. + 'camViewUp @ ydir *. + a!+
	'camFor 8 + @ 'camRig 8 + @ xdir *. + 'camViewUp 8 + @ ydir *. + a!+
	'camFor 16 + @ 'camRig 16 + @ xdir *. + 'camViewUp 16 + @ ydir *. + a!
	'raydir v3Nor
	'raydir >a a@ neg a!+ a@ neg a!+ a@ neg a! ;

:mapinst					| instancia ss3d -> nodo (los nodos con sprite, en orden)
	0 'ik !
	0 ( ssmo_nodes <? dup ssmo_nadr d@ 0 >=? ( over ik 2 << 'i2n + d! 1 'ik +! ) drop 1+ ) drop ;

:spritehit
	'camEye 'raydir ninst ss3dpick 'pk !
	pk -? ( drop ; ) drop
	'camEye 'raydir pk ss3dhit 0 <? ( drop ; ) 'bt !
	pk 2 << 'i2n + d@ 'bi ! ;

:nodehit | i --		; marcador del nodo contra el rayo
	dup 'nh ! mi ssmo_wpos
	'camEye 16 + @ - 'dz ! 'camEye 8 + @ - 'dy ! 'camEye @ - 'dx !
	dx 'raydir @ *. dy 'raydir 8 + @ *. + dz 'raydir 16 + @ *. + 'tt !
	tt 0 <=? ( drop ; ) drop
	dx 'raydir @ tt *. - 'ex2 !
	dy 'raydir 8 + @ tt *. - 'ey2 !
	dz 'raydir 16 + @ tt *. - 'ez2 !
	ex2 dup *. ey2 dup *. + ez2 dup *. + 330 >? ( drop ; ) drop
	tt bt <? ( tt 'bt ! nh 'bi ! ) drop ;

:pickray | -- nodo/-1		; nodo mas cercano al rayo en raydir
	$7fffffffffff 'bt ! -1 'bi !
	spritehit
	0 ( ssmo_nodes <? dup nodehit 1+ ) drop
	bi ;

| plano de trabajo: perpendicular al eje gaxis (0 x, 1 y, 2 z), a la altura pcoord
#gsel 3				| 0 x | 1 y | 2 z | 3 automatico (eje al que mira la camara)
#gaxis 1
#pcoord 0
#bestv
#dpos 0 0 0
#doff 0 0 0
#dhit 0 0 0
#drag 0
#rg
#tgx #tgy #tgz

:setgaxis				| elige el eje del plano de trabajo
	gsel 3 <? ( 'gaxis ! ; ) drop
	0 'gaxis !
	'camFor @ abs 'bestv !
	'camFor 8 + @ abs bestv >? ( dup 'bestv ! 1 'gaxis ! ) drop
	'camFor 16 + @ abs bestv >? ( 2 'gaxis ! ) drop ;

:planehit | -- flag		; rayo del mouse contra el plano de trabajo
	'raydir gaxis 3 << + @ 'rg !
	rg abs 655 <? ( drop 0 ; ) drop
	pcoord 'camEye gaxis 3 << + @ - rg /.
	-? ( drop 0 ; )
	dup 'raydir @ *. 'camEye @ + 'dhit !
	dup 'raydir 8 + @ *. 'camEye 8 + @ + 'dhit 8 + !
	'raydir 16 + @ *. 'camEye 16 + @ + 'dhit 16 + !
	1 ;

:dragbegin | arranca el arrastre del seleccionado (si hay)
	0 'drag !
	setgaxis
	nsel? 0? ( drop ; ) drop
	sel mi ssmo_wpos 'dpos 16 + ! 'dpos 8 + ! 'dpos !
	'dpos gaxis 3 << + @ 'pcoord !
	planehit 0? ( drop ; ) drop
	'dpos @ 'dhit @ - 'doff !
	'dpos 8 + @ 'dhit 8 + @ - 'doff 8 + !
	'dpos 16 + @ 'dhit 16 + @ - 'doff 16 + !
	1 'drag ! ;

:dragmove | arrastra el nodo al punto donde el rayo (raydir) corta el plano de trabajo
	planehit 0? ( drop ; ) drop
	'dhit @ 'doff @ + 'tgx !
	'dhit 8 + @ 'doff 8 + @ + 'tgy !
	'dhit 16 + @ 'doff 16 + @ + 'tgz !
	tgx tgy tgz sel mi ssmo_w2l
	snapg 'pz ! snapg 'py ! snapg 'px !
	applypos ;

:dragmouse
	drag 0? ( drop ; ) drop
	sdlb 1 nand? ( drop 0 'drag ! ; ) drop
	sdlx sdly raymouse dragmove ;

:addat | agrega un nodo hijo del seleccionado bajo el mouse (en el plano de trabajo)
	setgaxis
	sel addn -? ( drop ; ) drop
	sdlx sdly raymouse
	sel -? ( drop 'rpx gaxis 3 << + @ ) ( drop sel mi ssmo_wpos 'tgz ! 'tgy ! 'tgx ! 'tgx gaxis 3 << + @ )
	'pcoord !
	planehit 0? ( drop ; ) drop
	'dhit @ 'dhit 8 + @ 'dhit 16 + @ sel mi ssmo_w2l
	snapg 'pz ! snapg 'py ! snapg 'px !
	px py pz sel ssmo_npos ;

:pickmouse
	sdlx sdly raymouse pickray 'sel ! dragbegin ;
:dnmouse
	sdlx 'xp ! sdly 'yp !
	sdlb 4 =? ( drop ; ) drop
	pickmouse ;

:viewmouse
	sdlb 1 nand? ( 0 'drag ! ) drop
	immMouse
	1 =? ( wheelcam )
	2 =? ( dnmouse )
	3 =? ( dragmouse movecam )
	drop ;

|----------------------
| escena
:mcol | i -- color
	sel =? ( drop $ffff3020 ; ) drop $30c0ff20 ;

:marker | i --
	dup 'mk ! mi ssmo_wpos 'mz ! 'my ! 'mx !
	matini 0.03 dup dup matscale mx my mz matpos
	mk mcol draw_cube ;

:drawscene
	updview
	sel hlcol mi ssmo_hilite
	'ss3dset 0 mi ssmo_draw dup 'ninst ! ss3dlen!
	mapinst
	0 ( ssmo_nodes <? dup marker 1+ ) drop ;

|----------------------
| interfaz
:modelabel | -- "texto"
	posemode? 1? ( drop "editando POSE" ; ) drop "editando ARMADO" ;

:nodeinfo
	nsel? 0? ( drop "sin nodo seleccionado" uiLabelC ; ) drop
	sel ssmo_nadr 4 + d@ sel ssmo_nadr d@ sprname sel name@
	"%s  spr:%s  padre:%d" sprint uiLabelC ;

:ui_model
	"MULTISPRITE" uiLabelC
	n3dsprites ssmo_nodes "nodos: %d   sprites del .ssv: %d" sprint uiLabelC
	modelabel uiLabelC
	syncvars
	ssmo_nodes 1? ( "nodo" 0 ssmo_nodes 1- 'sel uiSlideriL ) drop
	nodeinfo
	"x" -48.0 48.0 'px uiSliderfL uiEx? 1? ( px snapg 'px ! applypos ) drop
	"y" -48.0 48.0 'py uiSliderfL uiEx? 1? ( py snapg 'py ! applypos ) drop
	"z" -48.0 48.0 'pz uiSliderfL uiEx? 1? ( pz snapg 'pz ! applypos ) drop
	"escala" 0.1 3.0 'sc uiSliderfL uiEx? 1? ( applysc ) drop
	"paso rot (vueltas)" 0.01 0.25 'rstep uiSliderfL
	'b_rx+ "X+" uiNBtn 'b_rx- "X-" uiNBtn
	'b_ry+ "Y+" uiNBtn 'b_ry- "Y-" uiNBtn
	'b_rz+ "Z+" uiNBtn 'b_rz- "Z-" uiNBtn
	'b_rrot "reset rot" uiNBtn
	uiLn
	'snap "snap pos/rot 15" uiToggle
	"grilla (voxeles)" 0.0625 8.0 'gstep uiSliderfL uiEx? 1? ( chgstep ) drop
	"plano: 0 x  1 y  2 z  3 auto" uiLabelC
	"-" 0 3 'gsel uiSlideriL
	uiLn ;

:ui_edit
	"AGREGAR / CAMBIAR" uiLabelC
	"sprite (-1 = hueso)" -1 n3dsprites 1- 'ssel uiSlideriL
	ssel sprname "%s" sprint uiLabelC
	'b_addchild "hijo del nodo" uiNBtn
	'b_addroot "raiz" uiNBtn
	'b_setspr "asignar sprite" uiNBtn
	uiLn
	"padre (-1 = raiz)" -1 ssmo_nodes 1- 'psel uiSlideriL
	'b_setpar "asignar padre" uiNBtn
	'b_dup "duplicar" uiNBtn
	'b_del "borrar (hoja)" uiNBtn
	uiLn ;

:keyline | k --
	dup dup 'ksl ! ccur ssmo_ckey@ ksl "%d: t=%d pose=%d" sprint uiLabelC ;

:clipinfo
	ccur ssmo_cloop@ 'cloop !
	'cloop "loop" uiToggle
	cloop ccur ssmo_cloop!
	ccur ssmo_ckeys ccur ssmo_cname@ "%s : %d keys" sprint uiLabelC
	0 ( ccur ssmo_ckeys 6 min <? dup keyline 1+ ) drop
	ccur ssmo_ckeys 1? ( "key a borrar" 0 ccur ssmo_ckeys 1- 'ksel uiSlideriL ) drop ;

:ui_anim
	"POSES Y CLIPS" uiLabelC
	ssmo_clips ssmo_poses "poses: %d   clips: %d" sprint uiLabelC
	'editpose "editar pose" uiToggle
	ssmo_poses 1? ( "pose actual" 0 ssmo_poses 1- 'pcur uiSlideriL ) drop
	'b_newpose "nueva pose" uiNBtn
	'b_delpose "borrar pose" uiNBtn
	uiLn
	ssmo_clips 1? ( "clip" 0 ssmo_clips 1- 'ccur uiSlideriL ) drop
	clip? 1? ( clipinfo ) drop
	'b_newclip "nuevo clip" uiNBtn
	'b_delclip "borrar clip" uiNBtn
	uiLn
	"tiempo del key (ms)" 0 3000 'kms uiSlideriL
	'b_addkey "agregar key (pose actual)" uiNBtn
	'b_delkey "borrar key" uiNBtn
	uiLn
	'showclip "ver clip" uiToggle
	'playing "reproducir" uiToggle
	"t (ms)" 0 3000 'tm uiSlideriL
	uiLn ;

:sceneui
	slot "escena  slot %d" sprint uiLabelC
	'slot- "-" uiNBtn 'slot+ "+" uiNBtn 'savescene "save" uiNBtn 'loadscene "load" uiNBtn
	uiLn
	status 1 =? ( slot "guardado slot %d" sprint uiLabelC )
	2 =? ( ssmo_nodes slot "cargado slot %d: %d nodos" sprint uiLabelC )
	3 =? ( slot "slot %d: sin archivo valido" sprint uiLabelC )
	drop ;

:ui_sun
	"SOL" uiLabelC
	'rl_ao_on "SAO" uiToggle
	'shadowon "sombras" uiToggle uiEx? 1? ( shadowon ss3dshadow! ) drop
	"azimut" 0.0 1.0 'sun_az uiSliderfL uiEx? 1? ( setsun ) drop
	"altura" 0.0 0.25 'sun_el uiSliderfL uiEx? 1? ( setsun ) drop ;

:interface
	1 'fscale !
	$ffffffff 'fcolor !

	uiFull
	0.05 %ch uiN
	$1f0000ff 'fcolor !
	uiWinBox frect
	$ffffffff 'fcolor !
	'exit "Exit" uiNBtn
	'selprev "<" uiNBtn
	'selnext ">" uiNBtn
	'totop "T" uiNBtn
	'tofront "F" uiNBtn
	'toside "S" uiNBtn

	0.22 %w uiO
	$1f00ff00 'fcolor !
	uiWinBox frect
	$ffffffff 'fcolor !
	ui_model
	ui_edit

	0.22 %w uiE
	$1fff0000 'fcolor !
	uiWinBox frect
	$ffffffff 'fcolor !
	ui_anim
	sceneui
	ui_sun

	uiRest uiWinBox immBox
	viewmouse ;

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

	<tab> =? ( selnext )
	<spc> =? ( addat )
	<ins> =? ( b_dup ) <del> =? ( b_del )
	<f5> =? ( savescene ) <f9> =? ( loadscene )
	<le> =? ( gstep neg 0 0 nudge ) <ri> =? ( gstep 0 0 nudge )
	<up> =? ( 0 gstep 0 nudge ) <dn> =? ( 0 gstep neg 0 nudge )
	<home> =? ( 0 0 gstep neg nudge ) <end> =? ( 0 0 gstep nudge )
	<pgup> =? ( 0.1 scalestep ) <pgdn> =? ( -0.1 scalestep )
	drop ;

:main
	vupdate
	makecam
	clampsel
	rl_frame_begin
	drawscene
	SS3Ddraw
	draw_grid
	light
	rl_frame_end
	hud
	GLUpdate ;

:viewresize
	sh sw rl_resizewin
	fixFontResize ;

: | <<<<<<<< Boot
	"ssmedit r3dv" 1024 768 GLini GLInfo
	$fff vaini
	glgfx
	rl_init
	IniShapes
	'SSVFILE dup 256 ss3dload ss3loadnames
	initmodel
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
	SS3Dshutdown
	endShapes
	rl_shutdown
	GLend ;
