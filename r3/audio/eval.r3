| eval.r3 - mini-notacion tipo Strudel: parser recursivo + evaluador por ciclos
| PHREDA 2025
|
| SINTAXIS
|   c4 d#4 eb3 60   nota (c4 = 60, sin octava = octava 3, un numero = nota midi)
|   ~ -             silencio                       a b c  ==  [a b c]
|   [a b c]         secuencia: un paso por elemento
|   <a b c>         alterna: un elemento por ciclo
|   {a b c}         todos al mismo tiempo (capas)
|   (a b c)         uno al azar en cada evaluacion
|   [a b, c d e]    la coma apila capas (tambien en < > ( ) y al nivel superior)
|   a*2  a*1.5      mas rapido, se repite dentro del paso     a/2  mas lento
|   a!3  a!         replica: a a a / a a                      a@3  a _   peso: el paso dura 3 / uno mas
|   a?  a?0.3       se pierde con probabilidad 0.5 / 0.3
|   a(3,8)  a(3,8,2)  euclidiano (pulsos,pasos,rotacion)
|   a:3             variante (sample) 0..255                  a^0.5  volumen 0..1
|
| API
|   process | "str" --         parsea a ##tokens
|   eval    | --              eventos del ciclo ##ccycle -> ##stack (la limpia antes)
|   processat | "str" 'buf -- bytes     parsea a otro buffer (devuelve los bytes usados)
|   evalat  | 'buf cycle --   eventos del ciclo cycle del arbol de 'buf -> ##stack (no la limpia)
|   evento (64 bits): nota(8) variante(8) volumen(8) <<32 | start(16)<<16 | dur(16)
|                     start y dur: fraccion del ciclo (65536 = 1 ciclo); volumen 0 = normal

^r3/lib/console.r3
^r3/lib/parse.r3
^r3/lib/rand.r3

|--- eventos
##stack * $2000
##stack> 'stack

:push stack> !+ 'stack> ! ;

|--- arbol: nodos de 32 bytes
|  0 c tipo (0 nota 1 seq 2 alt 3 capas 4 azar 5 silencio)  1 c nota  2 c variante  3 c volumen
|  4 w nro de hijos  6 w primer hijo (indice)  8 d peso (16.16)  12 d suma de pesos de los hijos
|  16 d velocidad (fast/slow 16.16)  20 d prob. de sonar (16.16)  24 c euclid pulsos  25 c pasos  26 c rotacion
##tokens * $8000
##tokens> 'tokens
#tbase 'tokens

:n.type		c@ ;
:n.note		1+ c@ $ff and ;
:n.var		2 + c@ $ff and ;
:n.vol		3 + c@ $ff and ;
:n.nk		4 + w@ ;
:n.fk		6 + w@ ;
:n.weight	8 + d@ ;
:n.wsum		12 + d@ ;
:n.rate		16 + d@ ;
:n.prob		20 + d@ ;
:n.ek		24 + c@ $ff and ;
:n.en		25 + c@ $ff and ;
:n.er		26 + c@ ;

:>node | idx -- adr
	5 << tbase + ;

|--- parser
#pp			| puntero de parseo
:cc pp c@ $ff and ;
:pp+ pp 1+ 'pp ! ;
:skipws ( cc 1? 33 <? drop pp+ ) drop ;

:delim? | c -- 0/1		| espacio ( ) < > [ ] { } ,
	$ff and
	33 <? ( 1 nip ; )
	$5b =? ( 1 nip ; ) $5d =? ( 1 nip ; )
	$3c =? ( 1 nip ; ) $3e =? ( 1 nip ; )
	$7b =? ( 1 nip ; ) $7d =? ( 1 nip ; )
	$28 =? ( 1 nip ; ) $29 =? ( 1 nip ; )
	$2c =? ( 1 nip ; )
	0 nip ;

:skiptok ( cc delim? 0? drop pp+ ) drop ;

:mint | -- n
	pp str>nro swap 'pp ! ;
:mnum | -- fix
	pp str>fnro swap 'pp ! ;
:digit? | -- 0/1
	cc 48 - 0 9 in? ( drop 1 ; ) drop 0 ;

|--- nodo en construccion
#cur * 32
:c.type 'cur ;
:c.note 'cur 1+ ;
:c.var 'cur 2 + ;
:c.vol 'cur 3 + ;
:c.nk 'cur 4 + ;
:c.fk 'cur 6 + ;
:c.weight 'cur 8 + ;
:c.wsum 'cur 12 + ;
:c.rate 'cur 16 + ;
:c.prob 'cur 20 + ;
:c.ek 'cur 24 + ;
:c.en 'cur 25 + ;
:c.er 'cur 26 + ;

#mfast #mslow #mrep

:curinit
	'cur 0 32 cfill
	1.0 c.weight d!  1.0 c.rate d!  1.0 c.prob d!
	1.0 'mfast !  1.0 'mslow !  1 'mrep ! ;

