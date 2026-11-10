| VOXED - editor de voxeles ss3d (un objeto a la vez)
| PHREDA 2026
|
| mouse: izq = herramienta | der + arrastrar = orbitar | medio + arrastrar = desplazar | rueda = zoom
| V F G = attach / erase / paint | 1 2 3 = voxel / linea / caja | X cancela el 1er punto
| U = deshacer | W S = zoom, A D Q E = desplazar | F1 = sombras | F2 = SSAO
|
| modelo: nv x nv x nv voxeles (max 32: la mascara de capas es de 32 bits)
| vidx = indice de paleta por voxel, dpal = tira de colores completa (ss3d), dcols = mascara|base

^r3/lib/rand.r3
^r3/lib/mem.r3

^r3/util/varanim.r3
^r3/util/glgfx.r3
^r3/util/glimm.r3

^./renderlib.r3
^./ss3d.r3
^./ss3dshadow.r3
^./rlgrid.r3

|----------------------------------
| camara orbital
#cam_yaw 0.1
#cam_pit -0.12
#cdist 3.2
#tgt 0.0 0.5 0.0
#camEye 0 0 0
#camTo 0 0 0
#camUp 0.0 1.0 0.0
#camAdv 0 0 0	| hacia atras
#camLat 0 0 0	| izquierda
#camVU 0 0 0	| arriba de la camara
#cp #sp #cy #sy
#va #vl #vu

:cpytgt | 'dst --
	>a 'tgt @ a!+ 'tgt 8 + @ a!+ 'tgt 16 + @ a! ;

:makecam
	cam_yaw sincos 'cy ! 'sy !
	cam_pit -0.24 max 0.24 min sincos 'cp ! 'sp !
	'camAdv >a
	cy neg cp *. a!+
	sp neg a!+
	sy neg cp *. a!
	'camLat >a
	sy a!+
	0 a!+
	cy neg a!
	'camVU >a
	cy sp *. neg a!+
	cp a!+
	sy sp *. neg a!
	'camTo cpytgt
	'camEye cpytgt
	'camEye 'camAdv cdist v3+*
	'camEye 'camTo 'camUp rl_camera ;

#xp #yp

:orbitmouse
	sdlx dup xp - -0.003 * 'cam_yaw +! 'xp !
	sdly dup yp - -0.003 * cam_pit + -0.24 max 0.24 min 'cam_pit ! 'yp ! ;

:panmouse
	sdlx dup xp - 0.0015 * cdist *. 'tgt 'camLat pick2 v3+* drop 'xp !
	sdly dup yp - 0.0015 * cdist *. 'tgt 'camVU pick2 v3+* drop 'yp ! ;

:zoomk | f --	; cdist *= f
	cdist swap *. 0.3 max 40.0 min 'cdist ! ;

:wheelcam
	SDLw 0? ( drop ; ) 0.1 * 1.0 swap - zoomk ;

:dnmouse sdlx 'xp ! sdly 'yp ! ;

:keycam
	va 1? ( 1.0 va + zoomk ) drop
	vl 1? ( 'tgt 'camLat vl cdist *. v3+* ) drop
	vu 1? ( 'tgt 'camVU vu cdist *. v3+* ) drop ;

:vtop
	'cam_yaw 0.0 cam_yaw 21 1.0 0 +vanim
	'cam_pit -0.24 cam_pit 21 1.0 0 +vanim ;
:vfront
	'cam_yaw 0.0 cam_yaw 21 1.0 0 +vanim
	'cam_pit 0.0 cam_pit 21 1.0 0 +vanim ;
:vside
	'cam_yaw 0.25 cam_yaw 21 1.0 0 +vanim
	'cam_pit 0.0 cam_pit 21 1.0 0 +vanim ;
:viso
	'cam_yaw 0.1 cam_yaw 21 1.0 0 +vanim
	'cam_pit -0.12 cam_pit 21 1.0 0 +vanim ;

|----------------------------------
| luces: sol con sombra + luz puntual en la camara
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
	0.2
	1.0 1.0 1.0
	'camEye >a
	a@+ a@+ 1.0 + a@
	rl_point_light ;

|----------------------------------
| MODELO
#nv 32			| voxeles por lado (max 32)
:nvox nv nv * nv * ;
:ncol0 nv nv * ;						| columnas del objeto
:ncolsn ncol0 2 + ;						| + cursor + barra
:npaln nvox nv + 1+ ;					| + cursor + barra
:colsbytes ncolsn 3 << ;
:palbytes npaln 2 << ;

