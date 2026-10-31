| r3profview - analizador del profile (TUI)
| lee mem/profile.def (lo genera r3genprof) y mem/profile.mem (lo graba el programa medido)
| PHREDA 2026

^r3/util/tui.r3
^r3/lib/parse.r3

|---------------------------------------------------------------- datos
| fila (64 bytes), una por palabra del codigo principal:
|  0 nombre | 8 flags | 16 llamadas | 24 ms | 32 inicio en edges | 40 cantidad | 48 clave de orden
| flags: 1 boot  2 dato  4 funcion (con profile)  8 sin profile  16 R autollamada  64 init (boot previo)
| edges: dwords, filas a las que llama cada palabra (sin repetidos)

#cnt 0 #nmainv 0 #title 0
#dat 0 #edges 0 #ord 0
#nedges 0 #estart 0 #tsz 0
#here0 0 #total 1 #msg 0 #havemem 0

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

|---------------------------------------------------------------- carga de profile.def
:>>fld | adr -- adr' ; hasta '|' o CR (o el 0 final)
	( c@+ $ff and 1?
		$7c =? ( drop 1- ; )
		13 =? ( drop 1- ; )
		drop ) drop 1- ;

:fld | adr -- adr' str ; corta el campo con un 0
	dup >>fld 0 over c! 1+ swap ;

:flagsof | str -- n
	c@ $ff and
	$42 =? ( drop 1 ; )		| B boot
	$44 =? ( drop 2 ; )		| D dato
	$46 =? ( drop 4 ; )		| F funcion
	$49 =? ( drop 64 ; )	| I arranque previo
	drop 8 ;				| X

:e? | n -- 0/1 ; ya esta en las llamadas de la fila actual (conserva A y B)
	ab[ estart 2 << edges + >a nedges estart -
	( 1? 1- da@+ pick2 =? ( 3drop 1 ]ba ; ) drop ) 2drop 0 ]ba ;

:edgeadd | n --
	dup e? 1? ( 2drop ; ) drop
	nedges 2 << edges + d! 1 'nedges +! ;

#rcur 0
:rowparse | adr -- adr'
	rcur rec >a
	fld a!+					| nombre
	fld flagsof a!+			| flags
	0 a!+ 0 a!+				| llamadas ms
	nedges dup 'estart ! a!+
	fld						| adr' str
	( trim dup c@ 1? drop getnro edgeadd ) 2drop
	nedges estart - a!+		| cantidad
	0 a!+ ;					| clave

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

|---------------------------------------------------------------- carga de profile.mem
| [cantidad] y por fila 16 bytes: inicio | llamadas<<32 + ms
:loadmem | -- 0/1
	here dup "mem/profile.mem" load		| ini fin
	over =? ( 2drop 0 ; )
	drop >b b@+ cnt min
	0 ( over <?
		b@+ drop b@+					| n i v
		over rec 16 + >a
		dup 32 >> a!+ $ffffffff and a!+
		1+ ) 2drop 1 ;

