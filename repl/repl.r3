| r3repl - REPL environment for R3Forth   (folder repl/)    TUI version (util/tui.r3)
| A session = a project: repl/proj/<n>/<n>.r3 (scratch by default).
| Each line is generated as a program (mem/repl.r3) and run with r3.
| The stack is recovered with the internal library repl/repldump.r3 (mem/repl.out).
| There is no interpreter in the REPL: r3lin runs everything.
|   replcore.r3  session and project (includes, definitions, files)
|   replgen.r3   generation and execution of the program
|   repl2.r3     screen, commands and keys (layout and colors from util/tui.r3)
^r3/util/tui.r3
^repl/replhelp.r3
^repl/replcore.r3
^repl/replgen.r3

|---------------- variables
#sw 0
#px 0 #py 0 #pw 0		| prompt frame
#tmp * 256
#pe 0
#busy 0 #sf 0 #quit 0 #zero 0
#fnd 0
#nol 0

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

:r.user
	bg1 fw .nsp fx .col
	fBl "▐" .write bg1 fTx .sp fw 5 - lt lwrite ;
:r.head
	fPr "*  " .write fMu fw 4 - lt lwrite ;
:r.ok
	fGr "  + " .write fMu fw 6 - lt lwrite ;
:r.err
	fRd "  x " .write fw 6 - lt lwrite ;
:r.out
	.sp .sp fPu "▐" .write bg0 fTx .sp fw 8 - lt lwrite ;
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
	drop ;

:drawlines
	fh 'vis !
	ntl vis - scroll - 0 max dup 'i0 !
	vis + ntl min 'i1 !
	fhome 'rowt vis .lines ;

