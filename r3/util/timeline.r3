| About timeline
| framerate independient event animation system
| PHREDA 2020
|------------------
^r3/win/sdl2.r3
^r3/win/sdl2mixer.r3

^r3/util/arr8.r3
^r3/util/penner.r3

##screen 0 0
##fx 0 0
##fxp 0 0

|------ tiempo
#prevt
##timenow

::timeline.start
	msec 'prevt ! 0 'timenow ! ;

:dtime
	msec dup prevt - 'timenow +! 'prevt ! ;

|------ linea de tiempo
#timeline 0
#timeline< 0
#timeline> 0

::timeline.clear
	'fxp p.clear
	'fx p.clear
	'screen p.clear
	timeline
	dup 'timeline> !
	'timeline< !
	;

:searchless | time adr --time adr
	( 32 - timeline >=?
		dup @	| time adr time
		pick2 <=? ( drop 32 + ; )
		drop ) 32 + ;

:+tline	| 'fx 'scr event time --
	1000 *.
	timeline> searchless | adr
	dup dup 32 + swap timeline> over - 2 >> move>
	>a a!+ a!+ a!+ a!
	32 'timeline> +! ;

:tictline
	timeline< timenow
	( over
		timeline> =? ( 3drop ; )
		@ >?
		swap
		dup 8 + @ ex
		32 + swap ) drop
	'timeline< ! ;

|-------------------- LOOP
:evt.restart
	'fx p.clear
	timeline 'timeline< !
	timeline.start ;

::+restart | tiempo --
	>r 0 0 'evt.restart r> +tline ;

|-----------------------------
::xywh64 | x y w h -- 64b
	$ffff and swap
	$ffff and 16 << or swap
	$ffff and 32 << or swap
	$ffff and 48 << or ;

::w% sw 16 *>> ;
::h% sh 16 *>> ;

::xywh%64 | x y w h -- 64b
	h% $ffff and swap
	w% $ffff and 16 << or swap
	h% $ffff and 32 << or swap
	w% $ffff and 48 << or ;

::xy%64 | x y -- 64b
	h% $ffff and 32 << or swap
	w% $ffff and 48 << or 
	$ffffffff or ;

::64xy | b -- x y 
	dup 48 >> swap 16 << 48 >> ;
	
::64wh | b -- w h
	dup 32 << 48 >> swap 48 << 48 >> ;
	
::64xywh | b -- x y w h
	dup 48 >> swap dup 16 << 48 >> swap
	dup 32 << 48 >> swap 48 << 48 >> ;
	
#sdlbin [ 0 0 0 0 ]
#sdlbox [ 0 0 0 0 ]

::64box | b adr --
	swap
	dup 48 >> rot d!+
	swap dup 16 << 48 >> rot d!+
	swap dup 32 << 48 >> rot d!+
	swap 48 << 48 >> swap d! ;
	
|-------------------- FILLBOX
:drawbox | adr --
	>b b@+ 1 and? ( drop ; ) 
	SDLrenderer swap
	dup 26 >> $ff and swap dup 16 >> $ff and swap 8 >> $ff and 
	$ff SDL_SetRenderDrawColor 
	b@ 'sdlbox 64box
	SDLrenderer 'sdlbox SDL_RenderFillRect
	;

::+box | box color --
	'drawbox 'screen p!+ >a
	8 << 1 or a!+ a!+ ;

|-------------------- IMAGEN
:drawimg | adr --
	>b b@+ 1 and? ( drop ; ) 
|	8 >> 1? ( SDLrenderer over 
|		dup 16 >> $ff and swap dup 8 >> $ff and swap $ff and 
|		SDL_SetTextureColorMod )
	drop
	b@+ 'sdlbox 64box
	SDLrenderer b@ 0 'sdlbox SDL_RenderCopy
	;

::+img  | img box --
	'drawimg 'screen p!+ >a
	0 a!+ a!+ a! ;

|-------------------- TEXTO
:drawtxt | adr --
	>b b@+ 1 and? ( drop ; ) 
|	8 >> 1? ( SDLrenderer over 
|		dup 16 >> $ff and swap dup 8 >> $ff and swap $ff and 
|		SDL_SetTextureColorMod )
	drop
	b@+ 'sdlbox 64box
	b@+ 'sdlbin 64box
	SDLrenderer b@ 'sdlbin 'sdlbox SDL_RenderCopy
	;

::+txt  | img boxi boxo --
	'drawtxt 'screen p!+ >a
	0 a!+ a!+ a!+ a! ;
	
|-------------------- SONIDO
:evt.play | adr --
	-1 over 16 + @ 0 -1 Mix_PlayChannelTimed ;

::+sound | sonido inicio --
	0 'evt.play 2swap >r swap r> +tline ;

|-------------------- VIDEO ***********
:drawvideo
	@+ 1 and? ( 2drop ; ) drop
	>a
|	a@+ a@+ videoshow a!
	;

:+video | x y --
	'drawvideo 'screen p!+ >a
	1 a!+
	swap a!+ a!+ | x1 y1
	0 a!+	| estado
	;

|-------------------- EXEC
::+event | exec inicio --
	0 0 2swap +tline ;


|-----------------------------
:getscr | -- adrlast
	'screen p.last ;

:getfx | -- adrlast
	'fxp p.last ;

|-----------------------------
:evt.on | adr -- adr
	dup 16 + @ 8 + dup @ 1 not and swap ! ;

