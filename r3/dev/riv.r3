| Riv Ide Editor
| PHREDA 2026

^r3/lib/console.r3
^r3/lib/clipboard.r3
^r3/util/utfg.r3
|^r3/lib/trace.r3

#hashfile 
#filename * 1024

#src
#src>
#src$

#view>
#viewx 0
#viewy 0
#vieww 40
#viewh 20

#mode 0
#ncount	

#line * 2048

#pad * 512
#msg * 512

#curx
#cury

:cursorintext
	curx viewx - 1+ cury viewy - 1+ .at	 ;
	
:stm0
	cursorintext
	;
:stm1
	.yellow "-- INSERT --" .write
	cursorintext
	;
:stm2
	.green "-- VISUAL --" .write
	cursorintext
	;
:stm3
	
	.green "-- VISUAL LINE--" .write
	cursorintext
	;
:stm4
	":" .write
	'pad .write
	;
	
#stmodes stm0 stm1 stm2 stm3 stm4
|---------------------------
:drawline
	vieww ( 1? 1- 
		ca@+ 0? ( drop 1+ .nsp -1 a+ ; ) 
		13 =? ( drop 1+ .nsp ; )
		9 =? ( drop .sp 32  ) 
		.emit ) drop ;

:drawscreen
	.reset .cls
	view> >a
	viewh 2 -
	0 ( over <?
		drawline .cr
		1+ ) drop 
		
	.rever
	vieww .nsp
	"[" .write 'filename .write "]" .write
	cury 1+ curx 1+ " %d:%d " .print 
	ncount " %d " .print
	src> c@ ">%h<" .print
	src> "%w" .print
	.cr
	.reset	
	mode 3 << 'stmodes + @ ex
	.flush
	;


|------- calc xy cursor

|----- edicion
:lins | c --
	src> dup 1- src$ over - 1+ cmove>
	1 'src$ +!
:lover | c --
	src> c!+ dup 'src> !
	src$ >? ( dup 'src$ ! ) drop
:0lin | --
	0 src$ c! ;

#modo 'lins

:back
	src> src <=? ( drop ; )
	dup 1- swap src$ over - 1+ cmove
	-1 'src$ +!
	-1 'src> +! ;

:del
	src> src$ >=? ( drop ; )
	1+ src <=? ( drop ; )
	dup 1- swap src$ over - 1+ cmove
	-1 'src$ +! ;

:<<13 | a -- a
	( src >=?
		dup c@ 13 =? ( drop ; )
		drop 1- ) ;

:>>13 | a -- a
	( src$ <=?
		dup c@ 13 =? ( drop ; )
		drop 1+ ) 1- ;

:khome
	src> 1- <<13 1+ 'src> ! 0 'curx ! ;
:kend
	src> dup >>13 dup rot - 'curx ! 'src> ! ;
:kfspace
	src> 1- <<13 1+ 'src> ! 0 'curx ! 
	src> ( c@+ 0? ( 2drop -1 'curx +! ; ) 
		$ff and 32 <=? drop 1 'curx +! ) 2drop ;
	;

#ilinea

:kup
	cury 0? ( drop ; ) drop | in start
	src> c@ 0? ( drop src> <<13 1+ 'src> ! -1 'cury +! ; ) drop | in end
	src> src <=? ( drop ; )
	dup 1- <<13		| cur inili
	swap over - swap	| cnt cur
	dup 1- <<13			| cnt cur cura
	dup 'ilinea !
	swap over - 		| cnt cura cur-cura
	rot min + src max 
	dup 'src> ! 
	ilinea 1+ - 'curx !
	-1 'cury +! ;

:kdn
	src> src$ >=? ( drop ; )
	dup 1- <<13 | cur inilinea	
	over swap - swap | cnt cursor
	>>13		| cnt cura
	dup 'ilinea !
	dup 1+ >>13 	| cnt cura curb
	over - rot min +
	dup 'src> ! 
	ilinea 1+ - 'curx !
	1 'cury +! ;

:kri
	src> src$ >=? ( drop ; ) 
	dup c@ 13 =? ( 2drop ; ) drop
	1+ 'src> !
	1 'curx +! ;

:kle	
	src> 1- src <=? ( drop ; ) 
	dup c@ 13 =? ( 2drop ; ) drop 
	'src> !
	-1 'curx +! ;
	
|------------------------------
	
:kcount
	$30 $39 in? ( dup $30 - ncount 10* + 'ncount ! ) ;
	
:vcount | vector --
	ncount 0? ( 1+ ) ( 1? 1- over ex ) 2drop ;

:kmovecursor
	[le] =? ( kle ) 
	[up] =? ( kup )	
	[dn] =? ( kdn ) 
	[ri] =? ( kri ) 
	[home] =? ( khome )
	[end] =? ( kend )
	;
	
:chmode
	modo 'lins =? ( drop 'lover 'modo ! .ovec ; )
	drop 'lins 'modo ! .insc ;

:kinstext
	32 126 in? ( dup modo ex 1 'curx +! )
	[tab] =? ( dup modo ex 2 'curx +! )
	[enter] =? ( dup modo ex 0 'curx +! 1 'cury +! )
	;
	
|---NORMAL
:knor
	evtkey
	[esc] =? ( -1 'mode ! ) 
	kcount
	kmovecursor		
	$3A =? ( 4 'mode ! ) | :
	$2F =? ( 4 'mode ! ) | /
	$30 =? ( khome ) | 0
	$24 =? ( kend ) | $
	$5e =? ( kfspace ) | ^
	
	$68 =? ( 'kle vcount ) |h
	$6A =? ( 'kup vcount ) |j
	$6B =? ( 'kdn vcount ) |k
	$6C =? ( 'kri vcount ) |l	
	
	$69 =? ( 1 'mode ! ) | i
	$72 =? ( 2 'mode ! ) | r
	$76 =? ( 3 'mode ! ) | v
	$56 =? ( 4 'mode ! ) | V
	drop ;
	
|---INSERT
:kins
	evtkey
	[esc] =? ( 0 'mode ! ) 
	kmovecursor
	kinstext
	drop ;
	
|---REPLACE
:krep
	evtkey
	[esc] =? ( 0 'mode ! ) 
	kmovecursor	
	kinstext	
	drop ;
|---VISUAL
:kvis
	evtkey
	[esc] =? ( 0 'mode ! ) 
	kmovecursor
	drop ;
|---CMD
:kcmd
	evtkey
	[esc] =? ( 0 'mode ! ) 
	|[enter] =? ( ) |ejecuta
	
	drop ;

#kmode 'knor 'kins 'krep 'kvis 'kcmd

:getevent
	inevt
	1 =? ( drop 'kmode mode 3 << + @ ex ; )
	| 2 =? ( hmou )
	drop
	50 ms getevent ;
	
:editor
	( mode -1 <>? drop
		drawscreen
		getevent
		) drop ;

::rivMem | "" --
	src strcpy
	src only13 1- 'src$ ! |-- queda solo cr al fin de linea
	src dup 'view> ! 'src> ! 
	0 'curx ! 0 'cury !
	0 'mode !
	;
	
#test
"esto es un texto de prueba
de varias lineas
para probar el editor"
	
|---------------	
:
	mark 
	here
	dup 'src ! $ffff +
	dup 'src$ ! $fff +
	'here
	src 'src> !
	0 'curx ! 0 'cury !
	0 'mode !
	.alsb
	0 'viewx ! 0 'viewy !
	cols 'vieww ! rows 'viewh !
	.ovec
	'test rivMem
	editor
	.masb 
	.free
	;