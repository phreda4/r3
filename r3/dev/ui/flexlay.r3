| r3d4 sdl debbuger
| PHREDA 2024
|
^r3/lib/sdl2gfx.r3
^r3/util/txfont.r3

|--- Layout
##fx ##fy ##fw ##fh 
#flFsize 18

::flin? | x y -- 0/-1
	fy - $ffff and fh >? ( 2drop 0 ; ) drop | limit 0--$ffff
	fx - $ffff and fw >? ( drop 0 ; ) drop
	-1 ;

#flstack * 64 | 8 niveles
#flstack> 'flstack

:xywh>fl | x y w h -- v
	$ffff and 16 <<
	swap $ffff and or 16 <<
	swap $ffff and or 16 <<
	swap $ffff and or ; | hhwwyyxx
	
|:fl>xywh | v -- x y w h 
|	dup $ffff and swap
|	dup 16 >> $ffff and swap
|	dup 32 >> $ffff and swap
|	48 >> $ffff and ;
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
	0 0 sw sh flx! ;
	
:flx+! flstack> 8 - dup w@ rot + clamp0 swap w! ;
:fly+! flstack> 8 - 2 + dup w@ rot + clamp0 swap w! ;
:flw+! flstack> 8 - 4 + dup w@ rot + clamp0 swap w! ;
:flh+! flstack> 8 - 6 + dup w@ rot + clamp0 swap w! ;
	
::flxpush	
	fh fw fy fx flstack> w!+ w!+ w!+ w!+ 'flstack> ! ;
::flxpop	
	-8 'flstack> +! flstack> fl>now ;
::flxFill 
	flstack> 8 - fl>now ;

| N=^ S=v E=> O=<
| - is full minus the number
::flxN | lineas --
	-? ( fh + )
	flxFill dup fly+! dup neg flh+!	'fh ! ;
::flxS | lineas --
	-? ( fh + )
	flxFill dup neg flh+! fh fy + over - 'fy ! 'fh ! ;
::flxE | cols --
	-? ( fw + )
	flxFill dup neg flw+! fw fx + over - 'fx ! 'fw ! ;
::flxO | cols --
	-? ( fw + )
	flxFill dup flx+! dup neg flw+! 'fw ! ;
	
::fw% fw 16 *>> ;
::fh% fh 16 *>> ;

::flpad | x y --
	dup 'fy +! 2* neg 'fh +!
	dup 'fx +! 2* neg 'fw +! ;
	
|::flcr	.cr fx .col ;

::flFontSize
	;
	
::flrfill
	8 fx 8 + fy 8 + fw 16 - fh 16 - SDLFRound 
	fx 10 + fy 10 + txat
	fy fx "x:%d y:%d" txprint
	fx 10 + fy 26 + txat
	fh fw "w:%d h:%d" txprint
	;
	
|--------------------------------	
#font1

|-----------------------------
:main
	0 SDLcls
	font1 txfont

	flx
|	10 10 txat "Flex layout" txprint

$7f00 sdlcolor
	5 32 * flxN 
		flrfill

$3f00 sdlcolor	
	3 32 * flxN 
		flrfill	
		
$7f0000 sdlcolor		
	8 32 * flxS 
		flrfill
$3f0000 sdlcolor				
	4 32 * flxO 
		flrfill
		
$7f sdlcolor				
	8 32 * flxE 
		flxpush
		4 32 * flxN 	
			flrfill
$3f sdlcolor							
		flxfill 
			flrfill	
		flxpop
	flxFill
$7f7f sdlcolor					
	flrfill	

	SDLredraw
	sdlkey
	>esc< =? ( exit )
	drop
	;
	
|-----------------------------
|-----------------------------	
:	
	|"R3d4" 0 SDLfullw | full windows | 
	"R3d4" 1280 720 SDLinitR
	
	"media/ttf/Roboto-bold.ttf" 16 txloadwicon 'font1 !
 	20 flFontSize
	
	'main SDLshow
	SDLquit 
	;
