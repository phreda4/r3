| TUI IDE
| PHREDA 2025

^r3/util/tui.r3
^r3/util/tuiedit.r3
|^r3/lib/trace.r3

^r3/d4/r3token.r3
^r3/d4/helplib.r3
^r3/d4/manualview.r3

#msg * 1024		| last line msg

#vlist 
#msglist

#vwords 0 0
#vincs 0 0

#lwords

|---- change error mode
:moderror
	lerror tuiecursor! ;

:printfname
	.sp 'filename .write .sp ;

:makelistwords
	here dup 'lwords !
	dic< 
	|dic
	( dic> <? | solo codigo principal
		dup dic - 4 >> 1+ rot w!+ swap
		16 + ) drop
	0 swap w!+ 'here ! ;

|---------- TAGS in code	
:,ncar | n -- 
	65 ( swap 1? 1- swap dup ,c 1+ ) 2drop ;

| $..............01 - code/data
| $..............02 - loc/ext
| $..............04	1 es usado con direccion
| $..............08	1 r esta desbalanceada		| var cte
| $..............10	0 un ; 1 varios ;
| $..............20	1 si es recursiva
| $..............40	1 si tiene anonimas
| $..............80	1 termina sin ;

:wordhead
	nro>dic @+ 
	1 and? ( 201 .fc dic>name "#%w" ,print ,eol drop ; ) 
	196 .fc 
	dup 
	dic>name ":%w | " ,print 
	|$5b1b ,w "30;1m" ,s "|" ,s
	swap @ 
	dup $ff and dup ,ncar " -- " ,s	swap 48 << 56 >> + abs ,ncar 
	"  " ,s
	$10 and? ( ";" ,s )	| multiple
	$20 and? ( "R" ,s )	| recurse
	$80 and? ( "." ,s )	| no ;
	drop
	,eol ;
	
:xwriten.word | n --
	1- $ffff and 
	|cntdicc >=? ( drop "" lwrite ; ) 
	mark wordhead empty here lwrite ;
	
|---- helpword
#helpword * 32

:cpyhword | adr -- 
	'helpword 
	31 ( 1? 1- -rot		| copy word
		swap c@+ $ff and 
		32 <=? ( 2drop 0 swap c! drop ; )
		rot c!+ rot
		) drop
	0 swap c! 
	drop ;

:<<sp | adr -- adr' ; adr@=space
	( dup 1- c@ $ff and 32 >? drop 1- ) drop ;
	
:cpyhelpword
	fuente> <<sp cpyhword ;

:<<: | adr -- adr' ; adr@=:
	( fuente =? ( ; ) dup 1- c@ 
		$3a <>? | :
		$23 <>? | #
		drop 1- ) drop ;

:cpydefword 
	fuente> <<: cpyhword ;
	
:searchword | -- nro
	cntdef ( 1? 1-
		dup nro>dic @ dic>name
		'helpword =w 1? ( drop ; )
		drop ) ;
	
|---- screen
#nowword

:setcursoride
	vwords uiNindxn 1-
	dup 'nowword !
	nro>dic @
	|40 >> src + "%l" sprint 'msg strcpy 
	40 >>> fuente + |1- | :#
	tuiecursor!	
	;
		
|---- CHECKCODE
:cntlines | -- nrolin
	1 fuente 
	( lerror <?
		c@+ 13 =? ( rot 1+ -rot ) drop
		) drop ;
		
:coderror | error --
	.cl	15 .fc 1 .bc lerror " %w | " .print
	.write cntlines " in line %d" .print 
	.eline
	'msg strcpybuf ;
	
:codeok
	.cl	|2 .bc 0 .fc
	cnttok cntdef cntinc " OK | inc:%d words:%d tokens:%d" .print 
	.eline
	'msg strcpybuf ;

:checkcode
	TuSaveCode
	0 'msg !
	fuente 'filename r3loadmem
	error 1? ( coderror ; ) drop 
	codeok 
	;
	
|--- F3 Fx
#vanaly 0 0
#lanaly * $ffff

