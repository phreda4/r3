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
|   ssmo_trotate | ax ay az turnos adr --  igual que nrotate sobre una transformacion (8 d: x y z qx qy qz qw s)
| EDICION DE POSES / CLIPS (descripcion actual)
|   ssmo_pdel    | p -- 1/0        borra la pose p (y sus keys; las poses mayores bajan 1)
|   ssmo_kadd    | pose ms c -- k  inserta un key en el clip c ordenado por tiempo (-1 si no entra)
|   ssmo_kdel    | k c --          borra el key k del clip c      ssmo_ckeys | c -- n
|   ssmo_ckey@   | k c -- pose ms  ssmo_cloop! | 0/1 c --   ssmo_cloop@ | c -- 0/1
|   ssmo_cname@  | c -- adr        ssmo_cname! | "nombre" c --  ssmo_cdel | c --  (con sus keys)
|   ssmo_ndup    | i -- j          duplica el nodo i (mismo padre, transformacion, color, nombre y filas de pose)
| INSTANCIA
|   ssmo_inst   | d -- m            ssmo_bind | m --        (pose de armado)
|   ssmo_rpos   | x y z m --  ssmo_rrot | qx qy qz qw m --  ssmo_rscale | s m --   (raiz, en mundo)
|   ssmo_pose!  | pose m --         ssmo_blend | pa pb t m --    ssmo_play | clip ms m --
|   ssmo_loc    | nodo m -- adr     (8 d editables: animacion por programa)
|   ssmo_hilite | nodo color m --   (nodo -1 = ninguno)   ssmo_wpos | nodo m -- x y z  (mundo)
|   ssmo_w2l    | x y z nodo m -- lx ly lz   punto del mundo (escala ss3d) -> voxeles locales del nodo
|                (necesita ssmo_update; sirve para arrastrar o ubicar un nodo con el mouse)
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
::ssmo_node | spr parent -- i
	0 dget 80 dget >=? ( 3drop -1 ; )		| spr parent n
	over <=? ( 3drop -1 ; )				| el padre debe ser menor
	ab[ dup ssmo_nadr >a
	-rot swap da!+ da!+				| spr parent
	0 da!+ 0 da!+ 0 da!+				| x y z
	0 da!+ 0 da!+ 0 da!+ 1.0 da!+			| qx qy qz qw
	1.0 da!+ $ffffff00 da!+ 0 da!+			| escala color nombre
	]ba
	0 ( 8 dget <? dup 80 dget * pick2 + 5 << 48 dget + pick2 ssmo_nadr 8 + 32 cmove 1+ ) drop
	dup 1+ 0 dset ;

::ssmo_npos | x y z i --
	ab[ ssmo_nadr 16 + >a da! -4 a+ da! -4 a+ da! ]ba ;
::ssmo_nrot | qx qy qz qw i --
	ab[ ssmo_nadr 32 + >a da! -4 a+ da! -4 a+ da! -4 a+ da! ]ba ;
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

::ssmo_qaxis | ax ay az turnos -- qx qy qz qw
	2/ sincos >r >r					| ax ay az   (r: cos sin)
	rot r@ *. -rot swap r@ *. swap r@ *.		| ax*s ay*s az*s
	r> drop r> ;

|---- poses
::ssmo_pose | -- p
	8 dget 88 dget >=? ( drop -1 ; ) drop
	8 dget dup 80 dget * 5 << 48 dget +		| p pa
	0 ( 0 dget <? dup 5 << pick2 + over ssmo_nadr 8 + 32 cmove 1+ ) 2drop
	dup 1+ 8 dset ;

::ssmo_pnode | p nodo -- adr
	swap 80 dget * + 5 << 48 dget + ;

::ssmo_t! | x y z qx qy qz qw s adr --
	ab[ 28 + >a da! -4 a+ da! -4 a+ da! -4 a+ da! -4 a+ da! -4 a+ da! -4 a+ da! -4 a+ da! ]ba ;

|---- clips
::ssmo_clip | "nombre" loop -- c
	16 dget 96 dget >=? ( drop 2drop -1 ; ) drop
	swap addname 16 dget				| loop off c
	ab[ dup 4 << 56 dget + >a
	-rot da!+ 24 dget da!+ 0 da!+ da!+		| nombre primerkey 0 loop
	]ba
	dup 1+ 16 dset ;

