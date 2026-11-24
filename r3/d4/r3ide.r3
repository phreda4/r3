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
#helpword * 64

:cpyhword | adr -- 
	'helpword 
	63 ( 1? 1- -rot		| copy word
		swap c@+ $ff and 
		32 <=? ( 2drop 0 swap c! drop ; )
		rot c!+ rot
		) drop
	0 swap c! 
	drop ;

:cprev | adr -- adr c ; the char before adr (0 at the start of the source)
	fuente >? ( dup 1- c@ $ff and ; ) 0 ;

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
	14 =? ( drop 114 .fc ; )
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

|--- F2 help: what the cursor is on (helptxt.r3, meta/mhelp.txt) and the words of the code
| The list has entries of 3 kinds (bits 60-61 of the value):
|  0 a help line of a base word or of a library   (value = number of the line)
|  1 a word of the code, or of an included file   (value = number in the dictionary)
|  2 a row of text: numbers, strings, comments... (value = place in hwpool)
| bit 59 = the definition that the code uses, 58 = the declared effect (the comment of the definition
| line) is not the one computed by the analyzer, 57 = the definition has no declared effect.
| You can type to search: the words that start with the text, then the ones that have it inside.

#infohelp * 128
#hwlist * 4096		| the entries (512 at most)
#hwtmp * 4096
#hwcnt 0
#hwsel 0 #hwoff 0	| the selected entry, the first one shown
#hwq * 32		| the text typed to search
#hwpool * 1024		| the text rows
#hwpool> 0
#hweff * 128
#hwdef * 256		| the line of a definition of the code: name | effect ; description
#hwdec * 128		| the effect declared in that line
#hwtl * 128		| one row of a text (2 blanks in)
#hwnm * 64
#hwpa * 256		| the path of a file (a word of the table of includes)
#hwun 0 #hwup 0		| the definition used: number and file
#incbuf * 128
#prevfile * 256		| the file before opening the source of a library (ctrl+B comes back)
#prevpos 0

:incl? | 'path -- 0/1 ; the code includes the file (the table of includes of the last compile)
	'inc ( inc> <? @+ pick2 =s 1? ( 3drop 1 ; ) drop 8 + ) 2drop 0 ;

:avail? | n -- 0/1 ; the word can be used: a base word, or of an included library
	hbase <? ( drop 1 ; ) hw.where incl? ;

:hpfx? | c -- 0/1 ; the ' : # that go before a word
	$27 =? ( drop 1 ; ) $3a =? ( drop 1 ; ) $23 =? ( drop 1 ; ) drop 0 ;

:hwword | -- "word" ; the word under the cursor, without the ' : # of an address or a definition
	'helpword ( dup c@ $ff and hpfx? 1? drop 1+ ) drop ;

|---- entries
:ek | e -- kind
	60 >> $3 and ;
:ev | e -- value
	$ffffffff and ;

:eavail | e -- 0/1
	dup ek 0? ( drop ev avail? ; ) 2drop 1 ;

:egrp | e -- 0/1/2 ; the code first, then the available, then the rest
	dup ek 1 =? ( 2drop 0 ; ) drop
	eavail 1? ( drop 1 ; ) drop 2 ;

:hwreset | --
	0 'hwcnt ! 0 'hwpool> ! ;

:hwadd | e --
	hwcnt 511 >? ( 2drop ; )
	3 << 'hwlist + ! 1 'hwcnt +! ;

:hwtext | "text" -- ; a row of text
	hwpool> 900 >? ( 2drop ; )
	swap 'hwpool pick2 + strcpyl
	'hwpool - 'hwpool> !
	2 60 << or hwadd ;

:hwcopy | f k i -- f k' i ; the entry i to the temp list k if its group is f
	dup 3 << 'hwlist + @ dup egrp pick4 <>? ( 2drop ; ) drop
	pick2 3 << 'hwtmp + ! swap 1+ swap ;

:hwpass | f k -- f k' ; k = entries already in the temp list
	0 ( hwcnt <? hwcopy 1+ ) drop ;

:hwsort | --
	0 0 hwpass nip 1 swap hwpass nip 2 swap hwpass 2drop
	'hwlist 'hwtmp hwcnt 3 << cmove ;

