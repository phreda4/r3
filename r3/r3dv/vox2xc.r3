|MEM 512
| vox2xc.r3 - .vox (MagicaVoxel) -> .ssv, version con etapa de compresion de la tira de colores
|
| "carpeta" voxdir              junta y ordena los .vox
| "salida" 0 voxconvert         tira SIN comprimir: salida.ssv   (cada columna agrega su tira nueva)
| "salida" 1 voxconvert         salida_raw.ssv (sin comprimir) + salida.ssv (comprimida) + salida.txt
|
| la tira sin comprimir sirve de entrada a la compresion: tiras unicas (hash), de mas larga a mas corta,
| cada una se ubica donde cabe (comodin = compatible con todo) o se pega al final solapando con la cola
| mismo formato .ssv (SSV2) que vox2x.r3, ver ese archivo
| comodin de la tira = $00000001, indice 0 reservado
| orientacion como ss3d/vox2ssa: x = vx, z(fila) = sy-1-vy, bit y(capa) = sz-1-vz
| modelos > 32 se cortan en partes base_pNNN; voxels con 6 vecinos llenos quedan con color comodin

^r3/lib/console.r3
^r3/lib/mem.r3
^r3/lib/str.r3
^r3/lib/math.r3

#SENT $00000001		| comodin de la tira

#path * 256
#names * 65536		| nombres 0-terminados
#names>
#list * 8192		| punteros a nombres (max 1024)
#nlist

#fb #fe			| inicio/fin del archivo en memoria
#ver #nnod #npal
#nmod #models * 32768	| 32 bytes: sx sy sz nvox (d) ptr xyzi (q), max 1024
#nshp #shapes * 8192	| shapes (nSHP): nframes first (d), max 1024
#nfr #frames * 65536	| indice de modelo por frame (d), max 16384
#pal * 2048		| 256 ABGR (q), idx 0 = vacio

|---- escena minima (solo para nombres y ocultos)
#nodes * 131072		| 32 bytes por id: tipo(d) a(d) b(d) c(d) name(q); 1=TRN 2=GRP 3=SHP, max 4096
#kids * 32768		| hijos de grupos
#nkid
#lhid * 256		| capa oculta
#vis * 16384		| 16 bytes: shape idx (d), nombre (q); max 1024
#nvis
#curname
#ne

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

|---- carpeta
:isvox? | str -- str 1/0
	count 4 <? ( drop 0 ; )
	over + 4 - ".vox" =s ;

:addname | ent --
	dup FDIR 1? ( 2drop ; ) drop
	dup FSIZEF 16000000 >? ( 2drop "  SKIP archivo muy grande" .println ; ) drop
	FNAME isvox? 0? ( 2drop ; ) drop
	names> dup 'list nlist 3 << + !
	strcpyl 'names> ! 1 'nlist +! ;

:scan | "path" --
	0 'nlist ! 'names 'names> !
|WIN|	"%s//*" sprint		
	ffirst ( 1? addname fnext ) drop ;

:gt? | i -- i 1/0
	dup 3 << 'list + dup 8 - @ swap @ cmpstr 0 >? ( drop 1 ; ) drop 0 ;

:swapl | i -- i
	dup 3 << 'list + dup 8 - @ over @ pick2 8 - ! swap ! ;

:fix | i -- i
	gt? 0? ( drop ; ) drop swapl ;

:sortnames
	nlist ( 1 >?
		1 ( nlist <? fix 1+ ) drop
		1- ) drop ;

::voxdir | "carpeta" --
	'path strcpy 'path scan sortnames ;

:voxname | i -- "nombre"
	3 << 'list + @ ;

|---- diccionarios .vox
#sp #sl #dname #dhid
#tkey * 256

:rs | adr -- adr'		; string con largo: sp = bytes, sl = largo
	d@+ 'sl ! dup 'sp ! sl + ;

:skipstr | adr -- adr'
	d@+ + ;
:skipdict | adr -- adr'
	d@+ ( 1? 1- swap skipstr skipstr swap ) drop ;

