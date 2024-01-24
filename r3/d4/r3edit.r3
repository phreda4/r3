| editor for d4
| PHREDA 2024
|..............................
#fuente  	| fuente editable
#fuente> 	| cursor
#$fuente	| fin de texto
#pantaini>
#pantafin>
#ylinea


:<<13 | a -- a
	( fuente >=?
		dup c@ 13 =? ( drop ; )
		drop 1 - ) ;

:>>13 | a -- a
	( $fuente <?
		dup c@ 13 =? ( drop 1 - ; ) | quitar el 1 -
		drop 1 + )
	drop $fuente 2 - ;

:khome
	fuente> 1 - <<13 1 + 'fuente> ! ;
:kend
	fuente> >>13  1 + 'fuente> ! ;

:scrollup | 'fuente -- 'fuente
	pantaini> 1 - <<13 1 - <<13  1 + 'pantaini> !
	ylinea 1? ( 1 - ) 'ylinea ! ;

:scrolldw
	pantaini> >>13 2 + 'pantaini> !
	pantafin> >>13 2 + 'pantafin> !
	1 'ylinea +! ;

:colcur
	fuente> 1 - <<13 swap - ;

:karriba
	fuente> fuente =? ( drop ; )
	dup 1 - <<13		| cur inili
	swap over - swap	| cnt cur
	dup 1 - <<13			| cnt cur cura
	swap over - 		| cnt cura cur-cura
	rot min + fuente max
	'fuente> !
	;

:kabajo
	fuente> $fuente >=? ( drop ; )
	dup 1 - <<13 | cur inilinea
	over swap - swap | cnt cursor
	>>13 1 +    | cnt cura
	dup 1 + >>13 1 + 	| cnt cura curb
	over -
	rot min +
	'fuente> !
	;

:kder
	fuente> $fuente <? ( 1 + 'fuente> ! ; ) drop ;

:kizq
	fuente> fuente >? ( 1 - 'fuente> ! ; ) drop ;

:kpgup
	20 ( 1? 1 - karriba ) drop ;

:kpgdn
	20 ( 1? 1 - kabajo ) drop ;

|----------------------------------------
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
	( c@+ 1? 13 <>? drop ) 
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
		13 <>?
		,ct ) drop 1 - 0 ;
	
	
:endline
	,c ( endline? c@+ 1? 13 <>? ,ct )	
	eline ;
	
:parseline 
	0 wcolor drop
	,tcolor
	dup cntlin + 'endlin !
	( endline? c@+ 1? 13 <>?  | 0 o 13 sale
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
		
|----------------------------------------
::code-key	
	evtkey
	$48 =? ( karriba ) $50 =? ( kabajo )
	$4d =? ( kder ) $4b =? ( kizq )
	$47 =? ( khome ) $4f =? ( kend )
	$49 =? ( kpgup ) $51 =? ( kpgdn )	
	drop
	;
	

::code-set | src --
	dup 'fuente !
	dup >>0 1 - '$fuente !
	'fuente> ! 
	;
	

	
	