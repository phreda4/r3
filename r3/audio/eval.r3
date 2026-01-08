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

| tokenizado
| cant(8)seq(12)str(12)
#list * 1024
#list> 'list

:]list@ | n -- list@
	2 << 'list + d@ ;
	
:]list+!
	1 24 << swap 2 << 'list + d+! ;

| secuencias
| token(8)|type(8)|end(12)|start(12)
#rseq * 1024 

:]seq | n -- adr
	3 << 'rseq + ;
	
:listnro
	list> 'list - 2 >> ;
	
:]seqini! | n --
	]seq dup @ listnro or swap ! ;
	
:]seqend! | n --
	]seq dup @ listnro 12 << or swap ! ;
	
|:]seq+!	]seq 1 24 << swap +! ;

:newseq | type --
	24 <<
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
	|dup ]seq+!		| suma uno a la seq
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

:markseq | 'str -- 
	dup 'str$ !
	'list 'list> ! 0 'lvl ! 0 'aseq ! 0 'nseq ! 
	aseq dup ]seqini! push | first node..a b -> [a b]
	( trimall 1? token ) 2drop 
	pop ]seqend!
	;
	
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
| falta euclid
| error
	drop 1+ ;
	
:resetvars	
	1 'repl !
	1.0 'mult ! 1.0 'divi !
	1.0 'weig ! 1.0 'prob !
	0 'eucl ! 0 'vari !
	;
	
:parsemod | str -- 
	resetvars
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

|------------------------------------------------
| TOKEN
|type (3)
|repeat (5)
|note(8)	|nk:nrokids (in mem)
|vol(8)var(8)|fk:firstkid (in mem)
|mod->prob(8)
|mod->scale(12)
|mod->weight(12)

#tokens * $fff
#tokens> 'tokens

| EXT
| (seq=acc) (nodo=inc)
#extok * $fff

#tokenow

:]token@ | n -- v
	3 << 'tokens + @ ;

:]extok | n -- v
	3 << 'extok + ;

:,tok
	tokens> !+ 'tokens> ! ;

:tok>ext | tok -- ext
	'tokens - 'extok + ;

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

:n.acc@ | n -- v
	]extok @ 24 >> $ffffff and  ;
	
:n.wsum@ | n -- v
	]extok @ $ffffff and ;
	
:.token | v -- v
	dup t.type "%b " .print
	dup t.repeat "!%d " .print
	dup t.note "n:%d "  .print
	dup t.prob "?%d " .print
	dup t.scale "*/%f " .print
	dup t.weigth "@%f " .print
	
	dup t.type $3 and 0? ( drop ; ) drop | nodes
	dup t.nk "[%d " .print
	dup t.fk "%d]" .print
	;
	

:toknro
	tokens> 'tokens - 3 >> ;

:tokenn+!
	$100 tokenow +! ;
	
:vars!or | v -- v
	repl $1f and 3 << or
	prob $ff 16 *>> $ff and 32 << or
	mult divi 0? ( 1+ ) /. |<<< FIX
	8 >> $fff and 40 << or | scale
	weig 8 >> $fff and 52 << or
	;

:,tokx
	0 tokens> tok>ext ! 
	,tok ;
	
:,note 
	parsenote $ff and 8 << | note
	vars!or
	,tokx
	;

:sub | n end now -- n end now 
	over 2 - ]list@ $fff and str$ + | ]mod
	1+ parsemod 
	
	dup 1+ ]list@ 12 >> $fff and | nro seq
	16 <<
	vars!or 
	;
	
|---------------------	

:,seq | []  | grabar salto
	sub	1 or ,tokx ;
	
:,alt | <>	| grabar salto
	sub 2 or ,tokx ;
	
:,par | {}  | grabar salto
	sub 3 or ,tokx ;
	
:,jmp
	sub 

|---------------------
	
:,endlvl
	2drop -$100 tokenow +! ;

