| r3 code analyzer
| PHREDA 2019
|------------------
^./r3base.r3
^./r3pass1.r3
^./r3pass2.r3
^./r3pass3.r3
^./r3pass4.r3
^./r3gencod.r3
^./r3gendat.r3

::r3c | str --
	r3name
	here dup 'src !
	'r3filename

	2dup load | "fn" mem
	here =? ( "no src" .print ; )
	0 swap c!+ 'here !
	0 'error !
	0 'cnttokens !
	0 'cntdef !
	'inc 'inc> !

	swap
	r3-stage-1
	error 1? ( "ERROR %s" .print ; ) drop
	r3-stage-2
	1? ( "ERROR %s" .print ; ) drop
	r3-stage-3
	r3-stage-4
	;

|------------------------------------------------
#filenow
#defnow
#defpnow
#wordnow
#wordpnow

#iniword
#cntword

#cntlines

:header
	"r3Code " .print
	filenow 3 << 'inc + @
	" %l " .print
    mark
    defnow ,wordinfo ,eol
    empty
    here .print
	cr
	;

:wcursor
	defnow =? ( ">" .print ; )
	" " .print ;

:wordline | nro --
	wcursor
	4 << dicc +
	@+ "%w " .print
	drop
	cr
	;

:pagdef
	0 max
	cntdef 1 - min
	defpnow <? ( dup 'defpnow ! )
	defpnow cntlines 1 - + >? ( dup cntlines 1 - - 'defpnow ! )
	dup 4 << dicc + 4 +
	@+ 'iniword !
	4 + @ 12 >>> 'cntword !
	'defnow !
	0 'wordpnow !
	;

:wcursor
	wordnow =? ( $ffffff 'ink ! ">" emits ; )
	" " emits
	;
:insline | nro --
	cntword >=? ( drop ; )
	wcursor
	2 << iniword + @
	tokenprint
	;

:infoline | nro --
	cntword >=? ( drop ; )
	drop
	"|" .print
	;

:paglin
	0 max
	cntword 1 - min
	wordpnow <? ( dup 'wordpnow ! )
	wordpnow cntlines 1 - + >? ( dup cntlines 1 - - 'wordpnow ! )

	'wordnow !
	;

:keyboard
	key
	<le> =? ( defnow 1 - pagdef )
	<ri> =? ( defnow 1 + pagdef )

	<up> =? ( wordnow 1 - paglin )
	<dn> =? ( wordnow 1 + paglin )

	>esc< =? ( exit )
	drop
	;

:browser
	cls home
	header
	0 ( cntlines <?
		dup defpnow + wordline
		1 + ) drop
	0 ( cntlines <?
		14 over 1 + gotoxy
		dup wordpnow + insline
		1 + ) drop
	0 ( cntlines <?
		28 over 1 + gotoxy
		dup wordpnow + infoline
		1 + ) drop
	keyboard
	;

:r3code
	inc> 'inc - 3 >> 1 - 'filenow !
	cntdef 1 - pagdef
	'browser onshow
	;

: 	fonti
	rows 2 - 'cntlines !

	"r3/test.r3"
|	"r3/testgui.r3"
	r3c

    r3code
	;

