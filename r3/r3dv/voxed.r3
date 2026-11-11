|MEM 64
| VOXED - editor de voxeles ss3d (un objeto a la vez, 32 slots)
| PHREDA 2026
|
| mouse: izq = herramienta | der + arrastrar = orbitar | medio + arrastrar = desplazar | rueda = zoom
| V F G = attach / erase / paint | 1 2 3 = voxel / linea / caja | X cancela el 1er punto
| U = deshacer | W S = zoom, A D Q E = desplazar | F1 sombras | F2 SSAO | F3 paleta | F4 archivos | F5 herramientas
|
| modelo: nv x nv x nv voxeles (max 32: la mascara de capas es de 32 bits)
| vidx = indice de paleta por voxel, dpal = tira de colores completa (ss3d), dcols = mascara|base

^r3/lib/rand.r3
^r3/lib/mem.r3
^r3/lib/str.r3

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
:ncolsn ncol0 2* 2 + ;					| objeto + cursor + barra + pared
:npaln nvox 1+ nv + ncol0 + ;			| tiras: objeto, cursor, barra, pared
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

#cr #cg #cb #cmx #cmn #cd
:hueof | -- h
	cmx cr =? ( drop cg cb - 60 * cd / 360 + 360 mod ; )
	cg =? ( drop cb cr - 60 * cd / 480 + 360 mod ; )
	drop cr cg - 60 * cd / 600 + 360 mod ;
:rgb>hsv | r g b -- h s v
	'cb ! 'cg ! 'cr !
	cr cg max cb max 'cmx !
	cr cg min cb min 'cmn !
	cmx cmn - 'cd !
	cd 0? ( drop 0 0 cmx ; ) drop
	hueof cd 255 * cmx / cmx ;

:pv | 'arr -- v
	si 3 << + @ ;

:slotcalc | i --
	'si !
	'pah pv 'pas pv 'pav pv hsv>rgb 8 <<
	'prg pv 5 << 'pmt pv 2 << or 'pgl pv or or
	'prgb si 3 << + ! ;

:pset | h s v --	; ranura si
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

|--- slots (32 modelos en memoria): mascaras, indices, paleta
:slb ncol0 3 << nvox + 14336 + ;
#slots #sused * 32 #snames * 1024 #slotcur
#spp #cs #cb2 #cd2

:sadr | n -- adr
	slb * slots + ;
:cp>s | 'src bytes --
	'cb2 ! 'cs ! spp cs cb2 cmove cb2 'spp +! ;
:cp<s | 'dst bytes --
	'cb2 ! 'cd2 ! cd2 spp cb2 cmove cb2 'spp +! ;

:slotsave | n --
	sadr 'spp !
	dcols ncol0 3 << cp>s
	vidx nvox cp>s
	'pah 2048 cp>s 'pas 2048 cp>s 'pav 2048 cp>s 'pmt 2048 cp>s
	'prg 2048 cp>s 'pgl 2048 cp>s 'prgb 2048 cp>s ;

:slotinit
	palinit
	vidx 0 nvox 2 >> dfill
	0 ( ncol0 <? dup 3 << dcols + 0 swap d! 1+ ) drop
	refreshstrips 1 'dirty ! ;

|--- memoria e imagen .ssv (0 = objeto, 1 = cursor de 1 voxel, 2 = barra de nv voxeles, 3 = pared nv x 1 x nv)
:initmem
	here 'dcols ! colsbytes 'here +!
	here 'dpal ! palbytes 'here +!
	here 'vidx ! nvox 'here +!
	vidx 0 nvox 2 >> dfill
	here 'ucols ! colsbytes 'here +!
	here 'uidx ! nvox 'here +!
	here 'slots ! slb 32 * 'here +! ;

:initcols
	dcols >a
	0 ( ncol0 <? 0 da!+ dup nv * da!+ 1+ ) drop
	1 da!+ nvox da!+
	1 nv << 1- da!+ nvox 1+ da!+
	0 ( ncol0 <? 1 da!+ dup nvox 1+ nv + + da!+ 1+ ) drop ;

#wx #wz
:wallcol | k -- color
	nv /mod 'wx ! 'wz !
	wx 7 and 0? ( drop $8a8a9800 ; ) drop
	wz 7 and 0? ( drop $8a8a9800 ; ) drop
	wx wz + 1 and 1? ( drop $44444c00 ; ) drop
	$3a3a4200 ;

