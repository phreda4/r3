|MEM 64
| demo9 r3dv - multi3dsprite (ssmodel.r3): jerarquias de 3dsprites con poses y clips
| PHREDA 2026
|
| A: cubo de 64x64x64 = 8 sprites de 32^3 (globe) pegados, bajo un nodo raiz; clip "explotar"
| B: brazo articulado (huesos sin voxeles + sprites cilindro/cubo/piramide); clip "saludo"
| Los modelos se guardan/cargan como .ssm (si no existen se arman por programa y se guardan).
| mouse: arrastrar = rotar camara, rueda = zoom | ESPACIO = pausa
^./renderlib.r3
^./rlshapes.r3
^./ss3d.r3
^./ssmodel.r3
^r3/util/immzone.r3

#cam_yaw  -0.785398
#cam_pit   0.45
#cam_dist  4.5

#camEye -10.0 2.0 0.0
#camTo  0.0 0.8 0.0
#camUp  0.0 1.0 0.0

#xp #yp
:movecam
	sdlx dup xp - 0.002 * 'cam_yaw +! 'xp !
	sdly dup yp - neg 0.002 *
	cam_pit + 0.2 min -0.2 max 'cam_pit !
	'yp ! 
:calcam
	'camEye >a
	cam_yaw cos cam_pit cos *. cam_dist *. a!+
	cam_pit sin cam_dist *. 0.8 + a!+
	cam_yaw sin cam_pit cos *. cam_dist *. a!
	'camEye 'camTo 'camUp rl_camera ;
:wheelcam
	SDLw 0? ( drop ; ) neg
	0.6 * 'cam_dist +!
	calcam ;

#fsun [
-0.5 -1.0 -0.5 0
 1.0 0.9 0.8 1.2
 ]
:luz
	1.4
	0.2 0.2 1.0
	msec 3 <<
	dup cos -3 * over sin -3 * 1.0 +
	rot sin 2.5 *.
	rl_point_light
	1.2
	1.0 0.2 0.2
	msec 3 <<
	dup cos 3 * over sin 3 * 1.0 +
	rot 0.5 + sin 2.5 *.
	rl_point_light ;

|----------------------------------
| modelo A: cubo 64^3 = raiz + 8 globos (sprite 3, 32^3)
:h16 | k bit -- +-16 voxeles
	and 0? ( drop -16.0 ; ) drop 16.0 ;

#ci #kk #pp
:mkcubo
	9 2 1 3 ssmo_new drop
	"vox.ssv" ssmo_ssv!
	-1 -1 ssmo_node drop
	"cubo64" 0 ssmo_nname
	0 ( 8 <?
		3 0 ssmo_node 'ci !
		dup 1 h16 over 2 h16 pick2 4 h16 ci ssmo_npos
		1+ ) drop
	ssmo_pose drop
	ssmo_pose 'pp !					| pose 1: cada globo se aleja un 60%
	0 ( 8 <? dup 'kk !
		kk 1 h16 1.6 *. kk 2 h16 1.6 *. kk 4 h16 1.6 *.
		0 0 0 1.0 1.0 pp kk 1+ ssmo_pnode ssmo_t!
		1+ ) drop
	"explotar" 1 ssmo_clip drop
	0 0 ssmo_key 1 800 ssmo_key 0 1600 ssmo_key ;

|----------------------------------
| modelo B: brazo articulado (huesos: 0 raiz, 2 hombro, 4 codo, 6 muneca)
#ta #tp2 #tn2 #tq
:prot | turnos pose nodo --	; rotacion en Z del hueso dentro de la pose
	'tn2 ! 'tp2 ! 'ta !
	0 0 1.0 ta ssmo_qaxis
	tp2 tn2 ssmo_pnode 'tq !
	tq 24 + d! tq 20 + d! tq 16 + d! tq 12 + d! ;

:mkbrazo
	8 3 1 4 ssmo_new drop
	"vox.ssv" ssmo_ssv!
	-1 -1 ssmo_node drop		| 0 raiz
	0 0 ssmo_node drop			| 1 base (cubo)
	-1 0 ssmo_node drop			| 2 hombro
	1 2 ssmo_node drop			| 3 brazo (cilindro)
	-1 2 ssmo_node drop			| 4 codo
	1 4 ssmo_node drop			| 5 antebrazo
	-1 4 ssmo_node drop			| 6 muneca
	5 6 ssmo_node drop			| 7 mano (piramide)
	0 8.0 0 2 ssmo_npos
	0 8.0 0 3 ssmo_npos
	0 16.0 0 4 ssmo_npos
	0 6.4 0 5 ssmo_npos 0.8 5 ssmo_nscale
	0 12.8 0 6 ssmo_npos
	0 6.0 0 7 ssmo_npos 0.75 7 ssmo_nscale
	"hombro" 2 ssmo_nname "codo" 4 ssmo_nname "muneca" 6 ssmo_nname
	ssmo_pose drop
	ssmo_pose 'pp !
	0.12 pp 2 prot -0.25 pp 4 prot 0.1 pp 6 prot
	ssmo_pose 'pp !
	-0.12 pp 2 prot 0.25 pp 4 prot -0.1 pp 6 prot
	"saludo" 1 ssmo_clip drop
	1 0 ssmo_key 2 700 ssmo_key 1 1400 ssmo_key ;

|----------------------------------
#dA #dB #mA #mB
#anim 1
#tm 0

:loadmodel | 'mk "file" -- d
	dup ssmo_load 0? ( drop
		swap ex dup ssmo_save ssmo_load ; )
	nip nip ;

:initmodels
	'mkcubo "media/ssv/demo9a.ssm" loadmodel 'dA !
	'mkbrazo "media/ssv/demo9b.ssm" loadmodel 'dB !
	dA ssmo_inst 'mA !
	dB ssmo_inst 'mB !
	-1.0 0.7 0 mA ssmo_rpos 2.0 mA ssmo_rscale
	1.0 0.17 0 mB ssmo_rpos 2.0 mB ssmo_rscale ;

:updmodels
	anim 1? ( 16 'tm +! ) drop
	0 tm mA ssmo_play
	0 tm mB ssmo_play
	0 1.0 0 tm 16 << 6000 / ssmo_qaxis mA ssmo_rrot ;

:drawmodels
	'ss3dset 0 mA ssmo_draw
	'ss3dset swap mB ssmo_draw drop ;

:drawscene
	matini 10.0 .1 10.0 matscale 0 -0.1 0 matpos
	$5a5a5a20 draw_cube
	updmodels
	drawmodels
	SS3Ddraw ;

:render
	rl_frame_begin
	drawscene
	luz
	rl_frame_end ;

:main
	render
	GLUpdate
	immIni
	immMouse
	1 =? ( wheelcam )
	2 =? ( sdlx 'xp ! sdly 'yp ! )
	3 =? ( movecam )
	drop
	sdlkey
	>esc< =? ( exit )
	<spc> =? ( anim 1 xor 'anim ! )
	drop ;

:viewresize
	sh sw rl_resizewin ;

: | <<<<< Boot
	"demo9 r3dv multi3dsprite" 1024 768 GLini GLInfo
	rl_init
	IniShapes
	"media/ssv/vox" 64 ss3dload
	initmodels
	'camEye 'camTo 'camUp rl_camera
	8 'fsun memfloat
	'fsun rl_set_sun
	'viewresize SDLeventR
	calcam
	'main SDLshow
	SS3Dshutdown
	endShapes
	rl_shutdown
	GLend ;