::ssmo_key | pose ms --
	16 dget 0? ( 3drop ; ) drop
	24 dget 104 dget >=? ( 3drop ; ) drop
	ab[ 24 dget 3 << 64 dget + >a swap da!+ da!+ ]ba
	24 dget 1+ 24 dset
	16 dget 1- 4 << 56 dget + 8 + dup d@ 1+ swap d! ;

|---- edicion de la jerarquia
#sn #sk
#sperm * 4096
#sinv * 4096
#splc * 1024
#sbuf * 49152
#srow * 32768

:sparok? | i -- 1/0		; el padre ya esta ubicado (o es raiz)
	ssmo_nadr 4 + d@ -? ( drop 1 ; ) 'splc + c@ ;

:place | i --			; ubica el nodo i si su padre ya esta ubicado
	dup sparok? 0? ( 2drop ; ) drop
	dup sk 2 << 'sperm + d! 1 swap 'splc + c! 1 'sk +! ;

:sortpass
	0 ( sn <? dup 'splc + c@ 0? ( over place ) drop 1+ ) drop ;

:permnode | k --
	dup 48 * 'sbuf +					| k b
	over 2 << 'sperm + d@ ssmo_nadr over swap 48 cmove
	nip dup 4 + d@ -? ( 2drop ; )			| b padre
	2 << 'sinv + d@ swap 4 + d! ;

:permpose | p --
	80 dget * 5 << 48 dget +				| so
	0 ( sn <? dup 5 << 'srow + over 2 << 'sperm + d@ 5 << pick3 + 32 cmove 1+ ) drop
	'srow sn 5 << cmove ;

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
	swap ( -1 >? dup pick2 =? ( 3drop 1 ; ) drop ssmo_nadr 4 + d@ ) 2drop 0 ;

::ssmo_npar! | padre i -- 1/0
	swap -1 max swap				| pa ti
	-? ( 2drop 0 ; )
	0 dget >=? ( 2drop 0 ; )
	over 0 dget >=? ( 3drop 0 ; ) drop
	2dup anc? 1? ( 3drop 0 ; ) drop
	ssmo_nadr 4 + d!
	ssmo_sort ;

:shiftrecs | adr stride cnt --	; sube cada registro una posicion (adr = destino del primero)
	ab[ rot >a
	( 1? 1- a> dup pick3 + pick3 cmove over a+ ) 2drop ]ba ;

::ssmo_ndel | i -- 1/0		; solo nodos hoja
	-? ( drop 0 ; )
	0 dget >=? ( drop 0 ; )
	0 ( 0 dget <? dup ssmo_nadr 4 + d@ pick2 =? ( 3drop 0 ; ) drop 1+ ) drop
	40 dget over 48 * + 48 0 dget pick3 - 1- shiftrecs
	0 ( 8 dget <? dup 80 dget * 5 << 48 dget + pick2 5 << + 32 0 dget pick4 - 1- shiftrecs 1+ ) drop
	0 ( 0 dget 1- <? dup ssmo_nadr 4 + dup d@ pick3 >? ( 1- over d! 0 ) drop drop 1+ ) drop
	drop 0 dget 1- 0 dset 1 ;

::ssmo_nspr! | spr i --
	ssmo_nadr d! ;

::ssmo_ndup | i -- j
	dup ssmo_nadr dup d@ swap 4 + d@ ssmo_node	| i j
	-? ( nip ; )
	dup ssmo_nadr 8 + pick2 ssmo_nadr 8 + 40 cmove
	0 ( 8 dget <? dup 80 dget * dup pick3 + 5 << 48 dget + swap pick4 + 5 << 48 dget + 32 cmove 1+ ) drop
	nip ;

|---- edicion de clips / keys / poses
#kc #kp #kt #kf #kn #kj #kca #pd
:shiftup | adr stride cnt --	; baja cada registro (inserta lugar): copia de atras hacia adelante
	ab[ dup 1- pick2 * pick3 + >a rot drop
	( 1? 1- a> dup pick3 + swap pick3 cmove over neg a+ ) 2drop ]ba ;

:findins | -- j		; primer key del clip con tiempo > kt
	0 ( kn <? dup kf + 3 << 64 dget + 4 + d@ kt >? ( drop ; ) drop 1+ ) ;

::ssmo_kadd | pose ms c -- k
	'kc ! 'kt ! 'kp !
	kc -? ( drop -1 ; ) drop
	kc 16 dget >=? ( drop -1 ; ) drop
	24 dget 104 dget >=? ( drop -1 ; ) drop
	kc 4 << 56 dget + 'kca !
	kca 4 + d@ 'kf ! kca 8 + d@ 'kn !
	findins 'kj !
	64 dget kf kj + 3 << + 8 24 dget kf kj + - shiftup
	kp 64 dget kf kj + 3 << + d!
	kt 64 dget kf kj + 3 << + 4 + d!
	24 dget 1+ 24 dset
	kn 1+ kca 8 + d!
	kc 1+ ( 16 dget <? dup 4 << 56 dget + 4 + dup d@ 1+ swap d! 1+ ) drop
	kj ;

::ssmo_kdel | k c --
	'kc ! 'kj !
	kc -? ( drop ; ) drop
	kc 16 dget >=? ( drop ; ) drop
	kc 4 << 56 dget + 'kca !
	kca 4 + d@ 'kf ! kca 8 + d@ 'kn !
	kj -? ( drop ; ) drop
	kj kn >=? ( drop ; ) drop
	64 dget kf kj + 3 << + 8 24 dget kf kj + - 1- shiftrecs
	24 dget 1- 24 dset
	kn 1- kca 8 + d!
	kc 1+ ( 16 dget <? dup 4 << 56 dget + 4 + dup d@ 1- swap d! 1+ ) drop ;

::ssmo_ckeys | c -- n
	4 << 56 dget + 8 + d@ ;
::ssmo_ckey@ | k c -- pose ms
	'kc ! kc 4 << 56 dget + 4 + d@ + 3 << 64 dget + dup d@ swap 4 + d@ ;
::ssmo_cloop! | loop c --
	4 << 56 dget + 12 + d! ;
::ssmo_cloop@ | c -- 0/1
	4 << 56 dget + 12 + d@ 1 and ;
::ssmo_cname@ | c -- adr
	4 << 56 dget + d@ ssmo_name ;
::ssmo_cname! | "nombre" c --
	>r addname r> 4 << 56 dget + d! ;

#cdc
::ssmo_cdel | c --
	'cdc !
	cdc -? ( drop ; ) drop
	cdc 16 dget >=? ( drop ; ) drop
	( cdc 4 << 56 dget + 8 + d@ 1? drop 0 cdc ssmo_kdel ) drop
	56 dget cdc 4 << + 16 16 dget cdc - 1- shiftrecs
	16 dget 1- 16 dset ;

:keypose | k c -- pose
	4 << 56 dget + 4 + d@ + 3 << 64 dget + d@ ;

:cleanpose | c --		; quita los keys de la pose pd en el clip c (de atras hacia adelante)
	'kc !
	kc ssmo_ckeys ( 1? 1- dup kc keypose pd =? ( over kc ssmo_kdel ) drop ) drop ;

::ssmo_pdel | p -- 1/0
	'pd !
	pd -? ( drop 0 ; ) drop
	pd 8 dget >=? ( drop 0 ; ) drop
	0 ( 16 dget <? dup cleanpose 1+ ) drop
	0 ( 24 dget <? dup 3 << 64 dget + dup d@ pd >? ( 1- over d! 0 ) drop drop 1+ ) drop
	48 dget pd 80 dget 32 * * + 80 dget 32 * 8 dget pd - 1- shiftrecs
	8 dget 1- 8 dset 1 ;

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

:ldcp | dst n --		; copia n bytes desde A (el archivo) y avanza A
	a> over a+ swap cmove ;

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
	ab[ ibase 48 + >a
	40 dget lnn 48 * ldcp
	0 ( lnp <? dup 80 dget * 5 << 48 dget + lnn 5 << ldcp 1+ ) drop
	56 dget lnc 4 << ldcp
	64 dget lnk 3 << ldcp
	72 dget lnl ldcp ]ba
	lnn 0 dset lnp 8 dset lnc 16 dset lnk 24 dset lnl 32 dset
	ibase 24 + d@ 120 dset
	okpar 0? ( ; ) drop
	cur ;

|---- quaterniones 16.16
:qnorm | x y z w -- x y z w
	pick3 dup *. pick3 dup *. + pick2 dup *. + over dup *. + sqrt.	| x y z w n
	0? ( drop 4drop 0 0 0 1.0 ; )
	swap over /. >r swap over /. >r swap over /. >r /. r> r> r> ;

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

:qmulba | -- qx qy qz qw	; B * A normalizado (quaternions dword en +12 de cada registro)
	b> 24 + d@ a> 12 + d@ *. b> 12 + d@ a> 24 + d@ *. + b> 16 + d@ a> 20 + d@ *. + b> 20 + d@ a> 16 + d@ *. -
	b> 24 + d@ a> 16 + d@ *. b> 12 + d@ a> 20 + d@ *. - b> 16 + d@ a> 24 + d@ *. + b> 20 + d@ a> 12 + d@ *. +
	b> 24 + d@ a> 20 + d@ *. b> 12 + d@ a> 16 + d@ *. + b> 16 + d@ a> 12 + d@ *. - b> 20 + d@ a> 24 + d@ *. +
	b> 24 + d@ a> 24 + d@ *. b> 12 + d@ a> 12 + d@ *. - b> 16 + d@ a> 16 + d@ *. - b> 20 + d@ a> 20 + d@ *. -
	qnorm ;

#dx4 #dy4 #dz4 #dw4
::ssmo_trotate | ax ay az turnos adr --	; q = q * giro local (adr = x y z qx qy qz qw s)
	ab[ >a ssmo_qaxis 'dw4 ! 'dz4 ! 'dy4 ! 'dx4 !
	a> 12 + d@ a> 16 + d@ a> 20 + d@ a> 24 + d@ dx4 dy4 dz4 dw4 qmul
	a> 24 + d! a> 20 + d! a> 16 + d! a> 12 + d! ]ba ;
::ssmo_nrotate | ax ay az turnos i --	; q = q * giro local
	ssmo_nadr 8 + ssmo_trotate ;

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
	im ssmo_bind ;

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
:upnode | i --				; usa A (local) y B (mundo del padre)
	dup 48 * mpn + 4 + d@			| i padre
	-? ( drop dup 5 << mwld + swap 5 << mloc + 32 cmove ; )
	5 << mwld + >b				| i
	dup 5 << mloc + >a			| i
	5 << mwld +				| wd
	a> d@ b> 28 + d@ *. a> 4 + d@ b> 28 + d@ *. a> 8 + d@ b> 28 + d@ *.
	b> 12 + d@ b> 16 + d@ b> 20 + d@ b> 24 + d@ qrot	| wd x y z
	b> 8 + d@ + pick3 8 + d!
	b> 4 + d@ + pick2 4 + d!
	b> d@ + over d!
	qmulba							| wd qx qy qz qw
	pick4 24 + d! pick3 20 + d! pick2 16 + d! over 12 + d!
	b> 28 + d@ a> 28 + d@ *. swap 28 + d! ;

::ssmo_update | m --
	setim ab[ 0 ( mnn <? dup upnode 1+ ) drop ]ba ;

|---- dibujo (ss3dset por puntero: la biblioteca no depende de GL)
#dxt #dnext #dk			| parametros de ssmo_draw para todos los nodos
:ncolor | i -- color			; color del nodo (o el de resaltado)
	dup im 88 + @ =? ( 2drop im 96 + @ ; ) drop
	48 * mpn + 40 + d@ ;

:nodepos | dk -- x y z			; posicion en el mundo; B = registro mundo del nodo
	dup b> 8 + d@ *. >r
	dup b> 4 + d@ *. >r
	b> d@ *. r> r>
	im 48 + @ im 56 + @ im 64 + @ im 72 + @ qrot
	rot im 24 + @ + -rot swap im 32 + @ + swap im 40 + @ + ;

:drawnode | i --			; usa A (indice) y B (mundo del nodo)
	dup 48 * mpn + d@ -? ( 2drop ; ) drop
	dup >a 5 << mwld + >b
	dk nodepos
	im 48 + @ im 56 + @ im 64 + @ im 72 + @
	b> 12 + d@ b> 16 + d@ b> 20 + d@ b> 24 + d@ qmul qpack
	im 80 + @ b> 28 + d@ *.
	a> 48 * mpn + d@ a> ncolor
	dnext dxt ex
	1 'dnext +! ;

::ssmo_wpos | nodo m -- x y z		; posicion del nodo en el mundo (escala de ss3d)
	setim ab[ 5 << mwld + >b
	im 80 + @ 0.01 *. nodepos ]ba ;

#wpar2 #wpx #wpy #wpz #wsc #wdv #wxx #wyy #wzz #pq1 #pq2 #pq3 #pq4 #wd2
:parentframe | p --		; posicion (mundo), quaternion (con la raiz) y escala acumulada del padre
	-? ( drop
		im 24 + @ 'wpx ! im 32 + @ 'wpy ! im 40 + @ 'wpz !
		im 48 + @ 'pq1 ! im 56 + @ 'pq2 ! im 64 + @ 'pq3 ! im 72 + @ 'pq4 !
		1.0 'wsc ! ; )
	dup im ssmo_wpos 'wpz ! 'wpy ! 'wpx !
	5 << mwld + 'wd2 !
	im 48 + @ im 56 + @ im 64 + @ im 72 + @
	wd2 12 + d@ wd2 16 + d@ wd2 20 + d@ wd2 24 + d@ qmul
	'pq4 ! 'pq3 ! 'pq2 ! 'pq1 !
	wd2 28 + d@ 'wsc ! ;

::ssmo_w2l | x y z nodo m -- lx ly lz
	setim
	dup 48 * mpn + 4 + d@ 'wpar2 !
	drop
	'wzz ! 'wyy ! 'wxx !
	wpar2 parentframe
	wxx wpx - wyy wpy - wzz wpz -
	pq1 neg pq2 neg pq3 neg pq4 qrot
	im 80 + @ 0.01 *. wsc *. 1 max 'wdv !
	wdv /. 'wzz ! wdv /. 'wyy ! wdv /. 'wxx !
	wxx wyy wzz ;

::ssmo_draw | 'set primero m -- siguiente
	dup ssmo_update setim 'dnext ! 'dxt !
	im 80 + @ 0.01 *. 'dk !
	ab[ 0 ( mnn <? dup drawnode 1+ ) drop ]ba
	dnext ;

|---- animacion: poses
::ssmo_pose! | pose m --
	setim mcap * 5 << mpp + mloc swap mnn 5 << cmove ;

#ft #fs				| t y signo del quaternion, para todos los nodos
:lerp | a b t -- v
	>r over - r> *. + ;
:lst | d off --				; d[off] = lerp(A[off], B[off], t); usa A y B
	dup a> + d@ over b> + d@ ft lerp
	-rot + d! ;
:qd | off -- p				; usa A y B
	dup a> + d@ swap b> + d@ *. ;
:bq | off -- v				; usa A y B
	dup a> + d@ 1.0 ft - *. swap b> + d@ fs *. ft *. + ;
:blend8 | a b d --			; usa A y B
	rot >a swap >b
	dup 0 lst dup 4 lst dup 8 lst dup 28 lst
	1.0 'fs !
	12 qd 16 qd + 20 qd + 24 qd +
	-? ( -1.0 'fs ! ) drop
	12 bq 16 bq 20 bq 24 bq qnorm
	pick4 24 + d! pick3 20 + d! pick2 16 + d! swap 12 + d! ;

#ba #bb
:blendnode | i --
	5 << dup ba + over bb + rot mloc + blend8 ;

::ssmo_blend | pa pb t m --
	setim 'ft !
	mcap * 5 << mpp + 'bb !
	mcap * 5 << mpp + 'ba !
	ab[ 0 ( mnn <? dup blendnode 1+ ) drop ]ba ;

|---- animacion: clips
#cca #ccf #ccn #ccd #cct #cck #ckk
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
	cck ckk 3 << + dup d@ over 8 + d@ rot	| pa pb key
	dup 4 + d@ swap 12 + d@ over -		| pa pb t0 dur
	1 max swap cct swap - 16 << swap /		| pa pb t
	im ssmo_blend ;
