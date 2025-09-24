| pprint code
| PHREDA

^r3/lib/mem.r3
^r3/lib/parse.r3
^r3/lib/console.r3
^r3/lib/mconsole.r3

|------ Color line
#colornow 0

:wcolor
	over c@ 
	32 =? ( drop ; ) 9 =? ( drop ; )
	$22 =? ( drop 15 'colornow ! ; )	| $22 " string
	$5e =? ( drop 3 'colornow ! ; )	| $5e ^  Include
	$7c =? ( drop 8 'colornow ! ; )	| $7c |	 Comentario
	$3A =? ( drop 9 'colornow ! ; )	| $3a :  Definicion
	$23 =? ( drop 13 'colornow ! ; )	| $23 #  Variable
	$27 =? ( drop 14 'colornow ! ; )	| $27 ' Direccion
    drop
	over isNro 1? ( drop 11 'colornow ! ; ) 
	drop 10 'colornow ! ;

:,tcolor colornow ,fcolor ;

#endlin
#cntlin

:eline | adr char -- adr
	0? ( drop 1 - ; ) drop
	c@+ 10 =? ( drop ; ) drop 1 -
	;

:endline? | adr -- adr
	endlin <? ( ; )
	( c@+ 1? 13 <>? 10 <>? drop ) 
	drop 1 -
	;
	
:,ct
	9 =? ( ,sp ,sp 32 nip ) ,c ;
	
:strword
	,c
	( endline? c@+ 1?
		$22 =? (
			over c@ $22 <>? ( drop ; )
			,c swap 1 + swap )
		13 <>? 10 <>?
		,ct ) drop 1 - 0 ;
	
	
:endline
	,c ( endline? c@+ 1? 13 <>? 10 <>? ,ct )	
	eline ;
	
:parseline 
	0 wcolor drop
	,tcolor
	dup cntlin + 'endlin !
	( endline? c@+ 1? 13 <>? 10 <>?
		9 =? ( wcolor ,tcolor ,sp ,sp drop 32 )
		32 =? ( wcolor ,tcolor )
		$22 =? ( strword ) 		| $22 " string
		$5e =? ( endline ; )	| $5e ^  Include
		$7c =? ( endline ; )	| $7c |	 Comentario
		,c ) 
	eline ;
	


::code-print | scrx scry lines width source --
	swap 'cntlin !
	0 ( pick2 <? | scrx lines src linen
		pick4 pick4 pick2 + ,at ,sp
		swap parseline ,eline
		swap 1 + ) nip 4drop ;