|---- the dictionary of the last compile
:dicadr | nro -- adr ; where the name is
	nro>dic @ dic>name ;

:inmain? | adr -- 0/1 ; in the text of the editor
	fuente <? ( drop 0 ; ) $fuente >=? ( drop 0 ; ) drop 1 ;

:linenr | adr -- n ; line of an address of the editor
	1 fuente ( pick2 <? c@+ 13 =? ( rot 1+ -rot ) drop ) drop nip ;

:dicfind | 'name -- nro/-1 ; the last definition of the name: the one that the code uses
	cntdef ( 1? 1-
		dup dicadr pick2 =w 1? ( drop nip ; ) drop )
	2drop -1 ;

:dicfile | nro -- 'path ; the file where the word is defined
	ab[ 0 >a
	'inc ( dup inc> <? drop
		dup 8 + @ 32 >>> pick2 <=? drop
		dup @ >a 16 + )
	3drop a>
	]ba ;

:inmainw? | nro -- 0/1 ; the word is in the main file (the analyzer only computes the effect of those)
	dic< dic - 4 >> <? ( drop 0 ; ) drop 1 ;

:hwcomp | nro -- str ; the effect computed by the analyzer
	dup nro>dic @ 1 and? ( 2drop "variable" ; ) drop
	dup inmainw? 0? ( 2drop "" ; ) drop
	nro>dic 8 + @ dup $ff and 8 << swap 8 >> $ff and or hw.effab ;

:hwdefline | adr -- ; the line of adr (up to the CR) to hwdef
	ab[ >b 'hwdef >a
	255 ( dup 1? drop 1- cb@+ $ff and 9 =? ( drop 32 ) 14 >? ca!+ )
	2drop 0 ca!
	]ba ;

:efnr | adr -- n ; the names after the --
	0 swap ( efnext 1? drop swap 1+ swap ) 2drop ;

:hwcheck | nro -- flags ; compares the declared effect with the computed one
	dup dicadr hwdefline
	'hwdef 'hwdec 120 hw.eff
	dup inmainw? 0? ( 2drop 0 ; ) drop
	nro>dic dup @ 1 and? ( 2drop 0 ; ) drop
	'hwdec c@ $ff and 0? ( 2drop $200000000000000 ; ) drop
	8 + @ dup $ff and swap 8 >> 56 << 56 >>		| use delta
	over +						| use out
	'hwdec efleft efnr rxlnn				| use out nr nl
	pick3 <>? ( 4drop $400000000000000 ; ) drop
	over <>? ( 3drop $400000000000000 ; ) 3drop 0 ;

:hwefft | nro -- str ; the effect to show: the computed one, or the declared one if the analyzer did not see the word
	dup nro>dic @ 1 and? ( drop hwcomp ; ) drop
	dup inmainw? 1? ( drop hwcomp ; ) drop
	dup dicadr hwdefline 'hwdef 'hwdec 120 hw.eff
	drop 'hwdec ;

:hwcompl | nro -- str ; the row "computed:" of the details
	dup inmainw? 0? ( 2drop "  computed: (not analyzed: the word is in an included file)" ; ) drop
	hwcomp "  computed: %s" sprint ;

:hwuser | nro -- ; a word of the code
	dup hwcheck or $1000000000000000 or hwadd ;

:ewhere | e -- 'path/0
	dup ek 0? ( drop ev hw.where ; ) 2drop 0 ;

:hwshown? | nro -- 0/1 ; the file of the definition has a help line in the list
	dicfile 0 ( hwcnt <?
		dup 3 << 'hwlist + @ ewhere 1? ( pick2 =s 1? ( 3drop 1 ; ) ) drop
		1+ ) 2drop 0 ;

:hwlines | -- ; the help lines of the word
	hwword hw.find
	( +? dup hwadd hwword swap hw.next ) drop ;

:hwdefs | -- ; the definitions in the code that are not a help line already
	cntdef ( 1? 1-
		dup dicadr hwword =w 1? ( drop dup hwshown? 0? ( over hwuser ) ) drop )
	drop ;

