| r3genprof - agrega profiling al codigo principal (no a las librerias)
| por cada palabra con ;   :test 2 + ;   genera
|	:_test_ 2 + ;
|	:test N profile_start _test_ N profile_end ;
| N = nro de palabra - primera del codigo principal (indice 0..cntdef-nmain-1)
| profile_start | n --  y  profile_end | n --  van en inc-prof.r3
| no se envuelven: datos, palabras de arranque, palabras sin ;
| el boot principal ": ..." se reemplaza por
|	:_run_ ... ;
|	: N profile_mem _run_ profile_save ;      (N = cntdef - nmain = definiciones del codigo principal)
| profile_mem | n --   profile_save | --   tambien van en inc-prof.r3
| las referencias recursivas dentro de _test_ apuntan a _test_
|-----------------
^r3/d4/r3genera.r3

#profinc "^r3/d4/inc-prof.r3"

#cur -1		| palabra que se esta generando como _name_
##nmain	| primer palabra del codigo principal

:,selfname | --
	"_" ,s cur ,name0 "_" ,s ;

:ptokw | tok -- ; palabra o 'palabra
	dup 8 >> $ffffffff and
	cur =? ( drop $ff and 3 =? ( $27 ,c ) drop ,selfname ; )
	dup r3isboot 0? ( 2drop ,tokgen ; ) drop
	nmain <? ( 2drop ; ) drop	| llamada a boot de libreria: ya la encadena el include
	,tokgen ;

:ptok | tok --
	dup $ff and 2 3 in? ( drop ptokw ; ) drop ,tokgen ;

:isfunc? | n -- n 0/1 ; codigo con ; y no es boot
	dup r3isdata 1? ( drop 0 ; ) drop
	dup r3isboot 1? ( drop 0 ; ) drop
	dup nro>dic @ $80 and? ( drop 0 ; ) drop
	1 ;

:selfcur | n -- cur ; palabra a vigilar: -1 si r3token no la marco recursiva ($20) ni con 'palabra ($2000)
	dup nro>dic @ $2020 and? ( drop ; ) 2drop -1 ;

:,wrap | n --
	dup selfcur 'cur !
	":_" ,s dup ,name0 "_ " ,s
	dup ,r3body ,cr
	-1 'cur !
	dup nro>dic @ ,r3pre
	dup ,name0 ,sp
	dup nmain - "%d profile_start " ,print
	"_" ,s dup ,name0 "_ " ,s
	nmain - "%d profile_end ;" ,print ,cr ;

:nextl | adr -- adr' ; inicio de la linea siguiente
	( c@+ 1? 13 =? ( drop ; ) drop ) drop 1- ;

:inc? | adr -- 0/1 ; linea ^include o |XXX|^include
	c@+ $ff and
	$5e =? ( 2drop 1 ; )
	$7c <>? ( 2drop 0 ; ) drop
	3 + c@+ $ff and $7c <>? ( 2drop 0 ; ) drop
	c@ $ff and $5e =? ( drop 1 ; ) drop 0 ;

:,incs | -- ; includes directos del codigo principal
	inc> 16 - 8 + @ $ffffffff and src +
	( dup c@ 1? drop
		dup inc? 1? ( over "%l" ,print ,cr ) drop
		nextl ) 2drop ;

:,run | n -- ; boot principal -> :_run_ ... ;  y boot nuevo
	":_run_ " ,s
	dup ,r3body
	nro>dic @ $80 and? ( ";" ,s ) drop ,cr
	": " ,s cntdef nmain - "%d profile_mem _run_ profile_save ;" ,print ,cr ;

:,item | n --
	boot>> =? ( ,run ; )
	isfunc? 1? ( drop ,wrap ; ) drop ,r3def ;

::,r3prof | -- ; genera el codigo principal con profiling -> here
	dic< dic - 4 >> 'nmain !
	-1 'cur !
	switchmem "|MEM %d" ,print ,cr
	"| r3prof " ,s 'filename ,s ,cr
	,incs
	'profinc ,s ,cr
	'ptok 'gtok !
	nmain ( cntdef <? dup ,item 1+ ) drop
	r3nohooks ;

#pout * 1024

::r3prof | "src" "dst" -- ; las 3 etapas
	'pout strcpy
	r3tok
	error 0? ( drop mark ,r3prof 'pout savemem empty r3free ; )
	drop r3free ;
