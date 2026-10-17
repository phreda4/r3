| replcore - session and project of r3repl (no UI)
| includes, defined names, project text (defs) and the repl/proj/<n>/<n>.r3 files
| the generated program and its execution are in replgen.r3 ; the screen in repl2.r3
^r3/lib/console.r3
^repl/replib.r3
^r3/d4/r3token.r3	| before the definition of tok below (r3token uses the r3map one)
^r3/d4/r3genera.r3

##tk * 256		| current token (see tok)
##lo2 * 2048		| current line
#zero 0

|---------------- estado de la sesion
##sstk * 2048		| pila de la sesion (valores recuperados de mem/repl.out)
##sn 0
##incs * 4096		| includes de la sesion, 32 x 128 ("^r3/lib/math.r3")
##ninc 0 ##ninc0 0
##defs 0		| texto del proyecto (sin includes)
##defs> 0
##defl 0
##dnp * 512		| punteros a nombres definidos
##dnn 0 ##dnn0 0
#dnpool * 4096
#dnpool> 'dnpool

|---------------- texto: tokens, includes y nombres
::tok | adr -- adr' ; copies the token to 'tk (copynom), returns the delimiter (>>sp)
	dup 'tk swap copynom >>sp ;

::nextl | adr -- adr' ; start of the next line (>>cr stops AT the CR/LF)
	>>cr c@+ $ff and
	0? ( drop 1- ; )
	13 =? ( drop dup c@ $ff and 10 =? ( drop 1+ ; ) drop ; )
	drop ;

::lkind | adr -- k ; 0 expresion, 1 include, 2 definicion, 3 vacia/comentario
	trim c@ $ff and
	0? ( drop 3 ; )
	$5e =? ( drop 1 ; )
	$7c =? ( drop 3 ; )
	$3a =? ( drop 2 ; )
	$23 =? ( drop 2 ; )
	drop 0 ;

:inc? | "^path" -- 0/1
	0 ( ninc <?
		dup 7 << 'incs + pick2 = 1? ( 3drop 1 ; ) drop
		1+ ) 2drop 0 ;

::inc+ | "^path" --
	dup inc? 1? ( 2drop ; ) drop
	ninc 31 >=? ( 2drop ; ) drop
	ninc 7 << 'incs + strcpy 1 'ninc +! ;

:dn+ | str -- ; recuerda un nombre definido
	dnn 63 >=? ( 2drop ; ) drop
	dnpool> 'dnpool - 3800 >=? ( 2drop ; ) drop
	dnpool> dup dnn 3 << 'dnp + !
	strcpyl 'dnpool> ! 1 'dnn +! ;

::defined? | -- 0/1 ; 'tk es un nombre definido en la sesion
	0 ( dnn <?
		dup 3 << 'dnp + @ 'tk = 1? ( 2drop 1 ; ) drop
		1+ ) drop 0 ;

:dch? | c -- 0/1
	$3a =? ( drop 1 ; ) $23 =? ( drop 1 ; ) drop 0 ;

:regtok | si 'tk es :nombre o #nombre lo registra
	'tk c@ $ff and dch? 0? ( drop ; ) drop
	'tk ( dup c@ $ff and dch? 1? drop 1+ ) drop
	dup c@ $ff and 0? ( 2drop ; ) drop
	dn+ ;

::regnames | adr --
	( trim dup c@ $ff and 1? drop
		tok regtok ) 2drop ;

::defs+ | str -- ; agrega la linea a las definiciones de la sesion
	defs> defs - $1e000 >=? ( 2drop ; ) drop
	defs> strcpyl 1- 13 swap c!+ 10 swap c!+
	0 over c! 'defs> ! 1 'defl +! ;

|---------------- proyectos: repl/proj/<nombre>/<nombre>.r3
##pdir "repl/proj/"
##pname * 64
##ppath * 256
##pfold * 256
##pbuf 0
##menubuf * 1024