:calctotal | -- ; total = ms del boot (ultima fila); si no, el mayor
	cnt 1- rms 'total !
	total 1? ( drop ; ) drop
	0 ( cnt <? dup rms total max 'total ! 1+ ) drop
	total 0? ( 1 'total ! ) drop ;

|---------------------------------------------------------------- recursion
| en r3 no hay referencias hacia adelante: el grafo de llamadas directas no tiene ciclos
| salvo la autollamada (R). La recursion indirecta (ex sobre variable) no se ve aca.
:edgeini | r -- n ; A apunta a sus llamadas, n = cantidad
	rec 32 + @+ 2 << edges + >a @ ;

:addflag | n f --
	swap rec 8 + dup @ pick2 or swap ! drop ;

#fcur 0
:flagrow | r -- ; marca R si se llama a si misma
	dup 'fcur ! edgeini
	( 1? 1- da@+ fcur =? ( fcur 16 addflag ) drop ) drop ;

|---------------------------------------------------------------- orden
#sortk 2		| 0 nombre 1 llamadas 2 tiempo 3 us por llamada
#sortd 0		| 1 invierte
#showall 0
#psel 0 #ptop 0 #nvis 0 #selrow -1

:ord@ | i -- v
	3 << ord + @ ;
:ord! | v i --
	3 << ord + ! ;

:keyrow | i -- key
	dup rcalls over rms				| i calls ms
	sortk
	1 =? ( 2drop nip ; )			| calls
	2 =? ( drop nip nip ; )			| ms
	3 =? ( drop 1000 * swap 1 max / nip ; )
	4drop 0 ;

:cmprows | a b -- n ; <0 si a va antes que b
	sortk 0? ( drop
		rname swap rname swap cmpstr
		sortd 1? ( drop neg ; ) drop ; ) drop
	rec 48 + @ swap rec 48 + @ -
	sortd 1? ( drop neg ; ) drop ;

#sx 0
:ins | i -- ; inserta ord[i] en la parte ordenada
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

|---------------------------------------------------------------- carga total
:loadall | --
	tuR! here0 'here !
	0 'nvis ! 0 'psel ! 0 'ptop ! 0 'cnt !
	loaddef 0? ( drop "No mem/profile.def: generate with r3prof" 'msg ! ; ) drop
	cnt 0? ( drop "mem/profile.def no words" 'msg ! ; ) drop
	loadmem dup 'havemem ! 0? ( 1 'showall ! ) drop
	calctotal
	0 ( cnt <? dup flagrow 1+ ) drop
	0 'msg !
	-1 'selrow ! resort ;

|---------------------------------------------------------------- pantalla
:vh | -- n ; filas de datos de la tabla
	fh 1- ;

:spc | n --
	1 >? ( .nsp ; ) 1 =? ( drop .sp ; ) drop ;

:flagstr | f -- str
	16 and? ( drop "R" ; )
	8 and? ( drop "-" ; )
	drop " " ;

:flagdesc | f -- str
	1 and? ( drop "all code (boot)" ; )
	64 and? ( drop "pre-run (no time)" ; )
	16 and? ( drop "recursive" ; )
	8 and? ( drop "no profile (no ;)" ; )
	drop "" ;

#rp 0
:uspc | -- str ; us por llamada
	rp 16 + @ 0? ( drop "-" ; )
	rp 24 + @ 1000 * 16 << swap / .f2 ;

:pctfix | -- fix ; porcentaje del total (48.16)
	rp 24 + @ 100 * 16 << total / ;

:pctcol | --
	rp 24 + @ 1000 * total /
	300 >=? ( drop fRd ; )
	100 >=? ( drop fYe ; ) drop fGr ;

:nbar | bw -- bw n
	rp 24 + @ 0? ( ; )
	over * total / 1 max
	over min ;

:blocks | n --
	1 <? ( drop ; ) "█" .rep ;

:bar | --
	fw 62 - 1 <? ( drop ; )
	nbar pctcol
	dup blocks - spc ;

:showrow | k --
	dup psel =? ( bg3 ) drop
	ord@ rec 'rp !
	fTx 22 rp @ lwrite .sp
	fYe 1 rp 8 + @ flagstr lwrite .sp
	fTx 10 rp 16 + @ .d rwrite .sp
	8 rp 24 + @ .d rwrite .sp
	9 uspc rwrite .sp
	pctcol 6 pctfix .f1 rwrite .sp
	bar
	.reset fcr ;

:hcol | mode --
	sortk =? ( drop fPr ; ) drop fMu ;

:header | --
	.Bold
	0 hcol 22 "Word" lwrite .sp
	fMu 1 " " lwrite .sp
	1 hcol 10 "Calls" rwrite .sp
	2 hcol 8 "ms" rwrite .sp
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

|---------------------------------------------------------------- detalle
:,callees | r -- ; nombres a los que llama
	edgeini ( 1? 1- da@+ rname ,s ,sp ) drop ;

:calls? | r j -- 0/1 ; la fila j llama a r
	edgeini ( 1? 1- da@+ pick2 =? ( 3drop 1 ; ) drop ) 2drop 0 ;

:,callers | r -- ; nombres que la llaman
	0 ( cnt <? 2dup calls? 1? ( over rname ,s ,sp ) drop 1+ ) 2drop ;

#lw 0
:linelist | "label" 'builder --
	swap utf8count 'lw ! fMu .write fTx
	mark here swap psel ord@ swap ex 0 ,c
	fw lw - swap lwrite
	empty fcr ;

:clrline | --
	fw .nsp fx .col ;

:detailbody | --
	nvis 0? ( drop "(no data)" .lw ; ) drop
	psel ord@ rec 'rp !
	clrline fPr .Bold rp @ .write .NBold fTx
	.sp rp 8 + @ flagdesc .write fcr
	clrline rp 16 + @ "%d calls   " .print
	rp 24 + @ "%d ms   " .print
	uspc "%s us/call   " .print
	pctfix .f1 .write " % total" .write fcr
	"call to: " ',callees linelist
	"used by: " ',callers linelist ;

|---------------------------------------------------------------- pantalla
:sortname | -- str
	sortk 0? ( drop "name" ; )
	1 =? ( drop "calls" ; )
	2 =? ( drop "time" ; ) drop "us/call" ;

:topbar | --
	1 flxN fx fy .at .rev .eline
	" r3 profile " .write
	title 1? ( dup .write ) drop
	"  | orden: " .write sortname .write
	sortd 1? ( " (inv)" .write ) drop
	showall 1? ( "  | all" .write ) drop
	havemem 0? ( "  | no mem/profile.mem" .write ) drop
	.reset ;

:foot | --
	1 flxS fx fy .at .rev .eline
	" N C T P  sort  A all  R reload  H help  ESC" .write
	.reset ;

:msgscreen | --
	flxRest tuWina $1 " r3 profile " .wtitle 1 1 flpad fhome
	fYe msg .lw fTx
	"R reload   ESC help" .lw ;

:screen | --
	.reset
	topbar foot
	msg 1? ( drop msgscreen ; ) drop
	7 flxS tuWina $1 " Detalle " .wtitle 1 1 flpad fhome detailbody
	flxRest tuWina $1 " Words " .wtitle 1 1 flpad fhome table ;

|---------------------------------------------------------------- teclas
:help | --
	"Help r3profview" 62 15 tuDlg
	fcr
	"up dn PgUp PgDn Home End  move" .cw
	"N C T P   sort" .cw
	"A        word without calls" .cw
	"R        reload" .cw
	fcr
	"R = recurse" .cw
	"    calls" .cw
	"- = withoutprof" .cw
	fcr
	"Any key to Close" .cw
	tuDlgEnd
	uikey 1? ( exit ) drop ;

:movsel | d --
	nvis 0? ( 2drop ; ) drop
	psel + nvis 1- clamp0max 'psel ! tuR! ;

:onkey | --
	uikey 0? ( drop ; )
	[esc] =? ( exit )
	[up] =? ( -1 movsel ) [dn] =? ( 1 movsel )
	[pgup] =? ( vh neg movsel ) [pgdn] =? ( vh movsel )
	[home] =? ( 0 'psel ! tuR! )
	[end] =? ( nvis 1- 0 max 'psel ! tuR! )
	$20 or
	$6e =? ( 0 setsort ) $63 =? ( 1 setsort ) $74 =? ( 2 setsort ) $70 =? ( 3 setsort )
	$61 =? ( showall 1 xor 'showall ! resort )
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
