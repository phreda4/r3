| r3d4 tokenizer
| convert source code in exec tokens

| PHREDA 2024
|------------------
^r3/d4/r3map.r3
^r3/d4/r3vmd.r3

|--------------------------------
:error! | adr "" --
	'error ! 'lerror ! ;

#sst * 256 	| stack of blocks
#sst> 'sst
:sst!	sst> w!+ 'sst> ! ;
:sst@   -2 'sst> +! sst> w@ ;
:level 	sst> 'sst xor ;	

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
|	$5e =? ( drop isinc ; )	| $5e ^  Include
	$3A =? ( drop 1 'cntdef +! >>sp ; )	| $3a :  Definicion
	$23 =? ( drop 1 'cntdef +! >>sp ; )	| $23 #  Variable
	1 'cnttok +!
	$28 =? ( over 1 + c@ 33 <? ( 1 'cntblk +! ) drop )		| $28 (_
	$5b =? ( over 1 + c@ 33 <? ( 1 'cntblk +! ) drop )		| $5b [_
	$22 =? ( drop isstr ; )	| $22 "	 Cadena
	drop >>sp
	;

:str2pass1
	0 'state !
	( wrd2dicc 1? ) drop ;

|--- 1 pass, traverse code, calc sizes

:pass1
	0 'cntdef !
	0 'cnttok !
	0 'cntstr !
	'inc ( inc> <?				| every include
		8 + @+ str2pass1
		1 'cnttok +! | +1 jump for boot sequence
		) drop ;

		
|-------------------------------- 2pass

:.inc >>cr ;
:.com >>cr ;

|------- data
:,dataq | nro --
	fmem> !+ 'fmem> ! ;
:,datad | nro --
	fmem> d!+ 'fmem> ! ;
:,datab | nro --
	fmem> c!+ 'fmem> ! ;
:,datat | nro --
	'fmem> +! ;
	
#,dtipo	

:invarstr | adr -- adr'
	1 'datac +!
	fmem> >a
	( c@+ 1? 
		dup ca!+
		34 =? ( drop c@+ 
			34 <>? ( 2drop 0 a> 1- c!+ 'fmem> ! ; ) 
			) drop 
		) drop 
	"unfinish str" error!
	;

:invarnro
	1 'datac +!
	str>anro
	,dtipo ex ;

:invarbase | adr nro -- adr
	2 =? ( drop ',datab ',dtipo ! ; )	| (
	3 =? ( drop ',dataq ',dtipo ! ; )	| )
	4 =? ( drop ',datad ',dtipo ! ; )	| [
	5 =? ( drop ',dataq ',dtipo ! ; )	| ]
	43 =? ( drop ',datat ',dtipo ! ; )	| *
|	dup "base:%d" .println
	drop
	dup "base in var" error!
	0
	;

|------- code

| token format
| ..............ff token nro
| ffffff.......... adr to src
| ......ffffffff.. value


:,t | src nro -- src
|	dup ":%h" .println
	over src - 40 << or
	tok> !+ 'tok> ! ;
	
:endef
	level 1? ( over "bad Block ( )" error! ) drop
	state 2 <>? ( drop ; ) drop
	datac 1? ( drop ; ) drop
	0 ,dataq | #a :b converto to #a 0 :b
	;
	
:boot>>! | src char -- src char
	boot>> +? ( 
		pick2 8 << 2 or ,t | call prev 
		) drop 
	dic> dic - 4 >> 'boot>> ! ;
	
:.def 
	endef
	0 'flag !
	dup 1+ c@
	$3A =? ( 2 'flag ! ) 	|::
	33 <? ( boot>>! ) | : alone
	drop
	
	dup src - 1 + flag 1 >> + 40 << 	| skip : or ::
	tok> tok - 3 >> 8 << or
	flag or
	dic> !+ 0 swap !+ 'dic> !

	1 'state ! >>sp ;

:.var 
	endef
	1 'flag !
	dup 1+ c@
	$23 =? ( 3 'flag ! ) 			|##
	drop
	
	dup src - 1 + flag 1 >> + 40 << | skip # or ##
	fmem> fmem - 8 << or
	flag or
	dic> !+ 0 swap !+ 'dic> !
	
	',dataq ',dtipo !
	0 'datac !
	2 'state ! >>sp ;

	
|    1    2     3    4    5
| 0 .lit .word .adr .var .str ...
	
:.str 
	1 + | skip "
	state 2 =? ( drop invarstr ; ) drop
	strm> strm - 8 << 5 or ,t 
	strm> >a
	( c@+ 1? 
		dup ca!+
		34 =? ( drop c@+ 
			34 <>? ( drop 0 a> 1- c!+ 'strm> ! 1- ; ) 
			) drop 
		) drop 1 - 
	"str not close" error!
	;
		
:.nro 
	state 2 =? ( drop invarnro ; ) drop
	str>anro 
	dup 32 << 32 >> =? ( 
		$ffffffff and 8 << 1 or ,t 
		>>sp ; ) 
 	fmem> fmem - 8 << 4 or ,t 
	,dataq  | big value in gost var **		
	>>sp ;
	
|---------------------------------
#iswhile

:blockIn
	tok> tok - 3 >> sst! ;

:cond | atok' tok -- atok'
	dup $ff and
	$b <? ( 2drop ; ) | 0?..
	$1e >? ( 2drop ; ) | ..bt?
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
	over 8 + ( over <? @+ 
		cond ) 2drop 	
	iswhile 1? ( drop
		tok> - $ffffffff and 8 << swap 
		5 + or ,t >>sp
		; ) drop 
	8 - dup @ 
	tok> pick2 - 8 << or | jump if
	swap !
	5 + ,t >>sp 	
	;

:anonIn
	tok> tok - 3 >> sst! ;
	
:anonOut
	sst@ 3 << tok + | tok[
	tok> over - 8 - 8 << over @ or over !
	8 + 8 << swap 5 + or ,t >>sp ;
	
:.base | adr nro -- adr
	state 2 =? ( drop invarbase >>sp ; ) drop	
	2 =? ( blockIn )	| (
	3 =? ( blockOut ; )	| )
	4 =? ( anonIn )		| [
	5 =? ( anonOut ; )	| ]
	5 + ,t >>sp ;
	
:.word | adr nro -- adr
	1 - dup 4 << dic + @ 
	1 and? ( nip $ffffffff00 and 4 or ,t >>sp ; ) drop | var
	8 << 2 or ,t >>sp ;
	
:.adr | adr nro -- adr
	1 - 8 << 3 or ,t >>sp ;
	
:wrd2token | str -- str'
	( dup c@ $ff and 33 <?
		0? ( nip ; ) drop 1+ )	| trim0
|	over "%w " .print |** debug
	$5e =? ( drop .inc ; )	| $5e ^  Include
	$7c =? ( drop .com ; )	| $7c |	 Comentario
	$3A =? ( drop .def ; )	| $3a :  Definicion
	$23 =? ( drop .var ; )	| $23 #  Variable
	$22 =? ( drop .str ; )	| $22 "	 Cadena
	$27 =? ( drop 			| $27 ' Direccion
		|dup ?base 1? ( drop "No Addr for base dicc" error! ; ) drop
		1+ 
		?word 1? ( .adr ; ) drop
|		?iword +? ( .iadr ; ) drop
		1- "addr not exist" error!
		0 ; )
	drop
	dup isNro 1? ( drop .nro ; ) drop	| numero
	dup ?base 1? ( .base ; ) drop		| base
	?word 1? ( .word ; ) drop			| palabra
|	?iword +? ( .iword ; ) drop			| palabra externa
 	"word not found" error!
	0 ;

:str2pass2 | str --
	'sst 'sst> !		| reuse stackblock
	0 'state !	
	( wrd2token 1? ) drop ;	

:pass2	
	-1 'boot>> !
	'inc ( inc> <?			| every include
|		dup @ "%w" .println
		8 + @+ str2pass2
		error 1? ( 2drop ; ) drop
		inc> 16 - <? ( dic> 'dic< ! ) | main source code mark
		) drop ;
		
|---------------------
::r3load | 'filename --
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
	
|	.input
	
	fmem> $ff + 'here ! | 256bytes free mem
|	error 0? ( drop ; )	.println
|	lerror "%l" .println
	
	;
	

