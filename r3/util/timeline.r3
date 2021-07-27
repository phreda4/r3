| About timeline
| framerate independient event animation system
| PHREDA 2020
|------------------
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
	( 16 - timeline >=?
		dup @	| time adr time
		pick2 <=? ( drop 16 + ; )
		drop ) 16 + ;

:+tline	| 'fx 'scr event time --
	1000 *.
	timeline> searchless | adr
	dup dup 16 + swap timeline> over - 2 >> move>
	>a a!+ a!+ a!+ a!
	16 'timeline> +! ;

:tictline
	timeline< timenow
	( over
		timeline> =? ( 3drop ; )
		@ >?
		swap
		dup 4 + @ ex
		16 + swap ) drop
	'timeline< ! ;

|-------------------- LOOP
:evt.restart
	'fx p.clear
	timeline 'timeline< !
	timeline.start ;

::+restart | tiempo --
	>r 0 0 'evt.restart r> +tline ;

|-----------------------------
::xy2 | int -- x y
	dup 48 << 48 >> swap 16 >> ;

::2xy | x y -- int
	$ffff and 16 << swap $ffff and or ;

|-------------------- FILLBOX
:drawbox | adr --
	>b b@+ 1 and? ( drop ; ) 8 >> 'ink !
	b@+ xy2 b@+ xy2
	fillbox ;

::+box | x1 y1 x2 y2 color --
	'drawbox 'screen p!+ >a
	8 << 1 or a!+
	2swap
	16 << swap $ffff and or a!+
	16 << swap $ffff and or a!+
	;

|-------------------- SPRITE
:drawsprite | adr --
	>b b@+ 1 and? ( drop ; ) drop
	b@+ dup 48 << 48 >> swap 16 >>
	b@+ dup 48 << 48 >> pick3 - swap 16 >> pick2 -
	b@+ spritesize
	;

::+sprite | spr x1 y1 x2 y2 --
	'drawsprite 'screen p!+ >a
	1 a!+
	2swap
	16 << swap $ffff and or a!+
	16 << swap $ffff and or a!+
	a!+
	;

|-------------------- SPRITE NO SCALE
:drawspriteo | adr --
	>b b@+ 1 and? ( drop ; ) drop
	b@+ dup 48 << 48 >> swap 16 >>
	b@+ drop 
	b@+ sprite
	;

::+spriteo | spr x1 y1 x2 y2 --
	'drawspriteo 'screen p!+ >a
	1 a!+
	2swap
	16 << swap $ffff and or a!+
	16 << swap $ffff and or a!+
	a!+
	;

|-------------------- TEXTBOX
:drawtbox | adr --
	@+ 1 and? ( 2drop ; ) 8 >> 'ink !
	@+ dup 48 << 48 >> 'tx1 ! 16 >> 'ty1 !
	@+ dup 48 << 48 >> 'tx2 ! 16 >> 'ty2 !
	@+ int2pad
	@+
	dup 24 >> $44000000 fxfont! 	| fx --
	dup 16 >> $ff and swap $ffff and
	nfont! 		| nro size --
	@+ swap @ textbox ;

| pad=llllyyxx l=interlineado pady padx 16-8-8
| font=fxfosize 8-8-16
::+textbox | "" fx/font/size pad x1 y1 x2 y2 col --
	'drawtbox 'screen p!+ >a
	8 << 1 or a!+
	2swap
	16 << swap $ffff and or a!+
	16 << swap $ffff and or a!+
	a!+	| pad
	a!+	| font
	a!+	| str
	a!+ | centrado
	;

|-------------------- SONIDO
:evt.play
	dup 8 + @ SPLAY ;

::+sound | sonido inicio --
	0 'evt.play 2swap >r swap r> +tline ;

|-------------------- VIDEO
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

#t0
:interpola
	dup 48 << 48 >> swap 16 >> t0 *. + ;

:interlast
	dup 48 << 48 >> swap 16 >> + ;

:setlastcoor
	a@+ >b
	a@+ interlast $ffff and a@+ interlast 16 << or b!+
	a@+ interlast $ffff and a@+ interlast 16 << or b!+
	;

