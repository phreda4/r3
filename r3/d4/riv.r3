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

#view
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

:stm0
	curx viewx - 1+ cury viewy - 1+ .at	
	;
:stm1
	"-- INSERT --" .write
	curx viewx - 1+ cury viewy - 1+ .at	
	;
:stm2
	curx viewx - 1+ cury viewy - 1+ .at	
	;
:stm3
	"-- VISUAL --" .write
	curx viewx - 1+ cury viewy - 1+ .at		
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
	.cls
	view >a
	viewh 2 -
	0 ( over <?
		drawline .cr
		1+ ) drop 
		
	.rever
	vieww .nsp
	"[" .write 'filename .write "]" .write
	cury 1+ curx 1+ " %d:%d " .print 
	ncount " %d " .print
	.cr
	.reset	
	mode 3 << 'stmodes + @ ex
	.flush
	;

|---------------------------
:<<13 | a -- a
	( src >=?
		dup c@ 13 =? ( drop ; )
		drop 1- ) ;

:>>13 | a -- a
	( src$ <=?
		dup c@ 13 =? ( drop ; )
		drop 1+ ) 1- ;

:khome	src> 1- <<13 1+ 'src> ! ;
:kend	src> >>13 'src> ! ;

#ilinea

:kup
	cury 0? ( drop ; ) drop
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
	
	
:kmove
	;
:kcount
	$30 $39 in? ( dup $30 - ncount 10* + 'ncount ! ) ;
	
:vcount | vector --
	ncount 0? ( 1+ ) ( 1? 1- over ex ) 2drop ;
	
|---NORMAL
:knor
	evtkey
	[esc] =? ( -1 'mode ! ) 
	kcount
	[le] =? ( $48 nip ) 
	[up] =? ( $4A nip )	
	[dn] =? ( $4B nip ) 
	[ri] =? ( $4C nip ) 	
	$3A =? ( 4 'mode ! ) | :
	$2F =? ( 4 'mode ! ) | /
	toUpp
	$49 =? ( 1 'mode ! ) | I
	$52 =? ( 2 'mode ! ) | R
	$56 =? ( 3 'mode ! ) | V
	$48 =? ( 'kle vcount ) |H
	$4A =? ( 'kup vcount ) |J
	$4B =? ( 'kdn vcount ) |K
	$4C =? ( 'kri vcount ) |L
	drop ;
	
|---INSERT
:kins
	evtkey
	[esc] =? ( 0 'mode ! ) 
	
	drop ;
|---REPLACE
:krep
	evtkey
	[esc] =? ( 0 'mode ! ) 
	
	drop ;
|---VISUAL
:kvis
	evtkey
	[esc] =? ( 0 'mode ! ) 
	
	drop ;
|---CMD
:kcmd
	evtkey
	[esc] =? ( 0 'mode ! ) 
	|[enter] =? ( ) |ejecuta
	
	drop ;

#kmode 'knor 'kins 'krep 'kvis 'kcmd

:hkey

:getevent
	inevt
	1 =? ( drop 'kmode mode 3 << + @ ex ; )
	| 2 =? ( hmou )
	drop
	20 ms getevent ;
	
:editor
	( drawscreen
		getevent
		mode -1 <>? drop
		) drop ;
	
::rivMem | "" --
	src strcpy
	src only13 1- 'src$ ! |-- queda solo cr al fin de linea
	src dup 'view ! 'src> ! 
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