:initpal
	dpal $ffffff00 npaln dfill
	0 ( ncol0 <? dup wallcol over nvox 1+ nv + + 2 << dpal + d! 1+ ) drop
	refreshstrips ;

:buildimg
	here 'img !
	"SSV2" d@ , 4 , ncolsn , npaln ,
	0 , nv dup 8 << or nv 16 << or ,
	ncol0 , 1 dup 8 << or 1 16 << or ,
	ncol0 1+ , 1 nv 8 << or 1 16 << or ,
	ncol0 2 + , nv 1 8 << or nv 16 << or ,
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
| slots: cambiar de modelo
:slotload | n --
	dup 'sused + c@ 0? ( 2drop slotinit pushundo ; ) drop
	sadr 'spp !
	dcols ncol0 3 << cp<s
	vidx nvox cp<s
	'pah 2048 cp<s 'pas 2048 cp<s 'pav 2048 cp<s 'pmt 2048 cp<s
	'prg 2048 cp<s 'pgl 2048 cp<s 'prgb 2048 cp<s
	refreshstrips 1 'dirty ! 0 'aok ! pushundo ;

:slotswitch | n --
	dup slotcur =? ( 2drop ; ) drop
	slotcur slotsave
	1 'sused slotcur + c!
	dup 'slotcur !
	slotload ;

|----------------------------------
| importar .vox (MagicaVoxel): primer modelo, paleta RGBA o la de MagicaVoxel por defecto
#defpal
	$00000000 $ffffffff $ffccffff $ff99ffff $ff66ffff $ff33ffff $ff00ffff $ffffccff
	$ffccccff $ff99ccff $ff66ccff $ff33ccff $ff00ccff $ffff99ff $ffcc99ff $ff9999ff
	$ff6699ff $ff3399ff $ff0099ff $ffff66ff $ffcc66ff $ff9966ff $ff6666ff $ff3366ff
	$ff0066ff $ffff33ff $ffcc33ff $ff9933ff $ff6633ff $ff3333ff $ff0033ff $ffff00ff
	$ffcc00ff $ff9900ff $ff6600ff $ff3300ff $ff0000ff $ffffffcc $ffccffcc $ff99ffcc
	$ff66ffcc $ff33ffcc $ff00ffcc $ffffcccc $ffcccccc $ff99cccc $ff66cccc $ff33cccc
	$ff00cccc $ffff99cc $ffcc99cc $ff9999cc $ff6699cc $ff3399cc $ff0099cc $ffff66cc
	$ffcc66cc $ff9966cc $ff6666cc $ff3366cc $ff0066cc $ffff33cc $ffcc33cc $ff9933cc
	$ff6633cc $ff3333cc $ff0033cc $ffff00cc $ffcc00cc $ff9900cc $ff6600cc $ff3300cc
	$ff0000cc $ffffff99 $ffccff99 $ff99ff99 $ff66ff99 $ff33ff99 $ff00ff99 $ffffcc99
	$ffcccc99 $ff99cc99 $ff66cc99 $ff33cc99 $ff00cc99 $ffff9999 $ffcc9999 $ff999999
	$ff669999 $ff339999 $ff009999 $ffff6699 $ffcc6699 $ff996699 $ff666699 $ff336699
	$ff006699 $ffff3399 $ffcc3399 $ff993399 $ff663399 $ff333399 $ff003399 $ffff0099
	$ffcc0099 $ff990099 $ff660099 $ff330099 $ff000099 $ffffff66 $ffccff66 $ff99ff66
	$ff66ff66 $ff33ff66 $ff00ff66 $ffffcc66 $ffcccc66 $ff99cc66 $ff66cc66 $ff33cc66
	$ff00cc66 $ffff9966 $ffcc9966 $ff999966 $ff669966 $ff339966 $ff009966 $ffff6666
	$ffcc6666 $ff996666 $ff666666 $ff336666 $ff006666 $ffff3366 $ffcc3366 $ff993366
	$ff663366 $ff333366 $ff003366 $ffff0066 $ffcc0066 $ff990066 $ff660066 $ff330066
	$ff000066 $ffffff33 $ffccff33 $ff99ff33 $ff66ff33 $ff33ff33 $ff00ff33 $ffffcc33
	$ffcccc33 $ff99cc33 $ff66cc33 $ff33cc33 $ff00cc33 $ffff9933 $ffcc9933 $ff999933
	$ff669933 $ff339933 $ff009933 $ffff6633 $ffcc6633 $ff996633 $ff666633 $ff336633
	$ff006633 $ffff3333 $ffcc3333 $ff993333 $ff663333 $ff333333 $ff003333 $ffff0033
	$ffcc0033 $ff990033 $ff660033 $ff330033 $ff000033 $ffffff00 $ffccff00 $ff99ff00
	$ff66ff00 $ff33ff00 $ff00ff00 $ffffcc00 $ffcccc00 $ff99cc00 $ff66cc00 $ff33cc00
	$ff00cc00 $ffff9900 $ffcc9900 $ff999900 $ff669900 $ff339900 $ff009900 $ffff6600
	$ffcc6600 $ff996600 $ff666600 $ff336600 $ff006600 $ffff3300 $ffcc3300 $ff993300
	$ff663300 $ff333300 $ff003300 $ffff0000 $ffcc0000 $ff990000 $ff660000 $ff330000
	$ff0000ee $ff0000dd $ff0000bb $ff0000aa $ff000088 $ff000077 $ff000055 $ff000044
	$ff000022 $ff000011 $ff00ee00 $ff00dd00 $ff00bb00 $ff00aa00 $ff008800 $ff007700
	$ff005500 $ff004400 $ff002200 $ff001100 $ffee0000 $ffdd0000 $ffbb0000 $ffaa0000
	$ff880000 $ff770000 $ff550000 $ff440000 $ff220000 $ff110000 $ffeeeeee $ffdddddd
	$ffbbbbbb $ffaaaaaa $ff888888 $ff777777 $ff555555 $ff444444 $ff222222 $ff111111

