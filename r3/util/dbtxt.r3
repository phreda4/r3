| DB files
| PHREDA 2020
|--------------------------------------
| txt db
| field 1|field 2|..|field 3^
| field 1|field 2|..|field 3^
|
|
^r3/win/console.r3

##rowdb
#flds * 512
#flds> 'flds
#memflds * 8192
#memflds> 'memflds

|------------------------------------------
:FNAME | adr -- adrname
	44 + ;

::getnfilename | n "path" -- filename/0
	"%s/*" sprint
	ffirst drop fnext drop
	( fnext 0? ( nip ; ) swap 1? 1 - nip ) drop
	FNAME ;

:loadrow | "" -- ""
	'rowdb over "%s.now" sprint load
	'rowdb =? ( 0 'rowdb ! ) drop ;

:saverow | "" --
	1 'rowdb +!
	'rowdb 8 rot "%s.now" sprint save ;

::loadnfile | "" -- filename
	loadrow
	rowdb over getnfilename
	0? ( over getnfilename 0 'rowdb ! )
	swap
	saverow ;
	
|--------------------------------------
:,fld
	memflds> flds> !+ 'flds> ! ;

:,mf
	memflds> c!+ 'memflds> ! ;

:,mem | c --
	$7c =? ( drop 0 ,mf ,fld ; ) | |
	,mf ;

:loadrow | "" -- ""
	'rowdb over "%s.now" sprint load
	'rowdb =? ( 0 'rowdb ! ) drop ;

:saverow | "" --
	1 'rowdb +!
	'rowdb 8 rot "%s.now" sprint save ;

::>>line | adr -- adr'/0
	( c@+ 1?
	 	$5e =? ( drop ; ) | ^
		drop ) drop 1 - ;

:parsedb | lastmem -- lastmem
	here rowdb ( 1? swap
		>>line trim
		swap 1 - ) drop
	over >=? ( drop here 0 'rowdb ! ) | se paso
	,fld
	( c@+ 1? $5e <>? ,mem ) 2drop
	0 memflds> c! ;

| load one row db , incremental position
|
::loaddb-i | "filename" --
	loadrow
	mark
	'flds 'flds> !
	'memflds 'memflds> !
	here over load here >? ( parsedb ) drop
	empty
	saverow	;
	
::prevdb-i | "filename" --
	loadrow
	-1 'rowdb +!
	'rowdb 8 rot "%s.now" sprint save ;
	
| get field nro
|
::dbfld | nro -- string
	3 << 'flds +
	flds> >=? ( drop "" ; )
	@ ;

| load static db
|
::loaddb | "filename" -- 'db
	here swap load here =? ( drop 0 ; )
	0 swap c!+
	here swap 'here !
	;

::getdbrow | id 'db -- 'row
	( swap 1? 1 - swap
		>>line trim ) drop ;

::findbrow | hash 'db -- 'row/0
	swap @ swap
	( dup @ 1? pick2 =? ( drop nip ; ) drop
		>>line trim ) nip nip ;
		
::cntdbrow | 'db -- cnt
	>a
	0 ( ca@+ 1?
	 	$5e =? ( swap 1 + swap ) | ^
		drop ) drop ;
	
::>>fld | adr -- adr'
	( c@+ 1?
		$7c =? ( drop ; )
	 	$5e =? ( drop 1 - ; ) | ^
		drop ) drop 1 - ;

::getdbfld | nro 'row -- 'fld ; "|^" limit
	( swap 1? 1 - swap >>fld ) drop ;

::cpydbfld | 'fld 'str --
	( swap c@+ 1?
		$7c =? ( 2drop 0 swap c! ; )
	 	$5e =? ( 2drop 0 swap c! ; ) | ^
		rot c!+ ) nip swap c! ;
		
::cpydbfldn | max 'fld 'str --
	>b >a 
	( 1? 1 -
		ca@+ 0? ( cb! drop ; )
		$7c =? ( 2drop 0 cb! ; )
	 	$5e =? ( 2drop 0 cb! ; ) | ^
		cb!+ ) cb! ;		
