|MEM 64
| ssmedit r3dv - editor de multi3dsprite (.ssm): nodos, huesos y posiciones relativas
| PHREDA 2026
|
| Carga un .ssv (sprites) y el .ssm de trabajo (si no existe, arranca vacio).
| Cada nodo = un sprite del .ssv (o un hueso sin voxeles) con padre, posicion, rotacion y escala
| LOCALES al padre (posicion en voxeles). El nodo seleccionado se resalta y se dibujan marcadores
| en el origen de cada nodo (celeste = nodo, rojo = seleccionado).
|
| mouse: arrastrar = mirar, rueda = zoom, CLIC = seleccionar nodo (sprite o marcador de hueso)
| W S A D Q E = mover camara | flechas izq/der = nodo anterior/siguiente | SUPR = borrar nodo hoja | F5 = guardar
| POSES Y CLIPS: "editar pose" hace que x y z / escala / rotacion editen la pose actual en vez del
|   nodo (armado). Una pose = transformacion local de TODOS los nodos. Un clip = lista de keys
|   (pose, ms) con loop; "reproducir" previsualiza el clip actual.
| rotacion: botones X Y Z +/- giran el nodo en su eje local en pasos de "paso" (en vueltas)
| "padre" + [asignar padre]: cambia el padre (sin ciclos) y reordena la lista de nodos

^r3/lib/rand.r3
^r3/lib/mem.r3

^r3/util/varanim.r3
^r3/util/glgfx.r3
^r3/util/glimm.r3

^./renderlib.r3
^./rlshapes.r3
^./ss3d.r3
^./ssmodel.r3
^./rlgrid.r3

#SSVFILE "media/ssv/vox"
#SSMFILE "media/ssv/edit.ssm"

| Camera controls
#cam_yaw  0
#cam_pit  0
#camEye -4.5 1.5 0.0
#camTo  0.0 1.5  0.0
#camUp  0.0 1.0  0.0
#camAdv 0 0 0
#camLat 0 0 0
#camViewUp 0 0 0

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
	'camViewUp >a
	cy sp *. neg a!+
	cp a!+
	sy sp *. neg a!
	'camEye 'camTo 'camUp rl_camera ;

#xp #yp #px0 #py0 #dragged
:movecam
	sdlx px0 - abs sdly py0 - abs + 4 >? ( 1 'dragged ! ) drop
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

#fsun [
-0.5 -1.0 -0.5 0
 1.0 0.9 0.8 1.2
 ]

:light
	0.3
	1.0 1.0 1.0
	'camEye >a
	a@+ a@+ 1.0 + a@
	rl_point_light ;

|----------------------------------
| modelo
#dd #mi				| descripcion e instancia
#sel -1				| nodo seleccionado
#cnt #ccnt			| contadores para nombres nuevos
#ni #pp #na
#px #py #pz #sc			| transformacion que se edita (voxeles 16.16)
#ssel 0				| sprite elegido para agregar / asignar (-1 = hueso)
#psel -1			| padre elegido
#rstep 0.0625			| paso de rotacion en vueltas
#hlcol $ffd09000
#mx #my #mz #mk
| poses y clips
#editpose 0 #pcur 0		| editar la pose pcur en vez del armado
#ccur 0 #kms 0 #ksel 0 #cloop 1 #ksl
#showclip 0 #playing 0 #tm 0	| vista previa del clip

:name@ | i -- adr
	ssmo_nadr 44 + d@ ssmo_name ;

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

:addn | padre --
	ssel swap ssmo_node 'ni !
	ni -? ( drop ; ) drop
	1 'cnt +! cnt "nodo%d" sprint ni ssmo_nname
	ni 'sel ! ;

:b_addchild sel addn ;
:b_addroot -1 addn ;

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
:b_rx+ nsel? 0? ( drop ; ) drop 1.0 0 0 rstep curentry ssmo_trotate ;
:b_rx- nsel? 0? ( drop ; ) drop 1.0 0 0 rstep neg curentry ssmo_trotate ;
:b_ry+ nsel? 0? ( drop ; ) drop 0 1.0 0 rstep curentry ssmo_trotate ;
:b_ry- nsel? 0? ( drop ; ) drop 0 1.0 0 rstep neg curentry ssmo_trotate ;
:b_rz+ nsel? 0? ( drop ; ) drop 0 0 1.0 rstep curentry ssmo_trotate ;
:b_rz- nsel? 0? ( drop ; ) drop 0 0 1.0 rstep neg curentry ssmo_trotate ;

:b_save 'SSMFILE ssmo_save ;

:selprev sel 1- ssmo_nodes 1- min -1 max 'sel ! ;
:selnext sel 1+ ssmo_nodes 1- min -1 max 'sel ! ;

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

