| flex layout example
| PHREDA 2025

^./tui.r3

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
	
:fl>now | v --
	dup $ffff and 'fx !
	dup 16 >> $ffff and 'fy !
	dup 32 >> $ffff and 'fw !
	48 >> $ffff and 'fh ! ;
	
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
	
|::flx@ | -- x y w h
|	flstack> 8 - @ fl>xywh ;

:flx+! flstack> 8 - dup @ $ffff and rot + $ffff and 
	swap dup @ $ffff nand rot or swap ! ;
:fly+! flstack> 8 - dup @ 16 >> $ffff and rot + $ffff and 16 <<
	swap dup @ $ffff0000 nand rot or swap ! ;
:flw+! flstack> 8 - dup @ 32 >> $ffff and rot + $ffff and 32 <<
	swap dup @ $ffff00000000 nand rot or swap ! ;
:flh+! flstack> 8 - dup @ 48 >> $ffff and rot + $ffff and 48 <<
	swap dup @ $ffffffffffff and rot or swap ! ;

::flxpush	
	fx fy fw fh xywh>fl flstack> !+ 'flstack> ! ;
::flxpop	
	-8 'flstack> +! flstack> @ fl>now ;
::flxFill 
	flstack> 8 - @ fl>now ;

| N=^ S=v E=> O=<
::flxN | lineas --
	flxFill
	dup fly+! 
	dup neg flh+!
	'fh ! ;
	
::flxS | lineas --
	flxFill
	dup neg flh+!
	fh fy + over - 'fy ! 
	'fh ! ;

::flxE | cols --
	flxFill
	dup neg flw+!
	fw fx + over - 'fx !
	'fw ! ;
	
::flxO | cols --
	flxFill
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
|	flxvalid? 0? ( drop ; ) drop
	fx fy fw fh .boxd ;
:uiboxl	
|	flxvalid? 0? ( drop ; ) drop
	fx fy fw fh .boxl ;
	
|--------------------------------	
:main
	tui flx | full screen
	.reset .cls
	|fx fy fw fh .boxl | full screen
	5 flxN uiboxd
	
	3 flxN uiboxl	
	8 flxS uiboxd
	0.3 fw% flxO uiboxd
	
	
	28 flxE 
		flxpush
		4 flxN 	uiboxd
		flxfill uiboxl	
		flxpop
	flxFill
	uiboxl	
	;
	
|-----------------------------------
: 
	.term |.tuistart
	'main onTui 
	.free 
;
