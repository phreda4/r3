| metalib usage
| PHREDA 2023
^r3/d4/meta/metalibs.r3

|--------------
#pad * 1024
#pad> 'pad
#pad>	| cursor
#padf>	| fin

:lins  | c -- ;
	padf> 'pad - 1023 >? ( 2drop ; ) drop
	pad> dup 1 - padf> over - 1 + cmove> 1 'padf> +!
:lover | c -- ;
	pad> c!+ dup 'pad> !
	padf> >? (
		dup 'pad - 1023 >? ( swap 1 - swap -1 'pad> +! ) drop
		dup 'padf> ! ) drop
:0lin 0 padf> c! ;
:kdel pad> padf> >=? ( drop ; ) drop 1 'pad> +! | --;
:kback pad> 'pad <=? ( drop ; ) dup 1 - swap padf> over - 1 + cmove -1 'padf> +! -1 'pad> +! ;
:kder pad> padf> <? ( 1 + ) 'pad> ! ;
:kizq pad> 'pad >? ( 1 - ) 'pad> ! ;	

#modo 'lins

:inipad
	'pad ( c@+ 1? drop ) drop 1 -
	dup 'pad> ! 'padf> !
	'lins 'modo ! ;
	
|--------------
:char
	$1000 and? ( drop ; ) | downkey
	$4d =? ( kder ) 
	$4b =? ( kizq )
	$47 =? ( 'pad 'pad> ! ) 
	$4f =? ( padf> 'pad> ! )
	16 >> 0? ( drop ; )
	31 <? ( drop ; )
	modo ex ;



:vscreen
	1 10 .at ">" .write 'pad .write 
	2 pad> 'pad - + 10 .at ;

:padinput
	inipad
	( vscreen ( inkey 0? drop ) 
		$D001C <>? | enter
		char ) drop ;
		
|--------------
:.viewords | adr --
	( dup c@ 1? drop 
		dup .write .sp
		>>0 ) 2drop ;
		
|#r3_win_urlmon.r3 'name 'words 'calls 'info
:viewlibs
	'liblist ( @+ 1?
		@+ .println
		@+ .viewords
		drop
		) 2drop ;
		
:main
	.cls
	"test" .println
	|viewlibs
	padinput
	;
	
: main ;