|--- pila temporal de nodos (los hijos se copian contiguos a ##tokens al cerrar el grupo)
#tmp * $8000
#tmp> 'tmp

:cur>tmp1 tmp> 'cur 4 move 32 'tmp> +! ;

:kidsw | from -- sum		| suma de pesos de los nodos desde from hasta tmp>
	0 swap
	( tmp> <?
		dup n.weight rot + swap 32 + ) drop ;

:kids>cur | from type --	| nodo de grupo en cur con los nodos de tmp desde from
	curinit c.type c!
	dup kidsw c.wsum d!
	tokens> tbase - 5 >> c.fk w!
	tmp> over -
	dup 5 >> c.nk w!
	tokens> pick2 pick2 3 >> move
	tokens> + 'tokens> !
	'tmp> ! ;

|--- modificadores  * / ! @ ? : ^ (k,n,r)
:meuc | --
	skipws mint c.ek c!  skipws cc $2c =? ( pp+ ) drop
	skipws mint c.en c!  skipws
	cc $2c =? ( pp+ skipws mint c.er c! skipws ) drop
	cc $29 =? ( pp+ ) drop ;

:pmod | c -- 0/1
	$2a =? ( drop pp+ mnum 'mfast ! 1 ; )
	$2f =? ( drop pp+ mnum 'mslow ! 1 ; )
	$21 =? ( drop pp+ digit? 1? ( drop mint 'mrep ! 1 ; ) drop 2 'mrep ! 1 ; )
	$40 =? ( drop pp+ mnum c.weight d! 1 ; )
	$3f =? ( drop pp+ mnum 0? ( 0.5 + ) 1.0 swap - c.prob d! 1 ; )
	$3a =? ( drop pp+ mint c.var c! 1 ; )
	$5e =? ( drop pp+ mnum 255 *. 1 max 255 min c.vol c! 1 ; )
	$28 =? ( drop pp+ meuc 1 ; )
	drop 0 ;

:pmods ( cc pmod 1? drop ) drop ;

:pitemend | --		| modificadores, velocidad y replica
	pmods
	mslow 0? ( drop 1.0 ) mfast swap /. c.rate d!
	mrep ( 1? 1- cur>tmp1 ) drop ;

|--- notas
#semi 9 11 0 2 4 5 7		| a b c d e f g

:accid | semi -- semi'
	cc $20 or
	$23 =? ( drop pp+ 1+ ; ) $73 =? ( drop pp+ 1+ ; ) $62 =? ( drop pp+ 1- ; )
	drop ;

:octave | -- oct
	cc 48 - 0 9 in? ( pp+ ; ) drop 3 ;

:mnote | -- midi
	cc $20 or 97 - 3 << 'semi + @ pp+ accid octave 1+ 12 * + ;

:mrest curinit 5 c.type c! ;

|--- grupos (recursivos: pitem se llama por variable)
#pitemx

:gstep | pstart type -- pstart'
	cc $2c =? ( drop pp+ kids>cur cur>tmp1 tmp> ; )
	2drop pitemx ex ;

#fbase
:gfin | close type pstart --	| arma el nodo del grupo en cur
	rot drop fbase =? ( drop fbase swap kids>cur ; )
	swap kids>cur cur>tmp1 fbase 3 kids>cur ;

:pgroup | close type --
	tmp> >r tmp>
	( skipws cc 1? pick3 <>? drop over gstep )
	drop cc 1? ( pp+ ) drop
	r> 'fbase !
	rot drop fbase =? ( drop fbase swap kids>cur ; )
	swap kids>cur cur>tmp1 fbase 3 kids>cur ;

:mextend | _  : alarga el elemento anterior
	tmp> 'tmp >? ( 32 - dup 8 + d@ 1.0 + swap 8 + d! ; ) drop ;

:pitem | --
	cc
	$5b =? ( drop pp+ $5d 1 pgroup pitemend ; )
	$3c =? ( drop pp+ $3e 2 pgroup pitemend ; )
	$7b =? ( drop pp+ $7d 3 pgroup pitemend ; )
	$28 =? ( drop pp+ $29 4 pgroup pitemend ; )
	$7e =? ( drop pp+ mrest pitemend ; )
	$2d =? ( drop pp+ mrest pitemend ; )
	$5f =? ( drop pp+ mextend ; )
	drop
	cc $20 or 97 - 0 6 in? ( drop curinit mnote c.note c! pitemend ; ) drop
	cc 48 - 0 9 in? ( drop curinit mint c.note c! pitemend ; ) drop
	pp+ skiptok mrest pitemend ;

::processat | "str" 'buf -- bytes
	'pitem 'pitemx !
	swap 'pp ! 'tbase !
	tbase 32 + 'tokens> !
	'tmp 'tmp> !
	0 1 pgroup
	tbase 'cur 4 move
	tokens> tbase - ;

::process | "str" --
	'tokens processat drop ;

|--- evaluacion
|  tiempo interno: 1 ciclo = $100000000.  ev(s d node cyc): eventos del ciclo cyc del nodo en [s, s+d)
##ccycle
#vn #vcyc #vs #vd		| nodo, ciclo, inicio y duracion actuales
#clo #chi			| ventana de inicio de eventos permitida
#gprob			| probabilidad acumulada de los ancestros (16.16)
#evs0 #evd0

:evw | s d node cyc xt --	| guarda y fija el estado, ejecuta xt, restaura
	vn >r vcyc >r vs >r vd >r
	>r 'vcyc ! 'vn ! 'vd ! 'vs !
	r> ex
	r> 'vd ! r> 'vs ! r> 'vcyc ! r> 'vn ! ;

#ev1x #evbx
:ev | s d node cyc --
	ev1x evw ;
:evb | s d node cyc --
	evbx evw ;

:probok? | -- 0/1		| sobrevive a la probabilidad acumulada?
	gprob 65536 <? ( 65536 randmax <=? ( 0 nip ; ) ) drop 1 ;

:evnote | --		| el inicio se redondea a 16 bits antes de la ventana (sin duplicados en el borde)
	vs $8000 + 16 >>
	clo $8000 + 16 >> <? ( drop ; )
	chi $8000 + 16 >> >=? ( drop ; )
	probok? 0? ( 2drop ; ) drop
	16 <<
	vn n.note vn n.var 8 << or vn n.vol 16 << or 32 << or
	vd $8000 + 16 >> 1 max $ffff min or
	push ;

:wpos | acc W -- s		| vs + vd*acc/W
	swap vd * swap / vs + ;

:evseq | --
	vn n.wsum 0? ( drop ; )
	vn n.fk >node 0 vn n.nk
	( 1? >r
		dup pick3 wpos
		pick2 n.weight pick2 + >r
		r@ pick4 wpos
		over -
		pick3 vcyc ev
		drop 32 + r>
		r> 1- ) 4drop ;

:evalt | --
	vn n.nk 0? ( drop ; )
	vs vd rot
	vcyc over mod vn n.fk + >node
	swap vcyc swap /
	ev ;

:evstack | --
	vn n.fk >node vn n.nk
	( 1? >r
		vs vd pick2 vcyc ev
		32 + r> 1- ) 2drop ;

:evrand | --
	vn n.nk 0? ( drop ; )
	randmax vn n.fk + >node
	vs vd rot vcyc ev ;

:evtype | --
	vn n.type
	0 =? ( drop evnote ; )
	1 =? ( drop evseq ; )
	2 =? ( drop evalt ; )
	3 =? ( drop evstack ; )
	4 =? ( drop evrand ; )
	drop ;

|--- euclidiano (Bjorklund con enteros: cada grupo es bits+largo+cantidad)
#ba #bla #bca #bb #blb #bcb

:bleft | --			| lo que sobra del grupo mayor
	bca bcb >? ( drop ba 'bb ! bla 'blb ! bca bcb - 'bcb ! ; ) drop
	bcb bca - 'bcb ! ;

:bstep | --
	ba blb << bb or  bla blb +
	bca bcb min
	bleft
	'bca ! 'bla ! 'ba ! ;

:bjork | k n -- mask	| bit (n-1-i) = paso i
	over - 'bcb ! 'bca !
	1 'ba ! 1 'bla ! 0 'bb ! 1 'blb !
	( bca bcb min 1 >? drop bstep ) drop
	0 bca ( 1? 1- swap bla << ba or swap ) drop
	bcb ( 1? 1- swap blb << bb or swap ) drop ;

:ehit | mask i -- 0/1
	vn n.er + vn n.en + vn n.en mod
	vn n.en 1- swap - >> 1 and ;

:eucstep | mask i -- mask i
	2dup ehit 0? ( drop ; ) drop
	dup evd0 * vn n.en / evs0 + 'vs !
	evtype ;

:euclid | --
	evs0 >r evd0 >r
	vs 'evs0 !  vd 'evd0 !
	vd vn n.en / 'vd !
	vn n.ek vn n.en min vn n.en bjork 0
	( vn n.en <? eucstep 1+ ) 2drop
	evd0 'vd ! evs0 'vs !
	r> 'evd0 ! r> 'evs0 ! ;

:evbody | --
	gprob >r
	vn n.prob gprob *. 'gprob !
	vn n.en 0? ( drop evtype r> 'gprob ! ; ) drop
	euclid
	r> 'gprob ! ;

|--- velocidad: node*F repite/estira el ciclo del nodo F veces por ciclo del padre
:evfast | --
	clo >r chi >r
	vs clo max 'clo !  vs vd + chi min 'chi !
	vn n.rate vcyc over *
	dup 16 >>
	pick2 pick2 + $ffff + 16 >> >r
	( r@ <?
		dup 16 << pick2 -
		vd * pick3 / vs +
		vd 16 << pick4 /
		vn pick3 evb
		1+ )
	r> drop 3drop
	r> 'chi ! r> 'clo ! ;

:ev1 | --
	vn n.rate 1.0 <>? ( drop evfast ; ) drop
	evbody ;

::evalat | 'buf cycle --
	'ev1 'ev1x !  'evbody 'evbx !
	>r 'tbase !
	0 'clo !  $100000000 'chi !  65536 'gprob !
	0 $100000000 tbase r> ev ;

::eval | --
	'stack 'stack> !
	'tokens ccycle evalat ;

