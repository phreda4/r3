|MEM 64
| VOXED - editor de voxeles ss3d (un objeto a la vez, 32 slots, color directo)
| PHREDA 2026
|
| mouse: left = tool (click) | right drag = orbit | middle drag = pan | wheel = zoom
| V F G = attach / erase / paint | 1 2 3 = voxel / line / box | X = cancel the first point
| U = undo | W S = zoom, A D Q E = pan | F1 shadows | F2 SSAO | F3 color | F4 files | F5 tools
|
| modelo: nv x nv x nv voxeles (max 32: la mascara de capas es de 32 bits)
| los 32 slots viven en ssmulti.r3 (comprimidos de a uno, color $RRGGBBuma por voxel, sin paleta);
| el slot actual esta abierto (descomprimido) y se sube a la GPU con ssm_sync
| sprites: 0 = cursor (1 voxel), 1 = barra de nv voxeles, 2.. = slots

^r3/lib/rand.r3
^r3/lib/mem.r3
^r3/lib/str.r3

^r3/util/varanim.r3
^r3/rimm/rimmgl.r3
^r3/rimm/rimmwid.r3

^./renderlib.r3
^./ss3d.r3
^./ssmulti.r3
^./ss3dshadow.r3

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
| MODELO: 32 slots de nv x nv x nv voxeles con color directo, comprimidos de a uno (ssmulti.r3)
#nv 32			| voxeles por lado (max 32)
:nvox nv nv * nv * ;
:npaln nvox 34 * ;			| tiras: peor caso sin compresion de los 34 sprites

#sused * 32 #snames * 1024 #slotcur
:curspr slotcur 2 + ;		| sprite de ssmulti del slot actual
#usnap						| copia para deshacer (ssm_snap)

#vx #vy #vz					| voxel de trabajo (y hacia arriba)
:vci | -- ci\t\t; columna del voxel (ssmulti usa 32 de ancho)
	vx vz ssm_ci ;
:vlayer | -- capa\t; la capa 0 es la de arriba
	nv 1- vy - ;
:vocc? | -- 0/bit
	curspr vci vlayer ssm_vget ;
:vocc! | 0/1 --
	curspr vci vlayer ssm_vocc! ;
:vcolset | color --
	curspr vci vlayer ssm_vcol! ;

|--- color actual: HSV + material, $RRGGBBuma (u rough 3b, m metal 3b, a glow 2b)
#ch 60 #cs 255 #cv 255		| tono 0..359, saturacion y valor 0..255
#cmt 0 #crg 0 #cgl 0		| metal 0..7, rough 0..7, glow 0..3
#curc $ffff0000				| color actual calculado una vez por cuadro

:rgb3 | r g b -- rgb
	swap 8 << or swap 16 << or ;

#h_s #h_v #h_f #h_r #h_p #h_q #h_t
:hsv>rgb | h s v -- rgb\t\t; h 0..359 s v 0..255
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

:ccolor | -- color\t\t; evita el comodin $00000001 de la tira
	ch cs cv hsv>rgb 8 << crg 5 << cmt 2 << or cgl or or
	1 =? ( drop 0 ) ;

|--- muestras de color (solo referencia para elegir, no se guardan en el modelo)
#swc * 1024
#rw #hu #swi
:swatchhsv | i -- h s v
	'swi !
	swi 16 <? ( drop 0 0 swi 17 * ; ) drop
	swi 16 - 24 /mod swap 'rw ! 15 * 'hu !
	rw 5 <? ( drop hu 255 255 rw 40 * - ; ) drop
	hu 255 rw 4 - 40 * - 255 ;

