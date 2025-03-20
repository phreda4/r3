| arena MAP
| PHREDA 2024
|-------------------------
^r3/lib/rand.r3
^r3/lib/sdl2gfx.r3

^r3/util/varanim.r3
^r3/util/ttext.r3

^./arena-edit.r3

|---------------------
| SCRIPT
##sstate

##script
##script>

##term * 8192
##term> 'term 

::teclr	'term 'term> ! ;
::,te 	term> c!+ 'term> ! ;
	
|----
#speed 

:dighex | c --  dig / -1 | :;<=>?@ ... Z[\]^_' ... 3456789
	$3A <? ( $30 - ; ) tolow $57 - ;

:copysrc | copy to edit
	>>cr 2 +
	fuente >a
	( c@+ $25 <>?
		|10 <>? ( dup ca!+ ) drop
		ca!+
		) drop
	0 ca!+
	edset
	>>cr ;
	
:incode
|	'xedit 16 -500 26 0.5 0.0 +vanim
	;
	
:outcode
|	'xedit -500 16 25 0.5 0.0 +vanim
	;
	
:inmap
|	'viewpz 2.0 0.0 26 0.5 0.0 +vanim 
|	'viewpx 
|	SW viewpz mapw 16 * *. - 32 -
|	1400 26 0.5 0.0 +vanim 
	;
	
:outmap
|	'viewpz 0.0 2.0 25 0.5 0.0 +vanim 
|	'viewpx 1400 
|	SW viewpz mapw 16 * *. - 32 -
|	25 0.5 0.0 +vanim 
	;
	
:endless	
	outcode
	outmap
	'exit 2.0 +vexe
	;
	
#anilist 'incode 'outcode 'inmap 'outmap
	
:anima
	c@+ dighex
	$3 and 3 << 'anilist + @ ex
	>>cr
	;
	
:waitn	
	1 'sstate ! ;
	
:cntr | script -- 'script
	c@+
	0? ( drop 1- ; )
|	$25 =? ( ,te ; ) | %%
	$63 =? ( drop 12 ,te c@+ dighex ,te ; )	| %c1 color
	$2e =? ( drop teclr trim ; )	| %. clear
	$61 =? ( drop anima ; )			| %a1 animacion	
	$65 =? ( drop endless ; ) 		| %e end
	$69 =? ( drop 11 ,te ; )		| %i invert
	$73 =? ( drop copysrc trim ; ) 	| %s..%s source
	$77 =? ( drop >>sp waitn ; )	| %w1 espera
	
	,te
	;
	
:+t
	0? ( 2 'sstate ! 1- ) 
	$2c =? ( 0.3 'speed ! )	|,
	$2e =? ( 0.7 'speed ! ) |.
	$25 =? ( drop cntr ; )	|%
	10 =? ( 3 + )
	13 <? ( drop ; ) 
	,te 
	;
	
::addscript
	0.03 'speed !
	script> c@+ +t 'script> !
	
	sstate 1? ( drop ; ) drop
	'addscript speed +vexe
	;

::nextchapter
	0 'sstate ! teclr 
	script> trim 'script> !
	addscript 
	;
	
::completechapter
	( sstate 0? drop
		script> c@+ +t 'script> ! ) drop ;
