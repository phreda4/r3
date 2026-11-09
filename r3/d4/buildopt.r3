| buildopt - options of the build, shared by r3build (edits and saves) and r3plain (reads)
| file mem/build.mem = 4 qwords: target inline budget unroll
| PHREDA 2026
|
| usage: set the defaults in the bo.* variables, call bo.load, then read them back
|        ( fields that are not in the file keep the value they had )

|---- options (keep together: saved as 4 qwords)
##bo.target 0		| 0 WIN, 1 LIN, 2 MAC, 3 RPI (osgen)
##bo.inline 7		| max tokens of a word to inline (0 = no inline)
##bo.budget 2		| growth allowed when inlining a word with several calls (x inline)
##bo.unroll 0		| 1 = unroll format strings of ,print / sprint

#bo.buf * 64

::bo.save | --
	'bo.target 32 "mem/build.mem" save ;

::bo.load | --
	'bo.buf "mem/build.mem" load 'bo.buf -
	16 <? ( drop ; )
	'bo.buf @ $3 and 'bo.target !
	'bo.buf 8 + @ 0 max 99 min 'bo.inline !
	32 <? ( drop ; ) drop
	'bo.buf 16 + @ 1 max 16 min 'bo.budget !
	'bo.buf 24 + @ 1 and 'bo.unroll ! ;
