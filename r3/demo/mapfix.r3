| demo map fix
| PHREDA 2021
|------------------

^r3/win/console.r3
^r3/win/sdl2.r3
^r3/win/sdl2image.r3
^r3/util/tilesheet.r3

#ts_spr

#wmap 32
#hmap 32

#map (
6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6
1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
1 0 0 2 2 0 0 0 6 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
1 0 0 0 3 3 0 0 6 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
1 0 0 0 0 0 0 5 6 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
1 0 0 0 0 0 4 0 6 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
1 0 0 2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
1 0 2 2 2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
1 0 0 2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
1 0 0 2 0 0 7 7 7 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
1 0 0 0 0 0 0 0 0 8 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
1 0 0 0 0 0 0 0 0 8 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
1 0 0 0 0 0 0 0 0 8 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
1 6 6 6 6 6 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
1 0 0 0 0 0 0 0 0 0 0 0 0 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
1 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
1 0 0 0 0 0 0 9 9 0 0 0 0 0 0 0 0 0 0 1 1 1 0 0 0 0 0 0 0 0 0 1
1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 0 0 0 0 1
1 0 0 0 0 5 5 5 5 5 5 5 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 11 11 11 0 0 0 0 0 0 0 0 0 0 0 0 1
1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 0 0 0 0 0 0 0 0 1
1 0 0 0 0 0 0 0 0 10 10 10 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 1
1 0 0 0 0 0 2 0 2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
1 0 0 0 0 0 2 0 2 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
1 0 0 0 0 0 2 0 2 0 0 0 0 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
)

#nspr ( 0 84 85 86 87 88 89 90 1 2 3 4 5 )

|------ DRAW MAP

:gettilea | x y -- t
	4 >> swap 4 >> swap 32 * + 'map + ;

:gettile | x y -- t
	4 >> swap 4 >> swap 32 * + 'map + c@ ;

:drawtile | x y adr tile -- y x adr  
	0? ( drop ; ) 'nspr + c@ ts_spr 
	pick4 4 << pick4 4 << swap
	16 16 tsdraws ;

:drawmap
	'map 
	0 ( 32 <? 
		0 ( 32 <?
			rot c@+ drawtile rot rot 
			1 + ) drop
		1 + ) 2drop ;

		
|--------- PLAYER
#nplay ( 
91 92 91 93  
94 95 94 96 
)

#nstep
#ddx
#dx #dy
#xp 32.0 #yp 32.0

:[map]@ | x y -- adr
	swap -? ( 2drop 0 ; ) wmap >=? ( 2drop 0 ; )
	swap -? ( 2drop 0 ; ) hmap >=? ( 2drop 0 ; )
	wmap * + 'map + c@ ;
	
:roof? | -- techo?
	xp 8.0 + 20 >> yp 2.0 - 20 >> [map]@ ;

:floor? | -- piso?
	xp 8.0 + 20 >> yp 16.0 + 20 >> [map]@ ;

:wall? | dx -- wall?
	xp + 8.0 + 20 >> yp 8.0 + 20 >> [map]@ ;

:jump
	floor? 0? ( drop
		0.3 'dy +!
		roof? 1? ( dy -? ( 0 'dy ! ) drop ) drop
		; ) drop
	0 'dy !
	yp $fffff00000 and 'yp ! | fit y to map (16.0)
	SDLkey
	<up> =? ( -6.0 'dy ! )
	drop
	;

:go>>
	8.0 wall? 0? ( drop 0.08 nstep + $3ffff and 'nstep ! ; ) drop
	0 'nstep !
	xp $fff00000 and 'xp !
	drop 0 ;

:go<<
	-8.0 wall? 0? ( drop 0.08 nstep + $3ffff and 4.0 + 'nstep !	; ) drop
	4.0 'nstep ! 
	xp $fff00000 and 16.0 + 'xp !
	drop 0 ;

:player
	SDLkey
	<le> =? ( -0.25 'ddx ! )
	<ri> =? ( 0.25 'ddx ! )
	>le< =? ( 0 'ddx ! )
	>ri< =? ( 0 'ddx ! )
 	drop

    dx ddx 0? ( swap 0.4 *. )
	+ 3.0 min -3.0 max
	0 >? ( go>> )
	0 <? ( go<< )
	'dx !
	jump

	dx 'xp +!
	dy 'yp +!
	;


:drawplayer
	player
	nstep 16 >> 'nplay + c@  
	ts_spr
	xp 16 >> yp 16 >>
	16 16 tsdraws
	;

:resetplayer
	0 'ddx !
	0 'dx ! 0 'dy !
	64.0 'xp !
	480.0 'yp !
	;		

|----- MAIN
:demo
	0 SDLclear
	
	drawmap
	drawplayer

	SDLRedraw
	
	SDLkey
	>esc< =? ( exit )
	drop
	;

:main
	"r3sdl" 800 600 SDLinit

	64 64 "media/img/sokoban_tilesheet.png" loadts 'ts_spr !
	'demo SDLshow
	
	SDLquit
	;
	
: main ;