:eit? | e -- 0/1 ; is e the definition that the code uses
	dup ek
	1 =? ( drop ev hwun - 0? ( drop 1 ; ) drop 0 ; )
	0? ( drop ev hw.where hwup =s ; )
	2drop 0 ;

:hwavn | -- n ; entries that can be used
	0 0 ( hwcnt <?
		dup 3 << 'hwlist + @ egrp 2 <? ( rot 1+ -rot ) drop
		1+ ) drop ;

:hwmark | -- ; if there is more than one, marks the one that the code uses
	hwavn 2 <? ( drop ; ) drop
	hwword dicfind -? ( drop ; )
	dup 'hwun ! dicfile 'hwup !
	0 ( hwcnt <?
		dup 3 << 'hwlist + dup @ dup eit? 59 << or swap !
		1+ ) drop ;

|---- search: the names that start with hwq, or have it inside
:lc | c -- c' ; lower case
	$41 $5a in? ( $20 + ) ;

:pre? | name q -- 0/1 ; the name starts with q
	( dup c@ $ff and 1?				| name q c
		lc pick2 c@ $ff and lc <>? ( 3drop 0 ; ) drop
		swap 1+ swap 1+ )
	3drop 1 ;

:has? | name q -- 0/1 ; q is in the name
	( over c@ $ff and 32 >? drop
		2dup pre? 1? ( 3drop 1 ; ) drop
		swap 1+ swap )
	3drop 0 ;

