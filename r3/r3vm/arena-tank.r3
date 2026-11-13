| arena tank - tanques con script (rcodevm), un cpu por tanque
| PHREDA 2025
|
| tick fijo (30 por segundo):
|  1) cada tanque ejecuta su script con el mismo presupuesto de ciclos
|     (las palabras del script solo anotan intenciones: go turn fire)
|  2) fisica: giro, velocidad, movimiento, disparos, choques, bombas, danio
| el orden de los tanques no cambia el resultado: los sensores leen un
| mundo que no se modifica durante la fase 1
|-------------------------
^r3/lib/rand.r3
^r3/lib/math.r3
^r3/lib/sdl2gfx.r3
^r3/util/varanim.r3
^r3/util/arr16.r3
^r3/util/ttext.r3
^./rcodevm.r3

##tkimg		| spritesheet
##tkpx ##tkpy	| centro de la arena en pantalla
##tkrun		| 0 parado | 1 corriendo | 2 fin del juego | 3 error en un script
##tkerr		| posicion en el fuente del error
##tkwin		| tanque ganador (-1 empate)
##tkticks	| ticks ejecutados
##tktick 33	| ms por tick
##tkbudget 48	| ciclos de cpu por tanque por tick

#tanks 0 0
#bombs 0 0
#fx 0 0

#acc		| tiempo acumulado
#ctank		| tanque que ejecuta su script
#cyc		| ciclos que le quedan
#halt		| 1: termino el programa o error

|------------------- campos
| tanque: x y mov ani img hdg spd hdgd spdd dmg batt cpu pfire cool wait
:.x 8 + ; :.y 16 + ; :.mov 24 + ; :.ani 32 + ; :.img 40 + ;
:.hdg 48 + ; :.spd 56 + ; :.hdgd 64 + ; :.spdd 72 + ;
:.dmg 80 + ; :.batt 88 + ; :.cpu 96 + ; :.pfire 104 + ; :.cool 112 + ; :.wait 120 + ;
| bomba y fx: x y ang ani img . vx vy life own
:.ang 24 + ; :.vx 48 + ; :.vy 56 + ; :.life 64 + ; :.own 72 + ;

:tkid | tank -- nro
	'tanks p.nro ;

:scrx | x -- sx
	int. tkpx + ;
:scry | y -- sy
	int. tkpy + ;

:drawspr | adr -- adr
	dup 8 + >a
	a@+ scrx a@+ scry
	a@+ dup 32 >> swap $ffffffff and	| ang zoom
	a@+ aniFrame a@+ sspriterz ;

|------------------- efectos
:fxobj | adr --
	deltatime over .ani ani+!
	dup .ani @ aniFrame over .life @ =? ( 2drop 0 ; ) drop
	drawspr drop ;

:+fxexplo | x y --
	'fxobj 'fx p!+ >b
	swap b!+ b!+			| x y
	rand 32 << 2.0 or b!+		| ang zoom
	15 7 15.0 aniInit b!+
	tkimg b!+
	0 b!+ 0 b!+
	21 b! ;

:+fxflash | hdg x y --
	'fxobj 'fx p!+ >b
	swap b!+ b!+
	32 << 2.0 or b!+
	10 5 15.0 aniInit b!+
	tkimg b!+
	0 b!+ 0 b!+
	14 b! ;

|------------------- bombas
:bomb.draw | adr --
	dup .life @ -? ( 2drop 0 ; ) drop
	drawspr drop ;

#fs #fc			| seno y -coseno del rumbo
#mx #my

:tank.fire | tank -- tank		; crea el disparo pendiente
	dup .pfire @ 0? ( drop ; ) drop
	dup .hdg @ sincos neg 'fc ! 'fs !
	fs 30.0 *. over .x @ + 'mx !
	fc 30.0 *. over .y @ + 'my !
	'bomb.draw 'bombs p!+ >b
	mx b!+ my b!+
	dup .hdg @ 32 << 2.0 or b!+	| ang zoom
	14 1 0 aniInit b!+
	tkimg b!+
	fs 7.0 *. b!+ fc 7.0 *. b!+	| vx vy
	dup .pfire @ 7.0 /. int. b!+	| ticks de vuelo
	dup tkid b!			| dueno
	0 over .pfire !
	dup .hdg @ mx my +fxflash ;

#bombhit #cbomb #bx #by

