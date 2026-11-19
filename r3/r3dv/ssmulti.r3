| ssmulti.r3 - muchos 3dsprites ss3d en memoria estatica, comprimidos de a uno
| PHREDA 2026
|
| Cada 3dsprite guarda su propia region de la tira de colores: las tiras NO se comparten entre
| sprites (ni entre columnas), asi se puede editar de a uno: se abre (descomprime al pad de
| trabajo), se modifica y al cambiar de sprite (o con ssm_flush) se vuelve a comprimir y se
| acomoda la tira:
|   - mismo largo: se reescribe la region
|   - distinto largo: se corre la cola de la tira y se corrigen inicios de region y bases
| La mascara de ocupacion esta siempre en dcols (no hace falta abrir para leerla).
| Una columna con un solo color usa el flag de tira uniforme (base = $01000000 | indice).
| Todo en memoria estatica reservada en ssm_ini (sin malloc/realloc).
|
| MEMORIA: cada sprite ocupa SIEMPRE 32 x 32 columnas (ci = z*32 + x, 1024 por sprite) y 32 capas,
| sea cual sea su tamanio real (sx ly rw, <= 32). El tamanio real es metadata: al mostrar
| (ssm_image / ssm_sync) y al grabar solo se empaquetan las sx*rw columnas reales con la mascara
| recortada a las ly capas. Lo que queda fuera del tamanio se conserva en memoria (se puede
| agrandar de nuevo) pero no se ve ni se graba.
| En la GPU cada sprite empieza en la columna n*1024 y sus columnas van empaquetadas (z*sx + x).
|
| color directo $RRGGBBuma (no hay paleta indexada). Pad: un d por voxel, (ci*32 + capa)*4.
| Un bit apagado en la mascara hace que el color del pad se ignore.
|
| ssm_ini    | maxspr maxcolors --         reserva memoria (usa 'here')
| ssm_add    | sx layers rows -- n         agrega un sprite vacio (-1 si no entra o tamanio invalido)
| ssm_size!  | sx layers rows n --         cambia el tamanio real (no borra voxeles)
| ssm_size   | n -- sx layers rows
| ssm_ci     | x z -- ci                   columna dentro del sprite
| ssm_vget   | n ci layer -- 0/bit         ocupacion (no abre n)
| ssm_vocc!  | on n ci layer --            ocupa/vacia un voxel (abre n)
| ssm_vcol!  | color n ci layer --         color $RRGGBBuma del voxel (abre n)
| ssm_vcol@  | n ci layer -- color
|
| sobre el sprite ABIERTO (no hacen nada sin sprite abierto), x z layer inclusivos y recortados a 0..31:
| ssm_fill   | color x0 z0 l0 x1 z1 l1 --  ocupa y colorea la caja
| ssm_erase  | x0 z0 l0 x1 z1 l1 --        vacia la caja
| ssm_paint  | color x0 z0 l0 x1 z1 l1 --  cambia el color de los voxeles ocupados de la caja
| ssm_clear  | n --                        vacia el sprite (abre n)
| ssm_copy   | dst src --                  copia contenido y tamanio de src en dst (queda abierto dst)
|
| acceso directo al pad del sprite abierto:
| ssm_pad    | -- adr                      pad: adr + (ci*32 + capa)*4
| ssm_mask   | ci -- adr                   d de la mascara de la columna ci del abierto
| ssm_dirty  | --                          avisa que se modifico pad/mascara del abierto
|
| ayuda para undo (el que lo maneja es el editor):
| ssm_snapsz | -- bytes                    tamanio de una copia
| ssm_snap   | 'dst --                     copia el sprite abierto (pad + mascaras + cual es)
| ssm_rest   | 'src --                     abre el sprite de la copia y lo restaura
|
| ssm_edit   | n --                        abre n (comprime el abierto antes)
| ssm_flush  | --                          comprime el abierto (sigue abierto)
| ssm_close  | --                          comprime y cierra
| ssm_image  | --                          arma imagen .ssv en here para ss3dmem (deja here al inicio)
|                                          agregar TODOS los sprites antes de ssm_image
| ssm_sync   | 'upcols 'uppal 'upspr --    comprime y sube lo modificado ('ss3dupcols 'ss3duppal 'ss3dupspr)
| ssm_save   | "archivo.ssv" --            compresion completa (tiras compartidas, tamanio real)
| ssm_saver  | "archivo.ssv" first cnt --  idem, solo los sprites first .. first+cnt-1
| ssm_save1  | "archivo.ssv" n --          idem, solo el sprite n
| ssm_crop!  | 0/1 --                      al grabar, cada sprite se recorta a su bounding box de voxeles
|                                          (se corre al origen y su tamanio pasa a ser el del bbox)
| ssm_bbox   | n -- x0 z0 l0 x1 z1 l1 ok   bounding box de los voxeles de n (ok = 0 si esta vacio)
| ssm_savec  | "archivo.ssv" --            igual, y ademas los voxeles ocultos (6 vecinos llenos dentro del
|                                          sprite) pierden el color (comodin): mas chico, pero si se
|                                          vuelve a editar y se descubren salen sin color
| ssm_savec1 | "archivo.ssv" n --          idem ssm_savec, solo el sprite n
| ssm_savecr | "archivo.ssv" first cnt --  idem ssm_savec, solo los sprites first .. first+cnt-1
| ssm_load   | "archivo.ssv" --            carga .ssv completo y lo deja comprimido de a un sprite
| ssm_load1  | "archivo.ssv" n -- ok       carga el primer sprite del .ssv en n (toma su tamanio; queda abierto)
| ssm_loadr  | "archivo.ssv" first cnt -- n  carga el .ssv en los sprites first .. first+cnt-1 y vacia los que
|                                          sobran; devuelve la cantidad de sprites del archivo (0 = error)
| ssm_ins    | n --                        inserta un sprite vacio en n: los siguientes bajan un lugar y el
|                                          ultimo se pierde (se libera su tira); cantidad fija
| ssm_del    | n --                        saca el sprite n: los siguientes suben un lugar y el ultimo queda vacio
| ssm_clrerr | --                          borra el error (ssm_err)
| ssm_used ssm_cap ssm_n ssm_open ssm_err ssm_cols ssm_rstart ssm_rlen   consultas

