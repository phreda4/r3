| parse+vm
| PHREDA 2025

^r3/lib/console.r3
^r3/lib/rand.r3

|--- word stack ---
#stack * $ff
#stack> 'stack

:push stack> c!+ 'stack> ! ;
:pop -1 'stack> +! stack> c@ $ff and ;

#str$
#lvl
#aseq
#nseq

| cant(8)seq(12) str(12)
#list * 1024
#list> 'list

:]list@ | n -- list@
	2 << 'list + d@ ;
	
:]list+!
	1 24 << swap 2 << 'list + d+! ;
	
| type|cnt|end|start
#rseq * 1024 

:]seq | n -- adr
	3 << 'rseq + ;

:seqnro
	list> 'list - 2 >> ;
	
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
	list> d!+ 'list> !
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
	'list 'list> ! 0 'lvl ! 0 'aseq ! 0 'nseq ! 
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
	
:parsemod | str -- 
	1 'repl !
	1.0 'mult ! 1.0 'divi !
	1.0 'weig ! 1.0 'prob !
	0 'eucl ! 0 'vari !
	( c@+ 1?
		dup isD? 1? ( 3drop ; ) drop
		pmod
		) 2drop ;

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

:parsenote | str -- note
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
	swap parsemod
	;

|------------------------------------------------
| SEQ  type cnt slt rep prob |  mul div weig |euc 
| 1    2    7   15  8   8
| NOTE midi vol var rep prob |  mul div weig |euc 
| 1    7    8   8   8   8      (10) (10) (10) 2

#tokens * $fff
#tokens> 'tokens
#tokensw * $fff

:,tok
	tokens> !+ 'tokens> ! ;
	
| TOKEN
|type(4)	
|midi(8)/nk	|4
|prob(8)	|12
|scale(16)	|20
|weigt(16)	|36 


:vars!or | v -- v
	prob $ff 16 *>> $ff and 12 << or
|	repl $3f and 20 << or
	mult divi /. 8 >> $ffff and 20 << or | scale
	weig 8 >> $ffff and 36 << or
|weig
|vari
	;

|sumar todos los w
:.nk
:.note	4 >> $ff and ;
:.prob	12 >> $ff and ;
:.scale	20 >> $ffff and 8 << ;
:.weig 36 >> $ffff and 8 << ;
	
| n end now str -- n end now 
|vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
:,note 
	parsenote $ff and 4 << | note
	vars!or
	,tok 
	;

:sub | n end now str -- n end now 
	drop
	over ]list@
	$fff and str$ +
	1+ parsemod 
	pick2 ]list@ 24 >> $ff and 4 <<
	;
	
:,seq | []
	sub	1 or
	vars!or	
	,tok ;
	
:,alt | <>
	sub 2 or
	vars!or	
	,tok ;
	
:,par | {}
	sub 3 or
	vars!or	
	,tok ;
	
|^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^	

|------------------------------------
:pp | v -- 
	$fff and str$ + 
	dup >>spl 
	over =? ( 1+ ) 
	swap ( over <? c@+ .emit ) 2drop
	" " .print
	;
	
:token? | n end now -- n end now
	dup ]list@
	dup 12 >> $fff and | n end now L ln
	pick4 <>? ( 2drop ; ) drop |	pp ;
	pick3 ]list+!
	$fff and str$ + dup c@
	$3c =? ( drop ,alt ; ) |$3c $3e < >m
	$3e =? ( 2drop ; )
	$5b =? ( drop ,seq ; ) |$5b $5d [ ]m
	$5d =? ( 2drop ; )
	$7b =? ( drop ,par ; ) |$7b $7d { }m
	$7d =? ( 2drop ; )
	drop 
	,note ;
	
:compseq | n -- n
	dup ]seq @
	dup 12 >> $fff and
	swap $fff and | n end start
	( over <? token? 1+ ) 2drop
|	.cr
	;
	
:compile
	'tokens 'tokens> !
	0 ( nseq <=?
|		dup "%d:" .print
|		dup ]seq @ "%h" .println
		compseq
		1+ ) drop ;
	
|------------------------------------
|    NodeType type;
|    float scale;   // * /
|    float weight;  // @
|    float prob;    // ?
|    int note;                 // MIDI o -1 (~)
|    struct Node* kids[MAX_KIDS];
|    int nk;
|    float total_weight;       // precalculado