#vsx #vsy #vsz #vgot #vend
#offx #offy #offz
#mx #my #mz #mi

:importcolor | abgr slot --
	'si !
	dup $ff and swap dup 8 >> $ff and swap 16 >> $ff and
	rgb>hsv pset ;

:vc.size | adr --
	d@+ 'vsx ! d@+ 'vsy ! d@ 'vsz !
	nv vsx - 2/ 0 max 'offx !
	0 'offy !
	nv vsy - 2/ 0 max 'offz ! ;

:inb | -- 0/1
	vx vy max vz max nv <? ( drop 1 ; ) drop 0 ;

:putvox
	mx offx + 'vx ! mz offy + 'vy ! vsy 1- my - offz + 'vz !
	inb 0? ( drop ; ) drop
	1 vocc! mi vcolset ;

:vc.xyzi | adr --
	vgot 1? ( 2drop ; ) drop 1 'vgot !
	d@+
	( 1? 1- swap
		c@+ 'mx ! c@+ 'my ! c@+ 'mz ! c@+ 'mi !
		putvox
		swap ) 2drop ;

:vc.rgba | adr --
	0 ( 255 <?
		2dup 2 << + d@ over 1+ importcolor
		1+ ) 2drop ;

:vchunk | q --
	dup d@
	"SIZE" d@ =? ( drop 12 + vc.size ; )
	"XYZI" d@ =? ( drop 12 + vc.xyzi ; )
	"RGBA" d@ =? ( drop 12 + vc.rgba ; )
	2drop ;

:parsevox | start end --
	'vend ! 8 +
	( vend <?
		dup vchunk
		dup 4 + d@ 0 max 12 + + ) drop ;

