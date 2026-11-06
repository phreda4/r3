| vox2x.r3 - lector de .vox (MagicaVoxel) con animacion
| voxdir  "carpeta" --   junta y ordena los .vox
| voxopen "nombre"  -- 1/0   carga y parsea un .vox de la carpeta
| voxeach            recorre objetos y frames -> procframe

^r3/lib/console.r3
^r3/lib/mem.r3
^r3/lib/str.r3

#path * 256
#names * 65536		| nombres 0-terminados
#names>
#list * 8192		| punteros a nombres (max 1024)
#nlist

#fb #fe			| inicio/fin del archivo en memoria
#ver #nnod #npal
#nmod #models * 32768	| 32 bytes: sx sy sz nvox (d) ptr xyzi (q), max 1024
#nshp #shapes * 8192	| objetos (nSHP): nframes first (d), max 1024
#nfr #frames * 65536	| indice de modelo por frame (d), max 16384
#pal * 2048		| 256 ABGR (q), idx 0 = vacio

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

|---- chunks
:skipstr | adr -- adr'
	d@+ + ;
:skipdict | adr -- adr'
	d@+ ( 1? 1- swap skipstr skipstr swap ) drop ;

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
	16 + skipdict d@+			| p nm
	dup 'shapes nshp 3 << + d!+ nfr swap d!+ drop
	( 1? 1- swap
		d@+ nfr 16383 min 2 << 'frames + d!
		skipdict 1 'nfr +! swap )
	2drop 1 'nshp +! ;

:chunk | adr -- adr
	dup d@
	"SIZE" d@ =? ( drop dup c.size ; )
	"XYZI" d@ =? ( drop dup c.xyzi ; )
	"RGBA" d@ =? ( drop dup c.rgba ; )
	"nSHP" d@ =? ( drop dup c.nshp ; )
	"nTRN" d@ =? ( drop 1 'nnod +! ; )
	"nGRP" d@ =? ( drop 1 'nnod +! ; )
	drop ;

| archivos sin nodos: un objeto por modelo, un frame
:noshapes
	nshp 1? ( drop ; ) drop
	0 ( nmod <?
		dup dup 3 << 'shapes + 1 swap d!+ d!
		dup 2 << 'frames + over swap d!
		1+ ) drop
	nmod 'nshp ! nmod 'nfr ! ;

:parsevox | from to -- 1/0
	over =? ( 2drop 0 ; )
	'fe ! dup 'fb !
	0 'nmod ! 0 'nnod ! 0 'npal ! 0 'nshp ! 0 'nfr !
	'defpal 'pal 2048 cmove
	d@ "VOX " d@ <>? ( drop 0 ; ) drop
	fb 4 + d@ 'ver !
	fb 8 + d@ "MAIN" d@ <>? ( drop 0 ; ) drop
	fb 20 + fb 12 + d@ +
	( fe 12 - <?
		chunk
		dup 4 + d@ over 8 + d@ +
		swap 12 + + )
	drop noshapes 1 ;

|---- carga
:loadf | "name" -- from to
	'path "%s/%s" sprint here swap load here swap ;

::voxopen | "nombre" -- 1/0
	loadf parsevox ;

|---- recorrido: objeto -> frames
#cobj #cnf #cfirst

| aca va la conversion. obj=indice de objeto, frame=indice de cuadro,
| 'model -> sx sy sz nvox (d) y ptr (q) a nvox * (x y z i) bytes; 'pal = colores
:procframe | obj frame 'model --
	>a a> 12 + d@ -rot a> 8 + d@ -rot a> 4 + d@ -rot a> d@ -rot swap
	"    obj %d  frame %d  %dx%dx%d  voxels=%d" .println ;

::voxeach
	0 ( nshp <? dup 'cobj !
		dup 3 << 'shapes + d@+ 'cnf ! d@ 'cfirst !
		0 ( cnf <?
			dup cobj swap
			dup cfirst + 2 << 'frames + d@ 5 << 'models +
			procframe
			1+ ) drop
		1+ ) drop ;

|---- main
:procfile | i --
	voxname dup voxopen
	0? ( drop "  ERROR: %s no es un .vox valido" .println ; ) drop
	.write
	ver nshp nmod nnod "  nodos=%d  modelos=%d  objetos=%d  v%d" .println
	voxeach ;

: 
	"r3/r3dv/ss3d2/vox" voxdir
	'path nlist "%d archivos .vox en %s" .println
	0 ( nlist <? dup procfile 1+ ) drop
	waitkey
	.free ;
