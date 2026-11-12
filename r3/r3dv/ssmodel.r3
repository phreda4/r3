| ssmodel.r3 - multi3dsprite: jerarquia de 3dsprites (nodos/huesos), poses y animaciones
| PHREDA 2026
|
| Una DESCRIPCION (archivo .ssm, compartida) es una lista de nodos con padre; una INSTANCIA
| (ssmo_inst) tiene su propio estado local/mundo y su transformacion raiz, asi muchas
| instancias comparten la misma descripcion.
| Cada nodo: sprite del .ssv (o -1 = hueso sin voxeles), padre (o -1 = raiz, siempre un indice
| MENOR que el del nodo), posicion/rotacion/escala LOCALES al padre, color, nombre.
| Posiciones en VOXELES (16.16, 1.0 = un voxel). El sprite se dibuja centrado en el nodo.
| Mundo (como ss3d): voxel = 0.01 * escala; escala del nodo = escala_raiz * producto de escalas.
| Rotaciones: quaternion unitario 16.16 (qx qy qz qw).
|
| ARCHIVO .ssm (little endian, todo d de 32 bits)
|   cabecera 48 bytes: "SSM1" nnodos nposes nclips nkeys npool ssvname(off pool) 0 0 0 0 0
|   nodos  nnodos*48:  spr parent x y z qx qy qz qw escala color nombre(off pool)
|   poses  nposes*nnodos*32: por nodo x y z qx qy qz qw escala (transformacion local absoluta)
|   clips  nclips*16:  nombre(off) primerkey nkeys flags(bit0 = loop)
|   keys   nkeys*8:    pose tiempo_ms   (ordenadas por tiempo; duracion = ultimo key)
|   pool   npool bytes: strings terminados en 0 (offset 0 = "")
|
| DESCRIPCION (armado)
|   ssmo_new    | nodos poses clips keys -- d     capacidades; queda como actual
|   ssmo_cur    | d --                            elige la descripcion actual
|   ssmo_node   | spr parent -- i                 (-1 si no entra o el padre no es menor)
|   ssmo_npos   | x y z i --     ssmo_nrot | qx qy qz qw i --     ssmo_nscale | s i --
|   ssmo_ncol   | color i --     ssmo_nname | "nombre" i --       ssmo_ssv! | "archivo.ssv" --
|   ssmo_qaxis  | ax ay az turnos -- qx qy qz qw  (eje unitario)
|   ssmo_pose   | -- p            nueva pose = copia de los nodos (nodos nuevos entran en todas las poses)
|   ssmo_pnode  | p nodo -- adr    ssmo_t! | x y z qx qy qz qw s adr --
|   ssmo_clip   | "nombre" loop -- c     ssmo_key | pose ms --   (al ultimo clip)
|   ssmo_save   | "archivo.ssm" --        ssmo_load | "archivo.ssm" -- d (0 si falla; queda actual)
| EDICION (descripcion actual; ssmo_load deja lugar para agregar nodos/poses/clips)
|   ssmo_ndel   | i -- 1/0        borra un nodo hoja (los indices mayores bajan 1)
|   ssmo_npar!  | padre i -- 1/0  cambia el padre (-1 = raiz, sin ciclos) y reordena; ssmo_moved | viejo -- nuevo
|   ssmo_sort   | -- 1/0          deja todo padre antes que sus hijos (ssmo_moved da el nuevo indice)
|   ssmo_nspr!  | spr i --        ssmo_nrotate | ax ay az turnos i --  (gira en el eje local, eje unitario)
|   ssmo_qmul   | a4 b4 -- q4     quaternion a*b normalizado
| INSTANCIA
|   ssmo_inst   | d -- m            ssmo_bind | m --        (pose de armado)
|   ssmo_rpos   | x y z m --  ssmo_rrot | qx qy qz qw m --  ssmo_rscale | s m --   (raiz, en mundo)
|   ssmo_pose!  | pose m --         ssmo_blend | pa pb t m --    ssmo_play | clip ms m --
|   ssmo_loc    | nodo m -- adr     (8 d editables: animacion por programa)
|   ssmo_hilite | nodo color m --   (nodo -1 = ninguno)   ssmo_wpos | nodo m -- x y z  (mundo)
|   ssmo_update | m --              ssmo_world | nodo m -- adr (8 d: x y z qx qy qz qw s, en voxeles)
|   ssmo_draw   | 'ss3dset primero m -- siguiente    dibuja con instancias ss3d primero.. (usa 'ss3dset)
| CONSULTAS
|   ssmo_nodes ssmo_poses ssmo_clips ssmo_nadr ssmo_ssv ssmo_name | off -- adr