:initmodel
	'SSMFILE ssmo_load 0? ( drop
		512 8 8 64 ssmo_new
		"vox.ssv" ssmo_ssv! )
	'dd !
	ssmo_nodes 'cnt ! ssmo_clips 'ccnt !
	dd ssmo_inst 'mi !
	3.0 mi ssmo_rscale
	0 1.5 0 mi ssmo_rpos
	0 'sel !
	ssmo_nodes 0? ( -1 'sel ! ) drop ;

|----------------------------------
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

|----------------------------------
| seleccion con el mouse: sprites (ss3dhit) y marcadores de hueso (distancia rayo-punto)
#raydir 0 0 0
#xdir #ydir
#bt #bi #pk #nh #dx #dy #dz #tt #ex2 #ey2 #ez2
#i2n * 4096
#ik #ninst

:raymouse | x y --		; rayo (origen camEye) hacia el pixel x y, en raydir
	2* fix. sh / 1.0 - camFov *. 'ydir !
	2* fix. sw / 1.0 - camAsp *. camFov *. 'xdir !
	'raydir >a
	'camAdv @ 'camLat @ xdir *. + 'camViewUp @ ydir *. + a!+
	'camAdv 8 + @ 'camLat 8 + @ xdir *. + 'camViewUp 8 + @ ydir *. + a!+
	'camAdv 16 + @ 'camLat 16 + @ xdir *. + 'camViewUp 16 + @ ydir *. + a!
	'raydir v3Nor
	'raydir >a a@ neg a!+ a@ neg a!+ a@ neg a!
	;

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

:pickat | x y --
	raymouse pickray 'sel ! ;

|----------------------------------
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

|----------------------------------
| interfaz
:nodeinfo
	nsel? 0? ( drop "sin nodo seleccionado" uiLabelC ; ) drop
	sel ssmo_nadr 4 + d@ sel ssmo_nadr d@ sel name@
	"%s  spr:%d  padre:%d" sprint uiLabelC ;

:modelabel | -- "texto"
	posemode? 1? ( drop "editando POSE" ; ) drop "editando ARMADO" ;

:ui_model
	"MULTISPRITE" uiLabelC
	n3dsprites ssmo_nodes "nodos: %d   sprites del .ssv: %d" sprint uiLabelC
	modelabel uiLabelC
	syncvars
	ssmo_nodes 1? ( "nodo" 0 ssmo_nodes 1- 'sel uiSlideriL ) drop
	nodeinfo
	"x" -48.0 48.0 'px uiSliderfL uiEx? 1? ( applypos ) drop
	"y" -48.0 48.0 'py uiSliderfL uiEx? 1? ( applypos ) drop
	"z" -48.0 48.0 'pz uiSliderfL uiEx? 1? ( applypos ) drop
	"escala" 0.1 3.0 'sc uiSliderfL uiEx? 1? ( applysc ) drop
	"paso (vueltas)" 0.01 0.25 'rstep uiSliderfL
	'b_rx+ "X+" uiNBtn 'b_rx- "X-" uiNBtn
	'b_ry+ "Y+" uiNBtn 'b_ry- "Y-" uiNBtn
	'b_rz+ "Z+" uiNBtn 'b_rz- "Z-" uiNBtn
	'b_rrot "reset rot" uiNBtn
	uiLn ;

:ui_edit
	"AGREGAR / CAMBIAR" uiLabelC
	"sprite (-1 = hueso)" -1 n3dsprites 1- 'ssel uiSlideriL
	'b_addchild "hijo del nodo" uiNBtn
	'b_addroot "raiz" uiNBtn
	'b_setspr "asignar sprite" uiNBtn
	uiLn
	"padre (-1 = raiz)" -1 ssmo_nodes 1- 'psel uiSlideriL
	'b_setpar "asignar padre" uiNBtn
	'b_del "borrar (hoja)" uiNBtn
	uiLn
	'b_save "guardar .ssm" uiNBtn
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

:viewmouse
	immMouse
	1 =? ( wheelcam )
	2 =? ( sdlx 'xp ! sdly 'yp ! sdlx 'px0 ! sdly 'py0 ! 0 'dragged ! )
	3 =? ( movecam )
	6 =? ( dragged 0? ( sdlx sdly pickat ) drop )
	drop ;

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

	0.22 %cw uiO
	$1f00ff00 'fcolor !
	uiWinBox frect
	$ffffffff 'fcolor !
	ui_model
	ui_edit

	0.22 %cw uiE
	$1fff0000 'fcolor !
	uiWinBox frect
	$ffffffff 'fcolor !
	ui_anim

	uiRest uiWinBox immBox
	viewmouse ;

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
	<le> =? ( selprev ) <ri> =? ( selnext )
	<del> =? ( b_del )
	<f5> =? ( b_save )
	drop
	keycam ;

:main
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
	'SSVFILE 256 ss3dload
	initmodel
	1 rl_grid_init
	8 'fsun memfloat
	'fsun rl_set_sun
	'viewresize SDLeventR
	makecam
	'main SDLshow
	rl_grid_free
	SS3Dshutdown
	endShapes
	rl_shutdown
	GLend ;
