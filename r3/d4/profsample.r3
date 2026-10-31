| profsample - programa de ejemplo para probar el profiler (r3genprof)
| tiene: palabra muy llamada y barata, loop pesado, recursion, espera en ms, datos
| genera con r3/d4/test/profdemo.r3 o r3/d4/r3genprof.r3

^r3/lib/console.r3

#acc 0

:inc | -- ; muy llamada, muy barata
	1 'acc +! ;

:suma | n -- s ; 1+2+..+n
	0 swap ( 1? dup rot + swap 1- ) drop ;

:lote | n -- ; n veces suma de 1000
	( 1? 1- 1000 suma 'acc +! ) drop ;

:fib | n -- f ; recursiva, tiempo inclusivo
	2 <? ( ; )
	1- dup fib swap 1- fib + ;

:espera | -- ; 30 ms reales
	30 ms ;

:rapidas | -- ; 100000 llamadas a inc
	100000 ( 1? 1- inc ) drop ;

: 
	"profsample" .println
	500 lote
	24 fib drop
	espera espera espera
	rapidas
	acc "acc=%d" .println ;
