| r3prof - perfila el codigo seleccionado en main.r3 (mem/menu.mem)
|  1. instrumenta el fuente    -> _prof.r3 (junto al fuente) y mem/profile.def
|  2. ejecuta _prof.r3 y lo borra -> graba mem/profile.mem al terminar el programa
|  3. abre el analizador       -> r3/d4/r3profview.r3
| PHREDA 2026

^r3/lib/console.r3
^r3/d4/r3genprof.r3

#src * 1024
#profname * 1024

| el instrumentado va en la carpeta del fuente: "^./x.r3" es relativo a la carpeta del
| fuente raiz (tambien los anidados), si estuviera en mem/ no encontraria los includes
:profpath | -- 
	'src 'profname strpath
	'profname c@ 1? ( drop 'profname "%s/_prof.r3" sprint 'profname strcpy ; ) drop
	"_prof.r3" 'profname strcpy ;

:showerr | "msg" --
	.cr .bred .white " * ERROR * " .write .cr
	.reset .write .cr
	.bblue .white " Any key to continue... " .write .cr .flush
	waitkey ;

:instrument | -- 0/1
	'src r3tok
	error 1? ( showerr r3free 0 ; ) drop
	mark ,r3prof 'profname savemem empty
	mark ,r3profdef "mem/profile.def" savemem empty
	r3free 1 ;

:
	'src "mem/menu.mem" load drop
	profpath
	'profname delete
	"mem/profile.def" delete
	"mem/profile.mem" delete
	instrument 0? ( drop ; ) drop
	'profname filexist 0? ( drop "no se pudo escribir el instrumentado junto al fuente" showerr ; ) drop
	'profname r3run
	'profname delete
	"r3/d4/r3profview.r3" r3run ;