:drawhead
	fhome bg0 fPr .Bold "# " .write fTx "r3repl" .write .NBold
	fMu "  -  " .write 'pname .write
	fx fw + 19 - fy .at fMu 18 fmtname sn "stack %d  [%s]" sprint rwrite
	fx fy 1+ .at fDi fw 45 .nch ;

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
	dnn 0? ( fDi "(none)" .lw ) drop
	0 ( dnn <? 6 <?
		fMu dup 3 << 'dnp + @ "> %s" sprint .lw
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
#psel 0
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
	over 7 << 'prw + 'pe !
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
:drawprompt | frame: x y w ; uses 4 rows
	fx 'px ! fy 'py ! fw 'pw !
	fhome bg2 4 ( 1? 1- fBl "▐" .write bg2 fw 1- .nsp fcr ) drop
	bg2 fx 3 + fy 1+ .at
	inplen 0? ( fDi "Type an R3Forth expression  (e.g. 2 3 + dup *)" .write )
	1? ( fTx fw 5 - 'inp lwrite ) drop
	bg0 fx 3 + cur + fy 1+ .at .savec tuC! ;

:pbg | i -- ; fondo segun seleccion
	psel =? ( drop bg3 ; ) drop bg1 ;
:pc | i -- ; color del nombre
	psel =? ( drop fPr ; ) drop fTx ;

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
	pw 48 - 1 max 255 min 'pdef 2 + c!
	px py pn - pw pn flx!
	'pdef tcols fhome
	'prow pn .lines ;

#spin "|" "/" "-" "\" ( 0 )

:drawfoot
	bg0 fx fy fw 1 .boxf fx 1+ fy .at
	busy 1? ( fPr 'spin sf 4 mod n>>0 .write fMu " running r3..." .write 1 'sf +! )
	0? ( fDi "~/r3" .write ) drop
	cols 74 >=? ( fDi cols 68 - fy .at 66 "ctrl+c quit   tab complete   / commands   ^f format   ^t terminal  " rwrite ) drop ;

|---------------- dibujo: pantallas
:drawlogo | y -- 
	cols 43 - 2/ 1+ swap .at
	"[01R[023[03f[04o[05r[06t[07h" .awrite
	bg0 fTx ;

:draw-home
	1 flxS drawfoot
	cols 6 - 72 min 'pw ! cols pw - 2/ 1+ 'px ! rows 2/ 'py !
	py 9 - drawlogo
	fMu 1 py 4 - .at cols "interactive R3Forth environment" cwrite
	fMu 1 py 3 - .at cols 'pname "project: %s" sprint cwrite
	px py pw 4 flx! drawprompt
	fTx px py 6 + .at "tab" .write fDi " complete     " .write
	fTx "/words" .write fDi " search     " .write
	fTx "/help" .write fDi " commands" .write
	drawpopup ;

:draw-sess
	1 flxS drawfoot
	sw 1? ( dup flxE drawside ) drop
	2 flxN 2 0 flpad drawhead
	6 flxS 2 0 flpad drawprompt
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

:stack$ | -- 'str ; stack text in the current format (valid until the next write to here)
	mark
	"[ " ,s
	sn 12 - 0 max ( sn <? dup 3 << 'sstk + @ fmtstr ,print 1+ ) drop
	"]" ,s ,eol
	memsize drop empty ;

#nolm 14 #nols 5
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
	gk 0 <>? ( psave ) drop
	ninc ninc0 <>? ( psave ) drop
	0 'busy !
	stack$ 5 tstep
	"" 0 tstep ;

|---------------- comandos
:helpline | e --
	dup e.desc over e.arg rot "%s  %s  %s" sprint 8 tl+ ;

:cmd-help
	"Commands" 7 tl+
	'ctab ( dup c@ $ff and 1? drop dup helpline e.next ) 2drop
	"" 0 tl+ ;

#carg 0 #ntk 0

:wline | e --
	dup e.desc over e.arg rot "%s  %s  %s" sprint 8 tstep ;

:wtry | e --
	dup carg findstri 0? ( 2drop ; ) drop
	1 'ntk +!
	ntk 12 >? ( 2drop ; ) drop
	wline ;

:m.wlib | -- stop
	carg wsub 0? ( ; ) drop
	1 'ntk +!
	ntk 12 >? ( drop 1 ; ) drop
	ce effstr cl cw "%s  ^%s  %s" sprint 8 tstep 0 ;

:cmd-words | arg --
	trim 'carg !
	carg c@ 0? ( drop
		"base + mlibs.r3 libraries  -  /lib word  shows the include" 6 tstep
		"/words dup   to search" 6 tstep
		"" 0 tstep ; ) drop
	0 'ntk !
	'ctab ( dup c@ $ff and 1? drop dup wtry e.next ) 2drop
	'm.wlib scanwords drop
	ntk 0? ( "no results" 6 tstep ) drop
	ntk 12 >? ( "..." 6 tstep ) drop
	"" 0 tstep ;

:m.libline | -- stop
	'tk wis 0? ( ; ) drop
	ce effstr cl cw "%s  ^%s  %s" sprint 8 tstep 0 ;

:cmd-lib | arg --
	trim tok drop
	'tk c@ 0? ( drop "usage: /lib word" 6 tstep ; ) drop
	'tk wfind
	0? ( "not found in base or mlibs.r3" 4 tstep )
	1 =? ( ce effstr 'tk "%s  base  %s  -  no include needed" sprint 8 tstep )
	2 =? ( 'm.libline scanwords drop )
	drop "" 0 tstep ;

:cmd-src | the program every line is compiled with (rebuilt from the current project)
	"" 1 gen-src
	lbuf "mem/repl.r3" load 0 swap c!
	6 60 showlbuf
	"" 0 tl+ ;

:cmd-clear
	0 'ntl ! tp 'tp> ! 0 'scroll ! ;

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
	lbuf "mem/repl.ls" load 0 swap c!
	8 14 showlbuf
	'pname "current: %s" sprint 6 tl+
	"" 0 tl+ ;

:cmd-save
	psave
	'ppath "saved to %s" sprint 6 tl+
	"" 0 tl+ ;

:cmd-new | arg --
	trim tok drop
	'tk namecheck 0? ( drop "invalid name (a-z 0-9 _ -, up to 30)" 4 tl+ "" 0 tl+ ; ) drop
	'tk 'tk 'pdir "%s%s/%s.r3" sprint filexist 1? ( drop "already exists: /load name" 4 tl+ "" 0 tl+ ; ) drop
	'tk setproj mkproj proj-clear psave switched
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

:projbase | -- ; 'tk = nombre del archivo sin ruta ni .r3
	'ofile 'bp !
	'ofile ( c@+ $ff and 1? $2f =? ( over 'bp ! ) $5c =? ( over 'bp ! ) drop ) 2drop
	bp 'tk strcpy
	'tk ".r3" findstr dup 1? ( 0 over c! ) 2drop
	'tk sanit ;

:cmd-open | arg --
	resolve 0? ( drop "file not found (/find text)" 4 tl+ "" 0 tl+ ; ) drop
	projbase
	'tk namecheck 0? ( drop "invalid project name" 4 tl+ "" 0 tl+ ; ) drop
	'tk 'tk 'pdir "%s%s/%s.r3" sprint filexist 1? ( drop "a project with that name already exists (/load)" 4 tl+ "" 0 tl+ ; ) drop
	'tk setproj mkproj
	pbuf 'ofile load 0 swap c!
	pbuf proj-parse
	psave switched
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
	lbuf "mem/repl.ls" load 0 swap c!
	lbuf c@ 0? ( drop "no results" 6 tl+ "" 0 tl+ ; ) drop
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
	psave
	.masb .reset .cls .flush
	'ppath r3run
	.reterm
	runerr
	.cr " -- done, press any key --" .write .flush
	waitkey
	.alsb .flush
	"project launched" 6 tl+ "" 0 tl+ ;

:cmd-edit
	psave
	'ppath 'menubuf strcpy
	'menubuf 1024 "mem/menu.mem" save
	.masb .flush
	"r3/d4/r3ide.r3" r3run
	.reterm .alsb .flush
	proj-load drop
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
	"" 1 gen-src do-run
	"error.log" filexist 1? ( drop show-err 0 ; ) drop 1 ;

:hook-cmd | arg "name" -- ; /init and /done: one-line hook definition in the project
	'hname !
	hname ":%s " sprint 'pfx strcpy
	trim
	dup c@ 0? ( 2drop hook-show "" 0 tl+ ; ) drop
	"off" over = 1? ( 2drop 'pfx defs-del names-rebuild psave "hook removed" 6 tl+ "" 0 tl+ ; ) drop
	ninc 'ninc0 !
	'pfx defs-del
	hname ":%s %s ;" sprint 'lo2 strcpy
	'lo2 scaninc 'lo2 defs+
	names-rebuild
	hook-check 0? ( drop 'pfx defs-del names-rebuild ninc0 'ninc ! "hook rejected" 6 tl+ "" 0 tl+ ; ) drop
	psave hook-show "" 0 tl+ ;

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
	lbuf "mem/repl.log" load 0 swap c!
	lbuf "r3vm - PHREDA" findstr dup 1? ( 0 over c! ) 2drop
	.masb .reset .cls .flush
	lbuf c@ 0? ( " (no output yet)" .write ) drop
	lbuf .write
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

:submit
	inplen 0? ( drop ; ) drop
	'inp hist+ hist-save
	0 'scroll !
	'inp 1 tl+p
	0 'inp c! 0 'cur ! 0 'pn !
	dup c@ $ff and $2f =? ( drop docmd fin ; ) drop
	real-eval fin ;

:quit! 1 'quit ! exit ;

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
	$3 =? ( 1+ ) $4 =? ( quit! ) | ctrl+c +d
	drop ;

|---------------- pantalla (tui): tecla -> dibujo
:dokey
	uikey 0? ( drop ; )
	0 'uikey !
	onkey ;

:replscr
	dokey drawscr ;

:initmem | big buffers (>8192) are reserved in the boot: tp recs
	here
	dup 'tp ! $20000 +
	dup 'recs ! 16384 +
	'here !
	tp 'tp> ! ;

:main
	core-init gen-init initmem
	proj-boot
	.alsb
	( quit 0? drop 'replscr onTui ) | ESC ends onTui: it only closes the popup, so it is started again
	drop
	.masb .showc .Reset .flush ;

: main ;
