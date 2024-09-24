| editor
| PHREDA 2024

^r3/lib/console.r3
^r3/lib/mconsole.r3
^r3/lib/math.r3
^r3/lib/mem.r3
^r3/lib/parse.r3

^r3/d4/r3map.r3

##xcode 6 ##ycode 2
##wcode 40 ##hcode 20

##xlinea 0 ##ylinea 0	| primera linea visible
#xcursor #ycursor

##pantaini>	| comienzo de pantalla
##pantafin>	| fin de pantalla

##inisel	| inicio seleccion
##finsel	| fin seleccion

##fuente  	| fuente editable
##fuente> 	| cursor
##$fuente	| fin de texto

##clipboard	|'clipboard
##clipboard>

##undobuffer |'undobuffer
##undobuffer>

##mshift

|----- edicion
::lins  | c --
	fuente> dup 1 - $fuente over - 1 + cmove>
	1 '$fuente +!
:lover | c --
	fuente> c!+ dup 'fuente> !
	$fuente >? ( dup '$fuente ! ) drop
:0lin | --
	0 $fuente c! ;

#modo 'lins

:back
	fuente> fuente <=? ( drop ; )
	dup 1 - c@ undobuffer> c!+ 'undobuffer> !
	dup 1 - swap $fuente over - 1 + cmove
	-1 '$fuente +!
	-1 'fuente> +! ;

:del
	fuente>	$fuente >=? ( drop ; )
    1 + fuente <=? ( drop ; )
	9 over 1 - c@ undobuffer> c!+ c!+ 'undobuffer> !
	dup 1 - swap $fuente over - 1 + cmove
	-1 '$fuente +! ;

:<<13 | a -- a
	( fuente >=?
		dup c@ 13 =? ( drop ; )
		drop 1 - ) ;

:>>13 | a -- a
	( $fuente <?
		dup c@
		13 =? ( drop 1 - ; ) | quitar el 1 -
		drop 1 + )
	drop $fuente 2 - ;

#1sel #2sel

:selecc	| agrega a la seleccion
	mshift 0? ( dup 'inisel ! 'finsel ! ; ) drop
	inisel 0? ( fuente> '1sel ! ) drop
	fuente> dup '2sel !
	1sel over <? ( swap )
	'finsel ! 'inisel !
	;

:khome
	selecc
	fuente> 1 - <<13 1 + 'fuente> !
	selecc ;

:kend
	selecc
	fuente> >>13  1 + 'fuente> !
	selecc ;

:scrollup | 'fuente -- 'fuente
	pantaini> 1 - <<13 1 - <<13  1 + 'pantaini> !
	ylinea 1? ( 1 - ) 'ylinea !
	selecc ;

:scrolldw
	pantaini> >>13 2 + 'pantaini> !
	pantafin> >>13 2 + 'pantafin> !
	1 'ylinea +!
	selecc ;

:kup
	fuente> fuente =? ( drop ; )
	selecc
	dup 1 - <<13		| cur inili
	swap over - swap	| cnt cur
	dup 1 - <<13		| cnt cur cura
	swap over - 		| cnt cura cur-cura
	rot min + fuente max
	'fuente> !
	selecc ;

:kdn
	fuente> $fuente >=? ( drop ; )
	selecc
	dup 1 - <<13 | cur inilinea
	over swap - swap | cnt cursor
	>>13 1 +    | cnt cura
	dup 1 + >>13 1 + 	| cnt cura curb
	over - rot min +
	'fuente> !
	selecc ;

:kri
	selecc
	fuente> $fuente <?
	( 1 + 'fuente> ! selecc ; ) drop
	;

:kle
	selecc
	fuente> fuente >?
	( 1 - 'fuente> ! selecc ; ) drop
	;

:kpgup
	selecc
	20 ( 1? 1 - kup ) drop
	selecc ;

:kpgdn
	selecc
	20 ( 1? 1 - kdn ) drop
	selecc ;

|-------------------------------------------
::copysel
	inisel 0? ( drop ; )
	clipboard swap
	finsel over - pick2 over + 'clipboard> !
	cmove
	;

::realdel
	fuente>
	inisel <? ( drop ; )
	finsel <=? ( drop inisel 'fuente> ! ; )
	finsel inisel - over swap - 'fuente> !
	drop ;

::borrasel
	inisel finsel $fuente finsel - 4 + cmove
	finsel inisel - neg '$fuente +!
	realdel
	0 dup 'inisel ! 'finsel ! ;

:kdel
	inisel 0? ( drop del ; )
	drop borrasel ;

:kback
	inisel 0? ( drop back ; )
	drop borrasel ;

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

| 18 = blue dark for select
:inselect
	inisel finsel in? ( 18 ,bcolor ; )
	0 ,bcolor ;
	
:atselect
	inisel =? ( 18 ,bcolor ; )
	finsel =? ( 0 ,bcolor ; )
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
	( atselect c@+ 1?
		$22 =? (
			over c@ $22 <>? ( drop ; )
			,c swap 1 + swap )
		13 <>?
		,ct ) drop 1 - 0 ;
	
:endline
	,c ( atselect c@+ 1? 13 <>? ,ct )	
	1? ( drop ; ) drop 1 - ;
	
:parseline 
	,tcolor
	( atselect c@+ 1? 13 <>?  | 0 o 13 sale
		9 =? ( wcolor ,tcolor ,sp ,sp drop 32 )
		32 =? ( wcolor ,tcolor )
		$22 =? ( strword ) 		| $22 " string
		$5e =? ( endline ; )	| $5e ^  Include
		$7c =? ( endline ; )	| $7c |	 Comentario
		,c
		) 
	1? ( drop ; ) drop
	1 - ;

|... no color line	
:parselinenc
	( atselect c@+ 1? 13 <>? ,c ) 
	1? ( drop ; ) drop
	1 - ;

|..............................
:linenro | lin -- lin
	over ylinea + 1 + .d 3 .r. ,s 32 ,c ; 

:drawline | adr line -- line adr'
	"^[0m^[37m " ,printe	| ,esc "0m" ,s ,esc "37m" ,s  | reset,white,clear
	swap
	linenro
	iniline
	inselect
	parseline
	;

:setpantafin
	pantaini>
	0 ( hcode <?
		swap >>cr 1 + swap
		1 + ) drop
	$fuente <? ( 1 - ) 'pantafin> ! ;
	
|..............................
::code-draw
	fuente>
	( pantafin> >? scrolldw )
	( pantaini> <? scrollup )
	drop 
	,reset
	pantaini>
	0 ( hcode <?
		1 ycode pick2 + ,at
		drawline
		swap 1 + ) drop
	$fuente <? ( 1 - ) 'pantafin> ! ;

:emitcur
	13 =? ( drop 1 'ycursor +! 0 'xcursor ! ; )
	9 =? ( drop 3 'xcursor +! ; )
	drop 1 'xcursor +! ;

::cursorpos
	ylinea 'ycursor ! 0 'xcursor !
	pantaini> ( fuente> <? c@+ emitcur ) drop
	| hscroll
	xcursor
	xlinea <? ( dup 'xlinea ! )
	xlinea wcode + >=? ( dup wcode - 1 + 'xlinea ! )
	drop 
	,reset
	ycode ylinea - ycursor + | y
	xcode 5 - over ,at $3e ,c			| >
	xcode xlinea - xcursor + swap ,at 	| cursor position
	;
	
:vchar | char --  ; visible char
	$1000 and? ( drop ; )
	16 >> $ff and
	8 =? ( drop kback ; )
	9 =? ( modo ex ; )
	13 =? ( modo ex ; )
	32 <? ( drop ; )
	modo ex ;

::code-vkey | key -- key ; only view key
	$48 =? ( kup ) $50 =? ( kdn )
	$4d =? ( kri ) $4b =? ( kle )
	$47 =? ( khome ) $4f =? ( kend )
	$49 =? ( kpgup ) $51 =? ( kpgdn )	
	;

::code-key | key -- key
	$ff0000 and? ( dup vchar ; ) 
	$53 =? ( kdel )
	$52 =? (  modo | ins
			'lins =? ( drop 'lover 'modo ! .ovec ; )
			drop 'lins 'modo ! .insc )	
	code-vkey
	;

::code-set | src --
	dup 'pantaini> !
	dup 'fuente !
	dup 'fuente> !
	count + '$fuente !
|	0 'xlinea ! 0 'ylinea !
	setpantafin
	;
	
::,xycursor
	ycursor xcursor " %d:%d " ,print ;
	
::code-ram
	here	| --- RAM
	dup 'fuente !
	dup 'fuente> !
	dup '$fuente !
	$3ffff +			| 256kb texto
	dup 'clipboard !
	dup 'clipboard> !
	$3fff +				| 16KB
	dup 'undobuffer !
	dup 'undobuffer> !
	$3fff +         	| 16kb
	'here ! | -- FREE
	;

|----------------------------------------
#hashfile 
	
:simplehash | adr -- hash
	0 swap ( c@+ 1? rot dup 5 << + + swap ) 2drop ;
	
::loadtxt | name -- ; cargar texto
	fuente swap load 0 swap c!
	fuente only13 1 - '$fuente !	|-- queda solo cr al fin de linea
	fuente dup 'pantaini> ! simplehash 'hashfile !
	;

::savetxt | name -- ; guarda texto
	fuente simplehash hashfile =? ( drop ; ) drop | no cambio
	mark	
	fuente ( c@+ 1? 13 =? ( ,c 10 ) ,c ) 2drop
	savemem
	empty ;
	