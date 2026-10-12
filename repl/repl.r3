| r3repl - REPL environment for R3Forth   (folder repl/)
| A session = a project: repl/proj/<name>/<name>.r3 (scratch by default).
| Each line is generated as a program (mem/repl.r3) and run with r3.
| The stack is recovered with the internal library repl/repldump.r3 (mem/repl.out).
| There is no interpreter in the REPL: r3lin runs everything.
^r3/lib/console.r3
^r3/util/utfg.r3
^r3/d4/meta/mlibs.r3
^repl/replhelp.r3

|---------------- paleta (true color)
:bg0 0 0 0 .bgrgb ;
:bg1 24 24 28 .bgrgb ;
:bg2 36 36 42 .bgrgb ;
:bg3 56 56 66 .bgrgb ;
:bBl 92 156 245 .bgrgb ;
:bPu 157 124 216 .bgrgb ;
:fTx 238 238 238 .fgrgb ;
:fMu 140 140 152 .fgrgb ;
:fDi 88 88 98 .fgrgb ;
:fPr 250 178 131 .fgrgb ;
:fBl 92 156 245 .fgrgb ;
:fPu 157 124 216 .fgrgb ;
:fGr 127 216 143 .fgrgb ;
:fRd 224 108 117 .fgrgb ;
:fYe 245 167 66 .fgrgb ;

|---------------- variables
#sw 0 #mw 80
#px 0 #py 0 #pw 0
#tmp * 256
#tk * 256
#lo2 * 2048
#pe 0 #ry 0
#busy 0 #sf 0 #quit 0 #zero 0

|---------------- utilidades de pantalla
:layout
|LIN|	.getterminfo
	0 'sw ! cols 100 >=? ( 34 'sw ! ) drop
	cols sw - 'mw ! ;

|---------------- transcript
#tp * $20000
#tp> 'tp
#tl * $2000
#ntl 0
#scroll 0

:tl+p | "txt" style -- 'guardado
	ntl 1000 >=? ( 0 'ntl ! 'tp 'tp> ! ) drop
	tp> 'tp - $1f000 >? ( 0 'ntl ! 'tp 'tp> ! ) drop
	tp> 8 << or
	ntl 3 << 'tl + !
	tp> swap over strcpyl 'tp> !
	1 'ntl +! ;

:tl+ tl+p drop ;

|---------------- estado de la sesion
#sstk * 2048		| pila de la sesion (valores recuperados de mem/repl.out)
#sn 0
#incs * 4096		| includes de la sesion, 32 x 128 ("^r3/lib/math.r3")
#ninc 0 #ninc0 0
#defs * $20000		| texto del proyecto (sin includes)
#defs> 'defs
#defl 0
#dnp * 512		| punteros a nombres definidos
#dnn 0 #dnn0 0
#dnpool * 4096
#dnpool> 'dnpool

|---------------- help table (repl/replhelp.r3) and real libraries (mlibs.r3)

|--- librerias reales: liblist -> 'name 'words 'info  (mlibs.r3, generado por metabuild)
| scanlibs llama 'vec por cada palabra con cw=palabra cl=libreria ci=info
#cw 0 #cl 0 #ci 0 #xvec 0 #xwd 0 #xin 0
#fnd 0 #fcl 0 #fci 0

:scanlibs | 'vec --
	'xvec !
	'liblist ( @+ 1?
		dup @ 'cl !
		dup 8 + @ 'xwd !
		16 + @ 'xin !
		( xwd c@ $ff and 1? drop
			xin c@ $ff and 'ci ! xwd 'cw !
			xvec ex
			xwd >>0 'xwd ! 1 'xin +! )
		drop )
	2drop ;

:iswin? | -- 0/1 ; las de win/ no aplican en linux
	cl "/win/" findstr 0? ( ; ) drop 1 ;

:effinfo | info -- 'str ; info = $80 dato | uso<<4 | delta (4 bits con signo)
	$80 and? ( drop "data" ; )
	dup 4 >> 7 and swap $f and 8 xor 8 - over + swap
	"%d -> %d" sprint ;

#efb * 64
:effbuf | info -- 'efb
	effinfo 'efb strcpy 'efb ;

:btabfind | -- e/0 ; busca 'tk en la tabla base
	'btab ( dup c@ $ff and 1? drop
		dup 'tk = 1? ( drop ; ) drop
		e.next )
	2drop 0 ;

:m.exact
	cw 'tk = 0? ( drop ; ) drop
	iswin? 1? ( drop ; ) drop
	fnd 1? ( drop ; ) drop
	1 'fnd ! cl 'fcl ! ci 'fci ! ;

:libfind | -- 0/1 ; busca 'tk en mlibs
	0 'fnd ! 'm.exact scanlibs fnd ;

|---------------- texto: tokens, includes y nombres
:tok | adr -- adr' ; copies the token to 'tk (copynom), returns the delimiter (>>sp)
	dup 'tk swap copynom >>sp ;

:nextl | adr -- adr' ; start of the next line (>>cr stops AT the CR/LF)
	>>cr c@+ $ff and
	0? ( drop 1- ; )
	13 =? ( drop dup c@ $ff and 10 =? ( drop 1+ ; ) drop ; )
	drop ;

:lkind | adr -- k ; 0 expresion, 1 include, 2 definicion, 3 vacia/comentario
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

:inc+ | "^path" --
	dup inc? 1? ( 2drop ; ) drop
	ninc 31 >=? ( 2drop ; ) drop
	ninc 7 << 'incs + strcpy 1 'ninc +! ;

:dn+ | str -- ; recuerda un nombre definido
	dnn 63 >=? ( 2drop ; ) drop
	dnpool> 'dnpool - 3800 >=? ( 2drop ; ) drop
	dnpool> dup dnn 3 << 'dnp + !
	strcpyl 'dnpool> ! 1 'dnn +! ;

:defined? | -- 0/1 ; 'tk es un nombre definido en la sesion
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

