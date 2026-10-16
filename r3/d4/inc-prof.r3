| r4-include profile (now r3)
| PHREDA 2015 (2026)
|------------------
^r3/lib/mem.r3

| tabla profile
| mseca calls|deltamsec
#profile_table
#profile_end

::profile_start | nrow --
	4 << profile_table + msec swap ! ;

::profile_end | nrow --
	4 << profile_table + 
	msec over @ - $100000000 or
	swap 8 + +! ;

|------------------------------------------
::profile_mem | cntw --
	here >a
	a!+
	a> 'profile_table !
	( 1? 0 a!+ 0 a!+ 1- ) drop
	a> dup 'profile_end ! 
	'here ! ;

::profile_save | --
	profile_table 8 - profile_end over - "mem/profile.mem" save ;

