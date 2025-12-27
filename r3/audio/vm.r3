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
	+item 1+
	aseq push
	newseq
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
|------------------------------------------------
|  0 OP_END 
|  1 OP_NOTE,        // note_id
|  2 OP_SEQ,         // n, jump [ ]
|  3 OP_PAR,         // n, jump ,
|  4 OP_ALT,         // n, jump < >
|  5 OP_REPEAT,      // count repita
|  6 OP_EVERY,       // period elige por ciclo
|  7 OP_CHANCE,      // prob (0..255)
|  8 OP_TIME_SCALE,  // factor fp
|  9 OP_TIME_SHIFT,  // offset fp
|  10 OP_SEED,        // seed (random)
|  11 OP_RET          // fin de bloque
| Nodo         | Qué hace                     |
| ------------ | ---------------------------- |
| `SEQ`        | Divide el frame en N partes  |
| `PAR`        | Duplica el frame (no divide) |
| `ALT`        | Elige un frame completo      |
| `REPEAT`     | Reusa el frame               |
| `TIME_SCALE` | Escala el frame              |
| `TIME_SHIFT` | Desplaza el frame            |

#tokens * $fff
#tokens> 'tokens

:,,
	tokens> d!+ 'tokens> ! ;
	
:,note |
	4 << 1 or ,, ;



|Identidad: La nota misma (a#3)
:getid | str -- str 0/nota
	;
|Velocidad/Repetición: *, /, !, @
:getvel
	;
|Probabilidad: ?
:getpro
	;
|Euclidiano: ( )
:geteuc
	;
:getmodi
	| *2 acelera
	| /2 retrasa
	| !2 repite
	| ? probabilidad 0.5 ?.3
	| :1 variante
	| nro octava
	;

| `*n` | Multiplicación | Acelera n veces | `bd*2` |
| `/n` | División | Ralentiza n veces | `bd/2` |
| `!n` | Repetición | Repite n veces | `bd!3` |
| `< >` | Ángulos | Alterna cada ciclo | `<bd sd>` |
| `[ ]` | Corchetes | Sub-secuencia | `[bd hh]` |
| `,` | Coma | Superpone | `bd, hh*4` |
| `{ }` | Llaves | Polimetría | `{bd sd, kick}` |
| `(n,m)` | Paréntesis | Euclidiano | `bd(3,8)` |
| `?` | Interrogación | Probabilidad 50% | `bd?` |
| `~` | Tilde | Silencio | `bd ~ sd` |
| `:n` | Dos puntos | Variante/índice | `bd:2` |
	
:getcell | str -- ncell
	dup c@
	
	|.	| float
	|0..9 | int/float
	|a..g | nota
	| (	** real para parametros en nota
	| < alternancia
	| [ subsecuencia
	| { polimetria
	| , superpocision
	| ~_ silencio
	;
	
:compile
	'seq ( seq> <?
		d@+ 
		dup $fff and str$ + getcell
		"%h " .print
		dup 12 >> $ff and "lvl:%d " .print
		20 >> $ff and "seq:%d " .print .cr
		) 2drop ;
		
|------------------------------------
#t0 #t1

#tstack * $ff
#tstack>
#rstack * $7f
#rstack>

:o0 |  0 OP_END \ HIDDEN xxxxxxx0
	drop ;

:o1	|  1 OP_NOTE,        // note_id
	4 >> "play:%h " .print
	t0 t1 over - swap "t0:%f d:%f" .println
	;
	
|  2 OP_SEQ,         // n, jump [ ]
:o2	;
|  3 OP_PAR,         // n, jump ,
:o3	;
|  4 OP_ALT,         // n, jump < >
:o4	;
|  5 OP_REPEAT,      // count repita
:o5	;
|  6 OP_EVERY,       // period elige por ciclo
:o6	;
|  7 OP_CHANCE,      // prob (0..255)
:o7	;
| 8 OP_TIME_SCALE,  // factor fp
:o8	;
|  9 OP_TIME_SHIFT,  // offset fp
:o9	;
|  10 OP_SEED,        // seed (random)
:oa	;
|  11 OP_RET          // fin de bloque
:ob	
:oc	
:od	
:oe	
:of	drop ;

#oplist o0 o1 o2 o3 o4 o5 o6 o7 o8 o9 oa ob oc od of	

:eval
	0 't0 ! 1.0 't1 !
	'rstack 'rstack> !
	'tstack 'tstack> !
	'tokens 
	( d@+ 1? 
		dup $f and 3 << 'oplist + @ ex ) 
	2drop ;

|------------------------------------------------
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


#mus1
"a"
"b*2"
"[a b c]"
"a b <c d e> [a c] (a b <a c>)"
"<
[[g#2 g#3]*2 [e2 e3]*2]
,
[a b c]
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

:ej1
	;
	
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
	
	|compile
	'tokens >a
	$11 da!+
	0 da!+
	eval
	;


:
main
waitesc
;