|    Node* node;
|    float start;
|    float dur;
|    float cursor;  // solo SEQ
|    int idx;
|} Frame;

| top of tstack
#t0 	
#t1 
#node
#cursor
#idx

#totalw

#tstack * $ff
#tstack>

:tpush | --
	t0 $ffff and 
	t1 $ffff and 16 << or
	cursor $ffff and 32 << or
	node $ff and 48 << or
	idx $ff and 56 << or
	tstack> !+ 'tstack> ! ;
	
:tpop | --
	-8 'tstack> +! tstack> @ 
	dup $ffff and 't0 !
	dup 16 >> $ffff and 't1 ! 
	dup 32 >> $ffff and 'cursor !
	dup 48 >> $ff and 'node !
	56 >> $ff and 'idx !
	;
	
:tidx+
	1 56 << tstack> 8 - +! ;
:tcur+ | val
	$ffff and 32 << tstack> 8 - +! ;
	

| TOKEN
|type(4)	
|midi(8)	|4
|prob(8)	|12
|rep(6)		|20
|scale(16)	|26
|weigt(16)	|42
:pmod
	dup 4 >> $ff and "n:%d "  .print
	dup 12 >> $ff and "?%d " .print
	dup 20 >> $3f and "!%d " .print
	dup 26 >> $ffff and 8 << "*/%f " .print
	dup 42 >> $ffff and 8 << "@%f " .print
	;
	
:note | v --
	|pmod
	dup .note "n:%d " .print
	t0 "s:%f " .print
	.scale t1 *. "d:%f " .print
	.cr
	tpop
	;
	
#totalw
	
:sec
	"[]" .print
	idx over .nk 
	|2dup "nk:%d idx:%d " .print
	>=? ( 2drop tpop ; )
	dup "idx:%d " .print
	node 3 << 'tokensw + @ 'totalw !
	node + 'node !
	tidx+
	cursor 't0 ! 
	
	t1 over .scale *. 
	pick2 .weig *.
|	pick2 totalw /.
	dup tcur+
	't1 !
	0 'cursor !
	0 'idx !
	tpush ;
	
| (f->dur * n->mod.scale) * (n)->mod.weight / n->total_weight);
	 
:alt
	"<>" .print
	pmod .cr
|	t1 t0 "(%f %f)" .print
tpop
	;
	
:par
	"{}" .print
	pmod .cr
|	t1 t0 "(%f %f)" .print
tpop
	;
	
#tlist NOTE SEC ALT PAR 0 0 0 0 0 0 0 0 0 0 0 0

:calcnodo 
	node 4 << 'tokens + @
	idx 0? (
		over .prob $ff randmax <? ( 2drop tpop ; ) drop
		) drop
	dup $f and 3 << 'tlist + @ ex ;
	
:eval
	'tstack 'tstack> !
	0 't0 ! $ffff 't1 !
	0 'cursor !
	0 'idx !
	0 'node !
	tpush
	
	( 'tstack tstack> - 1? drop
		calcnodo
		) drop ;

|------------------------------------
:pp | v -- 
	$fff and str$ + 
	dup >>spl 
	over =? ( 1+ ) 
	swap ( over <? c@+ .emit ) 2drop
	" " .print
	;
		
:printlist
	0
	'list ( list> <?
		swap dup "%h:" .print 1+ swap
		d@+ 
		dup pp |$fff and "str:%h " .print	
|		dup 12 >> $ff and "lvl:%d " .print
		dup 12 >> $fff and "seq:%d " .print 
		24 >> $ff and "len:%d " .print
		.cr
		) 2drop ;


#mus1
|"a"
|"b!2"
"[a b? c]*2"
"a b <c d e> [a c] [a b <a c>]"
"< [[g#2 g#3]*2 [e2 e3]*2],[a b c]*2>"
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

:printseq
	0 ( nseq <=?
		dup "%d:" .print
		dup ]seq @
		24 >> $ff and 
		"%d" .println
		1+ ) drop ;

	
:main
	getch drop
	.cls
	"parse" .println
	
	'mus1 
	count "len:%d" .println 
	dup .println 
	markseq
	
	nseq "seq:%d " .print
	list> 'list - 2 >> "nlist:%d" .println
	compile
	
	printlist .cr
	
	
	printseq
	|eval
	;


:
main
waitesc
;
