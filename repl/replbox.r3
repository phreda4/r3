| replbox - the text box of r3repl2: text of several lines with cursor, mode, completeness, colors
| bx = the text (lines separated by LF, 0 at the end) ; bxc = cursor (byte index)
| bx.mode: 0 empty  1 immediate (it is run)  2 code (:)  3 data (#)  4 comments (|)  5 include (^)
| bx.color fills ba, one class per byte: 0 text  1 comment  2 string  3 number  4 base word  5 project word
|   6 library word  7 unknown word  8 definition name  9 marks ( ) [ ] ;  10 'address  11 include
^repl/replfmt.r3

##bx * 8192
##bxc 0
##bxy 0 ##bxx 0		| first visible line and column
#bxcol 0			| wanted column for up and down
##bxrz -1			| zone that is being replaced (-1 = a new one)
##bxdirty 1		| the classes (ba) are out of date
##ba * 8192
#bxo * 8192
#bsr 0 #bsc 0

::bx.len | -- n
	'bx count nip ;

|---------------- lines
:bx.sol? | i -- 0/1 ; i is at the start of a line
	0? ( drop 1 ; ) 1- 'bx + c@ $ff and 10 =? ( drop 1 ; ) drop 0 ;

::bx.ls | i -- s ; start of the line of i
	( dup bx.sol? 0? drop 1- ) drop ;

::bx.le | i -- e ; end of the line of i (the LF or the end of the text)
	( dup 'bx + c@ $ff and 1? 10 <>? drop 1+ ) drop ;

::bx.col | -- n
	bxc dup bx.ls - ;

::bx.line | -- n ; line of the cursor (0 = first)
	0 0 ( bxc <? dup 'bx + c@ $ff and 10 =? ( rot 1+ -rot ) drop 1+ ) drop ;

::bx.nl | -- n ; lines of the text
	1 0 ( dup 'bx + c@ $ff and 1? 10 =? ( rot 1+ -rot ) drop 1+ ) 2drop ;

::bx.lineat | n -- i ; start of line n
	0 swap ( 1? 1- swap bx.le 1+ swap ) drop bx.len min ;

:bx.sync | --
	bx.col 'bxcol ! 1 'bxdirty ! ;

|---------------- editing
::bx.clear | --
	0 'bx c! 0 'bxc ! 0 'bxy ! 0 'bxx ! 0 'bxcol ! -1 'bxrz ! 1 'bxdirty ! ;

:bx.room? | c -- c 0/1 ; there is room for the char (7900 in the text, 1990 in a line)
	bx.len 7900 >=? ( drop 0 ; ) drop
	dup 10 =? ( drop 1 ; ) drop
	bx.col 1990 <? ( drop 1 ; ) drop 0 ;

::bx.ins | c --
	bx.room? 0? ( 2drop ; ) drop
	'bx bxc + dup 1+ swap bx.len bxc - 1+ cmove>
	'bx bxc + c! 1 'bxc +! bx.sync ;

::bx.back | --
	bxc 0? ( drop ; ) drop
	'bx bxc + 1- dup 1+ bx.len bxc - 1+ cmove
	-1 'bxc +! bx.sync ;

::bx.del | --
	'bx bxc + c@ $ff and 0? ( drop ; ) drop
	'bx bxc + dup 1+ bx.len bxc - cmove
	bx.sync ;

::bx.left | --
	bxc 0? ( drop ; ) drop -1 'bxc +! bx.sync ;

::bx.right | --
	'bx bxc + c@ $ff and 0? ( drop ; ) drop 1 'bxc +! bx.sync ;

::bx.home | --
	bxc bx.ls 'bxc ! bx.sync ;

::bx.end | --
	bxc bx.le 'bxc ! bx.sync ;

::bx.up | -- 0/1 ; 0 = it was in the first line
	1 'bxdirty !
	bxc bx.ls 0? ( ; ) 1- dup bx.ls
	swap over - bxcol min + 'bxc ! 1 ;

::bx.down | -- 0/1 ; 0 = it was in the last line
	1 'bxdirty !
	bxc bx.le dup 'bx + c@ $ff and 0? ( 2drop 0 ; ) drop
	1+ dup bx.le over - bxcol min + 'bxc ! 1 ;

:bx.put | c -- ; the char at A (a CR is not copied, a tab is two spaces)
	a> 'bx - 7900 >=? ( 2drop ; ) drop
	13 =? ( drop ; ) 9 =? ( drop 32 ca!+ 32 ca!+ ; ) ca!+ ;

:bx.lastlf? | -- 0/1
	bx.len 0? ( ; ) 1- 'bx + c@ $ff and 10 =? ( drop 1 ; ) drop 0 ;

::bx.set | "text" -- ; the text in the box (CR LF becomes LF, no LF at the end), the cursor at the end
	'bx >a ( c@+ $ff and 1? bx.put ) 2drop 0 ca!
	( bx.lastlf? 1? drop 0 'bx bx.len + 1- c! ) drop
	bx.len 'bxc ! 0 'bxy ! 0 'bxx ! bx.sync ;

::bx.zone | i -- ; the text of zone i in the box (bxrz = i: the zone is replaced when the box is taken)
	dup 'bxrz !
	dup z.adr over z.len + dup c@ $ff and >r 0 over c!
	swap z.adr bx.set
	r> swap c! ;

::bx.out | -- adr ; the text with CR between the lines (as real-eval wants it)
	'bxo >a 'bx ( c@+ $ff and 1? 10 =? ( drop 13 ) ca!+ ) 2drop 0 ca! 'bxo ;

|---------------- the word at the cursor (completion)
::bx.word | -- i ; where the word before the cursor starts
	bxc ( dup 1? drop dup 1- 'bx + c@ $ff and 32 >? drop 1- ) drop ;

::bx.accept | "str" -- ; the word before the cursor is replaced by str and a space
	bx.word bxc over - ( 1? 1- bx.back ) 2drop
	( c@+ $ff and 1? bx.ins ) 2drop
	32 bx.ins ;

|---------------- mode
:ws? | c -- 0/1 ; a char that is not part of a word
	1? ( 33 <? ( drop 1 ; ) ) drop 0 ;

::bx.first | -- adr ; first char that is not a blank
	'bx ( dup c@ $ff and ws? 1? drop 1+ ) drop ;

::bx.mode | -- m
	bx.first c@ $ff and
	0? ( ; )
	$3a =? ( drop 2 ; ) $23 =? ( drop 3 ; ) $7c =? ( drop 4 ; ) $5e =? ( drop 5 ; )
	drop 1 ;

|---------------- completeness of a code zone: the text is tokenized (rtokx of replfmt)
#pd 0 #po 0 #ps 0 #pbad 0 #ptst 0 #pt * 8192

:quotes | str -- n
	0 swap ( c@+ $ff and 1? 34 =? ( rot 1+ -rot ) drop ) 2drop ;

:bx.col0? | -- 0/1 ; the token (ptst) starts a line
	ptst 'bx - 0? ( drop 1 ; ) drop
	ptst 1- c@ $ff and 10 =? ( drop 1 ; ) drop 0 ;

:bx.newdef | po' -- ; a definition starts
	po bx.col0? and 1? ( 1 'pbad ! ) drop
	'po ! ;

:bx.tok | -- ; the token in pt: pd ( [ open, po a : without its ;, ps string open, pbad a definition inside another
	'pt c@ $ff and
	$22 =? ( drop 'pt quotes 1 and 'ps ! ; )
	$3a =? ( drop 'pt 1+ c@ 1? ( 1 bx.newdef ) drop ; )
	$23 =? ( drop 'pt 1+ c@ 1? ( 0 bx.newdef ) drop ; )
	'pt 1+ c@ 1? ( 2drop ; ) drop
	$28 =? ( 1 'pd +! ) $5b =? ( 1 'pd +! )
	$29 =? ( -1 'pd +! ) $5d =? ( -1 'pd +! )
	$3b =? ( pd 0? ( 0 'po ! ) drop )
	drop ;

::bx.parse | -- ; fills pd po ps pbad
	0 'pd ! 0 'po ! 0 'ps ! 0 'pbad !
	'bx ( 'pt rtokx 'pt c@ $ff and 1? drop
		dup 'pt count nip - 'ptst ! bx.tok )
	2drop ;

::bx.complete? | -- 0/1 ; the zone can be taken (not a code zone, or the code zone is closed)
	bx.mode 2 <>? ( drop 1 ; ) drop
	bx.parse
	pbad 1? ( drop 1 ; ) drop
	ps 1? ( drop 0 ; ) drop
	pd 0 >? ( drop 0 ; ) drop
	po 1? ( drop 0 ; ) drop
	1 ;

::bx.err | -- "msg" ; why a code zone is wrong (0 = it is fine) ; after bx.complete?
	ps 1? ( drop "string not closed" ; ) drop
	pd -? ( drop "unmatched )" ; ) drop
	pbad 1? ( drop "missing ;  before the next definition" ; ) drop
	pd 1? ( drop pd "%d ( not closed" sprint ; ) drop
	po 1? ( drop "missing ;" ; ) drop
	0 ;

|---------------- colors
:bx.incursor? | -- 0/1 ; the cursor is in the token (or at its end)
	ptst 'bx - bxc >? ( drop 0 ; )
	'pt count nip + bxc <? ( drop 0 ; ) drop 1 ;

:wf | -- 0/1/2 ; wfind of the token in pt, without changing cw cl ce (the run of a line needs them while the box is drawn)
	cw cl ce 'pt wfind >r 'ce ! 'cl ! 'cw ! r> ;

:bx.cls | -- class ; of the token in pt
	'pt c@ $ff and
	$7c =? ( drop 1 ; ) $22 =? ( drop 2 ; ) $5e =? ( drop 11 ; )
	$3a =? ( drop 8 ; ) $23 =? ( drop 8 ; ) $27 =? ( drop 10 ; )
	drop
	'pt 1+ c@ $ff and 0? ( drop 'pt c@ $ff and
		$28 =? ( drop 9 ; ) $29 =? ( drop 9 ; ) $5b =? ( drop 9 ; ) $5d =? ( drop 9 ; ) $3b =? ( drop 9 ; )
		) drop
	'pt num? 1? ( drop 3 ; ) drop
	'pt m.find -? ( drop wf 0? ( drop bx.incursor? 0? ( drop 7 ; ) drop 0 ; ) 1 =? ( drop 4 ; ) drop 6 ; )
	drop 5 ;

:bx.paint | start len class --
	rot 'ba + >a swap ( 1? 1- over ca!+ ) 2drop ;

::bx.color | -- ; classes of the bytes of the text (only if the text changed)
	bxdirty 0? ( drop ; ) drop 0 'bxdirty !
	'ba >a bx.len 1+ ( 1? 1- 0 ca!+ ) drop
	'bx ( 'pt rtokx 'pt c@ $ff and 1? drop
		dup 'pt count nip - 'ptst !
		ptst 'bx - 'pt count nip bx.cls bx.paint )
	2drop ;

::bx.scroll | rows cols -- ; the cursor stays in the window
	'bsc ! 'bsr !
	bx.line bxy <? ( dup 'bxy ! ) drop
	bx.line bxy bsr + >=? ( dup bsr - 1+ 'bxy ! ) drop
	bx.col bxx <? ( dup 'bxx ! ) drop
	bx.col bxx bsc + >=? ( dup bsc - 1+ 'bxx ! ) drop ;
