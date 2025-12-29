| parse+vm
| PHREDA 2025

^r3/lib/console.r3

|--- word stack ---
#stack * $ff
#stack> 'stack

:push stack> c!+ 'stack> ! ;
:pop -1 'stack> +! stack> c@ $ff and ;

#str$
#lvl
#aseq
#nseq

| seq(12) str(12)
#seq * 1024
#seq> 'seq

| type|cnt|end|start
#rseq * 1024 

:]seq | n -- adr
	3 << 'rseq + ;

:seqnro
	seq> 'seq - 2 >> ;
	
:]seqini! | n --
	]seq dup @ seqnro or swap ! ;
	
:]seqend! | n --
	]seq dup @ seqnro 12 << or swap ! ;
	
:]seq+!
	]seq 1 24 << swap +! ;

:newseq | type --
	40 <<
	1 'nseq +! 
	nseq dup 'aseq ! 
	]seq ! ;


|delimiter  ESP ( ) < > [ ] { } ,
:isD? | char -- X/0
	$ff and
	$20 <=? ( 4 nip ; )
	$28 =? ( 1 nip ; ) |$28 $29 ( )m
	$29 =? ( 2 nip ; )
	$3c =? ( 1 nip ; ) |$3c $3e < >m alterna
	$3e =? ( 2 nip ; )
	$5b =? ( 1 nip ; ) |$5b $5d [ ]m secuencia
	$5d =? ( 2 nip ; )
	$7b =? ( 1 nip ; ) |$7b $7d { }m mismo tiempo
	$7d =? ( 2 nip ; )
	$2c =? ( 3 nip ; ) | ,
	0 nip ;

::>>spl | adr -- adr'
	( c@+ $ff and 32 >? 
		isD? 1? ( drop 1- ; ) drop
		) drop 1- ;

	
| ITEM 32bits
| seq(12) str(12)
:+item | adr  -- adr
	aseq 
	dup ]seq+!		| suma uno a la seq
	$fff and 12 << 
	over str$ - $fff and or
	seq> d!+ 'seq> !
	>>spl ;
	
:uplvl | adr type -- adr
	swap
	+item 1+
	aseq push
	swap newseq
	aseq ]seqini!
	1 'lvl +! ;
	
:dnlvl | --
	+item 1+
	aseq ]seqend!
	pop 'aseq !
	-1 'lvl +! 
	>>spl 
	dup c@ isD? 1? ( drop ; ) drop
	dup 1+ c@ isD? 1? ( drop ; ) drop
	1- ;
	
:coma
	|+item 
	aseq ]seq
	dup @ 
	$2000000000 or | <> -> {}  | [] -> []
	swap ! ;
	
:token
|	$28 =? ( drop 4 uplvl ; ) |$28 $29 ( )m
|	$29 =? ( drop dnlvl ; )
	$3c =? ( drop 1 uplvl ; ) |$3c $3e < >m
	$3e =? ( drop dnlvl ; )
	$5b =? ( drop 2 uplvl ; ) |$5b $5d [ ]m
	$5d =? ( drop dnlvl ; )
	$7b =? ( drop 3 uplvl ; ) |$7b $7d { }m
	$7d =? ( drop dnlvl ; )
	$2c =? ( drop coma 1+ ; ) | convierte <> en {}
	drop +item ;
	
:trimall | adr -- 'adr char
	( dup c@ 0? ( ; )
		$ff and 33 <? 
		drop 1+ ) ;

:markseq | 'str -- 
	dup 'str$ !
	'seq 'seq> ! 0 'lvl ! 0 'aseq ! 0 'nseq ! 
	aseq dup ]seqini! push
	( trimall 1? token ) 2drop 
	pop ]seqend!
	;
	
|----------------------------------

#vari
#repl

#prob
#mult
#divi
#weig
#eucl


