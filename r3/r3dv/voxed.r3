|MEM 128
| VOXED - editor de voxeles ss3d (un objeto a la vez, hasta 256 slots, color directo)
| PHREDA 2026
|
| mouse: left = tool (click) | right drag = orbit | middle drag = pan | wheel = zoom
| V F G = attach / erase / paint | 1 2 3 = voxel / line / box | X = cancel the first point
| U = undo | W S = zoom, A D Q E = pan | F1 shadows | F2 SSAO | F3 color | F4 files | F5 tools
| color: selector rimmcolor + paleta rapida (izquierdo elige, derecho guarda el color actual) + material
|
| modelo: nv x nv x nv voxeles (max 32: la mascara de capas es de 32 bits)
| los slots (hasta 256, como los frames de pixed.r3) viven en ssmulti.r3 (comprimidos de a uno, color
| $RRGGBBuma por voxel, sin paleta); el slot actual esta abierto (descomprimido) y se sube con ssm_sync
| sprites: 0 = cursor (1 voxel), 1 = barra de nv voxeles, 2.. = slots
|
| archivos (F4): carpeta de trabajo (media/ssv): los .ssv en la raiz, las subcarpetas son conjuntos de .vox
|   .ssv = todos los slots, recortados al bounding box al grabar, + .txt con los nombres; Open reemplaza todo
|   Save graba sobre el nombre actual (el anterior queda en .bak); pregunta antes de descartar cambios
|   .vox = intercambio con MagicaVoxel, actua sobre el slot actual (Import / Export)

^r3/lib/rand.r3
^r3/lib/mem.r3
^r3/lib/str.r3

^r3/util/varanim.r3
^r3/rimm/rimmgl.r3
^r3/rimm/rimmwid.r3
^r3/rimm/rimmcolor.r3
^r3/rimm/rimmfile.r3

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
#va #vl #vu

:cpytgt | 'dst --
	>a 'tgt @ a!+ 'tgt 8 + @ a!+ 'tgt 16 + @ a! ;

:makecam
	cam_yaw sincos cam_pit -0.24 max 0.24 min sincos	| syw cyw sp cp
	'camAdv >a
	pick2 neg over *. a!+
	over neg a!+
	pick3 neg over *. a!
	'camLat >a
	pick3 a!+
	0 a!+
	pick2 neg a!
	'camVU >a
	pick2 pick2 *. neg a!+
	dup a!+
	pick3 pick2 *. neg a!
	4drop
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
:npaln 4194304 ;				| capacidad de la tira de colores comprimida (256 slots, ~16K colores en promedio)

#nslots 1					| cantidad de slots (1..256)
#slotcur					| slot actual
#snames * 8192				| nombre de cada slot (32 bytes)
#sfresh * 256				| slot cargado de archivo: se centra al abrirlo por primera vez
#modif 0					| hay cambios sin grabar
#showF 0					| panel de archivos visible
#inview 0 #ccmod 0 #ppop 0		| mouse en la vista 3D / Ctrl apretado / popup abierto (rimm)
:curspr slotcur 2 + ;		| sprite de ssmulti del slot actual
#usnap						| copia para deshacer (ssm_snap)

#vx #vy #vz					| voxel de trabajo (y hacia arriba)
:vci | -- ci		; columna del voxel (ssmulti usa 32 de ancho)
	vx vz ssm_ci ;
:vlayer | -- capa	; la capa 0 es la de arriba
	nv 1- vy - ;
:vocc? | -- 0/bit
	curspr vci vlayer ssm_vget ;
:vocc! | 0/1 --
	curspr vci vlayer ssm_vocc! ;
:vcolset | color --
	curspr vci vlayer ssm_vcol! ;

|--- color actual: RGB (selector rimmcolor) + material, $RRGGBBuma (u rough 3b, m metal 3b, a glow 2b)
#ccol $ffff0000				| $RRGGBBuma del selector (rimmcolor): rgb + rough 3b, metal 3b, glow 2b
#curc $ffff0000				| color completo calculado una vez por cuadro

:rgb3 | r g b -- rgb
	swap 8 << or swap 16 << or ;

:ccolor | -- color		; evita el comodin $00000001 de la tira
	ccol $ffffffff and
	1 =? ( drop 0 ) ;

|--- paleta rapida (como dev/pixed.r3): izquierdo elige, derecho guarda el color actual
#qpal [
$000000 $1D2B53 $7E2553 $008751 $AB5236 $5F574F $C2C3C7 $FFF1E8
$FF004D $FFA300 $FFEC27 $00E436 $29ADFF $83769C $FF77A8 $FFCCAA
$FFFFFF $DDDDDD $BBBBBB $999999 $777777 $555555 $333333 $111111
$FF0000 $00FF00 $0000FF $FFFF00 $00FFFF $FF00FF $885533 $FF8800 ]
#pnb #ppb					| botones recien apretados / del cuadro anterior

