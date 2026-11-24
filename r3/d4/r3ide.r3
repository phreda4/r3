| TUI IDE
| PHREDA 2025

^r3/util/tui.r3
^r3/util/tuiedit.r3
|^r3/lib/trace.r3

^r3/d4/r3token.r3
^r3/d4/helptxt.r3

#msg * 1024		| last line msg

#vwords 0 0

#lwords

|---- change error mode
:moderror
	lerror tuiecursor! ;

|---- colors: the palette of the tui (util/tui.r3); the code ones are the colors of the editor (tcol)
:fBk 0 cfg ;					| dark text, for the badges of the mode
:bgBl 8 cbg ;	:bgPu 9 cbg ;	:bgGr 10 cbg ;	:bgRd 11 cbg ;

:topbar | 'bg "badge" -- ; first row: mode badge, file name and cursor
	1 flxN bg3 fTx fhome
	swap ex fBk .write bg3 fTx .sp
	'filename .write .sp
	" | " .write tuecursor. .write ;

:makelistwords
	here dup 'lwords !
	dic< 
	|dic
	( dic> <? | solo codigo principal
		dup dic - 4 >> 1+ rot w!+ swap
		16 + ) drop
	0 swap w!+ 'here ! ;

|---------- TAGS in code	
| $..............01 - code/data
| $..............02 - loc/ext
| $..............04	1 es usado con direccion
| $..............08	1 r esta desbalanceada		| var cte
| $..............10	0 un ; 1 varios ;
| $..............20	1 si es recursiva
| $..............40	1 si tiene anonimas
| $..............80	1 termina sin ;

:wordhead
	nro>dic @+ 
	1 and? ( 4 tcol .fc dic>name "#%w" ,print ,eol drop ; ) 
	3 tcol .fc 
	dup 
	dic>name ":%w | " ,print 
	swap @ 
	dup $ff and 8 << swap 8 >> $ff and or hw.effab ,s
	"  " ,s
	$10 and? ( ";" ,s )	| multiple
	$20 and? ( "R" ,s )	| recurse
	$80 and? ( "." ,s )	| no ;
	drop
	,eol ;
	
:xwriten.word | n --
	1- $ffff and 
	mark wordhead empty here lwrite ;
	
|---- helpword
#helpword * 32

:cpyhword | adr -- 
	'helpword 
	31 ( 1? 1- -rot		| copy word
		swap c@+ $ff and 
		32 <=? ( 2drop 0 swap c! drop ; )
		rot c!+ rot
		) drop
	0 swap c! 
	drop ;

:cprev | adr -- adr c ; the char before adr (0 at the start of the source)
	dup fuente >? ( dup 1- c@ $ff and ; ) 0 ;

:<<sp | adr -- adr' ; adr@=space
	( cprev 32 >? drop 1- ) drop ;
	
:cpyhelpword
	fuente> <<sp cpyhword ;

:<<: | adr -- adr' ; adr@=:
	( fuente =? ( ; ) dup 1- c@ 
		$3a <>? | :
		$23 <>? | #
		drop 1- ) drop ;

:cpydefword 
	fuente> <<: cpyhword ;
	
:searchword | -- nro
	cntdef ( 1? 1-
		dup nro>dic @ dic>name
		'helpword =w 1? ( drop ; )
		drop ) ;
	
|---- screen
#nowword

:setcursoride
	vwords uiNindxn 1-
	dup 'nowword !
	nro>dic @
	|40 >> src + "%l" sprint 'msg strcpy 
	40 >>> fuente + |1- | :#
	tuiecursor!	
	;
		
|---- CHECKCODE
:cntlines | -- nrolin
	1 fuente 
	( lerror <?
		c@+ 13 =? ( rot 1+ -rot ) drop
		) drop ;
		
:coderror | error --
	.cl bgRd fBk lerror " %w | " .print
	.write cntlines " in line %d" .print 
	.eline
	'msg strcpybuf ;
	
:codeok
	.cl
	cnttok cntdef cntinc " OK | inc:%d words:%d tokens:%d" .print 
	.eline
	'msg strcpybuf ;

:checkcode
	TuSaveCode
	0 'msg !
	fuente 'filename r3loadmem
	error 1? ( coderror ; ) drop 
	codeok 
	;

:codeerr? | -- 0/1 ; compile the code; 1 = error (the cursor goes to it)
	checkcode error 1? ( drop moderror 1 ; ) drop 0 ;