:defpalvox
	1 ( 256 <? dup dup 3 << 'defpal + @ swap importcolor 1+ ) drop ;

:importvox | "path" --
	here swap load
	dup here - 24 <? ( 2drop ; ) drop
	here d@ "VOX " d@ <>? ( 2drop ; ) drop
	pushundo
	vidx 0 nvox 2 >> dfill
	'o_clear eachvox
	0 'vgot ! 0 'offx ! 0 'offy ! 0 'offz !
	defpalvox
	here swap parsevox
	refreshstrips 1 'dirty ! 0 'aok ! ;

|--- lista de archivos .vox
#vpath "media/ssv/vox"
#names * 65536
#names>
#list * 8192
#nlist
#fpage #fi 
#fnm

:isvox? | str -- str 1/0
	count 4 <? ( drop 0 ; ) over + 4 - ".vox" =s ;

:addname | ent --
	nlist 1000 >=? ( 2drop ; ) drop
	dup FDIR 1? ( 2drop ; ) drop
	dup FSIZEF 16000000 >? ( 2drop ; ) drop
	FNAME isvox? 0? ( 2drop ; ) drop
	names> dup 'list nlist 3 << + ! strcpyl 'names> ! 1 'nlist +! ;

:scanvox
	0 'nlist ! 0 'fpage ! 'names 'names> !
	'vpath
|WIN|	"%s//*" sprint
	ffirst ( 1? addname fnext ) drop ;

:filepick
	fi 3 << 'list + @ 'fnm !
	fnm slotcur 5 << 'snames + strcpy
	fnm 'vpath "%s/%s" sprint importvox ;

|----------------------------------
| geometria en el mundo: el objeto esta centrado en x z y apoyado en y=0
#oscl 3.0		| escala (voxel = 0.01 * escala)
:vox 0.01 oscl *. ;
:half nv vox * 2/ ;
:cellc | g -- p		; centro de la celda g relativo al centro del objeto
	2* 1+ nv - vox * 2/ ;

|----------------------------------
| picking: rayo del mouse contra el objeto, recorrido exacto por celdas (DDA)
#camForMouse 0 0 0
#xdir #ydir
#ro 0 0 0
#rd 0 0 0
#tn #tf #miss #so #sd
#hitok #pok #fok #bok
#hcell 0 0 0		| voxel apuntado
#pcell 0 0 0		| ultima celda vacia que cruzo el rayo antes del voxel
#fcell 0 0 0		| primera celda del rayo
#bcell 0 0 0		| primera celda del piso (y=0) del rayo
#cc 0 0 0			| celda actual
#ss 0 0 0			| paso por eje (+1/-1)
#tm 0 0 0			| t del proximo borde por eje
#td 0 0 0			| t por celda por eje
#lax #ai #cop #cdd #cp0 #a3

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

:cp3 | 'dst 'src --
	swap >a dup @ a!+ dup 8 + @ a!+ 16 + @ a! ;
:setcc 3 << 'cc + ! ;
:setss 3 << 'ss + ! ;
:settm 3 << 'tm + ! ;
:settd 3 << 'td + ! ;

:dinit | i --		; celda de entrada, paso y tiempos del eje i
	'ai !
	'ro ai 3 << + @ 'cop ! 'rd ai 3 << + @ 'cdd !
	cop cdd tn *. + half + 0 max vox / nv 1- min 'cp0 !
	cp0 ai setcc
	cdd abs 32 <? ( drop 1 ai setss 1000000.0 ai settm 1000000.0 ai settd ; ) drop
	cdd 0 >? ( drop 1 ai setss cp0 1+ vox * half - cop - cdd /. ai settm vox cdd /. ai settd ; ) drop
	-1 ai setss cp0 vox * half - cop - cdd /. ai settm vox cdd neg /. ai settd ;

:ccocc | -- 0/1	; celda cc ocupada
	'cc @ 'vx ! 'cc 8 + @ 'vy ! 'cc 16 + @ 'vz !
	vocc? 1? ( drop 1 ; ) drop 0 ;

:minaxis | -- i
	0 'ai ! 'tm @ 'cop !
	'tm 8 + @ cop <? ( 1 'ai ! 'tm 8 + @ 'cop ! ) drop
	'tm 16 + @ cop <? ( 2 'ai ! ) drop
	ai ;

:advance | i -- ok	; avanza la celda en el eje i
	dup 'lax ! 3 << 'a3 !
	'cc a3 + @ 'ss a3 + @ +
	-? ( drop 0 ; ) nv >=? ( drop 0 ; )
	'cc a3 + !
	'tm a3 + @ 'td a3 + @ + 'tm a3 + !
	1 ;

:hithere
	'hcell 'cc cp3 1 'hitok !
	lax -? ( drop ; ) drop
	'pcell 'cc cp3
	'cc lax 3 << + @ 'ss lax 3 << + @ - 'pcell lax 3 << + !
	1 'pok ! ;

:emptyhere
	fok 0? ( 'fcell 'cc cp3 1 'fok ! ) drop
	bok 0? ( 'cc 8 + @ 0? ( 'bcell 'cc cp3 1 'bok ! ) drop ) drop ;

