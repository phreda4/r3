| main filesystem
| PHREDA 2019
|------------------------
^r3/win/console.r3
^r3/lib/trace.r3

#reset 0
#path * 1024
#name * 1024

#nfiles
#files * 8192
#files> 'files
#files< 'files
#filen * $3fff
#filen> 'filen

#nivel
#pagina
#actual
#linesv 15

|--------------------------------
:FNAME | adr -- adrname
|WIN| 44 +
|LIN| 19 +
|RPI| 11 +
|MAC| 21 +               | when _DARWIN_FEATURE_64_BIT_INODE is set !
	;

:FDIR? | adr -- 1/0
|WIN| @ 4 >>
|LIN| 18 + c@ 2 >>
|RPI| 10 + c@ 2 >>
|MAC| 20 + c@ 2 >>       | when _DARWIN_FEATURE_64_BIT_INODE is set !
	1 and ;

:FINFO | adr -- adr info
	dup FDIR? 0? ( 2 + ; ) drop 0 ;

:getname | nro -- ""
	3 << 'files + @ 8 >> 'filen + ;

:getinfo | nro -- info
	3 << 'files + @ $ff and ;

:getlvl | nro -- info
	3 << 'files + @ 4 >> $f and ;

:chginfo | nro --
	3 << 'files + dup @ $1 xor swap ! ;

|--------------------------------
:files.clear
	0 'nfiles !
	'filen 'filen> !
	'files dup 'files> ! 'files< !
	;

:files!+
	files> ( files< >?
		8 - dup @+ swap !
		) drop
	files< !+ 'files< !
	8 'files> +!
	;

:files.free
	0 'files ( files> <?
		@+ pick2 >? ( swap rot )
		drop ) drop
	8 >> 'filen +
	( c@+ 1? drop ) drop
	'filen> !
	;

:fileadd
	dup FNAME
	dup ".." = 1? ( 3drop ; ) drop
	dup "." = 1? ( 3drop ; ) drop
	drop
	FINFO nivel 4 << or filen> 'filen - 8 << or
	files!+
	FNAME filen> strcpyl 'filen> !
	;

:reload
	'path "%s//*" sprint
	ffirst ( fileadd fnext 1? ) drop
	files> 'files - 3 >> 'nfiles !
	;

:rebuild
	"r3" 'path strcpy
	files.clear
	0 'pagina !
	0 'nivel !
	reload
	;

|-----------------------------
:makepath | actual nivel --
	0? ( drop
		"r3/" 'path strcpy
		getname 'path strcat
		; )
	over 1 -
	( dup getlvl pick2 >=?
		drop 1 - ) drop
	over 1 - makepath drop
	"/" 'path strcat
	getname 'path strcat
	;

:expande
	actual dup
	getlvl makepath
   	actual chginfo
	actual getlvl 1 + 'nivel !
    actual 1 + 3 << 'files + 'files< !
	reload
	;

:remfiles
	actual chginfo
	actual getlvl 1 +
	actual 1 +
	( dup getlvl pick2 >=?
		drop 1 + ) drop
	nip
	actual 1 +
	( swap nfiles <?
		dup 3 << 'files + @
		pick2 3 << 'files + !
		1 + swap 1 + ) drop
	3 << 'files + 'files> !
	files> 'files - 3 >> 'nfiles !
	files.free
	;

:contrae
	'path ( c@+ 1? drop ) drop 1 -
	( 'path >?
		dup c@ $2f =? ( drop 0 swap c! remfiles ; )
		drop 1 - ) drop
	remfiles ;

|-------------
#nameaux * 1024

:next/ | adr -- adr'
	( c@+ 1?
		$2f =? ( drop 0 swap 1 - c!+ ; )
		drop ) nip ;

:getactual | adr actual -- actual
	( nfiles <?
		dup getname pick2 = 1? ( drop nip ; )
		drop 1 + ) nip ;


|--------------------------
:remlastpath
	'path ( c@+ 1? drop ) drop 1 -
	( dup c@ $2f <>? drop 1 - ) drop
	0 swap c! ;