:togglechk | F6: error if the ; of a word leave different stack
	retstrict 1 xor 'retstrict !
	checkcode ;
	
|--- F3 Rx: the stack of a word, token by token
| ENTER on a word of the list: one row for each token of the word.
|  TOKEN   the token, indented by the level of ( ) and [ ]
|  EFFECT  the effect of the token (help text of the base words, computed for the rest);
|          at ; the effect of the whole word; in red: ) that leaves the stack different, ; that exits
|          with another stack than the first ; or with the return stack unbalanced
|  STACK   the values, top at the right: a b c... are the entry of the word, the other
|          are named by the token that made them; x|y after a ?? ( ) is the value if the block
|          is skipped | if it runs (in a loop: at the entry | after one turn); ? unknown
| the data of r3token (deltaD, usoD, deltaR) is the truth; the names follow the effect of each token.

#vanaly 0 0
#rxtkw * $4000		| state of r3token after each token (2048 at most)
#lanaly * $7ffff		| the rows of the word
:rxmax 'lanaly $7bfff + ;	| a row is written only before this

:,scnt | str cnt -- ; the text cut or padded to cnt columns
	swap utf8count					| cnt str scount
	pick2 >? ( drop over ) swap	| cnt scnt str
	here pick2 utf8ncpy 'here !
	- ,nsp ;

:wD 40 << 56 >> ;		| w -- deltaD  (w = wwinfo of r3token)
:wR 56 << 56 >> ;		| w -- deltaR

|---- symbolic stack: each value is a label = color byte + text + 0
#rxsk * 2048		| 256 labels
#rxn 0			| values in the stack
#rxb 0			| base of the frame (the stack of the anonymous word [ ] being analyzed)
#rxneed 0		| values taken from the caller by the whole word

#rxpool * $ffff		| the labels
#rxpool> 0
#rxqm ( 8 63 0 )		| ? unknown
#rxtl 0 0

|---- a label in the pool, 20 chars at most
:rxlbl | 'str col -- lbl
	rxpool> 'rxpool $ffd0 + >=? ( 3drop 'rxqm ; )
	swap over c!+				| str p dst
	rot utf8count 20 min			| p dst str cnt
	rot swap utf8ncpy			| p end
	0 swap c!+ 'rxpool> ! ;

:rxpush | lbl --
	rxn 254 >? ( 2drop ; )
	3 << 'rxsk + ! 1 'rxn +! ;

