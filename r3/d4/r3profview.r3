| r3profview - profile analyzer (TUI)
| reads mem/profile.def (made by r3genprof) and mem/profile.mem (written by the measured program)
| views (Tab): table of words, call tree (one node per call path, exact times)
| PHREDA 2026

^r3/util/tui.r3
^r3/lib/parse.r3

|---------------------------------------------------------------- data
| row (64 bytes), one per word of the main code:
|  0 name | 8 flags | 16 calls | 24 ms | 32 start in edges | 40 count | 48 sort key | 56 self ms
| flags: 1 boot  2 data  4 function (measured)  8 not measured  16 R direct recursion
|        64 init (previous boot)  128 I indirect recursion seen while running
| edges: dwords, rows that each word calls (static, no repeats)
| node (64 bytes), one per call path, ids from 1:
|  0 parent | 8 row | 16 calls | 24 ms | 32 first child | 40 next sibling | 48 self ms
|  56 bit 0 expanded, depth<<8

#cnt 0 #nmainv 0 #title 0
#dat 0 #edges 0 #ord 0
#nedges 0 #estart 0 #tsz 0
#here0 0 #total 1 #msg 0 #havemem 0
#nodes 0 #nn 0 #tl 0 #ntl 0

:rec | i -- adr
	6 << dat + ;
:rname | i -- str
	rec @ ;
:rflags | i -- flags
	rec 8 + @ ;
:rcalls | i -- n
	rec 16 + @ ;
:rms | i -- ms
	rec 24 + @ ;

:nrec | id -- adr
	6 << nodes + ;

|---------------------------------------------------------------- load profile.def
:>>fld | adr -- adr' ; up to '|' or CR (or the final 0)
	( c@+ $ff and 1?
		$7c =? ( drop 1- ; )
		13 =? ( drop 1- ; )
		drop ) drop 1- ;

:fld | adr -- adr' str ; ends the field with a 0
	dup >>fld 0 over c! 1+ swap ;

:flagsof | str -- n
	c@ $ff and
	$42 =? ( drop 1 ; )		| B boot
	$44 =? ( drop 2 ; )		| D data
	$46 =? ( drop 4 ; )		| F function
	$49 =? ( drop 64 ; )	| I previous boot
	drop 8 ;				| X

:e? | n -- 0/1 ; already in the calls of the current row (keeps A and B)
	ab[ estart 2 << edges + >a nedges estart -
	( 1? 1- da@+ pick2 =? ( 3drop 1 ]ba ; ) drop ) 2drop 0 ]ba ;

:edgeadd | n --
	dup e? 1? ( 2drop ; ) drop
	nedges 2 << edges + d! 1 'nedges +! ;

#rcur 0
:rowparse | adr -- adr'
	rcur rec >a
	fld a!+					| name
	fld flagsof a!+			| flags
	0 a!+ 0 a!+				| calls ms
	nedges dup 'estart ! a!+
	fld						| adr' str
	( trim dup c@ 1? drop getnro edgeadd ) 2drop
	nedges estart - a!+		| count
	0 a!+ 0 a!+ ;			| sort key, self

