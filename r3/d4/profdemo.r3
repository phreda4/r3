| profdemo - genera el profile, ejecuta y lee el resultado
| 1 tokeniza  2 genera con profiling  3 ejecuta  4 lee mem/profile.mem
^r3/d4/r3genprof.r3

#cnt

:muestra | i row -- ; fila: msec-inicio | calls<<32 + msec
	8 + @ dup $ffffffff and
	swap 32 >> 0? ( 3drop ; )	| i ms calls
	rot nmain + r3name		| ms calls name
	"%w calls:%d ms:%d" .println ;

:informe | -- ; lee mem/profile.mem  [cantidad][filas de 16 bytes]
	here "mem/profile.mem" load here =? ( drop "sin datos" .println ; ) drop
	here @+ 'cnt !
	0 ( cnt <?
		dup dup 4 << pick3 + muestra
		1+ ) 2drop ;

:
	"r3/d4/profsample.r3" r3tok
	error 1? ( drop "error al tokenizar" .println r3free ; ) drop

	mark ,r3prof "mem/prof.r3" savemem empty	| genera
	"mem/profile.mem" delete

	"r3 mem/prof.r3" sys			| ejecuta
	"--- profile" .println
	informe						| lee, con los nombres del tokenizado
	r3free ;