:hit1 | tank -- tank		; la bomba toca a este tanque?
	dup .cpu @ 0? ( drop ; ) drop
	dup tkid cbomb .own @ =? ( drop ; ) drop
	dup .x @ cbomb .x @ - int. dup *
	over .y @ cbomb .y @ - int. dup * +
	196 >? ( drop ; ) drop
	1 'bombhit ! ;

:dmg1 | tank -- tank		; danio de la explosion en bx by
	dup .cpu @ 0? ( drop ; ) drop
	dup .x @ bx - int. dup *
	over .y @ by - int. dup * +
	676 >? ( drop ; ) drop
	0.25 over .dmg +! ;

:bomb.tick | adr -- adr
	dup .life @ -? ( drop ; ) drop
	dup 'cbomb !
	dup .vx @ over .x +!
	dup .vy @ over .y +!
	-1 over .life +!
	0 'bombhit !
	'hit1 'tanks p.mapv
	dup .x @ abs 256.0 >? ( 1 'bombhit ! ) drop
	dup .y @ abs 256.0 >? ( 1 'bombhit ! ) drop
	dup .life @ 1 <? ( 1 'bombhit ! ) drop
	bombhit 0? ( drop ; ) drop
	dup .x @ 'bx ! dup .y @ 'by !
	-1 over .life !			| marcada para borrar
	bx by +fxexplo
	'dmg1 'tanks p.mapv ;

|------------------- tanque: fisica
:turn1 | tank -- tank
	dup .hdgd @ over .hdg @ - $ffff and 0.5 >? ( 1.0 - )
	-0.012 max 0.012 min
	over .hdg @ + $ffff and over .hdg ! ;

:speed1 | tank -- tank
	dup .spdd @ over .spd @ -
	-0.04 max 0.04 min
	over .spd @ + over .spd ! ;

:move1 | tank -- tank
	dup .hdg @ sincos neg 'fc ! 'fs !
	dup .spd @ 2.5 *.
	dup fs *. pick2 .x +!
	fc *. over .y +! ;

:clamp1 | tank -- tank
	dup .x @ -242.0 max 242.0 min over .x !
	dup .y @ -242.0 max 242.0 min over .y ! ;

:tank.tick | tank -- tank
	dup .cpu @ 0? ( drop ; ) drop
	dup .cool @ 1? ( -1 pick2 .cool +! ) drop
	dup .batt @ 1.0 <? ( 0.004 pick2 .batt +! ) drop
	turn1 speed1 move1 clamp1
	tank.fire ;

#px #py #pp #pd

:tt.pair | a b -- a b		; choque entre dos tanques (simetrico)
	over .cpu @ 0? ( drop ; ) drop
	dup .cpu @ 0? ( drop ; ) drop
	over .x @ over .x @ - 'px !
	over .y @ over .y @ - 'py !
	px int. dup * py int. dup * +
	784 >=? ( drop ; )
	sqrt fix. 0.5 max 'pd !
	28.0 pd - 1 >> 'pp !
	px pd /. pp *. 'px !
	py pd /. pp *. 'py !
	px over .x +! py over .y +!
	swap
	px neg over .x +! py neg over .y +!
	swap ;

:tank.dead | tank -- tank
	dup .cpu @ 0? ( drop ; ) drop
	dup .dmg @ 1.0 <? ( drop ; ) drop
	0 over .cpu !
	0 over .spd ! 0 over .spdd !
	dup .x @ over .y @ +fxexplo ;

#nalive #lastalive
:count1 | tank -- tank
	dup .cpu @ 0? ( drop ; ) drop
	1 'nalive +! dup 'lastalive ! ;

:endcheck
	0 'nalive ! 'count1 'tanks p.mapv
	'tanks p.cnt 2 <? ( drop ; ) drop
	nalive 2 >=? ( drop ; ) drop
	2 'tkrun ! -1 'tkwin !
	nalive 1? ( lastalive tkid 'tkwin ! ) drop ;

|------------------- cpu
:vmtick1 | --
	-1 'cyc +!
	ip 0? ( drop 0 'cyc ! 1 'halt ! ; ) drop
	vmstepip
	terror 1 >? ( 0 'cyc ! 1 'halt ! ) drop ;

:slice | tank -- tank		; turno de cpu de un tanque
	dup .cpu @ 0? ( drop ; ) drop
	dup .wait @ 1? ( drop -1 over .wait +! ; ) drop
	dup 'ctank !
	tkbudget 'cyc !
	0 'halt ! 0 'terror !
	dup .cpu @ vm@
	( cyc 0 >? drop vmtick1 ) drop
	terror 1 >? ( drop ip 8 - vm2src 'tkerr ! 3 'tkrun ! ; ) drop
	halt 1? ( 1000000000 pick2 .wait ! ) drop	| fin del programa
	dup .cpu @ vm! ;

|------------------- palabras del script
:ifire | range --
	vmpop 32 >>
	0 'cyc !
	ctank .cool @ 1? ( 2drop ; ) drop
	ctank .batt @ 0.12 <? ( 2drop ; ) drop
	24.0 max 300.0 min ctank .pfire !
	-0.12 ctank .batt +!
	20 ctank .cool ! ;

:igo | speed --
	vmpop 32 >> -1.0 max 1.0 min ctank .spdd ! ;

:iturn | angle --
	vmpop 32 >> $ffff and ctank .hdgd ! ;

:adiff | a b -- |a-b|
	- $ffff and 0.5 >? ( 1.0 swap - ) ;

:tdist | dx dy -- dist
	int. dup * swap int. dup * + sqrt fix. ;

:tbear | dx dy -- heading
	atan2 0.25 + $ffff and ;

#sang #sbest #sdx #sdy
:scan1 | tank -- tank
	dup ctank =? ( drop ; ) drop
	dup .cpu @ 0? ( drop ; ) drop
	dup .x @ ctank .x @ - 'sdx !
	dup .y @ ctank .y @ - 'sdy !
	sdx sdy tbear sang adiff 0.015 >? ( drop ; ) drop
	sdx sdy tdist
	dup sbest <? ( 'sbest ! drop ; ) 2drop ;

:iscan | angle -- range
	vmpop 32 >> $ffff and 'sang !
	$7fffffff 'sbest !
	'scan1 'tanks p.mapv
	sbest $7fffffff =? ( drop 0 ) 32 << vmpush
	-6 'cyc +! ;

:ibatt | -- battery
	ctank .batt @ 32 << vmpush ;

:idamage | -- damage
	ctank .dmg @ 32 << vmpush ;

:idir | -- heading
	ctank .hdg @ 32 << vmpush ;

:ispeed | -- speed
	ctank .spd @ 32 << vmpush ;

:ipos | -- x y
	ctank .x @ 32 << vmpush ctank .y @ 32 << vmpush ;

:iid | -- nro
	ctank tkid 32 << vmpush ;

:iwait | ticks --
	vmpop 32 >> ctank .wait ! 0 'cyc ! ;

:ibear | dx dy -- heading
	vmpop 32 >> vmpop 32 >> swap tbear 32 << vmpush ;

:isin | ang -- sin
	vmpop 32 >> sin 32 << vmpush ;
:icos | ang -- cos
	vmpop 32 >> cos 32 << vmpush ;
:irand | max -- rand
	vmpop 32 >> randmax 32 << vmpush ;
:i*.
	vmpop 32 >> vmpop 32 >> *. 32 << vmpush ;
:i/.
	vmpop 32 >> vmpop 32 >> swap 0? ( 2drop 0 vmpush ; ) /. 32 << vmpush ;
:ifix.
	vmpop 32 >> fix. 32 << vmpush ;
:iint.
	vmpop 32 >> int. 32 << vmpush ;

|------ interfaz del script
#wordt * 512
#words "fire" "go" "turn" "scan" "batt" "damage" "dir" "speed" "pos" "id" "wait" "bear"
"sin" "cos" "rand" "*." "/." "fix." "int." 0
#worde ifire igo iturn iscan ibatt idamage idir ispeed ipos iid iwait ibear
isin icos irand i*. i/. ifix. iint.
#wordd ( $f1 $f1 $f1 $01 $10 $10 $10 $10 $20 $10 $f1 $f2 $01 $01 $01 $f2 $f2 $01 $01 )

|------------------- dibujo
#ctk
#tkcols $ff5080ff $ffff5050 $ff50ff50 $ffffe050
#bw

:tkcolor | -- argb
	ctk .cpu @ 0? ( drop $ff404040 ; ) drop
	ctk tkid 3 and 3 << 'tkcols + @ ;

:tkmode | -- 0 quieto | 1 mueve | 2 muerto
	ctk .cpu @ 0? ( drop 2 ; ) drop
	ctk .spd @ abs 0.03 >? ( drop 1 ; ) drop
	0 ;

:tkanim | --		; cada tanque avanza su propia animacion
	deltatime ctk .ani ani+!
	tkmode ctk .mov @ =? ( drop ; )
	dup ctk .mov !
	0? ( drop 0 0 0 aniInit ctk .ani ! ; )
	1 =? ( drop 0 2 12.0 aniInit ctk .ani ! ; )
	drop 2 1 0 aniInit ctk .ani ! ;

:hpbar | --
	ctk .cpu @ 0? ( drop ; ) drop
	1.0 ctk .dmg @ - 28 * int. 2 max 'bw !
	ctk .x @ scrx 14 - ctk .y @ scry 30 -
	$202020 color 2dup 28 5 frect
	$30e030 color ctk .dmg @ 0.5 >? ( $e03030 color ) drop
	2dup bw 5 frect
	1.0 tsize 6 tcol
	over 10 + over 12 - tat ctk tkid 1+ "%d" tprint
	2drop ;

:tank.draw | adr --
	'ctk !
	tkanim
	tkcolor sstint
	ctk .x @ scrx ctk .y @ scry
	ctk .hdg @ 2.0
	ctk .ani @ aniFrame tkimg sspriterz
	ssnotint
	hpbar ;

#ti #tj
:floor1
	ti 5 << tkpx + 240 -  tj 5 << tkpy + 240 -  2.0
	ti tj 3 * xor 3 and 21 +  tkimg sspritez ;

:floor
	0 ( 16 <? dup 'ti !
		0 ( 16 <? dup 'tj ! floor1 1+ ) drop
		1+ ) drop ;

:edge? | -- 0/1
	ti 0? ( drop 1 ; ) 17 =? ( drop 1 ; ) drop
	tj 0? ( drop 1 ; ) 17 =? ( drop 1 ; ) drop
	0 ;

:wall1
	ti 5 << tkpx + 272 -  tj 5 << tkpy + 272 -  2.0
	ti tj + 1 and 3 +  tkimg sspritez ;

:walls
	0 ( 18 <? dup 'ti !
		0 ( 18 <? dup 'tj ! edge? 1? ( wall1 ) drop 1+ ) drop
		1+ ) drop ;

::tk.draw
	floor walls
	'bombs p.draw
	'tanks p.draw
	'fx p.draw ;

|------------------- API
::tk.ini
	16 16 "media/img/tank.png" ssload 'tkimg !
	16 'tanks p.ini
	400 'bombs p.ini
	400 'fx p.ini
	'wordt 'words vmlistok
	'wordt 'worde 'wordd vmcpuio ;

::tk.reset
	'tanks p.clear 'bombs p.clear 'fx p.clear
	0 'acc ! 0 'tkticks ! -1 'tkwin ! 1 'tkrun ! ;

#tcpu
::tk.+tank | hdg x y --		; tanque nuevo con su cpu (codigo ya compilado)
	vmcpu 'tcpu !
	'tank.draw 'tanks p!+ >a
	swap a!+ a!+			| x y
	0 a!+				| mov
	0 0 0 aniInit a!+		| ani
	tkimg a!+
	dup a!+ 0 a!+ a!+ 0 a!+		| hdg spd hdgd spdd
	0 a!+ 1.0 a!+			| dmg batt
	tcpu a!+
	0 a!+ 0 a!+ 0 a! ;		| pfire cool wait

::tk.tick
	tkrun 1 <>? ( drop ; ) drop
	1 'tkticks +!
	'slice 'tanks p.mapv
	tkrun 1 <>? ( drop ; ) drop
	'tank.tick 'tanks p.mapv
	'tt.pair 'tanks p.map2
	'clamp1 'tanks p.mapv
	'bomb.tick 'bombs p.mapv
	'tank.dead 'tanks p.mapv
	endcheck ;

::tk.update | --		; tiempo real -> ticks fijos
	tkrun 1 <>? ( drop ; ) drop
	deltatime 100 min acc + 'acc !
	( acc tktick >=? drop
		tk.tick
		tktick neg 'acc +!
		) drop ;

::tk.sel | n --		; carga el cpu del tanque n como cpu actual (para el editor)
	'tanks p.adr .cpu @ 0? ( drop ; ) vm@ ;

::tk.cnt | -- n
	'tanks p.cnt ;