:parsedef | adr --
	fld drop						| "r3prof"
	fld str>nro nip 'nmainv !
	fld str>nro nip 'cnt !
	fld 'title !
	here dup 'dat ! cnt 6 << +
	dup 'edges ! tsz 1 << +
	dup 'ord ! cnt 3 << + 8 + align8 'here !
	0 'nedges !
	0 ( cnt <? dup 'rcur ! swap rowparse swap 1+ ) 2drop ;

:loaddef | -- 0/1
	here dup "mem/profile.def" load		| ini fin
	over =? ( 2drop 0 ; )
	0 over c!
	over - 'tsz !
	dup tsz + 1+ align8 'here !
	parsedef 1 ;

|---------------------------------------------------------------- load profile.mem
| cnt | cnt rows [ aux | calls<<32 + ms ] | nnodes | nnodes [ parent<<32 + row | calls<<32 + ms ] | overflow
:addflag | n f --
	swap rec 8 + dup @ pick2 or swap ! drop ;

#np 0 #pp 0 #dp 0 #lid 0
#qa 0 #qb 0 #mi 0 #mfin 0 #mcnt 0

:nms | id -- ms
	nrec 24 + @ ;

:nbefore? | c -- 0/1 ; c goes before the node being linked
	nms lid nms >=? ( drop 1 ; ) drop 0 ;

:go? | slot -- slot 0/1
	dup @ 0? ( ; ) nbefore? ;

:nlink | id -- ; sons ordered by ms, the biggest first
	dup 'lid !
	nrec @ 0? ( drop ; )
	nrec 32 +
	( go? 1? drop @ nrec 40 + ) drop
	dup @ lid nrec 40 + !
	lid swap ! ;

:ndflags | -- f ; expanded down to depth 1
	dp 2 <? ( drop dp 8 << 1 or ; ) drop dp 8 << ;

:nfin1 | id --
	dup nrec 'np !
	np @ 0? ( 2drop 1 np 56 + ! ; )
	nrec 'pp !
	pp 56 + @ 8 >> 1+ 'dp !
	ndflags np 56 + !
	np 24 + @ neg pp 48 + +!
	nlink ;

:nfin2 | id -- ; self >= 0 and self of the word
	nrec 'np !
	np 48 + @ 0 max dup np 48 + !
	np 8 + @ rec 56 + +! ;

:loadnodes | adr -- ; adr = place of the node count
	dup 8 + mfin >? ( 2drop ; ) drop
	@+ over mfin swap - 4 >> min		| adr' n
	dup 'nn !
	0? ( 2drop ; ) drop
	mfin 8 + align8 dup 'nodes !
	nn 1+ 6 << + dup 'tl !
	nn 3 << + align8 'here !
	>b
	0 ( nn <?
		b@+ 'qa ! b@+ 'qb !
		dup 1+ nrec >a
		qa 32 >> a!+
		qa $ffffffff and a!+
		qb 32 >> a!+
		qb $ffffffff and dup a!+
		0 a!+ 0 a!+
		a!+ 0 a!+
		1+ ) drop
	1 ( nn <=? dup nfin1 1+ ) drop
	1 ( nn <=? dup nfin2 1+ ) drop ;

:loadmem | -- 0 missing / 1 ok / 2 different program
	here dup "mem/profile.mem" load		| ini fin
	over =? ( 2drop 0 ; )
	'mfin ! dup 'mi !
	@ 'mcnt !
	mcnt cnt <>? ( drop 2 ; ) drop
	mi 8 + >b
	0 ( cnt <?
		b@+ 32 >> 1 and? ( over 128 addflag ) drop
		b@+ over rec 16 + >a
		dup 32 >> a!+ $ffffffff and a!+
		1+ ) drop
	mi 8 + cnt 4 << + loadnodes
	1 ;

:calctotal | -- ; total = ms of the boot (last row); else the biggest
	cnt 1- rms 'total !
	total 1? ( drop ; ) drop
	0 ( cnt <? dup rms total max 'total ! 1+ ) drop
	total 0? ( 1 'total ! ) drop ;

|---------------------------------------------------------------- recursion
| in r3 there are no forward references: direct calls cannot make a cycle, only
| the self call (R). Indirect recursion ('word ex) is detected while running (I).
:edgeini | r -- n ; A points to its calls, n = count
	rec 32 + @+ 2 << edges + >a @ ;

#fcur 0
:flagrow | r -- ; R if it calls itself
	dup 'fcur ! edgeini
	( 1? 1- da@+ fcur =? ( fcur 16 addflag ) drop ) drop ;

|---------------------------------------------------------------- order of the table
#sortk 2		| 0 name 1 calls 2 total 3 us per call 4 self
#sortd 0		| 1 reverses
#showall 0
#psel 0 #ptop 0 #nvis 0 #selrow -1

:ord@ | i -- v
	3 << ord + @ ;
:ord! | v i --
	3 << ord + ! ;

#kp 0
:keyrow | i -- key
	rec 'kp !
	sortk
	1 =? ( drop kp 16 + @ ; )
	2 =? ( drop kp 24 + @ ; )
	3 =? ( drop kp 24 + @ 1000 * kp 16 + @ 1 max / ; )
	4 =? ( drop kp 56 + @ ; )
	drop 0 ;

:cmprows | a b -- n ; <0 if a goes before b
	sortk 0? ( drop
		rname swap rname swap cmpstr
		sortd 1? ( drop neg ; ) drop ; ) drop
	rec 48 + @ swap rec 48 + @ -
	sortd 1? ( drop neg ; ) drop ;

#sx 0
:ins | i -- ; inserts ord[i] in the sorted part
	dup ord@ 'sx !
	( 1?
		sx over 1- ord@ cmprows
		+? ( drop sx swap ord! ; )
		drop dup 1- ord@ over ord! 1- )
	sx swap ord! ;

:visible? | i -- 0/1
	dup rflags 2 and? ( 2drop 0 ; ) drop
	showall 1? ( 2drop 1 ; ) drop
	rcalls 1? ( drop 1 ; ) drop 0 ;

:addord | i --
	dup keyrow over rec 48 + !
	nvis ord! 1 'nvis +! ;

:mkord | --
	0 'nvis !
	0 ( cnt <? dup visible? 1? ( drop dup addord 0 ) drop 1+ ) drop
	1 ( nvis <? dup ins 1+ ) drop ;

:keepsel | --
	nvis 1? ( drop psel ord@ 'selrow ! ; ) drop -1 'selrow ! ;

:findsel | --
	0 'psel !
	0 ( nvis <? dup ord@ selrow =? ( over 'psel ! ) drop 1+ ) drop ;

:resort | --
	keepsel mkord findsel tuR! ;

:setsort | m --
	sortk =? ( drop sortd 1 xor 'sortd ! resort ; )
	'sortk ! 0 'sortd ! resort ;

|---------------------------------------------------------------- call tree
#tsel 0 #ttop 0 #tselid 1

:tl! | id level --
	32 << or ntl 3 << tl + ! 1 'ntl +! ;

:tl@ | k -- id level
	3 << tl + @ dup $ffffffff and swap 32 >> ;

#cid 0 #clv 0
:godown | -- 0/1 ; goes to the first son if the node is expanded
	cid nrec 56 + @ 1 and 0? ( ; ) drop
	cid nrec 32 + @ 0? ( ; )
	'cid ! 1 'clv +! 1 ;

:up | -- ; next brother of the node, or of the nearest ancestor that has one
	( cid 1? drop
		cid nrec 40 + @ 1? ( 'cid ! ; ) drop
		cid nrec @ 'cid ! -1 'clv +! ) drop ;

:buildtree | -- ; the lines of the tree, in order, without recursion
	0 'ntl !
	nn 0? ( drop ; ) drop
	1 'cid ! 0 'clv !
	( cid 1? drop
		cid clv tl!
		godown 0? ( up ) drop ) drop ;

:keept | -- ; remembers the selected node
	ntl 1? ( drop tsel tl@ drop 'tselid ! ; ) drop 1 'tselid ! ;

:findt | -- ; finds the selected node again
	0 'tsel !
	0 ( ntl <? dup tl@ drop tselid =? ( over 'tsel ! ) drop 1+ ) drop ;

:retree | --
	keept buildtree findt tuR! ;

:haskids? | id -- 0/1
	nrec 32 + @ 0? ( ; ) drop 1 ;

:flipx | id -- ; expanded <-> collapsed
	nrec 56 + dup @ 1 xor swap ! ;

:ttoggle | --
	ntl 0? ( drop ; ) drop
	tsel tl@ drop dup haskids? 0? ( 2drop ; ) drop
	flipx retree ;

:tright | --
	ntl 0? ( drop ; ) drop
	tsel tl@ drop dup haskids? 0? ( 2drop ; ) drop
	nrec 56 + dup @ 1 and? ( 2drop ; ) drop
	dup @ 1 or swap ! retree ;

:tleft | --
	ntl 0? ( drop ; ) drop
	tsel tl@ drop
	dup haskids? 1? ( drop dup nrec 56 + @ 1 and? ( drop flipx retree ; ) drop 0 ) drop
	nrec @ 0? ( drop ; )
	'tselid ! findt tuR! ;

:tall | f -- ; 1 expand all, 0 collapse all
	1 ( nn <=?
		dup nrec 56 + dup @ -2 and pick3 or swap !
		1+ ) 2drop
	1 nrec 56 + dup @ 1 or swap !
	retree ;

:tmov | d --
	ntl 0? ( 2drop ; ) drop
	tsel + ntl 1- clamp0max 'tsel ! tuR! ;

|---------------------------------------------------------------- load all
:loadall | --
	tuR! here0 'here !
	0 'nvis ! 0 'psel ! 0 'ptop ! 0 'cnt !
	0 'nn ! 0 'ntl ! 0 'tsel ! 0 'ttop ! 1 'tselid !
	loaddef 0? ( drop "mem/profile.def not found: make it with r3prof" 'msg ! ; ) drop
	cnt 0? ( drop "mem/profile.def has no words" 'msg ! ; ) drop
	loadmem
	2 =? ( drop "mem/profile.mem is from another version of the program" 'msg ! ; )
	dup 'havemem ! 0? ( 1 'showall ! ) drop
	calctotal
	0 ( cnt <? dup flagrow 1+ ) drop
	0 'msg !
	buildtree
	-1 'selrow ! resort ;

|---------------------------------------------------------------- screen
#view 0			| 0 words  1 call tree

:vh | -- n ; data rows of the panel
	fh 1- ;

:spc | n --
	1 >? ( .nsp ; ) 1 =? ( drop .sp ; ) drop ;

:flagstr | f -- str
	128 and? ( drop "I" ; )
	16 and? ( drop "R" ; )
	8 and? ( drop "-" ; )
	drop " " ;

:flagdesc | f -- str
	1 and? ( drop "whole program (boot)" ; )
	64 and? ( drop "previous boot (not measured)" ; )
	128 and? ( drop "indirect recursion: counted once, at the outermost call" ; )
	16 and? ( drop "direct recursion: calls = entries from outside, time is right" ; )
	8 and? ( drop "not measured (does not end with ;)" ; )
	drop "" ;

#rp 0
:uspc | -- str ; us per call
	rp 16 + @ 0? ( drop "-" ; )
	rp 24 + @ 1000 * 16 << swap / .f2 ;

:pctfix | -- fix ; percent of the total (48.16)
	rp 24 + @ 100 * 16 << total / ;

:pctcolms | ms --
	1000 * total /
	300 >=? ( drop fRd ; )
	100 >=? ( drop fYe ; ) drop fGr ;

:pctcol | --
	rp 24 + @ pctcolms ;

:blocks | n --
	1 <? ( drop ; ) "█" .rep ;

:bar | ms fixed -- ; bar in the space that is left
	fw swap - 1 <? ( 2drop ; )			| ms bw
	over pctcolms
	swap 0? ( drop spc ; )
	over * total / 1 max
	over min dup blocks - spc ;

:selfstr | -- str ; self of the row in rp
	nn 0? ( drop "-" ; ) drop
	rp 56 + @ .d ;

:showrow | k --
	dup psel =? ( bg3 ) drop
	ord@ rec 'rp !
	fTx 22 rp @ lwrite .sp
	fYe 1 rp 8 + @ flagstr lwrite .sp
	fTx 10 rp 16 + @ .d rwrite .sp
	8 rp 24 + @ .d rwrite .sp
	8 selfstr rwrite .sp
	9 uspc rwrite .sp
	pctcol 6 pctfix .f1 rwrite .sp
	rp 24 + @ 71 bar
	.reset fcr ;

:hcol | mode --
	sortk =? ( drop fPr ; ) drop fMu ;

:header | --
	.Bold
	0 hcol 22 "Word" lwrite .sp
	fMu 1 " " lwrite .sp
	1 hcol 10 "Calls" rwrite .sp
	2 hcol 8 "ms" rwrite .sp
	4 hcol 8 "Self" rwrite .sp
	3 hcol 9 "us/call" rwrite .sp
	fMu 6 "%" rwrite .sp
	"Time" .write
	.reset fcr ;

:rowat | i --
	ptop + nvis <? ( showrow ; ) drop fw .nsp fcr ;

:fixscroll | --
	psel ptop <? ( psel 'ptop ! ) drop
	psel ptop vh + >=? ( vh - 1+ 'ptop ! psel ) drop
	ptop 0 max 'ptop ! ;

:table | --
	fixscroll header
	0 ( vh <? dup rowat 1+ ) drop ;

|---------------------------------------------------------------- tree view
#lv 0
:marker | -- str
	np 32 + @ 0? ( drop "  " ; ) drop
	np 56 + @ 1 and? ( drop "▾ " ; ) drop "▸ " ;

:tpar | -- fix ; percent of the parent
	np @ 0? ( drop 100 16 << ; )
	nrec 24 + @ 1 max np 24 + @ 100 * 16 << swap / ;

:tpct | -- fix ; percent of the total
	np 24 + @ 100 * 16 << total / ;

:showtl | k --
	dup tsel =? ( bg3 ) drop
	tl@ 'lv ! nrec 'np !
	fTx
	lv 1 << 24 min dup spc
	marker .write
	30 swap - 2 - 4 max np 8 + @ rname lwrite .sp
	10 np 16 + @ .d rwrite .sp
	8 np 24 + @ .d rwrite .sp
	8 np 48 + @ .d rwrite .sp
	np 24 + @ pctcolms
	6 tpar .f1 rwrite .sp
	6 tpct .f1 rwrite .sp
	np 24 + @ 74 bar
	.reset fcr ;

:theader | --
	fMu .Bold
	30 "Word" lwrite .sp
	10 "Calls" rwrite .sp
	8 "ms" rwrite .sp
	8 "Self" rwrite .sp
	6 "%par" rwrite .sp
	6 "%tot" rwrite .sp
	"Time" .write
	.reset fcr ;

:trowat | i --
	ttop + ntl <? ( showtl ; ) drop fw .nsp fcr ;

:tfixscroll | --
	tsel ttop <? ( tsel 'ttop ! ) drop
	tsel ttop vh + >=? ( vh - 1+ 'ttop ! tsel ) drop
	ttop 0 max 'ttop ! ;

:blank | n -- ; n empty lines
	( 1? 1- fw .nsp fcr ) drop ;

:notree | --
	fYe "No call tree in mem/profile.mem" .lw
	fTx "Run the program again with the new inc-prof." .lw
	vh 2 - blank ;

:treeview | --
	nn 0? ( drop notree ; ) drop
	tfixscroll theader
	0 ( vh <? dup trowat 1+ ) drop ;

|---------------------------------------------------------------- detail
:,callees | r -- ; names it calls (static)
	edgeini ( 1? 1- da@+ rname ,s ,sp ) drop ;

:calls? | r j -- 0/1 ; row j calls r
	edgeini ( 1? 1- da@+ pick2 =? ( 3drop 1 ; ) drop ) 2drop 0 ;

:,callers | r -- ; names that call it (static)
	0 ( cnt <? 2dup calls? 1? ( over rname ,s ,sp ) drop 1+ ) 2drop ;

:,path | id -- ; from the node up to the boot
	( 1? dup nrec 8 + @ rname ,s
		nrec @ 1? ( " < " ,s ) ) drop ;

:,kids | id -- ; sons, the biggest first
	nrec 32 + @ ( 1? dup nrec 8 + @ rname ,s ,sp nrec 40 + @ ) drop ;

#cn 0
:,npaths | r -- ; number of call paths of the word
	0 'cn !
	1 ( nn <=? dup nrec 8 + @ pick2 =? ( 1 'cn +! ) drop 1+ ) 2drop
	cn "%d" ,print ;

:,wordtot | r -- ; totals of the word
	rec 'rp !
	rp 56 + @ rp 24 + @ rp 16 + @ "%d calls   %d ms   %d self" ,print ;

#lw 0 #la 0
:linelist | "label" 'builder arg --
	'la !
	swap utf8count 'lw ! fMu .write fTx
	mark here swap la swap ex 0 ,c
	fw lw - swap lwrite
	empty fcr ;

:clrline | --
	fw .nsp fx .col ;

:detailbody | -- ; the word of the table
	nvis 0? ( drop "(no data)" .lw ; ) drop
	psel ord@ rec 'rp !
	clrline fPr .Bold rp @ .write .NBold fTx
	.sp rp 8 + @ flagdesc .write fcr
	clrline rp 16 + @ "%d calls   " .print
	rp 24 + @ "%d ms   " .print
	selfstr "%s self   " .print
	uspc "%s us/call   " .print
	pctfix .f1 .write " % of the total" .write fcr
	"calls to: " ',callees psel ord@ linelist
	"called by: " ',callers psel ord@ linelist
	"call paths: " ',npaths psel ord@ linelist ;

:tdetail | -- ; the node of the tree
	ntl 0? ( drop "(no data)" .lw ; ) drop
	tsel tl@ 'lv ! nrec 'np !
	np 8 + @ rec 'rp !
	clrline fPr .Bold rp @ .write .NBold fTx
	.sp rp 8 + @ flagdesc .write fcr
	clrline np 16 + @ "%d calls   " .print
	np 24 + @ "%d ms   " .print
	np 48 + @ "%d self   " .print
	tpar .f1 .write " % of the parent   " .write
	tpct .f1 .write " % of the total" .write fcr
	"path: " ',path tsel tl@ drop linelist
	"sons: " ',kids tsel tl@ drop linelist
	"word: " ',wordtot np 8 + @ linelist ;

|---------------------------------------------------------------- screen
:sortname | -- str
	sortk 0? ( drop "name" ; )
	1 =? ( drop "calls" ; )
	2 =? ( drop "time" ; )
	3 =? ( drop "us/call" ; ) drop "self" ;

:tbinfo | --
	view 1? ( drop "  | call tree" .write ; ) drop
	"  | order: " .write sortname .write
	sortd 1? ( " (reversed)" .write ) drop
	showall 1? ( "  | all words" .write ) drop ;

:topbar | --
	1 flxN fx fy .at .rev .eline
	" r3 profile " .write
	title 1? ( dup .write ) drop
	tbinfo
	havemem 0? ( "  | NO mem/profile.mem" .write ) drop
	.reset ;

:foot | --
	1 flxS fx fy .at .rev .eline
	view 1? ( drop " Tab words  Enter/Right/Left fold  + - all  R reload  H help  ESC" .write .reset ; ) drop
	" Tab tree  N C T P S order  A all  R reload  H help  ESC" .write
	.reset ;

:msgscreen | --
	flxRest tuWina $1 " r3 profile " .wtitle 1 1 flpad fhome
	fYe msg .lw fTx
	"R reload   ESC exit" .lw
	fh 4 - blank ;

:viewtitle | -- str
	view 1? ( drop " Call tree " ; ) drop " Words " ;

:detail | --
	view 1? ( drop tdetail ; ) drop detailbody ;

:panel | --
	view 1? ( drop treeview ; ) drop table ;

:screen | --
	.reset
	topbar foot
	msg 1? ( drop msgscreen ; ) drop
	7 flxS tuWina $1 " Detail " .wtitle 1 1 flpad fhome detail
	flxRest tuWina $1 viewtitle .wtitle 1 1 flpad fhome panel ;

|---------------------------------------------------------------- keys
:help | --
	"r3profview help" 66 20 tuDlg
	fcr
	"Tab           words / call tree" .cw
	"up down PgUp PgDn Home End   move" .cw
	"N C T P S     order the words (again = reverse)" .cw
	"A             words without calls yes/no" .cw
	"Enter Right Left   open / close / go to the parent" .cw
	"+ -           open / close all the tree" .cw
	"R             reload the files" .cw
	fcr
	"R = direct recursion: calls = entries from outside" .cw
	"I = indirect recursion: time counted once" .cw
	"- = not measured (no ;)     Self = ms without sons" .cw
	"Tree: one line for each call path, exact times" .cw
	fcr
	"any key closes" .cw
	tuDlgEnd
	uikey 1? ( exit ) drop ;

:movsel | d --
	view 1? ( drop tmov ; ) drop
	nvis 0? ( 2drop ; ) drop
	psel + nvis 1- clamp0max 'psel ! tuR! ;

:gohome | --
	view 1? ( drop 0 'tsel ! tuR! ; ) drop
	0 'psel ! tuR! ;

:goend | --
	view 1? ( drop ntl 1- 0 max 'tsel ! tuR! ; ) drop
	nvis 1- 0 max 'psel ! tuR! ;

:flipview | --
	view 1 xor 'view ! tuR! ;

:onkey | --
	uikey 0? ( drop ; )
	[esc] =? ( exit )
	[tab] =? ( flipview )
	[up] =? ( -1 movsel ) [dn] =? ( 1 movsel )
	[pgup] =? ( vh neg movsel ) [pgdn] =? ( vh movsel )
	[home] =? ( gohome ) [end] =? ( goend )
	[enter] =? ( ttoggle ) [ri] =? ( tright ) [le] =? ( tleft )
	$20 or
	$76 =? ( flipview )
	$6e =? ( 0 setsort ) $63 =? ( 1 setsort ) $74 =? ( 2 setsort ) $70 =? ( 3 setsort ) $73 =? ( 4 setsort )
	$61 =? ( showall 1 xor 'showall ! resort )
	$2b =? ( 1 tall ) $2d =? ( 0 tall )
	$72 =? ( loadall )
	$68 =? ( 'help onTui ) $3f =? ( 'help onTui )
	$71 =? ( exit )
	drop ;

:main | --
	screen onkey ;

:
	here 'here0 !
	loadall
	.alsb
	'main onTui
	.masb .free ;
