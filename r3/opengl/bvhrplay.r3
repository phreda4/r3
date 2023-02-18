| bvh load
| PHREDA 2016,2020
|----------------
|MEM 64
^r3/win/console.r3
^r3/win/sdl2gfx.r3
^r3/lib/3d.r3
^r3/lib/mem.r3

^r3/lib/trace.r3

#chsum
#model
#frames
#frametime
#animation

#framenow

#xcam 0 #ycam 0 #zcam 400.0
#xr 0 #yr 0

:bvhrload
	here dup rot load 'here !
	4 + d@+ 'animation !
	d@+ 'chsum !
	d@+ 'frames !
	d@+ 'frametime ! 
	dup 'animation +!
	'model !
	;

|------------------------------------------
:dumpmod | adr
	( d@+ 1?
		"%h " .print
		d@+ "%f " .print
		d@+ "%f " .print
		d@+ "%f " .print
		cr
		) 2drop ;

#xop #yop
:xxop 'yop ! 'xop ! ;
:xxline 2dup xop yop SDLLine 'yop ! 'xop ! ;

:3dop project3d xxop ;
:3dline project3d xxline ;

:drawboxz | z --
	-0.5 -0.5 pick2 3dop
	0.5 -0.5 pick2 3dline
	0.5 0.5 pick2 3dline
	-0.5 0.5 pick2 3dline
	-0.5 -0.5 rot 3dline ;

:drawlinez | x1 x2 --
	2dup -0.5 3dop 0.5 3dline ;

#boneslevel * 1024

:box | x y r --
	rot over - rot pick2 -
	rot 1 << dup SDLREct
	;

:drawstick | level
	0 0 0 project3d
	$ff00 SDLColor 
	2dup 2 box 
	2dup XXOP
	swap
	pick2 5 << 'boneslevel + d!+ d!
	2 <? ( ; )
	$ff SDLColor 
	dup 1 - 5 << 'boneslevel +
	d@+ swap d@ XXline ;

:drawcube |
	$ff00 SDLColor
	-0.5 drawboxz
	0.5 drawboxz
	-0.5 -0.5 drawlinez
	0.5 -0.5 drawlinez
	0.5 0.5 drawlinez
	-0.5 0.5 drawlinez ;



|-------------------------------
#anip
:val anip d@+ swap 'anip ! ;

:xpos val 0 0 mtransi ;
:ypos val 0 swap 0 mtransi ;
:zpos val 0 0 rot mtransi ;
:xrot val mrotxi ;
:yrot val mrotyi ;
:zrot val mrotzi ;
#lani xpos ypos zpos xrot yrot zrot

:anibones | flags --
	8 >> $ffffff and
	( 1? dup $f and 1 - 3 << 'lani + @ ex 4 >> )
	drop ;

:drawbones | bones --
	>b
	framenow chsum * 2 << animation + 'anip !
	0 ( db@+ 1? dup $ff and
		rot over - 1 + clamp0 | anterior-actual+1
		nmpop
		mpush
		db@+ db@+ db@+ mtransi
		swap anibones
		drawstick  |drawcube
		) drop
	nmpop
	;

:drawbones0 | bones --
	>b
	0 ( db@+ 1? $ff and
		swap over - 1 + clamp0 nmpop
		mpush
		db@+ db@+ db@+ mtransi
		drawcube
		) drop
	nmpop
	;
	
:drawbones1 | bones --	
	>b
	0 ( db@+ 1? $ff and
		swap over - 1 + clamp0 | anterior-actual+1
		nmpop
		mpush
		db@+ db@+ db@+ mtransi
		drawstick  |drawcube
		) drop
	nmpop
	;	

|----------------------------------------------
:freelook
	SDLx SDLy
	sh 1 >> - 7 << swap
	sw 1 >> - neg 7 << swap
	neg
|	swap 0 mrotxyz
	mrotx mroty ;
	
:people
	-200.0 ( 200.0 <? 100.0 +
		-200.0 ( 200.0 <? 100.0 +
			mpush
			2dup 0.0 swap mtransi
			model drawbones
			mpop ) drop
		) drop
	;


:main
	0 SDLcls
	
	1.0 3dmode
	|freelook
	xcam ycam zcam mtrans

	model drawbones
|	people
|	model drawbones1
	
	framenow 1 + frames >=? ( 0 nip ) 'framenow !
	
	SDLRedraw
	
	SDLkey
|	<f1> =? ( loadbvh )
	>esc< =? ( exit )

	drop
	;

:ini
	"media/bvh/ChaCha001.bvhr" bvhrload
	0 'framenow !
	;

: 
	ini 
	"r3sdl" 800 600 SDLinit	
	'main SDLshow 
	SDLquit
	;