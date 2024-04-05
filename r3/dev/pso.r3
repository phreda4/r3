| PSO
| PHREDA 2024
|-----------------------------
^r3/win/console.r3
^r3/win/sdl2gfx.r3
^r3/lib/3d.r3
^r3/lib/math.r3
^r3/lib/rand.r3

|-----------------------------
#xcam 0 #ycam 0 #zcam -100.0

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
#PopulationSize 100 | Population Size (default = 15)
#MaxDomain 50.0 | variable upper limit
#MinDomain -50.0 | variable lower limit
#Dimension 2 | The number of dimension
#W 0.9 | inertia weight
#C1 2.0 | weight for personal best
#C2 2.0 | weight for global best
#Trial 31
#Iteration 3000

#bestpop
#bestfit

:sphere | arr -- fit
	0 
	over 8 + @ 3 >> dup *. +
	over 24 + @ 3 >> dup *. +
	nip ;

:calcfitness | vector -- fitness
	sphere ;
	
| vel1 pos1 vel2 pos2 fitness
|-----------------------------
#popu
#popu>

:ini
	mark
	here 
	dup dup 'popu ! 'popu> !
	PopulationSize 5 3 << * 
	+ 
	'here ! 
	;

|-----------------------------	
:randpos
	MinDomain MaxDomain randminmax ;
:randvel
	-0.1 0.1 randminmax ;
	
:inip | adr -- adr
	dup >a
	randvel a!+ randpos a!+
	randvel a!+ randpos a!+
	dup calcfitness a!
	;
	
:inilist
	popu PopulationSize ( 1? 1 - swap
		inip 
		5 3 << + swap ) 2drop ;

|-----------------------------	
:drawp | adr -- adr
	dup 8 + @ over 24 + @ pick2 32 + @
	project3d 2 fcircle ;
	
:drawlist
	popu PopulationSize ( 1? 1 - swap
		drawp 
		5 3 << + swap ) 2drop ;
	
|-----------------------------	
:updp | adr -- adr
	dup 
	@+ over @ + 
	MaxDomain clampmax
	MinDomain clampmin
	swap !+	| 1
	@+ over @ + 
	MaxDomain clampmax
	MinDomain clampmin
	swap !+ | 2
	over calcfitness swap !
	;

:updlist
	popu PopulationSize ( 1? 1 - swap
		updp 
		5 3 << + swap ) 2drop ;

|-----------------------------	
|def update_velocity(self, best_position):
|        r_1 = np.random.rand(cf.get_dimension())
|       r_2 = np.random.rand(cf.get_dimension())
|        [Reload Equation] (x indicate position vector)
|        v = wv + c_1 * r_1 (x_pbest - x) + c_2 * r_2 (x_gbest - x)
|        self.__velocity = cf.get_W() * self.__velocity \
|                          + cf.get_C1() * r_1 * (self.__p_best_position - self.__position) \
|                          + cf.get_C2() * r_2 * (best_position - self.__position)
	
:solve
|    for trial in range(cf.get_trial()):
|        np.random.seed(trial)
|        results_list = [] # fitness list
|        pso_list = [] 
|        """Generate Initial Population"""
|        for p in range(cf.get_population_size()):
|            pso_list.append(id.Individual())
|        """Sort Array"""
|        pso_list =  sorted(pso_list, key=lambda ID : ID.get_fitness())
|        """Find Initial Best"""
|        BestPosition = pso_list[0].get_position() # Best Solution
|        BestFitness = fn.calculation(BestPosition,0)
|        """↓↓↓Main Loop↓↓↓"""
|        for iteration in range(cf.get_iteration()):
|            """Generate New Solutions"""
|            for i in range(len(pso_list)):
|                """Update Position"""
|                pso_list[i].update_position()
|                """Calculate Fitness"""
|                pso_list[i].set_fitness(fn.calculation(pso_list[i].get_position(), t=iteration))
|                """if f_x < f_(p_best) # for minimize optimization"""
|                if(pso_list[i].get_fitness() < pso_list[i].get_p_best_fitness()):
|                    pso_list[i].set_p_best_fitness(pso_list[i].get_fitness())
|                    pso_list[i].set_p_best_position(pso_list[i].get_position())
|                """if f_x < f_(g_best) # for minimize optimization"""
|                if(pso_list[i].get_fitness() < BestFitness):
|                    BestFitness = pso_list[i].get_fitness()
|                    BestPosition = pso_list[i].get_position()
|                """Reload Velocity"""
|                pso_list[i].update_velocity(BestPosition)
|            """Sort Array"""
|            pso_list = sorted(pso_list, key=lambda ID: ID.get_fitness())
|            """Rank and Find the Current Best"""
|            if pso_list[0].get_fitness() < BestFitness:
|                BestPosition = pso_list[0].get_position()
|                BestFitness = fn.calculation(BestPosition,iteration)
|            sys.stdout.write("\r Trial:%3d , Iteration:%7d, BestFitness:%.4f" % (trial , iteration, BestFitness))
|            results_list.append(str(BestFitness))
|        results_writer.writerow(results_list)
	
|-----------------------------	
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
	<up> =? ( 0.1 'zcam +! )
	<dn> =? ( -0.1 'zcam +! )
	<le> =? ( 0.1 'xcam +! )
	<ri> =? ( -0.1 'xcam +! )
	<pgdn> =? ( 0.1 'ycam +! )
	<pgup> =? ( -0.1 'ycam +! )
	drop
	;
	
|-----------------------------	
:
	"r4PSO" 1024 600 SDLinit
	dnlook
	ini
	inilist
	'main SDLshow
	SDLquit ;