|------------------------------------
:token? | n end now -- n end now
	dup ]list@ 
	dup 12 >> $fff and | n end now L ln
	pick4 <>? ( 2drop ; ) drop | no this secuence
	tokenn+!
	$fff and str$ + 
	dup c@
	$3c =? ( 2drop ,alt ; ) |$3c $3e < >m
	$3e =? ( ,endlvl ; )
	$5b =? ( 2drop ,seq ; ) |$5b $5d [ ]m
	$5d =? ( ,endlvl ; )
	$7b =? ( 2drop ,par ; ) |$7b $7d { }m
	$7d =? ( ,endlvl ; )
	drop ,note ;
	
:compseq | n -- n
	dup ]seq
	dup @ toknro 32 << or swap !
	
	resetvars
	tokens> 'tokenow ! 

	dup ]seq @
	dup 12 >> $fff and
	swap $fff and | n end start
	
	sub %101 or ,tokx
	
	( over <? 
|		dup "(%d)" .print
		token? 
		1+ ) 2drop 
		
|	error 1? ( "error en expr" ) drop
		
|	tokens> 8 - @ 
|	t.nk 0? ( -8 'tokens> +! ) | "a [b]" <- no deveria quitar [b] pero si "[[a b]]"!!
|	drop
	
	|tokenow 'tokens - 3 >> 40 << | nro de token de seq 
	|over ]seq +!
	;

:compile
	'tokens 'tokens> !
	0 ( nseq <=?
|		dup "%d) " .print
		compseq 
|		.cr
		1+ ) drop ;

| calc:
| real cant| sum weigth 

|	node n.acc@ node n.wsum@ /. t1 *. 't0 +! 
|	dup t.weigth node n.wsum@ /. t1 *. 't1 !

|	node n.wacc@ t1 *. 't0 +! 
|	node n.wsum@ t1 *. 't1 !
	
	
:sumkids | nod v -- nod v
	dup t.nk 
	pick2 8 + >a
	0 >b 
	( 1? 1-
		a@+ dup t.repeat swap t.weigth * b+ 
		) drop
|	b> "%f " .print .cr | sum all w*repeat
	b> 
	pick2 tok>ext !
	
	dup t.nk 
	pick2 8 + >a
	( 1? 1-
		a@+ t.weigth b> /. a> 8 - tok>ext ! | w sum / (no repeat)
		) drop
	;
	
:setjmp	
	%100 and? ( ; ) 
	dup $3 and 0? ( drop ; ) 
	;
	
:extinfo
	'tokens ( tokens> <?
		dup @ 
		%100 and? ( sumkids ) 
		setjmp
		drop
		8 + ) drop ;
		
|------------------------------------
| top of tstack
#t0 	
#t1 
#node
#rep
#idk

#totalw

#tstack * $ff
#tstack>

:.tstack
	'tstack ( tstack> <? @+ 
		dup 48 >> $ff and "(n:%d)" .print
		dup 56 >> $ff and "(idk:%d)" .print
		"%h " .print ) drop 
	"<top" .println ;
	
:tpush | --
	t0 $ffff and 
	t1 $ffff and 16 << or
	rep $ff and 32 << or
	node $ff and 48 << or
	idk $ff and 56 << or
	tstack> !+ 'tstack> !
|	node idk "    tpush k:%d n:%d" .println 
	;

:tstore
	t0 $ffff and 
	t1 $ffff and 16 << or
	rep $ff and 32 << or
	node $ff and 48 << or
	idk $ff and 56 << or
	tstack> 8 - ! ;
	
:tpop | --
	-8 'tstack> +! tstack> 8 - @ 
	dup $ffff and 't0 !
	dup 16 >> $ffff and 't1 ! 
	dup 32 >> $ff and 'rep !
	dup 48 >> $ff and 'node !
	56 >> $ff and 'idk !
|	node idk "    tpop k:%d n:%d" .println 
	;

|------------------------------------
:note | v --
	dup t.note "n:%d " .print
	t0 "(%f " .print
	|dup t.scale t1 *.  | scale en nodo
	t1 
	" %f )" .print
	drop
	.cr
	tpop
	;
	
