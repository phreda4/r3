| r3-gendat
| PHREDA 2018
|
^./r3base.r3

:tok>dicn | nro -- adr
	8 >>> 5 << dicc + @ "%w" sprint ;

:tok>cte | tok -- nro
	8 >>> src +
	dup ?numero 1? ( drop nip nip ; ) drop
	str>fnro nip ;

:tok>str | tok -- str
	8 >>> src + ;

|------------ compila DATO
#d1 "dq "
#d2 "dd "
#d3	"db "
#d4 "rb "
#dtipo 'd1
#dini 0
#dcnt 0
#instr 0

:pasoinstr	| cuando hay un string en otro tipo
	,cr dtipo ,s 0 'dini ! 0 'instr ! ;

:stringdd | cuando hay string dentro de otro tipo
	dtipo 'd3 =? ( drop "," ,s ; ) drop
	,cr 'd3 ,s 1 'instr !
|	'd3 'dtipo !
	;

:dfin
	instr 1? ( drop pasoinstr ; ) drop
	dini 0 'dini ! 1? ( drop dtipo ,s ; )
	drop "," ,s ;
:dfins
	dini 0? ( drop stringdd ; ) drop
	'd3 ,s 0 'dini ! ;
:dfind
	instr 1? ( drop pasoinstr ; ) drop
	dini 0 'dini ! 1? ( 'd1 ,s drop ; ) "," ,s drop  ;

:dtipoch
	dini 1? ( drop ; ) drop
	,cr 1 'dini ! ;

:cpycad | adr --
	( c@+ 1? 34 =? ( dup ,c ) ,c ) 2drop ;

:cpycadsrc | adr --
	( c@+ 1? 34 =? ( drop c@+ 34 <>? ( 2drop ; )
		"""," ,s 34 ,c ",""" ,s
		) ,c ) 2drop ;

:stringwith0
	34 ,c here swap cpycadsrc here - 34 ,c drop ",0" ,s ;

:,ddefw
:,ddefv drop ;

:,dlit  1 'dcnt +!
|		dcnt $f and $f =? ( ,cr ) drop	| every 16
		dfin tok>cte
		-? ( ,d ; )
		"$" ,s ,h ;

:,dlits	1 'dcnt +!
		dfins tok>str stringwith0 ;

:,dwor	1 'dcnt +! dfind
		tok>dicname
		,s ;

:,d;	drop ;

:,d(	drop 'd3 'dtipo ! dtipoch ;
:,d)	drop 'd1 'dtipo ! dtipoch ;
:,d[	drop 'd2 'dtipo ! dtipoch ;
:,d]	drop 'd1 'dtipo ! dtipoch ;

:,d*	'd4 'dtipo ! dtipoch ;

#coded 0
,ddefw ,ddefw ,ddefv ,ddefv 0 0 ,dlit ,dlit ,dlit ,dlit ,dlits ,dwor ,dwor ,dwor ,dwor
,d; ,d( ,d) ,d[ ,d]

|----- data
:datastep
	dup $ff and
	21 <? ( 3 << 'coded + @ ex ; )
	58 =? ( ,d* ) | token *
	2drop  | vacio
	;

:gendata | adr --
	dup 16 + @ 1 nand? ( 2drop ; )	| data
	$8 and? ( 2drop ; ) 			| cte!!
	12 >> $fff and 0? ( 2drop ; )	| no calls
	drop

	'd1 'dtipo !
	1 'dini !
	0 'dcnt !
	0 'instr !

    ";--------------------------" ,s ,cr
    "; " ,s
	dup dicc - 5 >> ,datainfo ,cr

	dup adr>dicname ,s ,sp
	adr>toklen
	( 1? 1 - >r
		d@+ datastep
		r> ) 2drop
	dini 0? ( drop ,cr ; ) drop
	dcnt 1? ( drop ,cr ; ) drop
	dtipo ,s 0 ,d ,cr
	;


|----- string
:otrostr
	1 'dini !
	over 8 >>> "str%h " ,print
	over ,dlits
	,cr ;

:gendatastr | adr --
	dup 16 + @ 1 and? ( 2drop ; )	 | code
	12 >> $fff and 0? ( 2drop ; )	 | no calls
	drop

	adr>toklen
	( 1? 1 - swap
		d@+ dup $ff and
		11 =? ( otrostr ) 2drop
		swap ) 2drop ;

::r3-gendata
	mark
	";---r3 compiler data.asm" ,ln
	"; *** STRINGS ***" ,s ,cr

	dicc ( dicc> <?
		dup gendatastr
		32 + ) drop

	"; *** VARS ***" ,s ,cr
	"align 16 " ,s ,cr
	dicc ( dicc> <?
		dup gendata
		32 + ) drop

	0 ,c
	"asm/data.asm"
	savemem
	empty ;