|--- deshacer (un nivel): copia del slot actual
:snap						| copia sin marcar cambios
	curspr ssm_edit usnap ssm_snap ;
:pushundo					| antes de modificar
	snap 1 'modif ! ;
:undo
	usnap ssm_rest 1 'modif ! ;

|--- memoria: sprites de ssmulti (0 = cursor, 1 = barra, 2.. = slots)
:initmem
	here 'usnap ! ssm_snapsz 'here +!
	258 npaln ssm_ini
	1 ssm_crop!					| al grabar, cada slot se recorta a su bounding box
	1 1 1 ssm_add drop
	1 nv 1 ssm_add drop
	256 ( 1? 1- nv nv nv ssm_add drop ) drop
	0 ssm_edit $ffffff00 0 0 0 0 0 0 ssm_fill
	1 ssm_edit $ffffff00 0 0 0 0 0 nv 1- ssm_fill ;

:upvox | sube a la GPU lo que cambio
	'ss3dupcols 'ss3duppal 'ss3dupspr ssm_sync ;

|----------------------------------
| herramientas
#bmode 0		| 0 attach 1 erase 2 paint
#bshape 0		| 0 voxel 1 linea 2 caja
#shpx

:applycell | -- ; aplica el modo en el voxel vx vy vz
	bmode 0 =? ( drop 1 vocc! curc vcolset ; )
	1 =? ( drop 0 vocc! ; )
	drop vocc? 1? ( drop curc vcolset ; ) drop ;

:cellapply | x y z --
	'vz ! 'vy ! 'vx ! applycell ;

:eachvox | 'op --
	0 ( nv <? dup 'vz !
		0 ( nv <? dup 'vy !
			0 ( nv <? dup 'vx !
				pick3 ex
				1+ ) drop
			1+ ) drop
		1+ ) 2drop ;

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
#stp
:lerp | d a i -- v
	rot 16 << * stp / swap 16 << + $8000 + 16 >> ;
:doline
	tx ax - ty ay - tz az -				| dx dy dz
	pick2 abs pick2 abs max over abs max 1 max 'stp !
	0 ( stp <=?						| dx dy dz i
		pick3 ax pick2 lerp
		pick3 ay pick3 lerp
		pick3 az pick4 lerp
		cellapply
		1+ ) 4drop ;

