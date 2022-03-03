| mini compressor
| PHREDA 2022
|---------------------------------------
| 0nnnnnnn - n literal number 
| n=1..128
| 1nnnnnnn oooooooo - n copy from o ofsset
| n=4..131
| o=1..256

^r3/lib/mem.r3

|---------- Decompress
	
:lit2 | adr --
	1 + ( 1? 1 - cb@+ ca!+ ) drop ;
	
:dec2pass
	cb@+ $80 nand? ( lit2 ; )
	$7f and 1 +
	a> cb@+ $ff and 1 + -
	swap ( 1? 1 -
		swap c@+ ca!+ swap ) 2drop ;

::minicdecode | 'adre adr dst -- dste
	>a >b
	( b> >? dec2pass ) drop
	a> ;
	
	
|--------- Compress
| new idea - original ??
| bcnt [byte] cnt of this byte in windows
| bfisrt [byte] last position of this byte
| bnext [position] next position of the byte in this position

#startmem
#posnow
#maxcnt
#maxoff

#bcnt * 256
#bfirst * 256
#bnext * 256

:setmap | byte --
	1 over 'bcnt + c+! 	| add 1 to cnt
	posnow 				| position
	swap 'bfirst + 
	dup c@ 				| byte pos bfirst prev --
	pick2 'bnext + c!
	c! 					| store first
	
	a> 256 - startmem <? ( drop ; )
	c@ $ff and
	-1 swap 'bcnt + c+! 	| remove from window
	;				
	
:compare | s1 s2 -- s1'
	( c@+ rot c@+ rot 
|		2dup "%h=%h " .println 
		=? drop swap ) drop nip ;
		
:testoff | pos -- pos cnt
	a> a> posnow pick3 - 
	-? ( 256 + )
	- compare a> - 
	;
	
:traverse | byte -- byte
	0 'maxcnt !
|	a> startmem - "%d " .print
|	dup "%h? " .print
	dup 'bcnt + c@ 0? ( drop ; ) | no hay
	over 'bfirst + c@ $ff and | byte cnt first
	( 
|		dup "%d-" .print
		testoff maxcnt >? ( over 'maxoff ! dup 'maxcnt ! ) drop
		swap 1 - 1? swap 
		'bnext + c@ $ff and  | byte cnt first
		) 2drop 
|	maxcnt " max:%d" .print cr 
	;
	
#adrfrom
#lenlit 

| encode literal
:enclit | len --
	0? ( drop ; )
|	dup "lit %d " .print
	dup 1 - cb!+ |"$%h " .print
	adrfrom swap 
	( 1? 1 - swap c@+ cb!+ swap ) drop
	'adrfrom ! ;

:enlit | --
	lenlit 0? ( drop ; ) 
	( 127 >? 
		128 enclit 
		128 - ) 
	enclit 
	0 'lenlit ! ;
	
:encpy | off cnt --
	( 127 >?
		127 $80 or cb!+ over cb!+
		128 - )
	0? ( 2drop ; )
	1 - $80 or cb!+ cb!+
	;
	
:runencode | i byte -- 
	maxcnt 4 <? ( drop 1 'lenlit +! setmap ; ) drop
	enlit 
	
	posnow maxoff - 
	-? ( 256 + ) 1 - 
	maxcnt 
	encpy
	
	setmap
	maxcnt 1 - ( 1? 1 -
		a> startmem - $ff and 'posnow !	
		ca@+ $ff and 
		setmap ) drop
|	dup "{%d}" .print
	maxcnt - 1 +
	clamp0
	maxcnt 'adrfrom +!
	;
	
::minicencode | dest src cnt -- cdest
	0 'lenlit ! 
	over 'adrfrom !
	over 'startmem !
	swap >a swap >b | a=src b=dst
	( 1? 1 - 
|		dup "{%d}" .print
		a> startmem - $ff and 'posnow !
		ca@+ $ff and 
|		over "1)%d=" .print
		traverse 
|		over "2)%d=" .print
|		2dup "+%h %d+" .println
		runencode
|		dup "3)%d=" .print
		) drop
|	dup "$%h " .print
	enlit
	b> ;