^r3/lib/mem.r3
^r3/lib/math.r3

#SENT $00000001			| comodin / "sin color"

#smax #pmax				| capacidades: sprites, colores
#nspr #npal				| usados
#sprt #rst				| tabla de sprites (8 bytes: org d | sx ly rw 0 c) / regiones (inicio d, largo d)
#dcols #dpal			| columnas (mascara d, base d) 1024 por sprite y tira de colores (d)
#wcol #cbuf #cbo		| pad de trabajo 32x32x32, salida de compresion, bases relativas
#pbuf #sdirty			| buffer de empaquetado, flags por sprite (1 = columnas, 2 = tabla)
#xcols #xpal			| fuente de decodificacion (normalmente dcols/dpal)
#open -1 #wdirty #ssmerr
#pd0 #pd1				| rango modificado de la tira de colores

:smorg | n -- org
	10 << ;
:smsx | n -- sx
	3 << sprt + 4 + c@ $ff and ;
:smly | n -- layers
	3 << sprt + 5 + c@ $ff and ;
:smrw | n -- rows
	3 << sprt + 6 + c@ $ff and ;
:smnc | n -- columnas reales
	dup smsx swap smrw * ;
:smrs | n -- inicio
	3 << rst + d@ ;
:smrl | n -- largo
	3 << rst + 4 + d@ ;
:ncols | -- columnas en memoria
	nspr 10 << ;

::ssm_used npal ;
::ssm_cap pmax ;
::ssm_n nspr ;
::ssm_open open ;				| sprite abierto (descomprimido) o -1
::ssm_err ssmerr ;
::ssm_clrerr 0 'ssmerr ! ;
::ssm_cols | n -- cnt
	smnc ;
::ssm_rstart | n -- idx
	smrs ;
::ssm_rlen | n -- cnt
	smrl ;
::ssm_size | n -- sx layers rows
	dup smsx swap dup smly swap smrw ;
::ssm_ci | x z -- ci
	5 << + ;

|---- bounding box de los voxeles de un sprite (solo mascaras: no hace falta abrirlo)
#kx0 #kz0 #kl0 #kx1 #kz1 #kl1 #bo #bm #bci #bok
:bboxn | n -- ok
	smorg 'bo !
	32 'kx0 ! 32 'kz0 ! 32 'kl0 ! -1 'kx1 ! -1 'kz1 ! -1 'kl1 !
	0 ( 1024 <? dup 'bci !
		bci bo + 3 << dcols + d@ $ffffffff and 'bm !
		bm 1? (
			bci 31 and dup kx0 min 'kx0 ! kx1 max 'kx1 !
			bci 5 >> dup kz0 min 'kz0 ! kz1 max 'kz1 !
			bm ctz kl0 min 'kl0 ! bm msb kl1 max 'kl1 !
		) drop
		1+ ) drop
	kx1 -? ( drop 0 ; ) drop 1 ;

::ssm_bbox | n -- x0 z0 l0 x1 z1 l1 ok
	bboxn 'bok !
	kx0 kz0 kl0 kx1 kz1 kl1 bok ;

#scrop
::ssm_crop! | 0/1 --
	'scrop ! ;

:pdclr
	$7fffffff 'pd0 ! -1 'pd1 ! ;
:pdmk | a b --
	pd1 max 'pd1 ! pd0 min 'pd0 ! ;

:sfl | n bits --		; marca flags de GPU del sprite n
	swap sdirty + dup c@ pick2 or swap c! drop ;
:sflafter | n --		; columnas de los sprites siguientes
	1+ ( nspr <? dup 1 sfl 1+ ) drop ;

