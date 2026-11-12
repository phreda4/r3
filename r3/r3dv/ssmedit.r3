|MEM 64
| ssmedit r3dv - editor de multi3dsprite (.ssm): nodos, huesos y posiciones relativas
| PHREDA 2026
|
| Carga un .ssv (sprites) y el .ssm de trabajo (si no existe, arranca vacio).
| Cada nodo = un sprite del .ssv (o un hueso sin voxeles) con padre, posicion, rotacion y escala
| LOCALES al padre (posicion en voxeles). El nodo seleccionado se resalta y se dibujan marcadores
| en el origen de cada nodo (celeste = nodo, rojo = seleccionado).
|
| mouse: arrastrar = mirar, rueda = zoom | W S A D Q E = mover camara
| flechas izq/der = nodo anterior/siguiente | SUPR = borrar nodo hoja | F5 = guardar
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
	'camEye 'camTo 'camUp rl_camera ;

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
#cnt				| contador para nombres nuevos
#ni #pp #na
#px #py #pz #sc			| posicion y escala del nodo seleccionado (voxeles 16.16)
#ssel 0				| sprite elegido para agregar / asignar (-1 = hueso)
#psel -1			| padre elegido
#rstep 0.0625			| paso de rotacion en vueltas
#hlcol $ffd09000
#mx #my #mz #mk

:name@ | i -- adr
	ssmo_nadr 44 + d@ ssmo_name ;

:nsel? | -- 1/0
	sel -? ( drop 0 ; )
	ssmo_nodes <? ( drop 1 ; ) drop 0 ;

:clampsel
	sel ssmo_nodes 1- min -1 max 'sel !
	psel ssmo_nodes 1- min -1 max 'psel !
	ssel n3dsprites 1- min -1 max 'ssel ! ;

:syncvars
	nsel? 0? ( drop ; ) drop
	sel ssmo_nadr 'na !
	na 8 + d@ 'px ! na 12 + d@ 'py ! na 16 + d@ 'pz ! na 36 + d@ 'sc ! ;

:applypos
	nsel? 0? ( drop ; ) drop
	px py pz sel ssmo_npos ;
:applysc
	nsel? 0? ( drop ; ) drop
	sc 0.05 max sel ssmo_nscale ;

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
	0 0 0 1.0 sel ssmo_nrot ;
:b_rx+ nsel? 0? ( drop ; ) drop 1.0 0 0 rstep sel ssmo_nrotate ;
:b_rx- nsel? 0? ( drop ; ) drop 1.0 0 0 rstep neg sel ssmo_nrotate ;
:b_ry+ nsel? 0? ( drop ; ) drop 0 1.0 0 rstep sel ssmo_nrotate ;
:b_ry- nsel? 0? ( drop ; ) drop 0 1.0 0 rstep neg sel ssmo_nrotate ;
:b_rz+ nsel? 0? ( drop ; ) drop 0 0 1.0 rstep sel ssmo_nrotate ;
:b_rz- nsel? 0? ( drop ; ) drop 0 0 1.0 rstep neg sel ssmo_nrotate ;

:b_save 'SSMFILE ssmo_save ;

:selprev sel 1- ssmo_nodes 1- min -1 max 'sel ! ;
:selnext sel 1+ ssmo_nodes 1- min -1 max 'sel ! ;

:initmodel
	'SSMFILE ssmo_load 0? ( drop
		512 8 8 64 ssmo_new
		"vox.ssv" ssmo_ssv! )
	'dd !
	ssmo_nodes 'cnt !
	dd ssmo_inst 'mi !
	3.0 mi ssmo_rscale
	0 1.5 0 mi ssmo_rpos
	0 'sel !
	ssmo_nodes 0? ( -1 'sel ! ) drop ;

|----------------------------------
| escena
:mcol | i -- color
	sel =? ( drop $ffff3020 ; ) drop $30c0ff20 ;

:marker | i --
	dup 'mk ! mi ssmo_wpos 'mz ! 'my ! 'mx !
	matini 0.03 dup dup matscale mx my mz matpos
	mk mcol draw_cube ;

:drawscene
	mi ssmo_bind
	sel hlcol mi ssmo_hilite
	'ss3dset 0 mi ssmo_draw ss3dlen!
	0 ( ssmo_nodes <? dup marker 1+ ) drop ;

|----------------------------------
| interfaz
:nodeinfo
	nsel? 0? ( drop "sin nodo seleccionado" uiLabelC ; ) drop
	sel ssmo_nadr 4 + d@ sel ssmo_nadr d@ sel name@
	"%s  spr:%d  padre:%d" sprint uiLabelC ;

:ui_nodes
	ssmo_nodes 1? ( drop "nodo" 0 ssmo_nodes 1- 'sel uiSlideriL ; ) drop ;
	
:ui_model
	"MULTISPRITE" uiLabelC
	n3dsprites ssmo_nodes "nodos: %d   sprites del .ssv: %d" sprint uiLabelC
	syncvars
	ui_nodes
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

:viewmouse
	immMouse
	1 =? ( wheelcam )
	3 =? ( movecam )
	2 =? ( sdlx 'xp ! sdly 'yp ! )
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

	0.24 %cw uiO
	$1f00ff00 'fcolor !
	uiWinBox frect
	$ffffffff 'fcolor !
	ui_model
	ui_edit

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
