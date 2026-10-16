| r4-include profile
| PHREDA 2015
|------------------
^r3/lib/mem.r3

| tabla profile
| mseca amsec calls
#profile_ini
#profile_table
#profile_fin

:12* | n -- n*12
	2 << dup 2* + ;

::profile_start | nrow --
	12* profile_table + msec swap ! ;

::profile_end | nrow --
	12* profile_table + >r
	msec r@+ - r +!
	1 r> 4+ +! ;

|------------------------------------------
::profile_save | --
	profile_ini profile_fin over - "mem/profile.mem" save ;

::profile_mem | cntw "" --
	mark
	here 'profile_ini !
	over , ,s 0 ,c | cnt "nombre"
	here 'profile_table !
	( 1? )( 0 , 0 , 0 , 1- ) drop
	here 'profile_fin ! ;

|":_run_ " ,print
|	wordcntok 1- swap 4+ swap printtokenlin drop
|	'ed.nombre swap ": %d ""%s"" profile_mem _run_ profile_save ;" ,print ,nl