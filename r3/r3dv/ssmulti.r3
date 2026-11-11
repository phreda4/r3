| ssmulti.r3 - muchos 3dsprites ss3d en memoria estatica, comprimidos de a uno
| PHREDA 2026
|
| Cada 3dsprite (sx x layers x rows, columnas (x,z) con mascara de 32 bits) guarda su propia
| region de la tira de colores: las tiras NO se comparten entre sprites (ni entre columnas),
| asi se puede editar de a uno: se abre (descomprime a un area de trabajo), se modifica y
| al cambiar de sprite (o con ssm_flush) se vuelve a comprimir y se acomoda la tira:
|   - mismo largo: se reescribe la region
|   - distinto largo: se corre la cola de la tira y se corrigen inicios de region y bases de columnas
| La mascara de ocupacion esta siempre en dcols (no hace falta abrir para leerla).
| Una columna con un solo color usa el flag de tira uniforme (base = $01000000 | indice).
| Todo en memoria estatica reservada en ssm_ini (sin malloc/realloc).
|
| ssm_ini    | maxspr maxcols maxcolors --    reserva memoria (usa 'here')
| ssm_add    | sx layers rows -- n            agrega un sprite vacio (-1 si no entra)
| ssm_vget   | n ci layer -- 0/bit            ocupacion (ci = z*sx + x, layer = bit)
| ssm_vocc!  | on n ci layer --               ocupa/vacia un voxel (abre n)
| ssm_vcol!  | color n ci layer --            color $RRGGBBuma del voxel (abre n)
| ssm_vcol@  | n ci layer -- color
| ssm_edit   | n --                           abre n (comprime el abierto antes)
| ssm_flush  | --                             comprime el abierto (sigue abierto)
| ssm_close  | --                             comprime y cierra
| ssm_image  | --                             arma imagen .ssv en here para ss3dmem (deja here al inicio)
| ssm_sync   | 'upcols 'uppal --              comprime y sube lo modificado ('ss3dupcols 'ss3duppal)
| ssm_save   | "archivo.ssv" --               compresion completa (tiras compartidas, igual que vox2x)
| ssm_load   | "archivo.ssv" --               carga .ssv completo y lo deja comprimido de a un sprite
| ssm_used ssm_cap ssm_n ssm_err ssm_cols ssm_org ssm_rstart ssm_rlen   consultas

^r3/lib/mem.r3
^r3/lib/math.r3

#SENT $00000001			| comodin / "sin color"

#smax #cmax #pmax		| capacidades: sprites, columnas, colores
#nspr #ncols #npal		| usados
#sprt #rst			| tabla de sprites (8 bytes: org d | sx ly rw 0 c) / regiones (inicio d, largo d)
#dcols #dpal			| columnas (mascara d, base d) y tira de colores (d)
#wcol #cbuf #cbo		| area de trabajo 32x32x32, salida de compresion, bases relativas
#xcols #xpal			| fuente de decodificacion (normalmente dcols/dpal)
#open -1 #wdirty #ssmerr
#cd0 #cd1 #pd0 #pd1		| rangos modificados (columnas / colores)

:smorg | n -- org
	3 << sprt + d@ ;
:smsx | n -- sx
	3 << sprt + 4 + c@ $ff and ;
:smly | n -- layers
	3 << sprt + 5 + c@ $ff and ;
:smrw | n -- rows
	3 << sprt + 6 + c@ $ff and ;
:smnc | n -- columnas
	dup smsx swap smrw * ;
:smrs | n -- inicio
	3 << rst + d@ ;
:smrl | n -- largo
	3 << rst + 4 + d@ ;

::ssm_used npal ;
::ssm_cap pmax ;
::ssm_n nspr ;
::ssm_err ssmerr ;
::ssm_cols | n -- cnt
	smnc ;
::ssm_org | n -- org
	smorg ;
::ssm_rstart | n -- idx
	smrs ;
::ssm_rlen | n -- cnt
	smrl ;

:cdclr
	$7fffffff 'cd0 ! -1 'cd1 ! $7fffffff 'pd0 ! -1 'pd1 ! ;
:cdmk | a b --
	cd1 max 'cd1 ! cd0 min 'cd0 ! ;
:pdmk | a b --
	pd1 max 'pd1 ! pd0 min 'pd0 ! ;

