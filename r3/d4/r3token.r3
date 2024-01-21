| r3d4 tokenizer
| convert source code in exec tokens

| PHREDA 2024
|------------------
^r3/d4/r3map.r3
^r3/d4/r3vmd.r3

|---- dicc
| info1
| $..............01 - code/data
| $..............02 - loc/ext
| $..............04	1 es usado con direccion
| $..............08	1 r esta desbalanceada		| var cte
| $..............10	0 un ; 1 varios ;
| $..............20	1 si es recursiva
| $..............40	1 si tiene anonimas
| $..............80	1 termina sin ;
| $............ff.. flag2
| $......ffffff....	-> tok+ -> code
| $ffffff.......... -> src+ -> src
|
| info2
| $..............ff - Data use		255
| $............ff.. - Data delta	-128..127
| $........ffff.... - calls			64k
| $ffffffff........ - len

|-------------------------------------------
|-------------------------------- includes
:escom
|WIN|	"WIN|" =pre 1? ( drop 4 + ; ) drop | Compila para WINDOWS
|LIN|	"LIN|" =pre 1? ( drop 4 + ; ) drop | Compila para LINUX
|MAC|	"MAC|" =pre 1? ( drop 4 + ; ) drop | Compila para MAC
|RPI|	"RPI|" =pre 1? ( drop 4 + ; ) drop | Compila para RPI
    >>cr ;

:includepal | str car -- str'
	$7c =? ( drop escom ; )		| $7c |	 Comentario
	$22 =? ( drop >>str ; )		| $22 "	 Cadena
	drop >>sp ;
	
:ininc? | str -- str adr/0
	'inc ( inc> <?
		@+ pick2 =s 1? ( drop ; ) drop
		8 + ) drop 0 ;

:realfilename | str -- str
	"." =pre 0? ( drop "%l" sprint ; ) drop
	2 + 'r3path "%s/%l" sprint ;

:rtrim | str -- str
	dup ( c@+ 1? drop ) drop 2 -
	( dup c@ $ff and 33 <? drop 1 - ) drop
	0 swap 1 + c! ;
	
:load.inc | str -- str newsrc ; incluye codigo
	here over realfilename rtrim 
	dup filexist 0? ( nip
			pick2 "Include not found" error!
			; ) drop
	load 0 swap c!
	here dup only13 'here !
	;

|*** need recursion detection!!
:includes | filename src -- filename
	dup ( trimcar 1?					| src src' char
		( $5e =? drop 					| $5e ^  Include
			ininc? 0? ( drop
				load.inc 0? ( drop ; )	| no existe
				includes
				error 1? ( drop ; ) drop
				dup ) drop
			>>cr trimcar )
		includepal ) 2drop
	over inc> !+ !+ 'inc> ! 
	;
	
|-------------------------------------------
|-------------------------------- 1pass
:iscom | adr -- 'adr
|WIN|	"WIN|" =pre 1? ( drop 4 + ; ) drop | Compila para WINDOWS
|LIN|	"LIN|" =pre 1? ( drop 4 + ; ) drop | Compila para LINUX
|MAC|	"MAC|" =pre 1? ( drop 4 + ; ) drop | Compila para MAC
|RPI|	"RPI|" =pre 1? ( drop 4 + ; ) drop | Compila para RPI
|	"MEM" =pre 1? ( drop				| MEM 640
|		4 +
|		trim str>nro 'switchmem !
|		>>cr ; ) drop
    >>cr ;
	
:isstr | adr -- 'adr
	1 + | skyp "
	( c@+ 1? 
		1 'cntstr +! 
		34 =? ( drop c@+ 34 <>? ( drop 1- ; ) ) 
		drop ) drop ;
	
