^r3/lib/term.r3

#hashfile 
#filename * 1024

#xlinea 0
#ylinea 0	| primera linea visible
#ycursor
#xcursor

#scrini>	| comienzo de pantalla
#scrend>	| fin de pantalla

#fuente		| fuente editable
#fuente> 	| cursor
#$fuente	| fin de texto

#clipboard	|'clipboard
#clipboard>

#undobuffer |'undobuffer
#undobuffer>

#linecomm 	| comentarios de linea
#linecomm>

|----- edicion
:lins | c --
	fuente> dup 1- $fuente over - 1+ cmove>
	1 '$fuente +!
:lover | c --
	fuente> c!+ dup 'fuente> !
	$fuente >? ( dup '$fuente ! ) drop
:0lin | --
	0 $fuente c! ;

#modo 'lins

:kback
	fuente> fuente <=? ( drop ; )
	dup 1- c@ undobuffer> c!+ 'undobuffer> !
	dup 1- swap $fuente over - 1+ cmove
	-1 '$fuente +!
	-1 'fuente> +! ;

:kdel
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
		13 =? ( drop 1- ; ) | quitar el 1 -
		drop 1+ ) 2 - ;

:khome	fuente> 1- <<13 1+ 'fuente> ! ;
:kend	fuente> >>13 1+ 'fuente> ! ;

:scrollup
	scrini> 2 - <<13 1+
	fuente <? ( drop ; )
	'scrini> !
	;

:scrolldw
	scrend> >>13 2 + 
	$fuente >=? ( drop ; ) 
	'scrend> !
	scrini> >>13 2 + 'scrini> !
	;

::setpantafin
	scrini>
	fh ( 1? swap >>13 1+ swap 1- ) drop
	$fuente <? ( 1- ) 'scrend> ! 
	;
	
:setpantaini
	scrend>
	fh ( 1? swap 2 - <<13 1+ swap 1- ) drop
	fuente <? ( fuente nip )
	'scrini> !
	;
	
:fixcur
	fuente>
	scrini> <? ( <<13 1+ 'scrini> ! -1 'ylinea +! setpantafin ; )
	scrend> >? ( >>13 2 + 'scrend> ! 1 'ylinea +! setpantaini ; )
	drop
	;

:karriba
	fuente> fuente =? ( drop ; )
	dup 1- <<13		| cur inili
	swap over - swap	| cnt cur
	dup 1- <<13			| cnt cur cura
	swap over - 		| cnt cura cur-cura
	rot min + fuente max
	'fuente> ! ;

:kabajo
	fuente> $fuente >=? ( drop ; )
	dup 1- <<13 | cur inilinea
	over swap - swap | cnt cursor
	>>13 1+		| cnt cura
	dup 1+ >>13 1+ 	| cnt cura curb
	over - rot min +
	'fuente> ! ;

:kder	fuente> $fuente <? ( 1+ 'fuente> ! ; ) drop ;
:kizq	fuente> fuente >? ( 1- 'fuente> ! ; ) drop ;
:kpgup	fh ( 1? 1- karriba ) drop ;
:kpgdn	fh ( 1? 1- kabajo ) drop ;

|------------------------------------------------

:simplehash | adr -- hash
	0 swap ( c@+ 1? rot dup 5 << + + swap ) 2drop ;
	
:loadtxt | -- ; cargar texto
	fuente 'filename 
	load 0 swap c!
	fuente only13 1- '$fuente !	|-- queda solo cr al fin de linea
	fuente dup 'scrini> ! simplehash 'hashfile !
	;

|-----------------
::TuLoadCode |
	'filename strcpy
	loadtxt
	;

:savetxt | -- ; guarda texto
	fuente simplehash hashfile =? ( drop ; ) drop | no cambio
	
	mark	
	fuente ( c@+ 1?
		13 =? ( ,c 10 ) ,c ) 2drop
		
	'filename savemem
	empty 
	;
	
|-----------------
#focoe	

:colore
|		9 =? ( wcolor ,tcolor ,sp ,sp drop 32 )
|		32 =? ( wcolor ,tcolor )
|		$22 =? ( strword ) 		| $22 " string
|		$5e =? ( endline ; )	| $5e ^  Include
|		$7c =? ( endline ; )	| $7c |	 Comentario
	;
	
:setcursor | y adr
	focoe 1? ( .savec ) drop
	over ylinea + 1+ 'ycursor !
	;
	
:drawline | 
	( fuente> =? ( setcursor )
		c@+ 1? 13 <>? | 0 o 13 sale
		.emit ) 
	1? ( drop ; ) drop 1- ;
	
|-----------------
:chmode
	modo 'lins =? ( drop 'lover 'modo ! .ovec ; )
	drop 'lins 'modo ! .insc ;
	

:EditFoco
	tuif 0? ( 'focoe ! ; )
	|1 =? ( drop inInput dup ) 
	'focoe !
	tuC!	| activate cursor
	tuTAB	| no tab in main
	uikey 0? ( drop ; )	
	32 126 in? ( modo ex fixcur ; ) 
	[tab] =? ( modo ex fixcur ; ) 
	[enter] =? ( modo ex fixcur ; ) 
	[BACK] =? ( kback )
	[DEL] =? ( kdel )
	[UP] =? ( karriba ) 
	[DN] =? ( kabajo )
	[RI] =? ( kder ) 
	[LE] =? ( kizq )
	[HOME] =? ( khome ) 
	[END] =? ( kend )
	[PGUP] =? ( kpgup ) 
	[PGDN] =? ( kpgdn )
	[INS] =? ( chmode )	
	drop 
	fixcur ;		

	
|---------------	
:iniline
	dup ylinea + 1+ 
	ycursor =? ( .d 4 .r. .write ">" .write ; )
	.d 4 .r. .write .sp ;

::tuEditCode 
	tuiw drop
	Editfoco
	scrini>
	0 ( fh <?
		fx over fy + .at
		iniline swap 
		drawline swap 
		1+ ) drop 
	$fuente <? ( 1- ) 
	'scrend> ! ;

		
|---------------	
:
	here
	dup 'fuente !
	dup 'fuente> !
	dup '$fuente !
	$3ffff +			| 256kb texto
	dup 'clipboard !
	dup 'clipboard> !
	$3fff +				| 16KB
	dup 'undobuffer !
	dup 'undobuffer> !
	$ffff +				| 64kb
	dup 'linecomm !
	dup	'linecomm> !
	$3fff +				| 4096 linecomm
	'here ! | -- FREE
	mark 
;