:getxdx | xy xy -- xy xy xdx
	over 48 << 48 >> over 48 << 48 >> over -
	16 << swap $ffff and or ;

:getydy | xy xy -- ydy
	swap 16 >> swap 16 >> over -
	16 << swap $ffff and or ;

|-----------------------------
:evt.on | adr -- adr
	dup 8 + @ 4 + dup @ 1 not and swap ! ;

::+fx.on | sec --
	>r 0 getscr 'evt.on r> +tline ;

|-----------------------------
:evt.off
	dup 8 + @ 4 + dup @ 1 or swap ! ;

::+fx.off | sec --
	>r 0 getscr 'evt.off r> +tline ;


|...........................
:evt.box-gen | adrp --
	'fx p!+ >a
	dup 12 + @ >b | fxp
	b@+ 1000 *. a!+	| inicio
	1.0 b@+ 1000 *.u /. a!+ | tiempo
    dup 8 + @ 8 + a!+ | scr
   	b@+ b@+ |xy2f xy1f
	b@+ b@+ |xy2i xy1i
	rot getxdx a!+ getydy a!+
	swap getxdx a!+ getydy a!+
	;

:boxa-gen
	a@+ >b
	a@+ interpola $ffff and a@+ interpola 16 << or b!+
	a@+ interpola $ffff and a@+ interpola 16 << or b!+
	;

|-----------------------------
:boxanim0 | screena --
	>a timenow a@+ - a@+ *.
	1.0 >=? ( drop setlastcoor 0 ; )
	't0 ! boxa-gen ;

:evt.lin |
	'boxanim0 evt.box-gen ;

::+fx.lin | xy1 xy2 xy1f xy2f duracion inicio --
	dup >r
	'fxp p! >a a!+ a!+ a!+ a!+ a!+ a!+
	getfx getscr 'evt.lin r> +tline ;

|-----------------------------
:boxanim1 | screena --
	>a timenow a@+ - a@+ *.
	1.0 >=? ( drop setlastcoor 0 ; )
	Quad_In 't0 ! boxa-gen ;

:evt.1 |
	'boxanim1 evt.box-gen ;

::+fx.QuaIn | xy1 xy2 xy1f xy2f duracion inicio --
	dup >r
	'fxp p! >a a!+ a!+ a!+ a!+ a!+ a!+
	getfx getscr 'evt.1 r> +tline ;

|-----------------------------
:boxanim2 | screena --
	>a timenow a@+ - a@+ *.
	1.0 >=? ( drop setlastcoor 0 ; )
	Quad_Out 't0 ! boxa-gen ;

:evt.2 |
	'boxanim2 evt.box-gen ;

::+fx.QuaOut | xy1 xy2 xy1f xy2f duracion inicio --
	dup >r
	'fxp p! >a a!+ a!+ a!+ a!+ a!+ a!+
	getfx getscr 'evt.2 r> +tline ;

|-----------------------------
:boxanim3 | screena --
	>a timenow a@+ - a@+ *.
	1.0 >=? ( drop setlastcoor 0 ; )
	Quad_InOut 't0 ! boxa-gen ;

:evt.3 |
	'boxanim3 evt.box-gen ;

::+fx.QuaIO | xy1 xy2 xy1f xy2f duracion inicio --
	dup >r
	'fxp p! >a a!+ a!+ a!+ a!+ a!+ a!+
	getfx getscr 'evt.3 r> +tline ;

|-----------------------------
:boxanim4 | screena --
	>a timenow a@+ - a@+ *.
	1.0 >=? ( drop setlastcoor 0 ; )
	Sin_In 't0 ! boxa-gen ;

:evt.4 |
	'boxanim4 evt.box-gen ;

::+fx.SinI | xy1 xy2 xy1f xy2f duracion inicio --
	dup >r
	'fxp p! >a a!+ a!+ a!+ a!+ a!+ a!+
	getfx getscr 'evt.4 r> +tline ;