#totalw
	
|Node* c = n->kids[f->idx++];
|float cdur = f->dur * (c->mod.weight / wsum);
|float cstart = f->start + f->dur * (acc / wsum);

:sec | value -- ; []
	|dup "%h |" .print
	rep over t.repeat |2dup "tr:%d sr:%d" .println
	>=? ( 2drop tpop ; ) drop
	idk over t.nk |2dup "tk:%d sk:%d" .println
	>=? ( 2drop 0 'idk ! 1 'rep +! tstore ; ) drop
	1 'idk +! tstore
	
	|---- new node
	node n.acc@ node n.wsum@ /. t1 *. 't0 +! 
	dup t.weigth node n.wsum@ /. t1 *. 't1 !

	t.fk idk + 1- 'node ! 
|	node n.wacc@ t1 *. 't0 +! 
|	node n.wsum@ t1 *. 't1 !
	
	0 'rep ! 0 'idk ! | cont rep, cond childs	
	tpush
	;
	
| (f->dur * n->mod.scale) * (n)->mod.weight / n->total_weight);
	 
:alt
	"<>" .print .token .cr
|	t1 t0 "(%f %f)" .print
	tpop ;
	
:par
	"{}" .print .token .cr
|	t1 t0 "(%f %f)" .print
	tpop ;
	
:jmp | salta a una secuencia
	| 'node !
	| sec/alt/par
	;
	
| NOTE/JMP
	
#tlist NOTE SEC ALT PAR 0 0 0 0 0 0 0 0 0 0 0 0

:calcnodo 
	node |dup "%h<<" .println
	3 << 'tokens + @ 
	
|	idk 0? ( rep 0? (
|		over t.prob $ff randmax <? ( 2drop tpop ; ) drop
|		) drop ) drop

	dup $3 and 3 << 'tlist + @ ex ;
	
:eval
	'tstack 'tstack> !
	0 't0 ! $ffff 't1 !
	0 'node ! 0 'rep ! 0 'idk ! | cont rep, cond childs
	tpush
	( tstack> 'tstack - 1? drop
		calcnodo
		) drop 
	;

|------------------------------------------
#mus1
|"a b c a" 
|"[a b c a]" 
"a b [c d a] e <e a>"
|"[ a b [c d] e ]"
|"b!2"
|"[a b? c]*2"
|"a b <c d e> [a c] [a b <a c>]"
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

| type|cnt|end|start

:printseq
	0 ( nseq <=?
		dup "%d: " .print
		dup ]seq @
		dup 32 >> $fff and "tok:%h " .print
		|dup 24 >> $ff and "cnt:%d " .print
		|dup 24 >> $fff and "len:%d " .println
		dup 12 >> $fff and
		swap $fff and | n end start
		( over <?
			dup "%h " .print
			1+ ) 2drop
		.cr
		1+ ) drop ;

:.ext
	;
	
:printoks
	0 'tokens ( tokens> <?
		swap dup "%h: " .print 1+ swap
		@+ 	.token
		dup "| %h " .print 
		drop 
		dup 8 - tok>ext @ 
		dup $ffffffff and "| %f" .print
		32 >> $ffffffff and " %f" .print
		
		.cr 
		) 2drop ;
		

:testnote
	parsenote "%d:" .print .ppw .cr ;
	
:testseq
	dup c@ "%k |" .print 1+ parsemod .ppw .cr ;
	
:main
	getch drop
	.cls
	"parse: " .print
	'mus1 dup .println 
	markseq .cr
	
	nseq "seq:%d " .print list> 'list - 2 >> "nlist:%d" .println .cr
	"----compile" .println
	compile
	"----list" .println
	printlist .cr
	"----seq" .println
	printseq .cr
	"----tokens" .println
	extinfo
	printoks
	
	"---------------------eval" .println
|	eval
	;


:
main
waitesc
;