:hwm? | 'name mode -- 0/1 ; mode 0: starts with hwq, 1: has it inside (not at the start)
	0? ( drop 'hwq pre? ; ) drop
	dup 'hwq pre? 1? ( 2drop 0 ; ) drop
	'hwq has? ;

:hwscan | mode -- ; help lines
	0 ( hw.count <?
		dup hline pick2 hwm? 1? ( over hwadd ) drop
		1+ ) 2drop ;

:hwscanu | mode -- ; words of the code
	dic< ( dic> <?
		dup @ dic>name pick2 hwm? 1? ( over dic - 4 >> hwuser ) drop
		16 + ) 2drop ;

:hwsearch | --
	0 hwscanu 0 hwscan 1 hwscanu 1 hwscan ;

|---- what is under the cursor
:isnum? | 'str -- 0/1
	?numero nip nip ;

:hwnum | -- ; the number, in other bases
	'helpword str>nro nip
	dup "decimal  %d" sprint hwtext
	dup "hex      $%h" sprint hwtext
	dup "binary   %%%b" sprint hwtext
	dup "fixed    %f  (48.16)" sprint hwtext
	32 126 in? ( dup "char     '%k'" sprint hwtext )
	drop ;

:hwlib | -- ; the words of the library of a ^ line
	0 ( hw.count <?
		dup hw.where 'helpword 1+ =s 1? ( over hwadd ) drop
		1+ ) drop
	hwcnt 0? ( drop "this file has no help data (only the libraries of r3 have)" hwtext ; ) drop ;

:hwfind | -- ; the word under the cursor: help lines and definitions of the code
	hwlines hwdefs hwmark
	hwcnt 0? ( hwword 'hwq 30 hw.cpy hwreset hwsearch ) drop ;

:hwstart | --
	hwreset
	'helpword c@ $ff and
	0? ( drop "nothing under the cursor: type to search" hwtext ; )
	$7c =? ( drop "a comment: the compiler ignores the rest of the line" hwtext ; )
	$5e =? ( drop hwlib ; )
	$22 =? ( drop "a string: the format codes in it (percent d, s, h, w) take values from the stack" hwtext ; )
	$27 =? ( "'word: the address of the word or of the variable" hwtext )
	drop
	'helpword isnum? 1? ( drop hwnum ; ) drop
	hwfind ;

:hwinfo | --
	hwcnt 512 >=? ( drop 'hwq "search: %s  (512+ found, type more to narrow)" sprint 'infohelp strcpy ; ) drop
	'hwq c@ $ff and 1? ( drop hwcnt 'hwq "search: %s  (%d found)" sprint 'infohelp strcpy ; ) drop
	hwcnt "found: %d" sprint 'infohelp strcpy ;

:hwrefresh | -- ; the list again (for the text typed, or for the word)
	0 'hwsel ! 0 'hwoff !
	hwreset
	'hwq c@ $ff and 1? ( drop hwsearch hwsort hwinfo ; ) drop
	hwstart hwsort hwinfo ;

:hwqadd | c --
	'hwq count nip 29 >? ( 2drop ; )
	'hwq + c!+ 0 swap c! hwrefresh ;

:hwqdel | --
	'hwq count nip 0? ( drop ; ) 1- 'hwq + 0 swap c! hwrefresh ;

|---- the rows
:,fld | str w mark -- ; a field: the mark, the text cut or padded to w
	,c ,scnt ;

:hwrowt | str mark -- ; a row of text
	mark here swap ,c swap ,s ,eol fw swap xwline empty fcr ;

:eavc | n -- mark
	avail? 1? ( drop 7 ; ) drop 2 ;

:ecol | e -- mark ; color of the effect of a word of the code
	$400000000000000 and? ( drop 8 ; )
	$200000000000000 and? ( drop 4 ; )
	drop 6 ;

:hweffn | n -- str mark ; the effect of the line, or the computed one if the help has none
	dup hline 'hweff 100 hw.eff
	'hweff c@ $ff and 1? ( 2drop 'hweff 6 ; ) drop
	dup avail? 0? ( 2drop "" 2 ; ) drop
	dup hline "%w" sprint dicfind -? ( 2drop "" 2 ; )
	nip hwcomp 4 ;

:hwlibtxt | n -- str mark
	dup hw.where swap avail? 1? ( drop "< %s" sprint 2 ; ) drop
	"< %s  (not included)" sprint 8 ;

:hwloc | nro -- str ; where it is defined
	dup dicadr inmain? 1? ( drop dicadr linenr "< this file, line %d" sprint ; ) drop
	dicfile "< %w" sprint ;

:hwl0 | e -- ; a help line
	mark here swap				| p e
	dup ev					| p e n
	dup hline "%w" sprint 18 pick2 eavc ,fld
	dup hweffn 26 swap ,fld
	dup hwlibtxt ,c ,s
	drop
	$800000000000000 and? ( 14 ,c "  (used)" ,s ) drop
	,eol fw swap xwline empty fcr ;

:hwl1 | e -- ; a word of the code
	mark here swap				| p e
	dup ev					| p e nro
	dup dicadr "%w" sprint 18 7 ,fld
	dup hwefft 26 pick3 ecol ,fld
	hwloc 2 ,c ,s				| p e
	dup $400000000000000 and? ( 8 ,c "  declared effect differs" ,s ) drop
	$800000000000000 and? ( 14 ,c "  (used)" ,s ) drop
	,eol fw swap xwline empty fcr ;

:hwl2 | e -- ; a text
	ev 'hwpool + 3 hwrowt ;

:hwline | e --
	dup ek
	0? ( drop hwl0 ; )
	1 =? ( drop hwl1 ; )
	drop hwl2 ;

|---- the details of the selected entry: the description in rows
:wrapcut | str w -- len ; the first row of the text: w chars at most, cut at a space
	over count nip over <=? ( nip nip ; ) drop
	dup >r
	( dup 1 >? drop over over + c@ $ff and 32 <>? drop 1- ) drop
	over over + c@ $ff and 32 =? ( drop nip r> drop ; ) drop
	2drop r> ;

:wrapdraw | str w max -- n ; the text in rows, w chars wide at most; n rows drawn
	ab[ rot >b swap 3 - 20 max 120 min swap
	32 'hwtl c! 32 'hwtl 1+ c!
	0
	( dup pick2 <? drop cb@ $ff and 1? drop
		b> pick3 wrapcut			| w max n len
		b> 'hwtl 2 + pick2 hw.cpy
		'hwtl 2 hwrowt
		b> over + ( dup c@ $ff and 32 =? drop 1+ ) drop >b
		drop 1+ )
	drop nip nip
	]ba ;

:hwdecs | -- str
	'hwdec c@ $ff and 1? ( drop 'hwdec "  declared: %s" sprint ; ) drop
	"  declared: (none)" ;

