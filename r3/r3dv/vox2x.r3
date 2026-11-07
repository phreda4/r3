|MEM 64
| vox2x.r3 - .vox (MagicaVoxel) -> asset .ssv (columnas RG32UI + tira de colores) + .txt de nombres
|
| "carpeta" voxdir        junta y ordena los .vox
| "salida"  voxconvert    genera salida.ssv y salida.txt (usa lo juntado por voxdir)
|
| orientacion como ss3d/vox2ssa: x = vx, z(fila) = sy-1-vy, bit y(capa) = sz-1-vz
| .ssv (SSV2), todo little endian:
|   cabecera 16 bytes: "SSV2" nspr ncol ncolores (d)
|   tabla nspr*8:      atlasIndex (d) | sizeX sizeY sizeZ 0 (c)    sizeY = capas (bits)
|   columnas ncol*8:   mascara (d) base (d)      texel de (x,z) = atlasIndex + z*sizeX + x
|   tira ncolores*4:   color = tira[base + y]    (base puede ser "negativo": aritmetica uint32)
| color: $RRGGBBuma (u rough 3b, m metal 3b, a glow 2b), por ahora uma = 0
| comodin de la tira = $00000001 (negro con glow 1, no tiene sentido); indice 0 reservado

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

|---- modelo -> grilla de columnas
#msx #msy #msz #mnv #mptr
#vol * 131072		| 32x32 columnas x 32 colores (d)
#mask * 4096		| mascara por columna (d)
#vx #vc #vcol #vb

:fits? | m -- 1/0
	>a a> d@ 33 >? ( drop 0 ; ) drop
	a> 4 + d@ 33 >? ( drop 0 ; ) drop
	a> 8 + d@ 33 >? ( drop 0 ; ) drop
	a> 12 + d@ 0? ( ; ) drop 1 ;

:loadmodel | m --
	dup d@ 'msx ! dup 4 + d@ 'msy ! dup 8 + d@ 'msz ! dup 12 + d@ 'mnv ! 16 + @ 'mptr ! ;

:skipmsg | m name --
	over 12 + d@ 0? ( 3drop ; ) drop
	"  SKIP " .write .write
	>a a> 8 + d@ a> 4 + d@ a> d@ " %dx%dx%d (>32)" .println ;

:rgbpack | abgr -- $RRGGBB00
	dup $ff and 24 <<
	over 8 >> $ff and 16 << or
	swap 16 >> $ff and 8 << or
	SENT =? ( $100 or ) ;

:clearvol
	'vol msy 10 << ( 1? 1- swap SENT swap d!+ swap ) 2drop
	'mask 0 msy 7 << cfill ;

:putvox | adr -- adr'
	d@+
	dup 24 >> $ff and 3 << 'pal + @ rgbpack 'vc !
	dup 8 >> $ff and msy 1- swap - 31 and 5 <<
	over $ff and 31 and or 'vcol !
	16 >> $ff and msz 1- swap - 31 and 'vb !
	1 vb << 'mask vcol 2 << + dup d@ rot or swap d!
	vc 'vol vcol 5 << vb + 2 << + d! ;

:fillvol
	mptr mnv ( 1? 1- swap putvox swap ) 2drop ;

|---- tira de colores con comodines
#PMAX 1048576
#HM 524287
#WINDOW 128
#palc			| tira global (4 MB, se reserva en 'here')
#htab			| hash de tiras, indice de inicio (2 MB, idem)
#np 1			| entradas usadas (0 reservado)
#hcnt #hidx #hp
#ss #sn			| tira actual: puntero y largo
#ci #ov #mp
#abort

:matchat | i -- 1/0		; la tira cabe (con comodines) en palc[i..]
	'ci !
	sn np ci - min 'ov !
	0 ( ov <?
		dup 2 << ss + d@
		SENT <>? (
			over ci + 2 << palc + d@
			SENT <>? ( over <>? ( 3drop 0 ; ) ) drop
		) drop
		1+ ) drop 1 ;

