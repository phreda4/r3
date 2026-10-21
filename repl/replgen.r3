| replgen - generation and real execution of r3repl (no UI)
| gen-src assembles the program (text) ; replchk generates from it, with the tokens, the one that is run
| do-run runs mem/repl.r3 with r3 ; readdump recovers the stack
| rd-err reads error.log (emsg efile eline) ; the results of a line are reported by repl.r3
^repl/replcore.r3

|---------------- generacion y ejecucion (r3 real)
##gk 0 ##ga 0 ##gl 0 ##gboot 0 ##gyour 0 ##gyn 0	| gyour = line of the typed code in mem/repl.r3 ; gyn = extra lines of a multi-line definition
#t0 0 ##tms 0
#obuf * 2064
##emsg * 256
##efile * 128
#els 0 #elne 0 ##eline 0

:gnl ,nl 1 'gl +! ;

#crc 0
:crn | adr -- n ; number of CR in the text (extra lines of a multi-line definition)
	0 'crc !
	( c@+ $ff and 1? 13 =? ( 1 'crc +! ) drop ) 2drop
	crc ;

::inyour? | line -- n ; 0 = not in the typed text, else its line number inside it (1..)
	gyour - -? ( drop 0 ; ) 1+ gyn 1+ >? ( drop 0 ; ) ;

:gen-defs | the project as it is (defs keeps its lines with CR LF)
	defs ,s defl 'gl +! ;

::gen-src | adr kind -- ; escribe mem/repl.r3
	'gk ! 'ga ! 0 'gyn !
	mark 0 'gl !
	"^repl/repldump.r3" ,s gnl
	0 ( ninc <? dup 7 << 'incs + ,s gnl 1+ ) drop
	"#rdini 0" ,s gnl
	gen-defs
	gk 2 =? ( gl 1+ 'gyour ! ga ,s gnl ga crn dup 'gyn ! 'gl +! ) drop
	"#rdend 0" ,s gnl
	gk 0? ( ":rdline" ,s gnl gl 1+ 'gyour ! ga ,s gnl ";" ,s gnl ) drop	| the line is a word: r3token gives its stack effect
	gl 1+ 'gboot !
	gk 1 =? ( gboot 'gyour ! ) drop
	": 'rdini 'rdend .rreg .rrest .rbegin " ,s
	0 ( sn <? dup 3 << 'sstk + @ "%d " ,print 1+ ) drop
	gk 0? ( "rdline " ,s ) drop
	".rdump ;" ,s gnl
	"mem/repl.r3" savemem
	empty ;

::gen-proj | -- ; the project alone: no hooks, no line
	"" 1 gen-src ;

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

::data-clear | -- ; forgets the variables of the session (mem/repl.dat)
	"mem/repl.dat" delete ;

::do-run
	cleanup
	msec 't0 !
	runcmd
	.reterm
	msec t0 - 'tms ! ;

|--- lectura de resultados
:rd-file | text -- text
	0 'efile c!
	dup "FILE:" findstr 0? ( drop ; ) 5 + 'efile swap copynom ;

:rd-line | text -- text
	0 'eline !
	dup "LINE:" findstr 0? ( drop ; ) 5 + str>nro nip 'eline ! ;

:rd-msg | text -- ; ultima linea no vacia del log
	dup 'els ! dup 'elne !
	( c@+ $ff and 1?
		10 =? ( over 'els ! )
		32 >? ( els 'elne ! )
		drop )
	2drop
	elne trim "^- " =pre 1? ( swap 3 + swap ) drop
	'emsg strcpyln ;

::rd-err
	mark "error.log" loadtxt
	rd-file rd-line rd-msg
	empty ;

::readdump | -- code ; 0 ok, 2 sin volcado, 3 underflow, 4 pila grande
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