:hwmk | flags -- mark
	$400000000000000 and? ( drop 8 ; ) drop 2 ;

:hwdetail1 | e -- n
	ev dup hwcheck				| nro flags
	hwdecs swap hwmk hwrowt			| nro
	dup hwcompl 2 hwrowt
	drop 'hwdef hw.desc fw 3 wrapdraw 2 + ;

:hwdetail | e -- n
	dup ek
	0? ( drop ev hline hw.desc fw 4 wrapdraw ; )
	1 =? ( drop hwdetail1 ; )
	2drop 0 ;

:hwdn | -- n ; rows that the details can take
	hwsel 3 << 'hwlist + @ ek
	0? ( drop 4 ; ) 1 =? ( drop 5 ; ) drop 0 ;

:hwfit | -- ; the selected entry with its details is in the window
	hwsel hwoff <? ( hwsel 'hwoff ! ) drop
	( hwoff hwsel <? drop hwsel hwoff - 1+ hwdn + fh >? drop 1 'hwoff +! ) drop ;

:hwrow | i -- i n ; draws the entry i and, if it is the selected one, its details
	dup hwsel =? ( bg3 ) drop
	dup 3 << 'hwlist + @ dup hwline		| i e
	over hwsel =? ( drop hwdetail 1+ bg1 ; ) drop drop bg1 1 ;

:helplist | -- ; the entries, a row each (the selected one with its details)
	hw.count 0? ( drop fMu "mhelp.txt is not ready (run metabuild.r3 and metahelp.r3)" .lw ; ) drop
	hwcnt 0? ( drop fMu "nothing found: type to search" .lw ; ) drop
	hwfit
	fh hwoff
	( over 1 >=? drop dup hwcnt <? drop
		hwrow rot swap - swap 1+ )
	3drop ;

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

|---- the source of a library: ctrl+O opens it, ctrl+B comes back
:dch? | c -- 0/1 ; the : # of a definition
	$3a =? ( drop 1 ; ) $23 =? ( drop 1 ; ) drop 0 ;

:skipdef | adr -- adr'
	( dup c@ $ff and dch? 1? drop 1+ ) drop ;

:finddef | 'name -- adr/0 ; the definition of the name in the text of the editor
	fuente ( $fuente <?
		dup skipdef over <>? ( dup pick3 =w 1? ( drop nip nip ; ) drop ) drop
		>>cr 1+ )
	2drop 0 ;

:hwopen | 'path 'name -- ; the file in the editor, at the definition of the name
	'hwnm 60 hw.cpy
	TuSaveCode
	'prevfile c@ $ff and 0? ( 'filename 'prevfile strcpy fuente> fuente - 'prevpos ! ) drop
	dup 'filename strcpy TuLoadCode
	'hwnm finddef 1? ( dup tuiecursor! ) drop
	"source opened: ctrl+B goes back to the file" 'msg strcpy ;

:fileback | -- ; ctrl+B
	'prevfile c@ $ff and 0? ( drop "there is no file to go back to" 'msg strcpy ; ) drop
	TuSaveCode
	'prevfile dup 'filename strcpy TuLoadCode
	0 'prevfile c!
	fuente prevpos + $fuente min tuiecursor!
	"back" 'msg strcpy ;

:hwgodef | nro -- ; to the definition: in this file the place is saved (ctrl+T), in other the file is opened
	dup dicadr inmain? 1? ( drop dicadr tuejpush tuiecursor! ; ) drop
	dup dicfile "%w" sprint 'hwpa strcpy
	dicadr "%w" sprint 'hwpa swap hwopen ;