:mset | k --
	dup 2 << ss + d@ SENT =? ( 2drop ; )
	swap mp + 2 << palc + d! ;

:mergeat | p --
	'mp !
	mp sn + PMAX >? ( drop 1 'abort ! ; ) drop
	mp sn + np >? (
		np ( over <? SENT over 2 << palc + d! 1+ ) drop
		dup 'np ! ) drop
	0 ( sn <? dup mset 1+ ) drop ;

:hashstrip | -- idx
	2166136261 0 ( sn <?
		dup 2 << ss + d@ rot xor 16777619 * $ffffffff and swap 1+ ) drop
	dup 15 >> xor HM and ;

:hfind | -- P0/0
	hidx 16 ( 1? 1- swap
		dup HM and 2 << htab + d@
		0? ( 3drop 0 ; )
		dup matchat 1? ( drop nip nip ; ) 2drop
		1+ swap )
	2drop 0 ;

:hins | p --
	'hp !
	hcnt 393216 >=? ( drop ; ) drop
	hidx 16 ( 1? 1- swap
		dup HM and 2 << htab + dup d@ 0? ( drop hp swap d! 1 'hcnt +! 2drop ; ) 2drop
		1+ swap )
	2drop ;

:wfind | -- P0/0
	np WINDOW - 1 max
	( np <? dup matchat 1? ( drop ; ) drop 1+ ) drop 0 ;

:findstrip | -- P0
	hashstrip 'hidx !
	hfind 1? ( dup mergeat ; ) drop
	wfind 1? ( dup mergeat dup hins ; ) drop
	np dup mergeat dup hins ;

:bakestrip | lo hi -- base
	over - 1+ 'sn !
	vcol 5 << over + 2 << 'vol + 'ss !
	findstrip swap - ;

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
	'mask vcol 2 << + d@
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

:procframe | m name --
	over fits? 0? ( drop skipmsg ; ) drop
	abort 1? ( 3drop ; ) drop
	swap loadmodel
	nspr 16384 >=? ( 1 'abort ! 2drop ; ) drop
	ncol msx msy * + AMAX >? ( 1 'abort ! 2drop ; ) drop
	clearvol fillvol bakecols
	'spr nspr 3 << + 'sa !
	ncol sa d! msx sa 4 + c! msz sa 5 + c! msy sa 6 + c! 0 sa 7 + c!
	count 'outtxt append 'nl 1 'outtxt append
	msx msy * 'ncol +! 1 'nspr +! ;

:procfile | i --
	dup voxname voxopen
	0? ( drop voxname "  ERROR: %s no es un .vox valido" .println ; ) 2drop
	'procframe voxeach ;

::voxconvert | "salida" --
	dup "%s.ssv" sprint 'outssv strcpy
	"%s.txt" sprint 'outtxt strcpy
	here dup 'atlas ! AMAX 3 << + dup 'palc ! 4194304 + dup 'htab ! 2097152 + 'here !
	atlas 0 AMAX 3 << cfill htab 0 2097152 cfill
	SENT palc d! 1 'np ! 0 'ncol ! 0 'nspr ! 0 'abort ! 0 'hcnt !
	'nl 0 'outtxt save
	0 ( nlist <? nspr 'n0 ! dup procfile
		nspr n0 - over voxname "  %s: %d sprites" .println
		1+ ) drop
	"SSV2" d@ 'hdr d! nspr 'hdr 4 + d! ncol 'hdr 8 + d! np 'hdr 12 + d!
	'hdr 16 'outssv save
	'spr nspr 3 << 'outssv append
	atlas ncol 3 << 'outssv append
	palc np 2 << 'outssv append
	abort 1? ( "ERROR: limite superado, salida incompleta" .println ) drop
	np ncol nspr "%d sprites, %d columnas, %d colores" .println 
	waitkey 
	;

: 
	"r3/r3dv/ss3d2/mexcla" voxdir			| carpeta con los .vox
	"r3/r3dv/ss3d2/mexcla" voxconvert	| genera sprites.ssv y sprites.txt
	.free ;
