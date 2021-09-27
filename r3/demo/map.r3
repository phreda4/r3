| demo map 
| PHREDA 2021
|------------------

^r3/win/console.r3
^r3/win/sdl2.r3
^r3/win/sdl2image.r3
^r3/util/tilesheet.r3
^r3/lib/key.r3

#ts_spr

#wmap 32
#hmap 32

#map (
1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
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
1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
1 6 6 6 6 6 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
1 0 0 0 0 0 0 0 0 0 0 0 0 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
1 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 0 0 0 0 0 0 0 0 0 1
1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 0 0 0 0 1
1 0 0 0 0 5 5 5 5 5 5 5 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 0 0 0 0 0 0 0 0 1
1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 1
1 0 0 0 0 0 2 0 2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
1 0 0 0 0 0 2 0 2 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
1 0 0 0 0 0 2 0 2 0 0 0 0 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
)

#nspr ( 0 84 85 86 87 88 89 90 )

:gettilea | x y -- t
	4 >> swap 4 >> swap 32 * + 'map + ;

:gettile | x y -- t
	4 >> swap 4 >> swap 32 * + 'map + c@ ;

:drawtile | x y adr tile -- y x adr  
	0? ( drop ; ) 'nspr + c@ ts_spr 
	pick4 6 << pick4 6 << swap
	tsdraw ;

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
#xp 128.0 #yp 64.0

:[map] | x y -- adr
	swap -? ( 0 nip ) wmap >=? ( 0 nip )
	swap -? ( 0 nip ) hmap >=? ( 0 nip )
	wmap * + 'map + ;
	
:roof? | -- techo?
	xp 32.0 + 22 >> yp 8.0 - 22 >> [map] c@ ;

:floor? | -- piso?
	xp 32.0 + 22 >> yp 64.0 + 22 >> [map] c@ ;

:wall? | dx -- wall?
	xp + 32.0 + 22 >> yp 32.0 + 22 >> [map] c@ ;

:jump
	floor? 0? ( drop
		0.4 'dy +!
		roof? 1? ( dy -? ( 0 'dy ! ) drop ) drop
		; ) drop
	0 'dy !
	yp $fff00000 and 'yp ! | fit y to map
	SDLkey
	<up> =? ( -14.0 'dy ! )
	drop
	;

:goleft
	32.0 wall? 0? ( drop 0.08 nstep + $3ffff and 'nstep ! ; ) drop
	0 'nstep !
	xp $fff00000 and 'xp !
	drop 0 ;

:gorigth
	-32.0 wall? 0? ( drop 0.08 nstep + $3ffff and 4.0 + 'nstep !	; ) drop
	4.0 'nstep ! 
	xp $fff00000 and 'xp !
	drop 0 ;

:player
	SDLkey
	<le> =? ( -0.25 'ddx ! )
	<ri> =? ( 0.25 'ddx ! )
	>le< =? ( 0 'ddx ! )
	>ri< =? ( 0 'ddx ! )
	
	<f1> =? ( 2 
		xp 32.0 + 22 >> 
		yp 32.0 + 22 >> 
		[map] c! )
 	drop

    dx ddx 0? ( swap 0.4 *. )
	+ 3.0 min -3.0 max
	0 >? ( goleft )
	0 <? ( gorigth )
	'dx !
	jump

	dx 'xp +!
	dy 'yp +!
	;


:drawplayer
	player
	.home nstep "%f" .print
	nstep 16 >> 'nplay + c@  
	ts_spr
	sw 1 >> sh 1 >> 
	tsdraw 
	;

:resetplayer
	0 'ddx !
	0 'dx ! 0 'dy !
	64.0 'xp !
	480.0 'yp !
	;		

|--------- RELATIVE MAP
#xm #ym

:drawrtile | y x -- y x
	dup xp 22 >> +
	pick2 yp 22 >> +
	[map] c@ 0? ( drop ; )
	'nspr + c@ ts_spr xm ym tsdraw ;

:drawrmap
	-7 6 << sw 1 >> + xp 16 >> $3f and - 'xm !
	-5 6 << sh 1 >> + yp 16 >> $3f and - 'ym !	
	-5 ( 5 <? 
		-7 ( 7 <?
        	drawrtile
			64 'xm +! 
			1 + ) drop
		-896 'xm +!
		64 'ym +!
		1 + ) drop ;
	
|----------------------------------------
:demo
	0 SDLcolor 
	SDLrenderer SDL_RenderClear
	
	drawrmap
	drawplayer

	SDLrenderer SDL_RenderPresent
	
	SDLkey
	>esc< =? ( exit )
	drop
	;

:main
	mark
	"r3sdl" 800 600 SDLinit

	64 64 "media/img/sokoban_tilesheet.png" loadts 'ts_spr !
	'demo SDLshow
	
	SDLquit
	;
	
: main ;