| r3debug
| PHREDA 2025
^r3/lib/memshare.r3
^r3/util/tui.r3
^r3/util/tuiedit.r3

^./infodebug.r3

^r3/lib/trace.r3

#vshare 0 0 4096 "/debug.mem"	| vm state
#bshare 0 0 256 "/bp.mem"		| breakpoint
#dshare 0 0 0 "/data.mem" 		| memdata
#cshare 0 0 0 "/code.mem" 		| codedata

#filename * 1024

#cntdicc #localdicc
#boot
#memc #memd
#memdsize #memcsize
#memcode #memdata
#mdatastack #mretstack
#cntinc #strinc | includes in order
#realdicc

|--- for show in code
#codenow -1
#codeinc
#codedicc #codedicc>
#codesrc #codesrc>

:run&loadinfo

	| start the server
	"mem/r3code.mem" delete
	"mem/r3dicc.mem" delete | "filename" --
	
	| start debug
	'filename 
	"cmd /c r3d ""%s""" sprint | only WIN for now
|	"d.bat" 
	sysnew 

	| wait info
	"mem/r3dicc.mem"  
	( 200 ms dup filexist 0? drop ) 
	2drop 

	here dup "mem/r3code.mem" load 'here !
	w@+ 'cntdicc ! w@+ 'localdicc ! 
	d@+ 'boot !
	d@+ 'memc ! d@+ 'memd !
	d@+ 'memdsize ! d@+ 'memcsize !
	@+ 'memcode ! @+ 'memdata !
	@+ dup 'mdatastack ! 504 3 << + 'mretstack !
	w@+ 'cntinc ! 'strinc !
	here dup "mem/r3dicc.mem" load 'here !
	'realdicc !
	;

#msg * 1024
	
#vincs 0 0
#vwords 0 0
#vtoken 0 0

#lincs
#lwords
#ltokens

:*>end		$fe vshare ! ;
:*>stop		$0 vshare ! ;
:*>play		$1 vshare ! ;
:*>step		$2 vshare ! ;
:*>stepo	$3 vshare ! ;

:vmSTATE	vshare @ ;
:vmINFO		vshare 1 3 << + @ ;
:vmIP		vshare 2 3 << + @ ;
:vmTOS		vshare 3 3 << + @ ;
:vmNOS		vshare 4 3 << + @ ;
:vmRTOS		vshare 5 3 << + @ ;
:vmREGA		vshare 6 3 << + @ ;
:vmREGB		vshare 7 3 << + @ ;
:vmDS		vshare 8 3 << + ;
:vmRS		vshare 512 3 << + ;

|---- aux info 
#dstackoff
#rstackoff
#dataoff

:precalc
	vmDS mdatastack - 8 + 'dstackoff !
	vmRS mretstack - 8 + 'rstackoff !
	dshare memdata - 'dataoff !
	;


|----
|DICC
|v=(inc<<56)|(pos<<40)|(dicc[i].mem<<8)|dicc[i].info;

:ndicc@ | n -- entry
	3 << realdicc + @ ;

|---- view dicc
:dicc>name | nd -- str
	40 >> $ffff and realdicc cntdicc 3 << + + ; | name word
	
:wcolor
	$10 nand? ( 201 .fc ":" ,s ; ) 196 .fc "#" ,s ;
	
:xwrite.word | str --
	mark
	str$>nro nip
	cntdicc >=? ( drop "" ; ) 
	ndicc@ 
	dup 58 >> "%d " ,print | nro include
	wcolor
	dicc>name ,s ,eol 
	empty
	here lwrite ;

:makelistwords
	here 'lwords !
	|localdicc 
	0 ( cntdicc <?
		dup .h ,s ,eol
		1+ ) drop
	,eol ;

:scrDicc
	.reset tuWina $1 "Dicc" .wtitle 1 1 flpad 
	'xwrite.word xwrite!
	'vwords lwords tuList | 'var list --
	xwrite.reset
	;

|-------------------------

:.datastack
	mdatastack dup
	( 8 + vmNOS <? 
		dup dstackoff + @ " %h" .print 
		) drop
	vmNOS <? ( vmTOS " %h" .print ) 
	drop ;

:.retstack
	mretstack 
	( 8 - vmRTOS >? 
		dup rstackoff + |@ 
		" %h " .print
		) drop ;
		
:scrMsg	
	.reset fx fy .at fw .hline .cr

	vmIP "IP:%h " .print 
	
	cshare vmIP 2 << + d@ |codesrc + d@ 
	.token .print .sp
	
	|codesrc vmIP 1- 3 << + @ ":%h:" .print
	
|	vmTOS	"TOS:%h " .print vmNOS	"NOS:%h " .print vmRTOS	"RTOS:%h " .print .cr
	vmREGA	"A:%h " .print vmREGB	"B:%h " .print 
