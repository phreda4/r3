| make map debug
| PHREDA 2026

|^r3/lib/console.r3
^r3/lib/trace.r3
 
#vshare 0 0 4096 "/debug.mem"	| vm state
#bshare 0 0 256 "/bp.mem"		| breakpoint
#dshare 0 0 0 "/data.mem" 		| memdata
#cshare 0 0 0 "/code.mem" 		| codedata

::*>end		$fe vshare ! ;
::*>stop		$0 vshare ! ;
::*>play		$1 vshare ! ;
::*>step		$2 vshare ! ;
::*>stepo	$3 vshare ! ;

::vmSTATE	vshare @ ;
::vmINFO		vshare 1 3 << + @ ;
::vmIP		vshare 2 3 << + @ ;
::vmTOS		vshare 3 3 << + @ ;
::vmNOS		vshare 4 3 << + @ ;
::vmRTOS		vshare 5 3 << + @ ;
::vmREGA		vshare 6 3 << + @ ;
::vmREGB		vshare 7 3 << + @ ;
::vmDS		vshare 8 3 << + ;
::vmRS		vshare 512 3 << + ;


#tokenstr
";" "LIT1" "ADR" "CALL" "VAR"
"EX" 
"0?" "1?" "+?" "-?"
"<?" ">?" "=?" ">=?" "<=?" "<>?" "AND?" "NAND?" "IN?"
"DUP" "DROP" "OVER" "PICK2" "PICK3" "PICK4" "SWAP" "NIP" 
"ROT" "-ROT" "2DUP" "2DROP" "3DROP" "4DROP" "2OVER" "2SWAP" 
">R" "R>" "R@" 
"AND" "OR" "XOR" "NAND" 
"+" "-" "*" "/" 
"<<" ">>" ">>>" 
"MOD" "/MOD" "*/" "*>>" "<</" 
"NOT" "NEG" "ABS" "SQRT" "CLZ" 
"@" "C@" "W@" "D@" 
"@+" "C@+" "W@+" "D@+" 
"!" "C!" "W!" "D!" 
"!+" "C!+" "W!+" "D!+" 
"+!" "C+!" "W+!" "D+!" 
">A" "A>" "A+" 
"A@" "A!" "A@+" "A!+" 
"CA@" "CA!" "CA@+" "CA!+" 
"DA@" "DA!" "DA@+" "DA!+" 
">B" "B>" "B+" 
"B@" "B!" "B@+" "B!+" 
"CB@" "CB!" "CB@+" "CB!+" 
"DB@" "DB!" "DB@+" "DB!+" 
"AB[" "]BA" 
"MOVE" "MOVE>" "FILL" 
"CMOVE" "CMOVE>" "CFILL" 
"DMOVE" "DMOVE>" "DFILL" 
"MEM" 
"LOADLIB" "GETPROC" 
"SYS0" "SYS1" "SYS2" "SYS3" "SYS4" "SYS5" 
"SYS6" "SYS7" "SYS8" "SYS9" "SYS10"
"JMP" "JMPR" "LIT2" "LIT3" "LITF" 
"AND_L" "OR_L" "XOR_L" "NAND_L" 
"+_L" "-_L" "*_L" "/_L" 
"<<_L" ">>_L" ">>>_L" 
"MOD_L" "/MOD_L" "* /_L" 
"*>>_L" "<</_L" 
"*>>16_L" "<<16/_L" 
"*>>16" "<<16/" 
"<?_L" ">?_L" "=?_L" ">=?_L" "<=?_L" "<>?_L" "AN?_L" "NA?_L" 
"<<>>_" ">>AND_" 
"+@_" "+C@_" "+W@_" "+D@_" 
"+!_" "+!C_" "+!W_" "+!D_" 
"1<<+@" "2<<+@" "3<<+@" 
"1<<+@C" "2<<+@C" "3<<+@C" 
"1<<+@W" "2<<+@W" "3<<+@W" 
"1<<+@D" "2<<+@D" "3<<+@D" 
"1<<+!" "2<<+!" "3<<+!" 
"1<<+!C" "2<<+!C" "3<<+!C" 
"1<<+!W" "2<<+!W" "3<<+!W" 
"1<<+!D" "2<<+!D" "3<<+!D" 
"AA1" "BA1" 
"av@" "avC@" "avW@" "avD@" 
"av@+" "avC@+" "avW@+" "avD@+" 
"av!" "avC!" "avW!" "avD!" 
"av!+" "avC!+" "avW!+" "avD!+" 
"av+!" "avC+!" "avW+!" "avD+!" 
"v@" "vC@" "vW@" "vD@" 
"v@+" "vC@+" "vW@+" "vD@+" 
"v!" "vC!" "vW!" "vD!" 
"v!+" "vC!+" "vW!+" "vD!+" 
"v+!" "vC+!" "vW+!" "vD+!" 