#dcols #dpal #vidx		| datos que se suben a la GPU / indice de paleta
#ucols #uidx			| copia para deshacer
#dirty 1
#img

#vx #vy #vz				| voxel de trabajo (y hacia arriba)

:vk | -- k		; posicion en la tira del voxel
	vz nv * vx + nv * nv 1- vy - + ;
:vmask | -- adr
	vz nv * vx + 3 << dcols + ;
:vbit 1 nv 1- vy - << ;
:vocc? | -- 0/bit
	vmask d@ vbit and ;
:vocc! | 0/1 --
	vmask dup d@			| on adr mask
	rot 1? ( drop vbit or swap d! ; ) drop
	vbit nand swap d! ;

|--- paleta: 256 ranuras, HSV + material por ranura
#pah * 2048
#pas * 2048
#pav * 2048
#pmt * 2048
#prg * 2048
#pgl * 2048
#prgb * 2048			| $RRGGBBuma
#psel 20
#si

:rgb3 | r g b -- rgb
	swap 8 << or swap 16 << or ;

#h_s #h_v #h_f #h_r #h_p #h_q #h_t
:hsv>rgb | h s v -- rgb		; h 0..359 s v 0..255
	'h_v ! 'h_s !
	60 /mod 255 * 60 / 'h_f ! 'h_r !
	h_v 255 h_s - * 255 / 'h_p !
	h_v 255 h_s h_f * 255 / - * 255 / 'h_q !
	h_v 255 h_s 255 h_f - * 255 / - * 255 / 'h_t !
	h_r 0 =? ( drop h_v h_t h_p rgb3 ; )
	1 =? ( drop h_q h_v h_p rgb3 ; )
	2 =? ( drop h_p h_v h_t rgb3 ; )
	3 =? ( drop h_p h_q h_v rgb3 ; )
	4 =? ( drop h_t h_p h_v rgb3 ; )
	drop h_v h_p h_q rgb3 ;

:pv | 'arr -- v
	si 3 << + @ ;

:slotcalc | i --
	'si !
	'pah pv 'pas pv 'pav pv hsv>rgb 8 <<
	'prg pv 5 << 'pmt pv 2 << or 'pgl pv or or
	'prgb si 3 << + ! ;

:pset | h s v --
	'pav si 3 << + ! 'pas si 3 << + ! 'pah si 3 << + !
	0 'prg si 3 << + ! 0 'pmt si 3 << + ! 0 'pgl si 3 << + !
	si slotcalc ;

#rw #hu
:palslot | i --
	'si !
	si 16 <? ( drop 0 0 si 17 * pset ; ) drop
	si 16 - 24 /mod swap 'rw ! 15 * 'hu !
	rw 5 <? ( drop hu 255 255 rw 40 * - pset ; ) drop
	hu 255 rw 4 - 40 * - 255 pset ;

:palinit
	0 ( 256 <? dup palslot 1+ ) drop ;

:vcolset | idx --	; indice de paleta del voxel y su tira de colores
	dup vk vidx + c!
	3 << 'prgb + @ vk 2 << dpal + d! ;

:refreshstrips | todas las tiras desde la paleta
	0 ( nvox <?
		dup vidx + c@ 3 << 'prgb + @
		over 2 << dpal + d!
		1+ ) drop ;

|--- memoria e imagen .ssv (sprite 0 = objeto, 1 = cursor de 1 voxel, 2 = barra de nv voxeles)
:initmem
	here 'dcols ! colsbytes 'here +!
	here 'dpal ! palbytes 'here +!
	here 'vidx ! nvox 'here +!
	vidx 0 nvox 2 >> dfill
	here 'ucols ! colsbytes 'here +!
	here 'uidx ! nvox 'here +! ;

:initcols
	dcols >a
	0 ( ncol0 <? 0 da!+ dup nv * da!+ 1+ ) drop
	1 da!+ nvox da!+
	1 nv << 1- da!+ nvox 1+ da!+ ;

:initpal
	dpal $ffffff00 npaln dfill
	refreshstrips ;

