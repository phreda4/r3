| DB files
| PHREDA 2020
|--------------------------------------
| txt db
| field 1|field 2|..|field 3^
| field 1|field 2|..|field 3^
|
|

#row
#flds * 512
#flds> 'flds
#memflds * 8192
#memflds> 'memflds

|------------------------------------------
:FNAME | adr -- adrname
	44 + ;

:getnfilename | n "path" -- filename/0
	ffirst drop fnext drop
	( fnext 0? ( nip ; ) swap 1? 1 - nip ) drop
	FNAME ;

:loadrow | "" -- ""
	'row over "%s.now" sprint load
	'row =? ( 0 'row ! ) drop ;

:saverow | "" --
	1 'row +!
	'row 8 rot "%s.now" sprint save ;

::loadnfile | "" -- filename
	loadrow
	row over getnfilename
	0? ( over getnfilename 0 'row ! )
	swap
	saverow ;

#filename * 1024
#filecut>

:listimg | 'list img -- 'list img
	filecut> @ rot !+ over swap !+ swap ;

::getfolderimg | 'list  "path" --
	dup 'filename strcpyl 1 - 'filecut> !
	ffirst drop fnext drop
	( fnext 1? FNAME
		filecut> strcpy
		'filename
		loadimg 1? ( listimg ) drop
		) swap ! ;

::listimg | hash 'list -- img
	( @+ 1?
		pick2 =? ( drop @ nip ; )
		drop 8 + ) nip nip ;

|--------------------------------------
:,fld
	memflds> flds> !+ 'flds> ! ;

:,mf
	memflds> c!+ 'memflds> ! ;

:,mem | c --
	$7c =? ( drop 0 ,mf ,fld ; ) | |
	,mf ;

:loadrow | "" -- ""
	'row over "%s.now" sprint load
	'row =? ( 0 'row ! ) drop ;

:saverow | "" --
	1 'row +!
	'row 8 rot "%s.now" sprint save ;

:>>line | adr -- adr'
	( c@+ 1?
	 	$5e =? ( drop ; ) | ^
		drop ) drop 1 - ;

:parsedb | lastmem -- lastmem
	here row ( 1? swap
		>>line trim
		swap 1 - ) drop
	over >=? ( drop here 0 'row ! ) | se paso
	,fld
	( c@+ $5e <>? ,mem ) 2drop
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
	0 swap !+
	here swap 'here !
	;

::getdbrow | id 'db -- 'row
	( swap 1? 1 - swap
		>>line trim ) drop ;

::findbrow | hash 'db -- 'row/0
	swap @ swap
	( dup @ 1? pick2 =? ( drop nip ; ) drop
		>>line trim ) nip nip ;

:>>fld | adr -- adr'
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