|-----------------------------
:boxanim5 | screena --
	>a timenow a@+ - a@+ *.
	1.0 >=? ( drop setlastcoor 0 ; )
	Sin_Out 't0 ! boxa-gen ;

:evt.5 |
	'boxanim5 evt.box-gen ;

::+fx.SinO | xy1 xy2 xy1f xy2f duracion inicio --
	dup >r
	'fxp p! >a a!+ a!+ a!+ a!+ a!+ a!+
	getfx getscr 'evt.5 r> +tline ;

|-----------------------------
:boxanim6 | screena --
	>a timenow a@+ - a@+ *.
	1.0 >=? ( drop setlastcoor 0 ; )
	Sin_InOut 't0 ! boxa-gen ;

:evt.6 |
	'boxanim6 evt.box-gen ;

::+fx.SinIO | xy1 xy2 xy1f xy2f duracion inicio --
	dup >r
	'fxp p! >a a!+ a!+ a!+ a!+ a!+ a!+
	getfx getscr 'evt.6 r> +tline ;

|-----------------------------
:boxanim7 | screena --
	>a timenow a@+ - a@+ *.
	1.0 >=? ( drop setlastcoor 0 ; )
	Exp_In 't0 ! boxa-gen ;

:evt.7 |
	'boxanim7 evt.box-gen ;

::+fx.ExpIn | xy1 xy2 xy1f xy2f duracion inicio --
	dup >r
	'fxp p! >a a!+ a!+ a!+ a!+ a!+ a!+
	getfx getscr 'evt.7 r> +tline ;

|-----------------------------
:boxanim8 | screena --
	>a timenow a@+ - a@+ *.
	1.0 >=? ( drop setlastcoor 0 ; )
	Exp_Out 't0 ! boxa-gen ;

:evt.8 |
	'boxanim8 evt.box-gen ;

::+fx.ExpOut | xy1 xy2 xy1f xy2f duracion inicio --
	dup >r
	'fxp p! >a a!+ a!+ a!+ a!+ a!+ a!+
	getfx getscr 'evt.8 r> +tline ;

|-----------------------------
:boxanim9 | screena --
	>a timenow a@+ - a@+ *.
	1.0 >=? ( drop setlastcoor 0 ; )
	Exp_InOut 't0 ! boxa-gen ;

:evt.9 |
	'boxanim9 evt.box-gen ;

::+fx.ExpIO | xy1 xy2 xy1f xy2f duracion inicio --
	dup >r
	'fxp p! >a a!+ a!+ a!+ a!+ a!+ a!+
	getfx getscr 'evt.9 r> +tline ;

|-----------------------------
:boxanimA | screena --
	>a timenow a@+ - a@+ *.
	1.0 >=? ( drop setlastcoor 0 ; )
	Ela_In 't0 ! boxa-gen ;

:evt.A |
	'boxanimA evt.box-gen ;

::+fx.ElaIn | xy1 xy2 xy1f xy2f duracion inicio --
	dup >r
	'fxp p! >a a!+ a!+ a!+ a!+ a!+ a!+
	getfx getscr 'evt.A r> +tline ;

|-----------------------------
:boxanimB | screena --
	>a timenow a@+ - a@+ *.
	1.0 >=? ( drop setlastcoor 0 ; )
	Ela_Out 't0 ! boxa-gen ;

:evt.B |
	'boxanimB evt.box-gen ;

::+fx.ElaOut | xy1 xy2 xy1f xy2f duracion inicio --
	dup >r
	'fxp p! >a a!+ a!+ a!+ a!+ a!+ a!+
	getfx getscr 'evt.B r> +tline ;

|-----------------------------
:boxanimC | screena --
	>a timenow a@+ - a@+ *.
	1.0 >=? ( drop setlastcoor 0 ; )
	Ela_InOut 't0 ! boxa-gen ;

:evt.C |
	'boxanimC evt.box-gen ;

::+fx.ElaIO | xy1 xy2 xy1f xy2f duracion inicio --
	dup >r
	'fxp p! >a a!+ a!+ a!+ a!+ a!+ a!+
	getfx getscr 'evt.C r> +tline ;