:buildimg
	here 'img !
	"SSV2" d@ , 3 , ncolsn , npaln ,
	0 , nv dup 8 << or nv 16 << or ,
	ncol0 , 1 dup 8 << or 1 16 << or ,
	ncol0 1+ , 1 nv 8 << or 1 16 << or ,
	here dcols colsbytes cmove colsbytes 'here +!
	here dpal palbytes cmove palbytes 'here +!
	img 'here ! ;

:upvox | sube a la GPU si hubo cambios
	dirty 0? ( drop ; ) drop
	0 'dirty !
	0 colsbytes dcols ss3dupcols
	0 palbytes dpal ss3duppal ;

|--- deshacer (un nivel)
:pushundo
	ucols dcols ncol0 3 << cmove
	uidx vidx nvox cmove ;
:undo
	dcols ucols ncol0 3 << cmove
	vidx uidx nvox cmove
	refreshstrips 1 'dirty ! ;

|----------------------------------
| herramientas
#bmode 0		| 0 attach 1 erase 2 paint
#bshape 0		| 0 voxel 1 linea 2 caja
#opx #shpx
#gx #gy #gz

:applycell | -- ; aplica el modo en el voxel vx vy vz
	bmode 0 =? ( drop 1 vocc! psel vcolset ; )
	1 =? ( drop 0 vocc! ; )
	drop vocc? 1? ( drop psel vcolset ; ) drop ;

:cellapply | x y z --
	'vz ! 'vy ! 'vx ! applycell 1 'dirty ! ;

:eachvox | 'op --
	'opx !
	0 ( nv <? dup 'vz !
		0 ( nv <? dup 'vy !
			0 ( nv <? dup 'vx !
				opx ex
				1+ ) drop
			1+ ) drop
		1+ ) drop
	1 'dirty ! ;

|--- conjunto
:o_clear 0 vocc! ;
:o_fill 1 vocc! psel vcolset ;
:o_rev vocc? 0? ( drop o_fill ; ) drop 0 vocc! ;
:ddx vx 2* 1+ nv - ;
:ddy vy 2* 1+ nv - ;
:ddz vz 2* 1+ nv - ;
:sq dup * ;
:in_sphere ddx sq ddy sq + ddz sq + nv sq <=? ( drop 1 ; ) drop 0 ;
:in_cyl ddx sq ddz sq + nv sq <=? ( drop 1 ; ) drop 0 ;
:in_pyr ddx abs ddz abs max nv vy - <=? ( drop 1 ; ) drop 0 ;
:in_cone ddx sq ddz sq + nv vy - sq <=? ( drop 1 ; ) drop 0 ;
:o_gen shpx ex 1? ( drop applycell ; ) drop ;

:a_clear pushundo 'o_clear eachvox ;
:a_fill pushundo 'o_fill eachvox ;
:a_rev pushundo 'o_rev eachvox ;
:a_sphere pushundo 'in_sphere 'shpx ! 'o_gen eachvox ;
:a_cyl pushundo 'in_cyl 'shpx ! 'o_gen eachvox ;
:a_pyr pushundo 'in_pyr 'shpx ! 'o_gen eachvox ;
:a_cone pushundo 'in_cone 'shpx ! 'o_gen eachvox ;

|--- mover (con vuelta) e invertir: leen la copia de deshacer
#sdx #sdy #sdz
#sx0 #sy0 #sz0
:o_copyfrom | copia el voxel (sx0 sy0 sz0) de la copia a vx vy vz
	ucols sz0 nv * sx0 + 3 << + d@ 1 nv 1- sy0 - << and
	0? ( drop 0 vocc! ; ) drop 1 vocc!
	uidx sz0 nv * sx0 + nv * nv 1- sy0 - + + c@ vcolset ;
:o_shift
	vx sdx - nv + nv mod 'sx0 !
	vy sdy - nv + nv mod 'sy0 !
	vz sdz - nv + nv mod 'sz0 !
	o_copyfrom ;
:o_fx nv 1- vx - 'sx0 ! vy 'sy0 ! vz 'sz0 ! o_copyfrom ;
:o_fy vx 'sx0 ! nv 1- vy - 'sy0 ! vz 'sz0 ! o_copyfrom ;
:o_fz vx 'sx0 ! vy 'sy0 ! nv 1- vz - 'sz0 ! o_copyfrom ;
:a_ix pushundo 'o_fx eachvox ;
:a_iy pushundo 'o_fy eachvox ;
:a_iz pushundo 'o_fz eachvox ;