#tokenstra * 512

#tokencnt (
0 0 0 0 0
0
0 0 0 0 |"0?" "1?" "+?" "-?"
0 0 0 0 0 0 0 0 0 |"<?" ">?" "=?" ">=?" "<=?" "<>?" "AND?" "NAND?" "IN?"
0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0
0 0 0
0 0 0 0
0 0 0 0
0 0 0
0 0 0 0 0
0 0 0 0 0
0 0 0 0
0 0 0 0
0 0 0 0
0 0 0 0
0 0 0 0
0 0 0
0 0 0 0
0 0 0 0
0 0 0 0
0 0 0
0 0 0 0
0 0 0 0
0 0 0 0
0 0 
0 0 0
0 0 0
0 0 0
0
0 0 
1 1 1 1 1 1 |"SYS0" "SYS1" "SYS2" "SYS3" "SYS4" "SYS5" 
1 1 1 1 1 |"SYS6" "SYS7" "SYS8" "SYS9" "SYS10"
1 -1 -1 -1 1 |"JMP" "JMPR" "LIT2" "LIT3" "LITF" 
1 1 1 1 |"AND_L" "OR_L" "XOR_L" "NAND_L" 
1 1 1 1 |"+_L" "-_L" "*_L" "/_L" 
1 1 1 |"<<_L" ">>_L" ">>>_L" 
1 1 1 |"MOD_L" "/MOD_L" "*/_L" 
1 1 |"*>>_L" "<</_L" 
2 2 |"*>>16_L" "<<16/_L" 
1 1 |"*>>16" "<<16/" 
1 1 1 1 1 1 1 1 |"<?_L" ">?_L" "=?_L" ">=?_L" "<=?_L" "<>?_L" "AN?_L" "NA?_L" 
3 3 |"<<>>_" ">>AND_" 
2 2 2 2 |"+@_" "+C@_" "+W@_" "+D@_" 
2 2 2 2 |"+!_" "+!C_" "+!W_" "+!D_" 
3 3 3 |"1<<+@" "2<<+@" "3<<+@" 
3 3 3 |"1<<+@C" "2<<+@C" "3<<+@C" 
3 3 3 |"1<<+@W" "2<<+@W" "3<<+@W" 
3 3 3 |"1<<+@D" "2<<+@D" "3<<+@D" 
3 3 3 |"1<<+!" "2<<+!" "3<<+!" 
3 3 3 |"1<<+!C" "2<<+!C" "3<<+!C" 
3 3 3 |"1<<+!W" "2<<+!W" "3<<+!W" 
3 3 3 |"1<<+!D" "2<<+!D" "3<<+!D" 
1 1 |"AA1" "BA1" 
1 1 1 1 |"av@" "avC@" "avW@" "avD@" 
1 1 1 1 |"av@+" "avC@+" "avW@+" "avD@+" 
1 1 1 1 |"av!" "avC!" "avW!" "avD!" 
1 1 1 1 |"av!+" "avC!+" "avW!+" "avD!+" 
1 1 1 1 |"av+!" "avC+!" "avW+!" "avD+!" 
1 1 1 1 |"av@" "avC@" "avW@" "avD@" 
1 1 1 1 |"av@+" "avC@+" "avW@+" "avD@+" 
1 1 1 1 |"av!" "avC!" "avW!" "avD!" 
1 1 1 1 |"av!+" "avC!+" "avW!+" "avD!+" 
1 1 1 1 |"av+!" "avC+!" "avW+!" "avD+!" 

