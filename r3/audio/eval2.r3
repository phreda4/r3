| parse+vm
| PHREDA 2025

^r3/lib/console.r3
^r3/lib/rand.r3

|--- word stack ---
#stack * $ff
#stack> 'stack

:push stack> !+ 'stack> ! ;
:pop -8 'stack> +! stack> @ ;

#str$
#lvl
#aseq
#nseq

| tokenizado
| cant(8)seq(12)str(12)
#list * 1024
#list> 'list

:]list@ | n -- list@
	2 << 'list + d@ ;
	
:]list+!
	1 24 << swap 2 << 'list + d+! ;

| secuencias
| type(4)|token(12)|cnt(8)|end(12)|start(12)
#rseq * 1024 

:]seq | n -- adr
	3 << 'rseq + ;
	
:listnro
	list> 'list - 2 >> ;
	
:]seqini! | n --
	]seq dup @ listnro or swap ! ;
	
:]seqend! | n --
	]seq dup @ listnro 12 << or swap ! ;
	
:newseq | type --
	44 << 1 24 << or
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

	
:]seq+!	]seq 1 24 << swap +! ;
:]seq-!	]seq -2 24 << swap +! ; | ] +1 -2
	
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
	aseq 
	dup ]seq-!
	]seqend!
	pop 'aseq !
	-1 'lvl +! 
	>>spl 
	dup c@ isD? 1? ( drop ; ) drop
	dup 1+ c@ isD? 1? ( drop ; ) drop
	1- ;
	
:coma
	|+item 
	aseq ]seq
	dup @ $80000000 or swap ! ; | bit de polyfonia
	
:token
|	$28 =? ( drop 4 uplvl ; ) |$28 $29 ( )m
|	$29 =? ( drop dnlvl ; )
	$5b =? ( drop 1 uplvl ; ) |$5b $5d [ ]m SEQ
	$5d =? ( drop dnlvl ; )
	$3c =? ( drop 2 uplvl ; ) |$3c $3e < >m ALT
	$3e =? ( drop dnlvl ; )
	$7b =? ( drop 3 uplvl ; ) |$7b $7d { }m POLY
	$7d =? ( drop dnlvl ; )
	$2c =? ( drop coma 1+ ; ) | marca seq con poly <a b , c> --> {[a b] [c]}
	drop +item ;
	
:trimall | adr -- 'adr char
	( dup c@ 0? ( ; )
		$ff and 33 <? 
		drop 1+ ) ;

:pass1 | 'str -- 
	dup 'str$ !
	'list 'list> ! 0 'lvl ! 0 'aseq ! 0 'nseq ! 
	aseq dup ]seqini! push | first node..a b -> [a b]
	( trimall 1? token ) 2drop 
	pop ]seqend!
	;
	
|----------------------------------
|----------------------------------
#vari #repl
#prob #mult #divi #weig #eucl

