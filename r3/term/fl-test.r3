| flex layout example
| PHREDA 2025

^r3/util/tui.r3

##fx ##fy ##fw ##fh 

::flin? | x y -- 0/-1
	fy - $ffff and fh >? ( 2drop 0 ; ) drop | limit 0--$ffff
	fx - $ffff and fw >? ( drop 0 ; ) drop
	-1 ;

#flstack * 80 | 10 niveles
#flstack> 'flstack

:xywh>fl | x y w h -- v
	$ffff and 16 <<
	swap $ffff and or 16 <<
	swap $ffff and or 16 <<
	swap $ffff and or ; | hhwwyyxx
	
:fl>xywh | v -- x y w h 
	dup $ffff and swap
	dup 16 >> $ffff and swap
	dup 32 >> $ffff and swap
	48 >> $ffff and ;

|::flx@ | -- x y w h
|	flstack> 8 - @ fl>xywh ;
	
:fl>now | v --
	w@+ 'fx ! w@+ 'fy ! w@+ 'fw ! w@ 'fh ! ;
	
::flxvalid? | -- 0= not valid
	fw 1 <? ( drop 0 ; ) drop 
	fh 1 <? ( drop 0 ; ) drop 
	-1 ;
	
::flx! | x y w h --
	2over 'fy ! 'fx !
	2dup 'fh ! 'fw ! 
	xywh>fl 'flstack !+ 'flstack> ! ;
	
::flx | --
	1 1 cols rows flx! ;
	

:flx+! flstack> 8 - dup w@ rot + clamp0 swap w! ;
:fly+! flstack> 8 - 2 + dup w@ rot + clamp0 swap w! ;
:flw+! flstack> 8 - 4 + dup w@ rot + clamp0 swap w! ;
:flh+! flstack> 8 - 6 + dup w@ rot + clamp0 swap w! ;

::flxpush	
	fx fy fw fh xywh>fl flstack> !+ 'flstack> ! ;
::flxpop	
	-8 'flstack> +! flstack> fl>now ;
::flxRest 
	flstack> 8 - fl>now ;

| N=^ S=v E=> O=<
::flxN | lineas --
	flxRest
	dup fly+! 
	dup neg flh+!
	'fh ! ;
	
::flxS | lineas --
	flxRest
	dup neg flh+!
	fh fy + over - 'fy ! 
	'fh ! ;

::flxE | cols --
	flxRest
	dup neg flw+!
	fw fx + over - 'fx !
	'fw ! ;
	
::flxO | cols --
	flxRest
	dup flx+!
	dup neg flw+! 
	'fw ! ;
	
::fw% fw 16 *>> ;
::fh% fh 16 *>> ;

::flpad | x y --
	dup 'fy +! 2* neg 'fh +!
	dup 'fx +! 2* neg 'fw +! ;
	


|--------------------------		

:uiboxd
	fx fy fw fh .boxd ;
:uiboxl	
	fx fy fw fh .boxl ;
	
|--------------------------------	
:main
	flx | full screen
	.reset .cls
	|fx fy fw fh .boxl | full screen
	5 flxN uiboxd
	
	|.termsize fx fy .at inkey "%h" .print
	fx 1+ fy 1+ .at
	rows cols "c:%d r:%d" .print .cr
	
	3 flxN uiboxl	
	8 flxS uiboxd
	0.3 fw% flxO uiboxd
	
	
	28 flxE 
		flxpush
		4 flxN 	uiboxd
		flxRest uiboxl	
		flxpop
	flxRest
	uiboxl	
	
	;
	
|-----------------------------------
: 
	'main onTui 
	.free 
;
