| r3prof - perfila el codigo seleccionado en main.r3 (mem/menu.mem)
|  1. instrumenta el fuente    -> mem/prof.r3 y mem/profile.def
|  2. ejecuta mem/prof.r3      -> graba mem/profile.mem al terminar el programa
|  3. abre el analizador       -> r3/d4/r3profview.r3
| PHREDA 2026

^r3/lib/console.r3
^r3/d4/r3genprof.r3

#src * 1024

:showerr | "msg" --
	.cr .bred .white " * ERROR * " .write .cr
	.reset .write .cr
	.bblue .white " Any key to continue... " .write .cr .flush
	waitkey ;

:instrument | -- 0/1
	'src r3tok
	error 1? ( showerr r3free 0 ; ) drop
	mark ,r3prof "mem/prof.r3" savemem empty
	mark ,r3profdef "mem/profile.def" savemem empty
	r3free 1 ;

:
	'src "mem/menu.mem" load drop
	"mem/prof.r3" delete
	"mem/profile.def" delete
	"mem/profile.mem" delete
	instrument 0? ( drop ; ) drop
	"mem/prof.r3" r3run
	"r3/d4/r3profview.r3" r3run ;
