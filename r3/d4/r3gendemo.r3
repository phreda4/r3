| demo r3genera: 3 etapas
^r3/d4/r3genera.r3

|--- etapa 2: estadisticas
#tipos * 128
:cuenta | tok --
	$ff and 15 >? ( drop 15 ) 3 << 'tipos + 1 swap +! ;
:porpalabra | n --
	dup r3isdata 1? ( 2drop ; ) drop
	'cuenta swap r3toks ;
:sinuso | n --
	dup r3calls 1? ( 2drop ; ) drop
	r3name "sin uso: %w" .println ;

|--- etapa 3: decorar nombres
:pref | n --
	"x_" ,s ,name0 ;

:
	"r3/d4/test.r3" r3tok
	error 1? ( "error" .println ) drop
	cntdef "defs:%d" .println
	'porpalabra r3defs
	0 ( 8 <? dup 3 << 'tipos + @ over "tipo %d: %d" .println 1+ ) drop
	'sinuso r3defs

	'pref 'gname !
	"mem/deco.r3" r3save
	r3free ;