:setactual
	actual dup getlvl makepath
	actual getinfo 1 >? ( remlastpath ) drop
	actual
	dup getinfo $3 and 2 <? ( 2drop "" 'name strcpy ; ) drop
	getname 'name strcpy
	;

|---------------------
:traverse | adr -- adrname
	dup next/ 0? ( drop ; )
	( dup next/ 1?
		swap
		actual getactual 'actual !
		expande
		) drop ;

:loadm
	'nameaux "mem/menu.mem" load
	'nameaux =? ( drop ; )
	'nameaux dup c@ 0? ( 2drop ; ) drop
	0 'actual !
	0 'path !
	traverse
	actual getactual nip
	pagina linesv + 1 - >=? ( dup linesv - 1 + 'pagina ! )
	'actual !
	drop
	setactual
	;

:savem
    'path 'name strcpy
	"/" 'name strcat
	actual getname 'name strcat
	'name 1024 "mem/menu.mem" save ;

|--------------------------
:remlastpath
	'path ( c@+ 1? drop ) drop 1 -
	( dup c@ $2f <>? drop 1 - ) drop
	0 swap c! ;

|--------------------------------
:runfile
	actual -? ( drop ; )
	getinfo $7 and 2 <? ( drop ; ) drop
	.reset
	'path
|WIN| "r3 ""%s/%s"""
|LIN| "./r3lin ""%s/%s"""
|RPI| "./r3rpi ""%s/%s"""
|MAC| "./r3mac %s/%s"
	sprint sys
	;

|--------------------------------
:editfile
	actual -? ( drop ; )
	getinfo $3 and 2 <>? ( drop ; ) drop
	.reset
	actual getname 'path "%s/%s" sprint 'name strcpy
	'name 1024 "mem/main.mem" save
|WIN| "r3 r3/editor/code-edit.r3"
|LIN| "./r3lin r3/editor/code-edit.r3"
|RPI| "./r3rpi r3/editor/code-edit.r3"
|MAC| "./r3mac r3/editor/code-edit.r3"
	 sys
	;

|--------------------------------
#nfile

:newfile
	1 'nfile !
	0 'name !
	;

:remaddtxt | --
	'name ".r3" =pos 1? ( drop ; ) drop
	".r3" swap strcat
	;

:createfile
	remaddtxt
	'name 'path "%s/%s" sprint 'name strcpy

	mark
	"^r3/lib/gui.r3" ,ln ,cr
	":main" ,ln
	"	cls home" ,ln
	"	""Hello Human!"" print" ,ln
	"	key >esc< =? ( exit ) drop" ,ln
	"	;" ,ln ,cr
	": 'main onshow ;" ,ln
	'name savemem
	empty

	'name 1024 "mem/main.mem" save
	'name 1024 "mem/menu.mem" save

|WIN| "r3 r3/editor/code-edit.r3"
|LIN| "./r3lin r3/editor/code-edit.r3"
|RPI| "./r3rpi r3/editor/code-edit.r3"
|MAC| "./r3mac r3/editor/code-edit.r3"
	sys

	rebuild
	loadm
	;

|--------------------------------
:fenter
	actual
	getinfo $f and
	0? ( drop expande ; )
	1 =? ( drop contrae ; )
	drop

	actual
	getname
	".r3" =pos 1? ( drop runfile ; ) drop
	drop
	;

:fdn
	actual nfiles 1 - >=? ( drop ; )
	1 + pagina linesv + 1 - >=? ( dup linesv - 1 + 'pagina ! )
	'actual !
	setactual ;

:fup
	actual 0? ( drop ; )
	1 - pagina <? ( dup 'pagina ! )
	'actual !
	setactual ;

:fpgdn
	actual nfiles 1 - >=? ( drop ; )
	20 + nfiles >? ( drop nfiles 1 - ) 'actual !
	actual pagina linesv + 1 -
	>=? ( dup linesv - 1 + 'pagina ! ) drop
	setactual ;

:fpgup
	actual 0? ( drop ; )
	20 - 0 <? ( drop 0 )
	pagina <? ( dup 'pagina ! )
	'actual !
	setactual ;

:fhome
	actual 0? ( drop ; ) drop
	0 'actual ! 0 'pagina !
	setactual ;

:fend
	actual nfiles 1 - >=? ( drop ; ) drop
	nfiles 1 - 'actual !
	actual 1 + pagina linesv + 1 -
	>=? ( dup linesv - 1 + 'pagina ! ) drop
	setactual ;


|--------------------------------
:printfn | n
	sp
	dup getlvl 1 << nsp
	dup getinfo $3 and "+- ." + c@ emit
	sp getname .print sp
	;

#filecolor 1 2 3 4 

:colorfile | n -- n
	actual =? ( .bwhite .black ; )
    dup getinfo $3 and 3 << 'filecolor + @ .fc ;

:drawl | n --
	sp colorfile printfn .reset ;
	
:drawtree
	0 2 .at
	0 ( linesv <?
		dup pagina +
		nfiles  >=? ( 2drop ; )
    	drawl
		cr 1 + ) drop ;
	
:screen
	.reset .cls 
	.bblue .white
	0 0 .at .eline
	0 0 .at " r3 " .print
	"^[7mF1^[27m Run ^[7mF2^[27m Edit ^[7mF3^[27m New " .printe
	
	.reset
	drawtree

	.bblue .white	
	0 linesv 2 + .at .eline
	0 linesv 2 + .at 
	
	'name 'path " %s/%s  " .print

	codekey 32 >> " $%h " .print
	
	0 actual pagina - 2 + .at
	;

:teclado
	codekey 32 >>
	$d001c =? ( fenter screen )
	
	$48 =? ( fup screen ) | up
	$50 =? ( fdn screen ) | dn
	$49 =? ( fpgup screen )
	$51 =? ( fpgdn screen )
	$47 =? ( fhome screen )
	$4f =? ( fend screen )
	
	$3b =? ( fenter screen )
	$3c =? ( editfile screen )
	$3d =? ( newfile screen )
	drop 
|	screen
	;


|---------------------------------
:main
	rebuild
	.getconsoleinfo
	rows 3 - 'linesv !
	loadm

	screen
	( getch 27 <>? drop
 		teclado ) drop
		
	savem		
	;

	
: main ;