::ssm_ini | maxspr maxcolors --
	'pmax ! 'smax !
	here
	dup 'sprt ! smax 3 << +
	dup 'rst ! smax 3 << +
	dup 'dcols ! smax 13 << +
	dup 'dpal ! pmax 2 << +
	dup 'wcol ! 131072 +
	dup 'cbuf ! 131072 +
	dup 'cbo ! 4096 +
	dup 'pbuf ! 8192 +
	dup 'sdirty ! smax +
	align16 'here !
	sprt 0 smax 4 << cfill
	dcols 0 smax 13 << cfill
	sdirty 0 smax cfill
	0 'nspr ! 0 'npal ! -1 'open ! 0 'wdirty ! 0 'ssmerr !
	dcols 'xcols ! dpal 'xpal !
	pdclr ;

|---- tamanio
#ax #al #ar #an #sa
:dimok | v -- 1/0
	1 <? ( drop 0 ; ) 32 >? ( drop 0 ; ) drop 1 ;
:dimsok | -- 1/0
	ax dimok 0? ( ; ) drop
	al dimok 0? ( ; ) drop
	ar dimok ;
:setsz | sx ly rw n --
	3 << sprt + 4 + 'sa !
	sa 2 + c! sa 1+ c! sa c! ;

::ssm_add | sx layers rows -- n
	'ar ! 'al ! 'ax !
	dimsok 0? ( drop -1 ; ) drop
	nspr smax >=? ( drop -1 ; ) drop
	ax al ar nspr setsz
	nspr 10 << nspr 3 << sprt + d!
	npal nspr 3 << rst + d!
	0 nspr 3 << rst + 4 + d!
	nspr 3 sfl
	nspr dup 1+ 'nspr ! ;

::ssm_size! | sx layers rows n --
	'an ! 'ar ! 'al ! 'ax !
	dimsok 0? ( drop ; ) drop
	an -? ( drop ; ) nspr >=? ( drop ; ) drop
	ax al ar an setsz
	an 3 sfl ;

|---- decodificar / expandir
#gb #gl
:getcolor | base layer -- color
	'gl ! 'gb !
	gb $ffffffff and 24 >> 1 =? ( drop gb $ffffff and 2 << xpal + d@ ; ) drop
	gb gl + 2 << xpal + d@ ;

#ex_o #ex_m #ex_b #ex_w
:expandcol | ci --
	dup ex_o + 3 << xcols + d@+ $ffffffff and 'ex_m ! d@ 'ex_b !
	ex_m 0? ( 2drop ; ) drop
	7 << wcol + 'ex_w !
	0 ( 32 <?
		ex_m over >> 1 and
		1? ( over ex_b swap getcolor pick2 2 << ex_w + d! ) drop
		1+ ) drop ;

:smexpand | n --
	smorg 'ex_o !
	wcol SENT 32768 dfill
	0 ( 1024 <? dup expandcol 1+ ) drop ;

|---- comprimir el pad -> cbuf (tira) y cbo (base relativa a la region)
#cn_o #cn_co #cn_lu #cn_lc
#cm #clo #chi #cw #cuc #cuu

