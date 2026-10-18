| replgen - generation and real execution of r3repl (no UI)
| gen-src writes mem/repl.r3 ; do-run runs it with r3 ; readdump recovers the stack
| rd-err reads error.log (emsg efile eline) ; the results of a line are reported by repl.r3
^repl/replcore.r3

|---------------- generacion y ejecucion (r3 real)
##gk 0 ##ga 0 ##gl 0 ##gboot 0 ##gyour 0	| gyour = line of the typed code in mem/repl.r3
#t0 0 ##tms 0
#obuf * 2064
##ebuf * 4096
##lbuf 0
##emsg * 256
##efile * 128
#els 0 #elne 0 ##eline 0

:gnl ,nl 1 'gl +! ;

#inboot 0
::bootline? | adr -- 0/1 ; linea que abre una palabra de arranque (: ...)
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
	defs ( dup c@ $ff and 1? drop
		dup 'lo2 strcpyln gline
		nextl ) 2drop ;

##mhook 0		| set by replmodel (m.init): "name" -- 0/1
::hasdef | "name" -- 0/1 ; is the word defined in the project? (the model of r3token answers)
	mhook 1? ( ex ; ) 2drop 0 ;

::gen-src | adr kind -- ; escribe mem/repl.r3
	'gk ! 'ga !
	mark 0 'gl !
	"^repl/repldump.r3" ,s gnl
	0 ( ninc <? dup 7 << 'incs + ,s gnl 1+ ) drop
	"#rdini 0" ,s gnl
	gen-defs
	gk 2 =? ( gl 1+ 'gyour ! ga ,s gnl ) drop
	"#rdend 0" ,s gnl
	gl 1+ 'gboot !
	gk 2 <>? ( gboot 'gyour ! ) drop
	": 'rdini 'rdend .rreg .rrest .rbegin " ,s
	gk 0? ( "repl-init" hasdef 1? ( "repl-init " ,s ) drop ) drop
	0 ( sn <? dup 3 << 'sstk + @ "%d " ,print 1+ ) drop
	gk 0? ( gnl gl 1+ 'gyour ! ga ,s gnl "repl-done" hasdef 1? ( "repl-done " ,s ) drop ) drop
	".rdump ;" ,s gnl
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

::data-clear | -- ; forgets the variables of the session (mem/repl.dat)
	"mem/repl.dat" delete ;

::do-run
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

::rd-err
	'ebuf "error.log" load 0 swap c!
	rd-file rd-line rd-msg ;

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

::gen-init | -- ; lbuf (>8192) is reserved at the boot
	here dup 'lbuf ! $4000 + 'here ! ;