:swinit
	0 ( 256 <? dup swatchhsv hsv>rgb over 2 << 'swc + d! 1+ ) drop ;

|--- deshacer (un nivel): copia del slot actual
:pushundo
	curspr ssm_edit usnap ssm_snap ;
:undo
	usnap ssm_rest ;

|--- memoria: sprites de ssmulti (0 = cursor, 1 = barra, 2.. = slots)
:initmem
	here 'usnap ! ssm_snapsz 'here +!
	34 npaln ssm_ini
	1 1 1 ssm_add drop
	1 nv 1 ssm_add drop
	32 ( 1? 1- nv nv nv ssm_add drop ) drop
	0 ssm_edit $ffffff00 0 0 0 0 0 0 ssm_fill
	1 ssm_edit $ffffff00 0 0 0 0 0 nv 1- ssm_fill ;

:upvox | sube a la GPU lo que cambio
	'ss3dupcols 'ss3duppal 'ss3dupspr ssm_sync ;

|----------------------------------
| herramientas
#bmode 0		| 0 attach 1 erase 2 paint
#bshape 0		| 0 voxel 1 linea 2 caja
#opx #shpx
#gx #gy #gz

:applycell | -- ; aplica el modo en el voxel vx vy vz
	bmode 0 =? ( drop 1 vocc! curc vcolset ; )
	1 =? ( drop 0 vocc! ; )
	drop vocc? 1? ( drop curc vcolset ; ) drop ;

:cellapply | x y z --
	'vz ! 'vy ! 'vx ! applycell ;

:eachvox | 'op --
	'opx !
	0 ( nv <? dup 'vz !
		0 ( nv <? dup 'vy !
			0 ( nv <? dup 'vx !
				opx ex
				1+ ) drop
			1+ ) drop
		1+ ) drop ;

|--- conjunto
:o_clear 0 vocc! ;
:o_fill 1 vocc! curc vcolset ;
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
:o_copyfrom | copia el voxel (sx0 sy0 sz0) de la copia (usnap: n, 1024 mascaras, pad) a vx vy vz
	usnap 4 + sz0 5 << sx0 + 2 << + d@ 1 nv 1- sy0 - << and
	0? ( drop 0 vocc! ; ) drop 1 vocc!
	usnap 4100 + sz0 5 << sx0 + 5 << nv 1- sy0 - + 2 << + d@ vcolset ;
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
	;

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
	;

|----------------------------------
| importar .vox (MagicaVoxel): primer modelo, paleta RGBA o la de MagicaVoxel por defecto
#defpal [
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
	]

#vsx #vsy #vsz #vgot #vend #vpass #vfe
#offx #offy #offz
#mx #my #mz #mi

#mpal * 1024		| paleta del .vox convertida: $RRGGBB00 por indice
#isl
:importcolor | abgr slot --
	'isl !
	dup $ff and swap dup 8 >> $ff and swap 16 >> $ff and
	rgb3 8 << 'mpal isl 2 << + d! ;

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
	1 vocc! mi 2 << 'mpal + d@ vcolset ;

:vc.xyzi | adr --		; segunda pasada (la paleta RGBA va despues de XYZI en el archivo)
	vpass 0? ( 2drop ; ) drop
	vgot 1? ( 2drop ; ) drop 1 'vgot !
	d@+
	( 1? 1- swap
		c@+ $ff and 'mx ! c@+ $ff and 'my ! c@+ $ff and 'mz ! c@+ $ff and 'mi !
		putvox
		swap ) 2drop ;

