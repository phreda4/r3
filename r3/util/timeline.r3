| About timeline
| framerate independient event animation system
| PHREDA 2020
|------------------
^r3/lib/sdl2gfx.r3
^r3/lib/sdl2mixer.r3

^r3/util/arr8.r3
^r3/util/penner.r3
^r3/util/boxtext.r3

##endtimeline 

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
	'fxp p8.clear
	'fx p8.clear
	'screen p8.clear
	timeline
	dup 'timeline> !
	'timeline< !
	0 'endtimeline !
	;

:searchless | time adr --time adr
	( 64 - timeline >=?
		dup @	| time adr time
		pick2 <=? ( drop 64 + ; )
		drop ) 64 + ;

:+tline	| 'fx 'scr event time --
	1000 *.
	timeline> searchless | adr
	dup dup 64 + swap timeline> over - 2 >> move>
	>a a!+ a!+ a!+ a!
	64 'timeline> +! ;

:tictline
	timeline< timenow
	( over
		timeline> =? ( 'timeline< ! 2drop ; )
		@ >=?
		swap
		dup 8 + @ ex
		64 + swap ) drop
	'timeline< ! ;

|-------------------- LOOP
:evt.restart
	'fx p8.clear
	timeline 'timeline< !
	timeline.start ;

::+restart | tiempo --
	>r 0 0 'evt.restart r> +tline ;

|-------------------- END
:evt.stop
	'fx p8.clear
	1 'endtimeline !
	;

::+stop | tiempo --
	>r 0 0 'evt.stop r> +tline ;
	
|-----------------------------

::64xy | b -- x y 
	dup 48 >> swap 16 << 48 >> ;
	
::64wh | b -- w h
	dup 32 << 48 >> swap 48 << 48 >> ;
	
::64xywh | b -- x y w h
	dup 48 >> swap dup 16 << 48 >> swap
	dup 32 << 48 >> swap 48 << 48 >> ;
	
#sdlbin [ 0 0 0 0 ]
#sdlbox [ 0 0 0 0 ]

|--- ratio adjust
:setbox | hn wn --
	a> 8 + d@ over - 1 >> a> d+! | padx
	a> 12 + d@ pick2 - 1 >> a> 4 + d+! | pady
	8 a+
	da!+ da!+ ;
	
:ratio2 | w h hx --
	drop
	a> 12 + d@ swap rot */ 	| WN
	a> 12 + d@ swap
	setbox ;
	
::64boxratio | 64wh 'box -- ; adjust box by ratio and pad!
	>a
	dup 32 >> swap 32 << 32 >>	| h w | texture
	a> 8 + d@ pick2 pick2 */	| h w HN
	a> 12 + d@ 
	>? ( ratio2 ; ) 
	nip nip a> 8 + d@ 	| HN WN
	setbox	;
	
|--------------	
:swapcolor | color -- swapcolor
	dup 16 >> $ff and 
	over 16 << $ff0000 and or
	swap $ff00ff00 and or ;
	
|-------------------- FILLBOX
:drawbox | adr --
	>b b@+ 1 and? ( drop ; ) 
	SDLrenderer swap
	dup 24 >> $ff and swap dup 16 >> $ff and swap 8 >> $ff and 
	$ff SDL_SetRenderDrawColor 
	b@ 'sdlbox 64box
	SDLrenderer 'sdlbox SDL_RenderFillRect
	;

::+box | box color --
	'drawbox 'screen p8!+ >a
	8 << 1 or a!+ a!+ ;

|-------------------- IMAGEN
:drawimg | adr --
	>b b@+ 1 and? ( drop ; ) 
|	8 >> 1? ( SDLrenderer over 
|		dup 16 >> $ff and swap dup 8 >> $ff and swap $ff and 
|		SDL_SetTextureColorMod )
	drop
	b@+ 'sdlbox 64box
	SDLrenderer b@+ 0? ( 2drop ; ) 
	0 'sdlbox SDL_RenderCopy
	;

#imgwh 0

::+img  | img box --
	'drawimg 'screen p8!+ >a
	1 a!+ a!+ 
	dup 0 0 'imgwh dup 4 + SDL_QueryTexture | texture info
	a!+ | texture
	imgwh a! ; 

|-------------------- IMAGEN with Aspect Ratio
:drawimgar | adr --
	>b b@+ 1 and? ( drop ; ) 
|	8 >> 1? ( SDLrenderer over 
|		dup 16 >> $ff and swap dup 8 >> $ff and swap $ff and 
|		SDL_SetTextureColorMod )
	drop
	b@+ 'sdlbox 64box
	SDLrenderer b@+ 0? ( 2drop ; ) | 0 en imagen
	b@ 'sdlbox 64boxratio
	0 'sdlbox SDL_RenderCopy
	;

::+imgar  | img box --
	'drawimgar 'screen p8!+ >a
	1 a!+ a!+ 
	dup 0 0 'imgwh dup 4 + SDL_QueryTexture | texture info
	a!+ | texture
	imgwh a! ; 
	
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
	'drawtxt 'screen p8!+ >a
	0 a!+ a!+ a!+ a! ;
	
|-------------------- TEXT BOX
:drawtbox
	>b b@+ 1 and? ( drop ; )
	8 >> dup >r 24 >>
	b@+ b@+ swap | box in 2do for animation
	r> $ffffff and | color
	b@+ | font
	textbox | $vh str box color font --
	;
	
::+tbox | font "" box color -- ; HVRRGGBB00
	'drawtbox 'screen p8!+ >a
	swapcolor
	8 << 1 or a!+ a!+ a!+ a! ;

|-------------------- TEXT BOX FILL BACK
:drawtboxb
	>b b@+ 1 and? ( drop ; )
	8 >> dup >r 24 >>
	b@+ b@+ swap | box in 2do for animation
	r> $ffffff and | color
	b@+ >r | font
	b@+ 24 << or 
	r>
	textboxb | $vh str box colorfb font --
	;
	
::+tboxb | colorb font "" boz color -- ; HVRRGGBB00
	'drawtboxb 'screen p8!+ >a
	swapcolor
	8 << 1 or a!+ a!+ a!+ a!+ 
	swapcolor a! ;
	
|-------------------- TEXT BOX FILL BACK
:drawtboxo
	>b b@+ 1 and? ( drop ; )
	8 >> dup >r 24 >>
	b@+ b@+ swap | box in 2do for animation
	r> $ffffff and | color
	b@+ >r | font
	b@+ 24 << or 
	r>
	textboxo | $vh str box colorfb font --
	;
	
::+tboxo | colorb font "" ooboz color -- ; HVRRGGBB00
	'drawtboxo 'screen p8!+ >a
	swapcolor
	8 << 1 or a!+ a!+ a!+ a!+ 
	swapcolor a! ;	
	
|-------------------- SOUND
:evt.play | adr --
	-1 over 16 + @ 0 -1 Mix_PlayChannelTimed drop ;

::+sound | sonido inicio --
	0 'evt.play 2swap >r swap r> +tline ;

|-------------------- MUSIC
:evt.playm | adr --
	dup 16 + @ 0 Mix_PlayMusic ;

::+music | sonido inicio --
	0 'evt.playm 2swap >r swap r> +tline ;

|-------------------- EXEC
::+event | exec inicio --
	0 0 2swap +tline ;


|-----------------------------
::getscr | -- adrlast
	'screen p8.last ;

:getfx | -- adrlast
	'fxp p8.last ;

|-----------------------------
:evt.on | adr -- adr
	dup 16 + @ 8 + dup @ 1 nand swap ! ;

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
	'boxanim 'fx p8!+ >a
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
	dup >r 'fxp p8!+ >a a!+ a!+ a!+ a!
	getfx getscr 'evt.box r> +tline ;

	
|-------------------- DINAMICOS
::+ifx.box | elemento boxstart boxend func duration sec --
	timenow +
	dup >r 'fxp p8!+ >a a!+ a!+ a!+ a!
	getfx 
	swap 
	'evt.box r> +tline ;
	
::+ifx.text | text elemento --
	;
	
::+ievent | exec inicio --
	timenow + 0 0 2swap +tline ;

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
	'colanim 'fx p8!+ >a
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
	dup >r 'fxp p8!+ >a a!+ a!+ a!+ a!
	getfx getscr 'evt.color r> +tline ;

|*********DEBUG
:dumptline
	timeline< timeline - 4 >> "%d" .println
	timeline
	( timeline> <?
		timeline< =? ( "> " .print )
		@+ "%d " .print
		@+ "%d " .print
		@+ "%d " .print
		@+ "%d " .println
		) drop .cr ;

::debugtimeline
	.cls
	timenow "%d " .print
	t0 "%f" .println
	dumptline
	[ dup @+ "%h " .print 
		@+ "%d " .print  
		@+ 64xywh "%d,%d:%d,%d " .print 
		@ "%h " .println ; ] 'screen p8.mapv .cr
	.cr
	[ dup @+ "%f " .print
		@+ "%f " .print
		@+ "%h " .print
		@+ 64xywh "%d,%d:%d,%d " .print
		@+ 64xywh "%d,%d:%d,%d " .print
		@+ "%d " .print
		@ "%d " .print
		.cr ; ] 'fxp p8.mapv .cr
	.cr
	;
	
::debugtlmem
	"" .println
	'screen p8.cnt "screen:%d " .println
	'fx p8.cnt "fx:%d " .println
	'fxp p8.cnt "fxp:%d " .println
	timeline> timeline  - "tl:%h " .println
	;
	
|*********DEBUG

::timeline.draw
	dtime
	tictline
	'fx p8.draw
	'screen p8.drawo
	;

::timeline.inimem
	512 'screen p8.ini
	512 'fx p8.ini
	512 'fxp p8.ini
	here 'timeline !
	$ffff 'here +!
	;