#ex1 #ey1 #ez1			| limites superiores de la caja
:dobox
	ax tx max 'ex1 ! ay ty max 'ey1 ! az tz max 'ez1 !
	az tz min ( ez1 <=?
		ay ty min ( ey1 <=?
			ax tx min ( ex1 <=?
				dup pick2 pick4 cellapply
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

#vsy #vgot #vpass
#offx #offy #offz
#mx #my #mz #mi

#mpal * 1024		| paleta del .vox convertida: $RRGGBB00 por indice
:importcolor | abgr slot --
	swap dup $ff and swap dup 8 >> $ff and swap 16 >> $ff and
	rgb3 8 << swap 2 << 'mpal + d! ;

:vc.size | adr --
	d@+ nv swap - 2/ 0 max 'offx !
	d@ 'vsy !
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
	swap 8 +
	( over <?
		dup vchunk
		dup 4 + d@ 0 max 12 + + ) 2drop ;

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
	0 'vpass ! here over parsevox
	1 'vpass ! here swap parsevox
	0 'aok ! ;

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
#ro 0 0 0
#rd 0 0 0
#tn #tf #miss
#hitok #pok #lok
#hcell 0 0 0		| voxel apuntado
#pcell 0 0 0		| ultima celda vacia antes del voxel golpeado
#lcell 0 0 0		| ultima celda vacia que cruza el rayo (celda de salida si no hay golpe)
#cc 0 0 0			| celda actual
#ss 0 0 0			| paso por eje (+1/-1)
#tm 0 0 0			| t del proximo borde por eje
#td 0 0 0			| t por celda por eje
#lax #ai #cop

:AdvMouse
	sdlx 2* fix. sw / 1.0 - camAsp *. camFov *.		| xdir
	sdly 2* fix. sh / 1.0 - camFov *.				| xdir ydir
	'camForMouse >a
	'camAdv @      'camLat @      pick3 *. + 'camVU @      pick2 *. + a!+
	'camAdv 8 + @  'camLat 8 + @  pick3 *. + 'camVU 8 + @  pick2 *. + a!+
	'camAdv 16 + @ 'camLat 16 + @ pick3 *. + 'camVU 16 + @ pick2 *. + a!+
	2drop
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
	dup abs 32 <? ( 2drop abs half >? ( 1 'miss ! ) drop ; ) drop
	over half neg swap - over /.
	pick2 half swap - pick2 /.
	2dup min tn max 'tn !
	max tf min 'tf !
	2drop ;

:cp3 | 'dst 'src --
	swap >a dup @ a!+ dup 8 + @ a!+ 16 + @ a! ;
:setcc 3 << 'cc + ! ;
:setss 3 << 'ss + ! ;
:settm 3 << 'tm + ! ;
:settd 3 << 'td + ! ;

:dinit | i --		; celda de entrada, paso y tiempos del eje i
	'ro over 3 << + @ 'rd pick2 3 << + @			| i cop cdd
	over over tn *. + half + 0 max vox / nv 1- min	| i cop cdd cp0
	dup pick4 setcc
	over abs 32 <? ( drop 1 pick4 setss 1000000.0 pick4 settm 1000000.0 pick4 settd 4drop ; ) drop
	over 0 >? ( drop 1 pick4 setss dup 1+ vox * half - pick3 - pick2 /. pick4 settm vox pick2 /. pick4 settd 4drop ; ) drop
	-1 pick4 setss dup vox * half - pick3 - pick2 /. pick4 settm vox pick2 neg /. pick4 settd 4drop ;

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
	dup 'lax ! 3 <<						| a3
	'cc over + @ 'ss pick2 + @ +				| a3 nc
	-? ( 2drop 0 ; ) nv >=? ( 2drop 0 ; )
	'cc pick2 + !
	'tm over + @ 'td pick2 + @ + 'tm pick2 + !
	drop 1 ;

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
	immMouse dup 'inview !
	0 =? ( 0 'curok ! )
	1 =? ( wheelcam pickhover )												| over
	2 =? ( dnmouse sdlb 'pbtn ! pbtn 1 =? ( toolpress ) drop )				| in
	3 =? ( sdlb 4 =? ( orbitmouse ) 2 =? ( panmouse ) 1 =? ( tooldrag ) drop )	| active
	6 =? ( pbtn 1 =? ( toolclick ) drop )									| click
	drop ;

|----------------------------------
| instancias: 0 objeto, 1 cursor, 2 ancla, 3.. barras de limite
#qid #qzz #qxx
#bi #sgx #sgy #sgz

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
	rot * -rot * + 2 =? ( drop 1 ; ) drop 0 ;

:axbar | x y z q col --		; barra en toda la arista, instancia bi
	oscl swap 1 swap bi ss3dset
	oscl 0.25 *. oscl oscl 0.25 *. bi ss3dscl3
	1 'bi +! ;

:ebx | s1 s2 --		; arista en x: y = s1, z = s2
	2dup sgy sgz near? 1? ( drop 2drop ; ) drop
	0 pick2 half * half + pick2 half * qzz $ff404000 axbar
	2drop ;
:eby | s1 s2 --		; arista en y: x = s1, z = s2
	2dup sgx sgz near? 1? ( drop 2drop ; ) drop
	over half * half pick2 half * qid $40ff4000 axbar
	2drop ;
:ebz | s1 s2 --		; arista en z: x = s1, y = s2
	2dup sgx sgy near? 1? ( drop 2drop ; ) drop
	over half * over half * half + 0 qxx $4080ff00 axbar
	2drop ;

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
| documento: .ssv (todos los slots) + .txt (nombres); carpeta de trabajo; slots dinamicos; .vox del slot
#wpath * 1024			| carpeta de trabajo
#fname * 256			| nombre del .ssv actual, sin carpeta ni extension ("" = sin nombre)
#fbuf * 1024			| buffer de los dialogos
#fp1 * 1024 #fp2 * 1024
#fpend 0				| que hacer cuando se acepta el dialogo
#ask 0					| accion que espera confirmacion (hay cambios sin grabar)
#savecull 0				| grabar compacto: los voxeles ocultos pierden el color
#umsg 0					| mensaje de estado
#tbuf * 9000
#tp #rdd #rdn #rc #le #cfn
#spage 0 #gi

:snameadr | n -- adr
	5 << 'snames + ;

|--- cadenas y rutas
:lslash | "str" -- adr/0		; ultimo / o \
	0 'le !
	( dup c@ 1?
		$2f =? ( over 'le ! ) $5c =? ( over 'le ! )
		drop 1+ ) 2drop le ;

:basename | "path" -- "name"
	dup lslash 0? ( drop ; ) nip 1+ ;

:stripx | adr --			; saca la ultima extension (.xxx)
	0 'le !
	( dup c@ 1?
		$2e =? ( over 'le ! )
		drop 1+ ) 2drop
	le 1? ( dup 0 swap c! ) drop ;

:cpyn | src dst max --	; copia acotada, con 0 final
	'rdn ! 'rdd !
	count rdn min 'rc !
	rdd swap rc cmove
	0 rdd rc + c! ;

:setpath | "folder/name.ext" --	; wpath = carpeta, fname = nombre sin extension
	dup lslash 0? ( drop "." 'wpath strcpy 'fname 255 cpyn 'fname stripx ; )
	dup 1+ 'fname 255 cpyn
	over - 'rc !
	'wpath swap rc cmove
	0 'wpath rc + c!
	'fname stripx ;

:ssvpath | -- str
	'fname 'wpath "%s/%s.ssv" sprint ;
:txtpath | -- str
	'fname 'wpath "%s/%s.txt" sprint ;

:copyfile | "src" "dst" --
	swap here swap load here -				| dst n
	0? ( 2drop ; )
	here swap rot save ;

:fsz | "file" -- bytes
	here swap load here - ;

:backup | "file" --		; el anterior queda en file.bak
	dup "%s.bak" sprint copyfile ;

|--- nombres de los slots (.txt: uno por linea)
:tput | c --
	tp c! 1 'tp +! ;
:tstr | str --
	( dup c@ 1? tput 1+ ) 2drop ;
:tname | i -- str
	dup snameadr dup c@ 1? ( drop nip ; ) 2drop
	'fname c@ 0? ( drop "sprite_%d" sprint ; ) drop
	'fname "%s_%d" sprint ;
:writenames | "path" --
	'tbuf 'tp !
	0 ( nslots <? dup tname tstr 10 tput 1+ ) drop
	'tbuf tp 'tbuf - rot save ;

:rdline | dst --
	'rdd ! 0 'rdn !
	( tp c@ $ff and 'rc ! rc 1? drop
		rc 10 =? ( drop 1 'tp +! 0 rdd rdn + c! ; ) drop
		rc 13 <>? ( rdn 31 <? ( rc rdd rdn + c! 1 'rdn +! ) drop ) drop
		1 'tp +! ) drop
	0 rdd rdn + c! ;
:ldnames | "path.txt" --
	here swap load here - 'cfn !
	'snames 0 8192 cfill
	cfn 0? ( drop ; ) drop
	0 here cfn + c!
	here 'tp !
	0 ( nslots <? dup snameadr rdline 1+ ) drop ;

|--- slots: el actual esta abierto en ssmulti; los demas comprimidos
:cshift | lo hi -- d		; desplazamiento para centrar [lo..hi] en nv
	over - 1+ nv swap - 2/ swap - ;
:centerfresh			| slot cargado de archivo: contenido al centro del cubo y apoyado en el piso
	slotcur 'sfresh + c@ 0? ( drop ; ) drop
	0 slotcur 'sfresh + c!
	curspr ssm_bbox 0? ( drop 3drop 3drop ; ) drop	| x0 z0 l0 x1 z1 l1
	nv - 1+ 'sdy !
	rot drop rot swap					| x0 x1 z0 z1
	cshift 'sdz ! cshift 'sdx !
	sdx sdy or sdz or 0? ( drop ; ) drop
	snap 'o_shift eachvox ;

:slotopen | n --		; abre el slot n (sin preguntar)
	'slotcur !
	slotcur 5 >> 'spage !
	curspr ssm_edit
	centerfresh
	snap ;

:slotswitch | n --
	-? ( drop ; ) nslots >=? ( drop ; ) slotcur =? ( drop ; )
	cancel slotopen ;

:slotgap | p --		; hueco de slot en p: sprites, nombres y marcas corridos
	cancel
	dup 2 + ssm_ins
	nslots ( over >? dup 1- 'sfresh + c@ over 'sfresh + c!
		dup snameadr over 1- snameadr 32 cmove
		1- ) drop
	dup snameadr 0 32 cfill
	0 over 'sfresh + c!
	1 'nslots +!
	nv nv nv pick3 2 + ssm_size!
	drop 1 'modif ! ;

:slotadd
	nslots 256 >=? ( drop ; ) drop
	slotcur 1+ dup slotgap slotopen ;

:slotdup
	nslots 256 >=? ( drop ; ) drop
	slotcur 1+ slotgap
	slotcur 3 + slotcur 2 + ssm_copy
	slotcur 1+ snameadr slotcur snameadr 32 cmove
	slotcur 1+ slotopen ;

:slotdel
	cancel
	nslots 2 <? ( drop pushundo curspr ssm_clear ; ) drop
	slotcur 2 + ssm_del
	slotcur ( nslots 1- <? dup 1+ 'sfresh + c@ over 'sfresh + c!
		dup snameadr over 1+ snameadr 32 cmove
		1+ ) drop
	nslots 1- snameadr 0 32 cfill
	-1 'nslots +!
	slotcur nslots 1- min slotopen
	1 'modif ! ;

:slotprev slotcur 1- slotswitch ;
:slotnext slotcur 1+ slotswitch ;

|--- documento nuevo / abrir / grabar
:docclear
	cancel ssm_close
	nslots ( 1? 1- dup 2 + ssm_clear ) drop ssm_close
	nslots ( 1? 1- nv nv nv pick3 2 + ssm_size! ) drop
	1 'nslots ! 'snames 0 8192 cfill 'sfresh 0 256 cfill
	0 'fname c!
	0 slotopen
	0 'modif ! 0 'ask ! 0 'umsg ! ;

:docopen					| abre el .ssv de fbuf: reemplaza todo
	cancel ssm_close
	'fbuf 2 256 ssm_loadr
	0? ( drop curspr ssm_edit "open failed" 'umsg ! ; )
	'fbuf setpath
	256 min 'nslots !
	nslots ( 1? 1- nv nv nv pick3 2 + ssm_size! ) drop
	'sfresh 0 256 cfill 'sfresh 1 nslots cfill
	txtpath ldnames
	0 slotopen
	0 'modif ! 0 'ask ! "opened" 'umsg ! ;

:savessv
	savecull 1? ( drop 'fp1 2 nslots ssm_savecr ; ) drop
	'fp1 2 nslots ssm_saver ;

:suggest | -- str		; nombre propuesto para Save as
	'fname c@ 0? ( drop 'wpath "%s/new.ssv" sprint ; ) drop
	ssvpath ;

:openpend | code mode --	; abre el dialogo de rimm; al aceptar se ejecuta fpend
	swap 'fpend ! 'fbuf 1024 rot uiFileAsk ;

:saveasdlg
	suggest 'fbuf strcpy
	"ssv" uiFileFilter
	1 2 openpend ;

:docsave
	'fname c@ 0? ( drop saveasdlg ; ) drop
	cancel ssm_clrerr
	ssvpath 'fp1 strcpy
	'fp1 backup
	savessv
	txtpath 'fp2 strcpy
	'fp2 backup
	'fp2 writenames
	ssm_err 1? ( drop "ERROR: color strip full" 'umsg ! ; ) drop
	'fp1 fsz 16 <? ( drop "ERROR: could not write the file" 'umsg ! ; ) drop
	0 'modif ! "saved" 'umsg ! ;

:opendlg
	'wpath "%s/" sprint 'fbuf strcpy
	"ssv" uiFileFilter
	2 1 openpend ;

:importdlg
	'wpath "%s/" sprint 'fbuf strcpy
	"vox" uiFileFilter
	3 1 openpend ;

:vname | -- str		; nombre propuesto para exportar
	slotcur snameadr dup c@ 0? ( 2drop 'wpath "%s/sprite.vox" sprint ; ) drop
	'wpath "%s/%s.vox" sprint ;

:exportdlg
	vname 'fbuf strcpy
	"vox" uiFileFilter
	4 2 openpend ;

:ensext | ".ext" --		; fbuf termina en .ext
	'fbuf over =pos nip 1? ( 2drop ; ) drop
	'fbuf strcat ;

|--- exportar .vox: el slot actual recortado a su bounding box; con mas de 255 colores se usan los 255
|    mas frecuentes y el resto va al mas cercano en RGB; se pierde metal/rough/glow
#xb0 #xb1 #xb2 #xb3 #xb4 #xb5 #xn #xnd
#xvx #xdc #xct #xmp #xht #xpal #xw #wp #xp
#ez #exx #el #xc #xk #xj #xbest #xbd #xr #xg #xbb

:w1 | b --
	wp c! 1 'wp +! ;
:w4 | v --
	wp d! 4 'wp +! ;

:xfind | rgb -- idx		; indice del color distinto (lo agrega si no esta)
	'xc !
	xc 2654435761 * 16 >> $ffff and				| xi
	( xht over 2 << + d@ 1?					| xi xv
		1- dup 2 << xdc + d@ xc =? ( drop nip ; ) drop drop
		1+ $ffff and ) drop
	xc xnd 2 << xdc + d!
	0 xnd 2 << xct + d!
	xnd 1+ xht rot 2 << + d!
	xnd 1 'xnd +! ;

:xcount | idx --
	2 << xct + dup d@ 1+ swap d! ;

:xvox1
	ez 5 << exx +
	dup curspr swap el ssm_vget 0? ( 2drop ; ) drop
	curspr swap el ssm_vcol@ $ffffffff and 8 >> $ffffff and xfind
	dup xcount
	xn 4 << xvx + 'xp !
	exx xb0 - xp d!
	xb4 ez - xp 4 + d!
	xb5 el - xp 8 + d!
	xp 12 + d!
	1 'xn +! ;

:xcollect
	xht 0 262144 cfill
	0 'xn ! 0 'xnd !
	xb1 ( xb4 <=? dup 'ez !
		xb0 ( xb3 <=? dup 'exx !
			xb2 ( xb5 <=? dup 'el ! xvox1 1+ ) drop
			1+ ) drop
		1+ ) drop ;

:xtop						| los 255 colores mas usados
	0 ( 255 <? dup 'xk !
		-1 'xbest ! -1 'xbd !
		0 ( xnd <? dup 'xj !
			xj 2 << xct + d@ 'xc !
			xc xbd >? ( xj 'xbest ! xc 'xbd ! ) drop
			1+ ) drop
		xbest xk 2 << xpal + d!
		xk 1+ xbest 2 << xmp + d!
		-1 xbest 2 << xct + d!
		1+ ) drop ;

:xnear1 | j --			; el color j va al mas cercano de los elegidos
	'xj !
	xj 2 << xct + d@ -? ( drop ; ) drop
	xj 2 << xdc + d@ 'xc !
	xc 16 >> $ff and 'xr ! xc 8 >> $ff and 'xg ! xc $ff and 'xbb !
	-1 'xbd ! 0 'xbest !
	0 ( 255 <? dup 'xk !
		xk 2 << xpal + d@ 2 << xdc + d@ 'xc !
		xc 16 >> $ff and xr - dup *
		xc 8 >> $ff and xg - dup * +
		xc $ff and xbb - dup * +
		xbd -? ( over 'xbd ! xk 'xbest ! ) drop
		dup xbd <? ( over 'xbd ! xk 'xbest ! ) 2drop
		1+ ) drop
	xbest 1+ xj 2 << xmp + d! ;

:xpalette
	xnd 255 >? ( drop xtop 0 ( xnd <? dup xnear1 1+ ) drop ; ) drop
	0 ( xnd <? dup dup 1+ swap 2 << xmp + d! 1+ ) drop ;

:palrgba | k -- v
	'xk !
	xk xnd 255 min >=? ( drop $ff000000 ; ) drop
	xk 'xj !
	xnd 255 >? ( xk 2 << xpal + d@ 'xj ! ) drop
	xj 2 << xdc + d@ 'xc !
	xc 16 >> $ff and
	xc 8 >> $ff and 8 << or
	xc $ff and 16 << or
	$ff000000 or ;

:xwrite
	xw 'wp !
	"VOX " d@ w4 150 w4
	"MAIN" d@ w4 0 w4 xn 2 << 1076 + w4
	"SIZE" d@ w4 12 w4 0 w4
	xb3 xb0 - 1+ w4 xb4 xb1 - 1+ w4 xb5 xb2 - 1+ w4
	"XYZI" d@ w4 xn 2 << 4 + w4 0 w4 xn w4
	0 ( xn <?
		dup 4 << xvx + 'xp !
		xp d@ w1 xp 4 + d@ w1 xp 8 + d@ w1
		xp 12 + d@ 2 << xmp + d@ w1
		1+ ) drop
	"RGBA" d@ w4 1024 w4 0 w4
	0 ( 256 <? dup palrgba w4 1+ ) drop ;

:expvox | "path" --
	here dup 'xvx ! 524288 + dup 'xdc ! 131072 + dup 'xct ! 131072 +
	dup 'xmp ! 131072 + dup 'xht ! 262144 + dup 'xpal ! 1024 + 'xw !
	curspr ssm_bbox 0? ( drop 3drop 3drop drop "empty sprite" 'umsg ! ; ) drop
	'xb5 ! 'xb4 ! 'xb3 ! 'xb2 ! 'xb1 ! 'xb0 !
	xcollect xpalette xwrite
	xw wp xw - pick2 save drop
	"exported" 'umsg ! ;

|--- importar .vox al slot actual (el nombre del slot pasa a ser el del archivo)
:docimport
	'fbuf importvox
	'fbuf basename slotcur snameadr 31 cpyn
	slotcur snameadr stripx ;

|--- acciones que reemplazan el documento: preguntan si hay cambios sin grabar
:doact | code --
	1 =? ( drop docclear ; )
	2 =? ( drop opendlg ; )
	3 =? ( drop exit ; )
	drop ;
:guard | code --			| con cambios sin grabar pregunta (y abre el panel de archivos, donde se responde)
	modif 0? ( drop doact ; ) drop 'ask ! 1 'showF ! ;
:gnew 1 guard ;
:gopen 2 guard ;
:gexit 3 guard ;
:askyes ask doact 0 'ask ! ;
:askno 0 'ask ! ;
:escape						| ESC: cancela la pregunta pendiente o sale (preguntando si hay cambios)
	ask 1? ( drop askno ; ) drop 3 guard ;

:dopend | el dialogo se acepto: el camino esta en fbuf
	fpend 1 =? ( drop ".ssv" ensext 'fbuf setpath docsave 0 'fpend ! ; )
	2 =? ( drop docopen 0 'fpend ! ; )
	3 =? ( drop docimport 0 'fpend ! ; )
	4 =? ( drop ".vox" ensext 'fbuf expvox 0 'fpend ! ; )
	drop 0 'fpend ! ;

|----------------------------------
| interfaz (tamanos relativos al texto)
#showT 1 #showP 1 #showV 0
:tgT showT 1 xor 'showT ! ;
:tgP showP 1 xor 'showP ! ;
:tgF showF 1 xor 'showF ! ;


#radv #radn #radt
:radsel radn radv ! ;
:rad | 'var n "text" --	; radio propio
	'radt ! 'radn ! 'radv !
	uiZone 'radsel uiClk
	radv @ radn =? ( $ff3070c0 'fcolor ! uilFill ) drop
	$ffffffff 'fcolor ! radt uiLabelC ;

:bg | color --
	'fcolor ! uiWinBox frect $ffffffff 'fcolor ! ;


:qhit | n -- n		; click sobre la muestra: izquierdo elige, derecho guarda el color actual
	uiPopup? 1? ( drop ; ) drop
	pnb 5 and 0? ( drop ; ) drop
	sdlx cx <? ( drop ; ) cx cw + >=? ( drop ; ) drop
	sdly cy <? ( drop ; ) cy ch + >=? ( drop ; ) drop
	pnb 1 and? ( drop dup 2 << 'qpal + d@ 8 << ccol $ff and or 'ccol ! ; ) drop
	ccol 8 >> $ffffff and over 2 << 'qpal + d! ;

:qpalui
	1 1 uiPad
	8 4 uiGrid
	0 ( 32 <?
		'qpal over 2 << + d@ dup $ff000000 or 'fcolor ! uiFill
		ccol 8 >> $ffffff and =? ( $ffffffff 'fcolor ! uiRect ) drop
		qhit
		uiNext
		1+ ) drop
	4 4 uiPad ;

:palpanel
	uiPush
	0.5 %cw uiN
	qpalui
	uiRest
	$ffffffff 'fcolor !
	"left: pick / right: store" uiLabelC
	'ccol uiColorMatH
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

:pgprev spage 1- 0 max 'spage ! ;
:pgnext spage 1+ nslots 31 + 5 >> 1- min 'spage ! ;

:slotpick gi slotswitch ;
:slotcur? | -- 1/0		; el sprite del boton gi es el actual
	gi slotcur =? ( drop 1 ; ) drop 0 ;
:slotbtn			| boton numerado: relleno si es el sprite actual
	uiZone 'slotpick uiClk
	slotcur? skinTab sk
	colText gi 1+ "%d" sprint uiLabelC ;

:docname | -- str		; el lugar del * queda reservado: los botones de al lado no se mueven
	'fname c@ 0? ( drop modif 1? ( drop "(untitled) *" ; ) drop "(untitled)  " ; ) drop
	modif 1? ( drop 'fname "%s *" sprint ; ) drop 'fname "%s  " sprint ;

:filepanel
	$ffffffff 'fcolor !
	"- SPRITE NAME -" uiLabelC
	slotcur snameadr 31 uiInputLine
	ask 1? ( "Unsaved changes. Discard?" uiLabelC 'askyes "Yes" uiNBtn 'askno "No" uiNBtn uiLn ) drop
	"- SSV -" uiLabelC
	'wpath uiLabelC
	'gnew "New" uiNBtn 'gopen "Open" uiNBtn 'docsave "Save" uiNBtn 'saveasdlg "Save as" uiNBtn uiLn
	'savecull "compact" uiToggle
	"- VOX (this sprite) -" uiLabelC
	'importdlg "Import" uiNBtn 'exportdlg "Export" uiNBtn uiLn
	umsg 1? ( umsg uiLabelC ) drop
	ssm_err 1? ( "ERROR: color strip full" uiLabelC ) drop ;

:statusline			| archivo y comandos de la tira
	$ffffffff 'fcolor !
	docname uiTlabel
	"   " uiTlabel
	'pgprev "<" uiNBtn
	nslots 31 + 5 >> spage 1+ "page %d/%d" sprint uiTlabel
	'pgnext ">" uiNBtn
	"   " uiTlabel
	'slotadd "Add" uiNBtn 'slotdup "Copy" uiNBtn 'slotdel "Del" uiNBtn
	nslots slotcur 1+ "   sprite %d/%d" sprint uiTlabel ;

:slotstrip			| los botones numerados de la pagina
	32 1 uiGrid
	0 ( 32 <? dup spage 5 << + 'gi !
		gi nslots <? ( slotbtn ) drop
		uiNext
		1+ ) drop ;

:bottompanel
	uiPush
	txh 8 + uiN
	statusline
	uiRest
	slotstrip
	uiPop ;

:topbar
	'gexit "Exit" uiNBtn
	'undokey "Undo" uiNBtn
	'showT "Tools" uiNToggle
	'showV "View" uiNToggle
	'showP "Color" uiNToggle
	'showF "Files" uiNToggle
	;

:optshadow
	shadowon 0? ( drop ; ) drop
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
	txh 8 + 2* 8 + uiS $3f1f1f1f bg bottompanel

	showT 1? ( 22 3 << uiO $3f1f1f1f bg toolpanel ) drop
	showV 1? ( 22 3 << uiO $3f1f1f1f bg viewpanel ) drop
	showF 1? ( 28 3 << uiE $3f1f1f1f bg filepanel ) drop
	showP 1? ( 27 3 << uiE $3f1f1f1f bg palpanel ) drop	
	uiRest uiWinBox immBox
	viewmouse ;

#shadowlast 1
:kk | -- 1/0		; teclas de letra: solo en la vista 3D, sin popup ni Ctrl
	ppop 1? ( drop 0 ; ) drop
	ccmod 1? ( drop 0 ; ) drop
	inview ;

:hud
	fini
	sdlb ppb nand 'pnb !
	uiStart 4 4 uiPad immFull
	interface
	uiPopup? 'ppop !
	uiEnd
	sdlb 'ppb !
	fend
	uiFileDone? 1? ( dopend ) drop

	shadowon shadowlast <>? ( shadowon 'shadowlast ! shadowon ss3dshadow! ) drop

	sdlkey
	<ctrl> =? ( 1 'ccmod ! ) <ctr2> =? ( 1 'ccmod ! )
	>ctrl< =? ( 0 'ccmod ! ) >ctr2< =? ( 0 'ccmod ! )
	>esc< =? ( ppop 0? ( escape ) drop )
	<s> =? ( ccmod 1? ( docsave ) drop ) <o> =? ( ccmod 1? ( 2 guard ) drop ) <n> =? ( ccmod 1? ( 1 guard ) drop )
	<le> =? ( kk 1? ( slotprev ) drop ) <ri> =? ( kk 1? ( slotnext ) drop )
	<w> =? ( kk 1? ( -0.03 'va ! ) drop ) >w< =? ( 0 'va ! )
	<s> =? ( kk 1? ( 0.03 'va ! ) drop ) >s< =? ( 0 'va ! )
	<a> =? ( kk 1? ( 0.02 'vl ! ) drop ) >a< =? ( 0 'vl ! )
	<d> =? ( kk 1? ( -0.02 'vl ! ) drop ) >d< =? ( 0 'vl ! )
	<q> =? ( kk 1? ( 0.02 'vu ! ) drop ) >q< =? ( 0 'vu ! )
	<e> =? ( kk 1? ( -0.02 'vu ! ) drop ) >e< =? ( 0 'vu ! )
	<v> =? ( kk 1? ( 0 'bmode ! ) drop ) <f> =? ( kk 1? ( 1 'bmode ! ) drop ) <g> =? ( kk 1? ( 2 'bmode ! ) drop )
	<1> =? ( kk 1? ( 0 'bshape ! cancel ) drop ) <2> =? ( kk 1? ( 1 'bshape ! cancel ) drop ) <3> =? ( kk 1? ( 2 'bshape ! cancel ) drop )
	<x> =? ( kk 1? ( cancel ) drop )
	<u> =? ( kk 1? ( undokey ) drop ) <z> =? ( ccmod 1? ( undokey ) drop )
	<f1> =? ( shadowon 1 xor 'shadowon ! )
	<f2> =? ( rl_ao_on 1 xor 'rl_ao_on ! )
	<f3> =? ( tgP ) <f4> =? ( tgF ) <f5> =? ( tgT )
	drop
	keycam ;

|--- sombras: solo proyecta el modelo (instancia 0); cursor, ancla y barras de ejes no
#oldhook
:shhook
	1 ss3dlen!  oldhook ex  bi ss3dlen! ;

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
	"media/ssv" 'wpath strcpy
	initmem
	ccolor 'curc !
	curspr ssm_edit
	ssm_image
	16 ss3dmem
	snap 0 'modif ! ;

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
	rl_shadow_hook 'oldhook !  'shhook 'rl_shadow_hook !
	0.15 'rl_ao_radius !				| voxel = 0.03 (0.01 * oscl): radio ~5 voxeles
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