:uniform2? | -- 1/0
	SENT 'cuc ! 1 'cuu !
	clo ( chi <=?
		dup 2 << cw + d@
		SENT <>? (
			cuc SENT =? ( over 'cuc ! ) drop
			cuc <>? ( 0 'cuu ! )
		) drop
		1+ ) drop
	cuu ;

:uslot | -- slot		; reusa el slot si el color es igual al ultimo uniforme
	cn_lu 0 >=? ( cuc cn_lc =? ( 2drop cn_lu ; ) drop ) drop
	cuc cn_co 2 << cbuf + d!
	cn_co dup 'cn_lu ! cuc 'cn_lc !
	1 'cn_co +! ;

:compresscol | ci --
	dup cn_o + 3 << dcols + d@ $ffffffff and 'cm !
	cm 0? ( drop 0 swap 2 << cbo + d! ; ) drop
	cm ctz 'clo ! cm msb 'chi !
	dup 7 << wcol + 'cw !
	uniform2? 1? ( drop
		uslot $1000000 or swap 2 << cbo + d! ; ) drop
	cn_co clo - swap 2 << cbo + d!
	clo ( chi <=?
		dup 2 << cw + d@ cn_co 2 << cbuf + d!
		1 'cn_co +!
		1+ ) drop ;

:compress | n -- largo
	smorg 'cn_o !
	0 'cn_co ! -1 'cn_lu !
	0 ( 1024 <? dup compresscol 1+ ) drop
	cn_co ;

|---- region: mover la cola, corregir bases, colocar
#mf #mt #mc
:movecols | from to count --
	'mc ! 'mt ! 'mf !
	mt mf <? ( drop
		0 ( mc <? dup mf + 2 << dpal + d@ over mt + 2 << dpal + d! 1+ ) drop ; ) drop
	mc ( 1? 1- dup mf + 2 << dpal + d@ over mt + 2 << dpal + d! ) drop ;

#sd
:shiftbases | from_col delta --
	'sd !
	( ncols <? dup 3 << 4 + dcols + dup d@ sd + swap d! 1+ ) drop ;

#pn #ps #pa
:putbase | ci --
	dup pn smorg + 3 << dcols + 'pa !
	pa d@ $ffffffff and 0? ( drop 0 pa 4 + d! drop ; ) drop
	2 << cbo + d@ ps + pa 4 + d! ;

:placeregion | n --		; copia cbuf a la region de n y fija las bases de sus columnas
	dup 'pn ! smrs 'ps !
	0 ( pn smrl <? dup 2 << cbuf + d@ over ps + 2 << dpal + d! 1+ ) drop
	0 ( 1024 <? dup putbase 1+ ) drop ;

#nw #ow #dl #tf
:shiftregions | n --		; cola de la tira corrida dl: inicios y bases de los sprites siguientes
	dup sflafter
	dup smrs ow + 'tf !
	tf tf dl + npal tf - movecols
	dup 1+ ( nspr <? dup 3 << rst + dup d@ dl + swap d! 1+ ) drop
	1+ nspr <? ( dup smorg dl shiftbases ) drop
	dl 'npal +! ;

:smcommit
	open 0 <? ( drop ; ) drop
	wdirty 0? ( drop ; ) drop
	open compress 'nw !
	open smrl 'ow !
	nw ow - 'dl !
	npal dl + pmax >? ( drop 1 'ssmerr ! ; ) drop
	dl 1? ( open shiftregions ) drop
	nw open 3 << rst + 4 + d!
	open placeregion
	open 1 sfl
	open smrs dup nw + 1- pdmk
	dl 1? ( open smrs npal 1- pdmk ) drop
	0 'wdirty ! ;

|---- API: abrir / editar
::ssm_edit | n --
	-? ( drop ; ) nspr >=? ( drop ; ) open =? ( drop ; )
	smcommit
	dup smexpand 'open !
	0 'wdirty ! ;

::ssm_flush smcommit ;
::ssm_close smcommit -1 'open ! ;

:vok | n -- 1/0		; abre n, 1 si quedo abierto
	dup ssm_edit open =? ( drop 1 ; ) drop 0 ;

#vn #vci #vl #va
::ssm_vget | n ci layer -- 0/bit
	'vl ! swap smorg + 3 << dcols + d@ $ffffffff and 1 vl << and ;

::ssm_vocc! | on n ci layer --
	'vl ! 'vci ! dup 'vn ! vok 0? ( 2drop ; ) drop
	vn smorg vci + 3 << dcols + 'va !
	vn 1 sfl 1 'wdirty !
	1? ( drop va d@ 1 vl << or va d! ; ) drop
	va d@ 1 vl << nand va d!
	SENT vci 7 << vl 2 << + wcol + d! ;

::ssm_vcol! | color n ci layer --
	'vl ! 'vci ! dup 'vn ! vok 0? ( 2drop ; ) drop
	vci 7 << vl 2 << + wcol + d!
	vn 1 sfl 1 'wdirty ! ;

::ssm_vcol@ | n ci layer -- color
	'vl ! 'vci ! 'vn !
	vn open =? ( drop vci 7 << vl 2 << + wcol + d@ ; ) drop
	vn smorg vci + 3 << dcols + 4 + d@ vl getcolor ;

|---- acceso directo al pad del abierto
:colma | ci -- adr		; mascara de la columna ci del abierto
	open 10 << + 3 << dcols + ;

::ssm_pad wcol ;
::ssm_mask | ci -- adr
	colma ;
::ssm_dirty
	open -? ( drop ; ) drop
	1 'wdirty ! open 1 sfl ;

|---- por rango (sobre el abierto)
#bx0 #bz0 #bl0 #bx1 #bz1 #bl1
#rx0 #rz0 #rl0 #rx1 #rz1 #rl1 #rlm #rc #rm #rp #rxt

:smsrt | a b -- lo hi
	2dup <? ( drop ; ) drop swap ;
:smclp | v -- v'
	0 max 31 min ;

:rbox | x0 z0 l0 x1 z1 l1 --	; deja la caja ordenada y recortada en rx0..rl1, rlm = mascara de capas
	'bl1 ! 'bz1 ! 'bx1 ! 'bl0 ! 'bz0 ! 'bx0 !
	bx0 bx1 smsrt smclp 'rx1 ! smclp 'rx0 !
	bz0 bz1 smsrt smclp 'rz1 ! smclp 'rz0 !
	bl0 bl1 smsrt smclp 'rl1 ! smclp 'rl0 !
	1 rl1 rl0 - 1+ << 1- rl0 << $ffffffff and 'rlm ! ;

:reach | 'xt --		; xt: ci --
	'rxt !
	rz0 ( rz1 <=?
		rx0 ( rx1 <=?
			over 5 << over + rxt ex
			1+ ) drop
		1+ ) drop ;

:rdone
	1 'wdirty ! open 1 sfl ;

:fillcol | ci --
	dup colma dup d@ rlm or swap d!
	7 << wcol + 'rp !
	rl0 ( rl1 <=? rc over 2 << rp + d! 1+ ) drop ;

:erasecol | ci --
	dup colma dup d@ rlm nand swap d!
	7 << wcol + 'rp !
	rl0 ( rl1 <=? SENT over 2 << rp + d! 1+ ) drop ;

:paintcol | ci --
	dup colma d@ $ffffffff and 'rm !
	7 << wcol + 'rp !
	rl0 ( rl1 <=?
		rm over >> 1 and
		1? ( rc pick2 2 << rp + d! ) drop
		1+ ) drop ;

::ssm_fill | color x0 z0 l0 x1 z1 l1 --
	rbox 'rc !
	open -? ( drop ; ) drop
	'fillcol reach rdone ;

::ssm_erase | x0 z0 l0 x1 z1 l1 --
	rbox
	open -? ( drop ; ) drop
	'erasecol reach rdone ;

::ssm_paint | color x0 z0 l0 x1 z1 l1 --
	rbox 'rc !
	open -? ( drop ; ) drop
	'paintcol reach rdone ;

::ssm_clear | n --
	vok 0? ( drop ; ) drop
	0 ( 1024 <? dup open 10 << + 3 << dcols + 0 swap d! 1+ ) drop
	wcol SENT 32768 dfill
	rdone ;

#cs #cd
::ssm_copy | dst src --
	'cs ! 'cd !
	cd -? ( drop ; ) nspr >=? ( drop ; ) cs =? ( drop ; ) drop
	cs -? ( drop ; ) nspr >=? ( drop ; ) drop
	cs vok 0? ( drop ; ) drop
	smcommit
	cs smsx cs smly cs smrw cd setsz
	cd 3 sfl
	0 ( 1024 <?
		dup cs 10 << + 3 << dcols + d@
		over cd 10 << + 3 << dcols + d!
		1+ ) drop
	cd 'open !
	rdone ;

|---- undo: copia del sprite abierto (n, mascaras, pad)
#sdst
::ssm_snapsz 135172 ;
::ssm_snap | 'dst --
	'sdst !
	open -? ( drop -1 sdst d! ; ) drop
	open sdst d!
	0 ( 1024 <?
		dup open 10 << + 3 << dcols + d@
		over 2 << sdst 4 + + d!
		1+ ) drop
	sdst 4100 + wcol 131072 cmove ;

::ssm_rest | 'src --
	'sdst !
	sdst d@ -? ( drop ; ) nspr >=? ( drop ; ) ssm_edit
	open -? ( drop ; ) drop
	0 ( 1024 <?
		dup 2 << sdst 4 + + d@
		over open 10 << + 3 << dcols + d!
		1+ ) drop
	wcol sdst 4100 + 131072 cmove
	rdone ;

|---- GPU: columnas empaquetadas al tamanio real
#pk_d #pk_sx #pk_rw #pk_lm #pk_s #pk_a #pk_m #pk_b
:packspr | n dst --		; sx*rw columnas (mascara d, base d) de n en dst
	'pk_d !
	dup smsx 'pk_sx !
	dup smrw 'pk_rw !
	dup smly 1 swap << 1- $ffffffff and 'pk_lm !
	smorg 'pk_s !
	0 ( pk_rw <?
		0 ( pk_sx <?
			over 5 << over + pk_s + 3 << dcols + 'pk_a !
			pk_a d@ $ffffffff and pk_lm and 'pk_m !
			pk_m pk_d d!
			0 'pk_b !
			pk_m 1? ( pk_a 4 + d@ 'pk_b ! ) drop
			pk_b pk_d 4 + d!
			8 'pk_d +!
			1+ ) drop
		1+ ) drop ;

#imgs
::ssm_image | --
	smcommit
	here 'imgs !
	"SSV2" d@ , nspr , smax 10 << , pmax ,
	here sprt nspr 3 << cmove nspr 3 << 'here +!
	here 0 smax 13 << cfill
	0 ( nspr <? dup dup 13 << here + packspr 1+ ) drop
	smax 13 << 'here +!
	here dpal pmax 2 << cmove pmax 2 << 'here +!
	imgs 'here ! ;

#syc #syp #sys #si #sf
:syncspr | i --
	'si !
	si sdirty + c@ $ff and 'sf !
	sf 2 and 1? ( si 3 << 8 si 3 << sprt + sys ex ) drop
	sf 1 and 1? (
		si pbuf packspr
		si 13 << si smnc 3 << pbuf syc ex ) drop
	0 si sdirty + c! ;

::ssm_sync | 'upcols 'uppal 'upspr --
	'sys ! 'syp ! 'syc !
	smcommit
	0 ( nspr <? dup syncspr 1+ ) drop
	pd0 pd1 <=? ( pd0 2 << pd1 pd0 - 1+ 2 << dpal pd0 2 << + syp ex ) drop
	pdclr ;

|---- compresion completa (tiras compartidas con comodines, igual que vox2x) -> .ssv
#fpmax #fp #fh #fnp #fabort #hcnt #hidx #hp
#fss #fsn #fci #fov #fmp
#HM 524287
#WINDOW 128
#sst * 128

:fmatch | i -- 1/0
	'fci !
	fsn fnp fci - min 'fov !
	0 ( fov <?
		dup 2 << fss + d@
		SENT <>? (
			over fci + 2 << fp + d@
			SENT <>? ( over <>? ( 3drop 0 ; ) ) drop
		) drop
		1+ ) drop 1 ;

:fmset | k --
	dup 2 << fss + d@ SENT =? ( 2drop ; )
	swap fmp + 2 << fp + d! ;

:fmerge | p --
	'fmp !
	fmp fsn + fpmax >? ( drop 1 'fabort ! ; ) drop
	fmp fsn + fnp >? (
		fnp ( over <? SENT over 2 << fp + d! 1+ ) drop
		dup 'fnp ! ) drop
	0 ( fsn <? dup fmset 1+ ) drop ;

:fhash | -- idx
	2166136261 0 ( fsn <?
		dup 2 << fss + d@ rot xor 16777619 * $ffffffff and swap 1+ ) drop
	dup 15 >> xor HM and ;

:fhfind | -- P0/0
	hidx 16 ( 1? 1- swap
		dup HM and 2 << fh + d@
		0? ( 3drop 0 ; )
		dup fmatch 1? ( drop nip nip ; ) 2drop
		1+ swap )
	2drop 0 ;

:fhins | p --
	'hp !
	hcnt 393216 >=? ( drop ; ) drop
	hidx 16 ( 1? 1- swap
		dup HM and 2 << fh + dup d@ 0? ( drop hp swap d! 1 'hcnt +! 2drop ; ) 2drop
		1+ swap )
	2drop ;

:fwfind | -- P0/0
	fnp WINDOW - 1 max
	( fnp <? dup fmatch 1? ( drop ; ) drop 1+ ) drop 0 ;

:ffind | -- P0
	fhash 'hidx !
	fhfind 1? ( dup fmerge ; ) drop
	fwfind 1? ( dup fmerge dup fhins ; ) drop
	fnp dup fmerge dup fhins ;

#uc #uu
:suni? | -- 1/0		; todos los colores no comodin de la tira sst son iguales (uc)
	SENT 'uc ! 1 'uu !
	0 ( fsn <?
		dup 2 << 'sst + d@
		SENT <>? (
			uc SENT =? ( over 'uc ! ) drop
			uc <>? ( 0 'uu ! )
		) drop
		1+ ) drop
	uu ;

#ocols #osp #svf #svh #svtc #svoc #svn #svo #svsx #svrw #svlm #scull #sv0 #svc #szt #pq #oq #svox #svoz #svol
#svz #svx #svm #svb #svhm #svlo #svhi #sva
#hdr * 16

:nmask | z x -- m		; mascara de la columna (z,x) (ya recortada) del sprite que se graba, 0 si esta fuera
	-? ( 2drop 0 ; ) svsx >=? ( 2drop 0 ; )
	swap -? ( 2drop 0 ; ) svrw >=? ( 2drop 0 ; )
	svoz + 5 << swap svox + + svo + 3 << dcols + d@ $ffffffff and svol >> svlm and ;

:hidmask | -- hm		; capas con los 6 vecinos llenos
	svz svx 1- nmask
	svz svx 1+ nmask and
	svz 1- svx nmask and
	svz 1+ svx nmask and
	svm and
	svm 1 << and
	svm 1 >> and ;

:putl | l --
	svm over >> 1 and 0? ( 2drop ; ) drop
	svhm over >> 1 and 1? ( 2drop ; ) drop
	dup svol + svb swap getcolor over svlo - 2 << 'sst + d! drop ;

:savecol0 | z x --
	'svx ! 'svz !
	svz svoz + 5 << svx svox + + svo + 3 << dcols + 'sva !
	sva d@ $ffffffff and svol >> svlm and 'svm !
	svm 0? ( drop ; ) drop
	svm svoc 3 << ocols + d!
	sva 4 + d@ 'svb !
	0 'svhm ! scull 1? ( hidmask 'svhm ! ) drop
	svm ctz 'svlo ! svm msb 'svhi !
	svhi svlo - 1+ 'fsn ! 'sst 'fss !
	'sst SENT 32 dfill
	svlo ( svhi <=? dup putl 1+ ) drop
	suni? 1? ( drop uc 'sst d! 1 'fsn !
		ffind $1000000 or svoc 3 << ocols + 4 + d! ; ) drop
	ffind svlo - svoc 3 << ocols + 4 + d! ;

:savecol | z x --
	savecol0 1 'svoc +! ;

:prepspr | n --		; tamanio de salida y corrimiento (recorte al bounding box si ssm_crop! 1)
	dup sv0 - 3 << szt + 'pq !
	scrop 0? ( drop
		dup smsx pq c! dup smly pq 1+ c! smrw pq 2 + c!
		0 pq 3 + c! 0 pq 4 + c! 0 pq 5 + c! ; ) drop
	bboxn 0? ( drop 1 pq c! 1 pq 1+ c! 1 pq 2 + c!
		0 pq 3 + c! 0 pq 4 + c! 0 pq 5 + c! ; ) drop
	kx1 kx0 - 1+ pq c! kl1 kl0 - 1+ pq 1+ c! kz1 kz0 - 1+ pq 2 + c!
	kx0 pq 3 + c! kz0 pq 4 + c! kl0 pq 5 + c! ;

:savespr | n --
	dup 'svn !
	dup smorg 'svo !
	sv0 - 3 << szt + 'pq !
	pq c@ $ff and 'svsx ! pq 2 + c@ $ff and 'svrw !
	pq 3 + c@ $ff and 'svox ! pq 4 + c@ $ff and 'svoz ! pq 5 + c@ $ff and 'svol !
	pq 1+ c@ $ff and 1 swap << 1- $ffffffff and 'svlm !
	svoc svn sv0 - 3 << osp + d!
	svn sv0 - 3 << osp + 4 + 'oq !
	pq c@ oq c! pq 1+ c@ oq 1+ c! pq 2 + c@ oq 2 + c!
	0 ( svrw <? 0 ( svsx <? 2dup savecol 1+ ) drop 1+ ) drop ;

:totcols | -- cnt
	0 0 ( svc <? dup 3 << szt + dup c@ $ff and swap 2 + c@ $ff and * rot + swap 1+ ) drop ;

:savefile | "file" --
	'svf ! smcommit
	here 'svh !
	here 'szt ! svc 3 << 'here +!
	sv0 ( sv0 svc + <? dup prepspr 1+ ) drop
	totcols 'svtc !
	here dup 'osp ! svc 3 << +
	dup 'ocols ! svtc 3 << +
	dup 'fp ! npal 2 + 2 << +
	dup 'fh ! 2097152 +
	'here !
	osp 0 svc 3 << cfill
	ocols 0 svtc 3 << cfill
	fh 0 2097152 cfill
	SENT fp d! 1 'fnp ! 0 'fabort ! 0 'hcnt ! npal 2 + 'fpmax !
	0 'svoc !
	sv0 ( sv0 svc + <? dup savespr 1+ ) drop
	"SSV2" d@ 'hdr d! svc 'hdr 4 + d! svtc 'hdr 8 + d! fnp 'hdr 12 + d!
	'hdr 16 svf save
	osp svc 3 << svf append
	ocols svtc 3 << svf append
	fp fnp 2 << svf append
	fabort 1? ( 1 'ssmerr ! ) drop
	svh 'here ! ;

:svset | first cnt -- ok		; rango de sprites a grabar (recortado a los que existen)
	over -? ( 3drop 0 ; ) drop
	nspr pick2 - min 'svc !
	'sv0 !
	svc 1 <? ( drop 0 ; ) drop 1 ;

::ssm_saver | "file" first cnt --
	svset 0? ( 2drop ; ) drop 0 'scull ! savefile ;
::ssm_savecr | "file" first cnt --
	svset 0? ( 2drop ; ) drop 1 'scull ! savefile ;
::ssm_save | "file" --
	0 nspr ssm_saver ;
::ssm_savec | "file" --
	0 nspr ssm_savecr ;
::ssm_save1 | "file" n --
	1 ssm_saver ;
::ssm_savec1 | "file" n --
	1 ssm_savecr ;

|---- carga de .ssv completo -> individual
#ln #lc #ltab #lcols #lpal #lt #lo #lx #ly #lz #rp #ldn

:ldfld | n --		; campos de la entrada n de la tabla del archivo
	3 << ltab + 'lt !
	lt d@ 'lo !
	lt 4 + c@ $ff and 'lx !
	lt 5 + c@ $ff and 'ly !
	lt 6 + c@ $ff and 'lz ! ;

:ldone? | -- 1/0		; la entrada leida con ldfld es valida
	lx dimok 0? ( ; ) drop
	ly dimok 0? ( ; ) drop
	lz dimok 0? ( ; ) drop
	lo lx lz * + lc >? ( drop 0 ; ) drop 1 ;

:ldok? | -- 1/0
	0 ( ln <?
		dup ldfld
		ldone? 0? ( nip ; ) drop
		1+ ) drop 1 ;

:loadmap | n --		; columnas del archivo (z*sx+x) -> 1024 por sprite (z*32+x)
	dup 'ldn ! ldfld
	lx ly lz ldn setsz
	ldn 10 << ldn 3 << sprt + d!
	0 ( lz <?
		0 ( lx <?
			over lx * over + lo + 3 << lcols + @
			pick2 5 << pick2 + ldn 10 << + 3 << dcols + !
			1+ ) drop
		1+ ) drop ;

:smloadspr | n --
	dup smexpand dup 'pn ! compress 'nw !
	npal nw + pmax >? ( drop 1 'ssmerr ! ; ) drop
	pn 3 << rst + 'rp !
	npal rp d! nw rp 4 + d!
	pn placeregion
	nw 'npal +! ;

::ssm_load | "file" --
	here swap load here - 16 <? ( drop 1 'ssmerr ! ; ) drop
	here d@ "SSV2" d@ <>? ( drop 1 'ssmerr ! ; ) drop
	here 4 + d@ 'ln ! here 8 + d@ 'lc !
	ln smax >? ( drop 1 'ssmerr ! ; ) drop
	here 16 + 'ltab ! ltab ln 3 << + 'lcols ! lcols lc 3 << + 'lpal !
	ldok? 0? ( drop 1 'ssmerr ! ; ) drop
	sprt 0 smax 4 << cfill
	dcols 0 smax 13 << cfill
	sdirty 0 smax cfill
	0 ( ln <? dup loadmap 1+ ) drop
	ln 'nspr ! 0 'npal ! -1 'open ! 0 'wdirty !
	lpal 'xpal !
	0 ( nspr <? dup smloadspr 1+ ) drop
	dcols 'xcols ! dpal 'xpal !
	sdirty 3 nspr cfill
	pdclr 0 npal 1- pdmk ;

|---- carga del primer sprite de un .ssv en el sprite n (usa el pad del abierto)
#ldx2 #ldz2 #ldm #lda #ldb #ldp #ldlm
:ld1col | --		; columna (ldz2, ldx2) del archivo -> mascara y pad de n
	ldz2 lx * ldx2 + lo + 3 << lcols + 'lda !
	lda d@ $ffffffff and ldlm and 'ldm !
	ldz2 5 << ldx2 +
	dup ldm swap colma d!
	ldm 0? ( 2drop ; ) drop
	7 << wcol + 'ldp !
	lda 4 + d@ 'ldb !
	0 ( 32 <?
		ldm over >> 1 and
		1? ( over ldb swap getcolor pick2 2 << ldp + d! ) drop
		1+ ) drop ;

:ldparse | "file" -- ok		; lee el .ssv en here y valida la cabecera y todos los sprites
	here swap load here - 16 <? ( drop 0 ; ) drop
	here d@ "SSV2" d@ <>? ( drop 0 ; ) drop
	here 4 + d@ 'ln ! here 8 + d@ 'lc !
	ln 1 <? ( drop 0 ; ) drop
	here 16 + 'ltab ! ltab ln 3 << + 'lcols ! lcols lc 3 << + 'lpal !
	ldok? ;

:ldone | idx n --		; sprite idx del archivo (leido con ldparse) pasa al sprite n (usa el pad)
	'ldn ! ldfld
	ldn ssm_clear
	open ldn <>? ( drop ; ) drop
	lx ly lz ldn setsz ldn 3 sfl
	ly 1 swap << 1- $ffffffff and 'ldlm !
	lpal 'xpal !
	0 ( lz <? dup 'ldz2 !
		0 ( lx <? dup 'ldx2 ! ld1col 1+ ) drop
		1+ ) drop
	dpal 'xpal !
	rdone ;

::ssm_load1 | "file" n -- ok
	swap ldparse 0? ( nip ; ) drop
	0 swap ldone 1 ;

#lfirst #lcnt
::ssm_loadr | "file" first cnt -- n
	'lcnt ! 'lfirst !
	lfirst -? ( drop 0 ; ) nspr >=? ( drop 0 ; ) drop
	nspr lfirst - lcnt min 'lcnt !
	ldparse 0? ( ; ) drop
	lcnt ( 1? 1- dup lfirst + ssm_clear ) drop
	ssm_close
	0 ( ln lcnt min <? dup dup lfirst + ldone 1+ ) drop
	ssm_close
	ln ;

|---- insertar / sacar un sprite (la cantidad total no cambia)
#ra #rl
:smblank | n --		; sprite vacio de 1x1x1
	dup 13 << dcols + 0 8192 cfill
	dup 10 << over 3 << sprt + d!
	1 1 1 pick3 setsz
	3 sfl ;

::ssm_del | n --
	-? ( drop ; ) nspr >=? ( drop ; )
	dup ssm_clear ssm_close
	'ra !
	ra ( nspr 1- <?
		dup 1+ 3 << sprt + @ over 3 << sprt + !
		dup 1+ 3 << rst + @ over 3 << rst + !
		dup 13 << dcols + over 1+ 13 << dcols + 8192 cmove
		dup 10 << over 3 << sprt + d!
		dup 3 sfl
		1+ ) drop
	nspr 1- 'rl !
	rl smblank
	npal rl 3 << rst + d! 0 rl 3 << rst + 4 + d! ;

::ssm_ins | n --
	-? ( drop ; ) nspr >=? ( drop ; )
	nspr 1- ssm_clear ssm_close
	'ra !
	nspr 2 - ( ra >=?
		dup 3 << sprt + @ over 1+ 3 << sprt + !
		dup 3 << rst + @ over 1+ 3 << rst + !
		dup 1+ 13 << dcols + over 13 << dcols + 8192 cmove
		dup 1+ 10 << over 1+ 3 << sprt + d!
		dup 1+ 3 sfl
		1- ) drop
	ra smblank
	ra nspr 1- <? ( ra 1+ 3 << rst + d@ ra 3 << rst + d! ) drop
	0 ra 3 << rst + 4 + d! ;