:wrd2dicc
	( dup c@ $ff and 33 <?
		0? ( nip ; ) drop 1+ )	| trim0
	$7c =? ( drop iscom ; )	| $7c |	 Comentario
	$5e =? ( drop >>cr ; )	| $5e ^  Include
	$3A =? ( drop 1 'cntdef +! >>sp ; )	| $3a :  Definicion
	$23 =? ( drop 1 'cntdef +! >>sp ; )	| $23 #  Variable
	1 'cnttok +!
	$22 =? ( drop isstr ; )	| $22 "	 Cadena
	drop >>sp ;

| traverse code, calc sizes
:pass1
	0 'cntdef !
	0 'cnttok !
	0 'cntstr !
	'inc ( inc> <?				| every include
		8 + @+
		( wrd2dicc 1? ) drop
		1 'cnttok +! | +1 jump for boot sequence
		) drop ;

|-------------------------------------------	
|-------------------------------- 2pass
| token format
| ..............ff token nro
| ffffff.......... adr to src
| ......ffffffff.. value

#sst * 512 	| stack for blocks and count
#sst> 'sst

:sst!	sst> d!+ 'sst> ! ;
:sst@   -4 'sst> +! sst> d@ ;
:level 	sst> 'sst xor ;	

#flag		| current flag for word

#codeini 	| for calc token len
#iswhile	| flag for IF/WHILE
#endcnt		| count ;

:,qv	fmem> !+ 'fmem> ! ;
:,dv	fmem> d!+ 'fmem> ! ;
:,cv	fmem> c!+ 'fmem> ! ;
:,tv	'fmem> +! ;

#gmem ',qv | data 

:,t | src nro -- src
	over src - 40 << or		| store src pointer
	tok> !+ 'tok> ! ;
	
:emptyvar
	flag 1 nand? ( drop ; ) drop | only var
	0 ,qv ;
	
:callend
	flag 1 and? ( drop ; ) drop | only code
	
	tok> codeini - 3 >> | code_length
	32 <<
	dic> 8 - ! | info in wordnow
	endcnt
	0? ( $80 'flag +! )
	1 >? ( $10 'flag +! )
	drop ;
	
:endef
	level 1? ( over "missing )" error! ) drop
	tok> codeini - 0? ( emptyvar ) drop	| no token in def
	codeini 1? ( callend ) drop	
|callend	|??
	tok> 'codeini !
	flag 
	dic> 16 - +! | store flag
	;
	
:boot>>! | src char -- src char
	boot>> +? ( 
		pick2 8 << 2 or ,t | call prev 
		) drop 
	dic> dic - 4 >> 'boot>> ! ;
	
:.def 
	endef
	0 'flag !
	0 'endcnt !
	1 + dup c@
	$3A =? ( 2 'flag ! swap 1 + swap ) 	|::
	33 <? ( boot>>! ) | : alone
	drop
	dup src - 40 << 
	tok> tok - 3 >> 16 << or
	dic> !+ 0 swap !+ 'dic> !
	>>sp ;

:.var 
	endef
	1 'flag !
	1 + dup c@
	$23 =? ( 3 'flag ! swap 1 + swap ) 	|##
	drop
	',qv 'gmem ! 			| save qword default
	dup src - 40 << 
	tok> tok - 3 >> 16 << or
	dic> !+ 
	fmem> fmem - 32 << | start free memory for vars
	swap !+ 'dic> !
	>>sp ;
	
|  0     1    2     3     4    5     6
| .lits .lit .word .wadr .var .vadr .str ...
	
:.strvar | adr -- adr'
	1 +  | skip "
	fmem> strm - 8 << 6 or ,t | ** check
	fmem> >a
	( c@+ 1? 
		dup ca!+
		34 =? ( drop c@+ 
			34 <>? ( 2drop 0 a> 1- c!+ 'fmem> ! ; ) 
			) drop 
		) drop 
	"unfinish str" error!
	0
	;
	
:.str 
|	flag 1 and? ( drop .strvar ; ) drop | only var
	1 + | skip "
	strm> strm - 8 << 6 or ,t 
	strm> >a
	( c@+ 1? 
		dup ca!+
		34 =? ( drop c@+ 
			34 <>? ( drop 0 a> 1- c!+ 'strm> ! 1- ; ) 
			) drop 
		) drop 1 - 
	"str not close" error!
	;
	
:.nrovar
	0 ,t 
|	dup "<%w>" .println
	dup str>anro nip gmem ex
	>>sp ;
	
:.nro 
	flag 1 and? ( drop .nrovar ; ) drop | only var
	dup str>anro nip
	dup 32 << 32 >> =? ( 
		$ffffffff and 8 << 1 or ,t 
		>>sp ; ) drop
	0 ,t	| src token, bit literal
	>>sp ;
	
|----------
:blockIn
	tok> tok - 3 >> sst! ;

:cond | atok' tok -- atok'
	dup $ff and
	$c <? ( 2drop ; ) | 0?..
	$1f >? ( 2drop ; ) | ..bt?
	drop
	dup 8 >> $ffffffff and 1? ( 2drop ; ) drop | no jump
	tok> pick2 - 8 + $ffffffff and 8 << or | saltar a tok>
	over 8 - !	| add adr to ??
	1 'iswhile !
	;

:blockOut | tok n -- tok
	0 'iswhile !
	sst@ 3 << tok + 
	tok> 			| src n from to
	over 8 + ( over <? @+ 	|** need skip []!
		cond ) 2drop 	
	iswhile 1? ( drop
		tok> - $ffffffff and 8 << swap 
		6 + or ,t >>sp
		; ) drop 
	8 - dup @ 
	tok> pick2 - 8 << or | jump if
	swap !
	6 + ,t >>sp  | load tok**
	;

|**** need push/pop flags for words
:anonIn
	tok> tok - 3 >> sst! 
	;
	
:anonOut
	flag $40 or 'flag !
	-1 'endcnt +!
	tok> 8 - @ $ff and 7 <>? ( | 7 = ;
		pick2 "need ; in ]" error!
		) drop
	sst@ 3 << tok + | tok[
	tok> over - 8 - 8 << over @ or over !
	8 + 8 << swap 6 + or ,t >>sp ;

	
:.basevar | adr nro -- adr
	dup 6 + ,t 
	2 =? ( drop ',cv 'gmem ! >>sp ; )	| (
	3 =? ( drop ',qv 'gmem ! >>sp ; )	| )
	4 =? ( drop ',dv 'gmem ! >>sp ; )	| [
	5 =? ( drop ',qv 'gmem ! >>sp ; )	| ]
	43 =? ( drop ',tv 'gmem ! >>sp ; )	| *
	drop
	"base in var" error!
	0
	;
	
:.base | adr nro -- adr
	flag 1 and? ( drop .basevar ; ) drop	| var
	1 =? ( 1 'endcnt +! )
	2 =? ( blockIn )	| (
	3 =? ( blockOut ; )	| )
	4 =? ( anonIn ) 	| [
	5 =? ( anonOut ; )	| ]
	6 + ,t >>sp 
	;
	
	
:.wordinvar | adr nro -- adr
	1 - dup 4 << dic + 
	@ 1 and? ( drop 
		dup 4 << dic + 8 + @ 32 >>> fmem + ,qv 
		8 << 5 or ,t >>sp ; ) drop 
	dup 4 << dic + @ dic>tok ,qv
	8 << 3 or ,t >>sp ; 
	
:.word | adr nro -- adr
	flag 1 and? ( drop .wordinvar ; ) drop	| in var always adr
	1 - dup 4 << dic + 
	dic> 16 - =? ( flag $20 or 'flag ! )	| recursive
	@ 
	dup $ff00 and flag or 'flag ! | copy flag2 to current word
	1 and? ( drop 8 << 4 or ,t >>sp ; ) | data
	drop 8 << 2 or ,t >>sp ; | code
	
:.adr | adr nro -- adr
	flag 1 and? ( drop .wordinvar ; ) drop	| in var always adr
	1 - dup 4 << dic +
	@ 1 and? ( drop 8 << 5 or ,t >>sp ; ) | adata
	drop 8 << 3 or ,t >>sp ; | acode
	
:wrd2token | str -- str'
	( dup c@ $ff and 33 <?
		0? ( nip ; ) drop 1+ )	| trim0
|	over "%w " .print |** debug
	$5e =? ( drop >>cr ; )	| $5e ^  Include
	$7c =? ( drop >>cr ; )	| $7c |	 Comentario
	$3A =? ( drop .def ; )	| $3a :  Definicion
	$23 =? ( drop .var ; )	| $23 #  Variable
	$22 =? ( drop .str ; )	| $22 "	 Cadena
	$27 =? ( drop 			| $27 ' Direccion
		|dup ?base 1? ( drop "No Addr for base dicc" error! ; ) drop
		1+ 
		?word 1? ( .adr ; ) drop
		1 - "addr not exist" error!
		0 ; )
	drop
	dup isNro 1? ( drop .nro ; ) drop	| numero
	dup ?base 1? ( .base ; ) drop		| base
	?word 1? ( .word ; ) drop			| palabra
 	"word not found" error!
	0 ;

:contword | dic -- dic
	dup @ $81 and $80 <>? ( drop ; ) drop | code sin ;
	dup 24 + @
	$ffffffff00000000 and | len
	over 8 + +!
	;
	
:pass2	
	-1 'boot>> !
	'sst 'sst> !		| stack
	0 'codeini !
	'inc ( inc> <?		| every include
|		dup @ "%w<<" .println
		8 + @+ 
		( wrd2token 1? ) drop 
		|error 1? ( 2drop ; ) drop
		inc> 16 - <? ( dic> 'dic< ! ) | main source code mark
		) drop 
	callend
	| continue word need add lengths
	dic> 16 - ( dic >? 
		16 - contword ) drop	
	;
	
|-------------------------------------------	
|--------------------- pass 3 - tree calls
:+call! | dic -- dic
	$10000 over 8 + +! ;
	
:overcode | dc 'tok tok ctok -- dc 'tok xx xx
	drop tok>dic +call! 
	dup 8 + @ 16 >> $ffff and 1 >? ( ; ) | only 1 call traverse
	drop 
	rot !+ swap | add to dicc calls
	dup dup ;

:overdire | dc 'tok tok ctok -- dc 'tok xx xx
	drop tok>dic +call! 
	dup @ $4 or over !					| set adr flag
	dup 8 + @ 16 >> $ffff and 1 >? ( ; )	| only 1 call traverse
	drop 
	rot !+ swap | add to dicc calls
	dup dup ;
	
:rcode | dc word -- dc
	toklen		| dc tok len
	( 1? 1 - >r
		@+ dup $ff and | dup "%d" .println
		2 =? ( overcode ) | word
		3 =? ( overdire ) | adr
		4 =? ( overcode ) | var
		5 =? ( overdire ) | adr
		2drop r> ) 2drop ;

:rdata | stack nro -- stack
	toklend 
	( 1? 1 - >r
		@+ dup $ff and |dup "%h " .print
		2 >=? ( 5 <=? ( overdire ) )
		2drop r> ) 2drop ;
		
:datacode | dc word -- dc
	dup @ 1 and? ( drop rdata ; ) drop rcode ;

:pass3	
	cntdef 1 -
	nro>dic +call!
	here !+
	( here >? | diccalls
		8 - dup @ datacode ) drop ;	

|-------------------------------------------
| pass 4 - static stack analisis
#usod
#deltad
#deltar
#cntfin
#pano		| anonima
#cano
#finlist 0 0 0 0 0 0 0 0 0 0
#lastdircode

:resetinfo | --
	0 'flag !
	'sst 'sst> !		| stack
	0 'pano ! 0 'cano ! 0 'cntfin !
	0 'usoD ! 0 'deltaD ! 0 'deltaR ! ;
:pushvar
	deltaD $ff and 8 << 
	usoD $ff and or 8 << 
	deltaR $ff and or
	sst! ;
:popvar
	sst@ 
	dup 56 << 56 >> 'deltaR !
	dup 8 >> $ff and 'usoD ! 
	40 << 56 >> 'deltaD ! ;
	
:dropvar
	sst@ drop ;

|------------------------------------------
:.blit 
:.lit
	;
:.code 
	dup 8 - @ tok>dic 8 + @ | get info2 from word
	dup $ff and neg deltaD swap - usoD min 'usoD ! 
	48 << 56 >> 'deltaD +!
	;
:.acode 
	dup 8 - @ 8 >> $ffffff and 'lastdircode ! ;
:.data 
:.adata 
:.str
	;
:.;
	pano 1? ( drop ; ) drop
	deltaD $ff and 8 << 
	usoD $ff and or 8 << 
	deltaR $ff and or
	cntfin 3 << 'finlist + !
	1 'cntfin +! ;
:.(
	pushvar ;
:.)
	popvar ;
:.[
	pushvar 1 'pano +! 1 'cano +! ;
:.]
	popvar -1 'pano +! 1 'deltad +! ; | push adr
:.??
	dup 8 - @ 24 << 32 >> over + 8 - 		| go to )
	@ 8 >> $ffffff and 0? ( drop ; ) drop	| IF -> do nothing
	dropvar pushvar ; 						| WHILE -> copy stack
:.ex
	lastdircode nro>dic 8 + @
	dup $ff and neg deltaD swap - usoD min 'usoD ! 
	48 << 56 >> 'deltaD +!
	;
	
#toklis 
.blit .lit .code .acode .data .adata .str
.; .( .) .[ .] 
.EX .?? .?? .?? .?? 
.?? .?? .?? .?? .?? .?? .?? .?? .?? 

|------------------------------------------
::tokeninfo | t --
	|dup "%h" .println .input
	$ff and dup r3ainfo
	c@+ deltaD swap - usoD min 'usoD !
	c@+ 'deltaD +!
	c@+ 'deltaR +!
	c@ $ff and flag or 'flag !
	25 >? ( drop ; )
	3 << 'toklis + @ ex
	;


:anacode | dic info1 --
	drop
	resetinfo
	dup toklen ( 1? 1 - swap
		@+ tokeninfo
		swap ) 2drop
	| store in dic
	flag 8 << 'flag !
	deltar 1? ( $08 'flag +! ) drop	| unbalanced R
	flag over @ or over !	| store flags2

	usod neg $ff and deltad $ff and 8 << or
	swap 8 + dup @ rot or swap ! | store stackmov
	;

:resetinfod | --
	;
	
:anadata | dic info1 --
	resetinfod
	2drop
	;
	
:StaticStackAnalisis
	dup @ 1 and? ( anadata ; ) anacode ;
	
::pass4
	0 ( cntdef <? 
		dup nro>dic StaticStackAnalisis
		1 + ) drop 
		;
	
|-------------------------------------------
::r3load | 'filename --
|-------------------------------------------
	0 0 error!
	
	dup 'filename strcpy
	dup 'r3path strpath
	
	here dup 'src !
	swap load 
	here =? ( "no source code" error! ; ) 
	0 swap c! 
	src only13 'here !
	
	'inc 'inc> ! 
	'filename src includes drop | load includes
	pass1			| calc sizes
	makemem			| reserve mem
	pass2			| tokenize code
	fmem> 'here !	| mark memory for vars
	pass3			| calc tree calls
|	pass4
|	.input
	;
	
	