^r3/lib/mem.r3
^r3/lib/math.r3

#cur				| descripcion actual

| campos de la descripcion (qwords): 0 nodos 8 poses 16 clips 24 keys 32 pool(bytes)
|   40 pnodos 48 pposes 56 pclips 64 pkeys 72 ppool 80 capnodos 88 cappose 96 capclip 104 capkey
|   112 cappool 120 ssvname
:dset | val off --
	cur + ! ;
:dget | off -- val
	cur + @ ;

#ab
:alloc | bytes -- adr		; memoria cero, alineada a 8
	7 + -8 and 'ab ! here dup 0 ab cfill ab 'here +! ;

::ssmo_cur | d --
	'cur ! ;
::ssmo_nodes 0 dget ;
::ssmo_poses 8 dget ;
::ssmo_clips 16 dget ;
::ssmo_nadr | i -- adr		; registro del nodo (48 bytes)
	48 * 40 dget + ;
::ssmo_name | off -- adr
	72 dget + ;
::ssmo_ssv | -- adr
	120 dget 72 dget + ;

::ssmo_new | nodos poses clips keys -- d
	128 alloc 'cur !
	104 dset 96 dset 88 dset 80 dset
	4096 112 dset 1 32 dset
	80 dget 48 * alloc 40 dset
	88 dget 80 dget * 5 << alloc 48 dset
	96 dget 4 << alloc 56 dset
	104 dget 3 << alloc 64 dset
	4096 alloc 72 dset
	cur ;

|---- nodos
#ni #na
::ssmo_node | spr parent -- i
	0 dget 'ni !
	ni 80 dget >=? ( drop 2drop -1 ; ) drop
	dup ni >=? ( drop 2drop -1 ; ) drop
	ni ssmo_nadr 'na !
	na 4 + d! na d!
	0 na 8 + d! 0 na 12 + d! 0 na 16 + d!
	0 na 20 + d! 0 na 24 + d! 0 na 28 + d! 1.0 na 32 + d!
	1.0 na 36 + d! $ffffff00 na 40 + d! 0 na 44 + d!
	0 ( 8 dget <? dup 80 dget * ni + 5 << 48 dget + na 8 + 32 cmove 1+ ) drop
	ni 1+ 0 dset
	ni ;

::ssmo_npos | x y z i --
	ssmo_nadr 'na ! na 16 + d! na 12 + d! na 8 + d! ;
::ssmo_nrot | qx qy qz qw i --
	ssmo_nadr 'na ! na 32 + d! na 28 + d! na 24 + d! na 20 + d! ;
::ssmo_nscale | s i --
	ssmo_nadr 36 + d! ;
::ssmo_ncol | color i --
	ssmo_nadr 40 + d! ;

#cs #cl
:addname | "s" -- off
	count 1+ 'cl ! 'cs !
	32 dget cl + 112 dget >? ( drop 0 ; ) drop
	72 dget 32 dget + cs cl cmove
	32 dget dup cl + 32 dset ;

::ssmo_nname | "nombre" i --
	>r addname r> ssmo_nadr 44 + d! ;
::ssmo_ssv! | "archivo.ssv" --
	addname 120 dset ;

#qs #qc #qa #qb #qz2
::ssmo_qaxis | ax ay az turnos -- qx qy qz qw
	2/ sincos 'qc ! 'qs !
	qs *. 'qz2 ! qs *. 'qb ! qs *. 'qa !
	qa qb qz2 qc ;

|---- poses
#pi #pa #nn
::ssmo_pose | -- p
	8 dget 88 dget >=? ( drop -1 ; ) drop
	8 dget 'pi ! 0 dget 'nn !
	pi 80 dget * 5 << 48 dget + 'pa !
	0 ( nn <? dup 5 << pa + over ssmo_nadr 8 + 32 cmove 1+ ) drop
	pi 1+ 8 dset pi ;

::ssmo_pnode | p nodo -- adr
	swap 80 dget * + 5 << 48 dget + ;

::ssmo_t! | x y z qx qy qz qw s adr --
	'na !
	na 28 + d! na 24 + d! na 20 + d! na 16 + d!
	na 12 + d! na 8 + d! na 4 + d! na d! ;

