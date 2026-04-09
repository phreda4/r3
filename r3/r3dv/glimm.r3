| 
| PHREDA 2026

^r3/lib/sdl2gl.r3
^./glfixfont.r3
^./gllib.r3

#marx 4 #mary 4 | margin
#padx 9 #pady 2 | pad

|--------------------------------------------------------------
| LAYOUT
#fx #fy #fw #fh	| win layout

#flcols 1 #flrows 1 #flcur 0
#flcolm	1 #flrowm 1

#cx #cy #cw 0 #ch 0 | cursor

#flstack * 64 | 8 niveles
#flstack> 'flstack

::%cw fw 16 *>> ;
::%ch fh 16 *>> ;

:f2c
|	marx fw over 2* - 'wiw ! fx + 'wix !
|	mary fh over 2* - 'wih ! fy + 'wiy ! 
	marx 'cx ! 
	mary 'cy ! 
	fw marx 2* - 'cw ! 
	fh mary 2* - 'ch ! ;

:fl>now | v --
	w@+ 'fx ! w@+ 'fy ! w@+ 'fw ! w@ 'fh ! ;
	
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
	
::uiPush
	fh fw fy fx flstack> w!+ w!+ w!+ w!+ 'flstack> ! ;
::uiPop
	-8 'flstack> +! flstack> fl>now f2c ;

:uiGet
	flstack> 8 - fl>now ;
::uiFill
	uiGet f2c ;

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
	flrowm dup mary 2* - 'wih !
	* fy + mary + 'wiy !
	flcolm dup marx 2* - 'wiw !
	* fx + marx + 'wix ! ;
	
::uiTo | w h -- 
	flrowm * mary 2* - 'wih !
	flcolm * marx 2* - 'wiw ! ;

::uiGrid | c r -- ; adjust for fit
	2dup 'flrows ! 'flcols ! 0 'flcur !
	fh swap /mod dup 2/ 'fy +! neg 'fh +! 'flrowm !
	fw swap /mod dup 2/ 'fx +! neg 'fw +! 'flcolm !
	0 0 uiAt ;
	
::uiNext	
	flcur 1+ 
	flrows flcols * >? ( 0 nip )
	dup 'flcur !
	flcols /mod swap uiAt ;
	
::uiNextV
	flcur 1+
	flrows flcols * >? ( 0 nip )
	dup 'flcur !
	flcols /mod uiAt ;

|--------------------------------------------------
::gZoneAll
	fx fy fw fh ;

::gZoneEle
	fx marx + fy mary + wiw marx 2* - wih mary 2* - ;
		
::tlwrite | "text" --
	fsize nip | w h
	wix marx + padx +
	wiy wih 2/ + rot 2/ -
	fat ftext ;
	
:tcwrite | "text" --
	fsize | w h
	wix wiw 2/ + rot 2/ -
	wiy wih 2/ + rot 2/ -
	fat
	ftext ;
	
:trwrite | "text" --
	fsize | w h
	wix wiw + mary 2* pady 2* + - rot -
	wiy wih 2/ + rot 2/ -
	fat
	ftext ;


| fullwidth button down
::uiFTBtn | 'v "" --
	fx cx +
	fy cy +
	fw marx 2* - 
	fsizeh pady 2* + 
	immBox immZone
|	uistate $7 and 2 << 'colors + d@ 'fcolor !
|	wix wiy wiw wih 5 frectb

	$ffffffff 'fcolor !
	uistate 1? ( wix wiy wiw wih 5 rectb ) drop
	tcwrite 
	
	uiClk 
	fsizeh 
	pady 2* + mary + 'cy +!
	;
	
::uiTBtn | 'click "" --
	fsize drop | w h 
	fx cx +
	fy cy +
	rot padx 2* + dup >r 
	fsizeh pady 2* + 
	immBox immZone
	
	wix wiy wiw wih 5 rectb
	
	$ffffffff 'fcolor !
|	uistate 1? ( wix wiy wiw wih 5 rectb ) drop
	tcwrite 

	uiClk 
	r> marx 2* + 'cx +!
	|pady 2* + mary + 'cy +!	
	;

::uiLabel | "" --
	fx cx + padx + 
	fy cy +
	fat ftext 
	fsizeh mary + 'cy +! ;
	
::uiLabelC | "" --
	fsize  | w h
	fx fw 2/ + rot 2/ -
	fy cy + rot >r
	fat ftext 
	r> mary + 'cy +! ;

::uiLabelR | "" --
	fsize  | w h
	fx fw + padx - rot -
	fy cy + rot >r
	fat ftext 
	r> mary + 'cy +! ;

	