#mvx #mvy #mvz #mxl #myl #mzl
:movepoll
	mvx mxl - mvy myl - mvz mzl -
	'sdz ! 'sdy ! 'sdx !
	sdx sdy or sdz or 1? ( pushundo 'o_shift eachvox ) drop
	mvx 'mxl ! mvy 'myl ! mvz 'mzl ! ;
:mvreset 0 'mvx ! 0 'mvy ! 0 'mvz ! 0 'mxl ! 0 'myl ! 0 'mzl ! ;

|--- formas: linea y caja entre el punto ancla (ax ay az) y el objetivo (tx ty tz)
#aok #ax #ay #az
#tx #ty #tz
#dxl #dyl #dzl #stp #li
:lerp | d a i -- v
	rot 16 << * stp / swap 16 << + $8000 + 16 >> ;
:doline
	tx ax - 'dxl ! ty ay - 'dyl ! tz az - 'dzl !
	dxl abs dyl abs max dzl abs max 1 max 'stp !
	0 ( stp <=? dup 'li !
		dxl ax li lerp dyl ay li lerp dzl az li lerp cellapply
		1+ ) drop
	0 'aok ! ;

#ex0 #ex1 #ey0 #ey1 #ez0 #ez1
:dobox
	ax tx min 'ex0 ! ax tx max 'ex1 !
	ay ty min 'ey0 ! ay ty max 'ey1 !
	az tz min 'ez0 ! az tz max 'ez1 !
	ez0 ( ez1 <=? dup 'gz !
		ey0 ( ey1 <=? dup 'gy !
			ex0 ( ex1 <=? dup 'gx !
				gx gy gz cellapply
				1+ ) drop
			1+ ) drop
		1+ ) drop
	0 'aok ! ;

|----------------------------------
| geometria en el mundo: el objeto esta centrado en x z y apoyado en y=0
#oscl 3.0		| escala (voxel = 0.01 * escala)
:vox 0.01 oscl *. ;
:half nv vox * 2/ ;
:cellc | g -- p		; centro de la celda g relativo al centro del objeto
	2* 1+ nv - vox * 2/ ;

|----------------------------------
| picking: rayo del mouse contra el objeto (espacio local centrado)
#camForMouse 0 0 0
#xdir #ydir
#ro 0 0 0
#rd 0 0 0
#tn #tf #tt #dtt #miss #so #sd
#hitok #hx #hy #hz		| voxel apuntado
#pok #px #py #pz		| ultima celda vacia antes del voxel
#fok #fx #fy #fz		| primera celda valida del rayo
#bok #bx #bz			| primera celda del piso (y=0) del rayo

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

:raylocal | -> 'ro 'rd relativos al centro del objeto
	AdvMouse
	'camForMouse @ neg 'rd !
	'camForMouse 8 + @ neg 'rd 8 + !
	'camForMouse 16 + @ neg 'rd 16 + !
	'camEye @ 'ro !
	'camEye 8 + @ half - 'ro 8 + !
	'camEye 16 + @ 'ro 16 + ! ;

:slab | o d --		; recorta tn tf con la placa +-half
	'sd ! 'so !
	sd abs 32 <? ( drop so abs half >? ( 1 'miss ! ) drop ; ) drop
	half neg so - sd /.
	half so - sd /.
	2dup min tn max 'tn !
	max tf min 'tf ! ;

:axcell | p -- g/-1
	half + -? ( drop -1 ; )
	vox / nv >=? ( drop -1 ; ) ;

:cell | x y z -- r	; -1 fuera, 0 vacio, 1 ocupado (voxel en vx vy vz)
	axcell -? ( drop 2drop -1 ; ) 'vz !
	axcell -? ( 2drop -1 ; ) 'vy !
	axcell -? ( drop -1 ; ) 'vx !
	vocc? 1? ( drop 1 ; ) drop 0 ;

:notefloor
	bok 1? ( drop ; ) drop
	vy 1? ( drop ; ) drop
	vx 'bx ! vz 'bz ! 1 'bok ! ;

:marchstep
	'ro @ 'rd @ tt *. +
	'ro 8 + @ 'rd 8 + @ tt *. +
	'ro 16 + @ 'rd 16 + @ tt *. +
	cell
	-? ( drop ; )
	1? ( drop vx 'hx ! vy 'hy ! vz 'hz ! 1 'hitok ! tt 'tf ! ; ) drop
	fok 0? ( vx 'fx ! vy 'fy ! vz 'fz ! 1 'fok ! ) drop
	notefloor
	vx 'px ! vy 'py ! vz 'pz ! 1 'pok ! ;

:rayhit
	0 'hitok ! 0 'pok ! 0 'fok ! 0 'bok ! 0 'miss !
	raylocal
	0 'tn ! 1000.0 'tf !
	'ro @ 'rd @ slab
	'ro 8 + @ 'rd 8 + @ slab
	'ro 16 + @ 'rd 16 + @ slab
	miss 1? ( drop ; ) drop
	tn tf >=? ( drop ; ) drop
	vox 3 / 1 max 'dtt !
	tn ( tf <? dup 'tt ! marchstep dtt + ) drop ;

:attachtarget | -- 0/1
	hitok 1? ( drop pok 0? ( ; ) drop px 'tx ! py 'ty ! pz 'tz ! 1 ; ) drop
	bok 1? ( drop bx 'tx ! 0 'ty ! bz 'tz ! 1 ; ) drop
	fok 0? ( ; ) drop
	fx 'tx ! fy 'ty ! fz 'tz ! 1 ;

#curok
:pickat | -- 0/1	; objetivo de la herramienta en tx ty tz
	rayhit
	bmode 0? ( drop attachtarget ; ) drop
	hitok 0? ( ; ) drop
	hx 'tx ! hy 'ty ! hz 'tz ! 1 ;

#lkey
:tkey tx 8 << ty + 8 << tz + ;

:toolpress
	pickat dup 'curok ! 0? ( drop ; ) drop
	bshape 0? ( drop pushundo tx ty tz cellapply tkey 'lkey ! ; ) drop
	aok 0? ( drop tx 'ax ! ty 'ay ! tz 'az ! 1 'aok ! ; ) drop
	pushundo
	bshape 1 =? ( drop doline ; ) drop
	dobox ;

:tooldrag
	pickat dup 'curok ! 0? ( drop ; ) drop
	bshape 0? ( drop tkey lkey =? ( drop ; ) 'lkey ! tx ty tz cellapply ; ) drop ;

:pickhover pickat 'curok ! ;

:viewmouse
	immMouse
	0 =? ( 0 'curok ! )
	1 =? ( wheelcam pickhover )								| over
	2 =? ( dnmouse sdlb 1 =? ( toolpress ) drop )			| in
	3 =? ( sdlb 4 =? ( orbitmouse ) 2 =? ( panmouse ) 1 =? ( tooldrag ) drop )	| active
	drop ;

|----------------------------------
| instancias: 0 objeto, 1 cursor, 2 ancla, 3..14 caja
#qid #qzz #qxx
#ea #eb #ek #ec #ei

:curscl | -- s
	curok 0? ( ; ) drop oscl 1.15 *. ;
:curcolor | -- c
	bmode 0? ( drop $40ff4003 ; ) 1 =? ( drop $ff404003 ; ) drop $40a0ff03 ;

:ancscl | -- s
	aok 0? ( ; ) drop oscl 1.15 *. ;

:hsg | b -- +-half
	1? ( drop half ; ) drop half neg ;

:ecol | k col -- c
	swap 0? ( drop ; ) drop drop $a0a0a003 ;

:edge | x y z q col i --
	'ei ! 'ec !
	oscl 2 ec ei ss3dset
	oscl 0.25 *. oscl oscl 0.25 *. ei ss3dscl3 ;

:edges
	0 ( 4 <? dup 'ek !
		ek 1 and hsg 'ea !
		ek 2 and hsg 'eb !
		ea half eb qid ek $40ff4003 ecol ek 3 + edge
		0 half ea + eb qzz ek $ff404003 ecol ek 7 + edge
		ea half eb + 0 qxx ek $4080ff03 ecol ek 11 + edge
		1+ ) drop ;

:placeall
	0 half 0 qid oscl 0 $ffffff00 0 ss3dset
	tx cellc ty cellc half + tz cellc qid curscl 1 curcolor 1 ss3dset
	ax cellc ay cellc half + az cellc qid ancscl 1 $ffff4003 2 ss3dset
	edges ;

|----------------------------------
| archivos: mem/voxedN.vxd (editor) y mem/voxedN.ssv (exportar a ss3d)
#slot 1
#sv #lp

:svarr | 'arr --
	0 ( 256 <? over over 3 << + @ , 1+ ) 2drop ;
:rd@ | -- v
	lp d@ lp 4 + 'lp ! ;
:ldarr | 'arr --
	0 ( 256 <? rd@ pick2 pick2 3 << + ! 1+ ) 2drop ;

:savevxd
	here 'sv !
	nv ,
	'pah svarr 'pas svarr 'pav svarr 'pmt svarr 'prg svarr 'pgl svarr
	here vidx nvox cmove nvox 'here +!
	0 ( ncol0 <? dup 3 << dcols + d@ , 1+ ) drop
	sv here over - slot "mem/voxed%d.vxd" sprint save
	sv 'here ! ;

:loadvxd
	here slot "mem/voxed%d.vxd" sprint load drop
	here d@ nv <>? ( drop ; ) drop
	here 4 + 'lp !
	'pah ldarr 'pas ldarr 'pav ldarr 'pmt ldarr 'prg ldarr 'pgl ldarr
	0 ( 256 <? dup slotcalc 1+ ) drop
	lp vidx nvox cmove nvox lp + 'lp !
	0 ( ncol0 <? rd@ over 3 << dcols + d! 1+ ) drop
	refreshstrips 1 'dirty ! ;

:exportssv
	here 'sv !
	"SSV2" d@ , 1 , ncol0 , nvox ,
	0 , nv dup 8 << or nv 16 << or ,
	here dcols ncol0 3 << cmove ncol0 3 << 'here +!
	here dpal nvox 2 << cmove nvox 2 << 'here +!
	sv here over - slot "mem/voxed%d.ssv" sprint save
	sv 'here ! ;

:newmodel
	pushundo
	'o_clear eachvox ;

:slot- slot 1 - 0 max 'slot ! ;
:slot+ slot 1 + 9 min 'slot ! ;

|----------------------------------
| interfaz
#lmode "attach (V)" "erase (F)" "paint (G)" ""
#lshape "voxel (1)" "line (2)" "box (3)" ""
#ci

:palpick ci 'psel ! ;

:palui
	16 16 uiGrid
	0 ( 256 <? dup 'ci !
		uiZoneW 'palpick uiClk
		'prgb ci 3 << + @ 8 >> $ff000000 or 'fcolor ! uiFill
		ci psel =? ( $ffffffff 'fcolor ! uiRect ) drop
		uiNext
		1+ ) drop ;

:slotchg psel slotcalc refreshstrips 1 'dirty ! ;

:leftpanel
	uiPush
	1.0 %cw uiN
	palui
	uiRest
	$ffffffff 'fcolor !
	'prgb psel 3 << + @ 8 >> psel "slot %d  #%h" sprint uiLabelC
	"H" 0 359 'pah psel 3 << + uiSlideriL uiEx? 1? ( slotchg ) drop
	"S" 0 255 'pas psel 3 << + uiSlideriL uiEx? 1? ( slotchg ) drop
	"V" 0 255 'pav psel 3 << + uiSlideriL uiEx? 1? ( slotchg ) drop
	"MATERIAL" uiLabelC
	"metal" 0 7 'pmt psel 3 << + uiSlideriL uiEx? 1? ( slotchg ) drop
	"rough" 0 7 'prg psel 3 << + uiSlideriL uiEx? 1? ( slotchg ) drop
	"glow" 0 3 'pgl psel 3 << + uiSlideriL uiEx? 1? ( slotchg ) drop
	uiPop ;

:rightpanel
	"MODO" uiLabelC
	'bmode 'lmode uiRadio
	"FORMA" uiLabelC
	'bshape 'lshape uiRadio
	"CONJUNTO" uiLabelC
	'a_clear "clear" uiNBtn 'a_fill "fill" uiNBtn 'a_rev "reverse" uiNBtn uiLn
	'a_sphere "sphere" uiNBtn 'a_cyl "cylinder" uiNBtn uiLn
	'a_pyr "pyramid" uiNBtn 'a_cone "cone" uiNBtn uiLn
	"MOVER (con vuelta)" uiLabelC
	"x" nv neg nv 'mvx uiSlideriL
	"y" nv neg nv 'mvy uiSlideriL
	"z" nv neg nv 'mvz uiSlideriL
	'mvreset "0" uiNBtn uiLn
	movepoll
	"INVERTIR" uiLabelC
	'a_ix "x" uiNBtn 'a_iy "y" uiNBtn 'a_iz "z" uiNBtn uiLn ;

:topbar
	'exit "Exit" uiNBtn
	'newmodel "nuevo" uiNBtn
	'undo "deshacer" uiNBtn
	'slot- "<" uiNBtn
	slot "slot %d" sprint uiTlabel
	'slot+ ">" uiNBtn
	'savevxd "guardar" uiNBtn
	'loadvxd "cargar" uiNBtn
	'exportssv "exportar .ssv" uiNBtn ;

:bottombar
	8 1 uiGrid
	'shadowon "sombras" uiToggle uiEx? 1? ( shadowon ss3dshadow! ) drop uiNext
	'rl_ao_on "SSAO" uiToggle uiNext
	'rl_aa_on "FXAA" uiToggle uiNext
	"az" 0.0 1.0 'sun_az uiSliderfL uiEx? 1? ( setsun ) drop uiNext
	"alt" 0.0 0.25 'sun_el uiSliderfL uiEx? 1? ( setsun ) drop uiNext
	'vtop "top" uiBtn uiNext
	'vfront "front" uiBtn uiNext
	'vside "side" uiBtn ;

:interface
	1 'fscale !
	$ffffffff 'fcolor !
	uiFull
	0.05 %ch uiN
	$1f0000ff 'fcolor ! uiWinBox frect
	$ffffffff 'fcolor !
	topbar
	sh 20 / uiS
	$1f0000ff 'fcolor ! uiWinBox frect
	$ffffffff 'fcolor !
	bottombar
	sw 22 * 100 / uiO
	$1f00ff00 'fcolor ! uiWinBox frect
	$ffffffff 'fcolor !
	leftpanel
	sw 20 * 100 / uiE
	$1f00ff00 'fcolor ! uiWinBox frect
	$ffffffff 'fcolor !
	rightpanel
	uiRest uiWinBox immBox
	viewmouse ;

:hud
	fini
	immIni
	interface
	fend

	sdlkey
	>esc< =? ( exit )
	<w> =? ( -0.03 'va ! ) >w< =? ( 0 'va ! )
	<s> =? ( 0.03 'va ! ) >s< =? ( 0 'va ! )
	<a> =? ( 0.02 'vl ! ) >a< =? ( 0 'vl ! )
	<d> =? ( -0.02 'vl ! ) >d< =? ( 0 'vl ! )
	<q> =? ( 0.02 'vu ! ) >q< =? ( 0 'vu ! )
	<e> =? ( -0.02 'vu ! ) >e< =? ( 0 'vu ! )
	<v> =? ( 0 'bmode ! ) <f> =? ( 1 'bmode ! ) <g> =? ( 2 'bmode ! )
	<1> =? ( 0 'bshape ! 0 'aok ! ) <2> =? ( 1 'bshape ! 0 'aok ! ) <3> =? ( 2 'bshape ! 0 'aok ! )
	<x> =? ( 0 'aok ! )
	<u> =? ( undo )
	<f1> =? ( shadowon 1 xor 'shadowon ! shadowon ss3dshadow! )
	<f2> =? ( rl_ao_on 1 xor 'rl_ao_on ! )
	drop
	keycam ;

:main
	vupdate
	makecam
	upvox
	placeall
	rl_frame_begin
	SS3Ddraw
	draw_grid
	light
	rl_frame_end
	hud
	GLUpdate ;

:viewresize
	sh sw rl_resizewin
	fixFontResize ;

:initvox
	0 0 0 1.0 packq 'qid !
	0 0 0.7071 0.7071 packq 'qzz !
	0.7071 0 0 0.7071 packq 'qxx !
	initmem
	palinit
	initcols
	initpal
	nv 2/ 'vx ! 0 'vy ! nv 2/ 'vz !
	applycell 				| un voxel inicial (attach, ranura psel)
	buildimg
	32 ss3dmem
	pushundo ;

: | <<<<<<<< Boot
	"VOXED" 1280 768 GLini GLInfo
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

	'main SDLshow

	rl_grid_free
	ss3dshadowend
	rl_shutdown
	SS3Dshutdown
	GLend
	;