:ddastep | -- cont
	ccocc 1? ( drop hithere 0 ; ) drop
	emptyhere
	minaxis advance ;

:ddaloop 1 ( 1? drop ddastep ) drop ;

:rayhit
	0 'hitok ! 0 'pok ! 0 'fok ! 0 'bok ! 0 'miss ! -1 'lax !
	raylocal
	0 'tn ! 1000.0 'tf !
	'ro @ 'rd @ slab
	'ro 8 + @ 'rd 8 + @ slab
	'ro 16 + @ 'rd 16 + @ slab
	miss 1? ( drop ; ) drop
	tn tf >=? ( drop ; ) drop
	0 dinit 1 dinit 2 dinit
	ddaloop ;

:c>t | 'cell --
	>a a@+ 'tx ! a@+ 'ty ! a@ 'tz ! ;

:attachtarget | -- 0/1
	hitok 1? ( drop pok 0? ( ; ) drop 'pcell c>t 1 ; ) drop
	bok 1? ( drop 'bcell c>t 1 ; ) drop
	fok 0? ( ; ) drop
	'fcell c>t 1 ;

#curok
:pickat | -- 0/1	; objetivo de la herramienta en tx ty tz
	rayhit
	bmode 0? ( drop attachtarget ; ) drop
	hitok 0? ( ; ) drop
	'hcell c>t 1 ;

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
| instancias: 0 objeto, 1 cursor, 2 ancla, 3..5 paredes de referencia (solo las posteriores), 6..8 ejes
#qid #qzz #qxx #ac0
#ec #ei
#showref 1

:rsc | -- escala de las referencias (0 = ocultas)
	showref 0? ( ; ) drop oscl ;

:curscl | -- s
	curok 0? ( ; ) drop oscl 1.15 *. ;
:curcolor | -- c
	bmode 0? ( drop $40ff4003 ; ) 1 =? ( drop $ff404003 ; ) drop $40a0ff03 ;
:ancscl | -- s
	aok 0? ( ; ) drop oscl 1.15 *. ;

:bk | e -- p	; pared opuesta a la camara: +-(half + 1/2 voxel)
	half vox 2/ + swap -? ( drop ; ) drop neg ;
:ywall | -- y	; piso si la camara esta arriba, techo si esta abajo
	'camEye 8 + @ half - -? ( drop half 2* vox 2/ + ; ) drop vox 2/ neg ;

:walls
	'camEye @ bk half 0 qzz rsc 3 $ffffff00 3 ss3dset
	0 ywall 0 qid rsc 3 $ffffff00 4 ss3dset
	0 half 'camEye 16 + @ bk qxx rsc 3 $ffffff00 5 ss3dset ;

:axbar | x y z q col i --
	'ei ! 'ec !
	rsc 2 ec ei ss3dset
	rsc 0.25 *. rsc 0.3 *. rsc 0.25 *. ei ss3dscl3 ;

:axes
	half neg 'ac0 !
	ac0 half 0.3 *. + vox ac0 qzz $ff404003 6 axbar
	ac0 vox half 0.3 *. + ac0 qid $40ff4003 7 axbar
	ac0 vox ac0 half 0.3 *. + qxx $4080ff03 8 axbar ;

:placeall
	0 half 0 qid oscl 0 $ffffff00 0 ss3dset
	tx cellc ty cellc half + tz cellc qid curscl 1 curcolor 1 ss3dset
	ax cellc ay cellc half + az cellc qid ancscl 1 $ffff4003 2 ss3dset
	walls axes ;

|----------------------------------
| archivos del slot: mem/voxedN.vxd (editor) y mem/voxedN.ssv (exportar a ss3d)
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
	sv here over - slotcur 1+ "mem/voxed%d.vxd" sprint save
	sv 'here ! ;

:loadvxd
	here slotcur 1+ "mem/voxed%d.vxd" sprint load
	here - 100 <? ( drop ; ) drop
	here d@ nv <>? ( drop ; ) drop
	pushundo
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
	sv here over - slotcur 1+ "mem/voxed%d.ssv" sprint save
	sv 'here ! ;

:newmodel
	pushundo
	'o_clear eachvox ;

|----------------------------------
| interfaz
#showL 1 #showR 1 #showF 0
:tgL showL 1 xor 'showL ! ;
:tgR showR 1 xor 'showR ! ;
:tgF showF 1 xor 'showF ! ;

#radv #radn #radt
:radsel radn radv ! ;
:rad | 'var n "text" --	; radio propio
	'radt ! 'radn ! 'radv !
	uiZone 'radsel uiClk
	radv @ radn =? ( $ff3070c0 'fcolor ! uilFill ) drop
	$ffffffff 'fcolor ! radt uiLabelC ;

#ci
:palpick ci 'psel ! ;

:palui
	1 1 uiPad
	16 16 uiGrid
	0 ( 256 <? dup 'ci !
		uiZoneW 'palpick uiClk
		'prgb ci 3 << + @ 8 >> $ff000000 or 'fcolor ! uiFill
		ci psel =? ( $ffffffff 'fcolor ! uiRect ) drop
		uiNext
		1+ ) drop
	4 4 uiPad ;

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
	'bmode 0 "attach (V)" rad
	'bmode 1 "erase (F)" rad
	'bmode 2 "paint (G)" rad
	"FORMA" uiLabelC
	'bshape 0 "voxel (1)" rad
	'bshape 1 "line (2)" rad
	'bshape 2 "box (3)" rad
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

:slotpick ci slotswitch ;

:fprev fpage 1 - 0 max 'fpage ! ;
:fnext fpage 1 + nlist 9 + 10 / 1- 0 max min 'fpage ! ;

:filelist
	nlist 0? ( drop "(sin .vox)" uiLabelC ; ) drop
	fpage 10 * 10 + nlist min 
	fpage 10 * ( over <? dup 'fi !
		uiZone 'filepick uiClk
		$ff203050 'fcolor ! uilFill $ffffffff 'fcolor !
		dup 3 << 'list + @ uiLabel
		1+ ) 2drop
	'fprev "<" uiNBtn
	fpage 1+ nlist 9 + 10 / "%d / %d" sprint uiTlabel
	'fnext ">" uiNBtn uiLn ;

:slottxt | -- str
	ci 'sused + c@ 1? ( drop ci 1+ "%d*" sprint ; ) drop ci 1+ "%d" sprint ;

:filepanel
	uiPush
	0.5 %cw uiN
	8 4 uiGrid
	0 ( 32 <? dup 'ci !
		slottxt 'slotpick swap uiBtn
		ci slotcur =? ( $ffffffff 'fcolor ! uiRect ) drop
		uiNext
		1+ ) drop
	uiRest
	$ffffffff 'fcolor !
	'snames slotcur 5 << + slotcur 1+ "slot %d  %s" sprint uiLabelC
	'savevxd "guardar" uiNBtn 'loadvxd "cargar" uiNBtn 'exportssv ".ssv" uiNBtn uiLn
	'newmodel "vaciar" uiNBtn uiLn
	"VOX" uiLabelC
	'vpath uiLabelC
	'scanvox "buscar" uiNBtn uiLn
	filelist
	uiPop ;

:topbar
	'exit "Exit" uiNBtn
	'undo "deshacer" uiNBtn
	'tgL "paleta" uiNBtn
	'tgF "archivos" uiNBtn
	'tgR "herram." uiNBtn ;

:bottombar
	9 1 uiGrid
	'shadowon "sombras" uiToggle uiEx? 1? ( shadowon ss3dshadow! ) drop uiNext
	'rl_ao_on "SSAO" uiToggle uiNext
	'rl_aa_on "FXAA" uiToggle uiNext
	'showref "ref" uiToggle uiNext
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
	showF 1? (
		sw 19 * 100 / uiO
		$1f00ff00 'fcolor ! uiWinBox frect
		$ffffffff 'fcolor !
		filepanel ) drop
	showL 1? (
		sw 15 * 100 / uiO
		$1f00ff00 'fcolor ! uiWinBox frect
		$ffffffff 'fcolor !
		leftpanel ) drop
	showR 1? (
		sw 18 * 100 / uiE
		$1f00ff00 'fcolor ! uiWinBox frect
		$ffffffff 'fcolor !
		rightpanel ) drop
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
	<f3> =? ( tgL ) <f4> =? ( tgF ) <f5> =? ( tgR )
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
	1 'sused c!
	scanvox
	buildimg
	16 ss3dmem
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