:pmod
	$2a =? ( drop str>fnro 'mult ! ; )		|* 
	$2f =? ( drop str>fnro 'divi ! ; )		|/ 
	$21 =? ( drop str>fnro int. 'repl ! ; )	|! 
	$40 =? ( drop str>fnro 'weig ! ; )		|@
	$3f =? ( drop str>fnro 0? ( 0.5 + ) 'prob ! ; ) |?
	$3a =? ( drop str>fnro int. 'vari ! ; )	| : Variante/índice
	| <.1
	| >.4
| falta euclid
	| %2.3 
| error
	drop 1+ ;
	
:resetvars
	1 'repl !
	1.0 'mult ! 1.0 'divi !
	1.0 'weig ! 1.0 'prob !
	0 'eucl ! 0 'vari !
	| desp < > -1.0 .. 1.0
	;
	
:parsemod | str -- 
	resetvars
	( c@+ 1?
		dup isD? 1? ( 3drop ; ) drop
		pmod
		) 2drop ;

#semitone ( 9 11 0 2 4 5 7 0 )

:parsenote | str -- note
	c@+
	$7e =? ( 2drop resetvars 0 'prob ! 0 ; ) | ~	
	$df and | uppcase+unsigned
	$41 <? ( 2drop -1 ; )	$47 >? ( 2drop -1 ; ) | A..G
	$41 - 'semitone + c@
	over c@ | adr note char
	$23 =? ( rot 1+ rot 1+ rot ) | #
	$df and | uppcase+unsigned
	$53 =? ( rot 1+ rot 1+ rot ) | s
	$42 =? ( rot 1+ rot 1- rot ) | b
	drop 
	4 12 * + | octva 4
	over c@ | adr note char
	$30 $39 in? ( | 0..9
		rot 1+ rot 
		4 12 * - | resta octava 4
		pick2 $30 - 12 * + | suma octava
		rot
		) 
	drop 
	swap parsemod
	;

|parse name/nro
| .. "hh sd"  or  "1.0 2 3.0"

|------------------------------------------------
| TOKEN
|type (3)
|repeat (5)
|note(8)		|nk:nrokids (in mem)
|vol(8)var(8)	|fk:firstkid (in mem) (node)
|mod->prob(8)
|mod->scale(12)
|mod->weight(12)

#tokens * $fff
#tokens> 'tokens

:]token@ 3 << 'tokens + @ ;
:,tok	tokens> !+ 'tokens> ! ;

| EXT
| (seq=acc) (nodo=inc)
#extok * $fff

:]extok	3 << 'extok + ;
:tok>ext 'tokens - 'extok + ;

:n.acc@ ]extok @ 32 >> $ffffffff and  ;
:n.wsum@ ]extok @ $ffffffff and ;

:t.type		$7 and ;
:t.repeat	3 >> $1f and ;

:t.nk
:t.note		8 >> $ff and ;

:t.fk		16 >> $ffff and ;
:t.vol		16 >> $ff and ;
:t.var		24 >> $ff and ;

:t.prob		32 >> $ff and ;
:t.scale	40 >> $fff and 8 << ; 
:t.weigth	52 >> $fff and 8 << ;


:.token | v -- v
	dup t.type "%b " .print
	dup t.repeat "!%d " .print
	dup t.note "n:%d "  .print
	dup t.prob "?%d " .print
	dup t.scale "*/%f " .print
	dup t.weigth "@%f " .print
	
	dup t.type $7 and 0? ( drop ; ) drop | nodes
	dup t.nk "[n:%d " .print
	dup t.fk "f:%h]" .print
	;

:toknro
	tokens> 'tokens - 3 >> ;

:vars!or | v -- v
	repl $1f and 3 << or
	prob $ff 16 *>> $ff and 32 << or
	mult divi 0? ( 1.0 + ) /. |<<< FIX
	8 >> $fff and 40 << or | scale
	weig 8 >> $fff and 52 << or
	;

:,note 
	parsenote $ff and 8 << | note
	vars!or
	,tok ;

:sub | n end now -- n end now 
	over 2 - ]list@ $fff and str$ + | ]mod
	2 + 
|	dup "%w//" .println
	parsemod 
	dup 1+ ]list@ 12 >> $fff and | nro seq
	16 <<
	|pick3 $ff and 8 << or | nro seq
	vars!or 
	;
	
:,seq	sub	1 or ,tok ;
:,alt	sub 2 or ,tok ;
:,par	sub 3 or ,tok ;
	
:token? | n end now -- n end now
	dup ]list@ 
	dup 12 >> $fff and | n end now L ln
	pick4 <>? ( 2drop ; ) drop | no this secuence	
|	dup "(%h) " .print
	$fff and str$ + 
	dup c@
	$3c =? ( 2drop ,alt ; ) |$3c $3e < >m
	$3e =? ( 2drop ; )
	$5b =? ( 2drop ,seq ; ) |$5b $5d [ ]m
	$5d =? ( 2drop ; )
	$7b =? ( 2drop ,par ; ) |$7b $7d { }m
	$7d =? ( 2drop ; )
	drop ,note ;
	
	
