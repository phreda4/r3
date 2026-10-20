| replfmt - automatic format of the definitions added to the project text (defs)
| ":name | a -- b"  the stack comment comes from the model (,mov of r3map), the old one is replaced
| the line ends after each word that takes values from the stack (the stack goes back)
| ( ) [ ] : the mark ends the line, the content goes one level in, the closing mark has its own line
| a blank line after each definition ; data, comments and boot words (": ") are left as they are
| defs-mark before adding the text, defs-fmt after the model knows the new words
^repl/replmodel.r3

#ftk * 1024 #fpk * 1024 #fnm * 128
#rdst 0
#fi 1 #fb 1 #ffirst 0 #fblank 0 #fmi 0
#dm0 0 #dl0 0 #ftmp 0

|---------------- tokens (the text is a stream: lines are not important, a definition ends at the next : # | in column 0)
:rput | c --
	rdst c!+ 'rdst ! ;

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
	( dup c@ $ff and 1? 13 <>? 10 <>? rput 1+ )
	drop 0 rdst c! ;

:rtstr | adr -- adr' ; "string" (a double quote inside is written twice)
	c@+ rput
	( dup c@ $ff and 1?
		34 =? ( drop c@+ rput dup c@ $ff and 34 <>? ( drop 0 rdst c! ; ) )
		rput 1+ )
	drop 0 rdst c! ;

:rtwrd | adr -- adr'
	( dup c@ $ff and 32 >? rput 1+ )
	drop 0 rdst c! ;

:rtok | adr dst -- adr' ; next token in dst (empty at the end or at the next definition)
	'rdst !
	skipws bound? 1? ( drop 0 rdst c! ; ) drop
	dup c@ $ff and 0? ( drop 0 rdst c! ; ) drop
	dup c@ $ff and
	$7c =? ( drop rtcom ; )
	$22 =? ( drop rtstr ; )
	drop rtwrd ;

|---------------- what a token does to the stack
:digit? | c -- 0/1
	48 <? ( drop 0 ; ) 57 >? ( drop 0 ; ) drop 1 ;

:num? | adr -- 0/1
	dup c@ $ff and
	dup digit? 1? ( 3drop 1 ; ) drop
	$24 =? ( drop 1+ c@ $ff and 32 >? ( drop 1 ; ) drop 0 ; )
	$25 =? ( drop 1+ c@ $ff and 32 >? ( drop 1 ; ) drop 0 ; )
	$2d =? ( drop 1+ c@ $ff and digit? ; )
	$2b =? ( drop 1+ c@ $ff and digit? ; )
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
:f-nl | -- ; ends the line (not if it is empty)
	fb 0? ( drop ,nl 1 'fb ! ; ) drop ;

:f-tabs | --
	fi ( 1? 1- 9 ,c ) drop ;

:f-out | "token" -- ; the indentation if it starts the line, a space if not
	fb 1? ( f-tabs 0 'fb ! ) 0? ( ,sp ) drop
	,s ;

:f-open | --
	'ftk f-out 1 'fi +! f-nl ;

:f-close | --
	f-nl fi 1 >? ( -1 'fi +! ) drop
	'ftk f-out ;

:f-semi | -- ; a ; inside a block ends the line
	'ftk f-out
	fi 1 >? ( drop f-nl ; ) drop ;

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
	1 'fi ! 1 'fb ! 1 'ffirst !
	( 'ftk rtok 'ftk c@ $ff and 1? drop
		stkcom? 0? ( drop f-tok 0 ) drop )
	drop f-nl ;

|---------------- a definition
:f-name | adr -- adr' ; ":name" as it was written
	( dup c@ $ff and 32 >? drop c@+ ,c ) drop ;

:f-stk | -- ; " | a -- b" (the mov of the model: delta<<8 | use, as ,mov of r3map wants)
	fmi m.eff -? ( drop ; )
	" | " ,s
	dup $ff and 8 << swap 8 >> $ff and or ,mov ;

:f-def | adr i -- adr'
	'fmi !
	f-name f-stk ,nl
	f-body
	,nl 1 'fblank ! ;

:f-nmidx | adr -- adr i ; model index of the word of ":name" (-1 = boot word or unknown)
	dup 1+ dup c@ $ff and $3a =? ( drop 1+ 0 ) drop
	'fnm 'rdst !
	( dup c@ $ff and 32 >? rput 1+ ) drop
	0 rdst c! drop
	'fnm c@ $ff and 0? ( drop -1 ; ) drop
	'fnm m.find ;

:f-copy | adr -- adr' ; a line as it is (one blank line at most after a definition)
	dup 'lo2 strcpyln
	'lo2 c@ $ff and 0? ( drop fblank 0? ( drop ,nl 1 'fblank ! 0 ) drop nextl ; ) drop
	'lo2 ,s ,nl 0 'fblank ! nextl ;

:f-item | adr -- adr'
	dup c@ $ff and $3a <>? ( drop f-copy ; ) drop
	f-nmidx -? ( drop f-copy ; )
	f-def ;

:fmt-text | adr -- ; the formatted text is written with ,s
	0 'fblank !
	( dup c@ $ff and 1? drop f-item ) 2drop ;

|---------------- use
::defs-mark | -- ; before adding text to defs
	defs> 'dm0 ! defl 'dl0 ! ;

::defs-fmt | -- ; formats what was added since defs-mark (the model must know the new words)
	defs> dm0 =? ( drop ; ) drop
	mark here 'ftmp !
	dm0 fmt-text 0 ,c
	dm0 'defs> ! 0 dm0 c! dl0 'defl !
	ftmp defs+n
	empty ;
