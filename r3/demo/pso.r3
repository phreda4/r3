| 2d Particle Swarm Optimization
| from the post https://novabbs.com/devel/article-flat.php?id=26288&group=comp.lang.forth#26288
| of Ahmed Melahi
|
| PHREDA 2024
|-----------------------------
^r3/lib/console.r3
^r3/lib/sdl2gfx.r3
^r3/lib/3d.r3
^r3/lib/math.r3
^r3/lib/rand.r3

|-----------------------------
#xcam 0 #ycam 0.0 #zcam -100.0

:fcircle | xc yc r --
	dup 2swap SDLFEllipse ;
	
#xo #yo	
:3dop project3d 'yo ! 'xo ! ;
:3dline project3d 2dup xo yo SDLLine 'yo ! 'xo ! ;

:3dpoint project3d msec 6 >> $7 and 4 and? ( $7 xor ) 1 + fcircle ;

:grillaxy
	-50.0 ( 50.0 <=?
		dup -50.0 0 3dop dup 50.0 0 3dline
		-50.0 over 0 3dop 50.0 over 0 3dline
		10.0 + ) drop ;

:grillayz
	-50.0 ( 50.0 <=?
		0 over -50.0 3dop 0 over 50.0 3dline
		0 -50.0 pick2 3dop 0 50.0 pick2 3dline
		10.0 + ) drop ;

:grillaxz
	-50.0 ( 50.0 <=?
		dup 0 -50.0 3dop dup 0 50.0 3dline
		-50.0 0 pick2 3dop 50.0 0 pick2 3dline
		10.0 + ) drop ;
		
#xm #ym
#rx #ry

:dnlook
	SDLx SDLy 'ym ! 'xm ! ;

:movelook
	SDLx SDLy
	ym over 'ym ! - neg 7 << 'rx +!
	xm over 'xm ! - 7 << neg 'ry +!  ;
	
|-----------------------------
#Dimension 2 | The number of dimension

#PopulationSize 100 | Population Size (default = 15)

#MaxDomain 50.0 | variable upper limit
#MinDomain -50.0 | variable lower limit
#W 0.9 | inertia weight
#C1 0.8 | weight for personal best
#C2 0.8 | weight for global best

#bestpx
#bestpy
#bestfit

|--- struct 
:.posx 0 ncell+ ;
:.posy 1 ncell+ ;
:.velx 2 ncell+ ;
:.vely 3 ncell+ ;
:.fit 4 ncell+ ;
:.bpx 5 ncell+ ;
:.bpy 6 ncell+ ;
:.bfit 7 ncell+ ;

|-----------------------------
#popu

:ini
	mark
	here 
	dup 'popu ! 
	PopulationSize 8 3 << * | reserve memory
	+ 'here ! 
	;

|-----------------------------	fitness 
:sphere | arr -- fit
	0 
	over @ 3 >> dup *. +
	over 8 + @ 3 >> dup *. +
	nip ;

:sin1 | arr -- fit ; no global min
	@+ swap @ 
	0.2 *. sin swap 0.2 *. sin +  ;

:sin2 | arr -- fit
	@+ swap @ 
	0.2 *. exp. neg swap 0.2 *. sin *. ;
	
:calcfitness | vector -- fitness
	sin1 ;

|-----------------------------	initialize
:changebest | adr fit -- adr fit
	dup 'bestfit !
	over .posx @ 'bestpx !
	over .posy @ 'bestpy !
	;
	
:randmm
	MinDomain MaxDomain randminmax ;

:randv
	-0.1 0.1 randminmax ;
	
:inip | adr -- adr
	dup >a
	randmm a!+ randmm a!+	| pos
	randv a!+ randv a!+	| vel
	dup calcfitness 
	bestfit <? ( changebest )
	a!+		| fitness
	dup .posx @ a!+			| bestpost
	dup .posy @ a!+
	dup .fit @ a!+			| bestfit
	;
	
:inilist
	$7fffffffffffffff 'bestfit !
	popu PopulationSize ( 1? 1 - swap
		inip 
		8 3 << + swap ) 2drop ;
	
|-----------------------------	update
:localbest | adr fitness -- adr fitness
	over .bfit @ >=? ( ; ) | no update
	over .posx @ pick2 .bpx !
	over .posy @ pick2 .bpy !
	dup pick2 .bfit !
	;

:limitmm | v -- vl
	MaxDomain clampmax MinDomain clampmin ;
	
:updp | adr -- adr
	dup .velx @ over .posx @ + limitmm over .posx !
	dup .vely @ over .posy @ + limitmm over .posy !
	dup calcfitness 
	bestfit <? ( changebest )	
	localbest
	over .fit !

	dup .velx @ W *.
	over .bpx @ pick2 .posx @ - C1 randmax *. +
	bestpx pick2 .posx @ - C2 randmax *. +
	over .velx ! 

	dup .vely @ W *.
	over .bpy @ pick2 .posy @ - C1 randmax *. +
	bestpy pick2 .posy @ - C2 randmax *. +
	over .vely ! 
	
	;

|   v[d+1] =  w * v[d] +
|		c1 * r1 * ( vbestpos[d] - vpos[d] ) +
|		c2 * r2 * ( swarm_bestpos[d] - vpos[d] )

:updlist
	popu PopulationSize ( 1? 1 - swap
		updp 
		8 3 << + swap ) 2drop ;

|-----------------------------	drawing
:drawp | adr -- adr
	dup .posx @ 
	over .posy @ 
	pick2 .fit @
	project3d 2 fcircle 
	;
	
:drawlist
	popu PopulationSize ( 1? 1 - swap
		drawp 
		8 3 << + swap ) 2drop ;
		
|-----------------------------	solve
#Trial 31
#Iteration 3000

#bbfit	
#bbx
#bby

:solve
	$7fffffffffffffff 'bbfit !
	Trial ( 1? 1 -
		inilist
		Iteration ( 1? 1 - updlist	) drop
		| check best
		bestfit bbfit <? (
			dup 'bbfit !
			bestpx 'bbx !
			bestpy 'bby !
			) drop
		) drop ;
	
	
|----------------------------- main
:main
	1.0 3dmode
	rx mrotx ry mroty
	xcam ycam zcam mtrans

	$0 SDLcls
	
	$3f3f3f SDLColor
	grillaxy grillayz grillaxz

	$ff0000 SDLColor
	drawlist	
	updlist
	SDLredraw
	
	movelook
	SDLkey
	>esc< =? ( exit )
	<up> =? ( 1.0 'zcam +! )
	<dn> =? ( -1.0 'zcam +! )
	<le> =? ( 1.0 'xcam +! )
	<ri> =? ( -1.0 'xcam +! )
	<pgdn> =? ( 1.0 'ycam +! )
	<pgup> =? ( -1.0 'ycam +! )
	
	<f1> =? ( inilist ) | reini
	drop
	;
	
|-----------------------------	
:
	"r3PSO" 1024 600 SDLinit
	dnlook
	ini
	inilist
	'main SDLshow
	SDLquit ;