:compseq | n -- n
	dup ]seq
	dup @ toknro 32 << or swap ! | nro token
	dup ]seq @
	dup 12 >> $fff and
	swap $fff and | n end start
	( over <? 
|		dup "(%d)" .print
		token? 
		1+ ) 2drop 		
|	error 1? ( "error en expr" ) drop
|	.cr
	;
	
:pass2
	'tokens 'tokens> !
	resetvars 1 vars!or ,tok | "a b" -> "[a b]"
	0 ( nseq <=?
|		dup "%d) " .print
		compseq 
|		.cr
		1+ ) drop ;
		
|------- save first kid and count in token seq
:fix | adr' t -- 'adr t
	over 8 - dup @
	dup t.fk ]seq @
	dup 32 >> $fff and 16 <<
	swap 24 >> $ff and 8 << or
	swap $fffff00 nand or
	swap !
	| pre calc wsum & totalw
	over 8 - @				| ... token
	0 over t.fk pick2 t.nk 	| token sum 1node cnt
	( 1? >r					| token sum node ; cnt
		dup ]token@
		dup t.weigth over t.scale *. swap t.repeat *	| token acc kid sum
		dup 32 << pick2 ]extok !
		rot + swap
		1+ r> 1- ) 2drop nip
	pick2 8 - tok>ext 
	dup @ rot or swap ! 
	;


	
:pass3
	'tokens ( tokens> <?
		@+ $7 and 1? ( fix ) drop
		) drop ;
		

|------------------------------------
:.note | v --
	t.note "note:%d " .println ;

:printrec | node --
	dup "%h)" .print
	dup ]token@ | node token
	dup $7 and | node token type
	0? ( drop nip .note ; )
	drop
	dup t.fk swap t.nk | node fk nk
	( 1? 1- swap
|		dup "%h " .print
		dup printrec
		1+ swap ) 3drop
	;

|------------------------------------------

##ccycle
#veval 0

:start+dur | v -- v
	dup 16 >> over + $ffff and 16 << swap $ffff and or ;

:s+d
	dup 16 << + $ffffffff and ;
	
|:list reuse
:note | fnode token start|dur 
	dup 16 >> $ffff and "%f " .print
	dup $ffff and "%f |" .print
	over t.note "%d" .println
	
|	over t.note 32 << over or 
|	push
	;

		
|    // Calcular peso total incluyendo speed
|    float total_weight = 0;
|    for (int j = 0; j < node->child_count; j++) {
|        Node* child = node->children[j];
|        total_weight += child->weight * child->repeat * child->speed;
|    if (total_weight == 0) break;
|    // Distribuir proporcionalmente
|    double scale = iteration_duration / total_weight;
|    double offset = current_start;
|    for (int j = 0; j < node->child_count; j++) {
|        Node* child = node->children[j];
|        double dur = (child->weight * child->repeat * child->speed) * scale;
|        calculate_events(child, offset, dur, cycle_index);
|        offset += dur;

|:]extok	3 << 'extok + ;
|:tok>ext 'tokens - 'extok + ;

|:n.acc@ ]extok @ 32 >> $ffffffff and  ;
|:n.wsum@ ]extok @ $ffffffff and ;
	
	
:seq2 | fnode token start|dur
	over t.fk pick2 t.nk 	| fnode token start|dur 1node cnt
	pick2 $ffff and 16 << | duration
	pick4 tok>ext @ $ffffffff and | total
	/. 
	dup "%f" .println
	swap | s|d 1node total cnt
	( 1? >r					| fnode token start|dur child ; r:nchild
		
		|over n.acc@
		
		over 32 << over or | add node info
		
		veval ex
		s+d swap 1+ swap 
		r> 1- ) 3drop ;

:seq | fnode token start|dur
	over t.fk pick2 t.nk 	| fnode token start|dur 1node cnt
	pick2 $ffff and over /	| duracion
	pick3 $ffff0000 and or	| fnode token start|dur 1node cnt 
	swap
	( 1? >r					| fnode token start|dur child start|dur ; r:nchild
		over 32 << over or | add node info
		veval ex
		
		s+d swap 1+ swap
		r> 1- ) 3drop ;
	
