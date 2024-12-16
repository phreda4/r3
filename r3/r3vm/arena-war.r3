| arena war
| PHREDA 2021-2024 (r3)
|-------------------------
^r3/lib/rand.r3
^r3/util/arr16.r3
^r3/lib/sdl2gfx.r3
^r3/util/hash2d.r3
^r3/r3vm/rcodevm.r3

##imgspr

#tanks 0 0
#disp 0 0
#fx 0 0

#viewpx #viewpy

##btnpad |  **

| tank
| x y ang anim ss vx vy ar io
| 1 2 3   4    5  6  7  8  9
:.x 1 ncell+ ;
:.y 2 ncell+ ;
:.a 3 ncell+ ;
:.ani 4 ncell+ ;
:.ss 5 ncell+ ;
:.vx 6 ncell+ ;
:.vy 7 ncell+ ;
:.end 8 ncell+ ;
:.io 9 ncell+ ;
:.color 10 ncell+ ;

:drawspr | arr -- arr
	dup 8 + >a
	a@+ int. viewpx + 
	a@+ int. viewpy +	| x y
	a@+ dup 32 >> swap $ffffffff and | rot zoom
	a@ timer+ dup a!+ anim>n 			| n
	a@+ sspriterz
	;

|------------------- fx
:fxobj | adr --
	dup .ani @ anim>n 
	over .end @ 
	=? ( 2drop 0 ; ) drop 
	drawspr
	|..... add velocity to position
	dup .vx @ over .x +!
	dup .vy @ over .y +!
	drop
	;

:+fxobj | last ss anim zoom ang x y --
	'fxobj 'fx p!+ >a
	swap a!+ a!+	| x y 
	32 << or a!+	| ang zoom
	a!+ a!+			| anim sheet
	0 a!+ 0 a!+ 	| vx vy
	a!				| last
	;

:+fxdisp | ang x y --
	'fxobj 'fx p!+ >b
	swap b!+ b!+	| x y 
	32 << 2.0 or b!+	| ang zoom
	10 4 $7f ICS>anim | init cnt scale
	b!+ 
	imgspr b!+	| anim sheet
	0 b!+ 0 b!+ 	| vx vy
	13 b!			| vrz
	;
	
:+fxexplo | x y --
	'fxobj 'fx p!+ >a
	swap a!+ a!+	| x y 
	rand 32 << 2.0 or a!+			| ang zoom
	15 6 $7f ICS>anim | init cnt scale
	a!+ 
	imgspr a!+	| anim sheet
	0 a!+ 0 a!+ 	| vx vy
	19 a!			| vrz
	;
	
|------------------- bomb
:disparo | adr --
	dup .end dup @ timer- -? ( 
		2drop dup .x @ swap .y @ +fxexplo
		0 ; ) swap !
	drawspr
	|..... add velocity to position
	dup .vx @ over .x +!
	dup .vy @ over .y +!
	
	dup 'disp p.nro | nro
	$1000 or | disp ini 200
	8
	pick2 .x @ int.  | x 
	pick3 .y @ int.  | y
	h2d+!	

	drop
	;

:+disparo | vel ang x y --
	pick2 neg 0.5 + pick2 pick2 +fxdisp
	'disparo 'disp p!+ >b
	swap b!+ b!+ 
	neg 0.25 + dup 0.25 + 32 << 2.0 or b!+	| angulo zoom
	14 1 0 ICS>anim | init cnt scale
	b!+ | ani
	imgspr b!+ |ss
	swap polar 
	b!+ b!+
	1000 b! | dist
	;

|------------------- player tank
:+disp | -- 
	3.0	| vel
	a> .a @ 32 >> neg 0.5 +
	a> .x @ a> .y @
	pick2 32.0 
	xy+polar | x y bangle r -- x y
	+disparo
	;
	
|------------------------
:motor | m --
 	a> .a @ 32 >> neg 0.5 + swap polar 
	a> .y +! a> .x +! ;

:turn | a --
	32 << a> .a +! ;

:shoot | --
	+disp
	;

:scan | --
	;
	