|---- clips
#ci #ca #ka
::ssmo_clip | "nombre" loop -- c
	16 dget 96 dget >=? ( drop 2drop -1 ; ) drop
	16 dget 'ci ! ci 4 << 56 dget + 'ca !
	ca 12 + d!
	addname ca d!
	24 dget ca 4 + d! 0 ca 8 + d!
	ci 1+ 16 dset ci ;

::ssmo_key | pose ms --
	16 dget 0? ( 3drop ; ) drop
	24 dget 104 dget >=? ( 3drop ; ) drop
	24 dget 3 << 64 dget + 'ka !
	ka 4 + d! ka d!
	24 dget 1+ 24 dset
	16 dget 1- 4 << 56 dget + 8 + dup d@ 1+ swap d! ;

|---- edicion de la jerarquia
#sn #sk #si #ti2 #pa2 #di #na3 #sa #ss_ #sc #so
#sperm * 4096
#sinv * 4096
#splc * 1024
#sbuf * 49152
#srow * 32768

:sparok? | i -- 1/0		; el padre ya esta ubicado (o es raiz)
	ssmo_nadr 4 + d@ -? ( drop 1 ; ) 'splc + c@ ;

:sortpass
	0 ( sn <? dup 'si !
		si 'splc + c@ 0? ( si sparok? 1? ( si sk 2 << 'sperm + d! 1 si 'splc + c! 1 'sk +! ) drop ) drop
		1+ ) drop ;

:permnode | k --
	dup 48 * 'sbuf + 'na3 !
	dup 2 << 'sperm + d@ ssmo_nadr na3 swap 48 cmove
	drop
	na3 4 + d@ -? ( drop ; ) 2 << 'sinv + d@ na3 4 + d! ;

:permpose | p --
	80 dget * 5 << 48 dget + 'so !
	0 ( sn <? dup 5 << 'srow + over 2 << 'sperm + d@ 5 << so + 32 cmove 1+ ) drop
	so 'srow sn 5 << cmove ;

::ssmo_sort | -- 1/0		; todo padre antes que sus hijos (orden estable); 0 si hay ciclo
	0 dget 'sn ! 'splc 0 1024 cfill 0 'sk !
	sn 1024 >? ( drop 0 ; ) drop
	0 ( sn <? sortpass 1+ ) drop
	sk sn <? ( drop 0 ; ) drop
	0 ( sn <? dup dup 2 << 'sperm + d@ 2 << 'sinv + d! 1+ ) drop
	0 ( sn <? dup permnode 1+ ) drop
	40 dget 'sbuf sn 48 * cmove
	0 ( 8 dget <? dup permpose 1+ ) drop
	1 ;

::ssmo_moved | viejo -- nuevo		; indice nuevo de un nodo despues de ssmo_sort
	2 << 'sinv + d@ ;

:anc? | p i -- 1/0		; i es ancestro de p (o p mismo)
	'di !
	( -1 >? dup di =? ( 2drop 1 ; ) drop ssmo_nadr 4 + d@ ) drop 0 ;

::ssmo_npar! | padre i -- 1/0
	'ti2 ! -1 max 'pa2 !
	ti2 -? ( drop 0 ; ) drop
	ti2 0 dget >=? ( drop 0 ; ) drop
	pa2 0 dget >=? ( drop 0 ; ) drop
	pa2 ti2 anc? 1? ( drop 0 ; ) drop
	pa2 ti2 ssmo_nadr 4 + d!
	ssmo_sort ;

:shiftrecs | adr stride cnt --	; sube cada registro una posicion (adr = destino del primero)
	'sc ! 'ss_ ! 'sa !
	0 ( sc <? dup ss_ * sa + dup ss_ + ss_ cmove 1+ ) drop ;

