| r3genera - r3 > tokens > r3 (sin optimizar)
| basado en r3plain.r3 - PHREDA 2024
|
| 3 etapas:
|  1 TOKENIZAR   r3tok "src" / r3free      carga y tokeniza (dic, tok en memoria)
|  2 ANALIZAR    r3defs r3toks + info      recorre dic/tokens sin generar nada
|  3 GENERAR     ,r3genera / r3save "dst"  simple, o con hooks para modificar
|
| hooks de la etapa 3 (0 = default). 'palabra 'hook !
|	gname | n --   imprime el nombre de la palabra n (cabecera y llamadas)
|	gdef  | n --   despues de la cabecera de la palabra n
|	gtok  | tok -- por cada token. tok and $ff = tipo (7 = ;)
|	defaults para usar dentro de los hooks: ,name0 ,tokgen
|-----------------
^r3/lib/console.r3
^r3/d4/r3token.r3

|-------------------------------------------
| ETAPA 1 - tokenizar
#ghere

::r3tok | "src" -- ; error queda en 'error
	here 'ghere !
	mark
	r3load ;

::r3free | -- ; libera la memoria de r3tok
	( memsize drop ghere <>? drop empty ) drop
	empty ;

|-------------------------------------------
| ETAPA 2 - analisis
::r3name | n -- str
	nro>dic @ dic>name ;

::r3isdata | n -- 0/1
	nro>dic @ 1 and ;

::r3calls | n -- cantidad de usos
	nro>dic 8 + @ 16 >> $ffff and ;

::r3len | n -- cantidad de tokens
	nro>dic toklend nip ;

::r3defs | 'word -- ; word | n --   por cada definicion
	0 ( cntdef <?
		2dup swap ex
		1+ ) 2drop ;

#ew
::r3toks | 'word n -- ; word | tok --   por cada token de la definicion n
	swap 'ew !
	nro>dic toklend
	( 1? 1- swap @+ ew ex swap ) 2drop ;

|-------------------------------------------
| ETAPA 3 - generar
##gname 0
##gdef 0
##gtok 0

::,name0 | n -- ; nombre original
	r3name "%w" ,print ;

::r3isboot | n -- 0/1 ; definicion ": " sin nombre
	r3name c@+ $3a <>? ( 2drop 0 ; ) drop
	c@ $ff and 33 <? ( drop 1 ; ) drop 0 ;

::,wname | n --
	dup r3isboot 1? ( drop "boot%d" ,print ; ) drop
	gname 1? ( ex ; ) drop
	,name0 ;

:,lows | str -- ; en minusculas
	( c@+ $ff and 1?
		65 90 in? ( 32 + )
		,c ) 2drop ;

:,strq | str -- ; string entre comillas
	34 ,c
	( c@+ 1? 34 =? ( dup ,c ) ,c ) 2drop
	34 ,c ;

::,tokgen | tok -- ; imprime un token
	dup $ff and
	0? ( drop 40 >>> src + "%w" ,print ; )		| literal grande
	1 =? ( drop 40 >>> src + "%w" ,print ; )	| literal
	2 =? ( drop 8 >> $ffffffff and ,wname ; )	| palabra
	3 =? ( drop $27 ,c 8 >> $ffffffff and ,wname ; )	| 'palabra
	4 =? ( drop 8 >> $ffffffff and ,wname ; )	| variable
	5 =? ( drop $27 ,c 8 >> $ffffffff and ,wname ; )	| 'variable
	6 =? ( drop 8 >> $ffffffff and strm + ,strq ; )		| string
	7 - basename ,lows drop ;

:,tok | tok --
	gtok 1? ( ex ; ) drop ,tokgen ;

:,hdef | n --
	gdef 1? ( ex ; ) 2drop ;

::,r3pre | info -- ; : :: # ##
	dup 1 and $17 * $3a swap - | info c
	dup ,c
	swap 2 and? ( over ,c ) 2drop ;

:,defname | n --
	boot>> =? ( drop ; )	| ultima boot sin nombre
	,wname ;

::,r3body | n --
	nro>dic toklend
	( 1? 1- swap @+ ,tok ,sp swap ) 2drop ;

::,r3def | n -- ; una palabra
	dup nro>dic @ ,r3pre
	dup ,defname ,sp
	dup ,hdef
	,r3body ,cr ;

::,r3genera | -- ; todo lo tokenizado -> here
	switchmem "|MEM %d" ,print ,cr
	"| r3genera " ,s 'filename ,s ,cr
	0 ( cntdef <? dup ,r3def 1+ ) drop ;

::r3nohooks | --
	0 'gname ! 0 'gdef ! 0 'gtok ! ;

|-------------------------------------------
| utiles
#gout * 1024

::r3save | "dst" -- ; genera (con los hooks actuales) y graba
	'gout strcpy
	mark ,r3genera 'gout savemem empty ;

::r3genera | "src" "dst" -- ; las 3 etapas, sin modificar
	swap r3tok
	error 0? ( drop r3nohooks r3save r3free ; )
	2drop r3free ;
