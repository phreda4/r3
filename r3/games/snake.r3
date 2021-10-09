| simple snake game
| PHREDA 2020
^r3/win/console.r3
^r3/win/sdl2.r3
^r3/lib/mem.r3
^r3/lib/rand.r3
^r3/lib/sys.r3

#gs 20	| box size
#tcx 40 | arena size
#tcy 30 | arena size
#px 10 #py 10	| player pos
#xv #yv			| player velocity
#ax 15 #ay 15	| fruit pos

#trail * 1024	| tail array
#trail> 'trail
#tail 5			| tail size

#ntime 
#dtime 
#speed

:pack | x y -- xy
	16 << or ;

:unpack | xy -- x y
	dup $ffff and swap 16 >> ;

:rpush | v --
	trail> !+ 'trail> ! ;

:rshift | --
	'trail dup 8 + trail> over - 3 >> move -8 'trail> +! ;

:drawbox | x y --
	gs * swap gs * swap gs 1 - dup SDLFillRect ;

:hit? | x y -- x y
	py <>? ( ; )
	swap px <>? ( swap ; ) swap
|.. check if hit tail??
	;

:logic
	px xv + 
	0 <? ( drop tcx 1 - ) 
	tcx >=? ( drop 0 )
	'px !
	
	py yv + 
	0 <? ( drop tcy 1 - ) 
	tcy >=? ( drop 0 ) 
	'py !
	
	px py pack rpush
	tail ( trail> 'trail - 3 >> <? rshift ) drop

	px ax - py ay - or 0? (
		1 'tail +! 
		tcx randmax 'ax ! 
		tcy randmax 'ay !
		-10 'speed +!
		) drop
	;
	
:game
	0 SDLclear

	$ff SDLcolor
	'trail ( trail> <?
		@+ unpack hit? drawbox ) drop
	$ff0000 SDLcolor
	ax ay drawbox
	
	SDLRedraw
	
|----- variable framelimit
	msec dup ntime - 'dtime +! 'ntime !
	dtime speed >? ( dup speed - 'dtime !
		logic ) drop

	SDLkey
	<up> =? ( -1 'yv ! 0 'xv ! )
	<dn> =? ( 1 'yv ! 0 'xv ! )
	<le> =? ( -1 'xv ! 0 'yv ! )
	<ri> =? ( 1 'xv ! 0 'yv ! )
	>esc< =? ( exit )
	drop
	;

:reset
	300 'speed !
	msec 'ntime ! 0 'dtime !
	5 'tail ! ;

:
	rerand
	"r3sdl" 800 600 SDLinit
	reset
	'game SDLshow
	SDLquit 
	;
