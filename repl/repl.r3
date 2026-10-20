| r3repl - REPL environment for R3Forth   (folder repl/)    TUI version (util/tui.r3)
| A session = a project: repl/proj/<n>/<n>.r3 (scratch by default).
| Each line is generated as a program (mem/repl.r3) and run with r3.
| The stack is recovered with the internal library repl/repldump.r3 (mem/repl.out).
| There is no interpreter in the REPL: r3lin runs everything.
|   replcore.r3  session and project (includes, definitions, files)
|   replgen.r3   generation and execution of the program
|   repl.r3      screen, commands and keys (layout and colors from util/tui.r3)
^r3/util/tui.r3
^repl/replhelp.r3
^repl/replcore.r3
^repl/replgen.r3
^repl/replchk.r3
^repl/replmodel.r3

|---------------- variables
#sw 0
#px 0 #py 0 #pw 0 #ptw 40		| prompt frame
#tmp * 256
#pe 0
#busy 0 #sf 0 #zero 0
#fnd 0
#nol 0
#bk 0 #bkn 0		| definicion de varias lineas en curso, lineas ingresadas
#bkb * 4096 #bkb> 0	| texto de la definicion (lineas separadas por 13)
#bkd 0 #bks 0 #bksm 0 #bkcm 0 #bktl 0 #bktc 0 #bkc 0 #bkk 0

|---------------- utilidades de pantalla
:layout
|LIN|	.getterminfo
	0 'sw ! cols 100 >=? ( 34 'sw ! ) drop ;

|---------------- transcript
#tp 0
#tp> 0
#tl * $2000
#ntl 0
#scroll 0

:tl+p | "txt" style -- 'guardado
	ntl 1000 >=? ( 0 'ntl ! tp 'tp> ! ) drop
	tp> tp - $1f000 >? ( 0 'ntl ! tp 'tp> ! ) drop
	tp> 8 << or
	ntl 3 << 'tl + !
	tp> swap over strcpyl 'tp> !
	1 'ntl +! ;

:tl+ tl+p drop ;

:lnb "" 0 tl+ ;			| linea en blanco
:lne 4 tl+ lnb ;		| error + blanco
:lnn 6 tl+ lnb ;		| nota + blanco

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


|---------------- dibujo: transcript (frame: x y w h of the zone)
#lt 0 #i0 0 #i1 0 #vis 0

:bar | -- ; marcador de linea (glifo basico; "|" para ASCII puro)
	"▌" .write ;

:r.user
	bg1 fx .col fw .ndel
	fBl bar bg1 fTx .sp fw 5 - lt lwrite ;
:r.cont
	bg1 fx .col fw .ndel
	fPr bar bg1 fTx .sp fw 5 - lt lwrite ;
:r.head
	fPr "*  " .write fMu fw 4 - lt lwrite ;
:r.ok
	fGr "  + " .write fMu fw 6 - lt lwrite ;
:r.err
	fRd "  x " .write fw 6 - lt lwrite ;
:r.out
	.sp .sp fPu bar bg0 fTx .sp fw 8 - lt lwrite ;
:r.note
	fMu "  " .write fw 4 - lt lwrite ;
:r.title
	.sp .sp fPr .Bold fw 6 - lt lwrite .NBold ;
:r.cmd
	fBl "  " .write
	lt ( c@+ $ff and 32 >? .emit ) drop 1-
	fMu fw 12 - swap lwrite ;

:rowt | i --
	i0 + i1 >=? ( drop ; )
	3 << 'tl + @
	dup $ff and swap 8 >> 'lt !
	bg0
	1 =? ( drop r.user ; )
	2 =? ( drop r.head ; )
	3 =? ( drop r.ok ; )
	4 =? ( drop r.err ; )
	5 =? ( drop r.out ; )
	6 =? ( drop r.note ; )
	7 =? ( drop r.title ; )
	8 =? ( drop r.cmd ; )
	9 =? ( drop r.cont ; )
	drop ;

:drawlines
	fh 'vis !
	ntl vis - scroll - 0 max dup 'i0 !
	vis + ntl min 'i1 !
	fhome 'rowt vis .lines ;

:drawhead
	fhome bg0 fPr .Bold "# " .write fTx "r3repl" .write .NBold
	fMu "  -  " .write 'pname .write
	fx fw + 19 - .col fMu 18 fmtname sn "stack %d  [%s]" sprint rwrite fcr
	fDi fw 45 .nch ;

|---------------- dibujo: sidebar (frame: right zone)
:sec | "titulo" --
	fcr fPr .Bold .lw .NBold ;

:bul | "txt" --
	fGr "*" .write fMu .sp fw 2 - swap lwrite fcr ;

:sstack
	"Stack" sec
	sn 0? ( fDi "(empty)" .lw ) drop
	0 ( sn <? 8 <?
		fMu sn 1- over - 3 << 'sstk + @ dup 'sbf fmt n>>0 sprint
		.lw 1+ ) drop ;