| make tokenstra for fast resolve names
::buildtokenstr
	'tokenstra
	'tokenstr ( 'tokenstra <?
		dup 'tokenstr - rot w!+ swap >>0 ) 2drop ;
		
::.tokenslow | value -- str
	'tokenstr swap $ff and n>>0 ;

::.token | value -- str
	$ff and 2* 'tokenstra + w@ 'tokenstr + ;
		
::token>cnt | value -- cnt
	$ff and 'tokencnt + c@ ;
	
##cntdicc ##localdicc
#boot
#memc #memd
#memdsize #memcsize
#memcode #memdata
##mdatastack ##mretstack
##cntinc ##strinc | includes in order
##realdicc

#codeinc
#codedicc #codedicc>
##codesrc ##codesrc>

	
|----
|DICC
|v=(inc<<56)|(pos<<40)|(dicc[i].mem<<8)|dicc[i].info;

::ndicc@ | n -- entry
	3 << realdicc + @ ;

|---- view dicc
::dicc>name | nd -- str
	40 >> $ffff and realdicc cntdicc 3 << + + ; | name word


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

::inc2src
	codeinc swap 3 << + @ ;

:translatecode | n -- n ; B=dicc
	0 'state ! 0 'xc ! 0 'yc ! | reset src
	0 'tokenc !
	dup inc2src | src
	dup 'srcini !
	( wrd2token 1? ) drop
	;

|------------------------------------
::makemapdebug
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
		|codesrc> over "%d %h" .println
		translatecode
		1+ ) drop
	|waitkey
	
	|codeinc <<memmap
	;

|---- aux info 
##dstackoff
##rstackoff
##dataoff

:precalc
	vmDS mdatastack - 8 + 'dstackoff !
	vmRS mretstack - 8 + 'rstackoff !
	dshare memdata - 'dataoff !
	;

::memtok
	2 << cshare + d@ .token ;
	
|------------------------------------
::run&loadinfo | "" --
	| ini loockup 
	buildtokenstr
	| start the server
	"mem/r3code.mem" delete
	"mem/r3dicc.mem" delete | "filename" --
	
	| start debug
	|'filename 
|WIN|	"cmd /c r3d ""%s""" sprint | only WIN for now
|LIN|	"./r3lind ""%s""" sprint
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
	|100 ms
	
|---- conect shared memory
	memdsize 'dshare 16 + !		| data mem size
	memcsize 'cshare 16 + !		| code mem size
	
	'vshare inisharev
	'bshare inisharev
	'dshare inisharev
	'cshare inisharev
	precalc
	;

|------------------------------------
::debugend
|----- end all	
	*>end

	'cshare endsharev
	'dshare endsharev
	'bshare endsharev
	'vshare endsharev
	;
	
|------------------------------------
::stoponerror
	0 vshare !
	-1 vshare 2 3 << + +! ||-1 vmIP +!
	vmState 8 >>
	;

|:printcode	
|	cshare >a
|	0 ( |memc |30 <? 
|		vmip =? ( .rever )
|		da@+ .token .write .sp
|		vmip =? ( .reset )
|		1+ ) drop ;

	|codesrc vmIP 1- 3 << + @ ":%h:" .print	
|	vmTOS	"TOS:%h " .print vmNOS	"NOS:%h " .print vmRTOS	"RTOS:%h " .print .cr
|	vmREGA	"A:%h " .print vmREGB	"B:%h | " .print 
|	cshare vmIP 2 << + d@ |codesrc + d@ .token .print 
|	vmDS	"DS:%h " .print vmRS	"RS:%h " .print 
	
|	cntdicc "cnddicc:%h " .print localdicc "localdicc:%h " .print
|	boot "boot:%h " .print memc "memc:%h " .print memd "memd:%h " .print
|	memdsize "mdsize:%h " .print memcsize "mcsize:%h " .print 
|	memcode "mcod:%h " .print memdata "mdat:%h " .print 
|	mdatastack "stack:%h " .print mretstack "rstack:%h " .print .cr