::setproj | "name" --
	'pname strcpy
	'pname 'pname 'pdir "%s%s/%s.r3" sprint 'ppath strcpy
	'pname 'pdir "%s%s" sprint 'pfold strcpy ;

:mk1 | "path" -- ; creates one folder (no shell: sys on Windows does not run cmd)
|WIN|	0 CreateDirectory drop
|LIN|	$1ff libc-mkdir drop
|MAC|	$1ff libc-mkdir drop
|RPI|	$1ff libc-mkdir drop
	;

::mkproj | creates repl/proj/<name> (each level, existing ones are ignored)
	"repl" mk1 "repl/proj" mk1 'pfold mk1 ;

::proj-clear
	0 'ninc ! defs 'defs> ! 0 defs c! 0 'defl !
	'dnpool 'dnpool> ! 0 'dnn ! ;

:pline | procesa la linea que esta en 'lo2
	'lo2 "| r3repl" =pre nip 1? ( drop ; ) drop
	defl 0? ( 'lo2 trim c@ 0? ( 2drop ; ) drop ) drop
	'lo2 lkind
	1 =? ( drop 'lo2 trim tok drop 'tk inc+ ; )
	2 =? ( 'lo2 regnames )
	drop 'lo2 defs+ ;

::proj-parse | adr -- ; includes y definiciones desde el texto
	proj-clear
	( dup c@ $ff and 1? drop
		dup 'lo2 strcpyln pline
		nextl )
	2drop ;

::proj-load | -- ok
	'ppath filexist 0? ( ; ) drop
	pbuf 'ppath load 0 swap c!
	pbuf proj-parse 1 ;

::proj-save | -- ok ; 0 = the file could not be saved
	mark
	'pname "| r3repl - project %s" ,print ,nl
	0 ( ninc <? dup 7 << 'incs + ,s ,nl 1+ ) drop
	,nl
	defs ,s
	'ppath savemem
	empty
	'ppath filexist 1? ( drop 1 ; ) drop 0 ;

::proj-ensure | -- ok ; crea el proyecto si no existe
	'ppath filexist 1? ( drop 1 ; ) drop
	mkproj proj-clear proj-save ;

::proj-remember
	'pname count "mem/repl.last" save ;

:okch? | c -- 0/1 ; a-z 0-9 _ -
	97 122 in? ( drop 1 ; ) 48 57 in? ( drop 1 ; ) 95 =? ( drop 1 ; ) 45 =? ( drop 1 ; ) drop 0 ;

::namecheck | str -- 0/1
	dup count nip 30 >? ( 2drop 0 ; ) drop
	dup c@ $ff and 0? ( 2drop 0 ; ) drop
	( c@+ $ff and 1? tolow okch? 0? ( 2drop 0 ; ) drop )
	2drop 1 ;

::sanit | str -- ; reemplaza por _ lo que no sea valido
	( dup c@ $ff and 1? tolow okch? 0? ( 95 pick2 c! ) drop 1+ ) 2drop ;

|---------------- edicion del texto del proyecto
::names-rebuild | rebuilds the defined-names list from the project text
	0 'dnn ! 'dnpool 'dnpool> !
	defs ( dup c@ $ff and 1? drop
		dup 'lo2 strcpyln 'lo2 lkind 2 =? ( 'lo2 regnames ) drop
		nextl ) 2drop ;

#delp 0
:keepline | appends 'lo2 to the project unless it starts with delp
	'lo2 delp =pre nip 1? ( drop ; ) drop 'lo2 defs+ ;

::defs-del | "prefix" -- ; removes the lines that start with prefix
	'delp !
	defs pbuf strcpy
	defs 'defs> ! 0 defs c! 0 'defl !
	pbuf ( dup c@ $ff and 1? drop
		dup 'lo2 strcpyln keepline nextl ) 2drop ;

::core-init | -- ; big buffers (>8192) are reserved at the boot
	here
	dup 'defs ! $20000 +
	dup 'pbuf ! $20000 +
	'here !
	defs 'defs> ! 0 defs c! ;
