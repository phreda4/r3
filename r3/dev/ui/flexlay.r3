| gui v.3
| 
| PHREDA 2025
|
^r3/lib/sdl2gfx.r3
^r3/util/txfont.r3

|--- Layout
#flFsize 18
#fx #fy #fw #fh 
#flpadx 0 #flpady 0
#flcols 1 #flrows 1 #flcur 0
#flcolm	1 #flrowm 1
##cx ##cy ##cw ##ch | cursor

:f2c
	flpadx fw over 2* - 'cw ! fx + 'cx !
	flpady fh over 2* - 'ch ! fy + 'cy !
	;

::unIn? | x y -- 0/-1
	cy - $ffff and ch >? ( 2drop 0 ; ) drop | limit 0--$ffff
	cx - $ffff and cw >? ( drop 0 ; ) drop
	-1 ;

::uiw% fw 16 *>> ;
::uih% fh 16 *>> ;

::uiPading | x y --
	'flpady ! 'flpadx ! ;
	
#flstack * 64 | 8 niveles
#flstack> 'flstack

:fl>now | v --
	w@+ 'fx ! w@+ 'fy ! w@+ 'fw ! w@ 'fh ! ;
	
::uiValid? | -- 0= not valid
	cw 1 <? ( drop 0 ; ) drop 
	ch 1 <? ( drop 0 ; ) drop 
	-1 ;

:xywh>fl | x y w h -- v
	$ffff and 16 <<
	swap $ffff and or 16 <<
	swap $ffff and or 16 <<
	swap $ffff and or ; | hhwwyyxx
	
::uiBox | x y w h --
	2over 'fy ! 'fx ! 2dup 'fh ! 'fw ! 
	xywh>fl 'flstack !+ 'flstack> ! 
	f2c ;
	
::uiFull | --
	0 0 sw sh uiBox ;
	
:flx+! flstack> 8 - dup w@ rot + clamp0 swap w! ;
:fly+! flstack> 8 - 2 + dup w@ rot + clamp0 swap w! ;
:flw+! flstack> 8 - 4 + dup w@ rot + clamp0 swap w! ;
:flh+! flstack> 8 - 6 + dup w@ rot + clamp0 swap w! ;
	
::uiPush	fh fw fy fx flstack> w!+ w!+ w!+ w!+ 'flstack> ! ;
::uiPop		-8 'flstack> +! flstack> fl>now f2c ;
:uiGet		flstack> 8 - fl>now ;
::uiRest	uiGet f2c ;

| N=^ S=v E=> O=<
| - is full minus the number
::uiN | lineas --
	-? ( fh + ) uiGet dup fly+! dup neg flh+!	'fh ! f2c ;
::uiS | lineas --
	-? ( fh + ) uiGet dup neg flh+! fh fy + over - 'fy ! 'fh ! f2c ;
::uiE | cols --
	-? ( fw + ) uiGet dup neg flw+! fw fx + over - 'fx ! 'fw ! f2c ;
::uiO | cols --
	-? ( fw + ) uiGet dup flx+! dup neg flw+! 'fw ! f2c ;
	
::uiAt | x y --
	flrowm dup flpady 2* - 'ch !
	* fy + flpady + 'cy !
	flcolm dup flpadx 2* - 'cw !
	* fx + flpadx + 'cx ! ;
	
::uiTo | w h -- 
	flrowm * flpady 2* - 'ch !
	flcolm * flpadx 2* - 'cw ! ;

::uiGrid | c r -- ; adjust for fit
	2dup 'flrows ! 'flcols ! 0 'flcur !
	fh swap /mod dup 2/ 'fy +! neg 'fh +! 'flrowm !
	fw swap /mod dup 2/ 'fx +! neg 'fw +! 'flcolm !
	0 0 uiAt ;
	
::uiNext	
::uiNextV
	flcur 1+ 
	flrows flcols * >? ( 0 nip )
	dup 'flcur !
	flcols /mod swap uiAt ;
::uiNextH
	flcur 1+
	flrows flcols * >? ( 0 nip )
	dup 'flcur !
	flcols /mod uiAt ;
|------------------------------
	
|::flcr	.cr fx .col ;

::flFontSize
	;
	
|---- draw

::uiText | "" align --
	txalign >r cw ch cx cy r> txText ;	
	
|---- widget	
|--------------------------------	
::uifill
	8 cx cy cw ch SDLFRound 

	ch cw cy cx "x:%d y:%d;w:%d h:%d"
	sprint $11 uiText
	;
	

#font1
#ali

:tt
"Texto muy largo
y con varias lineas
para ver como se comporta
cuando cambia de tamanio"
	ali uiText	
	;

:grillain
	4 1 uiGrid
	"1" $11 uiText
	8 cx cy cw ch SDLRound 
	uiNext
	"2" $11 uiText
	8 cx cy cw ch SDLRound 
	uiNext
	"3" $11 uiText
	8 cx cy cw ch SDLRound 
	uiNext
	"4" $11 uiText
	8 cx cy cw ch SDLRound 
	tt
	;

	
|-----------------------------
:main
	0 SDLcls
	font1 txfont

	4 4 uiPading
	uiFull

$7f00 sdlcolor
	2 32 * uiN 
		uifill

$3f00 sdlcolor	
	3 32 * uiN 
		uifill
		
$7f0000 sdlcolor		
	3 32 * uiS 
		uifill
$3f0000 sdlcolor				
	4 32 * uiO 
		uifill
		
$7f sdlcolor				
	8 32 * uiE 
		uiPush
		4 32 * uiN 	
			uifill
$3f sdlcolor							
		uiRest
			uifill
		uiPop
	uifill
	
$7f7f sdlcolor					
	uiRest
	
	grillain


	SDLredraw
	sdlkey
	>esc< =? ( exit )
	<f1> =? ( ali $1 + $33 and 'ali ! )
	<f2> =? ( ali $10 + $33 and 'ali ! )
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
