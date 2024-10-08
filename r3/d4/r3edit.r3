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
	fuente> dup 1- $fuente over - 1+ cmove>
	1 '$fuente +!
:lover | c --
	fuente> c!+ dup 'fuente> !
	$fuente >? ( dup '$fuente ! ) drop
:0lin | --
	0 $fuente c! ;

#modo 'lins

:back
	fuente> fuente <=? ( drop ; )
	dup 1- c@ undobuffer> c!+ 'undobuffer> !
	dup 1- swap $fuente over - 1+ cmove
	-1 '$fuente +!
	-1 'fuente> +! ;

:del
	fuente>	$fuente >=? ( drop ; )
    1+ fuente <=? ( drop ; )
	9 over 1- c@ undobuffer> c!+ c!+ 'undobuffer> !
	dup 1- swap $fuente over - 1+ cmove
	-1 '$fuente +! ;

:<<13 | a -- a
	( fuente >=?
		dup c@ 13 =? ( drop ; )
		drop 1- ) ;

:>>13 | a -- a
	( $fuente <?
		dup c@
		13 =? ( drop 1- ; ) | quitar el 1-
		drop 1+ )
	2 - ;

#1sel #2sel

:selecc	| agrega a la seleccion
	mshift 0? ( dup 'inisel ! 'finsel ! ; ) drop
	inisel 0? ( fuente> '1sel ! ) drop
	fuente> dup '2sel !
	1sel over <? ( swap )
	'finsel ! 'inisel !
	;

:khome
	fuente> 1- <<13 1+ 'fuente> ! ;

:kend
	fuente> >>13 1+ 'fuente> ! ;

|---------------
::scrollup | 'fuente -- 'fuente
	pantaini> 2 - <<13 1+
	fuente <=? ( fuente nip )
	'pantaini> !
	;

::scrolldw
	pantafin> >>13 2 + 
	$fuente >=? ( drop ; ) 
	'pantafin> !
	pantaini> >>13 2 + 'pantaini> !
	;

:setpantafin
	pantaini>
	hcode ( 1? swap >>13 1+ swap 1- ) drop
	$fuente <? ( 1- ) 'pantafin> ! ;
	
:setpantaini
	pantafin>
	hcode ( 1? swap 2 - <<13 1+ swap 1- ) drop
	fuente <? ( fuente nip )
	'pantaini> !
	;

:fixcur
	fuente>
	pantaini> <? ( <<13 1+ 'pantaini> ! setpantafin ; )
	pantafin> >? ( >>13 2 + 'pantafin> ! setpantaini ; )
	drop
	;
	
|---------------
:iline | a -- ca ia
	dup 1- <<13 swap over - ;
	
:kup
	fuente> fuente =? ( drop ; )
	iline swap iline
	rot min + fuente max
	'fuente> ! ;

:kdn
	fuente> $fuente >=? ( drop ; )
	dup 1- <<13 over swap - 
	swap | cnt cursor
	>>13 1+ dup 1+ >>13 1+ 	| cnt cura curb
	over - rot min + 
	'fuente> ! ;

:kri
	fuente> $fuente <? ( 1+ 'fuente> ! ; ) drop ;

:kle
	fuente> fuente >? ( 1- 'fuente> ! ; ) drop ;

:kpgup
	20 ( 1? 1- kup ) drop ;

:kpgdn
	20 ( 1? 1- kdn ) drop ;

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
	( 1? 1- swap
		c@+ 0? ( drop nip 1- ; )
		13 =? ( drop nip 1- ; )
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
			,c swap 1+ swap )
		13 <>?
		,ct ) drop 1- 0 ;
	
:endline
	,c ( atselect c@+ 1? 13 <>? ,ct )	
	1? ( drop ; ) drop 1- ;
	
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
	1- ;

|... no color line	
:parselinenc
	( atselect c@+ 1? 13 <>? ,c ) 
	1? ( drop ; ) drop
	1- ;

|..............................
:linenro | lin -- lin
	over ylinea + 1+ .d 3 .r. ,s 32 ,c ; 

:drawline | adr line -- line adr'
	"^[0m^[37m " ,printe	| ,esc "0m" ,s ,esc "37m" ,s  | reset,white,clear
	swap
	linenro
	iniline
	inselect
	parseline
	;

|..............................
::code-draw
	,reset
	pantaini>
	0 ( hcode <?
		1 ycode pick2 + ,at
		drawline
		swap 1+ ) drop
	$fuente <? ( 1- ) 'pantafin> ! ;

:emitcur
	13 =? ( drop 1 'ycursor +! 0 'xcursor ! ; )
	9 =? ( drop 3 'xcursor +! ; )
	drop 1 'xcursor +! ;

#cacheyl
#cachepi

:getcacheini |  -- pantanini>
	pantaini> cachepi =? ( cacheyl 'ylinea ! ; ) drop
	0 'ylinea !
	fuente 
	( pantaini> <? c@+ 13 =? ( 1 'ylinea +! ) drop ) 
	dup 'cachepi !
	ylinea 'cacheyl !
	;
	
::cursorcalc
	0 'xcursor !
	getcacheini
	
	ylinea 'ycursor !
	( fuente> <? c@+ emitcur ) drop
	| hscroll
	xcursor
	xlinea <? ( dup 'xlinea ! )
	xlinea wcode + >=? ( dup wcode - 1+ 'xlinea ! )
	drop ;

::cursorpos
	,reset
	ycode ylinea - ycursor + | y
	xcode 5 - over ,at $3e ,c			| >
	xcode xlinea - xcursor + swap ,at 	| cursor position
	;
	
:vchar | char --  ; visible char
	16 >> $ff and
	[BACK] =? ( drop kback ; )
	9 =? ( modo ex ; )
	13 =? ( modo ex ; )
	32 <? ( drop ; )
	modo ex ;

:inskey
	modo | ins
	'lins =? ( drop 'lover 'modo ! .ovec ; )
	drop 'lins 'modo ! .insc ;
	
::code-key | key -- key
|WIN|	$1000 and? ( ; )
	selecc
|WIN|	$ff0000 and? ( dup vchar fixcur selecc ; ) 

|LIN|	$20 $7e in? ( dup modo ex )
|LIN|	9 =? ( dup modo ex ) 
|LIN|	13 =? ( dup modo ex )
|LIN|	[BACK] =? ( kback ) 
	[DEL] =? ( kdel )
	[INS] =? ( inskey )	
	[UP] =? ( kup ) [DN] =? ( kdn )
	[RI] =? ( kri ) [LE] =? ( kle )
	[HOME] =? ( khome ) [END] =? ( kend )
	[PGUP] =? ( kpgup ) [PGDN] =? ( kpgdn )	
	fixcur selecc
	;

::code-set | src --
	dup 'pantaini> !
	dup 'fuente !
	dup 'fuente> !
	count + '$fuente !
	0 'xlinea ! 0 'ylinea !
	setpantafin
	;
	
::,xycursor
	ycursor 1+ xcursor 1+ " %d:%d " ,print ;
	
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
	fuente swap load 0 13 rot c!+ c!
	fuente only13 1- '$fuente !	|-- queda solo cr al fin de linea
	fuente dup 'pantaini> ! simplehash 'hashfile !
	;

::savetxt | name -- ; guarda texto
	fuente simplehash hashfile =? ( drop ; ) drop | no cambio
	mark	
	fuente ( c@+ 1? 13 =? ( ,c 10 ) ,c ) 2drop
	savemem
	empty ;
	