::ssmo_ndel | i -- 1/0		; solo nodos hoja
	'ti2 !
	ti2 -? ( drop 0 ; ) drop
	ti2 0 dget >=? ( drop 0 ; ) drop
	0 ( 0 dget <? dup ssmo_nadr 4 + d@ ti2 =? ( 2drop 0 ; ) drop 1+ ) drop
	40 dget ti2 48 * + 48 0 dget ti2 - 1- shiftrecs
	0 ( 8 dget <? dup 80 dget * 5 << 48 dget + ti2 5 << + 32 0 dget ti2 - 1- shiftrecs 1+ ) drop
	0 ( 0 dget 1- <? dup ssmo_nadr 4 + 'na3 ! na3 d@ ti2 >? ( 1- na3 d! 0 ) drop 1+ ) drop
	0 dget 1- 0 dset 1 ;

::ssmo_nspr! | spr i --
	ssmo_nadr d! ;

|---- archivo
#sf #hdr * 48
::ssmo_save | "archivo.ssm" --
	'sf !
	'hdr 0 48 cfill
	"SSM1" d@ 'hdr d!
	0 dget 'hdr 4 + d! 8 dget 'hdr 8 + d! 16 dget 'hdr 12 + d! 24 dget 'hdr 16 + d!
	32 dget 'hdr 20 + d! 120 dget 'hdr 24 + d!
	'hdr 48 sf save
	40 dget 0 dget 48 * sf append
	0 ( 8 dget <? dup 80 dget * 5 << 48 dget + 0 dget 5 << sf append 1+ ) drop
	56 dget 16 dget 4 << sf append
	64 dget 24 dget 3 << sf append
	72 dget 32 dget sf append ;

#ibase #iend #lnn #lnp #lnc #lnk #lnl
:okpar | -- 1/0		; todo padre es -1 o menor que el nodo
	0 ( lnn <? dup 48 * 40 dget + 4 + d@ over >=? ( 2drop 0 ; ) drop 1+ ) drop 1 ;

#sn1 #sp1 #sc1 #sk1 #sl1
::ssmo_load | "archivo.ssm" -- d
	here 'ibase ! ibase swap load 'iend !
	iend ibase - 48 <? ( drop 0 ; ) drop
	ibase d@ "SSM1" d@ <>? ( drop 0 ; ) drop
	ibase 4 + d@ 'lnn ! ibase 8 + d@ 'lnp ! ibase 12 + d@ 'lnc !
	ibase 16 + d@ 'lnk ! ibase 20 + d@ 'lnl !
	iend ibase -
	lnn 48 * 48 + lnp lnn * 5 << + lnc 4 << + lnk 3 << + lnl +
	<? ( drop 0 ; ) drop
	iend 'here !				| la imagen queda reservada; la descripcion es una copia con lugar para editar
	lnn 256 + lnp 8 + lnc 8 + lnk 64 + ssmo_new drop
	lnl 4096 + dup alloc 72 dset 112 dset
	ibase 48 + 'sn1 ! sn1 lnn 48 * + 'sp1 ! sp1 lnp lnn * 5 << + 'sc1 !
	sc1 lnc 4 << + 'sk1 ! sk1 lnk 3 << + 'sl1 !
	40 dget sn1 lnn 48 * cmove
	0 ( lnp <? dup 80 dget * 5 << 48 dget + over lnn * 5 << sp1 + lnn 5 << cmove 1+ ) drop
	56 dget sc1 lnc 4 << cmove
	64 dget sk1 lnk 3 << cmove
	72 dget sl1 lnl cmove
	lnn 0 dset lnp 8 dset lnc 16 dset lnk 24 dset lnl 32 dset
	ibase 24 + d@ 120 dset
	okpar 0? ( ; ) drop
	cur ;

|---- quaterniones 16.16
#nqx #nqy #nqz #nqw #nqn
:qnorm | x y z w -- x y z w
	'nqw ! 'nqz ! 'nqy ! 'nqx !
	nqx dup *. nqy dup *. + nqz dup *. + nqw dup *. + sqrt. 'nqn !
	nqn 0? ( drop 0 0 0 1.0 ; ) drop
	nqx nqn /. nqy nqn /. nqz nqn /. nqw nqn /. ;

#ax_ #ay_ #az_ #aw_ #bx_ #by_ #bz_ #bw_
:qmul | ax ay az aw bx by bz bw -- qx qy qz qw	; a * b normalizado
	'bw_ ! 'bz_ ! 'by_ ! 'bx_ ! 'aw_ ! 'az_ ! 'ay_ ! 'ax_ !
	aw_ bx_ *. ax_ bw_ *. + ay_ bz_ *. + az_ by_ *. -
	aw_ by_ *. ax_ bz_ *. - ay_ bw_ *. + az_ bx_ *. +
	aw_ bz_ *. ax_ by_ *. + ay_ bx_ *. - az_ bw_ *. +
	aw_ bw_ *. ax_ bx_ *. - ay_ by_ *. - az_ bz_ *. -
	qnorm ;

::ssmo_qmul | ax ay az aw bx by bz bw -- qx qy qz qw
	qmul ;

#dx4 #dy4 #dz4 #dw4
::ssmo_nrotate | ax ay az turnos i --	; q = q * giro local
	ssmo_nadr 'na !
	ssmo_qaxis 'dw4 ! 'dz4 ! 'dy4 ! 'dx4 !
	na 20 + d@ na 24 + d@ na 28 + d@ na 32 + d@ dx4 dy4 dz4 dw4 qmul
	na 32 + d! na 28 + d! na 24 + d! na 20 + d! ;

#rvx #rvy #rvz #rqx #rqy #rqz #rqw #rtx #rty #rtz
:qrot | x y z qx qy qz qw -- x y z	; v + w*t + q x t   (t = 2 q x v)
	'rqw ! 'rqz ! 'rqy ! 'rqx ! 'rvz ! 'rvy ! 'rvx !
	rqy rvz *. rqz rvy *. - 2* 'rtx !
	rqz rvx *. rqx rvz *. - 2* 'rty !
	rqx rvy *. rqy rvx *. - 2* 'rtz !
	rvx rqw rtx *. + rqy rtz *. + rqz rty *. -
	rvy rqw rty *. + rqz rtx *. + rqx rtz *. -
	rvz rqw rtz *. + rqx rty *. + rqy rtx *. - ;

:qpack | qx qy qz qw -- rp		; 4 x 16 bits (2.14), como ss3d packq
	2 >> $ffff and 48 << swap
	2 >> $ffff and 32 << or swap
	2 >> $ffff and 16 << or swap
	2 >> $ffff and or ;

|---- instancias: 0 desc | 8 loc | 16 wld | 24 x 32 y 40 z | 48 qx 56 qy 64 qz 72 qw | 80 escala
#im #td
:mcap td 80 + @ ;
:setim | m --
	dup 'im ! @ 'td ! ;
:mnn td @ ;
:mpn td 40 + @ ;
:mpp td 48 + @ ;
:mpc td 56 + @ ;
:mpk td 64 + @ ;
:mloc im 8 + @ ;
:mwld im 16 + @ ;

::ssmo_bind | m --
	setim
	0 ( mnn <? dup 5 << mloc + over 48 * mpn + 8 + 32 cmove 1+ ) drop ;

::ssmo_inst | d -- m
	112 alloc swap over ! dup setim
	td 80 + @ 5 << dup alloc im 8 + ! alloc im 16 + !
	1.0 im 72 + ! 1.0 im 80 + ! -1 im 88 + !
	im ssmo_bind im ;

::ssmo_rpos | x y z m --
	setim im 40 + ! im 32 + ! im 24 + ! ;
::ssmo_rrot | qx qy qz qw m --
	setim im 72 + ! im 64 + ! im 56 + ! im 48 + ! ;
::ssmo_rscale | s m --
	setim im 80 + ! ;
::ssmo_hilite | nodo color m --
	setim im 96 + ! im 88 + ! ;
::ssmo_loc | nodo m -- adr
	setim 5 << mloc + ;
::ssmo_world | nodo m -- adr
	setim 5 << mwld + ;

|---- mundo
#wi #wpar #lc #wd #pw
:upnode | i --
	dup 'wi ! 48 * mpn + 4 + d@ 'wpar !
	wi 5 << mloc + 'lc ! wi 5 << mwld + 'wd !
	wpar -? ( drop wd lc 32 cmove ; ) drop
	wpar 5 << mwld + 'pw !
	lc d@ pw 28 + d@ *. lc 4 + d@ pw 28 + d@ *. lc 8 + d@ pw 28 + d@ *.
	pw 12 + d@ pw 16 + d@ pw 20 + d@ pw 24 + d@ qrot
	pw 8 + d@ + wd 8 + d!
	pw 4 + d@ + wd 4 + d!
	pw d@ + wd d!
	pw 12 + d@ pw 16 + d@ pw 20 + d@ pw 24 + d@
	lc 12 + d@ lc 16 + d@ lc 20 + d@ lc 24 + d@ qmul
	wd 24 + d! wd 20 + d! wd 16 + d! wd 12 + d!
	pw 28 + d@ lc 28 + d@ *. wd 28 + d! ;

::ssmo_update | m --
	setim 0 ( mnn <? dup upnode 1+ ) drop ;

|---- dibujo (ss3dset por puntero: la biblioteca no depende de GL)
#dxt #dnext #dk #dspr #dcol #dw #dsx #dsy #dsz #dq
:drawnode | i --
	dup 48 * mpn + d@ -? ( 2drop ; ) 'dspr !
	dup 48 * mpn + 40 + d@ 'dcol !
	dup im 88 + @ =? ( im 96 + @ 'dcol ! ) drop
	5 << mwld + 'dw !
	dw d@ dk *. dw 4 + d@ dk *. dw 8 + d@ dk *.
	im 48 + @ im 56 + @ im 64 + @ im 72 + @ qrot
	im 40 + @ + 'dsz ! im 32 + @ + 'dsy ! im 24 + @ + 'dsx !
	im 48 + @ im 56 + @ im 64 + @ im 72 + @
	dw 12 + d@ dw 16 + d@ dw 20 + d@ dw 24 + d@ qmul qpack 'dq !
	dsx dsy dsz dq im 80 + @ dw 28 + d@ *. dspr dcol dnext dxt ex
	1 'dnext +! ;

::ssmo_wpos | nodo m -- x y z		; posicion del nodo en el mundo (escala de ss3d)
	setim 5 << mwld + 'dw !
	im 80 + @ 0.01 *. 'dk !
	dw d@ dk *. dw 4 + d@ dk *. dw 8 + d@ dk *.
	im 48 + @ im 56 + @ im 64 + @ im 72 + @ qrot
	im 40 + @ + 'dsz ! im 32 + @ + 'dsy ! im 24 + @ + 'dsx !
	dsx dsy dsz ;

::ssmo_draw | 'set primero m -- siguiente
	dup ssmo_update setim 'dnext ! 'dxt !
	im 80 + @ 0.01 *. 'dk !
	0 ( mnn <? dup drawnode 1+ ) drop
	dnext ;

|---- animacion: poses
::ssmo_pose! | pose m --
	setim mcap * 5 << mpp + mloc swap mnn 5 << cmove ;

#fa #fb #ft #fd #fs
:lerp | a b t -- v
	>r over - r> *. + ;
:bl | off --
	dup fa + d@ over fb + d@ ft lerp swap fd + d! ;
:bq | off -- v
	dup fa + d@ 1.0 ft - *. swap fb + d@ fs *. ft *. + ;
:blend8 | a b dst --
	'fd ! 'fb ! 'fa !
	0 bl 4 bl 8 bl 28 bl
	1.0 'fs !
	fa 12 + d@ fb 12 + d@ *. fa 16 + d@ fb 16 + d@ *. + fa 20 + d@ fb 20 + d@ *. + fa 24 + d@ fb 24 + d@ *. +
	-? ( 1.0 neg 'fs ! ) drop
	12 bq 16 bq 20 bq 24 bq qnorm
	fd 24 + d! fd 20 + d! fd 16 + d! fd 12 + d! ;

#ba #bb #bo
:blendnode | i --
	5 << 'bo !
	ba bo + bb bo + mloc bo + blend8 ;

::ssmo_blend | pa pb t m --
	setim 'ft !
	mcap * 5 << mpp + 'bb !
	mcap * 5 << mpp + 'ba !
	0 ( mnn <? dup blendnode 1+ ) drop ;

|---- animacion: clips
#cca #ccf #ccn #ccd #cct #cck #ckk #pka #pkb #tk0 #tk1
:findk | -- k
	0 ( ccn 1- <?
		dup 1+ 3 << cck + 4 + d@ cct >? ( drop ; ) drop
		1+ ) ;

::ssmo_play | clip ms m --
	setim 'cct !
	4 << mpc + 'cca !
	cca 4 + d@ 'ccf ! cca 8 + d@ 'ccn !
	ccn 0? ( drop ; ) drop
	mpk ccf 3 << + 'cck !
	cck ccn 1- 3 << + 4 + d@ 'ccd !
	cct 0 max 'cct !
	ccd 0 >? ( cca 12 + d@ 1 and 1? ( cct ccd mod 'cct ! ) drop ) drop
	cct ccd >? ( ccd 'cct ! ) drop
	findk 'ckk !
	ckk 1+ ccn >=? ( drop cck ckk 3 << + d@ im ssmo_pose! ; ) drop
	cck ckk 3 << + 'pka ! pka 8 + 'pkb !
	pka 4 + d@ 'tk0 ! pkb 4 + d@ 'tk1 !
	cct tk0 - 16 << tk1 tk0 - 1 max /
	pka d@ pkb d@ rot im ssmo_blend ;