:hwaccept | -- ; ENTER: a word of the code goes to its definition, one of a library that is not included adds the include
	hwcnt 0? ( drop ; ) drop
	hwsel 3 << 'hwlist + @ dup ek
	1 =? ( drop ev hwgodef ; )
	0? ( drop ev dup avail? 1? ( 2drop ; ) drop
		hw.where dup incline incaddr tueinsat
		"added ^%s  (ctrl+Z undoes it)" sprint 'msg strcpy ; )
	2drop ;

:hwsource | -- ; ctrl+O: the source of the selected word
	hwcnt 0? ( drop ; ) drop
	hwsel 3 << 'hwlist + @ dup ek
	1 =? ( drop ev hwgodef ; )
	0? ( drop ev
		hbase <? ( drop "the base words are in the compiler: they have no source file" 'msg strcpy ; )
		dup hw.where swap hline "%w" sprint hwopen ; )
	2drop ;

:hwenter0 | n -- ; the keys for a help line
	dup avail? 1? ( 2drop fPr " ENTER" .write fTx " Close" .write fPr " ^O" .write fTx " Source" .write ; ) drop
	hw.where fPr " ENTER" .write fYe " add ^" .write .write fPr " ^O" .write fTx " Source" .write ;

:hwenter | -- ; the keys for the selected entry
	hwcnt 0? ( drop ; ) drop
	hwsel 3 << 'hwlist + @ dup ek
	0? ( drop ev hwenter0 ; )
	1 =? ( 2drop fPr " ENTER" .write fTx " Go" .write fPr " ^O" .write fTx " Source" .write ; )
	2drop ;

:helpc
	.reset
	'bgBl " F2 HELP " topbar
	.eline
	
	1 flxS 
	bg3 fhome
	fPr " ESC" .write fTx " Exit" .write 
	fPr " UP/DN" .write fTx " Select" .write 
	hwenter
	fTx " | " .write fPr "find:" .write fYe 'hwq .write fTx "_ | " .write
	'infohelp .write
	'msg .write
	.eline
	rows 10 - flxN
	tuReadCode
	flxRest
	.reset bg1 fBl
	tuwina $1 " Help " .wtitle fTx 1 1 flpad .wfill 
	fhome helplist
	
	uiKey
	[esc] =? ( tuiexit ) 
	[up] =? ( hwsel 1- 0 max 'hwsel ! )
	[dn] =? ( hwsel 1+ hwcnt 1- 0 max min 'hwsel ! )
	[pgup] =? ( hwsel 8 - 0 max 'hwsel ! )
	[pgdn] =? ( hwsel 8 + hwcnt 1- 0 max min 'hwsel ! )
	[home] =? ( 0 'hwsel ! )
	[end] =? ( hwcnt 1- 0 max 'hwsel ! )
	[enter] =? ( hwaccept tuiexit )
	$f =? ( hwsource tuiexit )
	[back] =? ( hwqdel )
	33 126 in? ( dup hwqadd )
	drop ;

:helpcode
	cpyhelpword
	fuente 'filename r3loadmem
	0 'hwq !
	hwrefresh
	'helpc onTui ;
	
:hint | -- ; the effect of the word under the cursor, in the top bar
	cpyhelpword
	hw.count 0? ( drop ; ) drop
	hwword hw.find -? ( drop ; )
	hline 'hweff 100 hw.eff
	'hweff c@ $ff and 0? ( drop ; ) drop
	fTx " | " .write fYe hwword .write fMu "  " .write 'hweff .write fTx ;

:hint | -- ; the effect of the word under the cursor, in the top bar
	cpyhelpword
	hw.count 0? ( drop ; ) drop
	hwword hw.find -? ( drop ; )
	hline 'hweff 100 hw.eff
	'hweff c@ $ff and 0? ( drop ; ) drop
	fTx " | " .write fYe hwword .write fMu "  " .write 'hweff .write fTx ;

:helpdlg
	"r3IDE Help" 62 22 tuDlg
	fcr
	"F2 Help of the word under the cursor (type to search)" .cw
	"ENTER adds the include or goes to the definition" .cw
	"ctrl+O opens the source of a library   F3 Rx" .cw
	"F4/ctrl+R Run   F5/ctrl+D Debug" .cw
	fcr
	"ctrl+F Find   ctrl+N Next   ctrl+P Prev" .cw
	"ctrl+W Find the word under the cursor" .cw
	"ctrl+G Go to definition   ctrl+T Back" .cw
	"ctrl+B Back to the file before ctrl+O" .cw
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
	hint
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
	'prevfile c@ $ff and 1? ( fPr " ^B" .write fTx "file" .write ) drop
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
	$2 =? ( fileback )		| ctrl+b back to the file
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
	32
	'main onTui 
	TuSaveCode 
;
