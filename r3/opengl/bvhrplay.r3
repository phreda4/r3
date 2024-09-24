| load bvh and obj
| try to calculate bones influence by distance
| PHREDA 2016,2020
|----------------
|MEM 64
^r3/lib/console.r3
^r3/lib/sdl2gfx.r3
^r3/lib/3d.r3
^r3/lib/mem.r3
^r3/util/loadobj.r3
^r3/util/bfont.r3

^r3/lib/trace.r3

|----------
#chsum
#model
#frames
#frametime
#animation

#framenow

|----------

#nbones 
| x y z cnt
#bonespos	
| dist|nbone dist|nbone dist|nbone dist|nbone 
#vertexbones

|----------
#xcam 0 #ycam 0 #zcam -100.0
#xr 0 #yr 0

|-------------
#v2d

:d>xy | d -- x y
	dup 32 >> swap 32 << 32 >> ;
:xy>d | x y --
	$ffffffff and swap 32 << or ;
	

| WIRE
|-------------
#colorp [ $ffffff $ff0000 $00ff00 $0000ff $ffff00 $00ffff $ff00ff $7f7f7f $7f0000 $007f00 $00007f $7f7f00 $007f7f $7f007f $444444 $004400 
$ff8080 $80ff80 $8080ff $ffff80 $80ffff $ff80ff $7f7f7f $7f8080 $807f00 $80807f $7f7f80 $807f7f $7f807f $444444 $804480
]

:bonecolor | vert -- vert
	dup 5 << vertexbones +
	@ $1f and 2 << 'colorp + d@
	SDLColor
	;
	
:drawtri | x y x y x y --
	>r >r 2over 2over SDLLine
	r> r> 2swap 2over SDLLine
	SDLLine ;

:objwire
	mark
	here 'v2d !
	verl >b
	nver ( 1? 1 -
		b@+ b@+ b@+ 8 b+ project3d
		xy>d ,q ) drop
	facel >b
	nface ( 1? 1 -
		b@+ $fffff and 1 - 
		bonecolor
		3 << v2d + @ d>xy
		b@+ $fffff and 1 - 3 << v2d + @ d>xy
		b@+ $fffff and 1 - 3 << v2d + @ d>xy
		8 b+
		drawtri
		) drop
	empty
	;

|--------------------------------
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
		.cr
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
#xminb #yminb #zminb #xmaxb #ymaxb #zmaxb
	
:inilimit
	-10000.0 dup 'xmaxb ! dup 'ymaxb ! 'zmaxb !
	 10000.0 dup 'xminb ! dup 'yminb ! 'zminb ! 
	;
	
:adjlimit
	0 0 0 transform
	zminb <? ( dup 'zminb ! ) zmaxb >? ( dup 'zmaxb ! ) drop	
	yminb <? ( dup 'yminb ! ) ymaxb >? ( dup 'ymaxb ! ) drop	
	xminb <? ( dup 'xminb ! ) xmaxb >? ( dup 'xmaxb ! ) drop
	;
	
:bonesminmax | bones --
	>b
	matini
	inilimit
	0 ( db@+ 1? $ff and
		swap over - 1 + clamp0 | anterior-actual+1
		nmpop
		mpush
		db@+ db@+ db@+ mtransi
		adjlimit
		) drop
	nmpop
	;
	
:resizevertex
	objminmax
	model bonesminmax
	xmaxb xmax objescalax
	ymaxb ymax objescalay
	zmaxb zmax objescalaz
	;
	
|----------------------------------------------

#nb>
:bonesposc | --
	bonespos 'nb> !
	model >b
	matini
	0 ( db@+ 1? $ff and
		swap over - 1 + clamp0 | anterior-actual+1
		nmpop
		mpush
		db@+ db@+ db@+ mtransi
		0 0 0 transform
		swap rot nb> !+ !+ !+ 0 swap !+ 'nb> !
		) drop
	nmpop
	;

| keep 4 bones near
#maxbones 0 0 0 0