:rxpop | -- lbl
	rxn rxb <=? ( drop 'rxqm ; )
	drop -1 'rxn +! rxn 3 << 'rxsk + @ ;

:rxinlbl | i -- lbl ; a b c ...
	97 + 'rxtl c! 0 'rxtl 1+ c! 'rxtl 2 rxlbl ;

:rxinit | need --
	dup 'rxneed !
	0 'rxn ! 0 'rxb ! 'rxpool 'rxpool> !
	0 ( over <? dup rxinlbl rxpush 1+ ) 2drop ;

:rxsync | w -- ; the depth of the symbolic stack follows r3token
	wD rxneed + rxb max 255 min
	( rxn over >? drop rxpop drop ) drop
	( rxn over <? drop 'rxqm rxpush ) drop
	drop ;

|---- the effect text of a base word: "a b -- b a"
#rxefs * 128
#rxlnm * 128		| the names at the left of --
#rxlnn 0
#rxlpop * 128		| the labels taken by each name
#rxnnew 0		| new values made by the token
#rxtxt * 32		| text of the token
#rxcol 0			| color of the token

:rxnew | -- ; a new value named by the token
	rxnnew 0? ( drop 'rxtxt rxcol rxlbl rxpush 1 'rxnnew ! ; )
	'rxtxt "%s'%d" sprint rxcol rxlbl rxpush 1 'rxnnew +! ;

:efnext | adr -- adr' tok/0 ; next word of the effect (0 at the end or at the "(r:" part)
	( dup c@ $ff and 1? 33 <? drop 1+ ) drop
	dup c@ $ff and 0? ( drop 0 ; ) $28 =? ( drop 0 ; ) drop
	dup >>sp swap ;

:lnadd | tok --
	rxlnn 15 >? ( 2drop ; )
	3 << 'rxlnm + ! 1 'rxlnn +! ;

:efleft | adr -- adr' ; names at the left of --
	0 'rxlnn !
	( efnext dup "--" =s 0? drop lnadd ) 2drop ;

:efput | tok -- ; a name at the right: a value that was at the left, or a new one
	0 ( rxlnn <?
		dup 3 << 'rxlnm + @ pick2 =s 1?
			( drop nip 3 << 'rxlpop + @ rxpush ; ) drop
		1+ ) 2drop
	rxnew ;

:efright | adr --
	( efnext 1? efput ) 2drop ;

:rxhelp | n -- 1/0 ; applies the effect text of the help; 0 = there is none
	7 - bhelp 'rxefs 120 hw.eff
	'rxefs c@ $ff and 0? ( ; ) drop
	'rxefs efleft
	rxlnn ( 1? 1- rxpop over 3 << 'rxlpop + ! ) drop
	0 'rxnnew !
	efright 1 ;

:rxgen | eff -- ; by the numbers: takes use values, makes use+delta new ones
	0 'rxnnew !
	dup 8 >> $ff and swap 56 << 56 >> over +	| use out
	swap ( 1? 1- rxpop drop ) drop		| out
	( 1? 1- rxnew ) drop ;

|---- blocks ( ): the stack at the ( to mark what changed inside
#rxsnap * $10000
#rxsnap> 0
#rxsnapx 0		| blocks without a copy (it did not fit)

:rxopen | --
	rxsnap> rxn + 8000 >? ( drop 1 'rxsnapx +! ; ) drop
	'rxsnap rxsnap> 3 << + 'rxsk rxn 3 << cmove
	rxn rxsnap> rxn + 3 << 'rxsnap + !
	rxsnap> rxn + 1+ 'rxsnap> ! ;

:rxmerge | now before -- lbl ; a position after ( ): the same value, or before|now
	over =? ( drop ; )
	1+ swap 1+ swap "%s|%s" sprint 3 rxlbl ;

:rxclose | --
	rxsnapx 1? ( drop -1 'rxsnapx +! ; ) drop
	rxsnap> 1- 3 << 'rxsnap + @			| n
	dup 1+ neg 'rxsnap> +!
	rxn min 0 ( over <?				| m i
		dup 3 << 'rxsk + @
		over rxsnap> + 3 << 'rxsnap + @
		rxmerge over 3 << 'rxsk + !
		1+ ) 2drop ;

|---- anonymous words [ ]: its own stack above the base
#rxfrm * 256
#rxfrm> 0

:rxfo | --
	rxfrm> 31 <? ( rxb over 3 << 'rxfrm + ! 1+ 'rxfrm> ! rxn 'rxb ! ; ) drop ;

:rxfc | --
	rxfrm> 0? ( drop ; )
	rxb 'rxn !
	1- dup 'rxfrm> ! 3 << 'rxfrm + @ 'rxb ! ;

:rxstep | tok eff -- ; the symbolic stack follows one token
	swap $ff and				| eff n
	7 <? ( drop rxgen ; )		| numbers, calls, strings, addresses
	7 =? ( 2drop ; )			| ;
	8 =? ( 2drop rxopen ; )		| (
	9 =? ( 2drop rxclose ; )		| )
	10 =? ( 2drop rxfo ; )		| [
	11 =? ( drop rxfc rxgen ; )		| ]
	dup rxhelp 1? ( 3drop ; ) 2drop rxgen ;

|---- the token alone
:tokstr | tok -- str ; the text of the token
	dup $ff and 6 >? ( nip 7 - basename ; ) drop
	40 >>> src + "%w" sprint ;

:tokcol | n -- mark ; the color of the token (the colors of the editor, 9 = string)
	0? ( drop 6 ; ) 1 =? ( drop 6 ; ) 2 =? ( drop 7 ; ) 3 =? ( drop 5 ; )
	4 =? ( drop 4 ; ) 5 =? ( drop 5 ; ) 6 =? ( drop 9 ; )
	12 <? ( drop 3 ; ) drop 7 ;

:probe | ptr -- eff ; the effect of one token alone: use<<8 | delta
	resetinfo @+ tokeninfo drop wwinfo
	dup 8 >> $ff and 8 << swap 16 >> $ff and or ;

|---- the row of a token
#rxtok 0 #rxw 0 #rxeff 0	| token, state of r3token after it, its effect
#rxpw 0 #rxpt 0		| state and type of the token before
#rxxd 0 #rxxs 0		| depth of the first ; and if there was one

:rxblk | -- str/0 ; ) that leaves a different stack than the analyzer assumes
	rxpt 7 =? ( drop 0 ; ) drop
	rxpw wD rxw wD - 0? ( drop 0 ; )
	+? ( "block +%d" sprint ; ) "block %d" sprint ;

:rxexit | -- str/0 ; ; with return stack unbalanced or other stack than the first ;
	rxw wR 1? ( drop "R unbalanced" ; ) drop
	rxxs 0? ( drop rxw wD 'rxxd ! 1 'rxxs ! 0 ; ) drop
	rxw wD rxxd <>? ( drop "exit differs" ; ) drop 0 ;

:rxwarn | -- str/0
	rxtok $ff and
	9 =? ( drop rxblk ; )
	7 =? ( drop rxexit ; )
	drop 0 ;

:rxefftxt | -- str mark
	rxwarn 1? ( 8 ; ) drop
	rxtok $ff and
	7 =? ( drop rxneed 8 << rxw wD $ff and or hw.effab 3 ; )
	8 >=? ( 12 <? ( drop "" 2 ; ) )
	12 >=? ( drop 'rxefs c@ $ff and 1? ( drop 'rxefs 2 ; ) drop rxeff hw.effab 2 ; )
	drop rxeff hw.effab 2 ;

:rxlvl | -- n ; indent in levels
	rxw 32 >> $ff and rxtok $ff and
	8 =? ( drop 1- 0 max 6 min ; ) 10 =? ( drop 1- 0 max 6 min ; ) drop
	6 min ;

:,pic | -- ; the stack, top at the right (the last 24 values)
	12 ,c
	rxn 24 - 0 max 1? ( 2 ,c ".. " ,s )
	( rxn <? dup 3 << 'rxsk + @ ,s 32 ,c 1+ ) drop ;

:rxline | --
	rxlvl 2* dup ,nsp
	rxcol ,c 'rxtxt swap 16 swap - 4 max ,scnt
	rxefftxt ,c 20 ,scnt
	,pic ,eol ;

:tokline | ptr i --
	'rxtkw swap 3 << + @ 'rxw !
	dup @ 'rxtok !
	probe 'rxeff !
	rxtok tokstr 'rxtxt 28 hw.cpy
	rxtok $ff and tokcol 'rxcol !
	rxtok rxeff rxstep
	rxw rxsync
	here rxmax <? ( rxline ) drop
	rxw 'rxpw ! rxtok $ff and 'rxpt ! ;

|---- the passes over the tokens of a word
:pass1 | tok len -- ; r3token over the tokens
	ab[ 'rxtkw >a
	resetinfo
	( 1? 1- swap @+ tokeninfo wwinfo a!+ swap ) 2drop
	]ba ;

:rxentry | -- ; the first row: the values of the entry
	2 ,c "(in)" 16 ,scnt
	2 ,c "" 20 ,scnt
	,pic ,eol ;

:pass2 | tok len --
	0 'rxxs ! 0 'rxpw ! 0 'rxpt ! 0 'rxfrm> ! 0 'rxsnap> ! 0 'rxsnapx !
	rxentry
	0 ( over <? pick2 over 3 << + over tokline 1+ ) 3drop ;

:rxbody | dic -- ; the rows of the word
	dup @ 1 and? ( drop @ dic>name 4 ,c "#%w  (data)" ,print ,eol ; ) drop
	toklen 2048 min
	2dup pass1
	wwinfo 8 >> $ff and rxinit
	pass2
	here rxmax >? ( 8 ,c "(more tokens, not shown)" ,s ,eol ) drop ;

:setanalysis
	mark 'lanaly 'here !
	nowword nro>dic rxbody
	0 ,c
	empty
	0 'vanaly ! ;

|---- writes a row with colors: the bytes 1..9 of the text are colors, 12 starts the stack
:vis? | c -- 0/1 ; the byte takes a column
	32 <? ( drop 0 ; ) $c0 and $80 =? ( drop 0 ; ) drop 1 ;

:lvis | str -- n ; columns of the text
	0 swap ( c@+ $ff and 1? vis? rot + swap ) 2drop ;

:wcol | c -- ; a color mark
	8 =? ( drop 196 .fc ; )
	9 =? ( drop 0 tcol .fc ; )
	7 >? ( drop ; )
	0? ( drop ; )
	tcol .fc ;

:wbyte | w c -- w' ; a mark, or a char if there is room
	32 <? ( wcol ; )
	over 1 <? ( 3drop 0 ; ) drop
	dup $c0 and $80 =? ( drop .emit ; ) drop
	.emit 1- ;

:skipitem | -- n ; B is at a color mark: skips that value, returns its columns
	cb@+ drop
	0 ( cb@ $ff and 31 >? drop cb@+ drop 1+ ) drop ;

:wpic | w -- w' ; if the stack does not fit, the bottom values are cut: the top is what matters
	2 <? ( ; )
	b> lvis over <=? ( drop ; )
	( over 2 - >? skipitem - ) drop
	2 tcol .fc ".." .write 2 - ;

:padw | w --
	( 1? 1- .sp ) drop ;

:xwline | w str -- ; the writer of the rows of the word
	ab[ >b
	( cb@+ $ff and 1?
		12 =? ( drop wpic 0 )
		wbyte )
	drop padw
	]ba ;

|---- screens
#modefx
:fxlist
	cols 2/ flxE | 1/2 of screen
	.reset bg1 fPu
	tuwina $1 " Rx " .wtitle fTx 1 1 flpad .wfill 
	'xwriten.word xwriten!
	'vwords lwords tuListn | 'var list --
	tuX? 1? ( setcursoride ) drop
	xwriten.reset
	;

:wtitle | -- str ; name and effect of the word
	nowword nro>dic dup @ 1 and? ( drop @ dic>name " #%w " sprint ; ) drop
	dup 8 + @ dup $ff and 8 << swap 8 >> $ff and or hw.effab
	swap @ dic>name " %w | %s " sprint ;

:fxword
	cols dup 2/ + 2/ flxE | 3/4 of screen
	.reset bg1 fPu
	tuwina $1 wtitle .wtitle fTx 1 1 flpad .wfill 
	fhome fMu " token           effect               stack (top at right)" .lw
	1 'fy +! -1 'fh +!
	'xwline xwrite!
	'vanaly 'lanaly tuList | 'var list --
	xwrite.reset
	;

#modelfx fxlist fxword


:rxmode | -- "text" ; the mode of F3: the list of the words or the analysis of one
	modefx 0? ( drop " F3 RX list " ; ) drop " F3 RX word " ;

:fxwin
	.reset
	'bgPu rxmode topbar
	.sp 'helpword .write
	.eline
	
	1 flxS 
	bg3 fhome 
	fPr " ESC" .write fTx " Exit" .write 
	fPr " ENTER" .write fTx " Word" .write 
	fPr " BACK" .write fTx " Dicc" .write 
	fTx " | " .write 'helpword .write " | " .write
	'msg .write
	.eline
	
	modefx 3 << 'modelfx + @ ex
	
	flxRest 
	tuReadCode
	
	uiKey
	[esc] =? ( tuiexit ) 
	[enter] =? ( setanalysis 1 'modefx ! )
	[back] =? ( modefx 0? ( tuiexit ) drop 0 'modefx ! )
	drop ;

:setvwords | nrow --
	lwords ( w@+ 1?
		pick2 =? ( drop nip lwords - 1 >> 'vwords ! ; ) 
		drop ) 2drop 
	0 'vwords ! ;
	
:fxcode
	codeerr? 1? ( drop ; ) drop
	cpydefword
	'helpword c@ 0? ( drop "DEFINITION NOT FOUND" 'helpword strcpy ; ) drop
	makelistwords
	searchword dup 'nowword ! setvwords
	setanalysis
	0 'modefx !
	'fxwin onTui
	0 'uikey !
	tuR!
	;
	
|-------------------------------	
:runcode
	codeerr? 1? ( drop ; ) drop
	.masb .reset .cls .flush
	'filename r3run
	.reterm .alsb .flush
	tuR!
	;

:debugcode
	codeerr? 1? ( drop ; ) drop
	"r3/d4/r3debug.r3" r3run
	.reterm .alsb .flush 
	tuR! ;

|--- F2 help: the help lines of the word under the cursor (helptxt.r3, meta/mhelp.txt)
#infohelp * 128
#hwlist * 256		| the lines of the word (the same name can be in more than one library)
#hwtmp * 256
#hwcnt 0 #hwav 0		| how many lines, how many of included libraries (they go first)
#hwsel 0 #hwoff 0	| the selected line, the first one shown
#hweff * 128
#incbuf * 128

:incl? | 'path -- 0/1 ; the code includes the file (the table of includes of the last compile)
	'inc ( inc> <? @+ pick2 =s 1? ( 3drop 1 ; ) drop 8 + ) 2drop 0 ;

:avail? | n -- 0/1 ; the word can be used: a base word, or of an included library
	hbase <? ( drop 1 ; ) hw.where incl? ;

:hwword | -- "word" ; the word under the cursor, without the ' of an address
	'helpword c@ $ff and $27 =? ( drop 'helpword 1+ ; ) drop 'helpword ;

:hwadd | n -- n
	hwcnt 32 >=? ( drop ; ) drop
	dup hwcnt 3 << 'hwlist + ! 1 'hwcnt +! ;

:hwcopy | f k i -- f k' i ; the line i to the temp list k if its availability is f
	dup 3 << 'hwlist + @ dup avail? pick4 <>? ( 2drop ; ) drop
	pick2 3 << 'hwtmp + ! swap 1+ swap ;

:hwpass | f k -- f k' ; k = lines already in the temp list
	0 ( hwcnt <? hwcopy 1+ ) drop ;

:hwsort | -- ; the lines of included libraries first
	1 0 hwpass dup 'hwav !
	nip 0 swap hwpass 2drop
	'hwlist 'hwtmp hwcnt 3 << cmove ;

:hwfind | -- ; the lines of the word
	0 'hwcnt !
	hwword hw.find
	( +? hwadd hwword swap hw.next ) drop
	hwsort ;

:hwcol | n -- ; included: normal, not included: muted
	avail? 0? ( drop fMu ; ) drop fTx ;

:hwfmt | n -- "format"
	avail? 0? ( drop "%w  %s   < %s  (not included)" ; ) drop "%w  %s   < %s" ;

:hwdesc | n -- n ; the description of the line, if it has one
	dup hline hw.desc dup c@ $ff and 0? ( 2drop ; ) drop
	fMu "  %s" sprint .lw ;

:hwgap | i -- i ; the blank row (it is part of the selected entry)
	dup hwsel =? ( drop "" .lw ; ) drop fcr ;

:helpone | i -- i ; name  effect  < library, and the description
	dup hwsel =? ( bg3 ) drop
	dup 3 << 'hwlist + @
	dup hwcol dup hline 'hweff 100 hw.eff
	dup hw.where 'hweff pick2 hline pick3 hwfmt sprint .lw
	hwdesc drop hwgap bg1 ;

:helplist | -- ; the lines of the word, 3 rows each
	hw.count 0? ( drop fMu "mhelp.txt is not ready (run metabuild.r3 and metahelp.r3)" .lw ; ) drop
	hwcnt 0? ( drop fMu 'helpword "no help for: %s" sprint .lw ; ) drop
	fh 3 / 1 max				| rows
	hwsel hwoff <? ( hwsel 'hwoff ! ) drop
	hwsel hwoff pick2 + >=? ( hwsel pick2 - 1+ 'hwoff ! ) drop
	hwoff over + hwcnt min hwoff		| rows end first
	( over <? helpone 1+ ) 3drop ;

|--- the include of a library: after the last ^ of the header, or before the first line of code
:skipb | adr -- adr' ; blanks and new lines
	( dup c@ $ff and 1? 33 <? drop 1+ ) drop ;

:incstep | il adr -- il' adr' 1/0 ; a line of the header (comment or include): 1 = go on, 0 = the code starts
	skipb dup c@ $ff and
	0? ( drop 0 ; )
	$7c =? ( drop >>cr 1+ $fuente min 1 ; )
	$5e =? ( drop >>cr 1+ $fuente min nip dup 1 ; )
	drop 0 ;

:incaddr | -- adr ; il = the address after the last ^ of the header
	0 fuente ( incstep 1? drop ) drop
	swap 1? ( nip ; ) drop
	tuelstart fuente max ;

:incline | 'path -- 'str ; "^path" and a CR
	"^%s" sprint 'incbuf strcpy
	'incbuf dup count nip + 13 swap c!+ 0 swap c!
	'incbuf ;

:hwaccept | -- ; ENTER: a word of a library that is not included adds the include
	hwcnt 0? ( drop ; ) drop
	hwsel 3 << 'hwlist + @ dup avail? 1? ( 2drop ; ) drop
	hw.where
	dup incline incaddr tueinsat
	"added ^%s  (ctrl+Z undoes it)" sprint 'msg strcpy ;

:hwenter | -- ; what ENTER does with the selected line
	hwcnt 0? ( drop ; ) drop
	hwsel 3 << 'hwlist + @ dup avail? 1? ( 2drop fPr " ENTER" .write fTx " Close" .write ; ) drop
	hw.where fPr " ENTER" .write fYe " add ^" .write .write ;

:helpc
	.reset
	'bgBl " F2 HELP " topbar
	.eline
	
	1 flxS 
	bg3 fhome
	fPr " ESC" .write fTx " Exit" .write 
	fPr " UP/DN" .write fTx " Select" .write 
	hwenter
	fTx " | " .write 'helpword .write " | " .write
	'infohelp .write
	'msg .write
	.eline
	rows 2 >> flxN | 1/4 of screen
	tuReadCode
	flxRest
	.reset bg1 fBl
	tuwina $1 " Help " .wtitle fTx 1 1 flpad .wfill 
	fhome helplist
	
	uiKey
	[esc] =? ( tuiexit ) 
	[up] =? ( hwsel 1- 0 max 'hwsel ! )
	[dn] =? ( hwsel 1+ hwcnt 1- 0 max min 'hwsel ! )
	[enter] =? ( hwaccept tuiexit )
	drop ;

:helpcode
	cpyhelpword
	fuente 'filename r3loadmem
	hwfind 0 'hwsel ! 0 'hwoff !
	hwcnt "found: %d" sprint 'infohelp strcpy
	'helpc onTui ;
	
:helpdlg
	"r3IDE Help" 58 18 tuDlg
	fcr
	"F2 Word help (ENTER adds its include)   F3 Rx" .cw
	"F4/ctrl+R Run   F5/ctrl+D Debug" .cw
	fcr
	"ctrl+F Find   ctrl+N Next   ctrl+P Prev" .cw
	"ctrl+W Find the word under the cursor" .cw
	"ctrl+G Go to definition   ctrl+T Back" .cw
	"(the places are in a stack: back:n in the bar)" .cw
	fcr
	"ctrl+X Cut   ctrl+C Copy   ctrl+V Paste" .cw
	"ctrl+Z Undo   ctrl+Y Redo" .cw
	fcr
	"F6 Check that all the ; of a word leave the same stack" .cw
	"ctrl+H Help   ctrl+Q or ESC Quit" .cw
	tuDlgEnd
	uikey
	[esc] =? ( tuiexit )
	drop ;
	
|-------------------------------
:stackind | x y w -- ; the state of the return stack (ctrl+T), at the right end of the bottom bar x y w
	64 <? ( 3drop ; )
	rot + 9 - swap .at
	bg3 fDi tuejdepth 1? ( fPr ) drop
	"back:" .write
	tuejdepth "%d" sprint .write ;

:retind | -- ; state of the check of ; (F6)
	retstrict 1? ( drop bgGr fBk " ;chk " .write bg3 fTx ; ) drop
	fDi " ;chk" .write fTx ;

:main
	.reset
	'bgGr " EDIT " topbar
	" | " .write 'msg .write
	.eline
	
	1 flxS 
	bg3 fhome
	fx fy fw					| the bar, for stackind
	fPr " ^R" .write fTx "un" .write 
	fPr " ^D" .write fTx "ebug" .write 
	fPr " ^F" .write fTx "ind" .write 
	fPr " ^W" .write fTx "ord" .write 
	fPr " ^G" .write fTx "oto" .write 
	fPr " ^T" .write fTx "back" .write 
	fPr " ^H" .write fTx "elp" .write 
	fPr " F6" .write retind
	.eline
	flxRest
	tuEditCode
	stackind
	
	uiKey
	[f2] =? ( helpcode )
	[f3] =? ( fxcode )
	[f4] =? ( runcode )
	[f5] =? ( debugcode )
	[f6] =? ( togglechk )
	
	| ctrl
	$4 =? ( debugcode ) 		| ctrl+d debug
	$8 =? ( 'helpdlg onTui )	| ctrl+H Help	
	$11 =? ( tuiexit )				| ctrl+q quit
	$12 =? ( runcode )	| ctrl+r run	
	[esc] =? ( tuiexit ) 
	drop ;

|-----------------------------------
: 
	.alsb
	'filename "mem/menu.mem" load drop
	hw.load drop
	
	'filename TuLoadCode
	mark
	5 tuEditLN!
	'main onTui 
	TuSaveCode 
;
