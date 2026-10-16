| inc-prof - ejemplo: cuenta llamadas y tiempo inclusivo (ms) por palabra
| prof_ini | n --   prof_end | n --   (n = nro de palabra en el diccionario)
^r3/lib/console.r3

#pcnt * 16384	| 2048 palabras
#ptim * 16384
#pstk * 4096
#pstk> 'pstk
#pn

::prof_ini | n --
	dup 3 << 'pcnt + 1 swap +!
	pstk> !+ msec swap !+ 'pstk> ! ;

:rep1 | n --
	dup 3 << 'ptim + @ over 3 << 'pcnt + @ rot
	"w%d calls:%d ms:%d" .println ;

:report | -- ; no debe tocar la pila
	0 ( 2048 <?
		dup 3 << 'pcnt + @ 1? ( over rep1 ) drop
		1+ ) drop ;

::profile_mem | n -- ; reserva/limpia para n palabras
	'pn ! ;

::profile_save | -- ; vuelca el reporte
	report ;

::prof_end | n --
	-16 'pstk> +!
	pstk> 8 + @ msec swap -
	swap 3 << 'ptim + +!
	;
