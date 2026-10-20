| replmodel - model of the project built by r3token
| the REPL does not analyze text: it assembles the program (replgen), r3token tokenizes it
| and this model keeps what the dictionary says about the project words:
| name, data/code, exported, writes memory, effect, uses, line of the project file
| m.ready tokenizes again only if the project changed (mdirty is set by replcore)
|   m.count m.name m.data? m.writes? m.eff m.line m.find m.ok
|   m.boots m.bootline (the boot words of the project)  m.prev (an earlier definition of the same name)
|   m.ok = 0 : the project does not compile (m.errmsg m.errline say why); the model keeps the words before the error
^repl/replchk.r3

#mtab * 32768		| 1024 words x 32 bytes: name 24, flags 1, use 1, delta 1, line 2 (at 30)
#mn 0
#mok 1
#mtmp * 64
#mp 0
#msga 0 #msgk 0
#mbs * 128 #mbn 0	| boot words of the project: first line (file line), 16 at most

:m.add | n -- ; stores the word n of the dictionary
	mn 1024 >=? ( 2drop ; ) drop
	mn 5 << 'mtab + 'mp !
	dup r3name 'mtmp swap copynom
	0 'mtmp 23 + c!
	'mtmp mp strcpy
	dup nro>dic @ 3 and over ckwrites? 2 << or mp 24 + c!
	dup nro>dic 8 + @
	dup $ff and mp 25 + c!
	8 >> $ff and mp 26 + c!
	r3name src swap cklines mp 30 + w!
	1 'mn +! ;

:m.skip? | n -- 0/1 ; the words of the REPL itself are not part of the project
	dup r3isboot 1? ( 2drop 1 ; ) drop
	dup r3name "rdini" =s 1? ( 2drop 1 ; ) drop
	r3name "rdend" =s ;

:m.addboot | n -- ; lines of a boot word of the project
	mbn 16 >=? ( 2drop ; ) drop
	r3name src swap cklines mbn 3 << 'mbs + !
	1 'mbn +! ;

:m.chkboot | n --
	dup ckboot1? 1? ( drop m.addboot ; ) 2drop ;

:m.snap | -- ; the project words (between the libraries and the final boot)
	0 'mn ! 0 'mbn !
	ckwriters
	dic< dic - 4 >> ( cntdef <?
		dup m.chkboot
		dup m.skip? 0? ( over m.add ) drop
		1+ ) drop ;

#mmsg * 160 #mline 0
#msok 0 #mser 0 #msau 1

:m.snapok | -- code ; the tokens are loaded
	1 'mok ! m.snap 0 ;

:m.snaperr | -- ; the tokenizer stopped: the words before the error
	0 'mok ! 'ckmsg 'mmsg strcpy ckline 'mline !
	dic> dic - 4 >> 1- 0 max 'cntdef !	| the word being defined when the error came is incomplete
	m.snap ;

::m.update | -- ; tokenizes the project (without line) and stores its words
	0 'mdirty !
	ga 'msga ! gk 'msgk !
	ckonok 'msok ! ckonerr 'mser ! ckauto 'msau !
	'm.snapok 'ckonok ! 'm.snaperr 'ckonerr ! 0 'ckauto !
	gen-proj
	chk-loop drop
	msok 'ckonok ! mser 'ckonerr ! msau 'ckauto !
	msga 'ga ! msgk 'gk ! ;

::m.ready | -- ; the model is up to date
	mdirty 1? ( drop m.update ; ) drop ;

::m.ok | -- 0/1
	mok ;

::m.errmsg | -- 'str ; why the project does not compile
	'mmsg ;

::m.errline | -- line
	mline ;

::m.count | -- n
	mn ;

::m.name | i -- str
	5 << 'mtab + ;

:m.fl | i -- flags
	5 << 'mtab + 24 + c@ $ff and ;

::m.data? | i -- 0/1
	m.fl 1 and ;

::m.writes? | i -- 0/1
	m.fl 4 and 2 >> ;

::m.eff | i -- eff ; use<<8 | delta&$ff, -1 = data (the format of effstr)
	dup m.data? 1? ( 2drop -1 ; ) drop
	5 << 'mtab + dup 25 + c@ $ff and 8 << swap 26 + c@ $ff and or ;

::m.line | i -- line ; line of the project file
	5 << 'mtab + 30 + w@ $ffff and ;

::m.find | "name" -- i ; the last definition of that name, -1 = none
	mn ( 1? 1-
		2dup m.name =s 1? ( drop nip ; ) drop )
	2drop -1 ;

::m.boots | -- n
	mbn ;

::m.bootline | i -- first ; first line of the boot word i
	3 << 'mbs + @ ;

::m.prev | i -- j ; the previous definition of the same name, -1 = none
	dup m.name swap
	( 1? 1- 2dup m.name =s 1? ( drop nip ; ) drop )
	2drop -1 ;

::m.init | --
	1 'mdirty ! ;