:insbone | nro dist -- nro
	8 << over $ff and or | 256 huesos
	'maxbones | dist' bones
	@+ pick2 >? ( 2drop 
		'maxbones dup 8 + swap 3 move> 
		'maxbones ! ; ) drop
	@+ pick2 >? ( 2drop 
		'maxbones 8 + dup 8 + swap 2 move> 
		'maxbones 8 + ! ; ) drop 
	@+ pick2 >? ( 2drop 
		'maxbones 16 + dup 8 + swap 1 move> 
		'maxbones 16 + ! ; ) drop
	@+ pick2 >? ( 2drop 
		'maxbones 24 + ! ; ) 
	3drop
	;
	
:everybone | x y z --
	'maxbones 1000.0 8 << 4 fill
	bonespos >a
	0 ( nbones <?
|		'maxbones @+ "%f " .print @+ "%f " .print @+ "%f " .print @+ "%f = " .print drop
|		dup "%d." .println 
		pick3 a@+ - dup *.
		pick3 a@+ - dup *. 
		pick3 a@+ - dup *.
		+ + sqrt. insbone
		8 a+
		1 + ) 4drop
|	maxbones $ff and "%d " .print

	nb> 'maxbones 4 move
	4 3 << 'nb> +!
	;
	
:calcbones	
	bonesposc
	vertexbones 'nb> !
	matini
	verl >b
	nver ( 1? 1 -
|		dup "%d " .println
		b@+ b@+ b@+ everybone
		8 b+ 
		) drop 
		
|	.input		
		;
	
:scalex	1.0 objescalax ;
:scaley	1.0 objescalay ;
:scalez	1.0 objescalaz ;

#sumw
:wb, |
	a@+ 
	dup 8 >> sumw /. 1.0 swap - 
|	dup "%f" .print 
	, | 16.16 weight
	$ff and 
|	dup "%d " .print
	,c | nro vert
	;
	
|#mm	
:savebones
	mark
|	here "save %h" .println
|	here 'mm !
	vertexbones  >a
	nver ( 1? 1 -
		a@+ 8 >> a@+ 8 >> + a@+ 8 >> + a@+ 8 >> +  'sumw !
		4 3 << neg a+ | back to first
		wb, wb, wb, wb, | 4 bones
		) drop
		
|	here "save %h" .println		
|	here mm - 20 / "%d vertices" .println
|	.input
	"media/bvh/bones2mario" savemem
	empty
	;
	
|----------------------------------------------
:freelook
	SDLx SDLy
	sh 1 >> - 7 << swap
	sw 1 >> - neg 7 << swap
	neg
|	swap 0 mrotxyz
	mrotx mroty ;
	
|-------------------
:main
	0 SDLcls
	
	1.0 3dmode
	freelook
	xcam ycam zcam mtrans

	$ff  SDLColor
	
|	model drawbones
	model drawbones1

	$ffffff SDLColor
	objwire
	
	framenow 1 + frames >=? ( 0 nip ) 'framenow !
	
|	10 10 bat xmin ymin zmin "zm:%f ym:%f xm:%f" sprint bprint 
|	10 30 bat xmax ymax zmax "zM:%f yM:%f xM:%f" sprint bprint
	
	10 10 bat nbones "%d bones " sprint bprint
	SDLRedraw
	
	SDLkey
|	<f1> =? ( loadbvh )
	>esc< =? ( exit )
	<f1> =? ( objminmax objcentra )
	<f2> =? ( resizevertex ) 
	<f3> =? ( calcbones )
	<f4> =? ( savebones )
	
	<a> =? ( 1.1 scalex )
	<d> =? ( 0.9 scalex )
	<w> =? ( 1.1 scaley )
	<s> =? ( 0.9 scaley )
	<q> =? ( 1.1 scalez )
	<e> =? ( 0.9 scalez )

	<j> =? ( 0.1 0 0 objmove )
	<l> =? ( -0.1 0 0 objmove )
	<i> =? ( 0 0.1 0 objmove )
	<k> =? ( 0 -0.1 0 objmove )
	<u> =? ( 0 0 0.1 objmove )
	<o> =? ( 0 0 -0.1 objmove )

	drop
	;

:ini
	mark
	"media/obj/mario/mario.obj" loadobj 'model !
	"media/bvh/ChaCha001.bvhr" bvhrload
	0 'framenow !
	
	animation model - 4 >> 'nbones !
	here 
	dup 'bonespos ! | x y z cnt
	nbones 5 << + 
	dup 'vertexbones ! | b1 b2 b3 b4
	nver 5 << + | 8 * 4
	'here !	
	;

: 
	ini 
	"r3sdl" 800 600 SDLinit	
	bfont1 
	'main SDLshow 
	SDLquit
	;