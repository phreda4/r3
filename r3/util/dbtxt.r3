| DB files
| PHREDA 2020
|--------------------------------------
| txt db
| field 1|field 2|..|field 3^
| field 1|field 2|..|field 3^
|
|
^r3/lib/console.r3

##rowdb | number of the record the incremental words (loaddb-i, prevdb-i) will load next
#flds * 512
#flds> 'flds
#memflds * 8192
#memflds> 'memflds

|------------------------------------------
:FNAME | adr -- adrname
	44 + ;

::getnfilename | n "path" -- filename/0 ; name of the nth file of a folder (Windows only: it uses the Windows directory entry layout); 0 if there are fewer
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

::loadnfile | "path" -- filename ; incremental: each call returns the next file name of the folder, the position is kept in the file "path.now" and wraps to the first (Windows only)
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

::>>line | adr -- adr' ; address after the next ^ (end of record), or the final 0 if there is none
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
::loaddb-i | "filename" -- ; incremental: load the record number kept in "filename.now" and split it in fields (read them with dbfld), then advance to the next record (wraps at the end)
	loadrow
	mark
	'flds 'flds> !
	'memflds 'memflds> !
	here over load here >? ( parsedb ) drop
	empty
	saverow	;
	
::prevdb-i | "filename" -- ; step the position kept in "filename.now" back one record (the next loaddb-i loads the previous one)
	loadrow
	-1 'rowdb +!
	'rowdb 8 rot "%s.now" sprint save ;
	
| get field nro
|
::dbfld | nro -- str ; field nro (0 is the first) of the record loaded with loaddb-i; an empty string if there are fewer fields
	3 << 'flds +
	flds> >=? ( drop "" ; )
	@ ;

| load static db
|
::loaddb | "filename" -- 'db ; load a text database (records field|field|..^) at here, where it stays, and return its address; 0 if the file is empty or missing
	here swap load here =? ( drop 0 ; )
	0 swap c!+
	here swap 'here !
	;

::getdbrow | id 'db -- 'row ; address of record number id (0 is the first) of a database loaded with loaddb
	( swap 1? 1 - swap
		>>line trim ) drop ;

::findbrow | 'key 'db -- 'row/0 ; first record whose first 8 bytes equal the 8 bytes at 'key (the original comment called it hash); 0 if none
	swap @ swap
	( dup @ 1? pick2 =? ( drop nip ; ) drop
		>>line trim ) nip nip ;
		
::cntdbrow | 'db -- cnt ; number of records (count of ^); 0 if 'db is 0
	0? ( ; )
	>a
	0 ( ca@+ 1?
	 	$5e =? ( swap 1 + swap ) | ^
		drop ) drop ;
	
::>>fld | adr -- adr' ; address after the next | (next field); it stops at a ^ (end of record) without skipping it
	( c@+ 1?
		$7c =? ( drop ; )
	 	$5e =? ( drop 1 - ; ) | ^
		drop ) drop 1 - ;

::getdbfld | nro 'row -- 'fld ; address of field nro (0 is the first) of a record; the field ends at | or ^, not at a 0
	( swap 1? 1 - swap >>fld ) drop ;

::cpydbfld | 'fld 'str -- ; copy the text of a field (up to | or ^) to 'str with a final 0
	( swap c@+ 1?
		$7c =? ( 2drop 0 swap c! ; )
	 	$5e =? ( 2drop 0 swap c! ; ) | ^
		rot c!+ ) nip swap c! ;
		
::cpydbfldn | max 'fld 'str -- ; like cpydbfld copying at most max characters
	>b >a 
	( 1? 1 -
		ca@+ 0? ( cb! drop ; )
		$7c =? ( 2drop 0 cb! ; )
	 	$5e =? ( 2drop 0 cb! ; ) | ^
		cb!+ ) cb! ;		