:sdefs
	"Definitions" sec
	m.ready
	m.count 0? ( fDi "(none)" .lw ) drop
	0 ( m.count <? 6 <?
		fMu dup m.name "> %s" sprint .lw
		1+ ) drop ;

:slibs
	"Libraries" sec
	"base" bul
	ninc 0? ( fDi "  + added as needed" .lw ) drop
	0 ( ninc <? 6 <?
		dup 7 << 'incs + 4 + bul
		1+ ) drop ;

:sinfo
	"r3" sec
	fMu "real execution" .lw
	fMu "mem/repl.r3  mem/repl.out" .lw ;

:drawside
	bg1 .wfill 2 1 flpad fhome
	fTx .Bold "r3repl" .lw .NBold
	fMu 'pname "project %s" sprint .lw
	sstack sdefs slibs sinfo ;

|---------------- autocompletado
#pwd * 128
#pn 0
#psel 0 #poff 0 #ph 0
#wst 0
#inp * 256
#cur 0
#nc 0 #tmpr 0
#recs 0
#cp * 4096
#prw * 768

:inplen 'inp count nip ;

:ch@ | i -- c
	-? ( drop 0 ; ) 'inp + c@ $ff and ;

:wstart | -- i
	cur ( dup 1- ch@ 32 >? drop 1- ) drop ;

| candidato = 4 qwords: kind(0 comando: eff = args, 1 palabra: eff = efecto) eff libreria nombre
:cadd | name lib eff kind --
	nc 500 >=? ( 4drop ; ) drop
	nc 5 << recs + dup nc 3 << 'cp + !
	>a a!+ a!+ a!+ a!+
	1 'nc +! ;

:ctadd | e --
	'pwd =pre 0? ( 2drop ; ) drop
	dup e.lib over e.arg 0 cadd ;

:m.pre | -- stop
	'pwd wpre 0? ( ; ) drop
	cw cl ce 1 cadd 0 ;

:r.name 24 + @ ;
:r.lib 16 + @ ;
:r.eff@ | rec -- 'str
	dup 8 + @ swap @ 1? ( drop effstr ; ) drop ;

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
	over poff - 7 << 'prw + 'pe !
	dup r.name pe strcpy
	dup r.eff@ pe 32 + strcpy
	r.lib pe 72 + strcpy
	drop ;

:gather
	0 'nc !
	'ctab ( dup c@ $ff and 1? drop dup ctadd e.next ) 2drop
	'm.pre scanwords drop
	csort ;

:hide? | -- 1/0 ; palabras de 1 letra no abren popup (salvo / y .)
	'pwd 1+ c@ $ff and 1? ( drop 0 ; ) drop
	'pwd c@ $ff and $2f =? ( drop 0 ; ) $2e =? ( drop 0 ; ) drop 1 ;

:refill | llena las filas visibles desde poff
	0 ( pn <? dup poff + fillrow 1+ ) drop ;