:vc.rgba | adr --		; primera pasada
	vpass 1 =? ( 2drop ; ) drop
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
	1 ( 256 <? dup dup 2 << 'defpal + d@ swap importcolor 1+ ) drop ;

:importvox | "path" --
	here swap load
	dup here - 24 <? ( 2drop ; ) drop
	here d@ "VOX " d@ <>? ( 2drop ; ) drop
	pushundo
	curspr ssm_clear
	0 'vgot ! 0 'offx ! 0 'offy ! 0 'offz !
	defpalvox
	'vfe !
	0 'vpass ! here vfe parsevox
	1 'vpass ! here vfe parsevox
	0 'aok ! ;

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
#hitok #pok #lok
#hcell 0 0 0		| voxel apuntado
#pcell 0 0 0		| ultima celda vacia antes del voxel golpeado
#lcell 0 0 0		| ultima celda vacia que cruza el rayo (celda de salida si no hay golpe)
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

:ccocc | -- 0/1	; celda cc ocupada (el pick no ve la vista previa: con forma pendiente lee la copia)
	'cc @ 'vx ! 'cc 8 + @ 'vy ! 'cc 16 + @ 'vz !
	aok 1? ( drop usnap 4 + vz 5 << vx + 2 << + d@ 1 vlayer << and 1? ( drop 1 ; ) drop 0 ; ) drop
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
	'lcell 'cc cp3 1 'lok ! ;

:ddastep | -- cont
	ccocc 1? ( drop hithere 0 ; ) drop
	emptyhere
	minaxis advance ;

:ddaloop 1 ( 1? drop ddastep ) drop ;

:rayhit
	0 'hitok ! 0 'pok ! 0 'lok ! 0 'miss ! -1 'lax !
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
	lok 0? ( ; ) drop
	'lcell c>t 1 ;

#curok
:pickat | -- 0/1	; objetivo de la herramienta en tx ty tz
	rayhit
	bmode 0? ( drop attachtarget ; ) drop
	hitok 0? ( ; ) drop
	'hcell c>t 1 ;

#lkey #pkey #pbtn
:tkey tx 8 << ty + 8 << tz + ;

:cancel | cancela la forma pendiente y vuelve al original
	aok 0? ( drop ; ) drop
	undo 0 'aok ! ;
:undokey aok 1? ( drop cancel ; ) drop undo ;

:drawshape | aplica la forma entre el ancla y el objetivo
	bshape 1 =? ( drop doline ; ) drop dobox ;

:preview | vista previa: siempre parte del original (copia de deshacer)
	aok 0? ( drop ; ) drop
	bshape 0? ( drop cancel ; ) drop
	tkey pkey =? ( drop ; ) 'pkey !
	undo drawshape ;

:pickhover
	pickat dup 'curok ! 1? ( drop preview ; ) drop
	aok 1? ( undo -1 'pkey ! ) drop ;

:toolpress | boton izquierdo abajo: paint con forma voxel (arrastrando continua)
	pickat dup 'curok ! 0? ( drop ; ) drop
	bshape 0? ( drop bmode 2 =? ( drop pushundo tx ty tz cellapply tkey 'lkey ! ; ) drop ; ) drop ;

:tooldrag
	pickat dup 'curok ! 0? ( drop ; ) drop
	bshape 0? ( drop bmode 2 =? ( drop tkey lkey =? ( drop ; ) 'lkey ! tx ty tz cellapply ; ) drop ; ) drop
	preview ;

:toolclick | click (boton soltado dentro): attach / erase voxel, y 1er/2do punto de linea y caja
	pickat dup 'curok ! 0? ( drop ; ) drop
	bshape 0? ( drop bmode 2 <>? ( drop pushundo tx ty tz cellapply ; ) drop ; ) drop
	aok 0? ( drop pushundo tx 'ax ! ty 'ay ! tz 'az ! 1 'aok ! tkey 'pkey ! ; ) drop
	undo drawshape 0 'aok ! ;

:viewmouse
	immMouse
	0 =? ( 0 'curok ! )
	1 =? ( wheelcam pickhover )												| over
	2 =? ( dnmouse sdlb 'pbtn ! pbtn 1 =? ( toolpress ) drop )				| in
	3 =? ( sdlb 4 =? ( orbitmouse ) 2 =? ( panmouse ) 1 =? ( tooldrag ) drop )	| active
	6 =? ( pbtn 1 =? ( toolclick ) drop )									| click
	drop ;

|----------------------------------
| instancias: 0 objeto, 1 cursor, 2 ancla, 3.. barras de limite
#qid #qzz #qxx
#ec #bi #e1 #e2 #na #nb #sgx #sgy #sgz

:curscl | -- s
	curok 0? ( ; ) drop oscl 1.15 *. ;
:curcolor | -- c
	bmode 0? ( drop $40ff4003 ; ) 1 =? ( drop $ff404003 ; ) drop $40a0ff03 ;
:ancscl | -- s
	aok 0? ( ; ) drop oscl 1.15 *. ;

|--- limites del objeto: 12 aristas del cubo (4 por eje) con la barra de ejes;
|    se apagan las 3 que miran a la camara (la arista cercana de cada eje)
:sgn | v -- s
	0 >? ( drop 1 ; ) drop -1 ;

:camsides
	'camEye @ sgn 'sgx !
	'camEye 8 + @ half - sgn 'sgy !
	'camEye 16 + @ sgn 'sgz ! ;

:near? | s1 s2 c1 c2 -- 0/1
	'nb ! 'na ! swap na * swap nb * + 2 =? ( drop 1 ; ) drop 0 ;

:axbar | x y z q col --		; barra en toda la arista, instancia bi
	'ec !
	oscl 1 ec bi ss3dset
	oscl 0.25 *. oscl oscl 0.25 *. bi ss3dscl3
	1 'bi +! ;

:ebx | s1 s2 --		; arista en x: y = s1, z = s2
	2dup sgy sgz near? 1? ( drop 2drop ; ) drop
	'e2 ! 'e1 !
	0 e1 half * half + e2 half * qzz $ff404000 axbar ;
:eby | s1 s2 --		; arista en y: x = s1, z = s2
	2dup sgx sgz near? 1? ( drop 2drop ; ) drop
	'e2 ! 'e1 !
	e1 half * half e2 half * qid $40ff4000 axbar ;
:ebz | s1 s2 --		; arista en z: x = s1, y = s2
	2dup sgx sgy near? 1? ( drop 2drop ; ) drop
	'e2 ! 'e1 !
	e1 half * e2 half * half + 0 qxx $4080ff00 axbar ;

:axes
	camsides 3 'bi !
	-1 -1 ebx -1 1 ebx 1 -1 ebx 1 1 ebx
	-1 -1 eby -1 1 eby 1 -1 eby 1 1 eby
	-1 -1 ebz -1 1 ebz 1 -1 ebz 1 1 ebz
	bi ss3dlen! ;

:placeall
	0 half 0 qid oscl curspr $ffffff00 0 ss3dset
	tx cellc ty cellc half + tz cellc qid curscl 0 curcolor 1 ss3dset
	ax cellc ay cellc half + az cellc qid ancscl 0 $ffff4003 2 ss3dset
	axes ;

|----------------------------------
| archivos del slot: mem/voxedN.ssv (guardar, sin perdida) y mem/voxedN_c.ssv (exportar a ss3d, compresion maxima)
:fslot | -- str
	slotcur 1+ "mem/voxed%d.ssv" sprint ;

:savevxd
	fslot curspr ssm_save1 ;

:loadvxd
	cancel pushundo
	fslot curspr ssm_load1 1? ( nv nv nv curspr ssm_size! ) drop ;

:exportssv
	slotcur 1+ "mem/voxed%d_c.ssv" sprint curspr ssm_savec1 ;

:newmodel
	pushundo curspr ssm_clear ;

:slotswitch | n --
	dup slotcur =? ( 2drop ; ) drop
	cancel
	1 'sused slotcur + c!
	'slotcur !
	curspr ssm_edit
	pushundo ;

|----------------------------------
| interfaz (tamanos relativos al texto)
#showT 1 #showP 1 #showF 0 #showV 0
:tgT showT 1 xor 'showT ! ;
:tgP showP 1 xor 'showP ! ;
:tgF showF 1 xor 'showF ! ;
:tgV showV 1 xor 'showV ! ;


#radv #radn #radt
:radsel radn radv ! ;
:rad | 'var n "text" --	; radio propio
	'radt ! 'radn ! 'radv !
	uiZone 'radsel uiClk
	radv @ radn =? ( $ff3070c0 'fcolor ! uilFill ) drop
	$ffffffff 'fcolor ! radt uiLabelC ;

:bg | color --
	'fcolor ! uiWinBox frect $ffffffff 'fcolor ! ;

#ci
:palpick				| muestra ci -> color actual
	ci swatchhsv 'cv ! 'cs ! 'ch ! ;

:palui
	1 1 uiPad
	16 16 uiGrid
	0 ( 256 <? dup 'ci !
		uiZoneW 'palpick uiClk
		'swc ci 2 << + d@ $ff000000 or 'fcolor ! uiFill
		uiNext
		1+ ) drop
	4 4 uiPad ;

:palpanel
	uiPush
	1.0 %cw uiN
	palui
	uiRest
	curc 8 >> dup $ff000000 or 'fcolor !
	"color #%h" sprint uiLabelC
	$ffffffff 'fcolor !
	"H" 0 359 'ch uiSlideriL
	"S" 0 255 'cs uiSlideriL
	"V" 0 255 'cv uiSlideriL
	"MATERIAL" uiLabelC
	"metal" 0 7 'cmt uiSlideriL
	"rough" 0 7 'crg uiSlideriL
	"glow" 0 3 'cgl uiSlideriL
	uiPop ;

:toolpanel
	"- MODE -" uiLabelC
	'bmode 0 "attach (V)" rad
	'bmode 1 "erase (F)" rad
	'bmode 2 "paint (G)" rad
	"- SHAPE -" uiLabelC
	'bshape 0 "voxel (1)" rad
	'bshape 1 "line (2)" rad
	'bshape 2 "box (3)" rad
	"- BUILD -" uiLabelC
	'a_clear "clear" uiNBtn 'a_fill "fill" uiNBtn 'a_rev "reverse" uiNBtn uiLn
	'a_sphere "sphere" uiNBtn 'a_cyl "cylinder" uiNBtn uiLn
	'a_pyr "pyramid" uiNBtn 'a_cone "cone" uiNBtn uiLn
	"MOVE (wrap)" uiLabelC
	"x" nv neg nv 'mvx uiSlideriL
	"y" nv neg nv 'mvy uiSlideriL
	"z" nv neg nv 'mvz uiSlideriL
	'mvreset "0" uiNBtn uiLn
	movepoll
	"INVERT" uiLabelC
	'a_ix "x" uiNBtn 'a_iy "y" uiNBtn 'a_iz "z" uiNBtn uiLn ;

:slotpick ci slotswitch ;

:fprev fpage 1 - 0 max 'fpage ! ;
:fnext fpage 1 + nlist 9 + 10 / 1- 0 max min 'fpage ! ;

:filelist
	nlist 0? ( drop "(no .vox)" uiLabelC ; ) drop
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
	ci slotcur =? ( drop ci 1+ "[%d]" sprint ; ) drop
	ci 'sused + c@ 1? ( drop ci 1+ "%d*" sprint ; ) drop ci 1+ "%d" sprint ;

:filepanel
	uiPush
	0.5 %cw uiN
	8 4 uiGrid
	0 ( 32 <? dup 'ci !
		slottxt 'slotpick swap uiBtn
		uiNext
		1+ ) drop
	uiRest
	$ffffffff 'fcolor !
	'snames slotcur 5 << + slotcur 1+ "slot %d  %s" sprint uiLabelC
	'savevxd "Save" uiNBtn 'loadvxd "Load" uiNBtn 'exportssv "Export .ssv" uiNBtn uiLn
	'newmodel "Clear" uiNBtn uiLn
	"VOX FILES" uiLabelC
	'vpath uiLabelC
	'scanvox "Scan" uiNBtn uiLn
	filelist
	uiPop ;

:topbar
	'exit "Exit" uiNBtn
	'undokey "Undo" uiNBtn
	'tgT "Tools" uiNBtn
	'tgV "View" uiNBtn
	'tgP "Color" uiNBtn
	'tgF "Files" uiNBtn
	;

:optshadow
	shadowon -? ( drop ; ) drop
	"az" 0.0 1.0 'sun_az uiSliderfL uiEx? 1? ( setsun ) drop 
	"alt" 0.0 0.25 'sun_el uiSliderfL uiEx? 1? ( setsun ) drop 
	;

:viewpanel
	"VIEW" uiLabelC
	
	'vtop "Top" uiNBtn
	'vfront "Front" uiNBtn
	'vside "Side" uiNBtn 
	uiLn uiLn 
	'shadowon "Shadows" uiToggle	
	optshadow
	'rl_ao_on "SSAO" uiToggle
	'rl_aa_on "FXAA" uiToggle
	;

:interface
	1 'fscale !
	$ffffffff 'fcolor !
	uiFull
	24 uiN
	$1f0000ff bg topbar
	txh 2 << uiS				| 4 textlines

	showT 1? ( 22 3 << uiO $3f1f1f1f bg toolpanel ) drop
	showV 1? ( 22 3 << uiO $3f1f1f1f bg viewpanel ) drop
	showF 1? ( 28 3 << uiE $3f1f1f1f bg filepanel ) drop
	showP 1? ( 27 3 << uiE $3f1f1f1f bg palpanel ) drop	
	uiRest uiWinBox immBox
	viewmouse ;

#shadowlast 1
:hud
	fini
	uiStart 4 4 uiPad immFull
	interface
	uiEnd
	fend

	shadowon shadowlast <>? ( shadowon 'shadowlast ! shadowon ss3dshadow! ) drop

	sdlkey
	>esc< =? ( exit )
	<w> =? ( -0.03 'va ! ) >w< =? ( 0 'va ! )
	<s> =? ( 0.03 'va ! ) >s< =? ( 0 'va ! )
	<a> =? ( 0.02 'vl ! ) >a< =? ( 0 'vl ! )
	<d> =? ( -0.02 'vl ! ) >d< =? ( 0 'vl ! )
	<q> =? ( 0.02 'vu ! ) >q< =? ( 0 'vu ! )
	<e> =? ( -0.02 'vu ! ) >e< =? ( 0 'vu ! )
	<v> =? ( 0 'bmode ! ) <f> =? ( 1 'bmode ! ) <g> =? ( 2 'bmode ! )
	<1> =? ( 0 'bshape ! cancel ) <2> =? ( 1 'bshape ! cancel ) <3> =? ( 2 'bshape ! cancel )
	<x> =? ( cancel )
	<u> =? ( undokey )
	<f1> =? ( shadowon 1 xor 'shadowon ! )
	<f2> =? ( rl_ao_on 1 xor 'rl_ao_on ! )
	<f3> =? ( tgP ) <f4> =? ( tgF ) <f5> =? ( tgT )
	drop
	keycam ;

:main
	vupdate
	ccolor 'curc !
	makecam
	upvox
	placeall
	rl_frame_begin
	SS3Ddraw
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
	ccolor 'curc !
	nv 2/ 'vx ! 0 'vy ! nv 2/ 'vz !
	curspr ssm_edit
	applycell 				| un voxel inicial (attach, color actual)
	1 'sused c!
	scanvox
	ssm_image
	16 ss3dmem
	pushundo ;

: | <<<<<<<< Boot
	"VOXED" 1280 768 GLini GLInfo
	$fff vaini
	glgfx
	|"media/ttf/Roboto-Medium.ttf" 16 txload txfont
	"media/ttf/VictorMono-Bold.ttf" 16 txload txfont
	initvox
	rl_init
	2048 ss3dshadowini
	1 ss3dshadowauto
	'viewresize SDLeventR
	setsun
	shadowon ss3dshadow!
	makecam

	'main SDLshow

	ss3dshadowend
	rl_shutdown
	SS3Dshutdown
	GLend
	;