::ssm_ini | maxspr maxcols maxcolors --
	'pmax ! 'cmax ! 'smax !
	here
	dup 'sprt ! smax 3 << +
	dup 'rst ! smax 3 << +
	dup 'dcols ! cmax 3 << +
	dup 'dpal ! pmax 2 << +
	dup 'wcol ! 131072 +
	dup 'cbuf ! 131072 +
	dup 'cbo ! 4096 +
	'here !
	sprt 0 smax 4 << cfill
	dcols 0 cmax 3 << cfill
	0 'nspr ! 0 'ncols ! 0 'npal ! -1 'open ! 0 'wdirty ! 0 'ssmerr !
	dcols 'xcols ! dpal 'xpal !
	cdclr ;

#ax #al #ar #ac
::ssm_add | sx layers rows -- n
	'ar ! 'al ! 'ax !
	nspr smax >=? ( drop -1 ; ) drop
	al 32 >? ( drop -1 ; ) drop
	ax ar * 'ac !
	ac 1024 >? ( drop -1 ; ) drop
	ncols ac + cmax >? ( drop -1 ; ) drop
	ncols nspr 3 << sprt + d!
	ax nspr 3 << sprt + 4 + c!
	al nspr 3 << sprt + 5 + c!
	ar nspr 3 << sprt + 6 + c!
	npal nspr 3 << rst + d!
	0 nspr 3 << rst + 4 + d!
	ac 'ncols +!
	nspr dup 1+ 'nspr ! ;

|---- decodificar / expandir
#gb #gl
:getcolor | base layer -- color
	'gl ! 'gb !
	gb $ffffffff and 24 >> 1 =? ( drop gb $ffffff and 2 << xpal + d@ ; ) drop
	gb gl + 2 << xpal + d@ ;

#ex_o #ex_c #ex_m #ex_b #ex_w
:expandcol | ci --
	dup ex_o + 3 << xcols + d@+ $ffffffff and 'ex_m ! d@ 'ex_b !
	ex_m 0? ( 2drop ; ) drop
	7 << wcol + 'ex_w !
	0 ( 32 <?
		ex_m over >> 1 and
		1? ( over ex_b swap getcolor pick2 2 << ex_w + d! ) drop
		1+ ) drop ;

:smexpand | n --
	dup smnc 'ex_c ! smorg 'ex_o !
	wcol SENT ex_c 5 << dfill
	0 ( ex_c <? dup expandcol 1+ ) drop ;

|---- comprimir el area de trabajo -> cbuf (tira) y cbo (base relativa a la region)
#cn_o #cn_c #cn_co #cn_lu #cn_lc
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
	dup smnc 'cn_c ! smorg 'cn_o !
	0 'cn_co ! -1 'cn_lu !
	0 ( cn_c <? dup compresscol 1+ ) drop
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
	0 ( pn smnc <? dup putbase 1+ ) drop ;

#nw #ow #dl #tf
:shiftregions | n --		; cola de la tira corrida dl: inicios y bases de los sprites siguientes
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
	open smorg dup open smnc + 1- cdmk
	open smrs dup nw + 1- pdmk
	dl 1? ( open smorg ncols 1- cdmk open smrs npal 1- pdmk ) drop
	0 'wdirty ! ;

|---- API: abrir / editar
::ssm_edit | n --
	open =? ( drop ; )
	smcommit
	dup smexpand 'open !
	0 'wdirty ! ;

::ssm_flush smcommit ;
::ssm_close smcommit -1 'open ! ;

#vn #vci #vl #va
::ssm_vget | n ci layer -- 0/bit
	'vl ! swap smorg + 3 << dcols + d@ $ffffffff and 1 vl << and ;

::ssm_vocc! | on n ci layer --
	'vl ! 'vci ! dup 'vn ! ssm_edit
	vn smorg vci + dup cd1 max 'cd1 ! dup cd0 min 'cd0 ! 3 << dcols + 'va !
	1 'wdirty !
	1? ( drop va d@ 1 vl << or va d! ; ) drop
	va d@ 1 vl << nand va d!
	SENT vci 7 << vl 2 << + wcol + d! ;

::ssm_vcol! | color n ci layer --
	'vl ! 'vci ! ssm_edit
	vci 7 << vl 2 << + wcol + d! 1 'wdirty ! ;

