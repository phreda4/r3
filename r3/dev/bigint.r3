| biginteger
|PHREDA 2021
|-----------
^r3/win/console.r3
^r3/lib/mem.r3

#n 8
#nbig  0 0 0 0 0 0 0 0 | 512 bits

:big! | n 'b --
	2dup !
	8 +
	swap -? ( drop -1 7 fill ; ) drop
	0 7 fill ; 
	
	
:+big | n 'b --
	>a 
	dup $ffffffff and da@ + dup da!+ 32 >> swap 32 >> + | n carry
	dup $ffffffff and da@ + dup da!+ 32 >> swap 32 >> + | n carry
	dup $ffffffff and da@ + dup da!+ 32 >> swap 32 >> + | n carry
	dup $ffffffff and da@ + dup da!+ 32 >> swap 32 >> + | n carry
	dup $ffffffff and da@ + dup da!+ 32 >> swap 32 >> + | n carry
	dup $ffffffff and da@ + dup da!+ 32 >> swap 32 >> + | n carry
	dup $ffffffff and da@ + dup da!+ 32 >> swap 32 >> + | n carry
	dup $ffffffff and da@ + dup da!+ 32 >> swap 32 >> + | n carry
	dup $ffffffff and da@ + dup da!+ 32 >> swap 32 >> + | n carry
	dup $ffffffff and da@ + dup da!+ 32 >> swap 32 >> + | n carry
	dup $ffffffff and da@ + dup da!+ 32 >> swap 32 >> + | n carry
	dup $ffffffff and da@ + dup da!+ 32 >> swap 32 >> + | n carry
	dup $ffffffff and da@ + dup da!+ 32 >> swap 32 >> + | n carry
	dup $ffffffff and da@ + dup da!+ 32 >> swap 32 >> + | n carry
	dup $ffffffff and da@ + dup da!+ 32 >> swap 32 >> + | n carry
	dup $ffffffff and da@ + dup da!+ 32 >> swap 32 >> + | n carry
	;

:+carry | a b -- c carry
	2dup + swap over - pick2 - 1? ( 1 nip ) ;

:+big | n 'b --
	>a
	a@ +carry swap a!+
	a@ +carry swap a!+
	a@ +carry swap a!+
	a@ +carry swap a!+
	a@ +carry swap a!+
	a@ +carry swap a!+
	a@ +carry swap a!+
	a@ +carry swap a!+ drop ;

:b+big | 'b 'b --
	>a >b
	a@ b@+ +carry swap a!+
	a@ + b@+ +carry swap a!+
	a@ + b@+ +carry swap a!+
	a@ + b@+ +carry swap a!+
	a@ + b@+ +carry swap a!+
	a@ + b@+ +carry swap a!+
	a@ + b@+ +carry swap a!+
	a@ + b@+ +carry swap a!+ drop ;
	
:-big | n 'b --
	;
:*big | n 'b --
	;
:/big | n 'b --
	;
	
:modbig | n 'b --
	;
	
:cpybig | bsrc bdst --
	;
	
:str>big | "1234" 'big --
	0 'n ! 
	trim dup c@ $2c =? ( 1 'n ! swap 1 + swap ) drop
	;

:big>dec | 'big mem --
	;

:bigfac | nro 'big --
	2dup big!
	swap
	( 1 - 1?
		dup pick2 *big 
		) 2drop  ;
	
:.bigprint | 'big --
	@+ "%d " .print
	@+ "%d " .print
	@+ "%d " .print
	@+ "%d " .print
	@+ "%d " .print
	@+ "%d " .print
	@+ "%d " .print
	@ "%d " .println ;
	
#result * 64 | 512 bits		
:
	.cls 
	
	'result .bigprint
	33 'result big!
	'result .bigprint

	-33 'result big!
	'result .bigprint
	
	34 'result +big
	'result .bigprint
	
|	100 'result bigfac 
	
	mark
|	'result here big>dec
	empty
|	here .println

	.input
	;
	
	
