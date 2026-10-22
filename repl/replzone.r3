| replzone - zones of the project text (defs): the units that are edited as a whole
| zone kinds: 1 code (: ::)  2 data (# ##)  3 comments (| in the first column, contiguous)  4 other text
| a new zone starts at : # | in the first column, or at text in the first column that follows another kind of zone
| a blank line ends it, except when indented text follows ; indented lines continue the zone
| z.build scans defs (linear): call it before using the zones, the text may have changed
^repl/replcore.r3

##zmax 2048
##zn 0				| zones found by z.build
#zt * 65536			| 32 bytes each: off len hash kind|nl<<8|line<<24
#zi -1 #zline 0
#zname * 256

:zr | i -- 'rec
	5 << 'zt + ;

::z.off | i -- n
	zr @ ;
::z.len | i -- n ; bytes, up to the end of its last line
	zr 8 + @ ;
::z.hash | i -- h
	zr 16 + @ ;
::z.kind | i -- k
	zr 24 + c@ $ff and ;
::z.nl | i -- n ; lines
	zr 24 + @ 8 >> $ffff and ;
::z.line | i -- n ; first line (0 = first line of defs)
	zr 24 + @ 24 >> $ffff and ;
::z.adr | i -- adr
	z.off defs + ;

|---------------- scan
:sp? | c -- 0/1 ; space or tab
	32 =? ( drop 1 ; ) 9 =? ( drop 1 ; ) drop 0 ;

:z.first | adr -- c ; first char that is not a space or a tab
	( dup c@ $ff and sp? 1? drop 1+ ) drop c@ $ff and ;

:z.blank? | adr -- 0/1
	z.first 0? ( drop 1 ; ) 13 =? ( drop 1 ; ) 10 =? ( drop 1 ; ) drop 0 ;

:mk? | c -- 0/1 ; : or #
	$3a =? ( drop 1 ; ) $23 =? ( drop 1 ; ) drop 0 ;

:z.nm | adr -- adr' ; after the marks of a definition
	( dup c@ $ff and mk? 1? drop 1+ ) drop ;

::z.hashstr | "name" -- h
	z.nm 0 swap ( dup c@ $ff and 32 >? drop c@+ $ff and rot 31 * + swap ) 2drop $ffffffff and ;

:z.h | kind adr -- h
	swap 3 <? ( drop z.hashstr ; ) 2drop 0 ;

:z.open | kind adr -- ; a zone starts at adr
	zn zmax >=? ( 3drop -1 'zi ! ; ) drop
	zn 'zi ! 1 'zn +!
	zi zr >a
	dup defs - a!+
	0 a!+
	2dup z.h a!+
	over zline 24 << or a!+
	2drop ;

:z.ext | end -- ; the current zone reaches end (start of the next line) and has one line more
	zi -? ( 2drop ; ) drop
	defs - zi zr @ - zi zr 8 + !
	zi zr 24 + dup @ 256 + swap ! ;

:z.take | adr -- adr' ; the line goes to the current zone
	nextl dup z.ext ;

:zk | -- kind ; of the current zone (0 none)
	zi -? ( drop 0 ; ) zr 24 + c@ $ff and ;

:z.cont? | adr -- 0/1 ; after the blank lines there is indented text
	( dup c@ $ff and 1? drop dup z.blank? 1? drop nextl ) drop
	c@ $ff and sp? ;

:z.gap | adr -- adr' ; blank line
	dup z.cont? 0? ( drop -1 'zi ! nextl ; ) drop
	zk 0? ( drop -1 'zi ! nextl ; ) 3 =? ( drop -1 'zi ! nextl ; ) drop
	z.take ;

:z.line1 | adr -- adr'
	dup z.blank? 1? ( drop z.gap ; ) drop
	dup c@ $ff and
	$3a =? ( drop 1 over z.open z.take ; )
	$23 =? ( drop 2 over z.open z.take ; )
	$7c =? ( drop zk 3 <>? ( drop 3 over z.open 0 ) drop z.take ; )
	drop dup c@ $ff and sp? 1? ( drop zk 0? ( drop 4 over z.open 0 ) 3 =? ( drop 4 over z.open 0 ) drop z.take ; ) drop
	zk 4 <>? ( drop 4 over z.open 0 ) drop z.take ;

::z.build | --
	0 'zn ! -1 'zi ! 0 'zline !
	defs ( dup c@ $ff and 1? drop z.line1 1 'zline +! ) 2drop ;

|---------------- names
::z.name | i -- 'str ; the name of a code or data zone, the beginning of the first line for the others
	dup z.kind 3 <? ( drop z.adr lcopy 'lo2 60 + 0 swap c! 'zname 'lo2 z.nm copynom 'zname ; ) drop
	z.adr lcopy 'lo2 60 + 0 swap c! 'lo2 'zname strcpy 'zname ;

::z.find | "name" -- i ; the last code or data zone with that name (-1 none)
	z.hashstr zn
	( 1? 1-
		dup z.kind 3 <? ( drop dup z.hash pick2 =? ( drop nip ; ) ) drop
		) 2drop -1 ;

|---------------- editing the text
::defs-recount | -- ; defl = lines of defs
	0 defs ( c@+ $ff and 1? 10 =? ( rot 1+ -rot ) drop ) 2drop 'defl ! ;

:,mem | adr n -- ; n bytes to here
	dup >r here -rot cmove r> 'here +! ;

#sf 0 #sn 0 #sa 0 #sc 0 #sT 0
::z.splice | off n adr cnt -- ok ; the n bytes at off become the cnt bytes at adr (lines with CR LF)
	'sc ! 'sa ! 'sn ! 'sf !
	defs> defs - sn - sc + $1e000 >=? ( drop 0 ; ) drop
	mark here 'sT !
	defs sf + sn + defs> over - ,mem
	defs sf + sa sc cmove
	defs sf + sc + sT defs> defs sf + sn + - cmove
	defs> sc + sn - 'defs> ! 0 defs> c!
	defs-recount 1 'mdirty !
	empty 1 ;

#zpend 0 #zany 0
:z.emit | adr -- ; a line of the text (the blank lines before it, if it is not the first one)
	zany 1? ( drop zpend ( 1? 1- ,nl ) ) drop
	0 'zpend ! 1 'zany !
	lcopy 'lo2 ,s ,nl ;

:z.lines | "text" -- ; the text to here as CR LF lines, without blank lines at the beginning or at the end
	0 'zpend ! 0 'zany !
	( dup c@ $ff and 1? drop
		dup z.blank? 1? ( 1 'zpend +! ) 0? ( over z.emit ) drop nextl ) 2drop ;

::z.replace | i "text" -- ok ; zone i is replaced by the text
	mark
	here swap z.lines
	swap dup z.off swap z.len
	rot dup here swap -
	z.splice
	empty ;

:z.endoff | i -- off ; where the zone and the blank lines after it end
	1+ zn <? ( z.off ; ) drop defs> defs - ;

::z.delete | i -- ok ; the zone and the blank lines after it
	dup z.off swap z.endoff over - defs 0 z.splice ;

::z.norm | -- ok ; a blank line after each zone, no other blank lines between zones
	z.build
	mark here
	0 ( zn <? dup z.adr over z.len ,mem ,nl 1+ ) drop
	here over - $1e000 >=? ( 2drop empty 0 ; ) drop
	dup here swap - defs + 'defs> !
	defs swap dup here swap - cmove
	0 defs> c!
	defs-recount 1 'mdirty !
	empty 1 ;