::ssm_vcol@ | n ci layer -- color
	'vl ! 'vci ! 'vn !
	vn open =? ( drop vci 7 << vl 2 << + wcol + d@ ; ) drop
	vn smorg vci + 3 << dcols + 4 + d@ vl getcolor ;

|---- GPU: imagen .ssv para ss3dmem y subida de lo modificado
#imgs
::ssm_image | --
	here 'imgs !
	"SSV2" d@ , nspr , cmax , pmax ,
	here sprt nspr 3 << cmove nspr 3 << 'here +!
	here dcols cmax 3 << cmove cmax 3 << 'here +!
	here dpal pmax 2 << cmove pmax 2 << 'here +!
	imgs 'here ! ;

#syc #syp
::ssm_sync | 'upcols 'uppal --
	'syp ! 'syc !
	smcommit
	cd0 cd1 <=? ( cd0 3 << cd1 cd0 - 1+ 3 << dcols cd0 3 << + syc ex ) drop
	pd0 pd1 <=? ( pd0 2 << pd1 pd0 - 1+ 2 << dpal pd0 2 << + syp ex ) drop
	cdclr ;

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

#ocols #svf #svh #svo #svm #svb #svlo #svhi #sva
#hdr * 16

:savecol | ci --
	svo + 3 << dcols + 'sva !
	sva d@ $ffffffff and 'svm !
	sva 4 + d@ 'svb !
	svm 0? ( drop ; ) drop
	svb $ffffffff and 24 >> 1 =? ( drop
		svb 0 getcolor 'sst d! 'sst 'fss ! 1 'fsn !
		ffind $1000000 or sva dcols - ocols + 4 + d! ; ) drop
	svm ctz 'svlo ! svm msb 'svhi !
	svhi svlo - 1+ 'fsn ! 'sst 'fss !
	'sst SENT 32 dfill
	svlo ( svhi <=?
		svm over >> 1 and
		1? ( over svb swap getcolor pick2 svlo - 2 << 'sst + d! ) drop
		1+ ) drop
	ffind svlo - sva dcols - ocols + 4 + d! ;

::ssm_save | "file" --
	'svf ! smcommit
	here 'svh !
	here dup 'ocols ! ncols 3 << +
	dup 'fp ! npal 2 + 2 << +
	dup 'fh ! 2097152 +
	'here !
	ocols dcols ncols 3 << cmove
	fh 0 2097152 cfill
	SENT fp d! 1 'fnp ! 0 'fabort ! 0 'hcnt ! npal 2 + 'fpmax !
	0 ( nspr <? dup smorg 'svo !
		0 ( over smnc <? dup savecol 1+ ) drop
		1+ ) drop
	"SSV2" d@ 'hdr d! nspr 'hdr 4 + d! ncols 'hdr 8 + d! fnp 'hdr 12 + d!
	'hdr 16 svf save
	sprt nspr 3 << svf append
	ocols ncols 3 << svf append
	fp fnp 2 << svf append
	fabort 1? ( 1 'ssmerr ! ) drop
	svh 'here ! ;

|---- carga de .ssv completo -> individual
#ln #lc #ltab #lcols #lpal #rp
:smloadspr | n --
	dup smexpand dup 'pn ! compress 'nw !
	npal nw + pmax >? ( drop 1 'ssmerr ! ; ) drop
	pn 3 << rst + 'rp !
	npal rp d! nw rp 4 + d!
	pn placeregion
	nw 'npal +! ;

::ssm_load | "file" --
	here swap load drop
	here d@ "SSV2" d@ <>? ( drop 1 'ssmerr ! ; ) drop
	here 4 + d@ 'ln ! here 8 + d@ 'lc !
	ln smax >? ( drop 1 'ssmerr ! ; ) drop
	lc cmax >? ( drop 1 'ssmerr ! ; ) drop
	here 16 + 'ltab ! ltab ln 3 << + 'lcols ! lcols lc 3 << + 'lpal !
	sprt 0 smax 4 << cfill
	dcols 0 cmax 3 << cfill
	sprt ltab ln 3 << cmove
	dcols lcols lc 3 << cmove
	ln 'nspr ! lc 'ncols ! 0 'npal !
	lcols 'xcols ! lpal 'xpal !
	0 ( nspr <? dup smloadspr 1+ ) drop
	dcols 'xcols ! dpal 'xpal !
	-1 'open ! 0 'wdirty !
	0 ncols 1- cdmk 0 npal 1- pdmk ;
