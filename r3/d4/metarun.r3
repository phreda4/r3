^r3/d4/meta/metalibs.r3

|------------ metalibs
|#r3.. 'name 'words 'calls 'info
|#liblist 'r3..

:searchword | str lib+ 'names -- str lib+ nro/-1
	0 ( swap dup c@ 1? drop 
		dup pick4 =s 1? ( 2drop ; ) drop
		>>0 swap 1+ ) 3drop -1 ;	
	
:searchall | str -- str nro lib/0
	'liblist ( @+ 1?
		8 + @ searchword
		+? ( swap 8 - swap ; ) drop
		) 2drop 
	0 0 ;

:?iword	
	searchall nip | lib nro
	;

:.iword | adr nro -- adr
	8 << 8 or ,t >>sp ;
	
:.iadr | adr nro -- adr
	8 << 9 or ,t >>sp ;
	