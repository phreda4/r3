| replfmt - automatic format of the definitions added to the project text (defs)
| ":name | a -- b"  the stack comment comes from the model (,mov of r3map), the old one is replaced
| the line ends after each word that takes values from the stack (the stack goes back)
| ( ) [ ] : the mark ends the line, the content goes one level in, the closing mark has its own line
| a blank line after each definition ; data, comments and boot words (": ") are left as they are
| defs-mark before adding the text, defs-fmt after the model knows the new words
^repl/replmodel.r3
^repl/replzone.r3

#ftk * 4096 #fpk * 4096 #fnm * 256
##fparen 1		| 1: the line ends after ( and [ and the block goes in ; 0: the block stays in the line until a word takes the stack back
#fi 1 #fb 1 #ffirst 0 #fblank 0
#fbk * 4096 #fbp 0	| one flag per open block: it has a line break inside
#dm0 0 #dl0 0

|---------------- tokens (the text is a stream: lines are not important, a definition ends at the next : # | in column 0)
:skipws | adr -- adr'
	( dup c@ $ff and 1? 33 <? drop 1+ ) drop ;

:col0? | adr -- adr 0/1
	dup 1- c@ $ff and
	10 =? ( drop 1 ; ) 13 =? ( drop 1 ; ) drop 0 ;

:bound? | adr -- adr 0/1 ; a definition, data or comment line starts here
	col0? 0? ( ; ) drop
	dup c@ $ff and
	$3a =? ( drop 1 ; ) $23 =? ( drop 1 ; ) $7c =? ( drop 1 ; )
	drop 0 ;

:rtcom | adr -- adr' ; comment up to the end of the line
	( dup c@ $ff and 1? 13 <>? 10 <>? ca!+ 1+ )
	drop 0 ca! ;

:rtstr | adr -- adr' ; "string" (a double quote inside is written twice)
	c@+ ca!+
	( dup c@ $ff and 1?
		34 =? ( drop c@+ ca!+ dup c@ $ff and 34 <>? ( drop 0 ca! ; ) )
		ca!+ 1+ )
	drop 0 ca! ;

:rtwrd | adr -- adr'
	( dup c@ $ff and 32 >? ca!+ 1+ )
	drop 0 ca! ;

:rtok0 | adr -- adr' ; next token, it is written at A (empty at the end)
	skipws
	dup c@ $ff and 0? ( drop 0 ca! ; ) drop
	dup c@ $ff and
	$7c =? ( drop rtcom ; )
	$22 =? ( drop rtstr ; )
	drop rtwrd ;

::rtokx | adr dst -- adr' ; next token in dst (the lines do not matter)
	>a rtok0 ;

:rtok | adr dst -- adr' ; the same, but empty at the next definition (: # | in the first column)
	>a skipws bound? 1? ( drop 0 ca! ; ) drop
	rtok0 ;

|---------------- what a token does to the stack
:digit? | c -- 0/1
	48 <? ( drop 0 ; ) 57 >? ( drop 0 ; ) drop 1 ;

:dig? | c -- 0/1
	48 <? ( drop 0 ; ) 57 >? ( drop 0 ; ) drop 1 ;

:hexd? | c -- 0/1
	dup dig? 1? ( 2drop 1 ; ) drop
	$20 or 97 <? ( drop 0 ; ) 102 >? ( drop 0 ; ) drop 1 ;

:decd? | c -- 0/1 ; a digit or the point of a fixed number
	46 =? ( drop 1 ; ) dig? ;

:bind? | c -- 0/1
	48 =? ( drop 1 ; ) 49 =? ( drop 1 ; ) drop 0 ;

:alld | adr -- 0/1 ; all the chars are digits (or a point)
	( c@+ $ff and 1? decd? 1? drop ) drop 1- c@ $ff and 0? ( drop 1 ; ) drop 0 ;

:allh | adr -- 0/1
	( c@+ $ff and 1? hexd? 1? drop ) drop 1- c@ $ff and 0? ( drop 1 ; ) drop 0 ;

:allb | adr -- 0/1
	( c@+ $ff and 1? bind? 1? drop ) drop 1- c@ $ff and 0? ( drop 1 ; ) drop 0 ;

::num? | adr -- 0/1 ; a number: 12  -3  0.5  $ff  %101  (0? 1+ 2* are words)
	dup c@ $ff and
	$24 =? ( drop 1+ dup c@ $ff and 0? ( 2drop 0 ; ) drop allh ; )
	$25 =? ( drop 1+ dup c@ $ff and 0? ( 2drop 0 ; ) drop allb ; )
	$2d =? ( drop 1+ dup c@ $ff and dig? 0? ( 2drop 0 ; ) drop alld ; )
	dig? 1? ( drop alld ; )
	2drop 0 ;

:eff>delta | eff -- delta ; data (-1) puts its value
	-? ( drop 1 ; ) $ff and 56 << 56 >> ;

:wdelta | adr -- delta ; project word, base word or library word (unknown: 0)
	dup m.find -? ( drop wfind 0? ( drop 0 ; ) drop ce eff>delta ; )
	nip m.eff eff>delta ;

:brk? | adr -- 0/1 ; the line can end here: a token follows that is not ( ) [ ] ; or a comment
	'fpk rtok drop
	'fpk c@ $ff and 0? ( ; )
	$7c =? ( drop 0 ; )
	'fpk 1+ c@ $ff and 1? ( 2drop 1 ; ) drop
	$28 =? ( drop 0 ; ) $29 =? ( drop 0 ; )
	$5b =? ( drop 0 ; ) $5d =? ( drop 0 ; )
	$3b =? ( drop 0 ; )
	drop 1 ;

|---------------- output
:f-brk | -- ; the block where we are has a line break inside
	fbp 1? ( drop 1 fbp 1- 'fbk + c! ; ) drop ;

:f-nl | -- ; ends the line (not if it is empty)
	fb 0? ( drop f-brk ,nl 1 'fb ! ; ) drop ;

:f-tabs | --
	fi ( 1? 1- 9 ,c ) drop ;

:f-out | "token" -- ; the indentation if it starts the line, a space if not
	fb 1? ( f-tabs 0 'fb ! ) 0? ( ,sp ) drop
	,s ;

:f-open | --
	'ftk f-out 1 'fi +!
	fparen fbp 'fbk + c! 1 'fbp +!
	fparen 1? ( f-nl ) drop ;

:f-close | --
	fbp 1? ( -1 'fbp +! fbp 'fbk + c@ $ff and 1? ( f-nl ) drop ) drop
	fi 1 >? ( -1 'fi +! ) drop
	'ftk f-out ;

:f-semi | adr -- adr ; a ; inside a block ends the line, unless the block closes next
	'ftk f-out
	fi 1 >? ( drop dup brk? 1? ( f-nl ) ) drop ;

:f-tok | adr -- adr ; the token in ftk
	'ftk "(" =s 1? ( drop f-open ; ) drop
	'ftk "[" =s 1? ( drop f-open ; ) drop
	'ftk ")" =s 1? ( drop f-close ; ) drop
	'ftk "]" =s 1? ( drop f-close ; ) drop
	'ftk ";" =s 1? ( drop f-semi ; ) drop
	'ftk c@ $ff and $7c =? ( drop 'ftk f-out f-nl ; ) drop
	'ftk f-out
	'ftk num? 1? ( drop ; ) drop
	'ftk c@ $ff and $27 =? ( drop ; ) $22 =? ( drop ; ) drop
	'ftk wdelta -? ( drop dup brk? 1? ( f-nl ) ) drop ;

:stkcom? | -- 0/1 ; the first token is the stack comment that the definition had
	ffirst 0? ( ; ) drop
	0 'ffirst !
	'ftk c@ $ff and $7c <>? ( drop 0 ; ) drop
	'ftk "--" findstr 1? ( drop 1 ; ) drop 0 ;

:f-body | adr -- adr'
	1 'fi ! 1 'fb ! 1 'ffirst ! 0 'fbp !
	( 'ftk rtok 'ftk c@ $ff and 1? drop
		stkcom? 0? ( drop f-tok 0 ) drop )
	drop f-nl ;

|---------------- a definition
:f-name | adr -- adr' ; ":name" as it was written
	( dup c@ $ff and 32 >? drop c@+ ,c ) drop ;

:f-stk | i -- ; " | a -- b" (the mov of the model: delta<<8 | use, as ,mov of r3map wants)
	m.eff -? ( drop ; )
	" | " ,s
	dup $ff and 8 << swap 8 >> $ff and or ,mov ;

:f-def | adr i -- adr'
	swap f-name swap f-stk ,nl
	f-body
	,nl 1 'fblank ! ;

:f-nmidx | adr -- adr i ; model index of the word of ":name" (-1 = boot word or unknown)
	dup 1+ dup c@ $ff and $3a =? ( drop 1+ 0 ) drop
	'fnm >a
	( dup c@ $ff and 32 >? ca!+ 1+ ) drop
	0 ca! drop
	'fnm c@ $ff and 0? ( drop -1 ; ) drop
	'fnm m.find ;

:f-copy | adr -- adr' ; a line as it is (one blank line at most after a definition)
	dup lcopy
	'lo2 c@ $ff and 0? ( drop fblank 0? ( drop ,nl 1 'fblank ! 0 ) drop nextl ; ) drop
	'lo2 ,s ,nl 0 'fblank ! nextl ;

:f-item | adr -- adr'
	dup c@ $ff and $3a <>? ( drop f-copy ; ) drop
	f-nmidx -? ( drop f-copy ; )
	f-def ;

::fmt-text | adr -- ; the formatted text is written with ,s
	0 'fblank !
	( dup c@ $ff and 1? drop f-item ) 2drop ;

|---------------- zones (replzone)
::fmt-zone | i -- ; formats the code zone i (the model must know the words)
	dup z.kind 1 <>? ( 2drop ; ) drop
	dup z.adr over z.len +
	dup c@ $ff and >r 0 over c!
	mark here
	pick2 z.adr fmt-text 0 ,c
	swap r> swap c!
	z.replace drop empty ;

::defs-fmt-all | -- ; formats every code zone and leaves one blank line after each zone
	m.ready z.build
	zn ( 1? 1- dup fmt-zone ) drop
	z.norm drop ;

|---------------- use
::defs-mark | -- ; before adding text to defs
	defs> 'dm0 ! defl 'dl0 ! ;

::defs-fmt | -- ; formats what was added since defs-mark (the model must know the new words)
	defs> dm0 =? ( drop ; ) drop
	mark here
	dm0 fmt-text 0 ,c
	dm0 'defs> ! 0 dm0 c! dl0 'defl !
	defs+n empty ;