|	vmDS	"DS:%h " .print vmRS	"RS:%h " .print 
	.cr

|	cntdicc "cnddicc:%h " .print localdicc "localdicc:%h " .print
|	boot "boot:%h " .print memc "memc:%h " .print memd "memd:%h " .print
|	memdsize "mdsize:%h " .print memcsize "mcsize:%h " .print 
|	memcode "mcod:%h " .print memdata "mdat:%h " .print 
|	mdatastack "stack:%h " .print mretstack "rstack:%h " .print .cr
	"D|" .write .datastack .cr
	|"R|" .write .retstack
	;
	
|---- view tokens	

:typedef $10 and? ( "#" .write ; ) ":" .write ;
	
:.fcr .cr fx .col ;
	
:scrTokens
	.reset fx fy .at fw .hline 
	.fcr

|-------- print dicc
|	localdicc ( cntdicc <? 
|		dup ndicc@ stypedef 40 >> realdicc + cntdicc 3 << + .write .fcr
|		1+ ) drop
	
|-------- print includes
	strinc cntinc ( 1? 1- swap
		dup .write .fcr
		>>0 swap ) 2drop
	;
	
:printcode	
	cshare >a
	0 ( |memc 
	30 <? 
		vmip =? ( .rever )
		da@+ .token .write .sp
		|$ffffffff and "%h " .print
		vmip =? ( .reset )
		1+ ) drop
	;
	
|---- print on code
#xc #yc #state 0 #tokenc
#srcini

