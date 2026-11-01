| r3 profile runtime - included by the code made by r3genprof
| PHREDA 2015 (2026)
|
| profile_start | n --   profile_end | n --   wrap every measured word (n = row = word - nmain)
| profile_mem | cnt --    reserve the tables      profile_save | --   write mem/profile.mem
|
| row, one per word (16 bytes):  [ aux | calls<<32 + msec ]
|   aux: bits 0-15 nesting level, bit 32 = the word was re-entered (indirect recursion)
|   msec is added only by the outermost entry, so recursion is not counted twice
| node, one per different call path (16 bytes):  [ parent<<32 + row | calls<<32 + msec ]
|   ids start at 1, parent 0 = the first node (boot). Exact time for every path.
| file mem/profile.mem:  cnt | cnt rows | nnodes | nnodes nodes | overflow count
|   (the first part is the same as the old format)
|
| the call stack (frames) lets profile_start know who is calling
|
| NOTE: every measured word uses more of the return stack (about 4 times for indirect
| recursion), so a program that recurses through 'word ex can overflow it sooner
| than the plain program (about 150 levels against about 500). Direct recursion is not affected.

^r3/lib/mem.r3

#profile_table 0
#profile_endp 0
#pcnt 0

#pstack 0		| frames, 32 bytes: [ row | start | node | previous current node ]
#psp 0
#povf 0			| starts ignored because the frame stack is full
#pcur 0			| node of the call in progress (0 = none)

#phash 0		| hash, 16 bytes: [ key | node id ]   key = (parent<<32 + row) + 1
#phashend 0
#pmask 0
#pnodes 0
#pmaxn 0		| node capacity
#pnn 0			| nodes in use
#pnf 0			| paths that did not fit

#pdelta 0
#pn 0

|------------------------------------------------ call tree
:nval | id -- adr ; address of [calls<<32 + msec] of the node
	1- 4 << pnodes + 8 + ;

:nodeof | parent row -- id/0 ; find or create the node of this path (0 = no room)
	swap 32 << or 1+						| key
	dup $9E3779B1 * 24 >> pmask and 4 << phash + >a
	pmask 1+
	( 1? 1-								| key n
		a@ pick2 =? ( 3drop a> 8 + @ ; )
		0? ( 2drop						| key
			pnn pmaxn >=? ( 2drop 1 'pnf +! 0 ; ) drop
			dup a!
			1 'pnn +! pnn dup a> 8 + !	| key id
			dup 1- 4 << pnodes +		| key id adr
			pick2 1- swap !				| node = [parent<<32 + row]
			nip ; )
		drop
		a> 16 + phashend =? ( drop phash ) >a
		) 2drop 0 ;

|------------------------------------------------ start / end
:pstart | row --
	psp 8192 >=? ( 2drop 1 'povf +! ; ) drop
	dup 4 << profile_table + >a
	a@ dup $ffff and 1? ( swap $100000000 or swap ) drop 1+ a!
	$100000000 a> 8 + +!
	pcur over nodeof						| row node
	psp 5 << pstack + >b
	swap b!+ msec b!+						| node
	dup b!+ pcur b!+
	1? ( dup nval $100000000 swap +! 'pcur ! 1 'psp +! ; )
	drop 1 'psp +! ;

:pend | row --
	povf 1? ( drop -1 'povf +! drop ; ) drop
	psp 1- dup 'psp ! 5 << pstack + >b
	b@+ drop b@+ msec swap - 'pdelta !	| row
	b@+ 'pn ! b@ 'pcur !
	pn 1? ( dup nval pdelta swap +! ) drop
	dup 4 << profile_table + >a
	a@ 1- dup a! $ffff and 0? ( pdelta a> 8 + +! ) drop
	drop ;

::profile_start | n --
	ab[ pstart ]ba ;

::profile_end | n --
	ab[ pend ]ba ;

|------------------------------------------------ memory and save
::profile_mem | cntw --
	here >a
	dup 'pcnt ! dup a!+
	a> 'profile_table !
	( 1? 0 a!+ 0 a!+ 1- ) drop
	a> dup 'profile_endp !
	dup 'pstack ! 8192 5 << + >a			| frames (no need to clear)
	pcnt 7 << 2048 max 32768 min
	2048 ( over <? 1 << ) nip 'pmaxn !		| node capacity: power of 2
	a> 'phash !
	pmaxn 1 << dup 1- 'pmask !
	( 1? 0 a!+ 0 a!+ 1- ) drop				| clear the hash
	a> 'phashend !
	a> 'pnodes !
	pmaxn ( 1? 0 a!+ 0 a!+ 1- ) drop		| clear the nodes
	a> 'here !
	0 'psp ! 0 'povf ! 0 'pnn ! 0 'pnf ! 0 'pcur ! ;

::profile_save | --
	here >a
	profile_table 8 - >b
	pcnt 1 << 1+ ( 1? 1- b@+ a!+ ) drop		| cnt and rows
	pnn a!+
	pnodes >b
	pnn ( 1? 1- b@+ a!+ b@+ a!+ ) drop		| nodes
	povf pnf + a!+
	here a> here - "mem/profile.mem" save ;
