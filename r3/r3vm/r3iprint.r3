| r3 interactive
| experiment for make a r3computer like jupiter ace
| PHREDA 2021

^./r3ivm.r3
^./r3itok.r3

|------------------------
:,tokenl | nro dic -- str
	swap 2 << + @ code2name ,s ;

:,i16	drop @+ 48 << 48 >> "%d" ,print 2 - ;
:,i32	drop @+ "%d" ,print ;
:,b		INTWORDS - 'wbasdic ,tokenl ;
:,b16	INTWORDS - 'wbasdic ,tokenl 2 + ;
:,iCOM	drop c@+ over "|" ,s ,s ,cr $ff and + 1 - ;
:,iSTR	drop c@+ over 34 ,c ,s 34 ,c $ff and + 1 - ;
:,iCALL	drop @+ 8 - @ code2name ,s ;
:,iADR	drop @+ 8 - @ $3fffffff and code2name "'" ,s ,s ;

#,tokenp
,i16 ,i32 ,iSTR ,iCOM
,i16 ,i32 ,iCALL ,iADR ,iCALL
,b ,b ,b16 ,b16 ,b16		|";" "(" ")" "[" "]"
,b ,b16 ,b16 ,b16 ,b16	|"EX" "0?" "1?" "+?" "-?"
,b16 ,b16 ,b16 ,b16		|"<?" ">?" "=?" ">=?"
,b16 ,b16 ,b16 ,b16 ,b16 |"<=?" "<>?" "AND?" "NAND?" "BT?"

:,minilit | t --
	57 << 57 >> "%d" ,print  ;

::,token | adr -- adr'
	c@+
	$80 and? ( ,minilit ; )
	27 >? ( ,b ; )
	dup 2 << ',tokenp + @ ex ;

|------------------------
:defw
	code2name ":%s " ,print
	@+ $ffff and	| dir cant
	over +
	swap ( over <? ,token 32 ,c
		) 2drop ;

:defv0
	$3fffffff and code2name "#%s " ,print
	@+ $ffff and	| dir cant
	over +
	swap ( over <? @+ "$%h " ,print	| dword
		 ) 2drop ;

:defv1
	$3fffffff and code2name "#%s " ,print 
	@+ $ffff and	| dir cant
	over +
	swap ( over <? @+ 8 - @ code2name "'%s " ,print | adr
		 ) 2drop ;

:defv2
	$3fffffff and code2name "#%s " ,print
	@ $ffff and	| dir cant
	" * $%h" ,print ,cr ;

#deflist 'defw 'defv0 'defv1 'defv2

::,printdef | adr --
	@+ dup 30 >> $3 and 2 << 'deflist + @ ex ;

