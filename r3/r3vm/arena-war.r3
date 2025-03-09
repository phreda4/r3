| arena war
| PHREDA 2021-2024 (r3)
|-------------------------
^r3/lib/rand.r3
^r3/lib/sdl2gfx.r3

^r3/util/varanim.r3
^r3/util/arr16.r3
^r3/util/ttext.r3
^r3/util/hash2d.r3

^./tedit.r3
^./rcodevm.r3


##imgspr

#tanks 0 0
#disp 0 0
#fx 0 0

::%w sW 16 *>> ; 
::%h sH 16 *>> ; 

##viewpx ##viewpy ##viewpz

##btnpad |  **
##vel
##

| tank
| x y ang anim ss vx vy ar io
| 1 2 3   4    5  6  7  8  9
:.x 1 ncell+ ;
:.y 2 ncell+ ;
:.ang 3 ncell+ ;
:.ani 4 ncell+ ;
:.ss 5 ncell+ ;

:.vx 6 ncell+ ;
:.vy 7 ncell+ ;
:.end 8 ncell+ ;
:.io 9 ncell+ ;
:.color 10 ncell+ ;

:.tfire	6 ncell+ ; | fire range 0..100.0 
:.tfiret 7 ncell+ ; | fire time msec..0
:.tspeed 8 ncell+ ; | speed 		-32.0.. 32.0
:.tspeedd 9 ncell+ ; | speed destino 	
:.angd 10 ncell+ ; | ang destino 0..1
:.tinf 11 ncell+ ; 	| battery/damage


:drawspr | arr -- arr
	dup 8 + >a
	a@+ viewpz *. int. viewpx + 
	a@+ viewpz *. int. viewpy +	| x y
	a@+ dup 32 >> swap | rot
	$ffffffff and viewpz *. | zoom	 
	a@ deltatime + dup a!+ anim>n 			| n
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
	13 b!			| live
	;
	
:+fxexplo | x y --
	'fxobj 'fx p!+ >a
	swap a!+ a!+	| x y 
	rand 32 << 2.0 or a!+			| ang zoom
	15 6 $7f ICS>anim | init cnt scale
	a!+ 
	imgspr a!+	| anim sheet
	0 a!+ 0 a!+ 	| vx vy
	19 a!			| live
	;
	