:alt | fnode token start|dur
	ccycle pick2 t.nk mod 
	pick2 t.fk +
	32 << over or | add node info
	veval ex ;
	
:poly | fnode token start|dur
	over t.fk pick2 t.nk 	| fnode token start|dur 1node cnt
	( 1? >r					| fnode token start|dur child ; r:nchild
		over over 32 << or | add node info
		veval ex
		1+
		r> 1- ) 2drop ;
		
:ran
	over t.fk 
	pick2 t.nk 	| fnode token start|dur node
	randmax +
	32 << over or | add node info
	veval ex
	;
	
#listv	'note 'seq2 'alt 'poly 'ran 0 0 0

:(eval) | fnode --
	dup 32 >> ]token@ 	| fnode token
	dup t.scale over t.repeat *.	| fnode token total
	0? ( 1+ ) | ceil
|	dup "total:%d" .println
	pick2 $ffff and over /			| fnode token total start|dur
	pick3 $ffff0000 and or swap 	| fnode token start|dur total
|	2dup "cnt:%d sd:%h" .println
	( 1? >r			| fnode token start|dur
		over t.prob $ff randmax >? ( drop 
			over $7 and 3 << 'listv + @ ex 
			dup ) drop
		s+d
		r> 1- ) 
	4drop ;
	
	
::eval |
	'(eval) 'veval !
	'stack 'stack> ! | evenl list
	$ffff (eval) ;

|------------------------------------------
#mus1
"<[g4*0.75 g4*0.25 a4 g4 c5 b4]
[g4*0.75 g4*0.25 a4 g4 d5 c5]
>"
"< {a b c } {d e f} > a ~ " 
"a b <e f> ~ " 
"a b [c d] "
"[[b c c c ] a a ]" 
|"[b c] a" 
|"[a b c a]" 
"[a b c a]" 
"[a b [c a]]" 
"c c [b b b] c {a a}"
"[ a b [c d] e ]"
"b!2"
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

|------------------------------------
:pp | v -- 
	$fff and str$ + 
	dup >>spl 
	over =? ( 1+ ) 
	swap ( over <? c@+ .emit ) 2drop
	" " .print
	;
		
:printlist
	0 'list ( list> <?
		swap dup "%h:" .print 1+ swap
		d@+ 
		dup pp |$fff and "str:%h " .print	
|		dup 12 >> $ff and "lvl:%d " .print

|		dup 12 >> $fff and "seq:%d " .print 
|		24 >> $ff and "len:%d " .print

		"%h" .print
		.cr
		) 2drop ;

| type|cnt|end|start

:printseq
	0 ( nseq <=?
		dup "%d: " .print
		dup ]seq @
		dup 32 >> $fff and "tok:%h " .print
		dup 24 >> $ff and "cnt:%d " .print
		|dup 24 >> $fff and "len:%d " .println
		dup 12 >> $fff and
		swap $fff and | n end start
		( over <?
			dup "%h " .print
			1+ ) 2drop
		.cr
		1+ ) drop ;

:printoks
	0 'tokens ( tokens> <?
		swap dup "%h: " .print 1+ swap
		@+ 	.token
		"| %h " .print 
		dup 8 - tok>ext @ " %h" .print
		|drop 
		.cr 
		) 2drop ;

:main
	getch drop
	.cls
	"parse: " .print
	'mus1 dup .println 
	
	pass1 .cr
|	"----list" .println printlist .cr
	"----pass2" .println pass2
	"----seq" .println printseq .cr
	pass3	
	"----tokens" .println printoks
	
	|"----printrec" .println 0 printrec .cr
	
	"----eval" .println
	0 'ccycle ! "." .println eval 
|	1 'ccycle +! "." .println eval 
|	1 'ccycle +! "." .println eval
	;

:
main
waitesc
;