::+fx.on | sec --
	>r 0 getscr 'evt.on r> +tline ;

|-----------------------------
:evt.off
	dup 16 + @ 8 + dup @ 1 or swap ! ;

::+fx.off | sec --
	>r 0 getscr 'evt.off r> +tline ;
	
|-----------------------------
#t0

:setlastcoor
	8 a+ a@+ a@+ a@
	dup 48 >> pick2 48 >> + $ffff and 48 << >r
	dup 16 << 48 >> pick2 16 << 48 >> + $ffff and 32 << r> or >r 
	dup 32 << 48 >> pick2 32 << 48 >> + $ffff and 16 << r> or >r 
	48 << 48 >> swap 48 << 48 >> + $ffff and r> or 	
	swap ! 
	;

:boxanim | screena --
	>a timenow a@+ - a@+ *.
	1.0 >=? ( drop setlastcoor 0 ; )
	a@+ ex 't0 ! 
	a@+ a@+ a@ | scrobj ini delta
	dup 48 >> t0 *. pick2 48 >> + $ffff and 48 << >r
	dup 16 << 48 >> t0 *. pick2 16 << 48 >> + $ffff and 32 << r> or >r 
	dup 32 << 48 >> t0 *. pick2 32 << 48 >> + $ffff and 16 << r> or >r 
	48 << 48 >> t0 *. swap 48 << 48 >> + $ffff and r> or 	
	swap ! 
	;

::evt.box
	'boxanim 'fx p!+ >a
	dup 24 + @ >b | fxp
	b@+ 1000 *. a!+	| inicio
	1.0 b@+ 1000 *.u /. a!+ | tiempo
	b@+ a!+			| function
    dup 16 + @ 16 + a!+ | scr+16 = box
   	b@+ b@+ dup a!+ |  end ini 
	over 48 >> over 48 >> - $ffff and 48 << >r
	over 16 << 48 >> over 16 << 48 >> - $ffff and 32 << r> or >r
	over 32 << 48 >> over 32 << 48 >> - $ffff and 16 << r> or >r	
	swap 48 << 48 >> swap 48 << 48 >> - $ffff and r> or a!
	;

::+fx.box | boxstart boxend func duration sec --
	dup >r 'fxp p!+ >a a!+ a!+ a!+ a!
	getfx getscr 'evt.box r> +tline ;
	
|-------------------- ANIMADOR color
:setlastcol
	8 a+ a@+ a@+ a@
	dup 38 << 55 >> pick2 16 >> $ff and + $ff and 16 << >r
	dup 47 << 55 >> pick2 8 >> $ff and + $ff and 8 << r> or >r	
	55 << 55 >> swap $ff and + $ff and r> or 
	8 << over @ $ff and or | preserve low8bit
	swap ! ;
	
:scale8
	t0 16 *>> ;
	
:colanim | screena --
	>a timenow a@+ - a@+ *.
	1.0 >=? ( drop setlastcol 0 ; )
	a@+ ex 't0 ! 
	a@+ a@+ a@+ | scrobj ini delta
	dup 38 << 55 >> scale8 pick2 16 >> $ff and + $ff and 16 << >r
	dup 47 << 55 >> scale8 pick2 8 >> $ff and + $ff and 8 << r> or >r	
	55 << 55 >> scale8 swap $ff and + $ff and r> or 
	8 << over @ $ff and or | preserve low8bit
	swap !
	;

::evt.color
	'colanim 'fx p!+ >a
	dup 24 + @ >b | fxp
	b@+ 1000 *. a!+	| inicio
	1.0 b@+ 1000 *.u /. a!+ | tiempo
	b@+ a!+			| function
	
    dup 16 + @ 8 + a!+ | scr+8=color
	
   	b@+ b@+ dup a!+ |  end ini 
	over 40 << 56 >> over 40 << 56 >> - $1ff and 18 << >r
	over 48 << 56 >> over 48 << 56 >> - $1ff and 9 << r> or >r
	swap 56 << 56 >> swap 56 << 56 >> - $1ff and r> or
	a!
	;

::+fx.color | colorstart colorend func duraction sec --
	dup >r 'fxp p!+ >a a!+ a!+ a!+ a!
	getfx getscr 'evt.color r> +tline ;

|*********DEBUG
:dumptline
	timeline< timeline - 4 >> "%d" .print cr
	timeline
	( timeline> <?
		timeline< =? ( "> " .print )
		@+ "%d " .print
		@+ "%d " .print
		@+ "%d " .print
		@+ "%d " .print cr
		) drop ;

::debugtimeline
	.home .cls
	timenow "%d " .print
	t0 "%f" .print cr
	dumptline
	[ dup @+ "%h " .print 
		@+ "%d " .print  
		@+ 64xywh "%d,%d:%d,%d " .print 
		@ "%h " .print cr ; ] 'screen p.mapv cr
	cr
	[ dup @+ "%f " .print
		@+ "%f " .print
		@+ "%h " .print
		@+ 64xywh "%d,%d:%d,%d " .print
		@+ 64xywh "%d,%d:%d,%d " .print
		@+ "%d " .print
		@ "%d " .print
		cr ; ] 'fxp p.mapv cr
	cr

	;
|*********DEBUG

::timeline.draw
	dtime
	tictline
	'fx p.draw
	'screen p.drawo
	;

::timeline.inimem
	here 'timeline !
	$fff 'here +!
	1024 'screen p.ini
	1024 'fx p.ini
	1024 'fxp p.ini
	;