|-----------------------------
:boxanimD | screena --
	>a timenow a@+ - a@+ *.
	1.0 >=? ( drop setlastcoor 0 ; )
	Bac_In 't0 ! boxa-gen ;

:evt.D |
	'boxanimD evt.box-gen ;

::+fx.BacIn | xy1 xy2 xy1f xy2f duracion inicio --
	dup >r
	'fxp p! >a a!+ a!+ a!+ a!+ a!+ a!+
	getfx getscr 'evt.D r> +tline ;

|-----------------------------
:boxanimE | screena --
	>a timenow a@+ - a@+ *.
	1.0 >=? ( drop setlastcoor 0 ; )
	Bac_Out 't0 ! boxa-gen ;

:evt.E |
	'boxanimE evt.box-gen ;

::+fx.BacOut | xy1 xy2 xy1f xy2f duracion inicio --
	dup >r
	'fxp p! >a a!+ a!+ a!+ a!+ a!+ a!+
	getfx getscr 'evt.E r> +tline ;

|-----------------------------
:boxanimF | screena --
	>a timenow a@+ - a@+ *.
	1.0 >=? ( drop setlastcoor 0 ; )
	Bac_InOut 't0 ! boxa-gen ;

:evt.F |
	'boxanimF evt.box-gen ;

::+fx.BacIO | xy1 xy2 xy1f xy2f duracion inicio --
	dup >r
	'fxp p! >a a!+ a!+ a!+ a!+ a!+ a!+
	getfx getscr 'evt.F r> +tline ;

|-----------------------------
:boxanimG | screena --
	>a timenow a@+ - a@+ *.
	1.0 >=? ( drop setlastcoor 0 ; )
	Bou_Out 't0 ! boxa-gen ;

:evt.G |
	'boxanimG evt.box-gen ;

::+fx.BouOut | xy1 xy2 xy1f xy2f duracion inicio --
	dup >r
	'fxp p! >a a!+ a!+ a!+ a!+ a!+ a!+
	getfx getscr 'evt.G r> +tline ;

|-----------------------------
:boxanimH | screena --
	>a timenow a@+ - a@+ *.
	1.0 >=? ( drop setlastcoor 0 ; )
	Bou_In 't0 ! boxa-gen ;

:evt.H |
	'boxanimH evt.box-gen ;

::+fx.BouIn | xy1 xy2 xy1f xy2f duracion inicio --
	dup >r
	'fxp p! >a a!+ a!+ a!+ a!+ a!+ a!+
	getfx getscr 'evt.H r> +tline ;

|-----------------------------
:boxanimI | screena --
	>a timenow a@+ - a@+ *.
	1.0 >=? ( drop setlastcoor 0 ; )
	Bou_InOut 't0 ! boxa-gen ;

:evt.I |
	'boxanimI evt.box-gen ;

::+fx.BouIO | xy1 xy2 xy1f xy2f duracion inicio --
	dup >r
	'fxp p! >a a!+ a!+ a!+ a!+ a!+ a!+
	getfx getscr 'evt.I r> +tline ;

|-------------------- ANIMADOR size
:animfont
	;

:+fxfont | padi size padif sizef sec peener
	;

|-------------------- ANIMADOR color



|*********DEBUG
:dumptline
	timeline< timeline - 4 >> "%d" print cr
	timeline
	( timeline> <?
		timeline< =? ( "> " print )
		@+ "%d " print
		@+ "%d " print
		@+ "%d " print
		@+ "%d " print cr
		) drop ;

:debugtimeline
	t0 "%f" print cr
	dumptline
	[ dup @+ "%h " print @ "%d" print  cr ; ] 'screen p.mapv cr
	[ dup @+ "%f " print
		@+ "%f " print
		@+ xy2 "%d,%d " print
		@+ xy2 "%d,%d " print
		@+ xy2 "%d,%d " print
		@ xy2 "%d,%d " print
		cr ; ] 'fxp p.mapv cr
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
	$ffff 'here +!
	1024 'screen p.ini
	1024 'fx p.ini
	1024 'fxp p.ini
	;