|--------------------------
:tanima | btn -- btn
	$f and? ( a> .ani dup @ 0 2 $ff vICS>anim swap ! ; )
	a> .ani dup @ 0 0 0 vICS>anim swap ! ;
	
:ptank | adr -- adr
	dup >a
	
	a> 'tanks p.nro | nro
	32
	a> .x @ int.  | x 
	a> .y @ int.  | y
	h2d+!
	
	btnpad
	$1 and? ( 0.01 turn )
	$2 and? ( -0.01 turn )
	$4 and? ( -0.4 motor )
	$8 and? ( 0.4 motor )
	$10 and? ( +disp btnpad $10 nand 'btnpad ! )
	tanima
	drop
	drawspr	
	drop
	;

:+ptank | color sheet ani zoom ang x y --
	'ptank 'tanks p!+ >a
	swap a!+ a!+	| x y 
	32 << or a!+	| ang zoom
	a!+ a!+			| anim sheet
	0 a!+ 0 a!+ 	| vx vy
	0 a!+			| end
	;

|------------------- NPC tank
:dtank | adr -- adr
	dup >a
	
	a> 'tanks p.nro | nro
	32
	a> .x @ int.  | x 
	a> .y @ int.  | y
	h2d+!
	
	a> .io @
	$1 and? ( 0.01 turn )
	$2 and? ( -0.01 turn )
	$4 and? ( -0.4 motor )
	$8 and? ( 0.4 motor )
	$10 and? ( +disp a> .io dup @ $f and swap ! )
	tanima
	20 randmax 0? ( $1f randmax a> .io ! ) drop
	drop
	a> .color @ sstint | color
	drawspr	
	ssnotint | sin tint
	drop
	;
	
:+tank | sheet anim zoom ang x y --
	'dtank 'tanks p!+ >a
	swap a!+ a!+	| x y 
	32 << or a!+	| ang zoom
	a!+	a!+			| anim sheet
	0 a!+ 0 a!+ 	| vx vy
	0 a!+			| end
	0 a!+			| io
	a! | color
	;
	
::war.+rtank
	rand $ff000000 or | color
	imgspr 
	0 0 0 ICS>anim | init cnt scale -- 
	2.0 1.0 randmax 
	600.0 randmax 300.0 -
	400.0 randmax 200.0 -
	+tank
	;


::war.draw
	H2d.clear
	'disp p.draw
	'tanks p.draw
	'fx p.draw
	;
	
::war.reset
	sw 1 >> 'viewpx !
	sh 1 >> 'viewpy !

	'fx p.clear
	'tanks p.clear
	'disp p.clear
	
	imgspr
	0 0 0 ICS>anim | init cnt scale -- 
	2.0 0.0 
	0 0 +ptank 
	;

|------------------------
|scan (degree,resolution):range
:iscan
	vmpop
	vmpop
	vmpush
	;
|cannon (degree,range):ok
:ishoot
	vmpop
	vmpop
	vmpush
	;
|drive (degree,speed)
:idrive
	vmpop
	vmpop
	;
:idamage | -- d
	vmpush ;
:ispeed | -- s
	vmpush ;
	
:ipos | -- x y 
	vmpush vmpush ;
:isin | ang -- sin
	vmpop sin vmpush ;
:icos | ang -- cos
	vmpop cos vmpush ;
:itan | ang -- tan
	vmpop tan vmpush ;
:itan2 | x y -- ang
	vmpop vmpop swap atan2 vmpush ;
:irand | max -- rand
	vmpop randmax vmpush ;

|------ IO interface
##wordt * 88

##words "scan" "shoot" "drive" "damage" "speed" "pos" "sin" "cos" "tan" "tan2" "rand" 0
##worde	iscan ishoot idrive idamage ispeed ipos isin icos itan itan2 irand 
##wordd ( $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 ) 

::WAR.ins0
	'wordt 'words vmlistok 
	'wordt 'worde 'wordd vmcpuio
	;
	
::war.ini
	16 16 "media/img/tank.png" ssload 'imgspr !
	400 'fx p.ini
	100 'tanks p.ini
	1000 'disp p.ini
	1000 H2d.ini 
	
	'wordt 'words vmlistok	
	
	;
