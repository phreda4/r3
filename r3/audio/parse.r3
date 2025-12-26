| parse tree 
| PHREDA 2025

^r3/lib/console.r3

#error

|--- word stack ---
#stack * $ff
#stack> 'stack

:push stack> w!+ 'stack> ! ;
:pop -1 'stack> +! 'stack> c@ ;

#str$
#lvl 
#type
#nseq
#seq * 512
#seq> 'seq

|delimiter ( ) < > [ ] { } 
::>>spl | adr -- adr'	; next space or delimiter
	( c@+ $ff and 32 >? 
		$28 =? ( drop ; ) |$28 $29 ( )m
		$29 =? ( drop 1- ; )
		$3c =? ( drop ; ) |$3c $3e < >m
		$3e =? ( drop 1- ; )
		$5b =? ( drop ; ) |$5b $5d [ ]m
		$5d =? ( drop 1- ; )
		$7b =? ( drop ; ) |$7b $7d { }m
		$7d =? ( drop 1- ; )
		drop ) drop 1- ;
	
| ITEM 32bits
| seq(4) type(4) lvl(4) str(12)
:+item | adr char -- adr
	|dup "%k" .println
	drop
	nseq 20 << 
	type 16 << or
	lvl 12 << or
	over str$ - or
	seq> d!+ 'seq> ! 
	>>spl ;
	
:uplvl | newtype --
	>r
	+item
	type push
	r> 'type !
	1 'nseq +!
	1 'lvl +! ;
	
:dnlvl | --
	pop 'type !
	+item
	-1 'lvl +! 
	1+ >>spl 
	dup c@ $ff and
	0? ( drop ; ) 
	$20 <=? ( drop ; )
	drop
	dup 1+ c@ 
	0? ( drop ; ) 
	drop
	1- ;
	
:token
	$28 =? ( 1 uplvl ; ) |$28 $29 ( )m
	$29 =? ( dnlvl ; )
	$3c =? ( 2 uplvl ; ) |$3c $3e < >m
	$3e =? ( dnlvl ; )
	$5b =? ( 3 uplvl ; ) |$5b $5d [ ]m
	$5d =? ( dnlvl ; )
	$7b =? ( 4 uplvl ; ) |$7b $7d { }m
	$7d =? ( dnlvl ; )
	+item ;
	
:trimall | adr -- 'adr char
	( dup c@ $ff and 
		33 <? 0? ( ; ) drop 1+ ) ;
	
:markseq | 'str -- cntnodos
	'seq 'seq> ! 0 'lvl ! 0 'nseq !
	dup 'str$ !
	( trimall 1? 
		token
		) 2drop ;
		
:printsec
	'seq ( seq> <?
		d@+ 
		dup $fff and "str:%h " .print
		dup 12 >> $f and "lvl:%d " .print
		dup 16 >> $f and "t:%d " .print
		20 >> $ff and "s:%d" .println
		) drop ;
	
:pp | v lvl -- v lvl
	over $fff and str$ + 
	dup >>spl swap
	( over <? c@+ .emit ) 2drop
	" " .print
	;
	
:printlvl | n --
	'seq ( seq> <?
		d@+ 
		dup 12 >> $f and pick3 =? ( pp ) 
		2drop ) .cr
	2drop ;
	
#tests
"[[g#2 g#3]*2 [e2 e3]*2]
a b"
|"a b c "
|"<a b c>"
|"[a b c]"
|"(a b c)"
|"a b <c d e> [a c] (a b <a c>)"
"inicio <nivel1 [nivel2 (nivel3)mod3]mod2>mod1 fin"
|"  a   b    c  "
|"a  <  b   c  >  d"
|"  inicio   <  nivel1   [  nivel2  ]  >   fin  "
"<a>mod1<b c>mod2" |**
|"<a>mod1 <b>mod2" 
|"[[a]mod1]mod2"
|"<a [b]mod1>mod2 c"
|"[a]* [b]+" 
|"((a)mod1)mod2"
"<a <b>!>?"
0

:test
	'tests .println .cr
	'tests markseq
	;
	
#mus1
"<
[e5 [b4 c5] d5 [c5 b4]]
[a4 [a4 c5] e5 [d5 c5]]
[b4 [~ c5] d5 e5]
[c5 a4 a4 ~]
[[~ d5] [~ f5] a5 [g5 f5]]
[e5 [~ c5] e5 [d5 c5]]
[b4 [b4 c5] d5 e5]
[c5 a4 a4 ~]
,
[[e2 e3]*4]
[[a2 a3]*4]
[[g#2 g#3]*2 [e2 e3]*2]
[a2 a3 a2 a3 a2 a3 b1 c2]
[[d2 d3]*4]
[[c2 c3]*4]
[[b1 b2]*2 [e2 e3]*2]
[[a1 a2]*4]
>"

:ej1
	'mus1 .println .cr
	'mus1 markseq .cr
	;
	
:main
	.cls
	"parse" .println
	
	test
	|ej1
	
	printsec .cr
	0 printlvl
	1 printlvl
	2 printlvl
	
	
	;

:
main
waitesc
;