:xycur+ | car -- car
	13 =? ( 1 'yc +! 0 'xc ! ; )
	9 =? ( 2 'xc +! ; ) 
	1 'xc +! ;
	
::>>cr | adr -- adr'
	( c@+ 1? 
		13 =? ( drop 1- ; ) 
		xycur+
		drop ) drop 1- ;

::>>sp | adr -- adr'	; next space
	( c@+ $ff and 32 >? xycur+
		drop ) drop 1- ;

:>>str | src -- 'src 
	c@+ xycur+ drop
	( c@+ 1? xycur+
		34 =? ( drop c@+ xycur+
			34 <>? ( drop ; ) 
			) drop 
		) drop ;	

| ii cc pppp xxx yyy
:curposxy | str -- str v
	yc $fff and 
	xc $fff and 12 << or 
	over srcini - $ffff and 24 << or  | str
	over ( c@+ $ff and 32 >? drop ) drop pick2 - 1-
	40 << or
	pick2 $ff and 48 << or | src
	;

:ctoken! | src -- src
	tokenc 1? ( 1- 'tokenc ! >>sp ; ) drop
	
	curposxy
	
	da@+ dup token>cnt -? ( 3drop codesrc> 8 - @ codesrc> !+ 'codesrc> ! ; ) 
	'tokenc !
	drop |.token .print |$ff and "(%h) | " .print
	
	codesrc> !+ 'codesrc> !
	dup	w@ 
	$2100 <? ( $ff and
		$5b =? ( 0 'tokenc ! ) | [ JMP (1)->(0)
 		|$5d =? ( ; ) |]
		) drop
	>>sp 
	;

:,token
	state 0? ( drop >>sp ; ) drop
	dup	w@ 
	$2100 <? ( $ff and
		$28 =? ( drop >>sp ; ) | (
		$29 =? ( drop >>sp ; ) | )
		) drop
|	dup "%w=" .print
	ctoken! |"[tok]" .write
	;

:,str 
	state 0? ( drop >>str ; ) drop
|	"<STR>" .print
	
	|||||ctoken! |"[str]" .write
	tokenc 1? ( 1- 'tokenc ! >>str ; ) drop
	curposxy
		
	da@+ drop |.token .print |$ff and "(%h) | " .print
	
	codesrc> !+ 'codesrc> !

	>>str ;
	
|--- build show in code
:defvar | str --
|.cr dup "%w " .print
	b@+ | dicc entry
	drop
	curposxy
	codedicc> !+ 'codedicc> !
	0 'state ! 
	;
	
:defwor | str --
|.cr dup "%w " .print
	b@+ | dicc entry
	$8 and? ( drop da@+ drop |"boot chain...." .println 
			curposxy codesrc> !+ 'codesrc> ! 
			dup ) 
	drop
	curposxy
	codedicc> !+ 'codedicc> !
	1 'state ! 
	;
	
:coment
	drop
|WIN|	"|WIN|" =pre 1? ( drop 5 + ; ) drop | Compila para WINDOWS
|LIN|	"|LIN|" =pre 1? ( drop 5 + ; ) drop | Compila para LINUX
	>>cr ;
	
:wrd2token | str -- str'
	( dup c@ $ff and 33 <? xycur+
		0? ( nip ; ) drop 1+ )	| trim0
	$5e =? ( drop >>cr ; )		| $5e ^  Include
	$7c =? ( coment ; )		| $7c |	 Comentario
	$3A =? ( drop defwor >>sp ; )	| $3a :  Definicion
	$23 =? ( drop defvar >>sp ; )	| $23 #  Variable
	$22 =? ( drop ,str ; )		| $22 "	 Cadena
	|$27 =? ( drop ,token ; )	| $27 ' Direccion
	drop
	,token ;

:inc2src
	codeinc swap 3 << + @ ;

:translatecode | n -- n ; B=dicc
	0 'state ! 0 'xc ! 0 'yc ! | reset src
	0 'tokenc !
	dup inc2src | src
	dup 'srcini !
	( wrd2token 1? ) drop
	;
	
:buildshowincode
| make memory map
	here 
	dup 'codeinc ! 
	cntinc 1+ 3 << +
	dup 'codedicc ! dup 'codedicc> !
	cntdicc 3 << +
	dup 'codesrc ! dup 'codesrc> !
	memc 3 << +
	'here !

| load src includes
	codeinc >a
	strinc 
	0 ( cntinc <? swap
		here dup a!+ 
		|over load 0 swap c!+ 'here !
		over load 0 swap c! here only13 'here !
		>>0 swap 1+ ) 2drop
	here dup a!+
	|'filename load 0 swap c!+ 'here !
	'filename load 0 swap c! here only13 'here !
	
| every include+main
	realdicc >b | dicc
	cshare 4 + >a | tokencode
	0 ( cntinc <=? 
		translatecode
		1+ ) drop
	|waitkey
	;


|-------------------------------------
#statusline * 256
#errorst 0

:slnormal
	.cl	4 .bc 7 .fc cols .nsp
	" ^[7mF3^[27m Step ^[7mF5^[27m Over ^[7mF5^[27m Run/Stop ^[7m F9 ^[27m End " .printe
	'statusline strcpybuf ;
	
:runtimerror
	vmState 8 >> 'errorst !
	0 vshare !
	-1 vshare 2 3 << + +! ||-1 vmIP +!
	
	.cl 15 .fc 1 .bc cols .nsp
	errorst " * RUNTIME ERROR: %h * " .print 
	'statusline strcpybuf ;
	
|-------------------------------------
#labelfilename * 256

:showcode | n --
	codenow =? ( drop ; ) 
	dup 'codenow !
	inc2src TuLoadMemC 
	0 'labelfilename c! | build label
	codenow cntinc <? ( 
		strinc over n>>0 'labelfilename strcpy
		" > " 'labelfilename strcat
		) drop
	'filename 'labelfilename strcat ;
	

|-------------------------------------
#cm -1

:remake
	dup 'cm ! 
	dup 48 >> $ff and showcode
	dup 24 >> $ffff and fuente + tuipos!
|	tuiecursor!	
	;

:drawcm
	3 .bc 0 .fc |1 .bc 7 .fc
	codesrc vmIP 1- 3 << + @ 
	cm <>? ( remake )
	tokenCursor
	;
	
:play/stop
	vmstate	1 =? ( drop *>stop ; ) drop *>play ;

|---- main	
:maindb
	.reset .cls
	
	1 flxN
	4 .bc 7 .fc
	fx fy .at fw .nsp
	" R3debug | " .write 'labelfilename .write
	
	1 flxS
	fx fy .at
	'statusline .write
	
	vmSTATE " >>%H<<" .PRINT	
|	cm $fff and " %d " .print

	7 flxS |tuWina $1 "Imm" .wtitle |242 .bc
	scrMsg
	
	30 flxE |tuWina $1 "Imm" .wtitle |242 .bc
	scrTokens
	
	|cols 3 / flxO 
	|scrDicc
	
	flxRest 
	tuReadCode 
	|tuEditCode 
	msec $100 and? ( drawcm ) drop 
	
	uiKey
	[f3] =? ( *>step )
	[f4] =? ( *>stepo )
	[f5] =? ( play/stop )
	
	[f9] =? ( *>end )
	drop 
	vmState $ff >? ( runtimerror ) drop
	;
	
:main
	run&loadinfo

|---- conect sharde memory
	memdsize 'dshare 16 + !		| data mem size
	memcsize 'cshare 16 + !		| code mem size
	
	'vshare inisharev
	'bshare inisharev
	'dshare inisharev
	'cshare inisharev
	precalc

|---- build code links
	|makelistwords
	|buildcodemark
	
	buildshowincode
	cntinc showcode
	
	slnormal
|---- run debug	
	'maindb onTuia
	
|----- end all	
	*>end

	'cshare endsharev
	'dshare endsharev
	'bshare endsharev
	'vshare endsharev
	;

: 
	.alsb 
	'filename "mem/menu.mem" load
|	"r3/d4/test.r3" 'filename strcpy
	
	main
	.masb .free ;