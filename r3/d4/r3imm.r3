| edit-code
| PHREDA 2007
|---------------------------------------
^r3/win/console.r3
^r3/lib/mconsole.r3
^r3/lib/math.r3
^r3/lib/mem.r3
^r3/lib/parse.r3

^r3/d4/r3edit.r3
^r3/d4/r3token.r3


|--------------- MAIN IMMEDIATE
| input line
#padh * 8192
#padh> 'padh
|#pad * 256

#cmax 1000
#padi>	| inicio
#padf>	| fin
#pad>	| cursor

:lins  | c -- ;
	padf> padi> - cmax >=? ( 2drop ; ) drop
	pad> dup 1 - padf> over - 1 + cmove> 1 'padf> +!
:lover | c -- ;
	pad> c!+ dup 'pad> !
	padf> >? (
		dup padi> - cmax >=? ( swap 1 - swap -1 'pad> +! ) drop
		dup 'padf> ! ) drop
:0lin 0 padf> c! ;

:kdel pad> padf> >=? ( drop ; ) drop 1 'pad> +! | --;
:kback pad> padi> <=? ( drop ; ) dup 1 - swap padf> over - 1 + cmove -1 'padf> +! -1 'pad> +! ;

:kder pad> padf> <? ( 1 + ) 'pad> ! ;
:kizq pad> padi> >? ( 1 - ) 'pad> ! ;

:kup
	pad> ( padi> >?
		1 - dup c@ $ff and 32 <? ( drop 'pad> ! ; )
		drop ) 'pad> ! ;
:kdn
	pad> ( c@+ 1?
		$ff and 32 <? ( drop 'pad> ! ; )
		drop ) drop 1 - 'pad> ! ;

#modop 'lins

::,immline
	padi> pad> over - ,type
	"s" ,[ | save cursor position
	pad> padf> over - ,type
	,eline
	"u" ,[ | restore cursor	
	;
	
:vchar | char --  ; visible char
	16 >> $ff and
	8 =? ( drop kback ; )
	9 =? ( modop ex ; )
|	13 =? ( modop ex ; )
	32 <? ( drop ; )
	modop ex ;
	
::immevkey | key -- key
	$ff0000 and? ( dup vchar ; ) 
	$ff and	
	$53 =? ( kdel )
|	$48 =? ( karriba ) $50 =? ( kabajo )
	$4d =? ( kder ) $4b =? ( kizq )
	$47 =? ( padi> 'pad> ! ) $4f =? ( padf> 'pad> ! )
|	$49 =? ( kpgup ) $51 =? ( kpgdn )
	
	$52 =? ( modop | ins
			'lins =? ( drop 'lover 'modop ! .ovec ; )
			drop 'lins 'modop ! .insc )	
	;

::immclear
	padi> dup 'padf> ! dup 'pad> ! 0 swap c! ;

::immset | buffer --
	dup 'padi> ! 
	immclear
	'lins 'modop !
	;
	

