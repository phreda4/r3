| parse+vm
| PHREDA 2025

^r3/lib/console.r3
^r3/lib/rand.r3

|--- word stack ---
##stack * $ff
##stack> 'stack

:push stack> !+ 'stack> ! ;
:pop -8 'stack> +! stack> @ ;

#str$
#lvl
#aseq
#nseq

| tokenizado
| cant(8)seq(12)str(12)
##list * 1024
##list> 'list

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
	|]seq dup @ listnro or swap ! ;
	listnro swap ]seq ! ;	
	
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
:]seq-!	]seq -1 24 << swap +! ; | remove ]}>
	
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
	
:coma | *****
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
	'stack 'stack> !
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

##tokens * $fff
##tokens> 'tokens

:]token@ 3 << 'tokens + @ ;
:,tok	tokens> !+ 'tokens> ! ;

| EXT
| (seq=acc) (nodo=inc)
#extok * $fff

:]extok	3 << 'extok + ;
::tok>ext 'tokens - 'extok + ;

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
	2 + parsemod 
	dup 1+ ]list@ 12 >> $fff and | nro seq
	16 <<
	vars!or ;
	
:,seq	sub	1 or ,tok ;
:,alt	sub 2 or ,tok ;
:,par	sub 3 or ,tok ;
	
:token? | n end now -- n end now
	dup ]list@ 
	dup 12 >> $fff and | n end now L ln
	pick4 <>? ( 2drop ; ) drop | no this secuence	
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
	( over <? token? 1+ ) 2drop 		
|	error 1? ( "error en expr" ) drop
|	.cr
	;
	
:pass2
	'tokens 'tokens> !
	resetvars 1 vars!or ,tok | "a b" -> "[a b]"
	0 ( nseq <=?
		compseq 
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
		
::process | str --
	pass1 
	pass2
	pass3
	;

|------------------------------------------
##ccycle
#veval 0

:start+dur | v -- v
	dup 16 << + $ffffffff and ;

|:list reuse
:note | fnode token start|dur 
	over t.note 32 << over or push ;

:seq | fnode token start|dur
	dup $ffff and pick3 32 >> n.wsum@ /. |fnode token s|d scale ;
	pick2 t.fk pick3 t.nk 	
	pick3 swap | fnode token start|dur scale 1node start|dur cnt
	( 1? >r					| fnode token start|dur scale child start|dur ; r:nchild
		over n.acc@ pick3 *. | fnode token start|dur scale child stat|dur realdur
		over $ffff0000 and over or | fnode token start|dur scale child start|dur realdur newsd
		pick3 32 << or 
		veval ex
		| fnode token start|dur scale child start|dur realdur
		swap $ffff0000 and or
		start+dur 
		swap 1+ swap 
		r> 1- ) 4drop ;
	
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
		1+ r> 1- ) 2drop ;
		
:ran
	over t.fk pick2 t.nk randmax +
	32 << over or | add node info
	veval ex ;
	
#listv	'note 'seq 'alt 'poly 'ran 0 0 0

:(eval) | fnode --
	dup 32 >> ]token@ 	| fnode token
	dup t.scale over t.repeat *.	| fnode token total
	0? ( 1+ ) | ceil
	pick2 $ffff and over /			| fnode token total start|dur
	pick3 $ffff0000 and or swap 	| fnode token start|dur total
	( 1? >r			| fnode token start|dur
		over t.prob $ff randmax >? ( drop 
			over $7 and 3 << 'listv + @ ex 
			dup ) drop
		start+dur
		r> 1- ) 
	4drop ;
	
	
::eval |
	'(eval) 'veval !
	'stack 'stack> ! | evenl list
	$ffff (eval) ;
	