|#bmacro .l .l .word .wadr .var .vadr .str 

:tok2str | tok -- str
	$ff and 6 >? ( 7 - basename ; ) drop
	dup 40 >>> src + "%w" sprint
	|3 << 'bmacro + @ ex 
	;
	
:,scnt | str cnt --
	swap utf8count					| cnt str scount
	pick2 >? ( drop over ) swap	| cnt scnt str
	here pick2 utf8ncpy 'here !
	- ,nsp ;
	
:buildline | token --
	dup tok2str		| tok str
	20 ,scnt
	tokeninfo	
	wwinfo 
	dup 32 >> $f and swap
	
	16 >> $ff and |,ncar
	" %h %d" ,print 
	
	0 ,c
|	deltaD $ff and 8 << 
|	usoD $ff and or 8 << 
|	deltaR $ff and or ;
	;
	
:setanalysis
	mark
	'lanaly 'here !
	resetinfo
	nowword nro>dic
|	dup "%d >> " ,print
|	dup @ dic>name "%w" ,print 0 ,c
	toklen | tok len
	( 1? 1- swap
		@+ buildline
		swap ) 2drop
	0 ,c
	empty
	0 'vanaly !	
	;
	
#modefx
:fxlist
	cols 2/ flxE | 1/4 of screen
	.reset
	tuwina $1 " Rx " .wtitle 1 1 flpad .wfill 
	'xwriten.word xwriten!
	'vwords lwords tuListn | 'var list --
	tuX? 1? ( setcursoride ) drop
	xwrite.reset
	;

:fxword
	cols 2/ flxE
	.reset
	tuwina $1 " Word " .wtitle 1 1 flpad .wfill 
	'vanaly 'lanaly tuList | 'var list --
|	tuX? 1? ( setcursoride ) drop
	;

#modelfx fxlist fxword

