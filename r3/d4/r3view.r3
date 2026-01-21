| view for d4
| PHREDA 2024
|..............................
^r3/lib/math.r3
^r3/lib/parse.r3
^r3/lib/console.r3

##fuente  	| fuente editable
##fuente> 	| cursor
##$fuente	| fin de texto

#inisrc>
#endsrc>

#xlinea
#ylinea
#ycursor

##xcode 6
##ycode 2
##wcode 40
##hcode 20

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
	inisrc> 1 - <<13 1 - <<13  1 + 'inisrc> !
	ylinea 1? ( 1 - ) 'ylinea ! ;

:scrolldw
	inisrc> >>13 2 + 'inisrc> !
	endsrc> >>13 2 + 'endsrc> !
	1 'ylinea +! ;

:colcur
	fuente> 1 - <<13 swap - ;

:kup
	fuente> fuente =? ( drop ; )
	dup 1 - <<13		| cur inili
	swap over - swap	| cnt cur
	dup 1 - <<13			| cnt cur cura
	swap over - 		| cnt cura cur-cura
	rot min + fuente max
	'fuente> !
	;

:kdn
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
	20 ( 1? 1 - kup ) drop ;

:kpgdn
	20 ( 1? 1 - kdn ) drop ;

|----------------------------------------
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

:incursor
	fuente> <>? ( ; )
	over 'ycursor !
	"s" ,[ | save cursor position
	;

:iniline
	xlinea wcolor
	( 1? 1 - swap
		c@+ 0? ( drop nip 1 - ; )
		13 =? ( drop nip 1 - ; )
		9 =? ( wcolor )
		32 =? ( wcolor )
		drop swap ) drop ;
	
:,ct
	9 =? ( ,sp ,sp 32 nip ) ,c ;
	
:strword
	,c
	( incursor c@+ 1?
		$22 =? (
			over c@ $22 <>? ( drop ; )
			,c swap 1 + swap )
		13 <>?
		,ct ) drop 1 - 0 ;
	
:endline
	,c ( incursor c@+ 1? 13 <>? ,ct )	
	1? ( drop ; ) drop 1 - ;
	
:parseline 
	,tcolor
	( incursor c@+ 1? 13 <>?  | 0 o 13 sale
		9 =? ( wcolor ,tcolor ,sp ,sp drop 32 )
		32 =? ( wcolor ,tcolor )
		$22 =? ( strword ) 		| $22 " string
		$5e =? ( endline ; )	| $5e ^  Include
		$7c =? ( endline ; )	| $7c |	 Comentario
		,c
		) 
	1? ( drop ; ) drop
	1 - ;

:setendsrc
	inisrc>
	0 ( hcode <?
		swap >>cr 1 + swap
		1 + ) drop
	$fuente <? ( 1 - ) 'endsrc> ! ;

:linenow
	ycursor =? ( $3e ,c ; ) 32 ,c ;
	
:linenro | lin -- lin
	over ylinea + linenow 1 + .d 3 .r. ,s 32 ,c ; 

:drawline | adr line -- line adr'
	"^[0m^[37m" ,printe			| ,esc "0m" ,s ,esc "37m" ,s  | reset,white,clear
	swap
	linenro	
	iniline
	parseline 
	;
	
::code-draw
	fuente>
	( endsrc> >? scrolldw )
	( inisrc> <? scrollup )
	drop 

	,reset
	inisrc>
	0 ( hcode <?
		1 ycode pick2 + ,at
		drawline
		swap 1 + ) drop
	$fuente <? ( 1 - ) 'endsrc> ! 
	;		
		

|----------------------------------------
::code-key	
	[up] =? ( kup ) [dn] =? ( kdn )
	[ri] =? ( kder ) [le] =? ( kizq )
	[home] =? ( khome ) [end] =? ( kend )
	[pgup] =? ( kpgup ) [pgdn] =? ( kpgdn )	
	;
	

::code-set | src --
	dup 'inisrc> !
	dup 'fuente !
	dup 'fuente> !
	count + '$fuente !
	0 'xlinea !
	0 'ylinea !
	setendsrc
	;
	
	