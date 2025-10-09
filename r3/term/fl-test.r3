| TUI Example
| PHREDA 2025

^./tui.r3

##fx ##fy ##fw ##fh 

#flstack * 40 | 5 niveles
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
	
::flxvalid? | -- 0=not ok
	fx fy and fw and fh and ;
	
::flx! | x y w h --
	2over 'fy ! 'fx !
	2dup 'fh ! 'fw ! 
	xywh>fl 'flstack !+ 'flstack> ! ;
	
::flx | --
	1 1 cols rows flx! ;
	
::flx@ | -- x y w h
	flstack> 8 - @ fl>xywh ;

:flx+! flstack> 8 - dup @ $ffff and rot + $ffff and 
	swap dup @ $ffff nand rot or swap ! ;
:fly+! flstack> 8 - dup @ 16 >> $ffff and rot + $ffff and 16 <<
	swap dup @ $ffff0000 nand rot or swap ! ;
:flw+! flstack> 8 - dup @ 32 >> $ffff and rot + $ffff and 32 <<
	swap dup @ $ffff00000000 nand rot or swap ! ;
:flh+! flstack> 8 - dup @ 48 >> $ffff and rot + $ffff and 48 <<
	swap dup @ $ffffffffffff and rot or swap ! ;

::flxpush fx fy fw fh xywh>fl flstack> !+ 'flstack> ! ;
::flxpop	-8 'flstack> +! flstack> @ fl>now ;

::flxFill flstack> 8 - @ fl>now ;

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
	
|--------------------------	
	
:uiText | align "" --
	2drop ;

|--------------------------------	
:main
	tui	flx | full screen
	.reset .cls
	|fx fy fw fh .boxl | full screen
	5 flxN
	fx fy fw fh .boxd
	3 flxN
	fx fy fw fh .boxl
	8 flxS
	fx fy fw fh .boxd
	10 flxO
	fx fy fw fh .boxd
	34 flxE
	flxpush
		4 flxN
		fx fy fw fh .boxd
		flxfill
		fx fy fw fh .boxl
	flxpop
	flxFill
	fx fy fw fh .boxl
	fx 1+ fy 1+ .at
	fx fy fw fh "%d %d %d %d" .print
	;
	
|-----------------------------------
: 
	.term |.tuistart
	'main onTui 
	.free 
;