:keyz | p len -- adr
	255 min dup >r swap 'tkey swap rot cmove 0 'tkey r> + c! 'tkey ;

:kvpair | adr -- adr'
	rs sp sl keyz
	dup "_name" cmpstr 0? ( 2drop rs sp 'dname ! ; ) drop
	"_hidden" cmpstr 0? ( drop rs sp c@ $ff and $30 <>? ( 1 'dhid ! ) drop ; ) drop
	rs ;

:readdict | adr -- adr'		; deja dname (ptr o 0) y dhid
	0 'dname ! 0 'dhid !
	d@+ ( 1? 1- swap kvpair swap ) drop ;

|---- chunks
:nodeadr | id -- adr
	4095 min 5 << 'nodes + ;

:c.size | adr --
	nmod 1024 >=? ( 2drop ; ) drop
	12 + 'models nmod 5 << +
	swap d@+ rot d!+ swap d@+ rot d!+ swap d@+ rot d!+ 2drop ;

:c.xyzi | adr --
	nmod 1024 >=? ( 2drop ; ) drop
	12 + d@+ 'models nmod 5 << + 12 + d!+ !
	1 'nmod +! ;

:c.rgba | adr --
	12 + 0 ( 255 <?
		dup 2 << pick2 + d@ over 1+ 3 << 'pal + !
		1+ ) 2drop 1 'npal ! ;

:c.nshp | adr --	| id dict nmodels { modelid dict }
	nshp 1024 >=? ( 2drop ; ) drop
	12 + d@+ nodeadr 'ne !
	skipdict d@+				| p nm
	dup 'shapes nshp 3 << + d!+ nfr swap d!+ drop
	( 1? 1- swap
		d@+ nfr 16383 min 2 << 'frames + d!
		skipdict 1 'nfr +! swap )
	2drop
	3 ne d! nshp ne 4 + d! 1 'nshp +! 1 'nnod +! ;

:c.ntrn | adr --	| id dict child reserved layer nframes {dict}
	12 + d@+ nodeadr 'ne !
	readdict d@+ ne 4 + d!
	4 + d@ ne 12 + d!
	1 ne d! dhid ne 8 + d! dname ne 16 + !
	1 'nnod +! ;

:c.ngrp | adr --	| id dict nchildren {child}
	12 + d@+ nodeadr 'ne !
	readdict d@+ 				| p n
	nkid ne 4 + d! dup ne 8 + d!
	( 1? 1- swap d@+ nkid 8191 min 2 << 'kids + d! 1 'nkid +! swap )
	2drop
	2 ne d! 1 'nnod +! ;

:c.layr | adr --	| id dict reserved
	12 + d@+ >r readdict drop dhid r> 255 min 'lhid + c! ;

:chunk | adr -- adr
	dup d@
	"SIZE" d@ =? ( drop dup c.size ; )
	"XYZI" d@ =? ( drop dup c.xyzi ; )
	"RGBA" d@ =? ( drop dup c.rgba ; )
	"nSHP" d@ =? ( drop dup c.nshp ; )
	"nTRN" d@ =? ( drop dup c.ntrn ; )
	"nGRP" d@ =? ( drop dup c.ngrp ; )
	"LAYR" d@ =? ( drop dup c.layr ; )
	drop ;

|---- recorrido del arbol: solo shapes visibles, en orden DFS
:hid? | e -- e 1/0
	dup 8 + d@ 1? ( drop 1 ; ) drop
	dup 12 + d@ dup $ffffff00 and 1? ( 2drop 0 ; ) drop
	'lhid + c@ $ff and ;

:walk | id --
	nodeadr dup d@
	1 =? ( drop hid? 1? ( 2drop ; ) drop
		dup 16 + @ 'curname !
		4 + d@ walk ; )
	2 =? ( drop dup 4 + d@ swap 8 + d@
		( 1? over 8191 min 2 << 'kids + d@ walk
			swap 1+ swap 1- )
		2drop ; )
	3 =? ( drop 4 + d@
		nvis 1024 >=? ( 2drop ; ) drop
		'vis nvis 4 << + swap over d!
		8 + curname swap ! 1 'nvis +! ; )
	2drop ;

:parsevox | from to -- 1/0
	over =? ( 2drop 0 ; )
	'fe ! dup 'fb !
	0 'nmod ! 0 'nnod ! 0 'npal ! 0 'nshp ! 0 'nfr ! 0 'nkid ! 0 'nvis ! 0 'curname !
	'nodes 0 131072 cfill 'lhid 0 256 cfill
	'pal 'defpal 2048 cmove
	d@ "VOX " d@ <>? ( drop 0 ; ) drop
	fb 4 + d@ 'ver !
	fb 8 + d@ "MAIN" d@ <>? ( drop 0 ; ) drop
	fb 20 + fb 12 + d@ +
	( fe 12 - <?
		chunk
		dup 4 + d@ over 8 + d@ +
		swap 12 + + )
	drop
	nnod 1? ( 0 nodeadr d@ 1? ( 0 walk ) drop ) drop
	1 ;

|---- carga
#fbase * 256		| nombre de archivo sin .vox
#obase * 256		| nombre de objeto
#fname * 256		| nombre de frame

:loadf | "name" -- from to
	'path "%s/%s" sprint here swap load here swap ;

::voxopen | "nombre" -- 1/0
	dup 'fbase strcpy
	count 4 - 'fbase + 0 swap c!
	loadf parsevox ;

|---- nombres (como vox2ssa: base_nombre / base_objNNN, frames _fNNN, sin nodos base_NNN)
:n3 | n -- adr
	100 <? ( 10 <? ( "00%d" sprint ; ) "0%d" sprint ; ) "%d" sprint ;

:mkobase | i nameptr --
	0? ( drop 'fbase 'obase strcpy "_obj" 'obase strcat n3 'obase strcat ; )
	'fbase 'obase strcpy "_" 'obase strcat
	nip dup 4 - d@ keyz 'obase strcat ;

#xt #cnf #cfirst

:mkfname | f --
	'obase 'fname strcpy
	cnf 1 =? ( 2drop ; ) drop
	"_f" 'fname strcat n3 'fname strcat ;

:eachshape | i --
	dup 4 << 'vis + dup 8 + @ swap d@	| i nameptr sidx
	3 << 'shapes + d@+ 'cnf ! d@ 'cfirst !
	mkobase
	0 ( cnf <?
		dup mkfname
		dup cfirst + 2 << 'frames + d@
		nmod <? ( dup 5 << 'models + 'fname xt ex )
		drop 1+ ) drop ;

:eachnonode
	0 ( nmod <?
		'fbase 'fname strcpy "_" 'fname strcat dup n3 'fname strcat
		dup 5 << 'models + 'fname xt ex
		1+ ) drop ;

::voxeach | 'xt --	; xt: 'model "nombre" -- , por cada objeto visible y cada frame
	'xt !
	nnod 0? ( drop eachnonode ; ) drop
	0 ( nvis <? dup eachshape 1+ ) drop ;

|---- modelo -> partes de hasta 32 -> grilla de columnas
#fsx #fsy #fsz #mnv #mptr	| modelo completo (voxels MagicaVoxel)
#msx #msy #msz			| parte actual: tamano
#pox #poy #poz			| parte actual: origen en el modelo
#dense				| indice de color por voxel del modelo (1 byte, 0 = vacio), va despues del archivo
#DMAX 16777216			| voxels maximos de un modelo (256^3)
#vol * 131072			| 32x32 columnas x 32 colores (d)
#mask * 4096			| mascara por columna (d)
#vx #vy #vz #vc #vcol #vb #pvox
#nx #ny #nz #hx #hy #hz

:fits? | m -- 1/0		; tiene voxels y entra en el buffer denso
	>a a> 12 + d@ 0? ( ; ) drop
	a> d@ a> 4 + d@ * a> 8 + d@ * DMAX >? ( drop 0 ; ) drop 1 ;

:loadmodel | m --
	dup d@ 'fsx ! dup 4 + d@ 'fsy ! dup 8 + d@ 'fsz ! dup 12 + d@ 'mnv ! 16 + @ 'mptr ! ;

:skipmsg | m name --
	over 12 + d@ 0? ( 3drop ; ) drop
	"  SKIP " .write .write
	>a a> 8 + d@ a> 4 + d@ a> d@ " %dx%dx%d (muy grande)" .println ;

:rgbpack | abgr -- $RRGGBB00
	dup $ff and 24 <<
	over 8 >> $ff and 16 << or
	swap 16 >> $ff and 8 << or
	SENT =? ( $100 or ) ;

|---- modelo denso: un byte por voxel, para saber los vecinos
:dadr | x y z -- adr
	fsy * + fsx * + dense + ;

:densevox | adr -- adr'
	d@+ dup $ff and 'vx ! dup 8 >> $ff and 'vy ! dup 16 >> $ff and 'vz ! 24 >> $ff and 'vc !
	vx fsx <? ( vy fsy <? ( vz fsz <? ( vc vx vy vz dadr c! ) drop ) drop ) drop ;

:builddense
	fe 15 + 4 >> 4 << 'dense !
	dense 0 fsx fsy * fsz * cfill
	mptr mnv ( 1? 1- swap densevox swap ) 2drop ;

:occ? | x y z -- 1/0		; voxel ocupado (fuera del modelo = vacio)
	'nz ! 'ny ! 'nx !
	nx -? ( drop 0 ; ) drop
	ny -? ( drop 0 ; ) drop
	nz -? ( drop 0 ; ) drop
	nx fsx >=? ( drop 0 ; ) drop
	ny fsy >=? ( drop 0 ; ) drop
	nz fsz >=? ( drop 0 ; ) drop
	nx ny nz dadr c@ $ff and 1? ( drop 1 ; ) drop 0 ;

:hidden? | x y z -- 1/0		; los 6 vecinos llenos: no se ve desde afuera
	'hz ! 'hy ! 'hx !
	hx 1- hy hz occ? 0? ( ; ) drop
	hx 1+ hy hz occ? 0? ( ; ) drop
	hx hy 1- hz occ? 0? ( ; ) drop
	hx hy 1+ hz occ? 0? ( ; ) drop
	hx hy hz 1- occ? 0? ( ; ) drop
	hx hy hz 1+ occ? 0? ( ; ) drop
	1 ;

|---- parte -> vol y mask  (x = vx, fila z = sy-1-vy, bit y = sz-1-vz, relativo a la parte)
:clearvol
	'vol msy 10 << ( 1? 1- swap SENT swap d!+ swap ) 2drop
	'mask 0 msy 7 << cfill ;

:putv | X Y Z --
	'vz ! 'vy ! 'vx !
	vx vy vz dadr c@ $ff and 0? ( drop ; ) 3 << 'pal + @ rgbpack
	vx vy vz hidden? 1? ( nip SENT swap ) drop 'vc !
	msy 1- vy poy - - 5 << vx pox - or 'vcol !
	msz 1- vz poz - - 'vb !
	1 vb << 'mask vcol 2 << + dup d@ rot or swap d!
	vc 'vol vcol 5 << vb + 2 << + d!
	1 'pvox +! ;

:fillpart
	0 ( msz <?
		0 ( msy <?
			0 ( msx <?
				dup pox + pick2 poy + pick4 poz + putv
				1+ ) drop
			1+ ) drop
		1+ ) drop ;

|---- tira sin comprimir: cada columna agrega su tira (lo..hi) al final
#RMAX 33554432		| entradas maximas de la tira (128 MB)
#rawt			| tira sin comprimir (se reserva en 'here')
#rawn 1			| entradas usadas (0 reservado)
#ss #sn #abort

:bakestrip | lo hi -- base
	over - 1+ 'sn !
	vcol 5 << over + 2 << 'vol + 'ss !
	rawn sn + RMAX >? ( 1 'abort ! 2drop 0 ; ) drop
	rawt rawn 2 << + ss sn 2 << cmove
	rawn swap - sn 'rawn +! ;

|---- atlas: columnas una detras de otra (sin empaquetado)
#AMAX 2097152		| columnas maximas (16 MB)
#atlas			| columnas (se reserva en 'here')
#ncol
#outssv * 256
#outtxt * 256
#nl 10
#spr * 131072		| tabla de sprites (8 bytes), max 16384
#nspr #sa #n0
#hdr * 16

:bakecol | gz gx --
	over 5 << over or 'vcol !
	over msx * over + ncol + 3 << atlas + 'sa !
	2drop
	'mask vcol 2 << + d@ $ffffffff and		| d@ extiende el signo: sin esto msb da 63 con el bit 31
	0? ( drop ; )
	dup sa d!
	dup ctz swap msb
	bakestrip sa 4 + d! ;

:bakecols
	0 ( msy <?
		0 ( msx <?
			2dup bakecol
			1+ ) drop
		1+ ) drop ;

#pnx #pny #pnz #nparts #pnm
#pbuf * 256

:partname | k -- adr
	nparts 1 =? ( 2drop pnm ; ) drop
	pnm 'pbuf strcpy "_p" 'pbuf strcat n3 'pbuf strcat 'pbuf ;

:dopart | k --		; parte k: ix = k mod nx, iy = (k / nx) mod ny, iz = k / (nx*ny)
	abort 1? ( 2drop ; ) drop
	dup pnx mod 5 << 'pox !
	dup pnx / pny mod 5 << 'poy !
	dup pnx pny * / 5 << 'poz !
	fsx pox - 32 min 'msx ! fsy poy - 32 min 'msy ! fsz poz - 32 min 'msz !
	nspr 16384 >=? ( 1 'abort ! 2drop ; ) drop
	ncol msx msy * + AMAX >? ( 1 'abort ! 2drop ; ) drop
	clearvol 0 'pvox ! fillpart
	pvox 0? ( 2drop ; ) drop
	bakecols
	'spr nspr 3 << + 'sa !
	ncol sa d! msx sa 4 + c! msz sa 5 + c! msy sa 6 + c! 0 sa 7 + c!
	partname count 'outtxt append 'nl 1 'outtxt append
	msx msy * 'ncol +! 1 'nspr +! ;

:procframe | m name --
	over fits? 0? ( drop skipmsg ; ) drop
	abort 1? ( 3drop ; ) drop
	'pnm ! loadmodel builddense
	fsx 31 + 5 >> 'pnx ! fsy 31 + 5 >> 'pny ! fsz 31 + 5 >> 'pnz !
	pnx pny * pnz * 'nparts !
	0 ( nparts <? dup dopart 1+ ) drop ;

|---- compresion de la tira
#OMAX 8388608		| entradas maximas de la tira comprimida
#MAXCAND 2048		| candidatos a revisar por tira
#DTM 4194303		| hash de tiras unicas
#VM 2097151		| indice de valores
#sP0 #sNL #sRep #sPos	| por tira: inicio en rawt, largo|lo<<8, representante, posicion final
#dtab #outa #nxt #vk #vcn #vhd
#ns #outn #plen
#cs #cn #ck #cj #cp #ck2 #cq #cps #cai #ccnt #cfix #uv #vv #vs #vp #hs #ca #wk

:setstrip | --
	ck 2 << sP0 + d@ 2 << rawt + 'cs !
	ck 2 << sNL + d@ $ff and 'cn ! ;

:col1 | i --		; reune las tiras en el orden de las columnas
	3 << atlas + 'ca !
	ca d@ $ffffffff and 0? ( drop ; )
	dup ctz swap msb over - 1+
	ca 4 + d@ pick2 + $ffffffff and ns 2 << sP0 + d!
	swap 8 << or ns 2 << sNL + d! 1 'ns +! ;

:collect
	0 'ns !
	0 ( ncol <? dup col1 1+ ) drop ;

:shash | -- slot
	2166136261 0 ( cn <?
		dup 2 << cs + d@ rot xor 16777619 * $ffffffff and swap 1+ ) drop
	cn xor 16777619 * $ffffffff and
	dup 13 >> xor DTM and ;

:same? | j -- 1/0
	dup 2 << sNL + d@ $ff and cn <>? ( 2drop 0 ; ) drop
	2 << sP0 + d@ 2 << rawt +
	0 ( cn <?
		2dup 2 << + d@ over 2 << cs + d@
		<>? ( 3drop 0 ; ) drop
		1+ ) 2drop 1 ;

:dd1 | k --		; representante de la tira k (contenido identico)
	'ck ! setstrip
	shash 'hs !
	0 ( 100000 <?
		hs 2 << dtab + d@
		0? ( 2drop ck 1+ hs 2 << dtab + d! ck ck 2 << sRep + d! ; )
		1- dup 'cj ! same? 1? ( 2drop cj ck 2 << sRep + d! ; ) drop
		hs 1+ DTM and 'hs !
		1+ ) drop ;

|-- indice: valor -> lista de posiciones en outa
:vslot | v -- slot
	'vv !
	vv $9E3779B1 * $ffffffff and 11 >> VM and 'vs !
	0 ( 100000 <?
		vs 2 << vcn + d@ 0? ( 2drop vs ; ) drop
		vs 2 << vk + d@ vv =? ( 2drop vs ; ) drop
		vs 1+ VM and 'vs !
		1+ ) drop vs ;

:vadd | v p --
	'vp ! vslot 'vs !
	vv vs 2 << vk + d!
	vs 2 << vcn + dup d@ 1+ swap d!
	vs 2 << vhd + d@ vp 2 << nxt + d!
	vp vs 2 << vhd + d! ;

:ov@ | p -- v
	2 << outa + d@ ;

:okat | pos -- 1/0	; la tira cabe en outa[pos..] (comodin compatible con todo)
	'cp !
	0 ( cn <?
		dup 2 << cs + d@
		SENT <>? (
			over cp + ov@
			SENT <>? ( over <>? ( 3drop 0 ; ) ) drop
		) drop
		1+ ) drop 1 ;

:an1 | i --		; ancla: valor fijo menos frecuente
	dup 2 << cs + d@ SENT =? ( 2drop ; )
	1 'cfix +!
	vslot 2 << vcn + d@
	ccnt >=? ( 2drop ; )
	'ccnt ! 'cai ! ;

:cand | -- 1/0
	cps 1 <? ( drop 0 ; ) drop
	cps cn + outn >? ( drop 0 ; ) drop
	cps okat ;

:search | -- pos/0
	0 'cfix ! 0 'cai ! 1000000000 'ccnt !
	0 ( cn <? dup an1 1+ ) drop
	cfix 0? ( drop 1 ; ) drop
	ccnt 0? ( drop 0 ; ) drop
	cai 2 << cs + d@ vslot 2 << vhd + d@ 'cq !
	0 ( MAXCAND <?
		cq 0? ( 2drop 0 ; ) drop
		cq cai - 'cps !
		cand 1? ( 2drop cps ; ) drop
		cq 2 << nxt + d@ 'cq !
		1+ ) drop 0 ;

:tok? | k -- 1/0	; sufijo de outa de largo k compatible con el prefijo de la tira
	'ck2 !
	0 ( ck2 <?
		dup 2 << cs + d@
		SENT <>? (
			over outn ck2 - + ov@
			SENT <>? ( over <>? ( 3drop 0 ; ) ) drop
		) drop
		1+ ) drop 1 ;

:tailov | -- ov
	cn 1- outn 1- min
	( 1? dup tok? 1? ( drop ; ) drop 1- ) ;

:extend | end --	; outn = max(outn, end), rellenando con comodin
	outn ( over <? SENT over 2 << outa + d! 1+ ) nip 'outn ! ;

:un1 | i --		; copia el valor fijo si el destino es comodin
	dup 2 << cs + d@ SENT =? ( 2drop ; ) 'uv !
	cp + dup ov@ SENT <>? ( 2drop ; ) drop
	uv over 2 << outa + d! uv swap vadd ;

:unify | pos --
	'cp !
	0 ( cn <? dup un1 1+ ) drop ;

:place | k --
	'ck ! setstrip
	search 0? ( drop outn tailov - ) 'cps !
	cps cn + dup OMAX >? ( 1 'abort ! 2drop ; ) drop
	extend
	cps unify
	cps ck 2 << sPos + d! ;

:pk1 | k --
	dup 2 << sRep + d@ over <>? ( 2drop ; ) drop
	dup 2 << sNL + d@ $ff and plen <>? ( 2drop ; ) drop
	place ;

:fx1 | k --		; duplicados: misma posicion que su representante
	dup 2 << sRep + d@ over =? ( 2drop ; ) drop
	dup 2 << sRep + d@ 2 << sPos + d@ swap 2 << sPos + d! ;

:wb1 | i --		; base nueva de la columna = posicion - lo
	3 << atlas + 'ca !
	ca d@ $ffffffff and 0? ( drop ; ) ctz
	wk 2 << sPos + d@ swap - $ffffffff and ca 4 + d!
	1 'wk +! ;

:compress | --		; deja la tira comprimida en outa/outn y reescribe las bases del atlas
	collect
	0 ( ns <? dup dd1 1+ ) drop
	SENT outa d! 1 'outn !
	32 ( 1? dup 'plen !
		0 ( ns <? dup pk1 1+ ) drop
		1- ) drop
	0 ( ns <? dup fx1 1+ ) drop
	0 'wk ! 0 ( ncol <? dup wb1 1+ ) drop ;

|---- salida
#outbase * 256
#outraw * 256
#docomp
#sn2 #sa2

:alloc | bytes -- adr
	here swap 'here +! ;

:savessv | "file" adr n --
	'sn2 ! 'sa2 ! 'outssv strcpy
	"SSV2" d@ 'hdr d! nspr 'hdr 4 + d! ncol 'hdr 8 + d! sn2 'hdr 12 + d!
	'hdr 16 'outssv save
	'spr nspr 3 << 'outssv append
	atlas ncol 3 << 'outssv append
	sa2 sn2 2 << 'outssv append ;

:procfile | i --
	dup voxname voxopen
	0? ( drop voxname "  ERROR: %s no es un .vox valido" .println ; ) 2drop
	'procframe voxeach ;

::voxconvert | "salida" comp --
	'docomp !
	dup "%s.txt" sprint 'outtxt strcpy
	dup "%s_raw.ssv" sprint 'outraw strcpy
	"%s.ssv" sprint 'outbase strcpy
	AMAX 3 << alloc 'atlas !
	RMAX 2 << alloc 'rawt !
	AMAX 2 << alloc 'sP0 !  AMAX 2 << alloc 'sNL !
	AMAX 2 << alloc 'sRep ! AMAX 2 << alloc 'sPos !
	DTM 1+ 2 << alloc 'dtab !
	OMAX 2 << alloc 'outa ! OMAX 2 << alloc 'nxt !
	VM 1+ 2 << alloc 'vk ! VM 1+ 2 << alloc 'vcn ! VM 1+ 2 << alloc 'vhd !
	SENT rawt d! 1 'rawn ! 0 'ncol ! 0 'nspr ! 0 'abort !
	'nl 0 'outtxt save
	0 ( nlist <? nspr 'n0 ! dup procfile
		nspr n0 - over voxname "  %s: %d sprites" .println
		1+ ) drop
	abort 1? ( "ERROR: limite superado, salida incompleta" .println ) drop
	docomp 0? ( drop 'outbase rawt rawn savessv
		rawn ncol nspr "%d sprites, %d columnas, %d entradas de tira (sin comprimir)" .println ; ) drop
	'outraw rawt rawn savessv
	compress
	abort 1? ( "ERROR: limite superado en la compresion" .println ) drop
	'outbase outa outn savessv
	ns rawn "tira: %d entradas sin comprimir, %d tiras" .println
	outn "tira comprimida: %d entradas" .println
	rawn 10 * outn / dup 10 mod swap 10 / ncol nspr "%d sprites, %d columnas, factor de compresion %d.%d:1" .println ;

: 
	"media/ssv/vox" voxdir			| carpeta con los .vox
	"media/ssv/vox" 1 voxconvert	| genera sprites.ssv y sprites.txt
	waitkey
	;