:pmod
	$2a =? ( drop str>fnro 'mult ! ; )		|* 
	$2f =? ( drop str>fnro 'divi ! ; )		|/ 
	$21 =? ( drop str>fnro int. 'repl ! ; )	|!
	$40 =? ( drop str>fnro 'weig ! ; )		|@
	$3f =? ( drop str>fnro 0? ( 0.5 + ) 'prob ! ; ) |?
	$3a =? ( drop str>fnro int. 'vari ! ; )	| : Variante/índice
| falta euclid
| error
	drop 1+ ;
	
:parsemod | str -- 'str
	1 'repl !
	1.0 'mult ! 1.0 'divi !
	1.0 'weig ! 1.0 'prob !
	0 'eucl ! 0 'vari !
	( c@+ 1?
		dup isD? 1? ( 2drop 1- ; ) drop
		pmod
		) drop 1- ;

:.ppw
	repl "!%d " .print
	mult "*%f " .print
	divi "/%f " .print
	weig "@%f " .print
	prob "?%f " .println
	vari ":%d " .print
	|eucl "m:%f " .print
	;

#semitone ( 9 11 0 2 4 5 7 0 )

:parsenote | str -- 'str note
	c@+
	$df and | uppcase+unsigned
	$41 <? ( -1 nip ; )	$47 >? ( -1 nip ; ) | A..G
	$41 - 'semitone + c@
	over c@ | adr note char
	$23 =? ( rot 1+ rot 1+ rot ) | #
	$df and | uppcase+unsigned
	$53 =? ( rot 1+ rot 1+ rot ) | s
	$42 =? ( rot 1+ rot 1- rot ) | b
	drop 
	4 12 * + | octva 4
	over c@ | adr note char
	|$30 >=? ( $39 <=? (  | 0..9
	$30 $39 in? (
		rot 1+ rot 
		4 12 * -
		pick2 $30 - 12 * +
		rot
		) |)
	drop 
	swap parsemod swap 
	;

|------------------------------------------------
| SEQ  type cnt slt rep prob |  mul div weig |euc 
| 1    2    7   15  8   8
| NOTE midi vol var rep prob |  mul div weig |euc 
| 1    7    8   8   8   8      (10) (10) (10) 2

#tokens * $fff
#tokens> 'tokens

:,tok
	tokens> !+ 'tokens> ! ;
	
| str --
:,note |
	parsenote nip
	,tok
	;
:,seq | []
	,tok
	;
:,alt | <>
	,tok
	;
:,par | {}
	,tok
	;
	

|------------------------------------
:compseq 
	]seq @ $fff and str$ + dup c@
	$3c =? ( drop ,alt ; ) |$3c $3e < >m
	$5b =? ( drop ,seq ; ) |$5b $5d [ ]m
	$7b =? ( drop ,par ; ) |$7b $7d { }m
	drop 
	,note ;
	
:getcell
	dup $fff and str$ + getcell
	12 >> $fff and "seq:%d " .print .cr	
	;
		
:compile
	'tokens 'tokens> !
	0 ( nseq <=?
		dup "%d:" .print
		dup ]seq @ "%h" .println
		|dup compseq
		1+ ) drop
	;
	
|------------------------------------
#t0 #t1 | top of tstack
#tstack * $ff
#tstack>

:tpush | --
	t1 32 << t0 or tstack> !+ 'tstack> ! ;
	
:tpop | --
	-8 'tstack> +! tstack> @ 
	dup $ffffffff and 't0 !
	32 >> $ffffffff and 't1 ! ;
	

#l		| top of lstack
#lstack * $7f
#lstack>

:lpush | --
	l lstack> !+ 'lstack> ! ;
	
:lpop | -- 
	-8 'lstack> +! lstack> @ 'l ! ;

:eval
	0 't0 ! 1.0 't1 !
	'lstack 'lstack> !
	'tstack 'tstack> !
	'tokens | ip
	( d@+ 1? |
		|dup $f and 3 << 'oplist + @ ex 
		) 
	2drop ;

|------------------------------------
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
		swap dup "%h:" .print 1+ swap
		d@+ 
		dup pp |$fff and "str:%h " .print	
|		dup 12 >> $ff and "lvl:%d " .print
		12 >> $fff and "seq:%d " .print .cr
		) 2drop ;


#mus1
|"a"
|"b*2"
|"[a b c]"
"a b <c d e> [a c] [a b <a c>]"
"<
[[g#2 g#3]*2 [e2 e3]*2]
,
[a b c]*2
>"
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

	
:main
	getch drop
	.cls
	"parse" .println
	
	'mus1 
	count "len:%d" .println 
	dup .println 
	markseq
	
	nseq "seq:%d" .println
	seq> 'seq - 2 >> "ntok:%d" .println
	printsec .cr
	
	compile
	|eval
	;


:
main
waitesc
;