:fxwin
	.reset .home 9 .bc 0 .fc 
	1 flxN 
	" r3Rx | " .write printfname 
	" | " .write tuecursor. .write 
	'helpword .write
	.eline
	
	1 flxS 
	fx fy .at 
	" ^[7mESC^[27m Exit rx ^[7mENTER^[27m Word ^[7mDel^[27m Dicc | " .printe 
	'helpword .write " | " .write
	'msg .write
	.eline
	
	modefx 3 << 'modelfx + @ ex
	
	flxRest 
	tuReadCode
	
	uiKey
	[enter] =? ( setanalysis 1 'modefx ! )
	[back] =? ( modefx 0? ( exit ) drop 0 'modefx ! )
|	[del] =? ( 0 'modefx ! )
	drop ;

:setvwords | nrow --
	lwords ( w@+ 1?
		pick2 =? ( drop nip lwords - 1 >> 'vwords ! ; ) 
		drop ) 2drop 
	0 'vwords ! ;
	
:fxcode
	checkcode error 1? ( drop moderror ; ) drop
	cpydefword
	'helpword c@ 0? ( drop "DEFINITION NOT FOUND" 'helpword strcpy ; ) drop
	makelistwords
	searchword dup 'nowword ! setvwords
	setanalysis
	0 'modefx !
	'fxwin onTui
	0 'uikey !
	tuR!
	;
	
|-------------------------------	
:runcode
	checkcode error 1? ( drop moderror ; ) drop
	.masb .reset .cls .flush
	'filename r3run
	.reterm .alsb .flush
	|here dup "error.log" load over =? ( 2drop ; ) 0 swap c!
	|drop "** error **" 'msg strcpy
	tuR!
	;

:debugcode
	checkcode error 1? ( drop moderror ; ) drop
	|.masb .reset .cls .flush
	"r3/d4/r3debug.r3" r3run
	.reterm .alsb .flush 
	tuR! ;

|------- old
:fileplain
	checkcode error 1? ( drop moderror ; ) drop
	"r3/editor/r3plain.r3" r3run
	tuR! ;
|------- old

:fileplaino
	checkcode error 1? ( drop moderror ; ) drop
	"r3/d4/r3plain.r3" r3run
|	.reterm .alsb .flush 
	"r3/d4/gen/plain.r3" r3run | exec
	tuR! ;

:filecompile
	checkcode error 1? ( drop moderror ; ) drop
	"r3/system/r3compiler.r3" r3run
	|.reterm .alsb .flush 
	tuR! ;

:filecompileo
	checkcode error 1? ( drop moderror ; ) drop
	|"r3/d4/r3plain.r3" r3run
	"r3/d4/r3wincomp.r3" r3run
	|.reterm .alsb .flush 
	tuR! ;

|-------------------------------

:compile
	checkcode error 1? ( drop moderror ; ) drop
	.masb .reset .cls
	"Building" .println
	"Code: " .write 'filename .write .cr .cr
	cntinc " includes:%d |" .print
	cntdef " words:%d |" .print
	cnttok " tokens:%d" .println
	.cr .cr
	cols .hline
	"[f2] Win64exe [f3] Plain " .write .cr
	cols .hline
	.reset .cr
	getch 
	[f2] =? ( filecompile )
	[f4] =? ( filecompileo )
	
	[f3] =? ( fileplaino ) 
	[f5] =? ( fileplain ) | dev
	
	drop
	.alsb
	;
	

|--- F2 help	
#infow
#infohelp * 128

:helpc
	.reset .home 9 .bc 0 .fc 
	1 flxN 
	" r3Manual | " .write printfname 
	" | " .write tuecursor. .write 
	.eline
	
	1 flxS 
	fx fy .at 
	" ^[7mESC^[27m Exit manual | " .printe 
	'helpword .write " | " .write
	'infohelp .write
	'msg .write
	.eline
	rows 2 >> flxN | 1/4 of screen
	tuReadCode
	flxRest
	.reset 
	tuwina $1 " Manual " .wtitle 1 1 flpad .wfill 
	viewmanual	
	
	uiKey
|	[f3] =? ( anacode )
| busqueda

	drop ;
	
:wordshow
	dup lwordhelp gomanual
	
	dup lwordlib
	swap lwordname 
	"%s << ^%s" sprint
	'infohelp strcpy 
	| search in manual or 
|	mark
|	4 << namwlist +	
|	@+ 6>str .write
|	@ .wordinfo 
|	empty
	;
	
:getlabel
	'helpword lwordfind
	$10000 and? ( drop "number push to data stack" 'infohelp strcpy 0 gomanual ; ) 
	$20000 and? ( drop "base word" 'infohelp strcpy 0 gomanual ; )
	+? ( wordshow ; ) 
	drop "Not found" 'infohelp strcpy ;
	
:helpcode
	cpyhelpword
	getlabel
	
	|'helpword lwordfind 'infow !
	
|	checkcode error 1? ( drop moderror ; ) drop
|	fuente 'filename r3loadmem
|	error 1? ( coderror ; ) drop
|	codeok
	
	'helpc onTui 
	;
	
|-------------------------------
:main
	.reset .home 4 .bc 7 .fc 
	1 flxN 
	" r3IDE | " .write printfname 
	" | " .write tuecursor. .write 
	.eline
	
	1 flxS 
	fx fy .at 
	" ^[7mF2^[27m Help ^[7mF3^[27m Rx ^[7mF4^[27m Run ^[7mF5^[27m Debug  ^[7mF10^[27m Build " .printe 
	'helpword .write
	'msg .write
	.eline
	flxRest
	tuEditCode
	
	uiKey
	[f2] =? ( helpcode )
	[f3] =? ( fxcode )
	[f4] =? ( runcode )
	[f5] =? ( debugcode )
	
	[f6] =? ( cpyhelpword  )
	
	[f10] =? ( compile )
	toLow
	drop ;

|-----------------------------------
: 
	.alsb
	'filename "mem/menu.mem" load drop
	|"r3/test/testasm.r3" 'filename strcpy
	
	makehelpwords	
	loadmanual	
	
	'filename TuLoadCode
	|TuNewCode
	mark
	'main onTui 
	TuSaveCode 
;
