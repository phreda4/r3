| parse tree 
| PHREDA 2025

^r3/lib/console.r3

#error

|--- word stack ---
#stack * $ff
#stack> 'stack

:push stack> c!+ 'stack> ! ;
:pop -1 'stack> +! stack> c@ $ff and ;

#str$
#lvl
#aseq
#nseq

#seq * 1024
#seq> 'seq

#rseq * 1024 

|delimiter  ESP ( ) < > [ ] { } ,
:isD? | char -- X/0
	$ff and
	$20 <=? ( 4 nip ; )
	$28 =? ( 1 nip ; ) |$28 $29 ( )m
	$29 =? ( 2 nip ; )
	$3c =? ( 1 nip ; ) |$3c $3e < >m
	$3e =? ( 2 nip ; )
	$5b =? ( 1 nip ; ) |$5b $5d [ ]m
	$5d =? ( 2 nip ; )
	$7b =? ( 1 nip ; ) |$7b $7d { }m
	$7d =? ( 2 nip ; )
	$2c =? ( 3 nip ; ) | ,
	0 nip ;

::>>spl | adr -- adr'
	( c@+ $ff and 32 >? 
		isD? 1? ( drop 1- ; ) drop
		) drop 1- ;
	
:]seq | n -- adr
	3 << 'rseq + ;
	
:seqnro
	seq> 'seq - 2 >> ;
	
:]seqini! | n --
	]seq dup @ seqnro or swap ! ;
	
:]seqend! | n --
	]seq dup @ seqnro 12 << or swap ! ;
	
:newseq
	1 'nseq +! 
	nseq dup 'aseq ! 
	]seq 0 swap ! ;
	
| ITEM 32bits
| seq(12) lvl(8) str(12)
:+item | adr  -- adr
	aseq $fff and 20 << 
	lvl $ff and 12 << or
	over str$ - $fff and or
	seq> d!+ 'seq> ! 
	>>spl ;
	
:uplvl | adr -- adr
	newseq
	aseq dup ]seqini! push
	+item 1+
	1 'lvl +! ;
	
:dnlvl | --
	pop 'aseq !
	+item
	aseq ]seqend!
	-1 'lvl +! 
	1+ >>spl 
	dup c@ isD? 1? ( drop ; ) drop
	dup 1+ c@ isD? 1? ( drop ; ) drop
	1- ;
	
:token
	$28 =? ( drop uplvl ; ) |$28 $29 ( )m
	$29 =? ( drop dnlvl ; )
	$3c =? ( drop uplvl ; ) |$3c $3e < >m
	$3e =? ( drop dnlvl ; )
	$5b =? ( drop uplvl ; ) |$5b $5d [ ]m
	$5d =? ( drop dnlvl ; )
	$7b =? ( drop uplvl ; ) |$7b $7d { }m
	$7d =? ( drop dnlvl ; )
	$2c =? ( drop +item 1+ ; ) | newseq ; )
	drop +item ;
	
:trimall | adr -- 'adr char
	( dup c@ 0? ( ; )
		$ff and 33 <? 
		drop 1+ ) ;
	
:markseq | 'str -- 
	dup 'str$ !
	'seq 'seq> ! 0 'lvl ! 0 'aseq ! 0 'nseq ! 
	aseq dup ]seqini! push
	( trimall 1? 
		|lvl nseq "%d %d " .print over "%w " .println getch drop
		token
		) 2drop 
	pop ]seqend!
	;

:pp | v -- 
	$fff and str$ + 
	dup >>spl 
	over =? ( 1+ ) 
	swap ( over <? c@+ .emit ) 2drop
	" " .print
	;
		
:printsec
	0
	'seq ( seq> <?
		swap dup "%d:" .print 1+ swap
		d@+ 
		dup pp |$fff and "str:%h " .print	
		dup 12 >> $ff and "lvl:%d " .print
		20 >> $ff and "seq:%d " .print .cr
		) 2drop ;
	
:printseq
	'rseq >a
	0 ( nseq <=? 
		dup "%d: " .print
		a@+ |"%h" .print
		dup 12 >> $fff and
		swap $fff and
		( over <?
			dup "%d " .print
			1+ ) 2drop
		.cr
		1+ ) drop
	;
	
#tests
"<
[[g#2 g#3]*2 [e2 e3]*2]
,
[a b c]
>"
|"a b c "
"<a b c>"
"[a b c]"
"(a b c)"
"a b <c d e> [a c] (a b <a c>)"
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

:ej0
	'tests 
	count "len:%d" .println 
	dup .println 
	markseq
	;
	
|-- real test	
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
	'mus1 
	count "len:%d" .println 
	dup .println 
	markseq
	;
	
:main
	getch drop
	.cls
	"parse" .println
	
	ej0 |0,1
	
	nseq "seq:%d" .println
	seq> 'seq - 2 >> "ntok:%d" .println
	
	printsec .cr
	.cr
	printseq .cr
	
|	"<A,B" .println
|	"A=[C,D" .println
|	"B=[a b c" .println
|	"C=[g#2 g#3]*2" .println
| 	"D=[e2 e3]*2" .println
	|0 printlvl
|	1 printlvl
|	2 printlvl
	
	
	;

:
main
waitesc
;