:regnames | adr --
	( trim dup c@ $ff and 1? drop
		tok regtok ) 2drop ;

#inq 0
:qcnt | -- n ; number of quotes in 'tk (findchar)
	0 'tk ( 34 findchar 1? 1+ swap 1+ swap ) drop ;

:tkcheck | -- stop ; token -> include si es palabra de libreria
	qcnt dup inq or swap 1 and inq xor 'inq !
	1? ( drop 0 ; ) drop
	'tk c@ $ff and
	$7c =? ( drop 1 ; )
	$3a =? ( drop 0 ; )
	$23 =? ( drop 0 ; )
	$5e =? ( drop 0 ; )
	$27 =? ( 'tk 1+ 'tk strcpy )
	drop
	'tk c@ 0? ( drop 0 ; ) drop
	'tk isNro 1? ( drop 0 ; ) drop
	defined? 1? ( drop 0 ; ) drop
	btabfind 1? ( drop 0 ; ) drop
	libfind 1? ( fcl "^%s" sprint inc+ ) drop
	0 ;

:scaninc | adr -- ; agrega los includes que necesite la linea
	0 'inq !
	( trim dup c@ $ff and 1? drop
		tok tkcheck
		1? ( nip 'zero swap ) drop )
	2drop ;

:defs+ | str -- ; agrega la linea a las definiciones de la sesion
	defs> 'defs - $1e000 >=? ( 2drop ; ) drop
	defs> strcpyl 1- 13 swap c!+ 10 swap c!+
	0 over c! 'defs> ! 1 'defl +! ;

|---------------- proyectos: repl/proj/<nombre>/<nombre>.r3
#pdir "repl/proj/"
#pname * 64
#ppath * 256
#pfold * 256
#pbuf * $20000
#menubuf * 1024

:setproj | "name" --
	'pname strcpy
	'pname 'pname 'pdir "%s%s/%s.r3" sprint 'ppath strcpy
	'pname 'pdir "%s%s" sprint 'pfold strcpy ;

:mk1 | "path" -- ; creates one folder (no shell: sys on Windows does not run cmd)
|WIN|	0 CreateDirectory drop
|LIN|	$1ff libc-mkdir drop
|MAC|	$1ff libc-mkdir drop
|RPI|	$1ff libc-mkdir drop
	;

:mkproj | creates repl/proj/<name> (each level, existing ones are ignored)
	"repl" mk1 "repl/proj" mk1 'pfold mk1 ;

:proj-clear
	0 'ninc ! 'defs 'defs> ! 0 'defs c! 0 'defl !
	'dnpool 'dnpool> ! 0 'dnn ! ;

:pline | procesa la linea que esta en 'lo2
	'lo2 "| r3repl" =pre nip 1? ( drop ; ) drop
	defl 0? ( 'lo2 trim c@ 0? ( 2drop ; ) drop ) drop
	'lo2 lkind
	1 =? ( drop 'lo2 trim tok drop 'tk inc+ ; )
	2 =? ( 'lo2 regnames )
	drop 'lo2 defs+ ;

:proj-parse | adr -- ; includes y definiciones desde el texto
	proj-clear
	( dup c@ $ff and 1? drop
		dup 'lo2 strcpyln pline
		nextl )
	2drop ;

:proj-load | -- ok
	'ppath filexist 0? ( ; ) drop
	'pbuf 'ppath load 0 swap c!
	'pbuf proj-parse 1 ;

:proj-save
	mark
	'pname "| r3repl - project %s" ,print ,nl
	0 ( ninc <? dup 7 << 'incs + ,s ,nl 1+ ) drop
	,nl
	'defs ,s
	'ppath savemem
	empty
	'ppath filexist 0? ( drop 'ppath "could not save %s  (paths are relative to where r3 runs; mkdir failed?)" sprint 4 tl+ ; ) drop ;

:proj-ensure | crea el proyecto si no existe
	'ppath filexist 1? ( drop ; ) drop
	mkproj proj-clear proj-save ;

:proj-remember
	'pname count "mem/repl.last" save ;

:okch? | c -- 0/1 ; a-z 0-9 _ -
	97 122 in? ( drop 1 ; ) 48 57 in? ( drop 1 ; ) 95 =? ( drop 1 ; ) 45 =? ( drop 1 ; ) drop 0 ;

:namecheck | str -- 0/1
	dup count nip 30 >? ( 2drop 0 ; ) drop
	dup c@ $ff and 0? ( 2drop 0 ; ) drop
	( c@+ $ff and 1? tolow okch? 0? ( 2drop 0 ; ) drop )
	2drop 1 ;

:sanit | str -- ; reemplaza por _ lo que no sea valido
	( dup c@ $ff and 1? tolow okch? 0? ( 95 pick2 c! ) drop 1+ ) 2drop ;

|---------------- generacion y ejecucion (r3 real)
#gk 0 #ga 0 #gl 0 #gboot 0
#t0 0 #tms 0
#obuf * 2064
#ebuf * 4096
#lbuf * $4000
#emsg * 256
#efile * 128
#els 0 #elne 0 #eline 0
#nol 0

:gnl ,nl 1 'gl +! ;

#inboot 0
:bootline? | adr -- 0/1 ; linea que abre una palabra de arranque (: ...)
	c@+ $3a <>? ( 2drop 0 ; ) drop
	c@ $ff and 33 <? ( drop 1 ; ) drop 0 ;

:emit-line 'lo2 ,s gnl ;
:emit-skip "|" ,s gnl ;

:gline | decide que hacer con la linea en 'lo2
	inboot 1? ( drop emit-skip
		'lo2 ";" findstr 1? ( 0 'inboot ! ) drop
		; ) drop
	'lo2 bootline? 0? ( drop emit-line ; ) drop
	1 'inboot !
	emit-skip
	'lo2 ";" findstr 1? ( 0 'inboot ! ) drop ;

:gen-defs | las palabras de arranque del proyecto no se ejecutan en el REPL
	0 'inboot !
	'defs ( dup c@ $ff and 1? drop
		dup 'lo2 strcpyln gline
		nextl ) 2drop ;

:hasdef | "name" -- 0/1 ; is the word defined in the project?
	'tk strcpy defined? ;

:gen-src | adr kind -- ; escribe mem/repl.r3
	'gk ! 'ga !
	mark 0 'gl !
	"^repl/repldump.r3" ,s gnl
	0 ( ninc <? dup 7 << 'incs + ,s gnl 1+ ) drop
	gen-defs
	gk 2 =? ( ga ,s gnl ) drop
	gl 1+ 'gboot !
	": .rbegin " ,s
	gk 0? ( "repl-init" hasdef 1? ( "repl-init " ,s ) drop ) drop
	0 ( sn <? dup 3 << 'sstk + @ "%d " ,print 1+ ) drop
	gk 0? ( ga ,s "repl-done" hasdef 1? ( " repl-done" ,s ) drop ) drop
	" .rdump ;" ,s gnl
	"mem/repl.r3" savemem
	empty ;

:runcmd | runs mem/repl.r3 with output to mem/repl.log
	mark here
|WIN|	"cmd /c ""r3 mem/repl.r3 > mem/repl.log 2>&1 < nul"""
|LIN|	"timeout 20 ./r3lin mem/repl.r3 > mem/repl.log 2>&1 < /dev/null"
|MAC|	"./r3mac mem/repl.r3 > mem/repl.log 2>&1 < /dev/null"
|RPI|	"./r3rpi mem/repl.r3 > mem/repl.log 2>&1 < /dev/null"
	,s 0 ,c
	sys empty ;

:cleanup
	"mem/repl.out" delete "error.log" delete "mem/repl.log" delete ;

:do-run
	cleanup
	msec 't0 !
	runcmd
	.reterm
	msec t0 - 'tms ! ;

|--- lectura de resultados
:rd-file
	0 'efile c!
	'ebuf "FILE:" findstr 0? ( drop ; ) 5 + 'efile swap copynom ;

:rd-line
	0 'eline !
	'ebuf "LINE:" findstr 0? ( drop ; ) 5 + str>nro nip 'eline ! ;

:rd-msg | ultima linea no vacia del log
	'ebuf 'els ! 'ebuf 'elne !
	'ebuf ( c@+ $ff and 1?
		10 =? ( over 'els ! )
		32 >? ( els 'elne ! )
		drop )
	2drop
	elne trim "^- " =pre 1? ( swap 3 + swap ) drop
	'emsg strcpyln ;

:rd-err
	'ebuf "error.log" load 0 swap c!
	rd-file rd-line rd-msg ;

:readdump | -- code ; 0 ok, 2 sin volcado, 3 underflow, 4 pila grande
	'obuf "mem/repl.out" load 'obuf -
	8 <? ( drop 2 ; ) drop
	'obuf @
	-1 =? ( drop 4 ; )
	-2 =? ( drop 3 ; )
	-? ( drop 2 ; )
	dup 255 >? ( 2drop 2 ; ) drop
	dup 'sn !
	0 ( over <? dup 1+ 3 << 'obuf + @ over 3 << 'sstk + ! 1+ ) 2drop
	0 ;

|---------------- stack display format: 0 decimal, 1 hex, 2 fixed point (16.16)
#fmt 0
#fmtn "dec" "hex" "fix" ( 0 )
#ffm "%d " "$%h " "%f " ( 0 )
#sbf "%d    $%h" "$%h    %d" "%f    %d" ( 0 )

:fmtname | -- "name"
	'fmtn fmt n>>0 ;
:fmtstr | -- "fmt "
	'ffm fmt n>>0 ;
:fmtcycle
	fmt 1+ 3 =? ( drop 0 ) 'fmt ! ;

|---------------- dibujo: transcript (se define antes de los pasos)
#ls 0 #lt 0 #ly 0 #i0 0 #i1 0 #vis 0

:r.user
	bg1 3 ly mw 4 - 1 .boxf
	fBl 3 ly .at "▐" .write 
	bg1 fTx 5 ly .at mw 9 - lt lwrite ;
:r.head
	3 ly .at fPr "*  " .write fMu mw 8 - lt lwrite ;
:r.ok
	3 ly .at fGr "  + " .write fMu mw 10 - lt lwrite ;
:r.err
	3 ly .at fRd "  x " .write mw 10 - lt lwrite ;
:r.out
	5 ly .at fPu "▐" .write bg0 fTx .sp mw 12 - lt lwrite ;
:r.note
	3 ly .at fMu "  " .write mw 8 - lt lwrite ;
:r.title
	5 ly .at fPr .Bold mw 10 - lt lwrite .NBold ;
:r.cmd
	3 ly .at fBl "  " .write
	lt ( c@+ $ff and 32 >? .emit ) drop 1-
	fMu mw 16 - swap lwrite ;

:rline | entry y --
	'ly ! dup $ff and swap 8 >> 'lt !
	bg0
	1 =? ( drop r.user ; )
	2 =? ( drop r.head ; )
	3 =? ( drop r.ok ; )
	4 =? ( drop r.err ; )
	5 =? ( drop r.out ; )
	6 =? ( drop r.note ; )
	7 =? ( drop r.title ; )
	8 =? ( drop r.cmd ; )
	drop ;

:drawlines
	py 3 - 'vis !
	ntl vis - scroll - 0 max dup 'i0 !
	vis + ntl min 'i1 !
	i0 ( i1 <?
		dup 3 << 'tl + @
		over i0 - 3 +
		rline
		1+ ) drop ;

:drawhead
	bg0 fDi 3 2 .at 45 mw 4 - .nch
	3 1 .at fPr .Bold "# " .write fTx "r3repl" .write .NBold
	fMu "  -  " .write 'pname .write
	fMu mw 20 - 1 .at 18 fmtname sn "stack %d  [%s]" sprint rwrite ;

|---------------- dibujo: sidebar
#sx 0 #sy 0

:sline | "txt" --
	sx sy .at .write 1 'sy +! ;

:sec | "titulo" --
	1 'sy +!
	fPr .Bold sline .NBold ;

:sstack
	"Stack" sec
	sn 0? ( fDi "(empty)" sline ) drop
	0 ( sn <? 8 <?
		fMu sn 1- over - 3 << 'sstk + @ dup 'sbf fmt n>>0 sprint
		sline 1+ ) drop ;

:sdefs
	"Definitions" sec
	dnn 0? ( fDi "(none)" sline ) drop
	0 ( dnn <? 6 <?
		fMu dup 3 << 'dnp + @ "> %s" sprint sline
		1+ ) drop ;

:slibs
	"Libraries" sec
	fGr sx sy .at "*" .write fMu " base" .write 1 'sy +!
	ninc 0? ( fDi "  + added as needed" sline ) drop
	0 ( ninc <? 6 <?
		fGr sx sy .at "*" .write fMu " " .write
		dup 7 << 'incs + 4 + sw 6 - swap lwrite 1 'sy +!
		1+ ) drop ;

:sinfo
	"r3" sec
	fMu "real execution" sline
	fMu "mem/repl.r3  mem/repl.out" sline ;

:drawside
	sw 0? ( drop ; ) drop
	bg1 mw 1+ 1 sw rows 1- .boxf
	mw 3 + 'sx ! 2 'sy !
	fTx .Bold "r3repl" sline .NBold
	fMu 'pname "project %s" sprint sline
	sstack sdefs slibs sinfo ;

|---------------- autocompletado
#pwd * 128
#pn 0
#psel 0
#wst 0
#inp * 256
#cur 0
#nc 0 #tmpr 0
#recs * 16384
#cp * 4096
#prw * 768

:inplen 'inp count nip ;

:ch@ | i -- c
	-? ( drop 0 ; ) 'inp + c@ $ff and ;

:wstart | -- i
	cur ( dup 1- ch@ 32 >? drop 1- ) drop ;

| candidato = 4 qwords: kind(0 base/cmd, 1 libreria) eff|info libreria nombre
:cadd | name lib eff kind --
	nc 500 >=? ( 4drop ; ) drop
	nc 5 << 'recs + dup nc 3 << 'cp + !
	>a a!+ a!+ a!+ a!+
	1 'nc +! ;

:btadd | e --
	'pwd =pre 0? ( 2drop ; ) drop
	dup e.lib over e.eff 0 cadd ;

:m.pre
	cw 'pwd =pre nip 0? ( drop ; ) drop
	iswin? 1? ( drop ; ) drop
	cw cl ci 1 cadd ;

:r.name 24 + @ ;
:r.lib 16 + @ ;
:r.eff@ | rec -- 'str
	dup 8 + @ swap @ 1? ( drop effinfo ; ) drop ;

:cgt | j -- 0/1 ; cp[j-1] > tmp ?
	0? ( ; )
	1- 3 << 'cp + @ r.name tmpr r.name cmpstr
	0? ( drop 0 ; ) +? ( drop 1 ; ) drop 0 ;

:csort
	1 ( nc <?
		dup 3 << 'cp + @ 'tmpr !
		dup ( dup cgt 1? drop
			dup 1- 3 << 'cp + @ over 3 << 'cp + !
			1- )
		drop
		tmpr swap 3 << 'cp + !
		1+ ) drop ;

:fillrow | k --
	dup 3 << 'cp + @
	over 7 << 'prw + 'pe !
	dup r.name pe strcpy
	dup r.eff@ pe 32 + strcpy
	r.lib pe 72 + strcpy
	drop ;

:gather
	0 'nc !
	'btab ( dup c@ $ff and 1? drop dup btadd e.next ) 2drop
	'm.pre scanlibs
	csort ;

:hide? | -- 1/0 ; palabras de 1 letra no abren popup (salvo / y .)
	'pwd 1+ c@ $ff and 1? ( drop 0 ; ) drop
	'pwd c@ $ff and $2f =? ( drop 0 ; ) $2e =? ( drop 0 ; ) drop 1 ;

:popup!
	0 'pn ! 0 'psel !
	wstart 'wst !
	'pwd >a
	wst ( cur <? dup 'inp + c@ ca!+ 1+ ) drop
	0 ca!
	'pwd c@ 0? ( drop ; ) drop
	'pwd isNro 1? ( drop ; ) drop
	hide? 1? ( drop ; ) drop
	gather
	nc 6 min 'pn !
	0 ( pn <? dup fillrow 1+ ) drop ;

:accept
	pn 0? ( drop ; ) drop
	'inp cur + 'tmp strcpy
	psel 7 << 'prw + 'inp wst + strcpyl
	1- 32 swap c!+
	dup 'inp - 'cur !
	'tmp swap strcpy ;

|---------------- entrada de texto
:kins | c --
	inplen 200 >=? ( 2drop ; ) drop
	inplen
	( cur >=?
		dup 'inp + dup c@ swap 1+ c!
		1- )
	drop
	'inp cur + c! 1 'cur +! ;

:kbks
	cur 0? ( drop ; ) drop
	cur 1-
	( dup 'inp + dup 1+ c@ swap c!
		dup 'inp + c@ $ff and 1? drop
		1+ )
	2drop -1 'cur +! ;

:kdel
	'inp cur + c@ 0? ( drop ; ) drop
	1 'cur +! kbks ;

|---------------- dibujo: prompt, popup, footer
:drawprompt
	0 ( 4 <?
		fBl px py pick2 + .at "▐" .write
		bg2 px 1+ py pick2 + pw 1- 1 .boxf
		1+ ) drop
	bg2 px 3 + py 1+ .at
	inplen 0? ( fDi "Type an R3Forth expression  (e.g. 2 3 + dup *)" .write )
	1? ( fTx pw 5 - 'inp lwrite ) drop
	bg2 px 3 + py 2 + .at
	|fBl .Bold "Repl" .write .NBold fMu "  r3" .write 
	bg0 ;

:pbg | i -- ; fondo segun seleccion
	psel =? ( drop bg3 ; ) drop bg1 ;
:pc | i -- ; color del nombre
	psel =? ( drop fPr ; ) drop fTx ;

:prow | i --
	dup pbg
	dup 7 << 'prw + 'pe !
	dup pn - py + 'ry !
	px ry pw 1 .boxf
	dup pc
	px 2 + ry .at pe .write
	fMu px 19 + ry .at pw 48 - pe 32 + lwrite
	fDi px pw + 28 - ry .at 26 pe 72 + rwrite
	drop ;

:drawpopup
	pn 0? ( drop ; ) drop
	0 ( pn <? dup prow 1+ ) drop ;

#spin "|" "/" "-" "\" ( 0 )

:drawfoot
	bg0 1 rows cols 1 .boxf
	2 rows .at
	busy 1? ( fPr 'spin sf 4 mod n>>0 .write fMu " running r3..." .write 1 'sf +! )
	0? ( fDi "~/r3" .write ) drop
	cols 74 >=? ( fDi cols 68 - rows .at 66 "ctrl+c quit   tab complete   / commands   ^f format   ^t terminal  " rwrite ) drop ;

:drawcommon
	drawpopup drawfoot
	px 3 + cur + py 1+ .at .showc .flush ;

|---------------- dibujo: pantallas
:drawlogo | y -- ; big chars (utfg .awrite), 4 filas, avance 7 columnas
	cols 43 - 2/ 1+ swap .at
	"[01R[023[03f[04o[05r[06t[07h" .awrite
	bg0 fTx ;

:draw-home
	cols 6 - 72 min 'pw ! cols pw - 2/ 1+ 'px ! rows 2/ 'py !
	py 9 - drawlogo
	fMu 1 py 4 - .at cols "interactive R3Forth environment" cwrite
	fMu 1 py 3 - .at cols 'pname "project: %s" sprint cwrite
	drawprompt
	fTx px py 6 + .at "tab" .write fDi " complete     " .write
	fTx "/words" .write fDi " search     " .write
	fTx "/help" .write fDi " commands" .write
	fYe px py 8 + .at "* Tip  " .write fMu "try  2 3 + dup *   then   :sq dup * ;   and   5 sq" .write
	drawcommon ;

:draw-sess
	mw 4 - 'pw ! 3 'px ! rows 6 - 'py !
	drawhead drawlines drawside drawprompt
	drawcommon ;

:draw
	layout
	.hidec bg0 fTx .cls
	ntl 0? ( drop draw-home ; ) drop
	draw-sess ;

|---------------- evaluacion real
:tstep | "txt" style --
	tl+ 1 'busy ! draw 60 ms ;

:stack$ | -- 'str ; stack text in the current format (valid until the next write to here)
	mark
	"[ " ,s
	sn 12 - 0 max ( sn <? dup 3 << 'sstk + @ fmtstr ,print 1+ ) drop
	"]" ,s ,eol
	memsize drop empty ;

#nolm 14 #nols 5
:showlbuf | style max -- ; vuelca las lineas de 'lbuf al transcript
	'nolm ! 'nols ! 0 'nol !
	'lbuf ( dup c@ $ff and 1? drop
		dup 'lo2 strcpyln
		'lo2 c@ 1? ( 'lo2 nols tl+ 1 'nol +! ) drop
		nextl
		nol nolm >=? ( nip 'zero swap ) drop )
	2drop ;

:outlines | muestra la salida del programa (mem/repl.log)
	'lbuf "mem/repl.log" load 0 swap c!
	'lbuf "r3vm - PHREDA" findstr dup 1? ( 0 over c! ) 2drop
	5 14 showlbuf ;

:show-err
	rd-err
	'emsg "error: %s" sprint 4 tstep
	eline 0? ( drop ; ) drop
	'efile "mem/repl.r3" =
	0? ( drop eline 'efile "in %s  line %d" sprint 6 tstep ; ) drop
	eline gboot =? ( drop "in your line" 6 tstep ; )
	1+ 'pname "in project %s  line %d" sprint 6 tstep ;

:fail | -- ; descarta lo agregado en esta linea
	ninc0 'ninc ! 0 'busy ! "" 0 tstep ;

:okpaso | muestra los includes nuevos
	ninc0 ( ninc <?
		dup 7 << 'incs + "include      %s" sprint 3 tstep
		1+ ) drop ;

:prep | -- ok ; kind 1: valida e incluye ; otros: includes automaticos
	gk
	1 =? ( drop
		ga trim tok drop
		'tk 1+ filexist 0? ( drop "file not found" 4 tstep "" 0 tstep 0 ; ) drop
		'tk inc+ 1 ; )
	2 =? ( drop
		ga trim bootline? 1? ( drop "boot words (: ...) are edited with /edit" 4 tstep "" 0 tstep 0 ; ) drop
		ga scaninc 1 ; )
	drop ga scaninc 1 ;

:real-eval | adr --
	dup 'ga ! lkind 'gk !
	gk 3 =? ( drop ; ) drop
	ninc 'ninc0 !
	prep 0? ( drop ; ) drop
	"r3repl  -  r3" 2 tstep
	ga gk gen-src
	gl "generate     mem/repl.r3  -  %d lines" sprint 3 tstep
	do-run
	"error.log" filexist 1? ( drop show-err fail ; ) drop
	readdump
	2 =? ( drop "r3 did not produce the stack dump (execution failed)" 4 tstep outlines fail ; )
	3 =? ( drop "stack underflow: the line consumes more values than available" 4 tstep outlines fail ; )
	4 =? ( drop "stack too large (more than 255 values)" 4 tstep outlines fail ; )
	drop
	okpaso
	tms "run          r3  -  %d ms" sprint 3 tstep
	outlines
	gk 2 =? (
		dnn 'dnn0 !
		ga defs+ ga regnames
		dnn0 ( dnn <? dup 3 << 'dnp + @ "defined      %s" sprint 3 tstep 1+ ) drop ) drop
	gk 0 <>? ( proj-save ) drop
	ninc ninc0 <>? ( proj-save ) drop
	0 'busy !
	stack$ 5 tstep
	"" 0 tstep ;

|---------------- comandos
:cmd-help
	"Commands" 7 tl+
	"/words txt  search words (base + mlibs)" 8 tl+
	"/lib word   which library to include" 8 tl+
	"/stack      show the stack        /reset  clear the stack" 8 tl+
	"/fmt [dec|hex|fix]  stack format (no arg: cycle; also ctrl+f)" 8 tl+
	"/term       show the output terminal of the last run (also ctrl+t)" 8 tl+
	"/src        show the generated program" 8 tl+
	"/save       save the project (also saved when code is added)" 8 tl+
	"/new name   new project           /load name  open one" 8 tl+
	"/proj       list projects" 8 tl+
	"/open file  new project from a code in r3/" 8 tl+
	"/find txt   search codes in r3/" 8 tl+
	"/init [code|off]  hook run before each line (e.g. graphics setup)" 8 tl+
	"/done [code|off]  hook run after each line (e.g. wait, quit)" 8 tl+
	"/edit       edit the project (r3ide, F5 debugs)   /run  launch it" 8 tl+
	".rs         inside any code: prints the stack and keeps it" 8 tl+
	"/clear      clear the screen history   /exit  quit" 8 tl+
	"" 0 tl+ ;

#carg 0 #ntk 0

:wline | e --
	dup e.lib over e.eff rot "%s  %s  %s" sprint 8 tstep ;

:wtry | e --
	dup carg findstri 0? ( 2drop ; ) drop
	1 'ntk +!
	ntk 12 >? ( 2drop ; ) drop
	wline ;

:m.wlib
	cw carg findstri 0? ( drop ; ) drop
	iswin? 1? ( drop ; ) drop
	1 'ntk +!
	ntk 12 >? ( drop ; ) drop
	ci effbuf cl cw "%s  ^%s  %s" sprint 8 tstep ;

:cmd-words | arg --
	trim 'carg !
	carg c@ 0? ( drop
		"base + mlibs.r3 libraries  -  /lib word  shows the include" 6 tstep
		"/words dup   to search" 6 tstep
		"" 0 tstep ; ) drop
	0 'ntk !
	'btab ( dup c@ $ff and 1? drop dup wtry e.next ) 2drop
	'm.wlib scanlibs
	ntk 0? ( "no results" 6 tstep ) drop
	ntk 12 >? ( "..." 6 tstep ) drop
	"" 0 tstep ;

:m.libline
	cw 'tk = 0? ( drop ; ) drop
	iswin? 1? ( drop ; ) drop
	1 'fnd +!
	ci effbuf cl cw "%s  ^%s  %s" sprint 8 tstep ;

:cmd-lib | arg --
	trim tok drop
	'tk c@ 0? ( drop "usage: /lib word" 6 tstep ; ) drop
	btabfind 1? ( e.eff 'tk "%s  base  %s  -  no include needed" sprint 8 tstep "" 0 tstep ; ) drop
	0 'fnd !
	'm.libline scanlibs
	fnd 0? ( "not found in base or mlibs.r3" 4 tstep ) drop
	"" 0 tstep ;

:cmd-src | the program every line is compiled with (rebuilt from the current project)
	"" 1 gen-src
	'lbuf "mem/repl.r3" load 0 swap c!
	6 60 showlbuf
	"" 0 tl+ ;

:cmd-clear
	0 'ntl ! 'tp 'tp> ! 0 'scroll ! ;

:cmd-reset
	0 'sn !
	"stack cleared" 6 tstep "" 0 tstep ;

|---------------- comandos de proyecto
#ofile * 256
#bp 0

:switched | despues de cambiar de proyecto
	0 'sn ! proj-remember ;

:pinfo
	dnn ninc 'pname "project %s  -  %d includes, %d definitions" sprint 6 tl+
	"" 0 tl+ ;

:ls-proj
|WIN|	"cmd /c ""dir /b repl\proj > mem/repl.ls 2>nul"""
|LIN|	"ls -1 repl/proj > mem/repl.ls 2>/dev/null"
|MAC|	"ls -1 repl/proj > mem/repl.ls 2>/dev/null"
|RPI|	"ls -1 repl/proj > mem/repl.ls 2>/dev/null"
	sys ;

:cmd-proj
	"Projects" 7 tl+
	ls-proj
	'lbuf "mem/repl.ls" load 0 swap c!
	8 14 showlbuf
	'pname "current: %s" sprint 6 tl+
	"" 0 tl+ ;

:cmd-save
	proj-save
	'ppath "saved to %s" sprint 6 tl+
	"" 0 tl+ ;

:cmd-new | arg --
	trim tok drop
	'tk namecheck 0? ( drop "invalid name (a-z 0-9 _ -, up to 30)" 4 tl+ "" 0 tl+ ; ) drop
	'tk 'tk 'pdir "%s%s/%s.r3" sprint filexist 1? ( drop "already exists: /load name" 4 tl+ "" 0 tl+ ; ) drop
	'tk setproj mkproj proj-clear proj-save switched
	pinfo ;

:cmd-load | arg --
	trim tok drop
	'tk c@ 0? ( drop cmd-proj ; ) drop
	'tk 'tk 'pdir "%s%s/%s.r3" sprint filexist 0? ( drop "no such project (/proj lists them)" 4 tl+ "" 0 tl+ ; ) drop
	'tk setproj proj-load drop switched
	pinfo ;

:tryf | "fmt" -- 0/1 ; prueba una ruta candidata para 'tk
	'tk swap sprint
	dup filexist 0? ( 2drop 0 ; ) drop
	".r3" =pos 0? ( 2drop 0 ; ) drop
	'ofile strcpy 1 ;

:resolve | arg -- 0/1 ; 'ofile = archivo .r3 encontrado
	trim tok drop
	'tk c@ 0? ( drop 0 ; ) drop
	"%s" tryf 1? ( ; ) drop
	"r3/%s" tryf 1? ( ; ) drop
	"%s.r3" tryf 1? ( ; ) drop
	"r3/%s.r3" tryf ;

:basename | -- ; 'tk = nombre del archivo sin ruta ni .r3
	'ofile 'bp !
	'ofile ( c@+ $ff and 1? $2f =? ( over 'bp ! ) $5c =? ( over 'bp ! ) drop ) 2drop
	bp 'tk strcpy
	'tk ".r3" findstr dup 1? ( 0 over c! ) 2drop
	'tk sanit ;

:cmd-open | arg --
	resolve 0? ( drop "file not found (/find text)" 4 tl+ "" 0 tl+ ; ) drop
	basename
	'tk namecheck 0? ( drop "invalid project name" 4 tl+ "" 0 tl+ ; ) drop
	'tk 'tk 'pdir "%s%s/%s.r3" sprint filexist 1? ( drop "a project with that name already exists (/load)" 4 tl+ "" 0 tl+ ; ) drop
	'tk setproj mkproj
	'pbuf 'ofile load 0 swap c!
	'pbuf proj-parse
	proj-save switched
	'ofile "base code: %s" sprint 6 tl+
	pinfo ;

:cmd-find | arg --
	trim tok drop
	'tk c@ 0? ( drop "usage: /find text" 6 tl+ "" 0 tl+ ; ) drop
	'tk
|WIN|	"cmd /c ""dir /s /b r3\*%s*.r3 > mem/repl.ls 2>nul"""
|LIN|	"find r3 -iname ""*%s*.r3"" | sort > mem/repl.ls 2>/dev/null"
|MAC|	"find r3 -iname ""*%s*.r3"" | sort > mem/repl.ls 2>/dev/null"
|RPI|	"find r3 -iname ""*%s*.r3"" | sort > mem/repl.ls 2>/dev/null"
	sprint sys
	'lbuf "mem/repl.ls" load 0 swap c!
	'lbuf c@ 0? ( drop "no results" 6 tl+ "" 0 tl+ ; ) drop
	8 14 showlbuf
	"/open path   opens it as a project" 6 tl+
	"" 0 tl+ ;

:runerr | muestra error.log como main.r3
	"error.log" filexist 0? ( drop ; ) drop
	'ebuf "error.log" load 0 swap c!
	.cr .bred .white " * ERROR * " .write .reset .cr
	'ebuf .write .cr
	"error.log" delete ;

:cmd-run
	proj-save
	.masb .reset .cls .flush
	'ppath r3run
	.reterm
	runerr
	.cr " -- done, press any key --" .write .flush
	waitkey
	.alsb .flush
	"project launched" 6 tl+ "" 0 tl+ ;

:cmd-edit
	proj-save
	'ppath 'menubuf strcpy
	'menubuf 1024 "mem/menu.mem" save
	.masb .flush
	"r3/d4/r3ide.r3" r3run
	.reterm .alsb .flush
	proj-load drop
	pinfo ;

:names-rebuild | rebuilds the defined-names list from the project text
	0 'dnn ! 'dnpool 'dnpool> !
	'defs ( dup c@ $ff and 1? drop
		dup 'lo2 strcpyln 'lo2 lkind 2 =? ( 'lo2 regnames ) drop
		nextl ) 2drop ;

#delp 0
:keepline | appends 'lo2 to the project unless it starts with delp
	'lo2 delp =pre nip 1? ( drop ; ) drop 'lo2 defs+ ;

:defs-del | "prefix" -- ; removes the lines that start with prefix
	'delp !
	'defs 'pbuf strcpy
	'defs 'defs> ! 0 'defs c! 0 'defl !
	'pbuf ( dup c@ $ff and 1? drop
		dup 'lo2 strcpyln keepline nextl ) 2drop ;

#hname 0
#pfx * 64
:hook-show
	0 'fnd !
	'defs ( dup c@ $ff and 1? drop
		dup 'lo2 strcpyln
		'lo2 'pfx =pre nip 1? ( 'lo2 6 tl+ 1 'fnd ! ) drop
		nextl ) 2drop
	fnd 0? ( "(none)" 6 tl+ ) drop ;

:hook-check | -- ok ; compiles the project (no hooks, no line) to validate it
	"" 1 gen-src do-run
	"error.log" filexist 1? ( drop show-err 0 ; ) drop 1 ;

:hook-cmd | arg "name" -- ; /init and /done: one-line hook definition in the project
	'hname !
	hname ":%s " sprint 'pfx strcpy
	trim
	dup c@ 0? ( 2drop hook-show "" 0 tl+ ; ) drop
	"off" over = 1? ( 2drop 'pfx defs-del names-rebuild proj-save "hook removed" 6 tl+ "" 0 tl+ ; ) drop
	ninc 'ninc0 !
	'pfx defs-del
	hname ":%s %s ;" sprint 'lo2 strcpy
	'lo2 scaninc 'lo2 defs+
	names-rebuild
	hook-check 0? ( drop 'pfx defs-del names-rebuild ninc0 'ninc ! "hook rejected" 6 tl+ "" 0 tl+ ; ) drop
	proj-save hook-show "" 0 tl+ ;

:showfmt
	fmtname "format: %s" sprint 6 tl+
	stack$ 5 tl+
	"" 0 tl+ ;

:cmd-fmt | arg --
	trim tok drop
	'tk c@ 0? ( drop fmtcycle showfmt ; ) drop
	"dec" 'tk = 1? ( drop 0 'fmt ! showfmt ; ) drop
	"hex" 'tk = 1? ( drop 1 'fmt ! showfmt ; ) drop
	"fix" 'tk = 1? ( drop 2 'fmt ! showfmt ; ) drop
	"fixed" 'tk = 1? ( drop 2 'fmt ! showfmt ; ) drop
	"usage: /fmt dec|hex|fix" 4 tl+ "" 0 tl+ ;

:cmd-term | shows the output terminal of the last run (raw, in the normal screen)
	'lbuf "mem/repl.log" load 0 swap c!
	'lbuf "r3vm - PHREDA" findstr dup 1? ( 0 over c! ) 2drop
	.masb .reset .cls .flush
	'lbuf c@ 0? ( " (no output yet)" .write ) drop
	'lbuf .write
	.cr .cr " -- end of output, press any key --" .write .flush
	waitkey
	.alsb .flush ;

:docmd | adr --
	"/help" over = 1? ( 2drop cmd-help ; ) drop
	"/words" over = 1? ( drop >>sp cmd-words ; ) drop
	"/lib" over = 1? ( drop >>sp cmd-lib ; ) drop
	"/stack" over = 1? ( 2drop stack$ 5 tstep "" 0 tstep ; ) drop
	"/fmt" over = 1? ( drop >>sp cmd-fmt ; ) drop
	"/init" over = 1? ( drop >>sp "repl-init" hook-cmd ; ) drop
	"/done" over = 1? ( drop >>sp "repl-done" hook-cmd ; ) drop
	"/term" over = 1? ( 2drop cmd-term ; ) drop
	"/src" over = 1? ( 2drop cmd-src ; ) drop
	"/save" over = 1? ( 2drop cmd-save ; ) drop
	"/new" over = 1? ( drop >>sp cmd-new ; ) drop
	"/load" over = 1? ( drop >>sp cmd-load ; ) drop
	"/proj" over = 1? ( 2drop cmd-proj ; ) drop
	"/open" over = 1? ( drop >>sp cmd-open ; ) drop
	"/find" over = 1? ( drop >>sp cmd-find ; ) drop
	"/edit" over = 1? ( 2drop cmd-edit ; ) drop
	"/run" over = 1? ( 2drop cmd-run ; ) drop
	"/clear" over = 1? ( 2drop cmd-clear ; ) drop
	"/reset" over = 1? ( 2drop cmd-reset ; ) drop
	"/exit" over = 1? ( 2drop 1 'quit ! ; ) drop
	drop "unknown command  -  /help" 4 tstep "" 0 tstep ;

|---------------- historial (no se guarda con el proyecto)
#hist * 8192
#hn 0 #hp 0

:hslot | n -- adr
	31 and 8 << 'hist + ;

:hist+ | str --
	hn hslot strcpy 1 'hn +! 0 'hp ! ;

:hist-save
	mark
	hn 32 - 0 max ( hn <? dup hslot ,s ,nl 1+ ) drop
	"mem/repl.hist" savemem
	empty ;

:hist-load
	'pbuf "mem/repl.hist" load 0 swap c!
	'pbuf ( dup c@ $ff and 1? drop
		dup 'lo2 strcpyln
		'lo2 255 + 0 swap c!
		'lo2 c@ 1? ( 'lo2 hist+ ) drop
		nextl )
	2drop 0 'hp ! ;

:hup | recorre el historial hacia atras
	hp 1+ dup hn >? ( 2drop ; ) drop
	dup 32 >? ( 2drop ; ) drop
	dup 'hp !
	hn swap - hslot 'inp strcpy inplen 'cur ! popup! ;

:hdn
	hp 0? ( drop ; ) drop
	hp 1- dup 'hp !
	0? ( drop 0 'inp c! 0 'cur ! popup! ; )
	hn swap - hslot 'inp strcpy inplen 'cur ! popup! ;

:proj-boot | abre el ultimo proyecto (o scratch)
	'pbuf "mem/repl.last" load 0 swap c!
	'tk 'pbuf trim copynom
	'tk namecheck 0? ( "scratch" 'tk strcpy ) drop
	'tk setproj proj-ensure proj-load drop proj-remember
	hist-load ;

|---------------- entrada de teclado
:fin
	0 'busy ! popup! ;

:submit
	inplen 0? ( drop ; ) drop
	'inp hist+ hist-save
	0 'scroll !
	'inp 1 tl+p
	0 'inp c! 0 'cur ! 0 'pn !
	dup c@ $ff and $2f =? ( drop docmd fin ; ) drop
	real-eval fin ;

:clampscroll
	scroll ntl rows 8 - - 0 max min 0 max 'scroll ! ;

:onkey | key --
	[esc] =? ( drop 0 'pn ! ; )
	12 =? ( drop cmd-clear ; )
	6 =? ( drop fmtcycle ; )
	20 =? ( drop cmd-term ; )
	[enter] =? ( drop submit ; )
	[back] =? ( drop kbks popup! ; )
	[del] =? ( drop kdel popup! ; )
	[le] =? ( drop cur 1? ( -1 'cur +! ) drop popup! ; )
	[ri] =? ( drop cur inplen <? ( 1 'cur +! ) drop popup! ; )
	[home] =? ( drop 0 'cur ! popup! ; )
	[end] =? ( drop inplen 'cur ! popup! ; )
	[tab] =? ( drop accept popup! ; )
	[up] =? ( drop pn 1? ( drop psel 1- 0 max 'psel ! ; ) drop hup ; )
	[dn] =? ( drop pn 1? ( drop psel 1+ pn 1- min 'psel ! ; ) drop hdn ; )
	[pgup] =? ( drop 5 'scroll +! clampscroll ; )
	[pgdn] =? ( drop -5 'scroll +! clampscroll ; )
	32 126 in? ( kins popup! ; )
	$3 =? ( 1+ ) $4 =? ( 1 'quit ! ) | ctrl+c +d
	drop ;

:main
	proj-boot
	.alsb
	( quit 0? drop
		draw getch onkey
		) drop
	.masb .showc .Reset .flush ;

: main ;