:selvis | mantiene psel dentro de la ventana
	psel poff <? ( psel 'poff ! ) drop
	psel poff pn + >=? ( psel pn - 1+ 'poff ! ) drop
	refill ;

:popup!
	0 'pn ! 0 'psel ! 0 'poff !
	wstart 'wst !
	'pwd >a
	wst ( cur <? dup 'inp + c@ ca!+ 1+ ) drop
	0 ca!
	'pwd c@ 0? ( drop ; ) drop
	'pwd isNro 1? ( drop ; ) drop
	hide? 1? ( drop ; ) drop
	gather
	nc 6 min 'pn ! refill ;

:accept
	pn 0? ( drop ; ) drop
	'inp cur + 'tmp strcpy
	psel poff - 7 << 'prw + 'inp wst + strcpyl
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
:pl | -- n ; lineas de texto del prompt (la ultima incluye el cursor)
	inplen ptw / 1+ ;

:ptw! | width pad -- ; ancho de texto del prompt para un frame y un margen
	2* - 3 - 1 max 'ptw ! ;

:phold | -- "text" ; texto del prompt vacio
	bk 0? ( drop "Type an R3Forth expression  (e.g. 2 3 + dup *)" ; ) drop
	bkn 1+ "definition  -  line %d  -  empty line to finish  (esc cancels)" sprint ;

:pbar | -- ; color de la barra del prompt: azul, violeta mientras se ingresa una definicion
	bk 0? ( drop fBl ; ) drop fPr ;

:promptline | i -- ; linea i del texto de entrada
	inplen 0? ( 2drop fDi ptw phold lwrite ; ) drop
	ptw * 'inp + fTx ptw swap lwrite ;

:drawprompt | pad -- ; texto de entrada con salto de linea (pl filas) mas 3 de margen
	0 flpad fhome
	fx 'px ! fy 'py ! fw 'pw !
	0 ( pl 3 + <?
		pbar bg2 bar fw .ndel .sp .sp
		1 pl in? ( dup 1- promptline )
		fcr 1+ ) drop
	bg0 fx 3 + cur ptw mod + fy 1+ cur ptw / + .at .savec tuC! ;

:pbg | i -- ; fondo segun seleccion
	psel poff - =? ( drop bg3 ; ) drop bg1 ;
:pc | i -- ; color del nombre
	psel poff - =? ( drop fPr ; ) drop fTx ;

#pdef ( 16 0 0 0 26 2 0 0 )	| tabla del popup: nombre, descripcion (ancho segun pw), libreria

:prow | i --
	dup pbg
	fw .nsp fx .col .sp .sp
	dup pc dup 7 << 'prw + 'pe !
	pe cell
	fMu pe 32 + cell
	fDi pe 72 + cell
	drop ;

:drawpopup
	pn 0? ( drop ; ) drop
	py 1- pn min 'ph !
	ph 1 <? ( drop ; ) drop
	flxpush
	px 'fx ! py ph - 'fy ! pw 'fw ! ph 'fh !
	pw 48 - 1 max 255 min 'pdef 2 + c!
	'pdef tcols fhome
	'prow ph .lines
	flxpop ;

#spin "|" "/" "-" "\" ( 0 )

:drawfoot
	bg0 .wfill fhome .sp
	busy 1? ( fPr 'spin sf 4 mod n>>0 .write fMu " running r3..." .write 1 'sf +! )
	0? ( fDi "~/r3" .write ) drop
	pn 1? ( nc pn >? ( fMu nc psel 1+ "  %d/%d" sprint .write ) drop ) drop
	bk 1? ( fPr bkd bkn "  definition  %d lines  %d open (" sprint .write ) drop
	cols 86 >=? ( fDi cols 80 - .col 78 "ctrl+c quit   tab complete   / commands   ^f format   ^t terminal   ^l clear  " rwrite ) drop ;

|---------------- dibujo: pantallas
:drawlogo | y -- 
	cols 43 - 2/ 1+ swap .at
	"[01R[023[03f[04o[05r[06t[07h" .awrite
	bg0 fTx ;

:homehead | frame de 9 filas
	fy drawlogo
	fhome 5 ( 1? 1- fcr ) drop
	fMu "interactive R3Forth environment" .cw
	'pname "project: %s" sprint .cw ;

:homehints
	fhome fTx "tab" .write fDi " complete     " .write
	fTx "/words" .write fDi " search     " .write
	fTx "/help" .write fDi " commands" .write ;

:bw | -- w ; ancho del bloque de inicio
	cols 6 - 72 min ;

:draw-home
	1 flxS drawfoot
	bw 1 ptw!
	flxRest bw 15 pl + flxC flxpush
	9 flxN homehead
	pl 3 + flxN 1 drawprompt
	2 flxN
	flxRest homehints
	drawpopup
	flxpop ;

:draw-sess
	1 flxS drawfoot
	cols 2 ptw!
	pl 4 + flxS 2 drawprompt
	sw 1? ( dup 1 1 flPad flxE drawside ) drop
	2 flxN 2 0 flpad drawhead
	flxRest 2 0 flpad drawlines
	drawpopup ;

:drawscr
	flx layout
	bg0 fTx .cls
	ntl 0? ( drop draw-home ; ) drop
	draw-sess ;

:frame | redraw now (during a long operation)
	.cl .hidec tui drawscr .restorec .showc .flush ;

|---------------- guardar el proyecto (core devuelve ok)
:savefail
	'ppath "could not save %s  (paths are relative to where r3 runs; mkdir failed?)" sprint 4 tl+ ;

:psave | --
	proj-save 0? ( drop savefail ; ) drop ;

|---------------- evaluacion real
:tstep | "txt" style --
	tl+ 1 'busy ! frame 60 ms ;

:tsb "" 0 tstep ;			| linea en blanco
:tse 4 tstep tsb ;		| error + blanco
:tsn 6 tstep tsb ;		| nota + blanco

:stack$ | -- 'str ; stack text in the current format (valid until the next write to here)
	mark
	"[ " ,s
	sn 12 - 0 max ( sn <? dup 3 << 'sstk + @ fmtstr ,print 1+ ) drop
	"]" ,s ,eol
	memsize drop empty ;

#nolm 0 #nols 0
:showlbuf | style max -- ; vuelca las lineas de lbuf al transcript
	'nolm ! 'nols ! 0 'nol !
	lbuf ( dup c@ $ff and 1? drop
		dup 'lo2 strcpyln
		'lo2 c@ 1? ( 'lo2 nols tl+ 1 'nol +! ) drop
		nextl
		nol nolm >=? ( nip 'zero swap ) drop )
	2drop ;

:outlines | muestra la salida del programa (mem/repl.log)
	lbuf "mem/repl.log" load 0 swap c!
	lbuf "r3vm - PHREDA" findstr dup 1? ( 0 over c! ) 2drop
	5 14 showlbuf ;

:err-where | 'file line -- ; where an error is: your line, a line of the project or another file
	0? ( 2drop ; )
	over "mem/repl.r3" = 0? ( drop swap "in %s  line %d" sprint 6 tstep ; ) drop
	dup inyour? 1? ( nip nip
		gyn 0? ( 2drop "in your line" 6 tstep ; ) drop
		"in your definition  line %d" sprint 6 tstep ; ) drop
	nip 'pname "in project %s  line %d" sprint 6 tstep ;

:show-err | -- ; runtime error (error.log)
	rd-err
	'emsg "error: %s" sprint 4 tstep
	'efile eline err-where ;

:fail | -- ; descarta lo agregado en esta linea
	ninc0 'ninc ! 0 'busy ! tsb ;

:okpaso | muestra los includes nuevos
	ninc0 ( ninc <?
		dup 7 << 'incs + "include      %s" sprint 3 tstep
		1+ ) drop ;

:prep | -- ok ; kind 1: valida e incluye ; los boots y los includes que faltan los resuelve chk-run con los tokens
	gk
	1 =? ( drop
		ga trim tok drop
		'tk 1+ filexist 0? ( drop "file not found" tse 0 ; ) drop
		'tk inc+ 1 ; )
	drop 1 ;

|---------------- aviso previo: la linea escribe memoria? (lo calcula replchk con los tokens)
:mw.report | -- ; avisa antes de ejecutar si la linea escribe memoria
	mwflag 0? ( drop ; ) drop
	mark
	"memory      writes: " ,s
	'mwmb ( mwmb> <? dup ,s " " ,s >>0 ) drop
	"(kept between lines)" ,s ,eol
	memsize drop empty
	6 tstep ;

:show-chk | -- ; compile error found by replchk (nothing was run)
	'ckmsg "error: %s" sprint 4 tstep
	'ckfile ckline err-where ;

#mtx * 128
:mdef | i -- 'str ; defined word: its effect and if it writes memory
	dup m.eff effstr over m.name
	"defined      %s  ( %s )" sprint 'mtx strcpy
	m.writes? 1? ( drop 'mtx "%s  (writes memory)" sprint ; ) drop
	'mtx ;

:mredef | i -- ; warns if the name was already defined in the project
	dup m.prev -? ( 2drop ; )
	m.line swap m.name "warning      %s was already defined (line %d)" sprint 6 tstep ;

#trc 0 #mn0 0
:trline | i -- ; one exit: word and stack (mem/repl.trc)
	80 * 'trbuf 16 + + >a
	mark "exit         " ,s
	a@+ trname ,s
	"  [ " ,s
	a@+ dup 8 >? ( ".. " ,s ) drop 8 min
	( 1? 1- a@+ "%d " ,print ) drop
	"]" ,s ,eol
	memsize drop empty
	6 tstep ;

:show-trace | -- ; the stack at the exit of each project word of the run
	"mem/repl.trc" filexist 0? ( drop ; ) drop
	'trbuf "mem/repl.trc" load drop
	'trbuf @ 'trc !
	0 ( trc 30 min <? dup trline 1+ ) drop
	trc 30 >? ( trc 30 - "...          %d more exits" sprint 3 tstep ) drop
	'trbuf 8 + @ 1? ( dup "...          %d exits not recorded (limit)" sprint 3 tstep ) drop ;

:real-eval | adr --
	m.ready
	dup 'ga ! lkind 'gk !
	gk 3 =? ( drop ga trim c@ $ff and 0? ( drop ; ) drop ga defs+ psave ; ) drop
	ninc 'ninc0 !
	prep 0? ( drop ; ) drop
	"r3repl  -  r3" 2 tstep
	ga gk gen-src
	chk-run
	1 =? ( drop show-chk fail ; )
	2 =? ( drop 'ckmsg "stack underflow: %s" sprint 4 tstep fail ; )
	3 =? ( drop 'ckmsg tse fail ; )
	drop
	gk 0? ( mw.report ) drop
	gl "generate     mem/repl.r3  -  %d lines" sprint 3 tstep
	"mem/repl.trc" delete
	chk-gen 0? ( drop "the program could not be generated from the tokens" tse fail ; ) drop
	do-run
	"error.log" filexist 1? ( drop show-err fail ; ) drop
	readdump
	2 =? ( drop "r3 did not produce the stack dump (execution failed)" 4 tstep outlines fail ; )
	3 =? ( drop "stack underflow: the line consumes more values than available" 4 tstep outlines fail ; )
	4 =? ( drop "stack too large (more than 255 values)" 4 tstep outlines fail ; )
	drop
	okpaso
	tms "run          r3  -  %d ms" sprint 3 tstep
	gk 0? ( trace 1? ( show-trace ) drop ) drop
	outlines
	gk 2 =? (
		m.count 'mn0 !
		ga defs+n m.ready
		mn0 ( m.count <? dup mdef 3 tstep dup mredef 1+ ) drop ) drop
	gk 0 <>? ( psave ) drop
	ninc ninc0 <>? ( psave ) drop
	0 'busy !
	stack$ 5 tstep
	tsb ;

|---------------- comandos
#cb * 256 #cd 0
:cput | str w -- ; copia str en 'cd y rellena con espacios hasta w
	over count nip - 0 max swap
	cd strcpyl 1- 'cd !
	( 1? 1- 32 cd c!+ 'cd ! ) drop ;

:cmdstr | e -- 'str ; columnas alineadas: comando, argumentos, descripcion
	'cb 'cd !
	dup 9 cput dup e.arg 15 cput
	e.desc cd strcpy 'cb ;

:helpline | e --
	cmdstr 8 tl+ ;

:cmd-help
	"Commands" 7 tl+
	'ctab ( dup c@ $ff and 1? drop dup helpline e.next ) 2drop
	lnb ;

#carg 0 #ntk 0

:wline | e --
	cmdstr 8 tstep ;

:wtry | e --
	dup carg findstri 0? ( 2drop ; ) drop
	1 'ntk +!
	ntk 12 >? ( 2drop ; ) drop
	wline ;

:libline | -- 0
	ce effstr cl cw "%s  ^%s  %s" sprint 8 tstep 0 ;

:m.wlib | -- stop
	carg wsub 0? ( ; ) drop
	1 'ntk +!
	ntk 12 >? ( drop 1 ; ) drop
	libline ;

:cmd-words | arg --
	trim 'carg !
	carg c@ 0? ( drop
		"base + mlibs.r3 libraries  -  /lib word  shows the include" 6 tstep
		"/words dup   to search" 6 tstep
		tsb ; ) drop
	0 'ntk !
	'ctab ( dup c@ $ff and 1? drop dup wtry e.next ) 2drop
	'm.wlib scanwords drop
	ntk 0? ( "no results" 6 tstep ) drop
	ntk 12 >? ( "..." 6 tstep ) drop
	tsb ;

:m.libline | -- stop
	'tk wis 0? ( ; ) drop
	libline ;

:cmd-lib | arg --
	trim tok drop
	'tk c@ 0? ( drop "usage: /lib word" 6 tstep ; ) drop
	'tk wfind
	0? ( "not found in base or mlibs.r3" 4 tstep )
	1 =? ( ce effstr 'tk "%s  base  %s  -  no include needed" sprint 8 tstep )
	2 =? ( 'm.libline scanwords drop )
	drop tsb ;

:cmd-src | the program every line is run with (the assembled one, generated again from the tokens)
	"" 'ga ! 1 'gk ! ga gk gen-src
	chk-gen drop
	lbuf "mem/repl.r3" load 0 swap c!
	6 60 showlbuf
	lnb ;

:cmd-clear
	0 'ntl ! tp 'tp> ! 0 'scroll ! ;

:pbackup | -- ; copia el proyecto a <name>.r3.bak antes de vaciarlo
	'ppath filexist 0? ( drop ; ) drop
	pbuf 'ppath load pbuf -
	pbuf swap 'ppath "%s.bak" sprint save ;

#rdok 0
:resetdlg | dialogo de confirmacion (tui.r3: tuDlg + onTui)
	"Reset" 56 8 tuDlg
	fcr
	'pname "Empties stack, data and ALL the code of %s" sprint .cw
	'pname "(a copy is kept in %s.r3.bak)" sprint fMu .cw fTx
	fcr
	1 flxS fhome
	fMu "[ENTER] reset     [ESC] cancel" .cw
	flxRest
	tuDlgEnd
	uikey
	[esc] =? ( exit )
	$d =? ( 1 'rdok ! exit )
	drop ;

:cmd-reset | vacia todo: pila, datos y codigo del proyecto (pide confirmacion)
	0 'rdok ! frame 'resetdlg onTui
	rdok 0? ( drop "reset cancelled" tsn ; ) drop
	pbackup
	0 'sn ! data-clear proj-clear 0 'ninc0 ! psave
	'pname "stack, data and code cleared  (backup: %s.r3.bak)" sprint tsn ;

|---------------- comandos de proyecto
#ofile * 256
#bp 0

:switched | despues de cambiar de proyecto
	0 'sn ! data-clear proj-remember ;

:pinfo
	m.ready
	m.count ninc 'pname "project %s  -  %d includes, %d definitions" sprint 6 tl+
	m.ok 0? ( drop m.errline m.errmsg "the project does not compile: %s  (line %d)" sprint 4 tl+ ) drop
	m.boots 1? ( dup 0 m.bootline swap "%d boot word(s) ignored when running  (first at line %d)" sprint 6 tl+ ) drop
	lnb ;

:ls-proj
|WIN|	"cmd /c ""dir /b repl\proj > mem/repl.ls 2>nul"""
|LIN|	"ls -1 repl/proj > mem/repl.ls 2>/dev/null"
|MAC|	"ls -1 repl/proj > mem/repl.ls 2>/dev/null"
|RPI|	"ls -1 repl/proj > mem/repl.ls 2>/dev/null"
	sys ;

:cmd-proj
	"Projects" 7 tl+
	ls-proj
	lbuf "mem/repl.ls" load 0 swap c!
	8 14 showlbuf
	'pname "current: %s" sprint 6 tl+
	lnb ;

:cmd-save
	psave
	'ppath "saved to %s" sprint 6 tl+
	lnb ;

:proj? | -- 0/1 ; existe el proyecto 'tk
	'tk 'tk 'pdir "%s%s/%s.r3" sprint filexist ;

:cmd-new | arg --
	trim tok drop
	'tk namecheck 0? ( drop "invalid name (a-z 0-9 _ -, up to 30)" lne ; ) drop
	proj? 1? ( drop "already exists: /load name" lne ; ) drop
	'tk setproj mkproj proj-clear psave switched
	pinfo ;

:cmd-load | arg --
	trim tok drop
	'tk c@ 0? ( drop cmd-proj ; ) drop
	proj? 0? ( drop "no such project (/proj lists them)" lne ; ) drop
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

:projbase | -- ; 'tk = nombre del archivo sin ruta ni .r3
	'ofile 'bp !
	'ofile ( c@+ $ff and 1? $2f =? ( over 'bp ! ) $5c =? ( over 'bp ! ) drop ) 2drop
	bp 'tk strcpy
	'tk ".r3" findstr dup 1? ( 0 over c! ) 2drop
	'tk sanit ;

:cmd-open | arg --
	resolve 0? ( drop "file not found (/find text)" lne ; ) drop
	projbase
	'tk namecheck 0? ( drop "invalid project name" lne ; ) drop
	proj? 1? ( drop "a project with that name already exists (/load)" lne ; ) drop
	'tk setproj mkproj
	pbuf 'ofile load 0 swap c!
	pbuf proj-parse
	psave switched
	'ofile "base code: %s" sprint 6 tl+
	pinfo ;

:cmd-find | arg --
	trim tok drop
	'tk c@ 0? ( drop "usage: /find text" lnn ; ) drop
	'tk
|WIN|	"cmd /c ""dir /s /b r3\*%s*.r3 > mem/repl.ls 2>nul"""
|LIN|	"find r3 -iname ""*%s*.r3"" | sort > mem/repl.ls 2>/dev/null"
|MAC|	"find r3 -iname ""*%s*.r3"" | sort > mem/repl.ls 2>/dev/null"
|RPI|	"find r3 -iname ""*%s*.r3"" | sort > mem/repl.ls 2>/dev/null"
	sprint sys
	lbuf "mem/repl.ls" load 0 swap c!
	lbuf c@ 0? ( drop "no results" lnn ; ) drop
	8 14 showlbuf
	"/open path   opens it as a project" 6 tl+
	lnb ;

:runerr | muestra error.log como main.r3
	"error.log" filexist 0? ( drop ; ) drop
	'ebuf "error.log" load 0 swap c!
	.cr .bred .white " * ERROR * " .write .reset .cr
	'ebuf .write .cr
	"error.log" delete ;

:cmd-run
	psave
	.masb .reset .cls .flush
	'ppath r3run
	.reterm
	runerr
	.cr " -- done, press any key --" .write .flush
	waitkey
	.alsb .flush
	"project launched" lnn ;

:cmd-edit
	psave
	'ppath 'menubuf strcpy
	'menubuf 1024 "mem/menu.mem" save
	.masb .flush
	"r3/d4/r3ide.r3" r3run
	.reterm .alsb .flush
	proj-load drop data-clear
	pinfo ;

#hname 0
#pfx * 64
:hook-show
	0 'fnd !
	defs ( dup c@ $ff and 1? drop
		dup 'lo2 strcpyln
		'lo2 'pfx =pre nip 1? ( 'lo2 6 tl+ 1 'fnd ! ) drop
		nextl ) 2drop
	fnd 0? ( "(none)" 6 tl+ ) drop ;

:hook-check | -- ok ; compiles the project (no hooks, no line) to validate it
	"" 'ga ! 1 'gk !
	ga gk gen-src
	chk-run 0? ( drop 1 ; ) drop
	show-chk 0 ;

:hook-cmd | arg "name" -- ; /init and /done: one-line hook definition in the project
	'hname !
	hname ":%s " sprint 'pfx strcpy
	trim
	dup c@ 0? ( 2drop hook-show lnb ; ) drop
	"off" over = 1? ( 2drop 'pfx defs-del psave "hook removed" lnn ; ) drop
	ninc 'ninc0 !
	'pfx defs-del
	hname ":%s %s ;" sprint 'lo2 strcpy
	'lo2 defs+
	hook-check 0? ( drop 'pfx defs-del ninc0 'ninc ! "hook rejected" lnn ; ) drop
	psave hook-show lnb ;

:showfmt
	fmtname "format: %s" sprint 6 tl+
	stack$ 5 tl+
	lnb ;

:cmd-fmt | arg --
	trim tok drop
	'tk c@ 0? ( drop fmtcycle showfmt ; ) drop
	"dec" 'tk = 1? ( drop 0 'fmt ! showfmt ; ) drop
	"hex" 'tk = 1? ( drop 1 'fmt ! showfmt ; ) drop
	"fix" 'tk = 1? ( drop 2 'fmt ! showfmt ; ) drop
	"fixed" 'tk = 1? ( drop 2 'fmt ! showfmt ; ) drop
	"usage: /fmt dec|hex|fix" lne ;

:cmd-term | shows the output terminal of the last run (raw, in the normal screen)
	lbuf "mem/repl.log" load 0 swap c!
	lbuf "r3vm - PHREDA" findstr dup 1? ( 0 over c! ) 2drop
	.masb .reset .cls .flush
	lbuf c@ 0? ( " (no output yet)" .write ) drop
	lbuf .write
	.cr .cr " -- end of output, press any key --" .write .flush
	waitkey
	.alsb .flush ;

:trace-msg
	trace 1? ( drop "trace on   -  stack at the exit of each project word, shown after the run" 5 tstep tsb ; ) drop
	"trace off" 5 tstep tsb ;

:cmd-trace | arg --
	trim tok drop
	'tk c@ 0? ( drop trace 1 xor 'trace ! trace-msg ; ) drop
	"on" 'tk = 1? ( drop 1 'trace ! trace-msg ; ) drop
	"off" 'tk = 1? ( drop 0 'trace ! trace-msg ; ) drop
	"usage: /trace on|off" lne ;

:docmd | adr --
	"/help" over = 1? ( 2drop cmd-help ; ) drop
	"/words" over = 1? ( drop >>sp cmd-words ; ) drop
	"/lib" over = 1? ( drop >>sp cmd-lib ; ) drop
	"/stack" over = 1? ( 2drop stack$ 5 tstep tsb ; ) drop
	"/fmt" over = 1? ( drop >>sp cmd-fmt ; ) drop
	"/init" over = 1? ( drop >>sp "repl-init" hook-cmd ; ) drop
	"/done" over = 1? ( drop >>sp "repl-done" hook-cmd ; ) drop
	"/term" over = 1? ( 2drop cmd-term ; ) drop
	"/src" over = 1? ( 2drop cmd-src ; ) drop
	"/trace" over = 1? ( drop >>sp cmd-trace ; ) drop
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
	"/exit" over = 1? ( 2drop exit ; ) drop
	drop "unknown command  -  /help" tse ;

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
	pbuf "mem/repl.hist" load 0 swap c!
	pbuf ( dup c@ $ff and 1? drop
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
	pbuf "mem/repl.last" load 0 swap c!
	'tk pbuf trim copynom
	'tk namecheck 0? ( "scratch" 'tk strcpy ) drop
	'tk setproj proj-ensure 0? ( savefail ) drop proj-load drop proj-remember
	hist-load ;

|---------------- entrada de teclado
:fin
	0 'busy ! popup! ;

|---------------- definiciones de varias lineas (: o #): se cierran con una linea vacia
| el scanner lleva parentesis abiertos (bkd), string abierto (bks), si la palabra ya tiene
| su ; (bksm) y la ultima definicion vista (bkk). Los comentarios | y los strings no cuentan.
:bk.t1 | -- ; token de un caracter
	bktc $28 =? ( 1 'bkd +! ) $29 =? ( -1 'bkd +! ) $3b =? ( bkd 0? ( 1 'bksm ! ) drop ) drop ;

:bk.tn | -- ; token mas largo: :nombre #nombre
	bktc $3a =? ( $3a 'bkk ! 0 'bksm ! ) $23 =? ( $23 'bkk ! ) drop ;

:bk.tend | -- ; fin de token
	bktl 1 =? ( drop bk.t1 0 'bktl ! ; )
	1 >? ( drop bk.tn 0 'bktl ! ; )
	drop 0 'bktl ! ;

:bk.ch | c --
	'bkc !
	bkcm 1? ( drop ; ) drop
	bks 1 =? ( drop bkc $22 =? ( 2 'bks ! ) drop ; ) drop
	bks 2 =? ( 0 'bks ! bkc $22 =? ( 1 'bks ! drop drop ; ) drop ) drop
	bkc 33 <? ( drop bk.tend ; ) drop
	bktl 0? ( bkc 'bktc !
		bkc $7c =? ( 1 'bkcm ! ) drop
		bkc $22 =? ( 1 'bks ! 1 'bktl +! ) drop ) drop
	1 'bktl +! ;

:bk.scan | adr -- ; actualiza el estado con una linea
	0 'bkcm ! 0 'bktl !
	( c@+ $ff and 1? bk.ch ) 2drop
	bk.tend
	bks 2 =? ( 0 'bks ! ) drop ;

:bk.reset | -- ; sale del modo definicion
	0 'bk ! 0 'bkn ! 0 'bkd ! 0 'bks ! 0 'bksm ! 0 'bktl ! 0 'bkcm ! 0 'bkk !
	'bkb 'bkb> ! 0 'bkb c! ;

:bk.err | "msg" -- ; error que no se arregla agregando lineas: se descarta la definicion
	tse bk.reset ;

:bk.add | adr -- ; agrega la linea al bloque
	dup bk.scan
	bkn 1? ( 13 bkb> c!+ 'bkb> ! ) drop
	bkb> strcpyl 1- 'bkb> !
	1 'bkn +! ;

:bk.open? | -- 0/1 ; la ultima palabra : todavia no tiene su ;
	bkk $3a =? ( bksm 0? ( 2drop 1 ; ) drop ) drop 0 ;

:bk.defstart? | adr -- 0/1 ; la linea empieza una definicion
	trim c@ $ff and $3a =? ( drop 1 ; ) $23 =? ( drop 1 ; ) drop 0 ;

:bk.nest? | adr -- 0/1 ; la linea abre otra definicion con una palabra sin cerrar
	bks 1? ( 2drop 0 ; ) drop
	bk.defstart? 0? ( ; )
	drop bk.open? ;

:bk.begin | adr -- ; primera linea de una definicion
	bk.reset 1 'bk !
	bk.add
	bkd -? ( drop "unmatched )" bk.err ; ) drop ;

:bk.end | -- ; linea vacia: cierra la definicion si esta completa
	bks 1? ( drop "string not closed  (esc cancels)" tse ; ) drop
	bkd 1? ( drop bkd "%d ( not closed  (esc cancels)" sprint tse ; ) drop
	bk.open? 1? ( drop "missing ;  (esc cancels)" tse ; ) drop
	'bkb real-eval bk.reset ;

:bk.line | -- ; enter dentro de la definicion (la linea esta en 'inp)
	0 'scroll !
	'inp trim c@ $ff and 0? ( drop 0 'inp c! 0 'cur ! 0 'pn ! bk.end ; ) drop
	'inp hist+ hist-save
	'inp 9 tl+p
	0 'inp c! 0 'cur ! 0 'pn !
	dup bk.nest? 1? ( 2drop "missing ;  before the next definition" bk.err ; ) drop
	bkb> 'bkb - 3800 >? ( 2drop "definition too long" bk.err ; ) drop
	bk.add
	bkd -? ( drop "unmatched )" bk.err ; ) drop ;

:bk.cancel | -- ; esc dentro de la definicion
	bk.reset "definition canceled" lnn ;

:submit
	bk 1? ( drop bk.line fin ; ) drop
	inplen 0? ( drop ; ) drop
	'inp hist+ hist-save
	0 'scroll !
	'inp 1 tl+p
	0 'inp c! 0 'cur ! 0 'pn !
	dup c@ $ff and $2f =? ( drop docmd fin ; ) drop
	dup lkind 2 =? ( drop bk.begin fin ; ) drop
	real-eval fin ;

:clampscroll
	scroll ntl rows 7 - pl - - 0 max min 0 max 'scroll ! ;

:onkey | key --
	uiKey
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
	[up] =? ( drop pn 1? ( drop psel 1- 0 max 'psel ! selvis ; ) drop hup ; )
	[dn] =? ( drop pn 1? ( drop psel 1+ nc 1- min 'psel ! selvis ; ) drop hdn ; )
	[pgup] =? ( drop 5 'scroll +! clampscroll ; )
	[pgdn] =? ( drop -5 'scroll +! clampscroll ; )
	32 126 in? ( kins popup! ; )
	$3 =? ( 1+ ) $4 =? ( exit ) | ctrl+c +d
	[esc] =? ( drop pn 1? ( drop 0 'pn ! ; ) drop bk 1? ( drop bk.cancel ; ) drop exit ; )
	drop ;

|---------------- pantalla (tui): tecla -> dibujo
:replscr
	onkey drawscr ;

:initmem | big buffers (>8192) are reserved in the boot: tp recs
	here
	dup 'tp ! $20000 +
	dup 'recs ! 16384 +
	'here !
	tp 'tp> ! ;

:main
	core-init gen-init m.init initmem
	data-clear proj-boot
	.alsb
	'replscr onTui 
	.masb .showc .Reset .flush ;

: main ;