|------------------- bomb
:disparo | adr --
	dup .end dup @ deltatime - -? ( 
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

:+disparo | dist vel ang x y --
	pick2 neg 0.5 + pick2 pick2 +fxdisp
	'disparo 'disp p!+ >b
	swap b!+ b!+ 
	neg 0.25 + dup 0.25 + 32 << 2.0 or b!+	| angulo zoom
	14 1 0 ICS>anim | init cnt scale
	b!+ | ani
	imgspr b!+ |ss
	swap polar 
	b!+ b!+
	b! | dist
	;

|------------------- player tank
:+disp | dist -- 
	3.0	| vel
	a> .ang @ 32 >> neg 0.5 +
	a> .x @ a> .y @
	pick2 32.0 
	xy+polar | x y bangle r -- x y
	+disparo
	;
	
|------------------------
#xt #yt #dirt

#tfire	| 0..100.0 metros
#tfiret	| msec..0

#tspeed	| -32.0.. 32.0
#tspeedd	

#tturn	| 0..1
#tturnd	| 0..1

#tbatt	| 0..1
#tdama	| 0..1 

:motor | m --
 	a> .ang @ 32 >> neg 0.5 + swap polar 
	a> .y +! a> .x +! ;

:turn | a --
	32 << a> .ang +! ;

:shoot | --
	+disp
	;

:scan | --
	;
	
|--------------------------
:tanima | btn -- btn
	$f and? ( a> .ani dup @ 0 2 $ff vICS>anim swap ! ; )
	a> .ani dup @ 0 0 0 vICS>anim swap ! ;

|:.x 1 ncell+ ;
|:.y 2 ncell+ ;
|:.ang 3 ncell+ ;
|:.ani 4 ncell+ ;
|:.ss 5 ncell+ ;
|:.tfire	6 ncell+ ; | fire range 0..100.0 
|:.tfiret 7 ncell+ ; | fire time msec..0
|:.tspeed 8 ncell+ ; | speed 		-32.0.. 32.0
|:.tspeedd 9 ncell+ ; | speed destino 	
|:.angd 10 ncell+ ; | ang destino 0..1
|:.tinf 11 ncell+ ; 	| battery/damage	

#chspeed 0.1
#chang 0.1

:calctank
| turn
	a> .angd @ a> .ang @ - 
	1? ( | cambiar rotacion
		chang deltatime * *. a> .ang +!
		) drop
| speed	
	a> .tspeedd @ a> .tspeed @ - 
	1? ( | cambiar velocidad
		chspeed deltatime * *. a> .tspeed +!
		) drop	
| motor	
	a> .tspeed @ 
	1? ( | motor encendido
		a> .ang @ 32 >> neg 0.5 +
		over polar 
		a> .y +! a> .x +! 
		) drop
| fire time
	a> .tfiret dup @ 0? ( 2drop ; ) 
	deltatime - 0 max swap ! ; 
	
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
	$10 and? ( 500 +disp btnpad $10 nand 'btnpad ! )
	tanima
	drop
	
	|calctank
	
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
	$10 and? ( 500 +disp a> .io dup @ $f and swap ! )
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
	1.0 'viewpz !

	'fx p.clear
	'tanks p.clear
	'disp p.clear
	
	imgspr
	0 0 0 ICS>anim | init cnt scale -- 
	2.0 0.0 
	0 0 +ptank 
	;



|------------------------
| IO
:ifire  | range --
	tfiret 1? ( drop ; ) drop
	vmpop 32 >> 'tfire !
		btnpad $10 or 'btnpad !
	1000 'tfiret !
	;
	
:igo | vel -- 
	vmpop 32 >> 'tspeedd ! ;
	
:iturn | angle --	
	vmpop 32 >> 'tturnd ! ;

:iscan | angle -- range
	vmpop 32 >>
	|scan
	32 << vmpush ;
	
:ibatt | -- battery
	tbatt 32 << vmpush ;

:idamage | -- dam
	tdama 32 << vmpush ;

:idir | -- dir
	dirt 32 << vmpush ;
	
:ispeed | -- speed
	tspeed 32 << vmpush ;
	
:ipos | -- x y 
	xt 32 << vmpush yt 32 << vmpush ;
	
:isin | ang -- sin
	vmpop 32 >> sin 32 << vmpush ;
:icos | ang -- cos
	vmpop 32 >> cos 32 << vmpush ;
:itan | ang -- tan
	vmpop 32 >> tan 32 << vmpush ;
:itan2 | x y -- ang
	vmpop 32 >> vmpop 32 >> swap atan2 32 << vmpush ;

:irand | max -- rand
	vmpop 32 >> randmax 32 << vmpush ;
:i*.  
	vmpop 32 >> *. 32 << vmpush ;
:i/. 
	vmpop 32 >> /. 32 << vmpush ;
:ifix.
	vmpop 32 >> fix. 32 << vmpush ;
:iint.
	vmpop 32 >> int. 32 << vmpush ;
	

|------ IO interface
##wordt * 256 | 32 words
##words "fire" "go" "turn" "scan" "batt" "damage" "dir" "speed" "pos" 
"sin" "cos" "tan" "tan2" "rand" "*." "/." "fix." "int." 0
##worde	ifire igo iturn iscan ibatt idamage idir ispeed ipos 
isin icos itan itan2 irand i*. i/. ifix. iint. 
##wordd ( $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 ) 

::war.ini
	16 16 "media/img/tank.png" ssload 'imgspr !
	400 'fx p.ini
	100 'tanks p.ini
	1000 'disp p.ini
	1000 H2d.ini 
	
	'wordt 'words vmlistok	
	'wordt 'worde 'wordd vmcpuio
	
	;
