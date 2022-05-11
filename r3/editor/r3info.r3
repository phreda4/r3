| r3debug
| PHREDA 2020
|------------------
^r3/win/console.r3

^r3/system/r3base.r3
^r3/system/r3pass1.r3
^r3/system/r3pass2.r3
^r3/system/r3pass3.r3
^r3/system/r3pass4.r3

#name * 1024
#namenow * 256

::r3debuginfo | str --
	r3name
	here dup 'src !
	'r3filename
	2dup load 
	here =? ( "no source code." .println ; )
	src only13 0 swap c!+ 'here !
	0 'error !
	0 'cnttokens !
	0 'cntdef !
	'inc 'inc> !
	swap	
	r3-stage-1 error 1? ( drop ; ) drop	
	r3-stage-2 1? ( drop ; ) drop 		
	r3-stage-3			
	r3-stage-4			
	;

:savedebug
	mark
	error ,s ,cr
	lerror src - ,d ,cr
	"mem/debuginfo.db" savemem
	empty ;

:emptyerror
 	0 0	"mem/debuginfo.db" save ;

|----------- SAVE INFOMAP
|	cntdef cnttokens cntinc "includes:%d tokens:%d definitions:%d" .println

:>>13 | a -- a
	( c@+ 1?
		13 =? ( drop ; ) 
		drop ) drop 1 - ;
	
:countlines | adr -- line
	0 src ( pick2 <? 
		>>13 swap 1 + swap ) 
	drop nip ;
	
:onlywords
	dup 16 + @ 1 and? ( drop 32 + ; ) drop | variable no graba
	@+ countlines 
	,q				| fff -nro de linea
	8 +
	@+ swap @+ 
	rot 32 << or 
	,q 				| info y mov<<32
	;
	
:savemap
	mark
	inc> 'inc -		| cantidad de includes
	dicc> dicc -	| cantidad de palabras
	swap 32 << or
	|,h ,cr
	,q
	
	dicc< ( dicc> <? | solo codigo principal
		onlywords ) drop

	"mem/infomap.db" savemem
	empty ;
	
|----------- SAVE DEBUG
:,printword | adr --
  	adr>toklen
	( 1? 1 - swap
		d@+
		dup $ff and "%h " ,print
		dup 8 >> 1? ( dup "%h " ,print ) drop
		,tokenprintc ,cr
		swap ) 2drop ;

:savedebugi
	mark
	"inc-----------" ,print ,cr
	'inc ( inc> <?
		@+ "%w " ,print
		@+ "%h " ,print ,cr
		) drop
	
	"dicc-----------" ,print ,cr
	dicc ( dicc> <?
		@+ "%w " ,print
		@+ "%h " ,print
		@+ "%h " ,print
		@+ "%h " ,print ,cr
		dup 32 - ,printword
		,cr ) drop
	
	"block----------" ,print ,cr
	blok cntblk ( 1? 1 - swap
		d@+ "%h " ,print
		d@+ "%h " ,print ,cr
		swap ) 2drop

	"mem/map.txt" savemem
	empty ;

|--------------------- BOOT
: 	
	'name "mem/main.mem" load drop
	'name r3debuginfo
	
	error 
	1? ( drop savedebug ; )
	drop
	
	emptyerror 
	savemap
	|savedebugi | save info in file for debug
	;

